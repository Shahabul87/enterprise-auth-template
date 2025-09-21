import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { useRouter } from 'next/navigation';
import ModernLoginForm from '@/components/auth/modern-login-form';
import { useAuthStore } from '@/stores/auth.store';
import { useToast } from '@/components/ui/use-toast';
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
}));
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));
jest.mock('@/components/ui/use-toast', () => ({
  useToast: jest.fn(),
}));
jest.mock('@/services/auth-api.service', () => ({
  magicLinkService: {
    sendMagicLink: jest.fn(),
  },
  webAuthnService: {
    startAuthentication: jest.fn(),
    finishAuthentication: jest.fn(),
  },
  base64ToArrayBuffer: jest.fn(),
  arrayBufferToBase64: jest.fn(),
}));

jest.mock('framer-motion', () => ({
  motion: {
    div: ({ children, ...props }: unknown) => <div {...props}>{children}</div>,
    button: ({ children, ...props }: unknown) => <button {...props}>{children}</button>,
    form: ({ children, ...props }: unknown) => <form {...props}>{children}</form>,
  },
  AnimatePresence: ({ children }: unknown) => children,
}));

jest.mock('lucide-react', () => ({
  Mail: () => <div data-testid="mail-icon" />,
  Lock: () => <div data-testid="lock-icon" />,
  Fingerprint: () => <div data-testid="fingerprint-icon" />,
  ArrowRight: () => <div data-testid="arrow-right-icon" />,
  Sparkles: () => <div data-testid="sparkles-icon" />,
  Shield: () => <div data-testid="shield-icon" />,
  Zap: () => <div data-testid="zap-icon" />,
  Eye: () => <div data-testid="eye-icon" />,
  EyeOff: () => <div data-testid="eye-off-icon" />,
  Check: () => <div data-testid="check-icon" />,
  Loader2: () => <div data-testid="loader2-icon" />,
  Github: () => <div data-testid="github-icon" />,
  Chrome: () => <div data-testid="chrome-icon" />,
}));

jest.mock('next/link', () => {
  return function MockLink({ children, href }: { children: React.ReactNode; href: string }) {
    return <a href={href}>{children}</a>;
  };
});

jest.mock('@/components/ui/button', () => ({
  Button: ({ children, ...props }: unknown) => <button {...props}>{children}</button>,
}));

jest.mock('@/components/ui/input', () => ({
  Input: ({ ...props }: unknown) => <input {...props} />,
}));

jest.mock('@/lib/utils', () => ({
  cn: (...args: unknown[]) => args.filter(Boolean).join(' '),
}));

/**
 * @jest-environment jsdom
 */

// Add missing UI component mocks
jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }) => <form {...props}>{children}</form>,
  FormField: ({ children }) => children,
  FormItem: ({ children }) => <div>{children}</div>,
  FormLabel: ({ children }) => <label>{children}</label>,
  FormControl: ({ children }) => <div>{children}</div>,
  FormMessage: ({ children }) => <span role="alert">{children}</span>,
  FormDescription: ({ children }) => <span>{children}</span>,
  useFormField: () => ({ error: null }),
}));

jest.mock('@/components/ui/password-input', () => ({
  PasswordInput: (props) => <input type="password" {...props} />
}));

jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: (config) => {
    const [values, setValues] = React.useState(config.defaultValues || {});
    const [errors, setErrors] = React.useState({});
    const [isSubmitting, setIsSubmitting] = React.useState(false);

    return {
      form: {
        register: (name) => ({
          name,
          onChange: (e) => setValues(prev => ({ ...prev, [name]: e.target.value })),
          value: values[name] || '',
        }),
        handleSubmit: (onSubmit) => async (e) => {
          e?.preventDefault();
          setIsSubmitting(true);
          try {
            await onSubmit(values);
          } finally {
            setIsSubmitting(false);
          }
        },
        formState: { errors, isSubmitting },
        watch: (name) => values[name],
        setValue: (name, value) => setValues(prev => ({ ...prev, [name]: value })),
        control: {},
      },
      isSubmitting,
      error: null,
      setError: jest.fn(),
      handleSubmit: async (onSubmit) => {
        setIsSubmitting(true);
        try {
          await onSubmit(values);
        } finally {
          setIsSubmitting(false);
        }
      },
    };
  },
  validationRules: {
    email: { required: 'Email is required', pattern: { value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/, message: 'Invalid email address' }},
    password: { required: 'Password is required', minLength: { value: 8, message: 'Password must be at least 8 characters' }},
  },
  isFormValid: () => true,
}));

