/**
 * Admin Dashboard Types for Enterprise Authentication Template
 * 
 * This file contains comprehensive type definitions for the admin dashboard,
 * including user management, role management, audit logs, analytics, and
 * system administration features.
 * 
 * @fileoverview Admin dashboard TypeScript type definitions
 * @version 1.0.0
 */

import type { User, Role } from './auth';
import type { SortConfig } from './api';

// ================================
// Dashboard Analytics Types
// ================================

/**
 * Main admin dashboard statistics
 */
export interface AdminDashboardStats {
  /** User statistics */
  users: UserManagementStats;
  /** Role and permission statistics */
  roles: RoleManagementStats;
  /** Authentication statistics */
  auth: AuthenticationStats;
  /** System performance metrics */
  system: SystemStats;
  /** Audit log statistics */
  audit: AuditLogStats;
  /** Security metrics */
  security: SecurityStats;
}

/**
 * User management statistics
 */
export interface UserManagementStats {
  /** Total number of users */
  total_users: number;
  /** Number of active users */
  active_users: number;
  /** Number of inactive users */
  inactive_users: number;
  /** Number of verified users */
  verified_users: number;
  /** Number of unverified users */
  unverified_users: number;
  /** Number of superusers */
  superusers: number;
  /** New users registered today */
  new_users_today: number;
  /** New users this week */
  new_users_this_week: number;
  /** New users this month */
  new_users_this_month: number;
  /** User growth rate (percentage) */
  growth_rate: number;
  /** Top user registration sources */
  registration_sources: Array<{
    source: string;
    count: number;
    percentage: number;
  }>;
}

/**
 * Role and permission management statistics
 */
export interface RoleManagementStats {
  /** Total number of roles */
  total_roles: number;
  /** Number of active roles */
  active_roles: number;
  /** Number of inactive roles */
  inactive_roles: number;
  /** Total number of permissions */
  total_permissions: number;
  /** Number of unique resources */
  unique_resources: number;
  /** Number of unique actions */
  unique_actions: number;
  /** Most assigned roles */
  popular_roles: Array<{
    role_id: string;
    role_name: string;
    user_count: number;
  }>;
  /** Least used permissions */
  unused_permissions: Array<{
    permission_id: string;
    resource: string;
    action: string;
  }>;
}

/**
 * Authentication and session statistics
 */
export interface AuthenticationStats {
  /** Total login attempts today */
  login_attempts_today: number;
  /** Successful logins today */
  successful_logins_today: number;
  /** Failed login attempts today */
  failed_logins_today: number;
  /** Login success rate (percentage) */
  login_success_rate: number;
  /** Currently active sessions */
  active_sessions: number;
  /** Password reset requests today */
  password_resets_today: number;
  /** Two-factor authentication usage */
  two_factor_enabled_users: number;
  /** OAuth login statistics */
  oauth_logins: Array<{
    provider: string;
    count: number;
  }>;
}

/**
 * System performance and health statistics
 */
export interface SystemStats {
  /** System uptime in seconds */
  uptime_seconds: number;
  /** Current server memory usage (MB) */
  memory_usage_mb: number;
  /** CPU usage percentage */
  cpu_usage_percent: number;
  /** Database connection pool status */
  database_connections: {
    active: number;
    idle: number;
    total: number;
  };
  /** Redis cache statistics */
  cache_stats: {
    hit_rate: number;
    miss_rate: number;
    total_keys: number;
  };
  /** API response times */
  api_response_times: {
    average_ms: number;
    p95_ms: number;
    p99_ms: number;
  };
  /** Application version */
  version: string;
  /** Environment */
  environment: 'development' | 'staging' | 'production';
}

/**
 * Security monitoring statistics
 */
export interface SecurityStats {
  /** Failed login attempts in last 24h */
  failed_login_attempts: number;
  /** Locked user accounts */
  locked_accounts: number;
  /** Suspicious activity alerts */
  security_alerts: number;
  /** IP addresses with multiple failed attempts */
  suspicious_ips: Array<{
    ip_address: string;
    attempt_count: number;
    last_attempt: string;
  }>;
  /** Brute force attack attempts */
  brute_force_attempts: number;
  /** Account takeover attempts */
  account_takeover_attempts: number;
  /** Security events by severity */
  security_events_by_severity: {
    low: number;
    medium: number;
    high: number;
    critical: number;
  };
}

