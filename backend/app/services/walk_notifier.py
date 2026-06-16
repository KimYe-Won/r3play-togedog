import json
from collections import defaultdict

from fastapi import WebSocket

from app.models.schemas import DangerDetectionResponse


class WalkNotifier:
    def __init__(self) -> None:
        self.connections: dict[str, set[WebSocket]] = defaultdict(set)

    async def connect(self, walk_id: str, websocket: WebSocket) -> None:
        await websocket.accept()
        self.connections[walk_id].add(websocket)

    def disconnect(self, walk_id: str, websocket: WebSocket) -> None:
        self.connections[walk_id].discard(websocket)
        if not self.connections[walk_id]:
            del self.connections[walk_id]

    async def broadcast_danger(self, danger: DangerDetectionResponse) -> None:
        message = json.dumps(
            {
                "type": "danger_detected",
                "data": danger.model_dump(mode="json"),
            },
            ensure_ascii=False,
        )
        dead_connections: list[WebSocket] = []
        for websocket in self.connections.get(danger.walk_id, set()):
            try:
                await websocket.send_text(message)
            except Exception:
                dead_connections.append(websocket)

        for websocket in dead_connections:
            self.disconnect(danger.walk_id, websocket)


walk_notifier = WalkNotifier()