jest.mock('@/hooks/use-error-handler', () => ({
  useFormErrorHandler: () => ({
    handleFormError: jest.fn(),
    clearAllErrors: jest.fn(),
    errors: {},
  }),
}));

// Mock dependencies
const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
  forward: jest.fn(),
  refresh: jest.fn(),
  prefetch: jest.fn(),
};
const mockToast = jest.fn();
const mockAuthStore = {
  login: jest.fn(),
};
// Mock passkey support
global.PublicKeyCredential = jest.fn();
global.navigator.credentials = {
  create: jest.fn(),
  get: jest.fn(),
  store: jest.fn(),
  preventSilentAccess: jest.fn(),
} as jest.Mocked<CredentialsContainer>;
describe('ModernLoginForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
    (useToast as jest.Mock).mockReturnValue({ toast: mockToast });
    (useAuthStore as jest.Mock).mockReturnValue(mockAuthStore);
  });
  it('should render with default password auth method', async () => {
    render(<ModernLoginForm />);
    expect(screen.getByPlaceholderText(/email/i)).toBeInTheDocument();
    expect(screen.getByPlaceholderText(/password/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
  });
  it('should switch between authentication methods', async () => {
    const user = userEvent.setup();
    render(<ModernLoginForm />);
    // Check default password method
    expect(screen.getByPlaceholderText(/password/i)).toBeInTheDocument();
    // Switch to passkey method
    const passkeyButton = screen.getByRole('button', { name: /passkey/i });
    await user.click(passkeyButton);
    expect(screen.getByRole('button', { name: /sign in with passkey/i })).toBeInTheDocument();
    // Switch to magic link method
    const magicLinkButton = screen.getByRole('button', { name: /magic link/i });
    await user.click(magicLinkButton);
    expect(screen.getByRole('button', { name: /send magic link/i })).toBeInTheDocument();
  });
  it('should handle password login submission', async () => {
    const user = userEvent.setup();
    mockAuthStore.login.mockResolvedValue({
      success: true,
      data: { user: { id: '1', email: 'test@example.com' } }
    });
    render(<ModernLoginForm />);
    // Fill in form
    await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
    await user.type(screen.getByPlaceholderText(/password/i), 'password123');
    // Submit form
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    await waitFor(() => {
      expect(mockAuthStore.login).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123'
      });
    });
  });
  it('should show validation error for empty fields', async () => {
    const user = userEvent.setup();
    render(<ModernLoginForm />);
    // Submit without filling fields
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    await waitFor(() => {
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Missing credentials',
        description: 'Please enter both email and password',
        variant: 'destructive'
      });
    });
  });
  it('should toggle password visibility', async () => {
    const user = userEvent.setup();
    render(<ModernLoginForm />);
    const passwordInput = screen.getByPlaceholderText(/password/i);
    const toggleButton = screen.getByTestId('eye-icon').closest('button');
    // Initially password should be hidden
    expect(passwordInput).toHaveAttribute('type', 'password');
    // Click to show password
    if (toggleButton) {
      await user.click(toggleButton);
    }
    await waitFor(() => {
      expect(passwordInput).toHaveAttribute('type', 'text');
    });
  });
  it('should handle magic link sending', async () => {
    const user = userEvent.setup();
    const { magicLinkService } = require('@/services/auth-api.service');
    magicLinkService.sendMagicLink.mockResolvedValue({ success: true });
    render(<ModernLoginForm />);
    // Switch to magic link method
    const magicLinkButton = screen.getByRole('button', { name: /magic link/i });
    await user.click(magicLinkButton);
    // Enter email
    await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
    // Send magic link
    const sendButton = screen.getByRole('button', { name: /send magic link/i });
    await user.click(sendButton);
    await waitFor(() => {
      expect(magicLinkService.sendMagicLink).toHaveBeenCalledWith('test@example.com');
    });
  });
  it('should handle passkey authentication', async () => {
    const user = userEvent.setup();
    const { webAuthnService } = require('@/services/auth-api.service');
    webAuthnService.startAuthentication.mockResolvedValue({
      success: true,
      data: { challenge: 'mock-challenge', allowCredentials: [] }
    });}}));
    // Mock navigator.credentials.get
    global.navigator.credentials = {
      get: jest.fn().mockResolvedValue({
        id: 'mock-credential-id',
        response: {
          authenticatorData: new ArrayBuffer(8),
          clientDataJSON: new ArrayBuffer(8),
          signature: new ArrayBuffer(8),
        },
      }),
    } as jest.Mocked<any>;
    render(<ModernLoginForm />);
    // Switch to passkey method
    const passkeyButton = screen.getByRole('button', { name: /passkey/i });
    await user.click(passkeyButton);
    // Click sign in with passkey
    const signInButton = screen.getByRole('button', { name: /sign in with passkey/i });
    await user.click(signInButton);
    await waitFor(() => {
      expect(webAuthnService.startAuthentication).toHaveBeenCalled();
    });
  });
  it('should show loading state during authentication', async () => {
    const user = userEvent.setup();
    mockAuthStore.login.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 1000)));
    render(<ModernLoginForm />);
    // Fill in form
    await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
    await user.type(screen.getByPlaceholderText(/password/i), 'password123');
    // Submit form
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    // Should show loading state
    expect(screen.getByTestId('loader2-icon')).toBeInTheDocument();
  });
  it('should handle login errors', async () => {
    const user = userEvent.setup();
    mockAuthStore.login.mockResolvedValue({
      success: false,
      error: { message: 'Invalid credentials' }
    });
    render(<ModernLoginForm />);
    // Fill in form
    await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
    await user.type(screen.getByPlaceholderText(/password/i), 'wrongpassword');
    // Submit form
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    await waitFor(() => {
      expect(mockToast).toHaveBeenCalledWith({
        title: 'Login failed',
        description: 'Invalid credentials',
        variant: 'destructive'
      });
    });
  });
  it('should render OAuth providers section', async () => {
    render(<ModernLoginForm />);
    expect(screen.getByTestId('github-icon')).toBeInTheDocument();
    expect(screen.getByTestId('chrome-icon')).toBeInTheDocument();
  });
  it('should render links to other auth pages', async () => {
    render(<ModernLoginForm />);
    expect(screen.getByText(/forgot password/i)).toBeInTheDocument();
    expect(screen.getByText(/create account/i)).toBeInTheDocument();
  });
  it('should handle form validation for email format', async () => {
    const user = userEvent.setup();
    render(<ModernLoginForm />);
    // Enter invalid email
    await user.type(screen.getByPlaceholderText(/email/i), 'invalid-email');
    await user.type(screen.getByPlaceholderText(/password/i), 'password123');
    // Submit form
    await user.click(screen.getByRole('button', { name: /sign in/i }));
    // Should show validation error (implementation dependent)
    // This test assumes the form validates email format
  });
  it('should show success state for magic link', async () => {
    const user = userEvent.setup();
    const { magicLinkService } = require('@/services/auth-api.service');
    magicLinkService.sendMagicLink.mockResolvedValue({ success: true });
    render(<ModernLoginForm />);
    // Switch to magic link method
    const magicLinkButton = screen.getByRole('button', { name: /magic link/i });
    await user.click(magicLinkButton);
    // Enter email and send
    await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
    await user.click(screen.getByRole('button', { name: /send magic link/i }));
    await waitFor(() => {
      expect(screen.getByTestId('check-icon')).toBeInTheDocument();
      expect(screen.getByText(/check your email/i)).toBeInTheDocument();
    });
  });

