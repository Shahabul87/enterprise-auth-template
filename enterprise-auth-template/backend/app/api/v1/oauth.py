"""
OAuth Authentication Endpoints

Handles OAuth authentication flows for various providers including
Google, GitHub, and Discord.
"""

import threading
from datetime import datetime, timedelta
from typing import Dict

import structlog
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.database import get_db_session
from app.dependencies.auth import get_current_user_optional
from app.models.user import User
from app.schemas.auth import (
    LoginResponse,
    MessageResponse,
    OAuthCallbackRequest,
    OAuthInitResponse,
    OAuthProvider,
    UserResponse,
)
from app.services.oauth_service import OAuthService

logger = structlog.get_logger(__name__)

router = APIRouter()
settings = get_settings()


@router.get("/oauth/{provider}/init", response_model=OAuthInitResponse)
async def oauth_init(
    provider: OAuthProvider,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
) -> OAuthInitResponse:
    """
    Initialize OAuth authentication flow.

    Generates and returns the authorization URL for the specified OAuth provider.

    Args:
        provider: OAuth provider (google, github, discord)
        request: FastAPI request object
        db: Database session

    Returns:
        OAuthInitResponse: Authorization URL and state parameter

    Raises:
        HTTPException: If provider is not supported or configured
    """
    logger.info("OAuth initialization requested", provider=provider.value)

    try:
        oauth_service = OAuthService(db)

        # Generate state for CSRF protection
        import secrets

        state = secrets.token_urlsafe(32)

        # Store state in Redis for CSRF protection
        # This provides secure, server-side state validation
        try:
            if settings.REDIS_URL:
                import redis

                redis_client = redis.Redis.from_url(settings.REDIS_URL)
                redis_client.setex(
                    f"oauth_state_{state}",
                    300,
                    provider.value,  # 5 minutes expiration
                )
            else:
                # Fallback to in-memory storage (development only)
                if not hasattr(oauth_init, "_state_store"):
                    oauth_init._state_store = {}
                    oauth_init._state_lock = threading.Lock()

                with oauth_init._state_lock:
                    oauth_init._state_store[state] = {
                        "provider": provider.value,
                        "expires": datetime.utcnow() + timedelta(seconds=300),
                    }
                logger.warning(
                    "Using in-memory OAuth state storage - configure REDIS_URL for production"
                )
        except Exception as e:
            logger.error("Failed to store OAuth state", error=str(e))
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Authentication service temporarily unavailable",
            )

        # Get authorization URL
        auth_url = oauth_service.get_authorization_url(provider.value, state)

        logger.info("OAuth initialization successful", provider=provider.value)

        return OAuthInitResponse(authorization_url=auth_url, state=state)

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "OAuth initialization failed",
            provider=provider.value,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to initialize OAuth flow",
        )


@router.post("/oauth/{provider}/callback", response_model=LoginResponse)
async def oauth_callback(
    provider: OAuthProvider,
    callback_data: OAuthCallbackRequest,
    request: Request,
    db: AsyncSession = Depends(get_db_session),
) -> LoginResponse:
    """
    Handle OAuth callback from provider.

    Exchanges authorization code for tokens and authenticates the user.

    Args:
        provider: OAuth provider (google, github, discord)
        callback_data: Authorization code and state from provider
        request: FastAPI request object
        db: Database session

    Returns:
        LoginResponse: Access and refresh tokens

    Raises:
        HTTPException: If authentication fails or state is invalid
    """
    logger.info(
        "OAuth callback received",
        provider=provider.value,
        has_code=bool(callback_data.code),
        has_state=bool(callback_data.state),
    )

    try:
        # Verify state for CSRF protection using Redis
        if not callback_data.state:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Missing state parameter",
            )

        try:
            stored_provider_value = None

            if settings.REDIS_URL:
                import redis

                redis_client = redis.Redis.from_url(settings.REDIS_URL)
                stored_provider = redis_client.get(f"oauth_state_{callback_data.state}")

                if stored_provider:
                    stored_provider_value = stored_provider.decode()
                    # Delete used state to prevent replay attacks
                    redis_client.delete(f"oauth_state_{callback_data.state}")
            else:
                # Check in-memory storage (development only)
                if hasattr(oauth_init, "_state_store"):
                    with oauth_init._state_lock:
                        state_data = oauth_init._state_store.get(callback_data.state)
                        if state_data:
                            # Check if expired
                            if datetime.utcnow() <= state_data["expires"]:
                                stored_provider_value = state_data["provider"]
                            # Remove used state
                            oauth_init._state_store.pop(callback_data.state, None)

            if not stored_provider_value:
                logger.warning(
                    "OAuth state not found or expired",
                    provider=provider.value,
                    state=callback_data.state[:8]
                    + "...",  # Log partial state for debugging
                )
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid or expired state parameter",
                )

            if stored_provider_value != provider.value:
                logger.warning(
                    "OAuth state provider mismatch",
                    expected=provider.value,
                    received=stored_provider_value,
                )
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="State parameter provider mismatch",
                )

        except (ImportError, Exception) as e:
            if "redis" in str(e).lower():
                logger.error(
                    "Redis error during OAuth state verification", error=str(e)
                )
            else:
                logger.error("Error during OAuth state verification", error=str(e))
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Authentication service temporarily unavailable",
            )

        oauth_service = OAuthService(db)

        # Get client information
        ip_address = request.client.host if request.client else None
        user_agent = request.headers.get("user-agent")

        # Authenticate user
        user, access_token, refresh_token = await oauth_service.authenticate_oauth_user(
            provider=provider.value,
            code=callback_data.code,
            state=callback_data.state,
            ip_address=ip_address,
            user_agent=user_agent,
        )

        logger.info(
            "OAuth authentication successful",
            provider=provider.value,
            user_id=user.id,
            email=user.email,
        )

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=900,  # 15 minutes
            requires_2fa=False,
            temp_token=None,
            user=UserResponse(
                id=str(user.id),
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
                is_active=user.is_active,
                is_verified=user.is_verified,
                roles=[role.name for role in user.roles],
                created_at=(user.created_at.isoformat() if user.created_at else None),
                updated_at=(user.updated_at.isoformat() if user.updated_at else None),
                last_login=(user.last_login.isoformat() if user.last_login else None),
            ),
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error("OAuth callback failed", provider=provider.value, error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="OAuth authentication failed",
        )


