"""
Key Management Security

Handles secure key generation, validation, and management for JWT and other cryptographic operations.
"""

import hashlib
import secrets
import string
from typing import List, Optional
import structlog

logger = structlog.get_logger(__name__)


class KeyGenerationError(Exception):
    """Exception raised when key generation fails."""

    pass


class KeyValidationError(Exception):
    """Exception raised when key validation fails."""

    pass


# Common weak/default keys that should never be used in production
DANGEROUS_KEYS = [
    "dev_secret_key_for_development_only_change_in_production",
    "dev_secret_key_change_in_production",
    "secret",
    "secretkey",
    "your-secret-key",
    "your_secret_key",
    "change_me",
    "changeme",
    "default",
    "password",
    "12345678",
    "secret123",
    "mysecretkey",
    "django-insecure",
    "flask-secret",
    "jwt-secret",
]


def generate_secure_jwt_secret(length: int = 64) -> str:
    """
    Generate a cryptographically secure JWT secret.

    Args:
        length: Length of the secret in bytes (default 64)

    Returns:
        Secure random string suitable for JWT signing

    Raises:
        KeyGenerationError: If generation fails
    """
    if length < 32:
        raise KeyGenerationError("JWT secret must be at least 32 bytes")

    try:
        # Generate random bytes and convert to URL-safe string
        secret_bytes = secrets.token_bytes(length)
        secret = secrets.token_urlsafe(length)

        # Additional entropy by mixing with system random
        alphabet = string.ascii_letters + string.digits + "-_"
        additional = "".join(secrets.choice(alphabet) for _ in range(16))

        # Combine for final secret
        final_secret = f"{secret[:48]}{additional}{secret[48:]}"[:length]

        logger.info(
            "Secure JWT secret generated", length=length, entropy_bits=length * 8
        )

        return final_secret

    except Exception as e:
        logger.error("Failed to generate JWT secret", error=str(e))
        raise KeyGenerationError(f"Failed to generate secure key: {e}")


def validate_jwt_secret(secret: str, min_length: int = 32) -> bool:
    """
    Validate a JWT secret for security requirements.

    Args:
        secret: JWT secret to validate
        min_length: Minimum required length (default 32)

    Returns:
        True if secret is valid

    Raises:
        KeyValidationError: If secret is invalid
    """
    if not secret:
        raise KeyValidationError("JWT secret cannot be empty")

    # Check length
    if len(secret) < min_length:
        raise KeyValidationError(f"JWT secret must be at least {min_length} characters")

    # Check for dangerous/default keys
    if secret.lower() in [k.lower() for k in DANGEROUS_KEYS]:
        raise KeyValidationError("JWT secret matches a known dangerous default key")

    # Check for common patterns
    if secret.startswith("dev_") or secret.startswith("test_"):
        raise KeyValidationError("JWT secret appears to be a development key")

    # Check entropy (basic check)
    unique_chars = len(set(secret))
    if unique_chars < 10:
        raise KeyValidationError(
            "JWT secret has insufficient entropy (too few unique characters)"
        )

    # Check for sequential patterns
    if any(pattern in secret.lower() for pattern in ["123", "abc", "qwerty"]):
        raise KeyValidationError("JWT secret contains predictable patterns")

    logger.info("JWT secret validated", length=len(secret), unique_chars=unique_chars)

    return True


def generate_api_key(prefix: str = "ak") -> tuple[str, str]:
    """
    Generate a secure API key with prefix.

    Args:
        prefix: Prefix for the API key (default "ak")

    Returns:
        Tuple of (api_key, key_hash)
    """
    # Generate random key
    key_secret = secrets.token_urlsafe(32)
    api_key = f"{prefix}_{key_secret}"

    # Generate hash for storage
    key_hash = hashlib.sha256(api_key.encode()).hexdigest()

    logger.info("API key generated", prefix=prefix, key_id=key_hash[:8])

    return api_key, key_hash


def hash_api_key(api_key: str) -> str:
    """
    Hash an API key for secure storage.

    Args:
        api_key: API key to hash

    Returns:
        Hashed API key
    """
    return hashlib.sha256(api_key.encode()).hexdigest()


def generate_encryption_key() -> bytes:
    """
    Generate a secure encryption key for symmetric encryption.

    Returns:
        32-byte encryption key
    """
    key = secrets.token_bytes(32)

    logger.info("Encryption key generated", key_size=32, algorithm="AES-256")

    return key


def rotate_jwt_secret(
    current_secret: str, grace_period_seconds: int = 300
) -> tuple[str, str]:
    """
    Rotate JWT secret with grace period for transition.

    Args:
        current_secret: Current JWT secret
        grace_period_seconds: Grace period in seconds

    Returns:
        Tuple of (new_secret, transition_key)
    """
    # Validate current secret
    try:
        validate_jwt_secret(current_secret)
    except KeyValidationError:
        logger.warning("Current JWT secret failed validation during rotation")

    # Generate new secret
    new_secret = generate_secure_jwt_secret()

    # Create transition key for grace period
    transition_data = f"{current_secret}:{new_secret}"
    transition_key = hashlib.sha256(transition_data.encode()).hexdigest()

    logger.info(
        "JWT secret rotation initiated",
        grace_period=grace_period_seconds,
        transition_key=transition_key[:8],
    )

    return new_secret, transition_key


def is_key_compromised(key: str, compromised_list: Optional[List[str]] = None) -> bool:
    """
    Check if a key appears in a list of compromised keys.

    Args:
        key: Key to check
        compromised_list: Optional list of known compromised keys

    Returns:
        True if key is compromised
    """
    # Use default dangerous keys if no list provided
    if compromised_list is None:
        compromised_list = DANGEROUS_KEYS

    # Check exact match
    if key in compromised_list:
        logger.warning("Key found in compromised list")
        return True

    # Check hash match (if list contains hashes)
    key_hash = hashlib.sha256(key.encode()).hexdigest()
    if key_hash in compromised_list:
        logger.warning("Key hash found in compromised list")
        return True

    return False
