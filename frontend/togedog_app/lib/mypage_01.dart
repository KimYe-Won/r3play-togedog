// TogeDog 마이페이지 — Figma node 488:202
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'pet_profile_store.dart';

class Mypage01Screen extends StatelessWidget {
  const Mypage01Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final profile = PetProfileStore.instance;
    final displayName = '${profile.displayPetName}아빠';
    final petName = profile.displayPetName;

    return Scaffold(
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
                    ),
                    SizedBox(height: 16 * scale),
                    _MembershipRow(scale: scale),
                    SizedBox(height: 20 * scale),
                    _SectionHeader(scale: scale, title: '접근성 설정'),
                    SizedBox(height: 8 * scale),
                    _SettingsCard(
                      scale: scale,
                      items: const ['장애유형 선택'],
                    ),
                    SizedBox(height: 20 * scale),
                    _SectionHeader(scale: scale, title: '알림 방식 설정'),
                    SizedBox(height: 8 * scale),
                    _SettingsCard(
                      scale: scale,
                      items: const ['음성 (TTS)', '진동', '텍스트'],
                    ),
                    SizedBox(height: 20 * scale),
                    _SectionHeader(scale: scale, title: '인터페이스 설정'),
                    SizedBox(height: 8 * scale),
                    _SettingsCard(
                      scale: scale,
                      items: const ['글자크기', '음성속도', '진동강도'],
                    ),
                    SizedBox(height: 20 * scale),
                    _SectionHeader(scale: scale, title: '기기 및 서비스 관리'),
                    SizedBox(height: 8 * scale),
                    _SettingsCard(
                      scale: scale,
                      items: const [
                        '웨어러블 디바이스 관리',
                        '카메라 및 센서 정상 작동 여부 진단',
                        '배터리 잔량 확인 및 소모품 교체 주기 알림 설정',
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
    );
  }
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
  });

  final double scale;
  final String displayName;
  final String petName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90 * scale,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserAvatar(scale: scale),
              SizedBox(width: 22 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Image.asset(
                        'asset/mypage/mypage_edit_name.png',
                        width: 15 * scale,
                        height: 15 * scale,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.edit,
                          size: 14 * scale,
                          color: const Color(0xFF6A6A6A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  Container(
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
                ],
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            child: _PetAvatar(scale: scale, petName: petName),
          ),
          Positioned(
            left: 100 * scale,
            top: 37 * scale,
            child: CustomPaint(
              size: Size(170 * scale, 2),
              painter: _DashedLinePainter(color: const Color(0xFF8756E7)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78 * scale,
      height: 78 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Image.asset(
              'asset/mypage/mypage_profile_user.png',
              width: 78 * scale,
              height: 78 * scale,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 78 * scale,
                height: 78 * scale,
                color: const Color(0xFFE8E8EC),
                child: Icon(Icons.person, size: 40 * scale),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'asset/mypage/mypage_edit_avatar.png',
              width: 28 * scale,
              height: 28 * scale,
              errorBuilder: (_, __, ___) => Container(
                width: 28 * scale,
                height: 28 * scale,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 14 * scale),
              ),
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
    return SizedBox(
      width: 78 * scale,
      height: 90 * scale,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            'asset/mypage/mypage_pet_ring.png',
            width: 68 * scale,
            height: 68 * scale,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Positioned(
            top: 3 * scale,
            child: ClipOval(
              child: Image.asset(
                TogedogAssets.petPhoto,
                width: 65 * scale,
                height: 65 * scale,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  TogedogAssets.petPhotoFallback,
                  width: 65 * scale,
                  height: 65 * scale,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Text(
              petName,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 10 * scale,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  final List<String> items;

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
              title: items[i],
              showDivider: i < items.length - 1,
            ),
        ],
      ),
    );
  }
}
