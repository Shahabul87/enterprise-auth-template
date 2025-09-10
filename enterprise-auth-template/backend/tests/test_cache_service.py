"""
Tests for Cache Service

Tests the multi-tier caching functionality implemented in Phase 2,
including performance optimizations and cache strategies.
"""

import json
import pytest
from unittest.mock import AsyncMock, patch

from app.services.cache_service import CacheService


class TestCacheService:
    """Test suite for CacheService functionality."""

    @pytest.fixture
    def mock_redis(self):
        """Mock Redis client."""
        redis_mock = AsyncMock()
        redis_mock.get.return_value = None
        redis_mock.setex.return_value = True
        redis_mock.delete.return_value = True
        redis_mock.flushdb.return_value = True
        redis_mock.info.return_value = {
            "connected_clients": 1,
            "used_memory": 1024,
            "used_memory_human": "1K",
            "keyspace_hits": 100,
            "keyspace_misses": 20,
        }
        return redis_mock

    @pytest.fixture
    def cache_service(self, mock_redis):
        """Cache service with mocked Redis."""
        service = CacheService()
        service._redis = mock_redis
        return service

    @pytest.mark.asyncio
    async def test_cache_user_permissions_success(self, cache_service, mock_redis):
        """Test successful user permissions caching."""
        user_id = "test-user-id"
        permissions = ["read:posts", "write:posts", "admin:manage"]
        
        result = await cache_service.cache_user_permissions(user_id, permissions)
        
        assert result is True
        mock_redis.setex.assert_called_once()
        call_args = mock_redis.setex.call_args
        assert call_args[0][0] == f"user_permissions:{user_id}"
        assert json.loads(call_args[0][2]) == permissions

    @pytest.mark.asyncio
    async def test_get_user_permissions_cache_hit(self, cache_service, mock_redis):
        """Test successful retrieval of cached permissions."""
        user_id = "test-user-id"
        permissions = ["read:posts", "write:posts"]
        mock_redis.get.return_value = json.dumps(permissions)
        
        result = await cache_service.get_user_permissions(user_id)
        
        assert result == permissions
        mock_redis.get.assert_called_once_with(f"user_permissions:{user_id}")

    @pytest.mark.asyncio
    async def test_get_user_permissions_cache_miss(self, cache_service, mock_redis):
        """Test cache miss scenario."""
        user_id = "test-user-id"
        mock_redis.get.return_value = None
        
        result = await cache_service.get_user_permissions(user_id)
        
        assert result is None
        mock_redis.get.assert_called_once_with(f"user_permissions:{user_id}")

    @pytest.mark.asyncio
    async def test_invalidate_user_permissions(self, cache_service, mock_redis):
        """Test cache invalidation."""
        user_id = "test-user-id"
        
        result = await cache_service.invalidate_user_permissions(user_id)
        
        assert result is True
        mock_redis.delete.assert_called_once_with(f"user_permissions:{user_id}")

    @pytest.mark.asyncio
    async def test_cache_user_roles(self, cache_service, mock_redis):
        """Test user roles caching."""
        user_id = "test-user-id"
        roles = [
            {"id": "role1", "name": "admin", "permissions": []},
            {"id": "role2", "name": "user", "permissions": []},
        ]
        
        result = await cache_service.cache_user_roles(user_id, roles)
        
        assert result is True
        mock_redis.setex.assert_called_once()
        call_args = mock_redis.setex.call_args
        assert call_args[0][0] == f"user_roles:{user_id}"
        assert json.loads(call_args[0][2]) == roles

    @pytest.mark.asyncio
    async def test_get_user_roles_cache_hit(self, cache_service, mock_redis):
        """Test successful retrieval of cached roles."""
        user_id = "test-user-id"
        roles = [{"id": "role1", "name": "admin"}]
        mock_redis.get.return_value = json.dumps(roles)
        
        result = await cache_service.get_user_roles(user_id)
        
        assert result == roles
        mock_redis.get.assert_called_once_with(f"user_roles:{user_id}")

    @pytest.mark.asyncio
    async def test_cache_query_result(self, cache_service, mock_redis):
        """Test database query result caching."""
        query_hash = "test-query-hash"
        result_data = {"users": [{"id": 1, "name": "Test"}]}
        
        result = await cache_service.cache_query_result(query_hash, result_data)
        
        assert result is True
        mock_redis.setex.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_query_result_with_pickle(self, cache_service, mock_redis):
        """Test retrieval of cached query results with pickle."""
        import pickle
        query_hash = "test-query-hash"
        result_data = {"users": [{"id": 1, "name": "Test"}]}
        mock_redis.get.return_value = pickle.dumps(result_data)
        
        result = await cache_service.get_query_result(query_hash)
        
        assert result == result_data
        mock_redis.get.assert_called_once_with(f"query_result:{query_hash}")

    @pytest.mark.asyncio
    async def test_generate_query_hash(self, cache_service):
        """Test query hash generation for consistent caching."""
        query = "SELECT * FROM users WHERE id = ?"
        params = {"user_id": "123", "limit": 10}
        
        hash1 = cache_service.generate_query_hash(query, params)
        hash2 = cache_service.generate_query_hash(query, params)
        
        assert hash1 == hash2  # Same query should produce same hash
        assert isinstance(hash1, str)
        assert len(hash1) == 64  # SHA256 hex digest length

    @pytest.mark.asyncio
    async def test_cache_static_data(self, cache_service, mock_redis):
        """Test static data caching."""
        key = "system_settings"
        data = {"max_users": 1000, "maintenance_mode": False}
        
        result = await cache_service.cache_static_data(key, data)
        
        assert result is True
        mock_redis.setex.assert_called_once()
        call_args = mock_redis.setex.call_args
        assert call_args[0][0] == f"static:{key}"
        assert json.loads(call_args[0][2]) == data

    @pytest.mark.asyncio
    async def test_get_static_data(self, cache_service, mock_redis):
        """Test static data retrieval."""
        key = "system_settings"
        data = {"max_users": 1000}
        mock_redis.get.return_value = json.dumps(data)
        
        result = await cache_service.get_static_data(key)
        
        assert result == data
        mock_redis.get.assert_called_once_with(f"static:{key}")

    @pytest.mark.asyncio
    async def test_clear_user_cache(self, cache_service, mock_redis):
        """Test clearing all cached data for a user."""
        user_id = "test-user-id"
        
        result = await cache_service.clear_user_cache(user_id)
        
        assert result is True
        # Should delete both permissions and roles cache
        assert mock_redis.delete.call_count == 2
        delete_calls = [call[0][0] for call in mock_redis.delete.call_args_list]
        assert f"user_permissions:{user_id}" in delete_calls
        assert f"user_roles:{user_id}" in delete_calls

    @pytest.mark.asyncio
    async def test_clear_all_cache(self, cache_service, mock_redis):
        """Test clearing all cached data."""
        result = await cache_service.clear_all_cache()
        
        assert result is True
        mock_redis.flushdb.assert_called_once()

    @pytest.mark.asyncio
    async def test_get_cache_stats(self, cache_service, mock_redis):
        """Test cache statistics retrieval."""
        stats = await cache_service.get_cache_stats()
        
        assert isinstance(stats, dict)
        assert "connected_clients" in stats
        assert "used_memory" in stats
        assert "keyspace_hits" in stats
        assert "keyspace_misses" in stats
        assert "hit_rate" in stats
        assert round(stats["hit_rate"], 2) == 83.33  # 100/(100+20) * 100

    @pytest.mark.asyncio
    async def test_cache_error_handling(self, mock_redis):
        """Test error handling in cache operations."""
        cache_service = CacheService()
        cache_service._redis = mock_redis
        
        # Simulate Redis connection error
        mock_redis.setex.side_effect = Exception("Redis connection failed")
        
        result = await cache_service.cache_user_permissions("user1", ["permission1"])
        
        assert result is False  # Should return False on error

    @pytest.mark.asyncio
    async def test_cache_service_initialization(self):
        """Test cache service initialization."""
        service = CacheService("redis://localhost:6379/1")
        
        assert service.redis_url == "redis://localhost:6379/1"
        assert service._redis is None

    @pytest.mark.performance
    @pytest.mark.asyncio
    async def test_cache_performance_ttl(self, cache_service, mock_redis):
        """Test different TTL values for cache performance optimization."""
        user_id = "test-user-id"
        permissions = ["read:posts"]
        
        # Test L1 Cache (5 min TTL)
        await cache_service.cache_user_permissions(user_id, permissions)
        call_args = mock_redis.setex.call_args
        assert call_args[0][1].total_seconds() == 300  # 5 minutes
        
        # Test L2 Cache (15 min TTL)
        await cache_service.cache_query_result("query1", {"data": "test"}, 15)
        call_args = mock_redis.setex.call_args
        assert call_args[0][1].total_seconds() == 900  # 15 minutes
        
        # Test L3 Cache (1 hour TTL)
        await cache_service.cache_static_data("config", {"setting": "value"})
        call_args = mock_redis.setex.call_args
        assert call_args[0][1].total_seconds() == 3600  # 1 hour

    @pytest.mark.integration
    @pytest.mark.asyncio
    async def test_cache_service_with_mock_cache_service(self, mock_cache_service):
        """Integration test with MockCacheService from conftest."""
        user_id = "test-user-id"
        permissions = ["read:posts", "write:posts"]
        
        # Test caching
        result = await mock_cache_service.cache_user_permissions(user_id, permissions)
        assert result is True
        
        # Test retrieval
        cached_permissions = await mock_cache_service.get_user_permissions(user_id)
        assert cached_permissions == permissions
        
        # Test invalidation
        result = await mock_cache_service.invalidate_user_permissions(user_id)
        assert result is True
        
        # Verify cache miss after invalidation
        cached_permissions = await mock_cache_service.get_user_permissions(user_id)
        assert cached_permissions is None