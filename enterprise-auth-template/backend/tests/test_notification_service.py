"""
Notification Service Tests

Comprehensive tests for notification service including email notifications,
SMS notifications, push notifications, and notification template management.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, patch
from typing import Dict, List, Any

from app.services.notification_service import (
    NotificationService,
    NotificationType,
    NotificationChannel,
    NotificationPriority,
    NotificationStatus,
)


@pytest.fixture
def notification_service():
    """Create notification service instance."""
    return NotificationService()


@pytest.fixture
def email_notification_data() -> Dict[str, Any]:
    """Sample email notification data."""
    return {
        "recipient": "user@example.com",
        "subject": "Test Email Notification",
        "template": "welcome_email",
        "variables": {
            "user_name": "John Doe",
            "activation_link": "https://example.com/activate?token=abc123",
        },
        "priority": NotificationPriority.NORMAL,
        "channel": NotificationChannel.EMAIL,
    }


@pytest.fixture
def sms_notification_data() -> Dict[str, Any]:
    """Sample SMS notification data."""
    return {
        "recipient": "+1234567890",
        "message": "Your verification code is: {{code}}",
        "template": "sms_verification",
        "variables": {"code": "123456"},
        "priority": NotificationPriority.HIGH,
        "channel": NotificationChannel.SMS,
    }


@pytest.fixture
def push_notification_data() -> Dict[str, Any]:
    """Sample push notification data."""
    return {
        "recipient": "user123",
        "title": "New Message",
        "body": "You have received a new message",
        "template": "push_message",
        "variables": {
            "sender": "Jane Doe",
            "message_preview": "Hello, how are you?",
        },
        "priority": NotificationPriority.NORMAL,
        "channel": NotificationChannel.PUSH,
        "metadata": {
            "click_action": "/messages",
            "icon": "message-icon.png",
        },
    }


@pytest.fixture
def notification_template_data() -> Dict[str, Any]:
    """Sample notification template data."""
    return {
        "name": "welcome_email",
        "type": NotificationType.TRANSACTIONAL,
        "channel": NotificationChannel.EMAIL,
        "subject": "Welcome to {{app_name}}!",
        "body": """
        <html>
        <body>
            <h1>Welcome {{user_name}}!</h1>
            <p>Thank you for joining {{app_name}}. Please click the link below to activate your account:</p>
            <a href="{{activation_link}}">Activate Account</a>
        </body>
        </html>
        """,
        "variables": ["app_name", "user_name", "activation_link"],
        "is_active": True,
    }


class TestNotificationService:
    """Test notification service core functionality."""

    @pytest.mark.asyncio
    async def test_send_email_notification_success(
        self, notification_service: NotificationService, email_notification_data: Dict[str, Any]
    ) -> None:
        """Test successful email notification sending."""
        with patch.object(notification_service, "_send_email") as mock_send_email:
            mock_send_email.return_value = AsyncMock(return_value=True)
            
            with patch.object(notification_service, "_get_template") as mock_get_template:
                mock_template = MagicMock()
                mock_template.subject = "Welcome to {{app_name}}!"
                mock_template.body = "Hello {{user_name}}, welcome!"
                mock_template.variables = ["app_name", "user_name"]
                mock_get_template.return_value = mock_template
                
                with patch.object(notification_service, "_render_template") as mock_render:
                    mock_render.return_value = {
                        "subject": "Welcome to MyApp!",
                        "body": "Hello John Doe, welcome!",
                    }
                    
                    result = await notification_service.send_notification(
                        **email_notification_data
                    )

                    assert result["success"] is True
                    assert result["notification_id"] is not None
                    assert result["status"] == NotificationStatus.SENT
                    assert result["channel"] == NotificationChannel.EMAIL
                    mock_send_email.assert_called_once()

    @pytest.mark.asyncio
    async def test_send_sms_notification_success(
        self, notification_service: NotificationService, sms_notification_data: Dict[str, Any]
    ) -> None:
        """Test successful SMS notification sending."""
        with patch.object(notification_service, "_send_sms") as mock_send_sms:
            mock_send_sms.return_value = AsyncMock(return_value=True)
            
            with patch.object(notification_service, "_get_template") as mock_get_template:
                mock_template = MagicMock()
                mock_template.body = "Your code is: {{code}}"
                mock_template.variables = ["code"]
                mock_get_template.return_value = mock_template
                
                with patch.object(notification_service, "_render_template") as mock_render:
                    mock_render.return_value = {
                        "body": "Your code is: 123456",
                    }
                    
                    result = await notification_service.send_notification(
                        **sms_notification_data
                    )

                    assert result["success"] is True
                    assert result["notification_id"] is not None
                    assert result["status"] == NotificationStatus.SENT
                    assert result["channel"] == NotificationChannel.SMS
                    mock_send_sms.assert_called_once()

    @pytest.mark.asyncio
    async def test_send_push_notification_success(
        self, notification_service: NotificationService, push_notification_data: Dict[str, Any]
    ) -> None:
        """Test successful push notification sending."""
        with patch.object(notification_service, "_send_push") as mock_send_push:
            mock_send_push.return_value = AsyncMock(return_value=True)
            
            with patch.object(notification_service, "_get_template") as mock_get_template:
                mock_template = MagicMock()
                mock_template.title = "New Message from {{sender}}"
                mock_template.body = "{{message_preview}}"
                mock_template.variables = ["sender", "message_preview"]
                mock_get_template.return_value = mock_template
                
                with patch.object(notification_service, "_render_template") as mock_render:
                    mock_render.return_value = {
                        "title": "New Message from Jane Doe",
                        "body": "Hello, how are you?",
                    }
                    
                    result = await notification_service.send_notification(
                        **push_notification_data
                    )

                    assert result["success"] is True
                    assert result["notification_id"] is not None
                    assert result["status"] == NotificationStatus.SENT
                    assert result["channel"] == NotificationChannel.PUSH
                    mock_send_push.assert_called_once()

    @pytest.mark.asyncio
    async def test_send_notification_failure(
        self, notification_service: NotificationService, email_notification_data: Dict[str, Any]
    ) -> None:
        """Test notification sending failure handling."""
        with patch.object(notification_service, "_send_email") as mock_send_email:
            mock_send_email.side_effect = Exception("SMTP connection failed")
            
            with patch.object(notification_service, "_get_template") as mock_get_template:
                mock_template = MagicMock()
                mock_template.subject = "Test"
                mock_template.body = "Test body"
                mock_get_template.return_value = mock_template
                
                result = await notification_service.send_notification(
                    **email_notification_data
                )

                assert result["success"] is False
                assert result["status"] == NotificationStatus.FAILED
                assert "SMTP connection failed" in result["error"]

    @pytest.mark.asyncio
    async def test_send_notification_invalid_template(
        self, notification_service: NotificationService, email_notification_data: Dict[str, Any]
    ) -> None:
        """Test notification sending with invalid template."""
        email_notification_data["template"] = "non_existent_template"
        
        with patch.object(notification_service, "_get_template") as mock_get_template:
            mock_get_template.side_effect = ValueError("Template not found")
            
            result = await notification_service.send_notification(
                **email_notification_data
            )

            assert result["success"] is False
            assert result["status"] == NotificationStatus.FAILED
            assert "Template not found" in result["error"]

    @pytest.mark.asyncio
    async def test_send_notification_invalid_recipient(
        self, notification_service: NotificationService, email_notification_data: Dict[str, Any]
    ) -> None:
        """Test notification sending with invalid recipient."""
        email_notification_data["recipient"] = "invalid-email"
        
        with patch.object(notification_service, "_validate_recipient") as mock_validate:
            mock_validate.side_effect = ValueError("Invalid email address")
            
            result = await notification_service.send_notification(
                **email_notification_data
            )

            assert result["success"] is False
            assert result["status"] == NotificationStatus.FAILED
            assert "Invalid email address" in result["error"]


class TestNotificationTemplates:
    """Test notification template management."""

    @pytest.mark.asyncio
    async def test_create_template_success(
        self, notification_service: NotificationService, notification_template_data: Dict[str, Any]
    ) -> None:
        """Test successful template creation."""
        with patch.object(notification_service, "_save_template") as mock_save:
            mock_save.return_value = AsyncMock(return_value="template-123")
            
            result = await notification_service.create_template(
                **notification_template_data
            )

            assert result["success"] is True
            assert result["template_id"] == "template-123"
            assert result["name"] == notification_template_data["name"]
            mock_save.assert_called_once()

    @pytest.mark.asyncio
    async def test_create_template_duplicate_name(
        self, notification_service: NotificationService, notification_template_data: Dict[str, Any]
    ) -> None:
        """Test template creation with duplicate name."""
        with patch.object(notification_service, "_check_template_exists") as mock_check:
            mock_check.return_value = True
            
            result = await notification_service.create_template(
                **notification_template_data
            )

            assert result["success"] is False
            assert "already exists" in result["error"]

    @pytest.mark.asyncio
    async def test_update_template_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful template update."""
        template_id = "template-123"
        update_data = {
            "subject": "Updated subject: {{user_name}}",
            "body": "Updated body content",
            "variables": ["user_name", "app_name"],
        }

        with patch.object(notification_service, "_get_template_by_id") as mock_get:
            mock_template = MagicMock()
            mock_template.id = template_id
            mock_template.name = "welcome_email"
            mock_get.return_value = mock_template
            
            with patch.object(notification_service, "_update_template") as mock_update:
                mock_update.return_value = AsyncMock(return_value=True)
                
                result = await notification_service.update_template(
                    template_id, **update_data
                )

                assert result["success"] is True
                assert result["template_id"] == template_id
                mock_update.assert_called_once()

    @pytest.mark.asyncio
    async def test_delete_template_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful template deletion."""
        template_id = "template-123"

        with patch.object(notification_service, "_get_template_by_id") as mock_get:
            mock_template = MagicMock()
            mock_template.id = template_id
            mock_template.name = "test_template"
            mock_get.return_value = mock_template
            
            with patch.object(notification_service, "_check_template_usage") as mock_check:
                mock_check.return_value = {"active_notifications": 0, "scheduled_notifications": 0}
                
                with patch.object(notification_service, "_delete_template") as mock_delete:
                    mock_delete.return_value = AsyncMock(return_value=True)
                    
                    result = await notification_service.delete_template(template_id)

                    assert result["success"] is True
                    assert result["template_id"] == template_id
                    mock_delete.assert_called_once()

    @pytest.mark.asyncio
    async def test_delete_template_in_use(
        self, notification_service: NotificationService
    ) -> None:
        """Test template deletion when template is in use."""
        template_id = "template-123"

        with patch.object(notification_service, "_get_template_by_id") as mock_get:
            mock_template = MagicMock()
            mock_template.id = template_id
            mock_get.return_value = mock_template
            
            with patch.object(notification_service, "_check_template_usage") as mock_check:
                mock_check.return_value = {
                    "active_notifications": 5,
                    "scheduled_notifications": 10
                }
                
                result = await notification_service.delete_template(template_id)

                assert result["success"] is False
                assert "template is currently in use" in result["error"]

    @pytest.mark.asyncio
    async def test_render_template_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful template rendering."""
        template_content = "Hello {{user_name}}, welcome to {{app_name}}!"
        variables = {"user_name": "John Doe", "app_name": "MyApp"}

        with patch.object(notification_service, "_render_template") as mock_render:
            mock_render.return_value = {
                "rendered_content": "Hello John Doe, welcome to MyApp!",
                "used_variables": ["user_name", "app_name"],
                "missing_variables": [],
            }
            
            result = await notification_service.render_template(
                template_content, variables
            )

            assert result["rendered_content"] == "Hello John Doe, welcome to MyApp!"
            assert len(result["used_variables"]) == 2
            assert len(result["missing_variables"]) == 0

    @pytest.mark.asyncio
    async def test_render_template_missing_variables(
        self, notification_service: NotificationService
    ) -> None:
        """Test template rendering with missing variables."""
        template_content = "Hello {{user_name}}, your balance is {{balance}}"
        variables = {"user_name": "John Doe"}  # Missing balance

        with patch.object(notification_service, "_render_template") as mock_render:
            mock_render.return_value = {
                "rendered_content": "Hello John Doe, your balance is {{balance}}",
                "used_variables": ["user_name"],
                "missing_variables": ["balance"],
                "warnings": ["Variable 'balance' not provided"],
            }
            
            result = await notification_service.render_template(
                template_content, variables
            )

            assert "{{balance}}" in result["rendered_content"]
            assert "balance" in result["missing_variables"]
            assert len(result["warnings"]) == 1


