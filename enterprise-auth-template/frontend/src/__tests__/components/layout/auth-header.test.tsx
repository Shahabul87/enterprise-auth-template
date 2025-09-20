
import React from 'react';
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useRouter } from 'next/navigation';
import { AuthHeader } from '@/components/layout/auth-header';
import { useRequireAuth } from '@/stores/auth.store';
import type { User } from '@/types';

/**
 * @jest-environment jsdom
 */

jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));

jest.mock('@/stores/auth.store', () => ({
  useRequireAuth: jest.fn(),
}));

jest.mock('next/link', () => {
  return ({ children, href }: { children: React.ReactNode; href: string }) => {
    return <a href={href}>{children}</a>;
  };

/**
 * AuthHeader Component Tests
 * Tests the authenticated header component with proper TypeScript types
 */


// Type-safe mocks
interface MockRouter {
  push: jest.MockedFunction<(url: string) => void>;
  replace: jest.MockedFunction<(url: string) => void>;
  back: jest.MockedFunction<() => void>;
  forward: jest.MockedFunction<() => void>;
  refresh: jest.MockedFunction<() => void>;
  prefetch: jest.MockedFunction<(url: string) => Promise<void>>;
}

interface MockAuthStore {
  user: User | null;
  isAuthenticated: boolean;
  logout: jest.MockedFunction<() => Promise<void>>;
  permissions: string[];
  hasPermission: jest.MockedFunction<(permission: string) => boolean>;
  isLoading: boolean;
}

// Mock modules
// Mock next/link
});

