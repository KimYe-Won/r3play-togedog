import 'package:flutter/material.dart';

import 'main_onboarding_05.dart';
import 'main_onboarding_06.dart';
import 'main_onboarding_07.dart';
import 'main_onboarding_08.dart';
import 'main_onboarding_09.dart';
import 'main_onboarding_10.dart';
import 'main_onboarding_11.dart';
import 'onboarding_transitions.dart';

enum _OnboardingModalStep { terms, location, notification, nearby, camera }

/// 06~10 모달을 하나의 라우트에서 부드럽게 이어주는 플로우
class MainOnboardingModalFlowScreen extends StatefulWidget {
  const MainOnboardingModalFlowScreen({super.key, required this.guidanceMode});

  final GuidanceMode guidanceMode;

  @override
  State<MainOnboardingModalFlowScreen> createState() =>
      _MainOnboardingModalFlowScreenState();
}

class _MainOnboardingModalFlowScreenState
    extends State<MainOnboardingModalFlowScreen> {
  _OnboardingModalStep _step = _OnboardingModalStep.terms;

  void _goToLocation() {
    setState(() => _step = _OnboardingModalStep.location);
  }

  void _goToNotification() {
    setState(() => _step = _OnboardingModalStep.notification);
  }

  void _goToNearby() {
    setState(() => _step = _OnboardingModalStep.nearby);
  }

  void _goToCamera() {
    setState(() => _step = _OnboardingModalStep.camera);
  }

  void _goToNextScreen() {
    Navigator.of(context).pushReplacement(
      OnboardingFadeRoute<void>(
        builder: (_) => const MainOnboarding11Screen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: MainOnboarding05Screen(
              initialSelectedMode: widget.guidanceMode,
              interactive: false,
            ),
          ),
          const ColoredBox(color: Color(0x73000000)),
          AnimatedSwitcher(
            duration: onboardingTransitionDuration,
            switchInCurve: onboardingTransitionCurve,
            switchOutCurve: onboardingTransitionCurve,
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: onboardingModalTransition,
            child: _buildStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _OnboardingModalStep.terms:
        return KeyedSubtree(
          key: const ValueKey('terms'),
          child: MainOnboarding06Screen(
            guidanceMode: widget.guidanceMode,
            onAgreed: _goToLocation,
          ),
        );
      case _OnboardingModalStep.location:
        return KeyedSubtree(
          key: const ValueKey('location'),
          child: MainOnboarding07Screen(
            guidanceMode: widget.guidanceMode,
            embedded: true,
            onCompleted: _goToNotification,
          ),
        );
      case _OnboardingModalStep.notification:
        return KeyedSubtree(
          key: const ValueKey('notification'),
          child: MainOnboarding08Screen(
            guidanceMode: widget.guidanceMode,
            embedded: true,
            onCompleted: _goToNearby,
          ),
        );
      case _OnboardingModalStep.nearby:
        return KeyedSubtree(
          key: const ValueKey('nearby'),
          child: MainOnboarding09Screen(
            guidanceMode: widget.guidanceMode,
            embedded: true,
            onCompleted: _goToCamera,
          ),
        );
      case _OnboardingModalStep.camera:
        return KeyedSubtree(
          key: const ValueKey('camera'),
          child: MainOnboarding10Screen(
            guidanceMode: widget.guidanceMode,
            embedded: true,
            onCompleted: _goToNextScreen,
          ),
        );
    }
  }
}
