"""
Metrics and Analytics Endpoints

Provides system metrics, user analytics, and performance monitoring
for administrators and authorized users.
"""

from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from enum import Enum

import structlog
from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db_session
from app.dependencies.auth import CurrentUser, get_current_user, require_permissions
from app.services.analytics_service import AnalyticsService
from app.services.audit_service import AuditService

logger = structlog.get_logger(__name__)

router = APIRouter()


class MetricType(str, Enum):
    """Types of metrics available."""
    USER_ACTIVITY = "user_activity"
    AUTHENTICATION = "authentication"
    API_USAGE = "api_usage"
    SYSTEM_PERFORMANCE = "system_performance"
    SECURITY_EVENTS = "security_events"


class TimeRange(str, Enum):
    """Time range options for metrics."""
    HOUR = "1h"
    DAY = "1d"
    WEEK = "7d"
    MONTH = "30d"
    QUARTER = "90d"
    YEAR = "365d"


class MetricsOverviewResponse(BaseModel):
    """System metrics overview response."""

    active_users: int = Field(..., description="Number of active users")
    total_users: int = Field(..., description="Total number of users")
    login_success_rate: float = Field(..., description="Login success rate percentage")
    api_requests_today: int = Field(..., description="API requests today")
    failed_logins_today: int = Field(..., description="Failed login attempts today")
    system_uptime: str = Field(..., description="System uptime")
    response_time_avg: float = Field(..., description="Average response time in ms")
    error_rate: float = Field(..., description="Error rate percentage")
    generated_at: str = Field(..., description="Metrics generation timestamp")


class UserAnalyticsResponse(BaseModel):
    """User analytics response."""

    period: str = Field(..., description="Analysis period")
    new_users: int = Field(..., description="New user registrations")
    active_users: int = Field(..., description="Active users in period")
    returning_users: int = Field(..., description="Returning users")
    user_retention_rate: float = Field(..., description="User retention rate")
    avg_session_duration: float = Field(..., description="Average session duration in minutes")
    most_active_hours: List[int] = Field(..., description="Most active hours of day")
    geographic_distribution: Dict[str, int] = Field(..., description="Users by country/region")


class AuthenticationMetricsResponse(BaseModel):
    """Authentication metrics response."""

    period: str = Field(..., description="Analysis period")
    total_login_attempts: int = Field(..., description="Total login attempts")
    successful_logins: int = Field(..., description="Successful logins")
    failed_logins: int = Field(..., description="Failed login attempts")
    success_rate: float = Field(..., description="Login success rate")
    two_factor_usage: float = Field(..., description="2FA usage percentage")
    oauth_logins: int = Field(..., description="OAuth login attempts")
    password_resets: int = Field(..., description="Password reset requests")
    account_lockouts: int = Field(..., description="Account lockout events")
    login_methods: Dict[str, int] = Field(..., description="Login methods breakdown")


class APIUsageMetricsResponse(BaseModel):
    """API usage metrics response."""

    period: str = Field(..., description="Analysis period")
    total_requests: int = Field(..., description="Total API requests")
    unique_users: int = Field(..., description="Unique API users")
    avg_requests_per_user: float = Field(..., description="Average requests per user")
    most_used_endpoints: List[Dict[str, Any]] = Field(..., description="Most used endpoints")
    error_rate: float = Field(..., description="API error rate")
    avg_response_time: float = Field(..., description="Average response time")
    rate_limit_hits: int = Field(..., description="Rate limit violations")
    api_key_usage: Dict[str, int] = Field(..., description="Usage by API key type")


class SecurityMetricsResponse(BaseModel):
    """Security metrics response."""

    period: str = Field(..., description="Analysis period")
    security_events: int = Field(..., description="Total security events")
    failed_auth_attempts: int = Field(..., description="Failed authentication attempts")
    suspicious_activities: int = Field(..., description="Suspicious activity detections")
    blocked_ips: int = Field(..., description="Blocked IP addresses")
    csrf_violations: int = Field(..., description="CSRF token violations")
    rate_limit_violations: int = Field(..., description="Rate limit violations")
    password_breach_detections: int = Field(..., description="Password breach detections")
    event_types: Dict[str, int] = Field(..., description="Security events by type")


