import 'dart:async';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:vibration/vibration.dart';
// 백엔드 연동
import 'backend_sync_service.dart';

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
    'person':           _DangerInfo(1, '사람이 있습니다', minBboxArea: 0.12, minFrames: 4),
    'stairs':           _DangerInfo(1, '계단이 감지되었습니다', minFrames: 2),
    'car':              _DangerInfo(1, '차량이 접근하고 있습니다', minFrames: 2),
    'bicycle':          _DangerInfo(1, '자전거가 접근하고 있습니다', minFrames: 2),
    'scooter':          _DangerInfo(1, '킥보드가 접근하고 있습니다', minFrames: 2),
    'motorcycle':       _DangerInfo(1, '오토바이가 접근하고 있습니다', minFrames: 2),
    'dog':              _DangerInfo(2, '전방에 다른 강아지가 접근하고 있습니다', useDirection: false, minFrames: 2),
    'chair':            _DangerInfo(2, '의자가 있습니다', minFrames: 2),
    'table':            _DangerInfo(2, '테이블이 있습니다', minFrames: 2),
    'pole_obstacle':    _DangerInfo(3, '장애물이 있습니다', minFrames: 3),
    'crosswalk':        _DangerInfo(3, '전방에 횡단보도입니다', useDirection: false, minFrames: 3),
    'traffic_light':    _DangerInfo(3, '전방에 신호등이 감지되었습니다', useDirection: false, minFrames: 3),
  };

  static const double _minConfidence = 0.5;
  static const Duration _highCooldown = Duration(seconds: 4);
  static const Duration _cooldown = Duration(seconds: 5);

  bool speechEnabled = true;
  // 모드별 진동 사용 여부. 소리(시각장애인) 모드=false, 진동(청각장애인) 모드=true.
  bool vibrationEnabled = true;

  // per-label cooldown tracking
  final Map<String, DateTime> _lastSpokeMap = {};
  // per-label 연속 감지 프레임 수 추적 (temporal consistency)
  final Map<String, int> _frameCount = {};
  StreamSubscription<List<YOLOResult>>? _subscription;

  Future<void> init() async {
    // 진단용 핸들러: speak가 실제로 시작/완료/에러 중 무엇인지 로그로 확인한다.
    _tts.setStartHandler(() => debugPrint('[TTS] start'));
    _tts.setCompletionHandler(() => debugPrint('[TTS] complete'));
    _tts.setCancelHandler(() => debugPrint('[TTS] cancel'));
    _tts.setErrorHandler((msg) => debugPrint('[TTS] error: $msg'));

    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    // WebRTC가 오디오를 통신모드로 잡고 있어도 안내 음성이 재생되도록,
    // TTS 출력을 '내비게이션 안내'(USAGE_ASSISTANCE_NAVIGATION_GUIDANCE) 속성으로 설정한다.
    try {
      await _tts.setAudioAttributesForNavigation();
    } catch (_) {
      // 일부 기기/엔진 미지원 시 무시(기본 속성 사용).
    }

    // 엔진/언어 가용성 진단
    try {
      final engines = await _tts.getEngines;
      final koAvailable = await _tts.isLanguageAvailable('ko-KR');
      debugPrint('[TTS] engines=$engines koAvailable=$koAvailable');
    } catch (e) {
      debugPrint('[TTS] diag error: $e');
    }
  }

  void listen(Stream<List<YOLOResult>> stream) {
    _subscription?.cancel();
    _subscription = stream.listen(processDetections);
  }

  void processDetections(List<YOLOResult> detections) {

    // 1. 현재 프레임에서 confidence + minBboxArea 필터를 통과한 라벨 집합 + 그 박스
    final Set<String> detectedLabels = {};
    final Map<String, Rect> boxByLabel = {};

    for (final d in detections) {
      if (d.confidence < _minConfidence) continue;
      final info = _dangerMap[d.className];
      if (info == null) continue;

      // normalizedBox(0~1)를 써야 한다. boundingBox는 픽셀 좌표라
      // area 임계값(0~1)·방향(centerX 0.35/0.65) 비교가 전부 틀어진다(항상 '오른쪽'으로 나옴).
      final box = d.normalizedBox;

      if (info.minBboxArea != null) {
        final area = box.width * box.height;
        if (area < info.minBboxArea!) continue;
      }

      detectedLabels.add(d.className);
      // 동일 라벨 다중 검출 시 마지막 검출의 박스 사용
      boxByLabel[d.className] = box;
    }

    // 2. 감지된 라벨은 증가, 감지 안 된 라벨은 감쇠(-1).
    //    하드 리셋(0)은 YOLO 박스가 한 프레임만 깜빡여도 누적을 날려 minFrames를
    //    못 채우게 한다. 감쇠는 짧은 미검출을 견디고 지속 검출만 누적되게 한다.
    for (final label in _dangerMap.keys) {
      if (detectedLabels.contains(label)) {
        _frameCount[label] = (_frameCount[label] ?? 0) + 1;
      } else {
        final count = _frameCount[label] ?? 0;
        if (count > 0) _frameCount[label] = count - 1;
      }
    }

    // 3. minFrames + 쿨다운 통과한 라벨들 중에서만 우선순위 경쟁
    _DangerInfo? topDanger;
    String? topLabel;
    Rect topBox = const Rect.fromLTRB(0.35, 0, 0.65, 1); // 기본=전방
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
        topBox = boxByLabel[label] ?? topBox;
      }
    }

    if (topDanger == null || topLabel == null) return;

    // 4. 발화 (쿨다운 이미 경쟁 단계에서 검증)
    _lastSpokeMap[topLabel] = now;
    final message = _buildMessage(topDanger, topBox);
    debugPrint(
        '[TTS] fire label=$topLabel speech=$speechEnabled vib=$vibrationEnabled msg="$message"');
    
    // [백엔드 연동] 위험 감지 → RTDB 저장
    unawaited(
      BackendSyncService.instance.sendDangerDetection(
        className: topLabel,
        priority: topDanger.priority,
        notificationMessage: message,
      ),
    );
    
    if (speechEnabled) _speak(message);
    if (vibrationEnabled) _vibrate(topDanger.priority);
  }

  Future<void> _speak(String message) async {
    final result = await _tts.speak(message);
    debugPrint('[TTS] speak ret=$result');
  }

  // 박스 위치로 방향 prefix를 붙여 최종 메시지 생성.
  // 경로(중앙선 x=0.5) 기준: 박스가 중앙선을 가로지르면 '전방'(내 경로 위),
  // 완전히 왼쪽이면 '왼쪽', 완전히 오른쪽이면 '오른쪽'.
  // → 코앞에 크게 잡혀 경로를 막는 물체는 중심이 약간 치우쳐도 '전방'으로 안내한다.
  String _buildMessage(_DangerInfo info, Rect box) {
    if (!info.useDirection) return info.message;

    const center = 0.5;
    final String direction;
    if (box.left <= center && box.right >= center) {
      direction = '전방에';
    } else if (box.right < center) {
      direction = '왼쪽에';
    } else {
      direction = '오른쪽에';
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