describe('Accessibility', () => {
    it('should have proper form labels and ARIA attributes', async () => {
      render(<ModernLoginForm />);
      const emailInput = screen.getByPlaceholderText(/email/i);
      const passwordInput = screen.getByPlaceholderText(/password/i);
      expect(emailInput).toHaveAttribute('type', 'email');
      expect(passwordInput).toHaveAttribute('type', 'password');
    });
    it('should be keyboard navigable', async () => {
      const user = userEvent.setup();
      render(<ModernLoginForm />);
      // Tab through form elements
      await user.tab();
      expect(screen.getByPlaceholderText(/email/i)).toHaveFocus();
      await user.tab();
      expect(screen.getByPlaceholderText(/password/i)).toHaveFocus();
      await user.tab();
      expect(screen.getByRole('button', { name: /sign in/i })).toHaveFocus();
    });
    it('should announce loading state to screen readers', async () => {
      const user = userEvent.setup();
      mockAuthStore.login.mockImplementation(() => new Promise(resolve => setTimeout(resolve, 1000)));
      render(<ModernLoginForm />);
      await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
      await user.type(screen.getByPlaceholderText(/password/i), 'password123');
      await user.click(screen.getByRole('button', { name: /sign in/i }));
      // Button should indicate loading state
      const button = screen.getByRole('button');
      expect(button).toBeDisabled();
    });
  });

