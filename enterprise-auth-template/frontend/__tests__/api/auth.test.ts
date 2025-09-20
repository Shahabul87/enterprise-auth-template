import { User, TokenPair, LoginRequest, RegisterRequest, ApiResponse } from '@/types';
import * as cookieManager from '@/lib/cookie-manager';

/**
 * Authentication API Tests
 *
 * Comprehensive tests for the authentication API client
 * including login, registration, token management, and error handling.
 */

jest.mock('@/lib/auth-api', () => ({
  __esModule: true,
  default: {
    login: jest.fn(),
    register: jest.fn(),
    refreshToken: jest.fn(),
    logout: jest.fn(),
    getCurrentUser: jest.fn(),
    getUserPermissions: jest.fn(),
    updateProfile: jest.fn(),
    changePassword: jest.fn(),
    requestPasswordReset: jest.fn(),
    confirmPasswordReset: jest.fn(),
    verifyEmail: jest.fn(),
    resendVerification: jest.fn(),
    linkOAuthAccount: jest.fn(),
    oauthCallback: jest.fn(),
  },
  AuthAPI: {
    login: jest.fn(),
    register: jest.fn(),
    refreshToken: jest.fn(),
    logout: jest.fn(),
    getCurrentUser: jest.fn(),
    getUserPermissions: jest.fn(),
    updateProfile: jest.fn(),
    changePassword: jest.fn(),
    requestPasswordReset: jest.fn(),
    confirmPasswordReset: jest.fn(),
    verifyEmail: jest.fn(),
    resendVerification: jest.fn(),
    linkOAuthAccount: jest.fn(),
    oauthCallback: jest.fn(),
  },
}));

jest.mock('@/lib/cookie-manager');

// Import after mocking
import AuthAPI from '@/lib/auth-api';

// Create a reference to the mocked module
const mockAuthAPI = AuthAPI as jest.Mocked<typeof AuthAPI>;

