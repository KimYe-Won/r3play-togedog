# 안내(guidance) 파이프라인 리뷰 메모

## ✅ 런타임 버그 수정 (2026-06-22, walk_ai_manager.dart / services/tts_service.dart)
- **재접속 반복 시 모델 멈춤**: 원인은 패키지 `YoloAnalyzer._isBusy` 고착(연결 종료가 `captureFrame()` await 도중 끼어들면 future가 안 끝나 `finally` 미도달 → `_isBusy=true` 영구 고착, analyzer 인스턴스는 재접속해도 유지됨). 수정: `connect()`에서 재접속이면 `LiveStreamingController`를 새로 생성(`_buildController`)해 깨끗한 analyzer로 시작, 이전 컨트롤러는 UI 스왑 후 2초 뒤 dispose. 탐지스트림(`_detectionController`)·TTS·오디오는 매니저가 소유해 유지.
- **TTS 안 들림**: WebRTC가 안드로이드 오디오를 통신모드(MODE_IN_COMMUNICATION/이어피스)로 잡아 TTS(미디어 음성)가 안 들림. `_vibrate`는 무조건 호출돼 진동만 났음. 수정: 연결 후 `Helper.setAndroidAudioConfiguration(AndroidAudioConfiguration.media)`로 미디어(normal) 모드 고정 → TTS 스피커 출력.
- **되울림**: `enableSpeaker: true` → **false**(송신폰 마이크 소리 재생 안 함). + 수신폰 로컬 오디오 트랙 `enabled=false`(마이크 송신 차단).
- **모드별 진동 분리**: `TtsService.vibrationEnabled` 추가 + `processDetections`에서 `if (vibrationEnabled) _vibrate(...)`. `_applyGuidanceMode`에서 sound(시각장애인)=음성O/진동X, vibration(청각장애인)=음성X/진동O+YAMNet배너, text=둘다X.
- **성능**: 화질 fullHd1080 유지 + detectionInterval **200ms**.

### 용어 정리
- "효과음" = YAMNet(`AudioService`, 수신폰 마이크 소리분류) → `AudioAlertBanner`(상단 텍스트 배너) + 진동. 실제 사운드 아님. 청각장애인(vibration) 모드 전용.
- `enableSpeaker` = WebRTC로 받은 송신폰 마이크 소리를 스피커로 재생할지. 앱 안내(TTS/진동/배너)와 무관.


## 진행 상황 스냅샷 (2026-06-22 저녁, 내일 이어서)

### ✅ 사용자 확인 완료 (정상 동작)
- 모델 탐지 + 재접속 안정성 (yolo_live_stream **0.10.0** 내부 `_isBusy` 리셋 + 컨트롤러 재사용 `late final`).
- TTS 발화 + 진동이 **모드별로 분리** 동작 (시각장애인=TTS만 / 청각장애인=진동만).
- `_frameCount` decay 적용, detectionInterval **200ms**, 추론 속도/프레임 양호.

### ✅ 이번 세션 코드 수정 → 빌드·설치 완료, **사용자 검증 대기**
1. **이슈4 방향 항상 "오른쪽"** — `tts_service.processDetections`에서 `boundingBox`(픽셀) → **`normalizedBox`(0~1)** 로 변경 (area/centerX 둘 다). → 수신폰 설치됨.
2. **이슈2 패널(음성/진동) 진입 시 흰 막 + 헤더/패널 UI 사라짐** — 원인: `walk_02`에서 패널을 `Semantics`로 감싸 패널 최상위 `Positioned`가 Stack 직속이 아니게 됨 → 레이아웃 깨짐. 수정: `Semantics` 래퍼 제거(패널을 Stack 직속으로). → 수신폰 설치됨.
3. **이슈1 재접속 시 화질 저하(첫 연결만 좋고 이후 계속 나쁨)** — 원인: 송신폰이 peerConnection을 1번만 만들고 재접속 때 같은 PC 재사용 → 낮아진 인코더 상태 잔존. 수정: `camera_app/lib/main.dart`를 명시적 `LiveStreamingController` + 리스너로 바꿔 **수신 연결 true→false 감지 시 `stop()`+`startAsSender()`로 세션 자동 리셋**. → 송신폰(SM_S901N) 설치됨.

### 설치 상태
- 수신앱(togedog_app): **SM_S916N / R3CWC01MWNA** — 이슈2·4 반영본.
- 송신앱(camera_app): **SM_S901N / R5CT40EEDTH** — 이슈1 반영본. (start 눌러두면 자동 리셋 동작)

## 06-23 진행

### ✅ 전방 판정(경로 기준)으로 변경 — 사용자 확정
- `tts_service._buildMessage`: 중심점(centerX 0.35/0.65) 기준 → **박스 Rect** 기준.
  - 박스가 중앙선(x=0.5)을 가로지르면 '전방', `box.right<0.5` 왼쪽, 그 외 오른쪽.
  - 의도: 코앞에 크게 잡혀 경로를 막는 물체는 중심이 약간 치우쳐도 '전방'.

### ✅ 이슈3 (얌넷 배너) 코드 수정 완료 — 빌드/검증 대기
1. **인덱스 전면 정정**: 기존 `_yamnetIndex` 하드코딩이 **전부 어긋남**(Car 300→**301**, horn 306→**302**, Siren 396→**390**, Emergency 397→**316**, Motorcycle 302→**320**, Dog 74→**69**, Bark 75→**70**, Yip 76→**71**, Bicycle bell 395→**198**). 공식 `yamnet_class_map.csv` 기준으로 정정, 인덱스를 `_SoundInfo(index, priority, label)`에 통합, `_yamnetIndex` 제거. 무효 'Beeping, horn honking' 삭제, 일반/오탐 'Engine'·'Bell' 제거, 'Motor vehicle (road)'(300) 추가.
2. **배너 위치**: `AudioAlertBanner`를 공용 `WalkRealtimeShell`(walk_shared.dart) 최상단에 추가 → walk_02에서도 표시. (walk_01은 자체 Scaffold라 중복 아님)
3. **마이크 해제**: `walk_ai_manager.connect()`에서 로컬 **오디오 트랙은 `stop()`**(마이크 완전 해제), 비디오는 `enabled=false` 유지. WebRTC 마이크 점유로 YAMNet(record)이 소리를 못 받던 문제 대응.
4. 진단 로그: `[YAMNet] start / alert=라벨(키) score / record error`.
- 주의: 얌넷은 여전히 **진동(청각장애인) 모드에서만** `_audioService.start()` 호출(설계). 배너 확인하려면 진동 모드로 테스트.

### 검증 체크리스트 (실기기)
- [ ] 전방: 박스가 화면 중앙 가로지를 때 '전방', 한쪽이면 좌/우
- [ ] 이슈2: 음성/진동 가이드 버튼 → 헤더·패널 정상, 영상 유지 (흰 막 없음)
- [ ] 이슈4: 의자 좌/중/우 → "왼쪽에/전방에/오른쪽에" 정확
- [ ] 이슈1: 송신폰 start 후 연결→끊기→재연결 시 화질이 첫 연결처럼 유지
- [ ] 이슈3: 진동 모드에서 차량/경적/사이렌/개/자전거벨 소리 → 상단 배너에 클래스명 표시 (`[YAMNet] alert` 로그 확인)

### 로그
- 스냅샷: `logs/2026-06-22_receiver_logcat.txt` (수신폰 flutter 로그 덤프).
