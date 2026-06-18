import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// 산책 타이머·지표를 walk_01~04가 공유합니다.
class WalkSession extends ChangeNotifier {
  WalkSession._();

  static final WalkSession instance = WalkSession._();
  static const String walk01RouteName = 'Walk01Screen';

  static const int initialHeartRate = 98;
  static const double initialDistanceKm = 1.2;
  static const int initialActivitySteps = 6245;
  static const String initialSafetyStatus = '안전';

  final Random _random = Random();

  Duration elapsed = Duration.zero;
  bool active = false;
  int heartRate = initialHeartRate;
  double distanceKm = initialDistanceKm;
  int activitySteps = initialActivitySteps;
  String safetyStatus = initialSafetyStatus;

  Timer? _walkTimer;
  Timer? _metricsTimer;

  void startWalk() {
    if (active) return;
    _walkTimer?.cancel();
    _metricsTimer?.cancel();
    active = true;
    elapsed = Duration.zero;
    _resetMetrics();
    _walkTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      notifyListeners();
    });
    _metricsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!active) return;
      _updateMetrics();
      notifyListeners();
    });
    notifyListeners();
  }

  void stopWalk() {
    _walkTimer?.cancel();
    _metricsTimer?.cancel();
    active = false;
    elapsed = Duration.zero;
    _resetMetrics();
    notifyListeners();
  }

  void _resetMetrics() {
    heartRate = initialHeartRate;
    distanceKm = initialDistanceKm;
    activitySteps = initialActivitySteps;
    safetyStatus = initialSafetyStatus;
  }

  void _updateMetrics() {
    heartRate = 70 + _random.nextInt(51);
    distanceKm = double.parse(
      (distanceKm + 0.05 + _random.nextDouble() * 0.1).toStringAsFixed(1),
    );
    activitySteps += 10 + _random.nextInt(20);
    safetyStatus = initialSafetyStatus;
  }

  String get formattedElapsed => formatWalkDuration(elapsed);

  String formatSteps(int steps) {
    final text = steps.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }
}

String formatWalkDuration(Duration duration) {
  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
