// 띵큐 -> 투게독 전환 화면
import 'package:flutter/material.dart';

/// Figma: 온보딩 띵큐 앱 전환 모달 (node 542:5924)
enum OnboardingApp { thinq, togedog }

/// 01 위에 투명 라우트로 올라오는 02 화면
class MainOnboarding02Screen extends StatefulWidget {
  const MainOnboarding02Screen({
    super.key,
    required this.initialApp,
  });

  final OnboardingApp initialApp;

  static const double designWidth = 402;
  static const Duration togedogSelectionHoldDuration =
      Duration(milliseconds: 450);

  @override
  State<MainOnboarding02Screen> createState() => _MainOnboarding02ScreenState();
}

class _MainOnboarding02ScreenState extends State<MainOnboarding02Screen> {
  late OnboardingApp _selectedApp;
  bool _isProceedingToTogedog = false;

  @override
  void initState() {
    super.initState();
    _selectedApp = widget.initialApp;
  }

  void _close() {
    if (_isProceedingToTogedog) return;
    Navigator.of(context).pop(_selectedApp);
  }

  void _onAppSelected(OnboardingApp app) {
    if (_isProceedingToTogedog) return;

    if (app == OnboardingApp.togedog) {
      setState(() {
        _selectedApp = app;
        _isProceedingToTogedog = true;
      });
      Future.delayed(MainOnboarding02Screen.togedogSelectionHoldDuration, () {
        if (!mounted) return;
        Navigator.of(context).pop(OnboardingApp.togedog);
      });
      return;
    }

    setState(() => _selectedApp = app);
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.sizeOf(context).width / MainOnboarding02Screen.designWidth;

    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
            ),
            Positioned(
              left: 17 * scale,
              top: 85 * scale,
              child: OnboardingAppSwitchModal(
                scale: scale,
                selectedApp: _selectedApp,
                onAppSelected: _onAppSelected,
              ),
            ),
            Positioned(
              left: 20 * scale,
              top: 42 * scale,
              child: HomeTitleButton(
                scale: scale,
                isExpanded: true,
                onPressed: _close,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingAppSwitchModal extends StatelessWidget {
  const OnboardingAppSwitchModal({
    super.key,
    required this.scale,
    required this.selectedApp,
    required this.onAppSelected,
  });

  final double scale;
  final OnboardingApp selectedApp;
  final ValueChanged<OnboardingApp> onAppSelected;

  static const Color _thinqBackground = Color(0xFFEFF0F5);
  static const Color _togedogBackground = Color(0xFFE2E4FB);
  static const Color _thinqAccent = Color(0xFFFD2B30);
  static const Color _togedogAccent = Color(0xFF8756E7);
  static const Color _headerSubtitleColor = Color(0xFF828282);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 368 * scale,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        29 * scale,
        20 * scale,
        30 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Text(
                '앱 전환',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize: 16 * scale,
                  height: 1,
                  color: const Color(0xFF111111),
                ),
              ),
              SizedBox(height: 9 * scale),
              Text(
                '원하는 서비스로 간편하게 이동해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 11 * scale,
                  height: 1,
                  color: _headerSubtitleColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Row(
            children: [
              Expanded(
                child: _AppOptionCard(
                  scale: scale,
                  title: 'LG ThinQ',
                  imageAsset: 'asset/온보딩 띵큐2_앱전환 띵큐.png',
                  backgroundColor: _thinqBackground,
                  accentColor: _thinqAccent,
                  imageTopPadding: 26 * scale,
                  imageHorizontalPadding: 2 * scale,
                  isSelected: selectedApp == OnboardingApp.thinq,
                  onTap: () => onAppSelected(OnboardingApp.thinq),
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: _AppOptionCard(
                  scale: scale,
                  title: 'LG TogeDog',
                  imageAsset: 'asset/온보딩 띵큐2_앱전환 투게독.png',
                  backgroundColor: _togedogBackground,
                  accentColor: _togedogAccent,
                  subtitle: '반려견 케어 전문 서비스',
                  imageTopPadding: 9 * scale,
                  imageHorizontalPadding: 4 * scale,
                  imageViewportWidth: 139,
                  imageViewportHeight: 148,
                  imageOverflowHeightScale: 1.21,
                  imageOverflowTopOffsetFactor: -0.0543,
                  isSelected: selectedApp == OnboardingApp.togedog,
                  onTap: () => onAppSelected(OnboardingApp.togedog),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppOptionCard extends StatefulWidget {
  const _AppOptionCard({
    required this.scale,
    required this.title,
    required this.imageAsset,
    required this.backgroundColor,
    required this.accentColor,
    required this.imageTopPadding,
    required this.imageHorizontalPadding,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.imageViewportWidth,
    this.imageViewportHeight,
    this.imageOverflowHeightScale = 1,
    this.imageOverflowTopOffsetFactor = 0,
  });

  static const double _badgeWidth = 66;
  static const double _badgeHeight = 20;
  static const double _secondaryRowHeight = 20;
  static const double _titleToSecondaryGap = 6;
  static const double _footerBottomPadding = 19;
  static const double _titleHeight = 16;
  static const double _subtitleLift = 3;

  final double scale;
  final String title;
  final String imageAsset;
  final Color backgroundColor;
  final Color accentColor;
  final double imageTopPadding;
  final double imageHorizontalPadding;
  final double? imageViewportWidth;
  final double? imageViewportHeight;
  final double imageOverflowHeightScale;
  final double imageOverflowTopOffsetFactor;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_AppOptionCard> createState() => _AppOptionCardState();
}

class _AppOptionCardState extends State<_AppOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 211 * scale,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(10 * scale),
            border: widget.isSelected
                ? Border.all(
                    color: widget.accentColor,
                    width: 2 * scale,
                  )
                : null,
          ),
          foregroundDecoration: _isHovered && !widget.isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10 * scale),
                  color: Colors.black.withValues(alpha: 0.04),
                )
              : null,
          child: Stack(
            children: [
              Positioned(
                left: widget.imageHorizontalPadding,
                right: widget.imageHorizontalPadding,
                top: widget.imageTopPadding,
                bottom: (_AppOptionCard._footerBottomPadding +
                        _AppOptionCard._secondaryRowHeight +
                        _AppOptionCard._titleToSecondaryGap +
                        _AppOptionCard._titleHeight) *
                    scale,
                child: widget.imageViewportWidth != null &&
                        widget.imageViewportHeight != null
                    ? Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: widget.imageViewportWidth! * scale,
                          height: widget.imageViewportHeight! * scale,
                          child: ClipRect(
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                widget.imageOverflowTopOffsetFactor *
                                    widget.imageViewportHeight! *
                                    scale,
                              ),
                              child: SizedBox(
                                width: widget.imageViewportWidth! * scale,
                                height: widget.imageViewportHeight! *
                                    widget.imageOverflowHeightScale *
                                    scale,
                                child: Image.asset(
                                  widget.imageAsset,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : ClipRect(
                        child: Image.asset(
                          widget.imageAsset,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.topCenter,
                        ),
                      ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: _AppOptionCard._footerBottomPadding * scale,
                height: _AppOptionCard._secondaryRowHeight * scale,
                child: Center(
                  child: widget.isSelected
                      ? _CurrentUseBadge(
                          scale: scale,
                          accentColor: widget.accentColor,
                        )
                      : widget.subtitle != null
                          ? Transform.translate(
                              offset: Offset(
                                0,
                                -_AppOptionCard._subtitleLift * scale,
                              ),
                              child: SizedBox(
                                height: _AppOptionCard._secondaryRowHeight *
                                    scale,
                                child: Center(
                                  child: _SecondaryLineText(
                                    scale: scale,
                                    text: widget.subtitle!,
                                    color: const Color(0xFF6A6A6A),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: (_AppOptionCard._footerBottomPadding +
                        _AppOptionCard._secondaryRowHeight +
                        _AppOptionCard._titleToSecondaryGap) *
                    scale,
                height: _AppOptionCard._titleHeight * scale,
                child: Center(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w700,
                      fontSize: 16 * scale,
                      height: 1,
                      color: const Color(0xFF111111),
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

class _CurrentUseBadge extends StatelessWidget {
  const _CurrentUseBadge({
    required this.scale,
    required this.accentColor,
  });

  final double scale;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _AppOptionCard._badgeWidth * scale,
      height: _AppOptionCard._badgeHeight * scale,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(
            _AppOptionCard._badgeHeight * scale / 2,
          ),
        ),
        child: Center(
          child: _SecondaryLineText(
            scale: scale,
            text: '현재 사용 중',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SecondaryLineText extends StatelessWidget {
  const _SecondaryLineText({
    required this.scale,
    required this.text,
    required this.color,
  });

  final double scale;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'LGSmartUI',
        fontWeight: FontWeight.w600,
        fontSize: 10 * scale,
        height: 1,
        color: color,
      ),
    );
  }
}

/// Figma Frame 785 — 김엘지 홈 + chevron (87×23)
class HomeTitleButton extends StatefulWidget {
  const HomeTitleButton({
    super.key,
    required this.scale,
    required this.onPressed,
    this.isExpanded = false,
  });

  final double scale;
  final VoidCallback onPressed;
  final bool isExpanded;

  @override
  State<HomeTitleButton> createState() => _HomeTitleButtonState();
}

class _HomeTitleButtonState extends State<HomeTitleButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  static const Color _collapsedTitleColor = Color(0xFF111111);
  static const Color _collapsedChevronColor = Color(0xFF1A1A1A);
  static const Color _expandedColor = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final isExpanded = widget.isExpanded;
    final titleColor = isExpanded ? _expandedColor : _collapsedTitleColor;
    final chevronColor = isExpanded ? _expandedColor : _collapsedChevronColor;

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
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _isPressed
                ? (isExpanded ? Colors.white : const Color(0xFF111111))
                    .withValues(alpha: isExpanded ? 0.16 : 0.12)
                : _isHovered
                    ? (isExpanded ? Colors.white : const Color(0xFF111111))
                        .withValues(alpha: isExpanded ? 0.1 : 0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(4 * scale),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '김엘지 홈',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize: 20 * scale,
                  height: 23 / 20,
                  color: titleColor,
                ),
              ),
              SizedBox(width: 9 * scale),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: isExpanded
                    ? SizedBox(
                        key: const ValueKey('expanded_chevron'),
                        width: 13 * scale,
                        height: 6 * scale,
                        child: CustomPaint(
                          painter: _ChevronDownPainter(color: chevronColor),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('collapsed_chevron'),
                        width: 6 * scale,
                        height: 13 * scale,
                        child: CustomPaint(
                          painter: _ChevronRightPainter(color: chevronColor),
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

class _ChevronRightPainter extends CustomPainter {
  const _ChevronRightPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.08)
      ..lineTo(size.width * 0.92, size.height * 0.5)
      ..lineTo(size.width * 0.08, size.height * 0.92);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronRightPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ChevronDownPainter extends CustomPainter {
  const _ChevronDownPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.08)
      ..lineTo(size.width * 0.5, size.height * 0.92)
      ..lineTo(size.width * 0.92, size.height * 0.08);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronDownPainter oldDelegate) =>
      oldDelegate.color != color;
}

Future<OnboardingApp?> openOnboarding02(
  BuildContext context, {
  required OnboardingApp selectedApp,
}) {
  return showGeneralDialog<OnboardingApp>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '닫기',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      return MainOnboarding02Screen(initialApp: selectedApp);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
