import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:yolo_live_stream/yolo_live_stream.dart';

import 'guidance_mode_store.dart';
import 'main_onboarding_05.dart';
import 'services/audio_service.dart';
import 'services/tts_service.dart';

/// 수신 WebRTC 연결과 YOLO 분석을 앱 전역에서 단 하나만 소유하는 매니저.
///
/// 패키지의 조립형 API([LiveStreamingConnector]+[YoloAnalyzer])를 직접 들고 있으므로
/// 연결·렌더러가 특정 화면 위젯에 묶이지 않는다. walk_01(작은 카드)·walk_02(전체화면)·
/// walk_03/04가 모두 같은 [remoteRenderer]를 그려서 같은 영상을 동시에 보여줄 수 있고,
/// 화면을 전환해도 연결이 끊기지 않아 종료 후 재연결도 정상 동작한다.
class WalkAiManager extends ChangeNotifier {
  WalkAiManager._();
  static final WalkAiManager instance = WalkAiManager._();

  /// Flutter 에셋 키(pubspec의 `asset/` 폴더 기준).
  static const String modelAsset = 'asset/deep_learning/best_v3_float16.tflite';
  static const String _lastIpKey = 'walk_last_ip';
  static const Duration _detectionInterval = Duration(milliseconds: 200);

  late final LiveStreamingConnector _connector;
  YoloAnalyzer? _analyzer;
  final TtsService _ttsService = TtsService();
  final AudioService _audioService = AudioService();
  final _detectionController = StreamController<List<YOLOResult>>.broadcast();

  bool _initialized = false;
  bool _started = false;
  String _lastIp = '';

  /// 수신 영상을 그리는 공유 렌더러. 여러 화면의 RTCVideoView/DetectionOverlay가 함께 쓴다.
  RTCVideoRenderer get remoteRenderer => _connector.remoteRenderer;

  /// 수신 영상이 도착해 화면에 그릴 수 있는 상태인지.
  bool get hasRemoteVideo => _connector.hasRemoteVideo;

  /// 송신자가 전면 카메라를 쓰는지(0.8.0+ 신호). 전면이면 영상을 좌우반전해 표시한다.
  bool get remoteIsFrontCamera => _connector.remoteIsFrontCamera;

  /// 현재 YOLO 탐지 결과(없으면 빈 목록).
  List<YOLOResult> get detections => _analyzer?.detections ?? const [];

  /// 수신 연결을 시작한 상태인지.
  bool get isConnected => _started;

  String get lastIp => _lastIp;
  Stream<AudioAlert> get audioAlertStream => _audioService.alertStream;

  Future<void> init() async {
    if (_initialized) return;
    await _ttsService.init();
    await _audioService.init();
    final prefs = await SharedPreferences.getInstance();
    _lastIp = prefs.getString(_lastIpKey) ?? '';

    _connector = LiveStreamingConnector(
      onUpdate: _notify,
      onError: (message) => debugPrint('LiveStream error: $message'),
      isRemoteAudioEnabled: false,
    );
    await _connector.initRenderers();

    _analyzer = YoloAnalyzer(
      onUpdate: _notify,
      onDetected: _handleDetected,
      getRemoteTrack: () => _connector.remoteVideoTrack,
      customModelPath: await _ensureModelFile(),
      interval: _detectionInterval,
    );

    _initialized = true;
  }

  /// ultralytics_yolo의 경로 해석기는 `assets/`(복수)로 시작할 때만 Flutter 에셋을
  /// 복사하므로, `asset/`(단수) 에셋은 인식하지 못한다. 그래서 에셋을 앱 문서 디렉터리에
  /// 직접 복사하고 그 절대 경로를 넘긴다(절대 경로는 해석기를 그대로 통과해 네이티브가 로드).
  Future<String> _ensureModelFile() async {
    final dir = await getApplicationSupportDirectory();
    final fileName = modelAsset.split('/').last;
    final file = File('${dir.path}/$fileName');

    final data = await rootBundle.load(modelAsset);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // 에셋 크기와 다르면(앱 업데이트로 모델 교체 등) 다시 쓴다.
    if (!file.existsSync() || file.lengthSync() != bytes.length) {
      await file.writeAsBytes(bytes, flush: true);
    }
    return file.path;
  }

  void _notify() {
    if (!_initialized) return;
    notifyListeners();
  }

  void _handleDetected(List<YOLOResult> detections) {
    if (!_detectionController.isClosed) {
      _detectionController.add(detections);
    }
  }

  Future<bool> connect(String ip) async {
    final ok = await _connector.startAsReceiver(ip);
    if (!ok) {
      _started = false;
      notifyListeners();
      return false;
    }
    _started = true;

    if (_analyzer != null) {
      try {
        await _analyzer!.start();
      } catch (error) {
        debugPrint('YOLO 모델 로드 실패: $error');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastIpKey, ip);
    _lastIp = ip;

    _applyGuidanceMode();
    notifyListeners();
    return true;
  }

  Future<void> disconnect() async {
    _analyzer?.stop();
    await _connector.close();
    await _ttsService.stop();
    _audioService.stop();
    _started = false;
    notifyListeners();
  }

  void onGuidanceModeChanged() {
    if (!isConnected) return;
    _ttsService.stop();
    _audioService.stop();
    _applyGuidanceMode();
  }

  void setSpeechEnabled(bool enabled) {
    _ttsService.speechEnabled = enabled;
  }

  void _applyGuidanceMode() {
    final mode = GuidanceModeStore.instance.selectedMode;
    switch (mode) {
      case GuidanceMode.sound:
        // 음성 모드: 시각 탐지 → 음성만 (진동 off)
        _ttsService.speechEnabled = true;
        _ttsService.vibrationEnabled = false;
        _ttsService.listen(_detectionController.stream);
      case GuidanceMode.vibration:
        // 진동 모드: 시각 탐지 → 진동만 (음성 off) + 청각(소리) 탐지 진동
        _ttsService.speechEnabled = false;
        _ttsService.vibrationEnabled = true;
        _ttsService.listen(_detectionController.stream);
        _audioService.start();
      case GuidanceMode.text:
        // 텍스트 모드: 음성·진동 모두 off
        _ttsService.speechEnabled = false;
        _ttsService.vibrationEnabled = false;
    }
  }
}
