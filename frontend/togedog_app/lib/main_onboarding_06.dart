// TogeDog 약관 동의 바텀시트 (05 위 모달)
import 'package:flutter/material.dart';

import 'main_onboarding_05.dart';
import 'main_onboarding_modal_flow.dart';
import 'onboarding_transitions.dart';
import 'togedog_accessibility.dart';

/// Figma: 약관 동의 — 동의 전 (784:1612) / 동의 후 (784:1666)
class MainOnboarding06Screen extends StatefulWidget {
  const MainOnboarding06Screen({
    super.key,
    required this.guidanceMode,
    this.onAgreed,
  });

  final GuidanceMode guidanceMode;
  final VoidCallback? onAgreed;

  static const double designWidth = 402;
  static const double sheetHeight = 330;
  static const double sheetTopRadius = 23;
  static const double sheetPaddingTop = 20;
  static const double sheetPaddingBottom = 28;
  static const double sheetPaddingLeft = 21;
  static const double sheetPaddingRight = 23;
  static const double contentToButtonGap = 29;
  static const double sectionGap = 16;
  static const double checkboxTextGap = 6;
  static const double agreeButtonHeight = 43;
  static const double agreeButtonRadius = 9;

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color grayBorder = Color(0xFF828282);
  static const Color disabledButtonBackground = Color(0xFFEDEDED);
  static const Color disabledButtonText = Color(0xFF828282);

  @override
  State<MainOnboarding06Screen> createState() => _MainOnboarding06ScreenState();
}

class _MainOnboarding06ScreenState extends State<MainOnboarding06Screen> {
  bool _allAgreed = false;
  bool _termsOfService = false;
  bool _privacyPolicy = false;

  bool get _canSubmit => _allAgreed && _termsOfService && _privacyPolicy;

  void _setAllAgreed(bool value) {
    setState(() {
      _allAgreed = value;
      _termsOfService = value;
      _privacyPolicy = value;
    });
  }

  void _setTermsOfService(bool value) {
    setState(() {
      _termsOfService = value;
      _allAgreed = _termsOfService && _privacyPolicy;
    });
  }

  void _setPrivacyPolicy(bool value) {
    setState(() {
      _privacyPolicy = value;
      _allAgreed = _termsOfService && _privacyPolicy;
    });
  }

  void _submit() {
    if (!_canSubmit) return;
    widget.onAgreed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.sizeOf(context).width / MainOnboarding06Screen.designWidth;

    return TogedogA11y.screen(
      name: '약관 동의',
      child: Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: MainOnboarding06Screen.sheetHeight * scale,
          padding: EdgeInsets.fromLTRB(
            MainOnboarding06Screen.sheetPaddingLeft * scale,
            MainOnboarding06Screen.sheetPaddingTop * scale,
            MainOnboarding06Screen.sheetPaddingRight * scale,
            MainOnboarding06Screen.sheetPaddingBottom * scale,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                MainOnboarding06Screen.sheetTopRadius * scale,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '약관 및',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize: 16 * scale,
                  height: 1.2,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: MainOnboarding06Screen.sectionGap * scale,
              ),
              Text(
                '약관 및 정책이 변경되어 재동의가 필요합니다.',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w400,
                  fontSize: 14 * scale,
                  height: 1.4,
                  color: Colors.black,
                  letterSpacing: 0.028 * scale,
                ),
              ),
              SizedBox(
                height: MainOnboarding06Screen.sectionGap * scale,
              ),
              _AgreementRow(
                scale: scale,
                isChecked: _allAgreed,
                onToggle: () => _setAllAgreed(!_allAgreed),
                checkboxShape: _AgreementCheckboxShape.circle,
                label: '모두 동의',
                labelWeight: FontWeight.w600,
                labelSize: 16,
                showChevron: false,
              ),
              SizedBox(
                height: MainOnboarding06Screen.sectionGap * scale,
              ),
              _AgreementRow(
                scale: scale,
                isChecked: _termsOfService,
                onToggle: () => _setTermsOfService(!_termsOfService),
                checkboxShape: _AgreementCheckboxShape.square,
                label: '(필수) LG전자 서비스 이용약관',
                labelWeight: FontWeight.w400,
                labelSize: 14,
                showChevron: true,
              ),
              SizedBox(
                height: MainOnboarding06Screen.sectionGap * scale,
              ),
              _AgreementRow(
                scale: scale,
                isChecked: _privacyPolicy,
                onToggle: () => _setPrivacyPolicy(!_privacyPolicy),
                checkboxShape: _AgreementCheckboxShape.square,
                label: '(필수) LG전자 서비스 개인정보 수집•이용 동의',
                labelWeight: FontWeight.w400,
                labelSize: 14,
                showChevron: true,
              ),
              SizedBox(
                height: MainOnboarding06Screen.contentToButtonGap * scale,
              ),
              _AgreeButton(
                scale: scale,
                enabled: _canSubmit,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

enum _AgreementCheckboxShape { circle, square }

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.scale,
    required this.isChecked,
    required this.onToggle,
    required this.checkboxShape,
    required this.label,
    required this.labelWeight,
    required this.labelSize,
    required this.showChevron,
  });

