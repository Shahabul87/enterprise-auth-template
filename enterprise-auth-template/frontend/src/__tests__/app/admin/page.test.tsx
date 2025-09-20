import React from 'react';
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useRouter } from 'next/navigation';
import AdminPage from '@/app/admin/page';
/**
 * @jest-environment jsdom
 */
// Mock dependencies
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
    setUser: () => {},
    user: null,
    isAuthenticated: false,
    isLoading: false,
    permissions: [],
    hasPermission: jest.fn(() => false),
    hasRole: jest.fn(() => false),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  }));
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));
jest.mock('@/components/admin/admin-dashboard', () => ({
  AdminDashboard: function MockAdminDashboard() {
    return <div data-testid="admin-dashboard">Admin Dashboard Component</div>;
  },
jest.mock('@/stores/admin-store', () => ({
  useAdminStore: jest.fn(),
}));
// Mock data
const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  prefetch: jest.fn(),
  back: jest.fn(),
};
const mockAuthStore = {
  user: {
    id: '1',
    email: 'admin@example.com',
    full_name: 'Admin User',
    is_superuser: true,
    roles: [
      {
        id: '1',
        name: 'admin',
        permissions: [
          { name: 'admin.read' },
          { name: 'admin.write' },
          { name: 'users.manage' },
        ],
      },
    ],
  },
  isAuthenticated: true,
};
const mockAdminStore = {
  stats: {
    totalUsers: 1250,
    activeUsers: 892,
    totalSessions: 156,
    systemHealth: 98.5,
  },
  fetchStats: jest.fn(),
};
describe('AdminPage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
    // Mock useRequireAuth to simulate authenticated admin user
    const { useRequireAuth } = require('@/stores/auth.store');
    useRequireAuth.mockReturnValue({
      user: mockAuthStore.user,
      isLoading: false,
    });
    // Mock useAdminStore
    const { useAdminStore } = require('@/stores/admin-store');
    useAdminStore.mockReturnValue(mockAdminStore);
  });
  it('should render admin dashboard for authenticated admin user', async () => {
    render(<AdminPage />);
    expect(screen.getByTestId('admin-dashboard')).toBeInTheDocument();
    expect(screen.getByText('Admin Dashboard Component')).toBeInTheDocument();
  });
  it('should show loading state while checking authentication', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    useRequireAuth.mockReturnValue({
      user: null,
      isLoading: true,
    });
    render(<AdminPage />);
    // You might expect a loading spinner or skeleton
    expect(screen.queryByTestId('admin-dashboard')).not.toBeInTheDocument();
  });
  it('should redirect non-admin users', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    useRequireAuth.mockReturnValue({
      user: { ...mockAuthStore.user, is_superuser: false, roles: [] },
      isLoading: false,
    });
    render(<AdminPage />);
    // The useRequireAuth hook should handle redirection
    // Check if the dashboard is not rendered for non-admin users
    expect(screen.queryByTestId('admin-dashboard')).not.toBeInTheDocument();
  });
  it('should fetch admin stats on mount', async () => {
    render(<AdminPage />);
    await waitFor(() => {
      expect(mockAdminStore.fetchStats).toHaveBeenCalledTimes(1);
    });
  });
  it('should handle admin store errors gracefully', async () => {
    const { useAdminStore } = require('@/stores/admin-store');
    useAdminStore.mockReturnValue({
      ...mockAdminStore,
      error: 'Failed to fetch stats',
    });
    render(<AdminPage />);
    // The component should still render even with errors
    expect(screen.getByTestId('admin-dashboard')).toBeInTheDocument();
  });
});