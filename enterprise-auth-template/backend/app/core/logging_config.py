"""
Structured logging configuration for the application.
Uses JSON format for easy parsing by log aggregation systems.
"""

import logging
import logging.config
import sys
import json
from typing import Dict, Any, Optional
from datetime import datetime
from pathlib import Path
import traceback
from contextvars import ContextVar

# Context variables for request tracking
request_id_var: ContextVar[Optional[str]] = ContextVar("request_id", default=None)
user_id_var: ContextVar[Optional[str]] = ContextVar("user_id", default=None)
correlation_id_var: ContextVar[Optional[str]] = ContextVar(
    "correlation_id", default=None
)


class JSONFormatter(logging.Formatter):
    """
    Custom JSON formatter for structured logging.
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.hostname = self._get_hostname()
        self.service_name = "enterprise-auth-backend"

    def format(self, record: logging.LogRecord) -> str:
        """
        Format log record as JSON.
        """
        # Build base log entry
        log_entry = {
            "@timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "service": self.service_name,
            "hostname": self.hostname,
            "environment": self._get_environment(),
        }

        # Add context variables if available
        request_id = request_id_var.get()
        if request_id:
            log_entry["request_id"] = request_id

        user_id = user_id_var.get()
        if user_id:
            log_entry["user_id"] = user_id

        correlation_id = correlation_id_var.get()
        if correlation_id:
            log_entry["correlation_id"] = correlation_id

        # Add location information
        log_entry["location"] = {
            "file": record.pathname,
            "line": record.lineno,
            "function": record.funcName,
            "module": record.module,
        }

        # Add exception information if present
        if record.exc_info:
            log_entry["exception"] = {
                "type": (
                    record.exc_info[0].__name__ if record.exc_info[0] else "Unknown"
                ),
                "message": str(record.exc_info[1]),
                "traceback": traceback.format_exception(*record.exc_info),
            }

        # Add extra fields
        if hasattr(record, "__dict__"):
            extras = {}
            for key, value in record.__dict__.items():
                if key not in [
                    "name",
                    "msg",
                    "args",
                    "created",
                    "filename",
                    "funcName",
                    "levelname",
                    "levelno",
                    "lineno",
                    "module",
                    "msecs",
                    "message",
                    "pathname",
                    "process",
                    "processName",
                    "relativeCreated",
                    "thread",
                    "threadName",
                    "exc_info",
                    "exc_text",
                    "stack_info",
                ]:
                    # Serialize complex objects
                    try:
                        if isinstance(
                            value, (dict, list, str, int, float, bool, type(None))
                        ):
                            extras[key] = value
                        else:
                            extras[key] = str(value)
                    except Exception:
                        extras[key] = repr(value)

            if extras:
                log_entry["extra"] = extras

        # Add performance metrics if available
        if hasattr(record, "duration"):
            log_entry["performance"] = {"duration": record.duration}

        # Add security context if available
        if hasattr(record, "client_ip"):
            if "security" not in log_entry:
                log_entry["security"] = {}
            log_entry["security"]["client_ip"] = record.client_ip

        if hasattr(record, "user_agent"):
            if "security" not in log_entry:
                log_entry["security"] = {}
            log_entry["security"]["user_agent"] = record.user_agent

        return json.dumps(log_entry, default=str)

    def _get_hostname(self) -> str:
        """Get system hostname."""
        import socket

        try:
            return socket.gethostname()
        except Exception:
            return "unknown"

    def _get_environment(self) -> str:
        """Get environment name from settings."""
        import os

        return os.getenv("ENVIRONMENT", "development")


class RequestContextFilter(logging.Filter):
    """
    Logging filter that adds request context to log records.
    """

    def filter(self, record: logging.LogRecord) -> bool:
        """
        Add context variables to log record.
        """
        # Add context variables as record attributes
        request_id = request_id_var.get()
        if request_id:
            record.request_id = request_id

        user_id = user_id_var.get()
        if user_id:
            record.user_id = user_id

        correlation_id = correlation_id_var.get()
        if correlation_id:
            record.correlation_id = correlation_id

        return True


class SecurityFilter(logging.Filter):
    """
    Filter to redact sensitive information from logs.
    """

    SENSITIVE_FIELDS = {
        "password",
        "secret",
        "token",
        "api_key",
        "access_token",
        "refresh_token",
        "authorization",
        "cookie",
        "session",
        "credit_card",
        "ssn",
        "pin",
        "cvv",
    }

    def filter(self, record: logging.LogRecord) -> bool:
        """
        Redact sensitive information from log record.
        """
        # Redact message
        record.msg = self._redact_sensitive(str(record.msg))

        # Redact arguments
        if record.args:
            record.args = tuple(self._redact_sensitive(str(arg)) for arg in record.args)

        # Redact extra fields
        for field in dir(record):
            if not field.startswith("_"):
                value = getattr(record, field)
                if isinstance(value, (str, dict)):
                    setattr(record, field, self._redact_sensitive(value))

        return True

    def _redact_sensitive(self, data):
        """
        Redact sensitive information from data.
        """
        if isinstance(data, str):
            # Simple redaction for common patterns
            import re

            # Redact email addresses partially
            data = re.sub(
                r"([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})",
                lambda m: f"{m.group(1)[:3]}***@{m.group(2)}",
                data,
            )

            # Redact JWT tokens
            data = re.sub(
                r"eyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+",
                "[REDACTED_JWT]",
                data,
            )

            # Redact API keys (common patterns)
            data = re.sub(
                r'(?i)(api[_-]?key|access[_-]?token|secret[_-]?key)(["\']?\s*[:=]\s*["\']?)([^"\'\s]+)',
                r"\1\2[REDACTED]",
                data,
            )

        elif isinstance(data, dict):
            # Redact dictionary values for sensitive keys
            redacted = {}
            for key, value in data.items():
                if any(sensitive in key.lower() for sensitive in self.SENSITIVE_FIELDS):
                    redacted[key] = "[REDACTED]"
                elif isinstance(value, (dict, str)):
                    redacted[key] = self._redact_sensitive(value)
                else:
                    redacted[key] = value
            return redacted

        return data


def setup_logging(
    log_level: str = "INFO",
    log_file: Optional[str] = None,
    enable_json: bool = True,
    enable_security_filter: bool = True,
) -> None:
    """
    Set up structured logging for the application.

    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Optional log file path
        enable_json: Whether to use JSON formatting
        enable_security_filter: Whether to enable security filtering
    """

    # Create logs directory if needed
    if log_file:
        log_path = Path(log_file)
        log_path.parent.mkdir(parents=True, exist_ok=True)

    # Build logging configuration
    config: Dict[str, Any] = {
        "version": 1,
        "disable_existing_loggers": False,
        "formatters": {
            "json": {"()": JSONFormatter},
            "standard": {
                "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
            },
        },
        "filters": {"context": {"()": RequestContextFilter}},
        "handlers": {
            "console": {
                "class": "logging.StreamHandler",
                "level": log_level,
                "formatter": "json" if enable_json else "standard",
                "filters": ["context"],
                "stream": "ext://sys.stdout",
            }
        },
        "root": {"level": log_level, "handlers": ["console"]},
        "loggers": {
            # Application loggers
            "app": {"level": log_level, "handlers": ["console"], "propagate": False},
            "uvicorn": {
                "level": log_level,
                "handlers": ["console"],
                "propagate": False,
            },
            "uvicorn.access": {
                "level": "INFO",
                "handlers": ["console"],
                "propagate": False,
            },
            # Reduce noise from libraries
            "sqlalchemy.engine": {
                "level": "WARNING",
                "handlers": ["console"],
                "propagate": False,
            },
            "httpx": {"level": "WARNING", "handlers": ["console"], "propagate": False},
            "httpcore": {
                "level": "WARNING",
                "handlers": ["console"],
                "propagate": False,
            },
        },
    }

    # Add security filter if enabled
    if enable_security_filter:
        config["filters"]["security"] = {"()": SecurityFilter}
        for handler in config["handlers"].values():
            if "filters" in handler:
                handler["filters"].append("security")
            else:
                handler["filters"] = ["security"]

    # Add file handler if log file specified
    if log_file:
        config["handlers"]["file"] = {
            "class": "logging.handlers.RotatingFileHandler",
            "level": log_level,
            "formatter": "json" if enable_json else "standard",
            "filters": ["context"],
            "filename": log_file,
            "maxBytes": 10485760,  # 10MB
            "backupCount": 5,
            "encoding": "utf-8",
        }

        if enable_security_filter:
            config["handlers"]["file"]["filters"].append("security")

        # Add file handler to root and app loggers
        config["root"]["handlers"].append("file")
        for logger_config in config["loggers"].values():
            if "file" not in logger_config.get("handlers", []):
                logger_config["handlers"].append("file")

    # Apply configuration
    logging.config.dictConfig(config)

    # Log startup message
    logger = logging.getLogger(__name__)
    logger.info(
        "Logging system initialized",
        extra={
            "log_level": log_level,
            "json_enabled": enable_json,
            "security_filter": enable_security_filter,
            "log_file": log_file,
        },
    )


class LoggerMixin:
    """
    Mixin class to add logging capabilities to any class.
    """

    @property
    def logger(self) -> logging.Logger:
        """Get logger for the class."""
        if not hasattr(self, "_logger"):
            self._logger = logging.getLogger(
                f"{self.__class__.__module__}.{self.__class__.__name__}"
            )
        return self._logger

    def log_debug(self, message: str, **kwargs):
        """Log debug message with extra context."""
        self.logger.debug(message, extra=kwargs)

    def log_info(self, message: str, **kwargs):
        """Log info message with extra context."""
        self.logger.info(message, extra=kwargs)

    def log_warning(self, message: str, **kwargs):
        """Log warning message with extra context."""
        self.logger.warning(message, extra=kwargs)

    def log_error(self, message: str, exception: Optional[Exception] = None, **kwargs):
        """Log error message with extra context."""
        if exception:
            self.logger.error(message, exc_info=exception, extra=kwargs)
        else:
            self.logger.error(message, extra=kwargs)

    def log_critical(self, message: str, **kwargs):
        """Log critical message with extra context."""
        self.logger.critical(message, extra=kwargs)


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger instance with the given name.

    Args:
        name: Logger name (usually __name__)

    Returns:
        Logger instance
    """
    return logging.getLogger(name)


# Convenience functions for setting context
def set_request_id(request_id: str):
    """Set request ID in logging context."""
    request_id_var.set(request_id)


def set_user_id(user_id: str):
    """Set user ID in logging context."""
    user_id_var.set(user_id)


def set_correlation_id(correlation_id: str):
    """Set correlation ID in logging context."""
    correlation_id_var.set(correlation_id)


def clear_context():
    """Clear all logging context variables."""
    request_id_var.set(None)
    user_id_var.set(None)
    correlation_id_var.set(None)


# Export public API
__all__ = [
    "setup_logging",
    "get_logger",
    "LoggerMixin",
    "JSONFormatter",
    "RequestContextFilter",
    "SecurityFilter",
    "set_request_id",
    "set_user_id",
    "set_correlation_id",
    "clear_context",
]
