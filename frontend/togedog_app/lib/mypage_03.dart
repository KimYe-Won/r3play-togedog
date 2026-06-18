// TogeDog 웨어러블 관리 — Figma node 730:6833
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'onboarding_wearable_shared.dart';
import 'pet_profile_store.dart';
import 'togedog_accessibility.dart';

/// Figma 730:6833 고정 좌표 (402×874)
class _Mypage03Layout {
  static const designWidth = 402.0;
  static const designHeight = 874.0;
  static const backLeft = 16.0;
  static const backTop = 36.0;
  static const backWidth = 131.0;
  static const backHeight = 33.0;
  static const titleTop = 87.0;
  static const subtitleTop = 140.0;
  static const heroLeft = 75.0;
  static const heroTop = 249.0;
  static const heroWidth = 252.0;
  static const heroGap = 20.0;
  static const productWidth = 194.0;
  static const productHeight = 250.0;
  static const titleFontSize = 25.0;
  static const dotsTop = 568.0;
  static const cardTop = 606.0;
  static const cardLeft = 37.0;
  static const cardWidth = 338.0;
  static const cardHeight = 100.0;
  static const cardPageStride = 350.0;
  static const helpTop = 769.0;
  static const helpLeft = 136.0;
  static const helpWidth = 130.0;
}

class _Mypage03Scaler {
  _Mypage03Scaler(BuildContext context)
      : media = MediaQuery.of(context),
        screenWidth = MediaQuery.sizeOf(context).width {
    topPadding = media.padding.top;
    bottomPadding = media.padding.bottom;
    final availableHeight = media.size.height - topPadding - bottomPadding;
    scale = math.min(
      screenWidth / _Mypage03Layout.designWidth,
      availableHeight / _Mypage03Layout.designHeight,
    );
    canvasWidth = _Mypage03Layout.designWidth * scale;
    canvasHeight = _Mypage03Layout.designHeight * scale;
    canvasLeft = (screenWidth - canvasWidth) / 2;
    canvasTop = topPadding + (availableHeight - canvasHeight) / 2;
  }

  final MediaQueryData media;
  final double screenWidth;
  late final double topPadding;
  late final double bottomPadding;
  late final double scale;
  late final double canvasWidth;
  late final double canvasHeight;
  late final double canvasLeft;
  late final double canvasTop;
}

class Mypage03Screen extends StatefulWidget {
  const Mypage03Screen({super.key});

  @override
  State<Mypage03Screen> createState() => _Mypage03ScreenState();
}

class _Mypage03ScreenState extends State<Mypage03Screen> {
  int _pageIndex = 0;
  double _dragPx = 0;

  void _onHorizontalDragUpdate(
    DragUpdateDetails details,
    double stridePx,
    int pageCount,
  ) {
    setState(() {
      final minDrag = _pageIndex >= pageCount - 1 ? 0.0 : -stridePx;
      final maxDrag = _pageIndex <= 0 ? 0.0 : stridePx;
      _dragPx = (_dragPx + details.delta.dx).clamp(minDrag, maxDrag);
    });
  }

