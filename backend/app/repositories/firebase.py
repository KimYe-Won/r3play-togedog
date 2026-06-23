from datetime import date, datetime, timedelta, timezone
from typing import TypeVar
from uuid import uuid4

from fastapi import HTTPException, status
from pydantic import BaseModel

from app.models.enums import ConnectionStatus, WalkStatus
from app.models.schemas import (
    BiometricCreate,
    BiometricResponse,
    DailyReportCreate,
    DailyReportResponse,
    DangerDetectionCreate,
    DangerDetectionResponse,
    DevicePairRequest,
    DeviceResponse,
    DeviceUpdate,
    DogCreate,
    DogResponse,
    DogUpdate,
    LatestBiometricResponse,
    MemberConsentsUpdate,
    MemberCreate,
    MemberResponse,
    MemberUpdate,
    MonthlyReportResponse,
    NotificationSettingResponse,
    NotificationSettingUpdate,
    WalkEndRequest,
    WalkResponse,
    WalkStartRequest,
    WeeklyReportResponse,
)
from app.repositories.base import Repository
from app.services.firebase_client import get_db_root

T = TypeVar("T", bound=BaseModel)


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


def _to_firebase(model: BaseModel) -> dict:
    return model.model_dump(mode="json")


def _from_firebase(model_cls: type[T], data: dict | None) -> T | None:
    if not data:
        return None
    return model_cls.model_validate(data)


