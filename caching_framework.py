#!/usr/bin/env python3
"""
Caching Implementation Framework
Provides comprehensive caching solutions for performance optimization.
"""

import ast
import hashlib
import json
import pickle
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass
from functools import wraps
from pathlib import Path
from typing import Any, Callable, Dict, List, Optional, Set, Tuple, Union
import argparse


# Cache Backends
class CacheBackend(ABC):
    """Abstract base class for cache backends."""
    
    @abstractmethod
    def get(self, key: str) -> Optional[Any]:
        """Retrieve value from cache."""
        pass
    
    @abstractmethod
    def set(self, key: str, value: Any, ttl: Optional[int] = None) -> None:
        """Store value in cache with optional TTL."""
        pass
    
    @abstractmethod
    def delete(self, key: str) -> bool:
        """Remove key from cache."""
        pass
    
    @abstractmethod
    def clear(self) -> None:
        """Clear all cache entries."""
        pass
    
    @abstractmethod
    def exists(self, key: str) -> bool:
        """Check if key exists in cache."""
        pass


class InMemoryCache(CacheBackend):
    """Simple in-memory cache implementation."""
    
    def __init__(self, max_size: int = 1000):
        self.cache: Dict[str, Tuple[Any, Optional[float]]] = {}
        self.access_order: List[str] = []
        self.max_size = max_size
    
    def get(self, key: str) -> Optional[Any]:
        if key in self.cache:
            value, expiry = self.cache[key]
            
            # Check if expired
            if expiry and time.time() > expiry:
                self.delete(key)
                return None
            
            # Update access order (LRU)
            if key in self.access_order:
                self.access_order.remove(key)
            self.access_order.append(key)
            
            return value
        return None
    
    def set(self, key: str, value: Any, ttl: Optional[int] = None) -> None:
        expiry = time.time() + ttl if ttl else None
        
        # Remove if exists to update access order
        if key in self.cache:
            self.access_order.remove(key)
        
        self.cache[key] = (value, expiry)
        self.access_order.append(key)
        
        # Evict oldest if over max size
        while len(self.cache) > self.max_size and self.access_order:
            oldest_key = self.access_order.pop(0)
            if oldest_key in self.cache:
                del self.cache[oldest_key]
    
    def delete(self, key: str) -> bool:
        if key in self.cache:
            del self.cache[key]
            if key in self.access_order:
                self.access_order.remove(key)
            return True
        return False
    
    def clear(self) -> None:
        self.cache.clear()
        self.access_order.clear()
    
    def exists(self, key: str) -> bool:
        if key in self.cache:
            _, expiry = self.cache[key]
            if expiry and time.time() > expiry:
                self.delete(key)
                return False
            return True
        return False


class RedisCache(CacheBackend):
    """Redis cache backend (requires redis-py)."""
    
    def __init__(self, host: str = 'localhost', port: int = 6379, 
                 db: int = 0, prefix: str = 'cache:'):
        self.prefix = prefix
        try:
            import redis
            self.redis = redis.Redis(host=host, port=port, db=db, decode_responses=False)
            self.redis.ping()  # Test connection
        except ImportError:
            raise ImportError("redis-py package required for RedisCache")
        except Exception as e:
            raise ConnectionError(f"Failed to connect to Redis: {e}")
    
    def _make_key(self, key: str) -> str:
        return f"{self.prefix}{key}"
    
    def get(self, key: str) -> Optional[Any]:
        try:
            data = self.redis.get(self._make_key(key))
            if data:
                return pickle.loads(data)
        except Exception:
            pass
        return None
    
    def set(self, key: str, value: Any, ttl: Optional[int] = None) -> None:
        try:
            data = pickle.dumps(value)
            if ttl:
                self.redis.setex(self._make_key(key), ttl, data)
            else:
                self.redis.set(self._make_key(key), data)
        except Exception as e:
            print(f"Cache set error: {e}")
    
    def delete(self, key: str) -> bool:
        try:
            return bool(self.redis.delete(self._make_key(key)))
        except Exception:
            return False
    
    def clear(self) -> None:
        try:
            keys = self.redis.keys(f"{self.prefix}*")
            if keys:
                self.redis.delete(*keys)
        except Exception as e:
            print(f"Cache clear error: {e}")
    
    def exists(self, key: str) -> bool:
        try:
            return bool(self.redis.exists(self._make_key(key)))
        except Exception:
            return False


