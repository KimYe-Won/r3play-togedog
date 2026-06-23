from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import DogCreate, DogResponse, DogUpdate
from app.repositories.base import Repository

router = APIRouter(prefix="/dogs", tags=["dogs"])


def _ensure_owner(dog: DogResponse, member_id: str) -> None:
    if dog.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")


@router.post("", response_model=DogResponse, status_code=status.HTTP_201_CREATED)
def create_dog(
    payload: DogCreate,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DogResponse:
    return repo.create_dog(member_id, payload)


@router.get("", response_model=list[DogResponse])
def list_dogs(
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> list[DogResponse]:
    return repo.list_dogs(member_id)


@router.get("/{dog_id}", response_model=DogResponse)
def get_dog(
    dog_id: str,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DogResponse:
    dog = repo.get_dog(dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    _ensure_owner(dog, member_id)
    return dog


@router.patch("/{dog_id}", response_model=DogResponse)
def update_dog(
    dog_id: str,
    payload: DogUpdate,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DogResponse:
    dog = repo.get_dog(dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    _ensure_owner(dog, member_id)
    return repo.update_dog(dog_id, payload)


@router.delete("/{dog_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_dog(
    dog_id: str,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> None:
    dog = repo.get_dog(dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    _ensure_owner(dog, member_id)
    repo.delete_dog(dog_id)