// ================================
// User Management Types
// ================================

/**
 * Extended user information for admin management
 */
export interface AdminUserDetails extends User {
  /** User&apos;s IP address from last login */
  last_login_ip?: string;
  /** Device information from last login */
  last_login_device?: string;
  /** Number of failed login attempts */
  failed_login_attempts: number;
  /** Account locked status */
  is_locked: boolean;
  /** Account lock reason */
  lock_reason?: string;
  /** When account was locked */
  locked_at?: string;
  /** Two-factor authentication enabled */
  two_factor_enabled: boolean;
  /** OAuth providers linked */
  oauth_providers: string[];
  /** User activity score */
  activity_score: number;
  /** Risk assessment level */
  risk_level: 'low' | 'medium' | 'high';
  /** User metadata */
  metadata: Record<string, unknown>;
}

/**
 * User filtering options for admin interface
 */
export interface UserFilters {
  /** Text search in name, email, etc. */
  search?: string;
  /** Filter by role ID */
  role_id?: string;
  /** Filter by account status */
  status?: 'active' | 'inactive' | 'locked' | 'all';
  /** Filter by verification status */
  is_verified?: boolean;
  /** Filter by superuser status */
  is_superuser?: boolean;
  /** Filter by date range */
  date_from?: string;
  date_to?: string;
  /** Filter by registration source */
  registration_source?: string;
  /** Filter by risk level */
  risk_level?: 'low' | 'medium' | 'high';
  /** Filter by 2FA status */
  two_factor_enabled?: boolean;
  /** Filter by OAuth provider */
  oauth_provider?: string;
}

/**
 * User creation request with admin privileges
 */
export interface AdminCreateUserRequest {
  /** User email address */
  email: string;
  /** Initial password (optional, can send invite) */
  password?: string;
  /** First name */
  first_name: string;
  /** Last name */
  last_name: string;
  /** Whether account is active */
  is_active?: boolean;
  /** Whether email is verified */
  is_verified?: boolean;
  /** Whether user is superuser */
  is_superuser?: boolean;
  /** Role IDs to assign */
  role_ids?: string[];
  /** Send invitation email instead of password */
  send_invitation?: boolean;
  /** Custom user metadata */
  metadata?: Record<string, unknown>;
  /** Skip email verification */
  skip_verification?: boolean;
}

/**
 * User update request with admin privileges
 */
export interface AdminUpdateUserRequest {
  /** Update email address */
  email?: string;
  /** Update first name */
  first_name?: string;
  /** Update last name */
  last_name?: string;
  /** Update active status */
  is_active?: boolean;
  /** Update verification status */
  is_verified?: boolean;
  /** Update superuser status */
  is_superuser?: boolean;
  /** Update assigned roles */
  role_ids?: string[];
  /** Reset password and send email */
  reset_password?: boolean;
  /** Unlock account */
  unlock_account?: boolean;
  /** Force password change on next login */
  force_password_change?: boolean;
  /** Update user metadata */
  metadata?: Record<string, unknown>;
}

/**
 * Bulk user operations
 */
export interface BulkUserOperation {
  /** User IDs to operate on */
  user_ids: string[];
  /** Operation to perform */
  operation: BulkUserOperationType;
  /** Additional operation parameters */
  parameters?: {
    /** Role ID for role assignments */
    role_id?: string;
    /** Reason for bulk action */
    reason?: string;
    /** Send notification emails */
    send_notifications?: boolean;
  };
}

/**
 * Available bulk user operations
 */
export type BulkUserOperationType =
  | 'activate'
  | 'deactivate'
  | 'verify'
  | 'unverify'
  | 'delete'
  | 'lock'
  | 'unlock'
  | 'assign_role'
  | 'remove_role'
  | 'force_password_reset'
  | 'enable_2fa'
  | 'disable_2fa';

// ================================
// Role and Permission Management
// ================================

/**
 * Extended role information for admin management
 */
export interface AdminRoleDetails extends Role {
  /** Number of users with this role */
  user_count: number;
  /** Whether role is system-defined */
  is_system: boolean;
  /** Role creation timestamp */
  created_at: string;
  /** Role last update timestamp */
  updated_at: string;
  /** Who created the role */
  created_by?: string;
  /** Who last updated the role */
  updated_by?: string;
  /** Role usage statistics */
  usage_stats: {
    /** Times this role was assigned this month */
    assignments_this_month: number;
    /** Average permissions per user with this role */
    avg_permissions_per_user: number;
  };
}

