"""
API Key Service for managing API authentication keys.
"""

from typing import List, Optional, Dict, Any
from uuid import UUID
from datetime import datetime, timedelta
from sqlalchemy import select, and_, or_, func
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError
import secrets
import hashlib

from app.models.api_key import APIKey, APIKeyScopes
from app.models.user import User
from app.models.organization import Organization
from app.services.audit_service import AuditService
from app.core.config import get_settings
from app.core.security import get_password_hash, verify_password
import logging

logger = logging.getLogger(__name__)


class APIKeyService:
    """Service for managing API keys."""

    def __init__(self, db: AsyncSession):
        """Initialize API key service."""
        self.db = db
        self.audit_service = AuditService(db)

    async def create_api_key(
        self,
        user_id: UUID,
        name: str,
        description: Optional[str] = None,
        scopes: Optional[List[str]] = None,
        rate_limit: int = 1000,
        allowed_ips: Optional[List[str]] = None,
        expires_in_days: Optional[int] = None,
        organization_id: Optional[UUID] = None
    ) -> tuple[APIKey, str]:
        """
        Create a new API key.

        Args:
            user_id: User ID who owns the key
            name: Name for the API key
            description: Description of key usage
            scopes: List of allowed scopes
            rate_limit: Requests per hour limit
            allowed_ips: List of allowed IP addresses
            expires_in_days: Days until expiration (None = never expires)
            organization_id: Organization ID if applicable

        Returns:
            Tuple of (APIKey object, raw API key string)
        """
        try:
            # Generate the API key
            raw_key = APIKey.generate_key()
            key_prefix = raw_key[:10]
            key_hash = get_password_hash(raw_key)

            # Calculate expiration
            expires_at = None
            if expires_in_days:
                expires_at = datetime.utcnow() + timedelta(days=expires_in_days)

            # Set default scopes if none provided
            if not scopes:
                scopes = APIKeyScopes.get_default_scopes()

            # Check organization limits if applicable
            if organization_id:
                org_query = select(Organization).where(Organization.id == organization_id)
                org_result = await self.db.execute(org_query)
                org = org_result.scalar_one_or_none()

                if org:
                    # Check API key limit
                    existing_keys = await self.get_organization_api_keys(organization_id)
                    if len(existing_keys) >= org.max_api_keys and org.max_api_keys != -1:
                        raise ValueError(f"Organization has reached API key limit ({org.max_api_keys})")

            # Create API key
            api_key = APIKey(
                name=name,
                key_prefix=key_prefix,
                key_hash=key_hash,
                description=description,
                scopes=scopes,
                rate_limit=rate_limit,
                allowed_ips=allowed_ips,
                expires_at=expires_at,
                user_id=user_id,
                organization_id=organization_id,
                is_active=True
            )

            self.db.add(api_key)
            await self.db.commit()
            await self.db.refresh(api_key)

            # Audit log
            await self.audit_service.log_action(
                user_id=user_id,
                action="api_key.create",
                resource_type="api_key",
                resource_id=str(api_key.id),
                details={
                    "name": name,
                    "scopes": scopes,
                    "expires_in_days": expires_in_days
                }
            )

            logger.info(f"Created API key: {name} for user {user_id}")

            # Return both the key object and the raw key (only time raw key is available)
            return api_key, raw_key

        except IntegrityError as e:
            await self.db.rollback()
            logger.error(f"Database integrity error creating API key: {str(e)}")
            raise ValueError("Failed to create API key due to database constraint")
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error creating API key: {str(e)}")
            raise

    async def verify_api_key(self, raw_key: str, ip_address: Optional[str] = None) -> Optional[APIKey]:
        """
        Verify an API key and return the key object if valid.

        Args:
            raw_key: The raw API key string
            ip_address: Request IP address for validation

        Returns:
            APIKey object if valid, None otherwise
        """
        try:
            # Extract key prefix for faster lookup
            if not raw_key or len(raw_key) < 10:
                return None

            key_prefix = raw_key[:10]

            # Find API key by prefix
            query = select(APIKey).options(
                selectinload(APIKey.user)
            ).where(
                and_(
                    APIKey.key_prefix == key_prefix,
                    APIKey.is_active == True
                )
            )

            result = await self.db.execute(query)
            api_key = result.scalar_one_or_none()

            if not api_key:
                return None

            # Verify the key hash
            if not verify_password(raw_key, api_key.key_hash):
                return None

            # Check if key is valid
            if not api_key.is_valid():
                return None

            # Check IP restrictions
            if ip_address and not api_key.check_ip_allowed(ip_address):
                logger.warning(f"API key {api_key.id} rejected from IP {ip_address}")
                return None

            # Update usage statistics
            api_key.update_usage(ip_address or "unknown")
            await self.db.commit()

            return api_key

        except Exception as e:
            logger.error(f"Error verifying API key: {str(e)}")
            return None

    async def get_api_key_by_id(self, key_id: UUID) -> Optional[APIKey]:
        """Get API key by ID."""
        query = select(APIKey).options(
            selectinload(APIKey.user),
            selectinload(APIKey.organization)
        ).where(APIKey.id == key_id)

        result = await self.db.execute(query)
        return result.scalar_one_or_none()

    async def get_user_api_keys(
        self,
        user_id: UUID,
        include_inactive: bool = False
    ) -> List[APIKey]:
        """Get all API keys for a user."""
        query = select(APIKey).where(APIKey.user_id == user_id)

        if not include_inactive:
            query = query.where(APIKey.is_active == True)

        query = query.order_by(APIKey.created_at.desc())

        result = await self.db.execute(query)
        return result.scalars().all()

    async def get_organization_api_keys(
        self,
        organization_id: UUID,
        include_inactive: bool = False
    ) -> List[APIKey]:
        """Get all API keys for an organization."""
        query = select(APIKey).where(APIKey.organization_id == organization_id)

        if not include_inactive:
            query = query.where(APIKey.is_active == True)

        query = query.order_by(APIKey.created_at.desc())

        result = await self.db.execute(query)
        return result.scalars().all()

    async def update_api_key(
        self,
        key_id: UUID,
        name: Optional[str] = None,
        description: Optional[str] = None,
        rate_limit: Optional[int] = None,
        allowed_ips: Optional[List[str]] = None,
        is_active: Optional[bool] = None,
        current_user_id: Optional[UUID] = None
    ) -> APIKey:
        """
        Update API key information.

        Args:
            key_id: API key ID
            name: New name
            description: New description
            rate_limit: New rate limit
            allowed_ips: New IP restrictions
            is_active: Active status
            current_user_id: User performing the update

        Returns:
            Updated API key
        """
        api_key = await self.get_api_key_by_id(key_id)
        if not api_key:
            raise ValueError(f"API key with ID {key_id} not found")

        # Only owner can update
        if current_user_id and api_key.user_id != current_user_id:
            raise ValueError("Only the key owner can update it")

        # Update fields
        if name is not None:
            api_key.name = name
        if description is not None:
            api_key.description = description
        if rate_limit is not None:
            api_key.rate_limit = rate_limit
        if allowed_ips is not None:
            api_key.allowed_ips = allowed_ips
        if is_active is not None:
            api_key.is_active = is_active

        api_key.updated_at = datetime.utcnow()

        await self.db.commit()
        await self.db.refresh(api_key)

        # Audit log
        if current_user_id:
            await self.audit_service.log_action(
                user_id=current_user_id,
                action="api_key.update",
                resource_type="api_key",
                resource_id=str(key_id),
                details={"changes": {
                    "name": name,
                    "description": description,
                    "rate_limit": rate_limit,
                    "is_active": is_active
                }}
            )

        return api_key

    async def rotate_api_key(
        self,
        key_id: UUID,
        current_user_id: UUID
    ) -> tuple[APIKey, str]:
        """
        Rotate an API key (revoke old and create new).

        Args:
            key_id: API key ID to rotate
            current_user_id: User performing the rotation

        Returns:
            Tuple of (new APIKey object, raw API key string)
        """
        old_key = await self.get_api_key_by_id(key_id)
        if not old_key:
            raise ValueError(f"API key with ID {key_id} not found")

        # Only owner can rotate
        if old_key.user_id != current_user_id:
            raise ValueError("Only the key owner can rotate it")

        # Create new key with same settings
        new_key, raw_key = await self.create_api_key(
            user_id=old_key.user_id,
            name=f"{old_key.name} (rotated)",
            description=old_key.description,
            scopes=old_key.scopes,
            rate_limit=old_key.rate_limit,
            allowed_ips=old_key.allowed_ips,
            organization_id=old_key.organization_id
        )

        # Revoke old key
        old_key.revoke(f"Rotated to key {new_key.id}")

        await self.db.commit()

        # Audit log
        await self.audit_service.log_action(
            user_id=current_user_id,
            action="api_key.rotate",
            resource_type="api_key",
            resource_id=str(key_id),
            details={
                "old_key_id": str(key_id),
                "new_key_id": str(new_key.id)
            }
        )

        logger.info(f"Rotated API key {key_id} to {new_key.id}")

        return new_key, raw_key

    async def revoke_api_key(
        self,
        key_id: UUID,
        reason: str,
        current_user_id: UUID
    ) -> bool:
        """
        Revoke an API key.

        Args:
            key_id: API key ID
            reason: Revocation reason
            current_user_id: User performing the revocation

        Returns:
            Success status
        """
        api_key = await self.get_api_key_by_id(key_id)
        if not api_key:
            raise ValueError(f"API key with ID {key_id} not found")

        # Only owner can revoke
        if api_key.user_id != current_user_id:
            # Check if user is admin
            user_query = select(User).where(User.id == current_user_id)
            user_result = await self.db.execute(user_query)
            user = user_result.scalar_one_or_none()

            if not user or not user.is_superuser:
                raise ValueError("Only the key owner or admin can revoke it")

        api_key.revoke(reason)

        await self.db.commit()

        # Audit log
        await self.audit_service.log_action(
            user_id=current_user_id,
            action="api_key.revoke",
            resource_type="api_key",
            resource_id=str(key_id),
            details={"reason": reason}
        )

        logger.info(f"Revoked API key {key_id}: {reason}")
        return True

    async def delete_api_key(
        self,
        key_id: UUID,
        current_user_id: UUID
    ) -> bool:
        """
        Delete an API key.

        Args:
            key_id: API key ID
            current_user_id: User performing the deletion

        Returns:
            Success status
        """
        api_key = await self.get_api_key_by_id(key_id)
        if not api_key:
            raise ValueError(f"API key with ID {key_id} not found")

        # Only owner can delete
        if api_key.user_id != current_user_id:
            raise ValueError("Only the key owner can delete it")

        await self.db.delete(api_key)
        await self.db.commit()

        # Audit log
        await self.audit_service.log_action(
            user_id=current_user_id,
            action="api_key.delete",
            resource_type="api_key",
            resource_id=str(key_id),
            details={"key_name": api_key.name}
        )

        logger.info(f"Deleted API key {key_id}")
        return True

    async def cleanup_expired_keys(self) -> int:
        """
        Clean up expired API keys.

        Returns:
            Number of keys cleaned up
        """
        try:
            query = select(APIKey).where(
                and_(
                    APIKey.expires_at != None,
                    APIKey.expires_at < datetime.utcnow(),
                    APIKey.is_active == True
                )
            )

            result = await self.db.execute(query)
            expired_keys = result.scalars().all()

            count = 0
            for key in expired_keys:
                key.revoke("Expired")
                count += 1

            if count > 0:
                await self.db.commit()
                logger.info(f"Cleaned up {count} expired API keys")

            return count

        except Exception as e:
            logger.error(f"Error cleaning up expired keys: {str(e)}")
            await self.db.rollback()
            return 0

    async def get_api_key_statistics(
        self,
        user_id: Optional[UUID] = None,
        organization_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Get API key usage statistics.

        Args:
            user_id: Filter by user
            organization_id: Filter by organization

        Returns:
            Dictionary with statistics
        """
        query = select(APIKey)

        if user_id:
            query = query.where(APIKey.user_id == user_id)
        elif organization_id:
            query = query.where(APIKey.organization_id == organization_id)

        result = await self.db.execute(query)
        keys = result.scalars().all()

        total_usage = sum(k.usage_count for k in keys)
        active_keys = [k for k in keys if k.is_active]
        expired_keys = [k for k in keys if k.is_expired()]

        return {
            "total_keys": len(keys),
            "active_keys": len(active_keys),
            "expired_keys": len(expired_keys),
            "revoked_keys": len([k for k in keys if k.revoked_at]),
            "total_usage": total_usage,
            "average_usage": total_usage / len(keys) if keys else 0,
            "most_used_key": max(keys, key=lambda k: k.usage_count).name if keys else None,
            "last_created": max(keys, key=lambda k: k.created_at).created_at.isoformat() if keys else None
        }
