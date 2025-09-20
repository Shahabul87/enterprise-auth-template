"""
Device Fingerprinting Service

Implements device fingerprinting for enhanced security,
tracking device trust levels, and detecting suspicious activities.
"""

import hashlib
import json
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List
from uuid import uuid4

import structlog
from sqlalchemy import select, and_, or_, func
from sqlalchemy.ext.asyncio import AsyncSession
from user_agents import parse as parse_user_agent

from app.core.database import Base
from app.core.exceptions import SecurityError, ValidationError
from app.core.redis_client import get_redis_client
from app.models.user import User
from app.services.audit_service import AuditService

logger = structlog.get_logger(__name__)


class DeviceFingerprint:
    """Device fingerprint data structure"""

    def __init__(
        self,
        user_agent: str,
        ip_address: str,
        screen_resolution: Optional[str] = None,
        timezone: Optional[str] = None,
        language: Optional[str] = None,
        platform: Optional[str] = None,
        webgl_vendor: Optional[str] = None,
        webgl_renderer: Optional[str] = None,
        canvas_fingerprint: Optional[str] = None,
        audio_fingerprint: Optional[str] = None,
        fonts: Optional[List[str]] = None,
        plugins: Optional[List[str]] = None,
        hardware_concurrency: Optional[int] = None,
        device_memory: Optional[int] = None,
        touch_support: Optional[bool] = None,
        cookie_enabled: Optional[bool] = None,
        do_not_track: Optional[str] = None,
        ad_blocker: Optional[bool] = None,
    ):
        self.user_agent = user_agent
        self.ip_address = ip_address
        self.screen_resolution = screen_resolution
        self.timezone = timezone
        self.language = language
        self.platform = platform
        self.webgl_vendor = webgl_vendor
        self.webgl_renderer = webgl_renderer
        self.canvas_fingerprint = canvas_fingerprint
        self.audio_fingerprint = audio_fingerprint
        self.fonts = fonts or []
        self.plugins = plugins or []
        self.hardware_concurrency = hardware_concurrency
        self.device_memory = device_memory
        self.touch_support = touch_support
        self.cookie_enabled = cookie_enabled
        self.do_not_track = do_not_track
        self.ad_blocker = ad_blocker

        # Parse user agent
        self.parsed_ua = parse_user_agent(user_agent)

    def generate_hash(self) -> str:
        """Generate a unique hash for this fingerprint"""
        # Combine stable attributes for fingerprint
        stable_attributes = [
            self.user_agent,
            self.screen_resolution,
            self.timezone,
            self.language,
            self.platform,
            self.webgl_vendor,
            self.webgl_renderer,
            self.canvas_fingerprint,
            self.audio_fingerprint,
            str(self.hardware_concurrency),
            str(self.device_memory),
            str(self.touch_support),
            json.dumps(sorted(self.fonts)) if self.fonts else "",
            json.dumps(sorted(self.plugins)) if self.plugins else "",
        ]

        fingerprint_string = "|".join(str(attr) for attr in stable_attributes if attr)

        return hashlib.sha256(fingerprint_string.encode()).hexdigest()

    def get_device_type(self) -> str:
        """Determine device type from fingerprint"""
        if self.parsed_ua.is_mobile:
            return "mobile"
        elif self.parsed_ua.is_tablet:
            return "tablet"
        elif self.parsed_ua.is_pc:
            return "desktop"
        elif self.parsed_ua.is_bot:
            return "bot"
        else:
            return "unknown"

    def get_browser_info(self) -> Dict[str, str]:
        """Get browser information"""
        return {
            "browser": self.parsed_ua.browser.family,
            "browser_version": self.parsed_ua.browser.version_string,
            "os": self.parsed_ua.os.family,
            "os_version": self.parsed_ua.os.version_string,
            "device": self.parsed_ua.device.family,
        }

    def calculate_trust_score(self) -> float:
        """
        Calculate device trust score (0-100)
        Higher score = more trustworthy
        """
        score = 50.0  # Base score

        # Positive factors
        if self.canvas_fingerprint:
            score += 10
        if self.webgl_vendor and self.webgl_renderer:
            score += 10
        if self.audio_fingerprint:
            score += 5
        if self.fonts and len(self.fonts) > 10:
            score += 5
        if self.cookie_enabled:
            score += 5
        if not self.parsed_ua.is_bot:
            score += 10

        # Negative factors
        if self.ad_blocker:
            score -= 5  # Slight penalty for ad blockers
        if self.do_not_track == "1":
            score -= 5  # Slight penalty for DNT
        if self.parsed_ua.is_bot:
            score -= 30  # Major penalty for bots
        if not self.user_agent:
            score -= 20  # Missing user agent is suspicious

        # Normalize score
        return max(0, min(100, score))

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary"""
        return {
            "hash": self.generate_hash(),
            "user_agent": self.user_agent,
            "ip_address": self.ip_address,
            "screen_resolution": self.screen_resolution,
            "timezone": self.timezone,
            "language": self.language,
            "platform": self.platform,
            "device_type": self.get_device_type(),
            "browser_info": self.get_browser_info(),
            "trust_score": self.calculate_trust_score(),
            "timestamp": datetime.utcnow().isoformat(),
        }


class DeviceFingerprintService:
    """Service for managing device fingerprints and trust"""

    def __init__(self, db: AsyncSession):
        self.db = db
        self.redis_client = get_redis_client()
        self.audit_service = AuditService(db)

    async def record_device(
        self, user_id: str, fingerprint: DeviceFingerprint, action: str = "login"
    ) -> Dict[str, Any]:
        """
        Record device fingerprint for user

        Args:
            user_id: User ID
            fingerprint: Device fingerprint data
            action: Action being performed (login, register, etc.)

        Returns:
            Device trust information
        """
        device_hash = fingerprint.generate_hash()
        device_key = f"device:{user_id}:{device_hash}"

        # Get existing device info
        existing_device = await self.redis_client.get(device_key)

        if existing_device:
            device_info = json.loads(existing_device)
            device_info["last_seen"] = datetime.utcnow().isoformat()
            device_info["seen_count"] = device_info.get("seen_count", 0) + 1
        else:
            # New device
            device_info = fingerprint.to_dict()
            device_info["first_seen"] = datetime.utcnow().isoformat()
            device_info["last_seen"] = datetime.utcnow().isoformat()
            device_info["seen_count"] = 1
            device_info["is_trusted"] = False
            device_info["user_id"] = user_id

            # Check for suspicious patterns
            await self._check_suspicious_patterns(user_id, fingerprint)

        # Update trust level
        device_info["is_trusted"] = await self._evaluate_trust(
            user_id, device_hash, device_info
        )

        # Store device info (expire in 90 days)
        await self.redis_client.setex(
            device_key, 7776000, json.dumps(device_info)  # 90 days
        )

        # Log device activity
        await self._log_device_activity(user_id, device_hash, action, device_info)

        return {
            "device_id": device_hash,
            "is_trusted": device_info["is_trusted"],
            "is_new": device_info["seen_count"] == 1,
            "trust_score": fingerprint.calculate_trust_score(),
            "requires_verification": self._requires_additional_verification(
                device_info
            ),
        }

    async def verify_device(
        self, user_id: str, device_hash: str, verification_method: str = "email"
    ) -> bool:
        """
        Mark device as verified/trusted

        Args:
            user_id: User ID
            device_hash: Device hash
            verification_method: Method used for verification

        Returns:
            Success status
        """
        device_key = f"device:{user_id}:{device_hash}"
        device_data = await self.redis_client.get(device_key)

        if not device_data:
            raise ValidationError("Device not found")

        device_info = json.loads(device_data)
        device_info["is_trusted"] = True
        device_info["verified_at"] = datetime.utcnow().isoformat()
        device_info["verification_method"] = verification_method

        await self.redis_client.setex(
            device_key, 7776000, json.dumps(device_info)  # 90 days
        )

        # Log verification
        await self.audit_service.log_event(
            event_type="device.verified",
            user_id=user_id,
            details={"device_id": device_hash, "method": verification_method},
        )

        return True

    async def get_user_devices(
        self, user_id: str, include_expired: bool = False
    ) -> List[Dict[str, Any]]:
        """
        Get all devices for a user

        Args:
            user_id: User ID
            include_expired: Include expired devices

        Returns:
            List of device information
        """
        pattern = f"device:{user_id}:*"
        device_keys = await self.redis_client.keys(pattern)

        devices = []
        for key in device_keys:
            device_data = await self.redis_client.get(key)
            if device_data:
                device_info = json.loads(device_data)
                devices.append(device_info)

        # Sort by last seen
        devices.sort(key=lambda x: x.get("last_seen", ""), reverse=True)

        return devices

    async def revoke_device(
        self, user_id: str, device_hash: str, reason: str = "user_initiated"
    ) -> bool:
        """
        Revoke/untrust a device

        Args:
            user_id: User ID
            device_hash: Device hash to revoke
            reason: Reason for revocation

        Returns:
            Success status
        """
        device_key = f"device:{user_id}:{device_hash}"

        # Delete device from Redis
        deleted = await self.redis_client.delete(device_key)

        if deleted:
            # Log revocation
            await self.audit_service.log_event(
                event_type="device.revoked",
                user_id=user_id,
                details={"device_id": device_hash, "reason": reason},
            )

            return True

        return False

    async def detect_anomalies(
        self, user_id: str, fingerprint: DeviceFingerprint
    ) -> Dict[str, Any]:
        """
        Detect anomalies in device usage

        Args:
            user_id: User ID
            fingerprint: Current device fingerprint

        Returns:
            Anomaly detection results
        """
        anomalies = []
        risk_level = "low"

        # Check for impossible travel
        travel_anomaly = await self._check_impossible_travel(
            user_id, fingerprint.ip_address
        )
        if travel_anomaly:
            anomalies.append(travel_anomaly)
            risk_level = "high"

        # Check for device proliferation
        device_count = len(await self.get_user_devices(user_id))
        if device_count > 10:
            anomalies.append(
                {
                    "type": "device_proliferation",
                    "message": f"User has {device_count} devices",
                    "severity": "medium",
                }
            )
            if risk_level == "low":
                risk_level = "medium"

        # Check for bot patterns
        if fingerprint.parsed_ua.is_bot:
            anomalies.append(
                {
                    "type": "bot_detected",
                    "message": "Bot user agent detected",
                    "severity": "high",
                }
            )
            risk_level = "high"

        # Check for suspicious fingerprint
        trust_score = fingerprint.calculate_trust_score()
        if trust_score < 30:
            anomalies.append(
                {
                    "type": "low_trust_score",
                    "message": f"Device trust score is {trust_score}",
                    "severity": "medium",
                }
            )
            if risk_level == "low":
                risk_level = "medium"

        return {
            "anomalies": anomalies,
            "risk_level": risk_level,
            "requires_mfa": risk_level in ["medium", "high"],
            "block_access": risk_level == "high" and len(anomalies) > 2,
        }

    async def _evaluate_trust(
        self, user_id: str, device_hash: str, device_info: Dict[str, Any]
    ) -> bool:
        """Evaluate if device should be trusted"""
        # Already verified
        if device_info.get("verified_at"):
            return True

        # Seen multiple times over time
        if device_info.get("seen_count", 0) >= 5:
            first_seen = datetime.fromisoformat(
                device_info.get("first_seen", datetime.utcnow().isoformat())
            )
            if (datetime.utcnow() - first_seen).days >= 7:
                return True

        # High trust score and seen before
        if (
            device_info.get("trust_score", 0) >= 70
            and device_info.get("seen_count", 0) >= 3
        ):
            return True

        return False

    def _requires_additional_verification(self, device_info: Dict[str, Any]) -> bool:
        """Check if additional verification is required"""
        # New device
        if device_info.get("seen_count", 0) == 1:
            return True

        # Low trust score
        if device_info.get("trust_score", 0) < 40:
            return True

        # Not trusted
        if not device_info.get("is_trusted", False):
            return True

        return False

    async def _check_suspicious_patterns(
        self, user_id: str, fingerprint: DeviceFingerprint
    ) -> None:
        """Check for suspicious device patterns"""
        # Get recent devices
        devices = await self.get_user_devices(user_id)

        # Check for rapid device switching
        recent_devices = [
            d
            for d in devices
            if (datetime.utcnow() - datetime.fromisoformat(d["last_seen"])).hours < 1
        ]

        if len(recent_devices) > 3:
            await self.audit_service.log_event(
                event_type="security.rapid_device_switching",
                user_id=user_id,
                details={
                    "device_count": len(recent_devices),
                    "new_device": fingerprint.generate_hash(),
                },
            )

    async def _check_impossible_travel(
        self, user_id: str, current_ip: str
    ) -> Optional[Dict[str, Any]]:
        """Check for impossible travel based on IP geolocation"""
        # This would integrate with a geolocation service
        # For now, return None (no anomaly detected)
        # In production, use services like MaxMind or IP2Location
        return None

    async def _log_device_activity(
        self, user_id: str, device_hash: str, action: str, device_info: Dict[str, Any]
    ) -> None:
        """Log device activity"""
        await self.audit_service.log_event(
            event_type=f"device.{action}",
            user_id=user_id,
            details={
                "device_id": device_hash,
                "device_type": device_info.get("device_type"),
                "browser": device_info.get("browser_info", {}).get("browser"),
                "os": device_info.get("browser_info", {}).get("os"),
                "trust_score": device_info.get("trust_score"),
                "is_trusted": device_info.get("is_trusted"),
            },
        )
