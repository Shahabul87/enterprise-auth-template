"""
System-wide constants for the application.
Central location for all application constants to ensure consistency.
"""
from enum import Enum
from typing import Final


# Application Metadata
APP_NAME: Final[str] = "Enterprise Authentication System"
APP_VERSION: Final[str] = "1.0.0"
API_VERSION: Final[str] = "v1"
API_PREFIX: Final[str] = f"/api/{API_VERSION}"


# Authentication Constants
ACCESS_TOKEN_EXPIRE_MINUTES: Final[int] = 30
REFRESH_TOKEN_EXPIRE_DAYS: Final[int] = 30
PASSWORD_RESET_TOKEN_EXPIRE_MINUTES: Final[int] = 15
MAGIC_LINK_EXPIRE_MINUTES: Final[int] = 15
EMAIL_VERIFICATION_TOKEN_EXPIRE_HOURS: Final[int] = 24
SESSION_EXPIRE_HOURS: Final[int] = 24
API_KEY_LENGTH: Final[int] = 32
OTP_LENGTH: Final[int] = 6
OTP_EXPIRE_SECONDS: Final[int] = 300  # 5 minutes


# Password Policy
MIN_PASSWORD_LENGTH: Final[int] = 8
MAX_PASSWORD_LENGTH: Final[int] = 128
PASSWORD_REQUIRE_UPPERCASE: Final[bool] = True
PASSWORD_REQUIRE_LOWERCASE: Final[bool] = True
PASSWORD_REQUIRE_NUMBERS: Final[bool] = True
PASSWORD_REQUIRE_SPECIAL: Final[bool] = True
PASSWORD_HISTORY_COUNT: Final[int] = 5  # Number of previous passwords to check
PASSWORD_EXPIRE_DAYS: Final[int] = 90


# Security Constants
MAX_LOGIN_ATTEMPTS: Final[int] = 5
LOGIN_ATTEMPT_WINDOW_MINUTES: Final[int] = 15
ACCOUNT_LOCKOUT_MINUTES: Final[int] = 30
BCRYPT_ROUNDS: Final[int] = 12
JWT_ALGORITHM: Final[str] = "HS256"
CSRF_TOKEN_LENGTH: Final[int] = 32
ALLOWED_ORIGINS: Final[list] = ["http://localhost:3000", "http://localhost:8000"]
SECURE_COOKIES: Final[bool] = True  # Should be True in production
COOKIE_HTTPONLY: Final[bool] = True
COOKIE_SAMESITE: Final[str] = "lax"


# Rate Limiting
DEFAULT_RATE_LIMIT: Final[str] = "100/minute"
LOGIN_RATE_LIMIT: Final[str] = "5/minute"
REGISTER_RATE_LIMIT: Final[str] = "3/minute"
PASSWORD_RESET_RATE_LIMIT: Final[str] = "3/hour"
API_KEY_RATE_LIMIT: Final[str] = "1000/hour"
ADMIN_RATE_LIMIT: Final[str] = "200/minute"


# Pagination
DEFAULT_PAGE_SIZE: Final[int] = 20
MAX_PAGE_SIZE: Final[int] = 100
MIN_PAGE_SIZE: Final[int] = 1


# File Upload
MAX_FILE_SIZE_MB: Final[int] = 10
ALLOWED_IMAGE_TYPES: Final[set] = {".jpg", ".jpeg", ".png", ".gif", ".webp"}
ALLOWED_DOCUMENT_TYPES: Final[set] = {".pdf", ".doc", ".docx", ".txt"}
AVATAR_MAX_SIZE_MB: Final[int] = 5


# Cache TTL (Time To Live) in seconds
CACHE_TTL_SHORT: Final[int] = 300  # 5 minutes
CACHE_TTL_MEDIUM: Final[int] = 3600  # 1 hour
CACHE_TTL_LONG: Final[int] = 86400  # 24 hours
CACHE_TTL_USER_SESSION: Final[int] = 1800  # 30 minutes
CACHE_TTL_PERMISSIONS: Final[int] = 600  # 10 minutes


# Database
DATABASE_POOL_SIZE: Final[int] = 20
DATABASE_MAX_OVERFLOW: Final[int] = 10
DATABASE_POOL_TIMEOUT: Final[int] = 30
DATABASE_POOL_RECYCLE: Final[int] = 3600
DATABASE_ECHO: Final[bool] = False  # Set to True for SQL debugging


