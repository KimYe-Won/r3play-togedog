// TogeDog 웰컴 화면
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_onboarding_05.dart';

/// Figma: 온보딩 투게독 (node 488:346)
class MainOnboarding04Screen extends StatefulWidget {
  const MainOnboarding04Screen({super.key});

  static const Duration fadeInDuration = Duration(milliseconds: 600);

  static const double designWidth = 402;
  static const double titleGroupWidth = 261.13;
  static const double logoAspectRatio = 261.38 / 45.25;
  static const double titleGroupGap = 12;
  static const double horizontalInset = 19;
  static const double buttonHeight = 47;
  static const double buttonRadius = 9;
  static const double bottomInset = 63;

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const String wordmarkAsset = 'asset/onboarding/onboarding_togedog_wordmark.svg';

  @override
  State<MainOnboarding04Screen> createState() => _MainOnboarding04ScreenState();
}

class _MainOnboarding04ScreenState extends State<MainOnboarding04Screen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeInController;
  late final Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      vsync: this,
      duration: MainOnboarding04Screen.fadeInDuration,
    );
    _fadeInAnimation = CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeInOutCubic,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fadeInController.forward();
    });
  }

  void _goToNextScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const MainOnboarding05Screen(),
      ),
    );
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.sizeOf(context).width / MainOnboarding04Screen.designWidth;
    final titleWidth = MainOnboarding04Screen.titleGroupWidth * scale;
    final logoWidth = titleWidth;
    final logoHeight = logoWidth / MainOnboarding04Screen.logoAspectRatio;
    final horizontalInset = MainOnboarding04Screen.horizontalInset * scale;
    final bottomInset = MainOnboarding04Screen.bottomInset * scale;
    final buttonHeight = MainOnboarding04Screen.buttonHeight * scale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SizedBox(
                      width: titleWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '투게독',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'LGSmartUI',
                              fontWeight: FontWeight.w700,
                              fontSize: 25 * scale,
                              height: 1.2,
                              color: MainOnboarding04Screen.brandPurple,
                            ),
                          ),
                          SizedBox(
                            height: MainOnboarding04Screen.titleGroupGap * scale,
                          ),
                          SizedBox(
                            width: logoWidth,
                            height: logoHeight,
                            child: SvgPicture.asset(
                              MainOnboarding04Screen.wordmarkAsset,
                              width: logoWidth,
                              height: logoHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(
                            height: MainOnboarding04Screen.titleGroupGap * scale,
                          ),
                          Text(
                            '“서로를 돌보는 새로운 연결”',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'LGSmartUI',
                              fontWeight: FontWeight.w600,
                              fontSize: 16 * scale,
                              height: 1.4,
                              color: MainOnboarding04Screen.textBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _StartButton(
                scale: scale,
                height: buttonHeight,
                onPressed: _goToNextScreen,
              ),
              SizedBox(height: bottomInset),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatefulWidget {
  const _StartButton({
    required this.scale,
    required this.height,
    required this.onPressed,
  });

  final double scale;
  final double height;
  final VoidCallback onPressed;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return MouseRegion(
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
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _buttonColor,
            borderRadius: BorderRadius.circular(
              MainOnboarding04Screen.buttonRadius * scale,
            ),
          ),
          child: Text(
            '시작하기',
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
    );
  }

  Color get _buttonColor {
    const base = MainOnboarding04Screen.brandPurple;
    if (_isPressed) {
      return Color.lerp(base, Colors.black, 0.16)!;
    }
    if (_isHovered) {
      return Color.lerp(base, Colors.white, 0.08)!;
    }
    return base;
  }
}
