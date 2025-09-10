/**
 * @jest-environment jsdom
 */
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import AdminDashboard from '@/components/admin/admin-dashboard';
import { useAuth } from '@/contexts/auth-context';
import AdminAPI from '@/lib/admin-api';
import { formatDate } from '@/lib/utils';

// Mock dependencies
jest.mock('@/contexts/auth-context', () => ({
  useAuth: jest.fn(),
}));

jest.mock('@/lib/admin-api', () => {
  const mockAdminAPI = {
    getDashboardStats: jest.fn(),
    getSystemHealth: jest.fn(),
  };
  return {
    default: mockAdminAPI,
    __esModule: true,
  };
});

jest.mock('@/lib/utils', () => ({
  formatDate: jest.fn(),
}));

// Mock UI components
jest.mock('@/components/ui/card', () => ({
  Card: ({ children, className, ...props }: React.PropsWithChildren<{ className?: string; [key: string]: unknown }>) => (
    <div data-testid='card' className={className} {...props}>
      {children}
    </div>
  ),
  CardContent: ({ children, className, ...props }: React.PropsWithChildren<{ className?: string; [key: string]: unknown }>) => (
    <div data-testid='card-content' className={className} {...props}>
      {children}
    </div>
  ),
  CardDescription: ({ children, ...props }: React.PropsWithChildren<{ [key: string]: unknown }>) => (
    <div data-testid='card-description' {...props}>
      {children}
    </div>
  ),
  CardHeader: ({ children, className, ...props }: React.PropsWithChildren<{ className?: string; [key: string]: unknown }>) => (
    <div data-testid='card-header' className={className} {...props}>
      {children}
    </div>
  ),
  CardTitle: ({ children, className, ...props }: React.PropsWithChildren<{ className?: string; [key: string]: unknown }>) => (
    <h2 data-testid='card-title' className={className} {...props}>
      {children}
    </h2>
  ),
}));

jest.mock('@/components/ui/badge', () => ({
  Badge: ({ children, variant, className, ...props }: React.PropsWithChildren<{ variant?: string; className?: string; [key: string]: unknown }>) => (
    <span data-testid='badge' data-variant={variant} className={className} {...props}>
      {children}
    </span>
  ),
}));

jest.mock('@/components/ui/separator', () => ({
  Separator: (props: { [key: string]: unknown }) => <hr data-testid='separator' {...props} />,
}));

jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children, variant, ...props }: React.PropsWithChildren<{ variant?: string; [key: string]: unknown }>) => (
    <div data-testid='alert' data-variant={variant} {...props}>
      {children}
    </div>
  ),
  AlertDescription: ({ children, ...props }: React.PropsWithChildren<{ [key: string]: unknown }>) => (
    <div data-testid='alert-description' {...props}>
      {children}
    </div>
  ),
}));

jest.mock('lucide-react', () => ({
  Users: ({ className }: { className?: string }) => <div data-testid='users-icon' className={className} />,
  Shield: ({ className }: { className?: string }) => <div data-testid='shield-icon' className={className} />,
  Key: ({ className }: { className?: string }) => <div data-testid='key-icon' className={className} />,
  Activity: ({ className }: { className?: string }) => <div data-testid='activity-icon' className={className} />,
  Clock: ({ className }: { className?: string }) => <div data-testid='clock-icon' className={className} />,
  AlertCircle: ({ className }: { className?: string }) => (
    <div data-testid='alert-circle-icon' className={className} />
  ),
  TrendingUp: ({ className }: { className?: string }) => <div data-testid='trending-up-icon' className={className} />,
  Server: ({ className }: { className?: string }) => <div data-testid='server-icon' className={className} />,
  Database: ({ className }: { className?: string }) => <div data-testid='database-icon' className={className} />,
  Wifi: ({ className }: { className?: string }) => <div data-testid='wifi-icon' className={className} />,
}));

