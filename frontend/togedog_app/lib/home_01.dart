// TogeDog 홈 화면
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_shell.dart';
import 'main_onboarding_01.dart';
import 'main_onboarding_02.dart';
import 'mypage_02.dart';
import 'pet_profile_store.dart';
import 'walk_02.dart';

/// Figma: 홈화면 (node 625:7472)
class Home01Screen extends StatefulWidget {
  const Home01Screen({super.key});

  static const double designWidth = 402;

  @override
  State<Home01Screen> createState() => _Home01ScreenState();
}

class _HomeAssets {
  static const background = 'asset/홈화면_배경.png';
  static const backgroundFallback = 'asset/home_screen_background.png';
  static const petChevron = 'asset/home_pet_chevron.svg';
  static const heartCircle = 'asset/home_heart_circle.svg';
  static const heartIcon = 'asset/home_heart_icon.svg';
  static const heartChart = 'asset/home_heart_chart.svg';
  static const activityCircle = 'asset/home_activity_circle.svg';
  static const activityIcon = 'asset/home_activity_icon.svg';
  static const walkCard = 'asset/home_walk_mode_card.png';
  static const petPhoto = 'asset/홈_콩이.png';
  static const petPhotoFallback = 'asset/home_pet_kong.png';

  static const Color heartCircleColor = Color(0xFFFBE5EC);
  static const Color activityCircleColor = Color(0xFFF0EAFF);

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

class _Home01ScreenState extends State<Home01Screen>
    with SingleTickerProviderStateMixin {
  static const Duration _statsRevealDelay = Duration(seconds: 2);
  static const Duration _statsAnimDuration = Duration(milliseconds: 700);
  static const int _targetHeartRate = 98;
  static const int _targetSteps = 6245;

  late final AnimationController _statsController;
  late final Animation<double> _statsCurve;
  Timer? _statsRevealTimer;
  late DateTime _displayedMonth;
  DateTime? _selectedDate;
  bool _isAppSwitchOpen = false;

  PetProfileStore get _profile => PetProfileStore.instance;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
    _statsController = AnimationController(
      vsync: this,
      duration: _statsAnimDuration,
    );
    _statsCurve = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );
    _statsRevealTimer = Timer(_statsRevealDelay, () {
      if (mounted) _statsController.forward();
    });
  }

  @override
  void dispose() {
    _statsRevealTimer?.cancel();
    _statsController.dispose();
    super.dispose();
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  void _openWalkMode() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Walk02Screen()),
    );
  }

  Future<void> _openAppSwitch() async {
    setState(() => _isAppSwitchOpen = true);

    final guardian = _profile.displayGuardianName;
    final result = await openOnboarding02(
      context,
      selectedApp: OnboardingApp.togedog,
      title: '$guardian 홈',
    );

    if (mounted) setState(() => _isAppSwitchOpen = false);
    if (!mounted || result == null) return;

    if (result == OnboardingApp.thinq) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const MainOnboarding01Screen(),
        ),
        (_) => false,
      );
    }
  }

  void _openPetProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const Mypage02Screen()),
    );
  }

  String _formatSteps(int value) {
    final text = value.toString();
    if (text.length <= 3) return text;
    return '${text.substring(0, text.length - 3)},${text.substring(text.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / Home01Screen.designWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final guardian = _profile.displayGuardianName;
    final petName = _profile.displayPetName;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              _HomeAssets.background,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Image.asset(
                _HomeAssets.backgroundFallback,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      22 * scale,
                      8 * scale,
                      22 * scale,
                      16 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HomeScreenHeader(
                          scale: scale,
                          guardian: guardian,
                          isAppSwitchOpen: _isAppSwitchOpen,
                          onTitleTap: _openAppSwitch,
                        ),
                        SizedBox(height: 20 * scale),
                        _PetStatusCard(
                          scale: scale,
                          petName: petName,
                          petSubtitle: _profile.petSubtitle,
                          statsCurve: _statsCurve,
                          formatSteps: _formatSteps,
                          targetHeartRate: _targetHeartRate,
                          targetSteps: _targetSteps,
                          onPetTap: _openPetProfile,
                        ),
                        SizedBox(height: 20 * scale),
                        _WalkModeCard(
                          scale: scale,
                          petName: petName,
                          onTap: _openWalkMode,
                        ),
                        SizedBox(height: 20 * scale),
                        _HomeCalendar(
                          scale: scale,
                          displayedMonth: _displayedMonth,
                          selectedDate: _selectedDate,
                          onDateSelected: (date) =>
                              setState(() => _selectedDate = date),
                          onPrevMonth: _prevMonth,
                          onNextMonth: _nextMonth,
                        ),
                        SizedBox(height: 100 * scale),
                      ],
                    ),
                  ),
                ),
                AppBottomNav(
                  scale: scale,
                  bottomInset: bottomInset,
                  activeTab: AppTab.home,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScreenHeader extends StatelessWidget {
  const _HomeScreenHeader({
    required this.scale,
    required this.guardian,
    required this.isAppSwitchOpen,
    required this.onTitleTap,
  });

  final double scale;
  final String guardian;
  final bool isAppSwitchOpen;
  final VoidCallback onTitleTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10 * scale),
              child: isAppSwitchOpen
                  ? const SizedBox.shrink()
                  : HomeTitleButton(
                      scale: scale,
                      title: '$guardian 홈',
                      onPressed: onTitleTap,
                    ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10 * scale),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => openNotifications(context),
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

class _PetStatusCard extends StatelessWidget {
  const _PetStatusCard({
    required this.scale,
    required this.petName,
    required this.petSubtitle,
    required this.statsCurve,
    required this.formatSteps,
    required this.targetHeartRate,
    required this.targetSteps,
    required this.onPetTap,
  });

  /// Figma Frame 784: 카드 전체 높이 184 (상단 18 + 콘텐츠 125 + 하단 41)
  static const double cardHeight = 184;
  static const double cardPaddingTop = 18;
  static const double cardPaddingBottom = 41;
  static const double contentHeight = 125;
  /// Figma Frame 773: 심박수·활동량 블록 시작 y=51 (Frame 774 y=-28 + rows y=79)
  static const double liveStatsRowsTop = 51;
  static const double statusSectionGap = 33;

  final double scale;
  final String petName;
  final String petSubtitle;
  final Animation<double> statsCurve;
  final String Function(int value) formatSteps;
  final int targetHeartRate;
  final int targetSteps;
  final VoidCallback onPetTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: cardHeight * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          10 * scale,
          cardPaddingTop * scale,
          17 * scale,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: contentHeight * scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15 * scale),
                          child: Image.asset(
                            _HomeAssets.petPhoto,
                            width: 93 * scale,
                            height: 125 * scale,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              _HomeAssets.petPhotoFallback,
                              width: 93 * scale,
                              height: 125 * scale,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        SizedBox(
                          width: 72 * scale,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: onPetTap,
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        petName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'LGSmartUI',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20 * scale,
                                          color: const Color(0xFF111111),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10 * scale),
                                    _HomeAssets.svg(
                                      _HomeAssets.petChevron,
                                      width: 4 * scale,
                                      height: 9 * scale,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Text(
                                petSubtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'LGSmartUI',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12 * scale,
                                  color: const Color(0xFF828282),
                                ),
                              ),
                              SizedBox(height: statusSectionGap * scale),
                              Text(
                                '상태',
                                style: TextStyle(
                                  fontFamily: 'LGSmartUI',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10 * scale,
                                  color: const Color(0xFF828282),
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6 * scale,
                                  vertical: 4 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F4EB),
                                  borderRadius: BorderRadius.circular(14 * scale),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6 * scale,
                                      height: 6 * scale,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1B9748),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 2 * scale),
                                    Text(
                                      '안정',
                                      style: TextStyle(
                                        fontFamily: 'LGSmartUI',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 8 * scale,
                                        color: const Color(0xFF1B9748),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: liveStatsRowsTop * scale,
                    width: 167 * scale,
                    child: AnimatedBuilder(
                      animation: statsCurve,
                      builder: (context, _) {
                        final heart =
                            (targetHeartRate * statsCurve.value).round();
                        final steps = (targetSteps * statsCurve.value).round();
                        final showValues = statsCurve.value > 0;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _LiveStatRow(
                              scale: scale,
                              circleAsset: _HomeAssets.heartCircle,
                              iconAsset: _HomeAssets.heartIcon,
                              iconSize: 16 * scale,
                              chart: _HeartChart(scale: scale),
                              label: '심박수',
                              value: showValues ? '$heart' : '–',
                              unit: 'bpm',
                            ),
                            SizedBox(height: 20 * scale),
                            _LiveStatRow(
                              scale: scale,
                              circleAsset: _HomeAssets.activityCircle,
                              iconAsset: _HomeAssets.activityIcon,
                              chart: _ActivityChart(scale: scale),
                              label: '활동량',
                              value: showValues ? formatSteps(steps) : '–',
                              unit: '걸음',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: cardPaddingBottom * scale),
          ],
        ),
      ),
    );
  }
}

