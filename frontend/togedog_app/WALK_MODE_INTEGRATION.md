# 산책모드 통합 가이드 (AI 에이전트용)

## 개요

`togedog_app`의 산책모드는 세 개의 서비스가 이미 완성되어 있다.
UI 화면 코드를 추가하고 이 서비스들을 연결하는 것이 작업 목표.

- `lib/services/walk_service.dart` — WebRTC 수신 + YOLO 시각 추론
- `lib/services/tts_service.dart` — 시각 위험 감지 → 한국어 TTS 발화
- `lib/services/audio_service.dart` — YAMNet 청각 감지 → 진동 + 화면 배너
- `lib/widgets/audio_alert_banner.dart` — 오디오 알림 오버레이 배너 위젯

**절대 수정하지 말 것**: 위 두 파일은 건드리지 않는다.

---

## 필수 사전 작업 (AndroidManifest.xml)

`android/app/src/main/AndroidManifest.xml`에 아래 항목들이 **누락**되어 있다. 반드시 추가해야 앱이 정상 동작한다.

### 1. 권한 추가 (`<manifest>` 바로 아래)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

### 2. WorkManager 크래시 수정 (`<application>` 안에 추가)

Android 16(API 36) 환경에서 WorkManager 초기화 충돌이 발생한다. `</application>` 닫기 전에 추가:

```xml
<provider
    android:name="androidx.startup.InitializationProvider"
    android:authorities="${applicationId}.androidx-startup"
    android:exported="false"
    tools:node="merge">
    <meta-data
        android:name="androidx.work.WorkManagerInitializer"
        android:value="androidx.startup"
        tools:node="remove" />
</provider>
```

`xmlns:tools="http://schemas.android.com/tools"` 를 `<manifest>` 태그에 추가해야 `tools:node`가 동작한다.

---

## 서비스 API

### WalkService

```dart
final walkService = WalkService(modelPath: 'assets/best_v3_float16.tflite');

await walkService.init();               // 렌더러 초기화 (한 번만)
bool ok = await walkService.connect(senderIp); // IP 입력받아 연결
await walkService.disconnect();         // 연결 해제
await walkService.dispose();            // 화면 종료 시 반드시 호출

walkService.isConnected                 // bool — 연결 상태
walkService.remoteRenderer              // RTCVideoRenderer — 영상 표시용
walkService.detectionStream             // Stream<List<YOLOResult>> — YOLO 감지 결과
walkService.errorStream                 // Stream<String> — 오류 메시지
```

### TtsService

```dart
final ttsService = TtsService();

await ttsService.init();                        // TTS 엔진 초기화
ttsService.listen(walkService.detectionStream); // 감지 스트림 연결 (connect 전에 해도 됨)
await ttsService.stop();                        // TTS 발화 중단
await ttsService.dispose();                     // 화면 종료 시 반드시 호출
```

---

## 산책모드 화면 연결 순서

```dart
// 1. 선언
late final WalkService _walkService;
late final TtsService _ttsService;

// 2. initState
@override
void initState() {
  super.initState();
  _walkService = WalkService(modelPath: 'assets/best_v3_float16.tflite');
  _ttsService = TtsService();
  _init();
}

Future<void> _init() async {
  await _walkService.init();
  await _ttsService.init();
  _ttsService.listen(_walkService.detectionStream);
  // 에러 스트림 구독 (필요 시 UI에 표시)
  _walkService.errorStream.listen((msg) { /* 오류 처리 */ });
}

// 3. 연결 버튼 액션 (senderIp는 사용자가 입력하는 강아지 폰 IP)
Future<void> _connect(String senderIp) async {
  final ok = await _walkService.connect(senderIp);
  if (!ok) { /* 연결 실패 처리 */ }
}

// 4. 영상 표시 위젯
RTCVideoView(
  _walkService.remoteRenderer,
  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
)

// 5. dispose
@override
void dispose() {
  _ttsService.dispose();
  _walkService.dispose();
  super.dispose();
}
```

---

## 런타임 권한 처리

`permission_handler` 패키지가 이미 `pubspec.yaml`에 포함되어 있다.
산책모드 화면 진입 전 또는 initState에서 카메라 권한을 요청해야 한다.

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> _requestPermissions() async {
  await [Permission.camera, Permission.microphone].request();
}
```

---

## 모델 에셋

`pubspec.yaml`에 이미 등록되어 있음:

```yaml
flutter:
  assets:
    - assets/best_v3_float16.tflite
