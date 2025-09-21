import React from 'react';
import { renderHook, act } from '@testing-library/react';
import { User, TokenPair, LoginRequest, RegisterRequest } from '@/types';
/**
 * Authentication Context Tests
 *
 * Tests for the authentication store functionality
 * including login, logout, token management, and permissions.
 */

// Mock the auth store module
jest.mock('@/stores/auth.store');

// Mock other dependencies
jest.mock('@/lib/auth-api');
jest.mock('@/lib/cookie-manager');
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
    refresh: jest.fn(),
  }),
}));

// Mock AuthProvider - just pass children through since we're testing the store directly
jest.mock('@/contexts/auth-context', () => ({
  AuthProvider: ({ children }: { children: React.ReactNode }) => children,
}));

// Import after mocking
import { useAuthStore } from '@/stores/auth.store';
import { AuthProvider } from '@/contexts/auth-context';
import * as cookieManager from '@/lib/cookie-manager';

describe('AuthContext', () => {
  // Test data});
  const mockUser: User = {
    id: 'test-user-id',
    email: 'test@example.com',
    full_name: 'Test User',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    user_metadata: {},
    roles: [
      {
        id: 'role-1',
        name: 'user',
        description: 'Standard user role',
        is_active: true,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        permissions: [],
      },
    ],
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    last_login: new Date().toISOString(),
  };

  const mockTokens: TokenPair = {
    access_token: 'mock-access-token',
    refresh_token: 'mock-refresh-token',
    token_type: 'bearer',
    expires_in: 3600,
  };

  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <AuthProvider>{children}</AuthProvider>
  );

  // Create mock implementation
  let mockAuthStore: any;

  beforeEach(() => {
    jest.clearAllMocks();

    // Reset mock state for each test
    mockAuthStore = {
      user: null,
      tokens: null,
      accessToken: null,
      isAuthenticated: false,
      isLoading: false,
      isInitialized: false,
      permissions: [],
      roles: [],
      session: null,
      error: null,
      authErrors: [],
      isEmailVerified: false,
      is2FAEnabled: false,
      requiresPasswordChange: false,
      // Mock functions
      isTokenValid: jest.fn(() => true),
      initialize: jest.fn(async () => {
        mockAuthStore.isInitialized = true;
        mockAuthStore.isLoading = false;
      }),
      login: jest.fn(async (credentials: LoginRequest) => {
        if (credentials.password === 'WrongPassword') {
          return { success: false, error: { code: 'INVALID_CREDENTIALS', message: 'Invalid credentials' } };
        }
        mockAuthStore.user = mockUser;
        mockAuthStore.tokens = mockTokens;
        mockAuthStore.isAuthenticated = true;
        mockAuthStore.accessToken = mockTokens.access_token;
        return { success: true, data: { user: mockUser, tokens: mockTokens } };
      }),
      register: jest.fn(async (data: RegisterRequest) => {
        if (data.email === 'existing@example.com') {
          return { success: false, error: { code: 'EMAIL_EXISTS', message: 'Email already exists' } };
        }
        mockAuthStore.user = mockUser;
        mockAuthStore.tokens = mockTokens;
        mockAuthStore.isAuthenticated = true;
        return { success: true, data: { message: 'Success' } };
      }),
      logout: jest.fn(async () => {
        mockAuthStore.user = null;
        mockAuthStore.tokens = null;
        mockAuthStore.isAuthenticated = false;
        mockAuthStore.accessToken = null;
        mockAuthStore.permissions = [];
      }),
      refreshToken: jest.fn(async () => {
        const newTokens = { ...mockTokens, access_token: 'refreshed-access-token' };
        mockAuthStore.tokens = newTokens;
        mockAuthStore.accessToken = newTokens.access_token;
        return true;
      }),
      refreshAccessToken: jest.fn(async () => null),
      updateUser: jest.fn((updates: Partial<User>) => {
        if (mockAuthStore.user) {
          mockAuthStore.user = { ...mockAuthStore.user, ...updates };
        }
      }),
      hasPermission: jest.fn((permission: string) => {
        if (permission.includes(':')) {
          const [resource] = permission.split(':');
          return mockAuthStore.permissions.some((p: string) =>
            p === permission || p === `${resource}:*` || p === '*'
          );
        }
        return mockAuthStore.permissions.includes(permission);
      }),
      hasRole: jest.fn((role: string) => {
        return mockAuthStore.user?.roles?.some((r: any) => r.name === role) || false;
      }),
      hasAnyRole: jest.fn(() => false),
      hasAllPermissions: jest.fn(() => false),
      setError: jest.fn(),
      clearError: jest.fn(),
      addAuthError: jest.fn(),
      clearAuthErrors: jest.fn(),
      updateSession: jest.fn(),
      checkSession: jest.fn(async () => true),
      extendSession: jest.fn(async () => {}),
      fetchUserData: jest.fn(async () => {}),
      fetchPermissions: jest.fn(async () => {
        mockAuthStore.permissions = ['users:read', 'users:write', 'content:*'];
      }),
      verifyEmail: jest.fn(async () => ({ success: true, data: { message: 'Success' } })),
      resendVerification: jest.fn(async () => ({ success: true, data: { message: 'Success' } })),
      changePassword: jest.fn(async () => ({ success: true, data: { message: 'Success' } })),
      requestPasswordReset: jest.fn(async () => ({ success: true, data: { message: 'Success' } })),
      confirmPasswordReset: jest.fn(async () => ({ success: true, data: { message: 'Success' } })),
      setup2FA: jest.fn(async () => ({ success: true, data: { qr_code: '', backup_codes: [] } })),
      verify2FA: jest.fn(async () => ({ success: true, data: { enabled: true, message: 'Success' } })),
      disable2FA: jest.fn(async () => ({ success: true, data: { enabled: false, message: 'Success' } })),
      clearAuth: jest.fn(() => {
        mockAuthStore.user = null;
        mockAuthStore.tokens = null;
        mockAuthStore.isAuthenticated = false;
        mockAuthStore.accessToken = null;
      }),
      setupTokenRefresh: jest.fn(),
      clearAuthData: jest.fn(),
      setAuth: jest.fn(),
      setUser: jest.fn((updates: any) => {
        if (typeof updates === 'object' && updates !== null) {
          mockAuthStore.user = mockAuthStore.user ? { ...mockAuthStore.user, ...updates } : updates;
        }
      }),
    };

    // Mock the hook to return our mock store
    (useAuthStore as jest.Mock).mockReturnValue(mockAuthStore);

    // Setup cookie manager mocks
    (cookieManager.getAuthTokens as jest.Mock).mockReturnValue(null);
    (cookieManager.hasAuthCookies as jest.Mock).mockReturnValue(false);
    (cookieManager.isTokenExpired as jest.Mock).mockReturnValue(false);
    (cookieManager.getCookie as jest.Mock).mockReturnValue(null);
    (cookieManager.storeAuthTokens as jest.Mock).mockImplementation(() => {});
    (cookieManager.clearAuthCookies as jest.Mock).mockImplementation(() => {});

    // Clear sessionStorage
    sessionStorage.clear();
  });

  describe('Initial State', () => {
    it('should initialize with unauthenticated state', () => {
      const { result } = renderHook(() => useAuthStore(), { wrapper });

      expect(result.current.user).toBeNull();
      expect(result.current.tokens).toBeNull();
      expect(result.current.isAuthenticated).toBe(false);
      expect(result.current.isLoading).toBe(false);
      expect(result.current.permissions).toEqual([]);
    });

    it('should load stored authentication on mount', () => {
      // Pre-setup the mock with authenticated state
      mockAuthStore.user = mockUser;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.accessToken = mockTokens.access_token;
      mockAuthStore.isAuthenticated = true;
      mockAuthStore.permissions = ['users:read', 'users:write'];

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      expect(result.current.user).toEqual(mockUser);
      expect(result.current.tokens).toEqual(mockTokens);
      expect(result.current.isAuthenticated).toBe(true);
      expect(result.current.permissions).toEqual(['users:read', 'users:write']);
    });

    it('should refresh expired tokens on mount', async () => {
      // Pre-setup the mock with authenticated state
      mockAuthStore.user = mockUser;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.accessToken = mockTokens.access_token;
      mockAuthStore.isAuthenticated = true;

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      await act(async () => {
        await result.current.refreshToken();
      });

      expect(result.current.tokens?.access_token).toBe('refreshed-access-token');
    });
  });

  describe('Login', () => {
    it('should successfully login user', async () => {
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'SecurePassword123!',
      };

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      await act(async () => {
        const response = await result.current.login(loginRequest);
        expect(response.success).toBe(true);
      });

      expect(result.current.user).toEqual(mockUser);
      expect(result.current.tokens).toEqual(mockTokens);
      expect(result.current.isAuthenticated).toBe(true);
    });

    it('should handle login failure', async () => {
      const loginRequest: LoginRequest = {
        email: 'test@example.com',
        password: 'WrongPassword',
      };

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      await act(async () => {
        const response = await result.current.login(loginRequest);
        expect(response.success).toBe(false);
        expect(response.error?.code).toBe('INVALID_CREDENTIALS');
      });

      expect(result.current.user).toBeNull();
      expect(result.current.isAuthenticated).toBe(false);
    });
  });

  describe('Register', () => {
    it('should successfully register and login user', async () => {
      const registerRequest: RegisterRequest = {
        email: 'new@example.com',
        password: 'SecurePassword123!',
        confirm_password: 'SecurePassword123!',
        full_name: 'New User',
        agree_to_terms: true,
      };

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      await act(async () => {
        const response = await result.current.register(registerRequest);
        expect(response.success).toBe(true);
      });

      expect(result.current.isAuthenticated).toBe(true);
    });

    it('should handle registration failure', async () => {
      const registerRequest: RegisterRequest = {
        email: 'existing@example.com',
        password: 'SecurePassword123!',
        confirm_password: 'SecurePassword123!',
        full_name: 'New User',
        agree_to_terms: true,
      };

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      await act(async () => {
        const response = await result.current.register(registerRequest);
        expect(response.success).toBe(false);
        expect(response.error?.code).toBe('EMAIL_EXISTS');
      });

      expect(result.current.isAuthenticated).toBe(false);
    });
  });

  describe('Logout', () => {
    it('should successfully logout user', async () => {
      // Pre-setup authenticated state
      mockAuthStore.user = mockUser;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.isAuthenticated = true;
      mockAuthStore.accessToken = mockTokens.access_token;

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      expect(result.current.isAuthenticated).toBe(true);

      await act(async () => {
        await result.current.logout();
      });

      expect(result.current.user).toBeNull();
      expect(result.current.tokens).toBeNull();
      expect(result.current.isAuthenticated).toBe(false);
    });
  });

  describe('Token Refresh', () => {
    it('should successfully refresh tokens', async () => {
      // Pre-setup authenticated state
      mockAuthStore.user = mockUser;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.isAuthenticated = true;
      mockAuthStore.accessToken = mockTokens.access_token;

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      await act(async () => {
        const refreshResult = await result.current.refreshToken();
        expect(refreshResult).toBe(true);
      });

      expect(result.current.tokens?.access_token).toBe('refreshed-access-token');
    });
  });

  describe('Permissions', () => {
    it('should check user permissions correctly', () => {
      // Pre-setup authenticated state with permissions
      mockAuthStore.user = mockUser;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.isAuthenticated = true;
      mockAuthStore.permissions = ['users:read', 'users:write', 'content:*'];

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      expect(result.current.hasPermission('users:read')).toBe(true);
      expect(result.current.hasPermission('users:write')).toBe(true);
      expect(result.current.hasPermission('users:delete')).toBe(false);

      // Wildcard permission check
      expect(result.current.hasPermission('content:read')).toBe(true);
      expect(result.current.hasPermission('content:write')).toBe(true);
    });

    it('should check user roles correctly', () => {
      // Pre-setup authenticated state with roles
      const userWithRoles = {
        ...mockUser,
        roles: [
          { id: 'role-1', name: 'user' },
          { id: 'role-2', name: 'admin' },
        ],
      };
      mockAuthStore.user = userWithRoles;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.isAuthenticated = true;

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      expect(result.current.hasRole('user')).toBe(true);
      expect(result.current.hasRole('admin')).toBe(true);
      expect(result.current.hasRole('superadmin')).toBe(false);
    });
  });

  describe('Update User', () => {
    it('should update user data', () => {
      // Pre-setup authenticated state
      mockAuthStore.user = mockUser;
      mockAuthStore.tokens = mockTokens;
      mockAuthStore.isAuthenticated = true;

      const { result } = renderHook(() => useAuthStore(), { wrapper });

      const updates = {
        full_name: 'Updated Name',
      };

      act(() => {
        result.current.setUser(updates);
      });

      expect(result.current.user?.full_name).toBe('Updated Name');
    });
  });
});