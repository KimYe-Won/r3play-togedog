// TogeDog 위치 접근 허용 모달 (05 위)
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_onboarding_05.dart';
import 'main_onboarding_08.dart';
import 'onboarding_transitions.dart';
import 'togedog_accessibility.dart';

/// Figma: 위치 동의 (node 817:3215) — 모달 Frame 756 (546:6285)
enum LocationPrecision { precise, approximate }

enum LocationPermissionChoice { whileUsingApp, once, deny }

class MainOnboarding07Screen extends StatefulWidget {
  const MainOnboarding07Screen({
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
  static const double modalWidth = 385;
  static const double modalHeight = 549;
  static const double modalTop = 266;
  static const double modalRadius = 30;
  static const double modalPaddingTop = 20;
  static const double modalPaddingBottom = 28;
  static const double modalPaddingHorizontal = 23;
  static const double sectionGap = 16;
  static const double contentBlockGap = 37;
  static const double privacyToMapsGap = 23;
  static const double permissionButtonGap = 24;
  static const double permissionButtonFontSize = 18;
  static const double mapsSectionHeight = 155;
  static const double mapColumnWidth = 129;
  static const double mapColumnGap = 35;
  static const double mapLabelGap = 10;
  static const double mapLabelHeight = 16;
  static const double mapDisplaySize = 129;
  static const double preciseMapContentSize = 139;
  static const double preciseMapContentOffset = -5;
  static const double approximateColumnOffsetTop = 0;
  static const double mapSelectionBorderWidth = 4;
  static const double privacyBoxWidth = 317;
  static const double privacyBoxHeight = 64;
  static const double privacyBoxRadius = 17;
  static const double titleWidth = 283;
  static const double titleHeight = 32;
  static const double pinWidth = 27.75;
  static const double pinHeight = 37;
  static const double pawOffsetLeft = 5.11;
  static const double pawOffsetTop = 7.79;
  static const double pawWidth = 17.638;
  static const double pawHeight = 14.417;

  static const String preciseMapAsset =
      'assets/onboarding/onboarding_location_precise_map.png';
  static const String approximateMapAsset =
      'assets/onboarding/onboarding_location_approximate_map.png';
  static const String chevronAsset =
      'assets/onboarding/onboarding_location_chevron.svg';

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color privacyBorder = Color(0xFFA7ADBB);
  static const Color dimOverlay = Color(0x73000000);
  static const double privacyChevronWidth = 24.5;
  static const double privacyChevronHeight = 29;

  @override
  State<MainOnboarding07Screen> createState() => _MainOnboarding07ScreenState();
}

class _MainOnboarding07ScreenState extends State<MainOnboarding07Screen> {
  LocationPrecision _selectedPrecision = LocationPrecision.precise;

  void _onPermissionSelected(LocationPermissionChoice choice) {
    if (widget.onCompleted != null) {
      widget.onCompleted!();
      return;
    }
    Navigator.of(context).pushReplacement(
      OnboardingFadeRoute<void>(
        builder: (_) => MainOnboarding08Screen(
          guidanceMode: widget.guidanceMode,
        ),
      ),
    );
  }

  double _layoutScale(Size screenSize, EdgeInsets padding) {
    final widthScale = screenSize.width / MainOnboarding07Screen.designWidth;
    final availableHeight = screenSize.height - padding.top - padding.bottom;
    final heightScale = availableHeight / MainOnboarding07Screen.designHeight;
    return math.min(widthScale, heightScale);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final screenSize = MediaQuery.sizeOf(context);
    final scale = _layoutScale(screenSize, padding);
    final modalHeight = MainOnboarding07Screen.modalHeight * scale;
    final modalTop = MainOnboarding07Screen.modalTop * scale;

    final modal = _buildModal(scale, modalHeight, modalTop);

    if (widget.embedded) {
      return modal;
    }

    return TogedogA11y.screen(
      name: '위치 접근 허용',
      child: Scaffold(
        body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: MainOnboarding05Screen(
              initialSelectedMode: widget.guidanceMode,
              interactive: false,
            ),
          ),
          const ColoredBox(color: MainOnboarding07Screen.dimOverlay),
          modal,
        ],
      ),
    ),
    );
  }

  Widget _buildModal(double scale, double modalHeight, double modalTop) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: modalTop),
          child: Container(
            width: MainOnboarding07Screen.modalWidth * scale,
            constraints: BoxConstraints(
              minHeight: modalHeight,
            ),
            padding: EdgeInsets.fromLTRB(
              MainOnboarding07Screen.modalPaddingHorizontal * scale,
              MainOnboarding07Screen.modalPaddingTop * scale,
              MainOnboarding07Screen.modalPaddingHorizontal * scale,
              MainOnboarding07Screen.modalPaddingBottom * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                MainOnboarding07Screen.modalRadius * scale,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _LocationPinIcon(scale: scale),
                SizedBox(height: MainOnboarding07Screen.sectionGap * scale),
                _PermissionTitle(scale: scale),
                SizedBox(height: MainOnboarding07Screen.sectionGap * scale),
                _LocationContentBlock(
                  scale: scale,
                  selectedPrecision: _selectedPrecision,
                  onPrecisionSelected: (precision) {
                    setState(() => _selectedPrecision = precision);
                  },
                  onPermissionSelected: _onPermissionSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationContentBlock extends StatelessWidget {
  const _LocationContentBlock({
    required this.scale,
    required this.selectedPrecision,
    required this.onPrecisionSelected,
    required this.onPermissionSelected,
  });

  final double scale;
  final LocationPrecision selectedPrecision;
  final ValueChanged<LocationPrecision> onPrecisionSelected;
  final ValueChanged<LocationPermissionChoice> onPermissionSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: (MainOnboarding07Screen.privacyBoxHeight +
                  MainOnboarding07Screen.privacyToMapsGap +
                  MainOnboarding07Screen.mapsSectionHeight) *
              scale,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              _PrivacyNoticeBox(scale: scale),
              SizedBox(
                height: MainOnboarding07Screen.privacyToMapsGap * scale,
              ),
              _LocationOptionRow(
                scale: scale,
                selectedPrecision: selectedPrecision,
                onPrecisionSelected: onPrecisionSelected,
              ),
            ],
          ),
        ),
        SizedBox(height: MainOnboarding07Screen.contentBlockGap * scale),
        _PermissionButtonColumn(
          scale: scale,
          onPermissionSelected: onPermissionSelected,
        ),
      ],
    );
  }
}

