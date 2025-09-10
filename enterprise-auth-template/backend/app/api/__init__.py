"""
API Router Configuration

Main API router that includes all endpoint modules.
Organizes all API routes under a common prefix.
"""

from fastapi import APIRouter

# Import v1 routers
from app.api.v1.auth import router as auth_router
from app.api.v1.users import router as users_router
from app.api.v1.oauth import router as oauth_router
from app.api.v1.two_factor import router as two_factor_router
from app.api.v1.webauthn import router as webauthn_router
from app.api.v1.health import router as health_router
from app.api.v1.magic_links import router as magic_links_router
from app.api.v1.roles import router as roles_router
from app.api.v1.permissions import router as permissions_router
from app.api.v1.admin import router as admin_router
from app.api.v1.sessions import router as sessions_router
from app.api.v1.audit import router as audit_router
from app.api.v1.profile import router as profile_router
from app.api.v1.metrics import router as metrics_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.webhooks import router as webhooks_router
from app.api.v1.api_keys import router as api_keys_router
from app.api.v1.organizations import router as organizations_router
from app.api.v1.device_management import router as device_management_router
from app.api.v1.websocket import router as websocket_router

# Create main API router
api_router = APIRouter()

# Include all v1 routers
api_router.include_router(auth_router, prefix="/v1", tags=["Authentication"])
api_router.include_router(users_router, prefix="/v1", tags=["Users"])
api_router.include_router(oauth_router, prefix="/v1", tags=["OAuth"])
api_router.include_router(two_factor_router, prefix="/v1", tags=["Two Factor"])
api_router.include_router(webauthn_router, prefix="/v1", tags=["WebAuthn"])
api_router.include_router(health_router, prefix="/v1", tags=["Health"])
api_router.include_router(magic_links_router, prefix="/v1", tags=["Magic Links"])
api_router.include_router(roles_router, prefix="/v1", tags=["Roles"])
api_router.include_router(permissions_router, prefix="/v1", tags=["Permissions"])
api_router.include_router(admin_router, prefix="/v1", tags=["Admin"])
api_router.include_router(sessions_router, prefix="/v1", tags=["Sessions"])
api_router.include_router(audit_router, prefix="/v1", tags=["Audit"])
api_router.include_router(profile_router, prefix="/v1/profile", tags=["Profile"])
api_router.include_router(metrics_router, prefix="/v1/metrics", tags=["Metrics"])
api_router.include_router(notifications_router, prefix="/v1/notifications", tags=["Notifications"])
api_router.include_router(webhooks_router, prefix="/v1/webhooks", tags=["Webhooks"])
api_router.include_router(api_keys_router, prefix="/v1/api-keys", tags=["API Keys"])
api_router.include_router(organizations_router, prefix="/v1/organizations", tags=["Organizations"])
api_router.include_router(device_management_router, prefix="/v1/devices", tags=["Device Management"])
api_router.include_router(websocket_router, prefix="/v1", tags=["WebSocket"])


@api_router.get("/health/")
async def api_health():
    """API health check endpoint"""
    return {"status": "healthy", "version": "1.0.0", "service": "enterprise-auth-api"}


@api_router.get("/version")
async def api_version():
    """API version endpoint"""
    return {"version": "1.0.0", "service": "enterprise-auth-api"}