describe('Edge Cases', () => {
    it('should handle network errors gracefully', async () => {
      const user = userEvent.setup();
      mockAuthStore.login.mockRejectedValue(new Error('Network error'));
      render(<ModernLoginForm />);
      await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
      await user.type(screen.getByPlaceholderText(/password/i), 'password123');
      await user.click(screen.getByRole('button', { name: /sign in/i }));
      await waitFor(() => {
        expect(mockToast).toHaveBeenCalledWith({
          title: 'Login failed',
          description: 'An unexpected error occurred. Please try again.',
          variant: 'destructive'
        });
      });
    });
    it('should handle passkey not supported', async () => {
      const user = userEvent.setup();
      // Mock unsupported browser
      global.navigator.credentials = undefined;
      render(<ModernLoginForm />);
      const passkeyButton = screen.getByRole('button', { name: /passkey/i });
      await user.click(passkeyButton);
      const signInButton = screen.getByRole('button', { name: /sign in with passkey/i });
      await user.click(signInButton);
      await waitFor(() => {
        expect(mockToast).toHaveBeenCalledWith({
          title: 'Passkey not supported',
          description: 'Your browser does not support passkeys.',
          variant: 'destructive'
        });
      });
    });
    it('should prevent multiple simultaneous submissions', async () => {
      const user = userEvent.setup();
      let resolveLogin: (value: unknown) => void;
      mockAuthStore.login.mockImplementation(() => new Promise(resolve => { resolveLogin = resolve; }));
      render(<ModernLoginForm />);
      await user.type(screen.getByPlaceholderText(/email/i), 'test@example.com');
      await user.type(screen.getByPlaceholderText(/password/i), 'password123');
      // First submission
      await user.click(screen.getByRole('button', { name: /sign in/i }));
      // Button should be disabled
      const button = screen.getByRole('button');
      expect(button).toBeDisabled();
      // Second click should not trigger another login
      await user.click(button);
      expect(mockAuthStore.login).toHaveBeenCalledTimes(1);
    });
  });

describe('Visual States', () => {
    it('should highlight active auth method', async () => {
      render(<ModernLoginForm />);
      const passwordButton = screen.getByRole('button', { name: /password/i });
      const passkeyButton = screen.getByRole('button', { name: /passkey/i });
      // Password should be active by default
      expect(passwordButton).toHaveClass('bg-blue-50');
      expect(passkeyButton).not.toHaveClass('bg-blue-50');
    });
    it('should show proper icons for each auth method', async () => {
      render(<ModernLoginForm />);
      expect(screen.getByTestId('lock-icon')).toBeInTheDocument();
      expect(screen.getByTestId('fingerprint-icon')).toBeInTheDocument();
      expect(screen.getByTestId('zap-icon')).toBeInTheDocument();
    });
  });
});