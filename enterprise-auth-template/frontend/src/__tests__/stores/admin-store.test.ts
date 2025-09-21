
import { renderHook, act } from '@testing-library/react';
import { useAdminStore } from '@/stores/admin.store';
jest.mock('@/lib/api-client', () => ({
  apiClient: {
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
  },
jest.mock('@/lib/admin-api', () => ({
  adminAPI: {
    getStats: jest.fn(),
    getUsers: jest.fn(),
    getUserById: jest.fn(),
    createUser: jest.fn(),
    setUser: jest.fn(),
    deleteUser: jest.fn(),
    getRoles: jest.fn(),
    getPermissions: jest.fn(),
    getAuditLogs: jest.fn(),
    getSystemHealth: jest.fn(),
  },
/**
 * @jest-environment jsdom
 */


// Mock API client
// Mock admin API
const mockAdminAPI = require('@/lib/admin-api').adminAPI;
describe('useAdminStore', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset store state
    useAdminStore.setState({
      stats: null,
      users: [],
      roles: [],
      permissions: [],
      auditLogs: [],
      systemHealth: null,
      isLoading: false,
      error: null
    });
  });
  it('should have initial state', async () => {
    const { result } = renderHook(() => useAdminStore());
    expect(result.current.stats).toBeNull();
    expect(result.current.users).toEqual([]);
    expect(result.current.roles).toEqual([]);
    expect(result.current.permissions).toEqual([]);
    expect(result.current.auditLogs).toEqual([]);
    expect(result.current.systemHealth).toBeNull();
    expect(result.current.isLoading).toBe(false);
    expect(result.current.error).toBeNull();
  });

describe('fetchStats', () => {
    it('should fetch admin statistics successfully', async () => {
      const mockStats = {
        totalUsers: 1250,
        activeUsers: 892,
        totalSessions: 156,
        totalRoles: 5,
        systemHealth: 98.5,
        registrationsToday: 23,
        loginAttemptsToday: 445,
        failedLoginAttemptsToday: 12,
      };
      mockAdminAPI.getStats.mockResolvedValue({
        success: true,
        data: mockStats
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchStats();
      });
      expect(result.current.stats).toEqual(mockStats);
      expect(result.current.isLoading).toBe(false);
      expect(result.current.error).toBeNull();
    });
    it('should handle stats fetch errors', async () => {
      const errorMessage = 'Failed to fetch stats';
      mockAdminAPI.getStats.mockResolvedValue({
        success: false,
        error: { message: errorMessage }
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchStats();
      });
      expect(result.current.stats).toBeNull();
      expect(result.current.error).toEqual(expect.objectContaining({
        message: errorMessage,
      expect(result.current.isLoading).toBe(false);
    });
    it('should set loading state during fetch', async () => {
      let resolvePromise: (value: any) => void;
      const promise = new Promise(resolve => {
        resolvePromise = resolve;
      });
      mockAdminAPI.getStats.mockReturnValue(promise);
      const { result } = renderHook(() => useAdminStore());
      act(() => {
        result.current.fetchStats();
      });
      expect(result.current.isLoading).toBe(true);
      await act(async () => {
        resolvePromise!({ success: true, data: {} });
        await promise;
      });
      expect(result.current.isLoading).toBe(false);
    });
  });

describe('User Management', () => {
    it('should fetch users successfully', async () => {
      const mockUsers = [
        {
          id: '1',
          email: 'user1@example.com',
          full_name: 'User One',
          is_active: true,
          created_at: '2024-01-01T00:00:00Z',
          roles: [],
        },
        {
          id: '2',
          email: 'user2@example.com',
          full_name: 'User Two',
          is_active: false,
          created_at: '2024-01-02T00:00:00Z',
          roles: [],
        },
      ];
      mockAdminAPI.getUsers.mockResolvedValue({
        success: true,
        data: { users: mockUsers, total: 2 }
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchUsers();
      });
      expect(result.current.users).toEqual(mockUsers);
      expect(result.current.error).toBeNull();
    });
    it('should create user successfully', async () => {
      const newUser = {
        email: 'newuser@example.com',
        full_name: 'New User',
        password: 'securePassword123!',
        roles: ['user'],
      };
      const createdUser = {
        id: '3',
        ...newUser,
        is_active: true,
        created_at: '2024-01-03T00:00:00Z',
      };
      mockAdminAPI.createUser.mockResolvedValue({
        success: true,
        data: createdUser
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.createUser(newUser);
      });
      expect(result.current.users).toContainEqual(createdUser);
      expect(result.current.error).toBeNull();
    });
    it('should update user successfully', async () => {
      const existingUser = {
        id: '1',
        email: 'user@example.com',
        full_name: 'Original Name',
        is_active: true,
      };
      useAdminStore.setState({ users: [existingUser] });
      const updates = {
        full_name: 'Updated Name',
        is_active: false,
      };
      const updatedUser = { ...existingUser, ...updates };
      mockAdminAPI.setUser.mockResolvedValue({
        success: true,
        data: updatedUser
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.setUser('1', updates);
      });
      expect(result.current.users).toContainEqual(updatedUser);
      expect(result.current.error).toBeNull();
    });
    it('should delete user successfully', async () => {
      const users = [
        { id: '1', email: 'user1@example.com' },
        { id: '2', email: 'user2@example.com' },
      ];
      useAdminStore.setState({ users });
      mockAdminAPI.deleteUser.mockResolvedValue({
        success: true,
        data: { message: 'User deleted successfully' }
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.deleteUser('1');
      });
      expect(result.current.users).toHaveLength(1);
      expect(result.current.users[0].id).toBe('2');
      expect(result.current.error).toBeNull();
    });
    it('should handle user creation validation errors', async () => {
      const invalidUser = {
        email: 'invalid-email',
        full_name: '',
        password: '123',
      };
      mockAdminAPI.createUser.mockResolvedValue({
        success: false,
        error: {
          message: 'Validation failed',
          code: 'VALIDATION_ERROR',
          details: {
            email: 'Invalid email format',
            full_name: 'Full name is required',
            password: 'Password too weak',
          },
        }
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.createUser(invalidUser);
      });
      expect(result.current.error).toEqual(expect.objectContaining({
        code: 'VALIDATION_ERROR',
        details: expect.any(Object)
    });
  });

describe('Role and Permission Management', () => {
    it('should fetch roles successfully', async () => {
      const mockRoles = [
        {
          id: '1',
          name: 'admin',
          description: 'Administrator role',
          permissions: ['all'],
        },
        {
          id: '2',
          name: 'user',
          description: 'Standard user role',
          permissions: ['read'],
        },
      ];
      mockAdminAPI.getRoles.mockResolvedValue({
        success: true,
        data: mockRoles
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchRoles();
      });
      expect(result.current.roles).toEqual(mockRoles);
      expect(result.current.error).toBeNull();
    });
    it('should fetch permissions successfully', async () => {
      const mockPermissions = [
        {
          id: '1',
          name: 'users.read',
          description: 'Read user data',
          resource: 'users',
          action: 'read',
        },
        {
          id: '2',
          name: 'users.write',
          description: 'Modify user data',
          resource: 'users',
          action: 'write',
        },
      ];
      mockAdminAPI.getPermissions.mockResolvedValue({
        success: true,
        data: mockPermissions
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchPermissions();
      });
      expect(result.current.permissions).toEqual(mockPermissions);
      expect(result.current.error).toBeNull();
    });
  });

describe('Audit Logs', () => {
    it('should fetch audit logs successfully', async () => {
      const mockAuditLogs = [
        {
          id: '1',
          action: 'user.login',
          user_id: 'user123',
          details: { ip: '192.168.1.1' },
          timestamp: '2024-01-01T12:00:00Z',
        },
        {
          id: '2',
          action: 'user.logout',
          user_id: 'user123',
          details: { duration: 3600 },
          timestamp: '2024-01-01T13:00:00Z',
        },
      ];
      mockAdminAPI.getAuditLogs.mockResolvedValue({
        success: true,
        data: { logs: mockAuditLogs, total: 2 }
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchAuditLogs();
      });
      expect(result.current.auditLogs).toEqual(mockAuditLogs);
      expect(result.current.error).toBeNull();
    });
    it('should filter audit logs by date range', async () => {
      const mockFilteredLogs = [
        {
          id: '1',
          action: 'user.login',
          timestamp: '2024-01-01T12:00:00Z',
        },
      ];
      mockAdminAPI.getAuditLogs.mockResolvedValue({
        success: true,
        data: { logs: mockFilteredLogs, total: 1 }
      });
      const { result } = renderHook(() => useAdminStore());
      const filters = {
        startDate: '2024-01-01',
        endDate: '2024-01-01',
        action: 'user.login',
      };
      await act(async () => {
        await result.current.fetchAuditLogs(filters);
      });
      expect(mockAdminAPI.getAuditLogs).toHaveBeenCalledWith(filters);
      expect(result.current.auditLogs).toEqual(mockFilteredLogs);
    });
  });

describe('System Health', () => {
    it('should fetch system health successfully', async () => {
      const mockHealth = {
        status: 'healthy',
        uptime: 86400,
        memoryUsage: 65.5,
        cpuUsage: 23.1,
        diskUsage: 45.0,
        activeConnections: 127,
        lastBackup: '2024-01-01T02:00:00Z',
      };
      mockAdminAPI.getSystemHealth.mockResolvedValue({
        success: true,
        data: mockHealth
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchSystemHealth();
      });
      expect(result.current.systemHealth).toEqual(mockHealth);
      expect(result.current.error).toBeNull();
    });
    it('should handle unhealthy system status', async () => {
      const mockHealth = {
        status: 'degraded',
        uptime: 86400,
        memoryUsage: 95.5, // High memory usage
        cpuUsage: 89.1, // High CPU usage
        issues: ['High memory usage', 'Database slow'],
      };
      mockAdminAPI.getSystemHealth.mockResolvedValue({
        success: true,
        data: mockHealth
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchSystemHealth();
      });
      expect(result.current.systemHealth).toEqual(mockHealth);
      expect(result.current.systemHealth.status).toBe('degraded');
    });
  });

describe('Error Handling', () => {
    it('should handle network errors gracefully', async () => {
      mockAdminAPI.getStats.mockRejectedValue(new Error('Network error'));
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchStats();
      });
      expect(result.current.error).toEqual(expect.objectContaining({
        message: 'Network error',
      expect(result.current.isLoading).toBe(false);
    });
    it('should clear errors when new requests succeed', async () => {
      // First, set an error
      useAdminStore.setState({
        error: new Error('Previous error')
      });
      mockAdminAPI.getStats.mockResolvedValue({
        success: true,
        data: { totalUsers: 100 }
      });
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await result.current.fetchStats();
      });
      expect(result.current.error).toBeNull();
    });
    it('should handle concurrent request errors properly', async () => {
      mockAdminAPI.getStats.mockRejectedValue(new Error('Stats error'));
      mockAdminAPI.getUsers.mockRejectedValue(new Error('Users error'));
      const { result } = renderHook(() => useAdminStore());
      await act(async () => {
        await Promise.all([
          result.current.fetchStats(),
          result.current.fetchUsers(),
        ]);
      });
      // Should have one of the errors (implementation dependent)
      expect(result.current.error).not.toBeNull();
    });
  });

describe('Store Actions', () => {
    it('should clear error state', async () => {
      useAdminStore.setState({
        error: new Error('Test error')
      });
      const { result } = renderHook(() => useAdminStore());
      act(() => {
        result.current.clearError();
      });
      expect(result.current.error).toBeNull();
    });
    it('should reset store to initial state', async () => {
      useAdminStore.setState({
        stats: { totalUsers: 100 },
        users: [{ id: '1', email: 'test@example.com' }],
        error: new Error('Test error')
      });
      const { result } = renderHook(() => useAdminStore());
      act(() => {
        result.current.reset();
      });
      expect(result.current.stats).toBeNull();
      expect(result.current.users).toEqual([]);
      expect(result.current.error).toBeNull();
    });
  });

describe('Performance', () => {
    it('should handle large datasets efficiently', async () => {
      const largeUserList = Array.from({ length: 1000 }, (_, i) => ({
        id: `user${i}`,
        email: `user${i}@example.com`,
        full_name: `User ${i}`,
      mockAdminAPI.getUsers.mockResolvedValue({
        success: true,
        data: { users: largeUserList, total: 1000 }
      });
      const { result } = renderHook(() => useAdminStore());
      const startTime = performance.now();
      await act(async () => {
        await result.current.fetchUsers();
      });
      const endTime = performance.now();
      expect(result.current.users).toHaveLength(1000);
      expect(endTime - startTime).toBeLessThan(100); // Should be fast
    });
  });
});
}}}}}}