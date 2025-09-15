"""
Test Configuration and Fixtures

Provides pytest fixtures and configuration for all test modules.
Includes database setup, authentication helpers, and mock services.
"""

import asyncio
import os
import secrets
from typing import AsyncGenerator, Generator

import pytest
import pytest_asyncio
from fastapi.testclient import TestClient
from httpx import AsyncClient
from sqlalchemy import create_engine, StaticPool
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

# Set test environment before importing app modules
os.environ["ENVIRONMENT"] = "test"
os.environ["TESTING"] = "true"
os.environ["SECRET_KEY"] = secrets.token_urlsafe(32)
os.environ["DATABASE_URL"] = "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth_test"

from app.core.database import Base, get_db_session
from app.core.security import create_access_token, get_password_hash
from app.main import app
from app.models.user import User, UserRole, RolePermission
from app.models.role import Role
from app.models.permission import Permission
from app.services.cache_service import CacheService


# Test database setup
TEST_DATABASE_URL = "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth_test"

# Create async test engine
test_engine = create_async_engine(
    TEST_DATABASE_URL,
    echo=False,
    poolclass=StaticPool,
)

TestSessionLocal = async_sessionmaker(
    test_engine, class_=AsyncSession, expire_on_commit=False
)


@pytest.fixture(scope="session")
def event_loop():
    """Create an instance of the default event loop for the test session."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest_asyncio.fixture
async def db_session() -> AsyncGenerator[AsyncSession, None]:
    """Create a test database session."""
    # Create tables
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Create session
    async with TestSessionLocal() as session:
        yield session

    # Drop tables after test
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest.fixture
def override_get_db(db_session: AsyncSession):
    """Override the get_db dependency."""
    async def _override_get_db():
        yield db_session

    return _override_get_db


@pytest.fixture
def client(override_get_db) -> Generator[TestClient, None, None]:
    """Create a test client with database dependency override."""
    app.dependency_overrides[get_db_session] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


@pytest_asyncio.fixture
async def async_client(override_get_db) -> AsyncGenerator[AsyncClient, None]:
    """Create an async test client."""
    app.dependency_overrides[get_db_session] = override_get_db
    async with AsyncClient(app=app, base_url="http://test") as async_test_client:
        yield async_test_client
    app.dependency_overrides.clear()


# Mock Cache Service for Testing
class MockCacheService(CacheService):
    """Mock cache service that uses in-memory storage instead of Redis."""
    
    def __init__(self):
        self.cache = {}
    
    async def get_redis(self):
        """Mock Redis client."""
        return self
    
    async def get(self, key: str):
        """Mock Redis get."""
        return self.cache.get(key)
    
    async def setex(self, key: str, ttl, value):
        """Mock Redis setex."""
        self.cache[key] = value
        return True
    
    async def delete(self, key: str):
        """Mock Redis delete."""
        self.cache.pop(key, None)
        return True
    
    async def flushdb(self):
        """Mock Redis flushdb."""
        self.cache.clear()
        return True
    
    async def info(self):
        """Mock Redis info."""
        return {
            "connected_clients": 1,
            "used_memory": len(str(self.cache)),
            "used_memory_human": f"{len(str(self.cache))}B",
            "keyspace_hits": 100,
            "keyspace_misses": 20,
        }


@pytest.fixture
def mock_cache_service():
    """Provide a mock cache service for testing."""
    return MockCacheService()


@pytest_asyncio.fixture
async def test_user(db_session: AsyncSession) -> User:
    """Create a test user."""
    # Create default role
    user_role = Role(
        name="user",
        description="Default user role",
        is_system=True
    )
    db_session.add(user_role)
    await db_session.flush()

    # Create test user
    user = User(
        email="test@example.com",
        hashed_password=get_password_hash("testpassword123"),
        full_name="Test User",
        is_active=True,
        is_verified=True,
        is_superuser=False,
    )
    db_session.add(user)
    await db_session.flush()

    # Assign role to user
    user_role_assignment = UserRole(user_id=user.id, role_id=user_role.id)
    db_session.add(user_role_assignment)
    
    await db_session.commit()
    await db_session.refresh(user)
    return user


@pytest_asyncio.fixture
async def admin_user(db_session: AsyncSession) -> User:
    """Create an admin test user."""
    # Create admin role
    admin_role = Role(
        name="admin",
        description="Administrator role",
        is_system=True
    )
    db_session.add(admin_role)
    await db_session.flush()

    # Create admin permissions
    admin_permission = Permission(
        resource="admin",
        action="manage",
        description="Full admin access"
    )
    db_session.add(admin_permission)
    await db_session.flush()

    # Associate permission with role
    role_permission = RolePermission(role_id=admin_role.id, permission_id=admin_permission.id)
    db_session.add(role_permission)

    # Create admin user
    admin = User(
        email="admin@example.com",
        hashed_password=get_password_hash("adminpassword123"),
        full_name="Admin User",
        is_active=True,
        is_verified=True,
        is_superuser=True,
    )
    db_session.add(admin)
    await db_session.flush()

    # Assign admin role
    user_role_assignment = UserRole(user_id=admin.id, role_id=admin_role.id)
    db_session.add(user_role_assignment)
    
    await db_session.commit()
    await db_session.refresh(admin)
    return admin


@pytest.fixture
def user_token(test_user: User) -> str:
    """Create a JWT token for the test user."""
    return create_access_token(
        user_id=str(test_user.id),
        email=test_user.email,
        roles=["user"],
        permissions=[]
    )


@pytest.fixture
def admin_token(admin_user: User) -> str:
    """Create a JWT token for the admin user."""
    return create_access_token(
        user_id=str(admin_user.id),
        email=admin_user.email,
        roles=["admin"],
        permissions=["admin:manage"]
    )


@pytest.fixture
def auth_headers(user_token: str) -> dict:
    """Create authentication headers for requests."""
    return {"Authorization": f"Bearer {user_token}"}


@pytest.fixture
def admin_headers(admin_token: str) -> dict:
    """Create admin authentication headers for requests."""
    return {"Authorization": f"Bearer {admin_token}"}


# Test data fixtures
@pytest.fixture
def user_create_data():
    """Valid user creation data."""
    return {
        "email": "newuser@example.com",
        "password": "SecurePassword123!",
        "full_name": "New User",
    }


@pytest.fixture
def user_login_data():
    """Valid login data."""
    return {
        "username": "test@example.com",  # FastAPI OAuth2PasswordRequestForm uses 'username'
        "password": "testpassword123",
    }


@pytest.fixture
def admin_login_data():
    """Valid admin login data."""
    return {
        "username": "admin@example.com",
        "password": "adminpassword123",
    }


# Performance test fixtures
@pytest.fixture
def sample_users_data():
    """Sample data for bulk user operations."""
    return [
        {
            "email": f"user{i}@example.com",
            "password": "TestPassword123!",
            "full_name": f"User{i} Test",
        }
        for i in range(1, 11)  # 10 sample users
    ]


@pytest_asyncio.fixture
async def populated_database(db_session: AsyncSession, sample_users_data):
    """Database populated with sample data for performance testing."""
    # Create roles
    user_role = Role(name="user", description="Regular user", is_system=True)
    editor_role = Role(name="editor", description="Content editor", is_system=False)
    db_session.add_all([user_role, editor_role])
    await db_session.flush()

    # Create permissions
    permissions = [
        Permission(resource="posts", action="read", description="Read posts"),
        Permission(resource="posts", action="write", description="Write posts"),
        Permission(resource="users", action="read", description="Read users"),
    ]
    db_session.add_all(permissions)
    await db_session.flush()

    # Associate permissions with roles
    role_permissions = [
        RolePermission(role_id=user_role.id, permission_id=permissions[0].id),  # user can read posts
        RolePermission(role_id=editor_role.id, permission_id=permissions[0].id),  # editor can read posts
        RolePermission(role_id=editor_role.id, permission_id=permissions[1].id),  # editor can write posts
    ]
    db_session.add_all(role_permissions)

    # Create users
    users = []
    for i, user_data in enumerate(sample_users_data):
        user = User(
            email=user_data["email"],
            hashed_password=get_password_hash(user_data["password"]),
            full_name=user_data["full_name"],
            is_active=True,
            is_verified=True,
            is_superuser=False,
        )
        users.append(user)
        db_session.add(user)
    
    await db_session.flush()

    # Assign roles to users
    user_roles = []
    for i, user in enumerate(users):
        # Alternate between user and editor roles
        role = user_role if i % 2 == 0 else editor_role
        user_role_assignment = UserRole(user_id=user.id, role_id=role.id)
        user_roles.append(user_role_assignment)
        db_session.add(user_role_assignment)

    await db_session.commit()
    return {"users": users, "roles": [user_role, editor_role], "permissions": permissions}


# Pytest configuration
def pytest_configure(config):
    """Configure pytest with custom markers."""
    config.addinivalue_line(
        "markers", "unit: mark test as a unit test"
    )
    config.addinivalue_line(
        "markers", "integration: mark test as an integration test"
    )
    config.addinivalue_line(
        "markers", "e2e: mark test as an end-to-end test"
    )
    config.addinivalue_line(
        "markers", "performance: mark test as a performance test"
    )
    config.addinivalue_line(
        "markers", "slow: mark test as slow running"
    )


# Async test configuration
pytest_plugins = ("pytest_asyncio",)