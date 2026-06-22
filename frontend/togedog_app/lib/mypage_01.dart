// TogeDog 마이페이지 — Figma node 488:202
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'main_onboarding_05.dart';
import 'mypage_02.dart';
import 'mypage_03.dart';
import 'pet_profile_store.dart';
import 'togedog_accessibility.dart';
import 'walk_ai_manager.dart';

/// Figma 488:202 프로필 영역
class _MypageAssets {
  static const profileUser = 'assets/mypage/mypage_profile_user.png';
  static const profilePet = 'assets/mypage/mypage_profile_pet.png';
  static const editAvatar = 'assets/mypage/mypage_edit_avatar.svg';
  static const editName = 'assets/mypage/mypage_edit_name.svg';
  static const petRing = 'assets/mypage/mypage_pet_ring.svg';
  static const profileDashedLine = 'assets/mypage/mypage_profile_dashed_line.svg';
}

/// Figma 760:6962 / 760:7089 / 760:7094
const double _kProfileInsetLeft = 7;
const double _kProfileAvatarSize = 78;
const double _kProfileUserPhotoSize = 99.273;
const double _kProfileUserPhotoLeft = -10.13;
const double _kProfileUserPhotoTop = -1.01;
const double _kProfileEditBadgeSize = 28;
const double _kProfileEditBadgeLeft = 50;
const double _kProfileEditBadgeTop = 50;
const double _kProfileNameGap = 22;
const double _kProfilePetRight = 9;
const double _kProfilePetRingSize = 68;
const double _kProfilePetRingLeft = 4;
const double _kProfilePetRingTop = -3;
const double _kProfilePetPhotoSize = 65.833;
const double _kProfilePetPhotoLeft = 6.5;
const double _kProfileDashedLineLeft = 207;
const double _kProfileDashedLineTop = 37;
const double _kProfileDashedLineWidth = 61;

class Mypage01Screen extends StatelessWidget {
  const Mypage01Screen({super.key});

