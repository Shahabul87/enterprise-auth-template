/**
 * Comprehensive Auth Store Tests
 *
 * Tests the Zustand auth store with proper TypeScript types,
 * state management, side effects, and full coverage.
 */

import { renderHook, act, waitFor } from '@testing-library/react';
import { useAuthStore, AuthState, AuthError, SessionInfo } from '@/stores/auth.store';
import AuthAPI from '@/lib/auth-api';
import {
  storeAuthTokens,
  getAuthTokens,
  clearAuthCookies,
  hasAuthCookies,
  isTokenExpired,
  getCookie,
  AUTH_COOKIES,
} from '@/lib/cookie-manager';
import type {
  ApiResponse,
  LoginRequest,
  LoginResponse,
  RegisterRequest,
  User,
  TokenPair,
  RefreshTokenRequest,
  ChangePasswordRequest,
  ResetPasswordRequest,
  ConfirmResetPasswordRequest,
} from '@/types';

// Type-safe mock interfaces
interface MockAuthAPI {
  login: jest.MockedFunction<(credentials: LoginRequest) => Promise<ApiResponse<LoginResponse>>>;
  register: jest.MockedFunction<(userData: RegisterRequest) => Promise<ApiResponse<{ message: string }>>>;
  logout: jest.MockedFunction<() => Promise<ApiResponse<{ message: string }>>>;
  refreshToken: jest.MockedFunction<(data: RefreshTokenRequest) => Promise<ApiResponse<TokenPair>>>;
  getCurrentUser: jest.MockedFunction<() => Promise<ApiResponse<User>>>;
  getUserPermissions: jest.MockedFunction<() => Promise<ApiResponse<string[]>>>;
  getUserRoles: jest.MockedFunction<() => Promise<ApiResponse<string[]>>>;
  verifyEmail: jest.MockedFunction<(token: string) => Promise<ApiResponse<{ message: string }>>>;
  resendVerification: jest.MockedFunction<(email: string) => Promise<ApiResponse<{ message: string }>>>;
  changePassword: jest.MockedFunction<(data: ChangePasswordRequest) => Promise<ApiResponse<{ message: string }>>>;
  requestPasswordReset: jest.MockedFunction<(data: ResetPasswordRequest) => Promise<ApiResponse<{ message: string }>>>;
  confirmPasswordReset: jest.MockedFunction<(data: ConfirmResetPasswordRequest) => Promise<ApiResponse<{ message: string }>>>;
  setup2FA: jest.MockedFunction<() => Promise<ApiResponse<{ qr_code: string; backup_codes: string[] }>>>;
  verify2FA: jest.MockedFunction<(code: string, token: string) => Promise<ApiResponse<TokenPair>>>;
  disable2FA: jest.MockedFunction<(code: string) => Promise<ApiResponse<{ message: string }>>>;
}

interface MockCookieManager {
  storeAuthTokens: jest.MockedFunction<(tokens: TokenPair) => void>;
  getAuthTokens: jest.MockedFunction<() => TokenPair | null>;
  clearAuthCookies: jest.MockedFunction<() => void>;
  hasAuthCookies: jest.MockedFunction<() => boolean>;
  isTokenExpired: jest.MockedFunction<(token: string) => boolean>;
  getCookie: jest.MockedFunction<(name: string) => string | null>;
}

// Mock AuthAPI with proper types - DECLARE BEFORE jest.mock()
const mockAuthAPI: MockAuthAPI = {
  login: jest.fn(),
  register: jest.fn(),
  logout: jest.fn(),
  refreshToken: jest.fn(),
  getCurrentUser: jest.fn(),
  getUserPermissions: jest.fn(),
  getUserRoles: jest.fn(),
  verifyEmail: jest.fn(),
  resendVerification: jest.fn(),
  changePassword: jest.fn(),
  requestPasswordReset: jest.fn(),
  confirmPasswordReset: jest.fn(),
  setup2FA: jest.fn(),
  verify2FA: jest.fn(),
  disable2FA: jest.fn(),
};

// Mock cookie manager with proper types - DECLARE BEFORE jest.mock()
const mockCookieManager: MockCookieManager = {
  storeAuthTokens: jest.fn(),
  getAuthTokens: jest.fn(),
  clearAuthCookies: jest.fn(),
  hasAuthCookies: jest.fn(),
  isTokenExpired: jest.fn(),
  getCookie: jest.fn(),
};

