"""
Custom exception handlers for the application.
Provides standardized error responses and proper HTTP status codes.
"""
from typing import Any, Dict, Optional
from fastapi import HTTPException, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from sqlalchemy.exc import IntegrityError, DataError, OperationalError
import logging
from datetime import datetime

logger = logging.getLogger(__name__)


class BaseAPIException(HTTPException):
    """Base exception class for API errors."""
    
    def __init__(
        self,
        status_code: int,
        error_code: str,
        message: str,
        details: Optional[Dict[str, Any]] = None
    ):
        self.error_code = error_code
        self.details = details or {}
        super().__init__(status_code=status_code, detail=message)


class AuthenticationException(BaseAPIException):
    """Raised when authentication fails."""
    
    def __init__(self, message: str = "Authentication failed", details: Optional[Dict[str, Any]] = None):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            error_code="AUTH_ERROR",
            message=message,
            details=details
        )


class AuthorizationException(BaseAPIException):
    """Raised when user lacks required permissions."""
    
    def __init__(self, message: str = "Insufficient permissions", details: Optional[Dict[str, Any]] = None):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            error_code="PERMISSION_DENIED",
            message=message,
            details=details
        )


class ResourceNotFoundException(BaseAPIException):
    """Raised when requested resource is not found."""
    
    def __init__(self, resource: str, identifier: Any):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            error_code="RESOURCE_NOT_FOUND",
            message=f"{resource} not found",
            details={"resource": resource, "identifier": str(identifier)}
        )


class ValidationException(BaseAPIException):
    """Raised when input validation fails."""
    
    def __init__(self, message: str, errors: Dict[str, Any]):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            error_code="VALIDATION_ERROR",
            message=message,
            details={"validation_errors": errors}
        )


class RateLimitException(BaseAPIException):
    """Raised when rate limit is exceeded."""
    
    def __init__(self, retry_after: int):
        super().__init__(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            error_code="RATE_LIMIT_EXCEEDED",
            message="Rate limit exceeded",
            details={"retry_after": retry_after}
        )


class ConflictException(BaseAPIException):
    """Raised when there's a conflict with existing data."""
    
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            error_code="CONFLICT",
            message=message,
            details=details
        )


class BusinessLogicException(BaseAPIException):
    """Raised when business logic validation fails."""
    
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            status_code=status.HTTP_400_BAD_REQUEST,
            error_code="BUSINESS_LOGIC_ERROR",
            message=message,
            details=details
        )


class ExternalServiceException(BaseAPIException):
    """Raised when external service fails."""
    
    def __init__(self, service: str, message: str):
        super().__init__(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            error_code="EXTERNAL_SERVICE_ERROR",
            message=f"External service error: {message}",
            details={"service": service}
        )


class DatabaseException(BaseAPIException):
    """Raised when database operation fails."""
    
    def __init__(self, message: str = "Database operation failed"):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            error_code="DATABASE_ERROR",
            message=message,
            details={}
        )


class TokenException(BaseAPIException):
    """Raised when token validation fails."""
    
    def __init__(self, message: str = "Invalid or expired token"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            error_code="TOKEN_ERROR",
            message=message,
            details={}
        )


class SessionException(BaseAPIException):
    """Raised when session validation fails."""
    
    def __init__(self, message: str = "Invalid or expired session"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            error_code="SESSION_ERROR",
            message=message,
            details={}
        )


class FeatureNotEnabledException(BaseAPIException):
    """Raised when trying to access a disabled feature."""
    
    def __init__(self, feature: str):
        super().__init__(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            error_code="FEATURE_NOT_ENABLED",
            message=f"Feature '{feature}' is not enabled",
            details={"feature": feature}
        )


async def base_api_exception_handler(request: Request, exc: BaseAPIException) -> JSONResponse:
    """Handler for BaseAPIException and its subclasses."""
    logger.warning(
        f"API Exception: {exc.error_code} - {exc.detail}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "error_code": exc.error_code,
            "status_code": exc.status_code,
            "details": exc.details
        }
    )
    
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": exc.error_code,
                "message": exc.detail,
                "details": exc.details
            },
            "metadata": {
                "timestamp": datetime.utcnow().isoformat(),
                "path": request.url.path
            }
        }
    )


async def http_exception_handler(request: Request, exc: HTTPException) -> JSONResponse:
    """Handler for general HTTP exceptions."""
    logger.warning(
        f"HTTP Exception: {exc.status_code} - {exc.detail}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "status_code": exc.status_code
        }
    )
    
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": f"HTTP_{exc.status_code}",
                "message": exc.detail,
                "details": {}
            },
            "metadata": {
                "timestamp": datetime.utcnow().isoformat(),
                "path": request.url.path
            }
        }
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    """Handler for request validation errors."""
    logger.warning(
        f"Validation Error: {exc.errors()}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "errors": exc.errors()
        }
    )
    
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "success": False,
            "error": {
                "code": "VALIDATION_ERROR",
                "message": "Request validation failed",
                "details": {"validation_errors": exc.errors()}
            },
            "metadata": {
                "timestamp": datetime.utcnow().isoformat(),
                "path": request.url.path
            }
        }
    )


async def database_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handler for database exceptions."""
    error_message = "Database operation failed"
    error_code = "DATABASE_ERROR"
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    
    if isinstance(exc, IntegrityError):
        error_message = "Data integrity violation"
        error_code = "INTEGRITY_ERROR"
        status_code = status.HTTP_409_CONFLICT
    elif isinstance(exc, DataError):
        error_message = "Invalid data format"
        error_code = "DATA_ERROR"
        status_code = status.HTTP_400_BAD_REQUEST
    elif isinstance(exc, OperationalError):
        error_message = "Database connection error"
        error_code = "CONNECTION_ERROR"
        status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    
    logger.error(
        f"Database Exception: {error_message}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "error": str(exc)
        },
        exc_info=True
    )
    
    return JSONResponse(
        status_code=status_code,
        content={
            "success": False,
            "error": {
                "code": error_code,
                "message": error_message,
                "details": {}
            },
            "metadata": {
                "timestamp": datetime.utcnow().isoformat(),
                "path": request.url.path
            }
        }
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Handler for unexpected exceptions."""
    logger.error(
        f"Unexpected Exception: {str(exc)}",
        extra={
            "path": request.url.path,
            "method": request.method,
            "error": str(exc)
        },
        exc_info=True
    )
    
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred",
                "details": {}
            },
            "metadata": {
                "timestamp": datetime.utcnow().isoformat(),
                "path": request.url.path
            }
        }
    )


def register_exception_handlers(app):
    """Register all exception handlers with the FastAPI app."""
    from fastapi.exceptions import RequestValidationError
    from sqlalchemy.exc import SQLAlchemyError
    
    # Register custom exception handlers
    app.add_exception_handler(BaseAPIException, base_api_exception_handler)
    app.add_exception_handler(HTTPException, http_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
    app.add_exception_handler(SQLAlchemyError, database_exception_handler)
    app.add_exception_handler(Exception, generic_exception_handler)