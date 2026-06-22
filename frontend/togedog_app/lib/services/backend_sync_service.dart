import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../backend_session_store.dart';
import '../guidance_mode_store.dart';
import '../main_onboarding_05.dart';
import 'api_client.dart';
import '../consent_store.dart';

// [백엔드 연동] 온보딩 프로필 → members / dogs API
class BackendSyncService {
  BackendSyncService._();

  static final BackendSyncService instance = BackendSyncService._();

  /// [백엔드 연동] POST /members + POST /dogs
  Future<bool> syncProfileFromOnboarding({
    required String guardianName,
    required String petName,
    required String breed,
    required String age,
  }) async {
    try {
      final session = BackendSessionStore.instance;

      // [백엔드 연동] POST /members — 최초 1회만 (member_id 없을 때)
      if (session.memberId == null || session.memberId!.isEmpty) {
        final memberId = 'user_${DateTime.now().millisecondsSinceEpoch}';
        final response = await ApiClient.instance.post(
          '/members',
          withMember: false,
          body: {
            'member_id': memberId,
            'name': guardianName,
            'email': '$memberId@example.com', // 온보딩에 이메일 없음 → 임시값 (.local 은 422)
            'guide_mode': _toGuideMode(GuidanceModeStore.instance.selectedMode),
          },
        );
        if (response.statusCode != 201) {
          debugPrint(
            '[백엔드 연동] POST /members 실패: '
            '${response.statusCode} ${response.body}',
          );
          return false;
        }
        await session.saveMemberId(memberId);
      }

      // [백엔드 연동] POST /dogs — X-Member-Id 헤더 필요
      final dogResponse = await ApiClient.instance.post(
        '/dogs',
        body: {
          'guardian_name': guardianName,
          'name': petName,
          'breed': breed,
          'gender': 'MALE', // 온보딩에 성별 없음 → 기본값
          if (age.isNotEmpty) 'special_notes': '나이: $age세',
        },
      );
      if (dogResponse.statusCode != 201) {
        debugPrint(
          '[백엔드 연동] POST /dogs 실패: '
          '${dogResponse.statusCode} ${dogResponse.body}',
        );
        return false;
      }

      final dogJson = jsonDecode(dogResponse.body) as Map<String, dynamic>;
      final dogId = dogJson['dog_id'] as String;
      await session.saveDogId(dogId);

      // [백엔드 연동] 온보딩 07~10에서 모은 동의 → DB 반영
      await syncConsents();
      await syncNotificationSettings(GuidanceModeStore.instance.selectedMode);

      
      // [백엔드 연동] 온보딩 05에서 고른 안내 방식 → DB 반영 (11화면 이후 member_id 생김)
      await syncNotificationSettings(GuidanceModeStore.instance.selectedMode);
      return true;
    } catch (e, st) {
      debugPrint('[백엔드 연동] syncProfileFromOnboarding 오류: $e\n$st');
      return false;
    }
  }
  
    // [백엔드 연동] PUT /members/me/consents
  Future<bool> syncConsents() async {
    final memberId = BackendSessionStore.instance.memberId;
    if (memberId == null || memberId.isEmpty) {
      debugPrint('[백엔드 연동] member_id 없음 — consents 스킵');
      return false;
    }

    final consents = ConsentStore.instance;
    final response = await ApiClient.instance.put(
      '/members/me/consents',
      body: {
        'location_consent': consents.locationConsent,
        'notification_consent': consents.notificationConsent,
        'device_consent': consents.deviceConsent,
        'camera_consent': consents.cameraConsent,
      },
    );
    if (response.statusCode != 200) {
      debugPrint(
        '[백엔드 연동] PUT /members/me/consents 실패: '
        '${response.statusCode} ${response.body}',
      );
      return false;
    }
    return true;
  }


  // [백엔드 연동] PUT /members/me/notification-settings
  Future<bool> syncNotificationSettings(GuidanceMode mode) async {
    final memberId = BackendSessionStore.instance.memberId;
    if (memberId == null || memberId.isEmpty) {
      debugPrint('[백엔드 연동] member_id 없음 — notification-settings 스킵');
      return false;
    }

    final response = await ApiClient.instance.put(
      '/members/me/notification-settings',
      body: {
        'guide_mode': _toGuideMode(mode),
        'voice_enabled': mode == GuidanceMode.sound,
        'vibration_enabled': mode == GuidanceMode.vibration,
        'text_enabled': mode == GuidanceMode.text,
      },
    );
    if (response.statusCode != 200) {
      debugPrint(
        '[백엔드 연동] PUT notification-settings 실패: '
        '${response.statusCode} ${response.body}',
      );
      return false;
    }
    return true;
  }

  // [백엔드 연동] POST /devices/pair
  Future<bool> pairDevice({
    required String deviceName,
    String? deviceId,
  }) async {
    final dogId = BackendSessionStore.instance.dogId;
    if (dogId == null || dogId.isEmpty) {
      debugPrint('[백엔드 연동] dog_id 없음 — devices/pair 스킵');
      return false;
    }

    final response = await ApiClient.instance.post(
      '/devices/pair',
      body: {
        'dog_id': dogId,
        'device_name': deviceName,
        'device_id': deviceId,
      },
    );
    if (response.statusCode != 201) {
      debugPrint(
        '[백엔드 연동] POST /devices/pair 실패: '
        '${response.statusCode} ${response.body}',
      );
      return false;
    }
    return true;
  }


  
  String _toGuideMode(GuidanceMode mode) {
    switch (mode) {
      case GuidanceMode.sound:
        return 'VOICE';
      case GuidanceMode.vibration:
        return 'VIBRATION';
      case GuidanceMode.text:
        return 'TEXT';
    }
  }
    // [백엔드 연동] POST /walks/start — dog_id 필요, 응답 walk_id 저장
  Future<bool> startWalkOnBackend() async {
    final dogId = BackendSessionStore.instance.dogId;
    if (dogId == null || dogId.isEmpty) {
      debugPrint('[백엔드 연동] dog_id 없음 — walks/start 스킵');
      return false;
    }

    final response = await ApiClient.instance.post(
      '/walks/start',
      body: {'dog_id': dogId},
    );
    if (response.statusCode != 201) {
      debugPrint(
        '[백엔드 연동] POST /walks/start 실패: '
        '${response.statusCode} ${response.body}',
      );
      return false;
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final walkId = json['walk_id'] as String;
    await BackendSessionStore.instance.saveWalkId(walkId);
    return true;
  }

  // [백엔드 연동] POST /walks/{walkId}/end
  Future<bool> endWalkOnBackend() async {
    final walkId = BackendSessionStore.instance.walkId;
    if (walkId == null || walkId.isEmpty) {
      debugPrint('[백엔드 연동] walk_id 없음 — walks/end 스킵');
      return false;
    }

    final response = await ApiClient.instance.post(
      '/walks/$walkId/end',
      body: {'status': 'COMPLETED'},
    );
    if (response.statusCode != 200) {
      debugPrint(
        '[백엔드 연동] POST /walks/end 실패: '
        '${response.statusCode} ${response.body}',
      );
      return false;
    }

    await BackendSessionStore.instance.saveWalkId(null);
    return true;
  }
}