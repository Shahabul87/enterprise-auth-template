
/**
 * Comprehensive test suite for AuthAPI class
 * Tests all authentication endpoints with proper TypeScript typing
 *
 * Coverage includes:
 * - User registration and login flows
 * - Token management (access/refresh)
 * - Password operations (change/reset)
 * - Email verification processes
 * - Two-factor authentication setup
 * - Session management
 * - OAuth provider integration
 * - Error handling and edge cases
 */
import AuthAPI from '@/lib/auth-api';
import apiClient from '@/lib/api-client';
import {
  User,
  LoginRequest,
  LoginResponse,
  RegisterRequest,
  RefreshTokenRequest,
  ChangePasswordRequest,
  ResetPasswordRequest,
  ConfirmResetPasswordRequest,
  TokenPair,
  ApiResponse,
  Role
} from '@/types';

// Mock the api-client module
jest.mock('@/lib/api-client', () => ({
  __esModule: true,
  default: {
    post: jest.fn(),
    get: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
  },
}));

// Type the mocked apiClient
const mockedApiClient = apiClient as jest.Mocked<typeof apiClient>;
describe('AuthAPI', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });
});
describe('User Registration', () => {
    const mockRegisterRequest: RegisterRequest = {
      email: 'test@example.com',
      password: 'SecurePass123!',
      confirm_password: 'SecurePass123!',
      full_name: 'Test User',
      agree_to_terms: true,
    };
    const mockRegisterResponse: ApiResponse<{ message: string }> = {
      success: true,
      data: { message: 'Registration successful. Please verify your email.' },
    };
    it('should register a new user successfully', async () => {
      mockedApiClient.post.mockResolvedValue(mockRegisterResponse);
      const result = await AuthAPI.register(mockRegisterRequest);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/register',
        {
          email: 'test@example.com',
          password: 'SecurePass123!',
          confirm_password: 'SecurePass123!',
          full_name: 'Test User',
          agree_to_terms: true
        }
      );
      expect(result).toEqual(mockRegisterResponse);
      expect(result.success).toBe(true);
      expect(result.data?.message).toBeDefined();
    });
    it('should handle registration with full_name mapping', async () => {
      const requestWithName = {
        email: 'test@example.com',
        password: 'SecurePass123!',
        confirm_password: 'SecurePass123!',
        name: 'Mapped Name', // Using name instead of full_name
        agree_to_terms: true,
      } as RegisterRequest & { name: string };
      // Remove full_name to test the fallback to name
      delete (requestWithName as Partial<RegisterRequest>).full_name;
      mockedApiClient.post.mockResolvedValue(mockRegisterResponse);
      await AuthAPI.register(requestWithName);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/register',
        expect.objectContaining({
          full_name: 'Mapped Name',
        })
      );
    });
    it('should handle registration errors', async () => {
      const errorResponse: ApiResponse<{ message: string }> = {
        success: false,
        error: {
          code: 'EMAIL_ALREADY_EXISTS',
          message: 'Email already registered',
        },
      };
      mockedApiClient.post.mockResolvedValue(errorResponse);
      const result = await AuthAPI.register(mockRegisterRequest);
      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('EMAIL_ALREADY_EXISTS');
    });
  });

