# Troubleshooting Guide

This guide provides solutions to common issues you might encounter when setting up, developing, or deploying the Enterprise Authentication Template.

## 📋 Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Setup Issues](#setup-issues)
- [Database Issues](#database-issues)
- [Authentication Problems](#authentication-problems)
- [API Issues](#api-issues)
- [Frontend Problems](#frontend-problems)
- [Docker Issues](#docker-issues)
- [Performance Problems](#performance-problems)
- [Production Issues](#production-issues)
- [Monitoring & Logging](#monitoring--logging)

## 🔍 Quick Diagnostics

### Health Check Commands

Before diving into specific issues, run these commands to get an overview of system health:

```bash
# Check all services status
make status

# Quick system health check
make health-check

# View all service logs
make logs

# Check database connectivity
make db-test

# Check Redis connectivity  
make redis-test
```

### System Information

```bash
# Check Docker status
docker --version
docker-compose --version
docker system df

# Check system resources
free -h          # Memory usage
df -h           # Disk usage
top             # CPU usage

# Check network connectivity
ping google.com
nslookup localhost
```

## 🚀 Setup Issues

### Issue: `make setup` Fails

**Symptoms:**
```bash
$ make setup
Permission denied
```

**Solutions:**

1. **Check Docker permissions:**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   newgrp docker
   
   # Test Docker without sudo
   docker run hello-world
   ```

2. **Verify Docker is running:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Check file permissions:**
   ```bash
   chmod +x init-project.sh
   chmod +x *.sh
   ```

### Issue: Environment File Not Found

**Symptoms:**
```
Error: .env file not found
```

**Solutions:**

1. **Copy example environment:**
   ```bash
   cp .env.example .env
   cp .env.example .env.dev
   ```

2. **Verify file exists:**
   ```bash
   ls -la .env*
   ```

3. **Check file contents:**
   ```bash
   cat .env.example
   ```

### Issue: Port Already in Use

**Symptoms:**
```
ERROR: for backend Cannot start service backend: driver failed programming external connectivity on endpoint
```

**Solutions:**

1. **Find processes using ports:**
   ```bash
   # Check common ports
   lsof -i :3000  # Frontend
   lsof -i :8000  # Backend
   lsof -i :5432  # PostgreSQL
   lsof -i :6379  # Redis
   ```

2. **Kill processes:**
   ```bash
   # Kill specific processes
   kill -9 $(lsof -t -i:8000)
   
   # Or stop all containers
   docker-compose down
   ```

3. **Use different ports:**
   ```bash
   # Edit docker-compose.dev.yml or .env file
   BACKEND_PORT=8001
   FRONTEND_PORT=3001
   ```

## 🗄️ Database Issues

### Issue: Database Connection Failed

**Symptoms:**
```
sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) could not connect to server
```

**Solutions:**

1. **Check PostgreSQL container:**
   ```bash
   # Check if container is running
   docker-compose ps postgres
   
   # Check container logs
   docker-compose logs postgres
   
   # Restart database
   docker-compose restart postgres
   ```

2. **Verify connection parameters:**
   ```bash
   # Test connection manually
   docker-compose exec postgres psql -U dev_user -d enterprise_auth_dev -c "SELECT 1;"
   ```

3. **Check environment variables:**
   ```bash
   # Verify database URL
   echo $DATABASE_URL
   
   # Or check in container
   docker-compose exec backend env | grep DATABASE
   ```

4. **Reset database:**
   ```bash
   # CAREFUL: This deletes all data
   make db-reset
   ```

### Issue: Migration Fails

**Symptoms:**
```
alembic.util.exc.CommandError: Can't locate revision identified by 'abc123'
```

**Solutions:**

1. **Check migration status:**
   ```bash
   docker-compose exec backend alembic current
   docker-compose exec backend alembic history
   ```

2. **Reset migrations (DESTRUCTIVE):**
   ```bash
   # Backup data first!
   make db-backup
   
   # Reset migrations
   docker-compose exec backend alembic downgrade base
   docker-compose exec backend alembic upgrade head
   ```

3. **Generate new migration:**
   ```bash
   docker-compose exec backend alembic revision --autogenerate -m "Fix migration"
   ```

### Issue: Database Locks / Deadlocks

**Symptoms:**
```
psycopg2.errors.DeadlockDetected: deadlock detected
```

**Solutions:**

1. **Check active connections:**
   ```sql
   -- Connect to database
   docker-compose exec postgres psql -U dev_user -d enterprise_auth_dev
   
   -- Check active queries
   SELECT pid, state, query FROM pg_stat_activity WHERE state = 'active';
   
   -- Kill problematic queries
   SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE state = 'active' AND pid != pg_backend_pid();
   ```

2. **Adjust connection pool:**
   ```python
   # In backend/app/core/database.py
   engine = create_async_engine(
       DATABASE_URL,
       pool_size=5,        # Reduce pool size
       max_overflow=10,    # Reduce overflow
       pool_timeout=30,    # Increase timeout
   )
   ```

## 🔐 Authentication Problems

### Issue: JWT Token Invalid/Expired

**Symptoms:**
```json
{
  "error": {
    "code": "TOKEN_INVALID",
    "message": "Token has expired"
  }
}
```

**Solutions:**

1. **Check token expiration:**
   ```bash
   # Decode JWT token (use online JWT debugger or)
   python -c "
   import jwt
   token = 'your-jwt-token'
   decoded = jwt.decode(token, options={'verify_signature': False})
   print(decoded)
   "
   ```

2. **Verify JWT secret:**
   ```bash
   # Check JWT secret in environment
   docker-compose exec backend env | grep JWT_SECRET_KEY
   ```

3. **Clear all sessions:**
   ```bash
   # Clear Redis cache
   docker-compose exec redis redis-cli FLUSHALL
   ```

### Issue: OAuth Login Fails

**Symptoms:**
- OAuth redirect fails
- "Invalid client" error from OAuth provider

**Solutions:**

1. **Verify OAuth configuration:**
   ```bash
   # Check OAuth environment variables
   docker-compose exec backend env | grep -E "(GOOGLE|GITHUB|DISCORD)_CLIENT"
   ```

2. **Check redirect URIs:**
   ```bash
   # Verify redirect URLs are configured correctly in OAuth provider
   # Google: http://localhost:8000/auth/oauth/google/callback
   # GitHub: http://localhost:8000/auth/oauth/github/callback
   ```

3. **Test OAuth endpoints:**
   ```bash
   curl -I "http://localhost:8000/auth/oauth/google"
   ```

### Issue: Password Reset Not Working

**Symptoms:**
- Reset emails not sent
- Reset tokens invalid

**Solutions:**

1. **Check email configuration:**
   ```bash
   # Test email service
   docker-compose exec backend python -c "
   from app.services.email_service import EmailService
   email_service = EmailService()
   # This will test SMTP connection
   "
   ```

2. **Verify email templates:**
   ```bash
   # Check if email templates exist
   ls -la backend/app/templates/email/
   ```

3. **Check Redis for tokens:**
   ```bash
   # Connect to Redis and check for reset tokens
   docker-compose exec redis redis-cli
   KEYS "password_reset:*"
   ```

## 🔌 API Issues

### Issue: CORS Errors

**Symptoms:**
```
Access to XMLHttpRequest at 'http://localhost:8000/api/v1/users/me' from origin 'http://localhost:3000' has been blocked by CORS policy
```

**Solutions:**

1. **Check CORS configuration:**
   ```python
   # In backend/app/main.py
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["http://localhost:3000"],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

2. **Verify environment variables:**
   ```bash
   docker-compose exec backend env | grep CORS
   ```

3. **Check browser network tab:**
   - Look for preflight OPTIONS requests
   - Verify response headers include `Access-Control-Allow-Origin`

### Issue: Rate Limiting Blocking Requests

**Symptoms:**
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests"
  }
}
```

**Solutions:**

1. **Check rate limit configuration:**
   ```bash
   docker-compose exec backend env | grep RATE_LIMIT
   ```

2. **Clear rate limit cache:**
   ```bash
   # Clear Redis rate limit keys
   docker-compose exec redis redis-cli
   KEYS "rate_limit:*"
   DEL rate_limit:*
   ```

3. **Adjust rate limits:**
   ```bash
   # In .env file
   RATE_LIMIT_API=1000/minute
   RATE_LIMIT_LOGIN=10/minute
   ```

### Issue: 500 Internal Server Error

**Symptoms:**
- API returns 500 status code
- Generic error messages

**Solutions:**

1. **Check backend logs:**
   ```bash
   docker-compose logs backend --tail=50
   ```

2. **Enable debug mode:**
   ```bash
   # In .env file
   DEBUG=true
   LOG_LEVEL=DEBUG
   ```

3. **Check database connectivity:**
   ```bash
   docker-compose exec backend python -c "
   from app.core.database import engine
   from sqlalchemy import text
   
   async def test():
       async with engine.begin() as conn:
           result = await conn.execute(text('SELECT 1'))
           print('DB connection OK')
   
   import asyncio
   asyncio.run(test())
   "
   ```

## ⚛️ Frontend Problems

### Issue: Next.js Build Fails

**Symptoms:**
```
Error: Failed to compile
Module not found: Can't resolve '@/components/ui/button'
```

**Solutions:**

1. **Check TypeScript paths:**
   ```json
   // In frontend/tsconfig.json
   {
     "compilerOptions": {
       "baseUrl": ".",
       "paths": {
         "@/*": ["./src/*"]
       }
     }
   }
   ```

2. **Reinstall dependencies:**
   ```bash
   cd frontend
   rm -rf node_modules package-lock.json
   npm install
   ```

3. **Check file imports:**
   ```typescript
   // Use correct import paths
   import { Button } from "@/components/ui/button"  // ✅
   import { Button } from "../ui/button"            // ❌ (relative path)
   ```

### Issue: Environment Variables Not Available

**Symptoms:**
- `process.env.NEXT_PUBLIC_API_URL` is undefined
- API calls fail with wrong URLs

**Solutions:**

1. **Check environment variable names:**
   ```bash
   # Must start with NEXT_PUBLIC_ for client-side
   NEXT_PUBLIC_API_URL=http://localhost:8000
   ```

2. **Restart development server:**
   ```bash
   # Environment variables are loaded at startup
   docker-compose restart frontend
   ```

3. **Verify in browser:**
   ```javascript
   // In browser console
   console.log(process.env.NEXT_PUBLIC_API_URL)
   ```

### Issue: Hydration Errors

**Symptoms:**
```
Warning: Text content did not match. Server: "Login" Client: "Logout"
```

**Solutions:**

1. **Check for client-only code:**
   ```typescript
   import { useEffect, useState } from 'react'
   
   function MyComponent() {
     const [mounted, setMounted] = useState(false)
     
     useEffect(() => {
       setMounted(true)
     }, [])
     
     if (!mounted) return null
     
     return <div>{/* Client-only content */}</div>
   }
   ```

2. **Use dynamic imports:**
   ```typescript
   import dynamic from 'next/dynamic'
   
   const ClientOnlyComponent = dynamic(
     () => import('../components/ClientOnly'),
     { ssr: false }
   )
   ```

## 🐳 Docker Issues

### Issue: Docker Build Fails

**Symptoms:**
```
ERROR [backend 5/8] RUN pip install -r requirements.txt
```

**Solutions:**

1. **Clear Docker cache:**
   ```bash
   docker system prune -a
   docker-compose build --no-cache
   ```

2. **Check Dockerfile:**
   ```dockerfile
   # Ensure correct Python version
   FROM python:3.11-slim
   
   # Update package lists
   RUN apt-get update && apt-get install -y \
       build-essential \
       && rm -rf /var/lib/apt/lists/*
   ```

3. **Check requirements.txt:**
   ```bash
   # Verify file exists and has content
   cat backend/requirements.txt
   ```

### Issue: Container Exits Immediately

**Symptoms:**
```
backend_1 exited with code 1
```

**Solutions:**

1. **Check container logs:**
   ```bash
   docker-compose logs backend
   ```

2. **Run container interactively:**
   ```bash
   docker-compose run --rm backend bash
   ```

3. **Check entry point:**
   ```dockerfile
   # In Dockerfile
   CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
   ```

### Issue: Volume Mount Not Working

**Symptoms:**
- Code changes not reflected
- Files not persisting

**Solutions:**

1. **Check volume syntax:**
   ```yaml
   # In docker-compose.yml
   services:
     backend:
       volumes:
         - ./backend:/app        # ✅ Correct
         - ./backend:/app/       # ❌ Trailing slash can cause issues
   ```

2. **Verify file permissions:**
   ```bash
   # Check ownership
   ls -la backend/
   
   # Fix permissions if needed
   sudo chown -R $USER:$USER backend/
   ```

3. **Check Docker settings:**
   ```bash
   # On macOS/Windows, ensure file sharing is enabled
   # Docker Desktop > Preferences > File Sharing
   ```

## 🚀 Performance Problems

### Issue: Slow API Response Times

**Symptoms:**
- API requests taking > 1 second
- High database load

**Solutions:**

1. **Enable query logging:**
   ```python
   # In backend/app/core/database.py
   engine = create_async_engine(
       DATABASE_URL,
       echo=True,  # Enable SQL query logging
   )
   ```

2. **Check database indexes:**
   ```sql
   -- Check slow queries
   SELECT query, mean_time, calls 
   FROM pg_stat_statements 
   ORDER BY mean_time DESC 
   LIMIT 10;
   
   -- Check missing indexes
   SELECT schemaname, tablename, attname, n_distinct, correlation 
   FROM pg_stats 
   WHERE schemaname = 'public';
   ```

3. **Add database indexes:**
   ```sql
   -- Common indexes for auth template
   CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
   CREATE INDEX CONCURRENTLY idx_sessions_user_id ON sessions(user_id);
   CREATE INDEX CONCURRENTLY idx_sessions_expires_at ON sessions(expires_at);
   ```

4. **Optimize queries:**
   ```python
   # Use select loading for relationships
   users = await session.execute(
       select(User)
       .options(selectinload(User.roles))
       .where(User.is_active == True)
   )
   ```

### Issue: High Memory Usage

**Symptoms:**
- Containers using excessive memory
- System becomes slow

**Solutions:**

1. **Check memory usage:**
   ```bash
   docker stats
   ```

2. **Limit container memory:**
   ```yaml
   # In docker-compose.yml
   services:
     backend:
       mem_limit: 1g
       memswap_limit: 2g
   ```

3. **Optimize connection pools:**
   ```python
   # Reduce pool sizes
   engine = create_async_engine(
       DATABASE_URL,
       pool_size=5,
       max_overflow=10,
   )
   ```

## 🔧 Production Issues

### Issue: SSL Certificate Problems

**Symptoms:**
```
SSL: CERTIFICATE_VERIFY_FAILED
```

**Solutions:**

1. **Check certificate expiry:**
   ```bash
   openssl x509 -in certificate.crt -text -noout | grep "Not After"
   ```

2. **Verify certificate chain:**
   ```bash
   openssl verify -CAfile ca-bundle.crt domain.crt
   ```

3. **Test SSL configuration:**
   ```bash
   curl -I https://yourdomain.com
   openssl s_client -connect yourdomain.com:443
   ```

### Issue: Load Balancer Health Checks Failing

**Symptoms:**
- Services marked as unhealthy
- Traffic not reaching application

**Solutions:**

1. **Check health endpoint:**
   ```bash
   curl http://localhost:8000/health
   ```

2. **Verify health check configuration:**
   ```python
   # In backend/app/api/v1/health.py
   @router.get("/health")
   async def health_check():
       return {
           "status": "healthy",
           "timestamp": datetime.utcnow(),
           "version": "1.0.0"
       }
   ```

3. **Check load balancer configuration:**
   ```yaml
   # Example for docker-compose
   healthcheck:
     test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
     interval: 30s
     timeout: 10s
     retries: 3
     start_period: 40s
   ```

## 📊 Monitoring & Logging

### Issue: Logs Not Appearing

**Symptoms:**
- No logs in monitoring dashboard
- Missing log files

**Solutions:**

1. **Check log configuration:**
   ```python
   # In backend/app/core/logging_config.py
   import logging
   
   logging.basicConfig(
       level=logging.INFO,
       format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
   )
   ```

2. **Verify log levels:**
   ```bash
   docker-compose exec backend env | grep LOG_LEVEL
   ```

3. **Check log files:**
   ```bash
   # View container logs
   docker-compose logs backend --tail=100
   
   # Check log files in container
   docker-compose exec backend ls -la /app/logs/
   ```

### Issue: Metrics Not Collected

**Symptoms:**
- Prometheus not scraping metrics
- Grafana dashboards empty

**Solutions:**

1. **Check metrics endpoint:**
   ```bash
   curl http://localhost:8000/metrics
   ```

2. **Verify Prometheus configuration:**
   ```yaml
   # In monitoring/prometheus.yml
   scrape_configs:
     - job_name: 'backend'
       static_configs:
         - targets: ['backend:8000']
       metrics_path: '/metrics'
   ```

3. **Check Prometheus targets:**
   ```bash
   # Access Prometheus UI at http://localhost:9090
   # Go to Status > Targets
   ```

## 🔍 Diagnostic Tools

### Log Analysis Commands

```bash
# Search for specific errors
docker-compose logs backend 2>&1 | grep -i error

# Monitor logs in real-time
docker-compose logs -f backend

# Check last 100 log entries
docker-compose logs backend --tail=100

# Search logs by timestamp
docker-compose logs backend --since="2024-09-05T10:00:00"
```

### Database Diagnostic Queries

```sql
-- Check database size
SELECT pg_size_pretty(pg_database_size(current_database()));

-- Check table sizes
SELECT schemaname, tablename, 
       pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check active connections
SELECT count(*) FROM pg_stat_activity;

-- Check slow queries
SELECT query, mean_time, calls 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;
```

### Performance Monitoring

```bash
# Monitor system resources
htop

# Monitor disk I/O
iotop

# Monitor network usage
nethogs

# Check Docker resource usage
docker stats

# Check container processes
docker-compose exec backend ps aux
```

## 🆘 Emergency Procedures

### Complete System Reset

```bash
# WARNING: This will delete all data!
# 1. Stop all services
docker-compose down -v

# 2. Remove all containers and images
docker system prune -a

# 3. Remove volumes
docker volume prune

# 4. Start fresh
make setup
```

### Database Backup & Restore

```bash
# Create backup
docker-compose exec postgres pg_dump -U dev_user enterprise_auth_dev > backup.sql

# Restore from backup
docker-compose exec postgres psql -U dev_user -d enterprise_auth_dev < backup.sql
```

### Rollback Deployment

```bash
# Kubernetes rollback
kubectl rollout undo deployment/backend -n enterprise-auth

# Docker Compose rollback
docker-compose down
git checkout previous-stable-tag
docker-compose up -d
```

## 📞 Getting Help

If you're still experiencing issues:

1. **Search existing issues**: Check [GitHub Issues](https://github.com/your-org/enterprise-auth-template/issues)
2. **Create detailed bug report**: Include logs, configuration, and steps to reproduce
3. **Join discussions**: Ask in [GitHub Discussions](https://github.com/your-org/enterprise-auth-template/discussions)
4. **Check documentation**: Review all documentation in the `docs/` directory

### Bug Report Template

```markdown
## Description
Brief description of the issue

## Environment
- OS: [Ubuntu 20.04]
- Docker version: [20.10.7]
- Node.js version: [18.17.0]
- Python version: [3.11.0]

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Logs
```
[Include relevant logs here]
```

## Additional Context
Any other context about the problem
```

---

**Remember**: When troubleshooting, always check logs first and isolate the problem to the smallest possible component!