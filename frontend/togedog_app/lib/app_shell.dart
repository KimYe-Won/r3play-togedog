// 공통 헤더·하단 네비·화면 전환
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_01.dart';
import 'mypage_01.dart';
import 'noti_01.dart';
import 'report_01.dart';
import 'walk_01.dart';

/// Figma 기준 화면 너비
const double kTogedogDesignWidth = 402;

enum AppTab { home, walk, report, mypage }

class TogedogAssets {
  static const background = 'asset/home/home_screen_background.png';
  static const backgroundFallback = 'asset/home/home_screen_background.png';
  static const bell = 'asset/home/home_bell.svg';
  static const settings = 'asset/home/home_settings.svg';
  static const headerChevron = 'asset/home/home_header_chevron.svg';
  static const navHome = 'asset/home/home_nav_home.svg';
  static const navWalkMode = 'asset/home/home_nav_walk_mode.svg';
  static const navReport = 'asset/home/home_nav_report.svg';
  static const navMypage = 'asset/home/home_nav_mypage.svg';
  static const petPhoto = 'asset/home/home_pet_kong.png';
  static const petPhotoFallback = 'asset/home/home_pet_kong.png';
  static const heartCircle = 'asset/home/home_heart_circle.svg';
  static const heartIcon = 'asset/home/home_heart_icon.svg';
  static const activityCircle = 'asset/home/home_activity_circle.svg';
  static const activityIcon = 'asset/home/home_activity_icon.svg';

  static Widget svg(
    String asset, {
    required double width,
    required double height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }
}

void openNotifications(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const Noti01Screen()),
  );
}

void navigateToTab(BuildContext context, AppTab tab) {
  final route = switch (tab) {
    AppTab.home => MaterialPageRoute<void>(builder: (_) => const Home01Screen()),
    AppTab.walk => MaterialPageRoute<void>(builder: (_) => const Walk01Screen()),
    AppTab.report => MaterialPageRoute<void>(builder: (_) => const Report01Screen()),
    AppTab.mypage => MaterialPageRoute<void>(builder: (_) => const Mypage01Screen()),
  };
  Navigator.of(context).pushReplacement(route);
}

class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.scale,
    required this.title,
    this.showChevron = false,
    this.onBellTap,
    this.leading,
  });

  final double scale;
  final String title;
  final bool showChevron;
  final VoidCallback? onBellTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: 9 * scale),
          ],
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w700,
                        fontSize: 20 * scale,
                        height: 1.15,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                  if (showChevron) ...[
                    SizedBox(width: 9 * scale),
                    TogedogAssets.svg(
                      TogedogAssets.headerChevron,
                      width: 6 * scale,
                      height: 13 * scale,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onBellTap ?? () => openNotifications(context),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(top: 2 * scale),
                    child: TogedogAssets.svg(
                      TogedogAssets.bell,
                      width: 21 * scale,
                      height: 21 * scale,
                    ),
                  ),
                ),
                SizedBox(width: 11 * scale),
                TogedogAssets.svg(
                  TogedogAssets.settings,
                  width: 25 * scale,
                  height: 25 * scale,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.scale,
    required this.bottomInset,
    required this.activeTab,
    this.backgroundColor,
  });

  final double scale;
  final double bottomInset;
  final AppTab activeTab;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        38 * scale,
        19 * scale,
        38 * scale,
        19 * scale + bottomInset,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00FFFFFF), Color(0xFFF0EAFF)],
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            scale: scale,
            label: '홈',
            active: activeTab == AppTab.home,
            onTap: activeTab == AppTab.home
                ? null
                : () => navigateToTab(context, AppTab.home),
            iconAsset: TogedogAssets.navHome,
            iconWidth: 25 * scale,
            iconHeight: 22 * scale,
          ),
          _NavItem(
            scale: scale,
            label: '산책모드',
            active: activeTab == AppTab.walk,
            onTap: activeTab == AppTab.walk
                ? null
                : () => navigateToTab(context, AppTab.walk),
            iconAsset: TogedogAssets.navWalkMode,
            iconWidth: 16.5 * scale,
            iconHeight: 22 * scale,
          ),
          _NavItem(
            scale: scale,
            label: '리포트',
            active: activeTab == AppTab.report,
            onTap: activeTab == AppTab.report
                ? null
                : () => navigateToTab(context, AppTab.report),
            iconAsset: TogedogAssets.navReport,
            iconWidth: 21 * scale,
            iconHeight: 21 * scale,
          ),
          _NavItem(
            scale: scale,
            label: '마이페이지',
            active: activeTab == AppTab.mypage,
            onTap: activeTab == AppTab.mypage
                ? null
                : () => navigateToTab(context, AppTab.mypage),
            iconAsset: TogedogAssets.navMypage,
            iconWidth: 26 * scale,
            iconHeight: 26 * scale,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.scale,
    required this.label,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.active,
    this.onTap,
  });

  final double scale;
  final String label;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final bool active;
  final VoidCallback? onTap;

  static const _activeColor = Color(0xFF8756E7);
  static const _inactiveColor = Color(0xFF6A6A6A);

  @override
  Widget build(BuildContext context) {
    final color = active ? _activeColor : _inactiveColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TogedogAssets.svg(
            iconAsset,
            width: iconWidth,
            height: iconHeight,
            color: color,
          ),
          SizedBox(height: 6 * scale),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 12 * scale,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 설정 목록 행 (마이페이지)
class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.scale,
    required this.title,
    this.onTap,
    this.showDivider = true,
  });

  final double scale;
  final String title;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 21 * scale, vertical: 14 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * scale,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18 * scale,
                  color: const Color(0xFF6A6A6A),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 21 * scale,
            endIndent: 21 * scale,
            color: const Color(0xFFE8E8EC),
          ),
      ],
    );
  }
}