/**
 * Role filtering options
 */
export interface RoleFilters {
  /** Search in role name and description */
  search?: string;
  /** Filter by active/inactive status */
  is_active?: boolean;
  /** Filter by system/custom roles */
  is_system?: boolean;
  /** Filter by permission ID */
  permission_id?: string;
  /** Filter by user count range */
  min_user_count?: number;
  max_user_count?: number;
}

/**
 * Role creation request with admin options
 */
export interface AdminCreateRoleRequest {
  /** Role name */
  name: string;
  /** Role description */
  description?: string;
  /** Whether role is active */
  is_active?: boolean;
  /** Permission IDs to assign */
  permission_ids?: string[];
  /** Whether role is system-defined */
  is_system?: boolean;
  /** Role metadata */
  metadata?: Record<string, unknown>;
}

/**
 * Role update request with admin options
 */
export interface AdminUpdateRoleRequest {
  /** Update role name */
  name?: string;
  /** Update description */
  description?: string;
  /** Update active status */
  is_active?: boolean;
  /** Update assigned permissions */
  permission_ids?: string[];
  /** Update metadata */
  metadata?: Record<string, unknown>;
}

/**
 * Permission filtering options
 */
export interface PermissionFilters {
  /** Search in permission details */
  search?: string;
  /** Filter by resource type */
  resource?: string;
  /** Filter by action type */
  action?: string;
  /** Filter by system/custom permissions */
  is_system?: boolean;
  /** Filter by usage (assigned to roles or not) */
  is_used?: boolean;
}

/**
 * Permission creation request
 */
export interface AdminCreatePermissionRequest {
  /** Permission resource */
  resource: string;
  /** Permission action */
  action: string;
  /** Human-readable description */
  description?: string;
  /** Whether permission is system-defined */
  is_system?: boolean;
  /** Permission metadata */
  metadata?: Record<string, unknown>;
}

// ================================
// Audit Log Types
// ================================

/**
 * Detailed audit log entry
 */
export interface AuditLogEntry {
  /** Unique log entry ID */
  id: string;
  /** User who performed the action */
  user_id?: string;
  /** User details */
  user_email?: string;
  user_name?: string;
  /** Action performed */
  action: string;
  /** Resource that was affected */
  resource_type: string;
  /** ID of the affected resource */
  resource_id?: string;
  /** Additional action details */
  details: Record<string, unknown>;
  /** IP address of the user */
  ip_address: string;
  /** User agent string */
  user_agent: string;
  /** Session ID */
  session_id?: string;
  /** Timestamp of the action */
  timestamp: string;
  /** Action result (success/failure) */
  result: 'success' | 'failure';
  /** Error message if failed */
  error_message?: string;
  /** Geographic location (if available) */
  location?: {
    country?: string;
    region?: string;
    city?: string;
  };
  /** Risk assessment for this action */
  risk_score: number;
}

/**
 * Audit log filtering options
 */
export interface AuditLogFilters {
  /** Search in actions, users, resources */
  search?: string;
  /** Filter by user ID */
  user_id?: string;
  /** Filter by action type */
  action?: string;
  /** Filter by resource type */
  resource_type?: string;
  /** Filter by result */
  result?: 'success' | 'failure' | 'all';
  /** Filter by date range */
  date_from?: string;
  date_to?: string;
  /** Filter by IP address */
  ip_address?: string;
  /** Filter by risk score range */
  min_risk_score?: number;
  max_risk_score?: number;
  /** Filter by location */
  country?: string;
  region?: string;
  city?: string;
}

/**
 * Audit log statistics for analytics
 */
export interface AuditLogStats {
  /** Total number of audit log entries */
  total_entries: number;
  /** Unique users in logs */
  unique_users: number;
  /** Unique actions performed */
  unique_actions: number;
  /** Entries today */
  entries_today: number;
  /** Entries this week */
  entries_this_week: number;
  /** Entries this month */
  entries_this_month: number;
  /** Most frequent actions */
  top_actions: Array<{
    action: string;
    count: number;
    percentage: number;
  }>;
  /** Most active users */
  top_users: Array<{
    user_id: string;
    user_name: string;
    user_email: string;
    action_count: number;
  }>;
  /** Activity by hour of day */
  activity_by_hour: Array<{
    hour: number;
    count: number;
  }>;
  /** Failed actions summary */
  failed_actions: {
    total: number;
    unique_users: number;
    top_failures: Array<{
      action: string;
      count: number;
      error_message: string;
    }>;
  };
}

