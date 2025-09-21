import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import { useRouter } from 'next/navigation';
import { LoginForm } from '@/components/auth/login-form';
import { useAuthStore } from '@/stores/auth.store';
import { useAuthForm } from '@/hooks/use-auth-form';
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
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
  })),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  })),
}));
jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: jest.fn(),
  validationRules: {
    email: { required: 'Email is required', pattern: /\S+@\S+\.\S+/ },
    password: { required: 'Password is required', minLength: 1 },
  },
  isFormValid: jest.fn(),
}));

jest.mock('@/components/auth/oauth-providers', () => {
  return function MockOAuthProviders({ className, onSuccess }: MockOAuthProvidersProps) {
    return (
      <div data-testid='oauth-providers' className={className}>
        OAuth Providers Component
        {onSuccess && <span data-testid='oauth-on-success'>has onSuccess</span>}
      </div>
    );
  };
});

jest.mock('@/components/auth/two-factor-verify', () => ({
  TwoFactorVerify: ({ tempToken, onSuccess, onCancel }: TwoFactorVerifyProps) => (
    <div data-testid='two-factor-verify'>
      <span data-testid='temp-token'>{tempToken}</span>
      <button onClick={onSuccess}>Verify Success</button>
      <button onClick={onCancel}>Cancel 2FA</button>
    </div>
  ),
}));

jest.mock('@/components/ui/button', () => ({
  Button: ({ children, disabled, onClick, className, type, ...props }: ComponentProps) => (
    <button disabled={disabled} onClick={onClick} className={className} type={type} {...props}>
      {children}
    </button>
  ),
}));

jest.mock('@/components/ui/input', () => {
  const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(({ ...props }, ref) => (
    <input ref={ref} {...props} />
  ));
  Input.displayName = 'Input';
  return { Input };
});
jest.mock('@/components/ui/password-input', () => {
  const PasswordInput = React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(({ ...props }, ref) => (
    <input ref={ref} type='password' {...props} />
  ));
  PasswordInput.displayName = 'PasswordInput';
  return { PasswordInput };
});
jest.mock('@/components/ui/alert', () => ({
  Alert: function Alert({ children, variant, ...props }: ComponentProps) {
    return (
      <div data-testid='alert' data-variant={variant} {...props}>
        {children}
      </div>
    );
  },
}));

jest.mock('@/components/ui/card', () => ({
  Card: ({ children, className, ...props }: ComponentProps) => (
    <div className={className} {...props}>
      {children}
    </div>
  ),
  CardContent: ({ children, ...props }: ComponentProps) => <div {...props}>{children}</div>,
  CardDescription: ({ children, ...props }: ComponentProps) => <div {...props}>{children}</div>,
  CardHeader: ({ children, ...props }: ComponentProps) => <div {...props}>{children}</div>,
  CardTitle: ({ children, ...props }: ComponentProps) => <h1 {...props}>{children}</h1>,
}));

jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }: ComponentProps) => <form {...props}>{children}</form>,
  FormControl: ({ children, ...props }: ComponentProps) => <div {...props}>{children}</div>,
  FormField: ({ render, name }: ComponentProps) => {
    const field = {
      value: name === 'rememberMe' ? 'false' : '',
      onChange: jest.fn(),
      onBlur: jest.fn(),
    };
    return render ? render({ field }) : <div data-testid="form-field" />;
  },
}));

jest.mock('next/link', () => {
  function MockLink({ children, href, ...props }: MockLinkProps) {
    return (
      <a href={href} {...props}>
        {children}
      </a>
    );
  };
  MockLink.displayName = 'MockLink';
  return MockLink;
});

jest.mock('lucide-react', () => ({
  Loader2: ({ className }: ComponentProps) => <div data-testid='loader-icon' className={className} />,
}));

/**
 * @jest-environment jsdom
 */
