export interface User {
  id: string;
  email: string;
  full_name: string;
  username?: string;
  avatar_url?: string;
  is_active: boolean;
  is_verified: boolean;
  email_verified: boolean;
  is_superuser: boolean;
  two_factor_enabled: boolean;
  failed_login_attempts: number;
  last_login: string | null;
  user_metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
  roles?: Role[];
  permissions?: string[];
}

export interface Role {
  id: string;
  name: string;
  description?: string;
  permissions?: Permission[];
}

export interface Permission {
  id: string;
  resource: string;
  action: string;
  description?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  full_name: string;
  confirm_password: string;
  agree_to_terms?: boolean;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
  user: User;
}

export interface TokenRefreshResponse {
  access_token: string;
  expires_in: number;
}

export interface PasswordResetRequest {
  email: string;
}

export interface PasswordResetConfirm {
  token: string;
  new_password: string;
}

export interface ConfirmResetPasswordRequest {
  token: string;
  new_password: string;
  confirm_password: string;
}

export interface ChangePasswordRequest {
  current_password: string;
  new_password: string;
}

export interface AuthSession {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}