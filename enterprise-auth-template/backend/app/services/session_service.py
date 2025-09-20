"""
Enhanced Session Management Service

Provides comprehensive session management with concurrent session limits,
device fingerprinting, and security monitoring.
"""

import hashlib
import json
from datetime import datetime, timedelta, timezone
from typing import Dict, List, Optional, Tuple
from uuid import uuid4

import structlog
from sqlalchemy import and_, delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

# Simple user agent parsing - replace with user_agents library if needed
import re

from app.core.config import get_settings
from app.models.session import UserSession
from app.models.user import User
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class SessionConfig:
    """Session management configuration."""

    # Session limits
    MAX_CONCURRENT_SESSIONS = 5  # Maximum active sessions per user
    MAX_CONCURRENT_DEVICES = 3  # Maximum different devices
    SESSION_TIMEOUT_MINUTES = 1440  # 24 hours default
    IDLE_TIMEOUT_MINUTES = 60  # 1 hour of inactivity

    # Security settings
    SUSPICIOUS_LOGIN_THRESHOLD = 3  # Failed logins before flagging
    GEO_ANOMALY_DISTANCE_KM = 500  # Distance that triggers anomaly
    DEVICE_TRUST_PERIOD_DAYS = 30  # Days before device needs re-verification

    # Fingerprinting weights
    FINGERPRINT_WEIGHTS = {
        "user_agent": 0.3,
        "accept_language": 0.2,
        "accept_encoding": 0.1,
        "screen_resolution": 0.2,
        "timezone": 0.1,
        "plugins": 0.1,
    }


class DeviceFingerprint:
    """Device fingerprinting utilities."""

    @staticmethod
    def generate_fingerprint(
        user_agent: str,
        accept_language: Optional[str] = None,
        accept_encoding: Optional[str] = None,
        screen_resolution: Optional[str] = None,
        timezone: Optional[str] = None,
        plugins: Optional[List[str]] = None,
    ) -> str:
        """
        Generate a device fingerprint from browser characteristics.

        Args:
            user_agent: User agent string
            accept_language: Accept-Language header
            accept_encoding: Accept-Encoding header
            screen_resolution: Screen resolution (from JavaScript)
            timezone: Browser timezone
            plugins: List of browser plugins

        Returns:
            Device fingerprint hash
        """
        fingerprint_data = {
            "user_agent": user_agent or "",
            "accept_language": accept_language or "",
            "accept_encoding": accept_encoding or "",
            "screen_resolution": screen_resolution or "",
            "timezone": timezone or "",
            "plugins": ",".join(plugins) if plugins else "",
        }

        # Create weighted fingerprint
        fingerprint_str = "|".join(
            f"{k}:{v}" for k, v in sorted(fingerprint_data.items())
        )

        return hashlib.sha256(fingerprint_str.encode()).hexdigest()

    @staticmethod
    def parse_user_agent(user_agent: str) -> Dict[str, str]:
        """
        Parse user agent string for device information.
        Simple implementation - can be enhanced with user_agents library.

        Args:
            user_agent: User agent string

        Returns:
            Parsed device information
        """
        if not user_agent:
            return {
                "browser": "Unknown",
                "operating_system": "Unknown",
                "device_type": "desktop",
                "device_family": "Unknown",
            }

        # Simple regex-based parsing
        browser = "Unknown"
        os = "Unknown"
        device_type = "desktop"

        # Detect browser
        if "Chrome" in user_agent:
            browser = "Chrome"
        elif "Firefox" in user_agent:
            browser = "Firefox"
        elif "Safari" in user_agent and "Chrome" not in user_agent:
            browser = "Safari"
        elif "Edge" in user_agent:
            browser = "Edge"

        # Detect OS
        if "Windows" in user_agent:
            os = "Windows"
        elif "Mac OS" in user_agent or "macOS" in user_agent:
            os = "macOS"
        elif "Linux" in user_agent:
            os = "Linux"
        elif "Android" in user_agent:
            os = "Android"
            device_type = "mobile"
        elif "iOS" in user_agent or "iPhone" in user_agent or "iPad" in user_agent:
            os = "iOS"
            device_type = "mobile" if "iPhone" in user_agent else "tablet"

        # Mobile detection
        if any(
            mobile_indicator in user_agent.lower()
            for mobile_indicator in [
                "mobile",
                "android",
                "iphone",
                "blackberry",
                "windows phone",
            ]
        ):
            device_type = "mobile"
        elif "tablet" in user_agent.lower() or "ipad" in user_agent.lower():
            device_type = "tablet"

        return {
            "browser": browser,
            "operating_system": os,
            "device_type": device_type,
            "device_family": device_type.title(),
        }


