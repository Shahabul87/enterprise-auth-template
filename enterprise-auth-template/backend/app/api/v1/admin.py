"""
Admin API endpoints for system administration
"""

from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.config import get_settings
from app.models.user import User
from app.services.admin_service import AdminService
from app.services.audit_service import AuditService
from app.dependencies.auth import require_superuser
from app.schemas.admin import (
    SystemStats,
    UserManagementRequest,
    UserManagementResponse,
    BulkUserOperation,
    SystemConfigUpdate,
    AdminDashboardData,
    UserActivityReport,
    SecurityReport,
    SystemHealthCheck,
)

router = APIRouter(prefix="/admin", tags=["admin"])
settings = get_settings()


@router.get("/dashboard", response_model=AdminDashboardData)
async def get_admin_dashboard(
    current_user: User = Depends(require_superuser), db: AsyncSession = Depends(get_db)
) -> AdminDashboardData:
    """Get comprehensive admin dashboard data"""
    admin_service = AdminService(db)

    try:
        dashboard_data = await admin_service.get_dashboard_data()

        # Log admin access
        audit_service = AuditService(db)
        await audit_service.log_activity(
            user_id=current_user.id,
            action="ADMIN_DASHBOARD_ACCESS",
            resource_type="admin",
            details={"timestamp": datetime.utcnow().isoformat()},
        )

        return dashboard_data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch dashboard data: {str(e)}",
        )


@router.get("/stats", response_model=SystemStats)
async def get_system_stats(
    current_user: User = Depends(require_superuser), db: AsyncSession = Depends(get_db)
) -> SystemStats:
    """Get system-wide statistics"""
    admin_service = AdminService(db)
    return await admin_service.get_system_stats()


