import React from 'react';
import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from '@/components/auth/login-form';
import type { ApiResponse, LoginResponse, LoginRequest, User, TokenPair } from '@/types';
/**
 * @jest-environment jsdom
 */
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(() => mockRouter),
}));
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
  })),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  })),
}));
jest.mock('@/hooks/use-error-handler', () => ({
  useFormErrorHandler: () => mockErrorHandler,
}));
jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: () => mockAuthForm,
  validationRules: {
    email: {
      required: 'Email is required',
      pattern: {
        value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
        message: 'Invalid email address',
      },
    },
  },
  isFormValid: () => true,
}));

jest.mock('@/components/ui/button', () => ({
  Button: ({ children, disabled, onClick, type }: ButtonProps) => (
    <button
      type={type}
      disabled={disabled}
      onClick={onClick}
      data-testid="login-submit-button"
    >
      {children}
    </button>
  ),
}));

jest.mock('@/components/ui/input', () => ({
  Input: ({ type, placeholder, disabled, ...props }: InputProps) => (
    <input
      type={type}
      placeholder={placeholder}
      disabled={disabled}
      data-testid={`login-${type === 'email' ? 'email' : 'input'}-field`}
      {...props}
    />
  ),}));
jest.mock('@/components/ui/password-input', () => ({
  PasswordInput: ({ placeholder, disabled, ...props }: InputProps) => (
    <input
      type="password"
      placeholder={placeholder}
      disabled={disabled}
      data-testid="login-password-field"
      {...props}
    />
  ),}));
jest.mock('@/components/ui/checkbox', () => ({
  Checkbox: ({ id, checked, onCheckedChange, disabled }: CheckboxProps) => (
    <input
      type="checkbox"
      id={id}
      checked={checked}
      disabled={disabled}
      data-testid="login-remember-checkbox"
      onChange={(e) => onCheckedChange?.(e.target.checked)}
    />
  ),}));
jest.mock('@/components/ui/form', () => ({
  FormControl: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  FormField: ({ render }: FormFieldProps) => (
    <div data-testid="form-field">
      {render({ field: { value: '', onChange: jest.fn(), onBlur: jest.fn() } })}
    </div>
  ),
  FormItem: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  FormLabel: ({ children }: { children: React.ReactNode }) => <label>{children}</label>,
  FormMessage: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,}));
jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children }: { children: React.ReactNode }) => <div data-testid="error-alert">{children}</div>,
  AlertDescription: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,}));
jest.mock('@/components/ui/card', () => ({
  Card: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  CardContent: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  CardDescription: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  CardHeader: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  CardTitle: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,}));
jest.mock('@/components/ui/separator', () => ({
  Separator: () => <hr data-testid="separator" />,
}));
jest.mock('next/link', () => {
  return ({ children, href }: { children: React.ReactNode; href: string }) => (
    <a href={href}>{children}</a>
  );
});
jest.mock('@/components/auth/oauth-providers', () => {
  const OAuthProviders = ({ className, onSuccess }: { className?: string; onSuccess?: () => void }) => (
    <div data-testid="oauth-providers" className={className} onClick={onSuccess}>
      OAuth Providers
    </div>
  );
  return { default: OAuthProviders };
});
jest.mock('@/components/auth/two-factor-verify', () => ({
  TwoFactorVerify: ({ tempToken, onSuccess, onCancel }: {
    tempToken: string;
    onSuccess: () => void;
    onCancel: () => void;
  }) => (
    <div data-testid="two-factor-verify">
      <span>{tempToken}</span>
      <button onClick={onSuccess} data-testid="2fa-success">Success</button>
      <button onClick={onCancel} data-testid="2fa-cancel">Cancel</button>
    </div>
  ),
}));
jest.mock('lucide-react', () => ({
  Loader2: () => <span data-testid="loader-icon">Loading</span>,
  Mail: () => <span data-testid="mail-icon">Mail</span>,
  Lock: () => <span data-testid="lock-icon">Lock</span>,
  ArrowRight: () => <span data-testid="arrow-right-icon">Arrow</span>,
  Shield: () => <span data-testid="shield-icon">Shield</span>,
  Sparkles: () => <span data-testid="sparkles-icon">Sparkles</span>,}));
jest.mock('@/lib/utils', () => ({
  cn: (...classes: string[]) => classes.filter(Boolean).join(' '),}));
/**
 * Comprehensive Login Form Tests
 *
 * Tests the LoginForm component with proper TypeScript types,
 * React hooks dependency management, and full coverage.
 */
