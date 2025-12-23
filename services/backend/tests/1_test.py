from typing import Dict, Any
from fastapi.testclient import TestClient
from fastapi import status
from app.main import app

client: TestClient = TestClient(app)


def test_read_root() -> None:
    """
    Тест корневого эндпоинта API.
    """
    response = client.get("/")
    assert response.status_code == status.HTTP_200_OK

    data: Dict[str, Any] = response.json()
    assert isinstance(data, dict)
    assert "message" in data
    assert "version" in data
    assert "docs" in data
    assert data["message"] == "Meal Planner API is running"


def test_health_check() -> None:
    """
    Тест health check эндпоинта.
    """
    response = client.get("/health")
    assert response.status_code == status.HTTP_200_OK

    data: Dict[str, Any] = response.json()
    assert isinstance(data, dict)
    assert "status" in data
    assert "service" in data
    assert data["status"] == "healthy"
    assert data["service"] == "meal-planner-api"
