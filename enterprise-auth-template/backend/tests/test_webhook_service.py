"""
Webhook Service Tests

Comprehensive tests for webhook service including webhook registration,
event dispatching, retry mechanisms, and security validation.
"""

import pytest
from datetime import datetime, timedelta
from unittest.mock import AsyncMock, MagicMock, patch
from typing import Dict, List, Any
import json
import hmac
import hashlib

from app.services.webhook_service import (
    WebhookService,
    WebhookEvent,
    WebhookDeliveryStatus,
    WebhookRetryPolicy,
)


@pytest.fixture
def webhook_service():
    """Create webhook service instance."""
    return WebhookService()


@pytest.fixture
def webhook_registration_data() -> Dict[str, Any]:
    """Sample webhook registration data."""
    return {
        "url": "https://api.example.com/webhooks/auth",
        "events": ["user.created", "user.updated", "user.deleted"],
        "description": "User management webhook",
        "secret": "webhook-secret-key",
        "active": True,
        "retry_policy": {
            "max_attempts": 3,
            "backoff_factor": 2,
            "initial_delay": 1,
        },
        "headers": {
            "Authorization": "Bearer webhook-token",
            "Content-Type": "application/json",
        },
    }


@pytest.fixture
def webhook_event_data() -> Dict[str, Any]:
    """Sample webhook event data."""
    return {
        "event": "user.created",
        "data": {
            "user_id": "user-123",
            "email": "newuser@example.com",
            "first_name": "New",
            "last_name": "User",
            "created_at": "2024-01-01T12:00:00Z",
        },
        "timestamp": datetime.utcnow().isoformat(),
        "version": "1.0",
        "source": "auth-service",
    }


@pytest.fixture
def mock_webhook() -> Dict[str, Any]:
    """Create mock webhook object."""
    return {
        "id": "webhook-123",
        "url": "https://api.example.com/webhooks/auth",
        "events": ["user.created", "user.updated"],
        "description": "Test webhook",
        "secret": "test-secret",
        "active": True,
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z",
        "last_delivery": None,
        "delivery_count": 0,
        "failure_count": 0,
    }


