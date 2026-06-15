// TogeDog 근처 기기 위치 동의 모달 (05 위)
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_onboarding_05.dart';
import 'main_onboarding_10.dart';
import 'onboarding_transitions.dart';

/// Figma: 기기 위치 동의 (node 817:3586) — 모달 Frame (817:3626)
enum NearbyDevicePermissionChoice { allow, deny }

class MainOnboarding09Screen extends StatelessWidget {
  const MainOnboarding09Screen({
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
  static const double modalTop = 591;
  static const double modalRadius = 30;
  static const double modalPaddingHorizontal = 36;
  static const double modalPaddingVertical = 19;
  static const double sectionGap = 24;
  static const double iconTitleGap = 10;
  static const double iconSize = 27;
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
        builder: (_) => MainOnboarding10Screen(guidanceMode: guidanceMode),
      ),
    );
  }

  Widget _buildModal(BuildContext context, double scale, double modalTopOffset) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: modalTopOffset),
        child: Container(
          width: modalWidth * scale,
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
              _NearbyDeviceHeader(scale: scale),
              SizedBox(height: sectionGap * scale),
              _NearbyDevicePermissionButtons(
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

    return Scaffold(
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
    );
  }
}

class _NearbyDeviceHeader extends StatelessWidget {
  const _NearbyDeviceHeader({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: MainOnboarding09Screen.iconSize * scale,
          height: MainOnboarding09Screen.iconSize * scale,
          child: SvgPicture.asset(
            'asset/onboarding_nearby_device_icon.svg',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        SizedBox(height: MainOnboarding09Screen.iconTitleGap * scale),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontSize: 14 * scale,
              height: 1.15,
              color: MainOnboarding09Screen.textBlack,
              letterSpacing: 0.028 * scale,
            ),
            children: const [
              TextSpan(
                text: 'LG TogeDog',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: '에서 근처에 있는 기기를 찾아\n',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: '연결하고 기기 간 상대적 위치를 파악하도록\n',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: '허용하시겠습니까?',
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NearbyDevicePermissionButtons extends StatelessWidget {
  const _NearbyDevicePermissionButtons({
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
        _NearbyDevicePermissionButton(
          scale: scale,
          label: '허용',
          onTap: onAllow,
        ),
        SizedBox(height: MainOnboarding09Screen.permissionButtonGap * scale),
        _NearbyDevicePermissionButton(
          scale: scale,
          label: '허용 안함',
          onTap: onDeny,
        ),
      ],
    );
  }
}

class _NearbyDevicePermissionButton extends StatefulWidget {
  const _NearbyDevicePermissionButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  State<_NearbyDevicePermissionButton> createState() =>
      _NearbyDevicePermissionButtonState();
}

class _NearbyDevicePermissionButtonState
    extends State<_NearbyDevicePermissionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return MouseRegion(
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
              fontSize:
                  MainOnboarding09Screen.permissionButtonFontSize * scale,
              height: 1.25,
              color: MainOnboarding09Screen.textBlack,
              letterSpacing: 0.036 * scale,
            ),
          ),
        ),
      ),
    );
  }
}
