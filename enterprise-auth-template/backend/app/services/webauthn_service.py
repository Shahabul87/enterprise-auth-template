"""
WebAuthn/Passkeys Service

Implements WebAuthn (Web Authentication API) for passwordless authentication
using FIDO2 passkeys. Provides secure, phishing-resistant authentication
for enterprise applications.

Features:
- Passkey registration (credential creation)
- Passkey authentication (credential assertion)
- Multi-device credential management
- Enterprise-grade security with attestation validation
- Cross-platform compatibility (iOS, Android, Windows Hello, etc.)
"""

import base64
import json
import secrets
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple, Any
from uuid import uuid4

import structlog
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from webauthn import (
    generate_registration_options,
    verify_registration_response,
    generate_authentication_options,
    verify_authentication_response,
)
from webauthn.helpers import (
    base64url_to_bytes,
    bytes_to_base64url,
)
from webauthn.helpers.structs import (
    AuthenticatorSelectionCriteria,
    UserVerificationRequirement,
    AttestationConveyancePreference,
    AuthenticatorAttachment,
    ResidentKeyRequirement,
    PublicKeyCredentialCreationOptions,
    PublicKeyCredentialRequestOptions,
    PublicKeyCredentialDescriptor,
    RegistrationCredential,
    AuthenticationCredential,
)
from webauthn.helpers.cose import COSEAlgorithmIdentifier

from app.core.config import get_settings
from app.models.user import User
from app.core.database import get_db_session

settings = get_settings()
logger = structlog.get_logger(__name__)


