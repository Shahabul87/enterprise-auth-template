import { renderHook, act } from '@testing-library/react';
import { useErrorHandler } from '@/hooks/use-error-handler';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/stores/auth.store';
import { ErrorHandler, StandardError, ErrorCategory } from '@/lib/error-handler';
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));
jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => ({
    user: null,
    tokens: null,
    accessToken: null,
    isAuthenticated: false,
    isLoading: false,
    isInitialized: true,
    permissions: [],
    roles: [],
    session: null,
    error: null,
    authErrors: [],
    isEmailVerified: false,
    is2FAEnabled: false,
    requiresPasswordChange: false,
    isTokenValid: () => true,
    initialize: async () => {},
    login: async () => ({ success: true, data: { user: null, tokens: null } }),
    register: async () => ({ success: true, data: { message: 'Success' } }),
    logout: async () => {},
    refreshToken: async () => true,
    refreshAccessToken: async () => null,
    updateUser: () => {},
    hasPermission: () => false,
    hasRole: () => false,
    hasAnyRole: () => false,
    hasAllPermissions: () => false,
    setError: () => {},
    clearError: () => {},
    addAuthError: () => {},
    clearAuthErrors: () => {},
    updateSession: () => {},
    checkSession: async () => true,
    extendSession: async () => {},
    fetchUserData: async () => {},
    fetchPermissions: async () => {},
    verifyEmail: async () => ({ success: true, data: { message: 'Success' } }),
    resendVerification: async () => ({ success: true, data: { message: 'Success' } }),
    changePassword: async () => ({ success: true, data: { message: 'Success' } }),
    requestPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    confirmPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    setup2FA: async () => ({ success: true, data: { qr_code: '', backup_codes: [] } }),
    verify2FA: async () => ({ success: true, data: { enabled: true, message: 'Success' } }),
    disable2FA: async () => ({ success: true, data: { enabled: false, message: 'Success' } }),
    clearAuth: () => {},
    setupTokenRefresh: () => {},
    clearAuthData: () => {},
    setAuth: () => {},
    user: null,
    isAuthenticated: false,
    isLoading: false,
    permissions: [],
    hasPermission: jest.fn(() => false),
    hasRole: jest.fn(() => false),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  })),
}}));));
jest.mock('@/lib/error-handler', () => ({
  ErrorCategory: {
    AUTHENTICATION: 'authentication',
    AUTHORIZATION: 'authorization',
    VALIDATION: 'validation',
    NETWORK: 'network',
    SERVER: 'server',
    CLIENT: 'client',
  },
  ErrorHandler: {
    handle: jest.fn(),
  },}));
/**
 * @jest-environment jsdom
 */
