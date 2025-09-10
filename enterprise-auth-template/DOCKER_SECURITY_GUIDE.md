# Docker Security Configuration Guide

This document outlines the security measures implemented in the Docker configurations to protect against common container security vulnerabilities.

## Security Vulnerabilities Addressed

### 1. Exposed Database Ports (FIXED ✅)

**Issue**: Database ports (PostgreSQL 5432, Redis 6379) were exposed to the host system, making them accessible from outside the Docker network.

**Risk**: 
- Direct database access from external networks
- Potential for unauthorized database connections
- Increased attack surface

**Solution**: 
- Removed port mappings from `docker-compose.dev.yml`
- Created separate override file for development database access
- Production configuration never exposed ports

### 2. Database Access During Development

**Development Override File**: `docker-compose.dev-with-db-access.yml`

Use when you need direct database access for development:

```bash
# Start with database access (localhost only)
docker-compose -f docker-compose.dev.yml -f docker-compose.dev-with-db-access.yml up

# Normal development (no exposed ports)
docker-compose -f docker-compose.dev.yml up
```

### 3. Security Hardening Features

#### PostgreSQL Security
- Connection limits (`max_connections=100`)
- Query logging (`log_statement=all`)
- SCRAM-SHA-256 authentication in development override
- SSL enabled in production
- Health checks implemented

#### Redis Security
- Memory limits (`maxmemory 512mb`)
- Password protection in production
- Connection timeouts (`timeout 300`)
- Persistence configuration
- Health checks implemented

## Network Security

### Docker Network Isolation
All services communicate through isolated Docker networks:
- `dev_network` for development
- `prod_network` for production

### Port Binding Security
When ports are exposed (development override only):
- Bound to `127.0.0.1` (localhost only)
- Not accessible from external networks
- Requires local machine access

## Usage Guidelines

### For Development

#### Normal Development (Secure)
```bash
# Start all services without exposed database ports
docker-compose -f docker-compose.dev.yml up -d

# Access databases through Docker exec (recommended)
docker-compose exec postgres psql -U dev_user -d enterprise_auth_dev
docker-compose exec redis redis-cli
```

#### Development with Database Tools
```bash
# Start with database access for tools like pgAdmin, Redis Commander
docker-compose -f docker-compose.dev.yml -f docker-compose.dev-with-db-access.yml up -d

# Connect to databases at:
# PostgreSQL: localhost:5432
# Redis: localhost:6379
# pgAdmin: http://localhost:5050
```

### For Production

Production environment automatically uses secure configuration:
- No exposed database ports
- SSL encryption enabled
- Password-protected Redis
- Health monitoring
- Resource limits

```bash
# Production deployment (always secure)
docker-compose -f docker-compose.prod.yml up -d
```

## Security Checklist

- [x] Database ports not exposed to host by default
- [x] Development override available for local access only
- [x] Network isolation between services
- [x] SSL/TLS encryption in production
- [x] Password protection for Redis
- [x] Connection and resource limits
- [x] Health checks for all services
- [x] Logging configuration
- [x] SCRAM-SHA-256 authentication
- [x] Memory limits and policies

## Monitoring and Alerts

### Health Checks
All critical services include health checks:
- Database connectivity
- Redis availability
- Application response

### Logging
- PostgreSQL query logging enabled
- Application logs structured (JSON)
- Security events logged

### Resource Monitoring
- Memory limits enforced
- Connection limits configured
- Timeout settings applied

## Emergency Access

If you need to access databases in production for maintenance:

1. **Use Docker exec** (preferred):
   ```bash
   docker exec -it enterprise_auth_postgres_prod psql -U $POSTGRES_USER -d $POSTGRES_DB
   ```

2. **Temporary port forwarding** (emergency only):
   ```bash
   # Forward port temporarily
   kubectl port-forward svc/postgres 5432:5432
   
   # Don't forget to stop port forwarding!
   ```

3. **Database administration tools** should connect through:
   - Application service mesh
   - VPN connection
   - Bastion hosts
   - Never directly exposed ports

## Best Practices

1. **Never expose database ports in production**
2. **Use localhost-only binding for development**
3. **Regular security audits of container configurations**
4. **Keep base images updated**
5. **Monitor container logs for suspicious activity**
6. **Implement proper backup strategies**
7. **Use secrets management for sensitive data**

## Updates and Maintenance

This configuration should be reviewed:
- Monthly for security updates
- Before production deployments
- After Docker/PostgreSQL/Redis version upgrades
- When new security vulnerabilities are discovered

## Related Security Documents

- [Enterprise Security Standards](./CLAUDE.md#security-standards)
- [API Security Guidelines](./docs/api-security.md)
- [Authentication Security](./docs/auth-security.md)
- [Production Deployment Guide](./docs/deployment.md)