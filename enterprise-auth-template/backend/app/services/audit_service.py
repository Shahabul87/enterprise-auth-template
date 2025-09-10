"""
Audit Service

Service layer for managing audit logs and compliance tracking.
"""

from datetime import datetime
from typing import Optional, Any, Dict
from uuid import UUID

import structlog
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.audit import AuditLog, AuditAction, AuditResult

logger = structlog.get_logger(__name__)


class AuditService:
    """
    Service for managing audit logs.

    Provides methods for logging user actions and system events
    for compliance and security monitoring.
    """

    def __init__(self, db: AsyncSession):
        """
        Initialize audit service.

        Args:
            db: Database session
        """
        self.db = db

    async def log_action(
        self,
        action: str,
        user_id: Optional[UUID] = None,
        user_email: Optional[str] = None,
        resource: Optional[str] = None,
        resource_id: Optional[str] = None,
        description: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        result: str = AuditResult.SUCCESS,
        error_message: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        request_id: Optional[str] = None,
        session_id: Optional[str] = None,
    ) -> AuditLog:
        """
        Log an audit event.

        Args:
            action: Action being performed
            user_id: ID of the user performing the action
            user_email: Email of the user performing the action
            resource: Resource being acted upon
            resource_id: ID of the resource
            description: Human-readable description
            details: Additional details as JSON
            result: Result of the action (success/failure/error)
            error_message: Error message if applicable
            ip_address: Client IP address
            user_agent: Client user agent
            request_id: Request tracking ID
            session_id: Session tracking ID

        Returns:
            Created audit log entry
        """
        try:
            audit_log = AuditLog.create_log(
                action=action,
                user_id=str(user_id) if user_id else None,
                user_email=user_email,
                resource=resource,
                resource_id=resource_id,
                description=description,
                details=details,
                result=result,
                error_message=error_message,
                ip_address=ip_address,
                user_agent=user_agent,
                request_id=request_id,
                session_id=session_id,
            )

            self.db.add(audit_log)
            await self.db.commit()

            logger.info(
                "Audit log created",
                action=action,
                user_id=str(user_id) if user_id else None,
                result=result,
            )

            return audit_log

        except Exception as e:
            logger.error(
                "Failed to create audit log",
                action=action,
                user_id=str(user_id) if user_id else None,
                error=str(e),
            )
            # Don't fail the main operation if audit logging fails
            await self.db.rollback()
            raise

    async def log_activity(
        self,
        action: str,
        user_id: Optional[UUID] = None,
        user_email: Optional[str] = None,
        resource_type: Optional[str] = None,  # Added for compatibility
        resource: Optional[str] = None,
        resource_id: Optional[str] = None,
        description: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        result: str = AuditResult.SUCCESS,
        error_message: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        request_id: Optional[str] = None,
        session_id: Optional[str] = None,
    ) -> AuditLog:
        """
        Alias for log_action to maintain backward compatibility.

        Args:
            action: Action being performed
            user_id: ID of the user performing the action
            user_email: Email of the user performing the action
            resource_type: Type of resource (backwards compatibility)
            resource: Resource being acted upon
            resource_id: ID of the resource
            description: Human-readable description
            details: Additional details as JSON
            result: Result of the action (success/failure/error)
            error_message: Error message if applicable
            ip_address: Client IP address
            user_agent: Client user agent
            request_id: Request tracking ID
            session_id: Session tracking ID

        Returns:
            Created audit log entry
        """
        # Use resource_type if provided and resource is not
        if resource_type and not resource:
            resource = resource_type

        return await self.log_action(
            action=action,
            user_id=user_id,
            user_email=user_email,
            resource=resource,
            resource_id=resource_id,
            description=description,
            details=details,
            result=result,
            error_message=error_message,
            ip_address=ip_address,
            user_agent=user_agent,
            request_id=request_id,
            session_id=session_id,
        )

    async def log_event(
        self,
        event_type: str,
        user_id: Optional[UUID] = None,
        user_email: Optional[str] = None,
        resource: Optional[str] = None,
        resource_id: Optional[str] = None,
        description: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
        result: str = AuditResult.SUCCESS,
        error_message: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None,
        request_id: Optional[str] = None,
        session_id: Optional[str] = None,
    ) -> AuditLog:
        """
        Log an event (alias for log_action with event terminology).

        Args:
            event_type: Type of event being logged
            user_id: ID of the user associated with the event
            user_email: Email of the user
            resource: Resource being acted upon
            resource_id: ID of the resource
            description: Human-readable description
            details: Additional details as JSON
            result: Result of the event (success/failure/error)
            error_message: Error message if applicable
            ip_address: Client IP address
            user_agent: Client user agent
            request_id: Request tracking ID
            session_id: Session tracking ID

        Returns:
            Created audit log entry
        """
        return await self.log_action(
            action=event_type,
            user_id=user_id,
            user_email=user_email,
            resource=resource,
            resource_id=resource_id,
            description=description,
            details=details,
            result=result,
            error_message=error_message,
            ip_address=ip_address,
            user_agent=user_agent,
            request_id=request_id,
            session_id=session_id,
        )
