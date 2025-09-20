
import React from 'react';
import { render, screen, waitFor, fireEvent, act } from '@testing-library/react';
import { useRouter } from 'next/navigation';
import { AppRouterInstance } from 'next/dist/shared/lib/app-router-context.shared-runtime';
import Dashboard from '@/app/dashboard/page';
import { useAuth } from '@/contexts/auth-context';
import { User } from '@/types';

/**
 * @jest-environment jsdom
 */

jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));

jest.mock('@/contexts/auth-context', () => ({
  useAuth: jest.fn(),
}));

jest.mock('@/components/ui/card', () => ({
  Card: ({ children, className }: { children: React.ReactNode; className?: string }) => (
    <div className={className} data-testid="card">
      {children}
    </div>
  ),
  CardHeader: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="card-header">{children}</div>
  ),
  CardTitle: ({ children }: { children: React.ReactNode }) => (
    <h2 data-testid="card-title">{children}</h2>
  ),
  CardContent: ({ children }: { children: React.ReactNode }) => (
    <div data-testid="card-content">{children}</div>
  ),
// Orphaned closing removed
jest.mock('@/components/ui/button', () => ({
  Button: ({ 
    children, 
    onClick, 
    variant, 
    size,
    className,
    ...props 
  }: {
    children: React.ReactNode;
    onClick?: () => void;
    variant?: string;
    size?: string;
    className?: string;
  }) => (
    <button 
      onClick={onClick} 
      className={className}
      data-variant={variant}
      data-size={size}
      {...props}
    >
      {children}
    </button>
  ),
// Orphaned closing removed
jest.mock('@/components/ui/avatar', () => ({
  Avatar: ({ children, className }: { children: React.ReactNode; className?: string }) => (
    <div className={className} data-testid="avatar">{children}</div>
  ),
  AvatarImage: ({ src, alt }: { src?: string; alt?: string }) => (
    <div data-testid="avatar-image" data-src={src} aria-label={alt} />
  ),
  AvatarFallback: ({ children }: { children: React.ReactNode }) => (
    <span data-testid="avatar-fallback">{children}</span>
  ),
// Orphaned closing removed
/**
 * Dashboard Page Tests
 *
 * Comprehensive tests for the dashboard page component
 * including user data display, navigation, and interactions.
 */


// Mock dependencies
const mockPush = jest.fn();
const mockUseRouter = useRouter as jest.MockedFunction<typeof useRouter>;
const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;
describe('Dashboard Page', () => {
  const mockUser: User = {
    id: 'user-123',
    email: 'user@example.com',
    full_name: 'John Doe',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    user_metadata: {
      theme: 'light',
      notifications: true,
    },
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
    created_at: '2024-01-15T10:30:00Z',
    updated_at: '2024-03-20T14:45:00Z',
    last_login: '2024-03-20T09:15:00Z',
  };
  const defaultAuthContext = {
    user: mockUser,
    tokens: {
      access_token: 'mock-token',
      refresh_token: 'mock-refresh',
      token_type: 'bearer',
      expires_in: 3600,
    },
    isAuthenticated: true,
    isLoading: false,
    permissions: ['users:read', 'posts:write'],
    login: jest.fn(),
    register: jest.fn(),
    logout: jest.fn(),
    refreshToken: jest.fn(),
    updateUser: jest.fn(),
    hasPermission: jest.fn(),
    hasRole: jest.fn(),
  };
  beforeEach(() => {
    mockUseRouter.mockReturnValue({
      push: mockPush,
      refresh: jest.fn(),
      back: jest.fn(),
      forward: jest.fn(),
      replace: jest.fn(),
      prefetch: jest.fn(),
    } as AppRouterInstance);
    mockUseAuth.mockReturnValue(defaultAuthContext);
  });
  afterEach(() => {
    jest.clearAllMocks();
  });

describe('Rendering', () => {
    it('should render dashboard with user information', async () => {
      render(<Dashboard />);
      expect(screen.getByText('Welcome back, John!')).toBeInTheDocument();
      expect(screen.getByText('Dashboard')).toBeInTheDocument();
      expect(screen.getByTestId('avatar')).toBeInTheDocument();
    });
    it('should display user profile information', async () => {
      render(<Dashboard />);
      expect(screen.getByText('Profile Information')).toBeInTheDocument();
      expect(screen.getByText('user@example.com')).toBeInTheDocument();
      expect(screen.getByText('John Doe')).toBeInTheDocument();
      expect(screen.getByText('Verified Account')).toBeInTheDocument();
    });
    it('should display account statistics', async () => {
      render(<Dashboard />);
      expect(screen.getByText('Account Statistics')).toBeInTheDocument();
      expect(screen.getByText('Member since')).toBeInTheDocument();
      expect(screen.getByText('Last login')).toBeInTheDocument();
      expect(screen.getByText('Account status')).toBeInTheDocument();
      expect(screen.getByText('Active')).toBeInTheDocument();
    });
    it('should display user roles and permissions', async () => {
      render(<Dashboard />);
      expect(screen.getByText('Roles & Permissions')).toBeInTheDocument();
      expect(screen.getByText('Your Roles')).toBeInTheDocument();
      expect(screen.getByText('user')).toBeInTheDocument();
      expect(screen.getByText('Your Permissions')).toBeInTheDocument();
      expect(screen.getByText('users:read')).toBeInTheDocument();
      expect(screen.getByText('posts:write')).toBeInTheDocument();
    });
  });

describe('User States', () => {
    it('should show loading state when user data is loading', async () => {
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        isLoading: true,
        user: null,
      });
      render(<Dashboard />);
      expect(screen.getByText('Loading dashboard...')).toBeInTheDocument();
      expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
    });
    it('should redirect to login when user is not authenticated', async () => {
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        isAuthenticated: false,
        user: null,
        tokens: null,
      });
      render(<Dashboard />);
      expect(mockPush).toHaveBeenCalledWith('/auth/login');
    });
    it('should display unverified account warning', async () => {
      const unverifiedUser = {
        ...mockUser,
        is_verified: false,
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: unverifiedUser,
      });
      render(<Dashboard />);
      expect(screen.getByText('Account Not Verified')).toBeInTheDocument();
      expect(screen.getByText('Please check your email and verify your account.')).toBeInTheDocument();
      expect(screen.getByText('Resend Verification Email')).toBeInTheDocument();
    });
    it('should display inactive account warning', async () => {
      const inactiveUser = {
        ...mockUser,
        is_active: false,
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: inactiveUser,
      });
      render(<Dashboard />);
      expect(screen.getByText('Account Inactive')).toBeInTheDocument();
      expect(screen.getByText('Your account has been deactivated. Please contact support.')).toBeInTheDocument();
    });
    it('should display admin privileges for superuser', async () => {
      const adminUser = {
        ...mockUser,
        is_superuser: true,
        roles: [
          ...mockUser.roles,
          {
            id: 'role-2',
            name: 'admin',
            description: 'Administrator role',
            is_active: true,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
            permissions: [],
          },
        ],
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: adminUser,
        permissions: ['admin:*', 'users:manage', 'posts:manage'],
      });
      render(<Dashboard />);
      expect(screen.getByText('Administrator')).toBeInTheDocument();
      expect(screen.getByText('admin')).toBeInTheDocument();
      expect(screen.getByText('Admin Dashboard')).toBeInTheDocument();
    });
  });

describe('Interactions', () => {
    it('should navigate to profile page when edit profile is clicked', async () => {
      render(<Dashboard />);
      const editProfileButton = screen.getByText('Edit Profile');
      act(() => { fireEvent.click(editProfileButton); });
      expect(mockPush).toHaveBeenCalledWith('/profile');
    });
    it('should navigate to settings page when settings is clicked', async () => {
      render(<Dashboard />);
      const settingsButton = screen.getByText('Settings');
      act(() => { fireEvent.click(settingsButton); });
      expect(mockPush).toHaveBeenCalledWith('/settings');
    });
    it('should logout user when logout button is clicked', async () => {
      const mockLogout = jest.fn();
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        logout: mockLogout,
      });
      render(<Dashboard />);
      const logoutButton = screen.getByText('Logout');
      act(() => { fireEvent.click(logoutButton); });
      expect(mockLogout).toHaveBeenCalled();
    });
    it('should handle resend verification email', async () => {
      const unverifiedUser = {
        ...mockUser,
        is_verified: false,
      };
      // Mock API call
      global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;.mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          success: true,
          data: { message: 'Verification email sent' },
        }),
      });
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: unverifiedUser,
      });
      render(<Dashboard />);
      const resendButton = screen.getByText('Resend Verification Email');
      act(() => { fireEvent.click(resendButton); });
      await act(async () => { await waitFor(() => {
        expect(fetch).toHaveBeenCalledWith('/api/auth/resend-verification', expect.any(Object));
      });
    }); });
    it('should navigate to admin dashboard for admin users', async () => {
      const adminUser = {
        ...mockUser,
        is_superuser: true,
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: adminUser,
      });
      render(<Dashboard />);
      const adminDashboardButton = screen.getByText('Admin Dashboard');
      act(() => { fireEvent.click(adminDashboardButton); });
      expect(mockPush).toHaveBeenCalledWith('/admin');
    });
  });

