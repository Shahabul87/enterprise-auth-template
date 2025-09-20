# Railway Deployment Guide

This guide will walk you through deploying your Enterprise Auth Template (FastAPI + Next.js) to Railway.

## Prerequisites

1. Railway account (sign up at https://railway.app)
2. GitHub repository connected
3. Railway CLI (optional): `npm i -g @railway/cli`

## Deployment Steps

### Step 1: Create Railway Project

1. Go to https://railway.app/new
2. Choose "Deploy from GitHub repo"
3. Select your repository: `Shahabul87/enterprise-auth-template`
4. Railway will automatically detect the services

### Step 2: Add PostgreSQL Database

1. In your Railway project, click "New Service"
2. Choose "Database" → "PostgreSQL"
3. Railway will automatically provision PostgreSQL
4. Note the connection string (will be available as `DATABASE_URL`)

### Step 3: Add Redis

1. Click "New Service" again
2. Choose "Database" → "Redis"
3. Railway will provision Redis
4. Note the connection URL (will be available as `REDIS_URL`)

### Step 4: Configure Backend Service

Click on your backend service and add these environment variables:

```env
# Database
DATABASE_URL=${{Postgres.DATABASE_URL}}
POSTGRES_USER=${{Postgres.PGUSER}}
POSTGRES_PASSWORD=${{Postgres.PGPASSWORD}}
POSTGRES_DB=${{Postgres.PGDATABASE}}
POSTGRES_HOST=${{Postgres.PGHOST}}
POSTGRES_PORT=${{Postgres.PGPORT}}

# Redis
REDIS_URL=${{Redis.REDIS_URL}}

# Security
JWT_SECRET_KEY=your-super-secret-jwt-key-change-this
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# CORS
CORS_ORIGINS=https://your-frontend-domain.railway.app

# Environment
ENVIRONMENT=production
DEBUG=false

# Email (optional - for production)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-specific-password
EMAIL_FROM=noreply@yourdomain.com

# OAuth (optional)
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret
```

### Step 5: Configure Frontend Service

Click on your frontend service and add these environment variables:

```env
# API URL - Update with your backend service URL
NEXT_PUBLIC_API_URL=https://backend-production-xxxx.up.railway.app
NEXT_PUBLIC_API_BASE_URL=https://backend-production-xxxx.up.railway.app/api

# NextAuth
NEXTAUTH_URL=https://frontend-production-xxxx.up.railway.app
NEXTAUTH_SECRET=your-nextauth-secret-key-change-this

# OAuth (must match backend)
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
GITHUB_CLIENT_ID=your-github-client-id
GITHUB_CLIENT_SECRET=your-github-client-secret

# Features
NEXT_PUBLIC_ENABLE_PWA=true
NEXT_PUBLIC_ENABLE_ANALYTICS=true
```

### Step 6: Deploy Commands

Railway will use these commands automatically:

#### Backend Build & Start:
```bash
# Build
cd backend && pip install -r requirements.txt

# Start (with migrations)
cd backend && alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

#### Frontend Build & Start:
```bash
# Build
cd frontend && npm ci && npm run build

# Start
cd frontend && npm start
```

### Step 7: Custom Domains (Optional)

1. Go to Settings → Domains for each service
2. Add your custom domain
3. Update DNS records as instructed

## Using Railway CLI

If you prefer CLI deployment:

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Link to project
railway link

# Deploy backend
railway up --service backend

# Deploy frontend
railway up --service frontend

# View logs
railway logs --service backend
railway logs --service frontend
```

## Environment-Specific Files

Create `.env.production` files:

### Backend `.env.production`:
```env
ENVIRONMENT=production
DEBUG=false
DATABASE_URL=${DATABASE_URL}
REDIS_URL=${REDIS_URL}
```

### Frontend `.env.production`:
```env
NODE_ENV=production
NEXT_PUBLIC_API_URL=${BACKEND_URL}
```

## Monitoring & Logs

1. **Logs**: Click on service → "View Logs"
2. **Metrics**: Click on service → "Metrics"
3. **Deployments**: Click on service → "Deployments"

## Health Checks

Railway automatically monitors:
- Backend: `https://your-backend.railway.app/health`
- Frontend: `https://your-frontend.railway.app/api/health`

## Scaling

To scale your services:

1. Go to service Settings
2. Under "Deploy" section:
   - Adjust "Replicas" for horizontal scaling
   - Adjust "CPU" and "Memory" for vertical scaling

## CI/CD

Railway automatically deploys when you push to GitHub:
- Push to `main` → Production deployment
- Push to `develop` → Staging deployment (if configured)

## Troubleshooting

### Common Issues:

1. **Database Connection Issues**
   ```bash
   # Check if migrations ran
   railway logs --service backend | grep alembic
   ```

2. **CORS Errors**
   - Ensure `CORS_ORIGINS` in backend includes frontend URL
   - Check `NEXT_PUBLIC_API_URL` in frontend

3. **Build Failures**
   ```bash
   # Check build logs
   railway logs --service backend --deployment
   ```

4. **Port Issues**
   - Railway provides `PORT` env variable automatically
   - Ensure your app uses `$PORT` or `process.env.PORT`

## Cost Optimization

Railway offers:
- **Developer Plan**: $5/month (includes $5 of usage)
- **Team Plan**: $20/seat/month
- **Free tier**: 500 hours/month

Tips:
1. Use "Sleep" feature for staging environments
2. Set up proper caching (Redis)
3. Optimize Docker images
4. Use CDN for static assets

## Security Checklist

- [ ] Change all default secrets
- [ ] Enable HTTPS (automatic on Railway)
- [ ] Set proper CORS origins
- [ ] Enable rate limiting
- [ ] Configure proper CSP headers
- [ ] Set up monitoring alerts
- [ ] Enable 2FA on Railway account
- [ ] Rotate secrets regularly

## Support

- Railway Discord: https://discord.gg/railway
- Railway Docs: https://docs.railway.app
- Status Page: https://status.railway.app

## Next Steps

1. Set up monitoring (Sentry, LogRocket)
2. Configure CDN (Cloudflare)
3. Set up backup strategy
4. Implement CI/CD pipelines
5. Configure staging environment