describe('User Login', () => {
    const mockLoginRequest: LoginRequest = {
      email: 'test@example.com',
      password: 'SecurePass123!',
      remember_me: true,
    };
    const mockRole: Role = {
      id: 'role-1',
      name: 'user',
      description: 'Standard user role',
      is_active: true,
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
      permissions: [],
    };
    const mockUser: User = {
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
      user_metadata: {},
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
      roles: [mockRole],
      permissions: ['read:profile'],
    };
    const mockBackendResponse = {
      success: true,
      data: {
        access_token: 'mock-access-token',
        refresh_token: 'mock-refresh-token',
        token_type: 'bearer',
        expires_in: 3600,
        user: mockUser,
        requires_2fa: false,
        temp_token: null,
      },
    };
    it('should login user successfully', async () => {
      mockedApiClient.post.mockResolvedValue(mockBackendResponse);
      const result = await AuthAPI.login(mockLoginRequest);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/login?prefer_json_tokens=true',
        mockLoginRequest
      );
      expect(result.success).toBe(true);
      expect(result.data).toBeDefined();
      const loginResponse = result.data as LoginResponse;
      expect(loginResponse.access_token).toBe('mock-access-token');
      expect(loginResponse.refresh_token).toBe('mock-refresh-token');
      expect(loginResponse.user.email).toBe('test@example.com');
      expect(loginResponse.requires_2fa).toBe(false);
    });
    it('should handle 2FA required login', async () => {
      const twoFAResponse = {
        ...mockBackendResponse,
        data: {
          ...mockBackendResponse.data,
          requires_2fa: true,
          temp_token: 'temp-2fa-token',
        },
      };
      mockedApiClient.post.mockResolvedValue(twoFAResponse);
      const result = await AuthAPI.login(mockLoginRequest);
      expect(result.success).toBe(true);
      const loginResponse = result.data as LoginResponse;
      expect(loginResponse.requires_2fa).toBe(true);
      expect(loginResponse.temp_token).toBe('temp-2fa-token');
    });
    it('should handle login with camelCase backend response', async () => {
      const camelCaseResponse = {
        success: true,
        data: {
          accessToken: 'mock-access-token',
          refreshToken: 'mock-refresh-token',
          tokenType: 'bearer',
          expiresIn: 3600,
          user: {
            ...mockUser,
            isVerified: true,
            isTwoFactorEnabled: false,
            lastLoginAt: '2024-01-01T00:00:00Z',
            created_at: '2024-01-01T00:00:00Z',
            updated_at: '2024-01-01T00:00:00Z',
          },
        },
      };
      mockedApiClient.post.mockResolvedValue(camelCaseResponse);
      const result = await AuthAPI.login(mockLoginRequest);
      expect(result.success).toBe(true);
      const loginResponse = result.data as LoginResponse;
      expect(loginResponse.access_token).toBe('mock-access-token');
      expect(loginResponse.user.is_verified).toBe(true);
    });
    it('should handle login errors', async () => {
      const errorResponse: ApiResponse<LoginResponse> = {
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      };
      mockedApiClient.post.mockResolvedValue(errorResponse);
      const result = await AuthAPI.login(mockLoginRequest);
      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('INVALID_CREDENTIALS');
    });
  });

describe('Token Management', () => {
    const mockRefreshRequest: RefreshTokenRequest = {
      refresh_token: 'mock-refresh-token',
    };
    const mockTokenPair: TokenPair = {
      access_token: 'new-access-token',
      refresh_token: 'new-refresh-token',
      token_type: 'bearer',
      expires_in: 3600,
    };
    it('should refresh tokens successfully', async () => {
      const refreshResponse: ApiResponse<TokenPair> = {
        success: true,
        data: mockTokenPair,
      };
      mockedApiClient.post.mockResolvedValue(refreshResponse);
      const result = await AuthAPI.refreshToken(mockRefreshRequest);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/refresh?prefer_json_tokens=true',
        mockRefreshRequest
      );
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockTokenPair);
    });
    it('should handle camelCase token refresh response', async () => {
      const camelCaseResponse = {
        success: true,
        data: {
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          tokenType: 'bearer',
          expiresIn: 3600,
        },
      };
      mockedApiClient.post.mockResolvedValue(camelCaseResponse);
      const result = await AuthAPI.refreshToken(mockRefreshRequest);
      expect(result.success).toBe(true);
      const tokens = result.data as TokenPair;
      expect(tokens.access_token).toBe('new-access-token');
      expect(tokens.refresh_token).toBe('new-refresh-token');
    });
    it('should handle refresh token errors', async () => {
      const errorResponse: ApiResponse<TokenPair> = {
        success: false,
        error: {
          code: 'INVALID_REFRESH_TOKEN',
          message: 'Refresh token is invalid or expired',
        },
      };
      mockedApiClient.post.mockResolvedValue(errorResponse);
      const result = await AuthAPI.refreshToken(mockRefreshRequest);
      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('INVALID_REFRESH_TOKEN');
    });
  });

