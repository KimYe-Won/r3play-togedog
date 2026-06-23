// [백엔드 연동] 서버 주소 설정
class ApiConfig {
  ApiConfig._();

  /// 실제 폰 + 같은 Wi-Fi → PC Wi-Fi IP
  // static const String baseUrl = 'http://192.168.0.13:8000';
  static const String baseUrl = 'http://127.0.0.1:8000';
  /// Android 에뮬레이터일 때는 이걸로 바꿔서 테스트:
  /// static const String baseUrl = '<http://10.0.2.2:8000>';
}