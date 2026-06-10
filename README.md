# R3PLAY TOGEDOG

장애인과 반려견을 위한 AI 기반 양방향 스마트케어 서비스

## 프로젝트 구조

```text
r3play-togedog/
├─ frontend/      # Flutter 앱
├─ backend/       # FastAPI 서버
├─ ai/            # YOLO 및 AI 추론 모델
├─ docs/          # 기획서 및 문서
└─ README.md
```
### 역할 분담
#### Frontend
- Flutter UI 구현
- Firebase 연동
- API 호출

#### Backend
- FastAPI 서버 개발
- WebSocket 통신
- Firebase 연동

#### 딥러닝 모델
- YOLOv11 모델 학습 및 추론
- 객체 탐지 결과 제공
- 백엔드 API 연동
  
#### 기술 스택
- Flutter
- FastAPI
- Firebase Realtime Database
- YOLOv11
- WebSocket
- GitHub
