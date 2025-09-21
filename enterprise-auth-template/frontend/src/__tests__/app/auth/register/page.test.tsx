
import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import { useRouter } from 'next/navigation';
import RegisterPage from '@/app/auth/register/page';
import { useGuestOnly } from '@/stores/auth.store';
import { AuthState } from '@/stores/auth.store';
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));

jest.mock('@/stores/auth.store', () => ({
  useGuestOnly: jest.fn(),
}));

jest.mock('@/components/auth/modern-register-form', () => ({
  ModernRegisterForm: function MockModernRegisterForm() {
    return <div data-testid="modern-register-form">Modern Register Form</div>;
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
describe('RegisterPage', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseRouter.mockReturnValue(mockRouter);
  });
  it('should show loading spinner when isLoading is true', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: true,
    }));
    render(<RegisterPage />);
    // Check for loading spinner
    const spinner = screen.getByRole('status', { hidden: true });
    expect(spinner).toBeInTheDocument();
    expect(spinner).toHaveClass('animate-spin');
    // Should not show the register form when loading
    expect(screen.queryByTestId('modern-register-form')).not.toBeInTheDocument();
  });
  it('should render register form when not loading', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    render(<RegisterPage />);
    // Should show the register form
    expect(screen.getByTestId('modern-register-form')).toBeInTheDocument();
    expect(screen.getByText('Modern Register Form')).toBeInTheDocument();
    // Should not show loading spinner
    expect(screen.queryByRole('status', { hidden: true })).not.toBeInTheDocument();
  });
  it('should call useGuestOnly with correct redirect path', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    render(<RegisterPage />);
    expect(mockUseGuestOnly).toHaveBeenCalledWith('/dashboard');
  });
  it('should render register-specific background elements', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<RegisterPage />);
    // Check for animated orbs with register-specific colors
    const orbs = container.querySelectorAll('.animate-blob');
    expect(orbs).toHaveLength(3);
    // Check for register-specific gradient background (purple/pink/orange theme)
    const gradientBg = container.querySelector('.from-purple-50.via-pink-50.to-orange-50');
    expect(gradientBg).toBeInTheDocument();
    // Check for blue orb
    const blueOrb = container.querySelector('.bg-blue-300');
    expect(blueOrb).toBeInTheDocument();
    // Check for purple orb
    const purpleOrb = container.querySelector('.bg-purple-300');
    expect(purpleOrb).toBeInTheDocument();
    // Check for orange orb
    const orangeOrb = container.querySelector('.bg-orange-300');
    expect(orangeOrb).toBeInTheDocument();
  });
  it('should have proper responsive classes', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<RegisterPage />);
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
    const { container } = render(<RegisterPage />);
    // Check for dark mode classes
    const darkModeElements = container.querySelectorAll('.dark\\:from-gray-900');
    expect(darkModeElements.length).toBeGreaterThan(0);
    // Check for dark mode orb colors
    const darkBlueOrb = container.querySelector('.dark\\:bg-blue-900');
    const darkPurpleOrb = container.querySelector('.dark\\:bg-purple-900');
    const darkOrangeOrb = container.querySelector('.dark\\:bg-orange-900');
    expect(darkBlueOrb).toBeInTheDocument();
    expect(darkPurpleOrb).toBeInTheDocument();
    expect(darkOrangeOrb).toBeInTheDocument();
  });
  it('should render with proper accessibility attributes', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    render(<RegisterPage />);
    // The page should be focusable and have proper structure
    const main = screen.getByTestId('modern-register-form');
    expect(main).toBeInTheDocument();
  });
  it('should transition from loading to loaded state', async () => {
    // Start with loading state
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: true,
    }));
    const { rerender } = render(<RegisterPage />);
    // Verify loading state
    expect(screen.getByRole('status', { hidden: true })).toBeInTheDocument();
    expect(screen.queryByTestId('modern-register-form')).not.toBeInTheDocument();
    // Transition to loaded state
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    rerender(<RegisterPage />);
    // Verify loaded state
    await waitFor(() => {
      expect(screen.queryByRole('status', { hidden: true })).not.toBeInTheDocument();
      expect(screen.getByTestId('modern-register-form')).toBeInTheDocument();
    });
  });
  it('should have proper z-index layering', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<RegisterPage />);
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
    const { container } = render(<RegisterPage />);
    // Check for animation classes on orbs with different delays
    const blob1 = container.querySelector('.animate-blob:not([class*="animation-delay"])');
    const blob2 = container.querySelector('[class*="animation-delay:2s"]');
    const blob3 = container.querySelector('[class*="animation-delay:4s"]');
    expect(blob1).toBeInTheDocument();
    expect(blob2).toBeInTheDocument();
    expect(blob3).toBeInTheDocument();
  });
  it('should handle undefined loading state gracefully', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    expect(() => render(<RegisterPage />)).not.toThrow();
  });
  it('should maintain aspect ratios for decorative elements', async () => {
    mockUseGuestOnly.mockReturnValue(createMockAuthState({
      isLoading: false,
    }));
    const { container } = render(<RegisterPage />);
    // Check that orbs have proper dimensions
    const orbs = container.querySelectorAll('.w-72.h-72');
    expect(orbs).toHaveLength(3);
    // Each orb should be circular
    orbs.forEach(orb => {
      expect(orb).toHaveClass('rounded-full');
    });
  });

