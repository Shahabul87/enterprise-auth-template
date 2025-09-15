#!/usr/bin/env python3
"""
Auth Smoke Test (self-contained, no external services)

Runs a minimal end-to-end authentication flow against the services layer
using an in-repo SQLite database:

1) Register user (inactive + unverified)
2) Verify email via EmailVerificationService (using token from DB)
3) Authenticate user and print access/refresh tokens

This avoids HTTP and external Postgres requirements and validates the
fixed flow works as intended.
"""

import asyncio
import os
import uuid
import sys
from pathlib import Path
from sqlalchemy import select

# Ensure backend/ is on PYTHONPATH
THIS_DIR = Path(__file__).resolve().parent
BACKEND_ROOT = THIS_DIR.parent
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))

# Configure test environment BEFORE importing app modules
os.environ.setdefault("ENVIRONMENT", "test")
os.environ.setdefault("TESTING", "true")
os.environ.setdefault("DATABASE_URL", "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth_test")
os.chdir(str(BACKEND_ROOT))

from app.core.database import init_db, create_tables, async_session_maker
from app.repositories.user_repository import UserRepository
from app.services.auth.registration_service import RegistrationService
from app.services.auth.email_verification_service import EmailVerificationService
from app.services.auth.authentication_service import AuthenticationService
from app.schemas.auth import RegisterRequest
from app.models.auth import EmailVerificationToken


async def run():
    # Initialize DB and create tables
    await init_db()
    await create_tables()

    # Unique test credentials
    email = f"smoke+{uuid.uuid4().hex[:8]}@example.com"
    password = "SmokePass123!"
    full_name = "Smoke Test User"

    async with async_session_maker() as session:
        user_repo = UserRepository(session)

        # 1) Register user (should be inactive + unverified)
        registration_service = RegistrationService(session, user_repo)
        reg_req = RegisterRequest(
            email=email,
            password=password,
            full_name=full_name,
            agree_to_terms=True,
        )
        reg_resp = await registration_service.register_user(reg_req)
        print("[1] Registered:", reg_resp.email, "isEmailVerified=", reg_resp.isEmailVerified)

        user = await user_repo.find_by_email(email)
        assert user is not None and user.is_active is False and user.email_verified is False

        # 2) Verify email using token from DB
        token_stmt = select(EmailVerificationToken).where(
            EmailVerificationToken.user_id == user.id,
            EmailVerificationToken.is_used.is_(False),
        )
        token = (await session.execute(token_stmt)).scalar_one_or_none()
        assert token is not None, "Verification token not created"

        email_service = EmailVerificationService(session, user_repo)
        ok = await email_service.verify_email(token.token)
        assert ok is True

        user = await user_repo.find_by_email(email)
        assert user.is_active is True and user.email_verified is True
        print("[2] Email verified: is_active=", user.is_active, "email_verified=", user.email_verified)

        # 3) Authenticate user
        auth_service = AuthenticationService(session, user_repo)
        login = await auth_service.authenticate_user(email=email, password=password)
        assert login.access_token and login.refresh_token
        print("[3] Login OK: access_token_len=", len(login.access_token), "refresh_token_len=", len(login.refresh_token))
        print("    user.email=", login.user.email, "user.email_verified=", login.user.email_verified)


if __name__ == "__main__":
    asyncio.run(run())
