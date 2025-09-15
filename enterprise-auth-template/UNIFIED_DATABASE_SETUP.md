# Unified Database Setup - Enterprise Authentication Template

## 🎯 Database Choice: PostgreSQL

### Why PostgreSQL?
- **Production-ready**: Industry standard for enterprise applications
- **ACID compliant**: Ensures data integrity for authentication
- **Advanced features**: JSONB, full-text search, row-level security
- **Scalable**: Handles millions of users
- **Secure**: Built-in encryption, SSL support, fine-grained permissions

## 📋 Complete Setup Guide

### 1. Prerequisites
Ensure PostgreSQL is installed and running:
```bash
# Check if PostgreSQL is running
psql --version
brew services list | grep postgresql

# If not installed:
brew install postgresql@15
brew services start postgresql@15
```

### 2. Database Configuration

#### Connection Details (Already in .env):
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=enterprise_auth
DB_USER=enterprise_user
DB_PASSWORD=enterprise_password_2024
DATABASE_URL=postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth
```

### 3. One-Time Database Setup

Run this script to set up everything:

```bash
#!/bin/bash
# File: setup_database.sh

echo "🚀 Setting up PostgreSQL for Enterprise Auth Template"

# Create database and user
psql -U postgres << EOF
-- Create user if not exists
DO
\$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_user
      WHERE usename = 'enterprise_user') THEN
      CREATE USER enterprise_user WITH PASSWORD 'enterprise_password_2024';
   END IF;
END
\$\$;

-- Create database if not exists
SELECT 'CREATE DATABASE enterprise_auth OWNER enterprise_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'enterprise_auth')\gexec

-- Grant all privileges
GRANT ALL PRIVILEGES ON DATABASE enterprise_auth TO enterprise_user;
EOF

echo "✅ Database and user created"

# Run migrations
cd backend
alembic upgrade head

echo "✅ Migrations complete"

# Verify setup
python3 << EOF
import asyncio
from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

async def verify():
    engine = create_async_engine(
        "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"
    )
    async with engine.connect() as conn:
        result = await conn.execute(text("SELECT COUNT(*) FROM users"))
        count = result.scalar()
        print(f"✅ Database connected! Users in database: {count}")
    await engine.dispose()

asyncio.run(verify())
EOF
```

### 4. Create Your User Account

```python
# File: create_user.py
import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.core.security import get_password_hash
import uuid

async def create_user():
    engine = create_async_engine(
        "postgresql+asyncpg://enterprise_user:enterprise_password_2024@localhost:5432/enterprise_auth"
    )
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        # Create your user
        from sqlalchemy import text

        user_id = str(uuid.uuid4())
        email = "sham251087@gmail.com"
        password_hash = get_password_hash("ShaM2510*##&*")

        await session.execute(text("""
            INSERT INTO users (id, email, hashed_password, full_name, is_active, email_verified, created_at, updated_at)
            VALUES (:id, :email, :password, :name, true, true, NOW(), NOW())
            ON CONFLICT (email) DO UPDATE
            SET hashed_password = :password,
                updated_at = NOW()
        """), {
            "id": user_id,
            "email": email,
            "password": password_hash,
            "name": "MD SHAHABUL ALAM"
        })

        await session.commit()
        print(f"✅ User created/updated: {email}")

    await engine.dispose()

if __name__ == "__main__":
    asyncio.run(create_user())
```

### 5. Running the Application

#### Start Services:
```bash
# 1. Ensure PostgreSQL is running
brew services start postgresql@15

# 2. Ensure Redis is running (for sessions)
redis-server

# 3. Start Backend
cd backend
uvicorn app.main:app --reload

# 4. Start Frontend
cd frontend
npm run dev

# 5. (Optional) Start Flutter
cd flutter_auth_template
flutter run
```

### 6. Testing Login

#### Via API:
```bash
curl -X POST "http://localhost:8000/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -H "Origin: http://localhost:3000" \
  -d '{"email": "sham251087@gmail.com", "password": "ShaM2510*##&*"}'
```

#### Via Frontend:
1. Open http://localhost:3000/auth/login
2. Enter credentials:
   - Email: `sham251087@gmail.com`
   - Password: `ShaM2510*##&*`

## 🔧 Troubleshooting

### Issue: Connection refused
```bash
# Check PostgreSQL is running
pg_isready -h localhost -p 5432

# Restart if needed
brew services restart postgresql@15
```

### Issue: Authentication failed
```bash
# Check user exists in PostgreSQL
psql -U postgres -d enterprise_auth -c "SELECT email, email_verified FROM users;"
```

### Issue: Password incorrect
```bash
# Reset password in database
cd backend
python3 create_user.py  # Run the script above
```

## 🏗️ Architecture Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Next.js Web    │────▶│   FastAPI       │────▶│   PostgreSQL    │
│  (Port 3000)    │     │   Backend       │     │   Database      │
│                 │     │   (Port 8000)   │     │   (Port 5432)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                        │
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│  Flutter App    │────▶│   Redis Cache   │     │   Alembic       │
│  (Mobile)       │     │   (Port 6379)   │     │   Migrations    │
│                 │     │                 │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## ✅ Benefits of This Unified Setup

1. **Single Source of Truth**: All components use the same PostgreSQL database
2. **No Confusion**: No SQLite vs PostgreSQL issues
3. **Production Ready**: Same setup works in development and production
4. **Scalable**: PostgreSQL handles enterprise-level loads
5. **Secure**: Built-in security features for authentication
6. **Consistent**: All users, sessions, and data in one place

## 🚀 Quick Commands

```bash
# Check everything is working
make verify-setup

# Reset database (WARNING: Deletes all data)
make db-reset

# Create test user
make create-test-user

# Run full test suite
make test-all
```

## 📝 Environment Files

Ensure these files exist:
- `backend/.env` - Backend configuration (PostgreSQL connection)
- `frontend/.env.local` - Frontend configuration (API URL)
- `flutter_auth_template/.env` - Flutter configuration (API URL)

All should point to the same backend URL: `http://localhost:8000`

---

**Remember**: Always use PostgreSQL for this enterprise authentication template. It's the only database that supports all the advanced features needed for production-grade authentication.