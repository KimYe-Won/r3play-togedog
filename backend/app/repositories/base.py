from abc import ABC, abstractmethod
from datetime import date, datetime

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


class Repository(ABC):
    @abstractmethod
    def create_member(self, payload: MemberCreate) -> MemberResponse: ...

    @abstractmethod
    def get_member(self, member_id: str) -> MemberResponse | None: ...

    @abstractmethod
    def update_member(self, member_id: str, payload: MemberUpdate) -> MemberResponse: ...

    @abstractmethod
    def update_member_consents(
        self, member_id: str, payload: MemberConsentsUpdate
    ) -> MemberResponse: ...

    @abstractmethod
    def upsert_notification_setting(
        self, member_id: str, payload: NotificationSettingUpdate
    ) -> NotificationSettingResponse: ...

    @abstractmethod
    def get_notification_setting(self, member_id: str) -> NotificationSettingResponse | None: ...

    @abstractmethod
    def create_dog(self, member_id: str, payload: DogCreate) -> DogResponse: ...

    @abstractmethod
    def list_dogs(self, member_id: str) -> list[DogResponse]: ...

    @abstractmethod
    def get_dog(self, dog_id: str) -> DogResponse | None: ...

    @abstractmethod
    def update_dog(self, dog_id: str, payload: DogUpdate) -> DogResponse: ...

    @abstractmethod
    def delete_dog(self, dog_id: str) -> None: ...

    @abstractmethod
    def pair_device(self, payload: DevicePairRequest) -> DeviceResponse: ...

    @abstractmethod
    def list_devices_by_dog(self, dog_id: str) -> list[DeviceResponse]: ...

    @abstractmethod
    def update_device(self, device_id: str, payload: DeviceUpdate) -> DeviceResponse: ...

    @abstractmethod
    def start_walk(self, member_id: str, payload: WalkStartRequest) -> WalkResponse: ...

    @abstractmethod
    def end_walk(self, walk_id: str, payload: WalkEndRequest) -> WalkResponse: ...

    @abstractmethod
    def get_walk(self, walk_id: str) -> WalkResponse | None: ...

    @abstractmethod
    def list_walks(self, member_id: str) -> list[WalkResponse]: ...

    @abstractmethod
    def create_danger_detection(
        self, payload: DangerDetectionCreate
    ) -> DangerDetectionResponse: ...

    @abstractmethod
    def list_danger_detections(self, walk_id: str) -> list[DangerDetectionResponse]: ...

    @abstractmethod
    def confirm_danger_detection(
        self, danger_id: str, is_confirmed: bool
    ) -> DangerDetectionResponse: ...

    @abstractmethod
    def create_biometric(self, payload: BiometricCreate) -> BiometricResponse: ...

    @abstractmethod
    def get_latest_biometric(self, dog_id: str) -> LatestBiometricResponse | None: ...

    @abstractmethod
    def create_daily_report(self, payload: DailyReportCreate) -> DailyReportResponse: ...

    @abstractmethod
    def get_daily_report(self, dog_id: str, report_date: date) -> DailyReportResponse | None: ...

    @abstractmethod
    def get_weekly_report(self, dog_id: str, end_date: date) -> WeeklyReportResponse: ...

    @abstractmethod
    def get_monthly_report(self, dog_id: str, year: int, month: int) -> MonthlyReportResponse: ...
