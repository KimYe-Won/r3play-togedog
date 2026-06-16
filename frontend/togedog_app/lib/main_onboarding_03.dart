// TogeDog 전환 로딩 화면
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gif/gif.dart';

import 'home_01.dart';
import 'main_onboarding_04.dart';
import 'pet_profile_store.dart';

/// Figma: TogeDog 전환 모달 (node 557:9467)
class MainOnboarding03Screen extends StatefulWidget {
  const MainOnboarding03Screen({super.key});

  static const double designWidth = 402;
  static const double gifWidth = 220;
  static const Duration loadingDuration = Duration(seconds: 3);
  static const String gifAsset = 'asset/onboarding_togedog_modal.gif';

  @override
  State<MainOnboarding03Screen> createState() => _MainOnboarding03ScreenState();
}

class _MainOnboarding03ScreenState extends State<MainOnboarding03Screen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: MainOnboarding03Screen.loadingDuration,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _progressController.forward().whenComplete(_goToNextScreen);
    });
  }

  void _goToNextScreen() async {
    if (!mounted) return;
    const loader = SvgAssetLoader(MainOnboarding04Screen.wordmarkAsset);
    await svg.cache.putIfAbsent(
      loader.cacheKey(null),
      () => loader.loadBytes(null),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MainOnboarding04Screen();
        },
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.sizeOf(context).width / MainOnboarding03Screen.designWidth;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 320 * scale,
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            24 * scale,
            20 * scale,
            28 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFC),
            borderRadius: BorderRadius.circular(24 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MainOnboarding03Screen.gifWidth * scale,
                height: 160 * scale,
                child: Gif(
                  image: const AssetImage(MainOnboarding03Screen.gifAsset),
                  autostart: Autostart.loop,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                'LG TogeDog으로\n전환 중입니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize: 18 * scale,
                  height: 26 / 18,
                  color: const Color(0xFF111111),
                ),
              ),
              SizedBox(height: 24 * scale),
              SizedBox(
                width: MainOnboarding03Screen.gifWidth * scale,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return _LoadingBar(
                      scale: scale,
                      progress: _progressAnimation.value,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({
    required this.scale,
    required this.progress,
  });

  final double scale;
  final double progress;

  static const Color _trackColor = Color(0xFFE0E0E0);
  static const Color _fillColor = Color(0xFF8756E7);

  @override
  Widget build(BuildContext context) {
    final fillFactor = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4 * scale),
      child: SizedBox(
        width: double.infinity,
        height: 6 * scale,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            const ColoredBox(color: _trackColor),
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fillFactor,
                heightFactor: 1,
                child: const ColoredBox(color: _fillColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 온보딩 완료 후 앱 전환에서 TogeDog 선택 시 홈으로, 최초는 03→04~14 온보딩
Future<void> openTogedogApp(BuildContext context) async {
  if (PetProfileStore.instance.onboardingCompleted) {
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const Home01Screen()),
      (_) => false,
    );
    return;
  }
  await openOnboarding03(context);
}

Future<void> openOnboarding03(BuildContext context) async {
  await precacheImage(
    const AssetImage(MainOnboarding03Screen.gifAsset),
    context,
  );
  if (!context.mounted) return;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '전환 중',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const MainOnboarding03Screen();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
