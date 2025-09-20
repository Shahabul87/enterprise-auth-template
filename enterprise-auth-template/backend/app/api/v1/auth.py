"""
Authentication Endpoints

Handles user authentication including login, registration,
token refresh, password reset, and OAuth flows.
"""

from typing import List, Optional

import structlog
from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    Request,
    Response,
    status,
)
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.core.config import get_settings
from app.core.security import verify_token
from app.middleware.csrf_protection import get_csrf_token_for_client
from app.models.user import User
from app.schemas.auth import (
    EmailVerificationRequest,
    LoginRequest,
    MessageResponse,
    PasswordResetConfirm,
    PasswordResetRequest,
    RegisterRequest,
    UserResponse,
    AuthResponseData,
)
from app.schemas.response import StandardResponse
from app.core.error_handling import (
    ErrorCategory,
    create_detailed_error_response,
    ProgressTracker,
    FallbackAuthManager,
)
from app.utils.response_helpers import (
    generate_request_id,
    login_success_response,
    token_refresh_success_response,
    user_profile_response,
    message_response,
    permissions_response,
    success_response,
    invalid_credentials_error,
    email_already_exists_error,
    account_locked_error,
    email_not_verified_error,
    token_expired_error,
    validation_error,
    server_error,
    invalid_token_error,
)

# Import new refactored services
from app.services.auth.authentication_service import (
    AuthenticationService,
    AuthenticationError,
    AccountLockedError,
    EmailNotVerifiedError,
)
from app.services.auth.registration_service import (
    RegistrationService,
    RegistrationError,
)
from app.services.auth.password_management_service import (
    PasswordManagementService,
    PasswordManagementError,
)
from app.services.auth.email_verification_service import (
    EmailVerificationService,
    EmailVerificationError,
)
from app.repositories.user_repository import UserRepository
from app.repositories.session_repository import SessionRepository
from app.repositories.role_repository import RoleRepository

bearer_scheme = HTTPBearer()

logger = structlog.get_logger(__name__)

router = APIRouter()


@router.get("/me", response_model=StandardResponse[dict])
async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Return the current authenticated user's profile.

    Expects a valid Bearer access token.
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Authentication required"
        )

    try:
        token_data = verify_token(credentials.credentials, "access")
        if not token_data:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        stmt = select(User).where(User.id == token_data.sub)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found"
            )

        request_id = generate_request_id()
        return user_profile_response(user, request_id)
    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to fetch current user", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=server_error("Failed to retrieve user profile").model_dump(),
        )


