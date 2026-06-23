// TogeDog 안내 방식 선택 화면
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'guidance_mode_store.dart';
import 'main_onboarding_06.dart';
import 'togedog_accessibility.dart';

/// Figma: 안내방식 선택 화면 (node 488:351)
enum GuidanceMode { sound, vibration, text }

class MainOnboarding05Screen extends StatefulWidget {
  const MainOnboarding05Screen({
    super.key,
    this.initialSelectedMode,
    this.interactive = true,
    this.fromMypage = false,
  });

  final GuidanceMode? initialSelectedMode;
  final bool interactive;
  /// 마이페이지 → 장애유형 선택 경로일 때 확인 후 마이페이지로 복귀
  final bool fromMypage;

  static const double designWidth = 402;
  static const double horizontalInset = 19;
  static const double contentLeft = 21;
  static const double headerTop = 88;
  static const double headerGap = 16;
  static const double headerToOptionsGap = 48;
  static const double optionOverlap = 8;
  static const double optionWrapperPadding = 10;
  static const double optionHeight = 110;
  static const double optionRadius = 20;
  static const double optionHorizontalPadding = 20;
  static const double optionVerticalPadding = 24;
  static const double iconSize = 50;
  static const double iconTextGap = 15;
  static const double titleSubtitleGap = 6;
  static const double buttonHeight = 47;
  static const double buttonRadius = 9;
  static const double bottomInset = 63;

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color selectedBackground = Color(0xFFF0EAFF);
  static const Color unselectedBorder = Color(0xFFF4F4F8);
  static const Color titleBlack = Color(0xFF111111);
  static const Color subtitleGray = Color(0xFF666666);
  static const Color descriptionGray = Color(0xFF6B7280);

  @override
  State<MainOnboarding05Screen> createState() => _MainOnboarding05ScreenState();
}

class _MainOnboarding05ScreenState extends State<MainOnboarding05Screen> {
  late GuidanceMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialSelectedMode ??
        GuidanceModeStore.instance.selectedMode;
  }

  void _goToNextScreen() {
    GuidanceModeStore.instance.setMode(_selectedMode);
    if (widget.fromMypage) {
      Navigator.of(context).pop();
      return;
    }
    openOnboarding06(context, guidanceMode: _selectedMode);
  }

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.sizeOf(context).width / MainOnboarding05Screen.designWidth;
    final horizontalInset = MainOnboarding05Screen.horizontalInset * scale;
    final bottomInset = MainOnboarding05Screen.bottomInset * scale;
    final buttonHeight = MainOnboarding05Screen.buttonHeight * scale;
    final topInset = (MainOnboarding05Screen.headerTop * scale -
            MediaQuery.paddingOf(context).top)
        .clamp(8.0, double.infinity);

    return TogedogA11y.screen(
      name: '안내 방식 선택',
      child: IgnorePointer(
        ignoring: !widget.interactive,
        child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalInset),
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: topInset),
                        _HeaderSection(scale: scale),
                        SizedBox(
                          height:
                              MainOnboarding05Screen.headerToOptionsGap * scale,
                        ),
                        _GuidanceOptionList(
                          scale: scale,
                          selectedMode: _selectedMode,
                          onModeSelected: (mode) {
                            if (!widget.interactive) return;
                            setState(() => _selectedMode = mode);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _NextButton(
                  scale: scale,
                  height: buttonHeight,
                  label: widget.fromMypage ? '확인' : '다음',
                  onPressed: widget.interactive ? _goToNextScreen : null,
                ),
                SizedBox(height: bottomInset),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안내 방식 선택',
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w700,
            fontSize: 25 * scale,
            height: 1.2,
            color: MainOnboarding05Screen.titleBlack,
          ),
        ),
        SizedBox(height: MainOnboarding05Screen.headerGap * scale),
        Text(
          '나에게 맞는 안내 방식을\n선택해주세요',
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w400,
            fontSize: 16 * scale,
            height: 1.4,
            color: MainOnboarding05Screen.subtitleGray,
          ),
        ),
      ],
    );
  }
}

class _GuidanceOptionList extends StatelessWidget {
  const _GuidanceOptionList({
    required this.scale,
    required this.selectedMode,
    required this.onModeSelected,
  });

  final double scale;
  final GuidanceMode selectedMode;
  final ValueChanged<GuidanceMode> onModeSelected;

