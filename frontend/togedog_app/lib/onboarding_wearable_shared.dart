import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'togedog_accessibility.dart';

enum WearableHarnessId { kong, star }

enum WearableConnectionStatus { available, connecting }

class WearableHarnessDevice {
  const WearableHarnessDevice({
    required this.id,
    required this.name,
    required this.status,
  });

  final WearableHarnessId id;
  final String name;
  final WearableConnectionStatus status;

  WearableHarnessDevice copyWith({WearableConnectionStatus? status}) {
    return WearableHarnessDevice(
      id: id,
      name: name,
      status: status ?? this.status,
    );
  }

  String get statusLabel =>
      status == WearableConnectionStatus.available ? '연결 가능' : '연결 중';
}

/// Figma 488:359 / 582:12748 공통 웨어러블 연결 레이아웃
class WearableConnectionTheme {
  WearableConnectionTheme._();

  static const double designWidth = 402;
  static const double designHeight = 875;
  static const double horizontalInset = 16;
  static const double backTop = 36;
  static const double backSize = 24;
  static const double titleTop = 93;
  static const double subtitleTop = 140;
  static const double subtitleHeight = 16;
  static const double heroLeft = 75;
  static const double heroTop = 203;
  static const double heroWidth = 252;
  /// Figma 슬롯 172×222, 12화면 보정 스케일
  static const double productSlotWidth = 172;
  static const double productSlotHeight = 222;
  static const double productBaseWidth = 140;
  static const double productBaseHeight = 180;
  static const double productVisualScale = 2.325;
  static const double productImageTopOffset = 3;
  /// 12화면 로딩바와 동일 (main_onboarding_12.dart)
  static const double loadingBarTop = 494;
  static const double loadingBarHeight = 3;
  static const double loadingBarBottom = loadingBarTop + loadingBarHeight;
  /// 12 로딩바↔상태카드 / 13 Harness↔콩이 하네스 카드 (Figma 34px)
  static const double harnessToCardGap = 34;
  static const double harnessTitleFontSize = 25;
  static const double harnessTitleLineHeight = 1.1;
  static const double harnessTitleMetricsHeight =
      harnessTitleFontSize * harnessTitleLineHeight;
  static const double cardLeft = 37;
  static const double card1Top = 531;
  static const double harnessTitleBottom = card1Top - harnessToCardGap;
  static const double harnessTitleTop =
      harnessTitleBottom - harnessTitleMetricsHeight;
  static const double card2Top = 647;
  static const double cardWidth = 338;
  static const double cardHeight = 100;
  static const double cardRadius = 20;
  static const double helpTop = 769;
  static const double modalTop = 445;
  static const double modalHeight = 429;
  static const double modalRadius = 23;
  /// Figma 585:12845 모달 내 제품 GIF 슬롯 (604:12878)
  static const double modalProductWidth = 136;
  static const double modalProductHeight = 201;
  static const double modalProductDisplayScale = 2;
  static double get modalProductDisplayWidth =>
      modalProductWidth * modalProductDisplayScale;
  static double get modalProductDisplayHeight =>
      modalProductHeight * modalProductDisplayScale;
  static const double modalHeaderToProductGap = 50;
  static const double modalProductToBatteryGap = 25;

  static const Color brandPurple = Color(0xFF8756E7);
  static const Color brandPurpleAlt = Color(0xFF8256E8);
  static const Color gradientStart = Color(0xFFFBFBFF);
  static const Color gradientEnd = Color(0xFFF0EAFF);
  static const Color titleBlack = Color(0xFF111111);
  static const Color subtitleGray = Color(0xFF828282);
  static const Color helpGray = Color(0xFF687080);
  static const Color dimOverlay = Color(0x73000000);
  static const Color batteryGreen = Color(0xFF41AC58);
  static const Color batteryBorder = Color(0xFFA7ADBB);
  static const Color disabledButtonBackground = Color(0xFFEDEDED);
  static const Color disabledButtonText = Color(0xFF828282);

  static double get productZoneTop => subtitleTop + subtitleHeight;

  static double productImageTop(double renderHeightDesign) {
    final zoneCenter = (productZoneTop + loadingBarTop) / 2;
    return zoneCenter - renderHeightDesign / 2 + productImageTopOffset;
  }

  static double get productRenderWidthDesign =>
      productBaseWidth * productVisualScale;

