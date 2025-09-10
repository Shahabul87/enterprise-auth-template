# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Enterprise Authentication Template - a production-ready full-stack application with comprehensive authentication and authorization features. The project consists of:

- **Backend**: FastAPI (Python 3.11+) with SQLAlchemy 2.0, PostgreSQL, and Redis
- **Frontend**: Next.js 14 with TypeScript, TailwindCSS, and shadcn/ui components
- **Infrastructure**: Docker-based development and production environments

## Core Architecture

### Backend Architecture (FastAPI)
- **Entry Point**: `backend/app/main.py`
- **API Routes**: `backend/app/api/` - Organized by feature (auth, users, admin)
- **Database Models**: `backend/app/models/` - SQLAlchemy 2.0 models
- **Business Logic**: `backend/app/services/` - Service layer for complex operations
- **Authentication**: JWT with refresh tokens, OAuth2, WebAuthn, 2FA support
- **Middleware**: Rate limiting, CORS, security headers in `backend/app/middleware/`
- **Database Migrations**: Alembic migrations in `backend/alembic/`

### Frontend Architecture (Next.js)
- **App Router**: `frontend/src/app/` - Next.js 14 App Router structure
- **Components**: `frontend/src/components/` - Reusable UI components
- **Authentication**: `frontend/src/lib/auth/` - Auth utilities and hooks
- **API Client**: TanStack Query for server state management
- **State Management**: Zustand stores in `frontend/src/stores/`
- **Middleware**: `frontend/src/middleware.ts` - Route protection

### Key Features
- Multiple authentication methods (Email/Password, OAuth2, WebAuthn, Magic Links)
- Role-Based Access Control (RBAC) with flexible permissions
- Complete audit logging for compliance
- Rate limiting and account security
- Docker-based development with hot reload

## Development Commands

### Quick Start
```bash
# Initial setup for new developers
make setup                # Complete setup with dependencies, Docker, and DB

# Start development environment
make dev-up               # Start all services with Docker
make dev-down            # Stop all services
make dev-restart         # Restart all services
make dev-logs            # View logs (optionally: SERVICE=backend make dev-logs)
```

### Backend Development
```bash
# Running backend locally (without Docker)
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Database operations
make db-migrate          # Run database migrations
make db-seed            # Seed initial data
make db-reset           # Reset database (WARNING: destroys data)

# Testing
cd backend
pytest tests/ -v                                    # Run all tests
pytest tests/test_auth_endpoints.py -v             # Run specific test file
pytest tests/ -k "test_login" -v                   # Run tests matching pattern
pytest tests/ -v --cov=app --cov-report=term-missing  # With coverage

# Code quality
cd backend
python -m black app/ tests/          # Format code
python -m isort app/ tests/          # Sort imports
python -m flake8 app/ tests/         # Lint code
python -m mypy app/                  # Type checking
```

### Frontend Development
```bash
# Running frontend locally (without Docker)
cd frontend
npm install
npm run dev              # Start development server on port 3000

# Testing
npm test                 # Run all tests
npm run test:watch      # Run tests in watch mode
npm run test:coverage   # Run tests with coverage

# Code quality
npm run lint            # Run ESLint
npm run lint:fix        # Auto-fix linting issues
npm run typecheck       # Run TypeScript compiler check
npx prettier --write .  # Format code
```

### Docker Operations
```bash
# Using docker-compose directly
docker-compose up -d                    # Start all services
docker-compose up -d postgres redis     # Start only infrastructure
docker-compose logs -f backend          # Follow backend logs
docker-compose exec backend bash        # Shell into backend container
docker-compose down -v                  # Stop and remove volumes

# Shell access
make shell-backend      # Open shell in backend container
make shell-frontend     # Open shell in frontend container
make shell-db          # Open PostgreSQL shell
```

### Testing Complete Flow
```bash
# Quick test script for authentication
./quick_test.sh         # Tests basic auth endpoints

# Manual testing guide
./test_auth.sh          # Comprehensive auth testing

# End-to-end testing
make test-e2e           # Run E2E tests
```

## Environment Configuration

### Required Environment Variables
The project uses `.env` files for configuration:
- `.env.example` - Template with all variables
- `.env.dev` - Development configuration
- `.env` - Production configuration

Key variables to configure:
- Database: `POSTGRES_*` variables
- Redis: `REDIS_*` variables
- JWT: `JWT_SECRET_KEY`, `JWT_ALGORITHM`
- OAuth: `GOOGLE_CLIENT_ID`, `GITHUB_CLIENT_ID`, etc.
- Email: SMTP or service provider settings

### Initial Setup
```bash
cp .env.example .env.dev
# Edit .env.dev with your configuration
./init-project.sh       # Initialize project with proper settings
```

## Authentication Implementation

### Auth Flow
1. Login/Register → JWT access token + HTTP-only refresh token
2. Protected routes check via middleware
3. Token refresh handled automatically
4. Session management with Redis
5. Rate limiting per endpoint

### Testing Auth Endpoints
```bash
# Registration
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "SecurePass123!", "name": "Test User"}'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "test@example.com", "password": "SecurePass123!"}'
```

## Database Schema

### Key Models
- **User**: Core user model with authentication
- **Role**: RBAC roles
- **Permission**: Granular permissions
- **Session**: Active user sessions
- **AuditLog**: Compliance audit trail

### Migration Workflow
```bash
# Create new migration
cd backend
alembic revision --autogenerate -m "Description"

# Apply migrations
alembic upgrade head

# Rollback
alembic downgrade -1
```

## Security Considerations

### Built-in Security Features
- Password hashing with bcrypt
- JWT with refresh token rotation
- Rate limiting (configurable per endpoint)
- CORS configuration
- Security headers (CSP, HSTS, etc.)
- SQL injection prevention via SQLAlchemy
- XSS protection in frontend
- CSRF protection

### Security Testing
```bash
# Run security scan
make security-scan

# Check dependencies
cd backend && safety check
cd frontend && npm audit
```

## Deployment

### Production Build
```bash
# Build production images
make prod-build

# Deploy with Docker Compose
docker-compose -f docker-compose.prod.yml up -d

# Kubernetes deployment
kubectl apply -f infrastructure/kubernetes/
```

### Health Checks
- Backend: `http://localhost:8000/health`
- Frontend: `http://localhost:3000/api/health`
- Metrics: `http://localhost:8000/metrics`

## Common Issues & Solutions

### Port Conflicts
If ports 3000, 8000, 5432, or 6379 are in use:
```bash
# Check what's using the port
lsof -i :8000

# Change ports in .env.dev or docker-compose.dev.yml
```

### Database Connection Issues
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check connection
docker-compose exec postgres psql -U dev_user -d enterprise_auth_dev

# Reset if needed
make db-reset
```

### Frontend Build Issues
```bash
# Clear Next.js cache
rm -rf frontend/.next
rm -rf frontend/node_modules
cd frontend && npm install
```

## API Documentation

- **Interactive API Docs**: http://localhost:8000/docs (Swagger UI)
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## Performance Monitoring

```bash
# Check resource usage
make monitor

# View application metrics
curl http://localhost:8000/metrics

# Database query analysis
docker-compose exec postgres pg_stat_activity
```

## Contributing Guidelines

### Code Standards
- Python: Follow PEP 8, use Black formatter
- TypeScript: ESLint + Prettier configuration
- Commit messages: Conventional commits format
- PR workflow: Feature branches → main

### Pre-commit Checks
```bash
# Run all quality checks
make ci-test

# Individual checks
make lint
make format
make test
make security-scan
```