// Type-safe mock interfaces
interface MockRouter {
  push: jest.MockedFunction<(url: string) => void>;
  replace: jest.MockedFunction<(url: string) => void>;
  back: jest.MockedFunction<() => void>;
  forward: jest.MockedFunction<() => void>;
  refresh: jest.MockedFunction<() => void>;
  prefetch: jest.MockedFunction<(url: string) => Promise<void>>;
}
interface MockAuthStore {
  login: jest.MockedFunction<(credentials: LoginRequest) => Promise<ApiResponse<LoginResponse>>>;
  isLoading: boolean;
  user: User | null;
  isAuthenticated: boolean;
  error: { code: string; message: string; timestamp: Date } | null;
}
interface MockErrorHandler {
  handleFormError: jest.MockedFunction<(error: unknown) => { userMessage: string; code: string }>;
  clearAllErrors: jest.MockedFunction<() => void>;
}
interface MockFormControl {
  handleSubmit: jest.MockedFunction<(callback: (data: LoginFormData) => Promise<boolean>) => (e?: React.BaseSyntheticEvent) => Promise<void>>;
  control: {
    register: jest.MockedFunction<(name: string) => object>;
    formState: { errors: Record<string, { message?: string }> };
  };
  reset: jest.MockedFunction<() => void>;
}
interface MockAuthForm {
  form: MockFormControl;
  isSubmitting: boolean;
  error: string | null;
  setError: jest.MockedFunction<(error: string | null) => void>;
  handleSubmit: jest.MockedFunction<(callback: (data: LoginFormData) => Promise<boolean>) => (data: LoginFormData) => Promise<boolean>>;
}
interface LoginFormData {
  email: string;
  password: string;
  rememberMe?: boolean;
}
// Mock Next.js router with proper types
const mockRouter: MockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
  forward: jest.fn(),
  refresh: jest.fn(),
  prefetch: jest.fn().mockResolvedValue(undefined),
};
// Mock auth store with proper types
const mockAuthStore: MockAuthStore = {
  login: jest.fn(),
  isLoading: false,
  user: null,
  isAuthenticated: false,
  error: null,
};
// Mock error handler with proper types
const mockErrorHandler: MockErrorHandler = {
  handleFormError: jest.fn(),
  clearAllErrors: jest.fn(),
};
// Mock form hook with proper types
const mockAuthForm: MockAuthForm = {
  form: {
    handleSubmit: jest.fn(),
    control: {
      register: jest.fn(),
      formState: { errors: {} },
    },
    reset: jest.fn(),
  },
  isSubmitting: false,
  error: null,
  setError: jest.fn(),
  handleSubmit: jest.fn(),
};
// Mock UI components with proper TypeScript interfaces
interface ButtonProps {
  children: React.ReactNode;
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
  className?: string;
  onClick?: () => void;
}

