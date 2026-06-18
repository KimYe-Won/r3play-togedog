// TogeDog 카메라 허용 모달 (05 위)
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_onboarding_05.dart';
import 'main_onboarding_11.dart';
import 'onboarding_transitions.dart';
import 'togedog_accessibility.dart';

/// Figma: 카메라 동의 (node 817:3636) — 모달 Frame (817:3675)
enum CameraPermissionChoice { allow, deny }

class MainOnboarding10Screen extends StatelessWidget {
  const MainOnboarding10Screen({
    super.key,
    required this.guidanceMode,
    this.embedded = false,
    this.onCompleted,
  });

  final GuidanceMode guidanceMode;
  final bool embedded;
  final VoidCallback? onCompleted;

  static const double designWidth = 402;
  static const double designHeight = 875;
  static const double modalWidth = 355;
  static const double modalHeight = 217;
  static const double modalTop = 591;
  static const double modalRadius = 30;
  static const double modalPaddingHorizontal = 36;
  static const double modalPaddingVertical = 19;
  static const double iconToContentGap = 10;
  static const double messageToButtonsGap = 29;
  static const double iconWidth = 23;
  static const double iconHeight = 22;
  static const double permissionButtonsWidth = 129;
  static const double permissionButtonsHeight = 70;
  static const double permissionButtonGap = 24;
  static const double permissionButtonFontSize = 18;

  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color dimOverlay = Color(0x73000000);

  double _layoutScale(Size screenSize, EdgeInsets padding) {
    final widthScale = screenSize.width / designWidth;
    final availableHeight = screenSize.height - padding.top - padding.bottom;
    final heightScale = availableHeight / designHeight;
    return math.min(widthScale, heightScale);
  }

  void _onPermissionSelected(BuildContext context) {
    if (onCompleted != null) {
      onCompleted!();
      return;
    }
    Navigator.of(context).pushReplacement(
      OnboardingFadeRoute<void>(
        builder: (_) => const MainOnboarding11Screen(),
      ),
    );
  }

  Widget _buildModal(
      BuildContext context, double scale, double modalTopOffset) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: modalTopOffset),
        child: Container(
          width: modalWidth * scale,
          constraints: BoxConstraints(minHeight: modalHeight * scale),
          padding: EdgeInsets.fromLTRB(
            modalPaddingHorizontal * scale,
            modalPaddingVertical * scale,
            modalPaddingHorizontal * scale,
            modalPaddingVertical * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(modalRadius * scale),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: iconWidth * scale,
                height: iconHeight * scale,
                child: SvgPicture.asset(
                  'asset/onboarding/onboarding_camera_icon.svg',
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              SizedBox(height: iconToContentGap * scale),
              _CameraPermissionMessage(scale: scale),
              SizedBox(height: messageToButtonsGap * scale),
              _CameraPermissionButtons(
                scale: scale,
                onAllow: () => _onPermissionSelected(context),
                onDeny: () => _onPermissionSelected(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final screenSize = MediaQuery.sizeOf(context);
    final scale = _layoutScale(screenSize, padding);
    final modalTopOffset = modalTop * scale;
    final modal = _buildModal(context, scale, modalTopOffset);

    if (embedded) {
      return modal;
    }

    return TogedogA11y.screen(
      name: '카메라 허용',
      child: Scaffold(
        body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: MainOnboarding05Screen(
              initialSelectedMode: guidanceMode,
              interactive: false,
            ),
          ),
          const ColoredBox(color: dimOverlay),
          modal,
        ],
      ),
    ),
    );
  }
}

class _CameraPermissionMessage extends StatelessWidget {
  const _CameraPermissionMessage({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'LGSmartUI',
          fontSize: 14 * scale,
          height: 1.15,
          color: MainOnboarding10Screen.textBlack,
          letterSpacing: 0.028 * scale,
        ),
        children: const [
          TextSpan(
            text: 'LG TogeDog',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: '에서 카메라를 사용하여\n',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: '반려견의 주변 환경을 확인하고\n',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: '위험 상황을 감지하도록 허용하시겠습니까?',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _CameraPermissionButtons extends StatelessWidget {
  const _CameraPermissionButtons({
    required this.scale,
    required this.onAllow,
    required this.onDeny,
  });

  final double scale;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CameraPermissionButton(
          scale: scale,
          label: '허용',
          onTap: onAllow,
        ),
        SizedBox(height: MainOnboarding10Screen.permissionButtonGap * scale),
        _CameraPermissionButton(
          scale: scale,
          label: '허용 안함',
          onTap: onDeny,
        ),
      ],
    );
  }
}

class _CameraPermissionButton extends StatefulWidget {
  const _CameraPermissionButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  State<_CameraPermissionButton> createState() =>
      _CameraPermissionButtonState();
}

class _CameraPermissionButtonState extends State<_CameraPermissionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return TogedogA11y.button(
      label: widget.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() {
          _isHovered = false;
          _isPressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: _isPressed
                ? 0.55
                : _isHovered
                    ? 0.75
                    : 1,
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w700,
                fontSize: MainOnboarding10Screen.permissionButtonFontSize * scale,
                height: 1.2,
                color: MainOnboarding10Screen.textBlack,
                letterSpacing: 0.036 * scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
