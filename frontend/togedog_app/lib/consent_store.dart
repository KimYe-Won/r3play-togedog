import 'package:shared_preferences/shared_preferences.dart';

// [백엔드 연동] 온보딩 07~10 동의 상태 — 11화면 등록 후 API 전송
class ConsentStore {
  ConsentStore._();

  static final ConsentStore instance = ConsentStore._();

  static const String _locationKey = 'consent_location';
  static const String _notificationKey = 'consent_notification';
  static const String _deviceKey = 'consent_device';
  static const String _cameraKey = 'consent_camera';

  bool locationConsent = false;
  bool notificationConsent = false;
  bool deviceConsent = false;
  bool cameraConsent = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    locationConsent = prefs.getBool(_locationKey) ?? false;
    notificationConsent = prefs.getBool(_notificationKey) ?? false;
    deviceConsent = prefs.getBool(_deviceKey) ?? false;
    cameraConsent = prefs.getBool(_cameraKey) ?? false;
  }

  Future<void> setLocationConsent(bool value) async {
    locationConsent = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationKey, value);
  }

  Future<void> setNotificationConsent(bool value) async {
    notificationConsent = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, value);
  }

  Future<void> setDeviceConsent(bool value) async {
    deviceConsent = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceKey, value);
  }

  Future<void> setCameraConsent(bool value) async {
    cameraConsent = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_cameraKey, value);
  }
}