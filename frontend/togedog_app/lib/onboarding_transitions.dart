import 'package:flutter/material.dart';

const Duration onboardingTransitionDuration = Duration(milliseconds: 320);
const Curve onboardingTransitionCurve = Curves.easeInOutCubic;

/// 온보딩 모달 전환용 페이드 라우트 (슬라이드 없음)
class OnboardingFadeRoute<T> extends PageRouteBuilder<T> {
  OnboardingFadeRoute({
    required WidgetBuilder builder,
    super.settings,
    Duration? transitionDuration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration:
              transitionDuration ?? onboardingTransitionDuration,
          reverseTransitionDuration:
              transitionDuration ?? onboardingTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: onboardingTransitionCurve,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        );
}

/// 플로우 내부 모달 교체용 페이드 + 미세 슬라이드
Widget onboardingModalTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: onboardingTransitionCurve,
  );
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.012),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}
