# app/routers/users.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from typing import Optional, List

router = APIRouter()

# Pydantic-модель пользователя (упрощённая)


class UserCreate(BaseModel):
    email: EmailStr
    username: str
    password: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    weight: Optional[float] = None
    height: Optional[int] = None
    age: Optional[int] = None


class UserOut(BaseModel):
    user_id: int
    email: EmailStr
    username: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None


# Временное хранилище (вместо БД)
_fake_users_db: list[UserOut] = []
_next_id = 1


@router.post("/", response_model=UserOut)
def create_user(user: UserCreate):
    global _next_id
    # простая проверка уникальности username/email
    for u in _fake_users_db:
        if u.username == user.username:
            raise HTTPException(
                status_code=400, detail="Username already exists")
        if u.email == user.email:
            raise HTTPException(status_code=400, detail="Email already exists")
    new_user = UserOut(
        user_id=_next_id,
        email=user.email,
        username=user.username,
        first_name=user.first_name,
        last_name=user.last_name,
    )
    _fake_users_db.append(new_user)
    _next_id += 1
    return new_user


@router.get("/", response_model=List[UserOut])
def list_users():
    return _fake_users_db


@router.get("/{user_id}", response_model=UserOut)
def get_user(user_id: int):
    for u in _fake_users_db:
        if u.user_id == user_id:
            return u
    raise HTTPException(status_code=404, detail="User not found")