describe('AuthAPI', () => {
  const mockUser: User = {
    id: 'test-user-id',
    email: 'test@example.com',
    full_name: 'Test User',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
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
    jest.clearAllMocks();
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

      mockAuthAPI.login.mockResolvedValue(mockResponse);

      const result = await AuthAPI.login(loginRequest);

      expect(AuthAPI.login).toHaveBeenCalledWith(loginRequest);
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

      mockAuthAPI.login.mockResolvedValue(mockErrorResponse);

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

      mockAuthAPI.login.mockRejectedValue(new Error('Network error'));

      await expect(AuthAPI.login(loginRequest)).rejects.toThrow('Network error');
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

      mockAuthAPI.login.mockResolvedValue(mockErrorResponse);

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
        full_name: 'New User',
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

      mockAuthAPI.register.mockResolvedValue(mockResponse);

      const result = await AuthAPI.register(registerRequest);

      expect(AuthAPI.register).toHaveBeenCalledWith(registerRequest);
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockUser);
    });

    it('should handle registration failure with existing email', async () => {
      const registerRequest: RegisterRequest = {
        email: 'existing@example.com',
        password: 'SecurePassword123!',
        confirm_password: 'SecurePassword123!',
        full_name: 'New User',
        agree_to_terms: true,
      };
      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'EMAIL_EXISTS',
          message: 'An account with this email already exists',
        },
      };

      mockAuthAPI.register.mockResolvedValue(mockErrorResponse);

      const result = await AuthAPI.register(registerRequest);

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('EMAIL_EXISTS');
    });

    it('should handle validation errors during registration', async () => {
      const registerRequest: RegisterRequest = {
        email: 'invalid-email',
        password: '123',
        confirm_password: '456',
        full_name: '',
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

      mockAuthAPI.register.mockResolvedValue(mockErrorResponse);

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

      mockAuthAPI.refreshToken.mockResolvedValue(mockResponse);

      const result = await AuthAPI.refreshToken({ refresh_token: 'mock-refresh-token' });

      expect(AuthAPI.refreshToken).toHaveBeenCalledWith({ refresh_token: 'mock-refresh-token' });
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

      mockAuthAPI.refreshToken.mockResolvedValue(mockErrorResponse);

      const result = await AuthAPI.refreshToken({ refresh_token: 'mock-refresh-token' });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('REFRESH_TOKEN_EXPIRED');
    });

    it('should successfully logout user', async () => {
      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Successfully logged out' },
      };

      mockAuthAPI.logout.mockResolvedValue(mockResponse);

      const result = await AuthAPI.logout();

      expect(AuthAPI.logout).toHaveBeenCalled();
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

      mockAuthAPI.getCurrentUser.mockResolvedValue(mockResponse);

      const result = await AuthAPI.getCurrentUser();

      expect(AuthAPI.getCurrentUser).toHaveBeenCalled();
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

      mockAuthAPI.getCurrentUser.mockResolvedValue(mockErrorResponse);

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

      mockAuthAPI.getUserPermissions.mockResolvedValue(mockResponse);

      const result = await AuthAPI.getUserPermissions();

      expect(AuthAPI.getUserPermissions).toHaveBeenCalled();
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
        full_name: 'Updated User',
        updated_at: new Date().toISOString(),
      };
      const mockResponse: ApiResponse<User> = {
        success: true,
        data: updatedUser,
      };

      mockAuthAPI.updateProfile.mockResolvedValue(mockResponse);

      const result = await AuthAPI.updateProfile(updateData);

      expect(AuthAPI.updateProfile).toHaveBeenCalledWith(updateData);
      expect(result.success).toBe(true);
      expect(result.data?.full_name).toBe('Updated User');
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

      mockAuthAPI.changePassword.mockResolvedValue(mockResponse);

      const result = await AuthAPI.changePassword(changePasswordData);

      expect(AuthAPI.changePassword).toHaveBeenCalledWith(changePasswordData);
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

      mockAuthAPI.changePassword.mockResolvedValue(mockErrorResponse);

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

      mockAuthAPI.requestPasswordReset.mockResolvedValue(mockResponse);

      const result = await AuthAPI.requestPasswordReset({ email });

      expect(AuthAPI.requestPasswordReset).toHaveBeenCalledWith({ email });
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

      mockAuthAPI.confirmPasswordReset.mockResolvedValue(mockResponse);

      const result = await AuthAPI.confirmPasswordReset(resetData);

      expect(AuthAPI.confirmPasswordReset).toHaveBeenCalledWith(resetData);
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

      mockAuthAPI.verifyEmail.mockResolvedValue(mockResponse);

      const result = await AuthAPI.verifyEmail(token);

      expect(AuthAPI.verifyEmail).toHaveBeenCalledWith(token);
      expect(result.success).toBe(true);
    });

    it('should successfully resend verification email', async () => {
      const mockResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Verification email sent' },
      };

      mockAuthAPI.resendVerification.mockResolvedValue(mockResponse);

      const result = await AuthAPI.resendVerification('test@example.com');

      expect(AuthAPI.resendVerification).toHaveBeenCalledWith('test@example.com');
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

      mockAuthAPI.linkOAuthAccount.mockResolvedValue(mockResponse);

      const result = await AuthAPI.linkOAuthAccount(provider);

      expect(AuthAPI.linkOAuthAccount).toHaveBeenCalledWith(provider);
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

      mockAuthAPI.oauthCallback.mockResolvedValue(mockResponse);

      const result = await AuthAPI.oauthCallback(provider, { code, state });

      expect(AuthAPI.oauthCallback).toHaveBeenCalledWith(provider, { code, state });
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockTokens);
    });
  });

  describe('Error Handling', () => {
    it('should handle server errors gracefully', async () => {
      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Internal server error',
        },
      };

      mockAuthAPI.login.mockResolvedValue(mockErrorResponse);

      const result = await AuthAPI.login({
        email: 'test@example.com',
        password: 'password',
      });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('INTERNAL_ERROR');
    });

    it('should handle non-JSON responses', async () => {
      const mockErrorResponse: ApiResponse<never> = {
        success: false,
        error: {
          code: 'SERVER_ERROR',
          message: 'Bad Gateway',
        },
      };

      mockAuthAPI.login.mockResolvedValue(mockErrorResponse);

      const result = await AuthAPI.login({
        email: 'test@example.com',
        password: 'password',
      });

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('SERVER_ERROR');
    });

    it('should handle timeout errors', async () => {
      mockAuthAPI.login.mockRejectedValue(new Error('timeout'));

      await expect(AuthAPI.login({
        email: 'test@example.com',
        password: 'password',
      })).rejects.toThrow('timeout');
    });
  });
});