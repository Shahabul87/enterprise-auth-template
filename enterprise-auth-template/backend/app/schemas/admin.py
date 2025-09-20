"""
Admin schemas for request/response validation
"""

from typing import List, Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field, EmailStr, ConfigDict


class SystemStats(BaseModel):
    """System-wide statistics"""

    users: Dict[str, int]
    sessions: Dict[str, int]
    organizations: Dict[str, int]
    api_keys: Dict[str, int]
    audit_logs: Dict[str, int]


class UserManagementRequest(BaseModel):
    """Request model for user management operations"""

    email: Optional[EmailStr] = None
    name: Optional[str] = None
    password: Optional[str] = Field(None, min_length=8)
    is_active: Optional[bool] = None
    is_superuser: Optional[bool] = None
    is_verified: Optional[bool] = None
    two_factor_enabled: Optional[bool] = None
    roles: Optional[List[str]] = None
    organization_id: Optional[str] = None


class UserManagementResponse(BaseModel):
    """Response model for user management operations"""

    id: str
    email: str
    name: Optional[str]
    is_active: bool
    is_verified: bool
    is_superuser: bool
    is_suspended: bool
    two_factor_enabled: bool
    roles: List[Dict[str, str]]
    organization_id: Optional[str]
    created_at: datetime
    last_login: Optional[datetime]
    suspension_reason: Optional[str]
    suspended_until: Optional[datetime]

    model_config = ConfigDict(from_attributes=True)


class BulkUserOperation(BaseModel):
    """Model for bulk user operations"""

    user_ids: List[str]
    action: str = Field(..., pattern="^(suspend|unsuspend|activate|deactivate|delete)$")
    reason: Optional[str] = None


class SystemConfigUpdate(BaseModel):
    """Model for system configuration updates"""

    auth_config: Optional[Dict[str, Any]] = None
    feature_flags: Optional[Dict[str, bool]] = None
    rate_limits: Optional[Dict[str, int]] = None
    maintenance_mode: Optional[bool] = None
    maintenance_message: Optional[str] = None


class AdminDashboardData(BaseModel):
    """Comprehensive dashboard data model"""

    total_users: int
    active_users: int
    suspended_users: int
    active_sessions: int
    recent_registrations: int
    failed_login_attempts: int
    role_distribution: Dict[str, int]
    recent_audit_logs: List[Dict[str, Any]]
    system_health: Dict[str, Any]


class UserActivityReport(BaseModel):
    """User activity report model"""

    period_days: int
    total_actions: int
    actions_by_type: Dict[str, int]
    daily_activity: List[Dict[str, Any]]
    most_active_users: List[Dict[str, Any]]


class SecurityReport(BaseModel):
    """Security report model"""

    period_days: int
    failed_login_attempts: int
    suspicious_ips: List[Dict[str, Any]]
    locked_accounts: int
    two_fa_adoption_rate: float
    recent_security_events: List[Dict[str, Any]]


class SystemHealthCheck(BaseModel):
    """System health check model"""

    status: str = Field(..., pattern="^(healthy|degraded|unhealthy)$")
    components: Dict[str, Dict[str, Any]]
    uptime: str
    version: str
    last_check: str