# Cache Decorators
def cache_result(
    ttl: Optional[int] = None,
    backend: Optional[CacheBackend] = None,
    key_prefix: str = "",
    include_args: bool = True,
    exclude_args: Optional[List[str]] = None
):
    """
    Decorator to cache function results.
    
    Args:
        ttl: Time to live in seconds
        backend: Cache backend to use (default: in-memory)
        key_prefix: Prefix for cache keys
        include_args: Whether to include arguments in cache key
        exclude_args: List of argument names to exclude from cache key
    """
    if backend is None:
        backend = InMemoryCache()
    
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Generate cache key
            cache_key = _generate_cache_key(
                func, args, kwargs, key_prefix, include_args, exclude_args
            )
            
            # Try to get from cache
            cached_result = backend.get(cache_key)
            if cached_result is not None:
                return cached_result
            
            # Execute function and cache result
            result = func(*args, **kwargs)
            backend.set(cache_key, result, ttl)
            
            return result
        
        # Add cache management methods
        wrapper.cache_clear = lambda: backend.clear()
        wrapper.cache_info = lambda: {
            'backend': backend.__class__.__name__,
            'ttl': ttl,
            'prefix': key_prefix
        }
        
        return wrapper
    return decorator


def cache_property(ttl: Optional[int] = None, backend: Optional[CacheBackend] = None):
    """Decorator to cache property results."""
    if backend is None:
        backend = InMemoryCache()
    
    def decorator(func: Callable) -> property:
        @property
        @wraps(func)
        def wrapper(self):
            cache_key = f"{self.__class__.__name__}.{func.__name__}.{id(self)}"
            
            cached_result = backend.get(cache_key)
            if cached_result is not None:
                return cached_result
            
            result = func(self)
            backend.set(cache_key, result, ttl)
            
            return result
        
        return wrapper
    return decorator


def _generate_cache_key(
    func: Callable, 
    args: tuple, 
    kwargs: dict, 
    prefix: str,
    include_args: bool,
    exclude_args: Optional[List[str]]
) -> str:
    """Generate cache key from function and arguments."""
    key_parts = [prefix, func.__module__, func.__name__]
    
    if include_args:
        # Include positional arguments
        if args:
            args_str = str(args)
            key_parts.append(hashlib.md5(args_str.encode()).hexdigest()[:8])
        
        # Include keyword arguments (excluding specified ones)
        if kwargs:
            filtered_kwargs = kwargs.copy()
            if exclude_args:
                for arg in exclude_args:
                    filtered_kwargs.pop(arg, None)
            
            if filtered_kwargs:
                kwargs_str = json.dumps(filtered_kwargs, sort_keys=True, default=str)
                key_parts.append(hashlib.md5(kwargs_str.encode()).hexdigest()[:8])
    
    return ':'.join(filter(None, key_parts))


# Cache Analysis and Optimization
@dataclass
class CacheOpportunity:
    """Represents a potential caching opportunity."""
    file_path: str
    line_number: int
    function_name: str
    opportunity_type: str  # 'expensive_computation', 'database_query', 'api_call', 'permission_check'
    confidence: float
    estimated_benefit: str
    suggested_implementation: str
    explanation: str