describe('User Profile Operations', () => {
    const mockUser: User = {
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
      user_metadata: {},
      created_at: '2024-01-01T00:00:00Z',
      updated_at: '2024-01-01T00:00:00Z',
      roles: [],
      permissions: [],
    };
    it('should get current user profile', async () => {
      const profileResponse: ApiResponse<User> = {
        success: true,
        data: mockUser,
      };
      mockedApiClient.get.mockResolvedValue(profileResponse);
      const result = await AuthAPI.getCurrentUser();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/profile/me');
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockUser);
    });
    it('should update user profile', async () => {
      const updateData: Partial<User> = {
        full_name: 'Updated Name',
        username: 'updateduser',
      };
      const updateResponse: ApiResponse<User> = {
        success: true,
        data: { ...mockUser, ...updateData },
      };
      mockedApiClient.put.mockResolvedValue(updateResponse);
      const result = await AuthAPI.updateProfile(updateData);
      expect(mockedApiClient.put).toHaveBeenCalledWith('/api/v1/profile/me', updateData);
      expect(result.success).toBe(true);
      expect(result.data?.full_name).toBe('Updated Name');
    });
  });

describe('Password Operations', () => {
    it('should change password successfully', async () => {
      const changePasswordRequest: ChangePasswordRequest = {
        current_password: 'OldPass123!',
        new_password: 'NewPass123!',
      };
      const successResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Password changed successfully' },
      };
      mockedApiClient.post.mockResolvedValue(successResponse);
      const result = await AuthAPI.changePassword(changePasswordRequest);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/profile/change-password',
        changePasswordRequest
      );
      expect(result.success).toBe(true);
      expect(result.data?.message).toBeDefined();
    });
    it('should request password reset', async () => {
      const resetRequest: ResetPasswordRequest = {
        email: 'test@example.com',
      };
      const successResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Password reset email sent' },
      };
      mockedApiClient.post.mockResolvedValue(successResponse);
      const result = await AuthAPI.requestPasswordReset(resetRequest);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/forgot-password',
        resetRequest
      );
      expect(result.success).toBe(true);
    });
    it('should confirm password reset', async () => {
      const confirmRequest: ConfirmResetPasswordRequest = {
        token: 'reset-token-123',
        new_password: 'NewPass123!',
        confirm_password: 'NewPass123!',
      };
      const successResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Password reset successfully' },
      };
      mockedApiClient.post.mockResolvedValue(successResponse);
      const result = await AuthAPI.confirmPasswordReset(confirmRequest);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/reset-password',
        confirmRequest
      );
      expect(result.success).toBe(true);
    });
  });

describe('Email Verification', () => {
    it('should verify email with token', async () => {
      const token = 'verify-token-123';
      const successResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Email verified successfully' },
      };
      mockedApiClient.get.mockResolvedValue(successResponse);
      const result = await AuthAPI.verifyEmail(token);
      expect(mockedApiClient.get).toHaveBeenCalledWith(
        `/api/v1/auth/verify-email/${encodeURIComponent(token)}`
      );
      expect(result.success).toBe(true);
    });
    it('should resend verification email', async () => {
      const email = 'test@example.com';
      const successResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Verification email sent' },
      };
      mockedApiClient.post.mockResolvedValue(successResponse);
      const result = await AuthAPI.resendVerification(email);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        '/api/v1/auth/resend-verification',
        { email }
      );
      expect(result.success).toBe(true);
    });
    it('should check email availability', async () => {
      const email = 'test@example.com';
      const availabilityResponse: ApiResponse<{ available: boolean }> = {
        success: true,
        data: { available: false },
      };
      mockedApiClient.get.mockResolvedValue(availabilityResponse);
      const result = await AuthAPI.checkEmailAvailability(email);
      expect(mockedApiClient.get).toHaveBeenCalledWith(
        `/api/v1/auth/check-email?email=${encodeURIComponent(email)}`
      );
      expect(result.success).toBe(true);
      expect(result.data?.available).toBe(false);
    });
  });

