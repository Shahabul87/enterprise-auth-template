"""
Database monitoring and query performance tracking.
Integrates with SQLAlchemy to monitor query performance.
"""

import time
import logging
from typing import Optional, Dict, Any
from sqlalchemy import event
from sqlalchemy.engine import Engine, Connection
from sqlalchemy.pool import Pool
from sqlalchemy.orm import Session
from contextlib import contextmanager
import asyncio
from datetime import datetime

from ..middleware.performance_middleware import (
    DB_QUERY_DURATION,
    DB_CONNECTION_POOL,
    update_connection_pool_metrics
)

logger = logging.getLogger(__name__)

# Store query context for tracking
class QueryContext:
    """Context for tracking query execution."""

    def __init__(self):
        self.start_time: Optional[float] = None
        self.statement: Optional[str] = None
        self.parameters: Optional[Dict] = None


def setup_database_monitoring(engine: Engine):
    """
    Set up database monitoring for SQLAlchemy engine.

    Args:
        engine: SQLAlchemy engine instance
    """

    @event.listens_for(engine, "before_cursor_execute")
    def receive_before_cursor_execute(
        conn: Connection,
        cursor,
        statement: str,
        parameters,
        context,
        executemany
    ):
        """Track query start time."""
        if not hasattr(context, '_query_context'):
            context._query_context = QueryContext()

        context._query_context.start_time = time.time()
        context._query_context.statement = statement
        context._query_context.parameters = parameters

    @event.listens_for(engine, "after_cursor_execute")
    def receive_after_cursor_execute(
        conn: Connection,
        cursor,
        statement: str,
        parameters,
        context,
        executemany
    ):
        """Track query execution time and log slow queries."""
        if hasattr(context, '_query_context') and context._query_context.start_time:
            duration = time.time() - context._query_context.start_time

            # Extract operation and table from SQL statement
            operation, table = _parse_sql_statement(statement)

            # Record metrics
            DB_QUERY_DURATION.labels(
                operation=operation,
                table=table
            ).observe(duration)

            # Log slow queries (> 100ms)
            if duration > 0.1:
                logger.warning(
                    "Slow database query detected",
                    extra={
                        "duration": f"{duration:.3f}s",
                        "operation": operation,
                        "table": table,
                        "statement": statement[:500],  # Truncate long statements
                        "parameters": str(parameters)[:200] if parameters else None
                    }
                )

            # Log extremely slow queries (> 1s) as errors
            elif duration > 1.0:
                logger.error(
                    "Extremely slow database query",
                    extra={
                        "duration": f"{duration:.3f}s",
                        "operation": operation,
                        "table": table,
                        "statement": statement[:1000],
                        "parameters": str(parameters)[:500] if parameters else None,
                        "timestamp": datetime.utcnow().isoformat()
                    }
                )

    @event.listens_for(engine, "handle_error")
    def receive_handle_error(exception_context):
        """Log database errors."""
        logger.error(
            "Database error occurred",
            extra={
                "statement": str(exception_context.statement)[:500],
                "parameters": str(exception_context.parameters)[:200]
                    if exception_context.parameters else None,
                "error": str(exception_context.original_exception),
                "timestamp": datetime.utcnow().isoformat()
            },
            exc_info=exception_context.original_exception
        )

    # Monitor connection pool if available
    if hasattr(engine, 'pool'):
        setup_pool_monitoring(engine.pool)


def setup_pool_monitoring(pool: Pool):
    """
    Set up connection pool monitoring.

    Args:
        pool: SQLAlchemy connection pool
    """

    @event.listens_for(pool, "connect")
    def receive_connect(dbapi_conn, connection_record):
        """Track new connection creation."""
        logger.info(
            "Database connection created",
            extra={
                "pool_size": pool.size(),
                "overflow": pool.overflow(),
                "total": pool.size() + pool.overflow(),
                "timestamp": datetime.utcnow().isoformat()
            }
        )
        _update_pool_metrics(pool)

    @event.listens_for(pool, "checkout")
    def receive_checkout(dbapi_conn, connection_record, connection_proxy):
        """Track connection checkout from pool."""
        _update_pool_metrics(pool)

        # Log if pool is running low
        available = pool.size() - pool.checkedout()
        if available <= 1:
            logger.warning(
                "Database connection pool running low",
                extra={
                    "available": available,
                    "checked_out": pool.checkedout(),
                    "total": pool.size(),
                    "timestamp": datetime.utcnow().isoformat()
                }
            )

    @event.listens_for(pool, "checkin")
    def receive_checkin(dbapi_conn, connection_record):
        """Track connection return to pool."""
        _update_pool_metrics(pool)

    @event.listens_for(pool, "reset")
    def receive_reset(dbapi_conn, connection_record):
        """Track connection reset."""
        logger.debug(
            "Database connection reset",
            extra={
                "timestamp": datetime.utcnow().isoformat()
            }
        )

    @event.listens_for(pool, "invalidate")
    def receive_invalidate(dbapi_conn, connection_record, exception):
        """Track connection invalidation."""
        logger.warning(
            "Database connection invalidated",
            extra={
                "exception": str(exception) if exception else None,
                "timestamp": datetime.utcnow().isoformat()
            }
        )
        _update_pool_metrics(pool)


