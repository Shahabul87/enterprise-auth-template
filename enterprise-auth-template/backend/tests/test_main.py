"""
Basic tests for the main application
"""

import pytest
import os
from fastapi.testclient import TestClient

# Set test environment variables
os.environ["DATABASE_URL"] = "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth_test"
os.environ["REDIS_URL"] = "redis://localhost:6379/1"
os.environ["SECRET_KEY"] = "test-secret-key-for-testing-32chars"
os.environ["ENVIRONMENT"] = "test"

from app.main import app

client = TestClient(app)


def test_health_endpoint():
    """Test that health endpoint returns 200"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


def test_api_health_endpoint():
    """Test API health endpoint"""
    response = client.get("/api/v1/health/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["service"] == "enterprise-auth-api"


def test_root_endpoint():
    """Test root endpoint works"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data


def test_api_version_endpoint():
    """Test API version endpoint"""
    response = client.get("/api/v1/version")
    assert response.status_code == 200
    data = response.json()
    assert data["version"] == "1.0.0"
    assert data["service"] == "enterprise-auth-api"
