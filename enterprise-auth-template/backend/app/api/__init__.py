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

# New routers for enhanced features
try:
    from app.api.v1.sms_auth import router as sms_auth_router

    SMS_AUTH_AVAILABLE = True
except ImportError:
    SMS_AUTH_AVAILABLE = False

try:
    from app.api.v1.monitoring import router as monitoring_router

    MONITORING_AVAILABLE = True
except ImportError:
    MONITORING_AVAILABLE = False

# Create main API router
api_router = APIRouter()

# Include all routers (v1 prefix handled by main app)
api_router.include_router(auth_router, prefix="/auth", tags=["Authentication"])
api_router.include_router(users_router, tags=["Users"])
api_router.include_router(oauth_router, tags=["OAuth"])
api_router.include_router(two_factor_router, tags=["Two Factor"])
api_router.include_router(webauthn_router, tags=["WebAuthn"])
api_router.include_router(health_router, tags=["Health"])
api_router.include_router(magic_links_router, tags=["Magic Links"])
api_router.include_router(roles_router, tags=["Roles"])
api_router.include_router(permissions_router, tags=["Permissions"])
api_router.include_router(admin_router, tags=["Admin"])
api_router.include_router(sessions_router, tags=["Sessions"])
api_router.include_router(audit_router, tags=["Audit"])
api_router.include_router(profile_router, prefix="/profile", tags=["Profile"])
api_router.include_router(metrics_router, prefix="/metrics", tags=["Metrics"])
api_router.include_router(
    notifications_router, prefix="/notifications", tags=["Notifications"]
)
api_router.include_router(webhooks_router, prefix="/webhooks", tags=["Webhooks"])
api_router.include_router(api_keys_router, prefix="/api-keys", tags=["API Keys"])
api_router.include_router(
    organizations_router, prefix="/organizations", tags=["Organizations"]
)
api_router.include_router(
    device_management_router, prefix="/devices", tags=["Device Management"]
)
api_router.include_router(websocket_router, tags=["WebSocket"])

# Include new feature routers if available
if SMS_AUTH_AVAILABLE:
    api_router.include_router(
        sms_auth_router, prefix="/auth", tags=["SMS Authentication"]
    )

if MONITORING_AVAILABLE:
    api_router.include_router(monitoring_router, tags=["Monitoring"])


@api_router.get("/health/")
async def api_health():
    """API health check endpoint"""
    return {"status": "healthy", "version": "1.0.0", "service": "enterprise-auth-api"}


@api_router.get("/version")
async def api_version():
    """API version endpoint"""
    return {"version": "1.0.0", "service": "enterprise-auth-api"}
