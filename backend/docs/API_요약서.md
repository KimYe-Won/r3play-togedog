# TogeDog API 요약서 (팀 공유용)

> **작성:** 백엔드/DB  
> **대상:** 프론트엔드, 딥러닝 팀  
> **상세 스펙:** 서버 실행 후 `http://{서버주소}:8000/docs` (Swagger UI)

---

## 1. 서버 정보

| 항목 | 값 |
|------|-----|
| 프로토콜 | HTTP / WebSocket |
| 로컬 주소 | `http://127.0.0.1:8000` |
| 데모 시 | 백엔드 담당자 PC IP (예: `http://192.168.x.x:8000`) |
| Health check | `GET /health` → `{"status":"ok","storage":"firebase"}` |
| API 문서 | `GET /docs` |

### 서버 실행 (백엔드)

```powershell
cd backend
.\.venv\Scripts\uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

> 데모 시 `--host 0.0.0.0` 으로 실행해야 다른 팀원 PC에서 접속 가능합니다.

---

## 2. 인증 (개발용)

현재 **Firebase Auth 미연동** 상태입니다. 아래 헤더로 테스트합니다.

| 헤더 | 값 | 필요한 API |
|------|-----|------------|
| `X-Member-Id` | 회원 ID (예: `user_001`) | 대부분의 조회·수정 API |

```http
X-Member-Id: user_001
```

> 추후 Firebase Auth JWT 토큰 방식으로 교체 예정

---

## 3. 데모 핵심 플로우

```text
POST /members              회원 생성
POST /dogs                 반려견 등록 (+ guardian_name)
POST /devices/pair         웨어러블 연결
POST /walks/start          산책 시작 → walk_id 확보
POST /danger-detections    위험 감지 (딥러닝)
POST /walks/{walk_id}/end  산책 종료
```

---

## 4. API 목록

### 4.1 회원 (members)

#### `POST /members` — 회원 생성
- **인증:** 없음

**Request**
```json
{
  "member_id": "user_001",
  "name": "김엘지",
  "email": "user@example.com",
  "phone": "010-1234-5678",
  "guide_mode": "VOICE"
}
```

| guide_mode | 설명 |
|------------|------|
| `VOICE` | 소리 중심 안내 |
| `VIBRATION` | 진동 중심 안내 |
| `TEXT` | 텍스트 안내 |

**Response:** `201` + 회원 정보

---

#### `GET /members/me` — 내 프로필 조회
- **인증:** `X-Member-Id` 필요

**Response:** `200` + 회원 정보

---

#### `PATCH /members/me` — 프로필 수정
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "name": "김엘지",
  "phone": "010-9999-8888",
  "guide_mode": "VOICE"
}
```

---

#### `PUT /members/me/consents` — 동의 항목 업데이트
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "location_consent": true,
  "notification_consent": true,
  "device_consent": true,
  "camera_consent": true
}
```

---

#### `PUT /members/me/notification-settings` — 알림 설정
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "guide_mode": "VOICE",
  "voice_enabled": true,
  "vibration_enabled": false,
  "text_enabled": true
}
```

---

### 4.2 반려견 (dogs)

#### `POST /dogs` — 반려견 등록
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "guardian_name": "김엘지",
  "name": "콩이",
  "breed": "말티즈",
  "gender": "MALE",
  "birth_date": "2020-03-15",
  "special_notes": "슬개골 주의",
  "neutered": true,
  "profile_image_url": null
}
```

| 필드 | 설명 |
|------|------|
| `guardian_name` | 보호자 성명 → `members.name` 갱신 |
| `name` | 반려견 이름 |
| `gender` | `MALE` / `FEMALE` |

**Response:** `201` + `dog_id` 포함

---

#### `GET /dogs` — 반려견 목록
- **인증:** `X-Member-Id` 필요

**Response:** `200` + 반려견 배열

---

#### `GET /dogs/{dog_id}` — 반려견 상세
#### `PATCH /dogs/{dog_id}` — 반려견 수정
#### `DELETE /dogs/{dog_id}` — 반려견 삭제

---

### 4.3 웨어러블 (devices)

#### `POST /devices/pair` — 기기 페어링
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "dog_id": "반려견_UUID",
  "device_name": "콩이 하네스",
  "device_id": null
}
```

**Response:** `201`
```json
{
  "device_id": "uuid",
  "dog_id": "...",
  "device_name": "콩이 하네스",
  "connection_status": "CONNECTED",
  "battery_level": null,
  "last_synced_at": "2026-06-16T..."
}
```

---

#### `GET /devices/dog/{dog_id}` — 반려견별 기기 목록
#### `PATCH /devices/{device_id}` — 기기 상태 갱신 (배터리 등)

---

### 4.4 산책 (walks)

#### `POST /walks/start` — 산책 시작
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "dog_id": "반려견_UUID"
}
```

**Response:** `201` + **`walk_id` 저장 필수**
```json
{
  "walk_id": "uuid",
  "member_id": "user_001",
  "dog_id": "...",
  "started_at": "2026-06-16T...",
  "ended_at": null,
  "status": "IN_PROGRESS"
}
```

---

#### `POST /walks/{walk_id}/end` — 산책 종료
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "status": "COMPLETED"
}
```

| status | 설명 |
|--------|------|
| `COMPLETED` | 정상 종료 |
| `CANCELLED` | 취소 |

---

#### `GET /walks` — 산책 목록
#### `GET /walks/{walk_id}` — 산책 상세

---

### 4.5 위험 감지 (danger-detections) — 딥러닝 팀

#### `POST /danger-detections` — 위험 감지 결과 전송
- **인증:** 없음
- **조건:** `walk_id`의 산책이 `IN_PROGRESS` 상태여야 함

