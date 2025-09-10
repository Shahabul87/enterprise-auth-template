"""
Custom Exceptions

Defines custom exceptions for the application.
"""

from typing import Any, Dict, Optional


class BaseError(Exception):
    """Base exception class"""
    
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        self.message = message
        self.details = details or {}
        super().__init__(self.message)


class ValidationError(BaseError):
    """Raised when validation fails"""
    pass


class ServiceError(BaseError):
    """Raised when a service operation fails"""
    pass


class SecurityError(BaseError):
    """Raised when a security check fails"""
    pass


class AuthenticationError(BaseError):
    """Raised when authentication fails"""
    pass


class AuthorizationError(BaseError):
    """Raised when authorization fails"""
    pass


class NotFoundError(BaseError):
    """Raised when a resource is not found"""
    pass


class ConflictError(BaseError):
    """Raised when there's a resource conflict"""
    pass


class RateLimitError(BaseError):
    """Raised when rate limit is exceeded"""
    pass


class ConfigurationError(BaseError):
    """Raised when configuration is invalid"""
    pass