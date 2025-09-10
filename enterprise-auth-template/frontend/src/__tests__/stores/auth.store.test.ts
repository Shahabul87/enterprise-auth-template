/**
 * @jest-environment jsdom
 */
import { renderHook, act } from '@testing-library/react';
import { useAuthStore } from '@/stores/auth.store';
import { AuthAPI } from '@/lib/auth-api';
import * as cookieManager from '@/lib/cookie-manager';

// Mock dependencies
jest.mock('@/lib/auth-api', () => ({
  AuthAPI: {
    login: jest.fn(),
    register: jest.fn(),
    logout: jest.fn(),
    refreshToken: jest.fn(),
    getCurrentUser: jest.fn(),
    requestPasswordReset: jest.fn(),
    confirmPasswordReset: jest.fn(),
    verifyEmail: jest.fn(),
    resendVerification: jest.fn(),
  },
}));

jest.mock('@/lib/cookie-manager', () => ({
  cookieManager: {
    storeAuthTokens: jest.fn(),
    getAccessToken: jest.fn(),
    getAuthTokens: jest.fn(),
    clearAuthCookies: jest.fn(),
    isAuthenticated: jest.fn(),
  },
}));

// Mock Next.js router
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
}));

const mockAuthAPI = AuthAPI as jest.Mocked<typeof AuthAPI>;
const mockCookieManager = cookieManager as jest.Mocked<typeof cookieManager>;

describe('useAuthStore', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset the store state before each test
    useAuthStore.setState({
      user: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,
    });
  });

  it('should have initial state', () => {
    const { result } = renderHook(() => useAuthStore());

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it('should handle successful login', async () => {
    const mockUser = {
      id: '1',
      email: 'test@example.com',
      first_name: 'Test',
      last_name: 'User',
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
        password: 'password123',
      });

      expect(response.success).toBe(true);
    });

    expect(result.current.user).toEqual(mockUser);
    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(mockCookieManager.storeAuthTokens).toHaveBeenCalledWith('access-token', 'refresh-token');
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
        password: 'wrong-password',
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
        password: 'password123',
      });

      expect(response.success).toBe(false);
      expect(response.error?.message).toBe('An error occurred during login');
    });

    expect(result.current.user).toBeNull();
    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.isLoading).toBe(false);
  });

  it('should handle successful registration', async () => {
    const mockUser = {
      id: '1',
      email: 'test@example.com',
      first_name: 'Test',
      last_name: 'User',
      is_active: true,
      is_verified: false,
      is_superuser: false,
      failed_login_attempts: 0,
      last_login: null,
      user_metadata: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      roles: [],
      permissions: [],
    };

    const mockResponse = {
      success: true,
      data: mockUser,
    };

    mockAuthAPI.register.mockResolvedValue(mockResponse);

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      const response = await result.current.register({
        email: 'test@example.com',
        password: 'password123',
        confirm_password: 'password123',
        first_name: 'Test',
        last_name: 'User',
        agree_to_terms: true,
      });

      expect(response.success).toBe(true);
    });

    expect(result.current.user).toEqual(mockUser);
    expect(result.current.isAuthenticated).toBe(true);
  });

  it('should handle logout', async () => {
    // Set initial authenticated state
    useAuthStore.setState({
      user: {
        id: '1',
        email: 'test@example.com',
        first_name: 'Test',
        last_name: 'User',
        is_active: true,
        is_verified: true,
        is_superuser: false,
        failed_login_attempts: 0,
        last_login: new Date().toISOString(),
        user_metadata: {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        roles: [],
      },
      isAuthenticated: true,
      isLoading: false,
      error: null,
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
    mockCookieManager.getAuthTokens = jest.fn().mockReturnValue({ refreshToken: 'old-refresh-token' });
    mockCookieManager.storeAuthTokens.mockImplementation(() => {});

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      const response = await result.current.refreshToken();
      expect(response).toBe(true);
    });

    expect(mockCookieManager.storeAuthTokens).toHaveBeenCalledWith('new-access-token', 'new-refresh-token');
  });

  it('should handle failed token refresh', async () => {
    mockAuthAPI.refreshToken.mockResolvedValue({
      success: false,
      error: { code: 'INVALID_TOKEN', message: 'Token expired' },
    });
    mockCookieManager.getAuthTokens = jest.fn().mockReturnValue({ refreshToken: 'expired-refresh-token' });

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
      first_name: 'Test',
      last_name: 'User',
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
    };

    mockCookieManager.hasAuthCookies = jest.fn().mockReturnValue(true);
    mockAuthAPI.getCurrentUser.mockResolvedValue({
      success: true,
      data: mockUser,
    });

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      await result.current.initialize();
    });

    expect(result.current.user).toEqual(mockUser);
    expect(result.current.isAuthenticated).toBe(true);
  });

  it('should handle forgot password', async () => {
    mockAuthAPI.requestPasswordReset.mockResolvedValue({
      success: true,
      data: { message: 'Password reset email sent' },
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
      data: { message: 'Password reset successfully' },
    });

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      const response = await result.current.confirmPasswordReset('reset-token', 'newpassword123');
      expect(response.success).toBe(true);
    });

    expect(mockAuthAPI.confirmPasswordReset).toHaveBeenCalledWith('reset-token', 'newpassword123');
  });

  it('should handle email verification', async () => {
    mockAuthAPI.verifyEmail.mockResolvedValue({
      success: true,
      data: { message: 'Email verified successfully' },
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
      data: { message: 'Verification email sent' },
    });

    const { result } = renderHook(() => useAuthStore());

    await act(async () => {
      const response = await result.current.resendVerification();
      expect(response.success).toBe(true);
    });

    expect(mockAuthAPI.resendVerification).toHaveBeenCalled();
  });

  it('should set and clear errors', () => {
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

  // Note: setLoading is not exposed as a public method - loading state is managed internally

  it('should update user profile', async () => {
    const initialUser = {
      id: '1',
      email: 'test@example.com',
      first_name: 'Test',
      last_name: 'User',
      is_active: true,
      is_verified: true,
      is_superuser: false,
      failed_login_attempts: 0,
      last_login: new Date().toISOString(),
      user_metadata: {},
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      roles: [],
    };

    const updatedUser = {
      ...initialUser,
      name: 'Updated User',
      email: 'updated@example.com',
    };

    useAuthStore.setState({
      user: initialUser,
      isAuthenticated: true,
    });

    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.updateUser(updatedUser);
    });

    expect(result.current.user).toEqual(updatedUser);
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
          first_name: 'Test',
          last_name: 'User',
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