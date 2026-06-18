// TogeDog 음성 안내 오버레이 — Figma node 1080:989
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'app_shell.dart';
import 'walk_shared.dart';

class Walk03Screen extends StatefulWidget {
  const Walk03Screen({super.key});

  @override
  State<Walk03Screen> createState() => _Walk03ScreenState();
}

class _Walk03ScreenState extends State<Walk03Screen> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakGuide();
  }

  Future<void> _speakGuide() async {
    await _tts.setLanguage('ko-KR');
    await _tts.speak('전방에 위험요소가 있습니다.');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kWalkDesignWidth;

    return WalkRealtimeShell(
      scale: scale,
      onBack: () => Navigator.of(context).pop(),
      panel: WalkVoiceGuidePanel(
        scale: scale,
        onEnd: () => endWalkAndGoToWalk01(context),
      ),
    );
  }
}

/// Figma 1080:989 / 1080:1051 패널
class WalkVoiceGuidePanel extends StatelessWidget {
  const WalkVoiceGuidePanel({
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
                '음성 안내',
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
              top: 165 * s,
              width: 83.223 * s,
              height: 61.737 * s,
              child: Image.asset(
                'asset/walk/walk_voice_wave_left.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 294.93 * s,
              top: 165 * s,
              width: 83.223 * s,
              height: 61.737 * s,
              child: Image.asset(
                'asset/walk/walk_voice_wave_right.png',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 116 * s,
              top: 108 * s,
              width: 169 * s,
              height: 169 * s,
              child: Stack(
                children: [
                  Image.asset(
                    'asset/walk/walk_voice_center_group.png',
                    width: 169 * s,
                    height: 169 * s,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: 103 * s,
                    left: 0,
                    right: 0,
                    child: WalkLoadingDotsText(scale: s, baseText: '안내 중'),
                  ),
                ],
              ),
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
