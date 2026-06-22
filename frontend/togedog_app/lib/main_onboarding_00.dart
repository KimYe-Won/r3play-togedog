// 기존 띵큐 시작 로고 화면
import 'package:flutter/material.dart';

import 'main_onboarding_01.dart';
import 'togedog_accessibility.dart';

/// Figma: 시작화면 splash (node 488:339)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration splashDuration = Duration(seconds: 1);
  static const Duration fadeOutDuration = Duration(milliseconds: 350);
  static const Duration fadeInDuration = Duration(milliseconds: 600);

  static const double designWidth = 402;
  static const double logoWidth = 183;
  static const double logoHeight = 184;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeOutController;
  late final Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _fadeOutController = AnimationController(
      vsync: this,
      duration: SplashScreen.fadeOutDuration,
    );
    _fadeOutAnimation = CurvedAnimation(
      parent: _fadeOutController,
      curve: Curves.easeInOutCubic,
    );

    Future.delayed(SplashScreen.splashDuration, _goToHome);
  }

  Future<void> _goToHome() async {
    await _fadeOutController.forward();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: SplashScreen.fadeInDuration,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MainOnboarding01Screen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = MediaQuery.sizeOf(context).width * (SplashScreen.logoWidth / SplashScreen.designWidth);

    return TogedogA11y.screen(
      name: '시작 화면',
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(_fadeOutAnimation),
            child: TogedogA11y.decorative(
              SizedBox(
                width: logoSize,
                height: logoSize * (SplashScreen.logoHeight / SplashScreen.logoWidth),
                child: Image.asset(
                  'assets/splash/splash_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
