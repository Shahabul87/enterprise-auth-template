"""
Search Service

Provides comprehensive search capabilities across all application data with
full-text search, filtering, faceting, and analytics.
"""

import json
import re
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any, Tuple, Union
from uuid import uuid4
from enum import Enum

import structlog
from sqlalchemy import (
    select, and_, or_, desc, asc, func, text,
    cast, String, Integer, DateTime
)
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.config import get_settings
from app.core.events import EventEmitter, Event
from app.models.user import User
from app.models.role import Role
from app.models.audit import AuditLog
from app.models.session import UserSession
from app.models.notification import Notification
from app.models.webhook import WebhookDelivery
from app.services.cache_service import CacheService

settings = get_settings()
logger = structlog.get_logger(__name__)


class SearchScope(str, Enum):
    """Available search scopes."""
    USERS = "users"
    AUDIT_LOGS = "audit_logs"
    SESSIONS = "sessions"
    NOTIFICATIONS = "notifications"
    WEBHOOKS = "webhooks"
    ALL = "all"


class SearchOperator(str, Enum):
    """Search operators for query building."""
    EQUALS = "eq"
    NOT_EQUALS = "ne"
    GREATER_THAN = "gt"
    GREATER_EQUAL = "gte"
    LESS_THAN = "lt"
    LESS_EQUAL = "lte"
    CONTAINS = "contains"
    STARTS_WITH = "starts_with"
    ENDS_WITH = "ends_with"
    IN = "in"
    NOT_IN = "not_in"
    IS_NULL = "is_null"
    IS_NOT_NULL = "is_not_null"
    BETWEEN = "between"
    REGEX = "regex"


class SortOrder(str, Enum):
    """Sort order options."""
    ASC = "asc"
    DESC = "desc"


class SearchError(Exception):
    """Base exception for search-related errors."""
    pass


class SearchValidationError(SearchError):
    """Exception raised when search validation fails."""
    pass


