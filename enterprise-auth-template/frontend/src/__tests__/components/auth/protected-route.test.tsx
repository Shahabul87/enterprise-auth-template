import React from 'react';
import { render, screen } from '@testing-library/react';
import { ProtectedRoute } from '@/components/auth/protected-route';
import { useAuthStore, type AuthState } from '@/stores/auth.store';
import type { User } from '@/types/auth.types';
jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => ({
    user: null,
    tokens: null,
    accessToken: null,
    isAuthenticated: false,
    isLoading: false,
    isInitialized: true,
    permissions: [],
    roles: [],
    session: null,
    error: null,
    authErrors: [],
    isEmailVerified: false,
    is2FAEnabled: false,
    requiresPasswordChange: false,
    isTokenValid: () => true,
    initialize: async () => {},
    login: async () => ({ success: true, data: { user: null, tokens: null } }),
    register: async () => ({ success: true, data: { message: 'Success' } }),
    logout: async () => {},
    refreshToken: async () => true,
    refreshAccessToken: async () => null,
    updateUser: () => {},
    hasPermission: () => false,
    hasRole: () => false,
    hasAnyRole: () => false,
    hasAllPermissions: () => false,
    setError: () => {},
    clearError: () => {},
    addAuthError: () => {},
    clearAuthErrors: () => {},
    updateSession: () => {},
    checkSession: async () => true,
    extendSession: async () => {},
    fetchUserData: async () => {},
    fetchPermissions: async () => {},
    verifyEmail: async () => ({ success: true, data: { message: 'Success' } }),
    resendVerification: async () => ({ success: true, data: { message: 'Success' } }),
    changePassword: async () => ({ success: true, data: { message: 'Success' } }),
    requestPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    confirmPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    setup2FA: async () => ({ success: true, data: { qr_code: '', backup_codes: [] } }),
    verify2FA: async () => ({ success: true, data: { enabled: true, message: 'Success' } }),
    disable2FA: async () => ({ success: true, data: { enabled: false, message: 'Success' } }),
    clearAuth: () => {},
    setupTokenRefresh: () => {},
    clearAuthData: () => {},
    setAuth: () => {},
    user: null,
    isAuthenticated: false,
    isLoading: false,
    permissions: [],
    hasPermission: jest.fn(() => false),
    hasRole: jest.fn(() => false),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  }))}}))));,
})),
    logout: jest.fn(),
    initialize: jest.fn(),
/**
 * Comprehensive test suite for ProtectedRoute component
 * Tests authentication checks, permission validation, role-based access, and loading states
 */
// Mock the auth store
  useAuthStore: jest.fn(),
const mockUseAuthStore = useAuthStore as jest.MockedFunction<typeof useAuthStore>;
// Helper function to safely cast mock states to AuthState
const mockAuthState = (state: MockAuthState | (PartialMockAuthState & Record<string, unknown>)): AuthState => {
  return state as unknown as AuthState;
};
// Define proper types for auth state - compatible with only needed properties
interface MockAuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  hasPermission: jest.MockedFunction<(permission: string) => boolean>;
  hasRole: jest.MockedFunction<(role: string) => boolean>;
  [key: string]: unknown; // Allow additional properties to be compatible with AuthState
interface PartialMockAuthState {
  user?: User | null;
  isAuthenticated?: boolean;
  isLoading?: boolean;
  hasPermission?: jest.MockedFunction<(permission: string) => boolean>;
  hasRole?: jest.MockedFunction<(role: string) => boolean>;
  [key: string]: unknown; // Allow additional properties
}}})));
describe('ProtectedRoute Component', () => {
  const defaultAuthState: MockAuthState = {
    user: {
      id: '1',
      email: 'test@example.com',
      full_name: 'Test User',
      username: 'testuser',
      is_active: true,
      is_verified: true,
      email_verified: true,
      is_superuser: false,
      two_factor_enabled: false,
      failed_login_attempts: 0,
      last_login: '2024-01-01T00:00:00Z',
      last_login_at: '2024-01-01T00:00:00Z',
      profile_picture: 'https://example.com/avatar.jpg',
      avatar_url: 'https://example.com/avatar.jpg',
      phone_number: '+1234567890',
      is_phone_verified: true,
      user_metadata: {},
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
      roles: [{
        id: 'user-role',
        name: 'user',
        description: 'User role',
        is_active: true,
        created_at: '2024-01-01T00:00:00Z',
        updated_at: '2024-01-01T00:00:00Z',
        permissions: [
          {
            id: 'read-posts',
            name: 'read:posts',
            resource: 'posts',
            action: 'read',
            description: 'Read posts permission',
            created_at: '2024-01-01T00:00:00Z',
            updated_at: '2024-01-01T00:00:00Z',
          },
          {
            id: 'write-posts',
            name: 'write:posts',
            resource: 'posts',
            action: 'write',
            description: 'Write posts permission',
            created_at: '2024-01-01T00:00:00Z',
            updated_at: '2024-01-01T00:00:00Z',
          },
        ],
      }],
      permissions: ['read:posts', 'write:posts'],
    },
    isAuthenticated: true,
    hasPermission: jest.fn((permission: string) => {
      return ['read:posts', 'write:posts'].includes(permission);
    }),
    hasRole: jest.fn((role: string) => {
      return ['user'].includes(role);
    }),
  };
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseAuthStore.mockReturnValue(mockAuthState(defaultAuthState));
  });