@router.post("/oauth/{provider}/link", response_model=MessageResponse)
async def link_oauth_account(
    provider: OAuthProvider,
    callback_data: OAuthCallbackRequest,
    request: Request,
    current_user: User = Depends(get_current_user_optional),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Link an OAuth account to existing user.

    Allows authenticated users to link additional OAuth providers
    to their existing account.

    Args:
        provider: OAuth provider to link
        callback_data: Authorization code from provider
        request: FastAPI request object
        current_user: Currently authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message

    Raises:
        HTTPException: If user is not authenticated or linking fails
    """
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required to link OAuth account",
        )

    logger.info(
        "OAuth account linking requested",
        provider=provider.value,
        user_id=current_user.id,
    )

    try:
        oauth_service = OAuthService(db)

        # Get OAuth user info
        oauth_user_info = await oauth_service._get_oauth_user_info(
            provider.value, callback_data.code
        )

        # Link OAuth account
        await oauth_service.link_oauth_account(
            user=current_user,
            provider=provider.value,
            oauth_user_info=oauth_user_info,
        )

        logger.info(
            "OAuth account linked successfully",
            provider=provider.value,
            user_id=current_user.id,
        )

        return MessageResponse(
            message=f"{provider.value.title()} account linked successfully"
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "OAuth account linking failed",
            provider=provider.value,
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to link OAuth account",
        )


@router.delete("/oauth/{provider}/unlink", response_model=MessageResponse)
async def unlink_oauth_account(
    provider: OAuthProvider,
    current_user: User = Depends(get_current_user_optional),
    db: AsyncSession = Depends(get_db_session),
) -> MessageResponse:
    """
    Unlink an OAuth account from user.

    Removes the connection between a user account and an OAuth provider.

    Args:
        provider: OAuth provider to unlink
        current_user: Currently authenticated user
        db: Database session

    Returns:
        MessageResponse: Success message

    Raises:
        HTTPException: If user is not authenticated or unlinking fails
    """
    if not current_user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required to unlink OAuth account",
        )

    logger.info(
        "OAuth account unlinking requested",
        provider=provider.value,
        user_id=current_user.id,
    )

    try:
        oauth_service = OAuthService(db)

        # Unlink OAuth account
        await oauth_service.unlink_oauth_account(
            user=current_user, provider=provider.value
        )

        logger.info(
            "OAuth account unlinked successfully",
            provider=provider.value,
            user_id=current_user.id,
        )

        return MessageResponse(
            message=f"{provider.value.title()} account unlinked successfully"
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "OAuth account unlinking failed",
            provider=provider.value,
            user_id=current_user.id,
            error=str(e),
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to unlink OAuth account",
        )


@router.get("/oauth/providers", response_model=Dict[str, bool])
async def get_oauth_providers() -> Dict[str, bool]:
    """
    Get list of configured OAuth providers.

    Returns a dictionary indicating which OAuth providers are configured
    and available for use.

    Returns:
        Dict[str, bool]: Provider availability status
    """
    from app.services.oauth_service import OAuthConfig

    return {
        "google": bool(OAuthConfig.GOOGLE["client_id"]),
        "github": bool(OAuthConfig.GITHUB["client_id"]),
        "discord": bool(OAuthConfig.DISCORD["client_id"]),
    }
