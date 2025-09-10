/**
 * Admin Store using Zustand
 * 
 * Manages admin dashboard state, user management, roles, permissions,
 * audit logs, system settings, and administrative operations.
 */

import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { 
  AdminDashboardStats,
  UserStats,
  UserFilters,
  CreateUserRequest,
  UpdateUserRequest,
  BulkUserOperation,
  BulkOperationResult,
  RoleFilters,
  CreateRoleRequest,
  UpdateRoleRequest,
  RoleWithUserCount,
  PermissionFilters,
  CreatePermissionRequest,
  UpdatePermissionRequest,
  PermissionWithRoleCount,
  AuditLogFilters,
  AuditLogStats,
  SystemSettings,
  UpdateSystemSettingsRequest,
  TableSort,
  TablePagination,
  AdminAction,
  AdminResource,
  User,
  ApiResponse,
  PaginatedResponse,
} from '@/types';

// Audit log entry interface
export interface AuditLogEntry {
  id: string;
  user_id: string;
  user_name: string;
  action: AdminAction;
  resource_type: AdminResource;
  resource_id?: string;
  ip_address: string;
  user_agent: string;
  timestamp: string;
  details?: Record<string, unknown>;
  changes?: {
    before: Record<string, unknown>;
    after: Record<string, unknown>;
  };
}

// System health interface
export interface SystemHealth {
  status: 'healthy' | 'warning' | 'critical';
  uptime: number;
  cpu_usage: number;
  memory_usage: number;
  disk_usage: number;
  database_status: 'connected' | 'disconnected' | 'slow';
  redis_status: 'connected' | 'disconnected' | 'slow';
  email_service_status: 'operational' | 'degraded' | 'down';
  last_backup: string;
  active_sessions: number;
  error_rate: number;
  response_time: number;
}

// Admin error interface
export interface AdminError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: Date;
  context?: string;
}

// View states for admin panels
export type AdminViewState = 
  | 'dashboard' 
  | 'users' 
  | 'roles' 
  | 'permissions' 
  | 'audit-logs' 
  | 'settings' 
  | 'system-health';

// Admin store state interface
export interface AdminState {
  // Current view and navigation
  currentView: AdminViewState;
  isLoading: boolean;
  isSaving: boolean;
  
  // Dashboard statistics
  dashboardStats: AdminDashboardStats | null;
  systemHealth: SystemHealth | null;
  
  // User management
  users: User[];
  usersPagination: TablePagination;
  usersSort: TableSort;
  usersFilters: UserFilters;
  selectedUsers: string[];
  userStats: UserStats | null;
  
  // Role management
  roles: RoleWithUserCount[];
  rolesPagination: TablePagination;
  rolesSort: TableSort;
  rolesFilters: RoleFilters;
  selectedRoles: string[];
  
  // Permission management
  permissions: PermissionWithRoleCount[];
  permissionsPagination: TablePagination;
  permissionsSort: TableSort;
  permissionsFilters: PermissionFilters;
  selectedPermissions: string[];
  
  // Audit logs
  auditLogs: AuditLogEntry[];
  auditLogsPagination: TablePagination;
  auditLogsSort: TableSort;
  auditLogsFilters: AuditLogFilters;
  auditStats: AuditLogStats | null;
  
  // System settings
  systemSettings: SystemSettings | null;
  
  // Error handling
  error: AdminError | null;
  errors: AdminError[];
  
  // Bulk operations
  bulkOperationProgress: {
    isRunning: boolean;
    operation: string;
    processed: number;
    total: number;
    errors: string[];
  };
  
  // Actions
  // Navigation
  setCurrentView: (view: AdminViewState) => void;
  
  // Dashboard actions
  fetchDashboardStats: () => Promise<void>;
  fetchSystemHealth: () => Promise<void>;
  refreshDashboard: () => Promise<void>;
  