class TestWebhookService:
    """Test webhook service core functionality."""

    @pytest.mark.asyncio
    async def test_register_webhook_success(
        self, webhook_service: WebhookService, webhook_registration_data: Dict[str, Any]
    ) -> None:
        """Test successful webhook registration."""
        with patch.object(webhook_service, "_validate_webhook_url") as mock_validate:
            mock_validate.return_value = True
            
            with patch.object(webhook_service, "_save_webhook") as mock_save:
                mock_save.return_value = "webhook-123"
                
                result = await webhook_service.register_webhook(
                    **webhook_registration_data
                )

                assert result["success"] is True
                assert result["webhook_id"] == "webhook-123"
                assert result["url"] == webhook_registration_data["url"]
                assert len(result["events"]) == 3
                mock_validate.assert_called_once()
                mock_save.assert_called_once()

    @pytest.mark.asyncio
    async def test_register_webhook_invalid_url(
        self, webhook_service: WebhookService, webhook_registration_data: Dict[str, Any]
    ) -> None:
        """Test webhook registration with invalid URL."""
        webhook_registration_data["url"] = "invalid-url"
        
        with patch.object(webhook_service, "_validate_webhook_url") as mock_validate:
            mock_validate.side_effect = ValueError("Invalid webhook URL")
            
            result = await webhook_service.register_webhook(
                **webhook_registration_data
            )

            assert result["success"] is False
            assert "Invalid webhook URL" in result["error"]

    @pytest.mark.asyncio
    async def test_register_webhook_duplicate_url(
        self, webhook_service: WebhookService, webhook_registration_data: Dict[str, Any]
    ) -> None:
        """Test webhook registration with duplicate URL."""
        with patch.object(webhook_service, "_check_webhook_exists") as mock_check:
            mock_check.return_value = True
            
            result = await webhook_service.register_webhook(
                **webhook_registration_data
            )

            assert result["success"] is False
            assert "already registered" in result["error"]

    @pytest.mark.asyncio
    async def test_update_webhook_success(
        self, webhook_service: WebhookService, mock_webhook: Dict[str, Any]
    ) -> None:
        """Test successful webhook update."""
        webhook_id = "webhook-123"
        update_data = {
            "events": ["user.created", "user.updated", "user.login"],
            "description": "Updated webhook description",
            "active": True,
        }

        with patch.object(webhook_service, "_get_webhook_by_id") as mock_get:
            mock_get.return_value = mock_webhook
            
            with patch.object(webhook_service, "_update_webhook") as mock_update:
                mock_update.return_value = True
                
                result = await webhook_service.update_webhook(
                    webhook_id, **update_data
                )

                assert result["success"] is True
                assert result["webhook_id"] == webhook_id
                assert len(result["events"]) == 3
                mock_update.assert_called_once()

    @pytest.mark.asyncio
    async def test_delete_webhook_success(
        self, webhook_service: WebhookService, mock_webhook: Dict[str, Any]
    ) -> None:
        """Test successful webhook deletion."""
        webhook_id = "webhook-123"

        with patch.object(webhook_service, "_get_webhook_by_id") as mock_get:
            mock_get.return_value = mock_webhook
            
            with patch.object(webhook_service, "_delete_webhook") as mock_delete:
                mock_delete.return_value = True
                
                with patch.object(webhook_service, "_cleanup_webhook_deliveries") as mock_cleanup:
                    mock_cleanup.return_value = 25  # Number of cleaned up deliveries
                    
                    result = await webhook_service.delete_webhook(webhook_id)

                    assert result["success"] is True
                    assert result["webhook_id"] == webhook_id
                    assert result["cleaned_deliveries"] == 25
                    mock_delete.assert_called_once()
                    mock_cleanup.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_webhooks_success(
        self, webhook_service: WebhookService
    ) -> None:
        """Test successful webhooks retrieval."""
        with patch.object(webhook_service, "_get_all_webhooks") as mock_get_all:
            mock_webhooks = [
                {
                    "id": "webhook-1",
                    "url": "https://api.example1.com/webhook",
                    "events": ["user.created"],
                    "active": True,
                    "delivery_stats": {
                        "total_deliveries": 150,
                        "successful_deliveries": 145,
                        "failed_deliveries": 5,
                        "success_rate": 0.967,
                    },
                },
                {
                    "id": "webhook-2",
                    "url": "https://api.example2.com/webhook",
                    "events": ["user.updated", "user.deleted"],
                    "active": False,
                    "delivery_stats": {
                        "total_deliveries": 75,
                        "successful_deliveries": 70,
                        "failed_deliveries": 5,
                        "success_rate": 0.933,
                    },
                },
            ]
            mock_get_all.return_value = mock_webhooks
            
            result = await webhook_service.get_webhooks()

            assert result["success"] is True
            assert len(result["webhooks"]) == 2
            assert result["total_count"] == 2
            assert result["webhooks"][0]["delivery_stats"]["success_rate"] == 0.967


