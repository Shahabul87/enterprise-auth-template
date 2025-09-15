"""
SMS Authentication Endpoints

Handles SMS-based authentication including OTP generation
and verification for login and registration.
"""

from typing import Optional
import structlog
from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, Field, validator
import re

from app.core.database import get_db_session
from app.services.sms_service import SMSService
# Import new refactored services
from app.services.auth.authentication_service import AuthenticationService
from app.services.auth.registration_service import RegistrationService
from app.repositories.user_repository import UserRepository
from app.repositories.session_repository import SessionRepository
from app.repositories.role_repository import RoleRepository
from app.schemas.response import StandardResponse
from app.schemas.auth import AuthResponseData
from app.core.exceptions import ValidationError

# Create local response helpers if not available
def success_response(data=None, message="Success"):
    return StandardResponse(success=True, data=data, message=message)

def error_response(message="Error occurred"):
    return StandardResponse(success=False, message=message)

def validation_error(message="Validation failed"):
    return StandardResponse(success=False, message=message)

logger = structlog.get_logger(__name__)
router = APIRouter(prefix="/sms", tags=["SMS Authentication"])


class PhoneNumberRequest(BaseModel):
    """Request model for phone number submission"""
    phone_number: str = Field(..., description="Phone number in E.164 format")
    purpose: str = Field(
        default="authentication",
        description="Purpose of OTP: authentication, registration, verification"
    )
    
    @validator("phone_number")
    def validate_phone_number(cls, v):
        # Basic E.164 format validation
        pattern = r'^\+[1-9]\d{1,14}$'
        if not re.match(pattern, v):
            raise ValueError("Phone number must be in E.164 format (e.g., +1234567890)")
        return v


class OTPVerificationRequest(BaseModel):
    """Request model for OTP verification"""
    phone_number: str = Field(..., description="Phone number in E.164 format")
    otp: str = Field(..., min_length=6, max_length=6, description="6-digit OTP")
    purpose: str = Field(
        default="authentication",
        description="Purpose of OTP verification"
    )
    
    @validator("otp")
    def validate_otp(cls, v):
        if not v.isdigit():
            raise ValueError("OTP must contain only digits")
        return v


class SMSRegistrationRequest(BaseModel):
    """Request model for SMS-based registration"""
    phone_number: str = Field(..., description="Phone number in E.164 format")
    otp: str = Field(..., min_length=6, max_length=6, description="6-digit OTP")
    name: str = Field(..., min_length=1, max_length=100, description="User's full name")
    email: Optional[str] = Field(None, description="Optional email address")
    
    @validator("phone_number")
    def validate_phone_number(cls, v):
        pattern = r'^\+[1-9]\d{1,14}$'
        if not re.match(pattern, v):
            raise ValueError("Phone number must be in E.164 format")
        return v