  // User management actions
  fetchUsers: (params?: { page?: number; filters?: UserFilters; sort?: TableSort }) => Promise<void>;
  createUser: (userData: CreateUserRequest) => Promise<boolean>;
  updateUser: (userId: string, data: UpdateUserRequest) => Promise<boolean>;
  deleteUser: (userId: string) => Promise<boolean>;
  toggleUserSelection: (userId: string) => void;
  selectAllUsers: (select: boolean) => void;
  setUsersFilters: (filters: Partial<UserFilters>) => void;
  setUsersSort: (sort: TableSort) => void;
  clearUsersFilters: () => void;
  
  // Role management actions
  fetchRoles: (params?: { page?: number; filters?: RoleFilters; sort?: TableSort }) => Promise<void>;
  createRole: (roleData: CreateRoleRequest) => Promise<boolean>;
  updateRole: (roleId: string, data: UpdateRoleRequest) => Promise<boolean>;
  deleteRole: (roleId: string) => Promise<boolean>;
  toggleRoleSelection: (roleId: string) => void;
  selectAllRoles: (select: boolean) => void;
  setRolesFilters: (filters: Partial<RoleFilters>) => void;
  setRolesSort: (sort: TableSort) => void;
  clearRolesFilters: () => void;
  
  // Permission management actions
  fetchPermissions: (params?: { page?: number; filters?: PermissionFilters; sort?: TableSort }) => Promise<void>;
  createPermission: (permissionData: CreatePermissionRequest) => Promise<boolean>;
  updatePermission: (permissionId: string, data: UpdatePermissionRequest) => Promise<boolean>;
  deletePermission: (permissionId: string) => Promise<boolean>;
  togglePermissionSelection: (permissionId: string) => void;
  selectAllPermissions: (select: boolean) => void;
  setPermissionsFilters: (filters: Partial<PermissionFilters>) => void;
  setPermissionsSort: (sort: TableSort) => void;
  clearPermissionsFilters: () => void;
  
  // Audit log actions
  fetchAuditLogs: (params?: { page?: number; filters?: AuditLogFilters; sort?: TableSort }) => Promise<void>;
  fetchAuditStats: () => Promise<void>;
  exportAuditLogs: (filters?: AuditLogFilters) => Promise<string>;
  setAuditLogsFilters: (filters: Partial<AuditLogFilters>) => void;
  setAuditLogsSort: (sort: TableSort) => void;
  clearAuditLogsFilters: () => void;
  
  // System settings actions
  fetchSystemSettings: () => Promise<void>;
  updateSystemSettings: (settings: UpdateSystemSettingsRequest) => Promise<boolean>;
  resetSystemSettings: () => Promise<boolean>;
  
  // Bulk operations
  executeBulkUserOperation: (operation: BulkUserOperation) => Promise<BulkOperationResult>;
  cancelBulkOperation: () => void;
  
  // System maintenance
  enableMaintenanceMode: (message?: string) => Promise<boolean>;
  disableMaintenanceMode: () => Promise<boolean>;
  clearSystemCache: () => Promise<boolean>;
  runSystemBackup: () => Promise<boolean>;
  
  // Error management
  setError: (error: AdminError | null) => void;
  clearError: () => void;
  addError: (error: AdminError) => void;
  clearErrors: () => void;
  
  // Utility actions
  refreshCurrentView: () => Promise<void>;
  clearAllData: () => void;
}

