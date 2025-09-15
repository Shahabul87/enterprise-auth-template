"""
Enhanced Error Handling and User Feedback System

Provides comprehensive error handling with detailed user feedback
for all possible failure scenarios in authentication flows.
"""

from enum import Enum
from typing import Dict, Any, Optional
import structlog
from datetime import datetime

logger = structlog.get_logger(__name__)


class ErrorCategory(str, Enum):
    """Categories of errors for better handling"""
    VALIDATION = "validation"
    AUTHENTICATION = "authentication"
    DATABASE = "database"
    NETWORK = "network"
    RATE_LIMIT = "rate_limit"
    PERMISSION = "permission"
    EXTERNAL_SERVICE = "external_service"
    SYSTEM = "system"
    CONFIGURATION = "configuration"


class ErrorSeverity(str, Enum):
    """Error severity levels"""
    LOW = "low"        # User can retry immediately
    MEDIUM = "medium"  # User should wait or try alternative
    HIGH = "high"      # User needs assistance
    CRITICAL = "critical"  # System failure


class UserFeedback:
    """User-friendly error messages and recovery suggestions"""

    MESSAGES = {
        # Registration Errors
        "email_already_exists": {
            "message": "This email is already registered",
            "suggestion": "Try logging in instead, or use password recovery if you forgot your password",
            "action": "redirect_to_login",
            "severity": ErrorSeverity.LOW
        },
        "weak_password": {
            "message": "Your password doesn't meet security requirements",
            "suggestion": "Use at least 8 characters with uppercase, lowercase, numbers, and symbols",
            "action": "highlight_password_field",
            "severity": ErrorSeverity.LOW
        },
        "invalid_email_format": {
            "message": "Please enter a valid email address",
            "suggestion": "Check for typos in your email (e.g., user@example.com)",
            "action": "highlight_email_field",
            "severity": ErrorSeverity.LOW
        },
        "database_connection_failed": {
            "message": "We're having trouble connecting to our servers",
            "suggestion": "Please wait a moment and try again. If the problem persists, our team has been notified",
            "action": "show_retry_button",
            "severity": ErrorSeverity.HIGH,
            "retry_after": 5
        },
        "rate_limit_exceeded": {
            "message": "Too many registration attempts",
            "suggestion": "For security reasons, please wait a few minutes before trying again",
            "action": "show_countdown_timer",
            "severity": ErrorSeverity.MEDIUM,
            "retry_after": 60
        },

        # Login Errors
        "invalid_credentials": {
            "message": "Email or password is incorrect",
            "suggestion": "Please check your credentials and try again. You can reset your password if needed",
            "action": "show_password_reset_link",
            "severity": ErrorSeverity.LOW
        },
        "account_locked": {
            "message": "Your account has been temporarily locked",
            "suggestion": "Too many failed login attempts. Please wait 15 minutes or reset your password",
            "action": "show_unlock_options",
            "severity": ErrorSeverity.MEDIUM,
            "retry_after": 900
        },
        "account_not_verified": {
            "message": "Please verify your email address",
            "suggestion": "Check your inbox for the verification email. We can resend it if needed",
            "action": "show_resend_verification",
            "severity": ErrorSeverity.LOW
        },
        "account_disabled": {
            "message": "This account has been disabled",
            "suggestion": "Please contact support for assistance",
            "action": "show_support_contact",
            "severity": ErrorSeverity.HIGH
        },

        # Network Errors
        "network_timeout": {
            "message": "The request is taking longer than expected",
            "suggestion": "Check your internet connection and try again",
            "action": "show_retry_button",
            "severity": ErrorSeverity.MEDIUM,
            "retry_after": 3
        },
        "server_maintenance": {
            "message": "We're performing scheduled maintenance",
            "suggestion": "Service will be back shortly. Expected time: 10 minutes",
            "action": "show_maintenance_page",
            "severity": ErrorSeverity.HIGH,
            "retry_after": 600
        },

        # System Errors
        "unexpected_error": {
            "message": "Something went wrong on our end",
            "suggestion": "We've been notified and are working on it. Please try again in a moment",
            "action": "show_error_report",
            "severity": ErrorSeverity.HIGH,
            "retry_after": 10
        }
    }

    @classmethod
    def get_feedback(cls, error_code: str) -> Dict[str, Any]:
        """Get user feedback for an error code"""
        return cls.MESSAGES.get(error_code, cls.MESSAGES["unexpected_error"])


class ErrorRecoveryStrategy:
    """Strategies for recovering from different error types"""

    @staticmethod
    def get_recovery_plan(error_category: ErrorCategory, error_code: str) -> Dict[str, Any]:
        """Get recovery plan for an error"""

        recovery_plans = {
            ErrorCategory.DATABASE: {
                "primary": "retry_with_exponential_backoff",
                "fallback": "queue_for_later_processing",
                "notification": "alert_ops_team",
                "user_action": "show_retry_or_queue_option"
            },
            ErrorCategory.RATE_LIMIT: {
                "primary": "enforce_cooldown_period",
                "fallback": "captcha_verification",
                "notification": "log_potential_abuse",
                "user_action": "show_countdown_timer"
            },
            ErrorCategory.NETWORK: {
                "primary": "retry_immediately",
                "fallback": "use_cached_response",
                "notification": "monitor_network_health",
                "user_action": "show_retry_button"
            },
            ErrorCategory.VALIDATION: {
                "primary": "highlight_invalid_fields",
                "fallback": "provide_examples",
                "notification": "track_validation_patterns",
                "user_action": "focus_first_error_field"
            },
            ErrorCategory.AUTHENTICATION: {
                "primary": "increment_failure_count",
                "fallback": "trigger_security_check",
                "notification": "log_security_event",
                "user_action": "show_alternative_auth_methods"
            }
        }

        return recovery_plans.get(error_category, {
            "primary": "log_and_retry",
            "fallback": "contact_support",
            "notification": "alert_team",
            "user_action": "show_generic_error"
        })


