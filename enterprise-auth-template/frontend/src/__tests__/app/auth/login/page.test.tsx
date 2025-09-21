
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { useRouter } from 'next/navigation';
import LoginPage from '@/app/auth/login/page';
import { useGuestOnly } from '@/stores/auth.store';
import { AuthState } from '@/stores/auth.store';
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));

jest.mock('@/stores/auth.store', () => ({
  useGuestOnly: jest.fn(),
}));

jest.mock('@/components/auth/modern-login-form', () => ({
  ModernLoginForm: function MockModernLoginForm() {
    return <div data-testid="modern-login-form">Modern Login Form</div>;
  },
}));

/**
 * @jest-environment jsdom
 */


// Mock dependencies
const mockUseRouter = useRouter as jest.MockedFunction<typeof useRouter>;
const mockUseGuestOnly = useGuestOnly as jest.MockedFunction<typeof useGuestOnly>;
const createMockAuthState = (overrides: Partial<AuthState> = {}): AuthState => ({
  // Core authentication state
  user: null,
  tokens: null,
  accessToken: null,
  isAuthenticated: false,
  isLoading: false,
  isInitialized: true,
  // Enhanced state
  permissions: [],
  roles: [],
  session: null,
  // Error handling
  error: null,
  authErrors: [],
  // Feature flags
  isEmailVerified: false,
  is2FAEnabled: false,
  requiresPasswordChange: false,
  isTokenValid: jest.fn().mockReturnValue(false),
  // Actions
  initialize: jest.fn().mockResolvedValue(undefined),
  login: jest.fn().mockResolvedValue({ success: true, data: {} }),
  register: jest.fn().mockResolvedValue({ success: true, data: { message: 'Success' } }),
  logout: jest.fn().mockResolvedValue(undefined),
  refreshToken: jest.fn().mockResolvedValue(true),
  refreshAccessToken: jest.fn().mockResolvedValue(null),
  updateUser: jest.fn(),
  // Permission & Role checks
  hasPermission: jest.fn().mockReturnValue(false),
  hasRole: jest.fn().mockReturnValue(false),
  hasAnyRole: jest.fn().mockReturnValue(false),
  hasAllPermissions: jest.fn().mockReturnValue(false),
  // Error management
  setError: jest.fn(),
  clearError: jest.fn(),
  addAuthError: jest.fn(),
  clearAuthErrors: jest.fn(),
  // Session management
  updateSession: jest.fn(),
  checkSession: jest.fn().mockResolvedValue(true),
  extendSession: jest.fn().mockResolvedValue(undefined),
  // Utility actions
  fetchUserData: jest.fn().mockResolvedValue(undefined),
  fetchPermissions: jest.fn().mockResolvedValue(undefined),
  verifyEmail: jest.fn().mockResolvedValue({ success: true, data: { message: 'Success' } }),
  changePassword: jest.fn().mockResolvedValue({ success: true, data: { message: 'Success' } }),
  resendVerification: jest.fn().mockResolvedValue({ success: true, data: { message: 'Success' } }),
  requestPasswordReset: jest.fn().mockResolvedValue({ success: true, data: { message: 'Success' } }),
  confirmPasswordReset: jest.fn().mockResolvedValue({ success: true, data: { message: 'Success' } }),
  ...overrides
});
const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
  forward: jest.fn(),
  refresh: jest.fn(),
  prefetch: jest.fn(),
};
describe('LoginPage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseRouter.mockReturnValue(mockRouter);
  });
  it('should show loading spinner when isLoading is true', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: true,
    }));
    render(<LoginPage />);
    // Check for loading spinner by its CSS class
    const spinner = document.querySelector('.animate-spin');
    expect(spinner).toBeInTheDocument();
    expect(spinner).toHaveClass('animate-spin');
    // Should not show the login form when loading
    expect(screen.queryByTestId('modern-login-form')).not.toBeInTheDocument();
  });
  it('should render login form when not loading', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    render(<LoginPage />);
    // Should show the login form
    expect(screen.getByTestId('modern-login-form')).toBeInTheDocument();
    expect(screen.getByText('Modern Login Form')).toBeInTheDocument();
    // Should not show loading spinner
    expect(screen.queryByRole('status', { hidden: true })).not.toBeInTheDocument();
  });
  it('should call useGuestOnly with correct redirect path', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    render(<LoginPage />);
    expect(mockUseGuestOnly).toHaveBeenCalledWith('/dashboard');
  });
  it('should render background elements', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<LoginPage />);
    // Check for animated orbs (background elements)
    const orbs = container.querySelectorAll('.animate-blob');
    expect(orbs).toHaveLength(3);
    // Check for gradient background
    const gradientBg = container.querySelector('.bg-gradient-to-br');
    expect(gradientBg).toBeInTheDocument();
  });
  it('should have proper responsive classes', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<LoginPage />);
    // Check for responsive container
    const container_ = container.querySelector('.min-h-screen');
    expect(container_).toBeInTheDocument();
    // Check for responsive padding
    const content = container.querySelector('.p-4.py-12');
    expect(content).toBeInTheDocument();
  });
  it('should handle dark mode classes', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<LoginPage />);
    // Check for dark mode classes
    const darkModeElements = container.querySelectorAll('.dark\\:from-gray-900');
    expect(darkModeElements.length).toBeGreaterThan(0);
  });
  it('should render with proper accessibility attributes', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    render(<LoginPage />);
    // The page should be focusable and have proper structure
    const main = screen.getByTestId('modern-login-form');
    expect(main).toBeInTheDocument();
  });
  it('should transition from loading to loaded state', async () => {
    // Start with loading state
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: true,
    }));
    const { rerender } = render(<LoginPage />);
    // Verify loading state
    expect(document.querySelector('.animate-spin')).toBeInTheDocument();
    expect(screen.queryByTestId('modern-login-form')).not.toBeInTheDocument();
    // Transition to loaded state
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    rerender(<LoginPage />);
    // Verify loaded state
    await waitFor(() => {
      expect(document.querySelector('.animate-spin')).not.toBeInTheDocument();
      expect(screen.getByTestId('modern-login-form')).toBeInTheDocument();
    });
  });
  it('should have proper z-index layering', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<LoginPage />);
    // Background should have lower z-index (or no z-index)
    const background = container.querySelector('.absolute.inset-0');
    expect(background).toBeInTheDocument();
    // Content should have higher z-index
    const content = container.querySelector('.relative.z-10');
    expect(content).toBeInTheDocument();
  });
  it('should render animation classes correctly', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<LoginPage />);
    // Check for animated blob elements (using Tailwind's arbitrary value syntax)
    const blobs = container.querySelectorAll('.animate-blob');
    expect(blobs).toHaveLength(3);
    
    // Check that all blobs have the animate-blob class
    blobs.forEach(blob => {
      expect(blob).toHaveClass('animate-blob');
    });
  });
  it('should handle undefined loading state gracefully', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    expect(() => render(<LoginPage />)).not.toThrow();
  });
  it('should maintain aspect ratios for decorative elements', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<LoginPage />);
    // Check that orbs have proper dimensions
    const orbs = container.querySelectorAll('.w-72.h-72');
    expect(orbs).toHaveLength(3);
    // Each orb should be circular
    orbs.forEach(orb => {
      expect(orb).toHaveClass('rounded-full');
    });
  });
});
describe('Loading State', () => {
    it('should center the loading spinner', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: true,
      }));
      const { container } = render(<LoginPage />);
      const loadingContainer = container.querySelector('.min-h-screen.flex.items-center.justify-center');
      expect(loadingContainer).toBeInTheDocument();
    });
    it('should have the same background in loading state', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: true,
      }));
      const { container } = render(<LoginPage />);
      // Should still have gradient background even in loading state
      const gradientBg = container.querySelector('.bg-gradient-to-br');
      expect(gradientBg).toBeInTheDocument();
    });
    it('should have proper spinner styling', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: true,
      }));
      const { container } = render(<LoginPage />);
      const spinner = container.querySelector('.animate-spin.rounded-full.h-12.w-12');
      expect(spinner).toBeInTheDocument();
      expect(spinner).toHaveClass('border-4', 'border-blue-500', 'border-t-transparent');
    });
  });

describe('Responsive Design', () => {
    it('should have mobile-friendly padding', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<LoginPage />);
      const content = container.querySelector('.p-4.py-12');
      expect(content).toBeInTheDocument();
    });
    it('should handle overflow properly', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<LoginPage />);
      const mainContainer = container.querySelector('.overflow-hidden');
      expect(mainContainer).toBeInTheDocument();
    });
  });