describe('AuthHeader Component', () => {
  let mockRouter: MockRouter;
  let mockAuthStore: MockAuthStore;
  const mockUser: User = {
    id: '123',
    email: 'test@example.com',
    full_name: 'Test User',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    last_login: null,
    user_metadata: {},
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    roles: [{ id: '1', name: 'user', permissions: [] }],
  beforeEach(() => {
    jest.clearAllMocks();
    mockRouter = {
      push: jest.fn(),
      replace: jest.fn(),
      back: jest.fn(),
      forward: jest.fn(),
      refresh: jest.fn(),
      prefetch: jest.fn().mockResolvedValue(undefined),
    };
    mockAuthStore = {
      user: mockUser,
      isAuthenticated: true,
      logout: jest.fn().mockResolvedValue(undefined),
      permissions: [],
      hasPermission: jest.fn().mockReturnValue(false),
      isLoading: false,
    };
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
    (useRequireAuth as jest.Mock).mockReturnValue(mockAuthStore);
  });

describe('Rendering', () => {
    it('should render header with logo and user info when authenticated', async () => {
      render(<AuthHeader />);
      expect(screen.getByText(/Enterprise Auth/i)).toBeInTheDocument();
      expect(screen.getByText(mockUser.email)).toBeInTheDocument();
    });
    it('should render login/signup buttons when not authenticated', async () => {
      mockAuthStore.isAuthenticated = false;
      mockAuthStore.user = null;
      render(<AuthHeader />);
      expect(screen.getByText('Log In')).toBeInTheDocument();
      expect(screen.getByText('Sign Up')).toBeInTheDocument();
    });
    it('should show loading state', async () => {
      mockAuthStore.isLoading = true;
      render(<AuthHeader />);
      expect(screen.getByTestId('auth-header-skeleton')).toBeInTheDocument();
    });
  });

describe('Navigation', () => {
    it('should navigate to home when logo is clicked', async () => {
      render(<AuthHeader />);
      const logo = screen.getByText(/Enterprise Auth/i);
      await act(async () => { await userEvent.click(logo);
      expect(mockRouter.push).toHaveBeenCalledWith('/');
    });
    it('should navigate to login page when Log In is clicked', async () => {
      mockAuthStore.isAuthenticated = false;
      mockAuthStore.user = null;
      render(<AuthHeader />);
      const loginButton = screen.getByText('Log In');
      await act(async () => { await userEvent.click(loginButton);
      expect(mockRouter.push).toHaveBeenCalledWith('/auth/login');
    });
    it('should navigate to signup page when Sign Up is clicked', async () => {
      mockAuthStore.isAuthenticated = false;
      mockAuthStore.user = null;
      render(<AuthHeader />);
      const signupButton = screen.getByText('Sign Up');
      await act(async () => { await userEvent.click(signupButton);
      expect(mockRouter.push).toHaveBeenCalledWith('/auth/register');
    });
  });

describe('User Menu', () => {
    it('should display user dropdown when authenticated', async () => {
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      expect(screen.getByText('Profile')).toBeInTheDocument();
      expect(screen.getByText('Settings')).toBeInTheDocument();
      expect(screen.getByText('Logout')).toBeInTheDocument();
    });
    it('should navigate to profile when Profile is clicked', async () => {
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      const profileLink = screen.getByText('Profile');
      await act(async () => { await userEvent.click(profileLink);
      expect(mockRouter.push).toHaveBeenCalledWith('/profile');
    });
    it('should navigate to settings when Settings is clicked', async () => {
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      const settingsLink = screen.getByText('Settings');
      await act(async () => { await userEvent.click(settingsLink);
      expect(mockRouter.push).toHaveBeenCalledWith('/settings');
    });
    it('should handle logout when Logout is clicked', async () => {
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      const logoutButton = screen.getByText('Logout');
      await act(async () => { await userEvent.click(logoutButton);
      expect(mockAuthStore.logout).toHaveBeenCalled();
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockRouter.push).toHaveBeenCalledWith('/');
      }); });
    });
  });

describe('Admin Access', () => {
    it('should show admin link for admin users', async () => {
      mockAuthStore.user = { ...mockUser, is_superuser: true, roles: [{ id: '1', name: 'admin', permissions: [], description: null, is_active: true, created_at: new Date().toISOString(), updated_at: new Date().toISOString() }] };
      mockAuthStore.hasPermission.mockReturnValue(true);
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      expect(screen.getByText('Admin Panel')).toBeInTheDocument();
    });
    it('should not show admin link for non-admin users', async () => {
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      expect(screen.queryByText('Admin Panel')).not.toBeInTheDocument();
    });
    it('should navigate to admin panel when clicked', async () => {
      mockAuthStore.user = { ...mockUser, is_superuser: true, roles: [{ id: '1', name: 'admin', permissions: [], description: null, is_active: true, created_at: new Date().toISOString(), updated_at: new Date().toISOString() }] };
      mockAuthStore.hasPermission.mockReturnValue(true);
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      const adminLink = screen.getByText('Admin Panel');
      await act(async () => { await userEvent.click(adminLink);
      expect(mockRouter.push).toHaveBeenCalledWith('/admin');
    });
  });

describe('Mobile Responsiveness', () => {
    it('should render mobile menu button on small screens', async () => {
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 375,
      });
      render(<AuthHeader />);
      expect(screen.getByRole('button', { name: /menu/i })).toBeInTheDocument();
    });
    it('should toggle mobile menu when button is clicked', async () => {
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 375,
      });
      render(<AuthHeader />);
      const menuButton = screen.getByRole('button', { name: /menu/i });
      await act(async () => { await userEvent.click(menuButton);
      expect(screen.getByRole('navigation', { name: /mobile menu/i })).toBeInTheDocument();
    });
    it('should close mobile menu after navigation', async () => {
      Object.defineProperty(window, 'innerWidth', {
        writable: true,
        configurable: true,
        value: 375,
      });
      render(<AuthHeader />);
      const menuButton = screen.getByRole('button', { name: /menu/i });
      await act(async () => { await userEvent.click(menuButton);
      const profileLink = screen.getByText('Profile');
      await act(async () => { await userEvent.click(profileLink);
      expect(screen.queryByRole('navigation', { name: /mobile menu/i })).not.toBeInTheDocument();
    });
  });

describe('Theme Toggle', () => {
    it('should render theme toggle button', async () => {
      render(<AuthHeader />);
      expect(screen.getByRole('button', { name: /toggle theme/i })).toBeInTheDocument();
    });
    it('should toggle between light and dark theme', async () => {
      render(<AuthHeader />);
      const themeButton = screen.getByRole('button', { name: /toggle theme/i });
      // Initially light theme
      expect(document.documentElement).toHaveClass('light');
      await act(async () => { await userEvent.click(themeButton);
      expect(document.documentElement).toHaveClass('dark');
      await act(async () => { await userEvent.click(themeButton);
      expect(document.documentElement).toHaveClass('light');
    });
  });

describe('Notifications', () => {
    it('should show notification icon when user is authenticated', async () => {
      render(<AuthHeader />);
      expect(screen.getByRole('button', { name: /notifications/i })).toBeInTheDocument();
    });
    it('should navigate to notifications page when clicked', async () => {
      render(<AuthHeader />);
      const notificationButton = screen.getByRole('button', { name: /notifications/i });
      await act(async () => { await userEvent.click(notificationButton);
      expect(mockRouter.push).toHaveBeenCalledWith('/notifications');
    });
  });

describe('Accessibility', () => {
    it('should have proper ARIA labels', async () => {
      render(<AuthHeader />);
      expect(screen.getByRole('banner')).toBeInTheDocument();
      expect(screen.getByRole('navigation')).toBeInTheDocument();
    });
    it('should support keyboard navigation', async () => {
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      userButton.focus();
      await userEvent.keyboard('{Enter}');
      expect(screen.getByText('Profile')).toBeInTheDocument();
      await userEvent.keyboard('{Escape}');
      expect(screen.queryByText('Profile')).not.toBeInTheDocument();
    });
    it('should announce authentication state to screen readers', async () => {
      render(<AuthHeader />);
      const authStatus = screen.getByRole('status', { name: /authentication status/i });
      expect(authStatus).toHaveTextContent('Logged in as Test User');
    });
  });

describe('Error Handling', () => {
    it('should handle logout errors gracefully', async () => {
      mockAuthStore.logout.mockRejectedValueOnce(new Error('Logout failed'));
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation();
      render(<AuthHeader />);
      const userButton = screen.getByRole('button', { name: /user menu/i });
      await act(async () => { await userEvent.click(userButton);
      const logoutButton = screen.getByText('Logout');
      await act(async () => { await userEvent.click(logoutButton);
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(consoleSpy).toHaveBeenCalledWith('Logout error:', expect.any(Error));
      }); });
      expect(screen.getByText(/logout failed/i)).toBeInTheDocument();
      consoleSpy.mockRestore();
    });
  });

describe('Sticky Behavior', () => {
  });
});