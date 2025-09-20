"""
User Repository Implementation

Concrete implementation of the IUserRepository interface for user data access.
"""

from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

from sqlalchemy import select, update, delete, func, or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.user import User, UserRole
from app.models.role import Role
from app.repositories.interfaces import IUserRepository


class UserRepository(IUserRepository):
    """Concrete implementation of the User repository."""

    def __init__(self, session: AsyncSession):
        """
        Initialize the user repository.

        Args:
            session: SQLAlchemy async session
        """
        self.session = session

    async def find_by_id(self, user_id: UUID) -> Optional[User]:
        """Find a user by their ID."""
        stmt = select(User).where(User.id == user_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_email(self, email: str) -> Optional[User]:
        """Find a user by their email address."""
        stmt = select(User).where(User.email == email)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_username(self, username: str) -> Optional[User]:
        """Find a user by their username."""
        stmt = select(User).where(User.username == username)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def create(self, user_data: Dict[str, Any]) -> User:
        """Create a new user."""
        user = User(**user_data)
        self.session.add(user)
        await self.session.flush()
        return user

    async def update(self, user_id: UUID, user_data: Dict[str, Any]) -> Optional[User]:
        """Update an existing user."""
        stmt = (
            update(User).where(User.id == user_id).values(**user_data).returning(User)
        )
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def delete(self, user_id: UUID) -> bool:
        """Delete a user by their ID."""
        stmt = delete(User).where(User.id == user_id)
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def list_all(self, skip: int = 0, limit: int = 100) -> List[User]:
        """List all users with pagination."""
        stmt = select(User).offset(skip).limit(limit)
        result = await self.session.execute(stmt)
        return list(result.scalars().all())

    async def find_by_phone(self, phone_number: str) -> Optional[User]:
        """Find a user by their phone number."""
        stmt = select(User).where(User.phone_number == phone_number)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_oauth_provider(
        self, provider: str, provider_id: str
    ) -> Optional[User]:
        """Find a user by OAuth provider and provider ID."""
        conditions = []

        if provider.lower() == "google":
            conditions.append(User.google_id == provider_id)
        elif provider.lower() == "github":
            conditions.append(User.github_id == provider_id)
        elif provider.lower() == "discord":
            conditions.append(User.discord_id == provider_id)
        elif provider.lower() == "microsoft":
            conditions.append(User.microsoft_id == provider_id)

        if not conditions:
            return None

        stmt = select(User).where(or_(*conditions))
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def count(self) -> int:
        """Count total number of users."""
        stmt = select(func.count()).select_from(User)
        result = await self.session.execute(stmt)
        return result.scalar() or 0

    async def exists_by_email(self, email: str) -> bool:
        """Check if a user exists with the given email."""
        stmt = select(func.count()).select_from(User).where(User.email == email)
        result = await self.session.execute(stmt)
        return (result.scalar() or 0) > 0

    async def update_last_login(self, user_id: UUID, login_time: datetime) -> bool:
        """Update user's last login timestamp."""
        stmt = update(User).where(User.id == user_id).values(last_login=login_time)
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def update_password(self, user_id: UUID, hashed_password: str) -> bool:
        """Update user's password."""
        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(hashed_password=hashed_password, updated_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def increment_failed_attempts(self, user_id: UUID) -> int:
        """Increment failed login attempts and return new count."""
        # Get current count
        user = await self.find_by_id(user_id)
        if not user:
            return 0

        new_count = user.failed_login_attempts + 1

        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(failed_login_attempts=new_count)
        )
        await self.session.execute(stmt)
        return new_count

    async def reset_failed_attempts(self, user_id: UUID) -> bool:
        """Reset failed login attempts to zero."""
        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(failed_login_attempts=0, locked_until=None)
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def lock_account(self, user_id: UUID, until: datetime) -> bool:
        """Lock user account until specified time."""
        stmt = update(User).where(User.id == user_id).values(locked_until=until)
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def find_with_roles(self, user_id: UUID) -> Optional[User]:
        """Find a user with their roles loaded."""
        stmt = select(User).options(selectinload(User.roles)).where(User.id == user_id)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def find_by_email_with_roles(self, email: str) -> Optional[User]:
        """Find a user by email with their roles loaded."""
        stmt = select(User).options(selectinload(User.roles)).where(User.email == email)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def verify_email(self, user_id: UUID) -> bool:
        """Mark user's email as verified."""
        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(
                email_verified=True,  # Primary field for email verification
                # Don't modify is_active - it's for account suspension, not verification
                email_verified_at=datetime.utcnow(),
                updated_at=datetime.utcnow(),
            )
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def activate_account(self, user_id: UUID) -> bool:
        """Activate a user account."""
        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(is_active=True, updated_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0

    async def deactivate_account(self, user_id: UUID) -> bool:
        """Deactivate a user account."""
        stmt = (
            update(User)
            .where(User.id == user_id)
            .values(is_active=False, updated_at=datetime.utcnow())
        )
        result = await self.session.execute(stmt)
        return result.rowcount > 0