// Mock dependencies
// Mock console methods to avoid noise in tests
const originalConsoleError = console.error;
const originalConsoleWarn = console.warn;
describe('useErrorHandler', () => {
  const mockRouter = { push: jest.fn() };
  const mockLogout = jest.fn();
  beforeEach(() => {
    jest.clearAllMocks();
    console.error = jest.fn();
    console.warn = jest.fn();
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
    (useAuthStore as jest.Mock).mockReturnValue({ logout: mockLogout });
  });
  afterEach(() => {
    console.error = originalConsoleError;
    console.warn = originalConsoleWarn;
  });
  it('should initialize with no error', async () => {
    const { result } = renderHook(() => useErrorHandler());
    expect(result.current.error).toBeNull();
    expect(result.current.isRetrying).toBe(false);
  });
  it('should handle basic errors', async () => {
    const mockError = new Error('Test error');
    const mockStandardError: StandardError = {
      message: 'Test error',
      code: 'ERROR',
      category: ErrorCategory.CLIENT,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    act(() => {
      result.current.handleError(mockError);
    });
    expect(result.current.error).toEqual(mockStandardError);
    expect(ErrorHandler.handle).toHaveBeenCalledWith(mockError, undefined);
  });
  it('should handle authentication errors with logout', async () => {
    const mockError = new Error('Token expired');
    const mockStandardError: StandardError = {
      message: 'Token expired',
      code: 'TOKEN_EXPIRED',
      category: ErrorCategory.AUTHENTICATION,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    act(() => {
      result.current.handleError(mockError);
    });
    expect(mockLogout).toHaveBeenCalled();
    expect(mockRouter.push).toHaveBeenCalledWith('/auth/login?expired=true');
  });
  it('should handle authorization errors with redirect', async () => {
    const mockError = new Error('Forbidden');
    const mockStandardError: StandardError = {
      message: 'Forbidden',
      code: 'FORBIDDEN',
      category: ErrorCategory.AUTHORIZATION,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    act(() => {
      result.current.handleError(mockError);
    });
    expect(mockRouter.push).toHaveBeenCalledWith('/unauthorized');
  });
  it('should clear errors', async () => {
    const mockStandardError: StandardError = {
      message: 'Test error',
      code: 'ERROR',
      category: ErrorCategory.CLIENT,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    act(() => {
      result.current.handleError(new Error('Test error'));
    });
    expect(result.current.error).not.toBeNull();
    act(() => {
      result.current.clearError();
    });
    expect(result.current.error).toBeNull();
  });
  it('should handle retry functionality for retryable errors', async () => {
    const mockOperation = jest.fn().mockResolvedValue('success');
    const mockStandardError: StandardError = {
      message: 'Network error',
      code: 'NETWORK_ERROR',
      category: ErrorCategory.NETWORK,
      retryable: true,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    // Set an error first
    act(() => {
      result.current.handleError(new Error('Network error'));
    });
    expect(result.current.error).toEqual(mockStandardError);
    // Retry the operation
    let retryResult;
    await act(async () => {
      retryResult = await result.current.retry(mockOperation);
    });
    expect(mockOperation).toHaveBeenCalled();
    expect(result.current.error).toBeNull();
    expect(result.current.isRetrying).toBe(false);
    expect(retryResult).toBe('success');
  });
  it('should not retry non-retryable errors', async () => {
    const mockOperation = jest.fn();
    const mockStandardError: StandardError = {
      message: 'Validation error',
      code: 'VALIDATION_ERROR',
      category: ErrorCategory.VALIDATION,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    // Set a non-retryable error
    act(() => {
      result.current.handleError(new Error('Validation error'));
    });
    // Try to retry
    await act(async () => {
      await result.current.retry(mockOperation);
    });
    expect(mockOperation).not.toHaveBeenCalled();
  });
  it('should handle retry failure', async () => {
    const mockError = new Error('Retry failed');
    const mockOperation = jest.fn().mockRejectedValue(mockError);
    const mockStandardError: StandardError = {
      message: 'Network error',
      code: 'NETWORK_ERROR',
      category: ErrorCategory.NETWORK,
      retryable: true,
    };
    const retryErrorStandard: StandardError = {
      message: 'Retry failed',
      code: 'ERROR',
      category: ErrorCategory.CLIENT,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    // Set an error first
    act(() => {
      result.current.handleError(new Error('Network error'));
    });
    // Update mock for retry error
    (ErrorHandler.handle as jest.Mock).mockReturnValue(retryErrorStandard);
    // Retry and expect it to fail
    await expect(
      act(async () => {
        await result.current.retry(mockOperation);
      })
    ).rejects.toThrow(mockError);
    expect(result.current.error).toEqual(retryErrorStandard);
    expect(result.current.isRetrying).toBe(false);
  });
  it('should pass options to ErrorHandler.handle', async () => {
    const mockError = new Error('Test error');
    const mockOptions = { showToast: true, context: { userId: '123' } };
    const mockStandardError: StandardError = {
      message: 'Test error',
      code: 'ERROR',
      category: ErrorCategory.CLIENT,
      retryable: false,
    };
    (ErrorHandler.handle as jest.Mock).mockReturnValue(mockStandardError);
    const { result } = renderHook(() => useErrorHandler());
    act(() => {
      result.current.handleError(mockError, mockOptions);
    });
    expect(ErrorHandler.handle).toHaveBeenCalledWith(mockError, mockOptions);
  });
});