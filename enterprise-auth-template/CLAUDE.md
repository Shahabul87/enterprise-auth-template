# CLAUDE.md

## ⚡ ABSOLUTE FIRST PRIORITY - READ BEFORE EVERY REQUEST
**MANDATORY**: Before processing ANY user request, you MUST:
1. Read this entire CLAUDE.md file
2. Read the root CLAUDE.md file at /Users/mdshahabulalam/CLAUDE.md
3. Apply ALL instructions from both files
4. NEVER skip reading these files - they contain critical updates

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🔥 SUPREME PRIORITY INSTRUCTIONS - MUST FOLLOW

### Architecture & Testing Protocol
1. **CLEAN ARCHITECTURE**: Follow Clean Architecture principles by Robert C. Martin - business logic MUST be independent of frameworks
2. **SHARED BACKEND**: One backend serves both Flutter mobile app and Next.js frontend
3. **TESTING REQUIREMENT**: ALWAYS test functionality yourself BEFORE asking user to test
4. **SERVER CLEANUP**: After testing, ALWAYS kill all ports and instruct user to run backend/frontend
5. **MOBILE TESTING**: Test Flutter app in emulator first, then provide clear instructions to user
6. **CRITICAL CHANGES**: NEVER make fatal changes to important files without explicit user permission
7. **CODE QUALITY**: Follow industry-level code quality, check safety and security vulnerabilities
8. **TYPE SAFETY**: NEVER use `any` or `unknown` data types in TypeScript - use proper types
9. **SCHEMA FIRST**: ALWAYS check database schema before coding, then code accordingly
10. **FILE DISCIPLINE**: NEVER create files with "_enhanced", "_updated", "_new" suffixes unless explicitly requested

### Testing & Cleanup Protocol
```bash
# After EVERY testing session:
1. Kill all test servers: killall uvicorn && killall node && killall flutter
2. Clear ports: lsof -ti:8000 | xargs kill -9 && lsof -ti:3000 | xargs kill -9
3. Instruct user with exact commands to run their servers

# User instructions template:
"Testing complete. All test servers have been stopped.
To run the application:
1. Backend: cd backend && uvicorn app.main:app --reload
2. Frontend: cd frontend && npm run dev
3. Flutter: cd flutter_auth_template && flutter run"
```

### Code Quality Checklist Before ANY Code Generation
- [ ] Check database schema (SQLAlchemy models)
- [ ] Verify API response types match frontend expectations
- [ ] Use proper TypeScript types (no `any` or `unknown`)
- [ ] Validate all inputs with Zod or similar
- [ ] Check for SQL injection vulnerabilities
- [ ] Check for XSS vulnerabilities
- [ ] Ensure proper error handling
- [ ] Test the code before presenting to user

## Clean Architecture Implementation

This project strictly follows Clean Architecture principles as defined by Robert C. Martin:

### Architecture Layers

```
enterprise-auth-template/
├── Domain Layer (Core Business Logic)
│   ├── Entities (User, Role, Permission, Session)
│   ├── Value Objects (Email, Password, Token)
│   └── Business Rules (Authentication, Authorization)
│
├── Application Layer (Use Cases)
│   ├── Services (AuthService, UserService, RoleService)
│   ├── DTOs (Request/Response objects)
│   └── Interfaces (Repository contracts)
│
├── Infrastructure Layer (External Concerns)
│   ├── Database (SQLAlchemy models, migrations)
│   ├── External Services (Email, OAuth providers)
│   └── Frameworks (FastAPI, Next.js, Flutter)
│
└── Presentation Layer (User Interface)
    ├── API Controllers (FastAPI routes)
    ├── Web UI (Next.js components)
    └── Mobile UI (Flutter screens)
```

### Dependency Rules
1. **Domain Layer**: No dependencies on any other layer
2. **Application Layer**: Depends only on Domain
3. **Infrastructure Layer**: Implements Application interfaces
4. **Presentation Layer**: Depends on Application layer

### File Management Rules
- **NEVER** create duplicate files with suffixes (_enhanced, _updated, _new)
- **ALWAYS** modify existing files in place
- **ALWAYS** document changes in CHANGES.md
- **NEVER** pollute the codebase with temporary files

## 🎯 20 Senior Engineering Principles Applied to This Project

### 🏗️ System Design & Architecture

1. **Design for Change** - Auth methods will evolve (OAuth, WebAuthn, biometric)
2. **Dependency Inversion** - Auth logic doesn't depend on FastAPI/Next.js/Flutter
3. **Domain Modeling** - User, Role, Permission, Session are core entities
4. **Trade-offs Documented** - JWT vs sessions, rate limiting vs performance
5. **Scalability vs Performance** - Redis for sessions (scale) vs in-memory (speed)

### 📦 Implementation & Coding

