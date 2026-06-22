# 안내(진동/음성) 파이프라인 — 수정 기록 & 검토 기준선

> 목적: 수정 전 기준선과 적용 내역을 기록한다.

## ✅ 적용 완료 (flutter analyze 통과)
- 패키지: `yolo_live_stream` 0.6.0 → **0.8.0** (controller 세션 소유/전면카메라 mirror 지원). `path_provider` 직접 의존성 추가.
- 모델 로딩(#1): `walk_ai_manager._ensureModelFile()`에서 에셋(`asset/...`)을 앱 지원 디렉터리로 복사 후 **절대경로**를 `customModelPath`로 전달.
- [P0] `tts_service`: area/centerX를 `normalizedBox`로 변경 (방향·근접 필터 정상화).
- [P1] `tts_service`: frameCount를 minFrames 상한 + 미검출 시 1씩 decay로 변경.
- [P1] 진동/모드 분리: `TtsService.vibrationEnabled` 추가, `_applyGuidanceMode`에서 음성모드=음성만 / 진동모드=진동+청각 / 텍스트=모두off.
- [P2] `audio_service`: YAMNet 인덱스를 공식 csv 기준으로 전부 정정(예: Dog 74→69, Car 300→301, Siren 396→390 등), 인덱스를 `_SoundInfo`에 통합해 이중맵 제거, 존재하지 않던 'Beeping, horn honking' 제거.
- [P2] 탐지 주기 100ms → **200ms**.

## 실기기 검증 필요(빌드 후)
- [ ] 모델 로드 성공(logcat에 ModelNotLoadedException 없음), 탐지 박스 표시
- [ ] `className`이 `_dangerMap` 키와 일치(라벨 메타데이터 확인) — 불일치 시 진동/음성 안 울림
- [ ] 방향 안내 좌/중/우 정상
- [ ] 음성/진동 모드별 채널 동작
- [ ] 소리(YAMNet) 경고 동작 — 521클래스 출력/순서가 표준 AudioSet인지 확인

---

## (참고) 수정 전 기준선
> 아래는 수정 전 코드 상태 기록.

## 전제
- 모델(`asset/deep_learning/best_v3_float16.tflite`)이 올바르게 붙어 `YOLOResult.className`이
  `tts_service.dart`의 `_dangerMap` 키('person','stairs','car'…)와 문자열로 일치한다고 가정.
- 화질 이슈는 수신앱이 아니라 **송신앱(camera_app)의 VideoQuality/비트레이트** 영역 → 별도 작업.

---

## [P0] 치명적 — 좌표 단위 (pixel → normalized)
`YOLOResult.boundingBox`는 픽셀 좌표, `normalizedBox`는 0~1. 현재 코드는 픽셀을 0~1로 가정해 사용.

- 파일: `lib/services/tts_service.dart`
- 현재(기준선):
  - `processDetections` 내 area 계산: `d.boundingBox.width * d.boundingBox.height` 를 `minBboxArea`(0.12)와 비교 → 항상 통과(필터 무력화)
  - centerX: `d.boundingBox.left + d.boundingBox.width / 2` → 수백 px → 방향이 항상 "오른쪽에"
- 기대 수정:
  - area / centerX 모두 `d.normalizedBox` 사용
- 검증 포인트:
  - [ ] area·centerX 계산이 `normalizedBox` 기반인가
  - [ ] 방향 안내가 왼쪽/전방/오른쪽 모두 정상 분기되는가 (0.35 / 0.65 임계와 정합)
  - [ ] person `minBboxArea=0.12` 근접 필터가 실제로 멀리 있는 사람을 걸러내는가

## [P1] 연속 프레임 카운트 리셋 → decay 권장
- 파일: `lib/services/tts_service.dart` (`processDetections`의 frameCount 갱신 루프)
- 현재(기준선): 미검출 프레임에서 `_frameCount[label] = 0` 즉시 리셋
  → 100ms × person minFrames=10 = 약 1초 연속 필요한데, 1프레임만 놓쳐도 리셋되어 트리거 곤란
- 기대 수정: 감소 방식 `count = max(0, count - 1)` 등 jitter 허용
- 검증: [ ] 한두 프레임 미검출에도 누적이 유지되는가

## [P1] 진동 이중 발생 / 모드 의미 정리
- 파일: `lib/services/tts_service.dart`(`_vibrate` 무조건 호출), `lib/walk_ai_manager.dart`(`_applyGuidanceMode`)
- 현재(기준선):
  - `processDetections`가 `speechEnabled`와 무관하게 항상 `_vibrate` 호출
  - 음성 모드 = 음성 + 진동 / 진동 모드 = YOLO진동 + YAMNet(AudioService)진동 (두 진동 소스 중첩 가능)
- 기대 수정(의도 확정 필요): 모드별 동작 명확화
  - 예) 음성 모드 = 음성 위주, 진동 모드 = 진동 위주로 소스 정리
- 검증: [ ] 모드별로 의도한 채널만 동작하는가 [ ] 진동 패턴 충돌 없는가

## [P2] YAMNet 인덱스 검증
- 파일: `lib/services/audio_service.dart` (`_yamnetIndex` 하드코딩 맵)
- 현재(기준선): Car=300, Siren=396 … Engine=303 등 하드코딩
- 기대 수정: 공식 `yamnet_class_map.csv`와 인덱스 대조, `Engine→오토바이` 오탐 여부 재검토
- 검증: [ ] 인덱스가 실제 클래스맵과 일치 [ ] 실환경 오탐 허용 범위

## [P2] 탐지 주기/성능
- 파일: `lib/walk_ai_manager.dart` (`_detectionInterval = 100ms`)
- 현재(기준선): 100ms(10fps) + captureFrame + float16 추론
- 기대 수정(선택): 150~250ms로 조정해 끊김/발열 테스트
- 검증: [ ] 보급형 기기에서 UI 끊김 없이 동작

---

## 참고(이 파이프라인 밖)
- 모델 라벨 메타데이터: tflite에 클래스명이 임베드돼 있어야 `className` 매핑 동작.
  `asset/deep_learning/`에 별도 labels 파일 없음 → 모델 붙일 때 최우선 확인.
- 화질: 송신앱(camera_app)의 해상도/프레임레이트/WebRTC 비트레이트 점검.
