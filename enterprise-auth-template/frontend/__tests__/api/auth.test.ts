/**
 * Authentication API Tests
 *
 * Comprehensive tests for the authentication API client
 * including login, registration, token management, and error handling.
 */

import AuthAPI from '@/lib/auth-api';
import { User, TokenPair, LoginRequest, RegisterRequest, ApiResponse } from '@/types';

// Mock fetch globally
global.fetch = jest.fn();
const mockFetch = fetch as jest.MockedFunction<typeof fetch>;

// Mock cookie manager
jest.mock('@/lib/cookie-manager', () => ({
  storeAuthTokens: jest.fn(),
  getAuthTokens: jest.fn(),
  clearAuthCookies: jest.fn(),
  getCookie: jest.fn(),
}));

describe('AuthAPI', () => {
  const mockUser: User = {
    id: 'test-user-id',
    email: 'test@example.com',
    first_name: 'Test',
    last_name: 'User',
    is_active: true,
    is_verified: true,
    is_superuser: false,
    failed_login_attempts: 0,
    user_metadata: {},
    roles: [],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    last_login: new Date().toISOString(),
  };

  const mockTokens: TokenPair = {
    access_token: 'mock-access-token',
    refresh_token: 'mock-refresh-token',
    token_type: 'bearer',
    expires_in: 3600,
  };

  beforeEach(() => {
    mockFetch.mockClear();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Login', () => {
    it('should successfully login user', async () => {
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'SecurePassword123!',
      };

      const mockResponse: ApiResponse<TokenPair> = {
        success: true,
        data: mockTokens,
        metadata: {
          timestamp: new Date().toISOString(),
          requestId: 'req-123',
          version: '1.0.0',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.login(loginRequest);

      expect(fetch).toHaveBeenCalledWith('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(loginRequest),
      });

      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockTokens);
    });

    it('should handle login failure with invalid credentials', async () => {
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'WrongPassword',
      };

      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.login(loginRequest);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('INVALID_CREDENTIALS');
      expect(result.error?.message).toBe('Invalid email or password');
    });

    it('should handle network error during login', async () => {
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'SecurePassword123!',
      };

      mockFetch.mockRejectedValueOnce(new Error('Network error'));

      const result = await AuthAPI.login(loginRequest);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('NETWORK_ERROR');
      expect(result.error?.message).toContain('Network error');
    });

    it('should handle rate limiting during login', async () => {
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'SecurePassword123!',
      };

      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'RATE_LIMITED',
          message: 'Too many login attempts. Please try again later.',
          details: {
            retryAfter: 300,
          },
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 429,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.login(loginRequest);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('RATE_LIMITED');
      expect(result.error?.details?.['retryAfter']).toBe(300);
    });
  });

  describe('Register', () => {
    it('should successfully register user', async () => {
      const registerRequest: RegisterRequest = {
        email: 'new@example.com',
        password: 'SecurePassword123!',
        confirm_password: 'SecurePassword123!',
        first_name: 'New',
        last_name: 'User',
        agree_to_terms: true,
      };

      const mockResponse: ApiResponse<User> = {
        success: true,
        data: mockUser,
        metadata: {
          timestamp: new Date().toISOString(),
          requestId: 'req-124',
          version: '1.0.0',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 201,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.register(registerRequest);

      expect(fetch).toHaveBeenCalledWith('/api/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(registerRequest),
      });

      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockUser);
    });

    it('should handle registration failure with existing email', async () => {
      const registerRequest: RegisterRequest = {
        email: 'existing@example.com',
        password: 'SecurePassword123!',
        confirm_password: 'SecurePassword123!',
        first_name: 'New',
        last_name: 'User',
        agree_to_terms: true,
      };

      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'EMAIL_EXISTS',
          message: 'An account with this email already exists',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.register(registerRequest);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('EMAIL_EXISTS');
    });

    it('should handle validation errors during registration', async () => {
      const registerRequest: RegisterRequest = {
        email: 'invalid-email',
        password: '123',
        confirm_password: '456',
        first_name: '',
        last_name: '',
        agree_to_terms: false,
      };

      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid input data',
          details: {
            email: ['Invalid email format'],
            password: ['Password must be at least 8 characters'],
            confirm_password: ['Passwords do not match'],
            first_name: ['First name is required'],
            agree_to_terms: ['You must agree to the terms of service'],
          },
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 422,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.register(registerRequest);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('VALIDATION_ERROR');
      expect(result.error?.details?.['email']).toContain('Invalid email format');
    });
  });

  describe('Token Management', () => {
    it('should successfully refresh token', async () => {
      const newTokens: TokenPair = {
        ...mockTokens,
        access_token: 'new-access-token',
      };

      const mockResponse: ApiResponse<TokenPair> = {
        success: true,
        data: newTokens,
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.refreshToken({ refresh_token: 'mock-refresh-token' });

      expect(fetch).toHaveBeenCalledWith('/api/auth/refresh', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        credentials: 'include', // Include cookies for refresh token
      });

      expect(result.success).toBe(true);
      expect(result.data?.access_token).toBe('new-access-token');
    });

    it('should handle refresh token expiration', async () => {
      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'REFRESH_TOKEN_EXPIRED',
          message: 'Refresh token has expired. Please login again.',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.refreshToken({ refresh_token: 'mock-refresh-token' });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('REFRESH_TOKEN_EXPIRED');
    });

    it('should successfully logout user', async () => {
      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Successfully logged out' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.logout();

      expect(fetch).toHaveBeenCalledWith('/api/auth/logout', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: expect.stringContaining('Bearer'),
        },
        credentials: 'include',
      });

      expect(result.success).toBe(true);
      expect(result.data?.message).toBe('Successfully logged out');
    });
  });

  describe('User Management', () => {
    it('should successfully get current user', async () => {
      const mockResponse: ApiResponse<User> = {
        success: true,
        data: mockUser,
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.getCurrentUser();

      expect(fetch).toHaveBeenCalledWith('/api/auth/me', {
        method: 'GET',
        headers: {
          Authorization: expect.stringContaining('Bearer'),
        },
      });

      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockUser);
    });

    it('should handle unauthorized access to current user', async () => {
      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.getCurrentUser();

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('UNAUTHORIZED');
    });

    it('should successfully get user permissions', async () => {
      const permissions = ['users:read', 'posts:write', 'admin:*'];

      const mockResponse: ApiResponse<string[]> = {
        success: true,
        data: permissions,
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.getUserPermissions();

      expect(fetch).toHaveBeenCalledWith('/api/auth/permissions', {
        method: 'GET',
        headers: {
          Authorization: expect.stringContaining('Bearer'),
        },
      });

      expect(result.success).toBe(true);
      expect(result.data).toEqual(permissions);
    });

    it('should successfully update user profile', async () => {
      const updateData = {
        first_name: 'Updated',
        last_name: 'Name',
        user_metadata: { theme: 'dark' },
      };

      const updatedUser = {
        ...mockUser,
        ...updateData,
        updated_at: new Date().toISOString(),
      };

      const mockResponse: ApiResponse<User> = {
        success: true,
        data: updatedUser,
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.updateProfile(updateData);

      expect(fetch).toHaveBeenCalledWith('/api/auth/profile', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: expect.stringContaining('Bearer'),
        },
        body: JSON.stringify(updateData),
      });

      expect(result.success).toBe(true);
      expect(result.data?.first_name).toBe('Updated');
    });
  });

  describe('Password Management', () => {
    it('should successfully change password', async () => {
      const changePasswordData = {
        current_password: 'OldPassword123!',
        new_password: 'NewPassword123!',
        confirm_password: 'NewPassword123!',
      };

      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Password changed successfully' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.changePassword(changePasswordData);

      expect(fetch).toHaveBeenCalledWith('/api/auth/change-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: expect.stringContaining('Bearer'),
        },
        body: JSON.stringify(changePasswordData),
      });

      expect(result.success).toBe(true);
    });

    it('should handle incorrect current password', async () => {
      const changePasswordData = {
        current_password: 'WrongPassword',
        new_password: 'NewPassword123!',
        confirm_password: 'NewPassword123!',
      };

      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'INVALID_CURRENT_PASSWORD',
          message: 'Current password is incorrect',
        },
      };

      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
        json: async () => mockErrorResponse,
      } as Response);

      const result = await AuthAPI.changePassword(changePasswordData);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('INVALID_CURRENT_PASSWORD');
    });

    it('should successfully request password reset', async () => {
      const email = 'user@example.com';

      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Password reset email sent' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.requestPasswordReset({ email });

      expect(fetch).toHaveBeenCalledWith('/api/auth/forgot-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      expect(result.success).toBe(true);
    });

    it('should successfully reset password with token', async () => {
      const resetData = {
        token: 'reset-token-123',
        new_password: 'NewPassword123!',
        confirm_password: 'NewPassword123!',
      };

      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Password reset successfully' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.confirmPasswordReset(resetData);

      expect(fetch).toHaveBeenCalledWith('/api/auth/reset-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(resetData),
      });

      expect(result.success).toBe(true);
    });
  });

  describe('Email Verification', () => {
    it('should successfully verify email', async () => {
      const token = 'verification-token-123';

      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Email verified successfully' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.verifyEmail(token);

      expect(fetch).toHaveBeenCalledWith('/api/auth/verify-email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ token }),
      });

      expect(result.success).toBe(true);
    });

    it('should successfully resend verification email', async () => {
      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Verification email sent' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.resendVerification('test@example.com');

      expect(fetch).toHaveBeenCalledWith('/api/auth/resend-verification', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: expect.stringContaining('Bearer'),
        },
      });

      expect(result.success).toBe(true);
    });
  });

  describe('OAuth Integration', () => {
    it('should successfully initiate OAuth login', async () => {
      const provider = 'google';

      const mockResponse: ApiResponse<{ authorize_url: string }> = {
        success: true,
        data: { authorize_url: 'https://accounts.google.com/oauth/authorize?...' },
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.linkOAuthAccount(provider);

      expect(fetch).toHaveBeenCalledWith(`/api/auth/oauth/${provider}/login`, {
        method: 'GET',
      });

      expect(result.success).toBe(true);
      expect(result.data?.authorize_url).toContain('accounts.google.com');
    });

    it('should successfully handle OAuth callback', async () => {
      const provider = 'google';
      const code = 'oauth-code-123';
      const state = 'oauth-state-456';

      const mockResponse: ApiResponse<TokenPair> = {
        success: true,
        data: mockTokens,
      };

      mockFetch.mockResolvedValueOnce({
        ok: true,
        status: 200,
        json: async () => mockResponse,
      } as Response);

      const result = await AuthAPI.oauthCallback(provider, { code, state });

      expect(fetch).toHaveBeenCalledWith(`/api/auth/oauth/${provider}/callback`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ code, state }),
      });

      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockTokens);
    });
  });

  describe('Error Handling', () => {
    it('should handle server errors gracefully', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 500,
        json: async () => ({
          success: false,
          error: {
            code: 'INTERNAL_ERROR',
            message: 'Internal server error',
          },
        }),
      } as Response);

      const result = await AuthAPI.login({
        email: 'test@example.com',
        password: 'password',
      });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('INTERNAL_ERROR');
    });

    it('should handle non-JSON responses', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 502,
        json: async () => {
          throw new Error('Invalid JSON');
        },
        text: async () => 'Bad Gateway',
      } as unknown as Response);

      const result = await AuthAPI.login({
        email: 'test@example.com',
        password: 'password',
      });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('SERVER_ERROR');
    });

    it('should handle timeout errors', async () => {
      mockFetch.mockImplementationOnce(
        () => new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), 100))
      );

      const result = await AuthAPI.login({
        email: 'test@example.com',
        password: 'password',
      });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('NETWORK_ERROR');
    });
  });
});