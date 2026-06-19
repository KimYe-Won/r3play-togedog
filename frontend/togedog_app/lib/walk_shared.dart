import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_live_streaming_view.dart';
import 'walk_session.dart';

const double kWalkDesignWidth = 402;

/// Figma 1080:1181 / main_onboarding_04 시작하기 버튼과 동일한 하단 여백
const double kWalkGuideEndButtonBottomInset = 63;

/// Figma 1128:899 — 손전등 버튼만 (중앙 1개)
/// Figma 1080:912 — 음성·손전등·진동 3버튼
///
/// 1128:899 레이아웃으로 바꾸려면 `true`로 변경하세요.
const bool kWalk02UseSingleFlashlightLayout = false;

class WalkRealtimeShell extends StatelessWidget {
  const WalkRealtimeShell({
    super.key,
    required this.scale,
    required this.onBack,
    this.bottomOverlay,
    this.panel,
  });

  final double scale;
  final VoidCallback onBack;
  final Widget? bottomOverlay;
  final Widget? panel;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(child: AppLiveStreamingView()),
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
                      const Color(0xFF1A1A1A),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (panel == null)
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
                WalkRealtimeHeader(scale: scale, onBack: onBack),
                if (bottomOverlay != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom:
                        kWalkGuideEndButtonBottomInset * scale + bottomInset,
                    child: bottomOverlay!,
                  ),
              ],
            ),
          ),
          if (panel != null) panel!,
        ],
      ),
    );
  }
}

class WalkRealtimeHeader extends StatelessWidget {
  const WalkRealtimeHeader({
    super.key,
    required this.scale,
    required this.onBack,
  });

  final double scale;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 26 * scale,
          top: 8 * scale,
          child: GestureDetector(
            onTap: onBack,
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
          top: 47 * scale,
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
          child: ListenableBuilder(
            listenable: WalkSession.instance,
            builder: (context, _) => WalkTimeBadge(
              scale: scale,
              elapsedText: WalkSession.instance.formattedElapsed,
            ),
          ),
        ),
      ],
    );
  }
}

class WalkTimeBadge extends StatelessWidget {
  const WalkTimeBadge({
    super.key,
    required this.scale,
    required this.elapsedText,
  });