  static const _options = [
    _GuidanceOptionData(
      mode: GuidanceMode.sound,
      title: '소리 중심 안내',
      description: '음성으로 정보를 확인해요',
      iconType: _GuidanceIconType.sound,
    ),
    _GuidanceOptionData(
      mode: GuidanceMode.vibration,
      title: '진동 중심 안내',
      description: '화면과 진동으로 확인해요',
      iconType: _GuidanceIconType.vibration,
    ),
    _GuidanceOptionData(
      mode: GuidanceMode.text,
      title: '텍스트 안내',
      description: '텍스트로 확인해요',
      iconType: _GuidanceIconType.text,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _options.length; i++)
          Transform.translate(
            offset:
                Offset(0, -MainOnboarding05Screen.optionOverlap * scale * i),
            child: Padding(
              padding: EdgeInsets.all(
                MainOnboarding05Screen.optionWrapperPadding * scale,
              ),
              child: _GuidanceOptionCard(
                scale: scale,
                data: _options[i],
                isSelected: selectedMode == _options[i].mode,
                onTap: () => onModeSelected(_options[i].mode),
              ),
            ),
          ),
      ],
    );
  }
}

enum _GuidanceIconType { sound, vibration, text }

class _GuidanceOptionData {
  const _GuidanceOptionData({
    required this.mode,
    required this.title,
    required this.description,
    required this.iconType,
  });

  final GuidanceMode mode;
  final String title;
  final String description;
  final _GuidanceIconType iconType;
}

class _GuidanceOptionCard extends StatefulWidget {
  const _GuidanceOptionCard({
    required this.scale,
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final double scale;
  final _GuidanceOptionData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_GuidanceOptionCard> createState() => _GuidanceOptionCardState();
}

class _GuidanceOptionCardState extends State<_GuidanceOptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final isSelected = widget.isSelected;

    return TogedogA11y.selectable(
      label: widget.data.title,
      description: widget.data.description,
      selected: isSelected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: BoxConstraints(
            minHeight: MainOnboarding05Screen.optionHeight * scale,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MainOnboarding05Screen.optionHorizontalPadding * scale,
            vertical: MainOnboarding05Screen.optionVerticalPadding * scale,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? MainOnboarding05Screen.selectedBackground
                : Colors.white,
            borderRadius: BorderRadius.circular(
              MainOnboarding05Screen.optionRadius * scale,
            ),
            border: Border.all(
              color: isSelected
                  ? MainOnboarding05Screen.brandPurple
                  : _isHovered
                      ? const Color(0xFFE0E0E0)
                      : MainOnboarding05Screen.unselectedBorder,
              width: 2 * scale,
            ),
          ),
          child: Row(
            children: [
              _GuidanceIcon(
                scale: scale,
                type: widget.data.iconType,
                isSelected: isSelected,
              ),
              SizedBox(width: MainOnboarding05Screen.iconTextGap * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data.title,
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * scale,
                        height: 1.2,
                        color: MainOnboarding05Screen.titleBlack,
                      ),
                    ),
                    SizedBox(
                      height: MainOnboarding05Screen.titleSubtitleGap * scale,
                    ),
                    Text(
                      widget.data.description,
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * scale,
                        height: 1.2,
                        color: MainOnboarding05Screen.descriptionGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _GuidanceIcon extends StatelessWidget {
  const _GuidanceIcon({
    required this.scale,
    required this.type,
    required this.isSelected,
  });

  final double scale;
  final _GuidanceIconType type;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final size = MainOnboarding05Screen.iconSize * scale;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white
            : MainOnboarding05Screen.selectedBackground,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: switch (type) {
        _GuidanceIconType.sound => SvgPicture.asset(
            'assets/onboarding/onboarding_guidance_sound_icon.svg',
            width: size * 0.88,
            height: size * 0.88,
            fit: BoxFit.contain,
            clipBehavior: Clip.none,
          ),
        _GuidanceIconType.vibration => SvgPicture.asset(
            'assets/onboarding/onboarding_guidance_vibration_icon.svg',
            width: size * 0.88,
            height: size * 0.88,
            fit: BoxFit.contain,
            clipBehavior: Clip.none,
          ),
        _GuidanceIconType.text => Text(
            'Aa',
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w700,
              fontSize: 24 * scale,
              height: 1,
              color: MainOnboarding05Screen.brandPurple,
            ),
          ),
      },
    );
  }
}

class _NextButton extends StatefulWidget {
  const _NextButton({
    required this.scale,
    required this.height,
    required this.label,
    required this.onPressed,
  });

  final double scale;
  final double height;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<_NextButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final enabled = widget.onPressed != null;

    return TogedogA11y.button(
      label: widget.label,
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
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          height: widget.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _buttonColor,
            borderRadius: BorderRadius.circular(
              MainOnboarding05Screen.buttonRadius * scale,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w700,
              fontSize: 16 * scale,
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
    );
  }

  Color get _buttonColor {
    if (widget.onPressed == null) {
      return MainOnboarding05Screen.brandPurple.withValues(alpha: 0.5);
    }

    const base = MainOnboarding05Screen.brandPurple;
    if (_isPressed) {
      return Color.lerp(base, Colors.black, 0.16)!;
    }
    if (_isHovered) {
      return Color.lerp(base, Colors.white, 0.08)!;
    }
    return base;
  }
}
