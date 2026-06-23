from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import BiometricCreate, BiometricResponse, LatestBiometricResponse
from app.repositories.base import Repository

router = APIRouter(prefix="/biometrics", tags=["biometrics"])


@router.post("", response_model=BiometricResponse, status_code=status.HTTP_201_CREATED)
def create_biometric(
    payload: BiometricCreate,
    repo: Repository = Depends(get_repository),
) -> BiometricResponse:
    return repo.create_biometric(payload)


@router.get("/dog/{dog_id}/latest", response_model=LatestBiometricResponse)
def get_latest_biometric(
    dog_id: str,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> LatestBiometricResponse:
    dog = repo.get_dog(dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    if dog.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")

    latest = repo.get_latest_biometric(dog_id)
    if not latest:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Biometric data not found.",
        )
    return latest
