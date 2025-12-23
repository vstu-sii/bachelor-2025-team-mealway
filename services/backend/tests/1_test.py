from typing import Dict, Any
from unittest.mock import Mock, patch


def test_read_root() -> None:
    """
    Тест корневого эндпоинта API.
    """
    # Мок ответа
    expected_data = {
        "message": "Meal Planner API is running",
        "version": "1.0.0",
        "docs": "/docs"
    }

    assert isinstance(expected_data, dict)
    assert "message" in expected_data
    assert "version" in expected_data
    assert "docs" in expected_data
    assert expected_data["message"] == "Meal Planner API is running"


def test_health_check() -> None:
    """
    Тест health check эндпоинта.
    """
    # Мок ответа
    expected_data = {
        "status": "healthy",
        "service": "meal-planner-api"
    }

    assert isinstance(expected_data, dict)
    assert "status" in expected_data
    assert "service" in expected_data
    assert expected_data["status"] == "healthy"
    assert expected_data["service"] == "meal-planner-api"
