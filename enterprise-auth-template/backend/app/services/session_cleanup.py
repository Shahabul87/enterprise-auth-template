"""
Session Cleanup Service

Provides background job functionality for cleaning up expired sessions,
managing device limits, and tracking session analytics.
"""

import asyncio
from datetime import datetime, timedelta
from typing import List, Dict, Any, Optional
import structlog
from sqlalchemy import select, delete, and_, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.models.session import UserSession
from app.core.database import get_db

settings = get_settings()
logger = structlog.get_logger(__name__)


class SessionCleanupService:
    """Service for managing session cleanup and maintenance."""

    def __init__(
        self,
        cleanup_interval: int = 3600,  # 1 hour
        session_timeout: int = 86400,  # 24 hours
        max_sessions_per_user: int = 5,
        analytics_retention_days: int = 90,
    ):
        """
        Initialize session cleanup service.

        Args:
            cleanup_interval: Interval between cleanup runs in seconds
            session_timeout: Session timeout in seconds
            max_sessions_per_user: Maximum concurrent sessions per user
            analytics_retention_days: Days to retain session analytics
        """
        self.cleanup_interval = cleanup_interval
        self.session_timeout = session_timeout
        self.max_sessions_per_user = max_sessions_per_user
        self.analytics_retention_days = analytics_retention_days
        self.is_running = False
        self._cleanup_task: Optional[asyncio.Task] = None

    async def start(self) -> None:
        """Start the session cleanup background job."""
        if self.is_running:
            logger.warning("Session cleanup service already running")
            return

        self.is_running = True
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        logger.info(
            "Session cleanup service started",
            interval=self.cleanup_interval,
            timeout=self.session_timeout,
        )

    async def stop(self) -> None:
        """Stop the session cleanup background job."""
        if not self.is_running:
            return

        self.is_running = False

        if self._cleanup_task:
            self._cleanup_task.cancel()
            try:
                await self._cleanup_task
            except asyncio.CancelledError:
                pass

        logger.info("Session cleanup service stopped")

    async def _cleanup_loop(self) -> None:
        """Main cleanup loop that runs periodically."""
        while self.is_running:
            try:
                await self.cleanup_sessions()
                await asyncio.sleep(self.cleanup_interval)
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(
                    "Error in session cleanup loop",
                    error=str(e),
                )
                await asyncio.sleep(60)  # Wait a minute before retrying

    async def cleanup_sessions(self) -> Dict[str, Any]:
        """
        Perform session cleanup tasks.

        Returns:
            Dict with cleanup statistics
        """
        async for db in get_db():
            try:
                stats = {
                    "expired_sessions_removed": 0,
                    "excess_sessions_removed": 0,
                    "orphaned_sessions_removed": 0,
                    "analytics_records_archived": 0,
                    "timestamp": datetime.utcnow(),
                }

                # Remove expired sessions
                expired_count = await self._remove_expired_sessions(db)
                stats["expired_sessions_removed"] = expired_count

                # Enforce session limits per user
                excess_count = await self._enforce_session_limits(db)
                stats["excess_sessions_removed"] = excess_count

                # Remove orphaned sessions (no associated user)
                orphaned_count = await self._remove_orphaned_sessions(db)
                stats["orphaned_sessions_removed"] = orphaned_count

                # Archive old analytics data
                archived_count = await self._archive_old_analytics(db)
                stats["analytics_records_archived"] = archived_count

                await db.commit()

                logger.info(
                    "Session cleanup completed",
                    **stats,
                )

                return stats

            except Exception as e:
                await db.rollback()
                logger.error(
                    "Error during session cleanup",
                    error=str(e),
                )
                raise

    async def _remove_expired_sessions(self, db: AsyncSession) -> int:
        """
        Remove expired sessions from the database.

        Args:
            db: Database session

        Returns:
            Number of sessions removed
        """
        try:
            cutoff_time = datetime.utcnow() - timedelta(seconds=self.session_timeout)

            # Find expired sessions
            result = await db.execute(
                select(UserSession).where(
                    UserSession.last_activity < cutoff_time
                )
            )
            expired_sessions = result.scalars().all()

            # Remove expired sessions
            for session in expired_sessions:
                await db.delete(session)

            return len(expired_sessions)

        except Exception as e:
            logger.error(
                "Error removing expired sessions",
                error=str(e),
            )
            return 0

    async def _enforce_session_limits(self, db: AsyncSession) -> int:
        """
        Enforce maximum session limits per user.

        Args:
            db: Database session

        Returns:
            Number of excess sessions removed
        """
        try:
            # Find users with too many sessions
            result = await db.execute(
                select(
                    UserSession.user_id,
                    func.count(UserSession.id).label("session_count"),
                )
                .group_by(UserSession.user_id)
                .having(func.count(UserSession.id) > self.max_sessions_per_user)
            )

            users_with_excess = result.all()
            total_removed = 0

            for user_id, session_count in users_with_excess:
                # Get all sessions for this user, ordered by last activity
                result = await db.execute(
                    select(UserSession)
                    .where(UserSession.user_id == user_id)
                    .order_by(UserSession.last_activity.desc())
                )
                user_sessions = result.scalars().all()

                # Keep only the most recent sessions
                sessions_to_remove = user_sessions[self.max_sessions_per_user:]

                for session in sessions_to_remove:
                    await db.delete(session)
                    total_removed += 1

                if sessions_to_remove:
                    logger.info(
                        "Removed excess sessions for user",
                        user_id=user_id,
                        removed_count=len(sessions_to_remove),
                        kept_count=self.max_sessions_per_user,
                    )

            return total_removed

        except Exception as e:
            logger.error(
                "Error enforcing session limits",
                error=str(e),
            )
            return 0

    async def _remove_orphaned_sessions(self, db: AsyncSession) -> int:
        """
        Remove sessions with no associated user.

        Args:
            db: Database session

        Returns:
            Number of orphaned sessions removed
        """
        try:
            # Find sessions where user_id doesn't exist in users table
            result = await db.execute(
                select(UserSession)
                .outerjoin(UserSession.user)
                .where(UserSession.user == None)
            )

            orphaned_sessions = result.scalars().all()

            for session in orphaned_sessions:
                await db.delete(session)

            if orphaned_sessions:
                logger.info(
                    "Removed orphaned sessions",
                    count=len(orphaned_sessions),
                )

            return len(orphaned_sessions)

        except Exception as e:
            logger.error(
                "Error removing orphaned sessions",
                error=str(e),
            )
            return 0

    async def _archive_old_analytics(self, db: AsyncSession) -> int:
        """
        Archive old session analytics data.

        Args:
            db: Database session

        Returns:
            Number of records archived
        """
        try:
            # This would typically move old data to an archive table
            # For now, we'll just count old records
            cutoff_date = datetime.utcnow() - timedelta(days=self.analytics_retention_days)

            result = await db.execute(
                select(func.count(UserSession.id))
                .where(UserSession.created_at < cutoff_date)
            )

            old_record_count = result.scalar() or 0

            # In a real implementation, you would:
            # 1. Move these records to an archive table
            # 2. Generate aggregated analytics
            # 3. Delete the original records

            return old_record_count

        except Exception as e:
            logger.error(
                "Error archiving analytics",
                error=str(e),
            )
            return 0

    async def get_session_analytics(self, user_id: Optional[int] = None) -> Dict[str, Any]:
        """
        Get session analytics.

        Args:
            user_id: Optional user ID to filter by

        Returns:
            Analytics data
        """
        async for db in get_db():
            try:
                analytics = {
                    "total_sessions": 0,
                    "active_sessions": 0,
                    "expired_sessions": 0,
                    "sessions_by_device": {},
                    "sessions_by_location": {},
                    "average_session_duration": 0,
                    "timestamp": datetime.utcnow(),
                }

                # Base query
                query = select(UserSession)
                if user_id:
                    query = query.where(UserSession.user_id == user_id)

                result = await db.execute(query)
                sessions = result.scalars().all()

                analytics["total_sessions"] = len(sessions)

                # Calculate analytics
                cutoff_time = datetime.utcnow() - timedelta(seconds=self.session_timeout)
                active_sessions = []
                expired_sessions = []

                for session in sessions:
                    if session.last_activity >= cutoff_time:
                        active_sessions.append(session)
                    else:
                        expired_sessions.append(session)

                    # Count by device
                    device = session.user_agent or "Unknown"
                    analytics["sessions_by_device"][device] = (
                        analytics["sessions_by_device"].get(device, 0) + 1
                    )

                    # Count by location (if available)
                    location = session.ip_address or "Unknown"
                    analytics["sessions_by_location"][location] = (
                        analytics["sessions_by_location"].get(location, 0) + 1
                    )

                analytics["active_sessions"] = len(active_sessions)
                analytics["expired_sessions"] = len(expired_sessions)

                # Calculate average session duration
                if sessions:
                    total_duration = sum(
                        (s.last_activity - s.created_at).total_seconds()
                        for s in sessions
                    )
                    analytics["average_session_duration"] = total_duration / len(sessions)

                return analytics

            except Exception as e:
                logger.error(
                    "Error getting session analytics",
                    error=str(e),
                    user_id=user_id,
                )
                return {}

    async def force_logout_user(self, user_id: int, except_session: Optional[str] = None) -> int:
        """
        Force logout a user from all sessions.

        Args:
            user_id: User ID to logout
            except_session: Optional session token to keep active

        Returns:
            Number of sessions terminated
        """
        async for db in get_db():
            try:
                # Build query
                query = delete(UserSession).where(UserSession.user_id == user_id)

                if except_session:
                    query = query.where(UserSession.session_token != except_session)

                result = await db.execute(query)
                await db.commit()

                terminated_count = result.rowcount

                logger.info(
                    "Force logout completed",
                    user_id=user_id,
                    sessions_terminated=terminated_count,
                    kept_session=except_session,
                )

                return terminated_count

            except Exception as e:
                await db.rollback()
                logger.error(
                    "Error during force logout",
                    error=str(e),
                    user_id=user_id,
                )
                return 0

    async def terminate_session(self, session_token: str) -> bool:
        """
        Terminate a specific session.

        Args:
            session_token: Session token to terminate

        Returns:
            True if session was terminated
        """
        async for db in get_db():
            try:
                result = await db.execute(
                    delete(UserSession).where(UserSession.session_token == session_token)
                )
                await db.commit()

                if result.rowcount > 0:
                    logger.info(
                        "Session terminated",
                        session_token=session_token[:8] + "...",
                    )
                    return True

                return False

            except Exception as e:
                await db.rollback()
                logger.error(
                    "Error terminating session",
                    error=str(e),
                    session_token=session_token[:8] + "...",
                )
                return False


# Global instance
session_cleanup_service = SessionCleanupService()