  final double scale;
  final String elapsedText;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          children: [
            const TextSpan(text: '산책 시간 '),
            TextSpan(
              text: elapsedText,
              style: const TextStyle(color: Color(0xFFFD2B30)),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkControlButton extends StatelessWidget {
  const WalkControlButton({
    super.key,
    required this.scale,
    required this.buttonAsset,
    required this.label,
    this.onTap,
    this.active = false,
  });

  final double scale;
  final String buttonAsset;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  static const double _kButtonSize = 55;
  static const double _kLabelGap = 8;

  @override
  Widget build(BuildContext context) {
    final buttonSize = _kButtonSize * scale;

    Widget button = SvgPicture.asset(
      buttonAsset,
      width: buttonSize,
      height: buttonSize,
      fit: BoxFit.contain,
    );

    if (active) {
      button = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Color(0xFF8756E7),
          BlendMode.srcIn,
        ),
        child: button,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: buttonSize, height: buttonSize, child: button),
          SizedBox(height: _kLabelGap * scale),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 14 * scale,
              height: 1,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma 1080:912 — 음성·손전등·진동 3버튼 하단 바
class WalkThreeButtonControls extends StatelessWidget {
  const WalkThreeButtonControls({
    super.key,
    required this.scale,
    required this.onVoiceTap,
    required this.onFlashlightTap,
    required this.onVibrationTap,
    this.flashlightOn = false,
  });

  final double scale;
  final VoidCallback onVoiceTap;
  final VoidCallback onFlashlightTap;
  final VoidCallback onVibrationTap;
  final bool flashlightOn;

  static const double _kButtonSize = 55;
  static const double _kLabelGap = 8;
  static const double _kLabelHeight = 14;
  static const double _kVoiceLeft = 76;
  static const double _kVibrationLeft = 272;

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final blockHeight = (_kButtonSize + _kLabelGap + _kLabelHeight) * s;
    final flashLeft = (kWalkDesignWidth - _kButtonSize) / 2;

    return Center(
      child: SizedBox(
        width: kWalkDesignWidth * s,
        height: blockHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _kVoiceLeft * s,
              top: 0,
              child: WalkControlButton(
                scale: s,
                buttonAsset: 'asset/walk/walk_btn_voice.svg',
                label: '음성 안내',
                onTap: onVoiceTap,
              ),
            ),
            Positioned(
              left: flashLeft * s,
              top: 0,
              child: WalkControlButton(
                scale: s,
                buttonAsset: 'asset/walk/walk_btn_flashlight.svg',
                label: '손전등',
                onTap: onFlashlightTap,
                active: flashlightOn,
              ),
            ),
            Positioned(
              left: _kVibrationLeft * s,
              top: 0,
              child: WalkControlButton(
                scale: s,
                buttonAsset: 'asset/walk/walk_btn_vibration.svg',
                label: '진동 안내',
                onTap: onVibrationTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma 1128:899 — 손전등 버튼만 (중앙 1개)
class WalkSingleFlashlightControl extends StatelessWidget {
  const WalkSingleFlashlightControl({
    super.key,
    required this.scale,
    required this.onFlashlightTap,
    this.flashlightOn = false,
  });

  final double scale;
  final VoidCallback onFlashlightTap;
  final bool flashlightOn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WalkControlButton(
        scale: scale,
        buttonAsset: 'asset/walk/walk_btn_flashlight.svg',
        label: '손전등',
        onTap: onFlashlightTap,
        active: flashlightOn,
      ),
    );
  }
}

class WalkGuideBottomPanel extends StatelessWidget {
  const WalkGuideBottomPanel({
    super.key,
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.centerIcon,
    required this.onEnd,
    this.vibrationModes,
  });

  final double scale;
  final String title;
  final String subtitle;
  final String statusLabel;
  final IconData centerIcon;
  final VoidCallback onEnd;
  final Widget? vibrationModes;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 424 * scale + bottomInset,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(23 * scale),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 26 * scale,
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 20 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 14 * scale,
                      color: const Color(0xFFD4D4D4),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 82 * scale,
              child: _GuideVisualizer(
                scale: scale,
                centerIcon: centerIcon,
                statusLabel: statusLabel,
              ),
            ),
            if (vibrationModes != null)
              Positioned(
                left: 0,
                right: 0,
                top: 252 * scale,
                child: vibrationModes!,
              ),
            Positioned(
              left: 19 * scale,
              right: 19 * scale,
              bottom: kWalkGuideEndButtonBottomInset * scale + bottomInset,
              child: WalkGuideEndButton(
                scale: scale,
                onTap: onEnd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalkVibrationModeRow extends StatelessWidget {
  const WalkVibrationModeRow({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return SizedBox(
      height: 51 * s,
      child: Stack(
        children: [
          Positioned(
            left: 53 * s,
            child: WalkVibrationModeChip(
              scale: s,
              bars: const [WalkVibrationBarSpec(11), WalkVibrationBarSpec(11)],
              title: '짧은 2회',
              subtitle: '조심',
            ),
          ),
          Positioned(
            left: 155.5 * s,
            child: WalkVibrationModeChip(
              scale: s,
              bars: const [
                WalkVibrationBarSpec(11),
                WalkVibrationBarSpec(11),
                WalkVibrationBarSpec(11),
              ],
              title: '3회 반복',
              subtitle: '경고',
            ),
          ),
          Positioned(
            left: 257 * s,
            child: WalkVibrationModeChip(
              scale: s,
              bars: const [WalkVibrationBarSpec(61)],
              title: '긴 진동',
              subtitle: '위험',
            ),
          ),
        ],
      ),
    );
  }
}

class WalkVibrationBarSpec {
  const WalkVibrationBarSpec(this.width);
  final double width;
}

class WalkVibrationModeChip extends StatelessWidget {
  const WalkVibrationModeChip({
    super.key,
    required this.scale,
    required this.bars,
    required this.title,
    required this.subtitle,
  });

  final double scale;
  final List<WalkVibrationBarSpec> bars;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final s = scale;

    return Container(
      width: 92 * s,
      height: 51 * s,
      padding: EdgeInsets.fromLTRB(0, 9 * s, 0, 5 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10 * s),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < bars.length; i++) ...[
                if (i > 0) SizedBox(width: 4 * s),
                _WalkVibrationGradientBar(scale: s, width: bars[i].width),
              ],
            ],
          ),
          SizedBox(height: 3 * s),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 10 * s,
              height: 1,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * s),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 8 * s,
              height: 1,
              color: const Color(0xFFA5A5A5),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkVibrationGradientBar extends StatelessWidget {
  const _WalkVibrationGradientBar({required this.scale, required this.width});

  final double scale;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * scale,
      height: 7 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.5 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFF648BF5), Color(0xFFDD8DFF)],
        ),
      ),
    );
  }
}

/// "안내 중." / "진동 중." 등 — 점 1~3개 순환
class WalkLoadingDotsText extends StatefulWidget {
  const WalkLoadingDotsText({
    super.key,
    required this.scale,
    required this.baseText,
  });

