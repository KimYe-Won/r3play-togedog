// TogeDog 디바이스 검색 화면
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_01.dart';
import 'main_onboarding_13.dart';
import 'onboarding_transitions.dart';
import 'pet_profile_store.dart';
import 'togedog_accessibility.dart';

/// Figma: 디바이스 검색 (node 766:8339)
class MainOnboarding12Screen extends StatefulWidget {
  const MainOnboarding12Screen({super.key});

  static const double designWidth = 402;
  static const double designHeight = 875;
  static const double horizontalInset = 19;
  static const double backTop = 36;
  static const double backSize = 24;
  static const double titleTop = 121;
  static const double ringsLeft = 57;
  static const double ringsTop = 173;
  static const double ringsSize = 288;
  static const double productLeft = 131;
  static const double productTop = 224;
  static const double productWidth = 140;
  static const double productHeight = 180;

  /// PNG 여백 보정 + 추가 확대 (기존 1.55 × 1.5)
  static const double productVisualScale = 2.325;
  static const double loadingBarLeft = 22;
  static const double loadingBarTop = 494;
  static const double loadingBarWidth = 359;
  static const double loadingBarHeight = 3;
  static const double loadingSegmentWidth = 195;
  static const double loadingTailWidth = 22;

  /// 롤링 게이지 — 보라 덩어리 사이 흰 간격 (디자인 px)
  static const double loadingHeadGap = 118;
  static const double statusCardLeft = 37;
  static const double statusCardTop = 531;
  static const double statusCardWidth = 338;
  static const double statusCardHeight = 100;
  static const double statusCardRadius = 20;
  static const double helpTop = 683;
  static const double buttonTop = 764;
  static const double buttonWidth = 364;
  static const double buttonHeight = 47;
  static const double buttonRadius = 9;

  static const String productImageAsset = 'assets/onboarding/onboarding_device_product.png';
  static const String backButtonAsset = 'assets/onboarding/onboarding_profile_back.svg';
  static const String cardIconAsset = 'assets/onboarding/onboarding_device_search_card_icon.svg';
  static const String pawDecor1Asset = 'assets/onboarding/onboarding_device_search_paw_decor_1.svg';
  static const String pawDecor2Asset = 'assets/onboarding/onboarding_device_search_paw_decor_2.svg';
  static const String pawDecor3Asset = 'assets/onboarding/onboarding_device_search_paw_decor_3.svg';
  static const String starAsset = 'assets/onboarding/onboarding_device_search_star.svg';
  static const String starSmallAsset = 'assets/onboarding/onboarding_device_search_star_sm.svg';

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color brandPurpleAlt = Color(0xFF8256E8);
  static const Color gradientStart = Color(0xFFFBFBFF);
  static const Color gradientEnd = Color(0xFFF0EAFF);
  static const Color titleBlack = Color(0xFF111111);
  static const Color helpGray = Color(0xFF687080);
  static const Color ringOuter = Color(0xFFF6F3FF);
  static const Color ringMiddle = Color(0xFFF1EDFD);
  static const Color ringInner = Color(0xFFEADFFF);

  @override
  State<MainOnboarding12Screen> createState() => _MainOnboarding12ScreenState();
}

class _MainOnboarding12ScreenState extends State<MainOnboarding12Screen> with TickerProviderStateMixin {
  static const Duration _exitDuration = Duration(milliseconds: 480);

  static const Duration _autoNavDelay = Duration(seconds: 6);

  Timer? _autoNavTimer;
  late final AnimationController _loadingController;
  late final AnimationController _ringController;
  late final AnimationController _exitController;
  bool _navigatedAway = false;
  bool _isTransitioningToWearable = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _exitController = AnimationController(
      vsync: this,
      duration: _exitDuration,
    );

