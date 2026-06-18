// TogeDog 실시간 산책 전체보기 — Figma node 1128:899 (기본)
// 대체 레이아웃: Figma node 1080:912 — walk_shared.dart의 kWalk02UseSingleFlashlightLayout 참고
import 'package:flutter/material.dart';

import 'walk_03.dart';
import 'walk_04.dart';
import 'walk_flashlight.dart';
import 'walk_shared.dart';

class Walk02Screen extends StatefulWidget {
  const Walk02Screen({super.key});

  @override
  State<Walk02Screen> createState() => _Walk02ScreenState();
}

class _Walk02ScreenState extends State<Walk02Screen> {
  bool _flashlightOn = false;

  Future<void> _toggleFlashlight() async {
    final success = await WalkFlashlight.toggle();
    if (!mounted) return;
    setState(() => _flashlightOn = success ? WalkFlashlight.torchOn : false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('손전등을 사용할 수 없는 기기입니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openVoiceGuide() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Walk03Screen()),
    );
  }

  void _openVibrationGuide() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Walk04Screen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kWalkDesignWidth;

    return WalkRealtimeShell(
      scale: scale,
      bindFlashlight: true,
      onBack: () => Navigator.of(context).pop(),
      bottomOverlay: kWalk02UseSingleFlashlightLayout
          ? _buildLayout1128(scale)
          : _buildLayout1080(scale),
    );
  }

  /// Figma 1128:899 — 손전등 버튼만
  Widget _buildLayout1128(double scale) {
    return WalkSingleFlashlightControl(
      scale: scale,
      flashlightOn: _flashlightOn,
      onFlashlightTap: _toggleFlashlight,
    );

    // Figma 1080:912 — 3버튼 레이아웃으로 바꿀 때 아래 주석을 해제하고
    // 위 return을 주석 처리하세요.
    //
    // return WalkThreeButtonControls(
    //   scale: scale,
    //   flashlightOn: _flashlightOn,
    //   onVoiceTap: _openVoiceGuide,
    //   onFlashlightTap: _toggleFlashlight,
    //   onVibrationTap: _openVibrationGuide,
    // );
  }

  /// Figma 1080:912 — 음성·손전등·진동 3버튼
  Widget _buildLayout1080(double scale) {
    return WalkThreeButtonControls(
      scale: scale,
      flashlightOn: _flashlightOn,
      onVoiceTap: _openVoiceGuide,
      onFlashlightTap: _toggleFlashlight,
      onVibrationTap: _openVibrationGuide,
    );

    // Figma 1128:899 — 손전등만 표시할 때 아래 주석을 해제하고
    // 위 return을 주석 처리하세요.
    //
    // return WalkSingleFlashlightControl(
    //   scale: scale,
    //   flashlightOn: _flashlightOn,
    //   onFlashlightTap: _toggleFlashlight,
    // );
  }
}
