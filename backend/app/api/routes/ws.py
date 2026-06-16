from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.services.walk_notifier import walk_notifier

router = APIRouter(tags=["websocket"])


@router.websocket("/ws/walks/{walk_id}")
async def walk_websocket(websocket: WebSocket, walk_id: str) -> None:
    await walk_notifier.connect(walk_id, websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        walk_notifier.disconnect(walk_id, websocket)
