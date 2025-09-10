# 🚀 Frontend-Backend Testing Infrastructure Plan

## Executive Summary
This document outlines a comprehensive infrastructure strategy for testing Flutter frontend (web/mobile) with the FastAPI backend, ensuring isolated environments, seamless integration, and conflict-free development.

## 🎯 Goals
1. **Unified Development Environment**: Single command to start entire stack
2. **Environment Isolation**: Separate dev, test, and staging environments
3. **Mobile Testing Support**: Test on real devices and emulators
4. **Data Management**: Consistent test data across environments
5. **Zero Conflicts**: Multiple developers can work simultaneously
6. **Automated Testing**: CI/CD ready infrastructure

## 🏗️ Infrastructure Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Development Machine                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Docker Compose Environment               │  │
│  ├──────────────────────────────────────────────────────┤  │
│  │                                                       │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │  │
│  │  │  PostgreSQL │  │    Redis    │  │   Mailhog   │ │  │
│  │  │    :5432    │  │    :6379    │  │    :8025    │ │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘ │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │          FastAPI Backend (:8000)                │ │  │
│  │  │  - Auto-reload on code changes                  │ │  │
│  │  │  - Environment-based configuration              │ │  │
│  │  │  - Database migrations on startup               │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  │                                                       │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │          Nginx Reverse Proxy (:80)              │ │  │
│  │  │  - Routes /api/* to backend                     │ │  │
│  │  │  - Serves Flutter web build                     │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Flutter Development Server (:3000)           │  │
│  │  - Hot reload enabled                                │  │
│  │  - Web, iOS, Android targets                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Mobile Device/Emulator                   │  │
│  │  - Android Emulator / iOS Simulator                  │  │
│  │  - Physical devices via USB/WiFi                     │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
enterprise-auth-template/
├── backend/
│   ├── app/
│   ├── tests/
│   ├── .env.dev
│   ├── .env.test
│   └── Dockerfile
├── flutter_auth_template/
│   ├── lib/
│   ├── test/
│   ├── .env.dev
│   ├── .env.staging
│   └── .env.prod
├── infrastructure/
│   ├── docker/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.dev.yml
│   │   ├── docker-compose.test.yml
│   │   └── docker-compose.prod.yml
│   ├── nginx/
│   │   ├── nginx.conf
│   │   └── sites/
│   ├── scripts/
│   │   ├── setup-dev.sh
│   │   ├── test-all.sh
│   │   ├── deploy.sh
│   │   └── seed-db.sh
│   └── kubernetes/
└── docs/
    ├── API.md
    ├── TESTING.md
    └── DEPLOYMENT.md
```

## 🔧 Environment Configuration

### 1. Backend Environments

**Development (.env.dev)**
```env
# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=auth_dev
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=dev_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_DB=0

# API Configuration
API_V1_PREFIX=/api/v1
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080"]
DEBUG=true
ENVIRONMENT=development

# JWT
JWT_SECRET_KEY=dev-secret-key-change-in-production
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# Email (Mailhog for dev)
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=noreply@dev.local
```

**Testing (.env.test)**
```env
# Separate test database
POSTGRES_DB=auth_test
REDIS_DB=1
ENVIRONMENT=testing
# Fast token expiry for testing
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=1
```

### 2. Flutter Environments

**lib/config/environment.dart**
```dart
class Environment {
  static const String dev = 'dev';
  static const String staging = 'staging';
  static const String prod = 'prod';
  
  static String current = const String.fromEnvironment(
    'ENV',
    defaultValue: dev,
  );
  
  static String get apiBaseUrl {
    switch (current) {
      case dev:
        return _getDevApiUrl();
      case staging:
        return 'https://staging-api.example.com';
      case prod:
        return 'https://api.example.com';
      default:
        return 'http://localhost:8000';
    }
  }
  
  static String _getDevApiUrl() {
    // Auto-detect platform for development
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // Android emulator localhost
      return 'http://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      // iOS simulator localhost
      return 'http://localhost:8000';
    } else {
      // Physical device - use machine's IP
      return 'http://192.168.1.100:8000'; // Update with your IP
    }
  }
}
```

## 🐳 Docker Compose Configuration

### Main docker-compose.yml
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI
    environment:
      MH_STORAGE: memory

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      - REDIS_URL=redis://redis:6379/${REDIS_DB:-0}
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    command: >
      sh -c "
        alembic upgrade head &&
        python scripts/seed_dev_data.py &&
        uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
      "

volumes:
  postgres_data:
  redis_data:
```

## 🧪 Testing Strategy

### 1. Backend Testing
```bash
# Unit tests with isolated database
docker-compose -f docker-compose.test.yml run --rm backend pytest

# Integration tests
docker-compose -f docker-compose.test.yml run --rm backend pytest tests/integration/

# Load testing
docker-compose -f docker-compose.test.yml run --rm locust
```

### 2. Flutter Testing
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests - Web
flutter test integration_test/ -d chrome

# Integration tests - Mobile
flutter test integration_test/ -d android
flutter test integration_test/ -d ios
```

### 3. End-to-End Testing
```bash
# Start test environment
./scripts/start-test-env.sh

# Run E2E tests
flutter drive --target=test_driver/app.dart
```

## 📱 Mobile Device Testing

### Android Setup
```bash
# 1. Enable Developer Mode on device
# 2. Enable USB Debugging
# 3. Connect via USB or WiFi

# For emulator
flutter emulators --launch pixel_5

# For physical device
adb devices  # Verify device is connected
flutter run -d <device-id>
```

### iOS Setup
```bash
# 1. Open Xcode
# 2. Select simulator or connect device
# 3. Trust computer on device

# For simulator
open -a Simulator
flutter run -d iPhone

# For physical device
flutter run -d <device-id>
```

## 🔄 Development Workflow

### Initial Setup
```bash
# 1. Clone repository
git clone <repo-url>

# 2. Run setup script
./scripts/setup-dev.sh

# 3. Start development environment
docker-compose up -d

# 4. Run Flutter app
cd flutter_auth_template
flutter pub get
flutter run -d chrome  # or android/ios
```

### Daily Development
```bash
# Start services
make dev-up

# Check logs
make dev-logs

# Run tests
make test-all

# Stop services
make dev-down
```

## 🛡️ Security Considerations

1. **Separate Secrets**: Different secrets for each environment
2. **Network Isolation**: Docker networks for service isolation
3. **CORS Configuration**: Strict origin validation
4. **Rate Limiting**: Different limits per environment
5. **Data Sanitization**: Automated PII removal in test data

## 📊 Monitoring & Debugging

### Backend Monitoring
- Health endpoint: `http://localhost:8000/health`
- Metrics: `http://localhost:8000/metrics`
- API Docs: `http://localhost:8000/docs`

### Flutter Debugging
- Flutter Inspector
- Network profiling via Dart DevTools
- Platform-specific debugging (Android Studio / Xcode)

## 🚀 Performance Optimization

1. **Backend Caching**: Redis for session and API caching
2. **Database Indexing**: Optimized queries with proper indexes
3. **Flutter State**: Efficient state management with Riverpod
4. **Asset Optimization**: Compressed images and lazy loading
5. **API Pagination**: Limit data transfer with pagination

## 📝 Testing Scenarios

### Authentication Flow Testing
```bash
# Test user registration
./scripts/test-auth.sh register

# Test login flow
./scripts/test-auth.sh login

# Test OAuth flow
./scripts/test-auth.sh oauth

# Test 2FA flow
./scripts/test-auth.sh 2fa
```

### Load Testing
```python
# locust/auth_load_test.py
from locust import HttpUser, task, between

class AuthUser(HttpUser):
    wait_time = between(1, 3)
    
    @task(3)
    def login(self):
        self.client.post("/api/v1/auth/login", json={
            "email": "test@example.com",
            "password": "TestPass123!"
        })
    
    @task(1)
    def check_profile(self):
        self.client.get("/api/v1/users/me")
```

## 🔍 Troubleshooting

### Common Issues

1. **Port Conflicts**
   ```bash
   # Check ports
   lsof -i :8000
   lsof -i :3000
   
   # Kill process
   kill -9 <PID>
   ```

2. **Database Connection Issues**
   ```bash
   # Reset database
   docker-compose down -v
   docker-compose up -d postgres
   docker-compose exec backend alembic upgrade head
   ```

3. **Flutter Connection Issues**
   ```bash
   # For Android emulator
   adb reverse tcp:8000 tcp:8000
   
   # For physical device
   # Use machine's IP address in Flutter config
   ```

## 📈 Scaling Considerations

1. **Horizontal Scaling**: Multiple backend instances with load balancer
2. **Database Replication**: Read replicas for scaling reads
3. **CDN Integration**: Static asset delivery
4. **Queue System**: Background job processing with Celery
5. **Monitoring**: Prometheus + Grafana for metrics

## 🎯 Success Metrics

- **API Response Time**: < 200ms for auth endpoints
- **App Load Time**: < 2s on mobile, < 1s on web
- **Test Coverage**: > 80% backend, > 70% frontend
- **Uptime**: 99.9% availability
- **Security**: Zero critical vulnerabilities

---

This infrastructure ensures seamless development and testing of both Flutter frontend and FastAPI backend with complete isolation and professional-grade tooling.