  final double scale;
  final bool isChecked;
  final VoidCallback onToggle;
  final _AgreementCheckboxShape checkboxShape;
  final String label;
  final FontWeight labelWeight;
  final double labelSize;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return TogedogA11y.checkbox(
      label: label,
      checked: isChecked,
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Row(
        children: [
          _AgreementCheckbox(
            scale: scale,
            isChecked: isChecked,
            shape: checkboxShape,
          ),
          SizedBox(width: MainOnboarding06Screen.checkboxTextGap * scale),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: labelWeight,
                fontSize: labelSize * scale,
                height: 1.3,
                color: Colors.black,
                decoration: TextDecoration.underline,
                decorationColor: Colors.black,
                letterSpacing: labelSize == 16 ? 0.32 * scale : 0.028 * scale,
              ),
            ),
          ),
          if (showChevron) ...[
            SizedBox(width: 8 * scale),
            _ChevronIcon(scale: scale),
          ],
        ],
      ),
    ),
    );
  }
}

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({
    required this.scale,
    required this.isChecked,
    required this.shape,
  });

  final double scale;
  final bool isChecked;
  final _AgreementCheckboxShape shape;

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == _AgreementCheckboxShape.circle;
    final size = (isCircle ? 23.0 : 20.0) * scale;
    final radius = isCircle ? size / 2 : 6 * scale;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            isChecked ? MainOnboarding06Screen.brandPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isChecked
              ? MainOnboarding06Screen.brandPurple
              : MainOnboarding06Screen.grayBorder,
          width: 1 * scale,
        ),
      ),
      child: isChecked
          ? Icon(
              Icons.check,
              size: (isCircle ? 12 : 10) * scale,
              color: Colors.white,
            )
          : null,
    );
  }
}

class _ChevronIcon extends StatelessWidget {
  const _ChevronIcon({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 5 * scale,
      height: 9 * scale,
      child: const CustomPaint(
        painter: _ChevronPainter(
          color: MainOnboarding06Screen.grayBorder,
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.08)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width * 0.1, size.height * 0.92);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _AgreeButton extends StatefulWidget {
  const _AgreeButton({
    required this.scale,
    required this.enabled,
    required this.onPressed,
  });

  final double scale;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_AgreeButton> createState() => _AgreeButtonState();
}

class _AgreeButtonState extends State<_AgreeButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final enabled = widget.enabled;

    return TogedogA11y.button(
      label: '동의',
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (enabled) setState(() => _isHovered = true);
      },
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) {
          if (enabled) setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: enabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: MainOnboarding06Screen.agreeButtonHeight * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(
              MainOnboarding06Screen.agreeButtonRadius * scale,
            ),
          ),
          child: Text(
            '동의',
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w400,
              fontSize: 16 * scale,
              height: 1,
              color: enabled
                  ? Colors.white
                  : MainOnboarding06Screen.disabledButtonText,
            ),
          ),
        ),
      ),
    ),
    );
  }

  Color get _backgroundColor {
    if (!widget.enabled) {
      return MainOnboarding06Screen.disabledButtonBackground;
    }

    const base = MainOnboarding06Screen.brandPurple;
    if (_isPressed) {
      return Color.lerp(base, Colors.black, 0.16)!;
    }
    if (_isHovered) {
      return Color.lerp(base, Colors.white, 0.08)!;
    }
    return base;
  }
}

Future<void> openOnboarding06(
  BuildContext context, {
  required GuidanceMode guidanceMode,
}) {
  return Navigator.of(context).push(
    OnboardingFadeRoute<void>(
      builder: (_) => MainOnboardingModalFlowScreen(
        guidanceMode: guidanceMode,
      ),
    ),
  );
}
