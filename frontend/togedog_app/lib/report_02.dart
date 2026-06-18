// TogeDog 주간 리포트 — Figma node 724:6506
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'report_shared.dart';
import 'togedog_accessibility.dart';

/// 주간 리포트 본문 (탭 인덱스 1)
class Report02Body extends StatelessWidget {
  const Report02Body({
    super.key,
    required this.scale,
    required this.petName,
  });

  final double scale;
  final String petName;

  static String weekOfMonthLabel() {
    final now = DateTime.now();
    final week = ((now.day - 1) / 7).floor() + 1;
    const ordinals = ['첫', '둘', '셋', '넷', '다섯'];
    final ordinal = week <= ordinals.length ? ordinals[week - 1] : '$week';
    final month = now.month;
    return '$month월 $ordinal째주';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeeklyStatusCard(
          scale: scale,
          weekLabel: weekOfMonthLabel(),
          petName: petName,
        ),
        SizedBox(height: 10 * scale),
        _WeeklyHealthSummaryCard(scale: scale),
        SizedBox(height: 10 * scale),
        _WeeklyActivityChartCard(scale: scale),
        SizedBox(height: 10 * scale),
        _WeeklyAnomalyCard(scale: scale),
      ],
    );
  }
}

class _WeeklyStatusCard extends StatelessWidget {
  const _WeeklyStatusCard({
    required this.scale,
    required this.weekLabel,
    required this.petName,
  });

