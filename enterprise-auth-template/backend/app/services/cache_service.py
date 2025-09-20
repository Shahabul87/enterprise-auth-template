"""
Multi-Tier Cache Service

Provides comprehensive caching capabilities with multiple cache levels:
- L1 Cache: User permissions and frequently accessed data (5min TTL)
- L2 Cache: Database query results (15min TTL)
- L3 Cache: Static data and configuration (1hr TTL)

This service addresses performance bottlenecks identified in the improvement plan
by implementing strategic caching to reduce database load and improve response times.
"""

import hashlib
import json
import pickle
from datetime import timedelta
from typing import Any, Dict, List, Optional, Union

import redis.asyncio as redis
import structlog

from app.core.config import get_settings

settings = get_settings()
logger = structlog.get_logger(__name__)


class CacheService:
    """
    Multi-tier caching service with Redis backend.

    Implements intelligent caching strategies to optimize database performance
    and reduce N+1 query problems identified in the audit.
    """

    def __init__(self, redis_url: Optional[str] = None) -> None:
        """
        Initialize cache service.

        Args:
            redis_url: Redis connection URL. Uses settings if not provided.
        """
        self.redis_url = redis_url or settings.REDIS_URL
        self._redis: Optional[redis.Redis] = None

    async def get_redis(self) -> redis.Redis:
        """Get Redis connection, creating it if needed."""
        if self._redis is None:
            if not self.redis_url:
                raise ValueError("Redis URL is not configured")
            self._redis = redis.from_url(
                self.redis_url,
                encoding="utf-8",
                decode_responses=False,  # Handle binary data
                socket_keepalive=True,
                socket_keepalive_options={},
                health_check_interval=30,
            )
        return self._redis

    async def close(self) -> None:
        """Close Redis connection."""
        if self._redis:
            await self._redis.close()

    # Generic cache operations

    async def get(self, key: str) -> Optional[Any]:
        """
        Get a value from cache.

        Args:
            key: Cache key

        Returns:
            Cached value or None if not found
        """
        try:
            redis_client = await self.get_redis()
            value = await redis_client.get(key)
            if value:
                try:
                    # Try to deserialize as JSON first
                    return json.loads(value)
                except (json.JSONDecodeError, TypeError):
                    # If not JSON, try pickle
                    try:
                        return pickle.loads(value)
                    except (pickle.PickleError, TypeError):
                        # Return as string if all else fails
                        return (
                            value.decode("utf-8") if isinstance(value, bytes) else value
                        )
            return None
        except Exception as e:
            logger.error("Failed to get cache value", key=key, error=str(e))
            return None

    async def set(self, key: str, value: Any, ttl: Optional[int] = None) -> bool:
        """
        Set a value in cache.

        Args:
            key: Cache key
            value: Value to cache
            ttl: Time to live in seconds (optional)

        Returns:
            True if successful
        """
        try:
            redis_client = await self.get_redis()

            # Serialize value
            serialized: Union[str, bytes]
            if isinstance(value, (dict, list)):
                serialized = json.dumps(value)
            elif isinstance(value, str):
                serialized = value
            else:
                serialized = pickle.dumps(value)

            if ttl:
                await redis_client.setex(key, timedelta(seconds=ttl), serialized)
            else:
                await redis_client.set(key, serialized)

            logger.debug("Cache value set", key=key, ttl=ttl)
            return True
        except Exception as e:
            logger.error("Failed to set cache value", key=key, error=str(e))
            return False

    async def delete(self, key: str) -> bool:
        """
        Delete a value from cache.

        Args:
            key: Cache key

        Returns:
            True if successful
        """
        try:
            redis_client = await self.get_redis()
            await redis_client.delete(key)
            logger.debug("Cache value deleted", key=key)
            return True
        except Exception as e:
            logger.error("Failed to delete cache value", key=key, error=str(e))
            return False

    async def delete_pattern(self, pattern: str) -> int:
        """
        Delete all keys matching a pattern.

        Args:
            pattern: Key pattern (e.g., "user:*")

        Returns:
            Number of keys deleted
        """
        try:
            redis_client = await self.get_redis()
            keys = []
            async for key in redis_client.scan_iter(match=pattern):
                keys.append(key)

            if keys:
                deleted = await redis_client.delete(*keys)
                logger.debug("Cache keys deleted", pattern=pattern, count=deleted)
                return deleted
            return 0
        except Exception as e:
            logger.error(
                "Failed to delete cache pattern", pattern=pattern, error=str(e)
            )
            return 0

    async def flush_all(self) -> bool:
        """
        Flush all cache entries.

        Returns:
            True if successful
        """
        try:
            redis_client = await self.get_redis()
            await redis_client.flushdb()
            logger.warning("All cache entries flushed")
            return True
        except Exception as e:
            logger.error("Failed to flush cache", error=str(e))
            return False

    # L1 Cache: User permissions and session data (5min TTL)

    async def cache_user_permissions(
        self, user_id: str, permissions: List[str]
    ) -> bool:
        """
        Cache user permissions with 5-minute TTL.

        Args:
            user_id: User ID
            permissions: List of user permissions

        Returns:
            bool: True if cached successfully
        """
        try:
            cache_key = f"user_permissions:{user_id}"
            redis_client = await self.get_redis()

            await redis_client.setex(
                cache_key, timedelta(minutes=5), json.dumps(permissions)
            )

            logger.debug(
                "User permissions cached",
                user_id=user_id,
                permission_count=len(permissions),
                cache_key=cache_key,
            )
            return True

        except Exception as e:
            logger.error(
                "Failed to cache user permissions", user_id=user_id, error=str(e)
            )
            return False

    async def get_user_permissions(self, user_id: str) -> Optional[List[str]]:
        """
        Get cached user permissions.

        Args:
            user_id: User ID

        Returns:
            List[str] or None: Cached permissions or None if not found
        """
        try:
            cache_key = f"user_permissions:{user_id}"
            redis_client = await self.get_redis()

            cached = await redis_client.get(cache_key)
            if cached:
                permissions = json.loads(cached)
                logger.debug(
                    "User permissions cache hit",
                    user_id=user_id,
                    permission_count=len(permissions),
                )
                return permissions

            logger.debug("User permissions cache miss", user_id=user_id)
            return None

        except Exception as e:
            logger.error(
                "Failed to get cached user permissions", user_id=user_id, error=str(e)
            )
            return None

    async def invalidate_user_permissions(self, user_id: str) -> bool:
        """
        Invalidate cached user permissions.

        Args:
            user_id: User ID

        Returns:
            bool: True if invalidated successfully
        """
        try:
            cache_key = f"user_permissions:{user_id}"
            redis_client = await self.get_redis()

            await redis_client.delete(cache_key)
            logger.debug("User permissions cache invalidated", user_id=user_id)
            return True

        except Exception as e:
            logger.error(
                "Failed to invalidate user permissions cache",
                user_id=user_id,
                error=str(e),
            )
            return False

    async def cache_user_roles(self, user_id: str, roles: List[Dict[str, Any]]) -> bool:
        """
        Cache user roles with 5-minute TTL.

        Args:
            user_id: User ID
            roles: List of user roles with permissions

        Returns:
            bool: True if cached successfully
        """
        try:
            cache_key = f"user_roles:{user_id}"
            redis_client = await self.get_redis()

            await redis_client.setex(cache_key, timedelta(minutes=5), json.dumps(roles))

            logger.debug(
                "User roles cached",
                user_id=user_id,
                role_count=len(roles),
                cache_key=cache_key,
            )
            return True

        except Exception as e:
            logger.error("Failed to cache user roles", user_id=user_id, error=str(e))
            return False

    async def get_user_roles(self, user_id: str) -> Optional[List[Dict[str, Any]]]:
        """
        Get cached user roles.

        Args:
            user_id: User ID

        Returns:
            List[Dict] or None: Cached roles or None if not found
        """
        try:
            cache_key = f"user_roles:{user_id}"
            redis_client = await self.get_redis()

            cached = await redis_client.get(cache_key)
            if cached:
                roles = json.loads(cached)
                logger.debug(
                    "User roles cache hit", user_id=user_id, role_count=len(roles)
                )
                return roles

            logger.debug("User roles cache miss", user_id=user_id)
            return None

        except Exception as e:
            logger.error(
                "Failed to get cached user roles", user_id=user_id, error=str(e)
            )
            return None

    # L2 Cache: Database query results (15min TTL)

    async def cache_query_result(
        self, query_hash: str, result: Any, ttl_minutes: int = 15
    ) -> bool:
        """
        Cache database query results.

        Args:
            query_hash: Hash of the query for cache key
            result: Query result to cache
            ttl_minutes: Time to live in minutes

        Returns:
            bool: True if cached successfully
        """
        try:
            cache_key = f"query_result:{query_hash}"
            redis_client = await self.get_redis()

            # Use pickle for complex objects
            serialized = pickle.dumps(result)
            await redis_client.setex(
                cache_key, timedelta(minutes=ttl_minutes), serialized
            )

            logger.debug(
                "Query result cached", query_hash=query_hash, ttl_minutes=ttl_minutes
            )
            return True

        except Exception as e:
            logger.error(
                "Failed to cache query result", query_hash=query_hash, error=str(e)
            )
            return False

    async def get_query_result(self, query_hash: str) -> Any:
        """
        Get cached query result.

        Args:
            query_hash: Hash of the query

        Returns:
            Any: Cached result or None if not found
        """
        try:
            cache_key = f"query_result:{query_hash}"
            redis_client = await self.get_redis()

            cached = await redis_client.get(cache_key)
            if cached:
                result = pickle.loads(cached)
                logger.debug("Query result cache hit", query_hash=query_hash)
                return result

            logger.debug("Query result cache miss", query_hash=query_hash)
            return None

        except Exception as e:
            logger.error(
                "Failed to get cached query result", query_hash=query_hash, error=str(e)
            )
            return None

    def generate_query_hash(self, query: str, params: Dict[str, Any]) -> str:
        """
        Generate consistent hash for query and parameters.

        Args:
            query: SQL query string
            params: Query parameters

        Returns:
            str: Hash of query and parameters
        """
        query_string = f"{query}:{json.dumps(params, sort_keys=True)}"
        return hashlib.sha256(query_string.encode()).hexdigest()

    # L3 Cache: Static data and configuration (1hr TTL)

    async def cache_static_data(self, key: str, data: Any, ttl_hours: int = 1) -> bool:
        """
        Cache static data with 1-hour TTL.

        Args:
            key: Cache key
            data: Data to cache
            ttl_hours: Time to live in hours

        Returns:
            bool: True if cached successfully
        """
        try:
            cache_key = f"static:{key}"
            redis_client = await self.get_redis()

            await redis_client.setex(
                cache_key, timedelta(hours=ttl_hours), json.dumps(data)
            )

            logger.debug("Static data cached", key=key, ttl_hours=ttl_hours)
            return True

        except Exception as e:
            logger.error("Failed to cache static data", key=key, error=str(e))
            return False

    async def get_static_data(self, key: str) -> Any:
        """
        Get cached static data.

        Args:
            key: Cache key

        Returns:
            Any: Cached data or None if not found
        """
        try:
            cache_key = f"static:{key}"
            redis_client = await self.get_redis()

            cached = await redis_client.get(cache_key)
            if cached:
                data = json.loads(cached)
                logger.debug("Static data cache hit", key=key)
                return data

            logger.debug("Static data cache miss", key=key)
            return None

        except Exception as e:
            logger.error("Failed to get cached static data", key=key, error=str(e))
            return None

    # Cache management utilities

    async def clear_user_cache(self, user_id: str) -> bool:
        """
        Clear all cached data for a user.

        Args:
            user_id: User ID

        Returns:
            bool: True if cleared successfully
        """
        try:
            redis_client = await self.get_redis()

            patterns = [
                f"user_permissions:{user_id}",
                f"user_roles:{user_id}",
            ]

            for pattern in patterns:
                await redis_client.delete(pattern)

            logger.info("User cache cleared", user_id=user_id)
            return True

        except Exception as e:
            logger.error("Failed to clear user cache", user_id=user_id, error=str(e))
            return False

    async def clear_all_cache(self) -> bool:
        """
        Clear all cached data (use with caution).

        Returns:
            bool: True if cleared successfully
        """
        try:
            redis_client = await self.get_redis()
            await redis_client.flushdb()

            logger.warning("All cache cleared")
            return True

        except Exception as e:
            logger.error("Failed to clear all cache", error=str(e))
            return False

    async def get_cache_stats(self) -> Dict[str, Any]:
        """
        Get cache statistics.

        Returns:
            Dict: Cache statistics
        """
        try:
            redis_client = await self.get_redis()
            info = await redis_client.info()

            return {
                "connected_clients": info.get("connected_clients", 0),
                "used_memory": info.get("used_memory", 0),
                "used_memory_human": info.get("used_memory_human", "0B"),
                "keyspace_hits": info.get("keyspace_hits", 0),
                "keyspace_misses": info.get("keyspace_misses", 0),
                "hit_rate": (
                    info.get("keyspace_hits", 0)
                    / max(
                        info.get("keyspace_hits", 0) + info.get("keyspace_misses", 0), 1
                    )
                )
                * 100,
            }

        except Exception as e:
            logger.error("Failed to get cache stats", error=str(e))
            return {}


# Global cache service instance
cache_service = CacheService()


async def get_cache_service() -> CacheService:
    """Dependency function to get cache service."""
    return cache_service
