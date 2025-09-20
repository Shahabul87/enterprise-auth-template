"""
WebAuthn API Endpoints

REST API endpoints for WebAuthn/Passkeys authentication including:
- Passkey registration (credential creation)
- Passkey authentication (credential assertion)
- Credential management operations
- Enterprise security validation

Supports FIDO2/WebAuthn standards for passwordless authentication.
"""

from typing import Dict, List, Optional, Any
from datetime import timedelta
import structlog

from fastapi import APIRouter, Depends, HTTPException, status, Request, Response
from fastapi.security import HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field

from app.core.database import get_db_session
from app.dependencies.auth import get_current_user, get_current_active_user
from app.models.user import User
from app.services.webauthn_service import webauthn_service
from app.core.security import create_access_token
from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)
security = HTTPBearer()

router = APIRouter(prefix="/webauthn", tags=["WebAuthn/Passkeys"])


# Request/Response Models


class WebAuthnRegistrationOptionsRequest(BaseModel):
    """Request model for WebAuthn registration options."""

    device_name: Optional[str] = Field(
        None, description="Optional device name for identification"
    )


class WebAuthnRegistrationRequest(BaseModel):
    """Request model for WebAuthn registration verification."""

    credential: Dict[str, Any] = Field(
        ..., description="WebAuthn registration credential response"
    )
    challenge: str = Field(
        ..., description="Expected challenge from registration options"
    )
    device_name: Optional[str] = Field(None, description="Optional device name")


class WebAuthnAuthenticationOptionsRequest(BaseModel):
    """Request model for WebAuthn authentication options."""

    email: Optional[str] = Field(
        None, description="User email (optional for discoverable credentials)"
    )


class WebAuthnAuthenticationRequest(BaseModel):
    """Request model for WebAuthn authentication verification."""

    credential: Dict[str, Any] = Field(
        ..., description="WebAuthn authentication credential response"
    )
    challenge: str = Field(
        ..., description="Expected challenge from authentication options"
    )


class WebAuthnCredentialResponse(BaseModel):
    """Response model for WebAuthn credential information."""

    id: str = Field(..., description="Internal credential ID")
    device_name: str = Field(..., description="Device name")
    created_at: str = Field(..., description="Creation timestamp")
    last_used: Optional[str] = Field(None, description="Last used timestamp")
    transports: List[str] = Field([], description="Supported transports")
    aaguid: str = Field(..., description="Authenticator AAGUID")
    credential_id_preview: str = Field(..., description="Credential ID preview")


class WebAuthnDeleteCredentialRequest(BaseModel):
    """Request model for deleting WebAuthn credential."""

    credential_id: str = Field(..., description="Internal credential ID to delete")


# Registration Endpoints


@router.post("/register/options")
async def get_registration_options(
    request: WebAuthnRegistrationOptionsRequest,
    current_user: User = Depends(get_current_active_user),
) -> Dict[str, Any]:
    """
    Generate WebAuthn registration options for passkey creation.

    This endpoint creates the challenge and options needed by the client
    to initiate WebAuthn credential registration.

    **Security Notes:**
    - Requires authenticated user
    - Challenge is temporary and single-use
    - Supports multiple credentials per user
    """
    try:
        logger.info(
            "WebAuthn registration options requested",
            user_id=str(current_user.id),
            user_email=current_user.email,
            device_name=request.device_name,
        )

        options, challenge = await webauthn_service.generate_registration_options(
            user=current_user,
            device_name=request.device_name,
        )

        # Store challenge in user session (simplified - use Redis in production)
        # For now, we return it to be sent back with registration request

        return {
            "success": True,
            "data": {
                "options": options,
                "challenge": challenge,  # Client will send this back
            },
            "metadata": {
                "user_id": str(current_user.id),
                "device_name": request.device_name,
                "timeout": options.get("timeout", 60000),
            },
        }

    except ValueError as e:
        logger.warning(
            "Invalid WebAuthn registration request",
            error=str(e),
            user_id=str(current_user.id),
        )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={
                "success": False,
                "error": {
                    "code": "INVALID_REQUEST",
                    "message": str(e),
                },
            },
        )
    except Exception as e:
        logger.error(
            "WebAuthn registration options generation failed",
            error=str(e),
            user_id=str(current_user.id),
            exception_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Failed to generate registration options",
                },
            },
        )