class WebAuthnCredential:
    """
    WebAuthn credential data structure for database storage.

    Stores credential information in a structured format within
    the user's webauthn_credentials JSONB field.
    """

    def __init__(
        self,
        credential_id: str,
        public_key: str,
        sign_count: int,
        aaguid: str,
        user_verified: bool,
        device_name: Optional[str] = None,
        created_at: Optional[datetime] = None,
        last_used: Optional[datetime] = None,
        transports: Optional[List[str]] = None,
    ):
        self.credential_id = credential_id
        self.public_key = public_key
        self.sign_count = sign_count
        self.aaguid = aaguid
        self.user_verified = user_verified
        self.device_name = device_name or "Unknown Device"
        self.created_at = created_at or datetime.utcnow()
        self.last_used = last_used
        self.transports = transports or []
        self.id = str(uuid4())  # Internal ID for management

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSONB storage."""
        return {
            "id": self.id,
            "credential_id": self.credential_id,
            "public_key": self.public_key,
            "sign_count": self.sign_count,
            "aaguid": self.aaguid,
            "user_verified": self.user_verified,
            "device_name": self.device_name,
            "created_at": self.created_at.isoformat(),
            "last_used": self.last_used.isoformat() if self.last_used else None,
            "transports": self.transports,
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'WebAuthnCredential':
        """Create from dictionary stored in JSONB."""
        created_at = datetime.fromisoformat(data["created_at"])
        last_used = datetime.fromisoformat(data["last_used"]) if data.get("last_used") else None

        credential = cls(
            credential_id=data["credential_id"],
            public_key=data["public_key"],
            sign_count=data["sign_count"],
            aaguid=data["aaguid"],
            user_verified=data["user_verified"],
            device_name=data.get("device_name", "Unknown Device"),
            created_at=created_at,
            last_used=last_used,
            transports=data.get("transports", []),
        )
        credential.id = data.get("id", str(uuid4()))
        return credential


class WebAuthnService:
    """
    WebAuthn service for enterprise passkey authentication.

    Implements the complete WebAuthn flow including:
    - Registration (credential creation)
    - Authentication (credential assertion)
    - Credential management
    - Security validation
    """

    def __init__(self):
        self.rp_id = self._get_relying_party_id()
        self.rp_name = settings.PROJECT_NAME
        self.origin = settings.FRONTEND_URL

        logger.info(
            "WebAuthn service initialized",
            rp_id=self.rp_id,
            rp_name=self.rp_name,
            origin=self.origin,
        )

    def _get_relying_party_id(self) -> str:
        """
        Extract relying party ID from frontend URL.

        For development: localhost
        For production: domain name (e.g., example.com)
        """
        try:
            from urllib.parse import urlparse
            parsed = urlparse(settings.FRONTEND_URL)
            # For localhost, use 'localhost', otherwise use hostname
            hostname = parsed.hostname or "localhost"
            return "localhost" if hostname == "localhost" else hostname
        except Exception:
            logger.warning("Failed to parse frontend URL, using localhost")
            return "localhost"

    async def generate_registration_options(
        self,
        user: User,
        device_name: Optional[str] = None,
    ) -> Tuple[Dict[str, Any], str]:
        """
        Generate WebAuthn registration options for passkey creation.

        Args:
            user: User object for credential registration
            device_name: Optional device name for identification

        Returns:
            Tuple of (registration_options, challenge) for client

        Raises:
            ValueError: If user data is invalid
        """
        try:
            # Validate user
            if not user.id or not user.email:
                raise ValueError("User must have valid ID and email")

            # Get existing credentials to exclude
            existing_credentials = await self._get_user_credentials(user)
            exclude_credentials = [
                {
                    "type": "public-key",
                    "id": base64url_to_bytes(cred.credential_id),
                }
                for cred in existing_credentials
            ]

            # User information for WebAuthn
            user_dict = {
                "id": str(user.id).encode('utf-8'),
                "name": user.email,
                "displayName": user.full_name or user.email,
            }

            # Authenticator selection criteria for enterprise security
            authenticator_selection = AuthenticatorSelectionCriteria(
                authenticator_attachment=AuthenticatorAttachment.CROSS_PLATFORM,  # Allow both platform and roaming
                resident_key=ResidentKeyRequirement.PREFERRED,  # Enable discoverable credentials
                user_verification=UserVerificationRequirement.REQUIRED,  # Require biometrics/PIN
            )

            # Generate registration options
            options = generate_registration_options(
                rp_id=self.rp_id,
                rp_name=self.rp_name,
                user=user_dict,
                exclude_credentials=exclude_credentials,
                authenticator_selection=authenticator_selection,
                attestation=AttestationConveyancePreference.INDIRECT,  # Get device attestation
                supported_algorithms=[
                    COSEAlgorithmIdentifier.ECDSA_SHA_256,  # ES256 (preferred)
                    COSEAlgorithmIdentifier.RSASSA_PKCS1_v1_5_SHA_256,  # RS256 (fallback)
                    COSEAlgorithmIdentifier.EDDSA,  # EdDSA (modern)
                ],
                timeout=60000,  # 60 seconds
            )

            # Store challenge for verification (in production, use Redis)
            challenge = bytes_to_base64url(options.challenge)

            logger.info(
                "WebAuthn registration options generated",
                user_id=str(user.id),
                user_email=user.email,
                device_name=device_name,
                challenge=challenge[:16] + "...",  # Log partial challenge
                existing_credentials_count=len(existing_credentials),
            )

            # Convert to serializable format for frontend
            serializable_options = {
                "rp": {"name": options.rp.name, "id": options.rp.id},
                "user": {
                    "id": bytes_to_base64url(options.user.id),
                    "name": options.user.name,
                    "displayName": options.user.display_name,
                },
                "challenge": challenge,
                "pubKeyCredParams": [
                    {"type": param.type, "alg": param.alg}
                    for param in options.pub_key_cred_params
                ],
                "timeout": options.timeout,
                "excludeCredentials": [
                    {
                        "type": cred["type"],
                        "id": bytes_to_base64url(cred["id"]),
                        "transports": ["usb", "nfc", "ble", "internal"],
                    }
                    for cred in exclude_credentials
                ],
                "authenticatorSelection": {
                    "authenticatorAttachment": authenticator_selection.authenticator_attachment,
                    "residentKey": authenticator_selection.resident_key,
                    "userVerification": authenticator_selection.user_verification,
                },
                "attestation": options.attestation,
            }

            return serializable_options, challenge

        except Exception as e:
            logger.error(
                "Failed to generate WebAuthn registration options",
                error=str(e),
                user_id=str(user.id) if user else None,
                exception_type=type(e).__name__,
            )
            raise ValueError(f"Failed to generate registration options: {str(e)}")

    async def verify_registration_response(
        self,
        user: User,
        credential_data: Dict[str, Any],
        expected_challenge: str,
        device_name: Optional[str] = None,
    ) -> bool:
        """
        Verify WebAuthn registration response and store credential.

        Args:
            user: User object for credential registration
            credential_data: Registration response from client
            expected_challenge: Expected challenge from registration options
            device_name: Optional device name for identification

        Returns:
            bool: True if registration successful, False otherwise
        """
        try:
            # Create registration credential object
            credential = RegistrationCredential.parse_raw(json.dumps(credential_data))

            # Verify registration response
            verification = verify_registration_response(
                credential=credential,
                expected_challenge=base64url_to_bytes(expected_challenge),
                expected_origin=self.origin,
                expected_rp_id=self.rp_id,
                require_user_verification=True,
            )

            # Check verification result based on available attributes
            is_verified = getattr(verification, 'verified', getattr(verification, 'user_verified', False))

            if not is_verified:
                logger.warning(
                    "WebAuthn registration verification failed",
                    user_id=str(user.id),
                    verification_details=str(verification),
                )
                return False

            # Extract credential information
            credential_id = bytes_to_base64url(verification.credential_id)
            public_key = bytes_to_base64url(verification.credential_public_key)
            aaguid = str(verification.aaguid) if verification.aaguid else "unknown"

            # Create WebAuthn credential object
            webauthn_cred = WebAuthnCredential(
                credential_id=credential_id,
                public_key=public_key,
                sign_count=verification.sign_count,
                aaguid=aaguid,
                user_verified=verification.user_verified,
                device_name=device_name or self._detect_device_name(credential_data),
                created_at=datetime.utcnow(),
                transports=credential_data.get("response", {}).get("transports", []),
            )

            # Store credential in user's WebAuthn credentials
            await self._store_user_credential(user, webauthn_cred)

            logger.info(
                "WebAuthn registration successful",
                user_id=str(user.id),
                credential_id=credential_id[:16] + "...",
                device_name=webauthn_cred.device_name,
                aaguid=aaguid,
                user_verified=verification.user_verified,
            )

            return True

        except Exception as e:
            logger.error(
                "WebAuthn registration verification failed",
                error=str(e),
                user_id=str(user.id),
                exception_type=type(e).__name__,
            )
            return False

    async def generate_authentication_options(
        self,
        user: Optional[User] = None,
    ) -> Tuple[Dict[str, Any], str]:
        """
        Generate WebAuthn authentication options for passkey login.

        Args:
            user: Optional user object (if None, allows discoverable credentials)

        Returns:
            Tuple of (authentication_options, challenge) for client
        """
        try:
            # Get user credentials if user provided
            allow_credentials = []
            if user:
                existing_credentials = await self._get_user_credentials(user)
                allow_credentials = [
                    {
                        "type": "public-key",
                        "id": base64url_to_bytes(cred.credential_id),
                        "transports": cred.transports,
                    }
                    for cred in existing_credentials
                ]

            # Generate authentication options
            options = generate_authentication_options(
                rp_id=self.rp_id,
                allow_credentials=allow_credentials,
                user_verification=UserVerificationRequirement.REQUIRED,
                timeout=60000,  # 60 seconds
            )

            challenge = bytes_to_base64url(options.challenge)

            logger.info(
                "WebAuthn authentication options generated",
                user_id=str(user.id) if user else "discoverable",
                challenge=challenge[:16] + "...",
                credentials_count=len(allow_credentials),
            )

            # Convert to serializable format
            serializable_options = {
                "challenge": challenge,
                "timeout": options.timeout,
                "rpId": options.rp_id,
                "allowCredentials": [
                    {
                        "type": cred["type"],
                        "id": bytes_to_base64url(cred["id"]),
                        "transports": cred.get("transports", []),
                    }
                    for cred in allow_credentials
                ],
                "userVerification": options.user_verification,
            }

            return serializable_options, challenge

        except Exception as e:
            logger.error(
                "Failed to generate WebAuthn authentication options",
                error=str(e),
                user_id=str(user.id) if user else None,
                exception_type=type(e).__name__,
            )
            raise ValueError(f"Failed to generate authentication options: {str(e)}")

    async def verify_authentication_response(
        self,
        credential_data: Dict[str, Any],
        expected_challenge: str,
    ) -> Optional[User]:
        """
        Verify WebAuthn authentication response and return authenticated user.

        Args:
            credential_data: Authentication response from client
            expected_challenge: Expected challenge from authentication options

        Returns:
            Optional[User]: Authenticated user if successful, None otherwise
        """
        try:
            credential = AuthenticationCredential.parse_raw(json.dumps(credential_data))
            credential_id = bytes_to_base64url(credential.raw_id)

            # Find user by credential ID
            user = await self._find_user_by_credential_id(credential_id)
            if not user:
                logger.warning(
                    "WebAuthn authentication failed - credential not found",
                    credential_id=credential_id[:16] + "...",
                )
                return None

            # Get stored credential
            stored_cred = await self._get_user_credential_by_id(user, credential_id)
            if not stored_cred:
                logger.warning(
                    "WebAuthn authentication failed - stored credential not found",
                    user_id=str(user.id),
                    credential_id=credential_id[:16] + "...",
                )
                return None

            # Verify authentication response
            verification = verify_authentication_response(
                credential=credential,
                expected_challenge=base64url_to_bytes(expected_challenge),
                expected_origin=self.origin,
                expected_rp_id=self.rp_id,
                credential_public_key=base64url_to_bytes(stored_cred.public_key),
                credential_current_sign_count=stored_cred.sign_count,
                require_user_verification=True,
            )

            # Check verification result based on available attributes
            is_verified = getattr(verification, 'verified', getattr(verification, 'user_verified', False))

            if not is_verified:
                logger.warning(
                    "WebAuthn authentication verification failed",
                    user_id=str(user.id),
                    credential_id=credential_id[:16] + "...",
                )
                return None

            # Update credential sign count and last used
            stored_cred.sign_count = verification.new_sign_count
            stored_cred.last_used = datetime.utcnow()
            await self._update_user_credential(user, stored_cred)

            logger.info(
                "WebAuthn authentication successful",
                user_id=str(user.id),
                user_email=user.email,
                credential_id=credential_id[:16] + "...",
                device_name=stored_cred.device_name,
                new_sign_count=verification.new_sign_count,
            )

            return user

        except Exception as e:
            logger.error(
                "WebAuthn authentication verification failed",
                error=str(e),
                exception_type=type(e).__name__,
            )
            return None

    async def get_user_credentials(self, user: User) -> List[Dict[str, Any]]:
        """
        Get user's WebAuthn credentials for management interface.

        Args:
            user: User object

        Returns:
            List of credential dictionaries with safe information
        """
        try:
            credentials = await self._get_user_credentials(user)

            # Return safe information for frontend
            return [
                {
                    "id": cred.id,
                    "device_name": cred.device_name,
                    "created_at": cred.created_at.isoformat(),
                    "last_used": cred.last_used.isoformat() if cred.last_used else None,
                    "transports": cred.transports,
                    "aaguid": cred.aaguid,
                    "credential_id_preview": cred.credential_id[:16] + "...",
                }
                for cred in credentials
            ]

        except Exception as e:
            logger.error(
                "Failed to get user WebAuthn credentials",
                error=str(e),
                user_id=str(user.id),
            )
            return []

    async def delete_user_credential(self, user: User, credential_id: str) -> bool:
        """
        Delete a user's WebAuthn credential.

        Args:
            user: User object
            credential_id: Internal credential ID (not WebAuthn credential ID)

        Returns:
            bool: True if deletion successful
        """
        try:
            credentials = await self._get_user_credentials(user)

            # Find and remove credential
            updated_credentials = [
                cred for cred in credentials if cred.id != credential_id
            ]

            if len(updated_credentials) == len(credentials):
                logger.warning(
                    "WebAuthn credential not found for deletion",
                    user_id=str(user.id),
                    credential_id=credential_id,
                )
                return False

            # Update user's credentials
            credentials_data = [cred.to_dict() for cred in updated_credentials]

            # Use the existing session from the service
            await self.session.execute(
                update(User)
                .where(User.id == user.id)
                .values(webauthn_credentials=credentials_data)
            )
            await self.session.commit()

            logger.info(
                "WebAuthn credential deleted",
                user_id=str(user.id),
                credential_id=credential_id,
                remaining_credentials=len(updated_credentials),
            )

            return True

        except Exception as e:
            logger.error(
                "Failed to delete WebAuthn credential",
                error=str(e),
                user_id=str(user.id),
                credential_id=credential_id,
            )
            return False

    # Helper methods

    async def _get_user_credentials(self, user: User) -> List[WebAuthnCredential]:
        """Get user's WebAuthn credentials from database."""
        try:
            if not user.webauthn_credentials:
                return []

            credentials = []
            for cred_data in user.webauthn_credentials:
                if isinstance(cred_data, dict):
                    credentials.append(WebAuthnCredential.from_dict(cred_data))

            return credentials

        except Exception as e:
            logger.error(
                "Failed to parse user WebAuthn credentials",
                error=str(e),
                user_id=str(user.id),
            )
            return []

    async def _store_user_credential(
        self, user: User, credential: WebAuthnCredential
    ) -> None:
        """Store WebAuthn credential for user."""
        try:
            # Get existing credentials
            existing_credentials = await self._get_user_credentials(user)

            # Add new credential
            existing_credentials.append(credential)

            # Convert to serializable format
            credentials_data = [cred.to_dict() for cred in existing_credentials]

            # Update user in database
            # Use the existing session from the service
            await self.session.execute(
                update(User)
                .where(User.id == user.id)
                .values(webauthn_credentials=credentials_data)
            )
            await self.session.commit()

        except Exception as e:
            logger.error(
                "Failed to store WebAuthn credential",
                error=str(e),
                user_id=str(user.id),
            )
            raise

    async def _update_user_credential(
        self, user: User, updated_credential: WebAuthnCredential
    ) -> None:
        """Update existing WebAuthn credential."""
        try:
            credentials = await self._get_user_credentials(user)

            # Find and update credential
            for i, cred in enumerate(credentials):
                if cred.credential_id == updated_credential.credential_id:
                    credentials[i] = updated_credential
                    break

            # Store updated credentials
            credentials_data = [cred.to_dict() for cred in credentials]

            # Use the existing session from the service
            await self.session.execute(
                update(User)
                .where(User.id == user.id)
                .values(webauthn_credentials=credentials_data)
            )
            await self.session.commit()

        except Exception as e:
            logger.error(
                "Failed to update WebAuthn credential",
                error=str(e),
                user_id=str(user.id),
            )
            raise

    async def _find_user_by_credential_id(self, credential_id: str) -> Optional[User]:
        """Find user by WebAuthn credential ID."""
        try:
            async with get_session() as session:
                # Query users with WebAuthn credentials
                result = await session.execute(
                    select(User).where(User.webauthn_credentials.isnot(None))
                )
                users = result.scalars().all()

                # Search through credentials
                for user in users:
                    if user.webauthn_credentials:
                        for cred_data in user.webauthn_credentials:
                            if (isinstance(cred_data, dict) and
                                cred_data.get("credential_id") == credential_id):
                                return user

                return None

        except Exception as e:
            logger.error(
                "Failed to find user by WebAuthn credential ID",
                error=str(e),
                credential_id=credential_id[:16] + "...",
            )
            return None

    async def _get_user_credential_by_id(
        self, user: User, credential_id: str
    ) -> Optional[WebAuthnCredential]:
        """Get specific WebAuthn credential by ID."""
        credentials = await self._get_user_credentials(user)

        for cred in credentials:
            if cred.credential_id == credential_id:
                return cred

        return None

    def _detect_device_name(self, credential_data: Dict[str, Any]) -> str:
        """Detect device name from credential data."""
        # Try to extract device information from attestation
        # This is a simplified implementation - production would use FIDO metadata
        transports = credential_data.get("response", {}).get("transports", [])

        if "internal" in transports:
            return "Built-in authenticator"
        elif "usb" in transports:
            return "USB security key"
        elif "nfc" in transports:
            return "NFC security key"
        elif "ble" in transports:
            return "Bluetooth security key"
        else:
            return "Unknown device"


# Global service instance
webauthn_service = WebAuthnService()
