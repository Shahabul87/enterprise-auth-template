// Authentication-specific API endpoints with type safety

import apiClient from './api-client';
import {
  User,
  TokenPair,
  LoginRequest,
  LoginResponse,
  RegisterRequest,
  RefreshTokenRequest,
  ChangePasswordRequest,
  ResetPasswordRequest,
  ConfirmResetPasswordRequest,
  ApiResponse,
} from '@/types';

export class AuthAPI {
  // Normalize backend (camelCase) auth payloads to frontend snake_case types
  private static normalizeAuthData(data: any): LoginResponse {
    const rawUser = data?.user ?? {};
    const user: User = {
      id: String(rawUser.id ?? rawUser.user_id ?? ''),
      email: rawUser.email ?? '',
      full_name: rawUser.full_name ?? rawUser.name ?? '',
      username: rawUser.username,
      is_active: rawUser.is_active ?? true,
      email_verified: rawUser.email_verified ?? rawUser.isEmailVerified ?? rawUser.is_verified ?? false,
      is_superuser: rawUser.is_superuser ?? false,
      two_factor_enabled: rawUser.two_factor_enabled ?? rawUser.isTwoFactorEnabled ?? false,
      failed_login_attempts: rawUser.failed_login_attempts ?? 0,
      last_login: rawUser.last_login ?? rawUser.lastLoginAt ?? null,
      last_login_at: rawUser.last_login_at ?? rawUser.lastLoginAt ?? undefined,
      profile_picture: rawUser.profile_picture ?? rawUser.profilePicture,
      avatar_url: rawUser.avatar_url,
      phone_number: rawUser.phone_number,
      is_phone_verified: rawUser.is_phone_verified,
      user_metadata: rawUser.user_metadata ?? {},
      created_at: rawUser.created_at ?? rawUser.createdAt ?? '',
      updated_at: rawUser.updated_at ?? rawUser.updatedAt ?? '',
      roles: rawUser.roles ?? [],
      permissions: rawUser.permissions ?? [],
    };

    const access_token = data?.access_token ?? data?.accessToken ?? '';
    const refresh_token = data?.refresh_token ?? data?.refreshToken ?? '';
    const token_type = data?.token_type ?? data?.tokenType ?? 'bearer';
    const expires_in = data?.expires_in ?? data?.expiresIn ?? 0;

    return {
      access_token,
      refresh_token,
      token_type,
      expires_in,
      user,
      requires_2fa: data?.requires_2fa ?? false,
      temp_token: data?.temp_token ?? data?.tempToken ?? null,
    };
  }
  // User registration - backend returns a message, not user data
  static async register(userData: RegisterRequest): Promise<ApiResponse<{ message: string }>> {
    // Map frontend payload to backend schema (full_name expected)
    const mapped = {
      email: userData.email,
      password: userData.password,
      confirm_password: userData.confirm_password,
      full_name: (userData as any).full_name ?? (userData as any).name,
      agree_to_terms: userData.agree_to_terms,
    };
    return apiClient.post<{ message: string }>('/api/v1/auth/register', mapped);
  }

  // User login
  static async login(credentials: LoginRequest): Promise<ApiResponse<any>> {
    // Ask backend to return JSON tokens (no cookies)
    const response = await apiClient.post<any>('/api/v1/auth/login?prefer_json_tokens=true', credentials);
    if (!response.success || !response.data) return response;
    // Backend wraps in StandardResponse, data contains auth fields in camelCase
    const normalized = AuthAPI.normalizeAuthData(response.data);
    return { success: true, data: normalized };
  }

  // Refresh access token
  static async refreshToken(
    refreshTokenData: RefreshTokenRequest
  ): Promise<ApiResponse<any>> {
    // Prefer JSON token refresh (no cookies needed)
    const response = await apiClient.post<any>('/api/v1/auth/refresh?prefer_json_tokens=true', refreshTokenData);
    if (!response.success || !response.data) return response;
    const data = response.data;
    const tokenPair: TokenPair = {
      access_token: data.access_token ?? data.accessToken ?? '',
      refresh_token: data.refresh_token ?? data.refreshToken ?? '',
      token_type: data.token_type ?? data.tokenType ?? 'bearer',
      expires_in: data.expires_in ?? data.expiresIn ?? 0,
    };
    return { success: true, data: tokenPair };
  }

