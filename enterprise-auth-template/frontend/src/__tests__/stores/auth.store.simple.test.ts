
import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from '@/stores/auth.store';
jest.mock('@/lib/auth-api');
jest.mock('@/lib/cookie-manager');

jest.mock('@/lib/cookie-manager');
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
}));

jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),}));
/**
 * @jest-environment jsdom
 */


// Mock window.location first
const mockLocation = {
  href: '',
  assign: jest.fn(),
  replace: jest.fn(),
  reload: jest.fn(),
};
Object.defineProperty(window, 'location', {
  value: mockLocation,
  writable: true
});

// Mock dependencies with manual mocks


describe('useAuthStore - Basic Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset the store state before each test
    useAuthStore.setState({
      user: null,
      tokens: null,
      accessToken: null,
      isAuthenticated: false,
      isLoading: false,
      isInitialized: false,
      permissions: [],
      roles: [],
      session: null,
      error: null,
      authErrors: [],
      isEmailVerified: false,
      is2FAEnabled: false,
      requiresPasswordChange: false
    });
    // Reset location mock
    mockLocation.href = '';
    mockLocation.assign.mockClear();
    mockLocation.replace.mockClear();
    mockLocation.reload.mockClear();
  });
  it('should have correct initial state', () => {
    const { result } = renderHook(() => useAuthStore());
    expect(result.current.user).toBeNull();
    expect(result.current.tokens).toBeNull();
    expect(result.current.accessToken).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.isInitialized).toBe(false);
    expect(result.current.permissions).toEqual([]);
    expect(result.current.roles).toEqual([]);
    expect(result.current.session).toBeNull();
    expect(result.current.error).toBeNull();
    expect(result.current.authErrors).toEqual([]);
    expect(result.current.isEmailVerified).toBe(false);
    expect(result.current.is2FAEnabled).toBe(false);
    expect(result.current.requiresPasswordChange).toBe(false);
  });
  it('should expose all required methods', () => {
    const { result } = renderHook(() => useAuthStore());
    // Core actions
    expect(typeof result.current.initialize).toBe('function');
    expect(typeof result.current.login).toBe('function');
    expect(typeof result.current.register).toBe('function');
    expect(typeof result.current.logout).toBe('function');
    expect(typeof result.current.refreshToken).toBe('function');
    expect(typeof result.current.updateUser).toBe('function');
    // Permission and role checks
    expect(typeof result.current.hasPermission).toBe('function');
    expect(typeof result.current.hasRole).toBe('function');
    expect(typeof result.current.hasAnyRole).toBe('function');
    expect(typeof result.current.hasAllPermissions).toBe('function');
    // Error management
    expect(typeof result.current.setError).toBe('function');
    expect(typeof result.current.clearError).toBe('function');
    // Session management
    expect(typeof result.current.updateSession).toBe('function');
    expect(typeof result.current.checkSession).toBe('function');
    // Utility actions
    expect(typeof result.current.fetchUserData).toBe('function');
    expect(typeof result.current.verifyEmail).toBe('function');
    expect(typeof result.current.resendVerification).toBe('function');
    expect(typeof result.current.requestPasswordReset).toBe('function');
    expect(typeof result.current.confirmPasswordReset).toBe('function');
  });
  it('should set and clear errors', () => {
    const { result } = renderHook(() => useAuthStore());
    const testError = {
      code: 'TEST_ERROR',
      message: 'Test error message',
      timestamp: new Date(),
    };
    act(() => {
      result.current.setError(testError);
    });
    expect(result.current.error).toEqual(testError);
    act(() => {
      result.current.clearError();
    });
    expect(result.current.error).toBeNull();
  });
  it('should update user data', () => {
    const { result } = renderHook(() => useAuthStore());
    const mockUser = {
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
      last_login: new Date().toISOString(),
      user_metadata: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      roles: [],
      permissions: [],
    };
    // Set initial user
    act(() => {
      useAuthStore.setState({ user: mockUser, isAuthenticated: true });
    });
    // Update user
    act(() => {
      result.current.updateUser({
        full_name: 'Updated Name',
        email: 'updated@example.com'
      });
    });
    expect(result.current.user).toMatchObject({
      full_name: 'Updated Name',
      email: 'updated@example.com'
    });
  });
  it('should handle permission checks', () => {
    const { result } = renderHook(() => useAuthStore());
    // Set permissions
    act(() => {
      useAuthStore.setState({
        permissions: ['read:profile', 'write:profile', 'admin:*'],
        roles: ['user', 'moderator']
      });
    });
    // Test exact permissions
    expect(result.current.hasPermission('read:profile')).toBe(true);
    expect(result.current.hasPermission('write:profile')).toBe(true);
    expect(result.current.hasPermission('delete:profile')).toBe(false);
    // Test wildcard permissions
    expect(result.current.hasPermission('admin:users')).toBe(true);
    expect(result.current.hasPermission('admin:settings')).toBe(true);
    // Test roles
    expect(result.current.hasRole('user')).toBe(true);
    expect(result.current.hasRole('admin')).toBe(false);
    // Test any role
    expect(result.current.hasAnyRole(['user', 'admin'])).toBe(true);
    expect(result.current.hasAnyRole(['admin', 'super_admin'])).toBe(false);
    // Test all permissions
    expect(result.current.hasAllPermissions(['read:profile', 'write:profile'])).toBe(true);
    expect(result.current.hasAllPermissions(['read:profile', 'delete:profile'])).toBe(false);
  });
  it('should handle session updates', () => {
    const { result } = renderHook(() => useAuthStore());
    const sessionUpdate = {
      device: 'iPhone 14',
      ipAddress: '192.168.1.1',
      location: 'New York, NY',
    };
    act(() => {
      result.current.updateSession(sessionUpdate);
    });
    expect(result.current.session).toMatchObject(sessionUpdate);
    expect(result.current.session?.loginTime).toBeInstanceOf(Date);
    expect(result.current.session?.lastActivity).toBeInstanceOf(Date);
  });
  it('should handle auth error management', () => {
    const { result } = renderHook(() => useAuthStore());
    const error1 = { code: 'ERROR_1', message: 'Error 1', timestamp: new Date() };
    const error2 = { code: 'ERROR_2', message: 'Error 2', timestamp: new Date() };
    act(() => {
      result.current.addAuthError?.(error1);
      result.current.addAuthError?.(error2);
    });
    expect(result.current.authErrors).toHaveLength(2);
    expect(result.current.authErrors).toContain(error1);
    expect(result.current.authErrors).toContain(error2);
    act(() => {
      result.current.clearAuthErrors?.();
    });
    expect(result.current.authErrors).toHaveLength(0);
  });
  it('should clear authentication data', () => {
    const { result } = renderHook(() => useAuthStore());
    const mockUser = {
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
      last_login: new Date().toISOString(),
      user_metadata: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      roles: [],
      permissions: [],
    };
    // Set authenticated state
    act(() => {
      useAuthStore.setState({
        user: mockUser,
        isAuthenticated: true,
        tokens: {
          access_token: 'token',
          refresh_token: 'refresh',
          token_type: 'bearer',
          expires_in: 3600,
        },
        permissions: ['read:profile'],
        roles: ['user']
      });
    });
    // Clear auth data
    act(() => {
      result.current.clearAuthData?.();
    });
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.tokens).toBeNull();
    expect(result.current.permissions).toEqual([]);
    expect(result.current.roles).toEqual([]);
  });
});
}}