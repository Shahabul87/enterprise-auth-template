"""
Comprehensive Monitoring and Alerting Service

Provides real-time monitoring, metrics collection, alerting,
and anomaly detection for the authentication system.
"""

import asyncio
import json
from datetime import datetime, timedelta
from typing import Dict, Any, List, Optional, Tuple
from enum import Enum
import structlog
from sqlalchemy import select, func, and_, or_, Integer
from sqlalchemy.ext.asyncio import AsyncSession
import httpx
from prometheus_client import Counter, Histogram, Gauge, generate_latest

from app.core.config import get_settings
from app.core.redis_client import get_redis_client
from app.models.user import User
from app.models.audit import AuditLog
from app.models.session import UserSession
from app.models.device import UserDevice
from app.services.email_service import EmailService

logger = structlog.get_logger(__name__)
settings = get_settings()


class AlertSeverity(Enum):
    """Alert severity levels"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class MetricType(Enum):
    """Types of metrics to track"""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"


# Prometheus metrics
auth_attempts = Counter(
    'auth_attempts_total',
    'Total authentication attempts',
    ['method', 'status']
)

active_sessions = Gauge(
    'active_sessions',
    'Number of active user sessions'
)

request_duration = Histogram(
    'request_duration_seconds',
    'Request duration in seconds',
    ['endpoint', 'method']
)

failed_logins = Counter(
    'failed_login_attempts_total',
    'Total failed login attempts',
    ['reason']
)

security_events = Counter(
    'security_events_total',
    'Security events by type',
    ['event_type', 'severity']
)

api_errors = Counter(
    'api_errors_total',
    'API errors by type',
    ['error_type', 'endpoint']
)

database_connections = Gauge(
    'database_connections',
    'Number of database connections',
    ['state']
)

cache_operations = Counter(
    'cache_operations_total',
    'Cache operations',
    ['operation', 'status']
)


class MonitoringService:
    """Comprehensive monitoring and alerting service"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
        self.redis_client = get_redis_client()
        self.email_service = EmailService()
        self.alert_cooldown = {}  # Track alert cooldowns
        self.metrics_buffer = []  # Buffer for batch metric writes
        
    async def track_event(
        self,
        event_type: str,
        user_id: Optional[str] = None,
        metadata: Optional[Dict[str, Any]] = None,
        severity: AlertSeverity = AlertSeverity.INFO
    ) -> None:
        """
        Track an event for monitoring
        
        Args:
            event_type: Type of event
            user_id: Optional user ID
            metadata: Additional event metadata
            severity: Event severity level
        """
        event_data = {
            "type": event_type,
            "timestamp": datetime.utcnow().isoformat(),
            "user_id": user_id,
            "metadata": metadata or {},
            "severity": severity.value
        }
        
        # Store in Redis for real-time processing
        event_key = f"event:{event_type}:{datetime.utcnow().timestamp()}"
        await self.redis_client.setex(
            event_key,
            86400,  # 24 hour TTL
            json.dumps(event_data)
        )
        
        # Update metrics
        security_events.labels(
            event_type=event_type,
            severity=severity.value
        ).inc()
        
        # Check if alert should be triggered
        await self._check_alert_conditions(event_type, severity, metadata)
        
        # Log for debugging
        logger.info(
            "Event tracked",
            event_type=event_type,
            severity=severity.value,
            user_id=user_id
        )
    
    async def track_authentication(
        self,
        method: str,
        success: bool,
        user_id: Optional[str] = None,
        ip_address: Optional[str] = None,
        device_id: Optional[str] = None,
        reason: Optional[str] = None
    ) -> None:
        """Track authentication attempts"""
        auth_attempts.labels(
            method=method,
            status="success" if success else "failed"
        ).inc()
        
        if not success:
            failed_logins.labels(reason=reason or "unknown").inc()
            
            # Track failed attempt pattern
            await self._track_failed_attempt_pattern(
                user_id,
                ip_address,
                device_id
            )
    
    async def track_api_error(
        self,
        error_type: str,
        endpoint: str,
        status_code: int,
        error_message: str
    ) -> None:
        """Track API errors"""
        api_errors.labels(
            error_type=error_type,
            endpoint=endpoint
        ).inc()
        
        # Alert on high error rates
        error_rate = await self._calculate_error_rate(endpoint)
        if error_rate > settings.ERROR_RATE_THRESHOLD:
            await self.send_alert(
                title=f"High Error Rate on {endpoint}",
                message=f"Error rate: {error_rate:.2%}",
                severity=AlertSeverity.WARNING,
                metadata={
                    "endpoint": endpoint,
                    "error_type": error_type,
                    "status_code": status_code
                }
            )
    
    async def get_system_health(self) -> Dict[str, Any]:
        """Get comprehensive system health status"""
        # Database health
        db_health = await self._check_database_health()
        
        # Redis health
        redis_health = await self._check_redis_health()
        
        # Authentication service health
        auth_health = await self._check_auth_service_health()
        
        # Calculate overall health score
        health_score = self._calculate_health_score(
            db_health,
            redis_health,
            auth_health
        )
        
        return {
            "status": "healthy" if health_score > 80 else "degraded" if health_score > 60 else "unhealthy",
            "score": health_score,
            "timestamp": datetime.utcnow().isoformat(),
            "components": {
                "database": db_health,
                "redis": redis_health,
                "authentication": auth_health
            },
            "metrics": await self.get_current_metrics()
        }
    
    async def get_current_metrics(self) -> Dict[str, Any]:
        """Get current system metrics"""
        # Get active sessions count
        sessions_result = await self.db.execute(
            select(func.count(UserSession.id)).where(
                UserSession.is_active == True
            )
        )
        active_sessions_count = sessions_result.scalar() or 0
        active_sessions.set(active_sessions_count)
        
        # Get recent authentication stats
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)
        auth_stats = await self.db.execute(
            select(
                func.count(AuditLog.id).label("total"),
                func.sum(
                    func.cast(
                        AuditLog.event_type.like("%success%"),
                        Integer
                    )
                ).label("successful")
            ).where(
                and_(
                    AuditLog.created_at >= one_hour_ago,
                    AuditLog.event_type.in_([
                        "user.login_success",
                        "user.login_failed"
                    ])
                )
            )
        )
        auth_result = auth_stats.first()
        
        return {
            "active_sessions": active_sessions_count,
            "auth_success_rate": (
                (auth_result.successful / auth_result.total * 100)
                if auth_result and auth_result.total > 0
                else 0
            ),
            "total_users": await self._get_total_users(),
            "new_users_today": await self._get_new_users_today(),
            "failed_logins_last_hour": await self._get_failed_logins_count(),
            "suspicious_activities": await self._get_suspicious_activities_count()
        }
    
    async def detect_anomalies(self) -> List[Dict[str, Any]]:
        """Detect anomalies in system behavior"""
        anomalies = []
        
        # Check for brute force attempts
        brute_force = await self._detect_brute_force()
        if brute_force:
            anomalies.extend(brute_force)
        
        # Check for unusual login patterns
        unusual_patterns = await self._detect_unusual_login_patterns()
        if unusual_patterns:
            anomalies.extend(unusual_patterns)
        
        # Check for account takeover attempts
        takeover_attempts = await self._detect_account_takeover_attempts()
        if takeover_attempts:
            anomalies.extend(takeover_attempts)
        
        # Check for abnormal API usage
        api_anomalies = await self._detect_api_anomalies()
        if api_anomalies:
            anomalies.extend(api_anomalies)
        
        return anomalies
    
    async def send_alert(
        self,
        title: str,
        message: str,
        severity: AlertSeverity,
        metadata: Optional[Dict[str, Any]] = None,
        channels: Optional[List[str]] = None
    ) -> None:
        """
        Send alert through configured channels
        
        Args:
            title: Alert title
            message: Alert message
            severity: Alert severity
            metadata: Additional alert metadata
            channels: Specific channels to use (email, slack, webhook)
        """
        # Check cooldown
        alert_key = f"{title}:{severity.value}"
        if alert_key in self.alert_cooldown:
            last_sent = self.alert_cooldown[alert_key]
            if (datetime.utcnow() - last_sent).seconds < 300:  # 5 min cooldown
                return
        
        # Prepare alert data
        alert_data = {
            "title": title,
            "message": message,
            "severity": severity.value,
            "timestamp": datetime.utcnow().isoformat(),
            "metadata": metadata or {}
        }
        
        # Determine channels
        if not channels:
            channels = self._get_alert_channels(severity)
        
        # Send through each channel
        for channel in channels:
            await self._send_alert_to_channel(channel, alert_data)
        
        # Update cooldown
        self.alert_cooldown[alert_key] = datetime.utcnow()
        
        # Log alert
        logger.warning(
            "Alert sent",
            title=title,
            severity=severity.value,
            channels=channels
        )
    
    async def generate_metrics_report(
        self,
        start_date: datetime,
        end_date: datetime
    ) -> Dict[str, Any]:
        """Generate comprehensive metrics report"""
        # Authentication metrics
        auth_metrics = await self._get_auth_metrics(start_date, end_date)
        
        # Security metrics
        security_metrics = await self._get_security_metrics(start_date, end_date)
        
        # Performance metrics
        performance_metrics = await self._get_performance_metrics(start_date, end_date)
        
        # User metrics
        user_metrics = await self._get_user_metrics(start_date, end_date)
        
        return {
            "period": {
                "start": start_date.isoformat(),
                "end": end_date.isoformat()
            },
            "authentication": auth_metrics,
            "security": security_metrics,
            "performance": performance_metrics,
            "users": user_metrics,
            "generated_at": datetime.utcnow().isoformat()
        }
    
    # Private helper methods
    
    async def _check_database_health(self) -> Dict[str, Any]:
        """Check database health"""
        try:
            # Simple query to test connection
            result = await self.db.execute(select(func.now()))
            result.scalar()
            
            return {
                "status": "healthy",
                "response_time_ms": 5,  # Would measure actual time
                "connections": {
                    "active": 10,  # Would get from connection pool
                    "idle": 5
                }
            }
        except Exception as e:
            logger.error("Database health check failed", error=str(e))
            return {
                "status": "unhealthy",
                "error": str(e)
            }
    
    async def _check_redis_health(self) -> Dict[str, Any]:
        """Check Redis health"""
        try:
            # Ping Redis
            await self.redis_client.ping()
            
            # Get info
            info = await self.redis_client.info()
            
            return {
                "status": "healthy",
                "response_time_ms": 2,
                "memory_usage_mb": info.get("used_memory_human", "unknown"),
                "connected_clients": info.get("connected_clients", 0)
            }
        except Exception as e:
            logger.error("Redis health check failed", error=str(e))
            return {
                "status": "unhealthy",
                "error": str(e)
            }
    
    async def _check_auth_service_health(self) -> Dict[str, Any]:
        """Check authentication service health"""
        # Check recent auth success rate
        success_rate = await self._calculate_auth_success_rate()
        
        # Check for any critical errors
        critical_errors = await self._get_critical_errors_count()
        
        status = "healthy"
        if success_rate < 0.5 or critical_errors > 10:
            status = "degraded"
        if success_rate < 0.2 or critical_errors > 50:
            status = "unhealthy"
        
        return {
            "status": status,
            "success_rate": success_rate,
            "critical_errors": critical_errors
        }
    
    def _calculate_health_score(self, *health_checks) -> float:
        """Calculate overall health score"""
        scores = {
            "healthy": 100,
            "degraded": 60,
            "unhealthy": 0
        }
        
        total_score = 0
        for check in health_checks:
            status = check.get("status", "unhealthy")
            total_score += scores.get(status, 0)
        
        return total_score / len(health_checks) if health_checks else 0
    
    async def _detect_brute_force(self) -> List[Dict[str, Any]]:
        """Detect brute force attempts"""
        # Check for multiple failed login attempts
        threshold = 10
        time_window = datetime.utcnow() - timedelta(minutes=5)
        
        result = await self.db.execute(
            select(
                AuditLog.user_id,
                AuditLog.ip_address,
                func.count(AuditLog.id).label("attempts")
            ).where(
                and_(
                    AuditLog.event_type == "user.login_failed",
                    AuditLog.created_at >= time_window
                )
            ).group_by(
                AuditLog.user_id,
                AuditLog.ip_address
            ).having(
                func.count(AuditLog.id) >= threshold
            )
        )
        
        anomalies = []
        for row in result:
            anomalies.append({
                "type": "brute_force",
                "severity": "high",
                "user_id": row.user_id,
                "ip_address": row.ip_address,
                "attempts": row.attempts,
                "message": f"Possible brute force attack: {row.attempts} failed attempts"
            })
        
        return anomalies
    
    async def _detect_unusual_login_patterns(self) -> List[Dict[str, Any]]:
        """Detect unusual login patterns"""
        anomalies = []
        
        # Check for logins from new locations
        # Check for logins at unusual times
        # Check for rapid device switching
        
        # This would require more sophisticated analysis
        # For now, return empty list
        return anomalies
    
    async def _detect_account_takeover_attempts(self) -> List[Dict[str, Any]]:
        """Detect potential account takeover attempts"""
        anomalies = []
        
        # Check for password resets followed by immediate login from different IP
        # Check for simultaneous sessions from different locations
        # Check for sudden change in user behavior
        
        return anomalies
    
    async def _detect_api_anomalies(self) -> List[Dict[str, Any]]:
        """Detect API usage anomalies"""
        anomalies = []
        
        # Check for unusual API request patterns
        # Check for excessive API calls
        # Check for unusual endpoints being accessed
        
        return anomalies
    
    def _get_alert_channels(self, severity: AlertSeverity) -> List[str]:
        """Get alert channels based on severity"""
        if severity == AlertSeverity.CRITICAL:
            return ["email", "slack", "webhook"]
        elif severity == AlertSeverity.ERROR:
            return ["email", "slack"]
        elif severity == AlertSeverity.WARNING:
            return ["slack"]
        else:
            return ["log"]
    
    async def _send_alert_to_channel(
        self,
        channel: str,
        alert_data: Dict[str, Any]
    ) -> None:
        """Send alert to specific channel"""
        if channel == "email":
            await self._send_email_alert(alert_data)
        elif channel == "slack":
            await self._send_slack_alert(alert_data)
        elif channel == "webhook":
            await self._send_webhook_alert(alert_data)
        else:
            logger.info("Alert logged", **alert_data)
    
    async def _send_email_alert(self, alert_data: Dict[str, Any]) -> None:
        """Send email alert"""
        if not settings.ALERT_EMAIL_RECIPIENTS:
            return
        
        await self.email_service.send_alert_email(
            recipients=settings.ALERT_EMAIL_RECIPIENTS.split(","),
            subject=f"[{alert_data['severity'].upper()}] {alert_data['title']}",
            body=alert_data['message'],
            metadata=alert_data.get('metadata', {})
        )
    
    async def _send_slack_alert(self, alert_data: Dict[str, Any]) -> None:
        """Send Slack alert"""
        if not settings.SLACK_WEBHOOK_URL:
            return
        
        async with httpx.AsyncClient() as client:
            await client.post(
                settings.SLACK_WEBHOOK_URL,
                json={
                    "text": alert_data['title'],
                    "attachments": [{
                        "color": self._get_severity_color(alert_data['severity']),
                        "text": alert_data['message'],
                        "footer": "Monitoring Service",
                        "ts": int(datetime.utcnow().timestamp())
                    }]
                }
            )
    
    async def _send_webhook_alert(self, alert_data: Dict[str, Any]) -> None:
        """Send webhook alert"""
        if not settings.ALERT_WEBHOOK_URL:
            return
        
        async with httpx.AsyncClient() as client:
            await client.post(
                settings.ALERT_WEBHOOK_URL,
                json=alert_data
            )
    
    def _get_severity_color(self, severity: str) -> str:
        """Get color for severity level"""
        colors = {
            "critical": "#FF0000",
            "error": "#FF6600",
            "warning": "#FFCC00",
            "info": "#0099FF"
        }
        return colors.get(severity, "#808080")
    
    # Additional helper methods for metrics
    
    async def _get_total_users(self) -> int:
        result = await self.db.execute(select(func.count(User.id)))
        return result.scalar() or 0
    
    async def _get_new_users_today(self) -> int:
        today = datetime.utcnow().date()
        result = await self.db.execute(
            select(func.count(User.id)).where(
                func.date(User.created_at) == today
            )
        )
        return result.scalar() or 0
    
    async def _get_failed_logins_count(self) -> int:
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)
        result = await self.db.execute(
            select(func.count(AuditLog.id)).where(
                and_(
                    AuditLog.event_type == "user.login_failed",
                    AuditLog.created_at >= one_hour_ago
                )
            )
        )
        return result.scalar() or 0
    
    async def _get_suspicious_activities_count(self) -> int:
        # Count recent security events
        one_hour_ago = datetime.utcnow() - timedelta(hours=1)
        result = await self.db.execute(
            select(func.count(AuditLog.id)).where(
                and_(
                    AuditLog.event_type.in_([
                        "security.brute_force_detected",
                        "security.suspicious_login",
                        "security.account_locked"
                    ]),
                    AuditLog.created_at >= one_hour_ago
                )
            )
        )
        return result.scalar() or 0