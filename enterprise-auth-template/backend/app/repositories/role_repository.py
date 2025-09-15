"""
Role Repository Implementation

Concrete implementation of the IRoleRepository interface for role data access.
"""

from typing import Optional, List, Dict, Any
from uuid import UUID

from sqlalchemy import select, delete, and_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.role import Role
from app.models.user import User, UserRole
from app.repositories.interfaces import IRoleRepository


class RoleRepository(IRoleRepository):
    """Concrete implementation of the Role repository."""

    def __init__(self, session: AsyncSession):
        """
        Initialize the role repository.

        Args:
            session: SQLAlchemy async session
        """
        self.session = session

    async def find_by_id(self, role_id: UUID) -> Optional[Role]:
        """Find a role by ID."""
        stmt = select(Role).where(Role.id == role_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_name(self, name: str) -> Optional[Role]:
        """Find a role by name."""
        stmt = select(Role).where(Role.name == name)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, role_data: Dict[str, Any]) -> Role:
        """Create a new role."""
        role = Role(**role_data)
        self.session.add(role)
        await self.session.flush()
        return role

    async def update(self, role_id: UUID, role_data: Dict[str, Any]) -> Optional[Role]:
        """Update an existing role."""
        role = await self.find_by_id(role_id)
        if role:
            for key, value in role_data.items():
                setattr(role, key, value)
            await self.session.flush()
        return role

    async def delete(self, role_id: UUID) -> bool:
        """Delete a role."""
        stmt = delete(Role).where(Role.id == role_id)
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def list_all(self) -> List[Role]:
        """List all roles."""
        stmt = select(Role)
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def assign_to_user(self, user_id: UUID, role_id: UUID) -> bool:
        """Assign a role to a user."""
        # Check if assignment already exists
        stmt = select(UserRole).where(
            and_(
                UserRole.user_id == user_id,
                UserRole.role_id == role_id
            )
        )
        result = await self.session.execute(stmt)

        if result.scalar_one_or_none():
            return False  # Already assigned

        # Create new assignment
        user_role = UserRole(user_id=user_id, role_id=role_id)
        self.session.add(user_role)
        await self.session.flush()
        return True

    async def remove_from_user(self, user_id: UUID, role_id: UUID) -> bool:
        """Remove a role from a user."""
        stmt = delete(UserRole).where(
            and_(
                UserRole.user_id == user_id,
                UserRole.role_id == role_id
            )
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def get_user_roles(self, user_id: UUID) -> List[Role]:
        """Get all roles assigned to a user."""
        stmt = (
            select(Role)
            .join(UserRole)
            .where(UserRole.user_id == user_id)
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def get_role_users(self, role_id: UUID) -> List[User]:
        """Get all users with a specific role."""
        stmt = (
            select(User)
            .join(UserRole)
            .where(UserRole.role_id == role_id)
        )
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def find_with_permissions(self, role_id: UUID) -> Optional[Role]:
        """Find a role with its permissions loaded."""
        stmt = (
            select(Role)
            .options(selectinload(Role.permissions))
            .where(Role.id == role_id)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()