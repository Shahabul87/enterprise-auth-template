
import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from '@/stores/auth.store';
import AuthAPI from '@/lib/auth-api';
import * as cookieManager from '@/lib/cookie-manager';

jest.mock('@/lib/auth-api', () => ({
  default: {
    login: jest.fn(),
    register: jest.fn(),
    logout: jest.fn(),
    refreshToken: jest.fn(),
    getCurrentUser: jest.fn(),
    requestPasswordReset: jest.fn(),
    confirmPasswordReset: jest.fn(),
    verifyEmail: jest.fn(),
    resendVerification: jest.fn(),
    setup2FA: jest.fn(),
    verify2FA: jest.fn(),
    disable2FA: jest.fn(),
  },
}));

jest.mock('@/lib/cookie-manager', () => ({
  storeAuthTokens: jest.fn(),
  getAccessToken: jest.fn(),
  getAuthTokens: jest.fn(),
  clearAuthCookies: jest.fn(),
  hasAuthCookies: jest.fn(),
  isTokenExpired: jest.fn(),
  getCookie: jest.fn(),
  AUTH_COOKIES: {
    ACCESS_TOKEN: 'access-token',
    REFRESH_TOKEN: 'refresh-token',
  },}));
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

// Mock AuthAPI
// Mock cookie manager
// Mock Next.js router


