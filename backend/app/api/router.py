from fastapi import APIRouter

from app.api.routes import biometrics, dangers, devices, dogs, members, reports, walks, ws

api_router = APIRouter()
api_router.include_router(members.router)
api_router.include_router(dogs.router)
api_router.include_router(devices.router)
api_router.include_router(walks.router)
api_router.include_router(dangers.router)
api_router.include_router(biometrics.router)
api_router.include_router(reports.router)
api_router.include_router(ws.router)