  // Logout (revoke tokens)
  static async logout(): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/logout');
  }

  // Get current user profile
  static async getCurrentUser(): Promise<ApiResponse<User>> {
    const response = await apiClient.get<any>('/api/v1/profile/me');
    if (!response.success || !response.data) return response as ApiResponse<User>;
    const normalized = AuthAPI.normalizeAuthData({ user: response.data });
    return { success: true, data: normalized.user };
  }

  // Update current user profile
  static async updateProfile(userData: Partial<User>): Promise<ApiResponse<User>> {
    return apiClient.put<User>('/api/v1/profile/me', userData);
  }

  // Change password
  static async changePassword(
    passwordData: ChangePasswordRequest
  ): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/profile/change-password', passwordData);
  }

  // Request password reset
  static async requestPasswordReset(
    resetData: ResetPasswordRequest
  ): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/forgot-password', resetData);
  }

  // Confirm password reset with token
  static async confirmPasswordReset(
    confirmData: ConfirmResetPasswordRequest
  ): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/reset-password', confirmData);
  }

  // Verify email address
  static async verifyEmail(token: string): Promise<ApiResponse<{ message: string }>> {
    // Backend uses GET /verify-email/{token}
    return apiClient.get<{ message: string }>(`/api/v1/auth/verify-email/${encodeURIComponent(token)}`);
  }

  // Resend email verification
  static async resendVerification(email: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/resend-verification', { email });
  }

  // Check if email is available
  static async checkEmailAvailability(email: string): Promise<ApiResponse<{ available: boolean }>> {
    return apiClient.get<{ available: boolean }>(
      `/api/v1/auth/check-email?email=${encodeURIComponent(email)}`
    );
  }

  // Get user permissions
  static async getUserPermissions(): Promise<ApiResponse<string[]>> {
    return apiClient.get<string[]>('/api/v1/auth/permissions');
  }

  // Get user roles
  static async getUserRoles(): Promise<ApiResponse<string[]>> {
    return apiClient.get<string[]>('/api/v1/auth/roles');
  }

  // Setup two-factor authentication (get QR code and secret)
  static async setup2FA(): Promise<
    ApiResponse<{
      secret: string;
      qr_code: string;
      backup_codes: string[];
      manual_entry_key: string;
      manual_entry_uri: string;
    }>
  > {
    return apiClient.post('/api/v1/auth/2fa/setup');
  }

  // Enable two-factor authentication (verify and enable)
  static async enable2FA(code: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/2fa/enable', { code });
  }

  // Get 2FA status
  static async get2FAStatus(): Promise<
    ApiResponse<{
      enabled: boolean;
      verified_at: string | null;
      backup_codes_remaining: number;
      methods: { [key: string]: boolean };
    }>
  > {
    return apiClient.get('/api/v1/auth/2fa/status');
  }

  // Regenerate backup codes
  static async regenerateBackupCodes(): Promise<
    ApiResponse<{
      backup_codes: string[];
      warning: string;
    }>
  > {
    return apiClient.post('/api/v1/auth/2fa/backup-codes/regenerate');
  }

  // Verify 2FA code
  static async verify2FACode(
    code: string,
    isBackup = false
  ): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/2fa/verify', {
      code,
      is_backup: isBackup,
    });
  }

  // Disable two-factor authentication
  static async disable2FA(password: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/2fa/disable', { password });
  }

  // Verify 2FA code during login
  static async verify2FA(code: string, token: string): Promise<ApiResponse<TokenPair>> {
    return apiClient.post<TokenPair>('/api/v1/auth/2fa/verify', { code, token });
  }

  // Get active sessions
  static async getActiveSessions(): Promise<
    ApiResponse<
      Array<{
        id: string;
        ip_address: string;
        user_agent: string;
        created_at: string;
        last_activity: string;
        is_current: boolean;
      }>
    >
  > {
    return apiClient.get('/api/v1/auth/sessions');
  }

  // Revoke a specific session
  static async revokeSession(sessionId: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/api/v1/auth/sessions/${sessionId}`);
  }

  // Revoke all other sessions (keep current)
  static async revokeAllOtherSessions(): Promise<ApiResponse<{ message: string }>> {
    return apiClient.post<{ message: string }>('/api/v1/auth/sessions/revoke-all');
  }

  // OAuth callback - exchange code for tokens
  static async oauthCallback(
    provider: string,
    data: {
      code: string;
      state: string;
    }
  ): Promise<ApiResponse<LoginResponse>> {
    return apiClient.post<LoginResponse>(`/api/v1/auth/oauth/${provider}/callback`, data);
  }

  // Get available OAuth providers
  static async getOAuthProviders(): Promise<
    ApiResponse<
      Array<{
        id: string;
        name: string;
        enabled: boolean;
      }>
    >
  > {
    return apiClient.get('/api/v1/auth/oauth/providers');
  }

  // Link OAuth account to existing user
  static async linkOAuthAccount(provider: string): Promise<ApiResponse<{ authorize_url: string }>> {
    return apiClient.post<{ authorize_url: string }>(`/api/v1/auth/oauth/${provider}/link`);
  }

  // Unlink OAuth account from user
  static async unlinkOAuthAccount(provider: string): Promise<ApiResponse<{ message: string }>> {
    return apiClient.delete<{ message: string }>(`/api/v1/auth/oauth/${provider}/unlink`);
  }

  // Get linked OAuth accounts
  static async getLinkedAccounts(): Promise<
    ApiResponse<
      Array<{
        provider: string;
        provider_user_id: string;
        linked_at: string;
      }>
    >
  > {
    return apiClient.get('/api/v1/auth/oauth/linked');
  }
}

export default AuthAPI;