// Mock API functions - replace with actual API calls
const AdminAPI = {
  async fetchDashboardStats(): Promise<ApiResponse<AdminDashboardStats>> {
    await new Promise(resolve => setTimeout(resolve, 800));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async fetchSystemHealth(): Promise<ApiResponse<SystemHealth>> {
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async fetchUsers(): Promise<ApiResponse<PaginatedResponse<User>>> {
    await new Promise(resolve => setTimeout(resolve, 600));
    return { 
      success: true, 
      data: { 
        items: [], 
        total: 0, 
        page: 1, 
        per_page: 10, 
        pages: 0, 
        has_next: false, 
        has_prev: false 
      } 
    };
  },
  
  async createUser(): Promise<ApiResponse<User>> {
    await new Promise(resolve => setTimeout(resolve, 800));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async updateUser(): Promise<ApiResponse<User>> {
    await new Promise(resolve => setTimeout(resolve, 600));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async deleteUser(): Promise<ApiResponse<{ message: string }>> {
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: { message: 'User deleted successfully' } };
  },
  
  async fetchRoles(): Promise<ApiResponse<PaginatedResponse<RoleWithUserCount>>> {
    await new Promise(resolve => setTimeout(resolve, 600));
    return { 
      success: true, 
      data: { 
        items: [], 
        total: 0, 
        page: 1, 
        per_page: 10, 
        pages: 0, 
        has_next: false, 
        has_prev: false 
      } 
    };
  },
  
  async fetchPermissions(): Promise<ApiResponse<PaginatedResponse<PermissionWithRoleCount>>> {
    await new Promise(resolve => setTimeout(resolve, 600));
    return { 
      success: true, 
      data: { 
        items: [], 
        total: 0, 
        page: 1, 
        per_page: 10, 
        pages: 0, 
        has_next: false, 
        has_prev: false 
      } 
    };
  },
  
  async fetchAuditLogs(): Promise<ApiResponse<PaginatedResponse<AuditLogEntry>>> {
    await new Promise(resolve => setTimeout(resolve, 600));
    return { 
      success: true, 
      data: { 
        items: [], 
        total: 0, 
        page: 1, 
        per_page: 10, 
        pages: 0, 
        has_next: false, 
        has_prev: false 
      } 
    };
  },
  
  async fetchSystemSettings(): Promise<ApiResponse<SystemSettings>> {
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async updateSystemSettings(): Promise<ApiResponse<SystemSettings>> {
    await new Promise(resolve => setTimeout(resolve, 800));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async executeBulkOperation(operation: BulkUserOperation): Promise<ApiResponse<BulkOperationResult>> {
    await new Promise(resolve => setTimeout(resolve, 2000));
    return { 
      success: true, 
      data: { 
        success: true, 
        processed: operation.user_ids.length, 
        failed: 0, 
        errors: [] 
      } 
    };
  }
};

export const useAdminStore = create<AdminState>()(
  devtools(
    subscribeWithSelector(
      persist(
        immer((set, get) => ({
          // Initial state
          currentView: 'dashboard',
          isLoading: false,
          isSaving: false,
          dashboardStats: null,
          systemHealth: null,
          
          // User management
          users: [],
          usersPagination: {
            page: 1,
            size: 10,
            total: 0,
            pages: 0,
          },
          usersSort: {
            field: 'created_at',
            direction: 'desc',
          },
          usersFilters: {},
          selectedUsers: [],
          userStats: null,
          
          // Role management
          roles: [],
          rolesPagination: {
            page: 1,
            size: 10,
            total: 0,
            pages: 0,
          },
          rolesSort: {
            field: 'name',
            direction: 'asc',
          },
          rolesFilters: {},
          selectedRoles: [],
          
          // Permission management
          permissions: [],
          permissionsPagination: {
            page: 1,
            size: 10,
            total: 0,
            pages: 0,
          },
          permissionsSort: {
            field: 'resource',
            direction: 'asc',
          },
          permissionsFilters: {},
          selectedPermissions: [],
          
          // Audit logs
          auditLogs: [],
          auditLogsPagination: {
            page: 1,
            size: 20,
            total: 0,
            pages: 0,
          },
          auditLogsSort: {
            field: 'timestamp',
            direction: 'desc',
          },
          auditLogsFilters: {},
          auditStats: null,
          
          // System settings
          systemSettings: null,
          
          // Error handling
          error: null,
          errors: [],
          
          // Bulk operations
          bulkOperationProgress: {
            isRunning: false,
            operation: '',
            processed: 0,
            total: 0,
            errors: [],
          },
          
          // Navigation actions
          setCurrentView: (view: AdminViewState) => {
            set((state) => {
              state.currentView = view;
            });
          },
          
          // Dashboard actions
          fetchDashboardStats: async () => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.fetchDashboardStats();
              if (response.success && response.data) {
                set((state) => {
                  state.dashboardStats = response.data || null;
                });
              }
            } catch (error) {
              const adminError: AdminError = {
                code: 'FETCH_DASHBOARD_STATS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch dashboard statistics',
                timestamp: new Date(),
                context: 'dashboard',
              };
              get().setError(adminError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          fetchSystemHealth: async () => {
            try {
              const response = await AdminAPI.fetchSystemHealth();
              if (response.success && response.data) {
                set((state) => {
                  state.systemHealth = response.data || null;
                });
              }
            } catch {
              // Mock API - suppress error handling
            }
          },
          
          refreshDashboard: async () => {
            await Promise.all([
              get().fetchDashboardStats(),
              get().fetchSystemHealth(),
            ]);
          },
          
          // User management actions
          fetchUsers: async (_unusedParams = {}) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              // In a real implementation, we would use these params
              // const currentState = get();
              // const requestParams = {
              //   page: params.page || currentState.usersPagination.page,
              //   filters: { ...currentState.usersFilters, ...params.filters },
              //   sort: params.sort || currentState.usersSort,
              // };
              
              const response = await AdminAPI.fetchUsers();
              if (response.success && response.data) {
                set((state) => {
                  state.users = response.data?.items || [];
                  state.usersPagination = {
                    page: response.data?.page || 1,
                    size: response.data?.per_page || 10,
                    total: response.data?.total || 0,
                    pages: response.data?.pages || 0,
                  };
                });
              }
            } catch (error) {
              const adminError: AdminError = {
                code: 'FETCH_USERS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch users',
                timestamp: new Date(),
                context: 'users',
              };
              get().setError(adminError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          createUser: async (_unusedUserData: CreateUserRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.createUser();
              if (response.success) {
                await get().fetchUsers(); // Refresh user list
                return true;
              }
              return false;
            } catch (error) {
              const adminError: AdminError = {
                code: 'CREATE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create user',
                timestamp: new Date(),
                context: 'users',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          updateUser: async (_unusedUserId: string, _unusedData: UpdateUserRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.updateUser();
              if (response.success) {
                await get().fetchUsers(); // Refresh user list
                return true;
              }
              return false;
            } catch (error) {
              const adminError: AdminError = {
                code: 'UPDATE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update user',
                timestamp: new Date(),
                context: 'users',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          deleteUser: async (userId: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.deleteUser();
              if (response.success) {
                set((state) => {
                  state.users = state.users.filter(user => user.id !== userId);
                  state.selectedUsers = state.selectedUsers.filter(id => id !== userId);
                });
                await get().fetchUsers(); // Refresh user list
                return true;
              }
              return false;
            } catch (error) {
              const adminError: AdminError = {
                code: 'DELETE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete user',
                timestamp: new Date(),
                context: 'users',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          toggleUserSelection: (userId: string) => {
            set((state) => {
              const index = state.selectedUsers.indexOf(userId);
              if (index === -1) {
                state.selectedUsers.push(userId);
              } else {
                state.selectedUsers.splice(index, 1);
              }
            });
          },
          
          selectAllUsers: (select: boolean) => {
            set((state) => {
              state.selectedUsers = select ? state.users.map(user => user.id) : [];
            });
          },
          
          setUsersFilters: (filters: Partial<UserFilters>) => {
            set((state) => {
              state.usersFilters = { ...state.usersFilters, ...filters };
            });
          },
          
          setUsersSort: (sort: TableSort) => {
            set((state) => {
              state.usersSort = sort;
            });
          },
          
          clearUsersFilters: () => {
            set((state) => {
              state.usersFilters = {};
              state.selectedUsers = [];
            });
          },
          
          // Role management actions (similar pattern)
          fetchRoles: async (_unusedParams = {}) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.fetchRoles();
              if (response.success && response.data) {
                set((state) => {
                  state.roles = response.data?.items || [];
                  state.rolesPagination = {
                    page: response.data?.page || 1,
                    size: response.data?.per_page || 10,
                    total: response.data?.total || 0,
                    pages: response.data?.pages || 0,
                  };
                });
              }
            } catch (error) {
              const adminError: AdminError = {
                code: 'FETCH_ROLES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch roles',
                timestamp: new Date(),
                context: 'roles',
              };
              get().setError(adminError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          createRole: async (_roleData: CreateRoleRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - simulate API call with role data
              // Creating role with provided data
              await new Promise(resolve => setTimeout(resolve, 800));
              await get().fetchRoles(); // Refresh role list
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'CREATE_ROLE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create role',
                timestamp: new Date(),
                context: 'roles',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          updateRole: async (_roleId: string, _data: UpdateRoleRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - simulate API call with role updates
              // Updating role with provided data
              await new Promise(resolve => setTimeout(resolve, 600));
              await get().fetchRoles(); // Refresh role list
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'UPDATE_ROLE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update role',
                timestamp: new Date(),
                context: 'roles',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          deleteRole: async (roleId: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 500));
              set((state) => {
                state.roles = state.roles.filter(role => role.id !== roleId);
                state.selectedRoles = state.selectedRoles.filter(id => id !== roleId);
              });
              await get().fetchRoles(); // Refresh role list
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'DELETE_ROLE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete role',
                timestamp: new Date(),
                context: 'roles',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          toggleRoleSelection: (roleId: string) => {
            set((state) => {
              const index = state.selectedRoles.indexOf(roleId);
              if (index === -1) {
                state.selectedRoles.push(roleId);
              } else {
                state.selectedRoles.splice(index, 1);
              }
            });
          },
          
          selectAllRoles: (select: boolean) => {
            set((state) => {
              state.selectedRoles = select ? state.roles.map(role => role.id) : [];
            });
          },
          
          setRolesFilters: (filters: Partial<RoleFilters>) => {
            set((state) => {
              state.rolesFilters = { ...state.rolesFilters, ...filters };
            });
          },
          
          setRolesSort: (sort: TableSort) => {
            set((state) => {
              state.rolesSort = sort;
            });
          },
          
          clearRolesFilters: () => {
            set((state) => {
              state.rolesFilters = {};
              state.selectedRoles = [];
            });
          },
          
          // Permission management actions (similar pattern)
          fetchPermissions: async (_unusedParams = {}) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.fetchPermissions();
              if (response.success && response.data) {
                set((state) => {
                  state.permissions = response.data?.items || [];
                  state.permissionsPagination = {
                    page: response.data?.page || 1,
                    size: response.data?.per_page || 10,
                    total: response.data?.total || 0,
                    pages: response.data?.pages || 0,
                  };
                });
              }
            } catch (error) {
              const adminError: AdminError = {
                code: 'FETCH_PERMISSIONS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch permissions',
                timestamp: new Date(),
                context: 'permissions',
              };
              get().setError(adminError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          createPermission: async (_permissionData: CreatePermissionRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - simulate API call with permission data
              // Creating permission with provided data
              await new Promise(resolve => setTimeout(resolve, 600));
              await get().fetchPermissions();
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'CREATE_PERMISSION_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create permission',
                timestamp: new Date(),
                context: 'permissions',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          updatePermission: async (_permissionId: string, _data: UpdatePermissionRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - simulate API call with permission updates
              // Updating permission with provided data
              await new Promise(resolve => setTimeout(resolve, 500));
              await get().fetchPermissions();
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'UPDATE_PERMISSION_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update permission',
                timestamp: new Date(),
                context: 'permissions',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          deletePermission: async (permissionId: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 400));
              set((state) => {
                state.permissions = state.permissions.filter(perm => perm.id !== permissionId);
                state.selectedPermissions = state.selectedPermissions.filter(id => id !== permissionId);
              });
              await get().fetchPermissions();
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'DELETE_PERMISSION_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete permission',
                timestamp: new Date(),
                context: 'permissions',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          togglePermissionSelection: (permissionId: string) => {
            set((state) => {
              const index = state.selectedPermissions.indexOf(permissionId);
              if (index === -1) {
                state.selectedPermissions.push(permissionId);
              } else {
                state.selectedPermissions.splice(index, 1);
              }
            });
          },
          
          selectAllPermissions: (select: boolean) => {
            set((state) => {
              state.selectedPermissions = select ? state.permissions.map(perm => perm.id) : [];
            });
          },
          
          setPermissionsFilters: (filters: Partial<PermissionFilters>) => {
            set((state) => {
              state.permissionsFilters = { ...state.permissionsFilters, ...filters };
            });
          },
          
          setPermissionsSort: (sort: TableSort) => {
            set((state) => {
              state.permissionsSort = sort;
            });
          },
          
          clearPermissionsFilters: () => {
            set((state) => {
              state.permissionsFilters = {};
              state.selectedPermissions = [];
            });
          },
          
          // Audit log actions
          fetchAuditLogs: async (_unusedParams = {}) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.fetchAuditLogs();
              if (response.success && response.data) {
                set((state) => {
                  state.auditLogs = response.data?.items || [];
                  state.auditLogsPagination = {
                    page: response.data?.page || 1,
                    size: response.data?.per_page || 20,
                    total: response.data?.total || 0,
                    pages: response.data?.pages || 0,
                  };
                });
              }
            } catch (error) {
              const adminError: AdminError = {
                code: 'FETCH_AUDIT_LOGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch audit logs',
                timestamp: new Date(),
                context: 'audit-logs',
              };
              get().setError(adminError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          fetchAuditStats: async () => {
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 500));
            } catch {
              // Mock API - suppress error handling
            }
          },
          
          exportAuditLogs: async (_filters?: AuditLogFilters) => {
            try {
              // Mock implementation - would return CSV or JSON data
              // Exporting audit logs with filters
              await new Promise(resolve => setTimeout(resolve, 1000));
              return 'timestamp,user,action,resource\n2023-01-01,admin,user:create,user:123';
            } catch (error) {
              const adminError: AdminError = {
                code: 'EXPORT_AUDIT_LOGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to export audit logs',
                timestamp: new Date(),
                context: 'audit-logs',
              };
              get().setError(adminError);
              return '';
            }
          },
          
          setAuditLogsFilters: (filters: Partial<AuditLogFilters>) => {
            set((state) => {
              state.auditLogsFilters = { ...state.auditLogsFilters, ...filters };
            });
          },
          
          setAuditLogsSort: (sort: TableSort) => {
            set((state) => {
              state.auditLogsSort = sort;
            });
          },
          
          clearAuditLogsFilters: () => {
            set((state) => {
              state.auditLogsFilters = {};
            });
          },
          
          // System settings actions
          fetchSystemSettings: async () => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.fetchSystemSettings();
              if (response.success && response.data) {
                set((state) => {
                  state.systemSettings = response.data || null;
                });
              }
            } catch (error) {
              const adminError: AdminError = {
                code: 'FETCH_SYSTEM_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch system settings',
                timestamp: new Date(),
                context: 'settings',
              };
              get().setError(adminError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          updateSystemSettings: async (_unusedSettings: UpdateSystemSettingsRequest) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await AdminAPI.updateSystemSettings();
              if (response.success && response.data) {
                set((state) => {
                  state.systemSettings = response.data || null;
                });
                return true;
              }
              return false;
            } catch (error) {
              const adminError: AdminError = {
                code: 'UPDATE_SYSTEM_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update system settings',
                timestamp: new Date(),
                context: 'settings',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          resetSystemSettings: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 800));
              await get().fetchSystemSettings();
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'RESET_SYSTEM_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to reset system settings',
                timestamp: new Date(),
                context: 'settings',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // Bulk operations
          executeBulkUserOperation: async (operation: BulkUserOperation) => {
            set((state) => {
              state.bulkOperationProgress = {
                isRunning: true,
                operation: operation.operation,
                processed: 0,
                total: operation.user_ids.length,
                errors: [],
              };
            });
            
            try {
              const response = await AdminAPI.executeBulkOperation(operation);
              if (response.success && response.data) {
                set((state) => {
                  state.bulkOperationProgress.processed = response.data?.processed || 0;
                });
                
                // Refresh users after bulk operation
                await get().fetchUsers();
                
                return response.data;
              }
              
              return {
                success: false,
                processed: 0,
                failed: operation.user_ids.length,
                errors: [{ user_id: '', error: 'Operation failed' }],
              };
            } catch (error) {
              const adminError: AdminError = {
                code: 'BULK_OPERATION_ERROR',
                message: error instanceof Error ? error.message : 'Bulk operation failed',
                timestamp: new Date(),
                context: 'users',
              };
              get().setError(adminError);
              
              return {
                success: false,
                processed: 0,
                failed: operation.user_ids.length,
                errors: [{ user_id: '', error: adminError.message }],
              };
            } finally {
              set((state) => {
                state.bulkOperationProgress.isRunning = false;
              });
            }
          },
          
          cancelBulkOperation: () => {
            set((state) => {
              state.bulkOperationProgress = {
                isRunning: false,
                operation: '',
                processed: 0,
                total: 0,
                errors: [],
              };
            });
          },
          
          // System maintenance
          enableMaintenanceMode: async (message?: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 500));
              await get().updateSystemSettings({
                maintenance_mode: true,
                ...(message !== undefined ? { maintenance_message: message } : {}),
              });
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'ENABLE_MAINTENANCE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to enable maintenance mode',
                timestamp: new Date(),
                context: 'settings',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          disableMaintenanceMode: async () => {
            return await get().updateSystemSettings({
              maintenance_mode: false,
            });
          },
          
          clearSystemCache: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 1000));
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'CLEAR_CACHE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to clear system cache',
                timestamp: new Date(),
                context: 'system',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          runSystemBackup: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 3000));
              return true;
            } catch (error) {
              const adminError: AdminError = {
                code: 'SYSTEM_BACKUP_ERROR',
                message: error instanceof Error ? error.message : 'Failed to run system backup',
                timestamp: new Date(),
                context: 'system',
              };
              get().setError(adminError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // Error management
          setError: (error: AdminError | null) => {
            set((state) => {
              state.error = error;
              if (error) {
                state.errors.push(error);
                // Keep only last 10 errors
                if (state.errors.length > 10) {
                  state.errors = state.errors.slice(-10);
                }
              }
            });
          },
          
          clearError: () => {
            set((state) => {
              state.error = null;
            });
          },
          
          addError: (error: AdminError) => {
            set((state) => {
              state.errors.push(error);
              // Keep only last 10 errors
              if (state.errors.length > 10) {
                state.errors = state.errors.slice(-10);
              }
            });
          },
          
          clearErrors: () => {
            set((state) => {
              state.errors = [];
            });
          },
          
          // Utility actions
          refreshCurrentView: async () => {
            const currentView = get().currentView;
            
            switch (currentView) {
              case 'dashboard':
                await get().refreshDashboard();
                break;
              case 'users':
                await get().fetchUsers();
                break;
              case 'roles':
                await get().fetchRoles();
                break;
              case 'permissions':
                await get().fetchPermissions();
                break;
              case 'audit-logs':
                await Promise.all([
                  get().fetchAuditLogs(),
                  get().fetchAuditStats(),
                ]);
                break;
              case 'settings':
                await get().fetchSystemSettings();
                break;
              case 'system-health':
                await get().fetchSystemHealth();
                break;
              default:
                break;
            }
          },
          
          clearAllData: () => {
            set((state) => {
              // Reset to initial state
              state.dashboardStats = null;
              state.systemHealth = null;
              state.users = [];
              state.roles = [];
              state.permissions = [];
              state.auditLogs = [];
              state.systemSettings = null;
              state.selectedUsers = [];
              state.selectedRoles = [];
              state.selectedPermissions = [];
              state.error = null;
              state.errors = [];
              state.bulkOperationProgress = {
                isRunning: false,
                operation: '',
                processed: 0,
                total: 0,
                errors: [],
              };
            });
          },
        })),
        {
          name: 'admin-storage',
          // Persist only UI preferences and filters
          partialize: (state) => ({
            currentView: state.currentView,
            usersFilters: state.usersFilters,
            usersSort: state.usersSort,
            rolesFilters: state.rolesFilters,
            rolesSort: state.rolesSort,
            permissionsFilters: state.permissionsFilters,
            permissionsSort: state.permissionsSort,
            auditLogsFilters: state.auditLogsFilters,
            auditLogsSort: state.auditLogsSort,
          }),
        }
      )
    ),
    {
      name: 'AdminStore',
    }
  )
);

// Selector hooks for common use cases
export const useAdminCurrentView = () => useAdminStore((state) => state.currentView);
export const useAdminLoading = () => useAdminStore((state) => state.isLoading);
export const useAdminError = () => useAdminStore((state) => state.error);
export const useDashboardStats = () => useAdminStore((state) => state.dashboardStats);
export const useSystemHealth = () => useAdminStore((state) => state.systemHealth);
export const useAdminUsers = () => useAdminStore((state) => ({
  users: state.users,
  pagination: state.usersPagination,
  selectedUsers: state.selectedUsers,
  filters: state.usersFilters,
  sort: state.usersSort,
}));

// Helper hooks for common admin patterns
export const useAdmin = useAdminStore;

export function useAdminDashboard() {
  const store = useAdminStore();
  
  return {
    stats: store.dashboardStats,
    systemHealth: store.systemHealth,
    isLoading: store.isLoading,
    error: store.error,
    fetchStats: store.fetchDashboardStats,
    fetchHealth: store.fetchSystemHealth,
    refresh: store.refreshDashboard,
  };
}

export function useAdminUserManagement() {
  const store = useAdminStore();
  
  return {
    users: store.users,
    pagination: store.usersPagination,
    selectedUsers: store.selectedUsers,
    filters: store.usersFilters,
    sort: store.usersSort,
    isLoading: store.isLoading,
    isSaving: store.isSaving,
    error: store.error,
    
    // Actions
    fetchUsers: store.fetchUsers,
    createUser: store.createUser,
    updateUser: store.updateUser,
    deleteUser: store.deleteUser,
    toggleSelection: store.toggleUserSelection,
    selectAll: store.selectAllUsers,
    setFilters: store.setUsersFilters,
    setSort: store.setUsersSort,
    clearFilters: store.clearUsersFilters,
    bulkOperation: store.executeBulkUserOperation,
  };
}

export function useAdminSystemSettings() {
  const store = useAdminStore();
  
  return {
    settings: store.systemSettings,
    isLoading: store.isLoading,
    isSaving: store.isSaving,
    error: store.error,
    
    // Actions
    fetch: store.fetchSystemSettings,
    update: store.updateSystemSettings,
    reset: store.resetSystemSettings,
    enableMaintenance: store.enableMaintenanceMode,
    disableMaintenance: store.disableMaintenanceMode,
    clearCache: store.clearSystemCache,
    runBackup: store.runSystemBackup,
  };
}