// Mock data
const mockDashboardStats = {
  users: {
    totalUsers: 150,
    activeUsers: 125,
    inactiveUsers: 25,
    newUsersToday: 5,
    newUsersThisWeek: 15,
    newUsersThisMonth: 30,
    verifiedUsers: 140,
    unverifiedUsers: 10,
    superusers: 3,
  },
  roles: {
    totalRoles: 5,
    activeRoles: 4,
    inactiveRoles: 1,
    customRoles: 3,
    systemRoles: 2,
  },
  permissions: {
    totalPermissions: 25,
    uniqueResources: 8,
    uniqueActions: 5,
  },
  audit: {
    totalLogs: 5000,
    logsToday: 250,
    logsThisWeek: 1200,
    logsThisMonth: 3500,
    topActions: [
      { action: 'user:login', count: 1500 },
      { action: 'user:logout', count: 1200 },
      { action: 'user:create', count: 30 },
      { action: 'user:update', count: 150 },
      { action: 'role:assign', count: 50 },
    ],
    topUsers: [
      { user_id: 'admin-id', user_name: 'admin@example.com', count: 500 },
      { user_id: 'john-id', user_name: 'john.doe@example.com', count: 300 },
      { user_id: 'jane-id', user_name: 'jane.smith@example.com', count: 250 },
    ],
    uniqueUsers: 100,
    uniqueActions: 15,
  },
  system: {
    uptime: 86400 * 30, // 30 days
    version: '1.0.0',
    environment: 'production',
    last_restart: '2024-01-01T00:00:00Z',
  },
};

const mockSystemHealth = {
  status: 'healthy' as const,
  timestamp: '2024-01-15T10:30:00Z',
  uptime: 86400 * 5, // 5 days
  version: '1.0.0',
  database: {
    status: 'connected' as const,
    response_time: 25,
  },
  redis: {
    status: 'connected' as const,
    response_time: 15,
  },
  services: [
    {
      name: 'API Gateway',
      status: 'healthy' as const,
      response_time: 50,
    },
    {
      name: 'Auth Service',
      status: 'healthy' as const,
      response_time: 30,
    },
    {
      name: 'Email Service',
      status: 'degraded' as const,
      response_time: 200,
      error: 'High response time',
    },
  ],
};

const mockAuthContext = {
  user: {
    id: 'admin',
    email: 'admin@example.com',
    first_name: 'Admin',
    last_name: 'User',
    is_active: true,
    is_verified: true,
    is_superuser: true,
    failed_login_attempts: 0,
    last_login: new Date().toISOString(),
    user_metadata: {},
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    roles: [],
  },
  tokens: {
    access_token: 'mock-access-token',
    refresh_token: 'mock-refresh-token',
    token_type: 'Bearer',
    expires_in: 3600,
  },
  isAuthenticated: true,
  isLoading: false,
  permissions: ['dashboard:read'],
  hasPermission: jest.fn(),
  hasRole: jest.fn(),
  login: jest.fn(),
  register: jest.fn(),
  logout: jest.fn(),
  refreshToken: jest.fn(),
  updateUser: jest.fn(),
};

const mockAdminAPI = AdminAPI as jest.Mocked<typeof AdminAPI>;
const mockFormatDate = formatDate as jest.MockedFunction<typeof formatDate>;
const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;

