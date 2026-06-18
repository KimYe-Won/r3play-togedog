// TogeDog 월간 리포트 — Figma node 625:6379
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'report_shared.dart';
import 'togedog_accessibility.dart';

/// 월간 리포트 본문 (탭 인덱스 2)
class Report03Body extends StatefulWidget {
  const Report03Body({super.key, required this.scale});

  final double scale;

  @override
  State<Report03Body> createState() => _Report03BodyState();
}

class _Report03BodyState extends State<Report03Body> {
  late DateTime _displayedMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
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

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final report = monthlyReportDataFor(_displayedMonth);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthlyMonthSelector(
          scale: scale,
          month: _displayedMonth.month,
          onPrev: _prevMonth,
          onNext: _nextMonth,
        ),
        SizedBox(height: 10 * scale),
        _MonthlySummaryCard(scale: scale, report: report),
        SizedBox(height: 10 * scale),
        _MonthlyCalendarCard(
          scale: scale,
          displayedMonth: _displayedMonth,
          walkDays: report.walkDays,
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        SizedBox(height: 10 * scale),
        _MonthlyAiAnalysisCard(scale: scale, report: report),
      ],
    );
  }
}

class _MonthlyMonthSelector extends StatelessWidget {
  const _MonthlyMonthSelector({
    required this.scale,
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final double scale;
  final int month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onPrev,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(10 * scale),
              child: TogedogAssets.svg(
                ReportAssets.monthlyChevronLeft,
                width: 20 * scale,
                height: 20 * scale,
              ),
            ),
          ),
          SizedBox(width: 40 * scale),
          Text(
            '$month월',
            style: reportFont(
              scale,
              size: 16,
              color: const Color(0xFF404040),
              height: 24 / 16,
            ),
          ),
          SizedBox(width: 40 * scale),
          GestureDetector(
            onTap: onNext,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(10 * scale),
              child: TogedogAssets.svg(
                ReportAssets.monthlyChevronRight,
                width: 20 * scale,
                height: 20 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.scale,
    required this.report,
  });