# Email
EMAIL_FROM_NAME: Final[str] = "Enterprise Auth System"
EMAIL_MAX_RECIPIENTS: Final[int] = 50
EMAIL_RETRY_ATTEMPTS: Final[int] = 3
EMAIL_RETRY_DELAY_SECONDS: Final[int] = 60


# Webhook
WEBHOOK_TIMEOUT_SECONDS: Final[int] = 30
WEBHOOK_MAX_RETRIES: Final[int] = 3
WEBHOOK_RETRY_DELAY_SECONDS: Final[int] = 60
WEBHOOK_SIGNATURE_HEADER: Final[str] = "X-Webhook-Signature"


# Audit Log
AUDIT_LOG_RETENTION_DAYS: Final[int] = 90
AUDIT_LOG_BATCH_SIZE: Final[int] = 100


# System Limits
MAX_SESSIONS_PER_USER: Final[int] = 10
MAX_API_KEYS_PER_USER: Final[int] = 5
MAX_ROLES_PER_USER: Final[int] = 10
MAX_PERMISSIONS_PER_ROLE: Final[int] = 100
MAX_ORGANIZATIONS_PER_USER: Final[int] = 5
MAX_USERS_PER_ORGANIZATION: Final[int] = 1000


# Feature Flags
FEATURE_OAUTH_ENABLED: Final[bool] = True
FEATURE_2FA_ENABLED: Final[bool] = True
FEATURE_WEBAUTHN_ENABLED: Final[bool] = True
FEATURE_MAGIC_LINKS_ENABLED: Final[bool] = True
FEATURE_API_KEYS_ENABLED: Final[bool] = True
FEATURE_WEBHOOKS_ENABLED: Final[bool] = True
FEATURE_AUDIT_LOG_ENABLED: Final[bool] = True
FEATURE_RATE_LIMITING_ENABLED: Final[bool] = True
FEATURE_MULTI_TENANCY_ENABLED: Final[bool] = False


class UserStatus(str, Enum):
    """User account status enumeration."""
    ACTIVE = "active"
    INACTIVE = "inactive"
    SUSPENDED = "suspended"
    LOCKED = "locked"
    PENDING = "pending"
    DELETED = "deleted"


class UserRole(str, Enum):
    """Default user roles enumeration."""
    SUPER_ADMIN = "super_admin"
    ADMIN = "admin"
    MODERATOR = "moderator"
    USER = "user"
    GUEST = "guest"


class PermissionScope(str, Enum):
    """Permission scope enumeration."""
    READ = "read"
    WRITE = "write"
    DELETE = "delete"
    ADMIN = "admin"


class AuditAction(str, Enum):
    """Audit log action types."""
    USER_LOGIN = "user.login"
    USER_LOGOUT = "user.logout"
    USER_REGISTER = "user.register"
    USER_UPDATE = "user.update"
    USER_DELETE = "user.delete"
    USER_PASSWORD_CHANGE = "user.password_change"
    USER_PASSWORD_RESET = "user.password_reset"
    USER_2FA_ENABLE = "user.2fa_enable"
    USER_2FA_DISABLE = "user.2fa_disable"
    USER_SESSION_REVOKE = "user.session_revoke"
    ROLE_CREATE = "role.create"
    ROLE_UPDATE = "role.update"
    ROLE_DELETE = "role.delete"
    PERMISSION_GRANT = "permission.grant"
    PERMISSION_REVOKE = "permission.revoke"
    API_KEY_CREATE = "api_key.create"
    API_KEY_REVOKE = "api_key.revoke"
    WEBHOOK_CREATE = "webhook.create"
    WEBHOOK_UPDATE = "webhook.update"
    WEBHOOK_DELETE = "webhook.delete"
    ADMIN_ACTION = "admin.action"
    SECURITY_ALERT = "security.alert"


class NotificationType(str, Enum):
    """Notification types."""
    EMAIL = "email"
    SMS = "sms"
    PUSH = "push"
    IN_APP = "in_app"
    WEBHOOK = "webhook"


class NotificationPriority(str, Enum):
    """Notification priority levels."""
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"