@router.post(
    "/send-otp",
    response_model=StandardResponse[dict],
    status_code=status.HTTP_200_OK,
    summary="Send OTP to phone number"
)
async def send_otp(
    request: PhoneNumberRequest,
    req: Request,
    db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[dict]:
    """
    Send OTP to the specified phone number.
    
    Supports different purposes:
    - authentication: For login
    - registration: For new user registration
    - verification: For phone number verification
    
    Rate limited to prevent abuse.
    """
    try:
        sms_service = SMSService(db)
        
        # Send OTP
        result = await sms_service.send_otp(
            phone_number=request.phone_number,
            purpose=request.purpose
        )
        
        logger.info(
            "OTP sent successfully",
            phone_number=request.phone_number[:3] + "****",
            purpose=request.purpose
        )
        
        return success_response(
            data={
                "message": "OTP sent successfully",
                "expires_in": 600  # 10 minutes
            },
            message="OTP has been sent to your phone number"
        )
        
    except ValidationError as e:
        logger.warning("OTP sending failed - validation error", error=str(e))
        return validation_error(str(e))
    except Exception as e:
        logger.error("Failed to send OTP", error=str(e))
        return error_response("Failed to send OTP. Please try again later.")


@router.post(
    "/verify-otp",
    response_model=StandardResponse[dict],
    status_code=status.HTTP_200_OK,
    summary="Verify OTP"
)
async def verify_otp(
    request: OTPVerificationRequest,
    req: Request,
    db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[dict]:
    """
    Verify OTP for the specified phone number.
    
    Used for various purposes including authentication
    and phone number verification.
    """
    try:
        sms_service = SMSService(db)
        
        # Verify OTP
        result = await sms_service.verify_otp(
            phone_number=request.phone_number,
            otp=request.otp,
            purpose=request.purpose
        )
        
        if result["success"]:
            logger.info(
                "OTP verified successfully",
                phone_number=request.phone_number[:3] + "****",
                purpose=request.purpose
            )
            
            return success_response(
                data={
                    "message": "OTP verified successfully",
                    "verified": True
                },
                message="Phone number verified successfully"
            )
        else:
            return error_response("Invalid or expired OTP")
            
    except ValidationError as e:
        logger.warning("OTP verification failed", error=str(e))
        return validation_error(str(e))
    except Exception as e:
        logger.error("Failed to verify OTP", error=str(e))
        return error_response("Verification failed. Please try again.")


@router.post(
    "/login",
    response_model=StandardResponse[AuthResponseData],
    status_code=status.HTTP_200_OK,
    summary="Login with phone number and OTP"
)
async def sms_login(
    request: OTPVerificationRequest,
    req: Request,
    db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[AuthResponseData]:
    """
    Login using phone number and OTP.
    
    Returns JWT tokens on successful authentication.
    """
    try:
        sms_service = SMSService(db)
        # Use new authentication service
        user_repo = UserRepository(db)
        session_repo = SessionRepository(db)
        auth_service = AuthenticationService(db, user_repo, session_repo)

        # Verify and login
        user = await sms_service.login_with_phone(
            phone_number=request.phone_number,
            otp=request.otp
        )
        
        if not user:
            return error_response("Invalid credentials or phone number not registered")

        # Get client info
        client_ip = req.client.host if req.client else "unknown"
        user_agent = req.headers.get("user-agent", "unknown")

        # Create session and generate tokens using new service
        auth_result = await auth_service._create_user_session(
            user=user,
            ip_address=client_ip,
            user_agent=user_agent
        )

        access_token = auth_result.access_token
        refresh_token = auth_result.refresh_token

        logger.info(
            "User logged in via SMS",
            user_id=str(user.id),
            phone_number=request.phone_number[:3] + "****"
        )

        return success_response(
            data=AuthResponseData(
                access_token=access_token,
                refresh_token=refresh_token,
                token_type="bearer",
                expires_in=auth_result.expires_in,
                user={
                    "id": str(user.id),
                    "phone_number": user.phone_number,
                    "email": user.email,
                    "full_name": user.full_name,
                    "is_active": user.is_active
                }
            ),
            message="Login successful"
        )
        
    except ValidationError as e:
        logger.warning("SMS login failed", error=str(e))
        return validation_error(str(e))
    except Exception as e:
        logger.error("SMS login error", error=str(e))
        return error_response("Login failed. Please try again.")


@router.post(
    "/register",
    response_model=StandardResponse[AuthResponseData],
    status_code=status.HTTP_201_CREATED,
    summary="Register with phone number"
)
async def sms_register(
    request: SMSRegistrationRequest,
    req: Request,
    db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[AuthResponseData]:
    """
    Register a new user with phone number and OTP.
    
    Requires OTP to be sent first via /send-otp endpoint
    with purpose='registration'.
    """
    try:
        sms_service = SMSService(db)
        # Use new registration service
        user_repo = UserRepository(db)
        role_repo = RoleRepository(db)
        registration_service = RegistrationService(db, user_repo, role_repo)

        # Register user
        user = await sms_service.register_with_phone(
            phone_number=request.phone_number,
            otp=request.otp,
            name=request.name,
            email=request.email
        )

        # Get client info
        client_ip = req.client.host if req.client else "unknown"
        user_agent = req.headers.get("user-agent", "unknown")

        # Create session and generate tokens using authentication service
        # (registration service creates user, auth service creates session)
        auth_service = AuthenticationService(db, user_repo, SessionRepository(db))
        auth_result = await auth_service._create_user_session(
            user=user,
            ip_address=client_ip,
            user_agent=user_agent
        )

        access_token = auth_result.access_token
        refresh_token = auth_result.refresh_token

        logger.info(
            "User registered via SMS",
            user_id=str(user.id),
            phone_number=request.phone_number[:3] + "****"
        )

        return success_response(
            data=AuthResponseData(
                access_token=access_token,
                refresh_token=refresh_token,
                token_type="bearer",
                expires_in=auth_result.expires_in,
                user={
                    "id": str(user.id),
                    "phone_number": user.phone_number,
                    "email": user.email,
                    "full_name": user.full_name,
                    "is_active": user.is_active
                }
            ),
            message="Registration successful"
        )
        
    except ValidationError as e:
        logger.warning("SMS registration failed", error=str(e))
        return validation_error(str(e))
    except Exception as e:
        logger.error("SMS registration error", error=str(e))
        return error_response("Registration failed. Please try again.")


@router.post(
    "/resend-otp",
    response_model=StandardResponse[dict],
    status_code=status.HTTP_200_OK,
    summary="Resend OTP"
)
async def resend_otp(
    request: PhoneNumberRequest,
    req: Request,
    db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[dict]:
    """
    Resend OTP to phone number.
    
    Rate limited to prevent abuse.
    Same as send-otp but explicitly for resending.
    """
    return await send_otp(request, req, db)