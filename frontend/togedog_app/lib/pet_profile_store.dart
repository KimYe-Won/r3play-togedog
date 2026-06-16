/// 온보딩 11화면에서 입력한 보호자·반려견 프로필 (앱 전역 공유)
class PetProfileStore {
  PetProfileStore._();

  static final PetProfileStore instance = PetProfileStore._();

  static const String defaultGuardianName = '보호자';
  static const String defaultPetName = '반려견';
  static const String defaultBreed = '견종';
  static const String defaultAgeLabel = '나이';

  String guardianName = '';
  String petName = '';
  String breed = '';
  String age = '';

  /// 온보딩 04~14 완료 여부 (앱 전환 시 재진입 방지)
  bool onboardingCompleted = false;

  void markOnboardingCompleted() {
    onboardingCompleted = true;
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
