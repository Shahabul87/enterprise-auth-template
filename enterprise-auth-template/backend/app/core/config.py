"""
Application Configuration

Centralized configuration management using Pydantic Settings.
Loads configuration from environment variables with proper validation.
"""

import os
import secrets
from functools import lru_cache
from typing import Any, List, Optional

import structlog
from pydantic import (
    AnyHttpUrl,
    EmailStr,
    HttpUrl,
    PostgresDsn,
    RedisDsn,
    field_validator,
)
from pydantic_settings import BaseSettings

logger = structlog.get_logger(__name__)


class Settings(BaseSettings):
    """
    Application settings loaded from environment variables.

    Uses Pydantic Settings for automatic validation and type conversion.
    """

    # ===========================================
    # GENERAL SETTINGS
    # ===========================================
    PROJECT_NAME: str = "Enterprise Auth Template"
    VERSION: str = "1.0.0"
    APP_VERSION: str = "1.0.0"  # Added for admin service
    ENVIRONMENT: str = "development"
    DEBUG: bool = True
    MAINTENANCE_MODE: bool = False
    MAINTENANCE_MESSAGE: str = "System is under maintenance"

    # ===========================================
    # EMAIL VERIFICATION SETTINGS
    # ===========================================
    EMAIL_VERIFICATION_REQUIRED: bool = True
    SKIP_EMAIL_VERIFICATION_IN_DEV: bool = True
    EMAIL_VERIFICATION_TOKEN_EXPIRE_HOURS: int = 24
    EMAIL_VERIFICATION_RESEND_COOLDOWN_MINUTES: int = 5

    # ===========================================
    # API SETTINGS
    # ===========================================
    API_V1_PREFIX: str = "/api/v1"
    DOCS_URL: str = "/docs"
    REDOC_URL: str = "/redoc"

    # ===========================================
    # SECURITY SETTINGS
    # ===========================================
    SECRET_KEY: str = ""
    ENCRYPTION_KEY: Optional[str] = None  # For 2FA backup codes encryption
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30
    BCRYPT_ROUNDS: int = 12
    API_KEY_MAX_AGE_DAYS: int = 90  # API key expiration in days

    # Authentication Features
    OAUTH_ENABLED: bool = True
    TWO_FACTOR_ENABLED: bool = True
    MAGIC_LINKS_ENABLED: bool = True
    WEBAUTHN_ENABLED: bool = True

    @field_validator("SECRET_KEY", mode="before")
    @classmethod
    def validate_secret_key(cls, v: str) -> str:
        """
        Validate JWT secret key using enterprise key management system.

        Enterprise Requirements:
        - Uses secure key generation with cryptographic randomness
        - Automatic entropy and strength validation
        - Key rotation and audit logging
        - Environment-specific requirements
        - NIST-compliant key management

        Args:
            v: The secret key value

        Returns:
            str: Validated or generated secure secret key

        Raises:
            ValueError: If secret key doesn&apos;t meet security standards
        """
        environment = os.getenv("ENVIRONMENT", "development")

        # Import key management system
        try:
            from app.core.security.key_management import (
                generate_secure_jwt_secret,
                validate_jwt_secret,
                KeyValidationError,
                KeyGenerationError
            )
        except ImportError:
            # Fallback to basic validation if key management not available
            return cls._fallback_key_validation(v, environment)

        # Auto-generate secure key if not provided or if using dangerous defaults
        dangerous_keys = {
            "dev_secret_key_for_development_only_change_in_production",
            "dev_secret_key_change_in_production",
            "your_secret_key_change_in_production_must_be_32_characters_or_longer",
            "development_secret_key_change_this_in_production_environment",
            "secret",
            "secretkey",
            "mysecretkey",
            "supersecret",
            "changeMe123456789012345678901234567890",
        }

        if not v or v.lower() in {key.lower() for key in dangerous_keys}:
            try:
                logger.warning(
                    "Generating secure JWT secret key",
                    reason="missing_or_insecure_key",
                    environment=environment
                )
                return str(generate_secure_jwt_secret(environment=environment))
            except KeyGenerationError as e:
                raise ValueError(f"Failed to generate secure key: {e}")

        # Bypass validation for testing with minimum requirements
        if environment.lower() in {"test", "testing"}:
            if len(v) >= 32:
                return v

        # Validate existing key using enterprise standards
        try:
            validation_result = validate_jwt_secret(v, environment)

            if not validation_result["valid"]:
                issues = "; ".join(validation_result["issues"])
                recommendations = "; ".join(validation_result["recommendations"])

                # In production, auto-generate if key is invalid
                if environment.lower() in {"production", "prod", "live"}:
                    logger.error(
                        "Invalid JWT secret in production, generating new key",
                        issues=issues,
                        recommendations=recommendations
                    )
                    return str(generate_secure_jwt_secret(environment=environment))

                raise ValueError(
                    f"SECRET_KEY validation failed: {issues}. "
                    f"Recommendations: {recommendations}"
                )

            # Log successful validation
            logger.info(
                "JWT secret key validated",
                length=validation_result["length"],
                entropy_score=validation_result["entropy_score"],
                environment=environment
            )

            return v

        except KeyValidationError as e:
            if environment.lower() in {"production", "prod", "live"}:
                logger.error("Key validation failed in production, generating new key", error=str(e))
                return str(generate_secure_jwt_secret(environment=environment))
            raise ValueError(f"SECRET_KEY validation failed: {e}")

    @classmethod
    def _fallback_key_validation(cls, v: str, environment: str) -> str:
        """Fallback key validation when enterprise key management is not available."""
        if not v:
            v = secrets.token_urlsafe(64 if environment.lower() in {"production", "prod"} else 32)

        # Basic length validation
        min_length = 64 if environment.lower() in {"production", "prod"} else 32
        if len(v) < min_length:
            raise ValueError(
                f"SECRET_KEY must be at least {min_length} characters for {environment}. "
                f"Current length: {len(v)}"
            )

        return v

    @field_validator("ENCRYPTION_KEY", mode="before")
    @classmethod
    def validate_encryption_key(cls, v: Optional[str]) -> Optional[str]:
        """
        Validate encryption key for 2FA backup codes.

        Args:
            v: The encryption key value

        Returns:
            Optional[str]: Validated encryption key or auto-generated if None
        """
        if v is None:
            # Auto-generate Fernet-compatible key
            from cryptography.fernet import Fernet

            return Fernet.generate_key().decode()

        # Validate Fernet key format if provided
        try:
            from cryptography.fernet import Fernet

            Fernet(v.encode())
        except Exception as e:
            raise ValueError(f"Invalid ENCRYPTION_KEY format: {e}")

        return v

    # ===========================================
    # DATABASE SETTINGS
    # ===========================================
    DB_HOST: str = "localhost"
    DB_PORT: int = 5432
    DB_NAME: str = "auth_template_dev"
    DB_USER: str = "postgres"
    DB_PASSWORD: str = "postgres"

    # Connection Pool Settings
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 30
    DB_POOL_TIMEOUT: int = 30

    DATABASE_URL: Optional[str] = None

    @field_validator("DATABASE_URL", mode="before")
    @classmethod
    def assemble_db_connection(cls, v: Optional[str], info) -> Any:
        """Construct database URL from individual components if not provided."""
        # NEVER allow SQLite - this application requires PostgreSQL
        if isinstance(v, str):
            if v.startswith("sqlite:") or v.startswith("sqlite+"):
                raise ValueError(
                    "SQLite is not supported. This application requires PostgreSQL for "
                    "proper foreign keys, JSONB fields, UUID support, and async operations. "
                    "Please configure a PostgreSQL database."
                )
            return v

        # Get values from the validation context
        if hasattr(info, "data") and info.data:
            values = info.data
        else:
            values = {}

        return PostgresDsn.build(
            scheme="postgresql+asyncpg",
            username=values.get("DB_USER"),
            password=values.get("DB_PASSWORD"),
            host=values.get("DB_HOST"),
            port=values.get("DB_PORT"),
            path=f"/{values.get('DB_NAME') or ''}",
        )

    # ===========================================
    # REDIS SETTINGS
    # ===========================================
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: str = ""
    REDIS_DB: int = 0

    REDIS_URL: Optional[str] = None

    @field_validator("REDIS_URL", mode="before")
    @classmethod
    def assemble_redis_connection(cls, v: Optional[str], info) -> Any:
        """Construct Redis URL from individual components if not provided."""
        # Allow empty Redis URL for testing
        environment = os.getenv("ENVIRONMENT", "development")
        if isinstance(v, str):
            if environment.lower() in {"test", "testing"} and v == "":
                return None  # Allow empty Redis URL in test environment
            return v

        # Get values from the validation context
        if hasattr(info, "data") and info.data:
            values = info.data
        else:
            values = {}

        return RedisDsn.build(
            scheme="redis",
            password=values.get("REDIS_PASSWORD") or None,
            host=values.get("REDIS_HOST"),
            port=values.get("REDIS_PORT"),
            path=f"/{values.get('REDIS_DB') or 0}",
        )

    # Session Settings
    SESSION_TIMEOUT_MINUTES: int = 1440  # 24 hours
    MAX_SESSIONS_PER_USER: int = 5  # Maximum concurrent sessions per user

    # ===========================================
    # CORS SETTINGS
    # ===========================================
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:3001",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:3001",
    ]
    ALLOWED_METHODS: List[str] = [
        "GET",
        "POST",
        "PUT",
        "DELETE",
        "OPTIONS",
        "PATCH",
    ]
    ALLOWED_HEADERS: List[str] = ["*"]
    ALLOWED_HOSTS: Optional[List[str]] = None

    # ===========================================
    # EMAIL SETTINGS
    # ===========================================
    EMAIL_PROVIDER: str = "smtp"  # smtp, sendgrid, mailgun, ses

    # SMTP Settings
    SMTP_HOST: Optional[str] = None
    SMTP_PORT: int = 587
    SMTP_USER: Optional[str] = None
    SMTP_PASSWORD: Optional[str] = None
    SMTP_TLS: bool = True
    SMTP_SSL: bool = False

    # SendGrid Settings
    SENDGRID_API_KEY: Optional[str] = None

    # AWS SES Settings
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "us-east-1"

    # Email Templates
    EMAIL_FROM: Optional[EmailStr] = None
    EMAIL_FROM_NAME: str = "Enterprise Auth Template"

    # ===========================================
    # OAUTH PROVIDER SETTINGS
    # ===========================================
    # Google OAuth
    GOOGLE_CLIENT_ID: Optional[str] = None
    GOOGLE_CLIENT_SECRET: Optional[str] = None

    # GitHub OAuth
    GITHUB_CLIENT_ID: Optional[str] = None
    GITHUB_CLIENT_SECRET: Optional[str] = None

    # Discord OAuth
    DISCORD_CLIENT_ID: Optional[str] = None
    DISCORD_CLIENT_SECRET: Optional[str] = None

    # ===========================================
    # FRONTEND SETTINGS
    # ===========================================
    FRONTEND_URL: str = "http://localhost:3000"
    BACKEND_URL: str = "http://localhost:8000"

    # ===========================================
    # RATE LIMITING
    # ===========================================
    RATE_LIMIT_REQUESTS: int = 100
    RATE_LIMIT_WINDOW: int = 60  # seconds
    RATE_LIMIT_PER_MINUTE: int = 60
    MAX_LOGIN_ATTEMPTS: int = 5
    LOCKOUT_DURATION_MINUTES: int = 30

    # ===========================================
    # LOGGING SETTINGS
    # ===========================================
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"  # json or text
    LOG_FILE: Optional[str] = None

    # ===========================================
    # MONITORING & OBSERVABILITY
    # ===========================================
    SENTRY_DSN: Optional[HttpUrl] = None
    METRICS_ENABLED: bool = True
    METRICS_PORT: int = 9090

    # ===========================================
    # WEBAUTHN SETTINGS
    # ===========================================
    WEBAUTHN_RP_ID: str = "localhost"
    WEBAUTHN_RP_NAME: str = "Enterprise Auth Template"
    WEBAUTHN_ORIGIN: str = "http://localhost:3000"

    # ===========================================
    # CELERY SETTINGS
    # ===========================================
    CELERY_BROKER_URL: Optional[RedisDsn] = None
    CELERY_RESULT_BACKEND: Optional[RedisDsn] = None

    @field_validator("CELERY_BROKER_URL", mode="before")
    @classmethod
    def assemble_celery_broker(cls, v: Optional[str], info) -> Any:
        """Construct Celery broker URL if not provided."""
        if isinstance(v, str):
            return v

        # Get values from the validation context
        if hasattr(info, "data") and info.data:
            values = info.data
        else:
            values = {}

        redis_url = values.get("REDIS_URL")
        if redis_url:
            # Use database 1 for Celery broker
            return str(redis_url).replace("/0", "/1")
        return None

    @field_validator("CELERY_RESULT_BACKEND", mode="before")
    @classmethod
    def assemble_celery_result_backend(cls, v: Optional[str], info) -> Any:
        """Construct Celery result backend URL if not provided."""
        if isinstance(v, str):
            return v

        # Get values from the validation context
        if hasattr(info, "data") and info.data:
            values = info.data
        else:
            values = {}

        redis_url = values.get("REDIS_URL")
        if redis_url:
            # Use database 2 for Celery results
            return str(redis_url).replace("/0", "/2")
        return None

    # Flower (Celery Monitoring)
    FLOWER_PORT: int = 5555

    # ===========================================
    # FEATURE FLAGS
    # ===========================================
    FEATURE_EMAIL_VERIFICATION_ENFORCEMENT: bool = True
    FEATURE_STRICT_EMAIL_VERIFICATION: bool = False
    FEATURE_BYPASS_VERIFICATION_FOR_ADMINS: bool = False
    FEATURE_EMAIL_VERIFICATION_GRACE_PERIOD_HOURS: int = 0

    # ===========================================
    # UTILITY METHODS
    # ===========================================
    def should_enforce_email_verification(self) -> bool:
        """
        Determine if email verification should be enforced based on environment and settings.

        Returns:
            bool: True if email verification should be enforced
        """
        # Always enforce if explicitly required
        if not self.EMAIL_VERIFICATION_REQUIRED:
            return False

        # Skip in development if configured
        if self.ENVIRONMENT == "development" and self.SKIP_EMAIL_VERIFICATION_IN_DEV:
            return False

        # Check feature flag
        if not self.FEATURE_EMAIL_VERIFICATION_ENFORCEMENT:
            return False

        return True

    def get_current_timestamp(self) -> str:
        """Get current timestamp in ISO format."""
        from datetime import datetime
        return datetime.utcnow().isoformat() + "Z"

    class Config:
        env_file = ".env"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """
    Get cached application settings.

    Using lru_cache to avoid reading environment variables multiple times.

    Returns:
        Settings: Application configuration
    """
    return Settings()