6. **Readability First** - Clear service methods over clever one-liners
7. **Composition** - Role-based permissions composed, not inherited
8. **Continuous Refactoring** - Evolve auth flows incrementally
9. **Simplicity** - Simple auth checks that juniors can debug
10. **Automation** - CI/CD for all three platforms (backend/web/mobile)

### 🔍 Testing & Reliability

11. **Isolated Business Logic** - Auth logic testable without database
12. **Test Pyramid** - Unit tests for services, fewer E2E tests
13. **Chaos Engineering** - Test auth failures, token expiry, rate limits
14. **Error Handling** - Auth failures, network issues, rate limit responses

### 🚀 Deployment & Operations

15. **Observability** - Auth metrics, login attempts, session tracking
16. **Feature Flags** - Toggle auth methods without redeployment
17. **Capacity Planning** - Monitor auth load, session storage growth
18. **Latency** - Sub-100ms auth checks for optimal UX

### 🧠 Project-Specific Application

19. **Communication** - Clear API docs, auth flow diagrams, security policies
20. **Next Engineer** - Comprehensive auth documentation and examples

### Implementation Examples in This Project:

```python
# Backend: Clean separation (Principle #2)
# app/services/auth_service.py - Business logic
# app/api/v1/auth.py - FastAPI details
# app/models/user.py - Domain model

# Frontend: Composition over inheritance (Principle #7)
# components/auth/login-form.tsx - Composed auth components
# lib/auth/hooks.ts - Reusable auth hooks

# Flutter: Test pyramid (Principle #12)
# test/unit/ - Many unit tests
# test/widget/ - Component tests
# integration_test/ - Few E2E tests
```

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

# Test specific files or patterns
npm test -- --testPathPattern="auth-store"  # Test specific file pattern
npm test -- --testNamePattern="login"       # Test specific test names

# Code quality
npm run lint            # Run ESLint
npm run lint:fix        # Auto-fix linting issues
npm run typecheck       # Run TypeScript compiler check
npx prettier --write .  # Format code

# Debug failing tests
npm test -- --verbose   # Show detailed test output
npm test -- --no-cache  # Clear Jest cache and run tests
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

## 📝 PROJECT-SPECIFIC CUSTOM COMMANDS

### /todo Command - Enterprise Authentication Template

This project inherits the `/todo` command from the user-level CLAUDE.md with additional project-specific enhancements.

**Project-Specific Options**:
```
/todo [base options] [project options]

Project Options:
  --component <type>    Specify component type (backend/frontend/flutter/infra)
  --feature <name>      Associate with feature (auth/rbac/audit/session)
  --sprint <id>         Assign to sprint/milestone
  --assignee <name>     Assign to team member (for documentation)
  --test-required       Mark as requiring test coverage
```

**Component-Specific Task Templates**:

1. **Backend Tasks** (`--component backend`):
   ```
   - API endpoint implementation
   - Service layer logic
   - Database model updates
   - Migration scripts
   - Test coverage
   - API documentation
   ```

2. **Frontend Tasks** (`--component frontend`):
   ```
   - Component implementation
   - State management
   - API integration
   - UI/UX implementation
   - Accessibility checks
   - Component tests
   ```

3. **Flutter Tasks** (`--component flutter`):
   ```
   - Screen implementation
   - Provider setup
   - Service integration
   - Platform-specific code
   - Widget tests
   - Integration tests
   ```

4. **Infrastructure Tasks** (`--component infra`):
   ```
   - Docker configuration
   - Environment setup
   - CI/CD pipeline
   - Deployment scripts
   - Monitoring setup
   - Security configuration
   ```

**Feature-Specific Workflows**:

1. **Authentication Features** (`--feature auth`):
   ```typescript
   interface AuthTaskFlow {
     backend: ['model', 'service', 'endpoint', 'validation'];
     frontend: ['form', 'validation', 'api-client', 'state'];
     flutter: ['screen', 'provider', 'service', 'biometric'];
     tests: ['unit', 'integration', 'e2e'];
   }
   ```

2. **RBAC Features** (`--feature rbac`):
   ```typescript
   interface RBACTaskFlow {
     permissions: ['define', 'implement', 'validate'];
     middleware: ['auth-check', 'permission-check', 'audit'];
     ui: ['role-management', 'permission-matrix', 'user-assignment'];
   }
   ```

**Project File Organization**:
```
enterprise-auth-template/
├── backend/
│   ├── app/              # Modify existing, document changes
│   ├── tests/            # Add tests as needed
│   └── docs/
│       └── CHANGES.md    # Backend modifications log
├── frontend/
│   ├── src/              # Modify existing components
│   ├── __tests__/        # Add tests as needed
│   └── docs/
│       └── CHANGES.md    # Frontend modifications log
├── flutter_auth_template/
│   ├── lib/              # Modify existing code
│   ├── test/             # Add tests as needed
│   └── docs/
│       └── CHANGES.md    # Flutter modifications log
└── .todo/
    ├── current.json      # Active todos
    ├── completed.json    # Completed todos (archive)
    └── metrics.json      # Task metrics and velocity

```

