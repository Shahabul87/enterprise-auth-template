
import { renderHook, act } from '@testing-library/react';
import { usePermission, usePermissionGuard, usePermissionRender, PermissionConfig } from '../../hooks/use-permission';
import { useUserPermissions, useUserRoles } from '@/hooks/api/use-auth';
import React from 'react';

/**
 * @jest-environment jsdom
 */

jest.mock('@/hooks/api/use-auth', () => ({
  useUserPermissions: jest.fn(),
  useUserRoles: jest.fn(),
// Orphaned closing removed
/**
 * Comprehensive test suite for usePermission hook
 * Tests all permission checking functionality with proper TypeScript typing
 */


// Type definitions for test mocks
interface MockQueryResult<T> {
  data: T | undefined;
  isLoading: boolean;
  error: Error | null;
}

type PermissionsList = string[];
type RolesList = string[];

// Mock the API hooks

const mockUseUserPermissions = useUserPermissions as jest.MockedFunction<typeof useUserPermissions>;
const mockUseUserRoles = useUserRoles as jest.MockedFunction<typeof useUserRoles>;
describe('usePermission Hook', () => {
  const mockPermissions = ['user:read', 'user:write', 'post:read', 'admin:read'];
  const mockRoles = ['user', 'editor'];
  beforeEach(() => {
    jest.clearAllMocks();
    // Default mock implementations
    mockUseUserPermissions.mockReturnValue({
      data: mockPermissions,
      isLoading: false,
      error: null,
    } as MockQueryResult<PermissionsList>);
    mockUseUserRoles.mockReturnValue({
      data: mockRoles,
      isLoading: false,
      error: null,
    } as MockQueryResult<RolesList>);
  });

describe('Hook Initialization', () => {
    it('should initialize with default config', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.permissions).toEqual(mockPermissions);
      expect(result.current.roles).toEqual(mockRoles);
      expect(result.current.isLoading).toBe(false);
      expect(result.current.isAuthenticated).toBe(false); // No user_id/token provided
      expect(result.current.error).toBeUndefined();
    });
    it('should initialize with custom config', () => {
      const config: PermissionConfig = {
        user_id: 'user-123',
        token: 'token-abc',
        requireAll: true,
      };
      const { result } = renderHook(() => usePermission(config));
      expect(result.current.isAuthenticated).toBe(true);
      expect(mockUseUserPermissions).toHaveBeenCalledWith('user-123', 'token-abc');
      expect(mockUseUserRoles).toHaveBeenCalledWith('user-123', 'token-abc');
    });
    it('should handle loading state', () => {
      mockUseUserPermissions.mockReturnValue({
        data: undefined,
        isLoading: true,
        error: null,
      } as MockQueryResult<PermissionsList>);
      mockUseUserRoles.mockReturnValue({
        data: undefined,
        isLoading: true,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.isLoading).toBe(true);
      expect(result.current.permissions).toEqual([]);
      expect(result.current.roles).toEqual([]);
    });
    it('should handle error state', () => {
      const mockError = new Error('Permission fetch failed');
      mockUseUserPermissions.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: mockError,
      } as MockQueryResult<PermissionsList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.error).toBe(mockError);
      expect(result.current.isLoading).toBe(false);
    });
  });

describe('Single Permission Checking', () => {
    it('should check if user has specific permission', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasPermission('user:read')).toBe(true);
      expect(result.current.hasPermission('user:write')).toBe(true);
      expect(result.current.hasPermission('user:delete')).toBe(false);
    });
    it('should return false when no permissions available', () => {
      mockUseUserPermissions.mockReturnValue({
        data: [],
        isLoading: false,
        error: null,
      } as MockQueryResult<PermissionsList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasPermission('user:read')).toBe(false);
    });
    it('should return false when permissions is null/undefined', () => {
      mockUseUserPermissions.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: null,
      } as MockQueryResult<PermissionsList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasPermission('user:read')).toBe(false);
    });
  });

