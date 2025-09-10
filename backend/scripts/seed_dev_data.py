#!/usr/bin/env python3
"""
Database seeding script for development environment.
Creates test users, roles, and sample data for testing.
"""

import asyncio
import logging
import sys
from pathlib import Path
from typing import List

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.database import async_session_maker, engine
from app.core.security import get_password_hash
from app.models.user import User
from app.models.role import Role, Permission
from app.models.user_session import UserSession
import secrets
from datetime import datetime, timedelta

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class DevDataSeeder:
    """Handles seeding of development data."""
    
    def __init__(self):
        self.session = None
        self.roles = {}
        self.permissions = {}
        self.users = {}
        
    async def __aenter__(self):
        """Async context manager entry."""
        self.session = async_session_maker()
        return self
        
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit."""
        if self.session:
            await self.session.close()
    
    async def seed_all(self):
        """Main seeding function."""
        try:
            logger.info("Starting database seeding...")
            
            # Check if data already exists
            if await self.data_exists():
                logger.info("Development data already exists. Skipping seeding.")
                return
            
            # Seed in order
            await self.seed_permissions()
            await self.seed_roles()
            await self.seed_users()
            await self.seed_test_sessions()
            
            await self.session.commit()
            logger.info("✅ Database seeding completed successfully!")
            
        except Exception as e:
            logger.error(f"❌ Error during seeding: {e}")
            await self.session.rollback()
            raise
    
    async def data_exists(self) -> bool:
        """Check if development data already exists."""
        result = await self.session.execute(
            select(User).where(User.email == "admin@example.com")
        )
        return result.scalar_one_or_none() is not None
    
    async def seed_permissions(self):
        """Create default permissions."""
        logger.info("Creating permissions...")
        
        permission_data = [
            # User permissions
            {"name": "users:read", "description": "View users"},
            {"name": "users:write", "description": "Create/update users"},
            {"name": "users:delete", "description": "Delete users"},
            
            # Role permissions
            {"name": "roles:read", "description": "View roles"},
            {"name": "roles:write", "description": "Create/update roles"},
            {"name": "roles:delete", "description": "Delete roles"},
            
            # Admin permissions
            {"name": "admin:access", "description": "Access admin panel"},
            {"name": "admin:manage", "description": "Manage system settings"},
            
            # API permissions
            {"name": "api:full_access", "description": "Full API access"},
        ]
        
        for perm_data in permission_data:
            permission = Permission(**perm_data)
            self.session.add(permission)
            self.permissions[perm_data["name"]] = permission
        
        await self.session.flush()
        logger.info(f"Created {len(permission_data)} permissions")
    
    async def seed_roles(self):
        """Create default roles."""
        logger.info("Creating roles...")
        
        # Admin role - all permissions
        admin_role = Role(
            name="admin",
            description="Administrator with full access",
            permissions=list(self.permissions.values())
        )
        self.session.add(admin_role)
        self.roles["admin"] = admin_role
        
        # User role - basic permissions
        user_role = Role(
            name="user",
            description="Regular user with basic access",
            permissions=[
                self.permissions["users:read"],
            ]
        )
        self.session.add(user_role)
        self.roles["user"] = user_role
        
        # Manager role - intermediate permissions
        manager_role = Role(
            name="manager",
            description="Manager with elevated access",
            permissions=[
                self.permissions["users:read"],
                self.permissions["users:write"],
                self.permissions["roles:read"],
            ]
        )
        self.session.add(manager_role)
        self.roles["manager"] = manager_role
        
        await self.session.flush()
        logger.info(f"Created {len(self.roles)} roles")
    
    async def seed_users(self):
        """Create test users."""
        logger.info("Creating test users...")
        
        users_data = [
            {
                "email": "admin@example.com",
                "name": "Admin User",
                "password": "Admin123!@#",
                "role": "admin",
                "is_email_verified": True,
                "is_active": True,
                "is_2fa_enabled": False,
            },
            {
                "email": "john.doe@example.com",
                "name": "John Doe",
                "password": "User123!@#",
                "role": "user",
                "is_email_verified": True,
                "is_active": True,
                "is_2fa_enabled": False,
            },
            {
                "email": "jane.manager@example.com",
                "name": "Jane Manager",
                "password": "Manager123!@#",
                "role": "manager",
                "is_email_verified": True,
                "is_active": True,
                "is_2fa_enabled": True,
                "two_factor_secret": "JBSWY3DPEHPK3PXP",  # Example secret
            },
            {
                "email": "unverified@example.com",
                "name": "Unverified User",
                "password": "Test123!@#",
                "role": "user",
                "is_email_verified": False,
                "is_active": True,
                "is_2fa_enabled": False,
            },
            {
                "email": "inactive@example.com",
                "name": "Inactive User",
                "password": "Test123!@#",
                "role": "user",
                "is_email_verified": True,
                "is_active": False,
                "is_2fa_enabled": False,
            },
            {
                "email": "oauth.user@example.com",
                "name": "OAuth User",
                "password": None,  # OAuth user without password
                "role": "user",
                "is_email_verified": True,
                "is_active": True,
                "is_2fa_enabled": False,
                "oauth_provider": "google",
            },
        ]
        
        for user_data in users_data:
            role_name = user_data.pop("role")
            password = user_data.pop("password")
            
            user = User(
                **user_data,
                hashed_password=get_password_hash(password) if password else None,
                email_verification_token=secrets.token_urlsafe(32) if not user_data.get("is_email_verified") else None,
            )
            
            # Add role
            user.roles.append(self.roles[role_name])
            
            self.session.add(user)
            self.users[user.email] = user
        
        await self.session.flush()
        logger.info(f"Created {len(users_data)} test users")
        
        # Print login credentials
        logger.info("\n" + "="*50)
        logger.info("📧 TEST USER CREDENTIALS:")
        logger.info("="*50)
        for user_data in users_data[:3]:  # Show first 3 users
            if user_data.get("password"):
                logger.info(f"Email: {user_data['email']}")
                logger.info(f"Password: {user_data['password']}")
                logger.info("-"*30)
    
    async def seed_test_sessions(self):
        """Create some active sessions for testing."""
        logger.info("Creating test sessions...")
        
        # Create active session for admin
        admin_user = self.users["admin@example.com"]
        session = UserSession(
            user_id=admin_user.id,
            token=secrets.token_urlsafe(32),
            ip_address="127.0.0.1",
            user_agent="Mozilla/5.0 (Development Testing)",
            expires_at=datetime.utcnow() + timedelta(days=7),
            last_activity=datetime.utcnow(),
            is_active=True,
        )
        self.session.add(session)
        
        await self.session.flush()
        logger.info("Created test sessions")


async def main():
    """Main function to run the seeding script."""
    try:
        async with DevDataSeeder() as seeder:
            await seeder.seed_all()
            
        logger.info("\n" + "="*50)
        logger.info("🚀 DEVELOPMENT ENVIRONMENT READY!")
        logger.info("="*50)
        logger.info("\nYou can now:")
        logger.info("1. Access the API at: http://localhost:8000")
        logger.info("2. View API docs at: http://localhost:8000/docs")
        logger.info("3. Check emails at: http://localhost:8025 (MailHog)")
        logger.info("4. Access database at: localhost:5432 (PostgreSQL)")
        logger.info("5. View cache at: localhost:6379 (Redis)")
        logger.info("\n" + "="*50)
        
    except Exception as e:
        logger.error(f"Failed to seed database: {e}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())