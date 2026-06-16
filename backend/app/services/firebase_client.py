from firebase_admin import credentials, db
import firebase_admin

from app.config import settings

_initialized = False


def init_firebase() -> None:
    global _initialized
    if _initialized:
        return

    if not settings.firebase_enabled:
        return

    credentials_path = settings.resolved_credentials_path
    if credentials_path is None or not credentials_path.exists():
        raise FileNotFoundError(
            f"Firebase credentials file not found: {credentials_path}"
        )

    database_url = settings.firebase_database_url.rstrip("/")
    cred = credentials.Certificate(str(credentials_path))
    firebase_admin.initialize_app(cred, {"databaseURL": database_url})
    _initialized = True


def get_db_root():
    if not _initialized:
        init_firebase()
    return db.reference("togedog")
