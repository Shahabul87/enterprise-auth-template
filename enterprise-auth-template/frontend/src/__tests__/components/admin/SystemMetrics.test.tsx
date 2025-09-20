import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import SystemMetrics from '@/components/admin/SystemMetrics';
import { useAuth, useRequireAuth } from '@/stores/auth.store';
import AdminAPI from '@/lib/admin-api';
import type { User } from '@/types';
/**
 * @jest-environment jsdom
 */
/**
 * SystemMetrics Component Tests
 * Tests the system metrics dashboard component with proper TypeScript types
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
jest.mock('@/lib/admin-api');
// Type definitions
interface MetricData {
  value: number;
  change: number;
  trend: 'up' | 'down' | 'stable';
}
interface SystemMetricsData {
  cpu_usage: MetricData;
  memory_usage: MetricData;
  disk_usage: MetricData;
  active_connections: MetricData;
  request_rate: MetricData;
  error_rate: MetricData;
  response_time: MetricData;
  database_connections: MetricData;
  cache_hit_rate: MetricData;
}
describe('SystemMetrics Component', () => {
  let queryClient: QueryClient;
  const mockUser: User = {
    id: '1',
    email: 'admin@test.com',
    full_name: 'Admin User',
    is_superuser: true,
    is_active: true,
    is_verified: true,
    two_factor_enabled: false,
    email_verified: true,
    permissions: ['admin.view_metrics', 'admin.manage_system'],
    roles: [
      {
        id: '1',
        name: 'Admin',
        permissions: [{ name: 'admin.view_metrics' }],
      },
    ],
  };
  const mockMetrics: SystemMetricsData = {
    cpu_usage: { value: 45.2, change: -5.3, trend: 'down' },
    memory_usage: { value: 67.8, change: 2.1, trend: 'up' },
    disk_usage: { value: 78.5, change: 0, trend: 'stable' },
    active_connections: { value: 234, change: 12, trend: 'up' },
    request_rate: { value: 1250, change: 8.5, trend: 'up' },
    error_rate: { value: 0.5, change: -0.2, trend: 'down' },
    response_time: { value: 125, change: -10, trend: 'down' },
    database_connections: { value: 45, change: 3, trend: 'up' },
    cache_hit_rate: { value: 92.3, change: 1.2, trend: 'up' },
  };
  beforeEach(() => {
    jest.clearAllMocks();
    queryClient = new QueryClient({
      defaultOptions: {
        queries: { retry: false },
      },
    });
    // Setup mock implementations
    (useAuth as jest.Mock).mockReturnValue({
      user: mockUser,
      isAuthenticated: true,
      isLoading: false,
      permissions: mockUser.permissions,
      hasPermission: (permission: string) =>
        mockUser.permissions?.includes(permission) ?? false,
    });
    const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
    const mockGetSystemMetrics = mockAdminAPI.getSystemMetrics || jest.fn();
    mockGetSystemMetrics.mockResolvedValue({
      success: true,
      data: mockMetrics,
    });
    // Ensure the mock is properly set
    if (mockAdminAPI) {
      mockAdminAPI.getSystemMetrics = mockGetSystemMetrics;
    }
  });
  afterEach(() => {
    queryClient.clear();
  });
  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <QueryClientProvider client={queryClient}>{component}</QueryClientProvider>
    );
  };
  it('should render system metrics when user has permission', async () => {
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });
    // Check for metric cards
    expect(screen.getByText('CPU Usage')).toBeInTheDocument();
    expect(screen.getByText('Memory Usage')).toBeInTheDocument();
    expect(screen.getByText('Disk Usage')).toBeInTheDocument();
  });
  it('should display metric values correctly', async () => {
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      // Check CPU usage
      expect(screen.getByText('45.2%')).toBeInTheDocument();
      expect(screen.getByText(/5.3% from last hour/)).toBeInTheDocument();
      // Check Memory usage
      expect(screen.getByText('67.8%')).toBeInTheDocument();
      expect(screen.getByText(/2.1% from last hour/)).toBeInTheDocument();
    });
  });
  it('should show loading state initially', () => {
    renderWithProviders(<SystemMetrics />);
    // Should show loading indicators
    expect(screen.getAllByTestId('metric-skeleton')).toHaveLength(9);
  });
  it('should handle API errors gracefully', async () => {
    const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
    const mockGetSystemMetrics = mockAdminAPI.getSystemMetrics || jest.fn();
    mockGetSystemMetrics.mockRejectedValue(new Error('Failed to fetch metrics'));
    if (mockAdminAPI) {
      mockAdminAPI.getSystemMetrics = mockGetSystemMetrics;
    }
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      expect(screen.getByText(/Failed to load system metrics/)).toBeInTheDocument();
    });
    // Should show retry button
    const retryButton = screen.getByRole('button', { name: /retry/i });
    expect(retryButton).toBeInTheDocument();
  });
  it('should refresh metrics on interval', async () => {
    jest.useFakeTimers();
    const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
    const mockGetSystemMetrics = mockAdminAPI.getSystemMetrics || jest.fn();
    mockGetSystemMetrics.mockResolvedValue({
      success: true,
      data: mockMetrics,
    });
    if (mockAdminAPI) {
      mockAdminAPI.getSystemMetrics = mockGetSystemMetrics;
    }
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      expect(mockGetSystemMetrics).toHaveBeenCalledTimes(1);
    });
    // Advance timer by 30 seconds (default refresh interval)
    act(() => {
      jest.advanceTimersByTime(30000);
    });
    await waitFor(() => {
      expect(mockGetSystemMetrics).toHaveBeenCalledTimes(2);
    });
    jest.useRealTimers();
  });
  it('should allow manual refresh', async () => {
    const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
    const mockGetSystemMetrics = mockAdminAPI.getSystemMetrics || jest.fn();
    mockGetSystemMetrics.mockResolvedValue({
      success: true,
      data: mockMetrics,
    });
    if (mockAdminAPI) {
      mockAdminAPI.getSystemMetrics = mockGetSystemMetrics;
    }
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      expect(screen.getByText('System Metrics')).toBeInTheDocument();
    });
    const refreshButton = screen.getByRole('button', { name: /refresh/i });
    await act(async () => { await userEvent.click(refreshButton);
    await waitFor(() => {
      expect(mockGetSystemMetrics).toHaveBeenCalledTimes(2);
    });
  });
  it('should not render when user lacks permission', () => {
    (useAuth as jest.Mock).mockReturnValue({
      user: { ...mockUser, permissions: [] },
      isAuthenticated: true,
      isLoading: false,
      permissions: [],
      hasPermission: () => false,
    });
    renderWithProviders(<SystemMetrics />);
    expect(
      screen.getByText(/You do not have permission to view system metrics/)
    ).toBeInTheDocument();
  });
  it('should display trend indicators correctly', async () => {
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      // Check for trend icons
      const upTrends = screen.getAllByTestId('trend-up');
      const downTrends = screen.getAllByTestId('trend-down');
      expect(upTrends).toHaveLength(5); // Based on mock data
      expect(downTrends).toHaveLength(3);
    });
  });
  it('should display critical thresholds with appropriate styling', async () => {
    const criticalMetrics = {
      ...mockMetrics,
      cpu_usage: { value: 95, change: 10, trend: 'up' as const },
      memory_usage: { value: 92, change: 5, trend: 'up' as const },
    };
    const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
    const mockGetSystemMetrics = mockAdminAPI.getSystemMetrics || jest.fn();
    mockGetSystemMetrics.mockResolvedValue({
      success: true,
      data: criticalMetrics,
    });
    if (mockAdminAPI) {
      mockAdminAPI.getSystemMetrics = mockGetSystemMetrics;
    }
    renderWithProviders(<SystemMetrics />);
    await waitFor(() => {
      const criticalCards = screen.getAllByTestId('metric-card-critical');
      expect(criticalCards).toHaveLength(2); // CPU and Memory above 90%
    });
  });
});