  final double scale;
  final String baseText;

  @override
  State<WalkLoadingDotsText> createState() => _WalkLoadingDotsTextState();
}

class _WalkLoadingDotsTextState extends State<WalkLoadingDotsText> {
  Timer? _timer;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() => _dotCount = _dotCount % 3 + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'LGSmartUI',
      fontWeight: FontWeight.w600,
      fontSize: 12 * widget.scale,
      height: 1,
      color: Colors.white,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: widget.baseText, style: style),
          TextSpan(text: '.' * _dotCount, style: style),
          TextSpan(
            text: '.' * (3 - _dotCount),
            style: style.copyWith(color: Colors.transparent),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class WalkGuideEndButton extends StatelessWidget {
  const WalkGuideEndButton(
      {super.key, required this.scale, required this.onTap});

  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 47 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(9 * scale),
        ),
        child: Text(
          '종료',
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w700,
            fontSize: 16 * scale,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _GuideVisualizer extends StatelessWidget {
  const _GuideVisualizer({
    required this.scale,
    required this.centerIcon,
    required this.statusLabel,
  });

  final double scale;
  final IconData centerIcon;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final circleSize = 169 * scale;

    return SizedBox(
      height: circleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 21 * scale,
            top: 57 * scale,
            child: _WaveBurst(scale: scale, mirrored: false),
          ),
          Positioned(
            right: 21 * scale,
            top: 57 * scale,
            child: _WaveBurst(scale: scale, mirrored: true),
          ),
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF648BF5).withValues(alpha: 0.35),
                  const Color(0xFFDD8DFF).withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Container(
            width: 141 * scale,
            height: 141 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              border: Border.all(
                color: const Color(0xFFDD8DFF).withValues(alpha: 0.55),
                width: 2 * scale,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(centerIcon, color: Colors.white, size: 34 * scale),
                SizedBox(height: 8 * scale),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 12 * scale,
                    color: Colors.white,
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

class _WaveBurst extends StatelessWidget {
  const _WaveBurst({required this.scale, required this.mirrored});

  final double scale;
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    final bars = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _waveBar(18),
        SizedBox(width: 3 * scale),
        _waveBar(34),
        SizedBox(width: 3 * scale),
        _waveBar(24),
        SizedBox(width: 3 * scale),
        _waveBar(40),
        SizedBox(width: 3 * scale),
        _waveBar(20),
      ],
    );

    return SizedBox(
      width: 83 * scale,
      height: 62 * scale,
      child: mirrored ? Transform.flip(flipX: true, child: bars) : bars,
    );
  }

  Widget _waveBar(double height) {
    return Container(
      width: 8 * scale,
      height: height * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4 * scale),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0xFF648BF5), Color(0xFFDD8DFF)],
        ),
      ),
    );
  }
}
