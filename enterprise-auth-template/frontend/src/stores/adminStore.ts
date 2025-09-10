import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

export interface SystemStats {
  totalUsers: number;
  activeUsers: number;
  newUsersToday: number;
  totalSessions: number;
  activeSessions: number;
  failedLogins: number;
  apiCalls: number;
  apiErrors: number;
  averageResponseTime: number;
  systemHealth: 'healthy' | 'degraded' | 'critical';
  lastUpdated: string;
}

export interface UserManagement {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  roles: string[];
  status: 'active' | 'inactive' | 'suspended' | 'locked';
  emailVerified: boolean;
  phoneVerified: boolean;
  twoFactorEnabled: boolean;
  permissions: string[];
  createdAt: string;
  lastLogin: string;
  loginCount: number;
  metadata?: Record<string, unknown>;
}

export interface AuditLog {
  id: string;
  userId: string;
  userEmail: string;
  action: string;
  resourceType: string;
  resourceId: string;
  ipAddress: string;
  userAgent: string;
  status: 'success' | 'failure';
  details: Record<string, unknown>;
  timestamp: string;
}

export interface SystemConfig {
  maxLoginAttempts: number;
  sessionTimeout: number;
  passwordMinLength: number;
  passwordRequireUppercase: boolean;
  passwordRequireLowercase: boolean;
  passwordRequireNumbers: boolean;
  passwordRequireSpecial: boolean;
  twoFactorRequired: boolean;
  emailVerificationRequired: boolean;
  maintenanceMode: boolean;
  maintenanceMessage: string;
  allowRegistration: boolean;
  allowPasswordReset: boolean;
  rateLimit: {
    enabled: boolean;
    requestsPerMinute: number;
    requestsPerHour: number;
  };
}

export interface Permission {
  id: string;
  name: string;
  resource: string;
  action: string;
  description: string;
}

export interface Role {
  id: string;
  name: string;
  description: string;
  permissions: Permission[];
  isSystem: boolean;
  priority: number;
  userCount: number;
}

interface AdminState {
  // State
  stats: SystemStats | null;
  users: UserManagement[];
  totalUsers: number;
  currentPage: number;
  pageSize: number;
  auditLogs: AuditLog[];
  systemConfig: SystemConfig | null;
  roles: Role[];
  permissions: Permission[];
  selectedUser: UserManagement | null;
  isLoading: boolean;
  error: string | null;
  filters: {
    users: {
      search: string;
      status: string;
      role: string;
      sortBy: string;
      sortOrder: 'asc' | 'desc';
    };
    auditLogs: {
      userId: string;
      action: string;
      resourceType: string;
      dateFrom: string;
      dateTo: string;
    };
  };

  // Actions - Statistics
  fetchStats: () => Promise<void>;
  refreshStats: () => Promise<void>;

  // Actions - User Management
  fetchUsers: (page?: number, limit?: number) => Promise<void>;
  searchUsers: (query: string) => Promise<void>;
  getUser: (userId: string) => Promise<void>;
  updateUserStatus: (userId: string, status: UserManagement['status']) => Promise<void>;
  updateUserRoles: (userId: string, roles: string[]) => Promise<void>;
  resetUserPassword: (userId: string) => Promise<void>;
  forceLogoutUser: (userId: string) => Promise<void>;
  unlockUser: (userId: string) => Promise<void>;
  deleteUser: (userId: string) => Promise<void>;
  impersonateUser: (userId: string) => Promise<void>;
  exportUsers: (format: 'csv' | 'json') => Promise<Blob>;
  importUsers: (file: File) => Promise<void>;

  // Actions - Audit Logs
  fetchAuditLogs: (page?: number, limit?: number) => Promise<void>;
  searchAuditLogs: (filters: AdminState['filters']['auditLogs']) => Promise<void>;
  exportAuditLogs: (format: 'csv' | 'json') => Promise<Blob>;

  // Actions - System Configuration
  fetchSystemConfig: () => Promise<void>;
  updateSystemConfig: (config: Partial<SystemConfig>) => Promise<void>;
  toggleMaintenanceMode: (enabled: boolean, message?: string) => Promise<void>;

  // Actions - Roles & Permissions
  fetchRoles: () => Promise<void>;
  fetchPermissions: () => Promise<void>;
  createRole: (role: Omit<Role, 'id' | 'userCount'>) => Promise<void>;
  updateRole: (roleId: string, updates: Partial<Role>) => Promise<void>;
  deleteRole: (roleId: string) => Promise<void>;
  assignPermissionToRole: (roleId: string, permissionId: string) => Promise<void>;
  removePermissionFromRole: (roleId: string, permissionId: string) => Promise<void>;

  // Actions - Bulk Operations
  bulkUpdateUserStatus: (userIds: string[], status: UserManagement['status']) => Promise<void>;
  bulkDeleteUsers: (userIds: string[]) => Promise<void>;
  bulkSendEmail: (userIds: string[], subject: string, content: string) => Promise<void>;

