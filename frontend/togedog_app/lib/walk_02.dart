// TogeDog 실시간 산책 화면 — Figma node 1080:912
import 'package:flutter/material.dart';

import 'live_camera_view.dart';

class Walk02Screen extends StatelessWidget {
  const Walk02Screen({super.key});

  static const double _designWidth = 402;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / _designWidth;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: LiveCameraView()),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 217 * scale,
            child: Image.asset(
              'asset/walk/walk_top_gradient.png',
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.72),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 200 * scale + bottomInset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  left: 26 * scale,
                  top: 8 * scale,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 18 * scale,
                          color: Colors.white,
                        ),
                        SizedBox(width: 9 * scale),
                        Text(
                          '실시간',
                          style: TextStyle(
                            fontFamily: 'LGSmartUI',
                            fontWeight: FontWeight.w700,
                            fontSize: 20 * scale,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 25 * scale,
                  top: 47 * scale + topInset * 0,
                  child: Row(
                    children: [
                      Container(
                        width: 8 * scale,
                        height: 8 * scale,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFD2B30),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        '실시간 전송 중',
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w600,
                          fontSize: 14 * scale,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 23 * scale,
                  top: 46 * scale,
                  child: Container(
                    height: 27 * scale,
                    padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFA5A5A5)),
                      borderRadius: BorderRadius.circular(13.5 * scale),
                    ),
                    alignment: Alignment.center,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w600,
                          fontSize: 14 * scale,
                          color: Colors.white,
                        ),
                        children: const [
                          TextSpan(text: '산책 시간 '),
                          TextSpan(
                            text: '00:28:45',
                            style: TextStyle(color: Color(0xFFFD2B30)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24 * scale + bottomInset,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _WalkControlButton(
                        scale: scale,
                        asset: 'asset/walk/walk_btn_voice.png',
                        label: '음성 안내',
                        fallbackIcon: Icons.mic_none,
                      ),
                      _WalkControlButton(
                        scale: scale,
                        asset: 'asset/walk/walk_btn_flashlight.png',
                        label: '손전등',
                        fallbackIcon: Icons.flashlight_on_outlined,
                      ),
                      _WalkControlButton(
                        scale: scale,
                        asset: 'asset/walk/walk_btn_vibration.png',
                        label: '진동 안내',
                        fallbackIcon: Icons.vibration,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkControlButton extends StatelessWidget {
  const _WalkControlButton({
    required this.scale,
    required this.asset,
    required this.label,
    required this.fallbackIcon,
  });

  final double scale;
  final String asset;
  final String label;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 55 * scale,
          height: 55 * scale,
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(fallbackIcon, color: Colors.white, size: 24 * scale),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w600,
            fontSize: 14 * scale,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
