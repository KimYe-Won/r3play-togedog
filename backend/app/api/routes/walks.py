from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import WalkEndRequest, WalkResponse, WalkStartRequest
from app.repositories.base import Repository

router = APIRouter(prefix="/walks", tags=["walks"])


@router.post("/start", response_model=WalkResponse, status_code=status.HTTP_201_CREATED)
def start_walk(
    payload: WalkStartRequest,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> WalkResponse:
    return repo.start_walk(member_id, payload)


@router.post("/{walk_id}/end", response_model=WalkResponse)
def end_walk(
    walk_id: str,
    payload: WalkEndRequest,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> WalkResponse:
    walk = repo.get_walk(walk_id)
    if not walk:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Walk not found.")
    if walk.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")
    return repo.end_walk(walk_id, payload)


@router.get("", response_model=list[WalkResponse])
def list_walks(
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> list[WalkResponse]:
    return repo.list_walks(member_id)


@router.get("/{walk_id}", response_model=WalkResponse)
def get_walk(
    walk_id: str,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> WalkResponse:
    walk = repo.get_walk(walk_id)
    if not walk:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Walk not found.")
    if walk.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")
    return walk