@router.get("/users", response_model=List[UserManagementResponse])
async def list_all_users(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    search: Optional[str] = None,
    role_id: Optional[str] = None,
    is_active: Optional[bool] = None,
    organization_id: Optional[str] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> List[UserManagementResponse]:
    """List all users with filtering and pagination"""
    admin_service = AdminService(db)

    filters = {}
    if search:
        filters["search"] = search
    if role_id:
        filters["role_id"] = role_id
    if is_active is not None:
        filters["is_active"] = is_active
    if organization_id:
        filters["organization_id"] = organization_id

    users = await admin_service.get_users(skip=skip, limit=limit, filters=filters)

    return users


@router.get("/users/{user_id}", response_model=UserManagementResponse)
async def get_user_details(
    user_id: str,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> UserManagementResponse:
    """Get detailed information about a specific user"""
    admin_service = AdminService(db)

    user = await admin_service.get_user_details(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    return user


@router.put("/users/{user_id}", response_model=UserManagementResponse)
async def update_user(
    user_id: str,
    request: UserManagementRequest,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> UserManagementResponse:
    """Update user information"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    # Prevent self-demotion
    if user_id == current_user.id and request.is_superuser is False:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot remove your own superuser status",
        )

    updated_user = await admin_service.update_user(user_id, request)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="USER_UPDATED",
        resource_type="user",
        resource_id=user_id,
        details=request.dict(exclude_unset=True),
    )

    return updated_user


@router.post("/users/{user_id}/suspend")
async def suspend_user(
    user_id: str,
    reason: str = Query(..., min_length=1),
    duration_hours: Optional[int] = Query(None, ge=1),
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Suspend a user account"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    # Prevent self-suspension
    if user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot suspend your own account",
        )

    suspension_until = None
    if duration_hours:
        suspension_until = datetime.utcnow() + timedelta(hours=duration_hours)

    result = await admin_service.suspend_user(
        user_id=user_id,
        reason=reason,
        suspended_until=suspension_until,
        suspended_by=current_user.id,
    )

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="USER_SUSPENDED",
        resource_type="user",
        resource_id=user_id,
        details={
            "reason": reason,
            "duration_hours": duration_hours,
            "suspended_until": (
                suspension_until.isoformat() if suspension_until else None
            ),
        },
    )

    return result


@router.post("/users/{user_id}/unsuspend")
async def unsuspend_user(
    user_id: str,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Unsuspend a user account"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    result = await admin_service.unsuspend_user(user_id)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="USER_UNSUSPENDED",
        resource_type="user",
        resource_id=user_id,
        details={"unsuspended_by": current_user.id},
    )

    return result


@router.delete("/users/{user_id}")
async def delete_user(
    user_id: str,
    hard_delete: bool = Query(False),
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, str]:
    """Delete or soft-delete a user account"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    # Prevent self-deletion
    if user_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account",
        )

    if hard_delete:
        await admin_service.hard_delete_user(user_id)
        action = "USER_HARD_DELETED"
    else:
        await admin_service.soft_delete_user(user_id)
        action = "USER_SOFT_DELETED"

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action=action,
        resource_type="user",
        resource_id=user_id,
        details={"deleted_by": current_user.id, "hard_delete": hard_delete},
    )

    return {
        "message": f"User {'permanently' if hard_delete else 'soft'} deleted successfully"
    }


@router.post("/users/bulk-operation", response_model=Dict[str, Any])
async def bulk_user_operation(
    operation: BulkUserOperation,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Perform bulk operations on multiple users"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    # Prevent operations on self
    if current_user.id in operation.user_ids:
        operation.user_ids.remove(current_user.id)

    result = await admin_service.bulk_user_operation(operation)

    # Log the bulk operation
    await audit_service.log_activity(
        user_id=current_user.id,
        action=f"BULK_{operation.action.upper()}",
        resource_type="user",
        details={
            "affected_users": len(operation.user_ids),
            "user_ids": operation.user_ids,
            "action": operation.action,
        },
    )

    return result


@router.get("/sessions/active", response_model=List[Dict[str, Any]])
async def get_active_sessions(
    user_id: Optional[str] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> List[Dict[str, Any]]:
    """Get all active user sessions"""
    admin_service = AdminService(db)
    return await admin_service.get_active_sessions(user_id=user_id)


@router.post("/sessions/{session_id}/terminate")
async def terminate_session(
    session_id: str,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, str]:
    """Terminate a specific user session"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    result = await admin_service.terminate_session(session_id)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="SESSION_TERMINATED",
        resource_type="session",
        resource_id=session_id,
        details={"terminated_by": current_user.id},
    )

    return result


@router.post("/sessions/terminate-all")
async def terminate_all_sessions(
    user_id: str,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Terminate all sessions for a specific user"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    result = await admin_service.terminate_all_user_sessions(user_id)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="ALL_SESSIONS_TERMINATED",
        resource_type="user",
        resource_id=user_id,
        details={
            "terminated_by": current_user.id,
            "sessions_terminated": result["terminated_count"],
        },
    )

    return result


@router.get("/audit-logs", response_model=List[Dict[str, Any]])
async def get_audit_logs(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    user_id: Optional[str] = None,
    action: Optional[str] = None,
    resource_type: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> List[Dict[str, Any]]:
    """Get audit logs with filtering"""
    admin_service = AdminService(db)

    filters = {}
    if user_id:
        filters["user_id"] = user_id
    if action:
        filters["action"] = action
    if resource_type:
        filters["resource_type"] = resource_type
    if start_date:
        filters["start_date"] = start_date
    if end_date:
        filters["end_date"] = end_date

    logs = await admin_service.get_audit_logs(skip=skip, limit=limit, filters=filters)

    return logs


@router.get("/activity-report", response_model=UserActivityReport)
async def get_user_activity_report(
    user_id: Optional[str] = None,
    days: int = Query(30, ge=1, le=365),
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> UserActivityReport:
    """Generate user activity report"""
    admin_service = AdminService(db)
    return await admin_service.generate_activity_report(user_id=user_id, days=days)


@router.get("/security-report", response_model=SecurityReport)
async def get_security_report(
    days: int = Query(30, ge=1, le=365),
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> SecurityReport:
    """Generate security report"""
    admin_service = AdminService(db)
    return await admin_service.generate_security_report(days=days)


@router.get("/system/config")
async def get_system_config(
    current_user: User = Depends(require_superuser), db: AsyncSession = Depends(get_db)
) -> Dict[str, Any]:
    """Get current system configuration"""
    admin_service = AdminService(db)
    return await admin_service.get_system_config()


@router.put("/system/config")
async def update_system_config(
    config_update: SystemConfigUpdate,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Update system configuration"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    result = await admin_service.update_system_config(config_update)

    # Log the configuration change
    await audit_service.log_activity(
        user_id=current_user.id,
        action="SYSTEM_CONFIG_UPDATED",
        resource_type="system",
        details=config_update.dict(exclude_unset=True),
    )

    return result


@router.get("/system/health", response_model=SystemHealthCheck)
async def check_system_health(
    current_user: User = Depends(require_superuser), db: AsyncSession = Depends(get_db)
) -> SystemHealthCheck:
    """Check system health and component status"""
    admin_service = AdminService(db)
    return await admin_service.check_system_health()


@router.post("/system/maintenance")
async def toggle_maintenance_mode(
    enable: bool,
    message: Optional[str] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Enable or disable maintenance mode"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    result = await admin_service.toggle_maintenance_mode(enable, message)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="MAINTENANCE_MODE_TOGGLED",
        resource_type="system",
        details={"enabled": enable, "message": message},
    )

    return result


@router.post("/cache/clear")
async def clear_cache(
    cache_type: Optional[str] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, str]:
    """Clear system cache"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    result = await admin_service.clear_cache(cache_type)

    # Log the action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="CACHE_CLEARED",
        resource_type="system",
        details={"cache_type": cache_type or "all"},
    )

    return result


@router.get("/exports/users")
async def export_users(
    format: str = Query("csv", pattern="^(csv|json|excel)$"),
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Export user data"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    export_url = await admin_service.export_users(format)

    # Log the export
    await audit_service.log_activity(
        user_id=current_user.id,
        action="USERS_EXPORTED",
        resource_type="export",
        details={"format": format},
    )

    return {"export_url": export_url, "format": format}


@router.get("/exports/audit-logs")
async def export_audit_logs(
    format: str = Query("csv", pattern="^(csv|json|excel)$"),
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Export audit logs"""
    admin_service = AdminService(db)
    audit_service = AuditService(db)

    export_url = await admin_service.export_audit_logs(
        format=format, start_date=start_date, end_date=end_date
    )

    # Log the export
    await audit_service.log_activity(
        user_id=current_user.id,
        action="AUDIT_LOGS_EXPORTED",
        resource_type="export",
        details={
            "format": format,
            "start_date": start_date.isoformat() if start_date else None,
            "end_date": end_date.isoformat() if end_date else None,
        },
    )

    return {"export_url": export_url, "format": format}
