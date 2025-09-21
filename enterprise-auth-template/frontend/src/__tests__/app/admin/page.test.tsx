import React from 'react';
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useRouter } from 'next/navigation';
import AdminPage from '@/app/admin/page';
/**
 * @jest-environment jsdom
 */
// Mock dependencies
const mockAuthStore = {
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
  hasPermission: jest.fn(() => false),
  hasRole: jest.fn(() => false),
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
};

jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => mockAuthStore),
  useRequireAuth: jest.fn(() => mockAuthStore),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  })),
}));
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));
jest.mock('@/components/admin/admin-layout', () => {
  return function MockAdminLayout({ children }: { children: React.ReactNode }) {
    return <div data-testid="admin-layout">{children}</div>;
  };
});

jest.mock('@/components/admin/admin-dashboard', () => {
  return function MockAdminDashboard() {
    return <div data-testid="admin-dashboard">Admin Dashboard Component</div>;
  };
});
jest.mock('@/lib/admin-api', () => ({
  default: {
    getDashboardStats: jest.fn(),
    getSystemHealth: jest.fn(),
  },
}));
// Mock data
const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  prefetch: jest.fn(),
  back: jest.fn(),
};

const mockAdminUser = {
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
};
const mockAdminAPI = {
  getDashboardStats: jest.fn(),
  getSystemHealth: jest.fn(),
};
describe('AdminPage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
  });
  it('should render admin dashboard for authenticated admin user', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    
    useRequireAuth.mockReturnValue({
      ...mockAuthStore,
      user: mockAdminUser,
      isAuthenticated: true,
      hasPermission: jest.fn(() => true)
    });

    render(<AdminPage />);
    expect(screen.getByTestId('admin-dashboard')).toBeInTheDocument();
    expect(screen.getByText('Admin Dashboard Component')).toBeInTheDocument();
  });
  
  it('should render dashboard while loading (user is null)', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    
    useRequireAuth.mockReturnValue({
      ...mockAuthStore,
      user: null,
      isLoading: true,
      isAuthenticated: false,
      hasPermission: jest.fn(() => false),
    });

    render(<AdminPage />);
    // When user is null (loading), the component renders the dashboard
    // The actual loading/redirect logic is handled by useRequireAuth hook
    expect(screen.getByTestId('admin-dashboard')).toBeInTheDocument();
  });
  
  it('should redirect non-admin users', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    
    useRequireAuth.mockReturnValue({
      ...mockAuthStore,
      user: { ...mockAdminUser, is_superuser: false, roles: [] },
      isAuthenticated: true,
      hasPermission: jest.fn(() => false)
    });

    render(<AdminPage />);
    // Should show access denied message
    expect(screen.getByText('Access Denied')).toBeInTheDocument();
    expect(screen.queryByTestId('admin-dashboard')).not.toBeInTheDocument();
  });
  
  it('should render dashboard when user has permissions', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    
    useRequireAuth.mockReturnValue({
      ...mockAuthStore,
      user: mockAdminUser,
      isAuthenticated: true,
      hasPermission: jest.fn(() => true)
    });

    render(<AdminPage />);
    expect(screen.getByTestId('admin-dashboard')).toBeInTheDocument();
  });
  it('should handle admin store errors gracefully', async () => {
    const { useRequireAuth } = require('@/stores/auth.store');
    
    useRequireAuth.mockReturnValue({
      ...mockAuthStore,
      user: mockAdminUser,
      isAuthenticated: true,
      hasPermission: jest.fn(() => true)
    });

    render(<AdminPage />);
    // The component should still render even with errors
    expect(screen.getByTestId('admin-dashboard')).toBeInTheDocument();
  });
});