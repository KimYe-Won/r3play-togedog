from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import DevicePairRequest, DeviceResponse, DeviceUpdate
from app.repositories.base import Repository

router = APIRouter(prefix="/devices", tags=["devices"])


@router.post("/pair", response_model=DeviceResponse, status_code=status.HTTP_201_CREATED)
def pair_device(
    payload: DevicePairRequest,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DeviceResponse:
    dog = repo.get_dog(payload.dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    if dog.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")
    return repo.pair_device(payload)


@router.get("/dog/{dog_id}", response_model=list[DeviceResponse])
def list_devices_by_dog(
    dog_id: str,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> list[DeviceResponse]:
    dog = repo.get_dog(dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    if dog.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")
    return repo.list_devices_by_dog(dog_id)


@router.patch("/{device_id}", response_model=DeviceResponse)
def update_device(
    device_id: str,
    payload: DeviceUpdate,
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DeviceResponse:
    devices = [
        device
        for dog in repo.list_dogs(member_id)
        for device in repo.list_devices_by_dog(dog.dog_id)
        if device.device_id == device_id
    ]
    if not devices:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found.")
    return repo.update_device(device_id, payload)