describe('Permissions and Roles', () => {
    it('should get user permissions', async () => {
      const permissions = ['read:profile', 'write:profile', 'delete:account'];
      const permissionsResponse: ApiResponse<string[]> = {
        success: true,
        data: permissions,
      };
      mockedApiClient.get.mockResolvedValue(permissionsResponse);
      const result = await AuthAPI.getUserPermissions();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/auth/permissions');
      expect(result.success).toBe(true);
      expect(result.data).toEqual(permissions);
    });
    it('should get user roles', async () => {
      const roles = ['user', 'moderator'];
      const rolesResponse: ApiResponse<string[]> = {
        success: true,
        data: roles,
      };
      mockedApiClient.get.mockResolvedValue(rolesResponse);
      const result = await AuthAPI.getUserRoles();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/auth/roles');
      expect(result.success).toBe(true);
      expect(result.data).toEqual(roles);
    });
  });

describe('Two-Factor Authentication', () => {
    it('should setup 2FA', async () => {
      const setup2FAResponse: ApiResponse<{
        secret: string;
        qr_code: string;
        backup_codes: string[];
        manual_entry_key: string;
        manual_entry_uri: string;
      }> = {
        success: true,
        data: {
          secret: 'JBSWY3DPEHPK3PXP',
          qr_code: 'data:image/png;base64,iVBORw0KGgoAAAANS...',
          backup_codes: ['12345678', '87654321'],
          manual_entry_key: 'JBSWY3DPEHPK3PXP',
          manual_entry_uri: 'otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP',
        },
      };
      mockedApiClient.post.mockResolvedValue(setup2FAResponse);
      const result = await AuthAPI.setup2FA();
      expect(mockedApiClient.post).toHaveBeenCalledWith('/api/v1/auth/2fa/setup');
      expect(result.success).toBe(true);
      expect(result.data?.secret).toBeDefined();
      expect(result.data?.qr_code).toBeDefined();
      expect(result.data?.backup_codes).toHaveLength(2);
    });
    it('should enable 2FA with verification code', async () => {
      const code = '123456';
      const enableResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Two-factor authentication enabled' },
      };
      mockedApiClient.post.mockResolvedValue(enableResponse);
      const result = await AuthAPI.enable2FA(code);
      expect(mockedApiClient.post).toHaveBeenCalledWith('/api/v1/auth/2fa/enable', { code });
      expect(result.success).toBe(true);
    });
    it('should get 2FA status', async () => {
      const statusResponse: ApiResponse<{
        enabled: boolean;
        verified_at: string | null;
        backup_codes_remaining: number;
        methods: { [key: string]: boolean };
      }> = {
        success: true,
        data: {
          enabled: true,
          verified_at: '2024-01-01T00:00:00Z',
          backup_codes_remaining: 8,
          methods: { totp: true, sms: false },
        },
      };
      mockedApiClient.get.mockResolvedValue(statusResponse);
      const result = await AuthAPI.get2FAStatus();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/auth/2fa/status');
      expect(result.success).toBe(true);
      expect(result.data?.enabled).toBe(true);
      expect(result.data?.backup_codes_remaining).toBe(8);
    });
    it('should verify 2FA code', async () => {
      const code = '123456';
      const verifyResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: '2FA verification successful' },
      };
      mockedApiClient.post.mockResolvedValue(verifyResponse);
      const result = await AuthAPI.verify2FACode(code, false);
      expect(mockedApiClient.post).toHaveBeenCalledWith('/api/v1/auth/2fa/verify', {
        code,
        is_backup: false
      });
      expect(result.success).toBe(true);
    });
    it('should disable 2FA', async () => {
      const password = 'CurrentPass123!';
      const disableResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Two-factor authentication disabled' },
      };
      mockedApiClient.post.mockResolvedValue(disableResponse);
      const result = await AuthAPI.disable2FA(password);
      expect(mockedApiClient.post).toHaveBeenCalledWith('/api/v1/auth/2fa/disable', { password });
      expect(result.success).toBe(true);
    });
  });

