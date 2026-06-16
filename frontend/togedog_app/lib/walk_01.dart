// TogeDog 산책모드 탭 화면 — Figma node 1080:1391
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_shell.dart';
import 'live_camera_view.dart';
import 'walk_02.dart';

/// 하단 네비게이션 산책모드 탭
class Walk01Screen extends StatefulWidget {
  const Walk01Screen({super.key});

  @override
  State<Walk01Screen> createState() => _Walk01ScreenState();
}

class _Walk01ScreenState extends State<Walk01Screen> {
  bool _soundOn = true;

  void _openRealtimeView() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Walk02Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20 * scale,
                  8 * scale,
                  20 * scale,
                  16 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppScreenHeader(scale: scale, title: '산책 모드'),
                    SizedBox(height: 20 * scale),
                    _WalkStatusCard(scale: scale),
                    SizedBox(height: 25 * scale),
                    _LiveFeedHeader(scale: scale),
                    SizedBox(height: 8 * scale),
                    _LiveCameraCard(
                      scale: scale,
                      soundOn: _soundOn,
                      onSoundTap: () => setState(() => _soundOn = !_soundOn),
                      onFullscreenTap: _openRealtimeView,
                    ),
                    SizedBox(height: 13 * scale),
                    _CurrentStatusCard(scale: scale),
                    SizedBox(height: 15 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: _WalkActionButton(
                            scale: scale,
                            label: '[시작]',
                            filled: true,
                            onTap: _openRealtimeView,
                          ),
                        ),
                        SizedBox(width: 13 * scale),
                        Expanded(
                          child: _WalkActionButton(
                            scale: scale,
                            label: '[종료]',
                            filled: false,
                            onTap: () => Navigator.of(context).pop(),
                          ),
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
              activeTab: AppTab.walk,
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkStatusCard extends StatelessWidget {
  const _WalkStatusCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 * scale,
      padding: EdgeInsets.symmetric(horizontal: 13 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFFD4D4D4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '산책하기',
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 14 * scale,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Row(
                  children: [
                    Container(
                      width: 6 * scale,
                      height: 6 * scale,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B9748),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      '활성화 중',
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w600,
                        fontSize: 10 * scale,
                        color: const Color(0xFF1B9748),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '산책 시간',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 10 * scale,
                  color: const Color(0xFF6A6A6A),
                ),
              ),
              Text(
                '00:28:45',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 18 * scale,
                  color: const Color(0xFF8756E7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveFeedHeader extends StatelessWidget {
  const _LiveFeedHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 13 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8 * scale,
                height: 8 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFF8756E7),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                '실시간',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _SignalBars(scale: scale),
              SizedBox(width: 4 * scale),
              Text(
                '실시간 전송 중',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w400,
                  fontSize: 9 * scale,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 2 * scale,
          height: 4 * scale,
          color: const Color(0xFF1CA24E),
        ),
        SizedBox(width: 1 * scale),
        Container(
          width: 2 * scale,
          height: 6 * scale,
          color: const Color(0xFF1CA24E),
        ),
        SizedBox(width: 1 * scale),
        Container(
          width: 2 * scale,
          height: 8 * scale,
          color: const Color(0xFF1CA24E),
        ),
      ],
    );
  }
}

class _LiveCameraCard extends StatelessWidget {
  const _LiveCameraCard({
    required this.scale,
    required this.soundOn,
    required this.onSoundTap,
    required this.onFullscreenTap,
  });

  final double scale;
  final bool soundOn;
  final VoidCallback onSoundTap;
  final VoidCallback onFullscreenTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 272 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFFD4D4D4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const LiveCameraView(),
          Positioned(
            right: 12 * scale,
            bottom: 12 * scale,
            child: Row(
              children: [
                _CameraOverlayButton(
                  scale: scale,
                  onTap: onSoundTap,
                  child: Icon(
                    soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    size: 18 * scale,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8 * scale),
                _CameraOverlayButton(
                  scale: scale,
                  onTap: onFullscreenTap,
                  child: SvgPicture.asset(
                    'asset/walk_camera_fullscreen.svg',
                    width: 18 * scale,
                    height: 18 * scale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraOverlayButton extends StatelessWidget {
  const _CameraOverlayButton({
    required this.scale,
    required this.onTap,
    required this.child,
  });

  final double scale;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36 * scale,
        height: 36 * scale,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8 * scale, 15 * scale, 8 * scale, 15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: const Color(0xFFF0EAFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4 * scale),
            child: Text(
              '  현재 상태',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 12 * scale,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          SizedBox(height: 9 * scale),
          Row(
            children: [
              Expanded(
                child: _StatusMetric(
                  scale: scale,
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      TogedogAssets.svg(
                        TogedogAssets.heartCircle,
                        width: 36 * scale,
                        height: 36 * scale,
                      ),
                      TogedogAssets.svg(
                        TogedogAssets.heartIcon,
                        width: 16 * scale,
                        height: 16 * scale,
                      ),
                    ],
                  ),
                  label: '심박수',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'LGSmartUI'),
                      children: [
                        TextSpan(
                          text: '98',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: ' bpm',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
                            color: const Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badge: '정상',
                  badgeBg: const Color(0xFFFDF0F8),
                  badgeColor: const Color(0xFFFE709A),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _StatusMetric(
                  scale: scale,
                  icon: Image.asset(
                    'asset/walk_distance_icon.png',
                    width: 36 * scale,
                    height: 36 * scale,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36 * scale,
                      height: 36 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2FF),
                        borderRadius: BorderRadius.circular(18 * scale),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 20 * scale,
                        color: const Color(0xFF5684E7),
                      ),
                    ),
                  ),
                  label: '거리',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'LGSmartUI'),
                      children: [
                        TextSpan(
                          text: '1.2',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: ' km',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
                            color: const Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badge: '정상',
                  badgeBg: const Color(0xFFEAF2FF),
                  badgeColor: const Color(0xFF5684E7),
                  borderColor: const Color(0xFFEAF2FF),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _StatusMetric(
                  scale: scale,
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      TogedogAssets.svg(
                        TogedogAssets.activityCircle,
                        width: 36 * scale,
                        height: 36 * scale,
                      ),
                      TogedogAssets.svg(
                        TogedogAssets.activityIcon,
                        width: 16 * scale,
                        height: 16 * scale,
                      ),
                    ],
                  ),
                  label: '활동량',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(fontFamily: 'LGSmartUI'),
                      children: [
                        TextSpan(
                          text: '6,245',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: '걸음',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
                            color: const Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badge: '평균 25%',
                  badgeBg: const Color(0xFFF0EAFF),
                  badgeColor: const Color(0xFF8756E7),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _StatusMetric(
                  scale: scale,
                  icon: Image.asset(
                    'asset/walk_status_shield.png',
                    width: 36 * scale,
                    height: 36 * scale,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.verified_user_outlined,
                      size: 28 * scale,
                      color: const Color(0xFF1CA24E),
                    ),
                  ),
                  label: '상태',
                  value: Text(
                    '안전',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 14 * scale,
                      color: const Color(0xFF1CA24E),
                    ),
                  ),
                  badge: '정상',
                  badgeBg: const Color(0xFFC7EBCC),
                  badgeColor: const Color(0xFF41AC58),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMetric extends StatelessWidget {
  const _StatusMetric({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeBg,
    required this.badgeColor,
    this.borderColor = const Color(0xFFF4F4F8),
  });

  final double scale;
  final Widget icon;
  final String label;
  final Widget value;
  final String badge;
  final Color badgeBg;
  final Color badgeColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135 * scale,
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 13 * scale),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(6 * scale),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: label == '거리' ? 8 * scale : 10 * scale,
              color: const Color(0xFF828282),
            ),
          ),
          SizedBox(height: 4 * scale),
          value,
          const Spacer(),
          Container(
            height: 19 * scale,
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(32.5 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              badge,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w400,
                fontSize: 10 * scale,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkActionButton extends StatelessWidget {
  const _WalkActionButton({
    required this.scale,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final double scale;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF8756E7) : Colors.white,
          borderRadius: BorderRadius.circular(10 * scale),
          border: filled
              ? null
              : Border.all(color: const Color(0xFFA7ADBB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w600,
            fontSize: 15 * scale,
            color: filled ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}