describe('Multiple Permissions Checking', () => {
    it('should check multiple permissions with OR logic (default)', () => {
      const { result } = renderHook(() => usePermission());
      // Has at least one of these permissions
      expect(result.current.hasPermissions(['user:read', 'user:delete'])).toBe(true);
      // Has none of these permissions
      expect(result.current.hasPermissions(['user:delete', 'user:create'])).toBe(false);
      // Empty array should return true
      expect(result.current.hasPermissions([])).toBe(true);
    });
    it('should check multiple permissions with AND logic', () => {
      const { result } = renderHook(() => usePermission());
      // Has all of these permissions
      expect(result.current.hasPermissions(['user:read', 'user:write'], true)).toBe(true);
      // Missing one permission
      expect(result.current.hasPermissions(['user:read', 'user:delete'], true)).toBe(false);
      // Empty array should return true
      expect(result.current.hasPermissions([], true)).toBe(true);
    });
    it('should respect global requireAll config', () => {
      const { result } = renderHook(() => usePermission({ requireAll: true }));
      // Should use AND logic by default
      expect(result.current.hasPermissions(['user:read', 'user:write'])).toBe(true);
      expect(result.current.hasPermissions(['user:read', 'user:delete'])).toBe(false);
      // Override global config
      expect(result.current.hasPermissions(['user:read', 'user:delete'], false)).toBe(true);
    });
    it('should handle empty permissions array', () => {
      mockUseUserPermissions.mockReturnValue({
        data: [],
        isLoading: false,
        error: null,
      } as MockQueryResult<PermissionsList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasPermissions(['user:read'])).toBe(false);
      expect(result.current.hasPermissions([])).toBe(true); // Empty requirements always return true
    });
  });

describe('Single Role Checking', () => {
    it('should check if user has specific role', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasRole('user')).toBe(true);
      expect(result.current.hasRole('editor')).toBe(true);
      expect(result.current.hasRole('admin')).toBe(false);
    });
    it('should return false when no roles available', () => {
      mockUseUserRoles.mockReturnValue({
        data: [],
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasRole('user')).toBe(false);
    });
    it('should return false when roles is null/undefined', () => {
      mockUseUserRoles.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.hasRole('user')).toBe(false);
    });
  });

describe('Multiple Roles Checking', () => {
    it('should check multiple roles with OR logic (default)', () => {
      const { result } = renderHook(() => usePermission());
      // Has at least one of these roles
      expect(result.current.hasRoles(['user', 'admin'])).toBe(true);
      // Has none of these roles
      expect(result.current.hasRoles(['admin', 'superuser'])).toBe(false);
      // Empty array should return true
      expect(result.current.hasRoles([])).toBe(true);
    });
    it('should check multiple roles with AND logic', () => {
      const { result } = renderHook(() => usePermission());
      // Has all of these roles
      expect(result.current.hasRoles(['user', 'editor'], true)).toBe(true);
      // Missing one role
      expect(result.current.hasRoles(['user', 'admin'], true)).toBe(false);
      // Empty array should return true
      expect(result.current.hasRoles([], true)).toBe(true);
    });
    it('should respect global requireAll config for roles', () => {
      const { result } = renderHook(() => usePermission({ requireAll: true }));
      // Should use AND logic by default
      expect(result.current.hasRoles(['user', 'editor'])).toBe(true);
      expect(result.current.hasRoles(['user', 'admin'])).toBe(false);
      // Override global config
      expect(result.current.hasRoles(['user', 'admin'], false)).toBe(true);
    });
  });

describe('Special Role Checking', () => {
    it('should check if user is admin', () => {
      mockUseUserRoles.mockReturnValue({
        data: ['user', 'admin'],
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.isAdmin()).toBe(true);
    });
    it('should check alternative admin role name', () => {
      mockUseUserRoles.mockReturnValue({
        data: ['user', 'administrator'],
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.isAdmin()).toBe(true);
    });
    it('should return false when user is not admin', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.isAdmin()).toBe(false);
    });
    it('should check if user is superuser', () => {
      mockUseUserRoles.mockReturnValue({
        data: ['user', 'superuser'],
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.isSuperuser()).toBe(true);
    });
    it('should check alternative superuser role name', () => {
      mockUseUserRoles.mockReturnValue({
        data: ['user', 'super_user'],
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.isSuperuser()).toBe(true);
    });
    it('should return false when user is not superuser', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.isSuperuser()).toBe(false);
    });
  });