describe('User Metadata', () => {
    it('should display custom user metadata', async () => {
      const userWithMetadata = {
        ...mockUser,
        user_metadata: {
          theme: 'dark',
          notifications: true,
          language: 'en',
          timezone: 'UTC',
          avatar_url: 'https://example.com/avatar.jpg',
        },
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: userWithMetadata,
      });
      render(<Dashboard />);
      expect(screen.getByText('Preferences')).toBeInTheDocument();
      expect(screen.getByText('Dark theme')).toBeInTheDocument();
      expect(screen.getByText('Notifications enabled')).toBeInTheDocument();
    });
    it('should handle user without metadata gracefully', async () => {
      const userWithoutMetadata = {
        ...mockUser,
        user_metadata: {},
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: userWithoutMetadata,
      });
      render(<Dashboard />);
      // Should not crash and should still render basic information
      expect(screen.getByText('Welcome back, John!')).toBeInTheDocument();
    });
  });

describe('Recent Activity', () => {
    it('should display recent activity section', async () => {
      render(<Dashboard />);
      expect(screen.getByText('Recent Activity')).toBeInTheDocument();
      expect(screen.getByText('Last login')).toBeInTheDocument();
      expect(screen.getByText('Profile updated')).toBeInTheDocument();
    });
    it('should format dates correctly', async () => {
      render(<Dashboard />);
      // Check that dates are formatted in a readable format
      const lastLoginText = screen.getByText(/Mar \d{2}, 2024/);
      expect(lastLoginText).toBeInTheDocument();
    });
  });