  final double scale;
  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 83 * scale,
      padding: EdgeInsets.fromLTRB(29 * scale, 12 * scale, 24 * scale, 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Row(
        children: [
          Expanded(child: _SummaryMetric(
            scale: scale,
            icon: TogedogAssets.svg(
              ReportAssets.monthlyWalk,
              width: 17 * scale,
              height: 17 * scale,
            ),
            label: '총 산책 횟수',
            value: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${report.walkCount} ',
                    style: reportFont(scale, size: 12),
                  ),
                  TextSpan(
                    text: '회',
                    style: reportFont(
                      scale,
                      size: 8,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
          )),
          _SummaryDivider(scale: scale),
          Expanded(child: _SummaryMetric(
            scale: scale,
            icon: TogedogAssets.svg(
              ReportAssets.monthlyClock,
              width: 19 * scale,
              height: 19 * scale,
            ),
            label: '총 산책 시간',
            value: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${report.walkHours}',
                    style: reportFont(scale, size: 12),
                  ),
                  TextSpan(
                    text: '시간 ',
                    style: reportFont(
                      scale,
                      size: 8,
                      color: const Color(0xFF828282),
                    ),
                  ),
                  TextSpan(
                    text: '${report.walkMinutesRemainder}',
                    style: reportFont(scale, size: 12),
                  ),
                  TextSpan(
                    text: '분',
                    style: reportFont(
                      scale,
                      size: 8,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
          )),
          _SummaryDivider(scale: scale),
          Expanded(child: _SummaryMetric(
            scale: scale,
            icon: SizedBox(
              width: 14.25 * scale,
              height: 19 * scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  TogedogAssets.svg(
                    ReportAssets.monthlyDistancePin,
                    width: 14.25 * scale,
                    height: 19 * scale,
                  ),
                  Positioned(
                    left: 2.62 * scale,
                    top: 4 * scale,
                    child: TogedogAssets.svg(
                      ReportAssets.monthlyDistancePaw,
                      width: 9.061 * scale,
                      height: 7.405 * scale,
                    ),
                  ),
                ],
              ),
            ),
            label: '총 산책 거리',
            value: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: report.distanceLabel,
                    style: reportFont(scale, size: 12),
                  ),
                  TextSpan(
                    text: ' km',
                    style: reportFont(
                      scale,
                      size: 8,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
          )),
          _SummaryDivider(scale: scale),
          Expanded(child: _SummaryMetric(
            scale: scale,
            icon: TogedogAssets.svg(
              ReportAssets.monthlyDanger,
              width: 19 * scale,
              height: 19 * scale,
            ),
            label: '위험 감지',
            value: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${report.dangerCount}',
                    style: reportFont(scale, size: 12),
                  ),
                  TextSpan(
                    text: ' 회',
                    style: reportFont(
                      scale,
                      size: 8,
                      color: const Color(0xFF828282),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 15 * scale,
      margin: EdgeInsets.symmetric(horizontal: 12 * scale),
      color: const Color(0xFFE8E8EC),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
  });

  final double scale;
  final Widget icon;
  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        SizedBox(height: 9 * scale),
        Text(
          label,
          textAlign: TextAlign.center,
          style: reportFont(
            scale,
            size: 8,
            color: const Color(0xFF828282),
          ),
        ),
        SizedBox(height: 4 * scale),
        value,
      ],
    );
  }
}

class _MonthlyCalendarCard extends StatelessWidget {
  const _MonthlyCalendarCard({
    required this.scale,
    required this.displayedMonth,
    required this.walkDays,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final double scale;
  final DateTime displayedMonth;
  final Set<int> walkDays;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final cells = _buildMonthCells(displayedMonth);
    final now = DateTime.now();
    final todayInMonth = displayedMonth.year == now.year &&
        displayedMonth.month == now.month;

    return Container(
      padding: EdgeInsets.fromLTRB(24 * scale, 20 * scale, 24 * scale, 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendItem(
                scale: scale,
                dotAsset: ReportAssets.monthlyLegendWalk,
                label: '산책 기록',
              ),
              SizedBox(width: 13 * scale),
              _LegendItem(
                scale: scale,
                dotAsset: ReportAssets.monthlyLegendDanger,
                label: '위험 감지',
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          _WeekdayHeaderRow(scale: scale),
          SizedBox(height: 4 * scale),
          for (var row = 0; row < cells.length ~/ 7; row++)
            _MonthDateRow(
              scale: scale,
              week: cells.sublist(row * 7, row * 7 + 7),
              displayedMonth: displayedMonth,
              walkDays: walkDays,
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
              todayInMonth: todayInMonth,
              todayDay: now.day,
            ),
        ],
      ),
    );
  }

  List<_MonthDay> _buildMonthCells(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7;
    final cells = <_MonthDay>[];

    final prevMonthDays = DateTime(month.year, month.month, 0).day;
    for (var i = startWeekday - 1; i >= 0; i--) {
      cells.add(_MonthDay(day: prevMonthDays - i, inMonth: false));
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(_MonthDay(day: d, inMonth: true));
    }
    var nextDay = 1;
    while (cells.length < 42) {
      cells.add(_MonthDay(day: nextDay++, inMonth: false));
    }
    return cells;
  }
}

class _MonthDay {
  const _MonthDay({required this.day, required this.inMonth});
  final int day;
  final bool inMonth;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.scale,
    required this.dotAsset,
    required this.label,
  });

  final double scale;
  final String dotAsset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TogedogAssets.svg(
          dotAsset,
          width: 6 * scale,
          height: 6 * scale,
        ),
        SizedBox(width: 5 * scale),
        Text(
          label,
          style: reportFont(
            scale,
            size: 8,
            color: const Color(0xFF828282),
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeaderRow extends StatelessWidget {
  const _WeekdayHeaderRow({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: SizedBox(
              height: 40 * scale,
              child: Center(
                child: Text(
                  label,
                  style: reportFont(
                    scale,
                    size: 14,
                    weight: FontWeight.w400,
                    color: const Color(0xFF404040),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthDateRow extends StatelessWidget {
  const _MonthDateRow({
    required this.scale,
    required this.week,
    required this.displayedMonth,
    required this.walkDays,
    required this.selectedDate,
    required this.onDateSelected,
    required this.todayInMonth,
    required this.todayDay,
  });

  final double scale;
  final List<_MonthDay> week;
  final DateTime displayedMonth;
  final Set<int> walkDays;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool todayInMonth;
  final int todayDay;

  bool _isWalkDay(_MonthDay cell) {
    return cell.inMonth && walkDays.contains(cell.day);
  }

  List<(int start, int end)> _walkRangesInWeek() {
    final ranges = <(int, int)>[];
    int? start;
    for (var i = 0; i < week.length; i++) {
      if (_isWalkDay(week[i])) {
        start ??= i;
      } else if (start != null) {
        ranges.add((start, i - 1));
        start = null;
      }
    }
    if (start != null) ranges.add((start, week.length - 1));
    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    final ranges = _walkRangesInWeek();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        return SizedBox(
          height: 40 * scale,
          child: Stack(
            children: [
              for (final range in ranges)
                Positioned(
                  left: range.$1 * cellWidth,
                  width: (range.$2 - range.$1 + 1) * cellWidth,
                  top: 0,
                  height: 40 * scale,
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
                    Expanded(
                      child: _MonthDayCell(
                        scale: scale,
                        day: week[i],
                        displayedMonth: displayedMonth,
                        selectedDate: selectedDate,
                        isWalkDay: _isWalkDay(week[i]),
                        isTodaySpot: todayInMonth &&
                            week[i].inMonth &&
                            week[i].day == todayDay,
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
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.scale,
    required this.day,
    required this.displayedMonth,
    required this.selectedDate,
    required this.isWalkDay,
    required this.isTodaySpot,
    this.onTap,
  });

  final double scale;
  final _MonthDay day;
  final DateTime displayedMonth;
  final DateTime? selectedDate;
  final bool isWalkDay;
  final bool isTodaySpot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = day.inMonth &&
        selectedDate != null &&
        selectedDate!.year == displayedMonth.year &&
        selectedDate!.month == displayedMonth.month &&
        selectedDate!.day == day.day;

    Color? bg;
    var textColor = day.inMonth ? const Color(0xFF404040) : const Color(0xFF737373);
    var fontWeight = FontWeight.w400;
    BoxShape shape = BoxShape.rectangle;
    BorderRadius? borderRadius;

    if (isSelected) {
      bg = const Color(0xFF8756E7);
      textColor = Colors.white;
      fontWeight = FontWeight.w600;
      shape = BoxShape.circle;
    } else if (isWalkDay) {
      textColor = const Color(0xFF8756E7);
      borderRadius = BorderRadius.circular(20 * scale);
    } else if (isTodaySpot) {
      bg = const Color(0xFFF5F5F5);
      shape = BoxShape.circle;
    } else {
      borderRadius = BorderRadius.circular(20 * scale);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: shape,
          borderRadius: shape == BoxShape.circle ? null : borderRadius,
        ),
        child: Text(
          '${day.day}',
          style: reportFont(
            scale,
            size: 14,
            weight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _MonthlyAiAnalysisCard extends StatelessWidget {
  const _MonthlyAiAnalysisCard({
    required this.scale,
    required this.report,
  });

  final double scale;
  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 145 * scale,
      padding: EdgeInsets.fromLTRB(12 * scale, 15 * scale, 12 * scale, 15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text('AI 월간 분석', style: reportFont(scale, size: 12)),
              const Spacer(),
              Text(
                '상세 보기',
                style: reportFont(
                  scale,
                  size: 9,
                  color: const Color(0xFF8756E7),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 12 * scale,
                color: const Color(0xFF8756E7),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  ReportAssets.monthlyPet,
                  width: 106 * scale,
                  height: 70 * scale,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    TogedogAssets.petPhoto,
                    width: 106 * scale,
                    height: 70 * scale,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 24 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지난달보다 산책 시간이 늘었어요',
                        style: reportFont(
                          scale,
                          size: 15,
                          weight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5 * scale),
                      Text(
                        '위험 상황은 ${report.dangerCount}회 감지되었고,\n'
                        '모두 안전하게 회피했어요.\n'
                        '다음 달도 꾸준히 산책해요!',
                        style: reportFont(
                          scale,
                          size: 10,
                          weight: FontWeight.w400,
                          color: const Color(0xFF6A6A6A),
                          height: 1.35,
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
    );
  }
}

/// 독립 화면 진입점 (탭 셸 없이 단독 표시 시)
class Report03Screen extends StatelessWidget {
  const Report03Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    return TogedogA11y.screen(
      name: '월간 리포트',
      child: Scaffold(
      backgroundColor: kReportScreenBackground,
      body: DefaultTextStyle(
        style: reportFont(scale, size: 12),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            23 * scale,
            8 * scale,
            23 * scale,
            16 * scale,
          ),
          child: Report03Body(scale: scale),
        ),
      ),
    ),
    );
  }
}