  final double scale;
  final String weekLabel;
  final String petName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            left: kReportCardContentLeft * scale,
            top: 20 * scale,
            child: Text(
              weekLabel,
              style: reportFont(
                scale,
                size: 11,
                color: const Color(0xFF8756E7),
              ),
            ),
          ),
          Positioned(
            left: kReportCardContentLeft * scale,
            top: 41 * scale,
            child: Text(
              '이번주 $petName 상태',
              style: reportFont(
                scale,
                size: 18,
                weight: FontWeight.w700,
                color: const Color(0xFF111111),
              ),
            ),
          ),
          Positioned(
            left: kReportCardContentLeft * scale,
            top: 79 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TogedogAssets.svg(
                  ReportAssets.safety,
                  width: 24 * scale,
                  height: 24 * scale,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '안정',
                  style: reportFont(
                    scale,
                    size: 20,
                    color: const Color(0xFF1CA24E),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: kReportCardContentLeft * scale,
            top: 110 * scale,
            child: Text(
              '특별한 이상 징후가 없어요.',
              style: reportFont(
                scale,
                size: 12,
                color: const Color(0xFF6A6A6A),
              ),
            ),
          ),
          Positioned(
            left: kWeeklyStatusPetGlowLeft * scale,
            top: kWeeklyStatusPetGlowTop * scale,
            width: kWeeklyStatusPetGlowSize * scale,
            height: kWeeklyStatusPetGlowSize * scale,
            child: TogedogAssets.svg(
              ReportAssets.weeklyPetGlow,
              width: kWeeklyStatusPetGlowSize * scale,
              height: kWeeklyStatusPetGlowSize * scale,
            ),
          ),
          Positioned(
            left: kWeeklyStatusPetLeft * scale,
            top: kWeeklyStatusPetTop * scale,
            width: kWeeklyStatusPetWidth * scale,
            height: kWeeklyStatusPetHeight * scale,
            child: Image.asset(
              ReportAssets.weeklyPet,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => Image.asset(
                TogedogAssets.petPhoto,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyHealthSummaryCard extends StatelessWidget {
  const _WeeklyHealthSummaryCard({required this.scale});

  final double scale;

  /// 아래 요일별 활동량 차트(이번 주 막대) 기준 일평균 환산값
  static const _avgDailySteps = 7068;
  static const _avgHeartRate = 91;
  static const _avgSleepHours = 8;
  static const _avgSleepMinutes = 5;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8 * scale, 15 * scale, 8 * scale, 15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5 * scale),
            child: Text('주간 건강 요약', style: reportFont(scale, size: 12)),
          ),
          SizedBox(height: 9 * scale),
          Row(
            children: [
              Expanded(
                child: _WeeklyHealthMetric(
                  scale: scale,
                  icon: TogedogAssets.svg(
                    ReportAssets.heartMetric,
                    width: 36 * scale,
                    height: 36 * scale,
                  ),
                  label: '심박수',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_avgHeartRate',
                          style: reportFont(scale, size: 16),
                        ),
                        TextSpan(
                          text: ' bpm',
                          style: reportFont(
                            scale,
                            size: 10,
                            color: const Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badge: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '▼2 ',
                          style: reportFont(
                            scale,
                            size: 10,
                            weight: FontWeight.w400,
                            color: const Color(0xFF5684E7),
                          ),
                        ),
                        TextSpan(
                          text: 'bpm',
                          style: reportFont(
                            scale,
                            size: 8,
                            weight: FontWeight.w400,
                            color: const Color(0xFF5684E7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badgeBg: const Color(0xFFEAF2FF),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _WeeklyHealthMetric(
                  scale: scale,
                  icon: TogedogAssets.svg(
                    ReportAssets.sleepMetric,
                    width: 36 * scale,
                    height: 36 * scale,
                  ),
                  label: '수면',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(text: '$_avgSleepHours', style: reportFont(scale, size: 16)),
                        TextSpan(
                          text: '시간',
                          style: reportFont(
                            scale,
                            size: 10,
                            color: const Color(0xFF828282),
                          ),
                        ),
                        TextSpan(
                          text: _avgSleepMinutes.toString().padLeft(2, '0'),
                          style: reportFont(scale, size: 16),
                        ),
                        TextSpan(
                          text: '분',
                          style: reportFont(
                            scale,
                            size: 10,
                            color: const Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badge: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '▲25',
                          style: reportFont(
                            scale,
                            size: 10,
                            weight: FontWeight.w400,
                            color: const Color(0xFFFE709A),
                          ),
                        ),
                        TextSpan(
                          text: '분',
                          style: reportFont(
                            scale,
                            size: 8,
                            weight: FontWeight.w400,
                            color: const Color(0xFFFE709A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badgeBg: const Color(0xFFFBE5EC),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _WeeklyHealthMetric(
                  scale: scale,
                  icon: TogedogAssets.svg(
                    ReportAssets.activityMetric,
                    width: 36 * scale,
                    height: 36 * scale,
                  ),
                  label: '활동량',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatSteps(_avgDailySteps),
                          style: reportFont(scale, size: 16),
                        ),
                        TextSpan(
                          text: '걸음',
                          style: reportFont(
                            scale,
                            size: 10,
                            color: const Color(0xFF828282),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badge: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '▲18',
                          style: reportFont(
                            scale,
                            size: 10,
                            weight: FontWeight.w400,
                            color: const Color(0xFFFE709A),
                          ),
                        ),
                        TextSpan(
                          text: '%',
                          style: reportFont(
                            scale,
                            size: 8,
                            weight: FontWeight.w400,
                            color: const Color(0xFFFE709A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badgeBg: const Color(0xFFFBE5EC),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _WeeklyHealthMetric(
                  scale: scale,
                  icon: TogedogAssets.svg(
                    ReportAssets.mealMetric,
                    width: 36 * scale,
                    height: 36 * scale,
                  ),
                  label: '식사',
                  value: Text(
                    '좋음',
                    textAlign: TextAlign.center,
                    style: reportFont(scale, size: 16),
                  ),
                  badge: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '▲5',
                          style: reportFont(
                            scale,
                            size: 10,
                            weight: FontWeight.w400,
                            color: const Color(0xFFFE709A),
                          ),
                        ),
                        TextSpan(
                          text: '%',
                          style: reportFont(
                            scale,
                            size: 8,
                            weight: FontWeight.w400,
                            color: const Color(0xFFFE709A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  badgeBg: const Color(0xFFFBE5EC),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatSteps(int steps) {
    final s = steps.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _WeeklyHealthMetric extends StatelessWidget {
  const _WeeklyHealthMetric({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeBg,
  });

  final double scale;
  final Widget icon;
  final String label;
  final Widget value;
  final Widget badge;
  final Color badgeBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135 * scale,
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 13 * scale),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF4F4F8)),
        borderRadius: BorderRadius.circular(6 * scale),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: reportFont(
              scale,
              size: 10,
              color: const Color(0xFF828282),
            ),
          ),
          SizedBox(height: 4 * scale),
          value,
          const Spacer(),
          Container(
            height: 19 * scale,
            padding: EdgeInsets.symmetric(horizontal: 6 * scale),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(32.5 * scale),
            ),
            alignment: Alignment.center,
            child: badge,
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChartCard extends StatelessWidget {
  const _WeeklyActivityChartCard({required this.scale});

  final double scale;

  static const _yTickLabels = ['12,000', '9,000', '6,000', '3,000', '0'];
  static const _dayLabels = ['일', '월', '화', '수', '목', '금', '토'];

  /// Figma 724:6651–6670 — [이번 주, 지난 주] bar heights
  static const _barPairs = [
    (26.0, 35.0),
    (40.0, 35.0),
    (22.0, 42.0),
    (32.0, 33.0),
    (30.0, 35.0),
    (57.0, 41.0),
    (28.0, 35.0),
  ];

  static const _maxBarHeight = 57.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 173 * scale,
      padding: EdgeInsets.fromLTRB(9 * scale, 17 * scale, 9 * scale, 12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 3 * scale),
                child: Text('요일별 활동량', style: reportFont(scale, size: 12)),
              ),
              const Spacer(),
              _ChartLegendItem(
                scale: scale,
                label: '이번 주',
                dotAsset: ReportAssets.weeklyLegendThis,
                dotColor: const Color(0xFF8756E7),
              ),
              SizedBox(width: 13 * scale),
              _ChartLegendItem(
                scale: scale,
                label: '지난 주',
                dotAsset: ReportAssets.weeklyLegendLast,
                dotColor: const Color(0xFFF0EAFF),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChartYAxis(scale: scale),
                SizedBox(width: 6 * scale),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: TogedogAssets.svg(
                                    ReportAssets.weeklyChartGrid,
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  height: 57 * scale,
                                  child: Row(
                                    children:
                                        List.generate(_barPairs.length, (i) {
                                      final pair = _barPairs[i];
                                      return Expanded(
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: _DayBarPair(
                                            scale: scale,
                                            thisWeekHeight: pair.$1,
                                            lastWeekHeight: pair.$2,
                                            maxHeight: _maxBarHeight,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Row(
                        children: List.generate(_dayLabels.length, (i) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                _dayLabels[i],
                                style: reportFont(
                                  scale,
                                  size: 8,
                                  color: const Color(0xFF6A6A6A),
                                ),
                              ),
                            ),
                          );
                        }),
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

class _ChartYAxis extends StatelessWidget {
  const _ChartYAxis({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    const labels = _WeeklyActivityChartCard._yTickLabels;

    return SizedBox(
      width: 36 * scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '(걸음)',
            style: reportFont(
              scale,
              size: 7,
              color: const Color(0xFFA5A5A5),
            ),
          ),
          SizedBox(height: 4 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: labels
                  .map(
                    (label) => Text(
                      label,
                      style: reportFont(
                        scale,
                        size: 7,
                        color: const Color(0xFFA5A5A5),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 16 * scale),
        ],
      ),
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({
    required this.scale,
    required this.label,
    required this.dotAsset,
    required this.dotColor,
  });

  final double scale;
  final String label;
  final String dotAsset;
  final Color dotColor;

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

class _DayBarPair extends StatelessWidget {
  const _DayBarPair({
    required this.scale,
    required this.thisWeekHeight,
    required this.lastWeekHeight,
    required this.maxHeight,
  });

  final double scale;
  final double thisWeekHeight;
  final double lastWeekHeight;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    const chartHeight = 57.0;
    final barWidth = 8 * scale;
    final gap = 4 * scale;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ActivityBar(
          scale: scale,
          width: barWidth,
          height: thisWeekHeight / maxHeight * chartHeight * scale,
          color: const Color(0xFF8756E7),
        ),
        SizedBox(width: gap),
        _ActivityBar(
          scale: scale,
          width: barWidth,
          height: lastWeekHeight / maxHeight * chartHeight * scale,
          color: const Color(0xFFF0EAFF),
        ),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  const _ActivityBar({
    required this.scale,
    required this.width,
    required this.height,
    required this.color,
  });

  final double scale;
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2 * scale)),
      ),
    );
  }
}

class _WeeklyAnomalyCard extends StatelessWidget {
  const _WeeklyAnomalyCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12 * scale, 15 * scale, 12 * scale, 15 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '주간 이상 징후 요약',
                style: reportFont(scale, size: 12),
              ),
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
          SizedBox(height: 7 * scale),
          Container(
            height: 53 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAFF),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 12 * scale),
                TogedogAssets.svg(
                  ReportAssets.weeklyCheck,
                  width: 26 * scale,
                  height: 26 * scale,
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이번주 특별한 이상 징후는 없었어요',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: reportFont(
                          scale,
                          size: 10,
                          weight: FontWeight.w700,
                          color: const Color(0xFF6A6A6A),
                        ),
                      ),
                      SizedBox(height: 3 * scale),
                      Text(
                        '모든 건강 지표가 정상 범위입니다',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: reportFont(
                          scale,
                          size: 8,
                          weight: FontWeight.w400,
                          color: const Color(0xFF6A6A6A),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  ReportAssets.weeklySummaryIllus,
                  width: 70 * scale,
                  height: 45 * scale,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                SizedBox(width: 8 * scale),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 독립 화면 진입점 (탭 셸 없이 단독 표시 시)
class Report02Screen extends StatelessWidget {
  const Report02Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    return TogedogA11y.screen(
      name: '주간 리포트',
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
          child: Report02Body(scale: scale, petName: '콩이'),
        ),
      ),
    ),
    );
  }
}