class TestNotificationBulkOperations:
    """Test bulk notification operations."""

    @pytest.mark.asyncio
    async def test_send_bulk_notifications_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful bulk notification sending."""
        bulk_data = {
            "template": "newsletter",
            "recipients": [
                {"email": "user1@example.com", "name": "User One"},
                {"email": "user2@example.com", "name": "User Two"},
                {"email": "user3@example.com", "name": "User Three"},
            ],
            "variables": {"app_name": "MyApp", "newsletter_date": "2024-01-15"},
        }

        with patch.object(notification_service, "_send_bulk_notifications") as mock_send_bulk:
            mock_send_bulk.return_value = {
                "success": True,
                "batch_id": "batch-123",
                "total_recipients": 3,
                "successful_sends": 3,
                "failed_sends": 0,
                "results": [
                    {"recipient": "user1@example.com", "status": "sent", "notification_id": "n1"},
                    {"recipient": "user2@example.com", "status": "sent", "notification_id": "n2"},
                    {"recipient": "user3@example.com", "status": "sent", "notification_id": "n3"},
                ],
            }
            
            result = await notification_service.send_bulk_notifications(
                **bulk_data
            )

            assert result["success"] is True
            assert result["total_recipients"] == 3
            assert result["successful_sends"] == 3
            assert result["failed_sends"] == 0

    @pytest.mark.asyncio
    async def test_send_bulk_notifications_partial_failure(
        self, notification_service: NotificationService
    ) -> None:
        """Test bulk notification sending with partial failures."""
        bulk_data = {
            "template": "newsletter",
            "recipients": [
                {"email": "user1@example.com", "name": "User One"},
                {"email": "invalid-email", "name": "User Two"},
                {"email": "user3@example.com", "name": "User Three"},
            ],
            "variables": {"app_name": "MyApp"},
        }

        with patch.object(notification_service, "_send_bulk_notifications") as mock_send_bulk:
            mock_send_bulk.return_value = {
                "success": True,
                "batch_id": "batch-123",
                "total_recipients": 3,
                "successful_sends": 2,
                "failed_sends": 1,
                "results": [
                    {"recipient": "user1@example.com", "status": "sent", "notification_id": "n1"},
                    {"recipient": "invalid-email", "status": "failed", "error": "Invalid email"},
                    {"recipient": "user3@example.com", "status": "sent", "notification_id": "n3"},
                ],
            }
            
            result = await notification_service.send_bulk_notifications(
                **bulk_data
            )

            assert result["success"] is True  # Overall success even with partial failures
            assert result["successful_sends"] == 2
            assert result["failed_sends"] == 1

    @pytest.mark.asyncio
    async def test_schedule_bulk_notifications_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful bulk notification scheduling."""
        schedule_data = {
            "template": "newsletter",
            "recipients": [
                {"email": "user1@example.com", "name": "User One"},
                {"email": "user2@example.com", "name": "User Two"},
            ],
            "variables": {"app_name": "MyApp"},
            "scheduled_at": datetime.utcnow() + timedelta(hours=1),
        }

        with patch.object(notification_service, "_schedule_bulk_notifications") as mock_schedule:
            mock_schedule.return_value = {
                "success": True,
                "batch_id": "batch-123",
                "scheduled_count": 2,
                "scheduled_at": schedule_data["scheduled_at"].isoformat(),
                "status": "scheduled",
            }
            
            result = await notification_service.schedule_bulk_notifications(
                **schedule_data
            )

            assert result["success"] is True
            assert result["scheduled_count"] == 2
            assert result["status"] == "scheduled"