class WebhookEvent(str, Enum):
    """Webhook event types."""
    USER_CREATED = "user.created"
    USER_UPDATED = "user.updated"
    USER_DELETED = "user.deleted"
    USER_LOGIN = "user.login"
    USER_LOGOUT = "user.logout"
    PASSWORD_CHANGED = "password.changed"
    TWO_FA_ENABLED = "2fa.enabled"
    TWO_FA_DISABLED = "2fa.disabled"
    SESSION_CREATED = "session.created"
    SESSION_EXPIRED = "session.expired"
    API_KEY_CREATED = "api_key.created"
    API_KEY_REVOKED = "api_key.revoked"
    SECURITY_ALERT = "security.alert"


class OrganizationRole(str, Enum):
    """Organization-level roles."""
    OWNER = "owner"
    ADMIN = "admin"
    MEMBER = "member"
    VIEWER = "viewer"
    GUEST = "guest"


class TokenType(str, Enum):
    """Token types used in the system."""
    ACCESS = "access"
    REFRESH = "refresh"
    PASSWORD_RESET = "password_reset"
    EMAIL_VERIFICATION = "email_verification"
    MAGIC_LINK = "magic_link"
    API_KEY = "api_key"


class SessionStatus(str, Enum):
    """Session status enumeration."""
    ACTIVE = "active"
    EXPIRED = "expired"
    REVOKED = "revoked"


class LoginMethod(str, Enum):
    """Authentication methods."""
    PASSWORD = "password"
    OAUTH = "oauth"
    WEBAUTHN = "webauthn"
    MAGIC_LINK = "magic_link"
    API_KEY = "api_key"


# Error Messages
ERROR_MESSAGES = {
    "AUTHENTICATION_FAILED": "Invalid credentials provided",
    "AUTHORIZATION_FAILED": "You do not have permission to access this resource",
    "ACCOUNT_LOCKED": "Account is locked due to too many failed login attempts",
    "ACCOUNT_SUSPENDED": "Account has been suspended",
    "ACCOUNT_NOT_VERIFIED": "Please verify your email address",
    "SESSION_EXPIRED": "Your session has expired. Please log in again",
    "TOKEN_INVALID": "Invalid or expired token",
    "RATE_LIMIT_EXCEEDED": "Too many requests. Please try again later",
    "PASSWORD_TOO_WEAK": "Password does not meet security requirements",
    "PASSWORD_REUSED": "Password has been used recently. Please choose a different password",
    "2FA_REQUIRED": "Two-factor authentication is required",
    "2FA_INVALID": "Invalid two-factor authentication code",
    "RESOURCE_NOT_FOUND": "The requested resource was not found",
    "DUPLICATE_EMAIL": "An account with this email already exists",
    "INVALID_FILE_TYPE": "Invalid file type",
    "FILE_TOO_LARGE": "File size exceeds maximum allowed",
}


# Success Messages
SUCCESS_MESSAGES = {
    "LOGIN_SUCCESS": "Successfully logged in",
    "LOGOUT_SUCCESS": "Successfully logged out",
    "REGISTER_SUCCESS": "Account created successfully",
    "PASSWORD_RESET_SUCCESS": "Password has been reset successfully",
    "PASSWORD_CHANGE_SUCCESS": "Password has been changed successfully",
    "EMAIL_VERIFIED": "Email address has been verified",
    "2FA_ENABLED": "Two-factor authentication has been enabled",
    "2FA_DISABLED": "Two-factor authentication has been disabled",
    "PROFILE_UPDATED": "Profile has been updated successfully",
    "SESSION_REVOKED": "Session has been revoked",
    "API_KEY_CREATED": "API key has been created",
    "API_KEY_REVOKED": "API key has been revoked",
}


# Regex Patterns
EMAIL_REGEX = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
USERNAME_REGEX = r'^[a-zA-Z0-9_-]{3,30}$'
PHONE_REGEX = r'^\+?1?\d{9,15}$'
URL_REGEX = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/\/=]*)$'


# Default Values
DEFAULT_AVATAR_URL: Final[str] = "/static/images/default-avatar.png"
DEFAULT_ORGANIZATION_NAME: Final[str] = "Default Organization"
DEFAULT_TIMEZONE: Final[str] = "UTC"
DEFAULT_LANGUAGE: Final[str] = "en"
DEFAULT_CURRENCY: Final[str] = "USD"