interface InputProps {
  type?: string;
  placeholder?: string;
  className?: string;
  disabled?: boolean;
  value?: string;
  onChange?: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

interface FormFieldProps {
  control: MockFormControl['control'];
  name: string;
  rules?: object;
  render: (props: { field: { value: string; onChange: () => void; onBlur: () => void } }) => React.ReactNode;
}

interface CheckboxProps {
  id?: string;
  checked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  disabled?: boolean;
}

// Test data with proper types
const mockUser: User = {
  id: 'user-123',
  email: 'test@example.com',
  full_name: 'Test User',
  username: 'testuser',
  is_active: true,
  is_verified: true,
  email_verified: true,
  is_superuser: false,
  two_factor_enabled: false,
  failed_login_attempts: 0,
  last_login: '2024-01-01T00:00:00Z',
  user_metadata: {},
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  roles: [],
  permissions: [],
const mockTokens: TokenPair = {
  access_token: 'mock-access-token',
  refresh_token: 'mock-refresh-token',
  token_type: 'bearer',
  expires_in: 3600,
const successfulLoginResponse: ApiResponse<LoginResponse> = {
  success: true,
  data: {
    access_token: mockTokens.access_token,
    refresh_token: mockTokens.refresh_token,
    token_type: mockTokens.token_type,
    expires_in: mockTokens.expires_in,
    user: mockUser,
    requires_2fa: false,
describe('LoginForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset mocks to default state
    mockAuthStore.login.mockResolvedValue(successfulLoginResponse);
    mockAuthStore.isLoading = false;
    mockAuthStore.user = null;
    mockAuthStore.isAuthenticated = false;
    mockAuthStore.error = null;
    mockErrorHandler.handleFormError.mockReturnValue({
      userMessage: 'Test error message',
      code: 'TEST_ERROR'
    });
    mockAuthForm.isSubmitting = false;
    mockAuthForm.error = null;
    mockAuthForm.handleSubmit.mockImplementation((callback) => callback);
    mockAuthForm.form.handleSubmit.mockImplementation((callback) =>
      jest.fn((e) => {
        e?.preventDefault();
        return callback({ email: 'test@example.com', password: 'password123', rememberMe: false });
      })
    );
  });

describe('Rendering', () => {
    it('renders login form with all required elements', async () => {
      render(<LoginForm />);
      expect(screen.getByText('Welcome back')).toBeInTheDocument();
      expect(screen.getByText('Sign in to continue to your secure workspace')).toBeInTheDocument();
      expect(screen.getByTestId('login-email-field')).toBeInTheDocument();
      expect(screen.getByTestId('login-password-field')).toBeInTheDocument();
      expect(screen.getByTestId('login-remember-checkbox')).toBeInTheDocument();
      expect(screen.getByTestId('login-submit-button')).toBeInTheDocument();
      expect(screen.getByText('Forgot password?')).toBeInTheDocument();
      expect(screen.getByText('Create an account')).toBeInTheDocument();
    });
    it('renders OAuth providers section', async () => {
      render(<LoginForm />);
      expect(screen.getByTestId('oauth-providers')).toBeInTheDocument();
      expect(screen.getByText('Or continue with')).toBeInTheDocument();
    });
    it('renders security badge', async () => {
      render(<LoginForm />);
      expect(screen.getByText('Enterprise-grade security with end-to-end encryption')).toBeInTheDocument();
      expect(screen.getByTestId('sparkles-icon')).toBeInTheDocument();
    });
  });

describe('Form Interaction', () => {
    it('handles form submission with valid credentials', async () => {
      const user = userEvent.setup();
      const onSuccess = jest.fn();
      render(<LoginForm onSuccess={onSuccess} />);
      const submitButton = screen.getByTestId('login-submit-button');
      await user.click(submitButton);
      await act(async () => { await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockAuthStore.login).toHaveBeenCalledWith({
          email: 'test@example.com',
          password: 'password123'
        }); }); });
      });
      expect(onSuccess).toHaveBeenCalled();
    });
    it('redirects to dashboard when no onSuccess callback provided', async () => {
      const user = userEvent.setup();
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      await user.click(submitButton);
      await act(async () => { await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockRouter.push).toHaveBeenCalledWith('/dashboard');
      }); }); });
    });
    it('handles login failure with error message', async () => {
      const user = userEvent.setup();
      const failureResponse: ApiResponse<LoginResponse> = {
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      };
      mockAuthStore.login.mockResolvedValue(failureResponse);
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      await user.click(submitButton);
      await act(async () => { await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockAuthForm.setError).toHaveBeenCalledWith('Invalid email or password');
      }); }); });
    });
    it('handles remember me checkbox interaction', async () => {
      const user = userEvent.setup();
      render(<LoginForm />);
      const rememberCheckbox = screen.getByTestId('login-remember-checkbox');
      await user.click(rememberCheckbox);
      // Verify checkbox interaction (implementation depends on form library)
      expect(rememberCheckbox).toBeInTheDocument();
    });
  });

describe('Loading States', () => {
    it('disables form elements when auth store is loading', async () => {
      mockAuthStore.isLoading = true;
      render(<LoginForm />);
      expect(screen.getByTestId('login-email-field')).toBeDisabled();
      expect(screen.getByTestId('login-password-field')).toBeDisabled();
      expect(screen.getByTestId('login-remember-checkbox')).toBeDisabled();
      expect(screen.getByTestId('login-submit-button')).toBeDisabled();
    });
    it('disables form elements when form is submitting', async () => {
      mockAuthForm.isSubmitting = true;
      render(<LoginForm />);
      expect(screen.getByTestId('login-email-field')).toBeDisabled();
      expect(screen.getByTestId('login-password-field')).toBeDisabled();
      expect(screen.getByTestId('login-remember-checkbox')).toBeDisabled();
      expect(screen.getByTestId('login-submit-button')).toBeDisabled();
    });
    it('shows loading state in submit button', async () => {
      mockAuthForm.isSubmitting = true;
      render(<LoginForm />);
      expect(screen.getByText('Signing in...')).toBeInTheDocument();
      expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
    });
  });

