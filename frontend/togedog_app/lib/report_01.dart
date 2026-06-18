// TogeDog 리포트 화면 — Figma node 696:7524
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'pet_profile_store.dart';
import 'report_02.dart';
import 'report_03.dart';
import 'report_shared.dart';
import 'togedog_accessibility.dart';

class Report01Screen extends StatefulWidget {
  const Report01Screen({super.key});

  @override
  State<Report01Screen> createState() => _Report01ScreenState();
}

class _Report01ScreenState extends State<Report01Screen> {
  int _selectedTab = 0;

  PetProfileStore get _profile => PetProfileStore.instance;

  String _todayDateLabel() {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final now = DateTime.now();
    return '${now.month}월 ${now.day}일 (${weekdays[now.weekday - 1]})';
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final petName = _profile.displayPetName;

    return DefaultTextStyle(
      style: reportFont(scale, size: 12),
      child: TogedogA11y.screen(
        name: '리포트',
        child: Scaffold(
        backgroundColor: kReportScreenBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    23 * scale,
                    8 * scale,
                    23 * scale,
                    16 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppScreenHeader(scale: scale, title: '리포트'),
                      SizedBox(height: 20 * scale),
                      ReportTabBar(
                        scale: scale,
                        selected: _selectedTab,
                        onChanged: (i) => setState(() => _selectedTab = i),
                      ),
                      SizedBox(height: 11 * scale),
                      if (_selectedTab == 0) ...[
                        _StatusCard(
                          scale: scale,
                          dateLabel: _todayDateLabel(),
                          petName: petName,
                        ),
                        SizedBox(height: 10 * scale),
                        _HealthSummaryCard(scale: scale),
                        SizedBox(height: 10 * scale),
                        _AiAnalysisCard(scale: scale),
                        SizedBox(height: 10 * scale),
                        _DangerRecordCard(scale: scale),
                      ]                       else if (_selectedTab == 1)
                        Report02Body(scale: scale, petName: petName)
                      else
                        Report03Body(scale: scale),
                    ],
                  ),
                ),
              ),
              AppBottomNav(
                scale: scale,
                bottomInset: bottomInset,
                activeTab: AppTab.report,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.scale,
    required this.dateLabel,
    required this.petName,
  });

  final double scale;
  final String dateLabel;
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
              dateLabel,
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
              '오늘의 $petName 상태',
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
            left: kDailyStatusPetLeft * scale,
            top: 1 * scale,
            width: kDailyStatusPetWidth * scale,
            height: kDailyStatusPetHeight * scale,
            child: Image.asset(
              ReportAssets.statusPet,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, __, ___) => Image.asset(
                TogedogAssets.petPhoto,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, __, ___) => Image.asset(
                  TogedogAssets.petPhotoFallback,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthSummaryCard extends StatelessWidget {
  const _HealthSummaryCard({required this.scale});

  final double scale;

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
            padding: EdgeInsets.only(left: 4 * scale),
            child: Text(
              '오늘의 건강 요약',
              style: reportFont(scale, size: 12),
            ),
          ),
          SizedBox(height: 9 * scale),
          Row(
            children: [
              Expanded(
                child: _HealthMetric(
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
                      style: reportFont(scale, size: 16),
                      children: [
                        TextSpan(
                          text: '98',
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
                  badge: '정상',
                  badgeBg: const Color(0xFFFDF0F8),
                  badgeColor: const Color(0xFFFE709A),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _HealthMetric(
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
                      style: reportFont(scale, size: 16),
                      children: [
                        TextSpan(
                          text: '8',
                          style: reportFont(scale, size: 16),
                        ),
                        TextSpan(
                          text: '시간',
                          style: reportFont(
                            scale,
                            size: 10,
                            color: const Color(0xFF828282),
                          ),
                        ),
                        TextSpan(
                          text: '20',
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
                  badge: '정상',
                  badgeBg: const Color(0xFFEAF2FF),
                  badgeColor: const Color(0xFF5684E7),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _HealthMetric(
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
                      style: reportFont(scale, size: 16),
                      children: [
                        TextSpan(
                          text: '6,245',
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
                  badge: '평균 25%',
                  badgeBg: const Color(0xFFF0EAFF),
                  badgeColor: const Color(0xFF8756E7),
                ),
              ),
              SizedBox(width: 9 * scale),
              Expanded(
                child: _HealthMetric(
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
                  badge: '정상',
                  badgeBg: const Color(0xFFFEF1EB),
                  badgeColor: const Color(0xFFFF7B00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthMetric extends StatelessWidget {
  const _HealthMetric({
    required this.scale,
    required this.icon,
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeBg,
    required this.badgeColor,
  });

  final double scale;
  final Widget icon;
  final String label;
  final Widget value;
  final String badge;
  final Color badgeBg;
  final Color badgeColor;

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
            padding: EdgeInsets.symmetric(horizontal: 8 * scale),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(32.5 * scale),
            ),
            alignment: Alignment.center,
            child: Text(
              badge,
              style: reportFont(
                scale,
                size: 10,
                weight: FontWeight.w400,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiAnalysisCard extends StatelessWidget {
  const _AiAnalysisCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 186 * scale,
      padding: EdgeInsets.fromLTRB(
        kReportCardContentLeft * scale,
        22 * scale,
        11 * scale,
        11 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 건강 분석',
                style: reportFont(scale, size: 12),
              ),
              SizedBox(height: 25 * scale),
              Text(
                '평소보다 활동량이 부족해요',
                style: reportFont(scale, size: 20),
              ),
              SizedBox(height: 5 * scale),
              RichText(
                text: TextSpan(
                  style: reportFont(
                    scale,
                    size: 15,
                    color: const Color(0xFF6A6A6A),
                  ),
                  children: [
                    TextSpan(text: '오늘은 ', style: reportFont(scale, size: 15, color: const Color(0xFF6A6A6A))),
                    TextSpan(
                      text: '가벼운 산책',
                      style: reportFont(
                        scale,
                        size: 15,
                        color: const Color(0xFF8756E7),
                      ),
                    ),
                    TextSpan(text: '을 추천해요', style: reportFont(scale, size: 15, color: const Color(0xFF6A6A6A))),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 36 * scale,
                padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5FF),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Row(
                  children: [
                    TogedogAssets.svg(
                      ReportAssets.walkPaw,
                      width: 18 * scale,
                      height: 18 * scale,
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      '20분 산책 추천',
                      style: reportFont(scale, size: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 36 * scale,
            width: 121 * scale,
            height: 97 * scale,
            child: Image.asset(
              ReportAssets.aiDog,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerRecordCard extends StatelessWidget {
  const _DangerRecordCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 93 * scale,
      padding: EdgeInsets.fromLTRB(12 * scale, 9 * scale, 12 * scale, 9 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '오늘의 위험 기록',
                style: reportFont(scale, size: 12),
              ),
              const Spacer(),
              Text(
                '전체 기록 보기',
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
          SizedBox(height: 6 * scale),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Row(
                children: [
                  TogedogAssets.svg(
                    ReportAssets.dangerCheck,
                    width: 26 * scale,
                    height: 26 * scale,
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '위험 상황 1회 감지',
                          style: reportFont(
                            scale,
                            size: 10,
                            weight: FontWeight.w700,
                            color: const Color(0xFF6A6A6A),
                          ),
                        ),
                        Text(
                          '산책 중 깨진 유리 접근 감지 → 안전하게 회피했어요',
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
                  SizedBox(width: 8 * scale),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6 * scale),
                    child: Image.asset(
                      ReportAssets.dangerMap,
                      width: 72 * scale,
                      height: 47 * scale,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72 * scale,
                        height: 47 * scale,
                        color: const Color(0xFFE8E8EC),
                      ),
                    ),
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
