import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:vibration/vibration.dart';

class _DangerInfo {
  const _DangerInfo(
    this.priority,
    this.message, {
    this.minBboxArea,
    this.useDirection = true,
    this.minFrames = 1,
  });
  final int priority;   // 낮을수록 위험 (1 = 최고 위험)
  final String message;
  final double? minBboxArea; // normalized area threshold (width*height, 0~1)
  final bool useDirection; // 방향 prefix(왼쪽/오른쪽/전방) 사용 여부
  final int minFrames; // 연속 감지 최소 프레임 수 (1 = 필터 없음)
}

class TtsService {
  final FlutterTts _tts = FlutterTts();

  // best_v3_float16.tflite 12클래스 — 위험 순위 + 한국어 알림 문구
  // priority 1=위험(4초쿨다운), 2=경고/3=조심(5초쿨다운)
  static const Map<String, _DangerInfo> _dangerMap = {
    'person':           _DangerInfo(1, '사람이 있습니다', minBboxArea: 0.12, minFrames: 10),
    'stairs':           _DangerInfo(1, '계단이 감지되었습니다', minFrames: 5),
    'car':              _DangerInfo(1, '차량이 접근하고 있습니다', minFrames: 3),
    'bicycle':          _DangerInfo(1, '자전거가 접근하고 있습니다', minFrames: 3),
    'scooter':          _DangerInfo(1, '킥보드가 접근하고 있습니다', minFrames: 3),
    'motorcycle':       _DangerInfo(1, '오토바이가 접근하고 있습니다', minFrames: 3),
    'dog':              _DangerInfo(2, '전방에 다른 강아지가 접근하고 있습니다', useDirection: false, minFrames: 5),
    'chair':            _DangerInfo(2, '의자가 있습니다', minFrames: 5),
    'table':            _DangerInfo(2, '테이블이 있습니다', minFrames: 5),
    'pole_obstacle':    _DangerInfo(3, '장애물이 있습니다', minFrames: 8),
    'crosswalk':        _DangerInfo(3, '전방에 횡단보도입니다', useDirection: false, minFrames: 8),
    'traffic_light':    _DangerInfo(3, '전방에 신호등이 감지되었습니다', useDirection: false, minFrames: 8),
  };

  static const double _minConfidence = 0.5;
  static const Duration _highCooldown = Duration(seconds: 4);
  static const Duration _cooldown = Duration(seconds: 5);

  bool speechEnabled = true;
  bool vibrationEnabled = true;

  // per-label cooldown tracking
  final Map<String, DateTime> _lastSpokeMap = {};
  // per-label 연속 감지 프레임 수 추적 (temporal consistency)
  final Map<String, int> _frameCount = {};
  StreamSubscription<List<YOLOResult>>? _subscription;

  Future<void> init() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  void listen(Stream<List<YOLOResult>> stream) {
    _subscription?.cancel();
    _subscription = stream.listen(processDetections);
  }

  void processDetections(List<YOLOResult> detections) {
    // 1. 현재 프레임에서 confidence + minBboxArea 필터를 통과한 라벨 집합 + 그 중심 x 좌표
    final Set<String> detectedLabels = {};
    final Map<String, double> centerXByLabel = {};

    for (final d in detections) {
      if (d.confidence < _minConfidence) continue;
      final info = _dangerMap[d.className];
      if (info == null) continue;

      // YOLOResult.boundingBox는 픽셀 좌표, normalizedBox가 0~1. 면적·방향 판단은 정규화 좌표로 한다.
      if (info.minBboxArea != null) {
        final area = d.normalizedBox.width * d.normalizedBox.height;
        if (area < info.minBboxArea!) continue;
      }

      detectedLabels.add(d.className);
      // 동일 라벨 다중 검출 시 마지막 검출의 중심 x 사용
      centerXByLabel[d.className] =
          d.normalizedBox.left + d.normalizedBox.width / 2;
    }

    // 2. 감지된 라벨은 증가(minFrames에서 상한), 감지 안 된 라벨은 1씩 감소(decay).
    //    한두 프레임 깜빡임에도 누적이 유지되고, 객체가 사라지면 곧 임계 아래로 떨어진다.
    for (final entry in _dangerMap.entries) {
      final label = entry.key;
      final minFrames = entry.value.minFrames;
      final current = _frameCount[label] ?? 0;
      if (detectedLabels.contains(label)) {
        _frameCount[label] = current + 1 > minFrames ? minFrames : current + 1;
      } else {
        _frameCount[label] = current > 0 ? current - 1 : 0;
      }
    }

    // 3. minFrames + 쿨다운 통과한 라벨들 중에서만 우선순위 경쟁
    _DangerInfo? topDanger;
    String? topLabel;
    double topCenterX = 0.5;
    final now = DateTime.now();

    for (final label in detectedLabels) {
      final info = _dangerMap[label]!;
      if ((_frameCount[label] ?? 0) < info.minFrames) continue;

      final cd = info.priority == 1 ? _highCooldown : _cooldown;
      final last = _lastSpokeMap[label];
      if (last != null && now.difference(last) < cd) continue;

      if (topDanger == null || info.priority < topDanger.priority) {
        topDanger = info;
        topLabel = label;
        topCenterX = centerXByLabel[label] ?? 0.5;
      }
    }

    if (topDanger == null || topLabel == null) return;

    // 4. 발화/진동 (쿨다운 이미 경쟁 단계에서 검증). 채널은 안내 모드에 따라 켜고 끈다.
    _lastSpokeMap[topLabel] = now;
    if (speechEnabled) _tts.speak(_buildMessage(topDanger, topCenterX));
    if (vibrationEnabled) _vibrate(topDanger.priority);
  }

  // bbox 중심 x 좌표로 방향 prefix를 붙여 최종 메시지 생성
  String _buildMessage(_DangerInfo info, double centerX) {
    if (!info.useDirection) return info.message;

    final String direction;
    if (centerX < 0.35) {
      direction = '왼쪽에';
    } else if (centerX > 0.65) {
      direction = '오른쪽에';
    } else {
      direction = '전방에';
    }
    return '$direction ${info.message}';
  }

  Future<void> _vibrate(int priority) async {
    if ((await Vibration.hasVibrator()) != true) return;
    switch (priority) {
      case 1: // 위험 — 강한 진동 1회 (800ms)
        Vibration.vibrate(pattern: [0, 800], intensities: [0, 255]);
        break;
      case 2: // 경고 — 중간 진동 3회 (250ms × 3)
        Vibration.vibrate(
          pattern: [0, 250, 120, 250, 120, 250],
          intensities: [0, 180, 0, 180, 0, 180],
        );
        break;
      case 3: // 조심 — 약한 진동 2회 (150ms × 2)
        Vibration.vibrate(
          pattern: [0, 150, 100, 150],
          intensities: [0, 120, 0, 120],
        );
        break;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _tts.stop();
  }
}
