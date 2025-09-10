# 🚀 Development Workflow Guide

Complete guide for developing, testing, and deploying the Enterprise Auth Template with Flutter frontend and FastAPI backend.

## 📋 Table of Contents
- [Quick Start](#quick-start)
- [Development Setup](#development-setup)
- [Daily Workflow](#daily-workflow)
- [Testing Strategy](#testing-strategy)
- [Debugging Guide](#debugging-guide)
- [Team Collaboration](#team-collaboration)
- [CI/CD Pipeline](#cicd-pipeline)

## 🎯 Quick Start

### First Time Setup (< 5 minutes)

```bash
# 1. Clone the repository
git clone <repository-url>
cd enterprise-auth-template

# 2. Run automated setup
make setup

# 3. Start development environment
make dev

# Done! 🎉
# Backend: http://localhost:8000
# Flutter: http://localhost:3000
```

### Test Credentials

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@example.com | Admin123!@# |
| User | john.doe@example.com | User123!@# |

## 🔧 Development Setup

### Prerequisites

- Docker & Docker Compose
- Flutter SDK (3.16+)
- Git
- Make (optional but recommended)

### Environment Structure

```
Your Machine
├── Backend (Docker)
│   ├── FastAPI (port 8000)
│   ├── PostgreSQL (port 5432)
│   ├── Redis (port 6379)
│   └── MailHog (port 8025)
└── Frontend
    ├── Flutter Web (port 3000)
    ├── Android Emulator/Device
    └── iOS Simulator/Device
```

## 💻 Daily Workflow

### Starting Your Day

```bash
# 1. Pull latest changes
git pull origin main

# 2. Start services
make dev

# 3. Check service health
make status

# 4. View URLs
make urls
```

### Development Cycle

#### Backend Development

```bash
# Make changes to backend code
cd backend/app/

# Changes auto-reload (hot reload enabled)
# View logs
make logs-backend

# Run tests after changes
make test-backend

# Check code quality
cd backend && python -m black . && python -m flake8
```

#### Flutter Development

```bash
# Make changes to Flutter code
cd enterprise-auth-template/flutter_auth_template/

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)

# Run on different platforms
flutter run -d chrome   # Web
flutter run -d android  # Android
flutter run -d ios      # iOS

# Run tests
make test-flutter
```

### Ending Your Day

```bash
# 1. Run tests
make test

# 2. Commit changes
git add .
git commit -m "feat: your feature description"

# 3. Push changes
git push origin feature/your-branch

# 4. Stop services
make stop
```

## 🧪 Testing Strategy

### Test Pyramid

```
        /\
       /E2E\      (5%)  - Critical user journeys
      /======\
     /Integration\ (25%) - API & component integration
    /==============\
   /   Unit Tests   \ (70%) - Business logic & utilities
  /==================\
```

### Running Tests

```bash
# All tests
make test

# Specific tests
make test-backend    # Backend only
make test-flutter    # Flutter only
make test-e2e        # End-to-end

# With coverage
make coverage
```

### Writing Tests

#### Backend Test Example

```python
# backend/tests/test_auth.py
import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_user_registration(client: AsyncClient):
    response = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@example.com",
            "password": "Test123!@#",
            "name": "Test User"
        }
    )
    assert response.status_code == 201
    assert "access_token" in response.json()
```

#### Flutter Test Example

```dart
// test/auth_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Login validation', () {
    final result = EmailValidator.validate('');
    expect(result, 'Email is required');
  });
}
```

## 🐛 Debugging Guide

### Backend Debugging

```bash
# 1. View logs
make logs-backend

# 2. Interactive debugging
make shell-backend
python -m pdb app/main.py

# 3. Database queries
make db-shell
\dt  -- List tables
SELECT * FROM users;
```

### Flutter Debugging

```dart
// Add breakpoints in VS Code/Android Studio
debugPrint('Debug message');

// Use Flutter Inspector
flutter inspector

// Network debugging
import 'package:flutter/foundation.dart';
if (kDebugMode) {
  // Debug-only code
}
```

### Common Issues

#### Port Already in Use

```bash
# Find process using port
lsof -i :8000

# Kill process
kill -9 <PID>

# Or use different port
export BACKEND_PORT=8001
```

#### Database Connection Failed

```bash
# Reset database
make db-reset

# Check PostgreSQL logs
docker logs auth_postgres

# Recreate with fresh data
make db-seed
```

#### Flutter Connection Issues

```bash
# For Android emulator
adb reverse tcp:8000 tcp:8000

# For physical device
make mobile-ip  # Get your IP
# Update environment.dart with IP
```

## 👥 Team Collaboration

### Git Workflow

```bash
# 1. Create feature branch
git checkout -b feature/auth-improvement

# 2. Make changes
# ... code ...

# 3. Commit with conventional commits
git commit -m "feat: add biometric authentication"
git commit -m "fix: resolve login timeout issue"
git commit -m "docs: update API documentation"

# 4. Push and create PR
git push origin feature/auth-improvement
```

### Conventional Commits

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Code restructuring
- `test:` Adding tests
- `chore:` Maintenance

### Code Review Checklist

- [ ] Tests pass
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] No security vulnerabilities
- [ ] Performance acceptable
- [ ] Mobile compatibility tested

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Backend Tests
        run: |
          docker-compose -f infrastructure/docker/docker-compose.test.yml up --abort-on-container-exit
      
      - name: Run Flutter Tests
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter test
      
      - name: Build
        run: make build
```

### Deployment Process

```bash
# 1. Staging deployment
make deploy-staging

# 2. Run smoke tests
make test-staging

# 3. Production deployment
make deploy-prod

# 4. Health check
curl https://api.yourapp.com/health
```

## 📊 Performance Monitoring

### Backend Metrics

```python
# View metrics endpoint
curl http://localhost:8000/metrics

# Important metrics:
# - Response time < 200ms
# - Error rate < 1%
# - Database queries < 50ms
```

### Flutter Performance

```bash
# Profile mode
flutter run --profile

# DevTools
flutter pub global run devtools

# Metrics to monitor:
# - Frame rendering < 16ms
# - Memory usage < 150MB
# - App size < 30MB
```

## 🔒 Security Checklist

### Development

- [ ] Never commit secrets (.env files)
- [ ] Use secure storage for tokens
- [ ] Validate all inputs
- [ ] Implement rate limiting
- [ ] Enable CORS properly

### Testing

```bash
# Security scan
make security

# Dependency check
cd backend && safety check
cd flutter && flutter pub audit
```

## 📝 Documentation

### API Documentation

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### Code Documentation

```python
# Backend: Use docstrings
def authenticate_user(email: str, password: str) -> User:
    """
    Authenticate a user with email and password.
    
    Args:
        email: User's email address
        password: Plain text password
        
    Returns:
        User object if authentication successful
        
    Raises:
        InvalidCredentialsException: If credentials are invalid
    """
```

```dart
// Flutter: Use dartdoc
/// Authenticates a user with the backend API.
/// 
/// Throws [AuthException] if authentication fails.
Future<User> login(String email, String password) async {
  // Implementation
}
```

## 🆘 Getting Help

### Resources

- API Docs: http://localhost:8000/docs
- Flutter Docs: https://flutter.dev/docs
- FastAPI Docs: https://fastapi.tiangolo.com

### Commands Help

```bash
# Show all available commands
make help

# Specific help
make help | grep test
```

### Troubleshooting

1. Check service status: `make status`
2. View logs: `make logs`
3. Reset environment: `make clean && make setup`
4. Ask team: Create issue in GitHub

## 🎓 Best Practices

### Code Quality

1. **Run tests before committing**
2. **Use linters and formatters**
3. **Write meaningful commit messages**
4. **Document complex logic**
5. **Review your own PR first**

### Performance

1. **Profile before optimizing**
2. **Cache expensive operations**
3. **Paginate large datasets**
4. **Optimize images and assets**
5. **Monitor production metrics**

### Security

1. **Never trust user input**
2. **Use parameterized queries**
3. **Implement proper authentication**
4. **Keep dependencies updated**
5. **Regular security audits**

---

## 📚 Additional Resources

- [Mobile Testing Guide](MOBILE_TESTING_GUIDE.md)
- [API Documentation](docs/API.md)
- [Deployment Guide](docs/DEPLOYMENT.md)
- [Architecture Decision Records](docs/ADR/)

---

**Remember**: Good development workflow = Happy developers = Quality software 🚀