import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:vibration/vibration.dart';

class AudioAlert {
  const AudioAlert({
    required this.priority,
    required this.label,
    required this.confidence,
  });
  final int priority;      // 1=위험, 2=경고, 3=조심
  final String label;      // 한국어 이름
  final double confidence;
}

class _SoundInfo {
  const _SoundInfo(this.priority, this.label, this.vibrationMs);
  final int priority;
  final String label;
  final int vibrationMs;
}

class AudioService {
  static const String _modelPath = 'assets/yamnet.tflite';
  static const double _minConfidence = 0.3;
  static const Duration _highCooldown = Duration(seconds: 4);
  static const Duration _cooldown = Duration(seconds: 6);

  // YAMNet 521개 클래스 중 관심 클래스 → 위험도 매핑
  static const Map<String, _SoundInfo> _soundMap = {
    // 위험
    'Car':                      _SoundInfo(1, '차량 소리', 200),
    'Vehicle horn, car horn, honking': _SoundInfo(1, '차량 경적', 200),
    'Beeping, horn honking':    _SoundInfo(1, '차량 경적', 200),
    'Siren':                    _SoundInfo(1, '사이렌', 200),
    'Emergency vehicle':        _SoundInfo(1, '긴급차량', 200),
    'Motorcycle':               _SoundInfo(1, '오토바이 소리', 200),
    'Engine':                   _SoundInfo(1, '오토바이 소리', 200),
    // 경고
    'Dog':                      _SoundInfo(2, '개 짖는 소리', 150),
    'Bark':                     _SoundInfo(2, '개 짖는 소리', 150),
    'Yip':                      _SoundInfo(2, '개 짖는 소리', 150),
    // 조심
    'Bicycle bell':             _SoundInfo(3, '자전거 벨', 100),
    'Bell':                     _SoundInfo(3, '벨 소리', 100),
  };

  final _alertController = StreamController<AudioAlert>.broadcast();
  Stream<AudioAlert> get alertStream => _alertController.stream;

  final _recorder = AudioRecorder();
  Interpreter? _interpreter;
  bool _running = false;
  final Map<String, DateTime> _lastAlertMap = {};

  Future<void> init() async {
    final options = InterpreterOptions()..useNnApiForAndroid = false;
    _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
  }

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _inferLoop();
  }

  void stop() {
    _running = false;
    _recorder.stop();
  }

  Future<void> _inferLoop() async {
    const sampleRate = 16000;
    const bufferSize = 15600; // 0.975초 @ 16kHz

    while (_running) {
      try {
        final stream = await _recorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: sampleRate,
            numChannels: 1,
          ),
        );

        final buffer = <int>[];
        await for (final chunk in stream) {
          if (!_running) break;
          buffer.addAll(chunk);

          if (buffer.length >= bufferSize * 2) {
            final pcm = buffer.sublist(0, bufferSize * 2);
            buffer.removeRange(0, bufferSize * 2);
            final floats = _pcm16ToFloat32(pcm);
            _runInference(floats);
          }
        }
      } catch (_) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Float32List _pcm16ToFloat32(List<int> pcm16) {
    final result = Float32List(pcm16.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      final lo = pcm16[i * 2];
      final hi = pcm16[i * 2 + 1];
      int sample = (hi << 8) | lo;
      if (sample >= 0x8000) sample -= 0x10000;
      result[i] = sample / 32768.0;
    }
    return result;
  }

  void _runInference(Float32List audio) {
    if (_interpreter == null) return;

    final input = [audio];
    final scores = List.filled(521, 0.0);
    final output = {0: [scores]};

    _interpreter!.runForMultipleInputs([input], output);

    final rawScores = (output[0] as List).first as List;

    _SoundInfo? topSound;
    String? topYamnetLabel;
    double topScore = 0;

    for (final entry in _soundMap.entries) {
      final idx = _yamnetIndex(entry.key);
      if (idx < 0 || idx >= rawScores.length) continue;
      final score = (rawScores[idx] as num).toDouble();
      if (score >= _minConfidence && (topSound == null || score > topScore)) {
        topSound = entry.value;
        topYamnetLabel = entry.key;
        topScore = score;
      }
    }

    if (topSound == null || topYamnetLabel == null) return;

    final now = DateTime.now();
    final cooldown = topSound.priority == 1 ? _highCooldown : _cooldown;
    final last = _lastAlertMap[topYamnetLabel];
    if (last != null && now.difference(last) < cooldown) return;

    _lastAlertMap[topYamnetLabel] = now;
    _vibrate(topSound.vibrationMs);
    _alertController.add(AudioAlert(
      priority: topSound.priority,
      label: topSound.label,
      confidence: topScore,
    ));
  }

  // YAMNet 클래스명 → 인덱스 (주요 클래스 하드코딩)
  int _yamnetIndex(String label) {
    const indices = {
      'Car': 300,
      'Vehicle horn, car horn, honking': 306,
      'Beeping, horn honking': 307,
      'Siren': 396,
      'Emergency vehicle': 397,
      'Motorcycle': 302,
      'Engine': 303,
      'Dog': 74,
      'Bark': 75,
      'Yip': 76,
      'Bicycle bell': 395,
      'Bell': 394,
    };
    return indices[label] ?? -1;
  }

  Future<void> _vibrate(int ms) async {
    if ((await Vibration.hasVibrator()) == true) {
      Vibration.vibrate(duration: ms);
    }
  }

  Future<void> dispose() async {
    stop();
    _interpreter?.close();
    await _alertController.close();
  }
}