  static double get productRenderHeightDesign =>
      productBaseHeight * productVisualScale;

  static const String productImageAsset = 'asset/onboarding/onboarding_device_product.png';
  static const String productGifAsset = 'asset/onboarding/onboarding_wearable_product.gif';
  static const String productFrontAsset =
      'asset/onboarding/onboarding_device_product_front.png';
  static const String backButtonAsset = 'asset/onboarding/onboarding_profile_back.svg';
  static const String cardIconAsset =
      'asset/onboarding/onboarding_device_search_card_icon.svg';
  static const String pawDecor1Asset =
      'asset/onboarding/onboarding_device_search_paw_decor_1.svg';
  static const String pawDecor2Asset =
      'asset/onboarding/onboarding_device_search_paw_decor_2.svg';
  static const String pawDecor3Asset =
      'asset/onboarding/onboarding_device_search_paw_decor_3.svg';
  static const String starAsset = 'asset/onboarding/onboarding_device_search_star.svg';
  static const String starSmallAsset =
      'asset/onboarding/onboarding_device_search_star_sm.svg';
  static const String batteryLightningAsset =
      'asset/onboarding/onboarding_wearable_battery_lightning.svg';
  static const String batteryTipAsset =
      'asset/onboarding/onboarding_wearable_battery_tip.svg';

  static const List<WearableHarnessDevice> initialDevices = [
    WearableHarnessDevice(
      id: WearableHarnessId.kong,
      name: '콩이 하네스',
      status: WearableConnectionStatus.available,
    ),
    WearableHarnessDevice(
      id: WearableHarnessId.star,
      name: '별이 하네스',
      status: WearableConnectionStatus.available,
    ),
  ];
}

class WearableCanvasScaler {
  WearableCanvasScaler(BuildContext context)
      : media = MediaQuery.of(context),
        screenWidth = MediaQuery.sizeOf(context).width,
        topPadding = MediaQuery.of(context).padding.top,
        bottomPadding = MediaQuery.of(context).padding.bottom {
    final availableHeight = screenHeight - topPadding - bottomPadding;
    scale = math.min(
      screenWidth / WearableConnectionTheme.designWidth,
      availableHeight / WearableConnectionTheme.designHeight,
    );
    canvasWidth = WearableConnectionTheme.designWidth * scale;
    canvasHeight = WearableConnectionTheme.designHeight * scale;
    canvasLeft = (screenWidth - canvasWidth) / 2;
    canvasTop = topPadding + (availableHeight - canvasHeight) / 2;
  }

  final MediaQueryData media;
  final double screenWidth;
  final double topPadding;
  final double bottomPadding;
  late final double scale;
  late final double canvasWidth;
  late final double canvasHeight;
  late final double canvasLeft;
  late final double canvasTop;

  double get screenHeight => media.size.height;

  double y(double designY) => designY * scale;
}

enum WearableConnectButtonMode { available, connecting, disabled }

/// 12→13 입장 모션 값 (0~1)
class WearableEntranceMotion {
  const WearableEntranceMotion({
    required this.product,
    required this.header,
    required this.harnessTitle,
    required this.card1,
    required this.card2,
    required this.help,
  });

  final double product;
  final double header;
  final double harnessTitle;
  final double card1;
  final double card2;
  final double help;

  static const WearableEntranceMotion complete = WearableEntranceMotion(
    product: 1,
    header: 1,
    harnessTitle: 1,
    card1: 1,
    card2: 1,
    help: 1,
  );

  static double interval(
    double t,
    double start,
    double end,
    Curve curve,
  ) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return curve.transform((t - start) / (end - start));
  }

  static WearableEntranceMotion fromProgress(double t) {
    return WearableEntranceMotion(
      product: interval(t, 0, 0.34, Curves.easeOutBack),
      header: interval(t, 0.05, 0.32, Curves.easeOutCubic),
      harnessTitle: interval(t, 0.18, 0.42, Curves.easeOutCubic),
      card1: interval(t, 0.24, 0.58, Curves.easeOutCubic),
      card2: interval(t, 0.40, 0.74, Curves.easeOutCubic),
      help: interval(t, 0.52, 0.86, Curves.easeOutCubic),
    );
  }
}

class WearableConnectionCanvas extends StatelessWidget {
  const WearableConnectionCanvas({
    super.key,
    required this.scale,
    required this.devices,
    this.onConnect,
    this.connectEnabled = true,
    this.entrance = WearableEntranceMotion.complete,
  });

