from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import (
    DangerDetectionConfirm,
    DangerDetectionCreate,
    DangerDetectionResponse,
)
from app.repositories.base import Repository
from app.services.walk_notifier import walk_notifier

router = APIRouter(prefix="/danger-detections", tags=["danger-detections"])


@router.post("", response_model=DangerDetectionResponse, status_code=status.HTTP_201_CREATED)
async def create_danger_detection(
    payload: DangerDetectionCreate,
    repo: Repository = Depends(get_repository),
) -> DangerDetectionResponse:
    danger = repo.create_danger_detection(payload)
    await walk_notifier.broadcast_danger(danger)
    return danger


@router.get("/walk/{walk_id}", response_model=list[DangerDetectionResponse])
def list_danger_detections(
    walk_id: str,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> list[DangerDetectionResponse]:
    walk = repo.get_walk(walk_id)
    if not walk:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Walk not found.")
    if walk.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")
    return repo.list_danger_detections(walk_id)


@router.patch("/{danger_id}/confirm", response_model=DangerDetectionResponse)
def confirm_danger_detection(
    danger_id: str,
    payload: DangerDetectionConfirm,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DangerDetectionResponse:
    dangers = [
        danger
        for walk in repo.list_walks(member_id)
        for danger in repo.list_danger_detections(walk.walk_id)
        if danger.danger_id == danger_id
    ]
    if not dangers:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Danger not found.")
    return repo.confirm_danger_detection(danger_id, payload.is_confirmed)