class SessionService:
    """
    Enhanced session management service.

    Features:
    - Concurrent session limits
    - Device fingerprinting and tracking
    - Suspicious activity detection
    - Geographic anomaly detection
    - Automatic session cleanup
    """

    def __init__(
        self,
        session: AsyncSession,
        cache_service: Optional[CacheService] = None,
    ):
        """
        Initialize session service.

        Args:
            session: Database session
            cache_service: Optional cache service for performance
        """
        self.session = session
        self.cache = cache_service or CacheService()

    async def create_session(
        self,
        user_id: str,
        ip_address: str,
        user_agent: str,
        device_fingerprint: Optional[str] = None,
        location_data: Optional[Dict] = None,
    ) -> Tuple[UserSession, bool]:
        """
        Create a new user session with security checks.

        Args:
            user_id: User ID
            ip_address: Client IP address
            user_agent: User agent string
            device_fingerprint: Device fingerprint
            location_data: Geographic location data

        Returns:
            Tuple of (created session, is_suspicious)
        """
        is_suspicious = False

        try:
            # Check concurrent session limits
            await self._enforce_session_limits(user_id)

            # Parse user agent
            device_info = DeviceFingerprint.parse_user_agent(user_agent)

            # Generate device fingerprint if not provided
            if not device_fingerprint:
                device_fingerprint = DeviceFingerprint.generate_fingerprint(user_agent)

            # Check for suspicious activity
            is_suspicious = await self._check_suspicious_activity(
                user_id,
                ip_address,
                device_fingerprint,
                location_data,
            )

            # Create session
            session_id = str(uuid4())
            expires_at = datetime.now(timezone.utc) + timedelta(
                minutes=SessionConfig.SESSION_TIMEOUT_MINUTES
            )

            user_session = UserSession(
                session_id=session_id,
                user_id=user_id,
                ip_address=ip_address,
                user_agent=user_agent,
                device_type=device_info.get("device_type"),
                browser=device_info.get("browser"),
                operating_system=device_info.get("operating_system"),
                country=location_data.get("country") if location_data else None,
                city=location_data.get("city") if location_data else None,
                expires_at=expires_at,
                session_metadata={
                    "device_fingerprint": device_fingerprint,
                    "device_family": device_info.get("device_family"),
                    "is_suspicious": is_suspicious,
                    "location": location_data,
                },
            )

            self.session.add(user_session)
            await self.session.commit()

            # Cache session for fast lookups
            await self._cache_session(user_session)

            # Log session creation
            logger.info(
                "Session created",
                user_id=user_id,
                session_id=session_id,
                device_type=device_info.get("device_type"),
                is_suspicious=is_suspicious,
            )

            # Alert if suspicious
            if is_suspicious:
                await self._handle_suspicious_session(user_session)

            return user_session, is_suspicious

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to create session",
                user_id=user_id,
                error=str(e),
            )
            raise

    async def validate_session(
        self,
        session_id: str,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
    ) -> Tuple[Optional[UserSession], bool]:
        """
        Validate a session and check for anomalies.

        Args:
            session_id: Session ID
            ip_address: Current IP address
            user_agent: Current user agent

        Returns:
            Tuple of (session if valid, is_anomaly_detected)
        """
        try:
            # Try cache first
            cached_session = await self._get_cached_session(session_id)
            if cached_session:
                user_session = cached_session
            else:
                # Query database
                stmt = select(UserSession).where(UserSession.session_id == session_id)
                result = await self.session.execute(stmt)
                user_session: Optional[UserSession] = result.scalar_one_or_none()

            if not user_session:
                return None, False

            # Check if session is valid
            if not user_session.is_valid:
                await self.invalidate_session(session_id)
                return None, False

            # Check for idle timeout
            idle_time = datetime.now(timezone.utc) - user_session.last_activity
            if idle_time > timedelta(minutes=SessionConfig.IDLE_TIMEOUT_MINUTES):
                logger.info(
                    "Session expired due to inactivity",
                    session_id=session_id,
                    idle_minutes=idle_time.total_seconds() / 60,
                )
                await self.invalidate_session(session_id)
                return None, False

            # Check for anomalies
            is_anomaly = False
            if ip_address and ip_address != user_session.ip_address:
                is_anomaly = True
                logger.warning(
                    "IP address change detected",
                    session_id=session_id,
                    original_ip=user_session.ip_address,
                    current_ip=ip_address,
                )

            if user_agent and user_agent != user_session.user_agent:
                # Parse and compare user agents
                original_device = DeviceFingerprint.parse_user_agent(
                    user_session.user_agent or ""
                )
                current_device = DeviceFingerprint.parse_user_agent(user_agent or "")

                # Major change detection
                if (
                    original_device["device_type"] != current_device["device_type"]
                    or original_device["operating_system"].split()[0]
                    != current_device["operating_system"].split()[0]
                ):
                    is_anomaly = True
                    logger.warning(
                        "Device change detected",
                        session_id=session_id,
                        original_device=original_device,
                        current_device=current_device,
                    )

            # Update activity if no major anomaly
            if not is_anomaly:
                await self._update_session_activity(session_id)

            return user_session, is_anomaly

        except Exception as e:
            logger.error(
                "Session validation failed",
                session_id=session_id,
                error=str(e),
            )
            return None, False

    async def invalidate_session(
        self,
        session_id: str,
        reason: Optional[str] = None,
    ) -> bool:
        """
        Invalidate a session.

        Args:
            session_id: Session ID to invalidate
            reason: Reason for invalidation

        Returns:
            Success status
        """
        try:
            stmt = (
                update(UserSession)
                .where(UserSession.session_id == session_id)
                .values(
                    is_active=False,
                    ended_at=datetime.now(timezone.utc),
                )
            )

            result = await self.session.execute(stmt)
            await self.session.commit()

            # Remove from cache
            await self._remove_cached_session(session_id)

            logger.info(
                "Session invalidated",
                session_id=session_id,
                reason=reason,
            )

            return result.rowcount > 0

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to invalidate session",
                session_id=session_id,
                error=str(e),
            )
            return False

    async def invalidate_user_sessions(
        self,
        user_id: str,
        except_session: Optional[str] = None,
        reason: Optional[str] = None,
    ) -> int:
        """
        Invalidate all sessions for a user.

        Args:
            user_id: User ID
            except_session: Session ID to keep active
            reason: Reason for invalidation

        Returns:
            Number of sessions invalidated
        """
        try:
            conditions = [
                UserSession.user_id == user_id,
                UserSession.is_active == True,
            ]

            if except_session:
                conditions.append(UserSession.session_id != except_session)

            stmt = (
                update(UserSession)
                .where(and_(*conditions))
                .values(
                    is_active=False,
                    ended_at=datetime.now(timezone.utc),
                )
            )

            result = await self.session.execute(stmt)
            await self.session.commit()

            count = result.rowcount

            logger.info(
                "User sessions invalidated",
                user_id=user_id,
                count=count,
                reason=reason,
            )

            return count

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to invalidate user sessions",
                user_id=user_id,
                error=str(e),
            )
            return 0

    async def get_active_sessions(self, user_id: str) -> List[UserSession]:
        """
        Get all active sessions for a user.

        Args:
            user_id: User ID

        Returns:
            List of active sessions
        """
        try:
            stmt = (
                select(UserSession)
                .where(
                    and_(
                        UserSession.user_id == user_id,
                        UserSession.is_active == True,
                        UserSession.expires_at > datetime.now(timezone.utc),
                    )
                )
                .order_by(UserSession.created_at.desc())
            )

            result = await self.session.execute(stmt)
            return list(result.scalars().all())

        except Exception as e:
            logger.error(
                "Failed to get active sessions",
                user_id=user_id,
                error=str(e),
            )
            return []

    async def _enforce_session_limits(self, user_id: str) -> None:
        """
        Enforce concurrent session limits.

        Args:
            user_id: User ID
        """
        active_sessions = await self.get_active_sessions(user_id)

        if len(active_sessions) >= SessionConfig.MAX_CONCURRENT_SESSIONS:
            # Remove oldest sessions
            sessions_to_remove = active_sessions[
                SessionConfig.MAX_CONCURRENT_SESSIONS - 1 :
            ]

            for session in sessions_to_remove:
                await self.invalidate_session(
                    session.session_id,
                    reason="concurrent_session_limit",
                )

            logger.info(
                "Concurrent session limit enforced",
                user_id=user_id,
                removed_count=len(sessions_to_remove),
            )

    async def _check_suspicious_activity(
        self,
        user_id: str,
        ip_address: str,
        device_fingerprint: str,
        location_data: Optional[Dict],
    ) -> bool:
        """
        Check for suspicious login activity.

        Args:
            user_id: User ID
            ip_address: IP address
            device_fingerprint: Device fingerprint
            location_data: Location data

        Returns:
            True if suspicious activity detected
        """
        is_suspicious = False

        try:
            # Get recent sessions
            stmt = (
                select(UserSession)
                .where(
                    and_(
                        UserSession.user_id == user_id,
                        UserSession.created_at
                        > datetime.now(timezone.utc) - timedelta(hours=24),
                    )
                )
                .order_by(UserSession.created_at.desc())
                .limit(10)
            )

            result = await self.session.execute(stmt)
            recent_sessions = list(result.scalars().all())

            if recent_sessions:
                # Check for rapid session creation
                if len(recent_sessions) >= SessionConfig.SUSPICIOUS_LOGIN_THRESHOLD:
                    time_diff = (
                        datetime.now(timezone.utc) - recent_sessions[-1].created_at
                    )
                    if time_diff < timedelta(minutes=10):
                        is_suspicious = True
                        logger.warning(
                            "Rapid session creation detected",
                            user_id=user_id,
                            session_count=len(recent_sessions),
                            time_window_minutes=time_diff.total_seconds() / 60,
                        )

                # Check for new device
                known_fingerprints = set()
                for session in recent_sessions:
                    if session.session_metadata:
                        fp = session.session_metadata.get("device_fingerprint")
                        if fp:
                            known_fingerprints.add(fp)

                if (
                    device_fingerprint not in known_fingerprints
                    and len(known_fingerprints) > 0
                ):
                    logger.info(
                        "New device detected",
                        user_id=user_id,
                        device_fingerprint=device_fingerprint[:8],
                    )

                # Check for geographic anomaly
                if location_data and recent_sessions[0].country:
                    if location_data.get("country") != recent_sessions[0].country:
                        is_suspicious = True
                        logger.warning(
                            "Geographic anomaly detected",
                            user_id=user_id,
                            previous_country=recent_sessions[0].country,
                            current_country=location_data.get("country"),
                        )

        except Exception as e:
            logger.error(
                "Suspicious activity check failed",
                user_id=user_id,
                error=str(e),
            )

        return is_suspicious

    async def _handle_suspicious_session(self, session: UserSession) -> None:
        """
        Handle a suspicious session.

        Args:
            session: Suspicious session
        """
        try:
            # Update session metadata
            if not session.session_metadata:
                session.session_metadata = {}

            session.session_metadata["security_alerts"] = session.session_metadata.get(
                "security_alerts", []
            )
            session.session_metadata["security_alerts"].append(
                {
                    "type": "suspicious_login",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "ip_address": session.ip_address,
                }
            )

            await self.session.commit()

            # Could trigger additional security measures:
            # - Send email notification
            # - Require 2FA
            # - Log to security monitoring system

            logger.warning(
                "Suspicious session flagged",
                session_id=session.session_id,
                user_id=session.user_id,
                ip_address=session.ip_address,
            )

        except Exception as e:
            logger.error(
                "Failed to handle suspicious session",
                session_id=session.session_id,
                error=str(e),
            )

    async def _update_session_activity(self, session_id: str) -> None:
        """Update session last activity timestamp."""
        try:
            stmt = (
                update(UserSession)
                .where(UserSession.session_id == session_id)
                .values(last_activity=datetime.now(timezone.utc))
            )

            await self.session.execute(stmt)
            await self.session.commit()

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to update session activity",
                session_id=session_id,
                error=str(e),
            )

    async def _cache_session(self, session: UserSession) -> None:
        """Cache session for fast lookups."""
        if self.cache:
            cache_key = f"session:{session.session_id}"
            cache_data = {
                "user_id": str(session.user_id),
                "is_active": session.is_active,
                "expires_at": session.expires_at.isoformat(),
                "ip_address": session.ip_address,
                "last_activity": session.last_activity.isoformat(),
            }

            ttl = int((session.expires_at - datetime.now(timezone.utc)).total_seconds())

            await self.cache.set(cache_key, cache_data, ttl=ttl)

    async def _get_cached_session(self, session_id: str) -> Optional[UserSession]:
        """Get session from cache."""
        if not self.cache:
            return None

        cache_key = f"session:{session_id}"
        cached_data = await self.cache.get(cache_key)

        if cached_data:
            # Convert cache data back to session object
            # This is a simplified version - in production, you'd want
            # to properly reconstruct the full object
            return None  # For now, return None to use database

        return None

    async def _remove_cached_session(self, session_id: str) -> None:
        """Remove session from cache."""
        if self.cache:
            cache_key = f"session:{session_id}"
            await self.cache.delete(cache_key)

    async def cleanup_expired_sessions(self) -> int:
        """
        Clean up expired sessions.

        Returns:
            Number of sessions cleaned up
        """
        try:
            stmt = delete(UserSession).where(
                UserSession.expires_at < datetime.now(timezone.utc)
            )

            result = await self.session.execute(stmt)
            await self.session.commit()

            count = result.rowcount

            if count > 0:
                logger.info(
                    "Expired sessions cleaned up",
                    count=count,
                )

            return count

        except Exception as e:
            await self.session.rollback()
            logger.error(
                "Failed to cleanup expired sessions",
                error=str(e),
            )
            return 0
