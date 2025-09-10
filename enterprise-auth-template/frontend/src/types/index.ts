// Export all types from a single entry point

// Primary exports - use these for main types
export * from './auth.types';
export * from './api.types';
export * from './admin.types';

// Secondary exports for compatibility (selective exports to avoid conflicts)
export type { 
  User as BasicUser,
  Role as BasicRole,
  Permission as BasicPermission
} from './auth';

export type {
  UserProfile,
  UserPreferences,
  UserActivity,
  UserStatistics,
  UserListParams
} from './user';

// Legacy exports for backwards compatibility
// These are exported with their original names to maintain compatibility
export type {
  // Auth types from auth.types.ts
  LoginRequest as LegacyLoginRequest,
  RegisterRequest as LegacyRegisterRequest,
  User as LegacyUser,
  Role as LegacyRole,
  Permission as LegacyPermission,
  LoginResponse as LegacyLoginResponse,
  TokenPair as LegacyTokenPair,
  TokenData as LegacyTokenData,
  RefreshTokenRequest as LegacyRefreshTokenRequest,
  ResetPasswordRequest as LegacyResetPasswordRequest,
  ConfirmResetPasswordRequest as LegacyConfirmResetPasswordRequest,
  ChangePasswordRequest as LegacyChangePasswordRequest,
  AuthState as LegacyAuthState,
  AuthActions as LegacyAuthActions,
  AuthContextType as LegacyAuthContextType,
  AuthError as LegacyAuthError,
  UserSession as LegacyUserSession,
  AuditLog as LegacyAuditLog,
} from './auth.types';

export type {
  // API types from api.types.ts
  ApiResponse as LegacyApiResponse,
  ApiError as LegacyApiError,
  ApiMetadata as LegacyApiMetadata,
  PaginatedResponse as LegacyPaginatedResponse,
  PaginationParams as LegacyPaginationParams,
  QueryParams as LegacyQueryParams,
  HttpMethod as LegacyHttpMethod,
  ApiConfig as LegacyApiConfig,
  RequestOptions as LegacyRequestOptions,
  FileUpload as LegacyFileUpload,
  UploadResponse as LegacyUploadResponse,
  HealthCheck as LegacyHealthCheck,
} from './api.types';

export type {
  // Admin types from admin.types.ts
  UserFilters as LegacyUserFilters,
  UserStats as LegacyUserStats,
  CreateUserRequest as LegacyCreateUserRequest,
  UpdateUserRequest as LegacyUpdateUserRequest,
  RoleFilters as LegacyRoleFilters,
  CreateRoleRequest as LegacyCreateRoleRequest,
  UpdateRoleRequest as LegacyUpdateRoleRequest,
  RoleWithUserCount as LegacyRoleWithUserCount,
  PermissionFilters as LegacyPermissionFilters,
  CreatePermissionRequest as LegacyCreatePermissionRequest,
  UpdatePermissionRequest as LegacyUpdatePermissionRequest,
  PermissionWithRoleCount as LegacyPermissionWithRoleCount,
  AuditLogFilters as LegacyAuditLogFilters,
  AuditLogStats as LegacyAuditLogStats,
  SystemSettings as LegacySystemSettings,
  UpdateSystemSettingsRequest as LegacyUpdateSystemSettingsRequest,
  BulkUserOperation as LegacyBulkUserOperation,
  BulkOperationResult as LegacyBulkOperationResult,
  AdminDashboardStats as LegacyAdminDashboardStats,
  TableSort as LegacyTableSort,
  TablePagination as LegacyTablePagination,
  TableState as LegacyTableState,
  AdminAction as LegacyAdminAction,
  AdminResource as LegacyAdminResource,
  PermissionAction as LegacyPermissionAction,
  AdminPermission as LegacyAdminPermission,
} from './admin.types';

// Global and environment types are imported automatically via .d.ts files
// No need to re-export them here as they're ambient declarations
