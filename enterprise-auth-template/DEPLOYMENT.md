# Deployment Guide

This guide covers deploying the Enterprise Authentication Template across different environments and platforms.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Configuration](#environment-configuration)
- [Docker Deployment](#docker-deployment)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Cloud Platform Deployment](#cloud-platform-deployment)
- [Database Setup](#database-setup)
- [SSL/TLS Configuration](#ssltls-configuration)
- [Monitoring Setup](#monitoring-setup)
- [Backup and Recovery](#backup-and-recovery)
- [Troubleshooting](#troubleshooting)

## 📋 Prerequisites

### System Requirements

**Minimum Requirements:**
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 20GB SSD
- **Network**: 100 Mbps

**Recommended (Production):**
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **Network**: 1 Gbps

### Software Requirements

- Docker 24.0+ and Docker Compose 2.0+
- PostgreSQL 16+ (if not using containerized database)
- Redis 7.0+ (if not using containerized cache)
- SSL certificates (for HTTPS)

## ⚙️ Environment Configuration

### Environment Files

Create environment files for different deployment stages:

```bash
# Copy example environment file
cp .env.example .env.prod

# Edit production configuration
nano .env.prod
```

### Production Environment Variables

```bash
# Application Configuration
ENVIRONMENT=production
DEBUG=false
APP_NAME="Enterprise Auth Template"
APP_VERSION=1.0.0
BACKEND_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com

# Database Configuration
POSTGRES_HOST=postgres-prod.yourdomain.com
POSTGRES_PORT=5432
POSTGRES_DB=enterprise_auth_prod
POSTGRES_USER=auth_prod_user
POSTGRES_PASSWORD=your-secure-password

# Redis Configuration
REDIS_HOST=redis-prod.yourdomain.com
REDIS_PORT=6379
REDIS_PASSWORD=your-redis-password
REDIS_DB=0

# JWT Configuration
JWT_SECRET_KEY=your-256-bit-secret-key
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=15
JWT_REFRESH_TOKEN_EXPIRE_DAYS=30

# OAuth2 Configuration
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_USE_TLS=true

# Security Configuration
CORS_ORIGINS=["https://yourdomain.com"]
ALLOWED_HOSTS=["yourdomain.com", "api.yourdomain.com"]
USE_HTTPS=true
SECURE_COOKIES=true

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_LOGIN=5/minute
RATE_LIMIT_API=1000/minute
RATE_LIMIT_STORAGE_URI=redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/1

# Monitoring
ENABLE_METRICS=true
LOG_LEVEL=INFO
SENTRY_DSN=your-sentry-dsn
```

## 🐳 Docker Deployment

### Production Docker Compose

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d
    networks:
      - backend
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/run/postgresql

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - backend
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp

  backend:
    image: enterprise-auth-backend:${APP_VERSION}
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    environment:
      - ENVIRONMENT=${ENVIRONMENT}
      - DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/${REDIS_DB}
    depends_on:
      - postgres
      - redis
    networks:
      - backend
      - frontend
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  frontend:
    image: enterprise-auth-frontend:${APP_VERSION}
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    environment:
      - NEXT_PUBLIC_API_URL=${BACKEND_URL}
    networks:
      - frontend
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
      - /var/cache/nginx
      - /var/run

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/prod/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/prod/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - backend
      - frontend
    networks:
      - frontend
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true

volumes:
  postgres_data:
  redis_data:
```

### Deploying with Docker Compose

```bash
# Build and start services
docker-compose -f docker-compose.prod.yml up -d

# Check service status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Run database migrations
docker-compose -f docker-compose.prod.yml exec backend alembic upgrade head

# Create initial admin user
docker-compose -f docker-compose.prod.yml exec backend python -m app.scripts.create_admin
```

## ☸️ Kubernetes Deployment

### Kubernetes Manifests

#### Namespace

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: enterprise-auth
```

#### ConfigMap

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: enterprise-auth-config
  namespace: enterprise-auth
data:
  ENVIRONMENT: "production"
  LOG_LEVEL: "INFO"
  BACKEND_URL: "https://api.yourdomain.com"
  FRONTEND_URL: "https://yourdomain.com"
```

#### Secrets

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: enterprise-auth-secrets
  namespace: enterprise-auth
type: Opaque
data:
  JWT_SECRET_KEY: base64-encoded-secret
  POSTGRES_PASSWORD: base64-encoded-password
  REDIS_PASSWORD: base64-encoded-password
  GOOGLE_CLIENT_SECRET: base64-encoded-secret
  GITHUB_CLIENT_SECRET: base64-encoded-secret
```

#### Database Deployment

```yaml
# k8s/postgres.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: enterprise-auth
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:16-alpine
        env:
        - name: POSTGRES_DB
          value: "enterprise_auth_prod"
        - name: POSTGRES_USER
          value: "auth_prod_user"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: enterprise-auth-secrets
              key: POSTGRES_PASSWORD
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
      volumes:
      - name: postgres-storage
        persistentVolumeClaim:
          claimName: postgres-pvc

---
apiVersion: v1
kind: Service
metadata:
  name: postgres-service
  namespace: enterprise-auth
spec:
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: enterprise-auth
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
```

#### Backend Deployment

```yaml
# k8s/backend.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: enterprise-auth
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: enterprise-auth-backend:1.0.0
        envFrom:
        - configMapRef:
            name: enterprise-auth-config
        env:
        - name: DATABASE_URL
          value: "postgresql://auth_prod_user:$(POSTGRES_PASSWORD)@postgres-service:5432/enterprise_auth_prod"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: enterprise-auth-secrets
              key: POSTGRES_PASSWORD
        - name: JWT_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: enterprise-auth-secrets
              key: JWT_SECRET_KEY
        ports:
        - containerPort: 8000
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"

---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: enterprise-auth
spec:
  selector:
    app: backend
  ports:
  - port: 8000
    targetPort: 8000
```

#### Ingress

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: enterprise-auth-ingress
  namespace: enterprise-auth
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - yourdomain.com
    - api.yourdomain.com
    secretName: enterprise-auth-tls
  rules:
  - host: yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 3000
  - host: api.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8000
```

### Deploy to Kubernetes

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods -n enterprise-auth

# Run migrations
kubectl exec -it deployment/backend -n enterprise-auth -- alembic upgrade head

# Scale deployment
kubectl scale deployment backend --replicas=5 -n enterprise-auth
```

## ☁️ Cloud Platform Deployment

### AWS Deployment (ECS)

#### ECS Task Definition

```json
{
  "family": "enterprise-auth-backend",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::account:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "backend",
      "image": "your-account.dkr.ecr.region.amazonaws.com/enterprise-auth-backend:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "ENVIRONMENT",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:enterprise-auth/database-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/enterprise-auth",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Google Cloud Platform (Cloud Run)

```yaml
# cloudrun.yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: enterprise-auth-backend
  annotations:
    run.googleapis.com/ingress: all
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/maxScale: "10"
        run.googleapis.com/cpu-throttling: "false"
    spec:
      containerConcurrency: 100
      timeoutSeconds: 300
      containers:
      - image: gcr.io/project-id/enterprise-auth-backend:latest
        ports:
        - containerPort: 8000
        env:
        - name: ENVIRONMENT
          value: production
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-url
              key: url
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
```

Deploy to Cloud Run:

```bash
# Build and push image
gcloud builds submit --tag gcr.io/PROJECT_ID/enterprise-auth-backend

# Deploy service
gcloud run deploy enterprise-auth-backend \
  --image gcr.io/PROJECT_ID/enterprise-auth-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## 💾 Database Setup

### PostgreSQL Production Configuration

#### Connection Pooling with PgBouncer

```ini
# pgbouncer.ini
[databases]
enterprise_auth_prod = host=postgres port=5432 dbname=enterprise_auth_prod

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 200
default_pool_size = 50
reserve_pool_size = 5
```

#### Database Migrations

```bash
# Run migrations in production
docker-compose -f docker-compose.prod.yml exec backend alembic upgrade head

# Create migration for schema changes
docker-compose -f docker-compose.prod.yml exec backend alembic revision --autogenerate -m "Add new table"

# Check migration status
docker-compose -f docker-compose.prod.yml exec backend alembic current
```

#### Database Backup Script

```bash
#!/bin/bash
# backup-db.sh

BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/enterprise_auth_backup_$TIMESTAMP.sql"

# Create backup
pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Remove backups older than 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_FILE.gz"
```

## 🔐 SSL/TLS Configuration

### Nginx SSL Configuration

```nginx
# nginx/prod/default.conf
server {
    listen 80;
    server_name yourdomain.com api.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/nginx/ssl/yourdomain.com.crt;
    ssl_certificate_key /etc/nginx/ssl/yourdomain.com.key;
    
    # SSL Security Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    location / {
        proxy_pass http://frontend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;

    ssl_certificate /etc/nginx/ssl/yourdomain.com.crt;
    ssl_certificate_key /etc/nginx/ssl/yourdomain.com.key;
    
    location / {
        proxy_pass http://backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Let's Encrypt with Certbot

```bash
# Install certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Generate certificates
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com

# Auto-renewal cron job
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null
```

## 📊 Monitoring Setup

### Prometheus Configuration

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']
    metrics_path: '/metrics'
    scrape_interval: 15s
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
      
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
```

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Enterprise Auth Template",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds_bucket)"
          }
        ]
      }
    ]
  }
}
```

## 🔄 Backup and Recovery

### Automated Backup Strategy

```bash
#!/bin/bash
# backup-strategy.sh

# Database backup
pg_dump $DATABASE_URL | gzip > /backups/db/backup_$(date +%Y%m%d).sql.gz

# Redis backup
redis-cli -h $REDIS_HOST -p $REDIS_PORT --rdb /backups/redis/backup_$(date +%Y%m%d).rdb

# Upload to S3
aws s3 sync /backups s3://your-backup-bucket/enterprise-auth/$(date +%Y/%m/%d)

# Cleanup old backups
find /backups -type f -mtime +30 -delete
```

### Recovery Procedures

```bash
# Database recovery
gunzip -c backup_20240905.sql.gz | psql $DATABASE_URL

# Redis recovery
redis-cli -h $REDIS_HOST -p $REDIS_PORT --rdb backup_20240905.rdb

# Application recovery
docker-compose -f docker-compose.prod.yml up -d
```

## 🔧 Troubleshooting

### Common Issues

#### Service Won't Start

```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Check service status
docker-compose -f docker-compose.prod.yml ps

# Check network connectivity
docker-compose -f docker-compose.prod.yml exec backend ping postgres
```

#### Database Connection Issues

```bash
# Test database connection
docker-compose -f docker-compose.prod.yml exec backend python -c "
from app.core.database import engine
from sqlalchemy import text
with engine.connect() as conn:
    result = conn.execute(text('SELECT 1'))
    print('Database connection successful')
"
```

#### SSL Certificate Issues

```bash
# Check certificate expiration
openssl x509 -in /path/to/certificate.crt -text -noout | grep "Not After"

# Test SSL configuration
curl -I https://yourdomain.com

# Verify certificate chain
openssl verify -CAfile ca-bundle.crt yourdomain.com.crt
```

### Performance Tuning

#### Backend Optimization

```python
# app/core/config.py
class Settings(BaseSettings):
    # Database connection pool
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 30
    DB_POOL_TIMEOUT: int = 30
    
    # Worker processes
    WORKERS_PER_CORE: int = 2
    MAX_WORKERS: int = 16
    
    # Caching
    CACHE_TTL: int = 300
    REDIS_POOL_SIZE: int = 50
```

#### Database Optimization

```sql
-- Create indexes for performance
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_sessions_user_id ON sessions(user_id);
CREATE INDEX CONCURRENTLY idx_audit_logs_timestamp ON audit_logs(timestamp DESC);

-- Analyze table statistics
ANALYZE users;
ANALYZE sessions;
ANALYZE audit_logs;
```

### Security Checklist

- [ ] All secrets stored securely (not in code)
- [ ] SSL/TLS certificates properly configured
- [ ] Database access restricted to application only
- [ ] Rate limiting enabled and configured
- [ ] Security headers properly set
- [ ] Regular security updates applied
- [ ] Backup encryption enabled
- [ ] Monitoring and alerting configured
- [ ] Access logs enabled and monitored
- [ ] Firewall rules properly configured

---

## 📞 Support

For deployment issues:
1. Check the [troubleshooting section](#troubleshooting)
2. Review application logs
3. Consult the [GitHub Issues](https://github.com/your-org/enterprise-auth-template/issues)
4. Contact support at support@your-organization.com

**Remember**: Always test deployments in a staging environment before production!