  // Actions - Filters
  setUserFilters: (filters: Partial<AdminState['filters']['users']>) => void;
  setAuditLogFilters: (filters: Partial<AdminState['filters']['auditLogs']>) => void;
  clearFilters: () => void;

  // Actions - UI State
  setSelectedUser: (user: UserManagement | null) => void;
  clearError: () => void;
}

const getAuthHeaders = () => ({
  Authorization: `Bearer ${localStorage.getItem('access_token')}`,
  'Content-Type': 'application/json',
});

export const useAdminStore = create<AdminState>()(
  devtools(
    (set, get) => ({
      // Initial state
      stats: null,
      users: [],
      totalUsers: 0,
      currentPage: 1,
      pageSize: 20,
      auditLogs: [],
      systemConfig: null,
      roles: [],
      permissions: [],
      selectedUser: null,
      isLoading: false,
      error: null,
      filters: {
        users: {
          search: '',
          status: 'all',
          role: 'all',
          sortBy: 'createdAt',
          sortOrder: 'desc',
        },
        auditLogs: {
          userId: '',
          action: '',
          resourceType: '',
          dateFrom: '',
          dateTo: '',
        },
      },

      // Statistics Actions
      fetchStats: async () => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/stats', {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch statistics');

          const stats = await response.json();
          set({ stats, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      refreshStats: async () => {
        await get().fetchStats();
      },

      // User Management Actions
      fetchUsers: async (page = 1, limit = 20) => {
        set({ isLoading: true, error: null });
        try {
          const filters = get().filters.users;
          const params = new URLSearchParams({
            page: page.toString(),
            limit: limit.toString(),
            ...(filters.search && { search: filters.search }),
            ...(filters.status !== 'all' && { status: filters.status }),
            ...(filters.role !== 'all' && { role: filters.role }),
            sortBy: filters.sortBy,
            sortOrder: filters.sortOrder,
          });

          const response = await fetch(`/api/v1/admin/users?${params}`, {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch users');

          const data = await response.json();
          set({ 
            users: data.users, 
            totalUsers: data.total || data.users.length,
            currentPage: page || 1,
            isLoading: false 
          });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      searchUsers: async (query) => {
        set((state) => ({
          filters: {
            ...state.filters,
            users: { ...state.filters.users, search: query },
          },
        }));
        await get().fetchUsers();
      },

      getUser: async (userId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}`, {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch user');

          const user = await response.json();
          set({ selectedUser: user, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      updateUserStatus: async (userId, status) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}/status`, {
            method: 'PATCH',
            headers: getAuthHeaders(),
            body: JSON.stringify({ status }),
          });

          if (!response.ok) throw new Error('Failed to update user status');

          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      updateUserRoles: async (userId, roles) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}/roles`, {
            method: 'PUT',
            headers: getAuthHeaders(),
            body: JSON.stringify({ roles }),
          });

          if (!response.ok) throw new Error('Failed to update user roles');

          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      resetUserPassword: async (userId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}/reset-password`, {
            method: 'POST',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to reset password');

          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      forceLogoutUser: async (userId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}/force-logout`, {
            method: 'POST',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to force logout user');

          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      unlockUser: async (userId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}/unlock`, {
            method: 'POST',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to unlock user');

          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      deleteUser: async (userId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}`, {
            method: 'DELETE',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to delete user');

          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      impersonateUser: async (userId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/${userId}/impersonate`, {
            method: 'POST',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to impersonate user');

          const data = await response.json();
          // Store impersonation token
          localStorage.setItem('impersonation_token', data.token);
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      exportUsers: async (format) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/users/export?format=${format}`, {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to export users');

          const blob = await response.blob();
          set({ isLoading: false });
          return blob;
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
          throw error;
        }
      },

      importUsers: async (file) => {
        set({ isLoading: true, error: null });
        try {
          const formData = new FormData();
          formData.append('file', file);

          const response = await fetch('/api/v1/admin/users/import', {
            method: 'POST',
            headers: getAuthHeaders(),
            body: formData,
          });

          if (!response.ok) throw new Error('Failed to import users');

          // Refresh users list after import
          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
          throw error;
        }
      },

      // Audit Log Actions
      fetchAuditLogs: async (page = 1, limit = 50) => {
        set({ isLoading: true, error: null });
        try {
          const filters = get().filters.auditLogs;
          const params = new URLSearchParams({
            page: page.toString(),
            limit: limit.toString(),
            ...(filters.userId && { user_id: filters.userId }),
            ...(filters.action && { action: filters.action }),
            ...(filters.resourceType && { resource_type: filters.resourceType }),
            ...(filters.dateFrom && { date_from: filters.dateFrom }),
            ...(filters.dateTo && { date_to: filters.dateTo }),
          });

          const response = await fetch(`/api/v1/admin/audit-logs?${params}`, {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch audit logs');

          const data = await response.json();
          set({ auditLogs: data.logs, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      searchAuditLogs: async (filters) => {
        set((state) => ({
          filters: {
            ...state.filters,
            auditLogs: { ...state.filters.auditLogs, ...filters },
          },
        }));
        await get().fetchAuditLogs();
      },

      exportAuditLogs: async (format) => {
        set({ isLoading: true, error: null });
        try {
          const filters = get().filters.auditLogs;
          const params = new URLSearchParams({
            format,
            ...(filters.userId && { user_id: filters.userId }),
            ...(filters.action && { action: filters.action }),
            ...(filters.resourceType && { resource_type: filters.resourceType }),
            ...(filters.dateFrom && { date_from: filters.dateFrom }),
            ...(filters.dateTo && { date_to: filters.dateTo }),
          });

          const response = await fetch(`/api/v1/admin/audit-logs/export?${params}`, {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to export audit logs');

          const blob = await response.blob();
          set({ isLoading: false });
          return blob;
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
          throw error;
        }
      },

      // System Configuration Actions
      fetchSystemConfig: async () => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/config', {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch system configuration');

          const config = await response.json();
          set({ systemConfig: config, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      updateSystemConfig: async (config) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/config', {
            method: 'PATCH',
            headers: getAuthHeaders(),
            body: JSON.stringify(config),
          });

          if (!response.ok) throw new Error('Failed to update system configuration');

          const updatedConfig = await response.json();
          set({ systemConfig: updatedConfig, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      toggleMaintenanceMode: async (enabled, message) => {
        await get().updateSystemConfig({
          maintenanceMode: enabled,
          ...(message && { maintenanceMessage: message }),
        });
      },

      // Roles & Permissions Actions
      fetchRoles: async () => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/roles', {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch roles');

          const roles = await response.json();
          set({ roles, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      fetchPermissions: async () => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/permissions', {
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to fetch permissions');

          const permissions = await response.json();
          set({ permissions, isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      createRole: async (role) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/roles', {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify(role),
          });

          if (!response.ok) throw new Error('Failed to create role');

          await get().fetchRoles();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      updateRole: async (roleId, updates) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/roles/${roleId}`, {
            method: 'PATCH',
            headers: getAuthHeaders(),
            body: JSON.stringify(updates),
          });

          if (!response.ok) throw new Error('Failed to update role');

          await get().fetchRoles();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      deleteRole: async (roleId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/roles/${roleId}`, {
            method: 'DELETE',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to delete role');

          await get().fetchRoles();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      assignPermissionToRole: async (roleId, permissionId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/roles/${roleId}/permissions/${permissionId}`, {
            method: 'POST',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to assign permission');

          await get().fetchRoles();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      removePermissionFromRole: async (roleId, permissionId) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch(`/api/v1/admin/roles/${roleId}/permissions/${permissionId}`, {
            method: 'DELETE',
            headers: getAuthHeaders(),
          });

          if (!response.ok) throw new Error('Failed to remove permission');

          await get().fetchRoles();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      // Bulk Operations
      bulkUpdateUserStatus: async (userIds, status) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/users/bulk/status', {
            method: 'PATCH',
            headers: getAuthHeaders(),
            body: JSON.stringify({ user_ids: userIds, status }),
          });

          if (!response.ok) throw new Error('Failed to update users');

          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      bulkDeleteUsers: async (userIds) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/users/bulk/delete', {
            method: 'DELETE',
            headers: getAuthHeaders(),
            body: JSON.stringify({ user_ids: userIds }),
          });

          if (!response.ok) throw new Error('Failed to delete users');

          await get().fetchUsers();
          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      bulkSendEmail: async (userIds, subject, content) => {
        set({ isLoading: true, error: null });
        try {
          const response = await fetch('/api/v1/admin/users/bulk/email', {
            method: 'POST',
            headers: getAuthHeaders(),
            body: JSON.stringify({ user_ids: userIds, subject, content }),
          });

          if (!response.ok) throw new Error('Failed to send emails');

          set({ isLoading: false });
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      // Filter Actions
      setUserFilters: (filters) => {
        set((state) => ({
          filters: {
            ...state.filters,
            users: { ...state.filters.users, ...filters },
          },
        }));
      },

      setAuditLogFilters: (filters) => {
        set((state) => ({
          filters: {
            ...state.filters,
            auditLogs: { ...state.filters.auditLogs, ...filters },
          },
        }));
      },

      clearFilters: () => {
        set({
          filters: {
            users: {
              search: '',
              status: 'all',
              role: 'all',
              sortBy: 'createdAt',
              sortOrder: 'desc',
            },
            auditLogs: {
              userId: '',
              action: '',
              resourceType: '',
              dateFrom: '',
              dateTo: '',
            },
          },
        });
      },

      // UI State Actions
      setSelectedUser: (user) => set({ selectedUser: user }),
      clearError: () => set({ error: null }),
    }),
    {
      name: 'AdminStore',
    }
  )
);