describe('Quick Actions', () => {
    it('should display quick action buttons', async () => {
      render(<Dashboard />);
      expect(screen.getByText('Quick Actions')).toBeInTheDocument();
      expect(screen.getByText('Edit Profile')).toBeInTheDocument();
      expect(screen.getByText('Settings')).toBeInTheDocument();
      expect(screen.getByText('Change Password')).toBeInTheDocument();
    });
    it('should navigate to change password page', async () => {
      render(<Dashboard />);
      const changePasswordButton = screen.getByText('Change Password');
      act(() => { fireEvent.click(changePasswordButton); });
      expect(mockPush).toHaveBeenCalledWith('/auth/change-password');
    });
  });

describe('Responsive Design', () => {
    it('should render mobile-friendly layout', async () => {
      // Mock mobile viewport
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 375,
      });
      render(<Dashboard />);
      // Check that mobile-specific classes or elements are present
      expect(screen.getByTestId('mobile-dashboard')).toBeInTheDocument();
    });
    it('should render desktop layout', async () => {
      // Mock desktop viewport
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 1200,
      });
      render(<Dashboard />);
      // Check that desktop-specific classes or elements are present
      expect(screen.getByTestId('desktop-dashboard')).toBeInTheDocument();
    });
  });

describe('Error Handling', () => {
    it('should handle API errors gracefully', async () => {
      global.fetch = jest.fn() as jest.MockedFunction<typeof fetch>;.mockRejectedValueOnce(new Error('Network error'));
      const unverifiedUser = {
        ...mockUser,
        is_verified: false,
      };
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: unverifiedUser,
      });
      render(<Dashboard />);
      const resendButton = screen.getByText('Resend Verification Email');
      act(() => { fireEvent.click(resendButton); });
      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Failed to resend verification email')).toBeInTheDocument();
      });
    }); });
    it('should display error state when user data fails to load', async () => {
      mockUseAuth.mockReturnValue({
        ...defaultAuthContext,
        user: null,
        isLoading: false,
      });
      render(<Dashboard />);
      expect(screen.getByText('Error loading dashboard')).toBeInTheDocument();
      expect(screen.getByText('Failed to load user data')).toBeInTheDocument();
      expect(screen.getByText('Retry')).toBeInTheDocument();
    });
  });

describe('Accessibility', () => {
    it('should have proper ARIA labels and roles', async () => {
      render(<Dashboard />);
      expect(screen.getByRole('main')).toBeInTheDocument();
      expect(screen.getByRole('heading', { name: 'Dashboard' })).toBeInTheDocument();
      expect(screen.getByLabelText('User avatar')).toBeInTheDocument();
    });
    it('should support keyboard navigation', async () => {
      render(<Dashboard />);
      const editProfileButton = screen.getByText('Edit Profile');
      editProfileButton.focus();
      expect(editProfileButton).toHaveFocus();
      fireEvent.keyDown(editProfileButton, { key: 'Enter' });
      expect(mockPush).toHaveBeenCalledWith('/profile');
    });
    it('should have proper semantic HTML structure', async () => {
      render(<Dashboard />);
      expect(screen.getByRole('banner')).toBeInTheDocument(); // header
      expect(screen.getByRole('main')).toBeInTheDocument(); // main content
      expect(screen.getByRole('navigation')).toBeInTheDocument(); // navigation
    });
  });
});