import 'package:shared_preferences/shared_preferences.dart';

import 'main_onboarding_05.dart';

/// 온보딩 05 안내 방식 선택 — 앱 전역 유지
class GuidanceModeStore {
  GuidanceModeStore._();

  static final GuidanceModeStore instance = GuidanceModeStore._();

  static const String _guidanceModeKey = 'guidance_mode';

  GuidanceMode? _selectedMode;

  GuidanceMode get selectedMode => _selectedMode ?? GuidanceMode.sound;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_guidanceModeKey);
    _selectedMode = _parse(raw);
  }

  Future<void> setMode(GuidanceMode mode) async {
    _selectedMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_guidanceModeKey, mode.name);
  }

  GuidanceMode? _parse(String? raw) {
    switch (raw) {
      case 'sound':
        return GuidanceMode.sound;
      case 'vibration':
        return GuidanceMode.vibration;
      case 'text':
        return GuidanceMode.text;
      default:
        return null;
    }
  }
}
