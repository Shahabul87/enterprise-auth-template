export interface User {
  id: string;
  email: string;
  first_name: string;
  last_name: string;
  is_active: boolean;
  is_verified: boolean;
  is_superuser: boolean;
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

export interface CreateUserRequest {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  is_active?: boolean;
  is_verified?: boolean;
  is_superuser?: boolean;
  role_ids?: string[];
}

export interface UpdateUserRequest {
  email?: string;
  first_name?: string;
  last_name?: string;
  is_active?: boolean;
  is_verified?: boolean;
  is_superuser?: boolean;
  role_ids?: string[];
}

export interface UserListParams extends Record<string, unknown> {
  page?: number;
  per_page?: number;
  search?: string;
  is_active?: boolean;
  is_verified?: boolean;
  role_id?: string;
  sort_by?: string;
  sort_order?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
  has_next: boolean;
  has_prev: boolean;
}

export interface BulkUserOperation {
  user_ids: string[];
  action: 'activate' | 'deactivate' | 'delete' | 'verify' | 'unverify';
  role_id?: string;
}

export type BulkUserActionType = 'activate' | 'deactivate' | 'delete' | 'verify' | 'unverify';

// User profile and preferences types
export interface UserProfile {
  id: string;
  user_id: string;
  avatar_url?: string;
  display_name?: string;
  bio?: string;
  location?: string;
  website?: string;
  social_links?: Record<string, string>;
  created_at: string;
  updated_at: string;
}

export interface UserPreferences {
  id: string;
  user_id: string;
  theme: 'light' | 'dark' | 'system';
  language: string;
  timezone: string;
  email_notifications: boolean;
  push_notifications: boolean;
  marketing_emails: boolean;
  created_at: string;
  updated_at: string;
}

export interface UserActivity {
  id: string;
  user_id: string;
  action: string;
  resource_type: string;
  resource_id?: string;
  details?: Record<string, unknown>;
  ip_address: string;
  user_agent: string;
  timestamp: string;
}

export interface UserStatistics {
  user_id: string;
  login_count: number;
  last_login_at?: string;
  profile_completion: number;
  activity_score: number;
  created_at: string;
  updated_at: string;
}