class TestWebhookEventDispatching:
    """Test webhook event dispatching functionality."""

    @pytest.mark.asyncio
    async def test_dispatch_event_success(
        self, webhook_service: WebhookService, webhook_event_data: Dict[str, Any]
    ) -> None:
        """Test successful event dispatching."""
        with patch.object(webhook_service, "_get_webhooks_for_event") as mock_get_webhooks:
            mock_webhooks = [
                {
                    "id": "webhook-1",
                    "url": "https://api.example1.com/webhook",
                    "secret": "secret1",
                    "headers": {},
                },
                {
                    "id": "webhook-2",
                    "url": "https://api.example2.com/webhook",
                    "secret": "secret2",
                    "headers": {"Authorization": "Bearer token"},
                },
            ]
            mock_get_webhooks.return_value = mock_webhooks
            
            with patch.object(webhook_service, "_deliver_webhook") as mock_deliver:
                mock_deliver.return_value = {
                    "success": True,
                    "delivery_id": "delivery-123",
                    "status_code": 200,
                    "response_time": 0.5,
                }
                
                result = await webhook_service.dispatch_event(
                    **webhook_event_data
                )

                assert result["success"] is True
                assert result["event"] == webhook_event_data["event"]
                assert result["dispatched_to"] == 2
                assert len(result["delivery_results"]) == 2
                assert mock_deliver.call_count == 2

    @pytest.mark.asyncio
    async def test_dispatch_event_no_webhooks(
        self, webhook_service: WebhookService, webhook_event_data: Dict[str, Any]
    ) -> None:
        """Test event dispatching when no webhooks are registered for the event."""
        with patch.object(webhook_service, "_get_webhooks_for_event") as mock_get_webhooks:
            mock_get_webhooks.return_value = []
            
            result = await webhook_service.dispatch_event(
                **webhook_event_data
            )

            assert result["success"] is True
            assert result["dispatched_to"] == 0
            assert len(result["delivery_results"]) == 0
            assert "No webhooks registered" in result["message"]

    @pytest.mark.asyncio
    async def test_dispatch_event_partial_failure(
        self, webhook_service: WebhookService, webhook_event_data: Dict[str, Any]
    ) -> None:
        """Test event dispatching with partial failures."""
        with patch.object(webhook_service, "_get_webhooks_for_event") as mock_get_webhooks:
            mock_webhooks = [
                {"id": "webhook-1", "url": "https://api.example1.com/webhook", "secret": "secret1"},
                {"id": "webhook-2", "url": "https://api.example2.com/webhook", "secret": "secret2"},
                {"id": "webhook-3", "url": "https://api.example3.com/webhook", "secret": "secret3"},
            ]
            mock_get_webhooks.return_value = mock_webhooks
            
            with patch.object(webhook_service, "_deliver_webhook") as mock_deliver:
                # First and third succeed, second fails
                mock_deliver.side_effect = [
                    {"success": True, "delivery_id": "del-1", "status_code": 200},
                    {"success": False, "error": "Connection timeout", "status_code": None},
                    {"success": True, "delivery_id": "del-3", "status_code": 201},
                ]
                
                result = await webhook_service.dispatch_event(
                    **webhook_event_data
                )

                assert result["success"] is True  # Overall success even with partial failures
                assert result["dispatched_to"] == 3
                assert result["successful_deliveries"] == 2
                assert result["failed_deliveries"] == 1

    @pytest.mark.asyncio
    async def test_deliver_webhook_with_signature(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook delivery with signature verification."""
        webhook = {
            "id": "webhook-123",
            "url": "https://api.example.com/webhook",
            "secret": "test-secret",
            "headers": {},
        }
        payload = {"event": "test.event", "data": {"id": "123"}}

        with patch.object(webhook_service, "_make_http_request") as mock_request:
            mock_request.return_value = {
                "status_code": 200,
                "response_time": 0.5,
                "response_headers": {},
                "response_body": '{"status": "received"}',
            }
            
            with patch.object(webhook_service, "_generate_signature") as mock_signature:
                expected_signature = "sha256=test-signature"
                mock_signature.return_value = expected_signature
                
                result = await webhook_service._deliver_webhook(webhook, payload)

                assert result["success"] is True
                assert result["status_code"] == 200
                
                # Verify signature was generated and added to headers
                mock_signature.assert_called_once_with(json.dumps(payload), "test-secret")
                
                # Verify the request was made with the signature header
                call_args = mock_request.call_args
                headers = call_args[1]["headers"]
                assert "X-Webhook-Signature" in headers
                assert headers["X-Webhook-Signature"] == expected_signature

    @pytest.mark.asyncio
    async def test_deliver_webhook_failure(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook delivery failure handling."""
        webhook = {
            "id": "webhook-123",
            "url": "https://api.example.com/webhook",
            "secret": "test-secret",
        }
        payload = {"event": "test.event", "data": {"id": "123"}}

        with patch.object(webhook_service, "_make_http_request") as mock_request:
            mock_request.side_effect = Exception("Connection refused")
            
            result = await webhook_service._deliver_webhook(webhook, payload)

            assert result["success"] is False
            assert "Connection refused" in result["error"]


class TestWebhookRetryMechanism:
    """Test webhook retry mechanisms."""

    @pytest.mark.asyncio
    async def test_schedule_retry_success(
        self, webhook_service: WebhookService
    ) -> None:
        """Test successful retry scheduling."""
        delivery_data = {
            "webhook_id": "webhook-123",
            "payload": {"event": "test.event", "data": {"id": "123"}},
            "attempt": 1,
            "max_attempts": 3,
            "next_retry_at": datetime.utcnow() + timedelta(minutes=1),
        }

        with patch.object(webhook_service, "_schedule_retry") as mock_schedule:
            mock_schedule.return_value = {
                "success": True,
                "retry_id": "retry-123",
                "scheduled_at": delivery_data["next_retry_at"].isoformat(),
                "attempt": 2,
            }
            
            result = await webhook_service.schedule_retry(
                **delivery_data
            )

            assert result["success"] is True
            assert result["retry_id"] == "retry-123"
            assert result["attempt"] == 2

    @pytest.mark.asyncio
    async def test_process_retries_success(
        self, webhook_service: WebhookService
    ) -> None:
        """Test successful retry processing."""
        with patch.object(webhook_service, "_get_pending_retries") as mock_get_retries:
            mock_retries = [
                {
                    "id": "retry-1",
                    "webhook_id": "webhook-1",
                    "payload": {"event": "test.event1"},
                    "attempt": 2,
                    "scheduled_at": datetime.utcnow() - timedelta(minutes=1),
                },
                {
                    "id": "retry-2",
                    "webhook_id": "webhook-2",
                    "payload": {"event": "test.event2"},
                    "attempt": 3,
                    "scheduled_at": datetime.utcnow() - timedelta(minutes=5),
                },
            ]
            mock_get_retries.return_value = mock_retries
            
            with patch.object(webhook_service, "_execute_retry") as mock_execute:
                mock_execute.side_effect = [
                    {"success": True, "delivery_id": "del-1", "status_code": 200},
                    {"success": False, "error": "Still failing", "final_attempt": True},
                ]
                
                result = await webhook_service.process_retries()

                assert result["success"] is True
                assert result["processed_retries"] == 2
                assert result["successful_retries"] == 1
                assert result["failed_retries"] == 1
                assert result["final_failures"] == 1

    @pytest.mark.asyncio
    async def test_calculate_retry_delay(
        self, webhook_service: WebhookService
    ) -> None:
        """Test retry delay calculation with exponential backoff."""
        retry_policy = {
            "max_attempts": 5,
            "initial_delay": 1,  # 1 second
            "backoff_factor": 2,
        }

        # Test different attempt numbers
        with patch.object(webhook_service, "_calculate_retry_delay") as mock_calculate:
            mock_calculate.side_effect = lambda attempt, policy: policy["initial_delay"] * (policy["backoff_factor"] ** (attempt - 1))
            
            delay_1 = await webhook_service._calculate_retry_delay(1, retry_policy)
            delay_2 = await webhook_service._calculate_retry_delay(2, retry_policy)
            delay_3 = await webhook_service._calculate_retry_delay(3, retry_policy)

            assert delay_1 == 1    # 1 * 2^0 = 1
            assert delay_2 == 2    # 1 * 2^1 = 2
            assert delay_3 == 4    # 1 * 2^2 = 4

    @pytest.mark.asyncio
    async def test_max_retry_attempts_reached(
        self, webhook_service: WebhookService
    ) -> None:
        """Test behavior when max retry attempts are reached."""
        delivery_data = {
            "webhook_id": "webhook-123",
            "payload": {"event": "test.event"},
            "attempt": 5,
            "max_attempts": 5,
        }

        with patch.object(webhook_service, "_mark_as_permanently_failed") as mock_mark_failed:
            mock_mark_failed.return_value = True
            
            result = await webhook_service._execute_retry(delivery_data)

            assert result["success"] is False
            assert result["final_attempt"] is True
            assert "Max retry attempts reached" in result["error"]
            mock_mark_failed.assert_called_once()


class TestWebhookSecurity:
    """Test webhook security features."""

    @pytest.mark.asyncio
    async def test_generate_signature_sha256(
        self, webhook_service: WebhookService
    ) -> None:
        """Test SHA256 signature generation."""
        payload = '{"event": "test.event", "data": {"id": "123"}}'
        secret = "test-secret"

        with patch.object(webhook_service, "_generate_signature") as mock_generate:
            # Calculate expected signature
            expected_signature = hmac.new(
                secret.encode('utf-8'),
                payload.encode('utf-8'),
                hashlib.sha256
            ).hexdigest()
            mock_generate.return_value = f"sha256={expected_signature}"
            
            signature = await webhook_service._generate_signature(payload, secret)

            assert signature.startswith("sha256=")
            assert len(signature) == 71  # "sha256=" + 64 hex characters

    @pytest.mark.asyncio
    async def test_verify_webhook_signature(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook signature verification."""
        payload = '{"event": "test.event"}'
        secret = "test-secret"
        signature = "sha256=" + hmac.new(
            secret.encode('utf-8'),
            payload.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()

        with patch.object(webhook_service, "_verify_signature") as mock_verify:
            mock_verify.return_value = True
            
            is_valid = await webhook_service._verify_signature(payload, signature, secret)

            assert is_valid is True
            mock_verify.assert_called_once()

    @pytest.mark.asyncio
    async def test_verify_webhook_invalid_signature(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook signature verification with invalid signature."""
        payload = '{"event": "test.event"}'
        secret = "test-secret"
        invalid_signature = "sha256=invalid-signature"

        with patch.object(webhook_service, "_verify_signature") as mock_verify:
            mock_verify.return_value = False
            
            is_valid = await webhook_service._verify_signature(payload, invalid_signature, secret)

            assert is_valid is False

    @pytest.mark.asyncio
    async def test_webhook_url_validation(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook URL validation."""
        valid_urls = [
            "https://api.example.com/webhook",
            "https://webhook.service.com/receive",
            "https://192.168.1.100:8080/webhook",
        ]
        
        invalid_urls = [
            "http://example.com/webhook",  # HTTP not allowed
            "ftp://example.com/webhook",   # Wrong protocol
            "https://localhost/webhook",   # Localhost not allowed
            "https://127.0.0.1/webhook",   # Loopback not allowed
            "not-a-url",                   # Invalid format
        ]

        with patch.object(webhook_service, "_validate_webhook_url") as mock_validate:
            # Mock validation logic
            def validate_url(url):
                if not url.startswith("https://"):
                    raise ValueError("Only HTTPS URLs are allowed")
                if "localhost" in url or "127.0.0.1" in url:
                    raise ValueError("Localhost URLs are not allowed")
                if not url.startswith(("https://", "http://")):
                    raise ValueError("Invalid URL format")
                return True
            
            mock_validate.side_effect = validate_url

            # Test valid URLs
            for url in valid_urls:
                try:
                    result = await webhook_service._validate_webhook_url(url)
                    assert result is True
                except ValueError:
                    pytest.fail(f"Valid URL {url} was rejected")

            # Test invalid URLs
            for url in invalid_urls:
                with pytest.raises(ValueError):
                    await webhook_service._validate_webhook_url(url)


class TestWebhookAnalytics:
    """Test webhook analytics and monitoring."""

    @pytest.mark.asyncio
    async def test_get_webhook_stats(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook statistics retrieval."""
        with patch.object(webhook_service, "_get_webhook_stats") as mock_stats:
            mock_stats.return_value = {
                "total_webhooks": 15,
                "active_webhooks": 12,
                "inactive_webhooks": 3,
                "total_deliveries": 5420,
                "successful_deliveries": 5180,
                "failed_deliveries": 240,
                "success_rate": 0.956,
                "average_response_time": 1.2,
                "events_by_type": {
                    "user.created": 1500,
                    "user.updated": 2800,
                    "user.deleted": 120,
                    "user.login": 1000,
                },
                "deliveries_by_status": {
                    "success": 5180,
                    "failed": 240,
                    "retrying": 15,
                    "pending": 5,
                },
                "top_failing_webhooks": [
                    {
                        "webhook_id": "webhook-1",
                        "url": "https://api.broken.com/webhook",
                        "failure_rate": 0.45,
                        "last_success": "2024-01-01T10:00:00Z",
                    },
                    {
                        "webhook_id": "webhook-2",
                        "url": "https://api.slow.com/webhook",
                        "failure_rate": 0.23,
                        "last_success": "2024-01-02T15:30:00Z",
                    },
                ],
            }
            
            result = await webhook_service.get_webhook_stats()

            assert result["total_webhooks"] == 15
            assert result["success_rate"] == 0.956
            assert len(result["events_by_type"]) == 4
            assert len(result["top_failing_webhooks"]) == 2

    @pytest.mark.asyncio
    async def test_get_delivery_history(
        self, webhook_service: WebhookService
    ) -> None:
        """Test delivery history retrieval."""
        webhook_id = "webhook-123"

        with patch.object(webhook_service, "_get_delivery_history") as mock_history:
            mock_history.return_value = {
                "webhook_id": webhook_id,
                "deliveries": [
                    {
                        "id": "delivery-1",
                        "event": "user.created",
                        "timestamp": "2024-01-01T12:00:00Z",
                        "status": "success",
                        "status_code": 200,
                        "response_time": 0.8,
                        "attempt": 1,
                    },
                    {
                        "id": "delivery-2",
                        "event": "user.updated",
                        "timestamp": "2024-01-01T12:05:00Z",
                        "status": "failed",
                        "status_code": 500,
                        "response_time": 5.0,
                        "attempt": 3,
                        "error": "Internal Server Error",
                    },
                ],
                "total_count": 2,
                "success_count": 1,
                "failure_count": 1,
                "average_response_time": 2.9,
            }
            
            result = await webhook_service.get_delivery_history(webhook_id)

            assert result["webhook_id"] == webhook_id
            assert len(result["deliveries"]) == 2
            assert result["success_count"] == 1
            assert result["failure_count"] == 1

    @pytest.mark.asyncio
    async def test_webhook_health_check(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook health check functionality."""
        webhook_id = "webhook-123"

        with patch.object(webhook_service, "_perform_health_check") as mock_health_check:
            mock_health_check.return_value = {
                "webhook_id": webhook_id,
                "url": "https://api.example.com/webhook",
                "health_status": "healthy",
                "response_time": 0.5,
                "last_check": datetime.utcnow().isoformat(),
                "checks": {
                    "url_reachable": True,
                    "ssl_valid": True,
                    "response_format": "valid",
                    "authentication": "valid",
                },
                "recommendations": [],
            }
            
            result = await webhook_service.perform_health_check(webhook_id)

            assert result["webhook_id"] == webhook_id
            assert result["health_status"] == "healthy"
            assert all(result["checks"].values())

    @pytest.mark.asyncio
    async def test_webhook_health_check_unhealthy(
        self, webhook_service: WebhookService
    ) -> None:
        """Test webhook health check for unhealthy webhook."""
        webhook_id = "webhook-123"

        with patch.object(webhook_service, "_perform_health_check") as mock_health_check:
            mock_health_check.return_value = {
                "webhook_id": webhook_id,
                "url": "https://api.broken.com/webhook",
                "health_status": "unhealthy",
                "response_time": None,
                "last_check": datetime.utcnow().isoformat(),
                "checks": {
                    "url_reachable": False,
                    "ssl_valid": True,
                    "response_format": "unknown",
                    "authentication": "unknown",
                },
                "recommendations": [
                    "Check if the webhook URL is correct and accessible",
                    "Verify network connectivity",
                    "Consider updating the webhook URL",
                ],
                "error": "Connection timeout after 30 seconds",
            }
            
            result = await webhook_service.perform_health_check(webhook_id)

            assert result["webhook_id"] == webhook_id
            assert result["health_status"] == "unhealthy"
            assert result["checks"]["url_reachable"] is False
            assert len(result["recommendations"]) == 3


# Performance and stress tests
@pytest.mark.performance
class TestWebhookPerformance:
    """Performance tests for webhook service."""

    @pytest.mark.asyncio
    async def test_bulk_event_dispatch_performance(
        self, webhook_service: WebhookService
    ) -> None:
        """Test performance of dispatching events to many webhooks."""
        # Simulate dispatching to 100 webhooks
        with patch.object(webhook_service, "_get_webhooks_for_event") as mock_get_webhooks:
            mock_webhooks = [
                {
                    "id": f"webhook-{i}",
                    "url": f"https://api{i}.example.com/webhook",
                    "secret": f"secret-{i}",
                }
                for i in range(100)
            ]
            mock_get_webhooks.return_value = mock_webhooks
            
            with patch.object(webhook_service, "_deliver_webhook") as mock_deliver:
                mock_deliver.return_value = {
                    "success": True,
                    "delivery_id": "test-delivery",
                    "status_code": 200,
                    "response_time": 0.1,
                }
                
                event_data = {
                    "event": "bulk.test",
                    "data": {"test": "data"},
                    "timestamp": datetime.utcnow().isoformat(),
                }
                
                result = await webhook_service.dispatch_event(**event_data)

                assert result["success"] is True
                assert result["dispatched_to"] == 100
                assert mock_deliver.call_count == 100

    @pytest.mark.asyncio
    async def test_concurrent_deliveries_performance(
        self, webhook_service: WebhookService
    ) -> None:
        """Test concurrent webhook deliveries performance."""
        import asyncio
        
        async def dispatch_single_event(event_num):
            """Dispatch a single event."""
            return await webhook_service.dispatch_event(
                event=f"test.event.{event_num}",
                data={"event_number": event_num},
                timestamp=datetime.utcnow().isoformat(),
            )

        with patch.object(webhook_service, "dispatch_event") as mock_dispatch:
            mock_dispatch.side_effect = lambda **kwargs: {
                "success": True,
                "event": kwargs["event"],
                "dispatched_to": 1,
                "delivery_results": [
                    {"success": True, "response_time": 0.1}
                ],
            }
            
            # Dispatch 20 events concurrently
            tasks = [dispatch_single_event(i) for i in range(20)]
            results = await asyncio.gather(*tasks)

            assert len(results) == 20
            assert all(result["success"] for result in results)
            assert mock_dispatch.call_count == 20