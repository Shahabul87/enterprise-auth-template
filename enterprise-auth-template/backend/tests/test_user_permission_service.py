"""
Tests for User Permission Service

Tests the permission management operations implemented in the refactored
user_permission_service module, including role assignments and permission checks.
"""

import pytest
from unittest.mock import AsyncMock, patch
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.user.user_permission_service import UserPermissionService
from app.models.user import User, UserRole, RolePermission
from app.models.role import Role
from app.models.permission import Permission
from app.core.security import get_password_hash


class TestUserPermissionService:
    """Test suite for UserPermissionService functionality."""

    @pytest.fixture
    def user_permission_service(self):
        """User permission service instance."""
        return UserPermissionService()

    @pytest.fixture
    def sample_roles_and_permissions(self, db_session):
        """Create sample roles and permissions for testing."""
        # Create permissions
        read_posts = Permission(
            resource="posts",
            action="read",
            description="Read posts permission"
        )
        write_posts = Permission(
            resource="posts", 
            action="write",
            description="Write posts permission"
        )
        admin_manage = Permission(
            resource="admin",
            action="manage", 
            description="Admin management permission"
        )
        
        db_session.add_all([read_posts, write_posts, admin_manage])
        
        # Create roles
        user_role = Role(
            name="user",
            description="Basic user role",
            is_system=True
        )
        editor_role = Role(
            name="editor", 
            description="Content editor role",
            is_system=False
        )
        admin_role = Role(
            name="admin",
            description="Administrator role", 
            is_system=True
        )
        
        db_session.add_all([user_role, editor_role, admin_role])
        return {
            'roles': {'user': user_role, 'editor': editor_role, 'admin': admin_role},
            'permissions': {'read_posts': read_posts, 'write_posts': write_posts, 'admin_manage': admin_manage}
        }

    @pytest.mark.asyncio
    async def test_get_user_permissions(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test retrieving user permissions."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()
        
        # Assign permissions to roles
        user_role_perm = RolePermission(
            role_id=roles['user'].id, 
            permission_id=permissions['read_posts'].id
        )
        editor_role_perm1 = RolePermission(
            role_id=roles['editor'].id,
            permission_id=permissions['read_posts'].id
        )
        editor_role_perm2 = RolePermission(
            role_id=roles['editor'].id,
            permission_id=permissions['write_posts'].id
        )
        
        db_session.add_all([user_role_perm, editor_role_perm1, editor_role_perm2])
        
        # Assign roles to user
        user_role_assignment = UserRole(user_id=test_user.id, role_id=roles['editor'].id)
        db_session.add(user_role_assignment)
        
        await db_session.commit()

        # Get user permissions
        user_permissions = await user_permission_service.get_user_permissions(
            db_session, test_user.id
        )

        permission_actions = [f"{p.resource}:{p.action}" for p in user_permissions]
        assert "posts:read" in permission_actions
        assert "posts:write" in permission_actions

    @pytest.mark.asyncio
    async def test_get_user_roles(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test retrieving user roles."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # Assign multiple roles to user
        user_role_assignment1 = UserRole(user_id=test_user.id, role_id=roles['user'].id)
        user_role_assignment2 = UserRole(user_id=test_user.id, role_id=roles['editor'].id)
        db_session.add_all([user_role_assignment1, user_role_assignment2])
        
        await db_session.commit()

        # Get user roles
        user_roles = await user_permission_service.get_user_roles(db_session, test_user.id)

        role_names = [role.name for role in user_roles]
        assert "user" in role_names
        assert "editor" in role_names
        assert len(user_roles) == 2

    @pytest.mark.asyncio
    async def test_check_user_permission(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test checking if user has specific permission."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()

        # Assign permission to role and role to user
        role_permission = RolePermission(
            role_id=roles['editor'].id,
            permission_id=permissions['write_posts'].id
        )
        user_role_assignment = UserRole(user_id=test_user.id, role_id=roles['editor'].id)
        
        db_session.add_all([role_permission, user_role_assignment])
        await db_session.commit()

        # Check permission
        has_permission = await user_permission_service.check_user_permission(
            db_session, test_user.id, "posts", "write"
        )
        
        assert has_permission is True

        # Check permission user doesn't have
        has_admin_permission = await user_permission_service.check_user_permission(
            db_session, test_user.id, "admin", "manage"
        )
        
        assert has_admin_permission is False

    @pytest.mark.asyncio
    async def test_check_user_role(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test checking if user has specific role."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # Assign role to user
        user_role_assignment = UserRole(user_id=test_user.id, role_id=roles['editor'].id)
        db_session.add(user_role_assignment)
        await db_session.commit()

        # Check role
        has_role = await user_permission_service.check_user_role(
            db_session, test_user.id, "editor"
        )
        
        assert has_role is True

        # Check role user doesn't have
        has_admin_role = await user_permission_service.check_user_role(
            db_session, test_user.id, "admin"
        )
        
        assert has_admin_role is False

    @pytest.mark.asyncio
    async def test_assign_role_to_user(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test assigning role to user."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # Assign role
        success = await user_permission_service.assign_role_to_user(
            db_session, test_user.id, roles['editor'].id
        )
        
        assert success is True

        # Verify assignment
        has_role = await user_permission_service.check_user_role(
            db_session, test_user.id, "editor"
        )
        
        assert has_role is True

    @pytest.mark.asyncio
    async def test_assign_duplicate_role(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test assigning duplicate role to user."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # Assign role twice
        await user_permission_service.assign_role_to_user(
            db_session, test_user.id, roles['editor'].id
        )
        
        # Second assignment should not fail but return False
        success = await user_permission_service.assign_role_to_user(
            db_session, test_user.id, roles['editor'].id
        )
        
        assert success is False

    @pytest.mark.asyncio
    async def test_remove_role_from_user(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test removing role from user."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # First assign role
        await user_permission_service.assign_role_to_user(
            db_session, test_user.id, roles['editor'].id
        )

        # Then remove it
        success = await user_permission_service.remove_role_from_user(
            db_session, test_user.id, roles['editor'].id
        )
        
        assert success is True

        # Verify removal
        has_role = await user_permission_service.check_user_role(
            db_session, test_user.id, "editor"
        )
        
        assert has_role is False

    @pytest.mark.asyncio
    async def test_remove_nonexistent_role(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test removing role user doesn't have."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # Try to remove role user doesn't have
        success = await user_permission_service.remove_role_from_user(
            db_session, test_user.id, roles['admin'].id
        )
        
        assert success is False

    @pytest.mark.asyncio
    async def test_get_role_permissions(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test getting permissions for a specific role."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()

        # Assign permissions to role
        role_perms = [
            RolePermission(role_id=roles['editor'].id, permission_id=permissions['read_posts'].id),
            RolePermission(role_id=roles['editor'].id, permission_id=permissions['write_posts'].id)
        ]
        db_session.add_all(role_perms)
        await db_session.commit()

        # Get role permissions
        role_permissions = await user_permission_service.get_role_permissions(
            db_session, roles['editor'].id
        )

        permission_actions = [f"{p.resource}:{p.action}" for p in role_permissions]
        assert "posts:read" in permission_actions
        assert "posts:write" in permission_actions
        assert len(role_permissions) == 2

    @pytest.mark.asyncio
    async def test_create_permission(self, user_permission_service, db_session):
        """Test creating new permission."""
        permission = await user_permission_service.create_permission(
            db_session,
            resource="comments",
            action="delete",
            description="Delete comments permission"
        )

        assert permission is not None
        assert permission.resource == "comments"
        assert permission.action == "delete"
        assert permission.description == "Delete comments permission"

    @pytest.mark.asyncio
    async def test_create_duplicate_permission(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test creating duplicate permission."""
        await db_session.flush()

        with pytest.raises(ValueError, match="Permission already exists"):
            await user_permission_service.create_permission(
                db_session,
                resource="posts",
                action="read",
                description="Duplicate permission"
            )

    @pytest.mark.asyncio
    async def test_create_role(self, user_permission_service, db_session):
        """Test creating new role."""
        role = await user_permission_service.create_role(
            db_session,
            name="moderator",
            description="Content moderator role",
            is_system=False
        )

        assert role is not None
        assert role.name == "moderator"
        assert role.description == "Content moderator role"
        assert role.is_system is False

    @pytest.mark.asyncio
    async def test_create_duplicate_role(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test creating duplicate role."""
        await db_session.flush()

        with pytest.raises(ValueError, match="Role already exists"):
            await user_permission_service.create_role(
                db_session,
                name="admin",
                description="Duplicate admin role"
            )

    @pytest.mark.asyncio
    async def test_assign_permission_to_role(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test assigning permission to role."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()

        # Assign permission to role
        success = await user_permission_service.assign_permission_to_role(
            db_session, roles['user'].id, permissions['read_posts'].id
        )
        
        assert success is True

        # Verify assignment
        role_permissions = await user_permission_service.get_role_permissions(
            db_session, roles['user'].id
        )
        
        permission_actions = [f"{p.resource}:{p.action}" for p in role_permissions]
        assert "posts:read" in permission_actions

    @pytest.mark.asyncio
    async def test_remove_permission_from_role(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test removing permission from role."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()

        # First assign permission
        await user_permission_service.assign_permission_to_role(
            db_session, roles['user'].id, permissions['read_posts'].id
        )

        # Then remove it
        success = await user_permission_service.remove_permission_from_role(
            db_session, roles['user'].id, permissions['read_posts'].id
        )
        
        assert success is True

        # Verify removal
        role_permissions = await user_permission_service.get_role_permissions(
            db_session, roles['user'].id
        )
        
        assert len(role_permissions) == 0

    @pytest.mark.asyncio
    async def test_get_all_permissions(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test getting all available permissions."""
        await db_session.flush()

        all_permissions = await user_permission_service.get_all_permissions(db_session)

        assert len(all_permissions) >= 3  # At least our sample permissions
        permission_combinations = [f"{p.resource}:{p.action}" for p in all_permissions]
        assert "posts:read" in permission_combinations
        assert "posts:write" in permission_combinations
        assert "admin:manage" in permission_combinations

    @pytest.mark.asyncio
    async def test_get_all_roles(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test getting all available roles."""
        await db_session.flush()

        all_roles = await user_permission_service.get_all_roles(db_session)

        assert len(all_roles) >= 3  # At least our sample roles
        role_names = [role.name for role in all_roles]
        assert "user" in role_names
        assert "editor" in role_names
        assert "admin" in role_names

    @pytest.mark.asyncio
    async def test_superuser_has_all_permissions(self, user_permission_service, db_session):
        """Test that superuser has all permissions regardless of roles."""
        # Create superuser
        superuser = User(
            email="super@example.com",
            hashed_password=get_password_hash("password"),
            first_name="Super",
            last_name="User",
            is_active=True,
            is_verified=True,
            is_superuser=True,
        )
        db_session.add(superuser)
        await db_session.flush()

        # Check any permission without assigning roles
        has_permission = await user_permission_service.check_user_permission(
            db_session, superuser.id, "admin", "manage"
        )
        
        assert has_permission is True

    @pytest.mark.asyncio
    async def test_inactive_user_no_permissions(self, user_permission_service, sample_roles_and_permissions, db_session):
        """Test that inactive users have no permissions."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        # Create inactive user
        inactive_user = User(
            email="inactive@example.com",
            hashed_password=get_password_hash("password"),
            first_name="Inactive",
            last_name="User",
            is_active=False,  # Inactive
            is_verified=True,
            is_superuser=False,
        )
        db_session.add(inactive_user)
        await db_session.flush()

        # Assign role with permission
        user_role_assignment = UserRole(user_id=inactive_user.id, role_id=roles['editor'].id)
        role_permission = RolePermission(
            role_id=roles['editor'].id,
            permission_id=permissions['write_posts'].id
        )
        db_session.add_all([user_role_assignment, role_permission])
        await db_session.commit()

        # Check permission - should be False for inactive user
        has_permission = await user_permission_service.check_user_permission(
            db_session, inactive_user.id, "posts", "write"
        )
        
        assert has_permission is False

    @pytest.mark.asyncio
    async def test_bulk_assign_roles(self, user_permission_service, sample_roles_and_permissions, populated_database, db_session):
        """Test bulk role assignment to multiple users."""
        roles = sample_roles_and_permissions['roles']
        await db_session.flush()

        # Get some users from populated database
        users_result = await db_session.execute("SELECT id FROM users LIMIT 3")
        user_ids = [row[0] for row in users_result]

        # Bulk assign editor role
        assigned_count = await user_permission_service.bulk_assign_role(
            db_session, user_ids, roles['editor'].id
        )

        assert assigned_count == 3

        # Verify assignments
        for user_id in user_ids:
            has_role = await user_permission_service.check_user_role(
                db_session, user_id, "editor"
            )
            assert has_role is True

    @pytest.mark.asyncio
    async def test_permission_caching_integration(self, user_permission_service, test_user, mock_cache_service, db_session):
        """Test permission service integration with caching."""
        # Mock cache service
        mock_cache_service.get_user_permissions.return_value = ["posts:read", "posts:write"]
        
        permissions = await user_permission_service.get_user_permissions_cached(
            db_session, test_user.id, mock_cache_service
        )

        assert permissions == ["posts:read", "posts:write"]
        mock_cache_service.get_user_permissions.assert_called_once_with(str(test_user.id))

    @pytest.mark.asyncio
    async def test_optimized_queries_no_n_plus_one(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test that permission queries are optimized (no N+1 queries)."""
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()

        # Set up user with multiple roles and permissions
        role_assignments = [
            UserRole(user_id=test_user.id, role_id=roles['user'].id),
            UserRole(user_id=test_user.id, role_id=roles['editor'].id)
        ]
        role_permissions = [
            RolePermission(role_id=roles['user'].id, permission_id=permissions['read_posts'].id),
            RolePermission(role_id=roles['editor'].id, permission_id=permissions['write_posts'].id)
        ]
        
        db_session.add_all(role_assignments + role_permissions)
        await db_session.commit()

        # Get permissions using optimized query
        user_permissions = await user_permission_service.get_user_permissions_optimized(
            db_session, test_user.id
        )

        # Should have both permissions
        permission_actions = [f"{p.resource}:{p.action}" for p in user_permissions]
        assert "posts:read" in permission_actions
        assert "posts:write" in permission_actions

    @pytest.mark.asyncio
    async def test_error_handling(self, user_permission_service, db_session):
        """Test service error handling."""
        with patch.object(db_session, 'execute', side_effect=Exception("Database error")):
            with pytest.raises(Exception, match="Database error"):
                await user_permission_service.get_user_permissions(db_session, "test-id")

    @pytest.mark.performance
    @pytest.mark.asyncio
    async def test_permission_check_performance(self, user_permission_service, test_user, sample_roles_and_permissions, db_session):
        """Test permission check performance with proper indexing."""
        import time
        
        roles = sample_roles_and_permissions['roles']
        permissions = sample_roles_and_permissions['permissions']
        
        await db_session.flush()

        # Set up permission chain
        user_role_assignment = UserRole(user_id=test_user.id, role_id=roles['editor'].id)
        role_permission = RolePermission(
            role_id=roles['editor'].id,
            permission_id=permissions['write_posts'].id
        )
        db_session.add_all([user_role_assignment, role_permission])
        await db_session.commit()

        start_time = time.time()
        
        # Perform permission check
        has_permission = await user_permission_service.check_user_permission(
            db_session, test_user.id, "posts", "write"
        )
        
        end_time = time.time()
        
        assert has_permission is True
        # Permission check should be fast with proper indexes (< 50ms)
        assert end_time - start_time < 0.05