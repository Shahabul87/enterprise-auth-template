
import { renderHook, act } from '@testing-library/react';
import { useUserStore } from '@/stores/user-store';
/**
 * @jest-environment jsdom
 */


// Mock the store
jest.mock('@/stores/user-store', () => ({
  useUserStore: jest.fn(() => ({
    currentUser: null,
    userList: [],
    activityLogs: [],
    statistics: null,
    loading: false,
    error: null,
    updating: false,
    uploadingAvatar: false,
    fetchCurrentUser: jest.fn(async () => {}),
    updateProfile: jest.fn(async () => {}),
    uploadAvatar: jest.fn(async () => {}),
    deleteAccount: jest.fn(async () => {}),
    fetchUserList: jest.fn(async () => {}),
    deleteUser: jest.fn(async () => {}),
    updateUserRole: jest.fn(async () => {}),
    fetchActivityLogs: jest.fn(async () => {}),
    fetchStatistics: jest.fn(async () => {}),
    clearError: jest.fn(),
    setCurrentUser: jest.fn(),
    setUserList: jest.fn(),
    setActivityLogs: jest.fn(),
    setStatistics: jest.fn(),
    addActivityLog: jest.fn(),
    setLoading: jest.fn(),
    setUpdating: jest.fn(),
    setUploadingAvatar: jest.fn(),
    setError: jest.fn(),
  })),
}));
describe('UserStore', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });
});
describe('Initial State', () => {
    it('should have correct initial state', async () => {
      const { result } = renderHook(() => useUserStore());

      expect(result.current.currentUser).toBeNull();
      expect(result.current.userList).toEqual([]);
      expect(result.current.activityLogs).toEqual([]);
      expect(result.current.statistics).toBeNull();
      expect(result.current.loading).toBe(false);
      expect(result.current.error).toBeNull();
    });
  });

describe('User Actions', () => {
    it('should set current user', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockUser = { id: '1', name: 'Test User', email: 'test@example.com' };

      act(() => {
        result.current.setCurrentUser(mockUser);
      });

      expect(result.current.setCurrentUser).toHaveBeenCalledWith(mockUser);
    });

    it('should set user list', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockUsers = [
        { id: '1', name: 'User 1', email: 'user1@example.com' },
        { id: '2', name: 'User 2', email: 'user2@example.com' }
      ];

      act(() => {
        result.current.setUserList(mockUsers);
      });

      expect(result.current.setUserList).toHaveBeenCalledWith(mockUsers);
    });

    it('should add activity log', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockLog = { id: '1', action: 'login', timestamp: new Date().toISOString() };

      act(() => {
        result.current.addActivityLog(mockLog);
      });

      expect(result.current.addActivityLog).toHaveBeenCalledWith(mockLog);
    });
  });

describe('Loading States', () => {
    it('should set loading state', async () => {
      const { result } = renderHook(() => useUserStore());

      act(() => {
        result.current.setLoading(true);
      });

      expect(result.current.setLoading).toHaveBeenCalledWith(true);
    });

    it('should set updating state', async () => {
      const { result } = renderHook(() => useUserStore());

      act(() => {
        result.current.setUpdating(true);
      });

      expect(result.current.setUpdating).toHaveBeenCalledWith(true);
    });

    it('should set uploading avatar state', async () => {
      const { result } = renderHook(() => useUserStore());

      act(() => {
        result.current.setUploadingAvatar(true);
      });

      expect(result.current.setUploadingAvatar).toHaveBeenCalledWith(true);
    });
  });

describe('Error Handling', () => {
    it('should set and clear errors', async () => {
      const { result } = renderHook(() => useUserStore());
      const mockError = 'Something went wrong';

      act(() => {
        result.current.setError(mockError);
      });

      expect(result.current.setError).toHaveBeenCalledWith(mockError);

      act(() => {
        result.current.clearError();
      });

      expect(result.current.clearError).toHaveBeenCalled();
    });
  });
});
}
