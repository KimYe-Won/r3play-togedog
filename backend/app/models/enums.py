from enum import StrEnum


class GuideMode(StrEnum):
    VOICE = "VOICE"
    VIBRATION = "VIBRATION"
    TEXT = "TEXT"


class DogGender(StrEnum):
    MALE = "MALE"
    FEMALE = "FEMALE"


class ConnectionStatus(StrEnum):
    DISCONNECTED = "DISCONNECTED"
    SEARCHING = "SEARCHING"
    PAIRING = "PAIRING"
    CONNECTED = "CONNECTED"
    SYNCING = "SYNCING"


class WalkStatus(StrEnum):
    IN_PROGRESS = "IN_PROGRESS"
    COMPLETED = "COMPLETED"
    CANCELLED = "CANCELLED"


class DangerType(StrEnum):
    OBSTACLE = "OBSTACLE"
    VEHICLE = "VEHICLE"
    PERSON = "PERSON"
    ANIMAL = "ANIMAL"
    OTHER = "OTHER"


class DangerLevel(StrEnum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"
