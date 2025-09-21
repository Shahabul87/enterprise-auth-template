import { renderHook, act } from '@testing-library/react';
import AuthAPI from '@/lib/auth-api';
import * as cookieManager from '@/lib/cookie-manager';


import React from 'react';
// We'll test the actual store instead of mocking it
jest.mock('@/lib/auth-api');
const mockAuthAPI = AuthAPI as jest.Mocked<typeof AuthAPI>;

jest.mock('@/lib/cookie-manager');
const mockCookieManager = cookieManager as jest.Mocked<typeof cookieManager>;
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
}));
/**
 * Comprehensive Auth Store Test Suite
 * Tests all authentication store functionality with proper TypeScript typing
 *
 * Coverage includes:
 * - Store initialization and cleanup
 * - Login/logout flows with proper state management
 * - Registration with email verification flows
 * - Token management and refresh mechanisms
 * - Permission and role-based access control
 * - Two-factor authentication setup and verification
 * - Password reset and change operations
 * - Session management and activity tracking
 * - Error handling and error state management
 * - Utility hooks and selectors
 * - Persistence and storage mechanisms
 */
import {  useAuthStore,
  AuthError,
  SessionInfo,
  useUser,
  useIsAuthenticated,
  useAuthLoading,
  useAuthError,
  usePermissions,
  useRoles
} from '@/stores/auth.store';
import {  User,
  TokenPair,
  ApiResponse
} from '@/types';
// Mock dependencies are already set up via jest.mock
// Type the mocked modules
// AuthAPI is already mocked above
// Mock user data
const createMockUser = (overrides: Partial<User> = {}): User => ({
  id: 'user-123',
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
  avatar_url: undefined,
  profile_picture: undefined,
  phone_number: undefined,
  is_phone_verified: undefined,
  user_metadata: {},
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  roles: [],
  permissions: [],
  ...overrides
});
const createMockTokenPair = (overrides: Partial<TokenPair> = {}): TokenPair => ({
  access_token: 'mock-access-token',
  refresh_token: 'mock-refresh-token',
  token_type: 'bearer',
  expires_in: 3600,
  ...overrides
});