class CacheOpportunityDetector(ast.NodeVisitor):
    """Detects potential caching opportunities in code."""
    
    def __init__(self, file_path: str, source_code: str):
        self.file_path = file_path
        self.source_code = source_code
        self.opportunities: List[CacheOpportunity] = []
        self.current_function = None
        self.loop_depth = 0
        
    def visit_FunctionDef(self, node: ast.FunctionDef) -> None:
        """Analyze functions for caching opportunities."""
        old_function = self.current_function
        self.current_function = node.name
        
        # Check if already cached
        has_cache = any(self._is_cache_decorator(dec) for dec in node.decorator_list)
        
        if not has_cache:
            # Check for expensive operations
            expensive_ops = self._find_expensive_operations(node)
            for op_type, confidence, details in expensive_ops:
                opportunity = CacheOpportunity(
                    file_path=self.file_path,
                    line_number=node.lineno,
                    function_name=node.name,
                    opportunity_type=op_type,
                    confidence=confidence,
                    estimated_benefit=self._estimate_benefit(op_type, details),
                    suggested_implementation=self._suggest_implementation(op_type, node.name),
                    explanation=self._explain_opportunity(op_type, details)
                )
                self.opportunities.append(opportunity)
        
        self.generic_visit(node)
        self.current_function = old_function
    
    def visit_For(self, node: ast.For) -> None:
        """Track loop depth for performance analysis."""
        self.loop_depth += 1
        self.generic_visit(node)
        self.loop_depth -= 1
    
    def visit_While(self, node: ast.While) -> None:
        """Track loop depth for performance analysis."""
        self.loop_depth += 1
        self.generic_visit(node)
        self.loop_depth -= 1
    
    def _is_cache_decorator(self, decorator: ast.AST) -> bool:
        """Check if decorator is cache-related."""
        cache_decorators = ['cache', 'lru_cache', 'cached', 'memoize']
        decorator_str = ast.unparse(decorator).lower()
        return any(cache_dec in decorator_str for cache_dec in cache_decorators)
    
    def _find_expensive_operations(self, node: ast.FunctionDef) -> List[Tuple[str, float, Dict]]:
        """Find expensive operations in function."""
        expensive_ops = []
        function_code = ast.unparse(node).lower()
        
        # Database queries
        db_patterns = [
            'query', 'filter', 'get', 'find', 'select', 'session.execute',
            '.objects.', 'model.objects', 'session.query'
        ]
        if any(pattern in function_code for pattern in db_patterns):
            expensive_ops.append(('database_query', 0.8, {'patterns': db_patterns}))
        
        # API calls
        api_patterns = [
            'requests.', 'httpx.', 'aiohttp.', 'urllib.', 'fetch(',
            'post(', 'get(', 'put(', 'delete('
        ]
        if any(pattern in function_code for pattern in api_patterns):
            expensive_ops.append(('api_call', 0.9, {'patterns': api_patterns}))
        
        # Permission checks
        if ('permission' in function_code or 'auth' in function_code or 
            'access' in function_code or 'role' in function_code):
            expensive_ops.append(('permission_check', 0.7, {'type': 'auth'}))
        
        # Expensive computations (heuristic)
        computation_patterns = [
            'for.*in.*for', 'while.*while', 'sort(', 'sorted(',
            'complex', 'heavy', 'calculate', 'compute', 'process'
        ]
        if any(pattern in function_code for pattern in computation_patterns):
            expensive_ops.append(('expensive_computation', 0.6, {'patterns': computation_patterns}))
        
        return expensive_ops
    
    def _estimate_benefit(self, op_type: str, details: Dict) -> str:
        """Estimate performance benefit of caching."""
        benefits = {
            'database_query': 'High - Database queries are typically slow',
            'api_call': 'Very High - Network calls have high latency',
            'permission_check': 'Medium - Reduces authorization overhead',
            'expensive_computation': 'Medium - Depends on computation complexity'
        }
        return benefits.get(op_type, 'Unknown')
    
    def _suggest_implementation(self, op_type: str, function_name: str) -> str:
        """Suggest caching implementation."""
        implementations = {
            'database_query': f"""
@cache_result(ttl=300)  # 5 minutes
def {function_name}(self, ...):
    # Your database query here
    pass
""",
            'api_call': f"""
@cache_result(ttl=3600, backend=redis_cache)  # 1 hour
def {function_name}(self, ...):
    # Your API call here
    pass
""",
            'permission_check': f"""
@cache_result(ttl=600, key_prefix="permissions")  # 10 minutes
def {function_name}(self, user_id, resource):
    # Your permission check here
    pass
""",
            'expensive_computation': f"""
@cache_result(ttl=1800)  # 30 minutes
def {function_name}(self, ...):
    # Your computation here
    pass
"""
        }
        return implementations.get(op_type, f"@cache_result(ttl=300)\ndef {function_name}(...):\n    pass")
    
    def _explain_opportunity(self, op_type: str, details: Dict) -> str:
        """Explain why caching would be beneficial."""
        explanations = {
            'database_query': 'Database queries can be slow and repeated calls with same parameters waste resources',
            'api_call': 'External API calls have network latency and may have rate limits',
            'permission_check': 'Permission checks often involve database lookups and can be cached safely',
            'expensive_computation': 'Complex calculations with same inputs can benefit from result caching'
        }
        return explanations.get(op_type, 'Function appears to perform expensive operations')


