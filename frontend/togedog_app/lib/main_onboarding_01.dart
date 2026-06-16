// 기존 띵큐 홈 화면
// 00에서 -> 01 -> 02로 가야 함
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_onboarding_02.dart';
import 'main_onboarding_03.dart';

/// Figma: 온보딩 띵큐 (node 542:5854)
class MainOnboarding01Screen extends StatefulWidget {
  const MainOnboarding01Screen({super.key});

  @override
  State<MainOnboarding01Screen> createState() => _MainOnboarding01ScreenState();
}

class _MainOnboarding01ScreenState extends State<MainOnboarding01Screen> {
  static const double designWidth = 402;

  /// onboarding_thinq_home.png 실제 픽셀 크기 (325×890)
  static const double imageNativeWidth = 325;
  static const double imageNativeHeight = 890;

  static const String _backgroundImageAsset = 'asset/onboarding_thinq_home.png';

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
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = screenWidth / designWidth;
    final imageHeight = screenWidth * (imageNativeHeight / imageNativeWidth);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: screenWidth,
          height: imageHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Image.asset(
                  _backgroundImageAsset,
                  fit: BoxFit.fill,
                ),
              ),
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
    );
  }
}