@router.post("/register/verify")
async def verify_registration(
    request: WebAuthnRegistrationRequest,
    current_user: User = Depends(get_current_active_user),
) -> Dict[str, Any]:
    """
    Verify WebAuthn registration response and store passkey.

    This endpoint verifies the credential created by the client
    and stores it for future authentication.

    **Security Notes:**
    - Validates challenge matches registration options
    - Verifies attestation and signature
    - Stores credential securely in database
    """
    try:
        logger.info(
            "WebAuthn registration verification requested",
            user_id=str(current_user.id),
            device_name=request.device_name,
        )

        success = await webauthn_service.verify_registration_response(
            user=current_user,
            credential_data=request.credential,
            expected_challenge=request.challenge,
            device_name=request.device_name,
        )

        if not success:
            logger.warning(
                "WebAuthn registration verification failed",
                user_id=str(current_user.id),
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "success": False,
                    "error": {
                        "code": "REGISTRATION_FAILED",
                        "message": "Failed to verify registration response",
                    },
                },
            )

        # Get updated credential list
        credentials = await webauthn_service.get_user_credentials(current_user)

        logger.info(
            "WebAuthn registration successful",
            user_id=str(current_user.id),
            total_credentials=len(credentials),
        )

        return {
            "success": True,
            "data": {
                "message": "Passkey registered successfully",
                "credential_count": len(credentials),
            },
            "metadata": {
                "user_id": str(current_user.id),
                "device_name": request.device_name,
                "registered_at": credentials[-1]["created_at"] if credentials else None,
            },
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "WebAuthn registration verification failed",
            error=str(e),
            user_id=str(current_user.id),
            exception_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Registration verification failed",
                },
            },
        )


# Authentication Endpoints


@router.post("/authenticate/options")
async def get_authentication_options(
    request: WebAuthnAuthenticationOptionsRequest,
) -> Dict[str, Any]:
    """
    Generate WebAuthn authentication options for passkey login.

    This endpoint creates the challenge and options needed by the client
    to initiate WebAuthn authentication.

    **Security Notes:**
    - Public endpoint (no authentication required)
    - Supports both user-specific and discoverable credentials
    - Challenge is temporary and single-use
    """
    try:
        logger.info(
            "WebAuthn authentication options requested",
            email=request.email,
            discoverable=request.email is None,
        )

        # Find user by email if provided
        user = None
        if request.email:
            from sqlalchemy import select
            from app.core.database import get_db_session

            async with get_db_session() as session:
                result = await session.execute(
                    select(User).where(User.email == request.email)
                )
                user = result.scalar_one_or_none()

                if not user or not user.is_active:
                    # Don't reveal if user exists for security
                    logger.warning(
                        "WebAuthn authentication options requested for invalid user",
                        email=request.email,
                    )

        options, challenge = await webauthn_service.generate_authentication_options(
            user=user
        )

        return {
            "success": True,
            "data": {
                "options": options,
                "challenge": challenge,  # Client will send this back
            },
            "metadata": {
                "email": request.email,
                "timeout": options.get("timeout", 60000),
                "user_verification": options.get("userVerification", "required"),
            },
        }

    except Exception as e:
        logger.error(
            "WebAuthn authentication options generation failed",
            error=str(e),
            email=request.email,
            exception_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Failed to generate authentication options",
                },
            },
        )


@router.post("/authenticate/verify")
async def verify_authentication(
    request: WebAuthnAuthenticationRequest,
    response: Response,
) -> Dict[str, Any]:
    """
    Verify WebAuthn authentication response and create session.

    This endpoint verifies the credential assertion from the client
    and creates an authenticated session.

    **Security Notes:**
    - Validates challenge matches authentication options
    - Verifies credential signature
    - Creates JWT tokens for session
    - Updates credential usage statistics
    """
    try:
        logger.info(
            "WebAuthn authentication verification requested",
        )

        user = await webauthn_service.verify_authentication_response(
            credential_data=request.credential,
            expected_challenge=request.challenge,
        )

        if not user:
            logger.warning("WebAuthn authentication verification failed")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "success": False,
                    "error": {
                        "code": "AUTHENTICATION_FAILED",
                        "message": "Invalid credentials",
                    },
                },
            )

        if not user.is_active:
            logger.warning(
                "WebAuthn authentication for inactive user",
                user_id=str(user.id),
            )
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "success": False,
                    "error": {
                        "code": "ACCOUNT_DISABLED",
                        "message": "Account is disabled",
                    },
                },
            )

        # Get user roles and permissions for token
        user_roles = [role.name for role in user.roles]
        user_permissions = user.get_permissions()

        # Create access token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            user_id=str(user.id),
            email=user.email,
            roles=user_roles,
            permissions=user_permissions,
            expires_delta=access_token_expires,
        )

        # Set secure HTTP-only cookies
        response.set_cookie(
            key="access_token",
            value=access_token,
            max_age=int(access_token_expires.total_seconds()),
            httponly=True,
            secure=settings.ENVIRONMENT == "production",
            samesite="lax",
        )

        # Update last login
        from datetime import datetime
        from sqlalchemy import update
        from app.core.database import get_db_session

        async with get_db_session() as session:
            await session.execute(
                update(User)
                .where(User.id == user.id)
                .values(last_login=datetime.utcnow())
            )
            await session.commit()

        logger.info(
            "WebAuthn authentication successful",
            user_id=str(user.id),
            user_email=user.email,
            roles=user_roles,
        )

        return {
            "success": True,
            "data": {
                "access_token": access_token,
                "token_type": "bearer",
                "user": {
                    "id": str(user.id),
                    "email": user.email,
                    "full_name": user.full_name,
                    "is_verified": user.is_verified,
                    "roles": user_roles,
                },
            },
            "metadata": {
                "authentication_method": "webauthn",
                "expires_in": int(access_token_expires.total_seconds()),
            },
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "WebAuthn authentication verification failed",
            error=str(e),
            exception_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Authentication verification failed",
                },
            },
        )


