# 안내(guidance) 파이프라인 리뷰 메모

## ✅ 런타임 버그 수정 (2026-06-22, walk_ai_manager.dart / services/tts_service.dart)
- **재접속 반복 시 모델 멈춤**: 원인은 패키지 `YoloAnalyzer._isBusy` 고착(연결 종료가 `captureFrame()` await 도중 끼어들면 future가 안 끝나 `finally` 미도달 → `_isBusy=true` 영구 고착, analyzer 인스턴스는 재접속해도 유지됨). 수정: `connect()`에서 재접속이면 `LiveStreamingController`를 새로 생성(`_buildController`)해 깨끗한 analyzer로 시작, 이전 컨트롤러는 UI 스왑 후 2초 뒤 dispose. 탐지스트림(`_detectionController`)·TTS·오디오는 매니저가 소유해 유지.
- **TTS 안 들림**: WebRTC가 안드로이드 오디오를 통신모드(MODE_IN_COMMUNICATION/이어피스)로 잡아 TTS(미디어 음성)가 안 들림. `_vibrate`는 무조건 호출돼 진동만 났음. 수정: 연결 후 `Helper.setAndroidAudioConfiguration(AndroidAudioConfiguration.media)`로 미디어(normal) 모드 고정 → TTS 스피커 출력.
- **되울림**: `enableSpeaker: true` → **false**(송신폰 마이크 소리 재생 안 함). + 수신폰 로컬 오디오 트랙 `enabled=false`(마이크 송신 차단).
- **모드별 진동 분리**: `TtsService.vibrationEnabled` 추가 + `processDetections`에서 `if (vibrationEnabled) _vibrate(...)`. `_applyGuidanceMode`에서 sound(시각장애인)=음성O/진동X, vibration(청각장애인)=음성X/진동O+YAMNet배너, text=둘다X.
- **성능**: 화질 fullHd1080 유지 + detectionInterval **300ms**(모델 끊김 대응).

### 용어 정리
- "효과음" = YAMNet(`AudioService`, 수신폰 마이크 소리분류) → `AudioAlertBanner`(상단 텍스트 배너) + 진동. 실제 사운드 아님. 청각장애인(vibration) 모드 전용.
- `enableSpeaker` = WebRTC로 받은 송신폰 마이크 소리를 스피커로 재생할지. 앱 안내(TTS/진동/배너)와 무관.


## 현재 상태 (2026-06-22)
- **베이스 = 사용자 패치 버전**(직접 빌드/설치한 현재 코드). 이 위에 아래 항목을 "현재 코드 테스트 후" 패치 예정.
- 사용자 패치가 이미 해결한 것:
  - 모델 로딩: `asset/` → `assets/` 폴더 리네임 + `modelPath = 'assets/deep_learning/best_v3_float16.tflite'` → ultralytics_yolo 경로 해석기가 정상 인식.
  - 전체화면/재연결 2버그: `yolo_live_stream` 0.8.0의 `LiveStreamingController`가 세션을 직접 소유 → 화면 이동에도 스트림 유지.
- 주의: 아래 항목들은 이전에 한 번 적용했다가 패치(git reset/clean 추정)로 **되돌아간** 상태. 현재 코드엔 미반영.

## ⏳ 테스트 후 다시 패치할 항목 (현재 코드 기준)

### P0 (정확도 핵심)
- [ ] `lib/services/tts_service.dart` `processDetections`: 면적(area)/중심X(centerX) 계산을 `boundingBox`(픽셀) → **`normalizedBox`(0~1)** 로 변경.
  - 증상: 방향 안내가 항상 "오른쪽"으로 치우침, person 근접(면적) 필터가 사실상 무력화.

### P1 (안정성)
- [ ] `tts_service` `_frameCount`: 미검출 시 즉시 0 리셋 → **minFrames 상한 + 미검출 시 1씩 decay** 로 변경 (YOLO 깜빡임 대응).
- [ ] 진동/모드 분리: `TtsService.vibrationEnabled` 플래그 추가 후 `walk_ai_manager._applyGuidanceMode`에서
  - 음성모드 = 음성만, 진동모드 = 진동(+청각), 텍스트모드 = 둘 다 off.
  - 현재: `_vibrate`가 모드와 무관하게 항상 호출됨.

### P2 (보강)
- [ ] `lib/services/audio_service.dart` YAMNet 인덱스를 공식 `yamnet_class_map.csv` 기준으로 정정. 인덱스를 `_SoundInfo`에 통합해 이중 맵 제거. 표준 AudioSet 521클래스/순서 확인.
- [ ] `walk_ai_manager` `detectionInterval` 100ms → 200ms (성능/발열).

## 실기기 검증 체크리스트 (현재 코드)
- [ ] 모델 로드 성공 (logcat에 `ModelNotLoadedException` 없음), 탐지 박스 표시됨
- [ ] YOLO `className` 이 `tts_service._dangerMap` 키와 일치 (라벨 메타데이터 확인) — 불일치 시 진동/음성 안 울림
- [ ] 방향 안내 좌/중/우 정상
- [ ] 음성/진동/텍스트 모드별 채널 동작
- [ ] 소리(YAMNet) 경고 동작
