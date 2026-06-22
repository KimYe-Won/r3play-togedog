import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:yolo_live_stream/yolo_live_stream.dart';

import 'guidance_mode_store.dart';
import 'main_onboarding_05.dart';
import 'services/audio_service.dart';
import 'services/tts_service.dart';

class WalkAiManager extends ChangeNotifier {
  WalkAiManager._();
  static final WalkAiManager instance = WalkAiManager._();

  static const String modelPath = 'assets/deep_learning/best_v3_float16.tflite';
  static const String _lastIpKey = 'walk_last_ip';

  // 컨트롤러는 1개를 끝까지 재사용한다. 재접속 시 _isBusy 고착 문제는
  // yolo_live_stream 0.10.0의 YoloAnalyzer.stop()이 _isBusy를 리셋하면서 해결됐다.
  late final LiveStreamingController _streamingController = _buildController();
  LiveStreamingController get streamingController => _streamingController;

  final TtsService _ttsService = TtsService();
  final AudioService _audioService = AudioService();
  final _detectionController = StreamController<List<YOLOResult>>.broadcast();

  bool _initialized = false;
  String _lastIp = '';

  bool get isConnected => _streamingController.isStarted;
  String get lastIp => _lastIp;
  Stream<AudioAlert> get audioAlertStream => _audioService.alertStream;

  LiveStreamingController _buildController() {
    final controller = LiveStreamingController(
      role: Role.receiver,
      // 송신폰 마이크 소리를 스피커로 재생하지 않는다(되울림 방지). 안내는 TTS/진동/배너로만.
      enableSpeaker: false,
      quality: VideoQuality.fullHd1080,
      customModelPath: modelPath,
      detectionInterval: const Duration(milliseconds: 200),
      onDetected: onDetected,
    );
    controller.addListener(_onControllerUpdate);
    return controller;
  }

  Future<void> init() async {
    if (_initialized) return;
    await _ttsService.init();
    await _audioService.init();
    final prefs = await SharedPreferences.getInstance();
    _lastIp = prefs.getString(_lastIpKey) ?? '';
    _initialized = true;
  }

  void _onControllerUpdate() {
    notifyListeners();
  }

  void onDetected(List<YOLOResult> detections) {
    if (!_detectionController.isClosed) {
      _detectionController.add(detections);
    }
  }

  Future<bool> connect(String ip) async {
    await _streamingController.startAsReceiver(ip);
    if (!_streamingController.isStarted) return false;

    // 수신폰은 영상만 받는 단방향이다. 자기 마이크가 송신폰으로 넘어가지 않도록 송신 오디오를 끈다.
    final localAudioTracks =
        _streamingController.connection.localStream?.getAudioTracks() ??
            const <MediaStreamTrack>[];
    for (final track in localAudioTracks) {
      track.enabled = false;
    }
    // WebRTC가 오디오 포커스를 잡고 통신모드(이어피스)로 두면 TTS가 안 들린다.
    // 이 앱은 WebRTC 오디오를 쓰지 않으므로, 포커스 관리를 끄고 일반(미디어) 모드로 둬서
    // flutter_tts가 스피커로 정상 재생되게 한다.
    await Helper.setAndroidAudioConfiguration(
      AndroidAudioConfiguration(
        manageAudioFocus: false,
        androidAudioMode: AndroidAudioMode.normal,
        androidAudioStreamType: AndroidAudioStreamType.music,
        androidAudioAttributesUsageType: AndroidAudioAttributesUsageType.media,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastIpKey, ip);
    _lastIp = ip;

    _applyGuidanceMode();
    notifyListeners();
    return true;
  }

  Future<void> disconnect() async {
    await streamingController.stop();
    await _ttsService.stop();
    _audioService.stop();
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
    debugPrint('[Walk] applyGuidanceMode: $mode');
    switch (mode) {
      case GuidanceMode.sound: // 시각장애인: TTS만, 진동 없음
        _ttsService.speechEnabled = true;
        _ttsService.vibrationEnabled = false;
        _ttsService.listen(_detectionController.stream);
      case GuidanceMode.vibration: // 청각장애인: 진동 + 소리감지 배너, TTS 없음
        _ttsService.speechEnabled = false;
        _ttsService.vibrationEnabled = true;
        _ttsService.listen(_detectionController.stream);
        _audioService.start();
      case GuidanceMode.text: // 텍스트만: 음성·진동 없음
        _ttsService.speechEnabled = false;
        _ttsService.vibrationEnabled = false;
    }
  }
}