describe('Missing Permissions and Roles', () => {
    it('should get missing permissions', () => {
      const { result } = renderHook(() => usePermission());
      const required = ['user:read', 'user:write', 'user:delete', 'admin:write'];
      const missing = result.current.getMissingPermissions(required);
      expect(missing).toEqual(['user:delete', 'admin:write']);
    });
    it('should return all permissions as missing when user has none', () => {
      mockUseUserPermissions.mockReturnValue({
        data: [],
        isLoading: false,
        error: null,
      } as MockQueryResult<PermissionsList>);
      const { result } = renderHook(() => usePermission());
      const required = ['user:read', 'user:write'];
      const missing = result.current.getMissingPermissions(required);
      expect(missing).toEqual(required);
    });
    it('should return all permissions as missing when permissions is null', () => {
      mockUseUserPermissions.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: null,
      } as MockQueryResult<PermissionsList>);
      const { result } = renderHook(() => usePermission());
      const required = ['user:read', 'user:write'];
      const missing = result.current.getMissingPermissions(required);
      expect(missing).toEqual(required);
    });
    it('should get missing roles', () => {
      const { result } = renderHook(() => usePermission());
      const required = ['user', 'editor', 'admin', 'superuser'];
      const missing = result.current.getMissingRoles(required);
      expect(missing).toEqual(['admin', 'superuser']);
    });
    it('should return all roles as missing when user has none', () => {
      mockUseUserRoles.mockReturnValue({
        data: [],
        isLoading: false,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      const required = ['user', 'admin'];
      const missing = result.current.getMissingRoles(required);
      expect(missing).toEqual(required);
    });
  });

describe('Complex Permission Actions', () => {
    it('should allow access when no requirements specified', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.canPerform({})).toBe(true);
      expect(result.current.canPerform({ permissions: [], roles: [] })).toBe(true);
    });
    it('should check permissions only', () => {
      const { result } = renderHook(() => usePermission());
      // User has user:read and user:write - should pass
      expect(result.current.canPerform({
        permissions: ['user:read', 'user:write']
      })).toBe(true);
      // User doesn't have admin:write - should fail
      expect(result.current.canPerform({
        permissions: ['admin:write'],
        requireAll: true
      })).toBe(false);
    });
    it('should check roles only', () => {
      const { result } = renderHook(() => usePermission());
      expect(result.current.canPerform({
        roles: ['user', 'editor']
      })).toBe(true);
      expect(result.current.canPerform({
        roles: ['admin'],
        requireAll: true
      })).toBe(false);
    });
    it('should check both permissions and roles (AND logic)', () => {
      const { result } = renderHook(() => usePermission());
      // User has required permissions AND roles
      expect(result.current.canPerform({
        permissions: ['user:read'],
        roles: ['user']
      })).toBe(true);
      // User has permissions but missing roles
      expect(result.current.canPerform({
        permissions: ['user:read'],
        roles: ['admin']
      })).toBe(false);
      // User has roles but missing permissions
      expect(result.current.canPerform({
        permissions: ['admin:write'],
        roles: ['user']
      })).toBe(false);
    });
    it('should respect requireAll flag in canPerform', () => {
      const { result } = renderHook(() => usePermission());
      // OR logic - has some permissions
      expect(result.current.canPerform({
        permissions: ['user:read', 'admin:write'],
        requireAll: false
      })).toBe(true);
      // AND logic - missing some permissions
      expect(result.current.canPerform({
        permissions: ['user:read', 'admin:write'],
        requireAll: true
      })).toBe(false);
    });
    it('should use global requireAll when action requireAll not specified', () => {
      const { result } = renderHook(() => usePermission({ requireAll: true }));
      // Should use global AND logic
      expect(result.current.canPerform({
        permissions: ['user:read', 'admin:write']
      })).toBe(false);
    });
  });

describe('Edge Cases', () => {
    it('should handle mixed loading states', () => {
      mockUseUserPermissions.mockReturnValue({
        data: mockPermissions,
        isLoading: false,
        error: null,
      } as MockQueryResult<PermissionsList>);
      mockUseUserRoles.mockReturnValue({
        data: undefined,
        isLoading: true,
        error: null,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      expect(result.current.isLoading).toBe(true);
      expect(result.current.permissions).toEqual(mockPermissions);
      expect(result.current.roles).toEqual([]);
    });
    it('should handle error priority', () => {
      const permissionError = new Error('Permission error');
      const roleError = new Error('Role error');
      mockUseUserPermissions.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: permissionError,
      } as MockQueryResult<PermissionsList>);
      mockUseUserRoles.mockReturnValue({
        data: undefined,
        isLoading: false,
        error: roleError,
      } as MockQueryResult<RolesList>);
      const { result } = renderHook(() => usePermission());
      // Should return the first error (permissions error)
      expect(result.current.error).toBe(permissionError);
    });
    it('should maintain function identity for performance', () => {
      const { result, rerender } = renderHook(() => usePermission());
      const initialHasPermission = result.current.hasPermission;
      const initialCanPerform = result.current.canPerform;
      rerender();
      // Functions should be memoized and maintain identity
      expect(result.current.hasPermission).toBe(initialHasPermission);
      expect(result.current.canPerform).toBe(initialCanPerform);
    });
  });
});

