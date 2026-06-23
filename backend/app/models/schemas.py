from datetime import date, datetime

from pydantic import BaseModel, EmailStr, Field

from app.models.enums import (
    ConnectionStatus,
    DangerLevel,
    DangerType,
    DogGender,
    GuideMode,
    WalkStatus,
)


class MemberCreate(BaseModel):
    member_id: str
    name: str
    email: EmailStr
    phone: str | None = None
    guide_mode: GuideMode = GuideMode.TEXT


class MemberUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    guide_mode: GuideMode | None = None


class MemberConsentsUpdate(BaseModel):
    location_consent: bool | None = None
    notification_consent: bool | None = None
    device_consent: bool | None = None
    camera_consent: bool | None = None


class MemberResponse(BaseModel):
    member_id: str
    name: str
    email: EmailStr
    phone: str | None = None
    guide_mode: GuideMode
    joined_at: datetime
    location_consent: bool
    notification_consent: bool
    device_consent: bool
    camera_consent: bool


class NotificationSettingUpdate(BaseModel):
    guide_mode: GuideMode
    voice_enabled: bool
    vibration_enabled: bool
    text_enabled: bool


class NotificationSettingResponse(BaseModel):
    setting_id: str
    member_id: str
    guide_mode: GuideMode
    voice_enabled: bool
    vibration_enabled: bool
    text_enabled: bool


class DogCreate(BaseModel):
    guardian_name: str | None = Field(
        default=None,
        description="보호자 성명. 제공 시 회원(members) 이름을 함께 갱신합니다.",
    )
    name: str
    breed: str
    gender: DogGender
    birth_date: date | None = None
    special_notes: str | None = None
    neutered: bool = False
    profile_image_url: str | None = None


class DogUpdate(BaseModel):
    guardian_name: str | None = Field(
        default=None,
        description="보호자 성명. 제공 시 회원(members) 이름을 함께 갱신합니다.",
    )
    name: str | None = None
    breed: str | None = None
    gender: DogGender | None = None
    birth_date: date | None = None
    special_notes: str | None = None
    neutered: bool | None = None
    profile_image_url: str | None = None


class DogResponse(BaseModel):
    dog_id: str
    member_id: str
    name: str
    breed: str
    gender: DogGender
    birth_date: date | None = None
    special_notes: str | None = None
    neutered: bool
    profile_image_url: str | None = None


class DevicePairRequest(BaseModel):
    dog_id: str
    device_name: str
    device_id: str | None = None


class DeviceUpdate(BaseModel):
    device_name: str | None = None
    connection_status: ConnectionStatus | None = None
    battery_level: int | None = Field(default=None, ge=0, le=100)
    last_synced_at: datetime | None = None


class DeviceResponse(BaseModel):
    device_id: str
    dog_id: str
    device_name: str
    connection_status: ConnectionStatus
    battery_level: int | None = None
    last_synced_at: datetime | None = None


class WalkStartRequest(BaseModel):
    dog_id: str


class WalkEndRequest(BaseModel):
    status: WalkStatus = WalkStatus.COMPLETED


class WalkResponse(BaseModel):
    walk_id: str
    member_id: str
    dog_id: str
    started_at: datetime
    ended_at: datetime | None = None
    status: WalkStatus


class DangerDetectionCreate(BaseModel):
    walk_id: str
    danger_type: DangerType
    danger_level: DangerLevel
    detected_at: datetime
    notification_message: str
    notification_channel: GuideMode
    distance_m: float | None = None


class DangerDetectionConfirm(BaseModel):
    is_confirmed: bool = True


class DangerDetectionResponse(BaseModel):
    danger_id: str
    walk_id: str
    danger_type: DangerType
    danger_level: DangerLevel
    detected_at: datetime
    notification_message: str
    notification_channel: GuideMode
    is_confirmed: bool
    sent_at: datetime | None = None
    distance_m: float | None = None


class BiometricCreate(BaseModel):
    dog_id: str
    heart_rate: int = Field(ge=0)
    activity_level: int = Field(ge=0)
    measured_at: datetime


class BiometricResponse(BaseModel):
    biometric_id: str
    dog_id: str
    heart_rate: int
    activity_level: int
    measured_at: datetime


class LatestBiometricResponse(BaseModel):
    dog_id: str
    heart_rate: int
    activity_level: int
    measured_at: datetime


class DailyReportCreate(BaseModel):
    dog_id: str
    report_date: date
    health_summary: str
    behavior_summary: str
    abnormal_signs: str | None = None


class DailyReportResponse(BaseModel):
    report_id: str
    dog_id: str
    report_date: date
    health_summary: str
    behavior_summary: str
    abnormal_signs: str | None = None


class WeeklyReportResponse(BaseModel):
    dog_id: str
    start_date: date
    end_date: date
    total_walks: int
    total_dangers: int
    daily_reports: list[DailyReportResponse]


class MonthlyReportResponse(BaseModel):
    dog_id: str
    year: int
    month: int
    total_walks: int
    total_dangers: int
    daily_reports: list[DailyReportResponse]
