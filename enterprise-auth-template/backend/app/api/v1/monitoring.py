"""
Monitoring and Alerting API Endpoints

Provides endpoints for system monitoring, metrics, health checks,
and alert management.
"""

from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any
import structlog
from fastapi import APIRouter, Depends, HTTPException, status, Query, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession
from prometheus_client import generate_latest
from fastapi.responses import PlainTextResponse
import asyncio

from app.core.database import get_db_session
from app.services.monitoring_service import MonitoringService, AlertSeverity
from app.dependencies.auth import require_admin, get_current_user
from app.schemas.response import StandardResponse
from app.models.user import User

logger = structlog.get_logger(__name__)
router = APIRouter(prefix="/monitoring", tags=["Monitoring"])


@router.get(
    "/health",
    response_model=StandardResponse[Dict[str, Any]],
    summary="Get system health status"
)
async def get_health_status(
    db: AsyncSession = Depends(get_db_session)
) -> StandardResponse[Dict[str, Any]]:
    """
    Get comprehensive system health status.
    
    Returns health scores for all system components.
    """
    monitoring_service = MonitoringService(db)
    health = await monitoring_service.get_system_health()
    
    return StandardResponse(
        success=True,
        data=health,
        message="System health retrieved successfully"
    )


@router.get(
    "/metrics",
    response_class=PlainTextResponse,
    summary="Get Prometheus metrics"
)
async def get_prometheus_metrics() -> PlainTextResponse:
    """
    Get system metrics in Prometheus format.
    
    Returns metrics that can be scraped by Prometheus.
    """
    metrics = generate_latest()
    return PlainTextResponse(
        content=metrics.decode("utf-8"),
        media_type="text/plain; charset=utf-8"
    )


@router.get(
    "/dashboard",
    response_model=StandardResponse[Dict[str, Any]],
    dependencies=[Depends(require_admin)],
    summary="Get monitoring dashboard data"
)
async def get_dashboard_data(
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_user)
) -> StandardResponse[Dict[str, Any]]:
    """
    Get comprehensive monitoring dashboard data.
    
    Requires admin privileges.
    """
    monitoring_service = MonitoringService(db)
    
    # Get current metrics
    metrics = await monitoring_service.get_current_metrics()
    
    # Get recent anomalies
    anomalies = await monitoring_service.detect_anomalies()
    
    # Get system health
    health = await monitoring_service.get_system_health()
    
    return StandardResponse(
        success=True,
        data={
            "metrics": metrics,
            "anomalies": anomalies,
            "health": health,
            "timestamp": datetime.utcnow().isoformat()
        },
        message="Dashboard data retrieved successfully"
    )


@router.get(
    "/anomalies",
    response_model=StandardResponse[List[Dict[str, Any]]],
    dependencies=[Depends(require_admin)],
    summary="Detect system anomalies"
)
async def detect_anomalies(
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_user)
) -> StandardResponse[List[Dict[str, Any]]]:
    """
    Detect and return system anomalies.
    
    Analyzes system behavior for suspicious patterns.
    """
    monitoring_service = MonitoringService(db)
    anomalies = await monitoring_service.detect_anomalies()
    
    # Send alerts for critical anomalies
    for anomaly in anomalies:
        if anomaly.get("severity") in ["high", "critical"]:
            await monitoring_service.send_alert(
                title=f"Anomaly Detected: {anomaly['type']}",
                message=anomaly.get("message", "Anomaly detected in system"),
                severity=AlertSeverity.WARNING,
                metadata=anomaly
            )
    
    return StandardResponse(
        success=True,
        data=anomalies,
        message=f"Found {len(anomalies)} anomalies"
    )


@router.post(
    "/alert",
    response_model=StandardResponse[Dict[str, str]],
    dependencies=[Depends(require_admin)],
    summary="Send manual alert"
)
async def send_alert(
    title: str,
    message: str,
    severity: str = "info",
    channels: Optional[List[str]] = None,
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_user)
) -> StandardResponse[Dict[str, str]]:
    """
    Send a manual alert through configured channels.
    
    Args:
        title: Alert title
        message: Alert message
        severity: Alert severity (info, warning, error, critical)
        channels: Specific channels to use
    """
    monitoring_service = MonitoringService(db)
    
    # Map string to enum
    severity_map = {
        "info": AlertSeverity.INFO,
        "warning": AlertSeverity.WARNING,
        "error": AlertSeverity.ERROR,
        "critical": AlertSeverity.CRITICAL
    }
    
    alert_severity = severity_map.get(severity.lower(), AlertSeverity.INFO)
    
    await monitoring_service.send_alert(
        title=title,
        message=message,
        severity=alert_severity,
        channels=channels,
        metadata={
            "sent_by": str(current_user.id),
            "sent_at": datetime.utcnow().isoformat()
        }
    )
    
    return StandardResponse(
        success=True,
        data={"status": "sent"},
        message="Alert sent successfully"
    )