class _LiveStatRow extends StatelessWidget {
  const _LiveStatRow({
    required this.scale,
    required this.circleAsset,
    required this.iconAsset,
    required this.chart,
    required this.label,
    required this.value,
    required this.unit,
    this.iconSize,
  });

  final double scale;
  final String circleAsset;
  final String iconAsset;
  final Widget chart;
  final String label;
  final String value;
  final String unit;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 167 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 32 * scale,
            height: 32 * scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _HomeAssets.svg(circleAsset, width: 32 * scale, height: 32 * scale),
                _HomeAssets.svg(
                  iconAsset,
                  width: iconSize ?? 20 * scale,
                  height: iconSize ?? 20 * scale,
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 10 * scale,
                    color: const Color(0xFF828282),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w600,
                          fontSize: 18 * scale,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(width: 2 * scale),
                      Text(
                        unit,
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w600,
                          fontSize: 10 * scale,
                          color: const Color(0xFF828282),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          chart,
        ],
      ),
    );
  }
}

class _HeartChart extends StatelessWidget {
  const _HeartChart({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39 * scale,
      height: 33 * scale,
      padding: EdgeInsets.symmetric(horizontal: 1 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6 * scale),
        color: _HomeAssets.heartCircleColor,
      ),
      child: _HomeAssets.svg(
        _HomeAssets.heartChart,
        width: 37 * scale,
        height: 21 * scale,
      ),
    );
  }
}