describe('AdminDashboard', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Setup default mocks
    mockUseAuth.mockReturnValue(mockAuthContext);
    mockFormatDate.mockImplementation((date, format) => `formatted-${date}-${format}`);

    // Default API responses
    mockAdminAPI.getDashboardStats.mockResolvedValue({
      success: true,
      data: mockDashboardStats,
    });

    mockAdminAPI.getSystemHealth.mockResolvedValue({
      success: true,
      data: mockSystemHealth,
    });

    // Default permissions
    mockAuthContext.hasPermission.mockReturnValue(true);
  });

  it('renders admin dashboard with stats', async () => {
    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('Admin Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Overview of system status and key metrics')).toBeInTheDocument();
    });

    // Check stats cards
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('150')).toBeInTheDocument();
    expect(screen.getByText('5 new today')).toBeInTheDocument();

    expect(screen.getByText('Active Users')).toBeInTheDocument();
    expect(screen.getByText('125')).toBeInTheDocument();

    expect(screen.getByText('Total Roles')).toBeInTheDocument();
    expect(screen.getByText('5')).toBeInTheDocument();

    expect(screen.getByText('Permissions')).toBeInTheDocument();
    expect(screen.getByText('25')).toBeInTheDocument();
  });

  it('shows permission denied when user lacks dashboard:read permission', () => {
    mockAuthContext.hasPermission.mockReturnValue(false);

    render(<AdminDashboard />);

    expect(screen.getByTestId('alert')).toBeInTheDocument();
    expect(
      screen.getByText("You don't have permission to view the admin dashboard.")
    ).toBeInTheDocument();
  });

  it('shows loading state initially', () => {
    // Make API call hang
    mockAdminAPI.getDashboardStats.mockImplementation(() => new Promise(() => {}));

    render(<AdminDashboard />);

    // Should show loading skeleton cards
    const cards = screen.getAllByTestId('card');
    expect(cards.length).toBeGreaterThan(0);

    // Should show loading animations - check for loading state
    expect(screen.getAllByTestId('card')).toHaveLength(expect.any(Number));
  });

  it('handles API error gracefully', async () => {
    mockAdminAPI.getDashboardStats.mockRejectedValue(new Error('API Error'));

    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByTestId('alert')).toBeInTheDocument();
      expect(screen.getByText('API Error')).toBeInTheDocument();
    });
  });

  it('handles API success with no data', async () => {
    mockAdminAPI.getDashboardStats.mockResolvedValue({
      success: false,
      error: { code: 'NO_DATA', message: 'No data available' },
    });

    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByTestId('alert')).toBeInTheDocument();
      expect(screen.getByText('No data available')).toBeInTheDocument();
    });
  });

  it('renders system health card when health data is available', async () => {
    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('System Health')).toBeInTheDocument();
      expect(
        screen.getByText('Real-time system status and performance metrics')
      ).toBeInTheDocument();
    });

    // Check system status
    expect(screen.getByText('Healthy')).toBeInTheDocument();
    expect(screen.getByText('5d 0h 0m')).toBeInTheDocument(); // Formatted uptime
    expect(screen.getByText('1.0.0')).toBeInTheDocument();

    // Check database and redis status
    expect(screen.getByText('Database')).toBeInTheDocument();
    expect(screen.getByText('connected')).toBeInTheDocument();
    expect(screen.getByText('25ms')).toBeInTheDocument();

    expect(screen.getByText('Redis')).toBeInTheDocument();
    expect(screen.getByText('15ms')).toBeInTheDocument();

    // Check services
    expect(screen.getByText('API Gateway')).toBeInTheDocument();
    expect(screen.getByText('Auth Service')).toBeInTheDocument();
    expect(screen.getByText('Email Service')).toBeInTheDocument();
  });

  it('handles system health API failure gracefully', async () => {
    mockAdminAPI.getSystemHealth.mockRejectedValue(new Error('Health API Error'));

    render(<AdminDashboard />);

    await waitFor(() => {
      // Dashboard should still render without system health
      expect(screen.getByText('Admin Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Total Users')).toBeInTheDocument();
    });

    // System health card should not be present
    expect(screen.queryByText('System Health')).not.toBeInTheDocument();
  });

  it('renders activity feed with audit stats', async () => {
    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('Recent Activity')).toBeInTheDocument();
      expect(screen.getByText('System activity overview and top actions')).toBeInTheDocument();
    });

    // Check activity stats
    expect(screen.getByText('250')).toBeInTheDocument(); // Today
    expect(screen.getByText('1,200')).toBeInTheDocument(); // This week
    expect(screen.getByText('3,500')).toBeInTheDocument(); // This month

    // Check top actions
    expect(screen.getByText('Top Actions')).toBeInTheDocument();
    expect(screen.getByText('user:login')).toBeInTheDocument();
    expect(screen.getByText('1,500')).toBeInTheDocument(); // Count for user:login

    // Check top users
    expect(screen.getByText('Most Active Users')).toBeInTheDocument();
    expect(screen.getByText('admin@example.com')).toBeInTheDocument();
    expect(screen.getByText('500')).toBeInTheDocument(); // Count for admin
  });

  it('renders secondary stats cards', async () => {
    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('Verified Users')).toBeInTheDocument();
      expect(screen.getByText('140')).toBeInTheDocument();
      expect(screen.getByText('93% verified')).toBeInTheDocument();

      expect(screen.getByText('Super Users')).toBeInTheDocument();
      expect(screen.getByText('3')).toBeInTheDocument();

      expect(screen.getByText('Audit Logs')).toBeInTheDocument();
      expect(screen.getByText('5,000')).toBeInTheDocument();
      expect(screen.getByText('250 today')).toBeInTheDocument();

      expect(screen.getByText('System Uptime')).toBeInTheDocument();
      expect(screen.getByText('30d')).toBeInTheDocument();
      expect(screen.getByText('Version 1.0.0')).toBeInTheDocument();
    });
  });

  it('renders system information card', async () => {
    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('System Information')).toBeInTheDocument();
      expect(screen.getByText('Current system status and environment details')).toBeInTheDocument();
    });

    expect(screen.getByText('Environment')).toBeInTheDocument();
    expect(screen.getByText('production')).toBeInTheDocument();

    expect(screen.getByText('Version')).toBeInTheDocument();
    expect(screen.getAllByText('1.0.0')).toHaveLength(2); // Appears in multiple places

    expect(screen.getByText('Last Updated')).toBeInTheDocument();
    expect(mockFormatDate).toHaveBeenCalledWith(expect.any(Date), 'short');
  });

  it('handles different system health statuses', async () => {
    const degradedHealth = {
      ...mockSystemHealth,
      status: 'degraded' as const,
      database: {
        status: 'disconnected' as const,
        response_time: 0,
      },
      services: [
        {
          name: 'API Gateway',
          status: 'unhealthy' as const,
          error: 'Service down',
        },
      ],
    };

    mockAdminAPI.getSystemHealth.mockResolvedValue({
      success: true,
      data: degradedHealth,
    });

    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('Degraded')).toBeInTheDocument();
      expect(screen.getByText('disconnected')).toBeInTheDocument();
      expect(screen.getByText('unhealthy')).toBeInTheDocument();
    });
  });

  it('formats uptime correctly for different durations', async () => {
    const testCases = [
      { uptime: 3600, expected: '1h 0m' }, // 1 hour
      { uptime: 90000, expected: '1d 1h 0m' }, // 1 day, 1 hour
      { uptime: 1800, expected: '30m' }, // 30 minutes
    ];

    for (const testCase of testCases) {
      const healthWithUptime = {
        ...mockSystemHealth,
        uptime: testCase.uptime,
      };

      mockAdminAPI.getSystemHealth.mockResolvedValue({
        success: true,
        data: healthWithUptime,
      });

      const { rerender } = render(<AdminDashboard />);

      await waitFor(() => {
        expect(screen.getByText(testCase.expected)).toBeInTheDocument();
      });

      rerender(<div />); // Clear for next iteration
    }
  });

  it('applies correct CSS classes based on props', () => {
    const customClass = 'custom-dashboard-class';
    const { container } = render(<AdminDashboard className={customClass} />);

    const dashboardContainer = container.firstChild as HTMLElement;
    expect(dashboardContainer).toHaveClass(customClass);
  });

  it('displays correct trend indicators', async () => {
    render(<AdminDashboard />);

    await waitFor(() => {
      // Trend should be calculated as (30 / 150) * 100 = 20%
      expect(screen.getByText('20%')).toBeInTheDocument();
    });

    expect(screen.getAllByTestId('trending-up-icon')).toHaveLength(1);
  });

  it('handles zero values correctly', async () => {
    const emptyStats = {
      ...mockDashboardStats,
      users: {
        ...mockDashboardStats.users,
        totalUsers: 0,
        activeUsers: 0,
        newUsersToday: 0,
        newUsersThisMonth: 0,
        superusers: 0,
        inactiveUsers: 0,
        newUsersThisWeek: 0,
        verifiedUsers: 0,
        unverifiedUsers: 0,
      },
      permissions: {
        ...mockDashboardStats.permissions,
        totalPermissions: 0,
        uniqueResources: 0,
        uniqueActions: 0,
      },
    };

    mockAdminAPI.getDashboardStats.mockResolvedValue({
      success: true,
      data: emptyStats,
    });

    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('0')).toBeInTheDocument();
    });
  });

  it('handles API response without system health', async () => {
    mockAdminAPI.getSystemHealth.mockResolvedValue({
      success: false,
      error: { code: 'HEALTH_UNAVAILABLE', message: 'Health check unavailable' },
    });

    render(<AdminDashboard />);

    await waitFor(() => {
      expect(screen.getByText('Admin Dashboard')).toBeInTheDocument();
    });

    // Should not render system health card
    expect(screen.queryByText('System Health')).not.toBeInTheDocument();
  });
});
