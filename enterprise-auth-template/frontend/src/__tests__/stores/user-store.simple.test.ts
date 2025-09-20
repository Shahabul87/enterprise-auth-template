
import { act, renderHook } from '@testing-library/react';
import { useUserStore } from '@/stores/user-store';

jest.mock('zustand/middleware', () => ({
  devtools: (fn: any) => fn,
  persist: (fn: any) => fn,
  subscribeWithSelector: (fn: any) => fn,
  immer: (fn: any) => fn,
// Orphaned closing removed
jest.mock('@/lib/api-client');


/**
 * @jest-environment jsdom
 */


// Mock zustand persist
// Mock API dependencies
describe('UserStore - Basic Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset store before each test
    const { result } = renderHook(() => useUserStore());
    act(() => {
      result.current.clearUserData();
    });
  });

describe('Initial State', () => {
    it('should have correct initial state', () => {
      const { result } = renderHook(() => useUserStore());
      expect(result.current.currentUser).toBeNull();
      expect(result.current.users).toEqual([]);
      expect(result.current.selectedUser).toBeNull();
      expect(result.current.isLoading).toBe(false);
      expect(result.current.isUpdating).toBe(false);
      expect(result.current.error).toBeNull();
      expect(result.current.errors).toEqual([]);
    });
    it('should have correct initial user list state', () => {
      const { result } = renderHook(() => useUserStore());
      expect(result.current.userList).toEqual({
        items: [],
        total: 0,
        page: 1,
        size: 10,
        pages: 0,
        has_next: false,
        has_prev: false,
      });
    });
    it('should have correct initial search and filter state', () => {
      const { result } = renderHook(() => useUserStore());
      expect(result.current.searchQuery).toBe('');
      expect(result.current.filters).toEqual({});
      expect(result.current.sortBy).toBe('created_at');
      expect(result.current.sortOrder).toBe('desc');
    });
  });

describe('Search and Filtering', () => {
    it('should set search query', () => {
      const { result } = renderHook(() => useUserStore());
      act(() => {
        result.current.setSearchQuery('test query');
      });
      expect(result.current.searchQuery).toBe('test query');
    });
    it('should set filters', () => {
      const { result } = renderHook(() => useUserStore());
      const filters = {
        is_active: true,
        role: 'admin',
      };
      act(() => {
        result.current.setFilters(filters);
      });
      expect(result.current.filters).toMatchObject(filters);
    });
    it('should set sorting', () => {
      const { result } = renderHook(() => useUserStore());
      act(() => {
        result.current.setSorting('email', 'asc');
      });
      expect(result.current.sortBy).toBe('email');
      expect(result.current.sortOrder).toBe('asc');
    });
    it('should clear filters', () => {
      const { result } = renderHook(() => useUserStore());
      // Set some filters first
      act(() => {
        result.current.setFilters({ is_active: true, role: 'admin' });
      });
      // Clear filters
      act(() => {
        result.current.clearFilters();
      });
      expect(result.current.filters).toEqual({});
    });
  });

describe('Error Management', () => {
    it('should set and clear errors', () => {
      const { result } = renderHook(() => useUserStore());
      const testError = {
        code: 'TEST_ERROR',
        message: 'Test error message',
        timestamp: new Date(),
      };
      act(() => {
        result.current.setError(testError);
      });
      expect(result.current.error).toEqual(testError);
      act(() => {
        result.current.clearError();
      });
      expect(result.current.error).toBeNull();
    });
    it('should add multiple errors to history', () => {
      const { result } = renderHook(() => useUserStore());
      const error1 = { code: 'ERROR_1', message: 'Error 1', timestamp: new Date() };
      const error2 = { code: 'ERROR_2', message: 'Error 2', timestamp: new Date() };
      act(() => {
        result.current.addError(error1);
        result.current.addError(error2);
      });
      expect(result.current.errors).toHaveLength(2);
      expect(result.current.errors).toContain(error1);
      expect(result.current.errors).toContain(error2);
    });
    it('should clear all errors', () => {
      const { result } = renderHook(() => useUserStore());
      // Add some errors first
      act(() => {
        result.current.addError({ code: 'ERROR_1', message: 'Error 1', timestamp: new Date() });
        result.current.addError({ code: 'ERROR_2', message: 'Error 2', timestamp: new Date() });
      });
      expect(result.current.errors).toHaveLength(2);
      act(() => {
        result.current.clearErrors();
      });
      expect(result.current.errors).toHaveLength(0);
    });
  });

describe('Loading States', () => {
    it('should manage loading state', () => {
      const { result } = renderHook(() => useUserStore());
      // Loading states are managed internally, test initial state
      expect(result.current.isLoading).toBe(false);
      expect(result.current.isUpdating).toBe(false);
      expect(result.current.isFetchingUsers).toBe(false);
    });
  });

describe('Utility Actions', () => {
    it('should clear all user data', () => {
      const { result } = renderHook(() => useUserStore());
      const mockUser = {
        id: '1',
        email: 'test@example.com',
        full_name: 'Test User',
        username: 'testuser',
        is_active: true,
        is_verified: true,
        email_verified: true,
        is_superuser: false,
        two_factor_enabled: false,
        failed_login_attempts: 0,
        last_login: new Date().toISOString(),
        user_metadata: {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        roles: [],
        permissions: [],
      };
      // Set some user data first
      act(() => {
        useUserStore.setState({
          currentUser: mockUser,
          selectedUser: mockUser,
          users: [mockUser],
        });
      });
      expect(result.current.currentUser).toEqual(mockUser);
      expect(result.current.selectedUser).toEqual(mockUser);
      expect(result.current.users).toHaveLength(1);
      // Clear data
      act(() => {
        result.current.clearUserData();
      });
      expect(result.current.currentUser).toBeNull();
      expect(result.current.selectedUser).toBeNull();
      expect(result.current.users).toEqual([]);
      expect(result.current.userList.items).toEqual([]);
    });
  });

describe('User List Management', () => {
    it('should select a user', () => {
      const { result } = renderHook(() => useUserStore());
      const mockUser = {
        id: '1',
        email: 'test@example.com',
        full_name: 'Test User',
        username: 'testuser',
        is_active: true,
        is_verified: true,
        email_verified: true,
        is_superuser: false,
        two_factor_enabled: false,
        failed_login_attempts: 0,
        last_login: new Date().toISOString(),
        user_metadata: {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        roles: [],
        permissions: [],
      };
      act(() => {
        result.current.selectUser(mockUser);
      });
      expect(result.current.selectedUser).toEqual(mockUser);
    });
    it('should clear selected user', () => {
      const { result } = renderHook(() => useUserStore());
      const mockUser = {
        id: '1',
        email: 'test@example.com',
        full_name: 'Test User',
        username: 'testuser',
        is_active: true,
        is_verified: true,
        email_verified: true,
        is_superuser: false,
        two_factor_enabled: false,
        failed_login_attempts: 0,
        last_login: new Date().toISOString(),
        user_metadata: {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        roles: [],
        permissions: [],
      };
      // Select user first
      act(() => {
        result.current.selectUser(mockUser);
      });
      expect(result.current.selectedUser).toEqual(mockUser);
      // Clear selection by passing null
      act(() => {
        result.current.selectUser(null);
      });
      expect(result.current.selectedUser).toBeNull();
    });
  });

describe('Store Methods Availability', () => {
    it('should expose all required store methods', () => {
      const { result } = renderHook(() => useUserStore());
      // Check that key methods exist
      expect(typeof result.current.fetchCurrentUser).toBe('function');
      expect(typeof result.current.updateProfile).toBe('function');
      expect(typeof result.current.fetchUsers).toBe('function');
      expect(typeof result.current.setSearchQuery).toBe('function');
      expect(typeof result.current.setFilters).toBe('function');
      expect(typeof result.current.setSorting).toBe('function');
      expect(typeof result.current.clearFilters).toBe('function');
      expect(typeof result.current.setError).toBe('function');
      expect(typeof result.current.clearError).toBe('function');
      expect(typeof result.current.clearUserData).toBe('function');
      expect(typeof result.current.selectUser).toBe('function');
      expect(typeof result.current.selectUser).toBe('function');
    });
  });
});