class SystemPerformanceResponse(BaseModel):
    """System performance metrics response."""

    period: str = Field(..., description="Analysis period")
    avg_response_time: float = Field(..., description="Average response time in ms")
    p95_response_time: float = Field(..., description="95th percentile response time")
    p99_response_time: float = Field(..., description="99th percentile response time")
    error_rate: float = Field(..., description="Error rate percentage")
    throughput: float = Field(..., description="Requests per second")
    database_performance: Dict[str, float] = Field(..., description="Database metrics")
    cache_hit_rate: float = Field(..., description="Cache hit rate percentage")
    memory_usage: float = Field(..., description="Memory usage percentage")
    cpu_usage: float = Field(..., description="CPU usage percentage")


class MetricDataPoint(BaseModel):
    """Individual metric data point."""

    timestamp: str = Field(..., description="Data point timestamp")
    value: float = Field(..., description="Metric value")
    metadata: Optional[Dict[str, Any]] = Field(None, description="Additional metadata")


class TimeSeriesResponse(BaseModel):
    """Time series metrics response."""

    metric_name: str = Field(..., description="Metric name")
    period: str = Field(..., description="Time period")
    data_points: List[MetricDataPoint] = Field(..., description="Time series data")
    summary: Dict[str, float] = Field(..., description="Summary statistics")


@router.get("/overview", response_model=MetricsOverviewResponse)
async def get_metrics_overview(
    current_user: CurrentUser = Depends(require_permissions(["metrics:read", "admin:access"])),
    db: AsyncSession = Depends(get_db_session),
) -> MetricsOverviewResponse:
    """
    Get system metrics overview.

    Provides a high-level overview of key system metrics including
    user activity, authentication rates, and system performance.

    Returns:
        MetricsOverviewResponse: System metrics overview
    """
    logger.info("System metrics overview requested", user_id=current_user.id)

    try:
        analytics_service = AnalyticsService(db)

        # Get overview metrics
        overview_data = await analytics_service.get_system_overview()

        return MetricsOverviewResponse(
            active_users=overview_data.get('active_users', 0),
            total_users=overview_data.get('total_users', 0),
            login_success_rate=overview_data.get('login_success_rate', 0.0),
            api_requests_today=overview_data.get('api_requests_today', 0),
            failed_logins_today=overview_data.get('failed_logins_today', 0),
            system_uptime=overview_data.get('system_uptime', "Unknown"),
            response_time_avg=overview_data.get('response_time_avg', 0.0),
            error_rate=overview_data.get('error_rate', 0.0),
            generated_at=datetime.utcnow().isoformat()
        )

    except Exception as e:
        logger.error("Failed to get metrics overview", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve metrics overview"
        )


