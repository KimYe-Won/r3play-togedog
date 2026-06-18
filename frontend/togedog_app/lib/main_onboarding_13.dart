// TogeDog 웨어러블 연결 화면
import 'package:flutter/material.dart';

import 'main_onboarding_14.dart';
import 'onboarding_transitions.dart';
import 'onboarding_wearable_shared.dart';
import 'togedog_accessibility.dart';

/// Figma: 디바이스 연결 (node 488:359)
class MainOnboarding13Screen extends StatefulWidget {
  const MainOnboarding13Screen({
    super.key,
    this.playEntrance = false,
  });

  /// 12화면 검색 완료 후 진입 시 입장 애니메이션 재생
  final bool playEntrance;

  @override
  State<MainOnboarding13Screen> createState() => _MainOnboarding13ScreenState();
}

class _MainOnboarding13ScreenState extends State<MainOnboarding13Screen>
    with SingleTickerProviderStateMixin {
  static const Duration _entranceDuration = Duration(milliseconds: 920);

  List<WearableHarnessDevice> _devices =
      List<WearableHarnessDevice>.from(WearableConnectionTheme.initialDevices);
  bool _isConnecting = false;
  AnimationController? _entranceController;

  @override
  void initState() {
    super.initState();
    if (widget.playEntrance) {
      _entranceController = AnimationController(
        vsync: this,
        duration: _entranceDuration,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _entranceController?.forward();
      });
    }
  }

  @override
  void dispose() {
    _entranceController?.dispose();
    super.dispose();
  }

  WearableEntranceMotion get _entranceMotion {
    if (_entranceController == null) {
      return WearableEntranceMotion.complete;
    }
    return WearableEntranceMotion.fromProgress(_entranceController!.value);
  }

  Future<void> _onConnect(WearableHarnessId id) async {
    if (_isConnecting) return;
    _isConnecting = true;

    setState(() {
      _devices = _devices
          .map(
            (device) => device.id == id
                ? device.copyWith(status: WearableConnectionStatus.connecting)
                : device,
          )
          .toList();
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      OnboardingFadeRoute<void>(
        builder: (_) => MainOnboarding14Screen(connectedHarnessId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaler = WearableCanvasScaler(context);

    return TogedogA11y.screen(
      name: '웨어러블 연결',
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
                  WearableConnectionTheme.gradientStart,
                  WearableConnectionTheme.gradientEnd,
                ],
                stops: [0.43175, 1.0103],
              ),
            ),
          ),
          Positioned(
            left: scaler.canvasLeft,
            top: scaler.canvasTop,
            width: scaler.canvasWidth,
            height: scaler.canvasHeight,
            child: AnimatedBuilder(
              animation: _entranceController ?? kAlwaysCompleteAnimation,
              builder: (context, child) {
                return WearableConnectionCanvas(
                  scale: scaler.scale,
                  devices: _devices,
                  onConnect: _onConnect,
                  entrance: _entranceMotion,
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}
