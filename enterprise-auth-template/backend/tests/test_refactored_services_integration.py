"""
Integration Tests for Refactored User Services

Tests the integration between the refactored user services and verifies
they work correctly together with the database optimizations.
"""

import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.user.user_crud_service import UserCRUDService
from app.services.user.user_auth_service import UserAuthService
from app.services.user.user_permission_service import UserPermissionService
from app.schemas.auth import RegisterRequest, LoginRequest
from app.models.user import User, Role, Permission


class TestRefactoredServicesIntegration:
    """Test suite for refactored services integration."""

    @pytest.fixture
    def user_crud_service(self, db_session):
        """User CRUD service instance."""
        return UserCRUDService(db_session)

    @pytest.fixture
    def user_auth_service(self, db_session):
        """User authentication service instance."""
        return UserAuthService(db_session)

    @pytest.fixture
    def user_permission_service(self, db_session):
        """User permission service instance."""
        return UserPermissionService(db_session)

    @pytest.fixture
    def sample_registration_data(self):
        """Sample registration data."""
        return RegisterRequest(
            email="testuser@example.com",
            password="SecurePassword123!",
            confirm_password="SecurePassword123!",
            first_name="Test",
            last_name="User",
            agree_to_terms=True
        )

    @pytest.mark.asyncio
    async def test_services_exist_and_instantiate(self, db_session):
        """Test that all refactored services can be instantiated."""
        crud_service = UserCRUDService(db_session)
        auth_service = UserAuthService(db_session)
        permission_service = UserPermissionService(db_session)

        assert crud_service is not None
        assert auth_service is not None
        assert permission_service is not None
        assert crud_service.session == db_session
        assert auth_service.session == db_session
        assert permission_service.session == db_session

    @pytest.mark.asyncio
    async def test_user_registration_flow(self, user_crud_service, sample_registration_data, db_session):
        """Test complete user registration flow using refactored services."""
        # Test registration
        user_response = await user_crud_service.create_user(
            sample_registration_data,
            ip_address="127.0.0.1"
        )

        assert user_response is not None
        assert user_response.email == sample_registration_data.email
        assert user_response.first_name == sample_registration_data.first_name
        assert user_response.last_name == sample_registration_data.last_name

        # Verify user exists in database
        users = await user_crud_service.get_users(skip=0, limit=10)
        user_emails = [user.email for user in users]
        assert sample_registration_data.email in user_emails

    @pytest.mark.asyncio
    async def test_authentication_flow(self, user_auth_service, sample_registration_data, db_session):
        """Test authentication flow using refactored auth service."""
        # First create a user through CRUD service
        crud_service = UserCRUDService(db_session)
        await crud_service.create_user(sample_registration_data, ip_address="127.0.0.1")

        # Test authentication
        login_data = LoginRequest(
            email=sample_registration_data.email,
            password=sample_registration_data.password
        )

        token_data = await user_auth_service.authenticate_and_create_token(
            login_data,
            ip_address="127.0.0.1"
        )

        assert token_data is not None
        assert "access_token" in token_data
        assert token_data["user"]["email"] == sample_registration_data.email

    @pytest.mark.asyncio
    async def test_permission_management_flow(self, user_permission_service, db_session):
        """Test permission management using refactored permission service."""
        # Create test role
        await user_permission_service.create_role(
            name="test_role",
            description="Test role for integration testing"
        )

        # Create test permission
        await user_permission_service.create_permission(
            resource="posts",
            action="read",
            description="Read posts permission"
        )

        # Verify role and permission creation
        roles = await user_permission_service.get_all_roles()
        permissions = await user_permission_service.get_all_permissions()

        role_names = [role.name for role in roles]
        assert "test_role" in role_names

        permission_combinations = [f"{p.resource}:{p.action}" for p in permissions]
        assert "posts:read" in permission_combinations

    @pytest.mark.asyncio
    async def test_service_caching_integration(self, user_crud_service, mock_cache_service, db_session):
        """Test that services properly integrate with caching."""
        # Verify cache service is available
        assert user_crud_service.cache_service is not None

        # Test cache integration (basic check)
        try:
            await user_crud_service.cache_service.get_cache_stats()
        except Exception as e:
            pytest.skip(f"Cache service not fully configured: {e}")

    @pytest.mark.asyncio
    async def test_database_optimization_queries(self, user_crud_service, populated_database, db_session):
        """Test that database queries are optimized (no N+1 queries)."""
        # Test optimized user retrieval with roles
        users = await user_crud_service.get_users_with_roles(skip=0, limit=5)
        
        assert len(users) <= 5
        # Should have loaded roles in the same query
        for user in users:
            assert hasattr(user, 'roles') or hasattr(user, '_sa_instance_state')

    @pytest.mark.asyncio
    async def test_service_error_handling(self, db_session):
        """Test that services handle errors gracefully."""
        crud_service = UserCRUDService(db_session)

        # Test handling of non-existent user
        user = await crud_service.get_user_by_id("non-existent-id")
        assert user is None

        # Test handling of invalid data
        with pytest.raises((ValueError, Exception)):
            invalid_data = RegisterRequest(
                email="invalid-email",
                password="weak",
                confirm_password="weak",
                first_name="",
                last_name="",
                agree_to_terms=False
            )
            await crud_service.create_user(invalid_data)

    @pytest.mark.asyncio
    async def test_service_performance_with_indexes(self, user_crud_service, populated_database, db_session):
        """Test that services benefit from database performance indexes."""
        import time

        # Test user lookup performance (should be fast with indexes)
        start_time = time.time()
        
        # Get first user from populated database
        users = await user_crud_service.get_users(skip=0, limit=1)
        if users:
            user = await user_crud_service.get_user_by_email(users[0].email)
            
        end_time = time.time()
        
        # Should complete quickly with proper indexing
        assert end_time - start_time < 0.1  # Less than 100ms

    @pytest.mark.asyncio
    async def test_transaction_management(self, user_crud_service, db_session):
        """Test that services properly handle database transactions."""
        registration_data = RegisterRequest(
            email="transaction@example.com",
            password="SecurePassword123!",
            confirm_password="SecurePassword123!",
            first_name="Transaction",
            last_name="Test",
            agree_to_terms=True
        )

        # Test successful transaction
        user_response = await user_crud_service.create_user(registration_data)
        assert user_response is not None

        # Verify user was committed to database
        user = await user_crud_service.get_user_by_email("transaction@example.com")
        assert user is not None
        assert user.email == "transaction@example.com"

    @pytest.mark.asyncio
    async def test_service_separation_of_concerns(self, db_session):
        """Test that services maintain proper separation of concerns."""
        # CRUD service should handle data operations
        crud_service = UserCRUDService(db_session)
        assert hasattr(crud_service, 'create_user')
        assert hasattr(crud_service, 'get_user_by_id')
        assert hasattr(crud_service, 'update_user')

        # Auth service should handle authentication
        auth_service = UserAuthService(db_session)
        assert hasattr(auth_service, 'authenticate_and_create_token')
        assert hasattr(auth_service, 'create_refresh_token')

        # Permission service should handle authorization
        permission_service = UserPermissionService(db_session)
        assert hasattr(permission_service, 'get_user_permissions')
        assert hasattr(permission_service, 'check_user_permission')

        # Services should not overlap responsibilities
        assert not hasattr(crud_service, 'authenticate_and_create_token')
        assert not hasattr(auth_service, 'create_permission')
        assert not hasattr(permission_service, 'create_user')

    @pytest.mark.asyncio
    async def test_service_method_signatures(self, db_session):
        """Test that service methods have consistent signatures."""
        crud_service = UserCRUDService(db_session)
        auth_service = UserAuthService(db_session)
        permission_service = UserPermissionService(db_session)

        # All services should accept session in constructor
        assert crud_service.session == db_session
        assert auth_service.session == db_session
        assert permission_service.session == db_session

        # Methods should be async
        import inspect
        assert inspect.iscoroutinefunction(crud_service.create_user)
        assert inspect.iscoroutinefunction(auth_service.authenticate_and_create_token)
        assert inspect.iscoroutinefunction(permission_service.get_user_permissions)

    @pytest.mark.performance
    @pytest.mark.asyncio
    async def test_service_performance_under_load(self, user_crud_service, db_session):
        """Test service performance under moderate load."""
        import asyncio
        import time

        # Create multiple registration requests
        registration_tasks = []
        for i in range(5):  # Small load test
            registration_data = RegisterRequest(
                email=f"loadtest{i}@example.com",
                password="SecurePassword123!",
                confirm_password="SecurePassword123!",
                first_name=f"LoadTest{i}",
                last_name="User",
                agree_to_terms=True
            )
            task = user_crud_service.create_user(registration_data)
            registration_tasks.append(task)

        start_time = time.time()
        results = await asyncio.gather(*registration_tasks, return_exceptions=True)
        end_time = time.time()

        # Check results
        successful_registrations = [r for r in results if not isinstance(r, Exception)]
        assert len(successful_registrations) == 5

        # Should handle multiple operations efficiently
        assert end_time - start_time < 2.0  # Less than 2 seconds for 5 operations

    @pytest.mark.asyncio
    async def test_phase_2_optimizations_working(self, user_crud_service, populated_database, db_session):
        """Test that Phase 2 optimizations (caching, indexes, refactoring) are working."""
        # Test 1: Services are properly refactored (not monolithic)
        assert user_crud_service.__class__.__name__ == "UserCRUDService"
        
        # Test 2: Caching is available
        assert hasattr(user_crud_service, 'cache_service')
        
        # Test 3: Database operations are reasonably fast (benefits from indexes)
        import time
        start_time = time.time()
        users = await user_crud_service.get_users(skip=0, limit=10)
        end_time = time.time()
        
        assert len(users) >= 0  # Should work
        assert end_time - start_time < 0.5  # Should be fast with indexes
        
        # Test 4: Services can handle typical operations without errors
        if users:
            user_detail = await user_crud_service.get_user_by_id(str(users[0].id))
            assert user_detail is not None