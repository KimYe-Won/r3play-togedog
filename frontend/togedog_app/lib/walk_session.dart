import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

// 백엔드 작업
import 'package:flutter/foundation.dart';

import 'services/backend_sync_service.dart';


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

    // 세션 활성화/타이머를 먼저 켠다. 백엔드 응답을 기다리면(await) 서버 미가동·미도달 시
    // active가 영영 false로 남아 "시작을 누르세요" 화면이 영상을 덮는다.
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

    // [백엔드 연동] POST /walks/start — walk_id 저장. 백그라운드 전송(UI 비차단).
    unawaited(
      BackendSyncService.instance.startWalkOnBackend().then((ok) {
        if (!ok) {
          debugPrint('[백엔드 연동] 산책 시작 API 실패 — 로컬 타이머는 동작');
        }
      }),
    );
  }

  void stopWalk() {
    // 로컬 종료를 먼저 처리(타이머 중지·비활성화). 백엔드는 백그라운드로.
    _walkTimer?.cancel();
    _metricsTimer?.cancel();
    active = false;
    elapsed = Duration.zero;
    _resetMetrics();
    notifyListeners();

    // [백엔드 연동] POST /walks/{walkId}/end — 백그라운드 전송(UI 비차단).
    unawaited(
      BackendSyncService.instance.endWalkOnBackend().then((ok) {
        if (!ok) {
          debugPrint('[백엔드 연동] 산책 종료 API 실패 — 로컬 타이머는 중지');
        }
      }),
    );
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
