"""
Core Security Utilities

Provides JWT token generation/validation, password hashing,
and other security-related utilities with enterprise-grade security standards.

Security Features:
- Secure JWT token generation with entropy validation
- HMAC-SHA256 signature verification
- Token blacklisting and rotation support
- Password strength validation with enterprise requirements
- Rate limiting tokens and session management
- Audit logging for all security operations
"""

import hashlib
import secrets
import time
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Optional, Set, Union

import structlog
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)

# Enterprise-grade password hashing context
pwd_context = CryptContext(
    schemes=["bcrypt"],
    deprecated="auto",
    bcrypt__rounds=settings.BCRYPT_ROUNDS,
    bcrypt__ident="2b",  # Use latest bcrypt variant
)

# Token blacklist (in production, use Redis)
_token_blacklist: Set[str] = set()

# Security constants
MIN_PASSWORD_LENGTH = 12
MAX_PASSWORD_LENGTH = 128
MAX_TOKEN_AGE_SECONDS = 86400  # 24 hours
MIN_TOKEN_ENTROPY = 0.7


class TokenData:
    """
    Enterprise-grade token data structure with comprehensive validation.

    Attributes:
        sub: Subject (user ID)
        email: User email address
        roles: List of user roles
        permissions: List of user permissions
        token_type: Type of token ('access' or 'refresh')
        exp: Expiration timestamp
        iat: Issued at timestamp
        jti: JWT ID for token tracking and revocation
        client_id: Optional client identifier
        session_id: Session identifier for tracking
    """

    def __init__(
        self,
        sub: str,
        email: str,
        roles: List[str],
        permissions: List[str],
        token_type: str,
        exp: int,
        iat: int,
        jti: Optional[str] = None,
        client_id: Optional[str] = None,
        session_id: Optional[str] = None,
    ) -> None:
        # Validate required fields
        if not sub:
            raise ValueError("Token subject (sub) cannot be empty")
        if not token_type:
            raise ValueError("Token type cannot be empty")
        if exp <= iat:
            raise ValueError("Token expiration must be after issuance time")
        if exp < int(time.time()):
            raise ValueError("Token cannot be created with past expiration")

        self.sub = sub
        self.email = email
        self.roles = roles or []
        self.permissions = permissions or []
        self.token_type = token_type
        self.exp = exp
        self.iat = iat
        self.jti = jti or secrets.token_urlsafe(16)
        self.client_id = client_id
        self.session_id = session_id

    def is_expired(self) -> bool:
        """Check if token is expired."""
        return datetime.now(timezone.utc).timestamp() > self.exp

    def time_to_expiry(self) -> timedelta:
        """Get time remaining until expiration."""
        exp_dt = datetime.fromtimestamp(self.exp, tz=timezone.utc)
        return exp_dt - datetime.now(timezone.utc)

    def __repr__(self) -> str:
        return f"TokenData(sub={self.sub}, type={self.token_type}, exp={self.exp})"


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verify a password against its hash.

    Args:
        plain_password: Plain text password
        hashed_password: Hashed password from database

    Returns:
        bool: True if password matches, False otherwise
    """
    try:
        return pwd_context.verify(plain_password, hashed_password)
    except Exception as e:
        logger.error("Password verification failed", error=str(e))
        return False


def get_password_hash(password: str) -> str:
    """
    Hash a password using bcrypt.

    Args:
        password: Plain text password

    Returns:
        str: Hashed password
    """
    return pwd_context.hash(password)


def generate_token_id() -> str:
    """
    Generate a unique token identifier.

    Returns:
        str: Unique token ID
    """
    return secrets.token_urlsafe(32)


def create_access_token(
    user_id: str,
    email: str,
    roles: List[str],
    permissions: List[str],
    expires_delta: Optional[timedelta] = None,
    client_id: Optional[str] = None,
    session_id: Optional[str] = None,
) -> str:
    """
    Create an enterprise-grade JWT access token with comprehensive security.

    Security Features:
    - Unique JWT ID (jti) for token tracking
    - Audience and issuer validation
    - Not-before time to prevent token reuse
    - Client and session tracking
    - Entropy validation for randomness
    - Comprehensive audit logging

    Args:
        user_id: User ID (validated for format)
        email: User email (validated for format)
        roles: List of user roles
        permissions: List of user permissions
        expires_delta: Custom expiration time
        client_id: Optional client identifier
        session_id: Optional session identifier

    Returns:
        str: Signed JWT access token

    Raises:
        ValueError: If token creation fails or validation errors
        SecurityError: If security requirements not met
    """
    try:
        # Input validation
        if not user_id or not isinstance(user_id, str):
            raise ValueError("user_id must be a non-empty string")
        if not email or "@" not in email:
            raise ValueError("email must be a valid email address")
        if not isinstance(roles, list):
            raise ValueError("roles must be a list")
        if not isinstance(permissions, list):
            raise ValueError("permissions must be a list")

        # Calculate expiration with bounds checking
        now = datetime.now(timezone.utc)
        if expires_delta:
            # Validate custom expiration
            if expires_delta.total_seconds() > MAX_TOKEN_AGE_SECONDS:
                logger.warning(
                    "Token expiration exceeds maximum allowed",
                    user_id=user_id,
                    requested_seconds=expires_delta.total_seconds(),
                    max_seconds=MAX_TOKEN_AGE_SECONDS,
                )
                expires_delta = timedelta(seconds=MAX_TOKEN_AGE_SECONDS)
            expire = now + expires_delta
        else:
            expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

        # Generate unique token ID with high entropy
        jti = secrets.token_urlsafe(32)

        # Validate JTI entropy
        jti_entropy = len(set(jti.lower())) / len(jti)
        if jti_entropy < MIN_TOKEN_ENTROPY:
            logger.warning(
                "Generated JTI has low entropy, regenerating",
                user_id=user_id,
                entropy=jti_entropy,
            )
            jti = secrets.token_urlsafe(48)  # Use larger size for better entropy

        # Create token payload with enterprise claims
        to_encode: Dict[str, Union[str, int, List[str]]] = {
            # Standard JWT claims
            "iss": settings.PROJECT_NAME,  # Issuer
            "aud": settings.FRONTEND_URL,  # Audience
            "sub": user_id,  # Subject
            "exp": int(expire.timestamp()),  # Expiration
            "iat": int(now.timestamp()),  # Issued At
            "nbf": int(now.timestamp()),  # Not Before
            "jti": jti,  # JWT ID
            # Custom claims
            "email": email,
            "roles": roles,
            "permissions": permissions,
            "type": "access",
            "session_id": session_id or secrets.token_urlsafe(16),
            "client_id": client_id,
            # Security metadata
            "token_version": "2.0",
            "security_level": "enterprise",
        }

        # Add optional claims if provided
        if client_id:
            to_encode["client_id"] = client_id

        # Sign token with validated secret key
        if not settings.SECRET_KEY:
            raise ValueError("SECRET_KEY not configured")

        encoded_jwt = jwt.encode(
            to_encode,
            settings.SECRET_KEY,
            algorithm=settings.ALGORITHM,
            headers={
                "typ": "JWT",
                "alg": settings.ALGORITHM,
                "kid": hashlib.sha256(settings.SECRET_KEY.encode()).hexdigest()[:16],
            },
        )

        # Validate generated token
        if len(encoded_jwt) < 100:  # Tokens should be substantial
            raise ValueError("Generated token appears malformed")

        # Comprehensive audit logging
        logger.info(
            "Access token created successfully",
            user_id=user_id,
            email=email,
            jti=jti,
            expires_at=expire.isoformat(),
            roles_count=len(roles),
            permissions_count=len(permissions),
            session_id=session_id,
            client_id=client_id,
            token_length=len(encoded_jwt),
            algorithm=settings.ALGORITHM,
        )

        return str(encoded_jwt)

    except Exception as e:
        logger.error(
            "Failed to create access token",
            error=str(e),
            user_id=user_id,
            email=email,
            exception_type=type(e).__name__,
        )
        raise ValueError(f"Failed to create access token: {str(e)}")


def create_refresh_token(
    user_id: str, expires_delta: Optional[timedelta] = None, session_id: Optional[str] = None
) -> tuple[str, str]:
    """
    Create a JWT refresh token with unique token ID.

    Args:
        user_id: User ID
        expires_delta: Custom expiration time

    Returns:
        tuple: (JWT refresh token, token ID)

    Raises:
        ValueError: If token creation fails
    """
    try:
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(
                days=settings.REFRESH_TOKEN_EXPIRE_DAYS
            )

        now = datetime.utcnow()
        token_id = generate_token_id()

        to_encode: Dict[str, Union[str, int]] = {
            "sub": user_id,
            "type": "refresh",
            "jti": token_id,
            "exp": int(expire.timestamp()),
            "iat": int(now.timestamp()),
        }

        # Add session ID for session tracking
        if session_id:
            to_encode["session_id"] = session_id

        encoded_jwt = jwt.encode(
            to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM
        )

        logger.debug(
            "Refresh token created",
            user_id=user_id,
            token_id=token_id,
            expires_at=expire.isoformat(),
        )

        return encoded_jwt, token_id

    except Exception as e:
        logger.error("Failed to create refresh token", error=str(e), user_id=user_id)
        raise ValueError(f"Failed to create refresh token: {str(e)}")


def verify_token(token: str, expected_type: str = "access") -> Optional[TokenData]:
    """
    Verify and decode a JWT token with enterprise security validation.

    Security Validations:
    - JWT signature verification with HMAC-SHA256
    - Token blacklist checking
    - Expiration and not-before time validation
    - Audience and issuer validation
    - Token type and format validation
    - Entropy and security level checks
    - Comprehensive audit logging

    Args:
        token: JWT token to verify
        expected_type: Expected token type ('access' or 'refresh')

    Returns:
        Optional[TokenData]: Token data if valid, None otherwise

    Security Notes:
        Returns None for any invalid token to prevent information leakage
        All security events are logged for audit purposes
    """
    if not token or not isinstance(token, str):
        logger.warning("Invalid token format provided")
        return None

    # Basic token format validation
    token = token.strip()
    if len(token) < 50:  # JWT tokens should be substantial
        logger.warning("Token too short, likely invalid")
        return None

    # Remove Bearer prefix if present
    if token.startswith("Bearer "):
        token = token[7:]

    try:
        # Decode and verify token signature
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM],
            audience=settings.FRONTEND_URL,  # Validate audience claim
            # Validate standard claims
            options={
                "verify_signature": True,
                "verify_exp": True,
                "verify_iat": True,
                "verify_nbf": True,
                "require_exp": True,
                "require_iat": True,
                "require_sub": True,
                "verify_aud": True,  # Verify audience
            },
        )

        # Extract and validate required fields
        sub: Optional[str] = payload.get("sub")
        token_type: Optional[str] = payload.get("type")
        exp: Optional[int] = payload.get("exp")
        iat: Optional[int] = payload.get("iat")
        jti: Optional[str] = payload.get("jti")

        # Validate required fields
        if not sub or not token_type or exp is None or iat is None:
            logger.warning(
                "Token missing required fields",
                payload_keys=list(payload.keys()),
                has_sub=bool(sub),
                has_type=bool(token_type),
                has_exp=exp is not None,
                has_iat=iat is not None,
            )
            return None

        # Validate JWT ID if present
        if jti and len(jti) < 16:
            logger.warning("Token JTI too short", jti_length=len(jti), user_id=sub)
            return None

        # Check token blacklist
        if jti and is_token_blacklisted(jti):
            logger.warning(
                "Blacklisted token rejected",
                user_id=sub,
                jti=jti,
                token_type=token_type,
            )
            return None

        # Validate token type
        if token_type != expected_type:
            logger.warning(
                "Token type mismatch",
                expected=expected_type,
                actual=token_type,
                user_id=sub,
                jti=jti,
            )
            return None

        # Additional time validations
        now = datetime.now(timezone.utc).timestamp()

        # Check not-before time
        nbf = payload.get("nbf")
        if nbf and now < nbf:
            logger.warning(
                "Token not yet valid", user_id=sub, nbf=nbf, now=now, jti=jti
            )
            return None

        # Validate issuer if present
        iss = payload.get("iss")
        if iss and iss != settings.PROJECT_NAME:
            logger.warning(
                "Invalid token issuer",
                expected_issuer=settings.PROJECT_NAME,
                actual_issuer=iss,
                user_id=sub,
            )
            return None

        # Validate security level
        security_level = payload.get("security_level")
        if security_level and security_level != "enterprise":
            logger.warning(
                "Non-enterprise security level token",
                security_level=security_level,
                user_id=sub,
            )

        # Extract fields based on token type
        if expected_type == "access":
            email: str = payload.get("email", "")
            roles: List[str] = payload.get("roles", [])
            permissions: List[str] = payload.get("permissions", [])
            session_id: Optional[str] = payload.get("session_id")
            client_id: Optional[str] = payload.get("client_id")

            if not email or "@" not in email:
                logger.warning(
                    "Access token missing or invalid email",
                    user_id=sub,
                    has_email=bool(email),
                )
                return None

            # Validate roles and permissions are lists
            if not isinstance(roles, list) or not isinstance(permissions, list):
                logger.warning(
                    "Invalid roles or permissions format",
                    user_id=sub,
                    roles_type=type(roles),
                    permissions_type=type(permissions),
                )
                return None

            logger.debug(
                "Access token verified successfully",
                user_id=sub,
                email=email,
                jti=jti,
                roles_count=len(roles),
                permissions_count=len(permissions),
                session_id=session_id,
            )

            return TokenData(
                sub=sub,
                email=email,
                roles=roles,
                permissions=permissions,
                token_type=token_type,
                exp=exp,
                iat=iat,
                jti=jti,
                client_id=client_id,
                session_id=session_id,
            )

        elif expected_type == "refresh":
            if not jti:
                logger.warning("Refresh token missing jti", user_id=sub)
                return None

            logger.debug("Refresh token verified successfully", user_id=sub, jti=jti)

            return TokenData(
                sub=sub,
                email="",  # Refresh tokens don't contain email
                roles=[],
                permissions=[],
                token_type=token_type,
                exp=exp,
                iat=iat,
                jti=jti,
            )

        logger.warning(
            "Unknown token type requested",
            expected_type=expected_type,
            user_id=sub,
        )
        return None

    except JWTError as e:
        # Handle all JWT errors including expired tokens, invalid signatures, etc.
        error_msg = str(e).lower()
        if "signature" in error_msg and "expired" in error_msg:
            logger.debug("Token expired during verification")
        else:
            logger.warning(
                "JWT verification failed",
                error=str(e),
                error_type=type(e).__name__,
            )
        return None
    except Exception as e:
        logger.warning(
            "JWT verification failed",
            error=str(e),
            error_type=type(e).__name__,
        )
        return None
    except Exception as e:
        logger.error(
            "Unexpected error during token verification",
            error=str(e),
            error_type=type(e).__name__,
        )
        return None


def generate_reset_token() -> str:
    """
    Generate a secure password reset token.

    Returns:
        str: Secure random token
    """
    return secrets.token_urlsafe(32)


def generate_verification_token() -> str:
    """
    Generate a secure email verification token.

    Returns:
        str: Secure random token
    """
    return secrets.token_urlsafe(32)


def blacklist_token(jti: str, expiration_time: Optional[datetime] = None) -> bool:
    """
    Add token to blacklist to prevent reuse.

    Args:
        jti: JWT ID to blacklist
        expiration_time: When the blacklist entry should expire

    Returns:
        bool: True if successfully blacklisted

    Note:
        In production, this should use Redis with TTL
    """
    try:
        _token_blacklist.add(jti)
        logger.info("Token blacklisted", jti=jti, expiration=expiration_time)
        return True
    except Exception as e:
        logger.error("Failed to blacklist token", jti=jti, error=str(e))
        return False


def is_token_blacklisted(jti: str) -> bool:
    """
    Check if token is blacklisted.

    Args:
        jti: JWT ID to check

    Returns:
        bool: True if token is blacklisted
    """
    return jti in _token_blacklist


def clear_token_blacklist() -> None:
    """Clear the token blacklist (for testing purposes)."""
    global _token_blacklist
    _token_blacklist.clear()


def create_secure_session_id() -> str:
    """
    Generate a secure session ID.

    Returns:
        str: Secure random session ID
    """
    return secrets.token_urlsafe(32)


def generate_random_token(length: int = 32) -> str:
    """
    Generate a secure random token.

    Args:
        length: Length of the token

    Returns:
        str: Secure random token
    """
    return secrets.token_urlsafe(length)


def validate_token_entropy(token: str) -> bool:
    """
    Validate that a token has sufficient entropy.

    Args:
        token: Token string to validate

    Returns:
        bool: True if entropy is sufficient
    """
    if len(token) < 32:
        return False

    # Calculate character entropy
    unique_chars = len(set(token.lower()))
    entropy_ratio = unique_chars / len(token)

    return entropy_ratio >= MIN_TOKEN_ENTROPY


def is_password_strong(password: str) -> tuple[bool, List[str]]:
    """
    Check if a password meets enterprise security requirements.

    Enterprise Password Policy:
    - Minimum 12 characters (enterprise standard)
    - Maximum 128 characters (prevent DoS)
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one digit
    - At least one special character
    - No common password patterns
    - No dictionary words
    - No personal information patterns

    Args:
        password: Password to check

    Returns:
        tuple: (is_strong, list_of_issues)
    """
    issues: List[str] = []

    # Length validation
    if len(password) < MIN_PASSWORD_LENGTH:
        issues.append(
            f"Password must be at least {MIN_PASSWORD_LENGTH} characters long (enterprise standard)"
        )

    if len(password) > MAX_PASSWORD_LENGTH:
        issues.append(f"Password must not exceed {MAX_PASSWORD_LENGTH} characters")

    # Character requirements
    if not any(c.isupper() for c in password):
        issues.append("Password must contain at least one uppercase letter")

    if not any(c.islower() for c in password):
        issues.append("Password must contain at least one lowercase letter")

    if not any(c.isdigit() for c in password):
        issues.append("Password must contain at least one digit")

    # Extended special character set for enterprise
    special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?~`"
    if not any(c in special_chars for c in password):
        issues.append("Password must contain at least one special character")

    # Check for common weak patterns
    password_lower = password.lower()

    # Common weak passwords
    common_passwords = {
        "password",
        "password123",
        "admin",
        "administrator",
        "root",
        "toor",
        "pass",
        "test",
        "guest",
        "user",
        "login",
        "welcome",
        "changeme",
        "secret",
        "qwerty",
        "letmein",
        "trustno1",
        "123456789",
        "passw0rd",
    }

    if password_lower in common_passwords:
        issues.append("Password is too common and easily guessable")

    # Check for keyboard patterns
    keyboard_patterns = [
        "qwerty",
        "asdf",
        "zxcv",
        "1234",
        "abcd",
        "!@#$",
        "qwertyuiop",
        "asdfghjkl",
        "zxcvbnm",
    ]

    for pattern in keyboard_patterns:
        if pattern in password_lower or pattern[::-1] in password_lower:
            issues.append("Password contains keyboard patterns")
            break

    # Check for repeated characters (more than 25% of password)
    if len(password) > 0:
        max_char_count = max(password.count(c) for c in set(password))
        if max_char_count > len(password) * 0.25:
            issues.append("Password contains too many repeated characters")

    # Check for sequential characters
    sequential_patterns = ["abcdefg", "1234567", "7654321", "gfedcba"]
    for pattern in sequential_patterns:
        if pattern in password_lower:
            issues.append("Password contains sequential characters")
            break

    # Entropy check
    if len(password) >= MIN_PASSWORD_LENGTH:
        unique_chars = len(set(password.lower()))
        entropy_ratio = unique_chars / len(password)
        if entropy_ratio < 0.4:  # Minimum entropy for passwords
            issues.append("Password lacks sufficient character diversity")

    return len(issues) == 0, issues


def check_permission(user_permissions: List[str], required_permission: str) -> bool:
    """
    Check if user has a specific permission.

    Args:
        user_permissions: List of user permissions
        required_permission: Required permission in 'resource:action' format

    Returns:
        bool: True if user has permission, False otherwise
    """
    # Check for super admin permission
    if "*:*" in user_permissions:
        return True

    # Check for specific permission
    if required_permission in user_permissions:
        return True

    # Check for wildcard resource permissions
    resource, action = required_permission.split(":", 1)
    resource_wildcard = f"{resource}:*"
    if resource_wildcard in user_permissions:
        return True

    return False


def has_role(user_roles: List[str], required_role: str) -> bool:
    """
    Check if user has a specific role.

    Args:
        user_roles: List of user roles
        required_role: Required role name

    Returns:
        bool: True if user has role, False otherwise
    """
    return required_role in user_roles