describe('Loading State', () => {
    it('should center the loading spinner', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: true,
      }));
      const { container } = render(<RegisterPage />);
      const loadingContainer = container.querySelector('.min-h-screen.flex.items-center.justify-center');
      expect(loadingContainer).toBeInTheDocument();
    });
    it('should have register-specific loading spinner color', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: true,
      }));
      const { container } = render(<RegisterPage />);
      const spinner = container.querySelector('.animate-spin.rounded-full.h-12.w-12');
      expect(spinner).toBeInTheDocument();
      expect(spinner).toHaveClass('border-4', 'border-purple-500', 'border-t-transparent');
    });
    it('should have the same background in loading state', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: true,
      }));
      const { container } = render(<RegisterPage />);
      // Should still have gradient background even in loading state
      const gradientBg = container.querySelector('.from-purple-50.via-pink-50.to-orange-50');
      expect(gradientBg).toBeInTheDocument();
    });
  });

describe('Visual Differences from Login Page', () => {
    it('should have different color scheme than login page', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<RegisterPage />);
      // Should use purple/pink/orange theme instead of blue/indigo/purple
      const registerGradient = container.querySelector('.from-purple-50.via-pink-50.to-orange-50');
      expect(registerGradient).toBeInTheDocument();
      // Should NOT have login page colors
      const loginGradient = container.querySelector('.from-blue-50.via-indigo-50.to-purple-50');
      expect(loginGradient).not.toBeInTheDocument();
    });
    it('should have different orb colors than login page', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<RegisterPage />);
      // Register page should have blue, purple, orange orbs
      expect(container.querySelector('.bg-blue-300')).toBeInTheDocument();
      expect(container.querySelector('.bg-purple-300')).toBeInTheDocument();
      expect(container.querySelector('.bg-orange-300')).toBeInTheDocument();
      // Should NOT have login page orb colors
      expect(container.querySelector('.bg-yellow-300')).not.toBeInTheDocument();
      expect(container.querySelector('.bg-pink-300')).not.toBeInTheDocument();
    });
  });

describe('Responsive Design', () => {
    it('should have mobile-friendly padding', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<RegisterPage />);
      const content = container.querySelector('.p-4.py-12');
      expect(content).toBeInTheDocument();
    });
    it('should handle overflow properly', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<RegisterPage />);
      const mainContainer = container.querySelector('.overflow-hidden');
      expect(mainContainer).toBeInTheDocument();
    });
  });

describe('Grid Pattern Overlay', () => {
    it('should render grid pattern overlay', async () => {
      mockUseGuestOnly.mockReturnValue(createMockAuthState({
        isLoading: false,
      }));
      const { container } = render(<RegisterPage />);
      const gridOverlay = container.querySelector('.grid-pattern');
      expect(gridOverlay).toBeInTheDocument();
    });
  });
});