  void _onHorizontalDragEnd(
    DragEndDetails details,
    double stridePx,
    int pageCount,
  ) {
    final velocity = details.primaryVelocity ?? 0;
    var nextIndex = _pageIndex;
    if (_dragPx < -stridePx * 0.18 || velocity < -280) {
      nextIndex = math.min(_pageIndex + 1, pageCount - 1);
    } else if (_dragPx > stridePx * 0.18 || velocity > 280) {
      nextIndex = math.max(_pageIndex - 1, 0);
    }
    setState(() {
      _pageIndex = nextIndex;
      _dragPx = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scaler = _Mypage03Scaler(context);
    final s = scaler.scale;
    final petName = PetProfileStore.instance.displayPetName;
    final devices = [
      _WearableDeviceData(
        name: '$petName 하네스',
        status: WearableConnectionStatus.connecting,
        productAsset: _MypageWearableAssets.product,
        productTitle: 'TogeDog Harness',
      ),
      const _WearableDeviceData(
        name: '별이 하네스',
        status: WearableConnectionStatus.available,
        productAsset: _MypageWearableAssets.product,
        productTitle: 'TogeDog Harness',
      ),
    ];

    final stridePx = _Mypage03Layout.cardPageStride * s;
    final carouselHeight =
        (_Mypage03Layout.cardTop + _Mypage03Layout.cardHeight - _Mypage03Layout.heroTop) * s;
    final cardOffsetInCarousel = (_Mypage03Layout.cardTop - _Mypage03Layout.heroTop) * s;

    return TogedogA11y.screen(
      name: '웨어러블 디바이스 관리',
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFBFBFF), Color(0xFFF0EAFF)],
                stops: [0.19006, 0.86364],
              ),
            ),
          ),
          Positioned(
            left: scaler.canvasLeft,
            top: scaler.canvasTop,
            width: scaler.canvasWidth,
            height: scaler.canvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ..._WearableBackgroundDecor.build(s),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _Mypage03Layout.titleTop * s,
                  child: Text(
                    '웨어러블 관리',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w700,
                      fontSize: 35 * s,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: _Mypage03Layout.subtitleTop * s,
                  child: Text(
                    '반려견의 상태를 확인할 기기를 연결해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 14 * s,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: _Mypage03Layout.heroTop * s,
                  width: scaler.canvasWidth,
                  height: carouselHeight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) =>
                        _onHorizontalDragUpdate(details, stridePx, devices.length),
                    onHorizontalDragEnd: (details) =>
                        _onHorizontalDragEnd(details, stridePx, devices.length),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var i = 0; i < devices.length; i++) ...[
                          Positioned(
                            left: _Mypage03Layout.heroLeft * s +
                                (i - _pageIndex) * stridePx +
                                _dragPx,
                            top: 0,
                            width: _Mypage03Layout.heroWidth * s,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: _Mypage03Layout.productWidth * s,
                                  height: _Mypage03Layout.productHeight * s,
                                  child: Image.asset(
                                    devices[i].productAsset,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomCenter,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFFE8E8EC),
                                    ),
                                  ),
                                ),
                                SizedBox(height: _Mypage03Layout.heroGap * s),
                                Text(
                                  devices[i].productTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'LGSmartUI',
                                    fontWeight: FontWeight.w700,
                                    fontSize: _Mypage03Layout.titleFontSize * s,
                                    color: const Color(0xFF111111),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: _Mypage03Layout.cardLeft * s +
                                (i - _pageIndex) * stridePx +
                                _dragPx,
                            top: cardOffsetInCarousel,
                            width: _Mypage03Layout.cardWidth * s,
                            height: _Mypage03Layout.cardHeight * s,
                            child: _DeviceCard(
                              scale: s,
                              name: devices[i].name,
                              status: devices[i].status,
                              connectMode: _connectButtonMode(
                                devices[i].status,
                                devices,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: _Mypage03Layout.heroLeft * s,
                  top: _Mypage03Layout.dotsTop * s,
                  width: _Mypage03Layout.heroWidth * s,
                  child: IgnorePointer(
                    child: Center(
                      child: _WearablePageDots(
                        scale: s,
                        activeIndex: _pageIndex,
                        itemCount: devices.length,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _Mypage03Layout.helpLeft * s,
                  top: _Mypage03Layout.helpTop * s,
                  width: _Mypage03Layout.helpWidth * s,
                  child: Column(
                    children: [
                      Text(
                        '기기가 보이지 않나요?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w400,
                          fontSize: 15 * s,
                          color: const Color(0xFF687080),
                        ),
                      ),
                      SizedBox(height: 6 * s),
                      Text(
                        '도움 받기',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w700,
                          fontSize: 15 * s,
                          color: const Color(0xFF8256E8),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: _Mypage03Layout.backLeft * s,
                  top: _Mypage03Layout.backTop * s,
                  width: _Mypage03Layout.backWidth * s,
                  height: _Mypage03Layout.backHeight * s,
                  child: TogedogA11y.button(
                    label: '뒤로',
                    hint: '이전 화면으로',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: TogedogAssets.svg(
                        _MypageWearableAssets.back,
                        width: _Mypage03Layout.backWidth * s,
                        height: _Mypage03Layout.backHeight * s,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

WearableConnectButtonMode _connectButtonMode(
  WearableConnectionStatus status,
  List<_WearableDeviceData> devices,
) {
  final anyConnecting = devices.any(
    (device) => device.status == WearableConnectionStatus.connecting,
  );
  if (status == WearableConnectionStatus.connecting) {
    return WearableConnectButtonMode.connecting;
  }
  if (anyConnecting) {
    return WearableConnectButtonMode.disabled;
  }
  return WearableConnectButtonMode.available;
}

class _WearableDeviceData {
  const _WearableDeviceData({
    required this.name,
    required this.status,
    required this.productAsset,
    required this.productTitle,
  });

  final String name;
  final WearableConnectionStatus status;
  final String productAsset;
  final String productTitle;
}

class _WearableBackgroundDecor {
  static List<Widget> build(double scale) {
    Widget paw(String asset, double left, double top, double width, double height, double angle) {
      return Positioned(
        left: left * scale,
        top: top * scale,
        child: Transform.rotate(
          angle: angle,
          child: TogedogAssets.svg(
            asset,
            width: width * scale,
            height: height * scale,
          ),
        ),
      );
    }

    Widget star(String asset, double left, double top, double size) {
      return Positioned(
        left: left * scale,
        top: top * scale,
        child: TogedogAssets.svg(
          asset,
          width: size * scale,
          height: size * scale,
        ),
      );
    }

    return [
      paw(_MypageWearableAssets.pawBg1, 28, 311.5, 40, 38, -0.37),
      paw(_MypageWearableAssets.pawBg2, 54, 479.3, 42, 40, -0.53),
      paw(_MypageWearableAssets.pawBg3, 329, 382, 39, 36, 0.29),
      star(_MypageWearableAssets.starSm, 308, 219, 13),
      star(_MypageWearableAssets.starSm, 277, 499, 13),
      star(_MypageWearableAssets.starSm, 83, 232, 13),
      star(_MypageWearableAssets.starLg, 27, 428, 18),
    ];
  }
}

class _WearablePageDots extends StatelessWidget {
  const _WearablePageDots({
    required this.scale,
    required this.activeIndex,
    required this.itemCount,
  });

  final double scale;
  final int activeIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final active = index == activeIndex;
        return Container(
          width: (active ? 8 : 6) * scale,
          height: (active ? 8 : 6) * scale,
          margin: EdgeInsets.symmetric(horizontal: 4 * scale),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF111111) : const Color(0xFFA7ADBB),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _MypageWearableAssets {
  static const back = 'asset/mypage/mypage_wearable_back.svg';
  static const product = 'asset/mypage/mypage_wearable_product.png';
  static const paw = 'asset/mypage/mypage_wearable_paw.svg';
  static const pawBg1 = 'asset/mypage/mypage_wearable_paw_bg_1.svg';
  static const pawBg2 = 'asset/mypage/mypage_wearable_paw_bg_2.svg';
  static const pawBg3 = 'asset/mypage/mypage_wearable_paw_bg_3.svg';
  static const starSm = 'asset/mypage/mypage_wearable_star_sm.svg';
  static const starLg = 'asset/mypage/mypage_wearable_star_lg.svg';
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.scale,
    required this.name,
    required this.status,
    required this.connectMode,
  });

  final double scale;
  final String name;
  final WearableConnectionStatus status;
  final WearableConnectButtonMode connectMode;

  @override
  Widget build(BuildContext context) {
    final statusLabel = status == WearableConnectionStatus.available
        ? '연결 가능'
        : '연결 중';

    return Container(
      padding: EdgeInsets.fromLTRB(20 * scale, 22 * scale, 35 * scale, 22 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          TogedogAssets.svg(
            _MypageWearableAssets.paw,
            width: 56 * scale,
            height: 56 * scale,
          ),
          SizedBox(width: 17 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w700,
                    fontSize: 18 * scale,
                    color: const Color(0xFF111111),
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * scale,
                    color: const Color(0xFF8256E8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 27 * scale,
            padding: EdgeInsets.symmetric(horizontal: 12 * scale),
            decoration: BoxDecoration(
              color: _connectButtonBackground(connectMode),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              '연결',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 12 * scale,
                color: _connectButtonTextColor(connectMode),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _connectButtonBackground(WearableConnectButtonMode mode) {
  const base = WearableConnectionTheme.brandPurple;
  switch (mode) {
    case WearableConnectButtonMode.connecting:
      return Color.lerp(base, Colors.white, 0.08)!;
    case WearableConnectButtonMode.disabled:
      return WearableConnectionTheme.disabledButtonBackground;
    case WearableConnectButtonMode.available:
      return base;
  }
}

Color _connectButtonTextColor(WearableConnectButtonMode mode) {
  switch (mode) {
    case WearableConnectButtonMode.disabled:
      return WearableConnectionTheme.disabledButtonText;
    case WearableConnectButtonMode.available:
    case WearableConnectButtonMode.connecting:
      return Colors.white;
  }
}