class _ActivityChart extends StatelessWidget {
  const _ActivityChart({required this.scale});
  final double scale;

  /// Figma Frame 763: 39×33, 배경은 활동량 아이콘 원과 동일 단색
  static const double chartHeight = 33;
  static const double _plotHeight = 22.751;

  static const List<({double left, double top, double height})> _bars = [
    (left: 0, top: 17.74, height: 5),
    (left: 6, top: 13.74, height: 9),
    (left: 11.85, top: 6.06, height: 16.664),
    (left: 17.89, top: 10.3, height: 12.426),
    (left: 23.93, top: 14.87, height: 7.852),
    (left: 29.79, top: 0, height: 22.725),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39 * scale,
      height: chartHeight * scale,
      padding: EdgeInsets.symmetric(horizontal: 3 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6 * scale),
        color: _HomeAssets.activityCircleColor,
      ),
      child: SizedBox(
        height: _plotHeight * scale,
        width: 33 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (final bar in _bars)
              Positioned(
                left: bar.left * scale,
                top: bar.top * scale,
                child: Container(
                  width: 3 * scale,
                  height: bar.height * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.5 * scale),
                    color: const Color(0xFF8756E7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WalkModeCard extends StatelessWidget {
  const _WalkModeCard({
    required this.scale,
    required this.petName,
    required this.onTap,
  });

  final double scale;
  final String petName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 115 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 6 * scale,
              height: 105 * scale,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1FF),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
              ),
            ),
            Positioned(
              right: 7 * scale,
              top: 0,
              width: 191 * scale,
              height: 115 * scale,
              child: Image.asset(
                _HomeAssets.walkCard,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 17 * scale,
              top: 27 * scale,
              right: 160 * scale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '산책 모드 시작',
                        style: TextStyle(
                          fontFamily: 'LGSmartUI',
                          fontWeight: FontWeight.w600,
                          fontSize: 18 * scale,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      _HomeAssets.svg(
                        _HomeAssets.petChevron,
                        width: 4 * scale,
                        height: 9 * scale,
                      ),
                    ],
                  ),
                  SizedBox(height: 9 * scale),
                  Text(
                    'AI가 주변 위험을 감지하고\n$petName의 상태를 모니터링해요',
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w400,
                      fontSize: 10 * scale,
                      height: 1.35,
                      color: const Color(0xFF111111),
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

class _HomeCalendar extends StatelessWidget {
  const _HomeCalendar({
    required this.scale,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  final double scale;
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    final cells = _buildMonthCells(displayedMonth);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10 * scale, horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 20)),
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 280 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CalendarNavButton(scale: scale, icon: Icons.chevron_left, onTap: onPrevMonth),
                Text(
                  '${displayedMonth.month}월',
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * scale,
                    color: const Color(0xFF404040),
                  ),
                ),
                _CalendarNavButton(scale: scale, icon: Icons.chevron_right, onTap: onNextMonth),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          _CalendarWeekdayRow(scale: scale),
          SizedBox(height: 4 * scale),
          for (var row = 0; row < cells.length ~/ 7; row++)
            _CalendarDateRow(
              scale: scale,
              week: cells.sublist(row * 7, row * 7 + 7),
              displayedMonth: displayedMonth,
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
            ),
        ],
      ),
    );
  }

  List<_CalendarDay> _buildMonthCells(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7;
    final cells = <_CalendarDay>[];

    final prevMonthDays = DateTime(month.year, month.month, 0).day;
    for (var i = startWeekday - 1; i >= 0; i--) {
      cells.add(_CalendarDay(day: prevMonthDays - i, inMonth: false));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(_CalendarDay(day: d, inMonth: true));
    }
    var nextDay = 1;
    while (cells.length < 42) {
      cells.add(_CalendarDay(day: nextDay++, inMonth: false));
    }
    return cells;
  }
}

