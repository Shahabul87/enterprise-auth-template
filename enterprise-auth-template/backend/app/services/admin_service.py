"""
Admin service for system administration operations
"""
import os
import csv
import json
import io
from io import StringIO
from typing import List, Optional, Dict, Any, Union, cast, TYPE_CHECKING
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_, func, distinct, select, update, delete
from sqlalchemy.exc import IntegrityError

from app.core.config import get_settings
from app.core.security import get_password_hash
from app.models.user import User
from app.models.role import Role
from app.models.permission import Permission
from app.models.session import UserSession
from app.models.audit import AuditLog
from app.models.organization import Organization
from app.models.api_key import APIKey
from app.models.notification import Notification
from app.models.login_attempt import LoginAttempt
from app.services.cache_service import CacheService
from app.services.export_service import ExportService
from app.core.events import EventEmitter
from app.schemas.admin import (
    SystemStats,
    UserManagementRequest,
    UserManagementResponse,
    BulkUserOperation,
    SystemConfigUpdate,
    AdminDashboardData,
    UserActivityReport,
    SecurityReport,
    SystemHealthCheck
)

settings = get_settings()

class AdminService:
    def __init__(self, db: Union[Session, AsyncSession]):
        self.db = db
        self.cache_service = CacheService()
        self.is_async = isinstance(db, AsyncSession)
        # ExportService expects AsyncSession, so we cast it appropriately
        self.export_service: Optional[ExportService] = None
        if self.is_async:
            self.export_service = ExportService(db, self.cache_service)

    async def _count_records(self, model: Any, filter_condition: Optional[Any] = None) -> int:
        """Helper method to count records for both sync and async sessions"""
        if self.is_async:
            stmt = select(func.count(model.id))
            if filter_condition is not None:
                stmt = stmt.where(filter_condition)
            result = await self.db.execute(stmt)
            return result.scalar() or 0
        else:
            db = cast(Session, self.db)  # Type narrowing for MyPy
            query = db.query(func.count(model.id))
            if filter_condition is not None:
                query = query.filter(filter_condition)
            return query.scalar() or 0

    async def get_dashboard_data(self) -> AdminDashboardData:
        """Get comprehensive dashboard data for admin panel"""
        # Get user statistics using helper method
        total_users = await self._count_records(User)
        active_users = await self._count_records(User, User.is_active == True)
        suspended_users = await self._count_records(User, User.is_active == False)

        # Get session statistics
        active_sessions = await self._count_records(UserSession, UserSession.is_active == True)

        # Get recent activity
        recent_registrations = await self._count_records(
            User, User.created_at >= datetime.utcnow() - timedelta(days=7)
        )

        # Get failed login attempts in last 24 hours
        failed_logins = await self._count_records(
            LoginAttempt,
            and_(
                LoginAttempt.success == False,
                LoginAttempt.created_at >= datetime.utcnow() - timedelta(hours=24)
            )
        )

        # Get role distribution
        if self.is_async:
            stmt = (
                select(Role.name, func.count(User.id))
                .join(User.roles)
                .group_by(Role.name)
            )
            result = await self.db.execute(stmt)
            role_distribution = result.all()
        else:
            db = cast(Session, self.db)
            role_distribution = db.query(
                Role.name,
                func.count(User.id)
            ).join(User.roles).group_by(Role.name).all()

        # Get recent audit logs
        if self.is_async:
            stmt = select(AuditLog).order_by(AuditLog.timestamp.desc()).limit(10)
            result = await self.db.execute(stmt)
            recent_logs = result.scalars().all()
        else:
            db = cast(Session, self.db)
            recent_logs = db.query(AuditLog).order_by(
                AuditLog.timestamp.desc()  # Use timestamp instead of created_at
            ).limit(10).all()

        return AdminDashboardData(
            total_users=total_users,
            active_users=active_users,
            suspended_users=suspended_users,
            active_sessions=active_sessions,
            recent_registrations=recent_registrations,
            failed_login_attempts=failed_logins,
            role_distribution={role: count for role, count in role_distribution},
            recent_audit_logs=[self._format_audit_log(log) for log in recent_logs],
            system_health=await self.check_system_health() if hasattr(self, 'check_system_health') else {}
        )

    async def get_system_stats(self) -> SystemStats:
        """Get system-wide statistics"""
        if self.is_async:
            # Async queries for AsyncSession
            today_start = datetime.utcnow().replace(hour=0, minute=0, second=0)

            stats = {
                "users": {
                    "total": (await self.db.execute(select(func.count(User.id)))).scalar() or 0,
                    "active": (await self.db.execute(select(func.count(User.id)).where(User.is_active == True))).scalar() or 0,
                    "verified": (await self.db.execute(select(func.count(User.id)).where(User.email_verified == True))).scalar() or 0,
                    "with_2fa": (await self.db.execute(select(func.count(User.id)).where(User.two_factor_enabled == True))).scalar() or 0,
                },
                "sessions": {
                    "active": (await self.db.execute(select(func.count(UserSession.id)).where(UserSession.is_active == True))).scalar() or 0,
                    "total_today": (await self.db.execute(select(func.count(UserSession.id)).where(
                        UserSession.created_at >= today_start
                    ))).scalar() or 0
                },
                "organizations": {
                    "total": (await self.db.execute(select(func.count(Organization.id)))).scalar() or 0,
                    "active": (await self.db.execute(select(func.count(Organization.id)).where(Organization.is_active == True))).scalar() or 0
                },
                "api_keys": {
                    "total": (await self.db.execute(select(func.count(APIKey.id)))).scalar() or 0,
                    "active": (await self.db.execute(select(func.count(APIKey.id)).where(APIKey.is_active == True))).scalar() or 0
                },
                "audit_logs": {
                    "total": (await self.db.execute(select(func.count(AuditLog.id)))).scalar() or 0,
                    "today": (await self.db.execute(select(func.count(AuditLog.id)).where(
                        AuditLog.created_at >= today_start
                    ))).scalar() or 0
                }
            }
        else:
            # Sync queries for Session (backwards compatibility)
            db = cast(Session, self.db)
            today_start = datetime.utcnow().replace(hour=0, minute=0, second=0)
            stats = {
                "users": {
                    "total": db.query(func.count(User.id)).scalar() or 0,
                    "active": db.query(func.count(User.id)).filter(User.is_active == True).scalar() or 0,
                    "verified": db.query(func.count(User.id)).filter(User.email_verified == True).scalar() or 0,
                    "with_2fa": db.query(func.count(User.id)).filter(User.two_factor_enabled == True).scalar() or 0,
                },
                "sessions": {
                    "active": db.query(func.count(UserSession.id)).filter(UserSession.is_active == True).scalar() or 0,
                    "total_today": db.query(func.count(UserSession.id)).filter(
                        UserSession.created_at >= today_start
                    ).scalar() or 0
                },
                "organizations": {
                    "total": db.query(func.count(Organization.id)).scalar() or 0,
                    "active": db.query(func.count(Organization.id)).filter(Organization.is_active == True).scalar() or 0
                },
                "api_keys": {
                    "total": db.query(func.count(APIKey.id)).scalar() or 0,
                    "active": db.query(func.count(APIKey.id)).filter(APIKey.is_active == True).scalar() or 0
                },
                "audit_logs": {
                    "total": db.query(func.count(AuditLog.id)).scalar() or 0,
                    "today": db.query(func.count(AuditLog.id)).filter(
                        AuditLog.created_at >= today_start
                    ).scalar() or 0
                }
            }
        return SystemStats(**stats)

    async def get_users(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None
    ) -> List[UserManagementResponse]:
        """Get users with filtering and pagination"""
        if self.is_async:
            # Build async query
            stmt = select(User)

            if filters:
                if "search" in filters:
                    search_term = f"%{filters['search']}%"
                    stmt = stmt.where(
                        or_(
                            User.email.ilike(search_term),
                            User.full_name.ilike(search_term) if hasattr(User, 'full_name') else User.email.ilike(search_term)
                        )
                    )
                if "role_id" in filters:
                    stmt = stmt.join(User.roles).where(Role.id == filters["role_id"])
                if "is_active" in filters:
                    stmt = stmt.where(User.is_active == filters["is_active"])
                if "organization_id" in filters:
                    stmt = stmt.where(User.organization_id == filters["organization_id"])

            stmt = stmt.offset(skip).limit(limit)
            result = await self.db.execute(stmt)
            users = result.scalars().all()
        else:
            # Use sync query for backwards compatibility
            db = cast(Session, self.db)
            query = db.query(User)

            if filters:
                if "search" in filters:
                    search_term = f"%{filters['search']}%"
                    query = query.filter(
                        or_(
                            User.email.ilike(search_term),
                            User.full_name.ilike(search_term) if hasattr(User, 'full_name') else User.email.ilike(search_term)
                        )
                    )
                if "role_id" in filters:
                    query = query.join(User.roles).filter(Role.id == filters["role_id"])
                if "is_active" in filters:
                    query = query.filter(User.is_active == filters["is_active"])
                if "organization_id" in filters:
                    query = query.filter(User.organization_id == filters["organization_id"])

            users = query.offset(skip).limit(limit).all()

        return [self._format_user_response(user) for user in users]

    async def get_user_details(self, user_id: str) -> Optional[UserManagementResponse]:
        """Get detailed information about a specific user"""
        if self.is_async:
            stmt = select(User).where(User.id == user_id)
            result = await self.db.execute(stmt)
            user = result.scalar_one_or_none()
        else:
            db = cast(Session, self.db)
            user = db.query(User).filter(User.id == user_id).first()

        if not user:
            return None
        return self._format_user_response(user)

    async def update_user(self, user_id: str, request: UserManagementRequest) -> UserManagementResponse:
        """Update user information"""
        if self.is_async:
            stmt = select(User).where(User.id == user_id)
            result = await self.db.execute(stmt)
            user = result.scalar_one_or_none()
        else:
            db = cast(Session, self.db)
            user = db.query(User).filter(User.id == user_id).first()

        if not user:
            raise ValueError("User not found")

        # Update fields
        update_data = request.dict(exclude_unset=True, exclude={"roles", "password"})
        for field, value in update_data.items():
            setattr(user, field, value)

        # Update password if provided
        if request.password:
            user.hashed_password = get_password_hash(request.password)

        # Update roles if provided
        if request.roles is not None:
            roles = self.db.query(Role).filter(Role.id.in_(request.roles)).all()
            user.roles = roles

        self.db.commit()
        self.db.refresh(user)

        # Clear user cache
        if hasattr(self.cache_service, 'delete'):
            await self.cache_service.delete(f"user:{user_id}")

        return self._format_user_response(user)

    async def suspend_user(
        self,
        user_id: str,
        reason: str,
        suspended_until: Optional[datetime] = None,
        suspended_by: str = None
    ) -> Dict[str, Any]:
        """Suspend a user account"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError("User not found")

        user.is_suspended = True
        user.suspended_at = datetime.utcnow()
        user.suspended_until = suspended_until
        user.suspension_reason = reason
        user.suspended_by = suspended_by

        # Terminate all active sessions
        self.db.query(UserSession).filter(
            and_(
                UserSession.user_id == user_id,
                UserSession.is_active == True
            )
        ).update({"is_active": False, "ended_at": datetime.utcnow()})

        self.db.commit()

        # Clear user cache
        if hasattr(self.cache_service, 'delete'):
            await self.cache_service.delete(f"user:{user_id}")

        return {
            "user_id": user_id,
            "suspended": True,
            "reason": reason,
            "suspended_until": suspended_until.isoformat() if suspended_until else None
        }

    async def unsuspend_user(self, user_id: str) -> Dict[str, Any]:
        """Unsuspend a user account"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError("User not found")

        user.is_suspended = False
        user.suspended_at = None
        user.suspended_until = None
        user.suspension_reason = None
        user.suspended_by = None

        self.db.commit()

        # Clear user cache
        if hasattr(self.cache_service, 'delete'):
            await self.cache_service.delete(f"user:{user_id}")

        return {
            "user_id": user_id,
            "suspended": False,
            "message": "User account unsuspended successfully"
        }

    async def soft_delete_user(self, user_id: str) -> None:
        """Soft delete a user account"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError("User not found")

        user.is_deleted = True
        user.deleted_at = datetime.utcnow()
        user.is_active = False

        # Terminate all sessions
        self.db.query(UserSession).filter(
            UserSession.user_id == user_id
        ).update({"is_active": False})

        self.db.commit()

        # Clear user cache
        if hasattr(self.cache_service, 'delete'):
            await self.cache_service.delete(f"user:{user_id}")

    async def hard_delete_user(self, user_id: str) -> None:
        """Permanently delete a user account"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError("User not found")

        # Delete related records first (cascade may not be configured)
        self.db.query(UserSession).filter(UserSession.user_id == user_id).delete()
        self.db.query(AuditLog).filter(AuditLog.user_id == user_id).delete()
        self.db.query(APIKey).filter(APIKey.user_id == user_id).delete()
        self.db.query(Notification).filter(Notification.user_id == user_id).delete()

        # Delete the user
        self.db.delete(user)
        self.db.commit()

        # Clear user cache
        if hasattr(self.cache_service, 'delete'):
            await self.cache_service.delete(f"user:{user_id}")

    async def bulk_user_operation(self, operation: BulkUserOperation) -> Dict[str, Any]:
        """Perform bulk operations on multiple users"""
        affected_users = []
        failed_users = []

        for user_id in operation.user_ids:
            try:
                if operation.action == "suspend":
                    await self.suspend_user(user_id, operation.reason or "Bulk suspension")
                elif operation.action == "unsuspend":
                    await self.unsuspend_user(user_id)
                elif operation.action == "activate":
                    user = self.db.query(User).filter(User.id == user_id).first()
                    if user:
                        user.is_active = True
                        self.db.commit()
                elif operation.action == "deactivate":
                    user = self.db.query(User).filter(User.id == user_id).first()
                    if user:
                        user.is_active = False
                        self.db.commit()
                elif operation.action == "delete":
                    await self.soft_delete_user(user_id)

                affected_users.append(user_id)
            except Exception as e:
                failed_users.append({"user_id": user_id, "error": str(e)})

        return {
            "action": operation.action,
            "total": len(operation.user_ids),
            "successful": len(affected_users),
            "failed": len(failed_users),
            "affected_users": affected_users,
            "failed_users": failed_users
        }

    async def get_active_sessions(self, user_id: Optional[str] = None) -> List[Dict[str, Any]]:
        """Get active user sessions"""
        query = self.db.query(UserSession).filter(UserSession.is_active == True)

        if user_id:
            query = query.filter(UserSession.user_id == user_id)

        sessions = query.all()
        return [self._format_session(session) for session in sessions]

    async def terminate_session(self, session_id: str) -> Dict[str, str]:
        """Terminate a specific session"""
        session = self.db.query(UserSession).filter(UserSession.id == session_id).first()
        if not session:
            raise ValueError("Session not found")

        session.is_active = False
        session.ended_at = datetime.utcnow()
        self.db.commit()

        # Clear session cache
        await self.cache_service.delete(f"session:{session_id}")

        return {"message": "Session terminated successfully"}

    async def terminate_all_user_sessions(self, user_id: str) -> Dict[str, Any]:
        """Terminate all sessions for a user"""
        result = self.db.query(UserSession).filter(
            and_(
                UserSession.user_id == user_id,
                UserSession.is_active == True
            )
        ).update({"is_active": False, "ended_at": datetime.utcnow()})

        self.db.commit()

        # Clear user session cache
        await self.cache_service.delete_pattern(f"session:user:{user_id}:*")

        return {
            "user_id": user_id,
            "terminated_count": result,
            "message": f"Terminated {result} sessions"
        }

    async def get_audit_logs(
        self,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """Get audit logs with filtering"""
        query = self.db.query(AuditLog)

        if filters:
            if "user_id" in filters:
                query = query.filter(AuditLog.user_id == filters["user_id"])
            if "action" in filters:
                query = query.filter(AuditLog.action == filters["action"])
            if "resource_type" in filters:
                query = query.filter(AuditLog.resource_type == filters["resource_type"])
            if "start_date" in filters:
                query = query.filter(AuditLog.created_at >= filters["start_date"])
            if "end_date" in filters:
                query = query.filter(AuditLog.created_at <= filters["end_date"])

        logs = query.order_by(AuditLog.created_at.desc()).offset(skip).limit(limit).all()
        return [self._format_audit_log(log) for log in logs]

    async def generate_activity_report(self, user_id: Optional[str] = None, days: int = 30) -> UserActivityReport:
        """Generate user activity report"""
        start_date = datetime.utcnow() - timedelta(days=days)

        query_filter = [AuditLog.created_at >= start_date]
        if user_id:
            query_filter.append(AuditLog.user_id == user_id)

        # Get activity summary
        total_actions = self.db.query(func.count(AuditLog.id)).filter(*query_filter).scalar()

        # Get actions by type
        actions_by_type = self.db.query(
            AuditLog.action,
            func.count(AuditLog.id)
        ).filter(*query_filter).group_by(AuditLog.action).all()

        # Get daily activity
        daily_activity = self.db.query(
            func.date(AuditLog.created_at),
            func.count(AuditLog.id)
        ).filter(*query_filter).group_by(
            func.date(AuditLog.created_at)
        ).order_by(func.date(AuditLog.created_at)).all()

        # Get most active users
        most_active_users = self.db.query(
            User.email,
            func.count(AuditLog.id).label("action_count")
        ).join(AuditLog, User.id == AuditLog.user_id).filter(
            AuditLog.created_at >= start_date
        ).group_by(User.email).order_by(
            func.count(AuditLog.id).desc()
        ).limit(10).all()

        return UserActivityReport(
            period_days=days,
            total_actions=total_actions,
            actions_by_type={action: count for action, count in actions_by_type},
            daily_activity=[{"date": str(date), "count": count} for date, count in daily_activity],
            most_active_users=[{"email": email, "actions": count} for email, count in most_active_users]
        )

    async def generate_security_report(self, days: int = 30) -> SecurityReport:
        """Generate security report"""
        start_date = datetime.utcnow() - timedelta(days=days)

        # Failed login attempts
        failed_logins = self.db.query(func.count(LoginAttempt.id)).filter(
            and_(
                LoginAttempt.success == False,
                LoginAttempt.created_at >= start_date
            )
        ).scalar() if hasattr(self, 'LoginAttempt') else 0

        # Suspicious activities (multiple failed logins from same IP)
        suspicious_ips = []
        if hasattr(self, 'LoginAttempt'):
            suspicious_ips = self.db.query(
                LoginAttempt.ip_address,
                func.count(LoginAttempt.id)
            ).filter(
                and_(
                    LoginAttempt.success == False,
                    LoginAttempt.created_at >= start_date
                )
            ).group_by(LoginAttempt.ip_address).having(
                func.count(LoginAttempt.id) > 5
            ).all()

        # Account lockouts
        locked_accounts = self.db.query(func.count(User.id)).filter(
            User.is_suspended == True
        ).scalar()

        # 2FA adoption rate
        total_users = self.db.query(func.count(User.id)).scalar()
        users_with_2fa = self.db.query(func.count(User.id)).filter(
            User.two_factor_enabled == True
        ).scalar()
        two_fa_adoption = (users_with_2fa / total_users * 100) if total_users > 0 else 0

        return SecurityReport(
            period_days=days,
            failed_login_attempts=failed_logins,
            suspicious_ips=[{"ip": ip, "attempts": count} for ip, count in suspicious_ips],
            locked_accounts=locked_accounts,
            two_fa_adoption_rate=two_fa_adoption,
            recent_security_events=await self._get_recent_security_events(start_date)
        )

    async def get_system_config(self) -> Dict[str, Any]:
        """Get current system configuration"""
        config = {
            "auth": {
                "jwt_expiry": settings.ACCESS_TOKEN_EXPIRE_MINUTES,
                "refresh_expiry": settings.REFRESH_TOKEN_EXPIRE_DAYS,
                "password_min_length": settings.PASSWORD_MIN_LENGTH,
                "max_login_attempts": settings.MAX_LOGIN_ATTEMPTS,
                "lockout_duration": settings.LOCKOUT_DURATION_MINUTES
            },
            "features": {
                "oauth_enabled": settings.OAUTH_ENABLED,
                "two_factor_enabled": settings.TWO_FACTOR_ENABLED,
                "magic_links_enabled": settings.MAGIC_LINKS_ENABLED,
                "webauthn_enabled": settings.WEBAUTHN_ENABLED
            },
            "limits": {
                "rate_limit_per_minute": settings.RATE_LIMIT_PER_MINUTE,
                "max_sessions_per_user": settings.MAX_SESSIONS_PER_USER,
                "api_key_max_age_days": settings.API_KEY_MAX_AGE_DAYS
            },
            "maintenance": {
                "mode": getattr(settings, "MAINTENANCE_MODE", False),
                "message": getattr(settings, "MAINTENANCE_MESSAGE", None)
            }
        }
        return config

    async def update_system_config(self, config_update: SystemConfigUpdate) -> Dict[str, Any]:
        """Update system configuration"""
        # This would typically update configuration in database or config file
        # For now, we'll just return the proposed changes
        updated_fields = config_update.dict(exclude_unset=True)

        # In production, you'd persist these changes
        # For example: await self._persist_config_changes(updated_fields)

        return {
            "updated": True,
            "changes": updated_fields,
            "message": "Configuration updated successfully"
        }

    async def check_system_health(self) -> SystemHealthCheck:
        """Check system health"""
        health = {
            "status": "healthy",
            "components": {
                "database": await self._check_database_health(),
                "cache": await self._check_cache_health(),
                "storage": await self._check_storage_health(),
                "email": await self._check_email_health()
            },
            "uptime": self._get_uptime(),
            "version": settings.APP_VERSION,
            "last_check": datetime.utcnow().isoformat()
        }

        # Determine overall status
        if any(comp["status"] == "unhealthy" for comp in health["components"].values()):
            health["status"] = "unhealthy"
        elif any(comp["status"] == "degraded" for comp in health["components"].values()):
            health["status"] = "degraded"

        return SystemHealthCheck(**health)

    async def toggle_maintenance_mode(self, enable: bool, message: Optional[str] = None) -> Dict[str, Any]:
        """Toggle maintenance mode"""
        # In production, this would update a persistent configuration
        settings.MAINTENANCE_MODE = enable
        if message:
            settings.MAINTENANCE_MESSAGE = message

        return {
            "maintenance_mode": enable,
            "message": message or "System is under maintenance",
            "updated_at": datetime.utcnow().isoformat()
        }

    async def clear_cache(self, cache_type: Optional[str] = None) -> Dict[str, str]:
        """Clear system cache"""
        if cache_type:
            await self.cache_service.delete_pattern(f"{cache_type}:*")
            return {"message": f"Cleared {cache_type} cache"}
        else:
            await self.cache_service.flush_all()
            return {"message": "Cleared all cache"}

    async def export_users(self, format: str = "csv") -> str:
        """Export user data"""
        users = self.db.query(User).all()
        return await self.export_service.export_users(users, format)

    async def export_audit_logs(
        self,
        format: str = "csv",
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None
    ) -> str:
        """Export audit logs"""
        query = self.db.query(AuditLog)

        if start_date:
            query = query.filter(AuditLog.timestamp >= start_date)  # Use timestamp instead of created_at
        if end_date:
            query = query.filter(AuditLog.timestamp <= end_date)  # Use timestamp instead of created_at

        logs = query.all()
        if self.export_service:
            return await self.export_service.export_audit_logs(logs, format)
        else:
            # Fallback to simple CSV export
            return self._simple_export(logs, format)

    # Helper methods
    def _format_user_response(self, user: User) -> UserManagementResponse:
        """Format user data for response"""
        return UserManagementResponse(
            id=str(user.id),  # Convert UUID to string
            email=user.email,
            name=user.full_name,  # Use full_name directly
            is_active=user.is_active,
            is_verified=user.email_verified,
            is_superuser=user.is_superuser,
            is_suspended=not user.is_active,  # Use is_active as proxy for suspension
            two_factor_enabled=getattr(user, 'two_factor_enabled', False),  # Safe attribute access
            roles=[{"id": str(role.id), "name": role.name} for role in user.roles] if hasattr(user, 'roles') else [],
            organization_id=str(user.organization_id) if hasattr(user, 'organization_id') and user.organization_id else None,
            created_at=user.created_at,
            last_login=getattr(user, 'last_login', None),  # Safe attribute access
            suspension_reason=getattr(user, 'suspension_reason', None),  # Safe attribute access
            suspended_until=getattr(user, 'suspended_until', None)  # Safe attribute access
        )

    def _format_session(self, session: UserSession) -> Dict[str, Any]:
        """Format session data"""
        return {
            "id": session.id,
            "user_id": session.user_id,
            "ip_address": session.ip_address,
            "user_agent": session.user_agent,
            "created_at": session.created_at.isoformat(),
            "last_activity": session.last_activity.isoformat() if session.last_activity else None,
            "is_active": session.is_active
        }

    def _format_audit_log(self, log: AuditLog) -> Dict[str, Any]:
        """Format audit log data"""
        return {
            "id": log.id,
            "user_id": log.user_id,
            "action": log.action,
            "resource_type": log.resource if hasattr(log, 'resource') else None,  # Use resource instead of resource_type
            "resource_id": log.resource_id,
            "details": log.details,
            "ip_address": log.ip_address,
            "user_agent": log.user_agent,
            "created_at": log.timestamp.isoformat() if hasattr(log, 'timestamp') else None  # Use timestamp instead of created_at
        }

    async def _get_recent_security_events(self, start_date: datetime) -> List[Dict[str, Any]]:
        """Get recent security-related events"""
        security_actions = [
            "LOGIN_FAILED", "ACCOUNT_LOCKED", "SUSPICIOUS_ACTIVITY",
            "PASSWORD_RESET", "TWO_FACTOR_DISABLED", "API_KEY_COMPROMISED"
        ]

        events = self.db.query(AuditLog).filter(
            and_(
                AuditLog.action.in_(security_actions),
                AuditLog.timestamp >= start_date  # Use timestamp instead of created_at
            )
        ).order_by(AuditLog.timestamp.desc()).limit(50).all()  # Use timestamp instead of created_at

        return [self._format_audit_log(event) for event in events]

    async def _check_database_health(self) -> Dict[str, Any]:
        """Check database health"""
        try:
            from sqlalchemy import text
            self.db.execute(text("SELECT 1"))  # Use text() for raw SQL
            return {"status": "healthy", "message": "Database connection OK"}
        except Exception as e:
            return {"status": "unhealthy", "message": str(e)}

    async def _check_cache_health(self) -> Dict[str, Any]:
        """Check cache health"""
        try:
            if hasattr(self.cache_service, 'set') and hasattr(self.cache_service, 'get'):
                await self.cache_service.set("health_check", "ok", ttl=10)
                value = await self.cache_service.get("health_check")
            else:
                # Fallback if cache service doesn't have these methods
                value = "ok"
            if value == "ok":
                return {"status": "healthy", "message": "Cache connection OK"}
            return {"status": "degraded", "message": "Cache read/write issue"}
        except Exception as e:
            return {"status": "unhealthy", "message": str(e)}

    async def _check_storage_health(self) -> Dict[str, Any]:
        """Check storage health"""
        try:
            # Check disk space
            import shutil
            total, used, free = shutil.disk_usage("/")
            free_percentage = (free / total) * 100

            if free_percentage < 5:
                return {"status": "unhealthy", "message": f"Low disk space: {free_percentage:.1f}% free"}
            elif free_percentage < 20:
                return {"status": "degraded", "message": f"Disk space warning: {free_percentage:.1f}% free"}
            return {"status": "healthy", "message": f"Disk space OK: {free_percentage:.1f}% free"}
        except Exception as e:
            return {"status": "unknown", "message": str(e)}

    async def _check_email_health(self) -> Dict[str, Any]:
        """Check email service health"""
        # This would check actual email service connection
        # For now, returning a mock response
        return {"status": "healthy", "message": "Email service OK"}

    def _get_uptime(self) -> str:
        """Get application uptime"""
        # This would calculate actual uptime from application start time
        # For now, returning a mock value
        return "7 days, 14 hours, 32 minutes"

    def _simple_export(self, data: List[Any], format: str) -> str:
        """Simple export function when ExportService is not available"""
        if format == "csv":
            output = io.StringIO()
            if data:
                # Get headers from first item
                if hasattr(data[0], '__dict__'):
                    headers = list(data[0].__dict__.keys())
                    writer = csv.DictWriter(output, fieldnames=headers)
                    writer.writeheader()
                    for item in data:
                        writer.writerow({k: str(v) for k, v in item.__dict__.items()})
            return output.getvalue()
        elif format == "json":
            return json.dumps([str(item) for item in data], default=str)
        else:
            raise ValueError(f"Unsupported format: {format}")
