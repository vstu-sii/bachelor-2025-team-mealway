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
    assert response.json() == {
        "message": "Meal Planner API is running",
        "version": "1.0.0",
        "docs": "/api/docs"
    }
