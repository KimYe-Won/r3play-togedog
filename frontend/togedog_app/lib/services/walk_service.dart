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
