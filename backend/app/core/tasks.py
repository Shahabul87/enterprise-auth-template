"""
Background tasks system for the application.
Provides task scheduling and execution functionality.
"""
import asyncio
from typing import Any, Callable, Dict, List, Optional, Union
from datetime import datetime, timedelta
from dataclasses import dataclass, field
from enum import Enum
import logging
import json
import pickle
from functools import wraps
import inspect
from concurrent.futures import ThreadPoolExecutor
import schedule
import time

logger = logging.getLogger(__name__)


class TaskStatus(str, Enum):
    """Task execution status."""
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    RETRY = "retry"


class TaskPriority(str, Enum):
    """Task priority levels."""
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    CRITICAL = "critical"


@dataclass
class Task:
    """Background task definition."""
    id: str
    name: str
    func: Callable
    args: tuple = field(default_factory=tuple)
    kwargs: Dict[str, Any] = field(default_factory=dict)
    priority: TaskPriority = TaskPriority.NORMAL
    status: TaskStatus = TaskStatus.PENDING
    scheduled_at: Optional[datetime] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    result: Any = None
    error: Optional[str] = None
    retry_count: int = 0
    max_retries: int = 3
    retry_delay: int = 60  # seconds
    timeout: Optional[int] = None  # seconds
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert task to dictionary."""
        return {
            "id": self.id,
            "name": self.name,
            "func_name": self.func.__name__ if self.func else None,
            "args": str(self.args),
            "kwargs": str(self.kwargs),
            "priority": self.priority.value,
            "status": self.status.value,
            "scheduled_at": self.scheduled_at.isoformat() if self.scheduled_at else None,
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "error": self.error,
            "retry_count": self.retry_count,
            "max_retries": self.max_retries
        }


class TaskQueue:
    """Priority-based task queue."""
    
    def __init__(self):
        self._queues: Dict[TaskPriority, asyncio.Queue] = {
            priority: asyncio.Queue() for priority in TaskPriority
        }
        self._tasks: Dict[str, Task] = {}
    
    async def put(self, task: Task) -> None:
        """Add task to queue."""
        self._tasks[task.id] = task
        await self._queues[task.priority].put(task)
        logger.debug(f"Task {task.id} ({task.name}) added to queue with priority {task.priority.value}")
    
    async def get(self) -> Task:
        """Get next task from highest priority queue."""
        # Check queues in priority order
        for priority in [TaskPriority.CRITICAL, TaskPriority.HIGH, TaskPriority.NORMAL, TaskPriority.LOW]:
            if not self._queues[priority].empty():
                task = await self._queues[priority].get()
                return task
        
        # If all queues are empty, wait on critical queue
        return await self._queues[TaskPriority.CRITICAL].get()
    
    def get_task(self, task_id: str) -> Optional[Task]:
        """Get task by ID."""
        return self._tasks.get(task_id)
    
    def get_all_tasks(self) -> List[Task]:
        """Get all tasks."""
        return list(self._tasks.values())
    
    def remove_task(self, task_id: str) -> None:
        """Remove task from tracking."""
        if task_id in self._tasks:
            del self._tasks[task_id]
    
    def get_queue_size(self, priority: Optional[TaskPriority] = None) -> int:
        """Get queue size."""
        if priority:
            return self._queues[priority].qsize()
        return sum(q.qsize() for q in self._queues.values())


class TaskWorker:
    """Worker to execute tasks from queue."""
    
    def __init__(self, worker_id: int, queue: TaskQueue):
        self.worker_id = worker_id
        self.queue = queue
        self.is_running = False
        self._current_task: Optional[Task] = None
    
    async def start(self) -> None:
        """Start processing tasks."""
        self.is_running = True
        logger.info(f"Worker {self.worker_id} started")
        
        while self.is_running:
            try:
                # Get next task
                task = await asyncio.wait_for(self.queue.get(), timeout=1.0)
                self._current_task = task
                
                # Execute task
                await self._execute_task(task)
                
                self._current_task = None
                
            except asyncio.TimeoutError:
                # No tasks available
                continue
            except Exception as e:
                logger.error(f"Worker {self.worker_id} error: {str(e)}", exc_info=True)
    
    async def _execute_task(self, task: Task) -> None:
        """Execute a single task."""
        logger.info(f"Worker {self.worker_id} executing task {task.id} ({task.name})")
        
        # Update task status
        task.status = TaskStatus.RUNNING
        task.started_at = datetime.utcnow()
        
        try:
            # Execute with timeout if specified
            if task.timeout:
                result = await asyncio.wait_for(
                    self._run_task_func(task),
                    timeout=task.timeout
                )
            else:
                result = await self._run_task_func(task)
            
            # Task completed successfully
            task.status = TaskStatus.COMPLETED
            task.completed_at = datetime.utcnow()
            task.result = result
            
            logger.info(f"Task {task.id} completed successfully")
            
        except asyncio.TimeoutError:
            task.status = TaskStatus.FAILED
            task.error = "Task execution timeout"
            await self._handle_task_failure(task)
            
        except Exception as e:
            task.status = TaskStatus.FAILED
            task.error = str(e)
            await self._handle_task_failure(task)
    
    async def _run_task_func(self, task: Task) -> Any:
        """Run the task function."""
        if asyncio.iscoroutinefunction(task.func):
            return await task.func(*task.args, **task.kwargs)
        else:
            # Run sync function in thread pool
            loop = asyncio.get_event_loop()
            with ThreadPoolExecutor() as executor:
                return await loop.run_in_executor(
                    executor,
                    task.func,
                    *task.args,
                    **task.kwargs
                )
    
    async def _handle_task_failure(self, task: Task) -> None:
        """Handle task failure and retry logic."""
        logger.error(f"Task {task.id} failed: {task.error}")
        
        if task.retry_count < task.max_retries:
            # Schedule retry
            task.retry_count += 1
            task.status = TaskStatus.RETRY
            task.scheduled_at = datetime.utcnow() + timedelta(seconds=task.retry_delay)
            
            logger.info(f"Scheduling retry {task.retry_count}/{task.max_retries} for task {task.id}")
            
            # Re-add to queue after delay
            await asyncio.sleep(task.retry_delay)
            task.status = TaskStatus.PENDING
            await self.queue.put(task)
        else:
            logger.error(f"Task {task.id} failed after {task.max_retries} retries")
    
    def stop(self) -> None:
        """Stop worker."""
        self.is_running = False
        logger.info(f"Worker {self.worker_id} stopped")
    
    def get_current_task(self) -> Optional[Task]:
        """Get currently executing task."""
        return self._current_task


class TaskManager:
    """Central task manager for background tasks."""
    
    _instance: Optional['TaskManager'] = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialized = False
        return cls._instance
    
    def __init__(self):
        if self._initialized:
            return
        
        self.queue = TaskQueue()
        self.workers: List[TaskWorker] = []
        self.worker_tasks: List[asyncio.Task] = []
        self.is_running = False
        self._task_registry: Dict[str, Callable] = {}
        self._scheduled_tasks: List[Dict[str, Any]] = []
        self._initialized = True
    
    async def start(self, num_workers: int = 4) -> None:
        """Start task manager with specified number of workers."""
        if self.is_running:
            return
        
        self.is_running = True
        
        # Create workers
        for i in range(num_workers):
            worker = TaskWorker(i, self.queue)
            self.workers.append(worker)
            
            # Start worker task
            worker_task = asyncio.create_task(worker.start())
            self.worker_tasks.append(worker_task)
        
        logger.info(f"Task manager started with {num_workers} workers")
        
        # Start scheduler
        asyncio.create_task(self._run_scheduler())
    
    async def stop(self) -> None:
        """Stop task manager and all workers."""
        if not self.is_running:
            return
        
        self.is_running = False
        
        # Stop all workers
        for worker in self.workers:
            worker.stop()
        
        # Wait for worker tasks to complete
        if self.worker_tasks:
            await asyncio.gather(*self.worker_tasks, return_exceptions=True)
        
        self.workers.clear()
        self.worker_tasks.clear()
        
        logger.info("Task manager stopped")
    
    def register_task(self, name: str, func: Callable) -> None:
        """Register a task function."""
        self._task_registry[name] = func
        logger.debug(f"Registered task: {name}")
    
    async def submit_task(
        self,
        func: Union[Callable, str],
        *args,
        task_id: Optional[str] = None,
        priority: TaskPriority = TaskPriority.NORMAL,
        scheduled_at: Optional[datetime] = None,
        max_retries: int = 3,
        retry_delay: int = 60,
        timeout: Optional[int] = None,
        **kwargs
    ) -> str:
        """Submit a task for execution."""
        import uuid
        
        # Generate task ID if not provided
        if not task_id:
            task_id = str(uuid.uuid4())
        
        # Resolve function if string name provided
        if isinstance(func, str):
            if func not in self._task_registry:
                raise ValueError(f"Task function '{func}' not registered")
            func = self._task_registry[func]
        
        # Create task
        task = Task(
            id=task_id,
            name=func.__name__ if hasattr(func, '__name__') else str(func),
            func=func,
            args=args,
            kwargs=kwargs,
            priority=priority,
            scheduled_at=scheduled_at,
            max_retries=max_retries,
            retry_delay=retry_delay,
            timeout=timeout
        )
        
        # Add to queue
        if scheduled_at and scheduled_at > datetime.utcnow():
            # Schedule for later
            self._scheduled_tasks.append({
                "task": task,
                "scheduled_at": scheduled_at
            })
            logger.info(f"Task {task_id} scheduled for {scheduled_at}")
        else:
            # Execute immediately
            await self.queue.put(task)
            logger.info(f"Task {task_id} submitted for immediate execution")
        
        return task_id
    
    def get_task_status(self, task_id: str) -> Optional[Dict[str, Any]]:
        """Get task status."""
        task = self.queue.get_task(task_id)
        if task:
            return task.to_dict()
        return None
    
    def cancel_task(self, task_id: str) -> bool:
        """Cancel a task."""
        task = self.queue.get_task(task_id)
        if task and task.status == TaskStatus.PENDING:
            task.status = TaskStatus.CANCELLED
            self.queue.remove_task(task_id)
            logger.info(f"Task {task_id} cancelled")
            return True
        return False
    
    def get_queue_stats(self) -> Dict[str, Any]:
        """Get queue statistics."""
        tasks = self.queue.get_all_tasks()
        
        status_counts = {}
        for status in TaskStatus:
            status_counts[status.value] = sum(1 for t in tasks if t.status == status)
        
        return {
            "total_tasks": len(tasks),
            "queue_sizes": {
                priority.value: self.queue.get_queue_size(priority)
                for priority in TaskPriority
            },
            "status_counts": status_counts,
            "active_workers": len(self.workers),
            "running_tasks": [
                worker.get_current_task().id
                for worker in self.workers
                if worker.get_current_task()
            ]
        }
    
    async def _run_scheduler(self) -> None:
        """Run scheduler to check for scheduled tasks."""
        while self.is_running:
            try:
                now = datetime.utcnow()
                tasks_to_run = []
                
                # Check scheduled tasks
                for item in self._scheduled_tasks[:]:
                    if item["scheduled_at"] <= now:
                        tasks_to_run.append(item["task"])
                        self._scheduled_tasks.remove(item)
                
                # Submit tasks
                for task in tasks_to_run:
                    await self.queue.put(task)
                    logger.info(f"Scheduled task {task.id} now running")
                
                # Sleep before next check
                await asyncio.sleep(1)
                
            except Exception as e:
                logger.error(f"Scheduler error: {str(e)}", exc_info=True)


# Global task manager instance
task_manager = TaskManager()


# Decorator for registering tasks
def background_task(
    name: Optional[str] = None,
    priority: TaskPriority = TaskPriority.NORMAL,
    max_retries: int = 3,
    retry_delay: int = 60,
    timeout: Optional[int] = None
):
    """
    Decorator to register a function as a background task.
    
    Usage:
        @background_task(name="send_email", priority=TaskPriority.HIGH)
        async def send_email(to: str, subject: str, body: str):
            # Send email logic
            pass
    """
    def decorator(func: Callable):
        task_name = name or func.__name__
        
        # Register the task
        task_manager.register_task(task_name, func)
        
        # Create wrapper that submits task
        @wraps(func)
        async def wrapper(*args, **kwargs):
            task_id = await task_manager.submit_task(
                func,
                *args,
                priority=priority,
                max_retries=max_retries,
                retry_delay=retry_delay,
                timeout=timeout,
                **kwargs
            )
            return task_id
        
        # Add direct call method
        wrapper.direct = func
        wrapper.task_name = task_name
        
        return wrapper
    
    return decorator


# Periodic task scheduler
class PeriodicTask:
    """Periodic task definition."""
    
    def __init__(
        self,
        func: Callable,
        interval: timedelta,
        name: Optional[str] = None,
        start_immediately: bool = False
    ):
        self.func = func
        self.interval = interval
        self.name = name or func.__name__
        self.start_immediately = start_immediately
        self.last_run: Optional[datetime] = None
        self.next_run: Optional[datetime] = None
        self.is_running = False
    
    async def run(self) -> None:
        """Run the periodic task."""
        self.is_running = True
        
        if self.start_immediately:
            await self._execute()
        
        while self.is_running:
            now = datetime.utcnow()
            
            if self.next_run is None:
                self.next_run = now + self.interval
            
            if now >= self.next_run:
                await self._execute()
                self.last_run = now
                self.next_run = now + self.interval
            
            # Sleep until next run
            sleep_time = (self.next_run - datetime.utcnow()).total_seconds()
            if sleep_time > 0:
                await asyncio.sleep(min(sleep_time, 60))  # Check at least every minute
    
    async def _execute(self) -> None:
        """Execute the task."""
        try:
            logger.info(f"Running periodic task: {self.name}")
            
            if asyncio.iscoroutinefunction(self.func):
                await self.func()
            else:
                loop = asyncio.get_event_loop()
                await loop.run_in_executor(None, self.func)
                
        except Exception as e:
            logger.error(f"Periodic task {self.name} failed: {str(e)}", exc_info=True)
    
    def stop(self) -> None:
        """Stop the periodic task."""
        self.is_running = False


# Built-in tasks
@background_task(name="cleanup_old_sessions", priority=TaskPriority.LOW)
async def cleanup_old_sessions():
    """Clean up expired sessions."""
    from app.services.session_service import SessionService
    service = SessionService()
    count = await service.cleanup_expired_sessions()
    logger.info(f"Cleaned up {count} expired sessions")
    return count


@background_task(name="send_email_notification", priority=TaskPriority.HIGH)
async def send_email_notification(to: str, subject: str, body: str):
    """Send email notification."""
    from app.services.email_service import EmailService
    service = EmailService()
    await service.send_email(to, subject, body)
    logger.info(f"Email sent to {to}")


@background_task(name="generate_report", priority=TaskPriority.NORMAL, timeout=300)
async def generate_report(report_type: str, params: Dict[str, Any]):
    """Generate report."""
    from app.services.report_service import ReportService
    service = ReportService()
    report = await service.generate(report_type, params)
    logger.info(f"Report generated: {report_type}")
    return report