// TogeDog 알림 화면 — Figma node 488:203
import 'package:flutter/material.dart';

class Noti01Screen extends StatelessWidget {
  const Noti01Screen({super.key});

  static const _items = [
    _NotiItem(
      title: 'LG전자 서비스 이용약관 및 개인정보\n처리방침 30일 전',
      date: '2026.05.28',
    ),
    _NotiItem(
      title: 'LG전자 서비스 개인정보 처리방침 시행 전\n개정 안내',
      date: '2026.05.18',
    ),
    _NotiItem(
      title: '청소 로봇 제품 등록 변경 안내',
      date: '2026.05.15',
    ),
    _NotiItem(
      title: '탄소 감축 프로젝트 이해관계자 협의회 안내',
      date: '2026.04.20',
    ),
    _NotiItem(
      title: 'LG전자 서비스 이용약관 및 개인정보\n처리방침 시행 전 개정 안내',
      date: '2026.04.20',
    ),
    _NotiItem(
      title: 'LG전자 서비스 이용약관 및 개인정보\n처리방침 30일 전 개정 안내',
      date: '2026.03.27',
    ),
    _NotiItem(
      title: 'ThinQ Web 신규 론칭 안내',
      date: '2026.03.19',
    ),
    _NotiItem(
      title: '일부 소셜 계정의 간편 로그인 서비스\n종료 안내',
      date: '2026.03.19',
    ),
    _NotiItem(
      title: 'Q 리워드 서비스 종료 및 리워드 사용 안내',
      date: '2026.02.05',
    ),
    _NotiItem(
      title: '우리 단지 서비스 업데이트 안내',
      date: '2026.02.05',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / 402;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(26 * scale, 8 * scale, 26 * scale, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: EdgeInsets.only(right: 9 * scale),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18 * scale,
                        color: const Color(0xFF111111),
                      ),
                    ),
                  ),
                  Text(
                    '알림',
                    style: TextStyle(
                      fontFamily: 'LGSmartUI',
                      fontWeight: FontWeight.w700,
                      fontSize: 20 * scale,
                      color: const Color(0xFF111111),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * scale),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 26 * scale),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE8E8EC),
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16 * scale),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontFamily: 'LGSmartUI',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15 * scale,
                                    height: 1.35,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                SizedBox(height: 8 * scale),
                                Text(
                                  item.date,
                                  style: TextStyle(
                                    fontFamily: 'LGSmartUI',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12 * scale,
                                    color: const Color(0xFF687080),
                                  ),
                                ),
                              ],
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotiItem {
  const _NotiItem({required this.title, required this.date});

  final String title;
  final String date;
}
