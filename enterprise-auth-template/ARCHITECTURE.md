# System Architecture

This document provides a comprehensive overview of the Enterprise Authentication Template's system architecture, design patterns, and technical decisions.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [System Components](#system-components)
- [Backend Architecture](#backend-architecture)
- [Frontend Architecture](#frontend-architecture)
- [Database Design](#database-design)
- [Authentication & Security](#authentication--security)
- [API Design](#api-design)
- [Infrastructure](#infrastructure)
- [Data Flow](#data-flow)
- [Scalability Considerations](#scalability-considerations)
- [Technical Decisions](#technical-decisions)

## 🏗️ Architecture Overview

The Enterprise Authentication Template follows a **modern, microservice-ready architecture** with clear separation of concerns, designed for scalability, maintainability, and security.

### High-Level Architecture

```mermaid
graph TB
    User[👤 User]
    CDN[🌐 CDN/Load Balancer]
    Frontend[⚛️ Next.js Frontend]
    API[🚀 FastAPI Backend]
    Cache[📦 Redis Cache]
    DB[🗄️ PostgreSQL Database]
    Email[📧 Email Service]
    OAuth[🔐 OAuth Providers]
    Monitoring[📊 Monitoring Stack]

    User --> CDN
    CDN --> Frontend
    Frontend --> API
    API --> Cache
    API --> DB
    API --> Email
    Frontend --> OAuth
    API --> OAuth
    API --> Monitoring
    Frontend --> Monitoring
```

### Architecture Principles

1. **Separation of Concerns**: Clear boundaries between presentation, business logic, and data layers
2. **Microservice Ready**: Components can be extracted into separate services
3. **API-First Design**: Frontend consumes backend through well-defined APIs
4. **Event-Driven**: Asynchronous processing for non-critical operations
5. **Security by Design**: Security considerations at every architectural level
6. **Scalability**: Horizontal scaling capabilities built-in
7. **Observability**: Comprehensive logging, metrics, and monitoring

## 🧩 System Components

### Core Services

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Frontend** | Next.js 14 + TypeScript | User interface and client-side logic |
| **Backend API** | FastAPI + Python 3.11 | Business logic and API endpoints |
| **Database** | PostgreSQL 16 | Primary data storage |
| **Cache** | Redis 7 | Session storage and caching |
| **Reverse Proxy** | Nginx | Load balancing and SSL termination |

### Supporting Services

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Email Service** | SMTP/SendGrid | Email notifications and verification |
| **Monitoring** | Prometheus + Grafana | Metrics and observability |
| **Logging** | Structured JSON logs | Application logging and debugging |
| **Container Runtime** | Docker + Docker Compose | Development and deployment |

## 🚀 Backend Architecture

### Layered Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        API[API Routes]
        Middleware[Middleware]
        Schemas[Pydantic Schemas]
    end
    
    subgraph "Business Logic Layer"
        Services[Service Classes]
        Auth[Authentication Logic]
        Validation[Input Validation]
    end
    
    subgraph "Data Access Layer"
        Models[SQLAlchemy Models]
        Repositories[Repository Pattern]
        Migrations[Alembic Migrations]
    end
    
    subgraph "External Integrations"
        Database[(PostgreSQL)]
        Cache[(Redis)]
        Email[Email Service]
        OAuth[OAuth Providers]
    end

    API --> Services
    Middleware --> Services
    Services --> Models
    Models --> Database
    Services --> Cache
    Services --> Email
    Services --> OAuth
```

### Directory Structure

```
backend/
├── app/
│   ├── api/                    # API route definitions
│   │   └── v1/                 # API version 1
│   │       ├── auth.py         # Authentication endpoints
│   │       ├── users.py        # User management endpoints
│   │       └── admin.py        # Admin endpoints
│   ├── core/                   # Core application logic
│   │   ├── config.py           # Configuration management
│   │   ├── database.py         # Database connection
│   │   ├── security.py         # Security utilities
│   │   └── deps.py             # Dependency injection
│   ├── models/                 # SQLAlchemy models
│   │   ├── user.py             # User model
│   │   ├── role.py             # Role and permission models
│   │   └── audit.py            # Audit log model
│   ├── schemas/                # Pydantic schemas
│   │   ├── user.py             # User schemas
│   │   └── auth.py             # Authentication schemas
│   ├── services/               # Business logic
│   │   ├── auth_service.py     # Authentication service
│   │   ├── user_service.py     # User management service
│   │   └── email_service.py    # Email service
│   ├── middleware/             # Custom middleware
│   │   ├── cors.py             # CORS middleware
│   │   ├── rate_limiter.py     # Rate limiting
│   │   └── logging.py          # Request logging
│   └── main.py                 # Application entry point
├── alembic/                    # Database migrations
├── tests/                      # Test suite
└── requirements.txt            # Python dependencies
```

### Design Patterns

#### Repository Pattern
```python
class UserRepository:
    def __init__(self, db: Session):
        self.db = db
    
    async def get_by_id(self, user_id: UUID) -> Optional[User]:
        return await self.db.get(User, user_id)
    
    async def get_by_email(self, email: str) -> Optional[User]:
        return await self.db.execute(
            select(User).where(User.email == email)
        ).scalar_one_or_none()
```

#### Service Layer Pattern
```python
class AuthService:
    def __init__(self, user_repo: UserRepository, email_service: EmailService):
        self.user_repo = user_repo
        self.email_service = email_service
    
    async def authenticate_user(self, email: str, password: str) -> Optional[User]:
        user = await self.user_repo.get_by_email(email)
        if user and verify_password(password, user.hashed_password):
            return user
        return None
```

#### Dependency Injection
```python
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    user_service: UserService = Depends(get_user_service)
) -> User:
    return await user_service.get_current_user(token)
```

## ⚛️ Frontend Architecture

### Component-Based Architecture

```mermaid
graph TB
    subgraph "App Layer"
        App[Next.js App Router]
        Pages[Page Components]
        Layouts[Layout Components]
    end
    
    subgraph "Feature Layer"
        Auth[Authentication Features]
        Dashboard[Dashboard Features]
        Admin[Admin Features]
    end
    
    subgraph "UI Layer"
        Components[Reusable Components]
        Forms[Form Components]
        UI[shadcn/ui Components]
    end
    
    subgraph "State Management"
        Zustand[Zustand Stores]
        TanStack[TanStack Query]
        Context[React Context]
    end
    
    subgraph "Services"
        API[API Client]
        Auth2[Auth Service]
        Utils[Utilities]
    end

    App --> Pages
    Pages --> Auth
    Pages --> Dashboard
    Auth --> Components
    Components --> UI
    Pages --> Zustand
    Components --> TanStack
    TanStack --> API
```

### Directory Structure

```
frontend/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/             # Authentication routes
│   │   ├── dashboard/          # Dashboard routes
│   │   ├── admin/              # Admin routes
│   │   ├── layout.tsx          # Root layout
│   │   └── page.tsx            # Home page
│   ├── components/             # React components
│   │   ├── auth/               # Authentication components
│   │   ├── dashboard/          # Dashboard components
│   │   ├── admin/              # Admin components
│   │   └── ui/                 # Reusable UI components
│   ├── lib/                    # Utility functions
│   │   ├── auth/               # Authentication utilities
│   │   ├── api/                # API client
│   │   └── utils.ts            # General utilities
│   ├── stores/                 # State management
│   │   ├── authStore.ts        # Authentication state
│   │   └── userStore.ts        # User state
│   ├── types/                  # TypeScript type definitions
│   └── styles/                 # Global styles
├── public/                     # Static assets
└── package.json                # Dependencies
```

### State Management Strategy

```typescript
// Zustand store for client-side state
export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  login: async (credentials) => {
    const response = await authApi.login(credentials);
    set({ user: response.user, isAuthenticated: true });
  },
  logout: () => {
    set({ user: null, isAuthenticated: false });
  },
}));

// TanStack Query for server state
export const useUserProfile = () => {
  return useQuery({
    queryKey: ['user', 'profile'],
    queryFn: () => userApi.getProfile(),
    enabled: !!authStore.isAuthenticated,
  });
};
```

## 🗄️ Database Design

### Entity Relationship Diagram

```mermaid
erDiagram
    User ||--o{ Session : has
    User ||--o{ UserRole : has
    User ||--o{ AuditLog : creates
    User ||--o{ WebAuthnCredential : owns
    Role ||--o{ UserRole : assigned_to
    Role ||--o{ RolePermission : has
    Permission ||--o{ RolePermission : granted_by
    
    User {
        uuid id PK
        string email UK
        string hashed_password
        string name
        boolean is_active
        boolean email_verified
        timestamp created_at
        timestamp updated_at
    }
    
    Role {
        uuid id PK
        string name UK
        string display_name
        string description
        timestamp created_at
    }
    
    Permission {
        uuid id PK
        string name UK
        string resource
        string action
        string description
    }
    
    Session {
        uuid id PK
        uuid user_id FK
        string session_token
        string refresh_token_hash
        timestamp expires_at
        string ip_address
        string user_agent
    }
    
    AuditLog {
        uuid id PK
        uuid user_id FK
        string action
        string resource
        json details
        string ip_address
        timestamp created_at
    }
    
    WebAuthnCredential {
        uuid id PK
        uuid user_id FK
        string credential_id
        bytes public_key
        int sign_count
        timestamp created_at
    }
```

### Database Schema Design Principles

1. **Normalization**: Tables are normalized to reduce data duplication
2. **UUID Primary Keys**: All tables use UUIDs for primary keys for better distribution
3. **Soft Deletes**: Important records use soft deletion with `deleted_at` timestamps
4. **Audit Trail**: All changes are tracked in audit logs
5. **Indexing Strategy**: Strategic indexes for query performance
6. **Data Integrity**: Foreign key constraints and check constraints

### Key Indexes

```sql
-- Performance-critical indexes
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_sessions_user_id ON sessions(user_id);
CREATE INDEX CONCURRENTLY idx_sessions_expires_at ON sessions(expires_at);
CREATE INDEX CONCURRENTLY idx_audit_logs_user_id_created_at ON audit_logs(user_id, created_at DESC);
CREATE INDEX CONCURRENTLY idx_user_roles_user_id ON user_roles(user_id);
```

## 🔐 Authentication & Security

### Multi-Factor Authentication Architecture

```mermaid
graph TB
    subgraph "Authentication Methods"
        Password[Password]
        OAuth[OAuth2/OIDC]
        WebAuthn[WebAuthn/FIDO2]
        MagicLink[Magic Links]
        TOTP[TOTP/HOTP]
    end
    
    subgraph "Authentication Flow"
        Request[Auth Request]
        Validate[Validate Credentials]
        MFA[Multi-Factor Check]
        TokenGen[Generate Tokens]
        Session[Create Session]
    end
    
    subgraph "Token Management"
        AccessToken[Access Token - 15min]
        RefreshToken[Refresh Token - 30d]
        SessionStore[Session Storage]
    end

    Password --> Validate
    OAuth --> Validate
    WebAuthn --> Validate
    MagicLink --> Validate
    
    Request --> Validate
    Validate --> MFA
    MFA --> TOTP
    MFA --> TokenGen
    TokenGen --> AccessToken
    TokenGen --> RefreshToken
    TokenGen --> Session
    Session --> SessionStore
```

### Security Layers

1. **Transport Security**: HTTPS/TLS encryption
2. **Authentication**: Multi-factor authentication support
3. **Authorization**: Role-based access control (RBAC)
4. **Input Validation**: Comprehensive input sanitization
5. **Rate Limiting**: Protection against brute force attacks
6. **Session Security**: Secure session management
7. **Audit Logging**: Complete audit trail
8. **Data Protection**: Encryption at rest and in transit

### JWT Token Strategy

```python
class TokenManager:
    def create_access_token(self, user_id: UUID, permissions: List[str]) -> str:
        payload = {
            "sub": str(user_id),
            "permissions": permissions,
            "type": "access",
            "exp": datetime.utcnow() + timedelta(minutes=15),
            "iat": datetime.utcnow(),
        }
        return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    
    def create_refresh_token(self, user_id: UUID) -> str:
        payload = {
            "sub": str(user_id),
            "type": "refresh",
            "exp": datetime.utcnow() + timedelta(days=30),
            "iat": datetime.utcnow(),
        }
        return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
```

## 🔌 API Design

### RESTful API Principles

1. **Resource-Based URLs**: `/api/v1/users/{id}`
2. **HTTP Methods**: Proper use of GET, POST, PUT, PATCH, DELETE
3. **Status Codes**: Meaningful HTTP status codes
4. **Consistent Response Format**: Standardized response structure
5. **Versioning**: API versioning through URL path
6. **Pagination**: Cursor-based pagination for large datasets
7. **Filtering & Sorting**: Query parameters for data filtering

### API Response Format

```json
{
  "success": true,
  "data": {
    // Response payload
  },
  "message": "Operation completed successfully",
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "pages": 5
  },
  "metadata": {
    "timestamp": "2024-09-05T12:00:00Z",
    "request_id": "uuid-v4",
    "version": "1.0.0"
  }
}
```

### Error Handling Strategy

```python
class APIException(HTTPException):
    def __init__(
        self,
        status_code: int,
        error_code: str,
        message: str,
        details: Dict[str, Any] = None
    ):
        self.error_code = error_code
        self.details = details or {}
        super().__init__(status_code=status_code, detail=message)

# Usage
raise APIException(
    status_code=400,
    error_code="INVALID_CREDENTIALS",
    message="Invalid email or password",
    details={"field": "password", "hint": "Password must be at least 8 characters"}
)
```

## 🏗️ Infrastructure

### Development Environment

```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: enterprise_auth_dev
      POSTGRES_USER: dev_user
      POSTGRES_PASSWORD: dev_pass
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    environment:
      - DATABASE_URL=postgresql://dev_user:dev_pass@postgres:5432/enterprise_auth_dev
      - REDIS_URL=redis://redis:6379/0
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    depends_on:
      - postgres
      - redis

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
```

### Production Infrastructure

```mermaid
graph TB
    subgraph "Load Balancer"
        ALB[Application Load Balancer]
    end
    
    subgraph "Web Tier"
        FE1[Frontend Instance 1]
        FE2[Frontend Instance 2]
        FE3[Frontend Instance 3]
    end
    
    subgraph "API Tier"
        BE1[Backend Instance 1]
        BE2[Backend Instance 2]
        BE3[Backend Instance 3]
    end
    
    subgraph "Data Tier"
        PG[(PostgreSQL Primary)]
        PGR[(PostgreSQL Replica)]
        Redis[(Redis Cluster)]
    end
    
    subgraph "Monitoring"
        Prometheus[Prometheus]
        Grafana[Grafana]
        Logs[Log Aggregation]
    end

    ALB --> FE1
    ALB --> FE2
    ALB --> FE3
    
    FE1 --> BE1
    FE2 --> BE2
    FE3 --> BE3
    
    BE1 --> PG
    BE2 --> PG
    BE3 --> PG
    
    BE1 --> Redis
    BE2 --> Redis
    BE3 --> Redis
    
    PG --> PGR
    
    BE1 --> Prometheus
    BE2 --> Prometheus
    BE3 --> Prometheus
    Prometheus --> Grafana
```

## 🌊 Data Flow

### User Registration Flow

```mermaid
sequenceDiagram
    participant U as User
    participant FE as Frontend
    participant API as Backend API
    participant DB as Database
    participant Email as Email Service
    participant Cache as Redis

    U->>FE: Submit registration form
    FE->>API: POST /auth/register
    API->>DB: Check if email exists
    DB->>API: Email availability
    API->>DB: Create user record
    DB->>API: User created
    API->>Email: Send verification email
    Email->>U: Verification email
    API->>Cache: Store verification token
    API->>FE: Registration success
    FE->>U: Show success message
    
    Note over U,Cache: Email verification flow
    U->>FE: Click verification link
    FE->>API: POST /auth/verify-email
    API->>Cache: Validate token
    Cache->>API: Token valid
    API->>DB: Update user as verified
    DB->>API: User updated
    API->>FE: Verification success
    FE->>U: Account verified
```

### Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant FE as Frontend
    participant API as Backend API
    participant DB as Database
    participant Cache as Redis

    U->>FE: Login credentials
    FE->>API: POST /auth/login
    API->>DB: Validate credentials
    DB->>API: User data
    API->>API: Generate JWT tokens
    API->>Cache: Store refresh token
    API->>FE: Access token + HTTP-only cookie
    FE->>U: Redirect to dashboard
    
    Note over U,Cache: Authenticated request flow
    U->>FE: Access protected resource
    FE->>API: GET /users/me (with token)
    API->>API: Validate access token
    API->>DB: Get user data
    DB->>API: User data
    API->>FE: User profile
    FE->>U: Show user data
```

## 📈 Scalability Considerations

### Horizontal Scaling

1. **Stateless Application Design**: No server-side session storage
2. **Database Connection Pooling**: Efficient database connection management
3. **Redis Clustering**: Distributed caching and session storage
4. **Load Balancing**: Multiple application instances behind load balancer
5. **CDN Integration**: Static asset delivery through CDN

### Performance Optimization

1. **Database Optimization**:
   - Strategic indexing
   - Query optimization
   - Connection pooling
   - Read replicas

2. **Caching Strategy**:
   - Redis for session storage
   - Application-level caching
   - HTTP caching headers
   - CDN caching

3. **API Optimization**:
   - Async/await patterns
   - Database query batching
   - Response compression
   - Pagination

### Monitoring & Observability

```python
# Metrics collection
from prometheus_client import Counter, Histogram, Gauge

REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status_code']
)

REQUEST_DURATION = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration'
)

ACTIVE_USERS = Gauge(
    'active_users_total',
    'Number of active users'
)
```

## 🤔 Technical Decisions

### Technology Choices

| Decision | Choice | Rationale |
|----------|---------|-----------|
| **Backend Framework** | FastAPI | Modern, fast, automatic API documentation, type hints |
| **Database** | PostgreSQL | ACID compliance, JSON support, excellent performance |
| **ORM** | SQLAlchemy 2.0 | Mature, async support, type safety |
| **Frontend Framework** | Next.js 14 | React-based, SSR/SSG, App Router |
| **State Management** | Zustand + TanStack Query | Simple, performant, separation of concerns |
| **Authentication** | JWT + Refresh Tokens | Stateless, scalable, secure |
| **Caching** | Redis | Fast, reliable, clustering support |
| **Containerization** | Docker | Consistency, portability, easy deployment |

### Design Trade-offs

1. **JWT vs Sessions**:
   - **Chosen**: JWT with refresh tokens
   - **Trade-off**: Stateless but larger token size
   - **Rationale**: Better for microservices and scaling

2. **SQL vs NoSQL**:
   - **Chosen**: PostgreSQL
   - **Trade-off**: ACID compliance vs eventual consistency
   - **Rationale**: Authentication requires strong consistency

3. **Monorepo vs Multi-repo**:
   - **Chosen**: Monorepo
   - **Trade-off**: Simpler development vs service independence
   - **Rationale**: Easier development and deployment for templates

### Security Decisions

1. **Password Storage**: bcrypt with salt rounds
2. **Token Expiration**: Short-lived access tokens (15 minutes)
3. **HTTPS Only**: All production traffic encrypted
4. **CSRF Protection**: SameSite cookies and CSRF tokens
5. **Rate Limiting**: Per-IP and per-user rate limiting
6. **Input Validation**: Comprehensive validation at API boundary

---

This architecture is designed to be **production-ready**, **scalable**, and **maintainable** while following industry best practices and security standards.