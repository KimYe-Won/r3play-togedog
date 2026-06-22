import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_wearable_shared.dart';

// 백엔드 작업
import 'onboarding_wearable_shared.dart';
import 'services/backend_sync_service.dart';

/// 온보딩 13 / 마이페이지 웨어러블 관리 — 연결된 하네스 저장
class WearableConnectionStore {
  WearableConnectionStore._();

  static final WearableConnectionStore instance = WearableConnectionStore._();

  static const String _connectedHarnessKey = 'connected_harness_id';

  WearableHarnessId? _connectedId;

  WearableHarnessId get connectedId => _connectedId ?? WearableHarnessId.kong;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _connectedId = _parse(prefs.getString(_connectedHarnessKey));
  }

  Future<void> setConnected(WearableHarnessId id) async {
    _connectedId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_connectedHarnessKey, id.name);

    // [백엔드 연동] POST /devices/pair — 11화면 이후 dog_id 필요
    final deviceName = id == WearableHarnessId.kong ? '콩이 하네스' : '별이 하네스';
    await BackendSyncService.instance.pairDevice(
      deviceName: deviceName,
      deviceId: id.name, // kong / star
    );
  }

  WearableConnectionStatus statusFor(WearableHarnessId id) {
    return id == connectedId
        ? WearableConnectionStatus.connecting
        : WearableConnectionStatus.available;
  }

  WearableHarnessId? _parse(String? raw) {
    switch (raw) {
      case 'kong':
        return WearableHarnessId.kong;
      case 'star':
        return WearableHarnessId.star;
      default:
        return null;
    }
  }
}