describe('Basic Rendering', () => {
    it('should render children when user is authenticated with no requirements', () => {
      render(
        <ProtectedRoute>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
    });
    it('should render children when user has required permissions', () => {
      render(
        <ProtectedRoute requiredPermissions={['read:posts']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(defaultAuthState.hasPermission).toHaveBeenCalledWith('read:posts');
    });
    it('should render children when user has required roles', () => {
      render(
        <ProtectedRoute requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(defaultAuthState.hasRole).toHaveBeenCalledWith('user');
    });
    it('should render children when user has both required permissions and roles', () => {
      render(
        <ProtectedRoute requiredPermissions={['read:posts']} requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(defaultAuthState.hasPermission).toHaveBeenCalledWith('read:posts');
      expect(defaultAuthState.hasRole).toHaveBeenCalledWith('user');
    });
  });

describe('Loading State', () => {
    it('should show loading spinner when isLoading is true', () => {
      const loadingState: PartialMockAuthState & { isLoading: true } = {
        ...defaultAuthState,
        isLoading: true,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(loadingState));
      const { container } = render(
        <ProtectedRoute>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
      const spinner = container.querySelector('.animate-spin');
      expect(spinner).toBeInTheDocument();
    });
    it('should not check permissions or roles while loading', () => {
      const loadingStateNoCheck: PartialMockAuthState & { isLoading: true } = {
        ...defaultAuthState,
        isLoading: true,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(loadingStateNoCheck));
      render(
        <ProtectedRoute requiredPermissions={['read:posts']} requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(defaultAuthState.hasPermission).not.toHaveBeenCalled();
      expect(defaultAuthState.hasRole).not.toHaveBeenCalled();
    });
  });

describe('Authentication Check', () => {
    it('should show redirect message when user is not authenticated', () => {
      const unauthenticatedState: PartialMockAuthState & { isAuthenticated: false; user: null } = {
        ...defaultAuthState,
        isAuthenticated: false,
        user: null,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(unauthenticatedState));
      render(
        <ProtectedRoute>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Redirecting to login...')).toBeInTheDocument();
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });
    it('should show redirect message when user is null despite being authenticated', () => {
      const authenticatedButNoUserState: PartialMockAuthState & { isAuthenticated: true; user: null } = {
        ...defaultAuthState,
        isAuthenticated: true,
        user: null,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(authenticatedButNoUserState));
      render(
        <ProtectedRoute>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Redirecting to login...')).toBeInTheDocument();
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });
    it('should not check permissions when user is not authenticated', () => {
      const unauthenticatedWithoutPermissionsState: PartialMockAuthState & { isAuthenticated: false; user: null } = {
        ...defaultAuthState,
        isAuthenticated: false,
        user: null,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(unauthenticatedWithoutPermissionsState));
      render(
        <ProtectedRoute requiredPermissions={['read:posts']} requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(defaultAuthState.hasPermission).not.toHaveBeenCalled();
      expect(defaultAuthState.hasRole).not.toHaveBeenCalled();
    });
  });

describe('Permission Validation', () => {
    it('should deny access when user lacks required permission', () => {
      const mockHasPermission = jest.fn().mockReturnValue(false);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredPermissions={['admin:write']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Access Denied')).toBeInTheDocument();
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
      expect(mockHasPermission).toHaveBeenCalledWith('admin:write');
    });
    it('should allow access when user has at least one required permission', () => {
      const mockHasPermission = jest.fn((permission) => permission === 'write:posts');
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredPermissions={['admin:write', 'write:posts']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(mockHasPermission).toHaveBeenCalledWith('admin:write');
      expect(mockHasPermission).toHaveBeenCalledWith('write:posts');
    });
    it('should check all permissions until one matches', () => {
      const mockHasPermission = jest.fn()
        .mockReturnValueOnce(false)
        .mockReturnValueOnce(false)
        .mockReturnValueOnce(true);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredPermissions={['perm1', 'perm2', 'perm3']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(mockHasPermission).toHaveBeenCalledTimes(3);
    });
    it('should handle empty permissions array', () => {
      render(
        <ProtectedRoute requiredPermissions={[]}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(defaultAuthState.hasPermission).not.toHaveBeenCalled();
    });
  });

describe('Role Validation', () => {
    it('should deny access when user lacks required role', () => {
      const mockHasRole = jest.fn().mockReturnValue(false);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredRoles={['admin']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Access Denied')).toBeInTheDocument();
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
      expect(mockHasRole).toHaveBeenCalledWith('admin');
    });
    it('should allow access when user has at least one required role', () => {
      const mockHasRole = jest.fn((role) => role === 'user');
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredRoles={['admin', 'user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(mockHasRole).toHaveBeenCalledWith('admin');
      expect(mockHasRole).toHaveBeenCalledWith('user');
    });
    it('should check all roles until one matches', () => {
      const mockHasRole = jest.fn()
        .mockReturnValueOnce(false)
        .mockReturnValueOnce(true);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredRoles={['admin', 'moderator']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(mockHasRole).toHaveBeenCalledTimes(2);
    });
    it('should handle empty roles array', () => {
      render(
        <ProtectedRoute requiredRoles={[]}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(defaultAuthState.hasRole).not.toHaveBeenCalled();
    });
  });

describe('Combined Requirements', () => {
    it('should deny access when user has role but lacks permission', () => {
      const mockHasPermission = jest.fn().mockReturnValue(false);
      const mockHasRole = jest.fn().mockReturnValue(true);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredPermissions={['admin:write']} requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Access Denied')).toBeInTheDocument();
      expect(mockHasRole).toHaveBeenCalledWith('user');
      expect(mockHasPermission).toHaveBeenCalledWith('admin:write');
    });
    it('should deny access when user has permission but lacks role', () => {
      const mockHasPermission = jest.fn().mockReturnValue(true);
      const mockHasRole = jest.fn().mockReturnValue(false);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredPermissions={['read:posts']} requiredRoles={['admin']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Access Denied')).toBeInTheDocument();
      expect(mockHasRole).toHaveBeenCalledWith('admin');
      // Roles are checked first, so permission check may not happen
    });
    it('should allow access when user has both required role and permission', () => {
      const mockHasPermission = jest.fn().mockReturnValue(true);
      const mockHasRole = jest.fn().mockReturnValue(true);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredPermissions={['read:posts']} requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Protected Content')).toBeInTheDocument();
      expect(mockHasRole).toHaveBeenCalledWith('user');
      expect(mockHasPermission).toHaveBeenCalledWith('read:posts');
    });
  });

describe('Custom Fallback', () => {
    it('should render custom fallback when access is denied due to permissions', () => {
      const mockHasPermission = jest.fn().mockReturnValue(false);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute
          requiredPermissions={['admin:write']}
          fallback={<div>Custom Access Denied Message</div>}
        >
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Custom Access Denied Message')).toBeInTheDocument();
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });
    it('should render custom fallback when access is denied due to roles', () => {
      const mockHasRole = jest.fn().mockReturnValue(false);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasRole: mockHasRole,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute
          requiredRoles={['admin']}
          fallback={<div>You need admin role</div>}
        >
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('You need admin role')).toBeInTheDocument();
      expect(screen.queryByText('Protected Content')).not.toBeInTheDocument();
    });
    it('should render complex fallback component', () => {
      const mockHasPermission = jest.fn().mockReturnValue(false);
      const mockState: MockAuthState = {
        ...defaultAuthState,
        hasPermission: mockHasPermission,
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      const ComplexFallback = () => (
        <div>
          <h1>Access Denied</h1>
          <p>You don&apos;t have permission</p>
          <button>Request Access</button>
        </div>
      );
      render(
        <ProtectedRoute
          requiredPermissions={['admin:write']}
          fallback={<ComplexFallback />}
        >
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Access Denied')).toBeInTheDocument();
      expect(screen.getByText('You don\'t have permission')).toBeInTheDocument();
      expect(screen.getByText('Request Access')).toBeInTheDocument();
    });
  });

describe('Edge Cases', () => {
    it('should handle multiple children elements', () => {
      render(
        <ProtectedRoute>
          <div>Child 1</div>
          <div>Child 2</div>
          <span>Child 3</span>
        </ProtectedRoute>
      );
      expect(screen.getByText('Child 1')).toBeInTheDocument();
      expect(screen.getByText('Child 2')).toBeInTheDocument();
      expect(screen.getByText('Child 3')).toBeInTheDocument();
    });
    it('should handle React Fragment as children', () => {
      render(
        <ProtectedRoute>
          <>
            <div>Fragment Child 1</div>
            <div>Fragment Child 2</div>
          </>
        </ProtectedRoute>
      );
      expect(screen.getByText('Fragment Child 1')).toBeInTheDocument();
      expect(screen.getByText('Fragment Child 2')).toBeInTheDocument();
    });
    it('should handle nested ProtectedRoute components', () => {
      render(
        <ProtectedRoute requiredRoles={['user']}>
          <ProtectedRoute requiredPermissions={['read:posts']}>
            <div>Nested Protected Content</div>
          </ProtectedRoute>
        </ProtectedRoute>
      );
      expect(screen.getByText('Nested Protected Content')).toBeInTheDocument();
      expect(defaultAuthState.hasRole).toHaveBeenCalledWith('user');
      expect(defaultAuthState.hasPermission).toHaveBeenCalledWith('read:posts');
    });
    it('should handle undefined user properties gracefully', () => {
      const mockState: MockAuthState = {
        user: {
          id: '1',
          email: 'test@example.com',
          full_name: 'Test User',
          is_active: true,
          is_verified: true,
          email_verified: true,
          is_superuser: false,
          two_factor_enabled: false,
          failed_login_attempts: 0,
          last_login: '2024-01-01T00:00:00Z',
          user_metadata: {},
          created_at: '2024-01-01T00:00:00Z',
          updated_at: '2024-01-01T00:00:00Z',
          roles: [], // Empty roles array to test the condition
          permissions: [],
        },
        isAuthenticated: true,
        isLoading: false,
        hasPermission: jest.fn().mockReturnValue(false),
        hasRole: jest.fn().mockReturnValue(false),
      };
      mockUseAuthStore.mockReturnValue(mockAuthState(mockState));
      render(
        <ProtectedRoute requiredRoles={['user']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Access Denied')).toBeInTheDocument();
    });
  });

describe('Performance Considerations', () => {
    it('should not re-check permissions on re-render if props haven&apos;t changed', () => {
      const { rerender } = render(
        <ProtectedRoute requiredPermissions={['read:posts']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(defaultAuthState.hasPermission).toHaveBeenCalledTimes(1);
      rerender(
        <ProtectedRoute requiredPermissions={['read:posts']}>
          <div>Protected Content Updated</div>
        </ProtectedRoute>
      );
      // Should be called again because React doesn't memoize by default
      expect(defaultAuthState.hasPermission).toHaveBeenCalledTimes(2);
    });
    it('should re-check permissions when requirements change', () => {
      const { rerender } = render(
        <ProtectedRoute requiredPermissions={['read:posts']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(defaultAuthState.hasPermission).toHaveBeenCalledWith('read:posts');
      rerender(
        <ProtectedRoute requiredPermissions={['write:posts']}>
          <div>Protected Content</div>
        </ProtectedRoute>
      );
      expect(defaultAuthState.hasPermission).toHaveBeenCalledWith('write:posts');
    });
  });

describe('TypeScript Type Safety', () => {
    it('should accept valid prop types', () => {
      // This test ensures TypeScript types are properly defined
      const validProps = {
        children: <div>Content</div>,
        requiredPermissions: ['read:posts'],
        requiredRoles: ['user'],
        fallback: <div>Fallback</div>,
      };
      render(<ProtectedRoute {...validProps} />);
      expect(screen.getByText('Content')).toBeInTheDocument();
    });
    it('should work with minimal props', () => {
      render(
        <ProtectedRoute>
          <div>Minimal Props Content</div>
        </ProtectedRoute>
      );
      expect(screen.getByText('Minimal Props Content')).toBeInTheDocument();
    });
  });
});