// Move jest.mock() calls AFTER variable declarations
jest.mock('@/lib/auth-api', () => ({
  __esModule: true,
  default: mockAuthAPI,
}));

jest.mock('@/lib/cookie-manager', () => ({
  storeAuthTokens: mockCookieManager.storeAuthTokens,
  getAuthTokens: mockCookieManager.getAuthTokens,
  clearAuthCookies: mockCookieManager.clearAuthCookies,
  hasAuthCookies: mockCookieManager.hasAuthCookies,
  isTokenExpired: mockCookieManager.isTokenExpired,
  getCookie: mockCookieManager.getCookie,
  AUTH_COOKIES: {
    ACCESS_TOKEN: 'access_token',
    REFRESH_TOKEN: 'refresh_token',
  },
}));

// Mock window for SSR/client-side checks
const mockWindow = {
  location: {
    href: '',
  },
};

// Test data with proper types
const mockUser: User = {
  id: 'user-123',
  email: 'test@example.com',
  full_name: 'Test User',
  username: 'testuser',
  is_active: true,
  email_verified: true,
  is_superuser: false,
  two_factor_enabled: false,
  failed_login_attempts: 0,
  last_login: '2024-01-01T00:00:00Z',
  user_metadata: { theme: 'dark' },
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  roles: [],
  permissions: ['read:users', 'write:posts'],
};

const mockTokens: TokenPair = {
  access_token: 'mock-access-token',
  refresh_token: 'mock-refresh-token',
  token_type: 'bearer',
  expires_in: 3600,
};

const mockLoginResponse: LoginResponse = {
  access_token: mockTokens.access_token,
  refresh_token: mockTokens.refresh_token,
  token_type: mockTokens.token_type,
  expires_in: mockTokens.expires_in,
  user: mockUser,
  requires_2fa: false,
};

const mockSessionInfo: SessionInfo = {
  loginTime: new Date('2024-01-01T00:00:00Z'),
  lastActivity: new Date('2024-01-01T00:05:00Z'),
  device: 'Chrome Browser',
  ipAddress: '192.168.1.1',
  location: 'New York, US',
};

