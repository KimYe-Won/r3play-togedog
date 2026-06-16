// TogeDog 내 정보 수정 — Figma node 488:397
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'pet_profile_store.dart';

class Mypage02Screen extends StatefulWidget {
  const Mypage02Screen({super.key});

  @override
  State<Mypage02Screen> createState() => _Mypage02ScreenState();
}

class _Mypage02ScreenState extends State<Mypage02Screen> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.sizeOf(context).width / kTogedogDesignWidth;
    final profile = PetProfileStore.instance;
    final displayName = '${profile.displayPetName}아빠';
    final petName = profile.displayPetName;
    final petDetailLine = _petDetailLine(profile);
    final notesLength = _notesController.text.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
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
                    '내 정보 수정',
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
            SizedBox(height: 20 * scale),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 19 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _InfoCard(
                      scale: scale,
                      sectionTitle: '사용자 정보',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AvatarWithCamera(
                                scale: scale,
                                imageAsset: 'asset/mypage_profile_user.png',
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _NameRow(scale: scale, name: displayName),
                                    SizedBox(height: 8 * scale),
                                    Text(
                                      'kongiappa@gmail.com',
                                      style: TextStyle(
                                        fontFamily: 'LGSmartUI',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14 * scale,
                                        color: const Color(0xFF828282),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18 * scale),
                          const Divider(height: 1, color: Color(0xFFE8E8EC)),
                          SizedBox(height: 16 * scale),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoField(
                                  scale: scale,
                                  label: '연락처',
                                  value: '010-1234-5678',
                                ),
                              ),
                              Expanded(
                                child: _InfoField(
                                  scale: scale,
                                  label: '선호 안내 방식',
                                  value: '진동 중심 안내',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    _InfoCard(
                      scale: scale,
                      sectionTitle: '반려견 정보',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AvatarWithCamera(
                                scale: scale,
                                imageAsset: TogedogAssets.petPhoto,
                                fallbackAsset: TogedogAssets.petPhotoFallback,
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _NameRow(scale: scale, name: petName),
                                    SizedBox(height: 6 * scale),
                                    Text(
                                      petDetailLine,
                                      style: TextStyle(
                                        fontFamily: 'LGSmartUI',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14 * scale,
                                        color: const Color(0xFF828282),
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      '4.2kg',
                                      style: TextStyle(
                                        fontFamily: 'LGSmartUI',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14 * scale,
                                        color: const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '접종 횟수',
                                    style: TextStyle(
                                      fontFamily: 'LGSmartUI',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12 * scale,
                                      color: const Color(0xFF828282),
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    '3회',
                                    style: TextStyle(
                                      fontFamily: 'LGSmartUI',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
                                      color: const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 18 * scale),
                          const Divider(height: 1, color: Color(0xFFE8E8EC)),
                          SizedBox(height: 16 * scale),
                          Row(
                            children: [
                              Expanded(
                                child: _InfoField(
                                  scale: scale,
                                  label: '생년월일',
                                  value: '24.06.10',
                                ),
                              ),
                              Expanded(
                                child: _InfoField(
                                  scale: scale,
                                  label: '특이사항',
                                  value: '알레르기 없음',
                                ),
                              ),
                              Expanded(
                                child: _InfoField(
                                  scale: scale,
                                  label: '중성화',
                                  value: 'O',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    Text(
                      '특이사항',
                      style: TextStyle(
                        fontFamily: 'LGSmartUI',
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * scale,
                        color: const Color(0xFF404040),
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Container(
                      height: 86 * scale,
                      padding: EdgeInsets.fromLTRB(
                        14 * scale,
                        12 * scale,
                        14 * scale,
                        10 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              counterText: '',
                              hintText: '알레르기, 건강 상태 등 특이사항을 입력해주세요',
                              hintStyle: TextStyle(
                                fontFamily: 'LGSmartUI',
                                fontWeight: FontWeight.w400,
                                fontSize: 12 * scale,
                                color: const Color(0xFF828282),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: 'LGSmartUI',
                              fontWeight: FontWeight.w400,
                              fontSize: 12 * scale,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Text(
                              '$notesLength/200',
                              style: TextStyle(
                                fontFamily: 'LGSmartUI',
                                fontWeight: FontWeight.w600,
                                fontSize: 10 * scale,
                                color: const Color(0xFFD4D4D4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Container(
                      height: 62 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: const Color(0xFFD4BEFE),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20 * scale,
                            height: 20 * scale,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8756E7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 14 * scale,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            '반려견 추가하기',
                            style: TextStyle(
                              fontFamily: 'LGSmartUI',
                              fontWeight: FontWeight.w600,
                              fontSize: 16 * scale,
                              color: const Color(0xFF8756E7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _petDetailLine(PetProfileStore profile) {
    final breed = profile.breed.isEmpty ? '푸들' : profile.breed;
    final age = profile.age.isEmpty || profile.age == PetProfileStore.defaultAgeLabel
        ? '3세'
        : '${profile.age}세';
    return '$breed • $age • 여';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.scale,
    required this.sectionTitle,
    required this.child,
  });

  final double scale;
  final String sectionTitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(23 * scale, 18 * scale, 23 * scale, 20 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: TextStyle(
              fontFamily: 'LGSmartUI',
              fontWeight: FontWeight.w700,
              fontSize: 15 * scale,
              color: const Color(0xFF111111),
            ),
          ),
          SizedBox(height: 16 * scale),
          child,
        ],
      ),
    );
  }
}

class _AvatarWithCamera extends StatelessWidget {
  const _AvatarWithCamera({
    required this.scale,
    required this.imageAsset,
    this.fallbackAsset,
  });

  final double scale;
  final String imageAsset;
  final String? fallbackAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82 * scale,
      height: 82 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Image.asset(
              imageAsset,
              width: 82 * scale,
              height: 82 * scale,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallbackAsset == null
                  ? Container(
                      width: 82 * scale,
                      height: 82 * scale,
                      color: const Color(0xFFE8E8EC),
                      child: Icon(Icons.person, size: 36 * scale),
                    )
                  : Image.asset(
                      fallbackAsset!,
                      width: 82 * scale,
                      height: 82 * scale,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28 * scale,
              height: 28 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF8756E7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2 * scale),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                size: 14 * scale,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.scale, required this.name});

  final double scale;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            name,
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
        SizedBox(width: 9 * scale),
        Image.asset(
          'asset/mypage_edit_name.png',
          width: 15 * scale,
          height: 15 * scale,
          errorBuilder: (_, __, ___) => Icon(
            Icons.edit,
            size: 14 * scale,
            color: const Color(0xFF6A6A6A),
          ),
        ),
      ],
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.scale,
    required this.label,
    required this.value,
  });

  final double scale;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w600,
            fontSize: 12 * scale,
            color: const Color(0xFF828282),
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'LGSmartUI',
            fontWeight: FontWeight.w600,
            fontSize: 14 * scale,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}
