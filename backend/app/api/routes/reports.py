from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.dependencies import get_member_id, get_repository
from app.models.schemas import (
    DailyReportCreate,
    DailyReportResponse,
    MonthlyReportResponse,
    WeeklyReportResponse,
)
from app.repositories.base import Repository

router = APIRouter(prefix="/reports", tags=["reports"])


def _ensure_dog_owner(repo: Repository, dog_id: str, member_id: str) -> None:
    dog = repo.get_dog(dog_id)
    if not dog:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Dog not found.")
    if dog.member_id != member_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access denied.")


@router.post("/daily", response_model=DailyReportResponse, status_code=status.HTTP_201_CREATED)
def create_daily_report(
    payload: DailyReportCreate,
    repo: Repository = Depends(get_repository),
) -> DailyReportResponse:
    return repo.create_daily_report(payload)


@router.get("/daily", response_model=DailyReportResponse)
def get_daily_report(
    dog_id: str = Query(...),
    report_date: date = Query(...),
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> DailyReportResponse:
    _ensure_dog_owner(repo, dog_id, member_id)
    report = repo.get_daily_report(dog_id, report_date)
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Report not found.")
    return report


@router.get("/weekly", response_model=WeeklyReportResponse)
def get_weekly_report(
    dog_id: str = Query(...),
    end_date: date = Query(default_factory=date.today),
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> WeeklyReportResponse:
    _ensure_dog_owner(repo, dog_id, member_id)
    return repo.get_weekly_report(dog_id, end_date)


@router.get("/monthly", response_model=MonthlyReportResponse)
def get_monthly_report(
    dog_id: str = Query(...),
    year: int = Query(..., ge=2000),
    month: int = Query(..., ge=1, le=12),
    member_id: str = Depends(get_member_id),
    repo: Repository = Depends(get_repository),
) -> MonthlyReportResponse:
    _ensure_dog_owner(repo, dog_id, member_id)
    return repo.get_monthly_report(dog_id, year, month)