def _parse_sql_statement(statement: str) -> tuple[str, str]:
    """
    Parse SQL statement to extract operation and table name.

    Args:
        statement: SQL statement string

    Returns:
        Tuple of (operation, table_name)
    """
    statement_upper = statement.upper().strip()

    # Determine operation
    if statement_upper.startswith('SELECT'):
        operation = 'SELECT'
    elif statement_upper.startswith('INSERT'):
        operation = 'INSERT'
    elif statement_upper.startswith('UPDATE'):
        operation = 'UPDATE'
    elif statement_upper.startswith('DELETE'):
        operation = 'DELETE'
    elif statement_upper.startswith('CREATE'):
        operation = 'CREATE'
    elif statement_upper.startswith('DROP'):
        operation = 'DROP'
    elif statement_upper.startswith('ALTER'):
        operation = 'ALTER'
    elif statement_upper.startswith('BEGIN'):
        operation = 'TRANSACTION'
    elif statement_upper.startswith('COMMIT'):
        operation = 'COMMIT'
    elif statement_upper.startswith('ROLLBACK'):
        operation = 'ROLLBACK'
    else:
        operation = 'OTHER'

    # Try to extract table name
    table = 'unknown'

    try:
        if operation in ['SELECT', 'DELETE']:
            # Look for FROM clause
            from_index = statement_upper.find('FROM')
            if from_index != -1:
                rest = statement_upper[from_index + 4:].strip()
                # Get first word after FROM
                table = rest.split()[0].strip('()"\'`[]')

        elif operation == 'INSERT':
            # Look for INTO clause
            into_index = statement_upper.find('INTO')
            if into_index != -1:
                rest = statement_upper[into_index + 4:].strip()
                # Get first word after INTO
                table = rest.split()[0].strip('()"\'`[]')

        elif operation == 'UPDATE':
            # Table name typically follows UPDATE
            parts = statement_upper.split()
            if len(parts) > 1:
                table = parts[1].strip('()"\'`[]')

        elif operation in ['CREATE', 'DROP', 'ALTER']:
            # Look for TABLE keyword
            table_index = statement_upper.find('TABLE')
            if table_index != -1:
                rest = statement_upper[table_index + 5:].strip()
                # Get first word after TABLE
                if rest:
                    table = rest.split()[0].strip('()"\'`[]')

        # Clean up table name (remove schema prefix if present)
        if '.' in table:
            table = table.split('.')[-1]

        # Normalize common table names
        table = table.lower()

    except (IndexError, AttributeError):
        # If parsing fails, keep 'unknown'
        pass

    return operation, table


def _update_pool_metrics(pool: Pool):
    """
    Update connection pool metrics.

    Args:
        pool: SQLAlchemy connection pool
    """
    try:
        checked_out = pool.checkedout() if hasattr(pool, 'checkedout') else 0
        total = pool.size() if hasattr(pool, 'size') else 0
        overflow = pool.overflow() if hasattr(pool, 'overflow') else 0

        idle = total - checked_out

        update_connection_pool_metrics(
            active=checked_out,
            idle=idle,
            total=total + overflow
        )
    except Exception as e:
        logger.error(f"Failed to update pool metrics: {e}")


class DatabaseMonitor:
    """
    Database monitoring context manager for tracking specific operations.
    """

    def __init__(self, operation: str, table: str):
        self.operation = operation
        self.table = table
        self.start_time: Optional[float] = None

    def __enter__(self):
        self.start_time = time.time()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.start_time:
            duration = time.time() - self.start_time

            # Record metrics
            DB_QUERY_DURATION.labels(
                operation=self.operation,
                table=self.table
            ).observe(duration)

            # Log if there was an error
            if exc_type:
                logger.error(
                    f"Database operation failed",
                    extra={
                        "operation": self.operation,
                        "table": self.table,
                        "duration": f"{duration:.3f}s",
                        "error": str(exc_val),
                        "error_type": exc_type.__name__
                    }
                )
            # Log slow operations
            elif duration > 0.1:
                logger.warning(
                    f"Slow database operation",
                    extra={
                        "operation": self.operation,
                        "table": self.table,
                        "duration": f"{duration:.3f}s"
                    }
                )


@contextmanager
def monitor_db_operation(operation: str, table: str):
    """
    Context manager for monitoring database operations.

    Usage:
        with monitor_db_operation("custom_query", "users"):
            # Your database operation here
            pass
    """
    monitor = DatabaseMonitor(operation, table)
    try:
        monitor.__enter__()
        yield monitor
    finally:
        monitor.__exit__(None, None, None)


async def monitor_async_db_operation(operation: str, table: str, func, *args, **kwargs):
    """
    Monitor an async database operation.

    Args:
        operation: Operation name for metrics
        table: Table name for metrics
        func: Async function to execute
        *args: Positional arguments for func
        **kwargs: Keyword arguments for func

    Returns:
        Result of func execution
    """
    start_time = time.time()

    try:
        result = await func(*args, **kwargs)
        duration = time.time() - start_time

        # Record metrics
        DB_QUERY_DURATION.labels(
            operation=operation,
            table=table
        ).observe(duration)

        # Log slow operations
        if duration > 0.1:
            logger.warning(
                f"Slow async database operation",
                extra={
                    "operation": operation,
                    "table": table,
                    "duration": f"{duration:.3f}s"
                }
            )

        return result

    except Exception as e:
        duration = time.time() - start_time

        logger.error(
            f"Async database operation failed",
            extra={
                "operation": operation,
                "table": table,
                "duration": f"{duration:.3f}s",
                "error": str(e),
                "error_type": type(e).__name__
            }
        )
        raise


# Export monitoring functions
__all__ = [
    'setup_database_monitoring',
    'setup_pool_monitoring',
    'DatabaseMonitor',
    'monitor_db_operation',
    'monitor_async_db_operation'
]
