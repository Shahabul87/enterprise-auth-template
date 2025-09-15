"""
Admin service for RBAC system management.

This service provides high-level administrative operations for managing
the entire RBAC system, including bulk operations, system health checks,
and administrative workflows.
"""
import json
import logging
from typing import List, Optional, Dict, Any, Tuple, Set
from uuid import UUID
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_, delete, func, update, desc, asc, text
from sqlalchemy.orm import selectinload, joinedload
from sqlalchemy.exc import IntegrityError
import redis.asyncio as redis

from app.models.role import Role, user_roles, role_permissions, DEFAULT_ROLES
from app.models.permission import Permission, user_permissions, DEFAULT_PERMISSIONS
from app.models.user import User
from app.models.organization import Organization
from app.services.role_service import RoleService
from app.services.permission_service import PermissionService
from app.core.exceptions import (
    ResourceNotFoundException,
    ValidationException,
    ConflictException,
    BusinessLogicException,
    AuthorizationException,
    DatabaseException
)
from app.core.events import EventEmitter
from app.core.constants import (
    SYSTEM_ROLES,
    ADMIN_ROLES,
    DEFAULT_ORGANIZATION_ROLES
)

logger = logging.getLogger(__name__)


class AdminService:
    """Service for administrative RBAC operations."""
    
    def __init__(
        self,
        db: AsyncSession,
        redis_client: Optional[redis.Redis] = None,
        event_emitter: Optional[EventEmitter] = None
    ):
        """
        Initialize admin service.
        
        Args:
            db: Database session
            redis_client: Redis client for caching
            event_emitter: Event emitter for audit logging
        """
        self.db = db
        self.redis = redis_client
        self.event_emitter = event_emitter
        self.role_service = RoleService(db, redis_client, event_emitter)
        self.permission_service = PermissionService(db, redis_client, event_emitter)
    
    # System Setup and Initialization
    
    async def initialize_system(self, admin_user_id: Optional[UUID] = None) -> Dict[str, Any]:
        """
        Initialize the RBAC system with default roles and permissions.
        
        Args:
            admin_user_id: ID of the admin user creating the system
            
        Returns:
            Dictionary with initialization results
        """
        results = {
            "permissions_created": 0,
            "roles_created": 0,
            "errors": []
        }
        
        try:
            # Create default permissions
            logger.info("Creating default permissions...")
            for perm_data in DEFAULT_PERMISSIONS:
                try:
                    existing = await self.permission_service.get_permission_by_code(
                        perm_data["code"], perm_data.get("scope", "global")
                    )
                    if not existing:
                        await self.permission_service.create_permission(**perm_data)
                        results["permissions_created"] += 1
                        logger.info(f"Created permission: {perm_data['code']}")
                except Exception as e:
                    error_msg = f"Failed to create permission {perm_data['code']}: {e}"
                    logger.error(error_msg)
                    results["errors"].append(error_msg)
            
            # Create default roles
            logger.info("Creating default roles...")
            for role_data in DEFAULT_ROLES:
                try:
                    existing = await self.role_service.get_role_by_name(role_data["name"])
                    if not existing:
                        await self.role_service.create_role(
                            created_by=admin_user_id,
                            **role_data
                        )
                        results["roles_created"] += 1
                        logger.info(f"Created role: {role_data['name']}")
                except Exception as e:
                    error_msg = f"Failed to create role {role_data['name']}: {e}"
                    logger.error(error_msg)
                    results["errors"].append(error_msg)
            
            # Assign permissions to roles
            await self._assign_default_permissions_to_roles()
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("system.initialized", {
                    "permissions_created": results["permissions_created"],
                    "roles_created": results["roles_created"],
                    "initialized_by": str(admin_user_id) if admin_user_id else None
                })
            
            logger.info("RBAC system initialization completed")
            return results
            
        except Exception as e:
            logger.error(f"Error initializing RBAC system: {e}")
            results["errors"].append(f"System initialization failed: {e}")
            return results
    
    async def create_organization_rbac(
        self,
        organization_id: UUID,
        admin_user_id: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Create RBAC structure for a new organization.
        
        Args:
            organization_id: Organization ID
            admin_user_id: Admin user creating the structure
            
        Returns:
            Dictionary with creation results
        """
        results = {
            "roles_created": 0,
            "permissions_created": 0,
            "errors": []
        }
        
        try:
            # Verify organization exists
            org_query = select(Organization).where(Organization.id == organization_id)
            org_result = await self.db.execute(org_query)
            organization = org_result.scalar_one_or_none()
            if not organization:
                raise ResourceNotFoundException("Organization", organization_id)
            
            # Create organization-specific roles
            org_roles = [
                {
                    "name": f"org_admin",
                    "display_name": "Organization Administrator",
                    "description": f"Administrator for organization {organization.name}",
                    "role_type": "organization",
                    "organization_id": organization_id,
                    "hierarchy_level": 1,
                    "priority": 800
                },
                {
                    "name": f"org_manager",
                    "display_name": "Organization Manager",
                    "description": f"Manager for organization {organization.name}",
                    "role_type": "organization",
                    "organization_id": organization_id,
                    "hierarchy_level": 2,
                    "priority": 600
                },
                {
                    "name": f"org_member",
                    "display_name": "Organization Member",
                    "description": f"Member of organization {organization.name}",
                    "role_type": "organization",
                    "organization_id": organization_id,
                    "hierarchy_level": 3,
                    "priority": 400,
                    "is_default": True
                }
            ]
            
            for role_data in org_roles:
                try:
                    existing = await self.role_service.get_role_by_name(
                        role_data["name"], organization_id
                    )
                    if not existing:
                        await self.role_service.create_role(
                            created_by=admin_user_id,
                            **role_data
                        )
                        results["roles_created"] += 1
                        logger.info(f"Created org role: {role_data['name']}")
                except Exception as e:
                    error_msg = f"Failed to create org role {role_data['name']}: {e}"
                    logger.error(error_msg)
                    results["errors"].append(error_msg)
            
            # Create organization-specific permissions if needed
            org_permissions = [
                {
                    "code": f"org:{organization_id}:manage",
                    "name": "Manage Organization",
                    "description": f"Manage organization {organization.name}",
                    "resource": "organization",
                    "action": "manage",
                    "scope": "organization",
                    "category": "organization",
                    "risk_level": "high"
                }
            ]
            
            for perm_data in org_permissions:
                try:
                    existing = await self.permission_service.get_permission_by_code(
                        perm_data["code"], perm_data.get("scope", "global")
                    )
                    if not existing:
                        await self.permission_service.create_permission(**perm_data)
                        results["permissions_created"] += 1
                        logger.info(f"Created org permission: {perm_data['code']}")
                except Exception as e:
                    error_msg = f"Failed to create org permission {perm_data['code']}: {e}"
                    logger.error(error_msg)
                    results["errors"].append(error_msg)
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("organization.rbac.created", {
                    "organization_id": str(organization_id),
                    "roles_created": results["roles_created"],
                    "permissions_created": results["permissions_created"],
                    "created_by": str(admin_user_id) if admin_user_id else None
                })
            
            logger.info(f"Organization RBAC created for {organization_id}")
            return results
            
        except Exception as e:
            logger.error(f"Error creating organization RBAC: {e}")
            results["errors"].append(f"Organization RBAC creation failed: {e}")
            return results
    
    # Bulk Operations
    
    async def bulk_user_role_assignment(
        self,
        assignments: List[Dict[str, Any]],
        assigned_by: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Bulk assign roles to multiple users.
        
        Args:
            assignments: List of assignment dictionaries
            assigned_by: Admin performing the assignments
            
        Returns:
            Results with success/failure counts
        """
        results = {
            "success_count": 0,
            "error_count": 0,
            "errors": [],
            "assignments_processed": 0
        }
        
        try:
            for assignment in assignments:
                results["assignments_processed"] += 1
                try:
                    user_id = UUID(assignment["user_id"])
                    role_ids = [UUID(rid) for rid in assignment["role_ids"]]
                    
                    # Assign each role
                    for role_id in role_ids:
                        success = await self.role_service.assign_role_to_user(
                            user_id, role_id, assigned_by
                        )
                        if success:
                            results["success_count"] += 1
                        else:
                            results["error_count"] += 1
                            
                except Exception as e:
                    results["error_count"] += 1
                    results["errors"].append({
                        "assignment": assignment,
                        "error": str(e)
                    })
                    logger.error(f"Bulk role assignment failed: {e}")
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("bulk.role.assignment", {
                    "assignments_processed": results["assignments_processed"],
                    "success_count": results["success_count"],
                    "error_count": results["error_count"],
                    "assigned_by": str(assigned_by) if assigned_by else None
                })
            
            return results
            
        except Exception as e:
            logger.error(f"Error in bulk role assignment: {e}")
            results["errors"].append(f"Bulk operation failed: {e}")
            return results
    
    async def bulk_permission_grant(
        self,
        grants: List[Dict[str, Any]],
        granted_by: Optional[UUID] = None
    ) -> Dict[str, Any]:
        """
        Bulk grant permissions to users and roles.
        
        Args:
            grants: List of grant dictionaries
            granted_by: Admin performing the grants
            
        Returns:
            Results with success/failure counts
        """
        return await self.permission_service.bulk_grant_permissions(grants, granted_by)
    
    async def cleanup_expired_assignments(self) -> Dict[str, Any]:
        """
        Clean up expired role and permission assignments.
        
        Returns:
            Cleanup results
        """
        results = {
            "expired_role_assignments": 0,
            "expired_permission_grants": 0,
            "errors": []
        }
        
        try:
            current_time = datetime.utcnow()
            
            # Clean up expired role assignments
            expired_roles_stmt = delete(user_roles).where(
                and_(
                    user_roles.c.expires_at.is_not(None),
                    user_roles.c.expires_at < current_time
                )
            )
            role_result = await self.db.execute(expired_roles_stmt)
            results["expired_role_assignments"] = role_result.rowcount
            
            # Clean up expired permission grants
            expired_permissions_stmt = delete(user_permissions).where(
                and_(
                    user_permissions.c.expires_at.is_not(None),
                    user_permissions.c.expires_at < current_time
                )
            )
            permission_result = await self.db.execute(expired_permissions_stmt)
            results["expired_permission_grants"] = permission_result.rowcount
            
            await self.db.commit()
            
            # Clear relevant caches
            if self.redis:
                # This would need more sophisticated cache clearing in production
                pass
            
            # Emit event
            if self.event_emitter:
                await self.event_emitter.emit("cleanup.expired", results)
            
            logger.info(f"Cleaned up {results['expired_role_assignments']} role assignments and {results['expired_permission_grants']} permission grants")
            return results
            
        except Exception as e:
            await self.db.rollback()
            logger.error(f"Error cleaning up expired assignments: {e}")
            results["errors"].append(f"Cleanup failed: {e}")
            return results
    
    # System Health and Analytics
    
    async def get_system_health(self) -> Dict[str, Any]:
        """
        Get RBAC system health metrics.
        
        Returns:
            System health statistics
        """
        try:
            health = {
                "timestamp": datetime.utcnow().isoformat(),
                "database": {},
                "roles": {},
                "permissions": {},
                "users": {},
                "assignments": {},
                "issues": []
            }
            
            # Database statistics
            role_count_query = select(func.count(Role.id))
            role_count_result = await self.db.execute(role_count_query)
            health["roles"]["total_count"] = role_count_result.scalar()
            
            active_roles_query = select(func.count(Role.id)).where(Role.is_active == True)
            active_roles_result = await self.db.execute(active_roles_query)
            health["roles"]["active_count"] = active_roles_result.scalar()
            
            permission_count_query = select(func.count(Permission.id))
            permission_count_result = await self.db.execute(permission_count_query)
            health["permissions"]["total_count"] = permission_count_result.scalar()
            
            active_permissions_query = select(func.count(Permission.id)).where(Permission.is_active == True)
            active_permissions_result = await self.db.execute(active_permissions_query)
            health["permissions"]["active_count"] = active_permissions_result.scalar()
            
            # High-risk permissions
            high_risk_query = select(func.count(Permission.id)).where(
                or_(Permission.risk_level.in_(["high", "critical"]), Permission.is_dangerous == True)
            )
            high_risk_result = await self.db.execute(high_risk_query)
            health["permissions"]["high_risk_count"] = high_risk_result.scalar()
            
            # User assignments
            user_role_assignments_query = select(func.count()).select_from(user_roles)
            user_role_result = await self.db.execute(user_role_assignments_query)
            health["assignments"]["user_roles"] = user_role_result.scalar()
            
            user_permission_assignments_query = select(func.count()).select_from(user_permissions)
            user_permission_result = await self.db.execute(user_permission_assignments_query)
            health["assignments"]["user_permissions"] = user_permission_result.scalar()
            
            # Check for potential issues
            issues = await self._identify_system_issues()
            health["issues"] = issues
            
            # Overall health score
            health["health_score"] = self._calculate_health_score(health)
            
            return health
            
        except Exception as e:
            logger.error(f"Error getting system health: {e}")
            return {
                "timestamp": datetime.utcnow().isoformat(),
                "error": str(e),
                "health_score": 0
            }
    
    async def get_role_analytics(self, days: int = 30) -> Dict[str, Any]:
        """
        Get role usage analytics.
        
        Args:
            days: Number of days to analyze
            
        Returns:
            Role analytics data
        """
        try:
            since_date = datetime.utcnow() - timedelta(days=days)
            
            # Most assigned roles
            most_assigned_query = select(
                Role.name,
                Role.display_name,
                func.count(user_roles.c.user_id).label("user_count")
            ).select_from(
                Role.join(user_roles, Role.id == user_roles.c.role_id)
            ).group_by(Role.id, Role.name, Role.display_name).order_by(desc("user_count")).limit(10)
            
            most_assigned_result = await self.db.execute(most_assigned_query)
            most_assigned = [
                {"role": row.name, "display_name": row.display_name, "user_count": row.user_count}
                for row in most_assigned_result
            ]
            
            # Unused roles
            unused_roles_query = select(Role.name, Role.display_name, Role.created_at).where(
                ~exists().where(user_roles.c.role_id == Role.id)
            ).where(Role.is_active == True)
            
            unused_result = await self.db.execute(unused_roles_query)
            unused_roles = [
                {"role": row.name, "display_name": row.display_name, "created_at": row.created_at.isoformat()}
                for row in unused_result
            ]
            
            # Roles by type
            role_types_query = select(
                Role.role_type,
                func.count(Role.id).label("count")
            ).group_by(Role.role_type)
            
            role_types_result = await self.db.execute(role_types_query)
            role_types = {row.role_type: row.count for row in role_types_result}
            
            return {
                "period_days": days,
                "most_assigned_roles": most_assigned,
                "unused_roles": unused_roles,
                "role_types": role_types,
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting role analytics: {e}")
            return {"error": str(e)}
    
    async def get_permission_analytics(self, days: int = 30) -> Dict[str, Any]:
        """
        Get permission usage analytics.
        
        Args:
            days: Number of days to analyze
            
        Returns:
            Permission analytics data
        """
        try:
            # Most used permissions (through roles and direct assignments)
            role_permission_usage_query = select(
                Permission.code,
                Permission.name,
                func.count(func.distinct(user_roles.c.user_id)).label("user_count_via_roles")
            ).select_from(
                Permission
                .join(role_permissions, Permission.id == role_permissions.c.permission_id)
                .join(user_roles, role_permissions.c.role_id == user_roles.c.role_id)
            ).group_by(Permission.id, Permission.code, Permission.name)
            
            role_usage_result = await self.db.execute(role_permission_usage_query)
            role_usage = {
                row.code: {"name": row.name, "user_count_via_roles": row.user_count_via_roles}
                for row in role_usage_result
            }
            
            # Direct permission assignments
            direct_permission_usage_query = select(
                Permission.code,
                Permission.name,
                func.count(user_permissions.c.user_id).label("direct_user_count")
            ).select_from(
                Permission.join(user_permissions, Permission.id == user_permissions.c.permission_id)
            ).group_by(Permission.id, Permission.code, Permission.name)
            
            direct_usage_result = await self.db.execute(direct_permission_usage_query)
            direct_usage = {
                row.code: {"name": row.name, "direct_user_count": row.direct_user_count}
                for row in direct_usage_result
            }
            
            # Combine usage data
            combined_usage = {}
            all_codes = set(role_usage.keys()) | set(direct_usage.keys())
            
            for code in all_codes:
                role_data = role_usage.get(code, {"name": "", "user_count_via_roles": 0})
                direct_data = direct_usage.get(code, {"name": "", "direct_user_count": 0})
                
                combined_usage[code] = {
                    "name": role_data["name"] or direct_data["name"],
                    "user_count_via_roles": role_data["user_count_via_roles"],
                    "direct_user_count": direct_data["direct_user_count"],
                    "total_user_count": role_data["user_count_via_roles"] + direct_data["direct_user_count"]
                }
            
            # Sort by total usage
            most_used = sorted(
                combined_usage.items(),
                key=lambda x: x[1]["total_user_count"],
                reverse=True
            )[:10]
            
            # Unused permissions
            unused_permissions_query = select(Permission.code, Permission.name, Permission.created_at).where(
                and_(
                    ~exists().where(role_permissions.c.permission_id == Permission.id),
                    ~exists().where(user_permissions.c.permission_id == Permission.id),
                    Permission.is_active == True
                )
            )
            
            unused_result = await self.db.execute(unused_permissions_query)
            unused_permissions = [
                {"code": row.code, "name": row.name, "created_at": row.created_at.isoformat()}
                for row in unused_result
            ]
            
            # Permissions by risk level
            risk_levels_query = select(
                Permission.risk_level,
                func.count(Permission.id).label("count")
            ).group_by(Permission.risk_level)
            
            risk_levels_result = await self.db.execute(risk_levels_query)
            risk_levels = {row.risk_level: row.count for row in risk_levels_result}
            
            return {
                "period_days": days,
                "most_used_permissions": [{"code": code, **data} for code, data in most_used],
                "unused_permissions": unused_permissions,
                "risk_levels": risk_levels,
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting permission analytics: {e}")
            return {"error": str(e)}
    
    # User Management Helpers
    
    async def promote_user_to_admin(
        self,
        user_id: UUID,
        promoted_by: Optional[UUID] = None,
        role_name: str = "admin"
    ) -> bool:
        """
        Promote a user to admin role.
        
        Args:
            user_id: User to promote
            promoted_by: Admin performing the promotion
            role_name: Admin role name to assign
            
        Returns:
            True if promoted successfully
        """
        try:
            # Get the admin role
            admin_role = await self.role_service.get_role_by_name(role_name)
            if not admin_role:
                raise ResourceNotFoundException("Role", role_name)
            
            # Assign the role
            success = await self.role_service.assign_role_to_user(
                user_id, admin_role.id, promoted_by
            )
            
            if success and self.event_emitter:
                await self.event_emitter.emit("user.promoted.admin", {
                    "user_id": str(user_id),
                    "role_name": role_name,
                    "promoted_by": str(promoted_by) if promoted_by else None
                })
            
            logger.info(f"User {user_id} promoted to {role_name}")
            return success
            
        except Exception as e:
            logger.error(f"Error promoting user {user_id} to admin: {e}")
            return False
    
    async def get_user_access_summary(self, user_id: UUID) -> Dict[str, Any]:
        """
        Get comprehensive access summary for a user.
        
        Args:
            user_id: User ID
            
        Returns:
            User access summary
        """
        try:
            # Get user roles
            user_roles_data = await self.role_service.get_user_roles(
                user_id, include_permissions=True, include_inherited=True
            )
            
            # Get direct permissions
            direct_permissions = await self.permission_service.get_user_direct_permissions(user_id)
            
            # Get all effective permissions
            all_permissions = await self.permission_service.get_user_permissions(user_id)
            
            # Categorize permissions by risk level
            risk_breakdown = {"low": 0, "medium": 0, "high": 0, "critical": 0}
            dangerous_permissions = []
            
            for perm in all_permissions:
                risk_breakdown[perm.risk_level] += 1
                if perm.is_dangerous:
                    dangerous_permissions.append({
                        "code": perm.code,
                        "name": perm.name,
                        "risk_level": perm.risk_level
                    })
            
            return {
                "user_id": str(user_id),
                "roles": [
                    {
                        "id": str(role.id),
                        "name": role.name,
                        "display_name": role.display_name,
                        "role_type": role.role_type,
                        "permission_count": len(role.inherited_permissions) if hasattr(role, '_inherited_permissions') else len(role.permissions)
                    }
                    for role in user_roles_data
                ],
                "direct_permissions": [
                    {
                        "code": perm.code,
                        "name": perm.name,
                        "risk_level": perm.risk_level
                    }
                    for perm in direct_permissions
                ],
                "total_permissions": len(all_permissions),
                "risk_breakdown": risk_breakdown,
                "dangerous_permissions": dangerous_permissions,
                "high_risk_count": risk_breakdown["high"] + risk_breakdown["critical"],
                "generated_at": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error getting user access summary {user_id}: {e}")
            return {"error": str(e)}
    
    # Security and Compliance
    
    async def audit_high_risk_assignments(self) -> Dict[str, Any]:
        """
        Audit high-risk role and permission assignments.
        
        Returns:
            Audit results with high-risk assignments
        """
        try:
            audit_results = {
                "high_risk_roles": [],
                "dangerous_permissions": [],
                "users_with_high_risk_access": [],
                "recommendations": []
            }
            
            # Find high-risk roles (with dangerous permissions)
            high_risk_roles_query = select(Role).join(
                role_permissions, Role.id == role_permissions.c.role_id
            ).join(
                Permission, role_permissions.c.permission_id == Permission.id
            ).where(
                or_(Permission.is_dangerous == True, Permission.risk_level == "critical")
            ).options(selectinload(Role.permissions))
            
            high_risk_result = await self.db.execute(high_risk_roles_query)
            high_risk_roles = list(set(high_risk_result.scalars().all()))
            
            for role in high_risk_roles:
                dangerous_perms = [p for p in role.permissions if p.is_dangerous or p.risk_level == "critical"]
                user_count_query = select(func.count()).select_from(user_roles).where(user_roles.c.role_id == role.id)
                user_count_result = await self.db.execute(user_count_query)
                user_count = user_count_result.scalar()
                
                audit_results["high_risk_roles"].append({
                    "role_id": str(role.id),
                    "name": role.name,
                    "display_name": role.display_name,
                    "dangerous_permissions": [p.code for p in dangerous_perms],
                    "user_count": user_count
                })
            
            # Find users with direct dangerous permissions
            dangerous_user_perms_query = select(User.id, User.email, Permission.code, Permission.name).select_from(
                User.join(user_permissions, User.id == user_permissions.c.user_id)
                .join(Permission, user_permissions.c.permission_id == Permission.id)
            ).where(or_(Permission.is_dangerous == True, Permission.risk_level == "critical"))
            
            dangerous_user_result = await self.db.execute(dangerous_user_perms_query)
            user_dangerous_perms = {}
            
            for row in dangerous_user_result:
                if row.id not in user_dangerous_perms:
                    user_dangerous_perms[row.id] = {
                        "user_id": str(row.id),
                        "email": row.email,
                        "dangerous_permissions": []
                    }
                user_dangerous_perms[row.id]["dangerous_permissions"].append({
                    "code": row.code,
                    "name": row.name
                })
            
            audit_results["users_with_high_risk_access"] = list(user_dangerous_perms.values())
            
            # Generate recommendations
            if len(audit_results["high_risk_roles"]) > 5:
                audit_results["recommendations"].append(
                    "Consider reviewing and consolidating high-risk roles"
                )
            
            if len(audit_results["users_with_high_risk_access"]) > 0:
                audit_results["recommendations"].append(
                    "Review users with direct dangerous permission assignments"
                )
            
            return audit_results
            
        except Exception as e:
            logger.error(f"Error auditing high-risk assignments: {e}")
            return {"error": str(e)}
    
    # Helper Methods
    
    async def _assign_default_permissions_to_roles(self) -> None:
        """Assign default permissions to system roles."""
        try:
            # Super admin gets all permissions
            super_admin = await self.role_service.get_role_by_name("super_admin")
            if super_admin:
                system_perm = await self.permission_service.get_permission_by_code("system:*")
                if system_perm:
                    await self.role_service.add_permission_to_role(super_admin.id, system_perm.id)
            
            # Admin gets most permissions except system:*
            admin = await self.role_service.get_role_by_name("admin")
            if admin:
                admin_permissions = [
                    "user:create", "user:read", "user:update", "user:delete", "user:list",
                    "role:create", "role:read", "role:update", "role:assign",
                    "permission:read", "permission:grant", "permission:revoke",
                    "admin:access", "audit_log:read"
                ]
                for perm_code in admin_permissions:
                    perm = await self.permission_service.get_permission_by_code(perm_code)
                    if perm:
                        await self.role_service.add_permission_to_role(admin.id, perm.id)
            
            # Moderator gets user management permissions
            moderator = await self.role_service.get_role_by_name("moderator")
            if moderator:
                mod_permissions = [
                    "user:read", "user:update", "user:list",
                    "role:read", "permission:read"
                ]
                for perm_code in mod_permissions:
                    perm = await self.permission_service.get_permission_by_code(perm_code)
                    if perm:
                        await self.role_service.add_permission_to_role(moderator.id, perm.id)
            
            # User gets basic permissions
            user_role = await self.role_service.get_role_by_name("user")
            if user_role:
                user_permissions = ["profile:read", "profile:update", "session:read"]
                for perm_code in user_permissions:
                    perm = await self.permission_service.get_permission_by_code(perm_code)
                    if perm:
                        await self.role_service.add_permission_to_role(user_role.id, perm.id)
            
            # Guest gets minimal permissions
            guest_role = await self.role_service.get_role_by_name("guest")
            if guest_role:
                guest_permissions = ["profile:read"]
                for perm_code in guest_permissions:
                    perm = await self.permission_service.get_permission_by_code(perm_code)
                    if perm:
                        await self.role_service.add_permission_to_role(guest_role.id, perm.id)
            
        except Exception as e:
            logger.error(f"Error assigning default permissions: {e}")
    
    async def _identify_system_issues(self) -> List[Dict[str, str]]:
        """Identify potential RBAC system issues."""
        issues = []
        
        try:
            # Check for roles without permissions
            roles_without_perms_query = select(Role.name, Role.display_name).where(
                and_(
                    Role.is_active == True,
                    ~exists().where(role_permissions.c.role_id == Role.id)
                )
            )
            roles_result = await self.db.execute(roles_without_perms_query)
            roles_without_perms = roles_result.fetchall()
            
            if roles_without_perms:
                issues.append({
                    "type": "roles_without_permissions",
                    "severity": "medium",
                    "message": f"{len(roles_without_perms)} active roles have no permissions assigned",
                    "details": [f"{row.name} ({row.display_name})" for row in roles_without_perms[:5]]
                })
            
            # Check for unused permissions
            unused_perms_query = select(Permission.code, Permission.name).where(
                and_(
                    Permission.is_active == True,
                    ~exists().where(role_permissions.c.permission_id == Permission.id),
                    ~exists().where(user_permissions.c.permission_id == Permission.id)
                )
            )
            unused_result = await self.db.execute(unused_perms_query)
            unused_perms = unused_result.fetchall()
            
            if unused_perms:
                issues.append({
                    "type": "unused_permissions",
                    "severity": "low",
                    "message": f"{len(unused_perms)} permissions are not assigned to any roles or users",
                    "details": [f"{row.code} ({row.name})" for row in unused_perms[:5]]
                })
            
            # Check for users with too many roles
            user_role_counts_query = select(
                user_roles.c.user_id,
                func.count(user_roles.c.role_id).label("role_count")
            ).group_by(user_roles.c.user_id).having(func.count(user_roles.c.role_id) > 10)
            
            excessive_roles_result = await self.db.execute(user_role_counts_query)
            excessive_roles = excessive_roles_result.fetchall()
            
            if excessive_roles:
                issues.append({
                    "type": "users_with_excessive_roles",
                    "severity": "medium",
                    "message": f"{len(excessive_roles)} users have more than 10 roles assigned",
                    "details": [f"User {row.user_id}: {row.role_count} roles" for row in excessive_roles[:5]]
                })
            
        except Exception as e:
            logger.error(f"Error identifying system issues: {e}")
            issues.append({
                "type": "system_check_error",
                "severity": "high",
                "message": f"Error running system health checks: {e}"
            })
        
        return issues
    
    def _calculate_health_score(self, health_data: Dict[str, Any]) -> int:
        """Calculate system health score (0-100)."""
        score = 100
        
        # Deduct points for issues
        for issue in health_data.get("issues", []):
            if issue["severity"] == "low":
                score -= 5
            elif issue["severity"] == "medium":
                score -= 15
            elif issue["severity"] == "high":
                score -= 30
        
        # Ensure score doesn't go below 0
        return max(0, score)