// ================================
// System Configuration Types
// ================================

/**
 * System-wide configuration settings
 */
export interface SystemSettings {
  /** Authentication settings */
  auth: {
    /** Allow user registration */
    registration_enabled: boolean;
    /** Require email verification */
    email_verification_required: boolean;
    /** Enable password reset */
    password_reset_enabled: boolean;
    /** Maximum failed login attempts */
    max_login_attempts: number;
    /** Account lockout duration (minutes) */
    lockout_duration_minutes: number;
    /** Session timeout (minutes) */
    session_timeout_minutes: number;
    /** Require 2FA for admin users */
    require_2fa_for_admins: boolean;
  };
  /** Password policy settings */
  password_policy: {
    /** Minimum password length */
    min_length: number;
    /** Require uppercase letters */
    require_uppercase: boolean;
    /** Require lowercase letters */
    require_lowercase: boolean;
    /** Require numbers */
    require_numbers: boolean;
    /** Require special characters */
    require_symbols: boolean;
    /** Password history check */
    prevent_reuse_count: number;
    /** Password expiration (days, 0 = never) */
    expiration_days: number;
  };
  /** Email settings */
  email: {
    /** From email address */
    from_address: string;
    /** From display name */
    from_name: string;
    /** Email service provider */
    provider: 'smtp' | 'sendgrid' | 'ses' | 'mailgun';
    /** Send welcome emails */
    send_welcome_emails: boolean;
    /** Send security alerts */
    send_security_alerts: boolean;
  };
  /** Security settings */
  security: {
    /** Enable rate limiting */
    rate_limiting_enabled: boolean;
    /** Rate limit requests per minute */
    rate_limit_per_minute: number;
    /** Enable IP whitelisting */
    ip_whitelisting_enabled: boolean;
    /** Whitelisted IP addresses */
    whitelisted_ips: string[];
    /** Enable security headers */
    security_headers_enabled: boolean;
    /** CORS allowed origins */
    cors_allowed_origins: string[];
  };
  /** Maintenance settings */
  maintenance: {
    /** Maintenance mode enabled */
    enabled: boolean;
    /** Maintenance message */
    message?: string;
    /** Scheduled maintenance start */
    scheduled_start?: string;
    /** Scheduled maintenance end */
    scheduled_end?: string;
    /** Allow admin access during maintenance */
    allow_admin_access: boolean;
  };
  /** Logging settings */
  logging: {
    /** Log level */
    level: 'debug' | 'info' | 'warning' | 'error';
    /** Enable audit logging */
    audit_logging_enabled: boolean;
    /** Log retention period (days) */
    retention_days: number;
    /** Enable performance logging */
    performance_logging_enabled: boolean;
  };
}

/**
 * System settings update request
 */
export interface UpdateSystemSettingsRequest extends Partial<SystemSettings> {
  /** Reason for the update */
  update_reason?: string;
  /** Send notification to other admins */
  notify_admins?: boolean;
}

// ================================
// Admin Action Types
// ================================

/**
 * Admin actions for audit logging and permissions
 */
