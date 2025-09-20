"""
SMS Service for Authentication

Handles SMS-based authentication including OTP generation,
verification, and integration with SMS providers.
"""

import secrets
import string
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
import httpx
import structlog
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_

from app.core.config import get_settings
from app.core.exceptions import ValidationError
from app.models.user import User
from app.services.audit_service import AuditService
from app.core.redis_client import get_redis_client


# Create ServiceError locally if not available
class ServiceError(Exception):
    pass


logger = structlog.get_logger(__name__)
settings = get_settings()


class SMSProvider:
    """Base class for SMS providers"""

    async def send_sms(self, phone_number: str, message: str) -> bool:
        raise NotImplementedError


class TwilioProvider(SMSProvider):
    """Twilio SMS provider implementation"""

    def __init__(self):
        self.account_sid = settings.TWILIO_ACCOUNT_SID
        self.auth_token = settings.TWILIO_AUTH_TOKEN
        self.from_number = settings.TWILIO_PHONE_NUMBER
        self.base_url = "https://api.twilio.com/2010-04-01"

    async def send_sms(self, phone_number: str, message: str) -> bool:
        """Send SMS via Twilio"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.base_url}/Accounts/{self.account_sid}/Messages.json",
                    auth=(self.account_sid, self.auth_token),
                    data={
                        "From": self.from_number,
                        "To": phone_number,
                        "Body": message,
                    },
                )
                return response.status_code == 201
        except Exception as e:
            logger.error("Failed to send SMS via Twilio", error=str(e))
            return False


class AWSProvider(SMSProvider):
    """AWS SNS SMS provider implementation"""

    def __init__(self):
        import boto3

        self.client = boto3.client(
            "sns",
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION,
        )

    async def send_sms(self, phone_number: str, message: str) -> bool:
        """Send SMS via AWS SNS"""
        try:
            response = self.client.publish(
                PhoneNumber=phone_number,
                Message=message,
                MessageAttributes={
                    "AWS.SNS.SMS.SMSType": {
                        "DataType": "String",
                        "StringValue": "Transactional",
                    }
                },
            )
            return response["ResponseMetadata"]["HTTPStatusCode"] == 200
        except Exception as e:
            logger.error("Failed to send SMS via AWS SNS", error=str(e))
            return False


class SMSService:
    """Service for handling SMS-based authentication"""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.audit_service = AuditService(db)
        self.redis_client = get_redis_client()

        # Select SMS provider based on configuration
        if settings.SMS_PROVIDER == "twilio":
            self.provider = TwilioProvider()
        elif settings.SMS_PROVIDER == "aws":
            self.provider = AWSProvider()
        else:
            self.provider = None

    def generate_otp(self, length: int = 6) -> str:
        """Generate a random OTP"""
        digits = string.digits
        return "".join(secrets.choice(digits) for _ in range(length))

    async def send_otp(
        self,
        phone_number: str,
        user_id: Optional[str] = None,
        purpose: str = "authentication",
    ) -> Dict[str, Any]:
        """
        Send OTP to phone number

        Args:
            phone_number: Phone number to send OTP to
            user_id: Optional user ID for tracking
            purpose: Purpose of OTP (authentication, verification, reset)

        Returns:
            Dictionary with success status and message
        """
        if not self.provider:
            raise ServiceError("SMS provider not configured")

        # Generate OTP
        otp = self.generate_otp()

        # Store OTP in Redis with 10-minute expiration
        otp_key = f"sms_otp:{phone_number}:{purpose}"
        otp_data = {
            "otp": otp,
            "attempts": 0,
            "created_at": datetime.utcnow().isoformat(),
            "user_id": user_id,
        }

        await self.redis_client.setex(otp_key, 600, str(otp_data))  # 10 minutes

        # Rate limiting check
        rate_key = f"sms_rate:{phone_number}"
        sends_today = await self.redis_client.incr(rate_key)
        if sends_today == 1:
            await self.redis_client.expire(rate_key, 86400)  # 24 hours

        if sends_today > settings.MAX_SMS_PER_DAY:
            raise ValidationError("Daily SMS limit exceeded")

        # Compose message
        message = self._compose_otp_message(otp, purpose)

        # Send SMS
        success = await self.provider.send_sms(phone_number, message)

        if success:
            # Log audit event
            await self.audit_service.log_event(
                event_type="sms.otp_sent",
                user_id=user_id,
                details={
                    "phone_number": self._mask_phone(phone_number),
                    "purpose": purpose,
                },
            )

            logger.info(
                "OTP sent successfully",
                phone_number=self._mask_phone(phone_number),
                purpose=purpose,
            )

            return {"success": True, "message": "OTP sent successfully"}
        else:
            raise ServiceError("Failed to send OTP")

    async def verify_otp(
        self, phone_number: str, otp: str, purpose: str = "authentication"
    ) -> Dict[str, Any]:
        """
        Verify OTP for phone number

        Args:
            phone_number: Phone number to verify
            otp: OTP code to verify
            purpose: Purpose of OTP verification

        Returns:
            Dictionary with verification result
        """
        otp_key = f"sms_otp:{phone_number}:{purpose}"

        # Get OTP data from Redis
        otp_data_str = await self.redis_client.get(otp_key)
        if not otp_data_str:
            raise ValidationError("OTP expired or invalid")

        import json

        otp_data = json.loads(otp_data_str)

        # Check attempts
        if otp_data["attempts"] >= settings.MAX_OTP_ATTEMPTS:
            await self.redis_client.delete(otp_key)
            raise ValidationError("Maximum OTP attempts exceeded")

        # Increment attempts
        otp_data["attempts"] += 1
        await self.redis_client.setex(
            otp_key, 300, json.dumps(otp_data)  # Reset expiry to 5 minutes
        )

        # Verify OTP
        if otp_data["otp"] != otp:
            if otp_data["attempts"] >= settings.MAX_OTP_ATTEMPTS:
                await self.redis_client.delete(otp_key)
            raise ValidationError("Invalid OTP")

        # OTP is valid, delete it
        await self.redis_client.delete(otp_key)

        # Log audit event
        await self.audit_service.log_event(
            event_type="sms.otp_verified",
            user_id=otp_data.get("user_id"),
            details={
                "phone_number": self._mask_phone(phone_number),
                "purpose": purpose,
            },
        )

        return {
            "success": True,
            "message": "OTP verified successfully",
            "user_id": otp_data.get("user_id"),
        }

    async def register_with_phone(
        self, phone_number: str, otp: str, name: str, email: Optional[str] = None
    ) -> User:
        """
        Register a new user with phone number

        Args:
            phone_number: Phone number for registration
            otp: OTP for verification
            name: User's name
            email: Optional email address

        Returns:
            Created user object
        """
        # Verify OTP first
        verification = await self.verify_otp(phone_number, otp, purpose="registration")

        if not verification["success"]:
            raise ValidationError("Invalid or expired OTP")

        # Check if phone number already exists
        existing_user = await self.db.execute(
            select(User).where(User.phone_number == phone_number)
        )
        if existing_user.scalar_one_or_none():
            raise ValidationError("Phone number already registered")

        # Create user
        user = User(
            phone_number=phone_number,
            full_name=name or "User",
            email=email or f"{phone_number}@sms.local",
            is_phone_verified=True,
            is_active=True,
            created_at=datetime.utcnow(),
        )

        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)

        # Log audit event
        await self.audit_service.log_event(
            event_type="user.registered_via_sms",
            user_id=str(user.id),
            details={"phone_number": self._mask_phone(phone_number)},
        )

        return user

    async def login_with_phone(self, phone_number: str, otp: str) -> Optional[User]:
        """
        Login user with phone number and OTP

        Args:
            phone_number: Phone number for login
            otp: OTP for verification

        Returns:
            User object if login successful
        """
        # Verify OTP
        verification = await self.verify_otp(
            phone_number, otp, purpose="authentication"
        )

        if not verification["success"]:
            return None

        # Get user by phone number
        result = await self.db.execute(
            select(User).where(
                and_(
                    User.phone_number == phone_number,
                    User.is_active == True,
                    User.is_phone_verified == True,
                )
            )
        )
        user = result.scalar_one_or_none()

        if user:
            # Update last login
            user.last_login_at = datetime.utcnow()
            await self.db.commit()

            # Log audit event
            await self.audit_service.log_event(
                event_type="user.login_via_sms",
                user_id=str(user.id),
                details={"phone_number": self._mask_phone(phone_number)},
            )

        return user

    def _compose_otp_message(self, otp: str, purpose: str) -> str:
        """Compose OTP message based on purpose"""
        messages = {
            "authentication": f"Your login OTP is: {otp}. Valid for 10 minutes.",
            "verification": f"Your verification code is: {otp}. Valid for 10 minutes.",
            "reset": f"Your password reset OTP is: {otp}. Valid for 10 minutes.",
            "registration": f"Welcome! Your registration OTP is: {otp}. Valid for 10 minutes.",
        }
        return messages.get(purpose, f"Your OTP is: {otp}")

    def _mask_phone(self, phone_number: str) -> str:
        """Mask phone number for privacy"""
        if len(phone_number) > 6:
            return f"{phone_number[:3]}****{phone_number[-2:]}"
        return "****"
