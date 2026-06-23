from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import (
    MemberConsentsUpdate,
    MemberCreate,
    MemberResponse,
    MemberUpdate,
    NotificationSettingResponse,
    NotificationSettingUpdate,
)
from app.repositories.base import Repository

router = APIRouter(prefix="/members", tags=["members"])


@router.post("", response_model=MemberResponse, status_code=status.HTTP_201_CREATED)
def create_member(
    payload: MemberCreate,
    repo: Repository = Depends(get_repository),
) -> MemberResponse:
    return repo.create_member(payload)


@router.get("/me", response_model=MemberResponse)
def get_my_profile(
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> MemberResponse:
    member = repo.get_member(member_id)
    if not member:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Member not found.")
    return member


@router.patch("/me", response_model=MemberResponse)
def update_my_profile(
    payload: MemberUpdate,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> MemberResponse:
    return repo.update_member(member_id, payload)


@router.put("/me/consents", response_model=MemberResponse)
def update_my_consents(
    payload: MemberConsentsUpdate,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> MemberResponse:
    return repo.update_member_consents(member_id, payload)


@router.put("/me/notification-settings", response_model=NotificationSettingResponse)
def upsert_notification_settings(
    payload: NotificationSettingUpdate,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> NotificationSettingResponse:
    return repo.upsert_notification_setting(member_id, payload)


@router.get("/me/notification-settings", response_model=NotificationSettingResponse)
def get_notification_settings(
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> NotificationSettingResponse:
    setting = repo.get_notification_setting(member_id)
    if not setting:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification settings not found.",
        )
    return setting