class PermissionCacheOptimizer:
    """Specialized optimizer for permission checking systems."""
    
    def __init__(self, cache_backend: Optional[CacheBackend] = None):
        self.cache = cache_backend or InMemoryCache(max_size=5000)
        
    def cache_permission_check(
        self,
        user_id: str,
        resource: str,
        action: str,
        ttl: int = 600  # 10 minutes
    ):
        """Decorator for permission checking functions."""
        def decorator(func: Callable) -> Callable:
            @wraps(func)
            def wrapper(*args, **kwargs):
                # Create cache key from permission check parameters
                cache_key = f"perm:{user_id}:{resource}:{action}"
                
                # Check cache first
                cached_result = self.cache.get(cache_key)
                if cached_result is not None:
                    return cached_result
                
                # Execute permission check
                result = func(*args, **kwargs)
                
                # Cache the result
                self.cache.set(cache_key, result, ttl)
                
                return result
            
            return wrapper
        return decorator
    
    def invalidate_user_permissions(self, user_id: str) -> None:
        """Invalidate all cached permissions for a user."""
        # This would need backend-specific implementation
        # For now, just clear all cache
        self.cache.clear()
    
    def warm_permission_cache(self, user_permissions: Dict[str, Dict[str, bool]]) -> None:
        """Pre-populate cache with user permissions."""
        for user_id, permissions in user_permissions.items():
            for perm_key, has_permission in permissions.items():
                cache_key = f"perm:{user_id}:{perm_key}"
                self.cache.set(cache_key, has_permission, ttl=600)