@router.get(
    "/report",
    response_model=StandardResponse[Dict[str, Any]],
    dependencies=[Depends(require_admin)],
    summary="Generate metrics report"
)
async def generate_report(
    start_date: Optional[datetime] = Query(None, description="Start date for report"),
    end_date: Optional[datetime] = Query(None, description="End date for report"),
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_user)
) -> StandardResponse[Dict[str, Any]]:
    """
    Generate comprehensive metrics report for specified period.
    
    Args:
        start_date: Report start date (defaults to 7 days ago)
        end_date: Report end date (defaults to now)
    """
    # Default to last 7 days
    if not end_date:
        end_date = datetime.utcnow()
    if not start_date:
        start_date = end_date - timedelta(days=7)
    
    monitoring_service = MonitoringService(db)
    report = await monitoring_service.generate_metrics_report(start_date, end_date)
    
    return StandardResponse(
        success=True,
        data=report,
        message="Report generated successfully"
    )


@router.post(
    "/track",
    response_model=StandardResponse[Dict[str, str]],
    summary="Track custom event"
)
async def track_event(
    event_type: str,
    metadata: Optional[Dict[str, Any]] = None,
    severity: str = "info",
    db: AsyncSession = Depends(get_db_session),
    current_user: Optional[User] = Depends(get_current_user)
) -> StandardResponse[Dict[str, str]]:
    """
    Track a custom event for monitoring.
    
    Args:
        event_type: Type of event to track
        metadata: Additional event metadata
        severity: Event severity level
    """
    monitoring_service = MonitoringService(db)
    
    severity_map = {
        "info": AlertSeverity.INFO,
        "warning": AlertSeverity.WARNING,
        "error": AlertSeverity.ERROR,
        "critical": AlertSeverity.CRITICAL
    }
    
    await monitoring_service.track_event(
        event_type=event_type,
        user_id=str(current_user.id) if current_user else None,
        metadata=metadata,
        severity=severity_map.get(severity.lower(), AlertSeverity.INFO)
    )
    
    return StandardResponse(
        success=True,
        data={"status": "tracked"},
        message="Event tracked successfully"
    )


@router.get(
    "/alerts/test",
    response_model=StandardResponse[Dict[str, str]],
    dependencies=[Depends(require_admin)],
    summary="Test alert channels"
)
async def test_alert_channels(
    db: AsyncSession = Depends(get_db_session),
    current_user: User = Depends(get_current_user)
) -> StandardResponse[Dict[str, str]]:
    """
    Test all configured alert channels.
    
    Sends test alerts to verify channel configuration.
    """
    monitoring_service = MonitoringService(db)
    
    # Test each channel
    channels = ["email", "slack", "webhook"]
    results = {}
    
    for channel in channels:
        try:
            await monitoring_service.send_alert(
                title="Test Alert",
                message=f"This is a test alert for {channel} channel",
                severity=AlertSeverity.INFO,
                channels=[channel],
                metadata={
                    "test": True,
                    "initiated_by": str(current_user.id)
                }
            )
            results[channel] = "success"
        except Exception as e:
            results[channel] = f"failed: {str(e)}"
            logger.error(f"Test alert failed for {channel}", error=str(e))
    
    return StandardResponse(
        success=True,
        data=results,
        message="Alert channel test completed"
    )


@router.websocket("/live")
async def websocket_monitoring(
    websocket: WebSocket,
    db: AsyncSession = Depends(get_db_session)
):
    """
    WebSocket endpoint for live monitoring data.
    
    Streams real-time metrics and alerts.
    """
    await websocket.accept()
    monitoring_service = MonitoringService(db)
    
    try:
        while True:
            # Send metrics every 5 seconds
            metrics = await monitoring_service.get_current_metrics()
            await websocket.send_json({
                "type": "metrics",
                "data": metrics,
                "timestamp": datetime.utcnow().isoformat()
            })
            
            # Check for anomalies
            anomalies = await monitoring_service.detect_anomalies()
            if anomalies:
                await websocket.send_json({
                    "type": "anomalies",
                    "data": anomalies,
                    "timestamp": datetime.utcnow().isoformat()
                })
            
            await asyncio.sleep(5)
            
    except WebSocketDisconnect:
        logger.info("WebSocket client disconnected")
    except Exception as e:
        logger.error("WebSocket error", error=str(e))
        await websocket.close()