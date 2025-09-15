// Authentication related types that match backend models

export interface User {
  id: string;
  email: string;
  full_name: string;
  username?: string;
  is_active: boolean;
  email_verified: boolean; // Changed from is_verified to match backend
  is_superuser: boolean;
  two_factor_enabled: boolean;
  failed_login_attempts: number;
  last_login: string | null;
  last_login_at?: string | null; // For backend compatibility
  profile_picture?: string; // Standardized field name
  avatar_url?: string; // Keep for backward compatibility
  phone_number?: string;
  is_phone_verified?: boolean;
  user_metadata: Record<string, unknown>;
  created_at: string;
  updated_at: string;
  roles: Role[];
  permissions?: string[]; // Direct permissions array from backend
}

export interface Role {
  id: string;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  permissions: Permission[];
}

export interface Permission {
  id: string;
  name: string;
  resource: string;
  action: string;
  description: string | null;
  created_at: string;
  updated_at: string;
}

export interface UserSession {
  id: string;
  user_id: string;
  session_token: string;
  ip_address: string | null;
  user_agent: string | null;
  expires_at: Date;
  session_metadata: Record<string, unknown>;
  created_at: Date;
  updated_at: Date;
}

export interface AuditLog {
  id: string;
  user_id: string | null;
  action: string;
  resource_type: string | null;
  resource_id: string | null;
  ip_address: string | null;
  user_agent: string | null;
  details: Record<string, unknown>;
  created_at: Date;
}

// Token types
export interface TokenPair {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}

export interface TokenData {
  sub: string;
  email: string;
  roles: string[];
  permissions: string[];
  token_type: string;
  exp: number;
  iat: number;
}

// Request/Response types
export interface LoginRequest {
  email: string;
  password: string;
  remember_me?: boolean; // Added for remember me functionality
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
  user: User;
  requires_2fa?: boolean;
  temp_token?: string | null;
}

// Standard API response wrapper
export interface StandardResponse<T> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  metadata?: {
    timestamp: string;
    request_id: string;
    version?: string;
  };
}

export interface RegisterRequest {
  email: string;
  password: string;
  confirm_password?: string; // Optional for backend compatibility
  full_name: string; // Backend expects full_name
  agree_to_terms: boolean;
}

export interface RefreshTokenRequest {
  refresh_token: string;
}

export interface ChangePasswordRequest {
  current_password: string;
  new_password: string;
}

export interface ResetPasswordRequest {
  email: string;
}

export interface ConfirmResetPasswordRequest {
  token: string;
  new_password: string;
  confirm_password: string; // Added to match backend schema
}

// Authentication context types
export interface AuthState {
  user: User | null;
  tokens: TokenPair | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  permissions: string[];
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
}

export interface AuthActions {
  login: (credentials: LoginRequest) => Promise<boolean>;
  register: (userData: RegisterRequest) => Promise<boolean>;
  logout: () => void;
  refreshToken: () => Promise<boolean>;
  updateUser: (userData: Partial<User>) => void;
}

export type AuthContextType = AuthState & AuthActions;

// Error types
export interface AuthError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

// Form validation types
export interface LoginFormData {
  email: string;
  password: string;
  rememberMe?: boolean;
}

export interface RegisterFormData {
  email: string;
  password: string;
  confirmPassword: string;
  name: string;
  terms: boolean;
}

export interface ChangePasswordFormData {
  currentPassword: string;
  newPassword: string;
  confirmNewPassword: string;
}

// Route protection types
export interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredPermissions?: string[];
  requiredRoles?: string[];
  fallback?: React.ReactNode;
}
