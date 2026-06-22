import 'dart:async';

import 'package:flutter/foundation.dart';
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

  late final LiveStreamingController streamingController = LiveStreamingController(
    role: Role.receiver,
    enableSpeaker: false,
    customModelPath: modelPath,
    detectionInterval: const Duration(milliseconds: 100),
    onDetected: onDetected,
  );
  final TtsService _ttsService = TtsService();
  final AudioService _audioService = AudioService();
  final _detectionController = StreamController<List<YOLOResult>>.broadcast();

  bool _initialized = false;
  String _lastIp = '';

  bool get isConnected => streamingController.isStarted;
  String get lastIp => _lastIp;
  Stream<AudioAlert> get audioAlertStream => _audioService.alertStream;

  Future<void> init() async {
    if (_initialized) return;
    await _ttsService.init();
    await _audioService.init();
    final prefs = await SharedPreferences.getInstance();
    _lastIp = prefs.getString(_lastIpKey) ?? '';
    streamingController.addListener(_onControllerUpdate);
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
    await streamingController.startAsReceiver(ip);
    print('streamingController.isStarted: ${streamingController.isStarted}');
    if (!streamingController.isStarted) return false;

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
    switch (mode) {
      case GuidanceMode.sound:
        _ttsService.speechEnabled = true;
        _ttsService.listen(_detectionController.stream);
      case GuidanceMode.vibration:
        _ttsService.speechEnabled = false;
        _ttsService.listen(_detectionController.stream);
        _audioService.start();
      case GuidanceMode.text:
        break;
    }
  }
}
