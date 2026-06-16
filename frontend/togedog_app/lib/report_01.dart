// TogeDog 리포트 화면 — Figma node 696:7524
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'pet_profile_store.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              TogedogAssets.background,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Image.asset(
                TogedogAssets.backgroundFallback,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
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
                        AppScreenHeader(scale: scale, title: '리포트'),
                        SizedBox(height: 20 * scale),
                        _ReportTabBar(
                          scale: scale,
                          selected: _selectedTab,
                          onChanged: (i) => setState(() => _selectedTab = i),
                        ),
                        SizedBox(height: 12 * scale),
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
        ],
      ),
    );
  }
}

class _ReportTabBar extends StatelessWidget {
  const _ReportTabBar({
    required this.scale,
    required this.selected,
    required this.onChanged,
  });

  final double scale;
  final int selected;
  final ValueChanged<int> onChanged;

  static const _labels = ['오늘의 리포트', '주간 리포트', '월간 리포트'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / _labels.length;
        final indicatorWidth = 97 * scale;
        final indicatorLeft =
            4 * scale + selected * tabWidth + (tabWidth - indicatorWidth) / 2;

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
                left: indicatorLeft.clamp(4 * scale, constraints.maxWidth - indicatorWidth - 4 * scale),
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
                children: List.generate(_labels.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          _labels[i],
                          style: TextStyle(
                            fontFamily: 'LGSmartUI',
                            fontWeight: FontWeight.w600,
                            fontSize: 11 * scale,
                            color: selected == i
                                ? Colors.white
                                : const Color(0xFF6A6A6A),
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
            left: 13 * scale,
            top: 20 * scale,
            child: Text(
              dateLabel,
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 11 * scale,
                color: const Color(0xFF8756E7),
              ),
            ),
          ),
          Positioned(
            left: 13 * scale,
            top: 41 * scale,
            child: Text(
              '오늘의 $petName 상태',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w700,
                fontSize: 18 * scale,
                color: const Color(0xFF111111),
              ),
            ),
          ),
          Positioned(
            left: 10 * scale,
            top: 79 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'asset/report_safety.png',
                  width: 24 * scale,
                  height: 24 * scale,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.verified_user,
                    size: 24 * scale,
                    color: const Color(0xFF1CA24E),
                  ),
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '안정',
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 20 * scale,
                    color: const Color(0xFF1CA24E),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10 * scale,
            top: 110 * scale,
            child: Text(
              '특별한 이상 징후가 없어요.',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 12 * scale,
                color: const Color(0xFF6A6A6A),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 1 * scale,
            width: 166 * scale,
            height: 154 * scale,
            child: Image.asset(
              'asset/report_status_pet.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, __, ___) => Image.asset(
                TogedogAssets.petPhoto,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  TogedogAssets.petPhotoFallback,
                  fit: BoxFit.cover,
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
              '  오늘의 건강 요약',
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w600,
                fontSize: 12 * scale,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          SizedBox(height: 9 * scale),
          Row(
            children: [
              Expanded(
                child: _HealthMetric(
                  scale: scale,
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      TogedogAssets.svg(
                        TogedogAssets.heartCircle,
                        width: 36 * scale,
                        height: 36 * scale,
                      ),
                      TogedogAssets.svg(
                        TogedogAssets.heartIcon,
                        width: 16 * scale,
                        height: 16 * scale,
                      ),
                    ],
                  ),
                  label: '심박수',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'LGSmartUI'),
                      children: [
                        TextSpan(
                          text: '98',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: ' bpm',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
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
                  icon: Image.asset(
                    'asset/report_sleep_icon.png',
                    width: 36 * scale,
                    height: 36 * scale,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.bedtime_outlined,
                      size: 28 * scale,
                      color: const Color(0xFF5684E7),
                    ),
                  ),
                  label: '수면',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'LGSmartUI'),
                      children: [
                        TextSpan(
                          text: '8',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: '시간',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
                            color: const Color(0xFF828282),
                          ),
                        ),
                        TextSpan(
                          text: '20',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: '분',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
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
                  icon: Stack(
                    alignment: Alignment.center,
                    children: [
                      TogedogAssets.svg(
                        TogedogAssets.activityCircle,
                        width: 36 * scale,
                        height: 36 * scale,
                      ),
                      TogedogAssets.svg(
                        TogedogAssets.activityIcon,
                        width: 16 * scale,
                        height: 16 * scale,
                      ),
                    ],
                  ),
                  label: '활동량',
                  value: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontFamily: 'LGSmartUI'),
                      children: [
                        TextSpan(
                          text: '6,245',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        TextSpan(
                          text: '걸음',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 10 * scale,
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
                  icon: Image.asset(
                    'asset/report_meal_icon.png',
                    width: 36 * scale,
                    height: 36 * scale,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.restaurant,
                      size: 28 * scale,
                      color: const Color(0xFFFF7B00),
                    ),
                  ),
                  label: '식사',
                  value: Text(
                    '좋음',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: const Color(0xFF1A1A1A),
                    ),
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
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w600,
              fontSize: 10 * scale,
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
              style: TextStyle(
                fontFamily: 'LGSmartUI',
                fontWeight: FontWeight.w400,
                fontSize: 10 * scale,
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
      padding: EdgeInsets.fromLTRB(14 * scale, 22 * scale, 11 * scale, 11 * scale),
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
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 25 * scale),
              Text(
                '평소보다 활동량이 부족해요',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 20 * scale,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 5 * scale),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'LGSmartUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * scale,
                    color: const Color(0xFF6A6A6A),
                  ),
                  children: const [
                    TextSpan(text: '오늘은 '),
                    TextSpan(
                      text: '가벼운 산책',
                      style: TextStyle(color: Color(0xFF8756E7)),
                    ),
                    TextSpan(text: '을 추천해요'),
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
                    Icon(
                      Icons.pets,
                      size: 18 * scale,
                      color: const Color(0xFF8756E7),
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      '20분 산책 추천',
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w600,
                        fontSize: 12 * scale,
                        color: const Color(0xFF1A1A1A),
                      ),
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
              'asset/report_ai_dog.png',
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
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Text(
                '전체 기록 보기',
                style: TextStyle(
                  fontFamily: 'LGSmartUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 9 * scale,
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
                  Icon(
                    Icons.check_circle_outline,
                    size: 26 * scale,
                    color: const Color(0xFF1CA24E),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '위험 상황 1회 감지',
                          style: TextStyle(
                            fontFamily: 'LGSmartUI',
                            fontWeight: FontWeight.w700,
                            fontSize: 10 * scale,
                            color: const Color(0xFF6A6A6A),
                          ),
                        ),
                        Text(
                          '산책 중 깨진 유리 접근 감지 → 안전하게 회피했어요',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'LGSmartUI',
                            fontWeight: FontWeight.w400,
                            fontSize: 8 * scale,
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
                      'asset/report_danger_map.png',
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
