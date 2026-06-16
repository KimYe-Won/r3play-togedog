from datetime import date, datetime, timedelta, timezone
from uuid import uuid4

from fastapi import HTTPException, status

from app.models.enums import ConnectionStatus, GuideMode, WalkStatus
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


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


class MemoryRepository(Repository):
    def __init__(self) -> None:
        self.members: dict[str, MemberResponse] = {}
        self.notification_settings: dict[str, NotificationSettingResponse] = {}
        self.dogs: dict[str, DogResponse] = {}
        self.member_dogs: dict[str, set[str]] = {}
        self.devices: dict[str, DeviceResponse] = {}
        self.dog_devices: dict[str, set[str]] = {}
        self.walks: dict[str, WalkResponse] = {}
        self.member_walks: dict[str, set[str]] = {}
        self.dangers: dict[str, DangerDetectionResponse] = {}
        self.walk_dangers: dict[str, set[str]] = {}
        self.biometrics: dict[str, list[BiometricResponse]] = {}
        self.daily_reports: dict[str, dict[str, DailyReportResponse]] = {}

    def create_member(self, payload: MemberCreate) -> MemberResponse:
        if payload.member_id in self.members:
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
        self.members[payload.member_id] = member
        self.member_dogs[payload.member_id] = set()
        self.member_walks[payload.member_id] = set()
        return member

    def get_member(self, member_id: str) -> MemberResponse | None:
        return self.members.get(member_id)

    def update_member(self, member_id: str, payload: MemberUpdate) -> MemberResponse:
        member = self._require_member(member_id)
        updated = member.model_copy(
            update=payload.model_dump(exclude_unset=True),
        )
        self.members[member_id] = updated
        return updated

    def update_member_consents(
        self, member_id: str, payload: MemberConsentsUpdate
    ) -> MemberResponse:
        member = self._require_member(member_id)
        updated = member.model_copy(
            update=payload.model_dump(exclude_unset=True),
        )
        self.members[member_id] = updated
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
        self.notification_settings[member_id] = setting

        member = self.members[member_id]
        self.members[member_id] = member.model_copy(update={"guide_mode": payload.guide_mode})
        return setting

    def get_notification_setting(self, member_id: str) -> NotificationSettingResponse | None:
        return self.notification_settings.get(member_id)

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
        self.dogs[dog_id] = dog
        self.member_dogs[member_id].add(dog_id)
        self.dog_devices.setdefault(dog_id, set())
        self.biometrics.setdefault(dog_id, [])
        self.daily_reports.setdefault(dog_id, {})
        return dog

    def list_dogs(self, member_id: str) -> list[DogResponse]:
        dog_ids = self.member_dogs.get(member_id, set())
        return [self.dogs[dog_id] for dog_id in dog_ids if dog_id in self.dogs]

    def get_dog(self, dog_id: str) -> DogResponse | None:
        return self.dogs.get(dog_id)

    def update_dog(self, dog_id: str, payload: DogUpdate) -> DogResponse:
        dog = self._require_dog(dog_id)
        if payload.guardian_name:
            self.update_member(dog.member_id, MemberUpdate(name=payload.guardian_name))
        updated = dog.model_copy(
            update=payload.model_dump(exclude_unset=True, exclude={"guardian_name"})
        )
        self.dogs[dog_id] = updated
        return updated

    def delete_dog(self, dog_id: str) -> None:
        dog = self._require_dog(dog_id)
        self.member_dogs[dog.member_id].discard(dog_id)
        self.dogs.pop(dog_id, None)

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
        self.devices[device_id] = device
        self.dog_devices.setdefault(payload.dog_id, set()).add(device_id)
        return device

    def list_devices_by_dog(self, dog_id: str) -> list[DeviceResponse]:
        device_ids = self.dog_devices.get(dog_id, set())
        return [self.devices[device_id] for device_id in device_ids if device_id in self.devices]

    def update_device(self, device_id: str, payload: DeviceUpdate) -> DeviceResponse:
        device = self._require_device(device_id)
        updated = device.model_copy(update=payload.model_dump(exclude_unset=True))
        self.devices[device_id] = updated
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
        self.walks[walk_id] = walk
        self.member_walks[member_id].add(walk_id)
        self.walk_dangers[walk_id] = set()
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
        self.walks[walk_id] = updated
        return updated

    def get_walk(self, walk_id: str) -> WalkResponse | None:
        return self.walks.get(walk_id)

    def list_walks(self, member_id: str) -> list[WalkResponse]:
        walk_ids = self.member_walks.get(member_id, set())
        walks = [self.walks[walk_id] for walk_id in walk_ids if walk_id in self.walks]
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
        self.dangers[danger_id] = danger
        self.walk_dangers.setdefault(payload.walk_id, set()).add(danger_id)
        return danger

    def list_danger_detections(self, walk_id: str) -> list[DangerDetectionResponse]:
        danger_ids = self.walk_dangers.get(walk_id, set())
        dangers = [self.dangers[danger_id] for danger_id in danger_ids if danger_id in self.dangers]
        return sorted(dangers, key=lambda danger: danger.detected_at)

    def confirm_danger_detection(
        self, danger_id: str, is_confirmed: bool
    ) -> DangerDetectionResponse:
        danger = self._require_danger(danger_id)
        updated = danger.model_copy(update={"is_confirmed": is_confirmed})
        self.dangers[danger_id] = updated
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
        self.biometrics.setdefault(payload.dog_id, []).append(biometric)
        return biometric

    def get_latest_biometric(self, dog_id: str) -> LatestBiometricResponse | None:
        records = self.biometrics.get(dog_id, [])
        if not records:
            return None
        latest = max(records, key=lambda record: record.measured_at)
        return LatestBiometricResponse(
            dog_id=latest.dog_id,
            heart_rate=latest.heart_rate,
            activity_level=latest.activity_level,
            measured_at=latest.measured_at,
        )

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
        self.daily_reports.setdefault(payload.dog_id, {})[
            payload.report_date.isoformat()
        ] = report
        return report

    def get_daily_report(self, dog_id: str, report_date: date) -> DailyReportResponse | None:
        return self.daily_reports.get(dog_id, {}).get(report_date.isoformat())

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
        reports = []
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
        total_walks = 0
        total_dangers = 0
        for walk in self.walks.values():
            if walk.dog_id != dog_id:
                continue
            walk_date = walk.started_at.date()
            if start_date <= walk_date <= end_date:
                total_walks += 1
                total_dangers += len(self.walk_dangers.get(walk.walk_id, set()))
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
        device = self.devices.get(device_id)
        if not device:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not found.")
        return device

    def _require_walk(self, walk_id: str) -> WalkResponse:
        walk = self.get_walk(walk_id)
        if not walk:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Walk not found.")
        return walk

    def _require_danger(self, danger_id: str) -> DangerDetectionResponse:
        danger = self.dangers.get(danger_id)
        if not danger:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Danger not found.")
        return danger


repository = MemoryRepository()
