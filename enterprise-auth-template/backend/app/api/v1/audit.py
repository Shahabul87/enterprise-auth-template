"""
Audit API endpoints for audit log management
"""

from typing import List, Optional, Dict, Any
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.services.audit_service import AuditService
from app.dependencies.auth import get_current_user, require_superuser
from app.models.user import User

router = APIRouter(prefix="/audit", tags=["audit"])


@router.get("/logs", response_model=List[Dict[str, Any]])
async def get_audit_logs(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    user_id: Optional[str] = None,
    action: Optional[str] = None,
    resource_type: Optional[str] = None,
    resource_id: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> List[Dict[str, Any]]:
    """Get audit logs with filtering"""
    audit_service = AuditService(db)

    # Regular users can only see their own audit logs
    if not current_user.is_superuser:
        user_id = current_user.id

    filters = {}
    if user_id:
        filters["user_id"] = user_id
    if action:
        filters["action"] = action
    if resource_type:
        filters["resource_type"] = resource_type
    if resource_id:
        filters["resource_id"] = resource_id
    if start_date:
        filters["start_date"] = start_date
    if end_date:
        filters["end_date"] = end_date

    logs = await audit_service.get_logs(skip=skip, limit=limit, filters=filters)

    return logs


@router.get("/logs/{log_id}", response_model=Dict[str, Any])
async def get_audit_log(
    log_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Get a specific audit log by ID"""
    audit_service = AuditService(db)

    log = await audit_service.get_log_by_id(log_id)
    if not log:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Audit log not found"
        )

    # Check permission
    if not current_user.is_superuser and log["user_id"] != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view this audit log",
        )

    return log


@router.get("/user/{user_id}/logs", response_model=List[Dict[str, Any]])
async def get_user_audit_logs(
    user_id: str,
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    action: Optional[str] = None,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> List[Dict[str, Any]]:
    """Get audit logs for a specific user"""
    # Check permission
    if not current_user.is_superuser and user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not authorized to view audit logs for this user",
        )

    audit_service = AuditService(db)

    filters = {"user_id": user_id}
    if action:
        filters["action"] = action
    if start_date:
        filters["start_date"] = start_date
    if end_date:
        filters["end_date"] = end_date

    logs = await audit_service.get_logs(skip=skip, limit=limit, filters=filters)

    return logs


@router.get("/actions", response_model=List[str])
async def get_audit_actions(
    current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
) -> List[str]:
    """Get list of all unique audit actions"""
    audit_service = AuditService(db)
    return await audit_service.get_unique_actions()


@router.get("/resource-types", response_model=List[str])
async def get_resource_types(
    current_user: User = Depends(get_current_user), db: AsyncSession = Depends(get_db)
) -> List[str]:
    """Get list of all unique resource types"""
    audit_service = AuditService(db)
    return await audit_service.get_unique_resource_types()


@router.get("/statistics", response_model=Dict[str, Any])
async def get_audit_statistics(
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, Any]:
    """Get audit log statistics (admin only)"""
    audit_service = AuditService(db)
    return await audit_service.get_statistics(start_date, end_date)


@router.post("/export")
async def export_audit_logs(
    format: str = Query("csv", pattern="^(csv|json|excel)$"),
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    user_id: Optional[str] = None,
    action: Optional[str] = None,
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, str]:
    """Export audit logs (admin only)"""
    audit_service = AuditService(db)

    filters = {}
    if user_id:
        filters["user_id"] = user_id
    if action:
        filters["action"] = action
    if start_date:
        filters["start_date"] = start_date
    if end_date:
        filters["end_date"] = end_date

    export_url = await audit_service.export_logs(format=format, filters=filters)

    # Log the export action
    await audit_service.log_activity(
        user_id=current_user.id,
        action="AUDIT_LOGS_EXPORTED",
        resource_type="export",
        details={"format": format, "filters": filters},
    )

    return {"export_url": export_url, "format": format}


@router.delete("/logs", response_model=Dict[str, str])
async def delete_old_audit_logs(
    older_than_days: int = Query(..., ge=30),
    current_user: User = Depends(require_superuser),
    db: AsyncSession = Depends(get_db),
) -> Dict[str, str]:
    """Delete audit logs older than specified days (admin only)"""
    audit_service = AuditService(db)

    deleted_count = await audit_service.delete_old_logs(older_than_days)

    # Log the deletion
    await audit_service.log_activity(
        user_id=current_user.id,
        action="AUDIT_LOGS_DELETED",
        resource_type="audit",
        details={"older_than_days": older_than_days, "deleted_count": deleted_count},
    )

    return {
        "message": f"Successfully deleted {deleted_count} audit logs older than {older_than_days} days"
    }
