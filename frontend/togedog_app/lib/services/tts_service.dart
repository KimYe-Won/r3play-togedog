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

      if (info.minBboxArea != null) {
        final area = d.boundingBox.width * d.boundingBox.height;
        if (area < info.minBboxArea!) continue;
      }

      detectedLabels.add(d.className);
      // 동일 라벨 다중 검출 시 마지막 검출의 중심 x 사용
      centerXByLabel[d.className] =
          d.boundingBox.left + d.boundingBox.width / 2;
    }

    // 2. 감지된 라벨은 증가, 감지 안 된 라벨은 리셋
    for (final label in _dangerMap.keys) {
      if (detectedLabels.contains(label)) {
        _frameCount[label] = (_frameCount[label] ?? 0) + 1;
      } else {
        _frameCount[label] = 0;
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

    // 4. 발화 (쿨다운 이미 경쟁 단계에서 검증)
    _lastSpokeMap[topLabel] = now;
    _tts.speak(_buildMessage(topDanger, topCenterX));
    _vibrate(topDanger.priority);
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
      case 1: Vibration.vibrate(duration: 300); break; // 위험
      case 2: Vibration.vibrate(duration: 150); break; // 경고
      case 3: Vibration.vibrate(duration: 80);  break; // 조심
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