@router.get("/users", response_model=UserAnalyticsResponse)
async def get_user_analytics(
    time_range: TimeRange = Query(TimeRange.WEEK, description="Time range for analysis"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:read", "users:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> UserAnalyticsResponse:
    """
    Get user analytics metrics.

    Provides detailed analytics about user behavior, registrations,
    activity patterns, and engagement metrics.

    Args:
        time_range: Time range for analysis
        current_user: Current authenticated user
        db: Database session

    Returns:
        UserAnalyticsResponse: User analytics data
    """
    logger.info("User analytics requested", user_id=current_user.id, time_range=time_range)

    try:
        analytics_service = AnalyticsService(db)

        # Get user analytics for the specified time range
        analytics_data = await analytics_service.get_user_analytics(time_range.value)

        return UserAnalyticsResponse(
            period=time_range.value,
            new_users=analytics_data.get('new_users', 0),
            active_users=analytics_data.get('active_users', 0),
            returning_users=analytics_data.get('returning_users', 0),
            user_retention_rate=analytics_data.get('user_retention_rate', 0.0),
            avg_session_duration=analytics_data.get('avg_session_duration', 0.0),
            most_active_hours=analytics_data.get('most_active_hours', []),
            geographic_distribution=analytics_data.get('geographic_distribution', {})
        )

    except Exception as e:
        logger.error("Failed to get user analytics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve user analytics"
        )


@router.get("/authentication", response_model=AuthenticationMetricsResponse)
async def get_authentication_metrics(
    time_range: TimeRange = Query(TimeRange.WEEK, description="Time range for analysis"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:read", "security:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> AuthenticationMetricsResponse:
    """
    Get authentication metrics.

    Provides detailed metrics about authentication attempts, success rates,
    security events, and authentication method usage.

    Args:
        time_range: Time range for analysis
        current_user: Current authenticated user
        db: Database session

    Returns:
        AuthenticationMetricsResponse: Authentication metrics data
    """
    logger.info("Authentication metrics requested", user_id=current_user.id, time_range=time_range)

    try:
        analytics_service = AnalyticsService(db)

        # Get authentication metrics for the specified time range
        auth_data = await analytics_service.get_authentication_metrics(time_range.value)

        return AuthenticationMetricsResponse(
            period=time_range.value,
            total_login_attempts=auth_data.get('total_login_attempts', 0),
            successful_logins=auth_data.get('successful_logins', 0),
            failed_logins=auth_data.get('failed_logins', 0),
            success_rate=auth_data.get('success_rate', 0.0),
            two_factor_usage=auth_data.get('two_factor_usage', 0.0),
            oauth_logins=auth_data.get('oauth_logins', 0),
            password_resets=auth_data.get('password_resets', 0),
            account_lockouts=auth_data.get('account_lockouts', 0),
            login_methods=auth_data.get('login_methods', {})
        )

    except Exception as e:
        logger.error("Failed to get authentication metrics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve authentication metrics"
        )


@router.get("/api-usage", response_model=APIUsageMetricsResponse)
async def get_api_usage_metrics(
    time_range: TimeRange = Query(TimeRange.WEEK, description="Time range for analysis"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:read", "api:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> APIUsageMetricsResponse:
    """
    Get API usage metrics.

    Provides detailed metrics about API usage patterns, endpoint popularity,
    performance statistics, and error rates.

    Args:
        time_range: Time range for analysis
        current_user: Current authenticated user
        db: Database session

    Returns:
        APIUsageMetricsResponse: API usage metrics data
    """
    logger.info("API usage metrics requested", user_id=current_user.id, time_range=time_range)

    try:
        analytics_service = AnalyticsService(db)

        # Get API usage metrics for the specified time range
        api_data = await analytics_service.get_api_usage_metrics(time_range.value)

        return APIUsageMetricsResponse(
            period=time_range.value,
            total_requests=api_data.get('total_requests', 0),
            unique_users=api_data.get('unique_users', 0),
            avg_requests_per_user=api_data.get('avg_requests_per_user', 0.0),
            most_used_endpoints=api_data.get('most_used_endpoints', []),
            error_rate=api_data.get('error_rate', 0.0),
            avg_response_time=api_data.get('avg_response_time', 0.0),
            rate_limit_hits=api_data.get('rate_limit_hits', 0),
            api_key_usage=api_data.get('api_key_usage', {})
        )

    except Exception as e:
        logger.error("Failed to get API usage metrics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve API usage metrics"
        )


@router.get("/security", response_model=SecurityMetricsResponse)
async def get_security_metrics(
    time_range: TimeRange = Query(TimeRange.WEEK, description="Time range for analysis"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:read", "security:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> SecurityMetricsResponse:
    """
    Get security metrics.

    Provides detailed security metrics including threat detection,
    authentication failures, and security event analysis.

    Args:
        time_range: Time range for analysis
        current_user: Current authenticated user
        db: Database session

    Returns:
        SecurityMetricsResponse: Security metrics data
    """
    logger.info("Security metrics requested", user_id=current_user.id, time_range=time_range)

    try:
        analytics_service = AnalyticsService(db)
        audit_service = AuditService(db)

        # Get security metrics for the specified time range
        security_data = await analytics_service.get_security_metrics(time_range.value)

        # Get additional audit data
        audit_data = await audit_service.get_security_event_summary(time_range.value)

        return SecurityMetricsResponse(
            period=time_range.value,
            security_events=security_data.get('security_events', 0),
            failed_auth_attempts=security_data.get('failed_auth_attempts', 0),
            suspicious_activities=security_data.get('suspicious_activities', 0),
            blocked_ips=security_data.get('blocked_ips', 0),
            csrf_violations=security_data.get('csrf_violations', 0),
            rate_limit_violations=security_data.get('rate_limit_violations', 0),
            password_breach_detections=security_data.get('password_breach_detections', 0),
            event_types=audit_data.get('event_types', {})
        )

    except Exception as e:
        logger.error("Failed to get security metrics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve security metrics"
        )


@router.get("/performance", response_model=SystemPerformanceResponse)
async def get_system_performance_metrics(
    time_range: TimeRange = Query(TimeRange.WEEK, description="Time range for analysis"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:read", "system:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> SystemPerformanceResponse:
    """
    Get system performance metrics.

    Provides detailed system performance metrics including response times,
    error rates, resource utilization, and database performance.

    Args:
        time_range: Time range for analysis
        current_user: Current authenticated user
        db: Database session

    Returns:
        SystemPerformanceResponse: System performance metrics data
    """
    logger.info("Performance metrics requested", user_id=current_user.id, time_range=time_range)

    try:
        analytics_service = AnalyticsService(db)

        # Get performance metrics for the specified time range
        perf_data = await analytics_service.get_performance_metrics(time_range.value)

        return SystemPerformanceResponse(
            period=time_range.value,
            avg_response_time=perf_data.get('avg_response_time', 0.0),
            p95_response_time=perf_data.get('p95_response_time', 0.0),
            p99_response_time=perf_data.get('p99_response_time', 0.0),
            error_rate=perf_data.get('error_rate', 0.0),
            throughput=perf_data.get('throughput', 0.0),
            database_performance=perf_data.get('database_performance', {}),
            cache_hit_rate=perf_data.get('cache_hit_rate', 0.0),
            memory_usage=perf_data.get('memory_usage', 0.0),
            cpu_usage=perf_data.get('cpu_usage', 0.0)
        )

    except Exception as e:
        logger.error("Failed to get performance metrics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve performance metrics"
        )


@router.get("/timeseries/{metric_type}", response_model=TimeSeriesResponse)
async def get_time_series_metrics(
    metric_type: MetricType,
    time_range: TimeRange = Query(TimeRange.DAY, description="Time range for data"),
    interval: str = Query("1h", description="Data interval (5m, 15m, 1h, 1d)"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:read"])),
    db: AsyncSession = Depends(get_db_session),
) -> TimeSeriesResponse:
    """
    Get time series metrics data.

    Provides time series data for specific metrics with configurable
    time ranges and intervals for charting and analysis.

    Args:
        metric_type: Type of metric to retrieve
        time_range: Time range for data
        interval: Data point interval
        current_user: Current authenticated user
        db: Database session

    Returns:
        TimeSeriesResponse: Time series metrics data
    """
    logger.info(
        "Time series metrics requested",
        user_id=current_user.id,
        metric_type=metric_type,
        time_range=time_range,
        interval=interval
    )

    try:
        analytics_service = AnalyticsService(db)

        # Get time series data
        series_data = await analytics_service.get_time_series_data(
            metric_type=metric_type.value,
            time_range=time_range.value,
            interval=interval
        )

        # Convert data points to required format
        data_points = [
            MetricDataPoint(
                timestamp=point['timestamp'],
                value=point['value'],
                metadata=point.get('metadata')
            )
            for point in series_data.get('data_points', [])
        ]

        return TimeSeriesResponse(
            metric_name=metric_type.value,
            period=time_range.value,
            data_points=data_points,
            summary=series_data.get('summary', {})
        )

    except Exception as e:
        logger.error("Failed to get time series metrics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve time series metrics"
        )


@router.get("/export/{metric_type}")
async def export_metrics(
    metric_type: MetricType,
    time_range: TimeRange = Query(TimeRange.MONTH, description="Time range for export"),
    format: str = Query("csv", description="Export format (csv, json, xlsx)"),
    current_user: CurrentUser = Depends(require_permissions(["metrics:export"])),
    db: AsyncSession = Depends(get_db_session),
) -> Dict[str, Any]:
    """
    Export metrics data.

    Exports metrics data in various formats for external analysis
    and reporting purposes.

    Args:
        metric_type: Type of metric to export
        time_range: Time range for export
        format: Export format
        current_user: Current authenticated user
        db: Database session

    Returns:
        Dict: Export information or download link
    """
    logger.info(
        "Metrics export requested",
        user_id=current_user.id,
        metric_type=metric_type,
        time_range=time_range,
        format=format
    )

    try:
        analytics_service = AnalyticsService(db)

        # Generate export
        export_result = await analytics_service.export_metrics_data(
            metric_type=metric_type.value,
            time_range=time_range.value,
            format=format,
            user_id=current_user.id
        )

        return {
            "export_id": export_result.get('export_id'),
            "download_url": export_result.get('download_url'),
            "expires_at": export_result.get('expires_at'),
            "file_size": export_result.get('file_size'),
            "record_count": export_result.get('record_count')
        }

    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        logger.error("Failed to export metrics", error=str(e))
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to export metrics data"
        )
