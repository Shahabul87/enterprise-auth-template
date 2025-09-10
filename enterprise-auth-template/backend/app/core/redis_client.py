"""
Redis Client Configuration

Provides Redis client instances for caching and session management.
"""

import redis.asyncio as redis
from typing import Optional
import structlog

from app.core.config import get_settings

logger = structlog.get_logger(__name__)
settings = get_settings()

_redis_client: Optional[redis.Redis] = None


async def init_redis() -> None:
    """Initialize Redis connection"""
    global _redis_client
    
    if settings.REDIS_URL:
        try:
            _redis_client = redis.from_url(
                str(settings.REDIS_URL),
                encoding="utf-8",
                decode_responses=True,
                socket_keepalive=True,
                socket_keepalive_options={},
                health_check_interval=30,
                retry_on_timeout=True,
                max_connections=20
            )
            
            # Test connection
            await _redis_client.ping()
            logger.info("Redis connection established")
            
        except Exception as e:
            logger.error("Failed to connect to Redis", error=str(e))
            _redis_client = None
    else:
        logger.warning("Redis URL not configured")


async def close_redis() -> None:
    """Close Redis connection"""
    global _redis_client
    
    if _redis_client:
        await _redis_client.close()
        _redis_client = None
        logger.info("Redis connection closed")


def get_redis_client() -> redis.Redis:
    """Get Redis client instance"""
    if not _redis_client:
        raise RuntimeError("Redis client not initialized")
    return _redis_client


class RedisClient:
    """Redis client wrapper with additional functionality"""
    
    def __init__(self):
        self.client = get_redis_client()
    
    async def get(self, key: str) -> Optional[str]:
        """Get value by key"""
        try:
            return await self.client.get(key)
        except Exception as e:
            logger.error("Redis GET error", key=key, error=str(e))
            return None
    
    async def set(self, key: str, value: str, ex: Optional[int] = None) -> bool:
        """Set key-value pair"""
        try:
            return await self.client.set(key, value, ex=ex)
        except Exception as e:
            logger.error("Redis SET error", key=key, error=str(e))
            return False
    
    async def setex(self, key: str, time: int, value: str) -> bool:
        """Set key-value pair with expiration"""
        try:
            return await self.client.setex(key, time, value)
        except Exception as e:
            logger.error("Redis SETEX error", key=key, error=str(e))
            return False
    
    async def delete(self, *keys: str) -> int:
        """Delete keys"""
        try:
            return await self.client.delete(*keys)
        except Exception as e:
            logger.error("Redis DELETE error", keys=keys, error=str(e))
            return 0
    
    async def exists(self, key: str) -> bool:
        """Check if key exists"""
        try:
            return bool(await self.client.exists(key))
        except Exception as e:
            logger.error("Redis EXISTS error", key=key, error=str(e))
            return False
    
    async def incr(self, key: str) -> int:
        """Increment key value"""
        try:
            return await self.client.incr(key)
        except Exception as e:
            logger.error("Redis INCR error", key=key, error=str(e))
            return 0
    
    async def expire(self, key: str, time: int) -> bool:
        """Set key expiration"""
        try:
            return await self.client.expire(key, time)
        except Exception as e:
            logger.error("Redis EXPIRE error", key=key, error=str(e))
            return False
    
    async def keys(self, pattern: str) -> list:
        """Get keys by pattern"""
        try:
            return await self.client.keys(pattern)
        except Exception as e:
            logger.error("Redis KEYS error", pattern=pattern, error=str(e))
            return []
    
    async def ping(self) -> bool:
        """Ping Redis"""
        try:
            await self.client.ping()
            return True
        except Exception as e:
            logger.error("Redis PING error", error=str(e))
            return False