describe('usePermissionGuard Hook', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseUserPermissions.mockReturnValue({
      data: ['user:read', 'user:write'],
      isLoading: false,
      error: null,
    } as MockQueryResult<PermissionsList>);
    mockUseUserRoles.mockReturnValue({
      data: ['user'],
      isLoading: false,
      error: null,
    } as MockQueryResult<RolesList>);
  });
  it('should return true when user has required permissions', () => {
    const { result } = renderHook(() =>
      usePermissionGuard({ permissions: ['user:read'] })
    );
    expect(result.current).toBe(true);
  });
  it('should return false when user lacks required permissions', () => {
    const { result } = renderHook(() =>
      usePermissionGuard({ permissions: ['admin:write'] })
    );
    expect(result.current).toBe(false);
  });
  it('should return false during loading to prevent flash of content', () => {
    mockUseUserPermissions.mockReturnValue({
      data: undefined,
      isLoading: true,
      error: null,
    } as MockQueryResult<PermissionsList>);
    const { result } = renderHook(() =>
      usePermissionGuard({ permissions: ['user:read'] })
    );
    expect(result.current).toBe(false);
  });
  it('should work with roles', () => {
    const { result } = renderHook(() =>
      usePermissionGuard({ roles: ['user'] })
    );
    expect(result.current).toBe(true);
  });
  it('should work with custom config', () => {
    const config = { user_id: 'user-123', token: 'token-abc' };
    const { result } = renderHook(() =>
      usePermissionGuard({ permissions: ['user:read'] }, config)
    );
    expect(result.current).toBe(true);
    expect(mockUseUserPermissions).toHaveBeenCalledWith('user-123', 'token-abc');
  });
});

describe('usePermissionRender Hook', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseUserPermissions.mockReturnValue({
      data: ['user:read', 'user:write'],
      isLoading: false,
      error: null,
    } as MockQueryResult<PermissionsList>);
    mockUseUserRoles.mockReturnValue({
      data: ['user'],
      isLoading: false,
      error: null,
    } as MockQueryResult<RolesList>);
  });
  it('should render component when user has permissions', () => {
    const { result } = renderHook(() => usePermissionRender());
    const component = 'Protected Content';
    const rendered = result.current(
      { permissions: ['user:read'] },
      component
    );
    expect(rendered).toBe(component);
  });
  it('should render null when user lacks permissions', () => {
    const { result } = renderHook(() => usePermissionRender());
    const component = 'Protected Content';
    const rendered = result.current(
      { permissions: ['admin:write'] },
      component
    );
    expect(rendered).toBeNull();
  });
  it('should render fallback when provided', () => {
    const { result } = renderHook(() => usePermissionRender());
    const component = 'Protected Content';
    const fallback = 'Access Denied';
    const rendered = result.current(
      { permissions: ['admin:write'] },
      component,
      fallback
    );
    expect(rendered).toBe(fallback);
  });
  it('should work with roles', () => {
    const { result } = renderHook(() => usePermissionRender());
    const component = 'User Content';
    const rendered = result.current(
      { roles: ['user'] },
      component
    );
    expect(rendered).toBe(component);
  });
  it('should work with complex requirements', () => {
    const { result } = renderHook(() => usePermissionRender());
    const component = 'Complex Content';
    const rendered = result.current(
      {
        permissions: ['user:read'],
        roles: ['user'],
        requireAll: true
      },
      component
    );
    expect(rendered).toBe(component);
  });
  it('should maintain function identity for performance', () => {
    const { result, rerender } = renderHook(() => usePermissionRender());
    const initialRenderIf = result.current;
    rerender();
    expect(result.current).toBe(initialRenderIf);
  });
});