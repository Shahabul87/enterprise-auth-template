"""
Response Standardization Middleware

Middleware to ensure all API responses follow the standardized format expected by Flutter app.
This middleware handles automatic response wrapping and request ID tracking.
"""

import json
import time
import uuid
from typing import Dict, Any, Optional

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse
import structlog

from app.schemas.response import StandardResponse, ErrorCodes, ResponseMetadata

logger = structlog.get_logger(__name__)


class ResponseStandardizationMiddleware(BaseHTTPMiddleware):
    """
    Middleware to standardize all API responses to match Flutter expectations.

    Features:
    - Automatic request ID generation and tracking
    - Response format standardization
    - Performance timing
    - Error response wrapping
    - Mobile client detection
    """

    def __init__(self, app, exclude_paths: Optional[list] = None):
        super().__init__(app)
        self.exclude_paths = exclude_paths or [
            "/docs", "/redoc", "/openapi.json",
            "/health", "/metrics", "/favicon.ico"
        ]

    async def dispatch(self, request: Request, call_next) -> Response:
        """
        Process the request and standardize the response.

        Args:
            request: The incoming HTTP request
            call_next: The next middleware/endpoint to call

        Returns:
            Response: Standardized response
        """
        start_time = time.time()

        # Generate request ID for tracking
        request_id = str(uuid.uuid4())[:8]

        # Add request ID to request state for access in endpoints
        request.state.request_id = request_id

        # Check if this path should be excluded from standardization
        if any(request.url.path.startswith(path) for path in self.exclude_paths):
            response = await call_next(request)
            self._add_performance_headers(response, start_time)
            return response

        # Detect client type for response optimization
        user_agent = request.headers.get("user-agent", "").lower()
        is_mobile_client = any(keyword in user_agent for keyword in [
            "flutter", "mobile", "android", "ios", "dart"
        ])

        # Add client info to request state
        request.state.is_mobile_client = is_mobile_client
        request.state.user_agent = user_agent

        # Log request info
        logger.info(
            "Request started",
            request_id=request_id,
            method=request.method,
            path=request.url.path,
            client_ip=request.client.host if request.client else None,
            user_agent=user_agent[:100],  # Truncate for logging
            is_mobile=is_mobile_client
        )

        try:
            # Process the request
            response = await call_next(request)

            # Add performance headers
            self._add_performance_headers(response, start_time)

            # Standardize response if it's JSON and not already standardized
            if (response.status_code < 400 and
                isinstance(response, JSONResponse) and
                request.url.path.startswith("/api/")):

                response = await self._standardize_success_response(
                    response, request_id
                )

            # Log successful request
            logger.info(
                "Request completed",
                request_id=request_id,
                status_code=response.status_code,
                duration_ms=round((time.time() - start_time) * 1000, 2),
                content_length=response.headers.get("content-length")
            )

            return response

        except Exception as exc:
            # Handle any unhandled exceptions
            logger.error(
                "Unhandled request error",
                request_id=request_id,
                error=str(exc),
                error_type=type(exc).__name__,
                duration_ms=round((time.time() - start_time) * 1000, 2),
                exc_info=True
            )

            # Create standardized error response
            error_response = StandardResponse(
                success=False,
                data=None,
                error={
                    "code": ErrorCodes.SERVER_ERROR,
                    "message": "An internal server error occurred",
                    "details": {"error_id": request_id}
                },
                metadata=ResponseMetadata(
                    request_id=request_id,
                    version="1.0.0"
                )
            )

            response = JSONResponse(
                content=error_response.model_dump(),
                status_code=500
            )
            self._add_performance_headers(response, start_time)

            return response

    def _add_performance_headers(self, response: Response, start_time: float) -> None:
        """Add performance and tracking headers to the response."""
        duration_ms = round((time.time() - start_time) * 1000, 2)

        response.headers["X-Request-Duration-Ms"] = str(duration_ms)
        response.headers["X-API-Version"] = "1.0.0"

        # Add CORS headers if needed for mobile clients
        if not response.headers.get("Access-Control-Allow-Origin"):
            response.headers["Access-Control-Allow-Origin"] = "*"

        # Add security headers
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"

    async def _standardize_success_response(
        self,
        response: JSONResponse,
        request_id: str
    ) -> JSONResponse:
        """
        Standardize a successful response to match Flutter expectations.

        Args:
            response: Original JSONResponse
            request_id: Request tracking ID

        Returns:
            JSONResponse: Standardized response
        """
        try:
            # Parse the current response body
            response_body = response.body
            if isinstance(response_body, bytes):
                response_body = response_body.decode('utf-8')

            current_data = json.loads(response_body)

            # Check if already standardized (has 'success' field)
            if isinstance(current_data, dict) and 'success' in current_data:
                # Already standardized, just add request ID if missing
                if not current_data.get('metadata', {}).get('request_id'):
                    current_data.setdefault('metadata', {})['request_id'] = request_id

                return JSONResponse(
                    content=current_data,
                    status_code=response.status_code,
                    headers=dict(response.headers)
                )

            # Wrap in standardized format
            standardized_response = StandardResponse(
                success=True,
                data=current_data,
                error=None,
                metadata=ResponseMetadata(request_id=request_id)
            )

            return JSONResponse(
                content=standardized_response.model_dump(),
                status_code=response.status_code,
                headers=dict(response.headers)
            )

        except Exception as e:
            logger.warning(
                "Failed to standardize response",
                request_id=request_id,
                error=str(e),
                exc_info=True
            )
            # Return original response if standardization fails
            return response


def get_request_id(request: Request) -> str:
    """
    Get the request ID from the request state.

    Args:
        request: FastAPI request object

    Returns:
        str: Request ID, or generates new one if not found
    """
    return getattr(request.state, 'request_id', str(uuid.uuid4())[:8])


def is_mobile_client(request: Request) -> bool:
    """
    Check if the request is from a mobile client.

    Args:
        request: FastAPI request object

    Returns:
        bool: True if mobile client detected
    """
    return getattr(request.state, 'is_mobile_client', False)