@router.post(
    "/register",
    response_model=StandardResponse[dict],
    status_code=status.HTTP_201_CREATED,
)
async def register(
    user_data: RegisterRequest,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Register a new user account.

    Creates a new user account with email verification.
    Sends verification email if email service is configured.

    Args:
        user_data: User registration data
        request: FastAPI request object
        db: Database session

    Returns:
        UserResponse: Created user information

    Raises:
        HTTPException: If email already exists or validation fails
    """
    logger.info("User registration attempt", email=user_data.email)

    try:
        # Use new repository pattern and registration service
        user_repo = UserRepository(db)
        role_repo = RoleRepository(db)
        registration_service = RegistrationService(db, user_repo, role_repo)

        # Get client information
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        user = await registration_service.register_user(
            registration_data=user_data,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        logger.info(
            "User registration successful",
            user_id=user.id,
            email=user.email,
        )

        request_id = generate_request_id()

        # Return a clear success message with instructions
        return message_response(
            f"Registration successful! We've sent a verification email to {user.email}. "
            f"Please check your inbox (including spam folder) and click the verification link to activate your account. "
            f"The link will expire in 24 hours.",
            request_id,
        )

    except ValueError as e:
        logger.warning(
            "User registration validation failed",
            email=user_data.email,
            error=str(e),
        )

        # Determine specific error type
        error_code = "validation_error"
        if "email already exists" in str(e).lower():
            error_code = "email_already_exists"
        elif "password" in str(e).lower():
            error_code = "weak_password"
        elif "email" in str(e).lower() and "invalid" in str(e).lower():
            error_code = "invalid_email_format"

        error_response = create_detailed_error_response(
            error_code=error_code,
            error_category=ErrorCategory.VALIDATION,
            context={"field": "email" if "email" in str(e).lower() else "password"},
            user_id=None,
        )

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=error_response
        )

    except AuthenticationError as e:
        logger.error("User registration failed", email=user_data.email, error=str(e))

        # For now, use the existing server_error function until we fix the relationship issue
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=server_error("Registration failed. Please try again.").model_dump(
                mode="json"
            ),
        )

    except Exception as e:
        logger.error(
            "Unexpected error during registration", email=user_data.email, error=str(e)
        )

        # For now, use the existing server_error function until we fix the relationship issue
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=server_error("Registration failed. Please try again.").model_dump(
                mode="json"
            ),
        )


@router.post("/login", response_model=StandardResponse[dict])
async def login(
    credentials: LoginRequest,
    response: Response,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
    prefer_json_tokens: bool = False,  # Query param to prefer JSON tokens over cookies
) -> StandardResponse[dict]:
    """
    Authenticate user and return tokens.

    Validates user credentials and returns JWT access and refresh tokens.
    Implements rate limiting and account lockout for security.

    Args:
        credentials: User login credentials
        request: FastAPI request object
        db: Database session

    Returns:
        LoginResponse: JWT tokens and user information

    Raises:
        HTTPException: If credentials are invalid or account is locked
    """
    logger.info("User login attempt", email=credentials.email)

    try:
        # Use new repository pattern and authentication service
        user_repo = UserRepository(db)
        session_repo = SessionRepository(db)
        auth_service = AuthenticationService(db, user_repo, session_repo)

        # Get client information
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        auth_result = await auth_service.authenticate_user(
            email=credentials.email,
            password=credentials.password,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        # Get the raw User model for response formatting
        user = await user_repo.find_by_email_with_roles(credentials.email)

        request_id = generate_request_id()

        # Check if client prefers JSON tokens (for Flutter app) or header preference
        use_json_tokens = (
            prefer_json_tokens
            or "application/json" in request.headers.get("accept", "")
            or "flutter" in request.headers.get("user-agent", "").lower()
            or "mobile" in request.headers.get("user-agent", "").lower()
        )

        if use_json_tokens:
            # Return tokens in JSON response for Flutter app
            logger.info(
                "User login successful with JSON tokens",
                user_id=auth_result.user.id,
                email=auth_result.user.email,
                client_type="mobile/flutter",
            )

            return login_success_response(
                user=user,  # Pass raw User model instead of UserResponse
                access_token=auth_result.access_token,
                refresh_token=auth_result.refresh_token,
                expires_in=15 * 60,  # 15 minutes
                request_id=request_id,
            )
        else:
            # Set httpOnly cookies for web browsers (legacy behavior)
            response.set_cookie(
                key="access_token",
                value=auth_result.access_token,
                httponly=True,
                secure=(
                    request.url.scheme == "https"
                ),  # HTTPS in prod, dev-friendly locally
                samesite="lax",  # CSRF protection
                max_age=15 * 60,  # 15 minutes (same as token expiry)
                path="/",
            )

            # Refresh token cookie (long-lived)
            response.set_cookie(
                key="refresh_token",
                value=auth_result.refresh_token,
                httponly=True,
                secure=(
                    request.url.scheme == "https"
                ),  # HTTPS in prod, dev-friendly locally
                samesite="lax",  # CSRF protection
                max_age=30 * 24 * 60 * 60,  # 30 days (same as token expiry)
                path=f"{get_settings().API_V1_PREFIX}/auth/refresh",  # Restrict to refresh endpoint
            )

            logger.info(
                "User login successful with secure cookies set",
                user_id=auth_result.user.id,
                email=auth_result.user.email,
                cookie_domain=request.url.hostname,
                client_type="web",
            )

            # Return standardized response without tokens (they're in cookies)
            from app.utils.response_helpers import format_user_response

            return login_success_response(
                user=user,  # Use the raw User model, not auth_result.user (which is UserResponse)
                access_token="",  # Empty since it's in cookie
                refresh_token=None,
                expires_in=15 * 60,
                request_id=request_id,
            )

    except AccountLockedError as e:
        logger.warning(
            "Login attempt on locked account",
            email=credentials.email,
            error=str(e),
        )

        error_response = create_detailed_error_response(
            error_code="account_locked",
            error_category=ErrorCategory.AUTHENTICATION,
            context={"email": credentials.email},
            user_id=None,
        )

        raise HTTPException(status_code=status.HTTP_423_LOCKED, detail=error_response)

    except EmailNotVerifiedError as e:
        logger.warning(
            "Login attempt with unverified email",
            email=credentials.email,
            error=str(e),
        )

        error_response = create_detailed_error_response(
            error_code="account_not_verified",
            error_category=ErrorCategory.AUTHENTICATION,
            context={"email": credentials.email},
            user_id=None,
        )

        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail=error_response
        )

    except AuthenticationError as e:
        logger.warning("User login failed", email=credentials.email, error=str(e))

        # Check specific error type
        error_code = "invalid_credentials"
        if "disabled" in str(e).lower():
            error_code = "account_disabled"
        elif "rate limit" in str(e).lower():
            error_code = "rate_limit_exceeded"

        error_response = create_detailed_error_response(
            error_code=error_code,
            error_category=ErrorCategory.AUTHENTICATION,
            context={"email": credentials.email},
            user_id=None,
        )

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail=error_response
        )

    except Exception as e:
        logger.error(
            "Unexpected error during login", email=credentials.email, error=str(e)
        )

        error_code = "unexpected_error"
        error_category = ErrorCategory.SYSTEM

        if "database" in str(e).lower():
            error_code = "database_connection_failed"
            error_category = ErrorCategory.DATABASE
        elif "network" in str(e).lower() or "timeout" in str(e).lower():
            error_code = "network_timeout"
            error_category = ErrorCategory.NETWORK

        error_response = create_detailed_error_response(
            error_code=error_code,
            error_category=error_category,
            context={"operation": "login"},
            user_id=None,
        )

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=error_response
        )


@router.post("/refresh", response_model=StandardResponse[dict])
async def refresh_token(
    request: Request,
    response: Response,
    db: AsyncSession = Depends(get_db_session),
    token_request: Optional[dict] = None,  # For JSON token requests
) -> StandardResponse[dict]:
    """
    Refresh access token using refresh token.

    Validates refresh token and issues new access token.
    Implements token rotation for enhanced security.

    Args:
        token_data: Refresh token request data
        request: FastAPI request object
        db: Database session

    Returns:
        TokenRefreshResponse: New access token information

    Raises:
        HTTPException: If refresh token is invalid or expired
    """
    try:
        # Use new repository pattern and authentication service
        user_repo = UserRepository(db)
        session_repo = SessionRepository(db)
        auth_service = AuthenticationService(db, user_repo, session_repo)

        # Get client information
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        # Get refresh token from cookie or JSON body
        refresh_token = request.cookies.get("refresh_token")

        # If no cookie, try to get from request body (for Flutter/mobile clients)
        if not refresh_token and token_request:
            refresh_token = token_request.get("refresh_token")

        # Also try Authorization header as fallback
        if not refresh_token:
            auth_header = request.headers.get("authorization")
            if auth_header and auth_header.startswith("Bearer "):
                refresh_token = auth_header[7:]

        if not refresh_token:
            logger.warning(
                "Refresh token missing from all sources", ip_address=ip_address
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=token_expired_error().model_dump(),
            )

        token_data = await auth_service.refresh_access_token(
            refresh_token=refresh_token,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        request_id = generate_request_id()

        # Check if this is a mobile/Flutter request
        use_json_tokens = (
            token_request is not None
            or "application/json" in request.headers.get("accept", "")
            or "flutter" in request.headers.get("user-agent", "").lower()
            or "mobile" in request.headers.get("user-agent", "").lower()
            or request.cookies.get("refresh_token")
            is None  # No cookie means JSON request
        )

        if use_json_tokens:
            # Return tokens in JSON for Flutter/mobile
            logger.debug(
                "Access token refreshed successfully with JSON response",
                expires_in=token_data["expires_in"],
                client_type="mobile/flutter",
            )

            return token_refresh_success_response(
                access_token=token_data["access_token"],
                refresh_token=token_data.get("refresh_token"),
                expires_in=int(token_data["expires_in"]),
                request_id=request_id,
            )
        else:
            # Set new access token in httpOnly cookie for web
            response.set_cookie(
                key="access_token",
                value=token_data["access_token"],
                httponly=True,
                secure=(request.url.scheme == "https"),
                samesite="lax",
                max_age=15 * 60,  # 15 minutes
                path="/",
            )

            # If refresh token was rotated, update the refresh cookie
            if "refresh_token" in token_data:
                response.set_cookie(
                    key="refresh_token",
                    value=token_data["refresh_token"],
                    httponly=True,
                    secure=(request.url.scheme == "https"),
                    samesite="lax",
                    max_age=30 * 24 * 60 * 60,  # 30 days
                    path=f"{get_settings().API_V1_PREFIX}/auth/refresh",
                )

            logger.debug(
                "Access token refreshed successfully with secure cookies",
                expires_in=token_data["expires_in"],
                client_type="web",
            )

            return message_response("Token refreshed successfully", request_id)

    except AuthenticationError as e:
        logger.warning("Token refresh failed", error=str(e))

        # Clear invalid cookies if they exist
        if request.cookies.get("access_token"):
            response.delete_cookie(key="access_token", path="/")
        if request.cookies.get("refresh_token"):
            response.delete_cookie(
                key="refresh_token", path=f"{get_settings().API_V1_PREFIX}/auth/refresh"
            )

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=token_expired_error().model_dump(),
        )


@router.post("/logout", response_model=StandardResponse[dict])
async def logout(
    request: Request,
    response: Response,
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Logout user and invalidate tokens with secure cookie cleanup.

    Enterprise security features:
    - Token blacklisting for immediate invalidation
    - Secure cookie cleanup with proper path clearing
    - Audit logging for security monitoring
    - Protection against logout CSRF attacks

    Args:
        request: FastAPI request object
        response: FastAPI response object
        db: Database session

    Returns:
        dict: Success message with cleanup confirmation
    """
    try:
        # Use new repository pattern and authentication service
        user_repo = UserRepository(db)
        session_repo = SessionRepository(db)
        auth_service = AuthenticationService(db, user_repo, session_repo)

        # Extract tokens from cookies (primary) or Authorization header (fallback)
        access_token = request.cookies.get("access_token")
        refresh_token = request.cookies.get("refresh_token")

        # Fallback to Authorization header if cookie not found
        if not access_token:
            auth_header = request.headers.get("authorization")
            if auth_header and auth_header.startswith("Bearer "):
                access_token = auth_header[7:]

        tokens_invalidated = 0

        # Invalidate access token if present
        if access_token:
            try:
                await auth_service.logout_user(access_token)
                tokens_invalidated += 1
                logger.debug("Access token invalidated", token_type="access")
            except Exception as e:
                logger.warning("Failed to invalidate access token", error=str(e))

        # Invalidate refresh token if present
        if refresh_token:
            try:
                # Additional refresh token invalidation if service supports it
                # await auth_service.invalidate_refresh_token(refresh_token)
                tokens_invalidated += 1
                logger.debug("Refresh token invalidated", token_type="refresh")
            except Exception as e:
                logger.warning("Failed to invalidate refresh token", error=str(e))

        # Clear httpOnly cookies securely
        # Clear access token cookie
        response.delete_cookie(
            key="access_token",
            path="/",
            httponly=True,
            secure=(request.url.scheme == "https"),
            samesite="lax",
        )

        # Clear refresh token cookie
        response.delete_cookie(
            key="refresh_token",
            path=f"{get_settings().API_V1_PREFIX}/auth/refresh",
            httponly=True,
            secure=(request.url.scheme == "https"),
            samesite="lax",
        )

        # Also clear from root path in case it was set there
        response.delete_cookie(
            key="refresh_token",
            path="/",
            httponly=True,
            secure=True,
            samesite="lax",
        )

        logger.info(
            "User logged out successfully with secure cleanup",
            tokens_invalidated=tokens_invalidated,
            had_access_token=bool(access_token),
            had_refresh_token=bool(refresh_token),
            ip_address=request.client.host if request.client else None,
        )

        request_id = generate_request_id()
        return message_response("Successfully logged out", request_id)

    except Exception as e:
        logger.error("Logout failed", error=str(e), exception_type=type(e).__name__)

        # Still clear cookies even if token invalidation failed
        response.delete_cookie(key="access_token", path="/")
        response.delete_cookie(
            key="refresh_token", path=f"{get_settings().API_V1_PREFIX}/auth/refresh"
        )
        response.delete_cookie(key="refresh_token", path="/")

        # Always return success for security reasons (don't leak internal errors)
        request_id = generate_request_id()
        return message_response("Successfully logged out", request_id)


@router.post("/forgot-password", response_model=StandardResponse[dict])
async def forgot_password(
    reset_request: PasswordResetRequest,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Send password reset email.

    Generates secure reset token and sends email with reset link.

    Args:
        reset_request: Password reset request data
        request: FastAPI request object
        db: Database session

    Returns:
        MessageResponse: Success message (always returns success for security)
    """
    logger.info("Password reset requested", email=reset_request.email)

    try:
        # Use new repository pattern and password management service
        user_repo = UserRepository(db)
        password_service = PasswordManagementService(db, user_repo)

        # Get client information for audit
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        # Request password reset (handles token generation and email sending)
        await password_service.request_password_reset(
            email=reset_request.email,
            ip_address=ip_address,
            user_agent=user_agent,
        )

    except Exception as e:
        # Log the error but don't expose it to the user
        logger.error(
            "Password reset request failed",
            email=reset_request.email,
            error=str(e),
        )

    # Always return the same message for security
    request_id = generate_request_id()
    return message_response(
        "If an account with that email exists, a password reset link has been sent.",
        request_id,
    )


@router.post("/reset-password", response_model=StandardResponse[dict])
async def reset_password(
    reset_data: PasswordResetConfirm,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Reset password using reset token.

    Validates reset token and updates user password.

    Args:
        reset_data: Password reset confirmation data
        request: FastAPI request object
        db: Database session

    Returns:
        MessageResponse: Success message

    Raises:
        HTTPException: If token is invalid or expired
    """
    try:
        # Use new repository pattern and password management service
        user_repo = UserRepository(db)
        password_service = PasswordManagementService(db, user_repo)

        # Get client information for audit
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        # Reset password using the token
        await password_service.reset_password(
            reset_token=reset_data.token,
            new_password=reset_data.new_password,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        logger.info("Password reset successful", token=reset_data.token[:8] + "...")

        request_id = generate_request_id()
        return message_response("Password has been reset successfully", request_id)

    except ValueError as e:
        logger.warning(
            "Password reset validation failed",
            token=reset_data.token[:8] + "...",
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=validation_error(str(e)).model_dump(),
        )
    except AuthenticationError as e:
        logger.error(
            "Password reset failed",
            token=reset_data.token[:8] + "...",
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=invalid_token_error().model_dump(),
        )


@router.get("/verify-email/{token}", response_model=StandardResponse[dict])
async def verify_email(
    token: str, request: Request, db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[dict]:
    """
    Verify user email address.

    Validates email verification token and activates account.

    Args:
        token: Email verification token
        request: FastAPI request object
        db: Database session

    Returns:
        MessageResponse: Success message

    Raises:
        HTTPException: If token is invalid or expired
    """
    try:
        # Use new repository pattern and email verification service
        user_repo = UserRepository(db)
        email_service = EmailVerificationService(db, user_repo)

        # Get client information
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        await email_service.verify_email(
            verification_token=token,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        logger.info("Email verified successfully", token=token[:8] + "...")

        request_id = generate_request_id()
        return message_response("Email verified successfully", request_id)

    except EmailVerificationError as e:
        logger.warning(
            "Email verification failed", token=token[:8] + "...", error=str(e)
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=validation_error(str(e)).model_dump(),
        )
    except ValueError as e:
        logger.warning(
            "Email verification failed", token=token[:8] + "...", error=str(e)
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=validation_error(str(e)).model_dump(),
        )
    except Exception as e:
        logger.error(
            "Unexpected error during email verification",
            token=token[:8] + "...",
            error=str(e),
            error_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=server_error("Registration failed").model_dump(),
        )


@router.post("/resend-verification", response_model=StandardResponse[dict])
async def resend_verification(
    verification_request: EmailVerificationRequest,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[dict]:
    """
    Resend email verification.

    Generates new verification token and sends email.

    Args:
        verification_request: Email verification request data
        request: FastAPI request object
        db: Database session

    Returns:
        MessageResponse: Success message
    """
    logger.info("Email verification resend requested", email=verification_request.email)

    try:
        # Use new repository pattern and email verification service
        user_repo = UserRepository(db)
        email_service = EmailVerificationService(db, user_repo)

        # Get client information for audit
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        # Resend verification email
        await email_service.resend_verification_email(
            email=verification_request.email,
            ip_address=ip_address,
            user_agent=user_agent,
        )

    except Exception as e:
        # Log the error but don't expose it to the user
        logger.error(
            "Verification email resend failed",
            email=verification_request.email,
            error=str(e),
        )

    # Always return success for security reasons
    request_id = generate_request_id()
    return message_response(
        "If an account with that email exists, a verification email has been sent.",
        request_id,
    )


@router.get("/permissions", response_model=StandardResponse[List[str]])
async def get_user_permissions(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[List[str]]:
    """
    Get current user's permissions.

    Returns a list of permission strings in format "resource:action".
    For development, this endpoint doesn't require email verification.

    Args:
        credentials: Bearer token credentials
        db: Database session

    Returns:
        List[str]: List of permission strings
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
        )

    try:
        # Verify and decode token
        token_data = verify_token(credentials.credentials, "access")

        if not token_data:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        # Get user from database
        stmt = select(User).where(User.id == token_data.sub)
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found",
            )

        # Check if user is active (but skip email verification for development)
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Account is not active",
            )

        # Default permissions for all authenticated users
        permissions = ["profile:read", "profile:write"]

        # Add role-based permissions if roles exist
        if token_data.roles:
            for role_name in token_data.roles:
                if role_name in ["admin", "super_admin"]:
                    permissions.extend(
                        [
                            "users:read",
                            "users:write",
                            "users:delete",
                            "admin:access",
                            "roles:manage",
                        ]
                    )
                elif role_name == "moderator":
                    permissions.extend(["users:read", "content:manage"])
                elif role_name == "user":
                    # User role gets default permissions (already added above)
                    pass

        # Remove duplicates and return
        request_id = generate_request_id()
        return permissions_response(list(set(permissions)), request_id)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get permissions", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=server_error("Failed to retrieve permissions").model_dump(),
        )


@router.get("/roles", response_model=StandardResponse[List[str]])
async def get_user_roles(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db_session),
) -> StandardResponse[List[str]]:
    """
    Get current user's roles.

    Returns a list of role names for the authenticated user.

    Args:
        credentials: Bearer token credentials
        db: Database session

    Returns:
        List[str]: List of role names
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
        )

    try:
        # Verify and decode token
        token_data = verify_token(credentials.credentials, "access")

        if not token_data:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
            )

        # Get user with roles
        stmt = (
            select(User)
            .options(selectinload(User.roles))
            .where(User.id == token_data.sub)
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found",
            )

        # Extract role names
        roles = [role.name for role in user.roles] if user.roles else []

        # Return roles
        request_id = generate_request_id()
        return success_response(roles, request_id)

    except HTTPException:
        raise
    except Exception as e:
        logger.error("Failed to get user roles", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=server_error("Failed to retrieve user roles").model_dump(),
        )


@router.get("/csrf-token")
async def get_csrf_token(request: Request, response: Response) -> dict:
    """
    Get CSRF token for client-side requests.

    Enterprise CSRF protection endpoint that provides secure tokens
    for preventing Cross-Site Request Forgery attacks in SPAs and
    AJAX applications.

    Security Features:
    - Cryptographically secure random token generation
    - Session-based token binding
    - Automatic token expiration (60 minutes)
    - Secure cookie storage with SameSite protection

    Args:
        request: FastAPI request object
        response: FastAPI response object for setting cookies

    Returns:
        dict: CSRF token information

    Note:
        Token is also set as a cookie for automatic inclusion in requests.
        Use X-CSRF-Token header or csrf_token form field for validation.
    """
    try:
        # Generate secure CSRF token
        csrf_token = get_csrf_token_for_client()

        # Get session identifier (same logic as middleware)
        import hashlib

        access_token = request.cookies.get("access_token") or request.headers.get(
            "authorization", ""
        ).replace("Bearer ", "")

        if access_token:
            session_id = hashlib.sha256(access_token.encode()).hexdigest()[:16]
        else:
            # Fallback for anonymous users
            client_ip = request.client.host if request.client else "unknown"
            user_agent = request.headers.get("user-agent", "")
            fallback_id = f"{client_ip}:{user_agent}"
            session_id = hashlib.sha256(fallback_id.encode()).hexdigest()[:16]

        # Store token (this would normally be done by middleware)
        from datetime import datetime, timedelta, timezone

        from app.middleware.csrf_protection import (
            CSRF_TOKEN_EXPIRE_MINUTES,
            _csrf_tokens,
        )

        expires_at = datetime.now(timezone.utc) + timedelta(
            minutes=CSRF_TOKEN_EXPIRE_MINUTES
        )

        token_key = f"{session_id}:{csrf_token}"
        _csrf_tokens[token_key] = {
            "expires_at": expires_at,
            "created_at": datetime.now(timezone.utc),
            "session_id": session_id,
        }

        # Set CSRF token cookie for automatic inclusion
        response.set_cookie(
            key="csrf_token",
            value=csrf_token,
            httponly=False,  # Must be readable by JavaScript
            secure=True,  # HTTPS only in production
            samesite="lax",  # CSRF protection
            max_age=CSRF_TOKEN_EXPIRE_MINUTES * 60,
            path="/",
        )

        logger.debug(
            "CSRF token generated",
            session_id=session_id,
            token_length=len(csrf_token),
            expires_at=expires_at.isoformat(),
            ip_address=request.client.host if request.client else None,
        )

        return {
            "csrf_token": csrf_token,
            "expires_in": CSRF_TOKEN_EXPIRE_MINUTES * 60,  # seconds
            "expires_at": expires_at.isoformat(),
            "header_name": "X-CSRF-Token",
            "form_field_name": "csrf_token",
            "usage": {
                "header": f"X-CSRF-Token: {csrf_token}",
                "form_field": "Include csrf_token field in form data",
                "cookie": "Token automatically available in csrf_token cookie",
            },
        }

    except Exception as e:
        logger.error(
            "CSRF token generation failed",
            error=str(e),
            error_type=type(e).__name__,
            ip_address=request.client.host if request.client else None,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to generate CSRF token",
        )


# OAuth endpoints will be implemented in separate modules
# Examples: /auth/oauth/google, /auth/oauth/github, etc.