```

파일 경로: `assets/best_v3_float16.tflite` (39MB, YOLO26m 커스텀 12클래스 float16)

---

## 서비스 전체 소스 (수정 금지)

### lib/services/walk_service.dart

```dart
import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:yolo_live_stream/yolo_live_stream.dart';

class WalkService {
  WalkService({required this.modelPath});

  final String modelPath;

  late final LiveStreamingConnector _connector;
  late final YoloAnalyzer _analyzer;

  bool _initialized = false;

  final _detectionController = StreamController<List<YOLOResult>>.broadcast();

  Stream<List<YOLOResult>> get detectionStream => _detectionController.stream;
  bool get isConnected => _initialized && _connector.isConnected;
  RTCVideoRenderer get remoteRenderer => _connector.remoteRenderer;

  Future<void> init() async {
    if (_initialized) return;
    _connector = LiveStreamingConnector(
      onUpdate: _onConnectorUpdate,
      onError: _onConnectorError,
    );
    _analyzer = YoloAnalyzer(
      onUpdate: _onAnalyzerUpdate,
      getRemoteTrack: () => _connector.remoteVideoTrack,
      customModelPath: modelPath,
    );
    await _connector.initRenderers();
    _initialized = true;
  }

  Future<bool> connect(String senderIp) async {
    await init();
    final ok = await _connector.startAsReceiver(senderIp);
    if (ok) await _analyzer.start();
    return ok;
  }

  Future<void> disconnect() async {
    if (!_initialized) return;
    _analyzer.stop();
    await _connector.close();
  }

  Future<void> dispose() async {
    if (!_initialized) return;
    await disconnect();
    await _analyzer.dispose();
    await _connector.dispose();
    await _detectionController.close();
    _initialized = false;
  }

  void _onConnectorUpdate() {}

  void _onConnectorError(String message) {
    _errorController.add(message);
  }

  void _onAnalyzerUpdate() {
    if (!_detectionController.isClosed) {
      _detectionController.add(_analyzer.detections);
    }
  }

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;
}
```

### lib/services/tts_service.dart

```dart
import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

class _DangerInfo {
  const _DangerInfo(
    this.priority,
    this.message, {
    this.minBboxArea,
    this.useDirection = true,
    this.minFrames = 1,
  });
  final int priority;
  final String message;
  final double? minBboxArea;
  final bool useDirection;
  final int minFrames;
}

class TtsService {
  final FlutterTts _tts = FlutterTts();

  static const Map<String, _DangerInfo> _dangerMap = {
    'person':        _DangerInfo(1, '사람이 있습니다', minBboxArea: 0.12, minFrames: 10),
    'stairs':        _DangerInfo(1, '계단이 감지되었습니다', minFrames: 5),
    'car':           _DangerInfo(1, '차량이 접근하고 있습니다', minFrames: 3),
    'bicycle':       _DangerInfo(1, '자전거가 접근하고 있습니다', minFrames: 3),
    'scooter':       _DangerInfo(1, '킥보드가 접근하고 있습니다', minFrames: 3),
    'motorcycle':    _DangerInfo(1, '오토바이가 접근하고 있습니다', minFrames: 3),
    'dog':           _DangerInfo(2, '전방에 다른 강아지가 접근하고 있습니다', useDirection: false, minFrames: 5),
    'chair':         _DangerInfo(2, '의자가 있습니다', minFrames: 5),
    'table':         _DangerInfo(2, '테이블이 있습니다', minFrames: 5),
    'pole_obstacle': _DangerInfo(3, '장애물이 있습니다', minFrames: 8),
    'crosswalk':     _DangerInfo(3, '전방에 횡단보도입니다', useDirection: false, minFrames: 8),
    'traffic_light': _DangerInfo(3, '전방에 신호등이 감지되었습니다', useDirection: false, minFrames: 8),
  };

  static const double _minConfidence = 0.5;
  static const Duration _highCooldown = Duration(seconds: 4);
  static const Duration _cooldown = Duration(seconds: 5);

