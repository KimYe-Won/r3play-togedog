// TogeDog 웨어러블 연결 완료 화면
import 'dart:async';

import 'package:flutter/material.dart';

import 'home_01.dart';
import 'onboarding_transitions.dart';
import 'onboarding_wearable_shared.dart';
import 'pet_profile_store.dart';
/// Figma: 디바이스 연결 완료 (node 582:12748)
class MainOnboarding14Screen extends StatefulWidget {
  const MainOnboarding14Screen({
    super.key,
    required this.connectedHarnessId,
  });

  final WearableHarnessId connectedHarnessId;

  @override
  State<MainOnboarding14Screen> createState() => _MainOnboarding14ScreenState();
}

class _MainOnboarding14ScreenState extends State<MainOnboarding14Screen>
    with SingleTickerProviderStateMixin {
  static const Duration _autoNavDelay = Duration(seconds: 4);

  late final AnimationController _modalController;
  late final Animation<double> _modalFade;
  late final Animation<Offset> _modalSlide;
  bool _modalVisible = true;
  bool _navigatedAway = false;
  Timer? _autoNavTimer;

  @override
  void initState() {
    super.initState();
    _modalController = AnimationController(
      vsync: this,
      duration: onboardingModalSwitchDuration,
    );
    _modalFade = CurvedAnimation(
      parent: _modalController,
      curve: onboardingModalSwitchInCurve,
    );
    _modalSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _modalController,
        curve: onboardingModalSwitchInCurve,
      ),
    );

    _autoNavTimer = Timer(_autoNavDelay, _goToHome);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      precacheImage(
        const AssetImage(WearableConnectionTheme.productGifAsset),
        context,
      );
      _modalController.forward();
    });
  }

  @override
  void dispose() {
    _autoNavTimer?.cancel();
    _modalController.dispose();
    super.dispose();
  }

  void _goToHome() {
    if (_navigatedAway || !mounted) return;
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
  void _closeModal() {
    if (!_modalVisible) return;
    setState(() => _modalVisible = false);
    _modalController.reverse();
  }

  /// 13화면에서 연결 탭 직후와 동일한 카드 상태
  List<WearableHarnessDevice> get _devices {
    return WearableConnectionTheme.initialDevices
        .map(
          (device) => device.id == widget.connectedHarnessId
              ? device.copyWith(status: WearableConnectionStatus.connecting)
              : device,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scaler = WearableCanvasScaler(context);

    return Scaffold(
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
            child: IgnorePointer(
              child: WearableConnectionCanvas(
                scale: scaler.scale,
                devices: _devices,
                connectEnabled: false,
                entrance: WearableEntranceMotion.complete,
              ),
            ),
          ),
          if (_modalVisible)
            Positioned(
              left: scaler.canvasLeft,
              top: scaler.canvasTop,
              width: scaler.canvasWidth,
              height: scaler.canvasHeight,
              child: FadeTransition(
                opacity: _modalFade,
                child: const ColoredBox(
                  color: WearableConnectionTheme.dimOverlay,
                ),
              ),
            ),
          if (_modalVisible)
            Positioned(
              left: scaler.canvasLeft,
              top: scaler.canvasTop + scaler.y(WearableConnectionTheme.modalTop),
              width: scaler.canvasWidth,
              child: SlideTransition(
                position: _modalSlide,
                child: FadeTransition(
                  opacity: _modalFade,
                  child: _WearableConnectionCompleteModal(
                    scale: scaler.scale,
                    onClose: _closeModal,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Figma 585:12845 — 연결 완료 바텀시트
class _WearableConnectionCompleteModal extends StatelessWidget {
  const _WearableConnectionCompleteModal({
    required this.scale,
    required this.onClose,
  });

  final double scale;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: WearableConnectionTheme.designWidth * scale,
      height: WearableConnectionTheme.modalHeight * scale,
      padding: EdgeInsets.fromLTRB(
        21 * scale,
        20 * scale,
        23 * scale,
        28 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(WearableConnectionTheme.modalRadius * scale),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 19 * scale,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '연결 완료',
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w700,
                          fontSize: 16 * scale,
                          height: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 2.5 * scale,
                      child: GestureDetector(
                        onTap: onClose,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(4 * scale),
                          child: _ModalCloseIcon(size: 14 * scale),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: WearableBatteryIndicator(scale: scale),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: (19 + 8) * scale,
            bottom: 52 * scale,
            child: Center(
              child: SizedBox(
                width: WearableConnectionTheme.modalProductDisplayWidth * scale,
                height:
                    WearableConnectionTheme.modalProductDisplayHeight * scale,
                child: Image.asset(
                  WearableConnectionTheme.productGifAsset,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalCloseIcon extends StatelessWidget {
  const _ModalCloseIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ModalCloseIconPainter(
          color: WearableConnectionTheme.subtitleGray,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ModalCloseIconPainter extends CustomPainter {
  const _ModalCloseIconPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2;
    canvas.drawLine(
      Offset(inset, inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ModalCloseIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
