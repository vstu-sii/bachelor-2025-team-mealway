from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel
from typing import Dict
import uuid
from datetime import datetime, timedelta

router = APIRouter()


class LoginRequest(BaseModel):
    username: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_at: datetime


# Простая in-memory таблица сессий
_sessions: Dict[str, TokenResponse] = {}

security = HTTPBearer()


@router.post("/login", response_model=TokenResponse)
def login(data: LoginRequest) -> TokenResponse:
    """
    Аутентификация пользователя и выдача JWT токена.
    """
    # В проде тут проверка реального пользователя и пароля по БД
    if not data.username or not data.password:
        raise HTTPException(
            status_code=400, detail="Username and password required")

    token = str(uuid.uuid4())
    expires = datetime.utcnow() + timedelta(hours=1)

    session = TokenResponse(access_token=token, expires_at=expires)
    _sessions[token] = session
    return session


@router.post("/logout")
def logout(credentials: HTTPAuthorizationCredentials = Depends(security)) -> Dict[str, str]:
    """
    Выход из системы - удаление токена из сессий.
    """
    token = credentials.credentials
    if token in _sessions:
        del _sessions[token]
    return {"detail": "Logged out successfully"}