class FirebaseRepository(Repository):
    def _ref(self, *parts: str):
        ref = get_db_root()
        for part in parts:
            ref = ref.child(part)
        return ref

    def create_member(self, payload: MemberCreate) -> MemberResponse:
        if self._ref("members", payload.member_id).get() is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Member already exists.",
            )

        member = MemberResponse(
            member_id=payload.member_id,
            name=payload.name,
            email=payload.email,
            phone=payload.phone,
            guide_mode=payload.guide_mode,
            joined_at=_utc_now(),
            location_consent=False,
            notification_consent=False,
            device_consent=False,
            camera_consent=False,
        )
        self._ref("members", payload.member_id).set(_to_firebase(member))
        self._ref("indexes", "member_dogs", payload.member_id).set({})
        self._ref("indexes", "member_walks", payload.member_id).set({})
        return member

    def get_member(self, member_id: str) -> MemberResponse | None:
        return _from_firebase(MemberResponse, self._ref("members", member_id).get())

    def update_member(self, member_id: str, payload: MemberUpdate) -> MemberResponse:
        member = self._require_member(member_id)
        updated = member.model_copy(update=payload.model_dump(exclude_unset=True))
        self._ref("members", member_id).set(_to_firebase(updated))
        return updated

    def update_member_consents(
        self, member_id: str, payload: MemberConsentsUpdate
    ) -> MemberResponse:
        member = self._require_member(member_id)
        updated = member.model_copy(update=payload.model_dump(exclude_unset=True))
        self._ref("members", member_id).set(_to_firebase(updated))
        return updated

    def upsert_notification_setting(
        self, member_id: str, payload: NotificationSettingUpdate
    ) -> NotificationSettingResponse:
        self._require_member(member_id)
        setting = NotificationSettingResponse(
            setting_id=member_id,
            member_id=member_id,
            guide_mode=payload.guide_mode,
            voice_enabled=payload.voice_enabled,
            vibration_enabled=payload.vibration_enabled,
            text_enabled=payload.text_enabled,
        )
        self._ref("notification_settings", member_id).set(_to_firebase(setting))

        member = self._require_member(member_id)
        updated_member = member.model_copy(update={"guide_mode": payload.guide_mode})
        self._ref("members", member_id).set(_to_firebase(updated_member))
        return setting

    def get_notification_setting(self, member_id: str) -> NotificationSettingResponse | None:
        return _from_firebase(
            NotificationSettingResponse,
            self._ref("notification_settings", member_id).get(),
        )

    def create_dog(self, member_id: str, payload: DogCreate) -> DogResponse:
        self._require_member(member_id)
        if payload.guardian_name:
            self.update_member(member_id, MemberUpdate(name=payload.guardian_name))
        dog_id = str(uuid4())
        dog = DogResponse(
            dog_id=dog_id,
            member_id=member_id,
            name=payload.name,
            breed=payload.breed,
            gender=payload.gender,
            birth_date=payload.birth_date,
            special_notes=payload.special_notes,
            neutered=payload.neutered,
            profile_image_url=payload.profile_image_url,
        )
        self._ref("dogs", dog_id).set(_to_firebase(dog))
        self._ref("indexes", "member_dogs", member_id, dog_id).set(True)
        self._ref("indexes", "dog_devices", dog_id).set({})
        return dog

    def list_dogs(self, member_id: str) -> list[DogResponse]:
        index = self._ref("indexes", "member_dogs", member_id).get() or {}
        dogs: list[DogResponse] = []
        for dog_id in index:
            dog = self.get_dog(dog_id)
            if dog:
                dogs.append(dog)
        return dogs

    def get_dog(self, dog_id: str) -> DogResponse | None:
        return _from_firebase(DogResponse, self._ref("dogs", dog_id).get())

    def update_dog(self, dog_id: str, payload: DogUpdate) -> DogResponse:
        dog = self._require_dog(dog_id)
        if payload.guardian_name:
            self.update_member(dog.member_id, MemberUpdate(name=payload.guardian_name))
        updated = dog.model_copy(
            update=payload.model_dump(exclude_unset=True, exclude={"guardian_name"})
        )
        self._ref("dogs", dog_id).set(_to_firebase(updated))
        return updated

    def delete_dog(self, dog_id: str) -> None:
        dog = self._require_dog(dog_id)
        self._ref("dogs", dog_id).delete()
        self._ref("indexes", "member_dogs", dog.member_id, dog_id).delete()

    def pair_device(self, payload: DevicePairRequest) -> DeviceResponse:
        self._require_dog(payload.dog_id)
        device_id = payload.device_id or str(uuid4())
        device = DeviceResponse(
            device_id=device_id,
            dog_id=payload.dog_id,
            device_name=payload.device_name,
            connection_status=ConnectionStatus.CONNECTED,
            battery_level=None,
            last_synced_at=_utc_now(),
        )
        self._ref("devices", device_id).set(_to_firebase(device))
        self._ref("indexes", "dog_devices", payload.dog_id, device_id).set(True)
        return device

    def list_devices_by_dog(self, dog_id: str) -> list[DeviceResponse]:
        index = self._ref("indexes", "dog_devices", dog_id).get() or {}
        devices: list[DeviceResponse] = []
        for device_id in index:
            device = _from_firebase(DeviceResponse, self._ref("devices", device_id).get())
            if device:
                devices.append(device)
        return devices

    def update_device(self, device_id: str, payload: DeviceUpdate) -> DeviceResponse:
        device = self._require_device(device_id)
        updated = device.model_copy(update=payload.model_dump(exclude_unset=True))
        self._ref("devices", device_id).set(_to_firebase(updated))
        return updated

    def start_walk(self, member_id: str, payload: WalkStartRequest) -> WalkResponse:
        self._require_member(member_id)
        dog = self._require_dog(payload.dog_id)
        if dog.member_id != member_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Dog does not belong to this member.",
            )

        walk_id = str(uuid4())
        walk = WalkResponse(
            walk_id=walk_id,
            member_id=member_id,
            dog_id=payload.dog_id,
            started_at=_utc_now(),
            ended_at=None,
            status=WalkStatus.IN_PROGRESS,
        )
        walk_index = {
            "started_at": walk.started_at.isoformat(),
            "ended_at": None,
            "dog_id": payload.dog_id,
            "status": walk.status.value,
        }
        self._ref("walks", walk_id).set(_to_firebase(walk))
        self._ref("indexes", "member_walks", member_id, walk_id).set(walk_index)
        self._ref("indexes", "dog_walks", payload.dog_id, walk_id).set(
            {"started_at": walk.started_at.isoformat(), "status": walk.status.value}
        )
        self._ref("indexes", "walk_dangers", walk_id).set({})
        return walk

    def end_walk(self, walk_id: str, payload: WalkEndRequest) -> WalkResponse:
        walk = self._require_walk(walk_id)
        if walk.status != WalkStatus.IN_PROGRESS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Walk is not in progress.",
            )

        updated = walk.model_copy(
            update={
                "ended_at": _utc_now(),
                "status": payload.status,
            }
        )
        walk_index = {
            "started_at": updated.started_at.isoformat(),
            "ended_at": updated.ended_at.isoformat() if updated.ended_at else None,
            "dog_id": updated.dog_id,
            "status": updated.status.value,
        }
        self._ref("walks", walk_id).set(_to_firebase(updated))
        self._ref("indexes", "member_walks", updated.member_id, walk_id).set(walk_index)
        self._ref("indexes", "dog_walks", updated.dog_id, walk_id).set(
            {"started_at": updated.started_at.isoformat(), "status": updated.status.value}
        )
        return updated

    def get_walk(self, walk_id: str) -> WalkResponse | None:
        return _from_firebase(WalkResponse, self._ref("walks", walk_id).get())

    def list_walks(self, member_id: str) -> list[WalkResponse]:
        index = self._ref("indexes", "member_walks", member_id).get() or {}
        walks: list[WalkResponse] = []
        for walk_id in index:
            walk = self.get_walk(walk_id)
            if walk:
                walks.append(walk)
        return sorted(walks, key=lambda walk: walk.started_at, reverse=True)

    def create_danger_detection(
        self, payload: DangerDetectionCreate
    ) -> DangerDetectionResponse:
        walk = self._require_walk(payload.walk_id)
        if walk.status != WalkStatus.IN_PROGRESS:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Danger detections can only be created during an active walk.",
            )

        danger_id = str(uuid4())
        danger = DangerDetectionResponse(
            danger_id=danger_id,
            walk_id=payload.walk_id,
            danger_type=payload.danger_type,
            danger_level=payload.danger_level,
            detected_at=payload.detected_at,
            notification_message=payload.notification_message,
            notification_channel=payload.notification_channel,
            is_confirmed=False,
            sent_at=_utc_now(),
            distance_m=payload.distance_m,
        )
        danger_index = {
            "detected_at": danger.detected_at.isoformat(),
            "danger_level": danger.danger_level.value,
            "danger_type": danger.danger_type.value,
        }
        self._ref("danger_detections", danger_id).set(_to_firebase(danger))
        self._ref("indexes", "walk_dangers", payload.walk_id, danger_id).set(danger_index)
        return danger

    def list_danger_detections(self, walk_id: str) -> list[DangerDetectionResponse]:
        index = self._ref("indexes", "walk_dangers", walk_id).get() or {}
        dangers: list[DangerDetectionResponse] = []
        for danger_id in index:
            danger = _from_firebase(
                DangerDetectionResponse,
                self._ref("danger_detections", danger_id).get(),
            )
            if danger:
                dangers.append(danger)
        return sorted(dangers, key=lambda danger: danger.detected_at)

    def confirm_danger_detection(
        self, danger_id: str, is_confirmed: bool
    ) -> DangerDetectionResponse:
        danger = self._require_danger(danger_id)
        updated = danger.model_copy(update={"is_confirmed": is_confirmed})
        self._ref("danger_detections", danger_id).set(_to_firebase(updated))
        return updated

    def create_biometric(self, payload: BiometricCreate) -> BiometricResponse:
        self._require_dog(payload.dog_id)
        biometric_id = str(uuid4())
        biometric = BiometricResponse(
            biometric_id=biometric_id,
            dog_id=payload.dog_id,
            heart_rate=payload.heart_rate,
            activity_level=payload.activity_level,
            measured_at=payload.measured_at,
        )
        self._ref("biometrics", payload.dog_id, biometric_id).set(_to_firebase(biometric))
        self._ref("indexes", "member_latest_biometric", payload.dog_id).set(
            {
                "heart_rate": biometric.heart_rate,
                "activity_level": biometric.activity_level,
                "measured_at": biometric.measured_at.isoformat(),
            }
        )
        return biometric

    def get_latest_biometric(self, dog_id: str) -> LatestBiometricResponse | None:
        data = self._ref("indexes", "member_latest_biometric", dog_id).get()
        if not data:
            return None
        return LatestBiometricResponse.model_validate({"dog_id": dog_id, **data})

    def create_daily_report(self, payload: DailyReportCreate) -> DailyReportResponse:
        self._require_dog(payload.dog_id)
        report_id = f"{payload.dog_id}_{payload.report_date.isoformat()}"
        report = DailyReportResponse(
            report_id=report_id,
            dog_id=payload.dog_id,
            report_date=payload.report_date,
            health_summary=payload.health_summary,
            behavior_summary=payload.behavior_summary,
            abnormal_signs=payload.abnormal_signs,
        )
        self._ref("daily_reports", payload.dog_id, payload.report_date.isoformat()).set(
            _to_firebase(report)
        )
        return report

    def get_daily_report(self, dog_id: str, report_date: date) -> DailyReportResponse | None:
        return _from_firebase(
            DailyReportResponse,
            self._ref("daily_reports", dog_id, report_date.isoformat()).get(),
        )

    def get_weekly_report(self, dog_id: str, end_date: date) -> WeeklyReportResponse:
        self._require_dog(dog_id)
        start_date = end_date - timedelta(days=6)
        daily_reports = self._reports_in_range(dog_id, start_date, end_date)
        total_walks, total_dangers = self._aggregate_walk_stats(dog_id, start_date, end_date)
        return WeeklyReportResponse(
            dog_id=dog_id,
            start_date=start_date,
            end_date=end_date,
            total_walks=total_walks,
            total_dangers=total_dangers,
            daily_reports=daily_reports,
        )

    def get_monthly_report(self, dog_id: str, year: int, month: int) -> MonthlyReportResponse:
        self._require_dog(dog_id)
        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(year, month + 1, 1) - timedelta(days=1)

        daily_reports = self._reports_in_range(dog_id, start_date, end_date)
        total_walks, total_dangers = self._aggregate_walk_stats(dog_id, start_date, end_date)
        return MonthlyReportResponse(
            dog_id=dog_id,
            year=year,
            month=month,
            total_walks=total_walks,
            total_dangers=total_dangers,
            daily_reports=daily_reports,
        )

    def _reports_in_range(
        self, dog_id: str, start_date: date, end_date: date
    ) -> list[DailyReportResponse]:
        reports: list[DailyReportResponse] = []
        current = start_date
        while current <= end_date:
            report = self.get_daily_report(dog_id, current)
            if report:
                reports.append(report)
            current += timedelta(days=1)
        return reports

    def _aggregate_walk_stats(
        self, dog_id: str, start_date: date, end_date: date
    ) -> tuple[int, int]:
        index = self._ref("indexes", "dog_walks", dog_id).get() or {}
        total_walks = 0
        total_dangers = 0
        for walk_id, walk_index in index.items():
            started_at = datetime.fromisoformat(walk_index["started_at"])
            if start_date <= started_at.date() <= end_date:
                total_walks += 1
                dangers = self._ref("indexes", "walk_dangers", walk_id).get() or {}
                total_dangers += len(dangers)
        return total_walks, total_dangers

    def _require_member(self, member_id: str) -> MemberResponse:
        member = self.get_member(member_id)
        if not member:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Member not found.")
        return member

    def _require_dog(self, dog_id: str) -> DogResponse:
        dog = self.get_dog(dog_id)
        if not dog:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
        return dog

    def _require_device(self, device_id: str) -> DeviceResponse:
        device = _from_firebase(DeviceResponse, self._ref("devices", device_id).get())
        if not device:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found.")
        return device

    def _require_walk(self, walk_id: str) -> WalkResponse:
        walk = self.get_walk(walk_id)
        if not walk:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Walk not found.")
        return walk

    def _require_danger(self, danger_id: str) -> DangerDetectionResponse:
        danger = _from_firebase(
            DangerDetectionResponse,
            self._ref("danger_detections", danger_id).get(),
        )
        if not danger:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Danger not found.")
        return danger