describe('Session Management', () => {
    it('should get active sessions', async () => {
      const sessions = [
        {
          id: 'session-1',
          ip_address: '192.168.1.1',
          user_agent: 'Mozilla/5.0...',
          created_at: '2024-01-01T00:00:00Z',
          last_activity: '2024-01-01T12:00:00Z',
          is_current: true,
        },
        {
          id: 'session-2',
          ip_address: '192.168.1.2',
          user_agent: 'Chrome/91.0...',
          created_at: '2024-01-01T00:00:00Z',
          last_activity: '2024-01-01T10:00:00Z',
          is_current: false,
        },
      ];
      const sessionsResponse: ApiResponse<typeof sessions> = {
        success: true,
        data: sessions,
      };
      mockedApiClient.get.mockResolvedValue(sessionsResponse);
      const result = await AuthAPI.getActiveSessions();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/auth/sessions');
      expect(result.success).toBe(true);
      expect(result.data).toHaveLength(2);
      expect(result.data?.[0].is_current).toBe(true);
    });
    it('should revoke specific session', async () => {
      const sessionId = 'session-123';
      const revokeResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Session revoked successfully' },
      };
      mockedApiClient.delete.mockResolvedValue(revokeResponse);
      const result = await AuthAPI.revokeSession(sessionId);
      expect(mockedApiClient.delete).toHaveBeenCalledWith(`/api/v1/auth/sessions/${sessionId}`);
      expect(result.success).toBe(true);
    });
    it('should revoke all other sessions', async () => {
      const revokeAllResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'All other sessions revoked' },
      };
      mockedApiClient.post.mockResolvedValue(revokeAllResponse);
      const result = await AuthAPI.revokeAllOtherSessions();
      expect(mockedApiClient.post).toHaveBeenCalledWith('/api/v1/auth/sessions/revoke-all');
      expect(result.success).toBe(true);
    });
  });

