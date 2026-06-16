from functools import lru_cache

from fastapi import Header, HTTPException, status

from app.config import settings
from app.repositories.base import Repository
from app.repositories.memory import MemoryRepository
from app.services.firebase_client import init_firebase


@lru_cache
def _get_repository() -> Repository:
    if settings.firebase_enabled:
        init_firebase()
        from app.repositories.firebase import FirebaseRepository

        return FirebaseRepository()
    return MemoryRepository()


def get_repository() -> Repository:
    return _get_repository()


def get_member_id(x_member_id: str | None = Header(default=None)) -> str:
    """Firebase Auth 연동 전 개발용 헤더."""
    if not x_member_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="X-Member-Id header is required.",
        )
    return x_member_id