  void _openEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Mypage02Screen()),
    );
  }

  Future<void> _openDisabilitySelection(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MainOnboarding05Screen(fromMypage: true),
      ),
    );
    WalkAiManager.instance.onGuidanceModeChanged();
  }

  void _openWearableManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Mypage03Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final profile = PetProfileStore.instance;
    final displayName = '${profile.displayPetName}아빠';
    final petName = profile.displayPetName;

    return TogedogA11y.screen(
      name: '마이페이지',
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F1F5),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    19 * scale,
                    8 * scale,
                    19 * scale,
                    16 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppScreenHeader(scale: scale, title: '마이페이지'),
                      SizedBox(height: 24 * scale),
                      _ProfileSection(
                        scale: scale,
                        displayName: displayName,
                        petName: petName,
                        onEditProfile: () => _openEditProfile(context),
                      ),
                      SizedBox(height: 16 * scale),
                      _MembershipRow(scale: scale),
                      SizedBox(height: 20 * scale),
                      _SectionHeader(scale: scale, title: '접근성 설정'),
                      SizedBox(height: 8 * scale),
                      _SettingsCard(
                        scale: scale,
                        items: [
                          _SettingsItem(
                            title: '장애유형 선택',
                            onTap: () => _openDisabilitySelection(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 20 * scale),
                      _SectionHeader(scale: scale, title: '알림 방식 설정'),
                      SizedBox(height: 8 * scale),
                      _SettingsCard(
                        scale: scale,
                        items: const [
                          _SettingsItem(title: '음성 (TTS)'),
                          _SettingsItem(title: '진동'),
                          _SettingsItem(title: '텍스트'),
                        ],
                      ),
                      SizedBox(height: 20 * scale),
                      _SectionHeader(scale: scale, title: '인터페이스 설정'),
                      SizedBox(height: 8 * scale),
                      _SettingsCard(
                        scale: scale,
                        items: const [
                          _SettingsItem(title: '글자크기'),
                          _SettingsItem(title: '음성속도'),
                          _SettingsItem(title: '진동강도'),
                        ],
                      ),
                      SizedBox(height: 20 * scale),
                      _SectionHeader(scale: scale, title: '기기 및 서비스 관리'),
                      SizedBox(height: 8 * scale),
                      _SettingsCard(
                        scale: scale,
                        items: [
                          _SettingsItem(
                            title: '웨어러블 디바이스 관리',
                            onTap: () => _openWearableManagement(context),
                          ),
                          const _SettingsItem(
                            title: '카메라 및 센서 정상 작동 여부 진단',
                          ),
                          const _SettingsItem(
                            title: '배터리 잔량 확인 및 소모품 교체 주기 알림 설정',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AppBottomNav(
                scale: scale,
                bottomInset: bottomInset,
                activeTab: AppTab.mypage,
                backgroundColor: const Color(0xFFF0F1F5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.scale, required this.title});

  final double scale;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'LGSmartUI',
        fontWeight: FontWeight.w600,
        fontSize: 15 * scale,
        color: const Color(0xFF6A6A6A),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.scale,
    required this.displayName,
    required this.petName,
    required this.onEditProfile,
  });

  final double scale;
  final String displayName;
  final String petName;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: _kProfileInsetLeft * scale),
      child: SizedBox(
        height: 90 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserAvatar(scale: scale),
                SizedBox(width: _kProfileNameGap * scale),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TogedogA11y.button(
                      label: displayName,
                      hint: '내 정보 수정',
                      child: GestureDetector(
                        onTap: onEditProfile,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontFamily: 'LGSmartUI',
                                fontWeight: FontWeight.w700,
                                fontSize: 20 * scale,
                                color: const Color(0xFF111111),
                              ),
                            ),
                            SizedBox(width: 9 * scale),
                            TogedogAssets.svg(
                              _MypageAssets.editName,
                              width: 14.716 * scale,
                              height: 14.72 * scale,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    TogedogA11y.button(
                      label: '내 정보 수정',
                      child: GestureDetector(
                        onTap: onEditProfile,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 31 * scale,
                          padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32.5 * scale),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '내 정보 수정',
                            style: TextStyle(
                              fontFamily: 'LGSmartUI',
                              fontWeight: FontWeight.w600,
                              fontSize: 12 * scale,
                              color: const Color(0xFF8756E7),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              right: _kProfilePetRight * scale,
              top: 0,
              child: _PetAvatar(scale: scale, petName: petName),
            ),
            Positioned(
              left: _kProfileDashedLineLeft * scale,
              top: _kProfileDashedLineTop * scale,
              child: TogedogAssets.svg(
                _MypageAssets.profileDashedLine,
                width: _kProfileDashedLineWidth * scale,
                height: 1 * scale,
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    return SizedBox(
      width: _kProfileAvatarSize * s,
      height: _kProfileAvatarSize * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: SizedBox(
              width: _kProfileAvatarSize * s,
              height: _kProfileAvatarSize * s,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned(
                    left: _kProfileUserPhotoLeft * s,
                    top: _kProfileUserPhotoTop * s,
                    width: _kProfileUserPhotoSize * s,
                    height: _kProfileUserPhotoSize * s,
                    child: Image.asset(
                      _MypageAssets.profileUser,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: _kProfileEditBadgeLeft * s,
            top: _kProfileEditBadgeTop * s,
            child: TogedogAssets.svg(
              _MypageAssets.editAvatar,
              width: _kProfileEditBadgeSize * s,
              height: _kProfileEditBadgeSize * s,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.scale, required this.petName});

  final double scale;
  final String petName;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final photoSize = _kProfilePetPhotoSize * s;
    return SizedBox(
      width: _kProfileAvatarSize * s,
      height: 90 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: _kProfilePetRingLeft * s,
            top: _kProfilePetRingTop * s,
            child: TogedogAssets.svg(
              _MypageAssets.petRing,
              width: _kProfilePetRingSize * s,
              height: _kProfilePetRingSize * s,
            ),
          ),
          Positioned(
            left: _kProfilePetPhotoLeft * s,
            top: 0,
            width: photoSize,
            height: photoSize,
            child: ClipOval(
              child: Image.asset(
                _MypageAssets.profilePet,
                width: photoSize,
                height: photoSize,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 71 * s,
            child: Text(
              petName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 10 * s,
                color: const Color(0xFF1A1A1A),
                height: 25 / 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipRow extends StatelessWidget {
  const _MembershipRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45 * scale,
      padding: EdgeInsets.symmetric(horizontal: 19 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '멤버쉽',
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 13 * scale,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Text(
            '가입하기',
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 13 * scale,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.scale, required this.items});

  final double scale;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            SettingsListTile(
              scale: scale,
              title: items[i].title,
              onTap: items[i].onTap,
              showDivider: i < items.length - 1,
            ),
        ],
      ),
    );
  }
}