# Credential Management Endpoints


@router.get("/credentials")
async def get_user_credentials(
    current_user: User = Depends(get_current_active_user),
) -> Dict[str, Any]:
    """
    Get user's registered WebAuthn credentials.

    Returns a list of the user's passkeys with safe information
    for management purposes.

    **Security Notes:**
    - Requires authenticated user
    - Returns only safe, non-sensitive credential information
    - Used for credential management UI
    """
    try:
        logger.info(
            "WebAuthn credentials list requested",
            user_id=str(current_user.id),
        )

        credentials = await webauthn_service.get_user_credentials(current_user)

        return {
            "success": True,
            "data": {
                "credentials": credentials,
                "total_count": len(credentials),
            },
            "metadata": {
                "user_id": str(current_user.id),
                "max_credentials": 10,  # Enterprise limit
            },
        }

    except Exception as e:
        logger.error(
            "Failed to get WebAuthn credentials",
            error=str(e),
            user_id=str(current_user.id),
            exception_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Failed to retrieve credentials",
                },
            },
        )


@router.delete("/credentials")
async def delete_credential(
    request: WebAuthnDeleteCredentialRequest,
    current_user: User = Depends(get_current_active_user),
) -> Dict[str, Any]:
    """
    Delete a user's WebAuthn credential.

    Removes a passkey from the user's account. Users can delete
    their own credentials for security or device management.

    **Security Notes:**
    - Requires authenticated user
    - Users can only delete their own credentials
    - Cannot delete last credential if no password set (enterprise policy)
    """
    try:
        logger.info(
            "WebAuthn credential deletion requested",
            user_id=str(current_user.id),
            credential_id=request.credential_id,
        )

        # Check if user has other authentication methods
        has_password = bool(current_user.hashed_password)
        current_credentials = await webauthn_service.get_user_credentials(current_user)

        if not has_password and len(current_credentials) <= 1:
            logger.warning(
                "Attempted to delete last WebAuthn credential without password",
                user_id=str(current_user.id),
            )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "success": False,
                    "error": {
                        "code": "LAST_CREDENTIAL",
                        "message": "Cannot delete last passkey without password backup",
                    },
                },
            )

        success = await webauthn_service.delete_user_credential(
            user=current_user,
            credential_id=request.credential_id,
        )

        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "success": False,
                    "error": {
                        "code": "CREDENTIAL_NOT_FOUND",
                        "message": "Credential not found",
                    },
                },
            )

        # Get updated credential list
        updated_credentials = await webauthn_service.get_user_credentials(current_user)

        logger.info(
            "WebAuthn credential deleted successfully",
            user_id=str(current_user.id),
            remaining_credentials=len(updated_credentials),
        )

        return {
            "success": True,
            "data": {
                "message": "Passkey deleted successfully",
                "remaining_credentials": len(updated_credentials),
            },
            "metadata": {
                "user_id": str(current_user.id),
                "deleted_credential_id": request.credential_id,
            },
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(
            "WebAuthn credential deletion failed",
            error=str(e),
            user_id=str(current_user.id),
            credential_id=request.credential_id,
            exception_type=type(e).__name__,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "Failed to delete credential",
                },
            },
        )


# Health and Status Endpoints


@router.get("/status")
async def webauthn_status() -> Dict[str, Any]:
    """
    Get WebAuthn service status and configuration.

    Returns information about WebAuthn support and configuration
    for client-side feature detection.

    **Public endpoint** - no authentication required.
    """
    try:
        return {
            "success": True,
            "data": {
                "webauthn_enabled": True,
                "rp_id": webauthn_service.rp_id,
                "rp_name": webauthn_service.rp_name,
                "supported_algorithms": [
                    "ES256",  # ECDSA with SHA-256
                    "RS256",  # RSASSA-PKCS1-v1_5 with SHA-256
                    "EdDSA",  # EdDSA signature algorithms
                ],
                "user_verification": "required",
                "attestation": "indirect",
            },
            "metadata": {
                "webauthn_version": "2.0",
                "fido_level": "FIDO2",
            },
        }

    except Exception as e:
        logger.error(
            "WebAuthn status check failed",
            error=str(e),
            exception_type=type(e).__name__,
        )
        return {
            "success": False,
            "error": {
                "code": "SERVICE_ERROR",
                "message": "WebAuthn service unavailable",
            },
        }
