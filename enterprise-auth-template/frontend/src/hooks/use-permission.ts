'use client';

import { useCallback, useMemo } from 'react';
import { useUserPermissions, useUserRoles } from '@/hooks/api/use-auth';

/**
 * Permission checking hook for role-based access control (RBAC)
 * 
 * Provides utilities to check user permissions and roles with loading states.
 * Built on top of TanStack Query for caching and efficient permission checks.
 * 
 * @example
 * ```typescript
 * const { hasPermission, hasRole, isLoading } = usePermission();
 * 
 * if (hasPermission('user:write')) {
 *   return <EditUserButton />;
 * }
 * 
 * if (hasRole('admin')) {
 *   return <AdminPanel />;
 * }
 * ```
 */

export interface PermissionConfig {
  /** User ID to check permissions for. If not provided, uses current user */
  userId?: string;
  /** Auth token for API requests */
  token?: string;
  /** Whether to require all permissions (AND logic) or any permission (OR logic) */
  requireAll?: boolean;
}

export interface PermissionState {
  /** All user permissions */
  permissions: string[];
  /** All user roles */
  roles: string[];
  /** Whether permissions are currently loading */
  isLoading: boolean;
  /** Whether user is authenticated */
  isAuthenticated: boolean;
  /** Error if permission check failed */
  error?: Error;
}

export interface PermissionActions {
  /** Check if user has a specific permission */
  hasPermission: (permission: string) => boolean;
  /** Check if user has multiple permissions */
  hasPermissions: (permissions: string[], requireAll?: boolean) => boolean;
  /** Check if user has a specific role */
  hasRole: (role: string) => boolean;
  /** Check if user has multiple roles */
  hasRoles: (roles: string[], requireAll?: boolean) => boolean;
  /** Check if user has admin privileges */
  isAdmin: () => boolean;
  /** Check if user is superuser */
  isSuperuser: () => boolean;
  /** Get missing permissions from required list */
  getMissingPermissions: (requiredPermissions: string[]) => string[];
  /** Get missing roles from required list */
  getMissingRoles: (requiredRoles: string[]) => string[];
  /** Check if user can perform action (combines permission and role checks) */
  canPerform: (action: {
    permissions?: string[];
    roles?: string[];
    requireAll?: boolean;
  }) => boolean;
}

export interface UsePermissionReturn extends PermissionState, PermissionActions {}

