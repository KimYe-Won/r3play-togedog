// 리포트 화면 공통 — Figma 696:7524 / 724:6506
import 'package:flutter/material.dart';

import 'togedog_accessibility.dart';

/// 리포트 화면 배경 (walk_01과 동일)
const Color kReportScreenBackground = Color(0xFFF8F5FF);

class ReportAssets {
  static const safety = 'assets/report/report_safety.svg';
  static const statusPet = 'assets/report/report_status_pet.png';
  static const heartMetric = 'assets/report/report_heart_metric.svg';
  static const sleepMetric = 'assets/report/report_sleep_icon.svg';
  static const activityMetric = 'assets/report/report_activity_metric.svg';
  static const mealMetric = 'assets/report/report_meal_icon.svg';
  static const aiDog = 'assets/report/report_ai_dog.png';
  static const walkPaw = 'assets/report/report_walk_paw.svg';
  static const dangerCheck = 'assets/report/report_danger_check.svg';
  static const dangerMap = 'assets/report/report_danger_map.png';

  static const weeklyPet = 'assets/report/report_weekly_pet.png';
  static const weeklyPetGlow = 'assets/report/report_weekly_pet_glow.svg';
  static const weeklySummaryIllus = 'assets/report/report_weekly_summary_illus.png';
  static const weeklyChartGrid = 'assets/report/report_weekly_chart_grid.svg';
  static const weeklyLegendThis = 'assets/report/report_weekly_legend_this.svg';
  static const weeklyLegendLast = 'assets/report/report_weekly_legend_last.svg';
  static const weeklyCheck = 'assets/report/report_weekly_check.svg';

  static const monthlyPet = 'assets/report/report_monthly_pet.png';
  static const monthlyWalk = 'assets/report/report_monthly_walk.svg';
  static const monthlyClock = 'assets/report/report_monthly_clock.svg';
  static const monthlyDistancePaw = 'assets/report/report_monthly_distance_paw.svg';
  static const monthlyDistancePin = 'assets/report/report_monthly_distance_pin.svg';
  static const monthlyDanger = 'assets/report/report_monthly_danger.svg';
  static const monthlyLegendWalk = 'assets/report/report_monthly_legend_walk.svg';
  static const monthlyLegendDanger = 'assets/report/report_monthly_legend_danger.svg';
  static const monthlyChevronLeft = 'assets/report/report_monthly_chevron_left.svg';
  static const monthlyChevronRight = 'assets/report/report_monthly_chevron_right.svg';
}

/// 카드 내부 콘텐츠 왼쪽 여백
const double kReportCardContentLeft = 14;

/// 오늘 리포트 — 상태 카드 반려견 이미지 (Figma Layer 8 2)
const double kDailyStatusPetLeft = 198;
const double kDailyStatusPetWidth = 166;
const double kDailyStatusPetHeight = 162;

/// 주간 리포트 — 상태 카드 (Figma 740:6417 / 740:6418)
const double kWeeklyStatusPetLeft = 182;
const double kWeeklyStatusPetTop = 16;
const double kWeeklyStatusPetWidth = 175;
const double kWeeklyStatusPetHeight = 132;
const double kWeeklyStatusPetGlowLeft = 206;
const double kWeeklyStatusPetGlowTop = 8;
const double kWeeklyStatusPetGlowSize = 144;

const List<String> kReportTabLabels = ['오늘의 리포트', '주간 리포트', '월간 리포트'];

/// 월별 리포트 데모 데이터 (home_01 달력과 report_03 공유)
class MonthlyReportData {
  const MonthlyReportData({
    required this.walkCount,
    required this.totalWalkMinutes,
    required this.distanceKm,
    required this.dangerCount,
    required this.walkDays,
  });

  final int walkCount;
  final int totalWalkMinutes;
  final double distanceKm;
  final int dangerCount;
  final Set<int> walkDays;

  int get walkHours => totalWalkMinutes ~/ 60;
  int get walkMinutesRemainder => totalWalkMinutes % 60;

  String get distanceLabel =>
      distanceKm == distanceKm.roundToDouble() ? distanceKm.toStringAsFixed(0) : distanceKm.toStringAsFixed(1);
}

MonthlyReportData monthlyReportDataFor(DateTime month) {
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final seed = month.year * 12 + month.month;

  if (month.month == 6) {
    const walkCount = 8;
    return MonthlyReportData(
      walkCount: walkCount,
      totalWalkMinutes: 9 * 60 + 45,
      distanceKm: 94.8,
      dangerCount: 18,
      walkDays: {for (var d = 6; d <= 13; d++) d},
    );
  }

  final walkCount = (3 + seed % 10).clamp(0, daysInMonth);
  final walkDays = _pickWalkDays(month.year, month.month, walkCount);
  final minutesPerWalk = 55 + (seed % 40);
  final totalWalkMinutes = walkCount * minutesPerWalk;
  final distanceKm = double.parse((walkCount * (9.5 + (seed % 15) / 10)).toStringAsFixed(1));
  final dangerCount = walkCount == 0 ? 0 : (walkCount * (1 + seed % 3));

  return MonthlyReportData(
    walkCount: walkCount,
    totalWalkMinutes: totalWalkMinutes,
    distanceKm: distanceKm,
    dangerCount: dangerCount,
    walkDays: walkDays.toSet(),
  );
}

List<int> _pickWalkDays(int year, int month, int count) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final n = count.clamp(0, daysInMonth);
  if (n == 0) return [];

  final result = <int>[];
  final gap = daysInMonth / (n + 1);
  for (var i = 0; i < n; i++) {
    var day = (gap * (i + 1)).round().clamp(1, daysInMonth);
    while (result.contains(day) && day < daysInMonth) {
      day++;
    }
    if (day <= daysInMonth) result.add(day);
  }
  for (var d = 1; result.length < n && d <= daysInMonth; d++) {
    if (!result.contains(d)) result.add(d);
  }
  result.sort();
  return result;
}

TextStyle reportFont(
  double scale, {
  required double size,
  FontWeight weight = FontWeight.w600,
  Color color = const Color(0xFF1A1A1A),
  double? height,
}) {
  return TextStyle(
    fontFamily: 'LGSmartUI',
    fontWeight: weight,
    fontSize: size * scale,
    color: color,
    height: height,
  );
}

class ReportTabBar extends StatelessWidget {
  const ReportTabBar({
    super.key,
    required this.scale,
    required this.selected,
    required this.onChanged,
  });

  final double scale;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / kReportTabLabels.length;
        final indicatorWidth = 97 * scale;
        final indicatorLeft = 4 * scale + selected * tabWidth + (tabWidth - indicatorWidth) / 2;

        return Container(
          height: 37 * scale,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: indicatorLeft.clamp(
                  4 * scale,
                  constraints.maxWidth - indicatorWidth - 4 * scale,
                ),
                top: 4 * scale,
                child: Container(
                  width: indicatorWidth,
                  height: 29 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8756E7),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                ),
              ),
              Row(
                children: List.generate(kReportTabLabels.length, (i) {
                  return Expanded(
                    child: TogedogA11y.button(
                      label: kReportTabLabels[i],
                      selected: selected == i,
                      child: GestureDetector(
                        onTap: () => onChanged(i),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            kReportTabLabels[i],
                            style: reportFont(
                              scale,
                              size: 11,
                              color: selected == i ? Colors.white : const Color(0xFF6A6A6A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
