// TogeDog 반려견 프로필 등록 화면
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'main_onboarding_12.dart';
import 'onboarding_transitions.dart';
import 'pet_profile_store.dart';
import 'togedog_accessibility.dart';

/// Figma: 반려견 프로필 등록 (node 557:11970) / 견종 펼침 (node 488:357)
class MainOnboarding11Screen extends StatefulWidget {
  const MainOnboarding11Screen({super.key});

  static const double designWidth = 402;
  static const double horizontalInset = 19;
  static const double heroHeight = 473;
  static const double titleTop = 80;
  static const double backTop = 36;
  static const double backSize = 24;
  static const double designScreenHeight = 875;
  static const double pawsTopRatio = 0.2523;
  static const double pawsBottomRatio = 0.5488;
  static const double dogWidth = 215;
  static const double dogHeight = 276;
  static const double dogTop = 197;
  static const double cameraSize = 43;
  static const double cameraTop = 383;
  static const double cameraRight = 23;
  static const double formRadius = 23;
  static const double formPaddingTop = 20;
  static const double formPaddingBottom = 28;
  static const double formPaddingLeft = 21;
  static const double formPaddingRight = 23;
  static const double fieldGap = 20;
  static const double labelInputGap = 6;
  static const double inputHeight = 44;
  static const double inputRadius = 8;
  static const double inputPaddingH = 14;
  static const double inputPaddingV = 10;
  static const double breedListMaxHeight = 320;
  static const double buttonHeight = 47;
  static const double buttonRadius = 9;
  static const double buttonGap = 12;
  static const double bottomPadding = 28;

  static const String dogImageAsset = 'asset/onboarding/onboarding_profile_dog.png';
  static const String backButtonAsset = 'asset/onboarding/onboarding_profile_back.svg';
  static const String pawsDecorationAsset = 'asset/onboarding/onboarding_profile_paws.svg';
  static const String cameraBgAsset = 'asset/onboarding/onboarding_profile_camera_bg.svg';
  static const String cameraIconAsset = 'asset/onboarding/onboarding_profile_camera_icon.svg';
  static const String chevronIconAsset = 'asset/onboarding/onboarding_profile_chevron.svg';

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color gradientStart = Color(0xFFFBFBFF);
  static const Color gradientEnd = Color(0xFFF0EAFF);
  static const Color titleBlack = Color(0xFF111111);
  static const Color subtitleGray = Color(0xFF828282);
  static const Color labelGray = Color(0xFF404040);
  static const Color requiredMarkRed = Color(0xFFE53935);
  static const Color placeholderGray = Color(0xFF737373);
  static const Color inputTextBlack = Color(0xFF171717);
  static const Color inputBorder = Color(0xFFD4D4D4);
  static const Color secondaryButtonBorder = Color(0xFFA7ADBB);
  static const Color breedListBorder = Color(0xFFE5E5E5);
  static const Color breedSelectedBackground = Color(0xFFFAFAFA);
  static const Color disabledButtonBackground = Color(0xFFEDEDED);
  static const Color disabledButtonText = Color(0xFF828282);

  static final List<String> dogBreeds = [
    '골든 리트리버',
    '닥스훈트',
    '달마시안',
    '도베르만',
    '말티즈',
    '미니어처 푸들',
    '보더 콜리',
    '비글',
    '비숑 프리제',
    '사모예드',
    '시바견',
    '시추',
    '웰시 코기',
    '진돗개',
    '차우차우',
    '치와와',
    '코카 스파니엘',
    '포메라니안',
    '푸들',
    '프렌치 불독',
    '하바니즈',
    '허스키',
  ]..sort();

  @override
  State<MainOnboarding11Screen> createState() => _MainOnboarding11ScreenState();
}

class _MainOnboarding11ScreenState extends State<MainOnboarding11Screen> {
  final _guardianNameController = TextEditingController();
  final _petNameController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isBreedExpanded = false;
  String? _selectedBreed;