  final double scale;
  final List<WearableHarnessDevice> devices;
  final void Function(WearableHarnessId id)? onConnect;
  final bool connectEnabled;
  final WearableEntranceMotion entrance;

  @override
  Widget build(BuildContext context) {
    final canvasWidth = WearableConnectionTheme.designWidth * scale;
    final canvasHeight = WearableConnectionTheme.designHeight * scale;
    final productRenderWidth =
        WearableConnectionTheme.productRenderWidthDesign * scale;
    final productRenderHeight =
        WearableConnectionTheme.productRenderHeightDesign * scale;
    final productTop = y(
      WearableConnectionTheme.productImageTop(
        WearableConnectionTheme.productRenderHeightDesign,
      ),
    );
    final anyConnecting = devices.any(
      (device) => device.status == WearableConnectionStatus.connecting,
    );
    final productScale = 0.56 + 0.44 * entrance.product;
    const cardRiseDesign = 132.0;
    const harnessRiseDesign = 28.0;

    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: (canvasWidth - productRenderWidth) / 2,
            top: productTop,
            width: productRenderWidth,
            height: productRenderHeight,
            child: Opacity(
              opacity: entrance.product.clamp(0, 1),
              child: Transform.scale(
                scale: productScale,
                alignment: Alignment.center,
                child: TogedogA11y.decorative(
                  Image.asset(
                    WearableConnectionTheme.productImageAsset,
                    width: productRenderWidth,
                    height: productRenderHeight,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: y(WearableConnectionTheme.harnessTitleTop) +
                (1 - entrance.harnessTitle) * harnessRiseDesign * scale,
            child: Opacity(
              opacity: entrance.harnessTitle.clamp(0, 1),
              child: Text(
                'TogeDog Harness',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize:
                      WearableConnectionTheme.harnessTitleFontSize * scale,
                  height: WearableConnectionTheme.harnessTitleLineHeight,
                  color: WearableConnectionTheme.titleBlack,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            width: canvasWidth,
            height: canvasHeight,
            child: IgnorePointer(
              child: Opacity(
                opacity: entrance.header.clamp(0, 1),
                child: _WearableDecorLayer(
                  canvasWidth: canvasWidth,
                  canvasHeight: canvasHeight,
                ),
              ),
            ),
          ),
          Positioned(
            left: WearableConnectionTheme.horizontalInset * scale,
            top: y(WearableConnectionTheme.backTop),
            child: Opacity(
              opacity: entrance.header.clamp(0, 1),
              child: TogedogA11y.button(
                label: '뒤로',
                hint: '이전 화면으로',
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.all(4 * scale),
                    child: SvgPicture.asset(
                      WearableConnectionTheme.backButtonAsset,
                      width: WearableConnectionTheme.backSize * scale,
                      height: WearableConnectionTheme.backSize * scale,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: y(WearableConnectionTheme.titleTop),
            child: Opacity(
              opacity: entrance.header.clamp(0, 1),
              child: Text(
                '웨어러블 연결',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w700,
                  fontSize: 30 * scale,
                  height: 1.1,
                  color: WearableConnectionTheme.titleBlack,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: y(WearableConnectionTheme.subtitleTop),
            child: Opacity(
              opacity: entrance.header.clamp(0, 1),
              child: Text(
                '반려견의 상태를 확인할 기기와 연결되었어요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * scale,
                  height: 1.2,
                  color: WearableConnectionTheme.subtitleGray,
                ),
              ),
            ),
          ),
          for (final entry in devices.asMap().entries)
            Positioned(
              left: WearableConnectionTheme.cardLeft * scale,
              top: y(
                entry.key == 0
                    ? WearableConnectionTheme.card1Top
                    : WearableConnectionTheme.card2Top,
              ) +
                  (1 -
                          (entry.key == 0
                              ? entrance.card1
                              : entrance.card2)) *
                      (entry.key == 0
                          ? cardRiseDesign
                          : cardRiseDesign * 1.5) *
                      scale,
              width: WearableConnectionTheme.cardWidth * scale,
              height: WearableConnectionTheme.cardHeight * scale,
              child: Opacity(
                opacity: (entry.key == 0 ? entrance.card1 : entrance.card2)
                    .clamp(0, 1),
                child: _WearableDeviceCard(
                  scale: scale,
                  device: entry.value,
                  buttonMode: _connectButtonMode(
                    entry.value,
                    anyConnecting: anyConnecting,
                    connectEnabled: connectEnabled,
                  ),
                  onConnect: connectEnabled &&
                          !anyConnecting &&
                          entry.value.status ==
                              WearableConnectionStatus.available &&
                          onConnect != null
                      ? () => onConnect!(entry.value.id)
                      : null,
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            top: y(WearableConnectionTheme.helpTop) +
                (1 - entrance.help) * 40 * scale,
            child: Opacity(
              opacity: entrance.help.clamp(0, 1),
              child: TogedogA11y.link(
                label: '도움 받기',
                hint: '기기가 보이지 않을 때 도움 받기',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '기기가 보이지 않나요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w400,
                        fontSize: 15 * scale,
                        height: 1.2,
                        color: WearableConnectionTheme.helpGray,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      '도움 받기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w700,
                        fontSize: 15 * scale,
                        height: 1.2,
                        color: WearableConnectionTheme.brandPurpleAlt,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double y(double designY) => designY * scale;

  static WearableConnectButtonMode _connectButtonMode(
    WearableHarnessDevice device, {
    required bool anyConnecting,
    required bool connectEnabled,
  }) {
    if (device.status == WearableConnectionStatus.connecting) {
      return WearableConnectButtonMode.connecting;
    }
    if (anyConnecting || !connectEnabled) {
      return WearableConnectButtonMode.disabled;
    }
    return WearableConnectButtonMode.available;
  }
}

class _WearableDeviceCard extends StatelessWidget {
  const _WearableDeviceCard({
    required this.scale,
    required this.device,
    required this.buttonMode,
    this.onConnect,
  });

  final double scale;
  final WearableHarnessDevice device;
  final WearableConnectButtonMode buttonMode;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          WearableConnectionTheme.cardRadius * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20 * scale, 22 * scale, 35 * scale, 22 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 56 * scale,
              height: 56 * scale,
              child: SvgPicture.asset(
                WearableConnectionTheme.cardIconAsset,
                width: 56 * scale,
                height: 56 * scale,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 17 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    device.name,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w700,
                      fontSize: 18 * scale,
                      height: 1.2,
                      color: WearableConnectionTheme.titleBlack,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    device.statusLabel,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 15 * scale,
                      height: 1.2,
                      color: WearableConnectionTheme.brandPurpleAlt,
                    ),
                  ),
                ],
              ),
            ),
            _ConnectButton(
              scale: scale,
              mode: buttonMode,
              onPressed: onConnect,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectButton extends StatefulWidget {
  const _ConnectButton({
    required this.scale,
    required this.mode,
    this.onPressed,
  });

  final double scale;
  final WearableConnectButtonMode mode;
  final VoidCallback? onPressed;

  @override
  State<_ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<_ConnectButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _isInteractive =>
      widget.mode == WearableConnectButtonMode.available &&
      widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;

    return MouseRegion(
      cursor:
          _isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: _isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onExit: _isInteractive
          ? (_) => setState(() {
                _isHovered = false;
                _isPressed = false;
              })
          : null,
      child: TogedogA11y.button(
        label: '연결',
        hint: widget.mode == WearableConnectButtonMode.connecting
            ? '연결 중'
            : widget.mode == WearableConnectButtonMode.disabled
                ? '연결 불가'
                : null,
        enabled: _isInteractive,
        child: GestureDetector(
          onTapDown:
              _isInteractive ? (_) => setState(() => _isPressed = true) : null,
          onTapUp:
              _isInteractive ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel:
              _isInteractive ? () => setState(() => _isPressed = false) : null,
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 54 * scale,
          height: 26.526 * scale,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _backgroundColor(),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Text(
            '연결',
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 12 * scale,
              height: 1,
              color: _textColor(),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Color _backgroundColor() {
    const base = WearableConnectionTheme.brandPurple;

    switch (widget.mode) {
      case WearableConnectButtonMode.connecting:
        return Color.lerp(base, Colors.white, 0.08)!;
      case WearableConnectButtonMode.disabled:
        return WearableConnectionTheme.disabledButtonBackground;
      case WearableConnectButtonMode.available:
        if (_isPressed) {
          return Color.lerp(base, Colors.black, 0.16)!;
        }
        if (_isHovered) {
          return Color.lerp(base, Colors.white, 0.08)!;
        }
        return base;
    }
  }

  Color _textColor() {
    switch (widget.mode) {
      case WearableConnectButtonMode.disabled:
        return WearableConnectionTheme.disabledButtonText;
      case WearableConnectButtonMode.available:
      case WearableConnectButtonMode.connecting:
        return Colors.white;
    }
  }
}

class WearableBatteryIndicator extends StatelessWidget {
  const WearableBatteryIndicator({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44 * scale,
          height: 17 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                top: 1 * scale,
                child: Container(
                  width: 33 * scale,
                  height: 15 * scale,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: WearableConnectionTheme.batteryBorder,
                      width: 1.5 * scale,
                    ),
                    borderRadius: BorderRadius.circular(3 * scale),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(2 * scale),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: WearableConnectionTheme.batteryGreen,
                        borderRadius: BorderRadius.circular(2 * scale),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 31 * scale,
                top: 4.5 * scale,
                child: SvgPicture.asset(
                  WearableConnectionTheme.batteryTipAsset,
                  width: 6 * scale,
                  height: 6 * scale,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 11.5 * scale,
                top: 0,
                child: SvgPicture.asset(
                  WearableConnectionTheme.batteryLightningAsset,
                  width: 10 * scale,
                  height: 17 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          '89%',
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w700,
            fontSize: 20 * scale,
            height: 1.2,
            color: WearableConnectionTheme.brandPurpleAlt,
          ),
        ),
      ],
    );
  }
}

class _WearableDecorLayer extends StatelessWidget {
  const _WearableDecorLayer({
    required this.canvasWidth,
    required this.canvasHeight,
  });

  final double canvasWidth;
  final double canvasHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canvasWidth,
      height: canvasHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
        _InsetAsset(
          asset: WearableConnectionTheme.pawDecor1Asset,
          topRatio: 0.2574,
          rightRatio: 0.831,
          bottomRatio: 0.6995,
          leftRatio: 0.0697,
          rotation: -21.05 * math.pi / 180,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: WearableConnectionTheme.pawDecor2Asset,
          topRatio: 0.4439,
          rightRatio: 0.7617,
          bottomRatio: 0.5098,
          leftRatio: 0.1343,
          rotation: -30.63 * math.pi / 180,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: WearableConnectionTheme.pawDecor3Asset,
          topRatio: 0.3513,
          rightRatio: 0.1054,
          bottomRatio: 0.6076,
          leftRatio: 0.7985,
          rotation: 16.53 * math.pi / 180,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: WearableConnectionTheme.starAsset,
          topRatio: 0.2174,
          rightRatio: 0.2015,
          bottomRatio: 0.7677,
          leftRatio: 0.7662,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: WearableConnectionTheme.starAsset,
          topRatio: 0.4851,
          rightRatio: 0.2786,
          bottomRatio: 0.5,
          leftRatio: 0.6891,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: WearableConnectionTheme.starAsset,
          topRatio: 0.2323,
          rightRatio: 0.7612,
          bottomRatio: 0.7529,
          leftRatio: 0.2065,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
        _InsetAsset(
          asset: WearableConnectionTheme.starSmallAsset,
          topRatio: 0.4039,
          rightRatio: 0.8881,
          bottomRatio: 0.5755,
          leftRatio: 0.0672,
          canvasWidth: canvasWidth,
          canvasHeight: canvasHeight,
        ),
      ],
      ),
    );
  }
}

class _InsetAsset extends StatelessWidget {
  const _InsetAsset({
    required this.asset,
    required this.topRatio,
    required this.rightRatio,
    required this.bottomRatio,
    required this.leftRatio,
    required this.canvasWidth,
    required this.canvasHeight,
    this.rotation = 0,
  });

  final String asset;
  final double topRatio;
  final double rightRatio;
  final double bottomRatio;
  final double leftRatio;
  final double canvasWidth;
  final double canvasHeight;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final top = canvasHeight * topRatio;
    final left = canvasWidth * leftRatio;
    final width = canvasWidth * (1 - leftRatio - rightRatio);
    final height = canvasHeight * (1 - topRatio - bottomRatio);

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: TogedogA11y.decorative(
        Transform.rotate(
          angle: rotation,
          child: SvgPicture.asset(
            asset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
