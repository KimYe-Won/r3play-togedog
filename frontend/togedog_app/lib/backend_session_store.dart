import 'package:shared_preferences/shared_preferences.dart';

// [백엔드 연동] member_id / dog_id / walk_id 앱 전역 저장
class BackendSessionStore {
  BackendSessionStore._();

  static final BackendSessionStore instance = BackendSessionStore._();

  static const String _memberIdKey = 'backend_member_id';
  static const String _dogIdKey = 'backend_dog_id';
  static const String _walkIdKey = 'backend_walk_id';

  String? memberId;
  String? dogId;
  String? walkId;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    memberId = prefs.getString(_memberIdKey);
    dogId = prefs.getString(_dogIdKey);
    walkId = prefs.getString(_walkIdKey);
  }

  Future<void> saveMemberId(String id) async {
    memberId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_memberIdKey, id);
  }

  Future<void> saveDogId(String id) async {
    dogId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dogIdKey, id);
  }

  Future<void> saveWalkId(String? id) async {
    walkId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_walkIdKey);
    } else {
      await prefs.setString(_walkIdKey, id);
    }
  }
}