export function usePermission(config: PermissionConfig = {}): UsePermissionReturn {
  const { userId, token, requireAll = false } = config;

  // Fetch user permissions and roles
  const {
    data: permissions = [],
    isLoading: permissionsLoading,
    error: permissionsError,
  } = useUserPermissions(userId, token);

  const {
    data: roles = [],
    isLoading: rolesLoading,
    error: rolesError,
  } = useUserRoles(userId, token);

  // Calculate derived state
  const isLoading = permissionsLoading || rolesLoading;
  const isAuthenticated = !!userId && !!token;
  const error = permissionsError || rolesError || undefined;

  // Permission checking functions
  const hasPermission = useCallback(
    (permission: string): boolean => {
      if (!permissions || permissions.length === 0) return false;
      return permissions.includes(permission);
    },
    [permissions]
  );

  const hasPermissions = useCallback(
    (requiredPermissions: string[], shouldRequireAll?: boolean): boolean => {
      if (!permissions || permissions.length === 0) return false;
      if (requiredPermissions.length === 0) return true;

      const checkAll = shouldRequireAll ?? requireAll;
      
      if (checkAll) {
        return requiredPermissions.every(permission => permissions.includes(permission));
      } else {
        return requiredPermissions.some(permission => permissions.includes(permission));
      }
    },
    [permissions, requireAll]
  );

  const hasRole = useCallback(
    (role: string): boolean => {
      if (!roles || roles.length === 0) return false;
      return roles.includes(role);
    },
    [roles]
  );

  const hasRoles = useCallback(
    (requiredRoles: string[], shouldRequireAll?: boolean): boolean => {
      if (!roles || roles.length === 0) return false;
      if (requiredRoles.length === 0) return true;

      const checkAll = shouldRequireAll ?? requireAll;
      
      if (checkAll) {
        return requiredRoles.every(role => roles.includes(role));
      } else {
        return requiredRoles.some(role => roles.includes(role));
      }
    },
    [roles, requireAll]
  );

  const isAdmin = useCallback((): boolean => {
    return hasRole('admin') || hasRole('administrator');
  }, [hasRole]);

  const isSuperuser = useCallback((): boolean => {
    return hasRole('superuser') || hasRole('super_user');
  }, [hasRole]);

  const getMissingPermissions = useCallback(
    (requiredPermissions: string[]): string[] => {
      if (!permissions) return requiredPermissions;
      return requiredPermissions.filter(permission => !permissions.includes(permission));
    },
    [permissions]
  );

  const getMissingRoles = useCallback(
    (requiredRoles: string[]): string[] => {
      if (!roles) return requiredRoles;
      return requiredRoles.filter(role => !roles.includes(role));
    },
    [roles]
  );

  const canPerform = useCallback(
    (action: {
      permissions?: string[];
      roles?: string[];
      requireAll?: boolean;
    }): boolean => {
      const { permissions: reqPermissions = [], roles: reqRoles = [], requireAll: actionRequireAll } = action;
      const checkAll = actionRequireAll ?? requireAll;

      // If no requirements specified, allow access
      if (reqPermissions.length === 0 && reqRoles.length === 0) {
        return true;
      }

      const hasRequiredPermissions = reqPermissions.length > 0 
        ? hasPermissions(reqPermissions, checkAll)
        : true;

      const hasRequiredRoles = reqRoles.length > 0 
        ? hasRoles(reqRoles, checkAll)
        : true;

      // If both permissions and roles are specified, user needs both (AND logic)
      if (reqPermissions.length > 0 && reqRoles.length > 0) {
        return hasRequiredPermissions && hasRequiredRoles;
      }

      // Otherwise, user needs either permissions OR roles
      return hasRequiredPermissions || hasRequiredRoles;
    },
    [hasPermissions, hasRoles, requireAll]
  );

  // Memoized return value for performance
  return useMemo(
    () => ({
      // State
      permissions,
      roles,
      isLoading,
      isAuthenticated,
      ...(error ? { error } : {}),
      // Actions
      hasPermission,
      hasPermissions,
      hasRole,
      hasRoles,
      isAdmin,
      isSuperuser,
      getMissingPermissions,
      getMissingRoles,
      canPerform,
    }),
    [
      permissions,
      roles,
      isLoading,
      isAuthenticated,
      error,
      hasPermission,
      hasPermissions,
      hasRole,
      hasRoles,
      isAdmin,
      isSuperuser,
      getMissingPermissions,
      getMissingRoles,
      canPerform,
    ]
  );
}

/**
 * Higher-order hook for component-level permission checking
 * 
 * @example
 * ```typescript
 * const ProtectedComponent = () => {
 *   const isAllowed = usePermissionGuard({
 *     permissions: ['user:read', 'user:write'],
 *     roles: ['editor'],
 *     requireAll: false, // User needs EITHER permissions OR roles
 *   });
 * 
 *   if (!isAllowed) {
 *     return <AccessDenied />;
 *   }
 * 
 *   return <SensitiveContent />;
 * };
 * ```
 */
export function usePermissionGuard(
  requirements: {
    permissions?: string[];
    roles?: string[];
    requireAll?: boolean;
  },
  config: PermissionConfig = {}
): boolean {
  const { canPerform, isLoading } = usePermission(config);

  // Return false if still loading to prevent flash of unauthorized content
  if (isLoading) {
    return false;
  }

  return canPerform(requirements);
}

/**
 * Permission-based conditional rendering hook
 * 
 * @example
 * ```typescript
 * const MyComponent = () => {
 *   const renderIf = usePermissionRender();
 * 
 *   return (
 *     <div>
 *       {renderIf(
 *         { permissions: ['user:write'] },
 *         <EditButton />
 *       )}
 *       {renderIf(
 *         { roles: ['admin'] },
 *         <DeleteButton />
 *       )}
 *     </div>
 *   );
 * };
 * ```
 */
export function usePermissionRender(config: PermissionConfig = {}) {
  const { canPerform } = usePermission(config);

  return useCallback(
    (
      requirements: {
        permissions?: string[];
        roles?: string[];
        requireAll?: boolean;
      },
      component: React.ReactNode,
      fallback?: React.ReactNode
    ): React.ReactNode => {
      return canPerform(requirements) ? component : (fallback || null);
    },
    [canPerform]
  );
}