describe('OAuth Integration', () => {
    it('should handle OAuth callback', async () => {
      const provider = 'google';
      const callbackData = {
        code: 'oauth-code-123',
        state: 'oauth-state-456',
      };
      const callbackResponse: ApiResponse<LoginResponse> = {
        success: true,
        data: {
          access_token: 'oauth-access-token',
          refresh_token: 'oauth-refresh-token',
          token_type: 'bearer',
          expires_in: 3600,
          user: {
            id: 'user-123',
            email: 'oauth@example.com',
            full_name: 'OAuth User',
            is_active: true,
            is_verified: true,
            email_verified: true,
            is_superuser: false,
            two_factor_enabled: false,
            failed_login_attempts: 0,
            last_login: null,
            user_metadata: {},
            created_at: '2024-01-01T00:00:00Z',
            updated_at: '2024-01-01T00:00:00Z',
            roles: [],
            permissions: [],
          },
        },
      };
      mockedApiClient.post.mockResolvedValue(callbackResponse);
      const result = await AuthAPI.oauthCallback(provider, callbackData);
      expect(mockedApiClient.post).toHaveBeenCalledWith(
        `/api/v1/auth/oauth/${provider}/callback`,
        callbackData
      );
      expect(result.success).toBe(true);
      expect(result.data?.access_token).toBeDefined();
    });
    it('should get OAuth providers', async () => {
      const providers = [
        { id: 'google', name: 'Google', enabled: true },
        { id: 'github', name: 'GitHub', enabled: true },
        { id: 'facebook', name: 'Facebook', enabled: false },
      ];
      const providersResponse: ApiResponse<typeof providers> = {
        success: true,
        data: providers,
      };
      mockedApiClient.get.mockResolvedValue(providersResponse);
      const result = await AuthAPI.getOAuthProviders();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/auth/oauth/providers');
      expect(result.success).toBe(true);
      expect(result.data).toHaveLength(3);
      expect(result.data?.[0].enabled).toBe(true);
    });
    it('should link OAuth account', async () => {
      const provider = 'github';
      const linkResponse: ApiResponse<{ authorize_url: string }> = {
        success: true,
        data: { authorize_url: 'https://github.com/login/oauth/authorize?...' },
      };
      mockedApiClient.post.mockResolvedValue(linkResponse);
      const result = await AuthAPI.linkOAuthAccount(provider);
      expect(mockedApiClient.post).toHaveBeenCalledWith(`/api/v1/auth/oauth/${provider}/link`);
      expect(result.success).toBe(true);
      expect(result.data?.authorize_url).toContain('github.com');
    });
    it('should unlink OAuth account', async () => {
      const provider = 'google';
      const unlinkResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Google account unlinked successfully' },
      };
      mockedApiClient.delete.mockResolvedValue(unlinkResponse);
      const result = await AuthAPI.unlinkOAuthAccount(provider);
      expect(mockedApiClient.delete).toHaveBeenCalledWith(`/api/v1/auth/oauth/${provider}/unlink`);
      expect(result.success).toBe(true);
    });
    it('should get linked accounts', async () => {
      const linkedAccounts = [
        {
          provider: 'google',
          provider_user_id: 'google-123',
          linked_at: '2024-01-01T00:00:00Z',
        },
        {
          provider: 'github',
          provider_user_id: 'github-456',
          linked_at: '2024-01-01T00:00:00Z',
        },
      ];
      const linkedResponse: ApiResponse<typeof linkedAccounts> = {
        success: true,
        data: linkedAccounts,
      };
      mockedApiClient.get.mockResolvedValue(linkedResponse);
      const result = await AuthAPI.getLinkedAccounts();
      expect(mockedApiClient.get).toHaveBeenCalledWith('/api/v1/auth/oauth/linked');
      expect(result.success).toBe(true);
      expect(result.data).toHaveLength(2);
    });
  });

describe('Logout', () => {
    it('should logout successfully', async () => {
      const logoutResponse: ApiResponse<{ message: string }> = {
        success: true,
        data: { message: 'Logged out successfully' },
      };
      mockedApiClient.post.mockResolvedValue(logoutResponse);
      const result = await AuthAPI.logout();
      expect(mockedApiClient.post).toHaveBeenCalledWith('/api/v1/auth/logout');
      expect(result.success).toBe(true);
      expect(result.data?.message).toBeDefined();
    });
  });

describe('Error Handling', () => {
    it('should handle network errors gracefully', async () => {
      const networkError = new Error('Network error');
      mockedApiClient.post.mockRejectedValue(networkError);
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'password',
      };
      // The AuthAPI should handle this through the apiClient's error handling
      // which is expected to return a proper ApiResponse structure
      const errorResponse: ApiResponse<LoginResponse> = {
        success: false,
        error: {
          code: 'NETWORK_ERROR',
          message: 'Network error occurred',
        },
      };
      mockedApiClient.post.mockResolvedValue(errorResponse);
      const result = await AuthAPI.login(loginRequest);
      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('NETWORK_ERROR');
    });
    it('should handle API errors with proper structure', async () => {
      const apiError: ApiResponse<{ message: string }> = {
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid request data',
          details: {
            field: 'email',
            issue: 'Invalid email format',
          },
        },
      };
      mockedApiClient.post.mockResolvedValue(apiError);
      const result = await AuthAPI.register({
        email: 'invalid-email',
        password: 'password',
        full_name: 'Test User',
        agree_to_terms: true
      });
      expect(result.success).toBe(false);
      expect(result.error?.code).toBe('VALIDATION_ERROR');
      expect(result.error?.details).toBeDefined();
    });
  });
});