  final Map<String, DateTime> _lastSpokeMap = {};
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
      centerXByLabel[d.className] = d.boundingBox.left + d.boundingBox.width / 2;
    }

    for (final label in _dangerMap.keys) {
      if (detectedLabels.contains(label)) {
        _frameCount[label] = (_frameCount[label] ?? 0) + 1;
      } else {
        _frameCount[label] = 0;
      }
    }

    _DangerInfo? topDanger;
    String? topLabel;
    double topCenterX = 0.5;

    for (final label in detectedLabels) {
      final info = _dangerMap[label]!;
      if ((_frameCount[label] ?? 0) < info.minFrames) continue;
      if (topDanger == null || info.priority < topDanger.priority) {
        topDanger = info;
        topLabel = label;
        topCenterX = centerXByLabel[label] ?? 0.5;
      }
    }

    if (topDanger == null || topLabel == null) return;

    final now = DateTime.now();
    final cooldown = topDanger.priority == 1 ? _highCooldown : _cooldown;
    final last = _lastSpokeMap[topLabel];
    if (last != null && now.difference(last) < cooldown) return;

    _lastSpokeMap[topLabel] = now;
    _tts.speak(_buildMessage(topDanger, topCenterX));
  }

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

  Future<void> stop() async {
    await _tts.stop();
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _tts.stop();
  }
}
```

---

## TTS 동작 방식 (수정 불필요, 참고용)

감지된 객체 중 최고 위험도 1개만 발화. 방향 포함.

| 클래스 | 위험도 | 쿨다운 | 예시 발화 |
|---|---|---|---|
| car, bicycle, scooter, motorcycle | HIGH | 4초 | "왼쪽에 차량이 접근하고 있습니다" |
| person | HIGH | 4초 | "전방에 사람이 있습니다" (근접 시만) |
| stairs | HIGH | 4초 | "오른쪽에 계단이 감지되었습니다" |
| dog, chair, table | MEDIUM | 5초 | "전방에 다른 강아지가 접근하고 있습니다" |
| pole_obstacle | LOW | 5초 | "오른쪽에 장애물이 있습니다" |
| crosswalk, traffic_light | LOW | 5초 | "전방에 횡단보도입니다" |

방향(왼쪽/전방/오른쪽)은 bbox 중심 x 좌표로 자동 결정됨.

---

---

## 오디오 감지 서비스 (AudioService)

청각장애인 보호자를 위한 소리 감지 기능. TTS 없이 **진동 + 화면 배너**로만 알림.

### AudioService API

```dart
final audioService = AudioService();

await audioService.init();   // YAMNet 모델 로드 (한 번만)
await audioService.start();  // 마이크 감지 시작
audioService.stop();         // 감지 중단
await audioService.dispose(); // 화면 종료 시 반드시 호출

audioService.alertStream    // Stream<AudioAlert> — 감지 결과
```

### 감지 클래스 → 위험도

| 소리 | 위험도 | 진동 | 배너 색상 |
|---|---|---|---|
| 차량 경적, 사이렌 | HIGH | 200ms | 빨강 #E53935 |
| 오토바이 소리 | HIGH | 200ms | 빨강 #E53935 |
| 개 짖는 소리 | MEDIUM | 150ms | 주황 #F57C00 |
| 자전거 벨 | LOW | 100ms | 파랑 #1976D2 |

쿨다운: HIGH 4초, MEDIUM/LOW 6초

### 화면 오버레이 연결

카메라 풀스크린 위에 Stack으로 얹는다:

```dart
Stack(
  children: [
    RTCVideoView(walkService.remoteRenderer), // 풀스크린 카메라
    Positioned(
      top: 0, left: 0, right: 0,
      child: AudioAlertBanner(stream: audioService.alertStream),
    ),
  ],
)
```

배너는 감지 시 위에서 슬라이드 인, 3초 후 자동으로 사라진다.

### 초기화 순서

```dart
await walkService.init();
await ttsService.init();
await audioService.init();           // YAMNet 로드
ttsService.listen(walkService.detectionStream);
await audioService.start();          // 마이크 시작
await walkService.connect(senderIp);
```

### dispose 순서

```dart
await ttsService.dispose();
await audioService.dispose();
await walkService.dispose();
```

### 롤백 방법 (YAMNet 제거 시)

아래 파일 삭제 + pubspec.yaml 3줄 제거로 완전 원상복구 가능. 기존 파일은 변경 없음.
- 삭제: `lib/services/audio_service.dart`
- 삭제: `lib/widgets/audio_alert_banner.dart`
- 삭제: `assets/yamnet.tflite`
- pubspec.yaml에서 `tflite_flutter`, `record`, `vibration` 제거

---

## 주의사항 요약

1. **`WalkService`, `TtsService` 파일은 수정하지 않는다.**
2. **`AndroidManifest.xml` 수정은 필수** — 권한 누락 시 카메라/네트워크 동작 안 함, WorkManager 미수정 시 앱 크래시.
3. **`dispose()` 반드시 호출** — 미호출 시 WebRTC 렌더러 메모리 누수.
4. **`RTCVideoView`는 `flutter_webrtc` 패키지 위젯** — 일반 Image/VideoPlayer 아님.
5. **연결 대상 IP**: 강아지 폰(camera_app)이 표시하는 IP를 사용자가 직접 입력.
