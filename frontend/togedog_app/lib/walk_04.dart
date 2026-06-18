// TogeDog 진동 안내 오버레이 — Figma node 1080:1183
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibration/vibration.dart';

import 'app_shell.dart';
import 'walk_shared.dart';

class Walk04Screen extends StatefulWidget {
  const Walk04Screen({super.key});

  @override
  State<Walk04Screen> createState() => _Walk04ScreenState();
}

class _Walk04ScreenState extends State<Walk04Screen> {
  @override
  void initState() {
    super.initState();
    _triggerWarningVibration();
  }

  Future<void> _triggerWarningVibration() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator != true) return;
    await Vibration.vibrate(pattern: [0, 120, 80, 120, 80, 120]);
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kWalkDesignWidth;

    return WalkRealtimeShell(
      scale: scale,
      onBack: () => Navigator.of(context).pop(),
      panel: WalkVibrationGuidePanel(
        scale: scale,
        onEnd: () => endWalkAndGoToWalk01(context),
      ),
    );
  }
}

/// Figma 1080:1183 / 1080:1245 패널
class WalkVibrationGuidePanel extends StatelessWidget {
  const WalkVibrationGuidePanel({
    super.key,
    required this.scale,
    required this.onEnd,
  });

  final double scale;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final s = scale;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 424 * s + bottomInset,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(23 * s)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 26 * s,
              child: Text(
                '진동 안내',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 20 * s,
                  height: 1,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 58 * s,
              child: Text(
                '전방에 위험요소가 있습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * s,
                  height: 1,
                  color: const Color(0xFFD4D4D4),
                ),
              ),
            ),
            Positioned(
              left: 22.53 * s,
              top: 137 * s,
              width: 83.223 * s,
              height: 61.737 * s,
              child: Image.asset(
                'asset/walk/walk_voice_wave_left.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 294.93 * s,
              top: 137 * s,
              width: 83.223 * s,
              height: 61.737 * s,
              child: Image.asset(
                'asset/walk/walk_voice_wave_right.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 116 * s,
              top: 80 * s,
              width: 169 * s,
              height: 169 * s,
              child: WalkVibrationCenterVisualizer(scale: s),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 252 * s,
              child: WalkVibrationModeRow(scale: s),
            ),
            Positioned(
              left: 19 * s,
              right: 19 * s,
              bottom: kWalkGuideEndButtonBottomInset * s + bottomInset,
              child: WalkGuideEndButton(scale: s, onTap: onEnd),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma 1080:1246(링 SVG) + 1080:1366(아이콘) + 코드 "진동 중..." 애니메이션
class WalkVibrationCenterVisualizer extends StatelessWidget {
  const WalkVibrationCenterVisualizer({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return SizedBox(
      width: 169 * s,
      height: 169 * s,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            'asset/walk/walk_vibration_center_rings.svg',
            width: 169 * s,
            height: 169 * s,
            fit: BoxFit.contain,
          ),
          // Figma 1080:1366 — 패널 (175, 135), 51×41.667 (약간 확대해 가독성 확보)
          Positioned(
            top: 40 * s,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 58 * s,
                height: 50 * s,
                child: SvgPicture.asset(
                  'asset/walk/walk_vibration_icon_figma.svg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            top: 103 * s,
            left: 0,
            right: 0,
            child: WalkLoadingDotsText(scale: s, baseText: '진동 중'),
          ),
        ],
      ),
    );
  }
}