    _autoNavTimer = Timer(_autoNavDelay, _goToNextScreen);
  }

  @override
  void dispose() {
    _autoNavTimer?.cancel();
    _loadingController.dispose();
    _ringController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _goToNextScreen() async {
    if (_navigatedAway || _isTransitioningToWearable || !mounted) return;
    _isTransitioningToWearable = true;
    _autoNavTimer?.cancel();
    _loadingController.stop();
    _ringController.stop();

    await _exitController.forward();
    if (!mounted) return;

    await Navigator.of(context).push<void>(
      OnboardingSearchToWearableRoute<void>(
        builder: (_) => const MainOnboarding13Screen(playEntrance: true),
      ),
    );

    if (!mounted) return;
    _isTransitioningToWearable = false;
    _resumeSearchAfterWearableReturn();
  }

  void _resumeSearchAfterWearableReturn() {
    _exitController.reset();
    _loadingController.repeat();
    _ringController.repeat();
    _autoNavTimer?.cancel();
    _autoNavTimer = Timer(_autoNavDelay, _goToNextScreen);
  }

  void _onCancel() {
    if (_navigatedAway || _isTransitioningToWearable || !mounted) return;
    _navigatedAway = true;
    _autoNavTimer?.cancel();
    PetProfileStore.instance.markOnboardingCompleted();
    Navigator.of(context).pushAndRemoveUntil(
      OnboardingFadeRoute<void>(
        builder: (_) => const Home01Screen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final topPadding = media.padding.top;
    final bottomPadding = media.padding.bottom;
    final screenHeight = media.size.height;
    final availableHeight = screenHeight - topPadding - bottomPadding;
    final scale = math.min(
      screenWidth / MainOnboarding12Screen.designWidth,
      availableHeight / MainOnboarding12Screen.designHeight,
    );
    final canvasWidth = MainOnboarding12Screen.designWidth * scale;
    final canvasHeight = MainOnboarding12Screen.designHeight * scale;
    final canvasLeft = (screenWidth - canvasWidth) / 2;
    final canvasTop = topPadding + (availableHeight - canvasHeight) / 2;

    return TogedogA11y.screen(
      name: '디바이스 검색',
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MainOnboarding12Screen.gradientStart,
                    MainOnboarding12Screen.gradientEnd,
                  ],
                  stops: [0.43175, 1.0103],
                ),
              ),
            ),
            Positioned(
              left: canvasLeft,
              top: canvasTop,
              width: canvasWidth,
              height: canvasHeight,
              child: _DesignCanvas(
                scale: scale,
                ringController: _ringController,
                loadingController: _loadingController,
                exitController: _exitController,
                onCancel: _onCancel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma 402×875 캔버스 — 스크롤 없이 비율 유지
class _DesignCanvas extends StatelessWidget {
  const _DesignCanvas({
    required this.scale,
    required this.ringController,
    required this.loadingController,
    required this.exitController,
    required this.onCancel,
  });

  final double scale;
  final AnimationController ringController;
  final AnimationController loadingController;
  final AnimationController exitController;
  final VoidCallback onCancel;

  double get _exitOpacity => 1 - Curves.easeInCubic.transform(exitController.value);

  double y(double designY) => designY * scale;

  static double _productWidth(double scale) =>
      MainOnboarding12Screen.productWidth * MainOnboarding12Screen.productVisualScale * scale;

  static double _productHeight(double scale) =>
      MainOnboarding12Screen.productHeight * MainOnboarding12Screen.productVisualScale * scale;

  @override
  Widget build(BuildContext context) {
    final canvasWidth = MainOnboarding12Screen.designWidth * scale;
    final canvasHeight = MainOnboarding12Screen.designHeight * scale;

    return AnimatedBuilder(
      animation: exitController,
      builder: (context, child) {
        return SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: MainOnboarding12Screen.ringsLeft * scale,
                top: y(MainOnboarding12Screen.ringsTop),
                width: MainOnboarding12Screen.ringsSize * scale,
                height: MainOnboarding12Screen.ringsSize * scale,
                child: Opacity(
                  opacity: _exitOpacity,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _WavePulsingRings(
                        scale: scale,
                        controller: ringController,
                      ),
                      SizedBox(
                        width: _productWidth(scale),
                        height: _productHeight(scale),
                        child: Image.asset(
                          MainOnboarding12Screen.productImageAsset,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                width: canvasWidth,
                height: canvasHeight,
                child: Opacity(
                  opacity: _exitOpacity,
                  child: _DecorLayer(
                    canvasWidth: canvasWidth,
                    canvasHeight: canvasHeight,
                  ),
                ),
              ),
              Positioned(
                left: MainOnboarding12Screen.horizontalInset * scale,
                top: y(MainOnboarding12Screen.backTop),
                child: TogedogA11y.button(
                  label: '뒤로',
                  hint: '이전 화면으로',
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.all(4 * scale),
                      child: SvgPicture.asset(
                        MainOnboarding12Screen.backButtonAsset,
                        width: MainOnboarding12Screen.backSize * scale,
                        height: MainOnboarding12Screen.backSize * scale,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: y(MainOnboarding12Screen.titleTop),
                child: Opacity(
                  opacity: _exitOpacity,
                  child: Text(
                    '기기를 찾고 있어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w700,
                      fontSize: 30 * scale,
                      height: 1.1,
                      color: MainOnboarding12Screen.titleBlack,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: MainOnboarding12Screen.loadingBarLeft * scale,
                top: y(MainOnboarding12Screen.loadingBarTop),
                child: Opacity(
                  opacity: _exitOpacity,
                  child: _RollingLoadingBar(
                    scale: scale,
                    controller: loadingController,
                  ),
                ),
              ),
              Positioned(
                left: MainOnboarding12Screen.statusCardLeft * scale,
                top: y(MainOnboarding12Screen.statusCardTop),
                width: MainOnboarding12Screen.statusCardWidth * scale,
                height: MainOnboarding12Screen.statusCardHeight * scale,
                child: Opacity(
                  opacity: _exitOpacity,
                  child: _StatusCard(scale: scale),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: y(MainOnboarding12Screen.helpTop),
                child: Opacity(
                  opacity: _exitOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '기기가 보이지 않나요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w400,
                          fontSize: 15 * scale,
                          height: 1.2,
                          color: MainOnboarding12Screen.helpGray,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        '도움 받기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w700,
                          fontSize: 15 * scale,
                          height: 1.2,
                          color: MainOnboarding12Screen.brandPurpleAlt,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: (canvasWidth - MainOnboarding12Screen.buttonWidth * scale) / 2,
                top: y(MainOnboarding12Screen.buttonTop),
                width: MainOnboarding12Screen.buttonWidth * scale,
                child: Opacity(
                  opacity: _exitOpacity,
                  child: _CancelButton(scale: scale, onPressed: onCancel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 안쪽→바깥 연속 파도 맥동 (끊김 없이 겹쳐서 퍼짐)
class _WavePulsingRings extends StatelessWidget {
  const _WavePulsingRings({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final AnimationController controller;

  static const _ringRadii = [144.0, 112.0, 76.3701];
  static const _ringColors = [
    MainOnboarding12Screen.ringOuter,
    MainOnboarding12Screen.ringMiddle,
    MainOnboarding12Screen.ringInner,
  ];

  /// ringIndex 0=바깥, 1=중간, 2=안쪽(작은) — sin 파도로 항상 연결된 맥동
  static double _scaleAt(int ringIndex, double t) {
    const stagger = 0.17;
    const amplitude = 0.095;
    final waveOrder = 2 - ringIndex;

    var phase = t - waveOrder * stagger;
    phase -= phase.floorToDouble();

    final wave = math.sin(phase * math.pi);
    final smoothBump = wave * wave;

    return 1 + amplitude * smoothBump;
  }

  @override
  Widget build(BuildContext context) {
    final size = MainOnboarding12Screen.ringsSize * scale;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < _ringRadii.length; i++)
                Transform.scale(
                  scale: _scaleAt(i, controller.value),
                  child: Container(
                    width: _ringRadii[i] * 2 * scale,
                    height: _ringRadii[i] * 2 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _ringColors[i],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DecorLayer extends StatelessWidget {
  const _DecorLayer({
    required this.canvasWidth,
    required this.canvasHeight,
  });

  final double canvasWidth;
  final double canvasHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _InsetAsset(
          asset: MainOnboarding12Screen.pawDecor1Asset,
          topRatio: 0.2574,
          rightRatio: 0.831,
          bottomRatio: 0.6995,
          leftRatio: 0.0697,
          rotation: -21.05 * math.pi / 180,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: MainOnboarding12Screen.pawDecor2Asset,
          topRatio: 0.4439,
          rightRatio: 0.7617,
          bottomRatio: 0.5098,
          leftRatio: 0.1343,
          rotation: -30.63 * math.pi / 180,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: MainOnboarding12Screen.pawDecor3Asset,
          topRatio: 0.3513,
          rightRatio: 0.1054,
          bottomRatio: 0.6076,
          leftRatio: 0.7985,
          rotation: 16.53 * math.pi / 180,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: MainOnboarding12Screen.starAsset,
          topRatio: 0.2174,
          rightRatio: 0.2015,
          bottomRatio: 0.7677,
          leftRatio: 0.7662,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: MainOnboarding12Screen.starAsset,
          topRatio: 0.4851,
          rightRatio: 0.2786,
          bottomRatio: 0.5,
          leftRatio: 0.6891,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: MainOnboarding12Screen.starAsset,
          topRatio: 0.2323,
          rightRatio: 0.7612,
          bottomRatio: 0.7529,
          leftRatio: 0.2065,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: MainOnboarding12Screen.starSmallAsset,
          topRatio: 0.4039,
          rightRatio: 0.8881,
          bottomRatio: 0.5755,
          leftRatio: 0.0672,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
      ],
    );
  }
}

class _InsetAsset extends StatelessWidget {
  const _InsetAsset({
    required this.asset,
    required this.topRatio,
    required this.rightRatio,
    required this.bottomRatio,
    required this.leftRatio,
    required this.canvasWidth,
    required this.canvasHeight,
    this.rotation = 0,
  });

  final String asset;
  final double topRatio;
  final double rightRatio;
  final double bottomRatio;
  final double leftRatio;
  final double canvasWidth;
  final double canvasHeight;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final top = canvasHeight * topRatio;
    final left = canvasWidth * leftRatio;
    final width = canvasWidth * (1 - leftRatio - rightRatio);
    final height = canvasHeight * (1 - topRatio - bottomRatio);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: rotation,
        child: SvgPicture.asset(
          asset,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// 보라 그라데이션 세그먼트가 왼쪽→오른쪽으로 연속 롤링
class _RollingLoadingBar extends StatelessWidget {
  const _RollingLoadingBar({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final trackWidth = MainOnboarding12Screen.loadingBarWidth * scale;
    final barHeight = MainOnboarding12Screen.loadingBarHeight * scale;
    final segmentWidth = MainOnboarding12Screen.loadingSegmentWidth * scale;
    final tailWidth = MainOnboarding12Screen.loadingTailWidth * scale;
    final headWidth = segmentWidth + tailWidth;
    final headGap = MainOnboarding12Screen.loadingHeadGap * scale;
    final loopUnit = headWidth + headGap;
    final radius = barHeight / 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: trackWidth,
        height: barHeight,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final base = controller.value * loopUnit;

            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const ColoredBox(color: Colors.white),
                for (final i in [-1, 0])
                  Positioned(
                    left: base + i * loopUnit,
                    top: 0,
                    child: _LoadingBarHead(
                      width: headWidth,
                      barHeight: barHeight,
                      radius: radius,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoadingBarHead extends StatelessWidget {
  const _LoadingBarHead({
    required this.width,
    required this.barHeight,
    required this.radius,
  });

  final double width;
  final double barHeight;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            MainOnboarding12Screen.brandPurple,
            MainOnboarding12Screen.brandPurple,
            MainOnboarding12Screen.gradientEnd,
          ],
          stops: [0, 0.78, 1],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          MainOnboarding12Screen.statusCardRadius * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * scale, 22 * scale, 35 * scale, 22 * scale),
        child: Row(
          children: [
            SvgPicture.asset(
              MainOnboarding12Screen.cardIconAsset,
              width: 56 * scale,
              height: 56 * scale,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 17 * scale),
            Expanded(
              child: Text(
                '주변 기기를 찾는 중이에요',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize: 15 * scale,
                  height: 1.2,
                  color: MainOnboarding12Screen.titleBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelButton extends StatefulWidget {
  const _CancelButton({
    required this.scale,
    required this.onPressed,
  });

  final double scale;
  final VoidCallback onPressed;

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return TogedogA11y.button(
      label: '취소',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: double.infinity,
            height: MainOnboarding12Screen.buttonHeight * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _buttonColor,
              borderRadius: BorderRadius.circular(
                MainOnboarding12Screen.buttonRadius * scale,
              ),
            ),
            child: Text(
              '취소',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
                height: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _buttonColor {
    const base = MainOnboarding12Screen.brandPurple;
    if (_isPressed) {
      return Color.lerp(base, Colors.black, 0.16)!;
    }
    if (_isHovered) {
      return Color.lerp(base, Colors.white, 0.08)!;
    }
    return base;
  }
}