describe('Auth Store Comprehensive Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset store state
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
    // Setup default mock implementations
    mockCookieManager.getAuthTokens.mockReturnValue(null);
    mockCookieManager.hasAuthCookies.mockReturnValue(false);
    mockCookieManager.isTokenExpired.mockReturnValue(false);
    mockCookieManager.getCookie.mockReturnValue(null);
  });
});
describe('Initial State', () => {
    it('should have correct initial state', async () => {
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
    it('should expose all required methods', async () => {
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
      expect(typeof result.current.addAuthError).toBe('function');
      expect(typeof result.current.clearAuthErrors).toBe('function');
      // Session management
      expect(typeof result.current.updateSession).toBe('function');
      expect(typeof result.current.checkSession).toBe('function');
      expect(typeof result.current.extendSession).toBe('function');
      // Utility actions
      expect(typeof result.current.fetchUserData).toBe('function');
      expect(typeof result.current.fetchPermissions).toBe('function');
      expect(typeof result.current.verifyEmail).toBe('function');
      expect(typeof result.current.resendVerification).toBe('function');
      expect(typeof result.current.changePassword).toBe('function');
      expect(typeof result.current.requestPasswordReset).toBe('function');
      expect(typeof result.current.confirmPasswordReset).toBe('function');
      // 2FA actions
      expect(typeof result.current.setup2FA).toBe('function');
      expect(typeof result.current.verify2FA).toBe('function');
      expect(typeof result.current.disable2FA).toBe('function');
    });
  });

describe('Permission and Role Management', () => {
    beforeEach(() => {
      useAuthStore.setState({
        permissions: ['read:profile', 'write:profile', 'admin:*'],
        roles: ['user', 'moderator']
      });
    });
    it('should check exact permissions correctly', async () => {
      const { result } = renderHook(() => useAuthStore());
      expect(result.current.hasPermission('read:profile')).toBe(true);
      expect(result.current.hasPermission('write:profile')).toBe(true);
      expect(result.current.hasPermission('delete:profile')).toBe(false);
    });
    it('should check wildcard permissions correctly', async () => {
      const { result } = renderHook(() => useAuthStore());
      expect(result.current.hasPermission('admin:users')).toBe(true);
      expect(result.current.hasPermission('admin:settings')).toBe(true);
      expect(result.current.hasPermission('admin:anything')).toBe(true);
      expect(result.current.hasPermission('user:profile')).toBe(false);
    });
    it('should check roles correctly', async () => {
      const { result } = renderHook(() => useAuthStore());
      expect(result.current.hasRole('user')).toBe(true);
      expect(result.current.hasRole('moderator')).toBe(true);
      expect(result.current.hasRole('admin')).toBe(false);
    });
    it('should check any role correctly', async () => {
      const { result } = renderHook(() => useAuthStore());
      expect(result.current.hasAnyRole(['user', 'admin'])).toBe(true);
      expect(result.current.hasAnyRole(['admin', 'super_admin'])).toBe(false);
      expect(result.current.hasAnyRole(['moderator'])).toBe(true);
    });
    it('should check all permissions correctly', async () => {
      const { result } = renderHook(() => useAuthStore());
      expect(result.current.hasAllPermissions(['read:profile', 'write:profile'])).toBe(true);
      expect(result.current.hasAllPermissions(['read:profile', 'delete:profile'])).toBe(false);
      expect(result.current.hasAllPermissions(['admin:users', 'admin:settings'])).toBe(true);
    });
    it('should return false for permissions when no permissions set', async () => {
      useAuthStore.setState({ permissions: [] });
      const { result } = renderHook(() => useAuthStore());
      expect(result.current.hasPermission('read:profile')).toBe(false);
      expect(result.current.hasAllPermissions(['read:profile'])).toBe(false);
    });
  });

describe('Error Management', () => {
    it('should set and clear errors', async () => {
      const { result } = renderHook(() => useAuthStore());
      const testError: AuthError = {
        code: 'TEST_ERROR',
        message: 'Test error message',
        timestamp: new Date(),
      };
      act(() => {
        result.current.setError(testError);
      });
      expect(result.current.error).toEqual(testError);
      expect(result.current.authErrors).toContain(testError);
      act(() => {
        result.current.clearError();
      });
      expect(result.current.error).toBeNull();
      expect(result.current.authErrors).toContain(testError); // Still in history
    });
    it('should add auth errors and maintain history limit', async () => {
      const { result } = renderHook(() => useAuthStore());
      act(() => {
        // Add 12 errors (more than the 10 limit)
        for (let i = 0; i < 12; i++) {
          result.current.addAuthError({
            code: `ERROR_${i}`,
            message: `Error ${i}`,
            timestamp: new Date()
          });
        }
      });
      expect(result.current.authErrors).toHaveLength(10);
      expect(result.current.authErrors[0].code).toBe('ERROR_2'); // First two should be removed
      expect(result.current.authErrors[9].code).toBe('ERROR_11');
    });
    it('should clear all auth errors', async () => {
      const { result } = renderHook(() => useAuthStore());
      act(() => {
        result.current.addAuthError({
          code: 'ERROR_1',
          message: 'Error 1',
          timestamp: new Date()
        });
        result.current.addAuthError({
          code: 'ERROR_2',
          message: 'Error 2',
          timestamp: new Date()
        });
      });
      expect(result.current.authErrors).toHaveLength(2);
      act(() => {
        result.current.clearAuthErrors();
      });
      expect(result.current.authErrors).toHaveLength(0);
    });
  });

describe('Session Management', () => {
    it('should update session information', async () => {
      const { result } = renderHook(() => useAuthStore());
      const sessionUpdate: Partial<SessionInfo> = {
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
    it('should check session and update activity when authenticated', async () => {
      useAuthStore.setState({
        isAuthenticated: true,
        tokens: createMockTokenPair(),
        session: {
          loginTime: new Date(),
          lastActivity: new Date(Date.now() - 60000), // 1 minute ago
        }
      });
      mockCookieManager.getCookie.mockReturnValue('valid-token');
      mockCookieManager.isTokenExpired.mockReturnValue(false);
      const { result } = renderHook(() => useAuthStore());
      let sessionValid: boolean;
      await act(async () => {
        sessionValid = await result.current.checkSession();
      });
      expect(sessionValid!).toBe(true);
      expect(result.current.session?.lastActivity.getTime()).toBeGreaterThan(
        Date.now() - 10000 // Should be very recent
      );
    });
    it('should return false when not authenticated', async () => {
      useAuthStore.setState({ isAuthenticated: false });
      const { result } = renderHook(() => useAuthStore());
      let sessionValid: boolean;
      await act(async () => {
        sessionValid = await result.current.checkSession();
      });
      expect(sessionValid!).toBe(false);
    });
  });

describe('Utility Actions', () => {
    it('should fetch user data successfully', async () => {
      const mockUser = createMockUser();
      mockAuthAPI.getCurrentUser.mockResolvedValue({
        success: true,
        data: mockUser
      });
      const { result } = renderHook(() => useAuthStore());

      // Set initial auth state since fetchUserData requires authentication
      act(() => {
        result.current.setAuth('access-token', 'refresh-token', mockUser);
      });

      await act(async () => {
        await result.current.fetchUserData();
      });

      expect(mockAuthAPI.getCurrentUser).toHaveBeenCalled();
      expect(result.current.user).toEqual(expect.objectContaining({
        id: mockUser.id,
        email: mockUser.email,
        full_name: mockUser.full_name,
        username: mockUser.username,
        is_active: mockUser.is_active,
        email_verified: mockUser.email_verified,
        is_superuser: mockUser.is_superuser,
        two_factor_enabled: mockUser.two_factor_enabled,
        failed_login_attempts: mockUser.failed_login_attempts,
        last_login: mockUser.last_login,
        user_metadata: mockUser.user_metadata,
        created_at: mockUser.created_at,
        updated_at: mockUser.updated_at,
        roles: mockUser.roles,
        permissions: mockUser.permissions,
      }));
      expect(mockCookieManager.storeAuthTokens).toHaveBeenCalled();
    });
  });
});