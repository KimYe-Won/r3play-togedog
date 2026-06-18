// 기존 띵큐 홈 화면
// 00에서 -> 01 -> 02로 가야 함
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_onboarding_02.dart';
import 'main_onboarding_03.dart';
import 'togedog_accessibility.dart';

enum ThinqTab { home, device, care, menu }

class _ThinqAssets {
  static const background = 'asset/onboarding/onboarding_thinq_home.png';
  static const navBarBackground = 'asset/onboarding/onboarding_thinq_nav_bar_bg.png';
  static const navHomeActive = 'asset/onboarding/onboarding_thinq_nav_home_active.svg';
  static const navHomeInactive = 'asset/onboarding/onboarding_thinq_nav_home_inactive.svg';
  static const navDeviceActive = 'asset/onboarding/onboarding_thinq_nav_device_active.svg';
  static const navDeviceInactive = 'asset/onboarding/onboarding_thinq_nav_device_inactive.svg';
  static const navCareActive = 'asset/onboarding/onboarding_thinq_nav_care_active.svg';
  static const navCareInactive = 'asset/onboarding/onboarding_thinq_nav_care_inactive.svg';
  static const navMenuActive = 'asset/onboarding/onboarding_thinq_nav_menu_active.svg';
  static const navMenuInactive = 'asset/onboarding/onboarding_thinq_nav_menu_inactive.svg';
}

/// Figma: 온보딩 띵큐 (node 542:5854)
class MainOnboarding01Screen extends StatefulWidget {
  const MainOnboarding01Screen({super.key});

  @override
  State<MainOnboarding01Screen> createState() => _MainOnboarding01ScreenState();
}

class _MainOnboarding01ScreenState extends State<MainOnboarding01Screen> {
  static const double designWidth = 402;
  static const double designHeight = 1030;

  OnboardingApp _selectedApp = OnboardingApp.thinq;
  bool _isAppSwitchOpen = false;

