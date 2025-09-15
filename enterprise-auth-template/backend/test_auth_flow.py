import asyncio
import json
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.core.config import get_settings
from app.core.database import get_db_session, init_db
from app.repositories.user_repository import UserRepository
from app.services.auth.authentication_service import AuthenticationService
from app.services.auth.registration_service import RegistrationService
from app.repositories.session_repository import SessionRepository
from app.repositories.role_repository import RoleRepository
from app.schemas.auth import RegisterRequest

async def test_complete_flow():
    settings = get_settings()
    
    print("="*50)
    print("DATABASE FLOW VERIFICATION")
    print("="*50)
    
    # 1. Show database config
    print(f"\n1. DATABASE CONFIGURATION:")
    print(f"   URL: {settings.DATABASE_URL}")
    print(f"   Database: {settings.DB_NAME}")
    print(f"   User: {settings.DB_USER}")
    
    # 2. Initialize database connection
    await init_db()
    
    # Create a session
    from app.core.database import async_session_maker
    async with async_session_maker() as session:
        
        # 3. Check existing users
        print(f"\n2. CHECKING EXISTING DATA:")
        result = await session.execute(text("SELECT email, email_verified FROM users"))
        users = result.fetchall()
        for user in users:
            print(f"   Found user: {user.email} (verified={user.email_verified})")
        
        # 4. Test registration flow (if no test user exists)
        print(f"\n3. REGISTRATION FLOW:")
        user_repo = UserRepository(session)
        test_email = "flowtest@example.com"
        
        existing = await user_repo.find_by_email(test_email)
        if existing:
            print(f"   Test user already exists: {test_email}")
        else:
            print(f"   Creating new test user: {test_email}")
            role_repo = RoleRepository(session)
            reg_service = RegistrationService(session, user_repo, role_repo)
            
            reg_data = RegisterRequest(
                email=test_email,
                password="TestPass123!",
                full_name="Flow Test User",
                confirm_password="TestPass123!",
                agree_to_terms=True
            )
            
            try:
                new_user = await reg_service.register_user(reg_data)
                await session.commit()
                print(f"   ✓ User created with ID: {new_user.id}")
            except Exception as e:
                print(f"   ✗ Registration failed: {e}")
                await session.rollback()
        
        # 5. Test authentication flow
        print(f"\n4. AUTHENTICATION FLOW:")
        auth_service = AuthenticationService(
            session,
            user_repo,
            SessionRepository(session)
        )
        
        # Try to authenticate the existing verified user
        try:
            result = await auth_service.authenticate_user(
                email="sham251087@gmail.com",
                password="input_password_here"  # Would need actual password
            )
            print(f"   ✓ Authentication successful for verified user")
        except Exception as e:
            print(f"   Note: Authentication requires correct password: {e}")
        
        # 6. Verify data consistency
        print(f"\n5. DATA CONSISTENCY CHECK:")
        
        # Check from same database
        result = await session.execute(
            text("SELECT COUNT(*) as count FROM users")
        )
        total_users = result.scalar()
        print(f"   Total users in database: {total_users}")
        
        # Check through repository (same session)
        all_users = await user_repo.list_all()
        print(f"   Users via repository: {len(all_users)}")
        
        # Verify they match
        if total_users == len(all_users):
            print(f"   ✓ Data consistency verified - same database!")
        else:
            print(f"   ✗ Data mismatch - check configuration!")
        
        await session.close()
    
    # Close database
    from app.core.database import close_db
    await close_db()
    
    print("\n" + "="*50)
    print("VERIFICATION COMPLETE")
    print("="*50)

asyncio.run(test_complete_flow())
