import 'package:flutter/material.dart';

const Duration onboardingTransitionDuration = Duration(milliseconds: 320);
const Curve onboardingTransitionCurve = Curves.easeInOutCubic;

/// 07~10 모달 카드 교체 — 선택 후 잠깐 쉬었다가 천천히 전환
const Duration onboardingModalSwitchDelay = Duration(milliseconds: 220);
const Duration onboardingModalSwitchDuration = Duration(milliseconds: 540);
const Duration onboardingModalSwitchReverseDuration = Duration(milliseconds: 460);
const Curve onboardingModalSwitchInCurve = Curves.easeOutCubic;
const Curve onboardingModalSwitchOutCurve = Curves.easeInCubic;

/// 12 검색 완료 → 13 웨어러블 연결 — 배경 유지, 13 입장 애니메이션에 맡김
const Duration onboardingSearchToWearableDuration = Duration(milliseconds: 1);

class OnboardingSearchToWearableRoute<T> extends PageRouteBuilder<T> {
  OnboardingSearchToWearableRoute({
    required WidgetBuilder builder,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: onboardingSearchToWearableDuration,
          reverseTransitionDuration: onboardingSearchToWearableDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              child,
        );
}

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

/// 플로우 내부 모달 교체용 페이드 + 아래에서 살짝 올라오는 슬라이드
Widget onboardingModalTransition(Widget child, Animation<double> animation) {
  final fade = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.92, curve: Curves.easeOut),
  );
  final slide = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
  );
  final scale = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
  );

  return FadeTransition(
    opacity: fade,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.018),
        end: Offset.zero,
      ).animate(slide),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.985, end: 1).animate(scale),
        child: child,
      ),
    ),
  );
}