class CacheFramework:
    """Main caching framework orchestrator."""
    
    def __init__(self, root_path: str = "."):
        self.root_path = Path(root_path)
        self.opportunities: List[CacheOpportunity] = []
    
    def analyze_caching_opportunities(self) -> List[CacheOpportunity]:
        """Analyze codebase for caching opportunities."""
        print("🔍 Analyzing caching opportunities...")
        
        python_files = list(self.root_path.rglob("*.py"))
        
        for file_path in python_files:
            if self._should_skip_file(file_path):
                continue
            
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    source_code = f.read()
                
                detector = CacheOpportunityDetector(str(file_path), source_code)
                detector.visit(ast.parse(source_code))
                
                self.opportunities.extend(detector.opportunities)
                
            except Exception as e:
                print(f"❌ Error analyzing {file_path}: {e}")
                continue
        
        return self.opportunities
    
    def _should_skip_file(self, file_path: Path) -> bool:
        """Check if file should be skipped."""
        skip_patterns = [
            '__pycache__', '.git', 'venv', 'env', 'node_modules',
            '.pytest_cache', '.mypy_cache', 'migrations'
        ]
        
        return any(pattern in str(file_path) for pattern in skip_patterns)
    
    def generate_caching_implementations(self, opportunities: List[CacheOpportunity]) -> str:
        """Generate caching implementation code."""
        if not opportunities:
            return "# No caching opportunities found"
        
        implementations = [
            "# 🚀 Recommended Caching Implementations",
            "",
            "from functools import lru_cache",
            "from typing import Any, Optional",
            "import time",
            "",
            "# Cache backends (choose one)",
            "# Option 1: Simple in-memory cache",
            "cache_backend = InMemoryCache(max_size=1000)",
            "",
            "# Option 2: Redis cache (requires redis-py)",
            "# cache_backend = RedisCache(host='localhost', port=6379)",
            "",
        ]
        
        # Group opportunities by type
        by_type = {}
        for opp in opportunities:
            if opp.opportunity_type not in by_type:
                by_type[opp.opportunity_type] = []
            by_type[opp.opportunity_type].append(opp)
        
        for op_type, opps in by_type.items():
            implementations.extend([
                f"# {op_type.replace('_', ' ').title()} Optimizations",
                ""
            ])
            
            for opp in opps[:3]:  # Show top 3 per type
                implementations.extend([
                    f"# File: {opp.file_path}:{opp.line_number}",
                    f"# Confidence: {opp.confidence:.1%}",
                    f"# Benefit: {opp.estimated_benefit}",
                    opp.suggested_implementation.strip(),
                    ""
                ])
        
        return "\n".join(implementations)
    
    def generate_report(self, opportunities: List[CacheOpportunity]) -> str:
        """Generate comprehensive caching report."""
        if not opportunities:
            return "# 🚀 Caching Analysis Report\n\n✅ No obvious caching opportunities found!"
        
        report = ["# 🚀 Caching Optimization Report", ""]
        
        # Summary
        high_confidence = [o for o in opportunities if o.confidence > 0.7]
        by_type = {}
        for opp in opportunities:
            by_type[opp.opportunity_type] = by_type.get(opp.opportunity_type, 0) + 1
        
        report.extend([
            f"## 📊 Summary",
            f"- **Total Opportunities**: {len(opportunities)}",
            f"- **High Confidence**: {len(high_confidence)}",
            f"- **Opportunity Types**: {', '.join(f'{k.replace('_', ' ').title()}: {v}' for k, v in by_type.items())}",
            ""
        ])
        
        # Detailed opportunities
        report.extend([
            "## 🎯 Caching Opportunities",
            ""
        ])
        
        for i, opp in enumerate(sorted(opportunities, key=lambda x: x.confidence, reverse=True), 1):
            confidence_emoji = "🟢" if opp.confidence > 0.7 else "🟡" if opp.confidence > 0.5 else "🔴"
            
            report.extend([
                f"### {i}. {opp.function_name}() - {opp.opportunity_type.replace('_', ' ').title()} {confidence_emoji}",
                f"**File**: `{opp.file_path}:{opp.line_number}`",
                f"**Confidence**: {opp.confidence:.1%}",
                f"**Estimated Benefit**: {opp.estimated_benefit}",
                "",
                f"**Explanation**: {opp.explanation}",
                "",
                f"**Suggested Implementation**:",
                f"```python",
                opp.suggested_implementation.strip(),
                f"```",
                "",
                "---",
                ""
            ])
        
        # Best practices
        report.extend([
            "## 💡 Caching Best Practices",
            "",
            "### When to Use Caching",
            "- Functions with expensive computations",
            "- Database queries with repeated parameters",
            "- External API calls",
            "- Permission/authorization checks",
            "",
            "### Cache TTL Guidelines",
            "- **Database queries**: 5-15 minutes",
            "- **API calls**: 30-60 minutes",
            "- **Permission checks**: 5-10 minutes",
            "- **Static data**: Several hours",
            "",
            "### Cache Invalidation Strategies",
            "- Time-based expiration (TTL)",
            "- Event-based invalidation",
            "- Cache warming on startup",
            "- Graceful cache refreshing",
            ""
        ])
        
        return "\n".join(report)


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Analyze and implement caching optimizations")
    parser.add_argument("--path", "-p", default=".", help="Path to analyze")
    parser.add_argument("--output", "-o", help="Output file for report")
    parser.add_argument("--generate-code", "-g", action="store_true", 
                       help="Generate implementation code")
    
    args = parser.parse_args()
    
    framework = CacheFramework(args.path)
    opportunities = framework.analyze_caching_opportunities()
    
    if args.generate_code:
        implementations = framework.generate_caching_implementations(opportunities)
        code_file = args.output or "caching_implementations.py"
        with open(code_file, 'w', encoding='utf-8') as f:
            f.write(implementations)
        print(f"📝 Implementation code saved to {code_file}")
    
    report = framework.generate_report(opportunities)
    
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(report)
        print(f"📝 Report saved to {args.output}")
    else:
        print(report)
    
    return len(opportunities)


if __name__ == "__main__":
    exit_code = main()
    exit(min(exit_code, 127))