**Request**
```json
{
  "walk_id": "산책_UUID",
  "danger_type": "VEHICLE",
  "danger_level": "HIGH",
  "detected_at": "2026-06-16T06:50:00Z",
  "notification_message": "전방 5m 이내에 차량이 감지되었습니다.",
  "notification_channel": "VOICE",
  "distance_m": 5.0
}
```

**danger_type (YOLO 클래스 매핑)**

| 값 | 설명 |
|----|------|
| `OBSTACLE` | 장애물 |
| `VEHICLE` | 차량 |
| `PERSON` | 사람 |
| `ANIMAL` | 동물 |
| `OTHER` | 기타 |

**danger_level**

| 값 | 설명 |
|----|------|
| `LOW` | 낮음 |
| `MEDIUM` | 보통 |
| `HIGH` | 높음 |
| `CRITICAL` | 긴급 |

**notification_channel:** `VOICE` / `VIBRATION` / `TEXT`

**Response:** `201` + `danger_id` 포함

> 위험 등록 시 WebSocket으로 연결된 클라이언트에 실시간 알림 전송

---

#### `GET /danger-detections/walk/{walk_id}` — 산책별 위험 목록
- **인증:** `X-Member-Id` 필요

#### `PATCH /danger-detections/{danger_id}/confirm` — 위험 확인 처리
- **인증:** `X-Member-Id` 필요

**Request**
```json
{
  "is_confirmed": true
}
```

---

### 4.6 생체데이터 (biometrics)

#### `POST /biometrics` — 생체데이터 수신
- **인증:** 없음

**Request**
```json
{
  "dog_id": "반려견_UUID",
  "heart_rate": 95,
  "activity_level": 42,
  "measured_at": "2026-06-16T10:30:00Z"
}
```

#### `GET /biometrics/dog/{dog_id}/latest` — 최신 생체데이터
- **인증:** `X-Member-Id` 필요

---

### 4.7 리포트 (reports)

#### `GET /reports/daily?dog_id={id}&report_date=2026-06-16`
#### `GET /reports/weekly?dog_id={id}&end_date=2026-06-16`
#### `GET /reports/monthly?dog_id={id}&year=2026&month=6`
- **인증:** `X-Member-Id` 필요

---

### 4.8 WebSocket — 실시간 위험 알림 (프론트엔드)

#### `WS /ws/walks/{walk_id}`

산책 중 위험 감지 시 서버가 아래 형식으로 메시지를 push합니다.

```json
{
  "type": "danger_detected",
  "data": {
    "danger_id": "uuid",
    "walk_id": "uuid",
    "danger_type": "VEHICLE",
    "danger_level": "HIGH",
    "detected_at": "2026-06-16T06:50:00Z",
    "notification_message": "전방에 차량이 감지되었습니다.",
    "notification_channel": "VOICE",
    "is_confirmed": false,
    "sent_at": "2026-06-16T...",
    "distance_m": 5.0
  }
}
```

**연결 예시 (JavaScript)**
```javascript
const ws = new WebSocket("ws://127.0.0.1:8000/ws/walks/{walk_id}");
ws.onmessage = (event) => {
  const message = JSON.parse(event.data);
  if (message.type === "danger_detected") {
    // 위험 알림 UI 표시
  }
};
```

---

## 5. 팀별 연동 가이드

### 프론트엔드

| 화면 | 사용 API |
|------|----------|
| 온보딩 · 회원가입 | `POST /members`, `PUT /members/me/consents` |
| 안내 방식 선택 | `PUT /members/me/notification-settings` |
| 반려견 프로필 등록 | `POST /dogs` (`guardian_name` 포함) |
| 웨어러블 페어링 | `POST /devices/pair` |
| 홈 · 실시간 상태 | `GET /biometrics/dog/{dog_id}/latest` |
| 산책 모드 | `POST /walks/start`, `POST /walks/{id}/end` |
| 산책 중 위험 알림 | `WS /ws/walks/{walk_id}` |
| 리포트 | `GET /reports/daily`, `weekly`, `monthly` |

**공통:** 대부분 API에 `X-Member-Id` 헤더 필요

---

### 딥러닝

| 역할 | API |
|------|-----|
| 위험 감지 결과 전송 | `POST /danger-detections` |

**필수 파라미터:** `walk_id`, `danger_type`, `danger_level`, `detected_at`, `notification_message`, `notification_channel`

**YOLO 탐지 클래스 → danger_type 매핑 (팀 협의 필요)**

| YOLO 클래스 (예시) | danger_type |
|--------------------|-------------|
| car, truck, bus | `VEHICLE` |
| person | `PERSON` |
| dog, cat | `ANIMAL` |
| 기타 장애물 | `OBSTACLE` |
| 분류 불가 | `OTHER` |

---

## 6. 에러 코드

| Code | 의미 |
|------|------|
| `200` | 성공 (조회·수정) |
| `201` | 성공 (생성) |
| `204` | 성공 (삭제) |
| `400` | 잘못된 요청 (예: 종료된 산책에 위험 등록) |
| `401` | `X-Member-Id` 헤더 없음 |
| `403` | 권한 없음 (다른 회원 데이터 접근) |
| `404` | 리소스 없음 |
| `409` | 중복 (이미 존재하는 회원) |
| `422` | 요청 body 형식 오류 |
| `500` | 서버 오류 |

---

## 7. 데이터 저장

- **DB:** Firebase Realtime Database
- **경로:** `togedog/members`, `togedog/dogs`, `togedog/walks`, `togedog/danger_detections` 등
- 상세 스키마: `backend/db/DB_설계서.md`

---

## 8. 문의

- API 상세·테스트: `/docs` (Swagger)
- 백엔드 담당: API 서버 주소 및 `X-Member-Id` 안내
- 데모 전 서버 실행 여부 확인 필요
