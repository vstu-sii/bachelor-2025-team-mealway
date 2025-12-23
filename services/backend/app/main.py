import os
from contextlib import asynccontextmanager
from typing import Any, Dict, AsyncIterator
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi_throttling import ThrottlingMiddleware  # type: ignore[import]

from app.routers import auth, meal_plans, users
from langfuse import Langfuse  # type: ignore[import]


# Инициализация Langfuse
langfuse = Langfuse(
    secret_key=os.getenv("LANGFUSE_SECRET_KEY"),
    public_key=os.getenv("LANGFUSE_PUBLIC_KEY"),
    host="http://langfuse-server:8080"
)

# Пример трассировки
trace = langfuse.trace(
    name="test-trace",
    user_id="user-123",
)

# Логирование запроса/ответа модели
trace.generation(
    name="llm-call",
    input={"prompt": "Hello"},
    output={"response": "Hi there!"}
)

# Конфигурация CORS для мобильного приложения
ALLOWED_ORIGINS: list[str] = [
    "http://localhost",
    "http://localhost:8080",
    "http://127.0.0.1",
    "http://127.0.0.1:8080",
]


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Управление жизненным циклом приложения"""
    # Инициализация при запуске
    print("Starting Meal Planner API...")

    # Инициализация вашей LLM модели
    # global m
    # m = Model(os.getenv("MEALWAY_MODEL", "LiquidAI/LFM2-1.2B"), None)
    # m.db = DB(m)

    yield  # Приложение работает

    # Очистка при завершении
    print("Shutting down Meal Planner API...")

app = FastAPI(
    title="Meal Planner API",
    description="API для мобильного приложения планирования питания с AI",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    lifespan=lifespan
)

# Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"]
)

app.add_middleware(ThrottlingMiddleware, limit=100, window=60)

# Подключаем роутеры
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(
    meal_plans.router,
    prefix="/api/meal-plans",
    tags=["Meal Plans"]
)


@app.get("/")
async def root() -> Dict[str, str]:
    """Корневой эндпоинт для проверки работы API"""
    return {
        "message": "Meal Planner API is running",
        "version": "1.0.0",
        "docs": "/api/docs"
    }


@app.get("/health")
async def health_check() -> Dict[str, Any]:
    """Эндпоинт для проверки здоровья сервиса"""
    return {
        "status": "healthy",
        "service": "meal-planner-api",
        "model_loaded": hasattr(app, 'm') and getattr(app, 'm', None) is not None
    }
