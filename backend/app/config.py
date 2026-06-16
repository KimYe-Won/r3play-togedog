from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_ROOT = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "TogeDog API"
    app_version: str = "0.1.0"
    debug: bool = True
    cors_origins: str = "http://localhost:3000,http://127.0.0.1:3000"

    firebase_credentials_path: str | None = None
    firebase_database_url: str | None = None

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def firebase_enabled(self) -> bool:
        return bool(self.firebase_credentials_path and self.firebase_database_url)

    @property
    def resolved_credentials_path(self) -> Path | None:
        if not self.firebase_credentials_path:
            return None
        path = Path(self.firebase_credentials_path)
        if not path.is_absolute():
            path = BACKEND_ROOT / path
        return path


settings = Settings()