describe('Auth Store', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.clearAllTimers();
    jest.useFakeTimers();

    // Reset all mocks to default state
    mockCookieManager.getAuthTokens.mockReturnValue(null);
    mockCookieManager.hasAuthCookies.mockReturnValue(false);
    mockCookieManager.isTokenExpired.mockReturnValue(false);
    mockCookieManager.getCookie.mockReturnValue(null);

    mockAuthAPI.login.mockResolvedValue({ success: true, data: mockLoginResponse });
    mockAuthAPI.register.mockResolvedValue({ success: true, data: { message: 'Registration successful' } });
    mockAuthAPI.logout.mockResolvedValue({ success: true, data: { message: 'Logged out' } });
    mockAuthAPI.refreshToken.mockResolvedValue({ success: true, data: mockTokens });
    mockAuthAPI.getCurrentUser.mockResolvedValue({ success: true, data: mockUser });
    mockAuthAPI.getUserPermissions.mockResolvedValue({ success: true, data: ['read:users', 'write:posts'] });
    mockAuthAPI.getUserRoles.mockResolvedValue({ success: true, data: ['user', 'editor'] });

    // Mock window
    global.window = mockWindow as Window & typeof globalThis;

    // Reset the store to initial state
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
      requiresPasswordChange: false,
    });
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe('Initial State', () => {
    it('has correct initial state', () => {
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

    it('provides all required action methods', () => {
      const { result } = renderHook(() => useAuthStore());

      expect(typeof result.current.initialize).toBe('function');
      expect(typeof result.current.login).toBe('function');
      expect(typeof result.current.register).toBe('function');
      expect(typeof result.current.logout).toBe('function');
      expect(typeof result.current.refreshToken).toBe('function');
      expect(typeof result.current.updateUser).toBe('function');
      expect(typeof result.current.hasPermission).toBe('function');
      expect(typeof result.current.hasRole).toBe('function');
      expect(typeof result.current.hasAnyRole).toBe('function');
      expect(typeof result.current.hasAllPermissions).toBe('function');
    });
  });

  describe('Initialization', () => {
    it('initializes with no stored tokens', async () => {
      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.initialize();
      });

      expect(result.current.isInitialized).toBe(true);
      expect(result.current.isLoading).toBe(false);
      expect(result.current.isAuthenticated).toBe(false);
      expect(mockCookieManager.getAuthTokens).toHaveBeenCalled();
    });

    it('initializes with valid stored tokens', async () => {
      mockCookieManager.getAuthTokens.mockReturnValue(mockTokens);
      mockCookieManager.getCookie.mockReturnValue(mockTokens.access_token);
      mockCookieManager.isTokenExpired.mockReturnValue(false);

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.initialize();
      });

      expect(result.current.isAuthenticated).toBe(true);
      expect(result.current.tokens).toEqual(mockTokens);
      expect(mockAuthAPI.getCurrentUser).toHaveBeenCalled();
      expect(mockAuthAPI.getUserPermissions).toHaveBeenCalled();
    });

    it('refreshes expired tokens during initialization', async () => {
      mockCookieManager.getAuthTokens.mockReturnValue(mockTokens);
      mockCookieManager.getCookie.mockReturnValue(mockTokens.access_token);
      mockCookieManager.isTokenExpired.mockReturnValue(true);

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.initialize();
      });

      expect(mockAuthAPI.refreshToken).toHaveBeenCalledWith({
        refresh_token: mockTokens.refresh_token,
      });
    });

    it('clears auth data when token refresh fails during initialization', async () => {
      mockCookieManager.getAuthTokens.mockReturnValue(mockTokens);
      mockCookieManager.getCookie.mockReturnValue(mockTokens.access_token);
      mockCookieManager.isTokenExpired.mockReturnValue(true);
      mockAuthAPI.refreshToken.mockResolvedValue({ success: false });

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.initialize();
      });

      expect(result.current.isAuthenticated).toBe(false);
      expect(mockCookieManager.clearAuthCookies).toHaveBeenCalled();
    });

    it('handles errors during initialization gracefully', async () => {
      mockCookieManager.getAuthTokens.mockReturnValue(mockTokens);
      mockAuthAPI.getCurrentUser.mockRejectedValue(new Error('Network error'));

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.initialize();
      });

      expect(result.current.isInitialized).toBe(true);
      expect(result.current.isAuthenticated).toBe(false);
    });
  });

  describe('Login', () => {
    it('handles successful login', async () => {
      const { result } = renderHook(() => useAuthStore());
      const credentials: LoginRequest = {
        email: 'test@example.com',
        password: 'password123',
      };

      let response: ApiResponse<LoginResponse>;
      await act(async () => {
        response = await result.current.login(credentials);
      });

      expect(response!.success).toBe(true);
      expect(result.current.isAuthenticated).toBe(true);
      expect(result.current.user).toEqual(mockUser);
      expect(result.current.tokens).toEqual(mockTokens);
      expect(result.current.accessToken).toBe(mockTokens.access_token);
      expect(mockCookieManager.storeAuthTokens).toHaveBeenCalledWith(mockTokens);
      expect(mockAuthAPI.getUserPermissions).toHaveBeenCalled();
    });

    it('handles login failure', async () => {
      const errorResponse: ApiResponse<LoginResponse> = {
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      };

      mockAuthAPI.login.mockResolvedValue(errorResponse);

      const { result } = renderHook(() => useAuthStore());
      const credentials: LoginRequest = {
        email: 'test@example.com',
        password: 'wrongpassword',
      };

      let response: ApiResponse<LoginResponse>;
      await act(async () => {
        response = await result.current.login(credentials);
      });

      expect(response!.success).toBe(false);
      expect(result.current.isAuthenticated).toBe(false);
      expect(result.current.error).toEqual({
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
        timestamp: expect.any(Date),
      });
    });

    it('handles login with 2FA requirement', async () => {
      const twoFactorResponse: LoginResponse = {
        ...mockLoginResponse,
        requires_2fa: true,
        temp_token: 'temp-token-123',
      };

      mockAuthAPI.login.mockResolvedValue({ success: true, data: twoFactorResponse });

      const { result } = renderHook(() => useAuthStore());
      const credentials: LoginRequest = {
        email: 'test@example.com',
        password: 'password123',
      };

      let response: ApiResponse<LoginResponse>;
      await act(async () => {
        response = await result.current.login(credentials);
      });

      expect(response!.success).toBe(true);
      expect(response!.data?.requires_2fa).toBe(true);
      expect(response!.data?.temp_token).toBe('temp-token-123');
    });

    it('handles network errors during login', async () => {
      mockAuthAPI.login.mockRejectedValue(new Error('Network error'));

      const { result } = renderHook(() => useAuthStore());
      const credentials: LoginRequest = {
        email: 'test@example.com',
        password: 'password123',
      };

      await act(async () => {
        try {
          await result.current.login(credentials);
        } catch (error) {
          expect(error).toBeInstanceOf(Error);
        }
      });

      expect(result.current.isAuthenticated).toBe(false);
      expect(result.current.error?.code).toBe('LOGIN_ERROR');
    });

    it('sets loading state during login', async () => {
      let resolveLogin: (value: ApiResponse<LoginResponse>) => void;
      const loginPromise = new Promise<ApiResponse<LoginResponse>>((resolve) => {
        resolveLogin = resolve;
      });

      mockAuthAPI.login.mockReturnValue(loginPromise);

      const { result } = renderHook(() => useAuthStore());
      const credentials: LoginRequest = {
        email: 'test@example.com',
        password: 'password123',
      };

      act(() => {
        result.current.login(credentials);
      });

      expect(result.current.isLoading).toBe(true);

      await act(async () => {
        resolveLogin!({ success: true, data: mockLoginResponse });
        await loginPromise;
      });

      expect(result.current.isLoading).toBe(false);
    });
  });

  describe('Registration', () => {
    it('handles successful registration', async () => {
      const { result } = renderHook(() => useAuthStore());
      const userData: RegisterRequest = {
        email: 'test@example.com',
        password: 'password123',
        full_name: 'Test User',
        agree_to_terms: true,
      };

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.register(userData);
      });

      expect(response!.success).toBe(true);
      expect(response!.data?.message).toBe('Registration successful');
      expect(mockAuthAPI.register).toHaveBeenCalledWith(userData);
    });

    it('handles registration failure', async () => {
      const errorResponse: ApiResponse<{ message: string }> = {
        success: false,
        error: {
          code: 'EMAIL_EXISTS',
          message: 'Email already registered',
        },
      };

      mockAuthAPI.register.mockResolvedValue(errorResponse);

      const { result } = renderHook(() => useAuthStore());
      const userData: RegisterRequest = {
        email: 'existing@example.com',
        password: 'password123',
        full_name: 'Test User',
        agree_to_terms: true,
      };

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.register(userData);
      });

      expect(response!.success).toBe(false);
      expect(result.current.error?.code).toBe('EMAIL_EXISTS');
    });

    it('handles network errors during registration', async () => {
      mockAuthAPI.register.mockRejectedValue(new Error('Network error'));

      const { result } = renderHook(() => useAuthStore());
      const userData: RegisterRequest = {
        email: 'test@example.com',
        password: 'password123',
        full_name: 'Test User',
        agree_to_terms: true,
      };

      await act(async () => {
        try {
          await result.current.register(userData);
        } catch (error) {
          expect(error).toBeInstanceOf(Error);
        }
      });

      expect(result.current.error?.code).toBe('REGISTRATION_ERROR');
    });
  });

  describe('Logout', () => {
    it('handles successful logout', async () => {
      // Set initial authenticated state
      useAuthStore.setState({
        user: mockUser,
        tokens: mockTokens,
        accessToken: mockTokens.access_token,
        isAuthenticated: true,
        session: mockSessionInfo,
      });

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.logout();
      });

      expect(mockAuthAPI.logout).toHaveBeenCalled();
      expect(result.current.isAuthenticated).toBe(false);
      expect(result.current.user).toBeNull();
      expect(result.current.tokens).toBeNull();
      expect(result.current.session).toBeNull();
      expect(mockCookieManager.clearAuthCookies).toHaveBeenCalled();
      expect(window.location.href).toBe('/auth/login');
    });

    it('handles logout even when API call fails', async () => {
      mockAuthAPI.logout.mockRejectedValue(new Error('Server error'));

      useAuthStore.setState({
        user: mockUser,
        isAuthenticated: true,
      });

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.logout();
      });

      expect(result.current.isAuthenticated).toBe(false);
      expect(mockCookieManager.clearAuthCookies).toHaveBeenCalled();
    });
  });

  describe('Token Refresh', () => {
    it('refreshes tokens successfully', async () => {
      const newTokens: TokenPair = {
        access_token: 'new-access-token',
        refresh_token: 'new-refresh-token',
        token_type: 'bearer',
        expires_in: 3600,
      };

      useAuthStore.setState({
        tokens: mockTokens,
        isAuthenticated: true,
      });

      mockAuthAPI.refreshToken.mockResolvedValue({ success: true, data: newTokens });

      const { result } = renderHook(() => useAuthStore());

      let refreshResult: boolean;
      await act(async () => {
        refreshResult = await result.current.refreshToken();
      });

      expect(refreshResult!).toBe(true);
      expect(result.current.tokens).toEqual(newTokens);
      expect(result.current.accessToken).toBe(newTokens.access_token);
      expect(mockCookieManager.storeAuthTokens).toHaveBeenCalledWith(newTokens);
    });

    it('handles token refresh failure', async () => {
      useAuthStore.setState({
        tokens: mockTokens,
        isAuthenticated: true,
      });

      mockAuthAPI.refreshToken.mockResolvedValue({ success: false });

      const { result } = renderHook(() => useAuthStore());

      let refreshResult: boolean;
      await act(async () => {
        refreshResult = await result.current.refreshToken();
      });

      expect(refreshResult!).toBe(false);
      expect(result.current.isAuthenticated).toBe(false);
      expect(mockCookieManager.clearAuthCookies).toHaveBeenCalled();
    });

    it('returns false when no refresh token available', async () => {
      useAuthStore.setState({
        tokens: null,
        isAuthenticated: false,
      });

      const { result } = renderHook(() => useAuthStore());

      let refreshResult: boolean;
      await act(async () => {
        refreshResult = await result.current.refreshToken();
      });

      expect(refreshResult!).toBe(false);
      expect(mockAuthAPI.refreshToken).not.toHaveBeenCalled();
    });

    it('handles refresh token network errors', async () => {
      useAuthStore.setState({
        tokens: mockTokens,
        isAuthenticated: true,
      });

      mockAuthAPI.refreshToken.mockRejectedValue(new Error('Network error'));

      const { result } = renderHook(() => useAuthStore());

      let refreshResult: boolean;
      await act(async () => {
        refreshResult = await result.current.refreshToken();
      });

      expect(refreshResult!).toBe(false);
      expect(result.current.isAuthenticated).toBe(false);
    });
  });

  describe('User Updates', () => {
    it('updates user data', () => {
      useAuthStore.setState({
        user: mockUser,
        isAuthenticated: true,
      });

      const { result } = renderHook(() => useAuthStore());

      const updateData: Partial<User> = {
        full_name: 'Updated Name',
        email_verified: true,
      };

      act(() => {
        result.current.updateUser(updateData);
      });

      expect(result.current.user?.full_name).toBe('Updated Name');
      expect(result.current.user?.email_verified).toBe(true);
      expect(result.current.user?.email).toBe(mockUser.email); // Unchanged
    });

    it('does nothing when no user is set', () => {
      const { result } = renderHook(() => useAuthStore());

      const updateData: Partial<User> = {
        full_name: 'Updated Name',
      };

      act(() => {
        result.current.updateUser(updateData);
      });

      expect(result.current.user).toBeNull();
    });
  });

  describe('Permission Checks', () => {
    beforeEach(() => {
      useAuthStore.setState({
        permissions: ['read:users', 'write:posts', 'admin:*'],
      });
    });

    it('checks exact permission match', () => {
      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasPermission('read:users')).toBe(true);
      expect(result.current.hasPermission('write:posts')).toBe(true);
      expect(result.current.hasPermission('delete:users')).toBe(false);
    });

    it('checks wildcard permissions', () => {
      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasPermission('admin:dashboard')).toBe(true);
      expect(result.current.hasPermission('admin:settings')).toBe(true);
      expect(result.current.hasPermission('user:profile')).toBe(false);
    });

    it('returns false when no permissions set', () => {
      useAuthStore.setState({
        permissions: [],
      });

      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasPermission('read:users')).toBe(false);
    });

    it('checks multiple permissions', () => {
      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasAllPermissions(['read:users', 'write:posts'])).toBe(true);
      expect(result.current.hasAllPermissions(['read:users', 'delete:users'])).toBe(false);
      expect(result.current.hasAllPermissions(['admin:dashboard', 'admin:settings'])).toBe(true);
    });
  });

  describe('Role Checks', () => {
    beforeEach(() => {
      useAuthStore.setState({
        roles: ['user', 'editor', 'moderator'],
      });
    });

    it('checks single role', () => {
      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasRole('user')).toBe(true);
      expect(result.current.hasRole('editor')).toBe(true);
      expect(result.current.hasRole('admin')).toBe(false);
    });

    it('checks any role from array', () => {
      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasAnyRole(['admin', 'moderator'])).toBe(true);
      expect(result.current.hasAnyRole(['admin', 'superuser'])).toBe(false);
      expect(result.current.hasAnyRole(['user', 'guest'])).toBe(true);
    });

    it('returns false when no roles set', () => {
      useAuthStore.setState({
        roles: [],
      });

      const { result } = renderHook(() => useAuthStore());

      expect(result.current.hasRole('user')).toBe(false);
      expect(result.current.hasAnyRole(['user', 'admin'])).toBe(false);
    });
  });

  describe('Error Management', () => {
    it('sets and clears errors', () => {
      const { result } = renderHook(() => useAuthStore());

      const error: AuthError = {
        code: 'TEST_ERROR',
        message: 'Test error message',
        timestamp: new Date(),
      };

      act(() => {
        result.current.setError(error);
      });

      expect(result.current.error).toEqual(error);
      expect(result.current.authErrors).toContain(error);

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBeNull();
      expect(result.current.authErrors).toContain(error); // Persists in history
    });

    it('adds multiple errors to history', () => {
      const { result } = renderHook(() => useAuthStore());

      const error1: AuthError = {
        code: 'ERROR_1',
        message: 'First error',
        timestamp: new Date(),
      };

      const error2: AuthError = {
        code: 'ERROR_2',
        message: 'Second error',
        timestamp: new Date(),
      };

      act(() => {
        result.current.addAuthError(error1);
        result.current.addAuthError(error2);
      });

      expect(result.current.authErrors).toHaveLength(2);
      expect(result.current.authErrors).toContain(error1);
      expect(result.current.authErrors).toContain(error2);
    });

    it('limits error history to 10 items', () => {
      const { result } = renderHook(() => useAuthStore());

      // Add 12 errors
      for (let i = 0; i < 12; i++) {
        const error: AuthError = {
          code: `ERROR_${i}`,
          message: `Error ${i}`,
          timestamp: new Date(),
        };

        act(() => {
          result.current.addAuthError(error);
        });
      }

      expect(result.current.authErrors).toHaveLength(10);
      expect(result.current.authErrors[0].code).toBe('ERROR_2'); // First two removed
    });

    it('clears all auth errors', () => {
      const { result } = renderHook(() => useAuthStore());

      const error: AuthError = {
        code: 'TEST_ERROR',
        message: 'Test error',
        timestamp: new Date(),
      };

      act(() => {
        result.current.addAuthError(error);
      });

      expect(result.current.authErrors).toHaveLength(1);

      act(() => {
        result.current.clearAuthErrors();
      });

      expect(result.current.authErrors).toHaveLength(0);
    });
  });

  describe('Session Management', () => {
    it('updates session information', () => {
      const { result } = renderHook(() => useAuthStore());

      const sessionUpdate: Partial<SessionInfo> = {
        lastActivity: new Date('2024-01-01T01:00:00Z'),
        device: 'Mobile Safari',
      };

      act(() => {
        result.current.updateSession(sessionUpdate);
      });

      expect(result.current.session?.lastActivity).toEqual(sessionUpdate.lastActivity);
      expect(result.current.session?.device).toBe(sessionUpdate.device);
      expect(result.current.session?.loginTime).toEqual(expect.any(Date));
    });

    it('creates new session when none exists', () => {
      const { result } = renderHook(() => useAuthStore());

      const sessionUpdate: Partial<SessionInfo> = {
        device: 'Chrome Browser',
        ipAddress: '192.168.1.100',
      };

      act(() => {
        result.current.updateSession(sessionUpdate);
      });

      expect(result.current.session?.device).toBe(sessionUpdate.device);
      expect(result.current.session?.ipAddress).toBe(sessionUpdate.ipAddress);
      expect(result.current.session?.loginTime).toEqual(expect.any(Date));
      expect(result.current.session?.lastActivity).toEqual(expect.any(Date));
    });

    it('checks session validity', async () => {
      useAuthStore.setState({
        isAuthenticated: true,
        tokens: mockTokens,
      });

      mockCookieManager.getCookie.mockReturnValue(mockTokens.access_token);
      mockCookieManager.isTokenExpired.mockReturnValue(false);

      const { result } = renderHook(() => useAuthStore());

      let sessionValid: boolean;
      await act(async () => {
        sessionValid = await result.current.checkSession();
      });

      expect(sessionValid!).toBe(true);
      expect(result.current.session?.lastActivity).toEqual(expect.any(Date));
    });

    it('refreshes token during session check if expired', async () => {
      useAuthStore.setState({
        isAuthenticated: true,
        tokens: mockTokens,
      });

      mockCookieManager.getCookie.mockReturnValue(mockTokens.access_token);
      mockCookieManager.isTokenExpired.mockReturnValue(true);

      const { result } = renderHook(() => useAuthStore());

      let sessionValid: boolean;
      await act(async () => {
        sessionValid = await result.current.checkSession();
      });

      expect(mockAuthAPI.refreshToken).toHaveBeenCalled();
      expect(sessionValid!).toBe(true);
    });

    it('extends session', async () => {
      useAuthStore.setState({
        tokens: mockTokens,
      });

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.extendSession();
      });

      expect(mockAuthAPI.refreshToken).toHaveBeenCalled();
      expect(result.current.session?.lastActivity).toEqual(expect.any(Date));
    });
  });

  describe('Utility Actions', () => {
    it('fetches user data', async () => {
      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.fetchUserData();
      });

      expect(mockAuthAPI.getCurrentUser).toHaveBeenCalled();
      expect(result.current.user).toEqual(mockUser);
      expect(result.current.isEmailVerified).toBe(true);
    });

    it('handles user data fetch failure gracefully', async () => {
      mockAuthAPI.getCurrentUser.mockResolvedValue({ success: false });

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.fetchUserData();
      });

      expect(result.current.user).toBeNull();
    });

    it('fetches permissions and roles', async () => {
      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.fetchPermissions();
      });

      expect(mockAuthAPI.getUserPermissions).toHaveBeenCalled();
      expect(mockAuthAPI.getUserRoles).toHaveBeenCalled();
      expect(result.current.permissions).toEqual(['read:users', 'write:posts']);
      expect(result.current.roles).toEqual(['user', 'editor']);
    });

    it('handles permission fetch failures gracefully', async () => {
      mockAuthAPI.getUserPermissions.mockResolvedValue({ success: false });
      mockAuthAPI.getUserRoles.mockResolvedValue({ success: false });

      const { result } = renderHook(() => useAuthStore());

      await act(async () => {
        await result.current.fetchPermissions();
      });

      expect(result.current.permissions).toEqual([]);
      expect(result.current.roles).toEqual([]);
    });
  });

  describe('Token Refresh Timer', () => {
    it('sets up token refresh timer', async () => {
      useAuthStore.setState({
        tokens: mockTokens,
        isAuthenticated: true,
      });

      const { result } = renderHook(() => useAuthStore());

      act(() => {
        result.current.setupTokenRefresh();
      });

      // Advance time to trigger refresh
      act(() => {
        jest.advanceTimersByTime(55 * 60 * 1000); // 55 minutes (5 min before expiry)
      });

      await waitFor(() => {
        expect(mockAuthAPI.refreshToken).toHaveBeenCalled();
      });
    });

    it('clears existing timer before setting new one', () => {
      const clearTimeoutSpy = jest.spyOn(global, 'clearTimeout');

      useAuthStore.setState({
        tokens: mockTokens,
        isAuthenticated: true,
      });

      const { result } = renderHook(() => useAuthStore());

      // Set up timer twice
      act(() => {
        result.current.setupTokenRefresh();
        result.current.setupTokenRefresh();
      });

      expect(clearTimeoutSpy).toHaveBeenCalled();
    });

    it('does not set timer when no tokens available', () => {
      const setTimeoutSpy = jest.spyOn(global, 'setTimeout');

      useAuthStore.setState({
        tokens: null,
      });

      const { result } = renderHook(() => useAuthStore());

      act(() => {
        result.current.setupTokenRefresh();
      });

      expect(setTimeoutSpy).not.toHaveBeenCalled();
    });
  });

  describe('Password Management', () => {
    it('changes password successfully', async () => {
      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.changePassword('oldpass', 'newpass');
      });

      expect(mockAuthAPI.changePassword).toHaveBeenCalledWith({
        current_password: 'oldpass',
        new_password: 'newpass',
      });
      expect(response!.success).toBe(true);
    });

    it('requests password reset', async () => {
      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.requestPasswordReset('test@example.com');
      });

      expect(mockAuthAPI.requestPasswordReset).toHaveBeenCalledWith({
        email: 'test@example.com',
      });
      expect(response!.success).toBe(true);
    });

    it('confirms password reset', async () => {
      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.confirmPasswordReset('reset-token', 'newpassword');
      });

      expect(mockAuthAPI.confirmPasswordReset).toHaveBeenCalledWith({
        token: 'reset-token',
        new_password: 'newpassword',
      });
      expect(response!.success).toBe(true);
    });
  });

  describe('Email Verification', () => {
    it('verifies email with token', async () => {
      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.verifyEmail('verify-token');
      });

      expect(mockAuthAPI.verifyEmail).toHaveBeenCalledWith('verify-token');
      expect(response!.success).toBe(true);
    });

    it('resends verification email', async () => {
      useAuthStore.setState({
        user: mockUser,
      });

      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.resendVerification();
      });

      expect(mockAuthAPI.resendVerification).toHaveBeenCalledWith(mockUser.email);
      expect(response!.success).toBe(true);
    });

    it('handles resend verification when no user email', async () => {
      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ message: string }>;
      await act(async () => {
        response = await result.current.resendVerification();
      });

      expect(response!.success).toBe(false);
      expect(response!.error?.code).toBe('NO_EMAIL');
    });
  });

  describe('Two-Factor Authentication', () => {
    it('sets up 2FA', async () => {
      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ qr_code: string; backup_codes: string[] }>;
      await act(async () => {
        response = await result.current.setup2FA();
      });

      expect(mockAuthAPI.setup2FA).toHaveBeenCalled();
      expect(result.current.is2FAEnabled).toBe(true);
    });

    it('verifies 2FA code', async () => {
      mockAuthAPI.verify2FA.mockResolvedValue({
        success: true,
        data: { access_token: 'token', refresh_token: 'refresh', token_type: 'bearer', expires_in: 3600 },
      });

      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ enabled: boolean; message: string }>;
      await act(async () => {
        response = await result.current.verify2FA('123456');
      });

      expect(mockAuthAPI.verify2FA).toHaveBeenCalledWith('123456', '');
      expect(response!.success).toBe(true);
      expect(response!.data?.enabled).toBe(true);
    });

    it('disables 2FA', async () => {
      useAuthStore.setState({
        is2FAEnabled: true,
      });

      const { result } = renderHook(() => useAuthStore());

      let response: ApiResponse<{ enabled: boolean; message: string }>;
      await act(async () => {
        response = await result.current.disable2FA('123456');
      });

      expect(mockAuthAPI.disable2FA).toHaveBeenCalledWith('123456');
      expect(response!.success).toBe(true);
      expect(result.current.is2FAEnabled).toBe(false);
    });
  });

  describe('Clear Auth Data', () => {
    it('clears all authentication data', () => {
      const clearTimeoutSpy = jest.spyOn(global, 'clearTimeout');

      useAuthStore.setState({
        user: mockUser,
        tokens: mockTokens,
        accessToken: mockTokens.access_token,
        isAuthenticated: true,
        permissions: ['read:users'],
        roles: ['user'],
        session: mockSessionInfo,
        isEmailVerified: true,
        is2FAEnabled: true,
      });

      const { result } = renderHook(() => useAuthStore());

      act(() => {
        result.current.clearAuthData();
      });

      expect(clearTimeoutSpy).toHaveBeenCalled();
      expect(mockCookieManager.clearAuthCookies).toHaveBeenCalled();
      expect(result.current.user).toBeNull();
      expect(result.current.tokens).toBeNull();
      expect(result.current.accessToken).toBeNull();
      expect(result.current.isAuthenticated).toBe(false);
      expect(result.current.permissions).toEqual([]);
      expect(result.current.roles).toEqual([]);
      expect(result.current.session).toBeNull();
      expect(result.current.isEmailVerified).toBe(false);
      expect(result.current.is2FAEnabled).toBe(false);
    });
  });

  describe('setAuth Method', () => {
    it('sets authentication data correctly', () => {
      const { result } = renderHook(() => useAuthStore());

      const userData = {
        id: 'new-user-id',
        email: 'new@example.com',
        name: 'New User',
        is_active: true,
        email_verified: true,
      };

      act(() => {
        result.current.setAuth('new-access-token', 'new-refresh-token', userData);
      });

      expect(result.current.isAuthenticated).toBe(true);
      expect(result.current.accessToken).toBe('new-access-token');
      expect(result.current.user?.email).toBe('new@example.com');
      expect(result.current.tokens?.access_token).toBe('new-access-token');
      expect(mockCookieManager.storeAuthTokens).toHaveBeenCalled();
    });
  });
});