class SearchService:
    """
    Comprehensive search service with advanced querying capabilities.

    Features:
    - Full-text search across multiple entities
    - Advanced filtering with multiple operators
    - Faceted search with aggregations
    - Auto-complete and suggestions
    - Search analytics and trending
    - Saved searches and search history
    - Security-aware search (respects permissions)
    - High-performance with caching
    - Search result highlighting
    - Export search results
    """

    def __init__(
        self,
        session: AsyncSession,
        cache_service: Optional[CacheService] = None,
        event_emitter: Optional[EventEmitter] = None
    ) -> None:
        """
        Initialize search service.

        Args:
            session: Database session
            cache_service: Cache service for performance optimization
            event_emitter: Event emitter for audit logging
        """
        self.session = session
        self.cache_service = cache_service or CacheService()
        self.event_emitter = event_emitter or EventEmitter()

        # Search configuration
        self.max_results = getattr(settings, 'MAX_SEARCH_RESULTS', 1000)
        self.default_page_size = getattr(settings, 'DEFAULT_SEARCH_PAGE_SIZE', 20)
        self.cache_ttl = getattr(settings, 'SEARCH_CACHE_TTL', 300)  # 5 minutes

        # Model mappings for search scopes
        self.scope_models = {
            SearchScope.USERS: User,
            SearchScope.AUDIT_LOGS: AuditLog,
            SearchScope.SESSIONS: UserSession,
            SearchScope.NOTIFICATIONS: Notification,
            SearchScope.WEBHOOKS: WebhookDelivery,
        }

        # Searchable fields for each scope
        self.searchable_fields = {
            SearchScope.USERS: [
                'email', 'full_name', 'phone_number',
                'created_at', 'last_login', 'is_active', 'is_verified'
            ],
            SearchScope.AUDIT_LOGS: [
                'action', 'user_email', 'description', 'result',
                'ip_address', 'user_agent', 'timestamp'
            ],
            SearchScope.SESSIONS: [
                'user_id', 'ip_address', 'user_agent', 'created_at',
                'ended_at', 'is_active'
            ],
            SearchScope.NOTIFICATIONS: [
                'title', 'message', 'type', 'category', 'priority',
                'status', 'created_at', 'read_at'
            ],
            SearchScope.WEBHOOKS: [
                'event_type', 'status', 'response_status', 'created_at',
                'delivered_at', 'attempt_count'
            ]
        }

    async def search(
        self,
        query: str,
        scope: SearchScope = SearchScope.ALL,
        filters: Optional[List[Dict[str, Any]]] = None,
        sort: Optional[List[Dict[str, str]]] = None,
        page: int = 1,
        page_size: Optional[int] = None,
        highlight: bool = True,
        facets: Optional[List[str]] = None,
        user_id: Optional[str] = None,
        include_analytics: bool = False
    ) -> Dict[str, Any]:
        """
        Perform comprehensive search across specified scopes.

        Args:
            query: Search query string
            scope: Search scope (users, audit_logs, etc.)
            filters: Additional filters to apply
            sort: Sort specifications
            page: Page number (1-based)
            page_size: Number of results per page
            highlight: Whether to highlight search terms
            facets: Fields to generate facets for
            user_id: User ID for permission checking and analytics
            include_analytics: Whether to include search analytics

        Returns:
            Dict: Search results with metadata

        Raises:
            SearchValidationError: If search parameters are invalid
            SearchError: If search execution fails
        """
        try:
            # Validate search parameters
            await self._validate_search_params(query, scope, filters, sort, page, page_size)

            # Check user permissions
            if user_id:
                await self._check_search_permissions(user_id, scope)

            # Normalize parameters
            page_size = page_size or self.default_page_size
            page_size = min(page_size, self.max_results)
            offset = (page - 1) * page_size

            # Generate cache key
            cache_key = self._generate_cache_key(query, scope, filters, sort, page, page_size)

            # Try to get cached results
            cached_results = await self.cache_service.get(cache_key)
            if cached_results and not include_analytics:
                results = json.loads(cached_results)
                await self._log_search_event(query, scope, user_id, len(results.get("items", [])), True)
                return results

            # Execute search
            search_results = await self._execute_search(
                query, scope, filters, sort, offset, page_size, highlight, facets
            )

            # Build response
            response = {
                "query": query,
                "scope": scope.value,
                "page": page,
                "page_size": page_size,
                "total_results": search_results["total_count"],
                "total_pages": (search_results["total_count"] + page_size - 1) // page_size,
                "items": search_results["items"],
                "facets": search_results.get("facets", {}),
                "suggestions": search_results.get("suggestions", []),
                "search_time_ms": search_results["search_time_ms"],
                "cached": False,
                "timestamp": datetime.utcnow().isoformat()
            }

            # Add analytics if requested
            if include_analytics:
                response["analytics"] = await self._get_search_analytics(query, scope, user_id)

            # Cache results
            await self.cache_service.set(
                cache_key,
                json.dumps(response, default=str),
                ttl=self.cache_ttl
            )

            # Log search event
            await self._log_search_event(query, scope, user_id, search_results["total_count"], False)

            return response

        except (SearchValidationError, SearchError):
            raise
        except Exception as e:
            logger.error(
                "Search execution failed",
                query=query,
                scope=scope.value,
                user_id=user_id,
                error=str(e)
            )
            raise SearchError(f"Search execution failed: {str(e)}")

    async def autocomplete(
        self,
        query: str,
        scope: SearchScope,
        field: str,
        limit: int = 10,
        user_id: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Get autocomplete suggestions for a field.

        Args:
            query: Partial query string
            scope: Search scope
            field: Field to get suggestions for
            limit: Maximum number of suggestions
            user_id: User ID for permission checking

        Returns:
            List: Autocomplete suggestions
        """
        try:
            # Validate field is searchable
            if field not in self.searchable_fields.get(scope, []):
                raise SearchValidationError(f"Field {field} is not searchable in scope {scope}")

            # Check permissions
            if user_id:
                await self._check_search_permissions(user_id, scope)

            # Generate cache key
            cache_key = f"autocomplete:{scope.value}:{field}:{query.lower()}:{limit}"

            # Try cached suggestions
            cached_suggestions = await self.cache_service.get(cache_key)
            if cached_suggestions:
                return json.loads(cached_suggestions)

            # Get model for scope
            model = self.scope_models.get(scope)
            if not model:
                raise SearchError(f"No model found for scope {scope}")

            # Build autocomplete query
            suggestions = await self._get_autocomplete_suggestions(model, field, query, limit)

            # Cache suggestions
            await self.cache_service.set(
                cache_key,
                json.dumps(suggestions, default=str),
                ttl=self.cache_ttl
            )

            return suggestions

        except (SearchValidationError, SearchError):
            raise
        except Exception as e:
            logger.error(
                "Autocomplete failed",
                query=query,
                scope=scope.value,
                field=field,
                error=str(e)
            )
            raise SearchError(f"Autocomplete failed: {str(e)}")

    async def save_search(
        self,
        user_id: str,
        name: str,
        query: str,
        scope: SearchScope,
        filters: Optional[List[Dict[str, Any]]] = None,
        description: Optional[str] = None,
        is_public: bool = False
    ) -> str:
        """
        Save a search for later use.

        Args:
            user_id: User ID saving the search
            name: Search name
            query: Search query
            scope: Search scope
            filters: Search filters
            description: Optional description
            is_public: Whether search is public

        Returns:
            str: Saved search ID
        """
        try:
            search_id = str(uuid4())
            saved_search = {
                "id": search_id,
                "user_id": user_id,
                "name": name,
                "query": query,
                "scope": scope.value,
                "filters": filters or [],
                "description": description,
                "is_public": is_public,
                "created_at": datetime.utcnow().isoformat(),
                "last_used_at": None,
                "use_count": 0
            }

            # Store saved search
            search_key = f"saved_search:{search_id}"
            await self.cache_service.set(
                search_key,
                json.dumps(saved_search),
                ttl=365 * 24 * 3600  # 1 year
            )

            # Add to user's saved searches list
            user_searches_key = f"user_saved_searches:{user_id}"
            user_searches = await self.cache_service.get(user_searches_key)

            if user_searches:
                user_search_ids = json.loads(user_searches)
            else:
                user_search_ids = []

            user_search_ids.append(search_id)
            await self.cache_service.set(
                user_searches_key,
                json.dumps(user_search_ids),
                ttl=365 * 24 * 3600
            )

            # Emit audit event
            await self.event_emitter.emit(Event(
                event_type="search.saved",
                data={
                    "search_id": search_id,
                    "user_id": user_id,
                    "name": name,
                    "scope": scope.value
                }
            ))

            logger.info(
                "Search saved",
                search_id=search_id,
                user_id=user_id,
                name=name
            )

            return search_id

        except Exception as e:
            logger.error(
                "Failed to save search",
                user_id=user_id,
                name=name,
                error=str(e)
            )
            raise SearchError(f"Failed to save search: {str(e)}")

    async def get_saved_searches(
        self,
        user_id: str,
        include_public: bool = True
    ) -> List[Dict[str, Any]]:
        """
        Get user's saved searches.

        Args:
            user_id: User ID
            include_public: Whether to include public searches

        Returns:
            List: Saved searches
        """
        try:
            saved_searches = []

            # Get user's saved searches
            user_searches_key = f"user_saved_searches:{user_id}"
            user_searches = await self.cache_service.get(user_searches_key)

            if user_searches:
                user_search_ids = json.loads(user_searches)

                for search_id in user_search_ids:
                    search_key = f"saved_search:{search_id}"
                    search_data = await self.cache_service.get(search_key)

                    if search_data:
                        saved_searches.append(json.loads(search_data))

            # TODO: Add public searches if include_public is True
            # This would require a separate index of public searches

            # Sort by last used, then by created date
            saved_searches.sort(
                key=lambda x: (x.get("last_used_at") or "", x["created_at"]),
                reverse=True
            )

            return saved_searches

        except Exception as e:
            logger.error(
                "Failed to get saved searches",
                user_id=user_id,
                error=str(e)
            )
            raise SearchError(f"Failed to get saved searches: {str(e)}")

    async def delete_saved_search(
        self,
        search_id: str,
        user_id: str
    ) -> bool:
        """
        Delete a saved search.

        Args:
            search_id: Search ID to delete
            user_id: User ID (for permission checking)

        Returns:
            bool: True if deleted successfully
        """
        try:
            # Get saved search
            search_key = f"saved_search:{search_id}"
            search_data = await self.cache_service.get(search_key)

            if not search_data:
                return False

            saved_search = json.loads(search_data)

            # Check permissions
            if saved_search["user_id"] != user_id:
                raise SearchError("Permission denied: Cannot delete another user's search")

            # Delete saved search
            await self.cache_service.delete(search_key)

            # Remove from user's searches list
            user_searches_key = f"user_saved_searches:{user_id}"
            user_searches = await self.cache_service.get(user_searches_key)

            if user_searches:
                user_search_ids = json.loads(user_searches)
                if search_id in user_search_ids:
                    user_search_ids.remove(search_id)
                    await self.cache_service.set(
                        user_searches_key,
                        json.dumps(user_search_ids),
                        ttl=365 * 24 * 3600
                    )

            logger.info(
                "Saved search deleted",
                search_id=search_id,
                user_id=user_id
            )

            return True

        except SearchError:
            raise
        except Exception as e:
            logger.error(
                "Failed to delete saved search",
                search_id=search_id,
                user_id=user_id,
                error=str(e)
            )
            raise SearchError(f"Failed to delete saved search: {str(e)}")

    async def get_search_analytics(
        self,
        user_id: Optional[str] = None,
        time_range: str = "7d"
    ) -> Dict[str, Any]:
        """
        Get search analytics and statistics.

        Args:
            user_id: Optional user ID to filter analytics
            time_range: Time range (1d, 7d, 30d)

        Returns:
            Dict: Analytics data
        """
        try:
            # Parse time range
            if time_range == "1d":
                start_time = datetime.utcnow() - timedelta(days=1)
            elif time_range == "7d":
                start_time = datetime.utcnow() - timedelta(days=7)
            elif time_range == "30d":
                start_time = datetime.utcnow() - timedelta(days=30)
            else:
                start_time = datetime.utcnow() - timedelta(days=7)

            analytics_data = {
                "time_range": time_range,
                "start_time": start_time.isoformat(),
                "end_time": datetime.utcnow().isoformat(),
                "total_searches": 0,
                "unique_users": 0,
                "top_queries": [],
                "top_scopes": [],
                "search_trends": [],
                "avg_results_per_search": 0,
                "cache_hit_rate": 0.0,
                "generated_at": datetime.utcnow().isoformat()
            }

            # In production, this would query actual analytics data
            # For now, return the structure with sample data
            return analytics_data

        except Exception as e:
            logger.error(
                "Failed to get search analytics",
                user_id=user_id,
                time_range=time_range,
                error=str(e)
            )
            return {"error": str(e)}

    async def _validate_search_params(
        self,
        query: str,
        scope: SearchScope,
        filters: Optional[List[Dict[str, Any]]],
        sort: Optional[List[Dict[str, str]]],
        page: int,
        page_size: Optional[int]
    ) -> None:
        """Validate search parameters."""
        if not query or len(query.strip()) < 1:
            raise SearchValidationError("Query must be at least 1 character")

        if len(query) > 1000:
            raise SearchValidationError("Query too long (max 1000 characters)")

        if page < 1:
            raise SearchValidationError("Page must be >= 1")

        if page_size and (page_size < 1 or page_size > self.max_results):
            raise SearchValidationError(f"Page size must be between 1 and {self.max_results}")

        # Validate filters
        if filters:
            for filter_item in filters:
                if not isinstance(filter_item, dict):
                    raise SearchValidationError("Filters must be dictionaries")

                required_keys = ["field", "operator", "value"]
                if not all(key in filter_item for key in required_keys):
                    raise SearchValidationError(f"Filter must contain: {required_keys}")

        # Validate sort
        if sort:
            for sort_item in sort:
                if not isinstance(sort_item, dict):
                    raise SearchValidationError("Sort items must be dictionaries")

                if "field" not in sort_item:
                    raise SearchValidationError("Sort item must contain 'field'")

    async def _check_search_permissions(self, user_id: str, scope: SearchScope) -> None:
        """Check if user has permission to search in the specified scope."""
        try:
            # Get user
            user_stmt = select(User).where(User.id == user_id)
            result = await self.session.execute(user_stmt)
            user = result.scalar_one_or_none()

            if not user or not user.is_active:
                raise SearchError(f"User {user_id} not found or inactive")

            # In production, implement proper permission checking
            # For now, allow all active users to search
            # Different scopes might require different permissions

            restricted_scopes = [SearchScope.AUDIT_LOGS]
            if scope in restricted_scopes:
                # Check if user has admin role for sensitive data
                user_roles = [role.name.lower() for role in user.roles] if hasattr(user, 'roles') else []
                if not any(role in user_roles for role in ['admin', 'super_admin']):
                    raise SearchError(f"Insufficient permissions to search {scope.value}")

        except SearchError:
            raise
        except Exception as e:
            logger.error(
                "Permission check failed",
                user_id=user_id,
                scope=scope.value,
                error=str(e)
            )
            raise SearchError("Permission validation failed")

    async def _execute_search(
        self,
        query: str,
        scope: SearchScope,
        filters: Optional[List[Dict[str, Any]]],
        sort: Optional[List[Dict[str, str]]],
        offset: int,
        limit: int,
        highlight: bool,
        facets: Optional[List[str]]
    ) -> Dict[str, Any]:
        """Execute the actual search query."""
        start_time = datetime.utcnow()

        try:
            if scope == SearchScope.ALL:
                # Search across all scopes
                results = await self._search_all_scopes(query, filters, sort, offset, limit)
            else:
                # Search specific scope
                results = await self._search_single_scope(
                    query, scope, filters, sort, offset, limit, highlight, facets
                )

            search_time = (datetime.utcnow() - start_time).total_seconds() * 1000
            results["search_time_ms"] = round(search_time, 2)

            return results

        except Exception as e:
            logger.error(
                "Search execution error",
                query=query,
                scope=scope.value,
                error=str(e)
            )
            raise SearchError(f"Search execution error: {str(e)}")

    async def _search_single_scope(
        self,
        query: str,
        scope: SearchScope,
        filters: Optional[List[Dict[str, Any]]],
        sort: Optional[List[Dict[str, str]]],
        offset: int,
        limit: int,
        highlight: bool,
        facets: Optional[List[str]]
    ) -> Dict[str, Any]:
        """Search within a single scope."""
        model = self.scope_models.get(scope)
        if not model:
            raise SearchError(f"No model found for scope {scope}")

        # Build base query
        query_obj = select(model)

        # Add search conditions
        search_conditions = await self._build_search_conditions(model, query, scope)
        if search_conditions:
            query_obj = query_obj.where(or_(*search_conditions))

        # Add filters
        if filters:
            filter_conditions = await self._build_filter_conditions(model, filters, scope)
            if filter_conditions:
                query_obj = query_obj.where(and_(*filter_conditions))

        # Get total count
        count_query = select(func.count()).select_from(query_obj.subquery())
        count_result = await self.session.execute(count_query)
        total_count = count_result.scalar()

        # Add sorting
        if sort:
            for sort_item in sort:
                field = sort_item["field"]
                direction = sort_item.get("direction", SortOrder.ASC)

                if hasattr(model, field):
                    model_field = getattr(model, field)
                    if direction == SortOrder.DESC:
                        query_obj = query_obj.order_by(desc(model_field))
                    else:
                        query_obj = query_obj.order_by(asc(model_field))

        # Add pagination
        query_obj = query_obj.offset(offset).limit(limit)

        # Execute query
        result = await self.session.execute(query_obj)
        items = result.scalars().all()

        # Convert to dictionaries
        items_data = []
        for item in items:
            item_dict = await self._model_to_dict(item)

            # Add highlights if requested
            if highlight:
                item_dict["_highlights"] = await self._generate_highlights(
                    item_dict, query, scope
                )

            items_data.append(item_dict)

        # Generate facets if requested
        facets_data = {}
        if facets:
            facets_data = await self._generate_facets(model, facets, search_conditions, filters)

        return {
            "items": items_data,
            "total_count": total_count,
            "facets": facets_data,
            "suggestions": await self._generate_suggestions(query, scope)
        }

    async def _search_all_scopes(
        self,
        query: str,
        filters: Optional[List[Dict[str, Any]]],
        sort: Optional[List[Dict[str, str]]],
        offset: int,
        limit: int
    ) -> Dict[str, Any]:
        """Search across all scopes."""
        all_results = []
        total_count = 0

        # Search each scope
        for scope in [SearchScope.USERS, SearchScope.AUDIT_LOGS, SearchScope.SESSIONS,
                     SearchScope.NOTIFICATIONS, SearchScope.WEBHOOKS]:
            try:
                scope_results = await self._search_single_scope(
                    query, scope, filters, sort, 0, limit, False, None
                )

                # Add scope information to each item
                for item in scope_results["items"]:
                    item["_scope"] = scope.value

                all_results.extend(scope_results["items"])
                total_count += scope_results["total_count"]

            except Exception as e:
                logger.warning(f"Failed to search scope {scope}: {str(e)}")
                continue

        # Sort combined results if specified
        if sort and all_results:
            sort_field = sort[0]["field"]
            sort_direction = sort[0].get("direction", SortOrder.ASC)
            reverse = sort_direction == SortOrder.DESC

            try:
                all_results.sort(
                    key=lambda x: x.get(sort_field, ""),
                    reverse=reverse
                )
            except Exception:
                # If sorting fails, keep original order
                pass

        # Apply pagination
        paginated_results = all_results[offset:offset + limit]

        return {
            "items": paginated_results,
            "total_count": total_count,
            "facets": {},
            "suggestions": []
        }

    async def _build_search_conditions(self, model, query: str, scope: SearchScope):
        """Build search conditions for full-text search."""
        conditions = []
        search_fields = self.searchable_fields.get(scope, [])

        # Split query into terms
        terms = query.strip().split()

        for field_name in search_fields:
            if hasattr(model, field_name):
                field = getattr(model, field_name)

                # For string fields, use ILIKE for case-insensitive search
                if hasattr(field.type, 'python_type') and field.type.python_type == str:
                    for term in terms:
                        conditions.append(field.ilike(f"%{term}%"))

        return conditions

    async def _build_filter_conditions(self, model, filters: List[Dict[str, Any]], scope: SearchScope):
        """Build filter conditions from filter specifications."""
        conditions = []

        for filter_item in filters:
            field_name = filter_item["field"]
            operator = filter_item["operator"]
            value = filter_item["value"]

            if not hasattr(model, field_name):
                continue

            field = getattr(model, field_name)

            # Apply operator-specific conditions
            if operator == SearchOperator.EQUALS:
                conditions.append(field == value)
            elif operator == SearchOperator.NOT_EQUALS:
                conditions.append(field != value)
            elif operator == SearchOperator.GREATER_THAN:
                conditions.append(field > value)
            elif operator == SearchOperator.GREATER_EQUAL:
                conditions.append(field >= value)
            elif operator == SearchOperator.LESS_THAN:
                conditions.append(field < value)
            elif operator == SearchOperator.LESS_EQUAL:
                conditions.append(field <= value)
            elif operator == SearchOperator.CONTAINS:
                conditions.append(field.ilike(f"%{value}%"))
            elif operator == SearchOperator.STARTS_WITH:
                conditions.append(field.ilike(f"{value}%"))
            elif operator == SearchOperator.ENDS_WITH:
                conditions.append(field.ilike(f"%{value}"))
            elif operator == SearchOperator.IN:
                if isinstance(value, list):
                    conditions.append(field.in_(value))
            elif operator == SearchOperator.NOT_IN:
                if isinstance(value, list):
                    conditions.append(~field.in_(value))
            elif operator == SearchOperator.IS_NULL:
                conditions.append(field.is_(None))
            elif operator == SearchOperator.IS_NOT_NULL:
                conditions.append(field.is_not(None))
            elif operator == SearchOperator.BETWEEN:
                if isinstance(value, list) and len(value) == 2:
                    conditions.append(field.between(value[0], value[1]))

        return conditions

    async def _model_to_dict(self, model_instance) -> Dict[str, Any]:
        """Convert SQLAlchemy model instance to dictionary."""
        result = {}

        for column in model_instance.__table__.columns:
            value = getattr(model_instance, column.name)

            # Convert datetime to ISO format
            if isinstance(value, datetime):
                result[column.name] = value.isoformat()
            else:
                result[column.name] = value

        return result

    async def _generate_highlights(
        self,
        item_data: Dict[str, Any],
        query: str,
        scope: SearchScope
    ) -> Dict[str, str]:
        """Generate search result highlights."""
        highlights = {}
        search_fields = self.searchable_fields.get(scope, [])
        terms = query.strip().split()

        for field_name in search_fields:
            if field_name in item_data and isinstance(item_data[field_name], str):
                field_value = str(item_data[field_name])
                highlighted_value = field_value

                # Highlight each search term
                for term in terms:
                    if len(term) > 2:  # Only highlight terms longer than 2 chars
                        pattern = re.compile(re.escape(term), re.IGNORECASE)
                        highlighted_value = pattern.sub(f"<mark>{term}</mark>", highlighted_value)

                if highlighted_value != field_value:
                    highlights[field_name] = highlighted_value

        return highlights

    async def _generate_facets(
        self,
        model,
        facet_fields: List[str],
        search_conditions,
        filters: Optional[List[Dict[str, Any]]]
    ) -> Dict[str, Any]:
        """Generate facets for search results."""
        facets = {}

        for field_name in facet_fields:
            if hasattr(model, field_name):
                field = getattr(model, field_name)

                # Build facet query
                facet_query = select(field, func.count().label('count')).group_by(field)

                # Apply search conditions
                if search_conditions:
                    facet_query = facet_query.where(or_(*search_conditions))

                # Apply existing filters (except for the faceted field)
                if filters:
                    filter_conditions = []
                    for filter_item in filters:
                        if filter_item["field"] != field_name:
                            # Add other filters
                            pass  # Simplified for now

                    if filter_conditions:
                        facet_query = facet_query.where(and_(*filter_conditions))

                # Execute facet query
                try:
                    result = await self.session.execute(facet_query.limit(20))
                    facet_values = []

                    for row in result:
                        facet_values.append({
                            "value": row[0],
                            "count": row[1]
                        })

                    facets[field_name] = sorted(facet_values, key=lambda x: x["count"], reverse=True)

                except Exception as e:
                    logger.warning(f"Failed to generate facet for {field_name}: {str(e)}")
                    facets[field_name] = []

        return facets

    async def _generate_suggestions(self, query: str, scope: SearchScope) -> List[str]:
        """Generate search suggestions."""
        # In production, this would use sophisticated suggestion algorithms
        # For now, return simple suggestions based on common terms
        suggestions = []

        # Add some contextual suggestions based on scope
        if scope == SearchScope.USERS:
            suggestions.extend(["active users", "verified users", "recent signups"])
        elif scope == SearchScope.AUDIT_LOGS:
            suggestions.extend(["login attempts", "failed logins", "admin actions"])

        return suggestions[:5]  # Limit to 5 suggestions

    async def _get_autocomplete_suggestions(
        self,
        model,
        field: str,
        query: str,
        limit: int
    ) -> List[Dict[str, Any]]:
        """Get autocomplete suggestions for a field."""
        if not hasattr(model, field):
            return []

        field_obj = getattr(model, field)

        # Build autocomplete query
        autocomplete_query = (
            select(field_obj, func.count().label('count'))
            .where(field_obj.ilike(f"{query}%"))
            .group_by(field_obj)
            .order_by(desc(func.count()))
            .limit(limit)
        )

        try:
            result = await self.session.execute(autocomplete_query)
            suggestions = []

            for row in result:
                if row[0]:  # Skip null values
                    suggestions.append({
                        "value": row[0],
                        "count": row[1]
                    })

            return suggestions

        except Exception as e:
            logger.error(f"Autocomplete query failed for {field}: {str(e)}")
            return []

    async def _log_search_event(
        self,
        query: str,
        scope: SearchScope,
        user_id: Optional[str],
        result_count: int,
        from_cache: bool
    ) -> None:
        """Log search event for analytics."""
        try:
            # Emit search event
            await self.event_emitter.emit(Event(
                event_type="search.performed",
                data={
                    "query": query,
                    "scope": scope.value,
                    "user_id": user_id,
                    "result_count": result_count,
                    "from_cache": from_cache,
                    "timestamp": datetime.utcnow().isoformat()
                }
            ))

            # Store search analytics data
            analytics_key = f"search_analytics:{datetime.utcnow().strftime('%Y%m%d%H')}"
            analytics_data = await self.cache_service.get(analytics_key)

            if analytics_data:
                analytics = json.loads(analytics_data)
            else:
                analytics = {"total_searches": 0, "unique_queries": set()}

            analytics["total_searches"] += 1
            analytics["unique_queries"] = list(set(analytics.get("unique_queries", [])))

            # Convert set back to list for JSON serialization
            unique_queries = set(analytics["unique_queries"])
            unique_queries.add(query.lower())
            analytics["unique_queries"] = list(unique_queries)

            await self.cache_service.set(
                analytics_key,
                json.dumps(analytics, default=list),
                ttl=7 * 24 * 3600  # 7 days
            )

        except Exception as e:
            logger.error("Failed to log search event", error=str(e))

    async def _get_search_analytics(
        self,
        query: str,
        scope: SearchScope,
        user_id: Optional[str]
    ) -> Dict[str, Any]:
        """Get search-specific analytics."""
        try:
            return {
                "query_popularity": 0,
                "avg_result_count": 0,
                "last_searched": None,
                "related_queries": []
            }
        except Exception:
            return {}

    def _generate_cache_key(
        self,
        query: str,
        scope: SearchScope,
        filters: Optional[List[Dict[str, Any]]],
        sort: Optional[List[Dict[str, str]]],
        page: int,
        page_size: int
    ) -> str:
        """Generate cache key for search results."""
        key_parts = [
            f"search:{scope.value}",
            f"q:{query.lower()}",
            f"p:{page}",
            f"s:{page_size}"
        ]

        if filters:
            filters_str = json.dumps(filters, sort_keys=True)
            key_parts.append(f"f:{hash(filters_str)}")

        if sort:
            sort_str = json.dumps(sort, sort_keys=True)
            key_parts.append(f"sort:{hash(sort_str)}")

        return ":".join(key_parts)


# Global instance
search_service = SearchService