export const ADMIN_ACTIONS = {
  // User management
  USER_VIEW: 'admin:user:view',
  USER_CREATE: 'admin:user:create',
  USER_UPDATE: 'admin:user:update',
  USER_DELETE: 'admin:user:delete',
  USER_ACTIVATE: 'admin:user:activate',
  USER_DEACTIVATE: 'admin:user:deactivate',
  USER_VERIFY: 'admin:user:verify',
  USER_LOCK: 'admin:user:lock',
  USER_UNLOCK: 'admin:user:unlock',
  USER_IMPERSONATE: 'admin:user:impersonate',
  USER_RESET_PASSWORD: 'admin:user:reset_password',
  USER_BULK_OPERATION: 'admin:user:bulk_operation',
  
  // Role management
  ROLE_VIEW: 'admin:role:view',
  ROLE_CREATE: 'admin:role:create',
  ROLE_UPDATE: 'admin:role:update',
  ROLE_DELETE: 'admin:role:delete',
  ROLE_ASSIGN_USER: 'admin:role:assign_user',
  ROLE_REMOVE_USER: 'admin:role:remove_user',
  ROLE_ASSIGN_PERMISSION: 'admin:role:assign_permission',
  ROLE_REMOVE_PERMISSION: 'admin:role:remove_permission',
  
  // Permission management
  PERMISSION_VIEW: 'admin:permission:view',
  PERMISSION_CREATE: 'admin:permission:create',
  PERMISSION_UPDATE: 'admin:permission:update',
  PERMISSION_DELETE: 'admin:permission:delete',
  
  // Audit logs
  AUDIT_VIEW: 'admin:audit:view',
  AUDIT_EXPORT: 'admin:audit:export',
  
  // System management
  SYSTEM_VIEW_SETTINGS: 'admin:system:view_settings',
  SYSTEM_UPDATE_SETTINGS: 'admin:system:update_settings',
  SYSTEM_VIEW_STATS: 'admin:system:view_stats',
  SYSTEM_MAINTENANCE: 'admin:system:maintenance',
  SYSTEM_BACKUP: 'admin:system:backup',
  SYSTEM_RESTORE: 'admin:system:restore',
} as const;

export type AdminAction = (typeof ADMIN_ACTIONS)[keyof typeof ADMIN_ACTIONS];

/**
 * Admin permission resources
 */
export const ADMIN_RESOURCES = {
  DASHBOARD: 'dashboard',
  USERS: 'users',
  ROLES: 'roles',
  PERMISSIONS: 'permissions',
  AUDIT_LOGS: 'audit_logs',
  SYSTEM_SETTINGS: 'system_settings',
  SECURITY: 'security',
} as const;

export type AdminResource = (typeof ADMIN_RESOURCES)[keyof typeof ADMIN_RESOURCES];

// ================================
// UI State Types
// ================================

/**
 * Generic table state for admin interfaces
 * @template T - Type of table data items
 */
export interface AdminTableState<T> {
  /** Table data */
  data: T[];
  /** Loading state */
  loading: boolean;
  /** Error state */
  error: string | null;
  /** Pagination info */
  pagination: {
    page: number;
    per_page: number;
    total: number;
    pages: number;
  };
  /** Sort configuration */
  sort: SortConfig;
  /** Applied filters */
  filters: Record<string, unknown>;
  /** Selected items */
  selected: string[];
  /** Selection mode */
  selection_mode: 'none' | 'single' | 'multiple';
}

/**
 * Admin panel navigation item
 */
export interface AdminNavItem {
  /** Unique identifier */
  id: string;
  /** Display label */
  label: string;
  /** Navigation path */
  path: string;
  /** Icon name or component */
  icon?: string;
  /** Required permissions */
  permissions?: AdminAction[];
  /** Child navigation items */
  children?: AdminNavItem[];
  /** Whether item is active */
  active?: boolean;
  /** Badge/notification count */
  badge?: number;
  /** External link indicator */
  external?: boolean;
}

/**
 * Admin notification/alert
 */
export interface AdminNotification {
  /** Unique notification ID */
  id: string;
  /** Notification type */
  type: 'info' | 'success' | 'warning' | 'error';
  /** Title */
  title: string;
  /** Message content */
  message: string;
  /** Timestamp */
  timestamp: string;
  /** Whether notification has been read */
  read: boolean;
  /** Associated action/link */
  action?: {
    label: string;
    url: string;
  };
  /** Auto-dismiss timeout (milliseconds) */
  auto_dismiss?: number;
}

/**
 * Admin breadcrumb item
 */
export interface AdminBreadcrumb {
  /** Display label */
  label: string;
  /** Navigation path (optional for last item) */
  path?: string;
  /** Whether item is active/current */
  active?: boolean;
}

// ================================
// Export Types
// ================================

// Enums and constants are already exported above

/**
 * Union of all admin filter types
 */
export type AdminFilters = 
  | UserFilters 
  | RoleFilters 
  | PermissionFilters 
  | AuditLogFilters;

/**
 * Union of all admin create request types
 */
export type AdminCreateRequest = 
  | AdminCreateUserRequest 
  | AdminCreateRoleRequest 
  | AdminCreatePermissionRequest;

/**
 * Union of all admin update request types
 */
export type AdminUpdateRequest = 
  | AdminUpdateUserRequest 
  | AdminUpdateRoleRequest 
  | UpdateSystemSettingsRequest;