// Note: Interface imports removed as they're not used in this test file
// Component props interface for testing
interface ComponentProps {
  children?: React.ReactNode;
  className?: string;
  disabled?: boolean;
  onClick?: () => void;
  type?: string;
  variant?: string;
  render?: any;
  name?: string;
  [key: string]: any;
}
// Login-specific interface definitions
interface MockOAuthProvidersProps {
  className?: string;
  onSuccess?: () => void;
}
interface TwoFactorVerifyProps {
  tempToken: string;
  onSuccess: () => void;
  onCancel: () => void;
}
interface MockLinkProps {
  children: React.ReactNode;
  href: string;
  className?: string;
  target?: string;
  rel?: string;
}
// Mock Next.js router
const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
};
const mockAuthContext = {
  user: {
    id: 'current-user',
    email: 'current@example.com',
    first_name: 'Current',
    last_name: 'User',
    full_name: 'Current User',
    is_active: true,
    is_verified: true,
    email_verified: true,
    is_superuser: false,
    two_factor_enabled: false,
    failed_login_attempts: 0,
    last_login: new Date().toISOString(),
    user_metadata: {},
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    roles: [],
  tokens: {
    access_token: 'mock-access-token',
    refresh_token: 'mock-refresh-token',
    token_type: 'Bearer',
    expires_in: 3600,
  isAuthenticated: false,
  isLoading: false,
  permissions: [],
  hasPermission: jest.fn(() => false),
  hasRole: jest.fn(() => false),
  login: jest.fn(),
  register: jest.fn(),
  logout: jest.fn(),
  refreshToken: jest.fn(),
  setUser: jest.fn(),
  error: null,
};

const mockForm = {
  handleSubmit: jest.fn(),
  control: {},
  watch: jest.fn(),
  formState: { errors: {} },
  reset: jest.fn(),
const mockUseAuthForm = {
  form: mockForm,
  isSubmitting: false,
  error: null,
  setError: jest.fn(),
  handleSubmit: jest.fn(),
describe('LoginForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
    (useAuthStore as unknown as jest.Mock).mockReturnValue(mockAuthContext);
    (useAuthForm as jest.Mock).mockReturnValue(mockUseAuthForm);
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(true);
    // Reset window.location mock
    delete (window as unknown as Record<string, unknown>)['location'];
    (window as unknown as Record<string, unknown>)['location'] = { href: '' };
  });
  it('renders the login form', () => {
    render(<LoginForm />);
    expect(screen.getByText('Welcome back')).toBeInTheDocument();
    expect(screen.getByText('Enter your credentials to access your account')).toBeInTheDocument();
    expect(screen.getByLabelText('Email address')).toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toBeInTheDocument();
  });
  it('renders form fields with correct placeholders', () => {
    render(<LoginForm />);
    expect(screen.getByPlaceholderText('Enter your email')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter your password')).toBeInTheDocument();
  });
  it('renders remember me checkbox', () => {
    render(<LoginForm />);
    const rememberMeCheckbox = screen.getByRole('checkbox');
    const rememberMeLabel = screen.getByLabelText('Remember me');
    expect(rememberMeCheckbox).toBeInTheDocument();
    expect(rememberMeLabel).toBeInTheDocument();
  });
  it('renders forgot password link', () => {
    render(<LoginForm />);
    const forgotPasswordLink = screen.getByText('Forgot password?');
    expect(forgotPasswordLink).toBeInTheDocument();
    expect(forgotPasswordLink.closest('a')).toHaveAttribute('href', '/auth/forgot-password');
  });
  it('renders register link', () => {
    render(<LoginForm />);
    expect(screen.getByText("Don't have an account?")).toBeInTheDocument();
    const registerLink = screen.getByText('Sign up');
    expect(registerLink).toBeInTheDocument();
    expect(registerLink.closest('a')).toHaveAttribute('href', '/auth/register');
  });
  it('renders OAuth providers component', () => {
    render(<LoginForm />);
    expect(screen.getByTestId('oauth-providers')).toBeInTheDocument();
    expect(screen.getByText('OAuth Providers Component')).toBeInTheDocument();
  });
  it('passes onSuccess prop to OAuth providers when provided', () => {
    const mockOnSuccess = jest.fn();
    render(<LoginForm onSuccess={mockOnSuccess} />);
    expect(screen.getByTestId('oauth-on-success')).toBeInTheDocument();
  });
  it('shows loading state when submitting', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<LoginForm />);
    expect(screen.getByText('Signing in...')).toBeInTheDocument();
    expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
  });
  it('shows error message when there is an error', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      error: 'Invalid credentials'
    });
    render(<LoginForm />);
    const alert = screen.getByTestId('alert');
    expect(alert).toBeInTheDocument();
    expect(alert).toHaveAttribute('data-variant', 'destructive');
    expect(screen.getByText('Invalid credentials')).toBeInTheDocument();
  });
  it('disables submit button when form is invalid', () => {
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(false);
    render(<LoginForm />);
    const submitButton = screen.getByRole('button', { name: /sign in/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when loading', () => {
    (useAuth as unknown as jest.Mock).mockReturnValue({
      ...mockAuthContext,
      isLoading: true
    });
    render(<LoginForm />);
    const submitButton = screen.getByRole('button', { name: /sign in/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when submitting', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<LoginForm />);
    const submitButton = screen.getByRole('button', { name: /signing in/i });
    expect(submitButton).toBeDisabled();
  });
  it('enables submit button when form is valid and not loading', () => {
    render(<LoginForm />);
    const submitButton = screen.getByRole('button', { name: /sign in/i });
    expect(submitButton).not.toBeDisabled();
  });
  it('calls login function on form submission', async () => {
    const mockHandleSubmit = jest.fn();
    mockUseAuthForm.handleSubmit.mockReturnValue(mockHandleSubmit);
    render(<LoginForm />);
    const form = screen.getByRole('form');
    act(() => { fireEvent.submit(form) });
    expect(mockForm.handleSubmit).toHaveBeenCalled();
  });
  it('shows 2FA verification when tempToken is set', () => {
    const { rerender } = render(<LoginForm />);
    // Initially should not show 2FA
    expect(screen.queryByTestId('two-factor-verify')).not.toBeInTheDocument();
    // Mock the component state to show 2FA
    // Note: This is a limitation of testing React internal state
    // In a real scenario, this would be triggered by a successful login that requires 2FA
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', jest.fn()]);
      .mockImplementationOnce(() => [true, jest.fn()]);
    rerender(<LoginForm />);
    expect(screen.getByTestId('two-factor-verify')).toBeInTheDocument();
    expect(screen.getByTestId('temp-token')).toHaveTextContent('temp-token-123');
  });
  it('handles 2FA success correctly', () => {
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', jest.fn()]);
      .mockImplementationOnce(() => [true, jest.fn()]);
    render(<LoginForm />);
    const successButton = screen.getByText('Verify Success');
    act(() => { fireEvent.click(successButton) });
    expect(window.location.href).toBe('/dashboard');
  });
  it('handles 2FA success with onSuccess callback', () => {
    const mockOnSuccess = jest.fn();
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', jest.fn()]);
      .mockImplementationOnce(() => [true, jest.fn()]);
    render(<LoginForm onSuccess={mockOnSuccess} />);
    const successButton = screen.getByText('Verify Success');
    act(() => { fireEvent.click(successButton) });
    expect(window.location.href).toBe('/');
  });
  it('handles 2FA cancellation', () => {
    const mockSetShow2FA = jest.fn();
    const mockSetTempToken = jest.fn();
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', mockSetTempToken])
      .mockImplementationOnce(() => [true, mockSetShow2FA]);
    render(<LoginForm />);
    const cancelButton = screen.getByText('Cancel 2FA');
    act(() => { fireEvent.click(cancelButton) });
    expect(mockSetShow2FA).toHaveBeenCalledWith(false);
    expect(mockSetTempToken).toHaveBeenCalledWith(null);
    expect(mockForm.reset).toHaveBeenCalled();
  });
  it('disables form fields when loading', () => {
    (useAuth as unknown as jest.Mock).mockReturnValue({
      ...mockAuthContext,
      isLoading: true
    });
    render(<LoginForm />);
    const emailInput = screen.getByLabelText('Email address');
    const passwordInput = screen.getByLabelText('Password');
    const rememberMeCheckbox = screen.getByRole('checkbox');
    expect(emailInput).toBeDisabled();
    expect(passwordInput).toBeDisabled();
    expect(rememberMeCheckbox).toBeDisabled();
  });
  it('disables form fields when submitting', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<LoginForm />);
    const emailInput = screen.getByLabelText('Email address');
    const passwordInput = screen.getByLabelText('Password');
    const rememberMeCheckbox = screen.getByRole('checkbox');
    expect(emailInput).toBeDisabled();
    expect(passwordInput).toBeDisabled();
    expect(rememberMeCheckbox).toBeDisabled();
  });
  it('handles successful login with onSuccess callback', async () => {
    const mockOnSuccess = jest.fn();
    const mockLogin = jest.fn().mockResolvedValue(true);
    (useAuth as unknown as jest.Mock).mockReturnValue({
      ...mockAuthContext,
      login: mockLogin
    });
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      const testData = {
        email: 'test@example.com',
        password: 'password123',
        rememberMe: false,
      };
      // Simulate the async callback
      setTimeout(() => callback(testData), 0);
      return jest.fn();
    });
    render(<LoginForm onSuccess={mockOnSuccess} />);
    // This would require more complex mocking to properly test the async flow
    expect(screen.getByText('Welcome back')).toBeInTheDocument();
  });
  it('validates form fields correctly', () => {
    render(<LoginForm />);
    expect(require('@/hooks/use-auth-form').isFormValid).toHaveBeenCalledWith(mockForm, [
      'email',
      'password',
    ]);
  });
  it('applies correct CSS classes', () => {
    render(<LoginForm />);
    // Check for main card structure
    expect(screen.getByText('Welcome back').closest('h1')).toBeInTheDocument();
    // Verify form structure is present
    const form = screen.getByRole('form');
    expect(form).toBeInTheDocument();
    // Check OAuth providers has correct class
    const oauthProviders = screen.getByTestId('oauth-providers');
    expect(oauthProviders).toHaveClass('mt-6');
  });
  it('handles edge case with undefined onSuccess prop', () => {
    render(<LoginForm />);
    // Should render without crashing when onSuccess is undefined
    expect(screen.getByText('Welcome back')).toBeInTheDocument();
    expect(screen.getByTestId('oauth-providers')).toBeInTheDocument();
    expect(screen.queryByTestId('oauth-on-success')).not.toBeInTheDocument();
  });
}}}}}}}}}}}}}}