  Future<void> _openAppSwitch() async {
    setState(() => _isAppSwitchOpen = true);

    final result = await openOnboarding02(
      context,
      selectedApp: _selectedApp,
    );

    if (mounted) {
      setState(() => _isAppSwitchOpen = false);
    }

    if (!mounted || result == null) return;

    setState(() => _selectedApp = result);

    if (result == OnboardingApp.togedog) {
      await openTogedogApp(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFE8F0F5),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scale = screenWidth / designWidth;
    final contentHeight = screenWidth * (designHeight / designWidth);

    return TogedogA11y.screen(
      name: '띵큐 홈',
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: screenWidth,
                height: contentHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: TogedogA11y.decorative(
                        Image.asset(
                          _ThinqAssets.background,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    ..._ThinqScreenTexts.build(scale),
                    if (!_isAppSwitchOpen)
                      Positioned(
                        left: 20 * scale,
                        top: 42 * scale,
                        child: HomeTitleButton(
                          scale: scale,
                          onPressed: _openAppSwitch,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          ThinqBottomNav(
            scale: scale,
            bottomInset: bottomInset,
            activeTab: ThinqTab.home,
          ),
        ],
      ),
    ),
    );
  }
}

/// Figma 542:5854 텍스트 레이어
class _ThinqScreenTexts {
  static const _black = Color(0xFF1A1A1A);
  static const _gray = Color(0xFF6A6A6A);
  static const _white = Color(0xFFFFFFFF);

  static List<Widget> build(double scale) {
    TextStyle regular(double size, Color color, {double? letterSpacing}) =>
        TextStyle(
          fontFamily: 'LGSmartUI',
          fontWeight: FontWeight.w400,
          fontSize: size * scale,
          height: 1.2,
          color: color,
          letterSpacing: letterSpacing != null ? letterSpacing * scale : null,
        );

    TextStyle bold(double size, Color color, {double? letterSpacing}) =>
        TextStyle(
          fontFamily: 'LGSmartUI',
          fontWeight: FontWeight.w700,
          fontSize: size * scale,
          height: 1.17,
          color: color,
          letterSpacing: letterSpacing != null ? letterSpacing * scale : null,
        );

    Widget text({
      required double left,
      required double top,
      double? width,
      required String value,
      required TextStyle style,
      TextAlign align = TextAlign.start,
      bool singleLine = false,
    }) {
      return Positioned(
        left: left * scale,
        top: top * scale,
        width: width != null ? width * scale : null,
        child: Text(
          value,
          textAlign: align,
          maxLines: singleLine ? 1 : null,
          softWrap: !singleLine,
          style: style,
        ),
      );
    }

    return [
      text(
        left: 107,
        top: 112,
        width: 263,
        value: '제품에 이상 징후가 발견되면 전문 상담사가\n알려드려요.',
        style: regular(15, _black, letterSpacing: 0.15),
      ),
      text(
        left: 111,
        top: 231,
        width: 263,
        value: '3D 홈뷰로 우리집과 제품의 실시간 상태를\n한눈에 확인해보세요.',
        style: regular(15, _black, letterSpacing: 0.15),
      ),
      text(
        left: 42,
        top: 396,
        width: 321,
        value: '제품을 추가하고 즐겨찾는 제품으로 배치하면 화면에서 바로 사용할 수 있어요.',
        style: regular(14, _gray),
        align: TextAlign.center,
      ),
      text(
        left: 34,
        top: 898,
        value: '여러 대의 에어컨을 함께 제어해요',
        style: regular(18, _black, letterSpacing: -0.36),
      ),
      text(
        left: 54,
        top: 650,
        value: '루틴 알아보기',
        style: regular(15, _black),
        singleLine: true,
      ),
      text(
        left: 122,
        top: 162,
        value: '지금 알아보기',
        style: regular(13, const Color(0xFF4B58B8), letterSpacing: 0.13),
      ),
      text(
        left: 126,
        top: 280,
        value: '3D 홈뷰 만들기',
        style: regular(13, const Color(0xFF4B58B8), letterSpacing: 0.13),
      ),
      text(
        left: 192,
        top: 443,
        value: '제품 추가',
        style: regular(13, const Color(0xFF4C62F2), letterSpacing: 0.13),
      ),
      text(
        left: 190,
        top: 986,
        value: '화면 편집',
        style: regular(13, const Color(0xFF4D5EEA), letterSpacing: 0.13),
      ),
      text(
        left: 34,
        top: 923,
        value: '그룹 제어 기능으로 에어컨들을 동시에 제어할 수 있어요',
        style: regular(13, _gray, letterSpacing: -0.13),
      ),
      text(
        left: 89,
        top: 544,
        value: '앱을 다운로드하여 제품과 공간을 업그레이드해보세요.',
        style: regular(12, _white, letterSpacing: 0.12),
      ),
      text(
        left: 18,
        top: 345,
        value: '즐겨 찾는 제품',
        style: bold(18, _black, letterSpacing: -0.36),
      ),
      text(
        left: 18,
        top: 599,
        value: '스마트 루틴',
        style: bold(18, _black, letterSpacing: -0.36),
      ),
      text(
        left: 18,
        top: 719,
        value: 'ThinQ 활용하기',
        style: bold(18, _black, letterSpacing: -0.36),
      ),
      text(
        left: 88,
        top: 522,
        value: 'ThinQ PLAY',
        style: bold(16, _white, letterSpacing: -0.32),
      ),
    ];
  }
}

class ThinqBottomNav extends StatelessWidget {
  const ThinqBottomNav({
    super.key,
    required this.scale,
    required this.bottomInset,
    required this.activeTab,
  });

  final double scale;
  final double bottomInset;
  final ThinqTab activeTab;

  static const _activeColor = Color(0xFF111111);
  static const _inactiveColor = Color(0xFF767676);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        38 * scale,
        19 * scale,
        38 * scale,
        19 * scale + bottomInset,
      ),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_ThinqAssets.navBarBackground),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ThinqNavItem(
            scale: scale,
            label: '홈',
            active: activeTab == ThinqTab.home,
            iconActive: _ThinqAssets.navHomeActive,
            iconInactive: _ThinqAssets.navHomeInactive,
            iconWidth: 24 * scale,
            iconHeight: 24 * scale,
          ),
          _ThinqNavItem(
            scale: scale,
            label: '디바이스',
            active: activeTab == ThinqTab.device,
            iconActive: _ThinqAssets.navDeviceActive,
            iconInactive: _ThinqAssets.navDeviceInactive,
            iconWidth: 24 * scale,
            iconHeight: 24 * scale,
          ),
          _ThinqNavItem(
            scale: scale,
            label: '케어',
            active: activeTab == ThinqTab.care,
            iconActive: _ThinqAssets.navCareActive,
            iconInactive: _ThinqAssets.navCareInactive,
            iconWidth: 24 * scale,
            iconHeight: 24 * scale,
          ),
          _ThinqNavItem(
            scale: scale,
            label: '메뉴',
            active: activeTab == ThinqTab.menu,
            iconActive: _ThinqAssets.navMenuActive,
            iconInactive: _ThinqAssets.navMenuInactive,
            iconWidth: 24 * scale,
            iconHeight: 24 * scale,
          ),
        ],
      ),
    );
  }
}

class _ThinqNavItem extends StatelessWidget {
  const _ThinqNavItem({
    required this.scale,
    required this.label,
    required this.iconActive,
    required this.iconInactive,
    required this.iconWidth,
    required this.iconHeight,
    required this.active,
  });

  final double scale;
  final String label;
  final String iconActive;
  final String iconInactive;
  final double iconWidth;
  final double iconHeight;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? ThinqBottomNav._activeColor : ThinqBottomNav._inactiveColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24 * scale,
          height: 24 * scale,
          child: Center(
            child: SvgPicture.asset(
              active ? iconActive : iconInactive,
              width: iconWidth,
              height: iconHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w600,
            fontSize: 12 * scale,
            color: color,
          ),
        ),
      ],
    );
  }
}