// Get the mocked functions for test assertions
const mockAuthAPI = require('@/lib/auth-api').default;
const mockCookieManager = require('@/lib/cookie-manager');
describe('useAuthStore', () => {
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
  it('should have initial state', async () => {
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
  it('should handle successful login', async () => {
    const mockUser = {
      id: '1',
      email: 'test@example.com',
      full_name: 'Test User',
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
    const mockResponse = {
      success: true,
      data: {
        access_token: 'access-token',
        refresh_token: 'refresh-token',
        token_type: 'Bearer',
        expires_in: 3600,
        user: mockUser,
      },
    };
    mockAuthAPI.login.mockResolvedValue(mockResponse);
    mockCookieManager.storeAuthTokens.mockImplementation(() => {});
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.login({
        email: 'test@example.com',
        password: 'password123'
      });
      expect(response.success).toBe(true);
    });
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user).toEqual(mockUser);
    expect(mockCookieManager.storeAuthTokens).toHaveBeenCalled();
  });
  it('should handle login failure', async () => {
    const mockError = {
      success: false,
      error: {
        code: 'INVALID_CREDENTIALS',
        message: 'Invalid email or password',
      },
    };
    mockAuthAPI.login.mockResolvedValue(mockError);
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.login({
        email: 'test@example.com',
        password: 'wrong-password'
      });
      expect(response.success).toBe(false);
      expect(response.error?.message).toBe('Invalid email or password');
    });
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });
  it('should handle login exception', async () => {
    mockAuthAPI.login.mockRejectedValue(new Error('Network error'));
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.login({
        email: 'test@example.com',
        password: 'password123'
      });
      expect(response.success).toBe(false);
      expect(response.error?.message).toBe('An error occurred during login');
    });
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });
  it('should handle successful registration', async () => {
    const mockResponse = {
      success: true,
      data: { message: 'Registration successful' },
    };
    mockAuthAPI.register.mockResolvedValue(mockResponse);
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.register({
        email: 'test@example.com',
        password: 'password123',
        confirm_password: 'password123',
        full_name: 'Test User',
        agree_to_terms: true
      });
      expect(response.success).toBe(true);
    });
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
    // Registration doesn't automatically authenticate - user needs to login
    expect(result.current.isAuthenticated).toBe(false);
  });
  it('should handle logout', async () => {
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
    useAuthStore.setState({
      user: mockUser,
      isAuthenticated: true,
      isLoading: false,
      error: null
    });
    mockAuthAPI.logout.mockResolvedValue({ success: true });
    mockCookieManager.clearAuthCookies.mockImplementation(() => {});
    const { result } = renderHook(() => useAuthStore());
    expect(result.current.isAuthenticated).toBe(true);
    await act(async () => {
      await result.current.logout();
    });
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.error).toBeNull();
    expect(mockCookieManager.clearAuthCookies).toHaveBeenCalled();
    expect(mockLocation.href).toBe('/auth/login');
  });
  it('should handle token refresh', async () => {
    const mockResponse = {
      success: true,
      data: {
        access_token: 'new-access-token',
        refresh_token: 'new-refresh-token',
        token_type: 'Bearer',
        expires_in: 3600,
      },
    };
    mockAuthAPI.refreshToken.mockResolvedValue(mockResponse);
    mockCookieManager.getAuthTokens.mockReturnValue({ refresh_token: 'old-refresh-token' });
    mockCookieManager.storeAuthTokens.mockImplementation(() => {});
    // Set initial state with tokens
    useAuthStore.setState({
      tokens: {
        access_token: 'old-access-token',
        refresh_token: 'old-refresh-token',
        token_type: 'Bearer',
        expires_in: 3600,
      },
      isAuthenticated: true
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.refreshToken();
      expect(response).toBe(true);
    });
    expect(mockCookieManager.storeAuthTokens).toHaveBeenCalled();
  });
  it('should handle failed token refresh', async () => {
    mockAuthAPI.refreshToken.mockResolvedValue({
      success: false,
      error: { code: 'INVALID_TOKEN', message: 'Token expired' }
    });
    mockCookieManager.getAuthTokens.mockReturnValue({ refresh_token: 'expired-refresh-token' });
    // Set initial state with tokens
    useAuthStore.setState({
      tokens: {
        access_token: 'old-access-token',
        refresh_token: 'expired-refresh-token',
        token_type: 'Bearer',
        expires_in: 3600,
      },
      isAuthenticated: true
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.refreshToken();
      expect(response).toBe(false);
    });
    // Should logout user when token refresh fails
    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
  });
  it('should initialize from token on mount', async () => {
    const mockUser = {
      id: '1',
      email: 'test@example.com',
      full_name: 'Test User',
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
    mockCookieManager.hasAuthCookies.mockReturnValue(true);
    mockCookieManager.getAuthTokens.mockReturnValue({
      access_token: 'valid-token',
      refresh_token: 'valid-refresh'
    });
    mockCookieManager.getCookie.mockReturnValue('valid-token');
    mockCookieManager.isTokenExpired.mockReturnValue(false);
    mockAuthAPI.getCurrentUser.mockResolvedValue({
      success: true,
      data: mockUser
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      await result.current.initialize();
    });
    expect(result.current.isLoading).toBe(false);
    // Initialization sets authenticated state based on valid tokens
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.user).toEqual(mockUser);
  });
  it('should handle forgot password', async () => {
    mockAuthAPI.requestPasswordReset.mockResolvedValue({
      success: true,
      data: { message: 'Password reset email sent' }
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.requestPasswordReset('test@example.com');
      expect(response.success).toBe(true);
    });
    expect(mockAuthAPI.requestPasswordReset).toHaveBeenCalledWith('test@example.com');
  });
  it('should handle reset password', async () => {
    mockAuthAPI.confirmPasswordReset.mockResolvedValue({
      success: true,
      data: { message: 'Password reset successfully' }
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.confirmPasswordReset('reset-token', 'newpassword123', 'newpassword123');
      expect(response.success).toBe(true);
    });
    expect(mockAuthAPI.confirmPasswordReset).toHaveBeenCalledWith('reset-token', 'newpassword123', 'newpassword123');
  });
  it('should handle email verification', async () => {
    mockAuthAPI.verifyEmail.mockResolvedValue({
      success: true,
      data: { message: 'Email verified successfully' }
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.verifyEmail('verify-token');
      expect(response.success).toBe(true);
    });
    expect(mockAuthAPI.verifyEmail).toHaveBeenCalledWith('verify-token');
  });
  it('should handle resend verification email', async () => {
    mockAuthAPI.resendVerification.mockResolvedValue({
      success: true,
      data: { message: 'Verification email sent' }
    });
    const { result } = renderHook(() => useAuthStore());
    await act(async () => {
      const response = await result.current.resendVerification();
      expect(response.success).toBe(true);
    });
    expect(mockAuthAPI.resendVerification).toHaveBeenCalled();
  });
  it('should set and clear errors', async () => {
    const { result } = renderHook(() => useAuthStore());
    act(() => {
      result.current.setError({ code: 'TEST_ERROR', message: 'Test error', timestamp: new Date() });
    });
    expect(result.current.error?.message).toBe('Test error');
    act(() => {
      result.current.clearError();
    });
    expect(result.current.error).toBeNull();
  });
  it('should update user profile', async () => {
    const initialUser = {
      id: '1',
      email: 'test@example.com',
      full_name: 'Test User',
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
    };
    useAuthStore.setState({
      user: initialUser,
      isAuthenticated: true
    });
    const { result } = renderHook(() => useAuthStore());
    act(() => {
      result.current.updateUser({
        full_name: 'Updated User',
        email: 'updated@example.com'
      });
    });
    expect(result.current.user).toMatchObject({
      full_name: 'Updated User',
      email: 'updated@example.com'
    });
  });
  it('should handle concurrent requests', async () => {
    const mockResponse = {
      success: true,
      data: {
        access_token: 'access-token',
        refresh_token: 'refresh-token',
        token_type: 'Bearer',
        expires_in: 3600,
        user: {
          id: '1',
          email: 'test@example.com',
          full_name: 'Test User',
          is_active: true,
          is_verified: true,
          is_superuser: false,
          failed_login_attempts: 0,
          last_login: new Date().toISOString(),
          user_metadata: {},
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
          roles: [],
          permissions: [],
        },
      },
    };
    mockAuthAPI.login.mockResolvedValue(mockResponse);
    const { result } = renderHook(() => useAuthStore());
    // Make multiple concurrent login requests
    await act(async () => {
      const promises = [
        result.current.login({ email: 'test1@example.com', password: 'pass1' }),
        result.current.login({ email: 'test2@example.com', password: 'pass2' }),
        result.current.login({ email: 'test3@example.com', password: 'pass3' }),
      ];
      await Promise.all(promises);
    });
    // Should handle concurrent requests without issues
    expect(result.current.isAuthenticated).toBe(true);
    expect(mockAuthAPI.login).toHaveBeenCalledTimes(3);
  });
});
}}}