class _CalendarDay {
  const _CalendarDay({required this.day, required this.inMonth});
  final int day;
  final bool inMonth;
}

class _CalendarDateRow extends StatelessWidget {
  const _CalendarDateRow({
    required this.scale,
    required this.week,
    required this.displayedMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final double scale;
  final List<_CalendarDay> week;
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  bool _inDemoRange(_CalendarDay cell) {
    return displayedMonth.month == 6 &&
        cell.inMonth &&
        cell.day >= 6 &&
        cell.day <= 12;
  }

  @override
  Widget build(BuildContext context) {
    int? rangeStart;
    int? rangeEnd;
    for (var i = 0; i < week.length; i++) {
      if (_inDemoRange(week[i])) {
        rangeStart ??= i;
        rangeEnd = i;
      }
    }

    final cellSize = 40 * scale;

    return Padding(
      padding: EdgeInsets.only(bottom: 4 * scale),
      child: SizedBox(
        width: 280 * scale,
        height: cellSize,
        child: Stack(
          children: [
            if (rangeStart != null && rangeEnd != null)
              Positioned(
                left: rangeStart * cellSize,
                width: (rangeEnd - rangeStart + 1) * cellSize,
                top: 0,
                height: cellSize,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EAFF),
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(20 * scale),
                      right: Radius.circular(20 * scale),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                for (var i = 0; i < week.length; i++)
                  _CalendarDayCell(
                    scale: scale,
                    day: week[i],
                    displayedMonth: displayedMonth,
                    selectedDate: selectedDate,
                    inRange: _inDemoRange(week[i]),
                    onTap: week[i].inMonth
                        ? () => onDateSelected(
                              DateTime(
                                displayedMonth.year,
                                displayedMonth.month,
                                week[i].day,
                              ),
                            )
                        : null,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    required this.scale,
    required this.icon,
    required this.onTap,
  });

  final double scale;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(10 * scale),
        child: Icon(icon, size: 20 * scale, color: const Color(0xFF404040)),
      ),
    );
  }
}

class _CalendarWeekdayRow extends StatelessWidget {
  const _CalendarWeekdayRow({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final label in labels)
          SizedBox(
            width: 40 * scale,
            height: 40 * scale,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w400,
                  fontSize: 14 * scale,
                  color: const Color(0xFF404040),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.scale,
    required this.day,
    required this.displayedMonth,
    required this.selectedDate,
    required this.inRange,
    this.onTap,
  });

  final double scale;
  final _CalendarDay day;
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final bool inRange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = day.inMonth &&
        selectedDate != null &&
        selectedDate!.year == displayedMonth.year &&
        selectedDate!.month == displayedMonth.month &&
        selectedDate!.day == day.day;

    final isMutedSpot =
        day.inMonth && displayedMonth.month == 6 && day.day == 25 && !isSelected;

    Color? bg;
    Color textColor = day.inMonth ? const Color(0xFF404040) : const Color(0xFF737373);
    FontWeight fontWeight = FontWeight.w400;

    if (isSelected) {
      bg = const Color(0xFF8756E7);
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
    } else if (inRange) {
      textColor = const Color(0xFF8756E7);
    } else if (isMutedSpot) {
      bg = const Color(0xFFF5F5F5);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40 * scale,
        height: 40 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: isSelected || isMutedSpot ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isSelected || isMutedSpot ? null : BorderRadius.zero,
        ),
        child: Text(
          '${day.day}',
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: fontWeight,
            fontSize: 14 * scale,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