class ProgressTracker:
    """Track registration/login progress for better user feedback"""

    STEPS = {
        "registration": [
            {"id": "validate_input", "name": "Validating your information", "duration": 0.5},
            {"id": "check_availability", "name": "Checking email availability", "duration": 1.0},
            {"id": "create_account", "name": "Creating your account", "duration": 1.5},
            {"id": "setup_security", "name": "Setting up security features", "duration": 1.0},
            {"id": "send_verification", "name": "Sending verification email", "duration": 1.0},
            {"id": "finalize", "name": "Finalizing registration", "duration": 0.5}
        ],
        "login": [
            {"id": "validate_credentials", "name": "Validating credentials", "duration": 0.5},
            {"id": "check_security", "name": "Security verification", "duration": 1.0},
            {"id": "create_session", "name": "Creating secure session", "duration": 0.5},
            {"id": "load_profile", "name": "Loading your profile", "duration": 1.0}
        ]
    }

    @classmethod
    def get_steps(cls, process: str) -> list:
        """Get progress steps for a process"""
        return cls.STEPS.get(process, [])

    @classmethod
    def estimate_time(cls, process: str) -> float:
        """Estimate total time for a process"""
        steps = cls.get_steps(process)
        return sum(step["duration"] for step in steps)


class SmartRetryManager:
    """Intelligent retry management with backoff strategies"""

    def __init__(self):
        self.retry_counts = {}
        self.backoff_strategies = {
            "exponential": lambda attempt: 2 ** attempt,
            "linear": lambda attempt: attempt * 2,
            "fibonacci": lambda attempt: self._fibonacci(attempt) * 2,
            "constant": lambda attempt: 5
        }

    def _fibonacci(self, n: int) -> int:
        """Calculate fibonacci number"""
        if n <= 1:
            return n
        return self._fibonacci(n-1) + self._fibonacci(n-2)

    def should_retry(self, error_code: str, user_id: str) -> tuple[bool, Optional[int]]:
        """Determine if retry should be allowed and wait time"""
        key = f"{user_id}:{error_code}"
        count = self.retry_counts.get(key, 0)

        # Max retries based on error type
        max_retries = {
            "database_connection_failed": 5,
            "network_timeout": 3,
            "rate_limit_exceeded": 0,  # No automatic retry
            "invalid_credentials": 3,   # Prevent brute force
        }.get(error_code, 2)

        if count >= max_retries:
            return False, None

        # Get backoff strategy
        strategy = "exponential" if "database" in error_code else "linear"
        wait_time = self.backoff_strategies[strategy](count)

        self.retry_counts[key] = count + 1
        return True, wait_time


class FallbackAuthManager:
    """Manage fallback authentication methods"""

    @staticmethod
    def get_alternative_methods(primary_method: str, user_preferences: Dict) -> list:
        """Get alternative authentication methods"""

        alternatives = []

        if primary_method == "password":
            if user_preferences.get("phone_verified"):
                alternatives.append({
                    "method": "sms_otp",
                    "label": "Send code via SMS",
                    "available": True
                })
            if user_preferences.get("email_verified"):
                alternatives.append({
                    "method": "magic_link",
                    "label": "Send login link to email",
                    "available": True
                })
            if user_preferences.get("oauth_providers"):
                for provider in user_preferences["oauth_providers"]:
                    alternatives.append({
                        "method": f"oauth_{provider}",
                        "label": f"Sign in with {provider.title()}",
                        "available": True
                    })

        return alternatives


def create_detailed_error_response(
    error_code: str,
    error_category: ErrorCategory,
    context: Optional[Dict] = None,
    user_id: Optional[str] = None
) -> Dict[str, Any]:
    """Create a comprehensive error response with recovery options"""

    # Get user feedback
    feedback = UserFeedback.get_feedback(error_code)

    # Get recovery strategy
    recovery = ErrorRecoveryStrategy.get_recovery_plan(error_category, error_code)

    # Check retry eligibility
    retry_manager = SmartRetryManager()
    can_retry, wait_time = retry_manager.should_retry(error_code, user_id or "anonymous")

    # Build response
    response = {
        "success": False,
        "error": {
            "code": error_code,
            "category": error_category.value,
            "message": feedback["message"],
            "severity": feedback["severity"].value
        },
        "feedback": {
            "suggestion": feedback["suggestion"],
            "action": feedback["action"],
            "retry_allowed": can_retry,
            "retry_after": wait_time or feedback.get("retry_after", 0)
        },
        "recovery": recovery,
        "timestamp": datetime.utcnow().isoformat(),
        "tracking_id": f"err_{datetime.utcnow().timestamp()}"
    }

    # Add context if provided
    if context:
        response["context"] = context

    # Log for monitoring
    logger.error(
        "Error occurred",
        error_code=error_code,
        category=error_category.value,
        user_id=user_id,
        tracking_id=response["tracking_id"]
    )

    return response