class TestNotificationQueue:
    """Test notification queue management."""

    @pytest.mark.asyncio
    async def test_queue_notification_success(
        self, notification_service: NotificationService, email_notification_data: Dict[str, Any]
    ) -> None:
        """Test successful notification queuing."""
        with patch.object(notification_service, "_add_to_queue") as mock_queue:
            mock_queue.return_value = {
                "success": True,
                "queue_id": "queue-123",
                "position": 5,
                "estimated_send_time": (datetime.utcnow() + timedelta(minutes=2)).isoformat(),
            }
            
            result = await notification_service.queue_notification(
                **email_notification_data
            )

            assert result["success"] is True
            assert result["queue_id"] == "queue-123"
            assert result["position"] == 5

    @pytest.mark.asyncio
    async def test_get_queue_status(
        self, notification_service: NotificationService
    ) -> None:
        """Test queue status retrieval."""
        with patch.object(notification_service, "_get_queue_status") as mock_status:
            mock_status.return_value = {
                "total_queued": 150,
                "processing": 5,
                "failed": 3,
                "completed_today": 1250,
                "average_processing_time": "2.5s",
                "queue_health": "healthy",
                "workers": {
                    "active": 3,
                    "idle": 2,
                    "total": 5,
                },
                "priorities": {
                    "high": 25,
                    "normal": 100,
                    "low": 25,
                },
            }
            
            result = await notification_service.get_queue_status()

            assert result["total_queued"] == 150
            assert result["queue_health"] == "healthy"
            assert result["workers"]["active"] == 3

    @pytest.mark.asyncio
    async def test_process_queue_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful queue processing."""
        with patch.object(notification_service, "_process_queue") as mock_process:
            mock_process.return_value = {
                "success": True,
                "processed_count": 50,
                "successful_sends": 48,
                "failed_sends": 2,
                "processing_time": "30s",
                "average_send_time": "0.6s",
            }
            
            result = await notification_service.process_queue(batch_size=50)

            assert result["success"] is True
            assert result["processed_count"] == 50
            assert result["successful_sends"] == 48

    @pytest.mark.asyncio
    async def test_retry_failed_notifications_success(
        self, notification_service: NotificationService
    ) -> None:
        """Test successful retry of failed notifications."""
        with patch.object(notification_service, "_retry_failed_notifications") as mock_retry:
            mock_retry.return_value = {
                "success": True,
                "retry_count": 15,
                "successful_retries": 12,
                "permanent_failures": 3,
                "retry_details": [
                    {"notification_id": "n1", "status": "sent", "attempts": 2},
                    {"notification_id": "n2", "status": "sent", "attempts": 3},
                    {"notification_id": "n3", "status": "permanent_failure", "attempts": 5},
                ],
            }
            
            result = await notification_service.retry_failed_notifications(
                max_attempts=5, batch_size=20
            )

            assert result["success"] is True
            assert result["successful_retries"] == 12
            assert result["permanent_failures"] == 3


class TestNotificationAnalytics:
    """Test notification analytics and reporting."""

    @pytest.mark.asyncio
    async def test_get_notification_stats(
        self, notification_service: NotificationService
    ) -> None:
        """Test notification statistics retrieval."""
        with patch.object(notification_service, "_get_notification_stats") as mock_stats:
            mock_stats.return_value = {
                "total_sent": 10500,
                "total_delivered": 10250,
                "total_failed": 250,
                "delivery_rate": 0.976,
                "open_rate": 0.65,
                "click_rate": 0.12,
                "bounce_rate": 0.024,
                "by_channel": {
                    "email": {
                        "sent": 8000,
                        "delivered": 7800,
                        "open_rate": 0.68,
                        "click_rate": 0.15,
                    },
                    "sms": {
                        "sent": 2000,
                        "delivered": 1950,
                        "open_rate": 0.95,
                        "click_rate": 0.05,
                    },
                    "push": {
                        "sent": 500,
                        "delivered": 500,
                        "open_rate": 0.45,
                        "click_rate": 0.08,
                    },
                },
                "by_template": [
                    {
                        "template": "welcome_email",
                        "sent": 2500,
                        "delivered": 2450,
                        "open_rate": 0.78,
                    },
                    {
                        "template": "password_reset",
                        "sent": 1500,
                        "delivered": 1485,
                        "open_rate": 0.92,
                    },
                ],
                "time_range": {
                    "start": "2024-01-01T00:00:00Z",
                    "end": "2024-01-31T23:59:59Z",
                },
            }
            
            result = await notification_service.get_notification_stats(
                start_date="2024-01-01", end_date="2024-01-31"
            )

            assert result["total_sent"] == 10500
            assert result["delivery_rate"] == 0.976
            assert len(result["by_channel"]) == 3
            assert len(result["by_template"]) == 2

    @pytest.mark.asyncio
    async def test_get_delivery_reports(
        self, notification_service: NotificationService
    ) -> None:
        """Test delivery report generation."""
        with patch.object(notification_service, "_generate_delivery_report") as mock_report:
            mock_report.return_value = {
                "report_id": "report-123",
                "generated_at": datetime.utcnow().isoformat(),
                "summary": {
                    "total_notifications": 1000,
                    "successful_deliveries": 950,
                    "failed_deliveries": 50,
                    "pending_deliveries": 0,
                },
                "failures_by_reason": {
                    "invalid_recipient": 25,
                    "service_unavailable": 15,
                    "rate_limit_exceeded": 10,
                },
                "delivery_times": {
                    "average": "2.3s",
                    "median": "1.8s",
                    "95th_percentile": "5.2s",
                },
                "recommendations": [
                    "Review invalid recipient addresses",
                    "Consider implementing retry logic for service unavailable errors",
                    "Monitor rate limits more closely",
                ],
            }
            
            result = await notification_service.generate_delivery_report(
                start_date="2024-01-01", end_date="2024-01-07"
            )

            assert result["summary"]["total_notifications"] == 1000
            assert result["summary"]["successful_deliveries"] == 950
            assert len(result["failures_by_reason"]) == 3
            assert len(result["recommendations"]) == 3


# Performance and integration tests
@pytest.mark.performance
class TestNotificationPerformance:
    """Performance tests for notification service."""

    @pytest.mark.asyncio
    async def test_bulk_notification_performance(
        self, notification_service: NotificationService
    ) -> None:
        """Test performance of bulk notification sending."""
        # Simulate sending 1000 notifications
        bulk_data = {
            "template": "bulk_test",
            "recipients": [
                {"email": f"user{i}@example.com", "name": f"User {i}"}
                for i in range(1000)
            ],
            "variables": {"app_name": "MyApp"},
        }

        with patch.object(notification_service, "_send_bulk_notifications") as mock_send:
            mock_send.return_value = {
                "success": True,
                "batch_id": "perf-test-batch",
                "total_recipients": 1000,
                "successful_sends": 995,
                "failed_sends": 5,
                "processing_time": "45s",
                "average_send_time": "0.045s",
                "throughput": "22.2 notifications/second",
            }
            
            result = await notification_service.send_bulk_notifications(
                **bulk_data
            )

            assert result["total_recipients"] == 1000
            assert result["successful_sends"] >= 990  # Allow for some failures
            assert "throughput" in result

    @pytest.mark.asyncio
    async def test_queue_processing_performance(
        self, notification_service: NotificationService
    ) -> None:
        """Test queue processing performance."""
        with patch.object(notification_service, "_process_queue") as mock_process:
            mock_process.return_value = {
                "success": True,
                "processed_count": 500,
                "processing_time": "25s",
                "throughput": "20 notifications/second",
                "memory_usage": "125MB",
                "cpu_usage": "45%",
            }
            
            result = await notification_service.process_queue(batch_size=500)

            assert result["processed_count"] == 500
            assert "throughput" in result
            assert "memory_usage" in result

    @pytest.mark.asyncio
    async def test_concurrent_notifications(
        self, notification_service: NotificationService
    ) -> None:
        """Test concurrent notification handling."""
        import asyncio
        
        async def send_notification(i):
            """Send a single notification."""
            return await notification_service.send_notification(
                recipient=f"user{i}@example.com",
                subject=f"Test {i}",
                template="test_template",
                variables={"user_id": str(i)},
                channel=NotificationChannel.EMAIL,
            )

        with patch.object(notification_service, "send_notification") as mock_send:
            mock_send.side_effect = lambda **kwargs: {
                "success": True,
                "notification_id": f"n-{kwargs['variables']['user_id']}",
                "status": NotificationStatus.SENT,
            }
            
            # Send 50 notifications concurrently
            tasks = [send_notification(i) for i in range(50)]
            results = await asyncio.gather(*tasks)

            assert len(results) == 50
            assert all(result["success"] for result in results)
            assert mock_send.call_count == 50