class _LocationPinIcon extends StatelessWidget {
  const _LocationPinIcon({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final pinWidth = MainOnboarding07Screen.pinWidth * scale;
    final pinHeight = MainOnboarding07Screen.pinHeight * scale;

    return SizedBox(
      width: pinWidth,
      height: pinHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          SvgPicture.asset(
            'assets/onboarding/onboarding_location_pin_stroke.svg',
            width: pinWidth,
            height: pinHeight,
            fit: BoxFit.contain,
          ),
          Positioned(
            left: MainOnboarding07Screen.pawOffsetLeft * scale,
            top: MainOnboarding07Screen.pawOffsetTop * scale,
            child: SvgPicture.asset(
              'assets/onboarding/onboarding_location_paw.svg',
              width: MainOnboarding07Screen.pawWidth * scale,
              height: MainOnboarding07Screen.pawHeight * scale,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionTitle extends StatelessWidget {
  const _PermissionTitle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MainOnboarding07Screen.titleWidth * scale,
      height: MainOnboarding07Screen.titleHeight * scale,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontSize: 14 * scale,
            height: 1.15,
            color: MainOnboarding07Screen.textBlack,
            letterSpacing: 0.028 * scale,
          ),
          children: const [
            TextSpan(
              text: 'LG TogeDog',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: '에서 이 기기의 위치 정보에\n',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: '액세스하도록 허용하시겠습니까?',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PrivacyNoticeBox extends StatelessWidget {
  const _PrivacyNoticeBox({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MainOnboarding07Screen.privacyBoxWidth * scale,
      height: MainOnboarding07Screen.privacyBoxHeight * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            MainOnboarding07Screen.privacyBoxRadius * scale,
          ),
          border: Border.all(
            color: MainOnboarding07Screen.privacyBorder,
            width: 1 * scale,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            15 * scale,
            16 * scale,
            12 * scale,
            16 * scale,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/onboarding/onboarding_location_shield.svg',
                width: 24 * scale,
                height: 24 * scale,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  '앱에서 위치 데이터를 서드 파티와 공유할 수 있다고 명시했습니다.',
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w400,
                    fontSize: 14 * scale,
                    height: 1.15,
                    color: MainOnboarding07Screen.textBlack,
                    letterSpacing: 0.028 * scale,
                  ),
                ),
              ),
              SizedBox(
                width: MainOnboarding07Screen.privacyChevronWidth * scale,
                height: MainOnboarding07Screen.privacyChevronHeight * scale,
                child: Center(
                  child: SvgPicture.asset(
                    MainOnboarding07Screen.chevronAsset,
                    width: 4.5 * scale,
                    height: 9 * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationOptionRow extends StatelessWidget {
  const _LocationOptionRow({
    required this.scale,
    required this.selectedPrecision,
    required this.onPrecisionSelected,
  });

  final double scale;
  final LocationPrecision selectedPrecision;
  final ValueChanged<LocationPrecision> onPrecisionSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MainOnboarding07Screen.mapsSectionHeight * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LocationMapOption(
            scale: scale,
            label: '정확한 위치',
            imageAsset: MainOnboarding07Screen.preciseMapAsset,
            mapContentSize: MainOnboarding07Screen.preciseMapContentSize,
            mapContentOffset: MainOnboarding07Screen.preciseMapContentOffset,
            isSelected: selectedPrecision == LocationPrecision.precise,
            onTap: () => onPrecisionSelected(LocationPrecision.precise),
          ),
          SizedBox(width: MainOnboarding07Screen.mapColumnGap * scale),
          _LocationMapOption(
            scale: scale,
            label: '대략적인 위치',
            imageAsset: MainOnboarding07Screen.approximateMapAsset,
            topOffset: MainOnboarding07Screen.approximateColumnOffsetTop,
            isSelected:
                selectedPrecision == LocationPrecision.approximate,
            onTap: () => onPrecisionSelected(LocationPrecision.approximate),
          ),
        ],
      ),
    );
  }
}

class _LocationMapOption extends StatelessWidget {
  const _LocationMapOption({
    required this.scale,
    required this.label,
    required this.imageAsset,
    required this.isSelected,
    required this.onTap,
    this.mapContentSize,
    this.mapContentOffset = 0,
    this.topOffset = 0,
  });

  final double scale;
  final String label;
  final String imageAsset;
  final bool isSelected;
  final VoidCallback onTap;
  final double? mapContentSize;
  final double mapContentOffset;
  final double topOffset;

  @override
  Widget build(BuildContext context) {
    final columnWidth = MainOnboarding07Screen.mapColumnWidth * scale;
    final displaySize = MainOnboarding07Screen.mapDisplaySize * scale;
    final contentSize =
        (mapContentSize ?? MainOnboarding07Screen.mapDisplaySize) * scale;
    final contentOffset = mapContentOffset * scale;
    final borderWidth =
        MainOnboarding07Screen.mapSelectionBorderWidth * scale;

    return TogedogA11y.selectable(
      label: label,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
        width: columnWidth,
        height: MainOnboarding07Screen.mapsSectionHeight * scale,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: topOffset * scale),
              child: SizedBox(
                width: displaySize,
                height: displaySize,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: displaySize,
                        height: displaySize,
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            Positioned(
                              left: contentOffset,
                              top: contentOffset,
                              width: contentSize,
                              height: contentSize,
                              child: Image.asset(
                                imageAsset,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: displaySize,
                        height: displaySize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MainOnboarding07Screen.brandPurple,
                            width: borderWidth,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MainOnboarding07Screen.mapLabelGap * scale),
            SizedBox(
              height: MainOnboarding07Screen.mapLabelHeight * scale,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 14 * scale,
                    height: 1.15,
                    color: MainOnboarding07Screen.textBlack,
                    letterSpacing: 0.028 * scale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _PermissionButtonColumn extends StatelessWidget {
  const _PermissionButtonColumn({
    required this.scale,
    required this.onPermissionSelected,
  });

  final double scale;
  final ValueChanged<LocationPermissionChoice> onPermissionSelected;

  static const _options = [
    (
      choice: LocationPermissionChoice.whileUsingApp,
      label: '앱 사용 중에만 허용',
    ),
    (
      choice: LocationPermissionChoice.once,
      label: '이번만 허용',
    ),
    (
      choice: LocationPermissionChoice.deny,
      label: '허용 안함',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          _PermissionTextButton(
            scale: scale,
            label: _options[i].label,
            onTap: () => onPermissionSelected(_options[i].choice),
          ),
          if (i < _options.length - 1)
            SizedBox(
              height: MainOnboarding07Screen.permissionButtonGap * scale,
            ),
        ],
      ],
    );
  }
}

class _PermissionTextButton extends StatefulWidget {
  const _PermissionTextButton({
    required this.scale,
    required this.label,
    required this.onTap,
  });

  final double scale;
  final String label;
  final VoidCallback onTap;

  @override
  State<_PermissionTextButton> createState() => _PermissionTextButtonState();
}

class _PermissionTextButtonState extends State<_PermissionTextButton> {
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
              fontSize:
                  MainOnboarding07Screen.permissionButtonFontSize * scale,
              height: 1.25,
              color: MainOnboarding07Screen.textBlack,
              letterSpacing: 0.036 * scale,
            ),
          ),
        ),
      ),
    ),
    );
  }
}