  bool get _canSubmit =>
      _guardianNameController.text.trim().isNotEmpty &&
      _petNameController.text.trim().isNotEmpty &&
      _selectedBreed != null &&
      _ageController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _guardianNameController.addListener(_onFieldsChanged);
    _petNameController.addListener(_onFieldsChanged);
    _ageController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _guardianNameController.removeListener(_onFieldsChanged);
    _petNameController.removeListener(_onFieldsChanged);
    _ageController.removeListener(_onFieldsChanged);
    _guardianNameController.dispose();
    _petNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _toggleBreedList() {
    setState(() => _isBreedExpanded = !_isBreedExpanded);
  }

  void _selectBreed(String breed) {
    setState(() {
      _selectedBreed = breed;
      _isBreedExpanded = false;
    });
  }

  void _registerAndGoToNextScreen() {
    if (!_canSubmit) return;
    PetProfileStore.instance.update(
      guardianName: _guardianNameController.text,
      petName: _petNameController.text,
      breed: _selectedBreed!,
      age: _ageController.text,
    );
    Navigator.of(context).push(
      OnboardingFadeRoute<void>(
        builder: (_) => const MainOnboarding12Screen(),
      ),
    );
  }

  void _skipToNextScreen() {
    PetProfileStore.instance.applySkipDefaults();
    Navigator.of(context).push(
      OnboardingFadeRoute<void>(
        builder: (_) => const MainOnboarding12Screen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / MainOnboarding11Screen.designWidth;
    final topPadding = MediaQuery.paddingOf(context).top;

    return TogedogA11y.screen(
      name: '반려견 프로필 등록',
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeroSection(scale: scale, topPadding: topPadding),
              Transform.translate(
                offset: Offset(0, -31 * scale),
                child: _ProfileFormSection(
                  scale: scale,
                  guardianNameController: _guardianNameController,
                  petNameController: _petNameController,
                  ageController: _ageController,
                  isBreedExpanded: _isBreedExpanded,
                  selectedBreed: _selectedBreed,
                  onBreedToggle: _toggleBreedList,
                  onBreedSelected: _selectBreed,
                  canRegister: _canSubmit,
                  onRegister: _registerAndGoToNextScreen,
                  onLater: _skipToNextScreen,
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

class _ProfileHeroSection extends StatelessWidget {
  const _ProfileHeroSection({
    required this.scale,
    required this.topPadding,
  });

  final double scale;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final heroHeight = MainOnboarding11Screen.heroHeight * scale + topPadding;
    final dogWidth = MainOnboarding11Screen.dogWidth * scale;
    final dogHeight = MainOnboarding11Screen.dogHeight * scale;
    final dogTop = MainOnboarding11Screen.dogTop * scale + topPadding;
    final cameraSize = MainOnboarding11Screen.cameraSize * scale;
    final cameraTop = MainOnboarding11Screen.cameraTop * scale + topPadding;
    final cameraRight = MainOnboarding11Screen.cameraRight * scale;
    final titleTop = MainOnboarding11Screen.titleTop * scale + topPadding;
    final backTop = MainOnboarding11Screen.backTop * scale + topPadding;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MainOnboarding11Screen.gradientStart,
                    MainOnboarding11Screen.gradientEnd,
                  ],
                  stops: [0.19, 0.86],
                ),
              ),
            ),
          ),
          Positioned(
            left: MainOnboarding11Screen.horizontalInset * scale,
            top: backTop,
            child: TogedogA11y.button(
              label: '뒤로',
              hint: '이전 화면으로',
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.all(4 * scale),
                  child: SvgPicture.asset(
                    MainOnboarding11Screen.backButtonAsset,
                    width: MainOnboarding11Screen.backSize * scale,
                    height: MainOnboarding11Screen.backSize * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: titleTop,
            child: Column(
              children: [
                Text(
                  '함께할 반려견을\n등록해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w700,
                    fontSize: 20 * scale,
                    height: 1.2,
                    color: MainOnboarding11Screen.titleBlack,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Text(
                  '반려견의 정보를 입력하면\n맞춤 케어 서비스를 제공해드려요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 14 * scale,
                    height: 1.3,
                    color: MainOnboarding11Screen.subtitleGray,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: MediaQuery.sizeOf(context).width * 0.1439,
            right: MediaQuery.sizeOf(context).width * 0.1455,
            top: MainOnboarding11Screen.designScreenHeight *
                MainOnboarding11Screen.pawsTopRatio *
                scale,
            height: MainOnboarding11Screen.designScreenHeight *
                (1 -
                    MainOnboarding11Screen.pawsTopRatio -
                    MainOnboarding11Screen.pawsBottomRatio) *
                scale,
            child: TogedogA11y.decorative(
              SvgPicture.asset(
                MainOnboarding11Screen.pawsDecorationAsset,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: dogTop,
            child: Center(
              child: TogedogA11y.decorative(
                SizedBox(
                  width: dogWidth,
                  height: dogHeight,
                  child: Image.asset(
                    MainOnboarding11Screen.dogImageAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: cameraRight,
            top: cameraTop,
            child: SizedBox(
              width: cameraSize,
              height: cameraSize,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: SvgPicture.asset(
                      MainOnboarding11Screen.cameraBgAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SvgPicture.asset(
                    MainOnboarding11Screen.cameraIconAsset,
                    width: 23 * scale,
                    height: 22 * scale,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFormSection extends StatelessWidget {
  const _ProfileFormSection({
    required this.scale,
    required this.guardianNameController,
    required this.petNameController,
    required this.ageController,
    required this.isBreedExpanded,
    required this.selectedBreed,
    required this.onBreedToggle,
    required this.onBreedSelected,
    required this.canRegister,
    required this.onRegister,
    required this.onLater,
  });

  final double scale;
  final TextEditingController guardianNameController;
  final TextEditingController petNameController;
  final TextEditingController ageController;
  final bool isBreedExpanded;
  final String? selectedBreed;
  final VoidCallback onBreedToggle;
  final ValueChanged<String> onBreedSelected;
  final bool canRegister;
  final VoidCallback onRegister;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MainOnboarding11Screen.formRadius * scale),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        MainOnboarding11Screen.formPaddingLeft * scale,
        MainOnboarding11Screen.formPaddingTop * scale,
        MainOnboarding11Screen.formPaddingRight * scale,
        MainOnboarding11Screen.formPaddingBottom * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileTextField(
            scale: scale,
            label: '보호자 이름',
            controller: guardianNameController,
            hintText: '이름을 입력해주세요',
          ),
          SizedBox(height: MainOnboarding11Screen.fieldGap * scale),
          _ProfileTextField(
            scale: scale,
            label: '반려견 이름',
            controller: petNameController,
            hintText: '이름을 입력해주세요',
          ),
          SizedBox(height: MainOnboarding11Screen.fieldGap * scale),
          _BreedSelector(
            scale: scale,
            isExpanded: isBreedExpanded,
            selectedBreed: selectedBreed,
            onToggle: onBreedToggle,
            onBreedSelected: onBreedSelected,
          ),
          SizedBox(height: MainOnboarding11Screen.fieldGap * scale),
          _AgeField(scale: scale, controller: ageController),
          SizedBox(height: 32 * scale),
          _PrimaryActionButton(
            scale: scale,
            label: '등록하기',
            enabled: canRegister,
            onPressed: onRegister,
          ),
          SizedBox(height: MainOnboarding11Screen.buttonGap * scale),
          _SecondaryActionButton(
            scale: scale,
            label: '나중에',
            onPressed: onLater,
          ),
          SizedBox(height: MainOnboarding11Screen.bottomPadding * scale),
        ],
      ),
    );
  }
}

class _RequiredFieldLabel extends StatelessWidget {
  const _RequiredFieldLabel({
    required this.scale,
    required this.label,
  });

  final double scale;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '*',
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
              height: 20 / 14,
              color: MainOnboarding11Screen.requiredMarkRed,
            ),
          ),
          TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
              height: 20 / 14,
              color: MainOnboarding11Screen.labelGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.scale,
    required this.label,
    required this.controller,
    required this.hintText,
  });

  final double scale;
  final String label;
  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequiredFieldLabel(scale: scale, label: label),
        SizedBox(height: MainOnboarding11Screen.labelInputGap * scale),
        _ProfileInputBox(
          scale: scale,
          child: TogedogA11y.textField(
            label: label,
            value: controller.text,
            hint: hintText,
            child: TextField(
              controller: controller,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w400,
              fontSize: 14 * scale,
              height: 24 / 14,
              color: MainOnboarding11Screen.inputTextBlack,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w400,
                fontSize: 14 * scale,
                height: 24 / 14,
                color: MainOnboarding11Screen.placeholderGray,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        ),
      ],
    );
  }
}

class _AgeField extends StatelessWidget {
  const _AgeField({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequiredFieldLabel(scale: scale, label: '나이'),
        SizedBox(height: MainOnboarding11Screen.labelInputGap * scale),
        Row(
          children: [
            SizedBox(
              width: 168 * scale,
              child: _ProfileInputBox(
                scale: scale,
                child: TogedogA11y.textField(
                label: '나이',
                value: controller.text,
                hint: '나이',
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w400,
                    fontSize: 14 * scale,
                    height: 24 / 14,
                    color: MainOnboarding11Screen.inputTextBlack,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: '나이',
                    hintStyle: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w400,
                      fontSize: 14 * scale,
                      height: 24 / 14,
                      color: MainOnboarding11Screen.placeholderGray,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            ),
            SizedBox(width: 16 * scale),
            Text(
              '세',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 14 * scale,
                height: 20 / 14,
                color: MainOnboarding11Screen.labelGray,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BreedSelector extends StatelessWidget {
  const _BreedSelector({
    required this.scale,
    required this.isExpanded,
    required this.selectedBreed,
    required this.onToggle,
    required this.onBreedSelected,
  });

  final double scale;
  final bool isExpanded;
  final String? selectedBreed;
  final VoidCallback onToggle;
  final ValueChanged<String> onBreedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequiredFieldLabel(scale: scale, label: '견종'),
        SizedBox(height: MainOnboarding11Screen.labelInputGap * scale),
        TogedogA11y.button(
          label: '견종 선택',
          hint: selectedBreed ?? '견종을 입력해주세요',
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
            children: [
              Expanded(
                child: _ProfileInputBox(
                  scale: scale,
                  child: Text(
                    selectedBreed ?? '견종을 입력해주세요',
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w400,
                      fontSize: 14 * scale,
                      height: 24 / 14,
                      color: selectedBreed == null
                          ? MainOnboarding11Screen.placeholderGray
                          : MainOnboarding11Screen.inputTextBlack,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              _ChevronButton(scale: scale, isExpanded: isExpanded),
            ],
          ),
        ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: isExpanded
              ? Padding(
                  padding: EdgeInsets.only(top: 10 * scale),
                  child: _BreedDropdownList(
                    scale: scale,
                    selectedBreed: selectedBreed,
                    onBreedSelected: onBreedSelected,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BreedDropdownList extends StatelessWidget {
  const _BreedDropdownList({
    required this.scale,
    required this.selectedBreed,
    required this.onBreedSelected,
  });

  final double scale;
  final String? selectedBreed;
  final ValueChanged<String> onBreedSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MainOnboarding11Screen.breedListMaxHeight * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: MainOnboarding11Screen.breedListBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: Offset(0, 4 * scale),
            blurRadius: 6 * scale,
            spreadRadius: -2 * scale,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: Offset(0, 12 * scale),
            blurRadius: 16 * scale,
            spreadRadius: -4 * scale,
          ),
        ],
      ),
      child: Scrollbar(
        thumbVisibility: true,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 4 * scale),
          itemCount: MainOnboarding11Screen.dogBreeds.length,
          separatorBuilder: (_, __) => const SizedBox.shrink(),
          itemBuilder: (context, index) {
            final breed = MainOnboarding11Screen.dogBreeds[index];
            final isSelected = breed == selectedBreed;

            return TogedogA11y.selectable(
              label: breed,
              selected: isSelected,
              child: Material(
                color: isSelected
                    ? MainOnboarding11Screen.breedSelectedBackground
                    : Colors.white,
                child: InkWell(
                  onTap: () => onBreedSelected(breed),
                  child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 10 * scale,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          breed,
                          style: TextStyle(
                            fontFamily: 'LGSmartUI',
                            fontWeight: FontWeight.w400,
                            fontSize: 16 * scale,
                            height: 24 / 16,
                            color: MainOnboarding11Screen.inputTextBlack,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 20 * scale,
                          color: MainOnboarding11Screen.brandPurple,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileInputBox extends StatelessWidget {
  const _ProfileInputBox({
    required this.scale,
    required this.child,
  });

  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MainOnboarding11Screen.inputHeight * scale,
      padding: EdgeInsets.symmetric(
        horizontal: MainOnboarding11Screen.inputPaddingH * scale,
        vertical: MainOnboarding11Screen.inputPaddingV * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          MainOnboarding11Screen.inputRadius * scale,
        ),
        border: Border.all(color: MainOnboarding11Screen.inputBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: Offset(0, 1 * scale),
            blurRadius: 2 * scale,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({
    required this.scale,
    required this.isExpanded,
  });

  final double scale;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40 * scale,
      height: 40 * scale,
      child: Center(
        child: AnimatedRotation(
          turns: isExpanded ? 0.75 : 0.25,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic,
          child: SvgPicture.asset(
            MainOnboarding11Screen.chevronIconAsset,
            width: 7 * scale,
            height: 12 * scale,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatefulWidget {
  const _PrimaryActionButton({
    required this.scale,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final double scale;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final enabled = widget.enabled;

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
          onTap: enabled ? widget.onPressed : null,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: MainOnboarding11Screen.buttonHeight * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _buttonColor,
              borderRadius: BorderRadius.circular(
                MainOnboarding11Screen.buttonRadius * scale,
              ),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w700,
                fontSize: 16 * scale,
                height: 1,
                color: enabled
                    ? Colors.white
                    : MainOnboarding11Screen.disabledButtonText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color get _buttonColor {
    if (!widget.enabled) {
      return MainOnboarding11Screen.disabledButtonBackground;
    }

    const base = MainOnboarding11Screen.brandPurple;
    if (_isPressed) {
      return Color.lerp(base, Colors.black, 0.16)!;
    }
    if (_isHovered) {
      return Color.lerp(base, Colors.white, 0.08)!;
    }
    return base;
  }
}

class _SecondaryActionButton extends StatefulWidget {
  const _SecondaryActionButton({
    required this.scale,
    required this.label,
    required this.onPressed,
  });

  final double scale;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_SecondaryActionButton> createState() => _SecondaryActionButtonState();
}

class _SecondaryActionButtonState extends State<_SecondaryActionButton> {
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
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: MainOnboarding11Screen.buttonHeight * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFF5F5F5)
                : _isHovered
                    ? const Color(0xFFFAFAFA)
                    : Colors.white,
            borderRadius: BorderRadius.circular(
              MainOnboarding11Screen.buttonRadius * scale,
            ),
            border: Border.all(
              color: MainOnboarding11Screen.secondaryButtonBorder,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w700,
              fontSize: 16 * scale,
              height: 1,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
