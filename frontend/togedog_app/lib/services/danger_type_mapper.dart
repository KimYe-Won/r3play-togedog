// [백엔드 연동] YOLO className / TTS priority → API enum 문자열
import '../main_onboarding_05.dart';

class DangerTypeMapper {
  DangerTypeMapper._();

  static const Map<String, String> _classToType = {
    'car': 'VEHICLE',
    'bicycle': 'VEHICLE',
    'scooter': 'VEHICLE',
    'motorcycle': 'VEHICLE',
    'person': 'PERSON',
    'dog': 'ANIMAL',
    'stairs': 'OBSTACLE',
    'chair': 'OBSTACLE',
    'table': 'OBSTACLE',
    'pole_obstacle': 'OBSTACLE',
    'crosswalk': 'OTHER',
    'traffic_light': 'OTHER',
  };

  /// YOLO className → danger_type. 매핑 없으면 null (API 호출 스킵).
  static String? yoloClassToDangerType(String className) {
    return _classToType[className];
  }

  /// TTS priority(1~3) → danger_level.
  static String priorityToDangerLevel(int priority) {
    switch (priority) {
      case 1:
        return 'HIGH';
      case 2:
        return 'MEDIUM';
      case 3:
        return 'LOW';
      default:
        return 'LOW';
    }
  }

  /// 안내 모드 → notification_channel.
  static String guidanceModeToChannel(GuidanceMode mode) {
    switch (mode) {
      case GuidanceMode.sound:
        return 'VOICE';
      case GuidanceMode.vibration:
        return 'VIBRATION';
      case GuidanceMode.text:
        return 'TEXT';
    }
  }
}