describe('Error Handling', () => {
    it('displays form error when present', async () => {
      mockAuthForm.error = 'Invalid credentials';
      render(<LoginForm />);
      expect(screen.getByTestId('error-alert')).toBeInTheDocument();
      expect(screen.getByText('Invalid credentials')).toBeInTheDocument();
    });
    it('handles unexpected errors during login', async () => {
      const user = userEvent.setup();
      const error = new Error('Network error');
      mockAuthStore.login.mockRejectedValue(error);
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      await user.click(submitButton);
      await act(async () => { await act(async () => { await act(async () => { await waitFor(() => {
        expect(mockErrorHandler.handleFormError).toHaveBeenCalledWith(error);
        expect(mockAuthForm.setError).toHaveBeenCalledWith('Test error message');
      }); }); });
    });
    it('clears errors before form submission', async () => {
      const user = userEvent.setup();
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      await user.click(submitButton);
      expect(mockErrorHandler.clearAllErrors).toHaveBeenCalled();
    });
  });

describe('Two-Factor Authentication', () => {
    it('shows 2FA verification when required', async () => {
      const twoFactorResponse: ApiResponse<LoginResponse> = {
        success: true,
        data: {
          ...successfulLoginResponse.data!,
          requires_2fa: true,
          temp_token: 'temp-token-123',
        },
      };
      mockAuthStore.login.mockResolvedValue(twoFactorResponse);
      // Mock state to show 2FA component
      jest.spyOn(React, 'useState')
        .mockReturnValueOnce(['temp-token-123', jest.fn()]) // tempToken;
        .mockReturnValueOnce([true, jest.fn()]); // show2FA;
      render(<LoginForm />);
      expect(screen.getByTestId('two-factor-verify')).toBeInTheDocument();
      expect(screen.getByTestId('temp-token')).toHaveTextContent('temp-token-123');
    });
    it('handles 2FA success', async () => {
      const user = userEvent.setup();
      // Mock state to show 2FA component
      jest.spyOn(React, 'useState')
        .mockReturnValueOnce(['temp-token-123', jest.fn()]) // tempToken;
        .mockReturnValueOnce([true, jest.fn()]); // show2FA;
      // Mock window.location
      delete (window as { location?: Location }).location;
      window.location = { href: '' } as Location;
      render(<LoginForm />);
      const successButton = screen.getByTestId('2fa-success');
      await user.click(successButton);
      expect(window.location.href).toBe('/dashboard');
    });
    it('handles 2FA cancellation', async () => {
      const user = userEvent.setup();
      const setShow2FA = jest.fn();
      const setTempToken = jest.fn();
      // Mock state to show 2FA component
      jest.spyOn(React, 'useState')
        .mockReturnValueOnce(['temp-token-123', setTempToken]) // tempToken;
        .mockReturnValueOnce([true, setShow2FA]); // show2FA;
      render(<LoginForm />);
      const cancelButton = screen.getByTestId('2fa-cancel');
      await user.click(cancelButton);
      expect(setShow2FA).toHaveBeenCalledWith(false);
      expect(setTempToken).toHaveBeenCalledWith(null);
      expect(mockAuthForm.form.reset).toHaveBeenCalled();
    });
  });

describe('Navigation', () => {
    it('renders correct links with proper hrefs', async () => {
      render(<LoginForm />);
      const forgotPasswordLink = screen.getByText('Forgot password?').closest('a');
      const signUpLink = screen.getByText('Create an account').closest('a');
      expect(forgotPasswordLink).toHaveAttribute('href', '/auth/forgot-password');
      expect(signUpLink).toHaveAttribute('href', '/auth/register');
    });
  });

describe('Accessibility', () => {
    it('renders form with proper accessibility attributes', async () => {
      render(<LoginForm />);
      // Form fields should have labels
      expect(screen.getByText('Email')).toBeInTheDocument();
      expect(screen.getByText('Password')).toBeInTheDocument();
      // Remember me should have proper label association
      const rememberLabel = screen.getByText('Remember me');
      expect(rememberLabel).toBeInTheDocument();
    });
    it('provides appropriate button states for screen readers', async () => {
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      expect(submitButton).toHaveAttribute('type', 'submit');
    });
  });

describe('Form Validation', () => {
    it('disables submit button when form is invalid', async () => {
      // Mock form as invalid
      const { isFormValid } = require('@/hooks/use-auth-form');
      isFormValid.mockReturnValue(false);
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      expect(submitButton).toBeDisabled();
    });
    it('enables submit button when form is valid', async () => {
      // Form is valid by default in our mocks
      render(<LoginForm />);
      const submitButton = screen.getByTestId('login-submit-button');
      expect(submitButton).not.toBeDisabled();
    });
  });

describe('Component Integration', () => {
    it('integrates properly with auth store', async () => {
      render(<LoginForm />);
      // Verify useAuthStore is called
      expect(require('@/stores/auth.store').useAuthStore).toHaveBeenCalled();
    });
    it('integrates properly with form hooks', async () => {
      render(<LoginForm />);
      // Verify useAuthForm is called with correct parameters
      expect(require('@/hooks/use-auth-form').useAuthForm).toHaveBeenCalledWith(
        expect.objectContaining({
          defaultValues: {
            email: '',
            password: '',
            rememberMe: false,
          },
          onSuccess: expect.any(Function),
        })
      );
    });
    it('integrates properly with error handler', async () => {
      render(<LoginForm />);
      // Verify useFormErrorHandler is called
      expect(require('@/hooks/use-error-handler').useFormErrorHandler).toHaveBeenCalled();
    });
  });
}}}}}}}}}}}}}}}}}}}}}}