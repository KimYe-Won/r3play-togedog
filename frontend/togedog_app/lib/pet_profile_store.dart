import 'package:shared_preferences/shared_preferences.dart';

/// 온보딩 11화면에서 입력한 보호자·반려견 프로필 (앱 전역 공유)
class PetProfileStore {
  PetProfileStore._();

  static final PetProfileStore instance = PetProfileStore._();

  static const String _onboardingCompletedKey = 'onboarding_completed';

  static const String defaultGuardianName = '보호자';
  static const String defaultPetName = '반려견';
  static const String defaultBreed = '견종';
  static const String defaultAgeLabel = '나이';

  String guardianName = '';
  String petName = '';
  String breed = '';
  String age = '';

  /// 온보딩 04~14를 완료했거나, 나중에/취소로 홈에 도착한 경우 true
  bool onboardingCompleted = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    onboardingCompleted = prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  void markOnboardingCompleted() {
    onboardingCompleted = true;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_onboardingCompletedKey, true),
    );
  }

  void update({
    required String guardianName,
    required String petName,
    required String breed,
    required String age,
  }) {
    this.guardianName = guardianName.trim();
    this.petName = petName.trim();
    this.breed = breed.trim();
    this.age = age.trim();
  }

  /// 11화면 '나중에' 선택 시 홈 기본 표시값
  void applySkipDefaults() {
    guardianName = defaultGuardianName;
    petName = defaultPetName;
    breed = defaultBreed;
    age = defaultAgeLabel;
  }

  String get displayGuardianName =>
      guardianName.isEmpty ? defaultGuardianName : guardianName;

  String get displayPetName =>
      petName.isEmpty ? defaultPetName : petName;

  String get petSubtitle {
    final breedLabel = breed.isEmpty ? defaultBreed : breed;
    final ageLabel = age.isEmpty ? defaultAgeLabel : age;
    if (ageLabel == defaultAgeLabel) {
      return '$breedLabel • $ageLabel';
    }
    return '$breedLabel • $ageLabel세';
  }
}