**Documentation Requirements for This Project**:

1. **API Changes**:
   ```markdown
   ## API Modification - [Endpoint]
   - Method: [GET/POST/PUT/DELETE]
   - Path: [/api/path]
   - Changes: [what changed]
   - Breaking: [yes/no]
   - Migration: [if breaking, how to migrate]
   ```

2. **Database Changes**:
   ```markdown
   ## Database Schema Change - [Table]
   - Migration: [migration file name]
   - Fields: [added/modified/removed]
   - Indexes: [changes to indexes]
   - Rollback: [rollback migration command]
   ```

3. **Component Changes**:
   ```markdown
   ## Component Modification - [Component Name]
   - File: [path/to/component]
   - Props: [changes to props]
   - State: [state management changes]
   - Breaking: [parent components affected]
   ```

**Example Project-Specific Usage**:
```bash
# Create todos for new auth feature
/todo --component backend --feature auth --test-required "Implement OAuth2 login with Google"

# Create todos for RBAC implementation
/todo --component all --feature rbac --priority high "Implement role-based access control"

# Create sprint-based todos
/todo --sprint sprint-3 --assignee team "Complete session management features"

# Create comprehensive test todos
/todo --category test --test-required "Add test coverage for auth service, user management, and API endpoints"
```

**Project-Specific Quality Gates**:
- ✅ Backend: Python type hints, FastAPI schemas validated
- ✅ Frontend: TypeScript strict mode, no `any` types
- ✅ Flutter: Null safety enabled, widget tests present
- ✅ Database: Migrations reversible, indexes optimized
- ✅ API: OpenAPI spec updated, response schemas consistent
- ✅ Security: Auth required on protected routes
- ✅ Tests: Coverage > 80% for new code
- ✅ Documentation: CHANGES.md updated for all core modifications

**Integration with Project Tools**:
```bash
# Makefile integration
make todo-list          # Show current todos
make todo-stats         # Show completion metrics
make todo-archive       # Archive completed todos

# Docker integration
docker-compose exec backend python scripts/todo_manager.py list
docker-compose exec frontend npm run todo:check
```

**Automated Todo Creation Triggers**:
1. On PR creation → Create review todos
2. On test failure → Create fix todos
3. On security scan issues → Create security todos
4. On performance regression → Create optimization todos
5. On dependency updates → Create update todos

## Test Development Best Practices

### Frontend Test Setup
**ALWAYS follow these patterns when writing frontend tests:**

1. **Mock Syntax Validation**
   - Ensure all `jest.mock()` calls have proper closing parentheses
   - Each mock should be self-contained with `}));` at the end
   - Never leave hanging mock declarations

2. **Store Method Verification**
   - Always verify actual method names exist in the store before testing
   - Use `grep` or IDE search to confirm method signatures
   - Match test expectations to actual implementation

3. **Timing-Based Tests**
   - Use `jest.useFakeTimers()` for consistent timing control
   - Advance timers explicitly with `jest.advanceTimersByTime()`
   - Don't assume zero/negative delays work synchronously

4. **Module Mocking Best Practices**
   ```typescript
   // Always use type assertions for mocked modules
   jest.mock('@/lib/module');
   const mockModule = Module as jest.Mocked<typeof Module>;
   ```

5. **Test Environment Setup**
   - Maintain comprehensive polyfills in `jest.setup.js`
   - Include crypto, clipboard, and other browser APIs
   - Keep E2E tests separate from unit tests

### Common Test Anti-Patterns to Avoid
- ❌ Modifying assertions to make tests pass
- ❌ Skipping tests without fixing root causes
- ❌ Using `any` type in test code
- ❌ Mixing E2E and unit test configurations
- ❌ Clearing all mocks without preserving implementations

### Test Debugging Workflow
1. Read error messages completely
2. Verify mock implementations
3. Check method names match implementation
4. Validate timing expectations
5. Ensure proper test environment setup

### Critical Test Development Rules
**MANDATORY when writing or fixing tests:**

1. **Always check actual store/component implementation before writing tests**
   - Never assume API structure without verification
   - Read the actual source code to understand method names and properties
   - Use `grep` or IDE search to find exact implementations

2. **Verify property names and method signatures match implementation**
   - Don't test `sidebarOpen` if the actual property is `sidebarState`
   - Don't call `setSidebarOpen()` if the actual method is `setSidebarState()`
   - Match test expectations to real API surface

3. **Consider test environment limitations with complex UI libraries**
   - Some features work in production but fail in test environments
   - Skip tests that can't work reliably in jsdom (with clear comments)
   - Focus on testing the logic, not the framework quirks

4. **Keep tests aligned with actual API structure**
   - If store has nested categories, test the nested structure
   - If methods return promises, test with async/await
   - If components use portals, account for portal rendering