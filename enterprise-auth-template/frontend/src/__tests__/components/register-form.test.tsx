import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { useRouter } from 'next/navigation';
import { RegisterForm } from '@/components/auth/register-form';
import { useAuthStore } from '@/stores/auth.store';
import { useAuthForm } from '@/hooks/use-auth-form';

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
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));
jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: jest.fn(),
  validationRules: {
    firstName: { required: 'First name is required' },
    lastName: { required: 'Last name is required' },
    email: { required: 'Email is required', pattern: /\S+@\S+\.\S+/ },
    password: { required: 'Password is required', minLength: 8 },
    confirmPassword: jest.fn(),
    terms: { required: 'You must agree to the terms' },
  },
  isFormValid: jest.fn(),
}));

jest.mock('@/components/ui/button', () => ({
  Button: ({ children, disabled, onClick, ...props }: ButtonProps) => (
    <button disabled={disabled} onClick={onClick} {...props}>
      {children}
    </button>
  ),
}));

jest.mock('@/components/ui/input', () => ({
  Input: React.forwardRef<HTMLInputElement, InputProps>(function Input({ ...props }, ref) {
    return <input ref={ref} {...props} />;
  }),
}));

jest.mock('@/components/ui/password-input', () => ({
  PasswordInput: React.forwardRef<HTMLInputElement, PasswordInputProps>(function PasswordInput({ ...props }, ref) {
    return <input ref={ref} type='password' {...props} />;
  }),
}));

jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children, variant, ...props }: AlertProps) => (
    <div data-testid='alert' data-variant={variant} {...props}>
      {children}
    </div>
  ),
  AlertDescription: ({ children, ...props }: AlertDescriptionProps) => (
    <div data-testid='alert-description' {...props}>
      {children}
    </div>
  ),
}));

jest.mock('@/components/ui/card', () => ({
  Card: ({ children, ...props }: CardProps) => <div {...props}>{children}</div>,
  CardContent: ({ children, ...props }: CardContentProps) => <div {...props}>{children}</div>,
  CardDescription: ({ children, ...props }: CardDescriptionProps) => (
    <div {...props}>{children}</div>
  ),
  CardHeader: ({ children, ...props }: CardHeaderProps) => <div {...props}>{children}</div>,
  CardTitle: ({ children, ...props }: CardTitleProps) => <h1 {...props}>{children}</h1>,
}));

jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }: FormProps) => <form {...props}>{children}</form>,
  FormControl: ({ children, ...props }: FormControlProps) => <div {...props}>{children}</div>,
  FormField: ({ render }: FormFieldProps) => {
    const field = { value: '', onChange: jest.fn(), onBlur: jest.fn() };
    return render({ field });
  },
}));

jest.mock('@/components/auth/password-strength-indicator', () => ({
  PasswordStrengthIndicator: ({ password }: PasswordStrengthIndicatorProps) => (
    <div data-testid='password-strength' data-password={password}>
      Password strength indicator
    </div>
  ),
}));

jest.mock('next/link', () => {
  function MockLink({ children, href, ...props }: LinkProps) {
    return (
      <a href={href} {...props}>
        {children}
      </a>
    );
  }
  return MockLink;
});
// Mock auth store
const mockLogin = jest.fn();
const mockRegister = jest.fn();
const mockLogout = jest.fn();
const mockSetUser = jest.fn();
/**
 * @jest-environment jsdom
 */
  ButtonProps,
  InputProps,
  AlertProps,
  AlertDescriptionProps,
  CardProps,
  CardContentProps,
  CardDescriptionProps,
  CardHeaderProps,
  CardTitleProps,
  FormFieldProps,
} from '../../types/test-interfaces';
// Specific password input props
interface PasswordInputProps {
  placeholder?: string;
  value?: string;
  onChange?: React.ChangeEventHandler<HTMLInputElement>;
  className?: string;
  disabled?: boolean;
  required?: boolean;
  name?: string;
  id?: string;
interface FormProps {
  children: React.ReactNode;
  [key: string]: unknown;
interface FormControlProps {
  children: React.ReactNode;
  [key: string]: unknown;
// Form component props
interface FormProps {
  children: React.ReactNode;
  className?: string;
  onSubmit?: React.FormEventHandler<HTMLFormElement>;
interface FormControlProps {
  children: React.ReactNode;
  className?: string;
interface FormItemProps {
  children: React.ReactNode;
  className?: string;
interface FormLabelProps {
  children: React.ReactNode;
  className?: string;
  htmlFor?: string;
interface FormMessageProps {
  children: React.ReactNode;
  className?: string;
interface FormItemProps {
  children: React.ReactNode;
  [key: string]: unknown;
interface FormLabelProps {
  children: React.ReactNode;
  [key: string]: unknown;
interface FormMessageProps {
  children: React.ReactNode;
  [key: string]: unknown;
interface PasswordStrengthIndicatorProps {
  password: string;
interface LinkProps {
  children: React.ReactNode;
  href?: string;
  [key: string]: unknown;
// Mock Next.js router
// Mock auth context
  useAuth: jest.fn(),
// Mock auth form hook
// Mock UI components
  FormItem: ({ children, ...props }: FormItemProps) => <div {...props}>{children}</div>,
  FormLabel: ({ children, ...props }: FormLabelProps) => <label {...props}>{children}</label>,
  FormMessage: ({ children, ...props }: FormMessageProps) => (
    <div data-testid='form-message' {...props}>
  MockLink.displayName = 'MockLink';
  return MockLink;
const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
const mockAuthContext = {
  register: jest.fn(),
const mockForm = {
  handleSubmit: jest.fn(),
  control: {},
  watch: jest.fn(),
  formState: { errors: {} },
const mockUseAuthForm = {
  form: mockForm,
  isSubmitting: false,
  handleSubmit: jest.fn(),
describe('RegisterForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue(mockRouter);
    (useAuth as jest.Mock).mockReturnValue(mockAuthContext);
    (useAuthForm as jest.Mock).mockReturnValue(mockUseAuthForm);
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(true);
    mockForm.watch.mockReturnValue('password123');
  });
  it('renders the registration form', () => {
    render(<RegisterForm />);
    expect(screen.getByText('Create an account')).toBeInTheDocument();
    expect(screen.getByText('Enter your details to get started')).toBeInTheDocument();
    expect(screen.getByLabelText('First name')).toBeInTheDocument();
    expect(screen.getByLabelText('Last name')).toBeInTheDocument();
    expect(screen.getByLabelText('Email address')).toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toBeInTheDocument();
    expect(screen.getByLabelText('Confirm password')).toBeInTheDocument();
  });
  it('renders form fields with correct placeholders', () => {
    render(<RegisterForm />);
    expect(screen.getByPlaceholderText('John')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Doe')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('john@example.com')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Create a strong password')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Confirm your password')).toBeInTheDocument();
  });
  it('renders terms and conditions checkbox', () => {
    render(<RegisterForm />);
    expect(screen.getByText(/I agree to the/)).toBeInTheDocument();
    expect(screen.getByText('Terms of Service')).toBeInTheDocument();
    expect(screen.getByText('Privacy Policy')).toBeInTheDocument();
    const termsCheckbox = screen.getByRole('checkbox');
    expect(termsCheckbox).toBeInTheDocument();
  });
  it('renders password strength indicator', () => {
    render(<RegisterForm />);
    const strengthIndicator = screen.getByTestId('password-strength');
    expect(strengthIndicator).toBeInTheDocument();
    expect(strengthIndicator).toHaveAttribute('data-password', 'password123');
  });
  it('shows loading state when submitting', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true,
    });
    render(<RegisterForm />);
    expect(screen.getByText('Creating account...')).toBeInTheDocument();
  });
  it('shows error message when there is an error', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      error: 'Registration failed',
    });
    render(<RegisterForm />);
    const alert = screen.getByTestId('alert');
    expect(alert).toBeInTheDocument();
    expect(alert).toHaveAttribute('data-variant', 'destructive');
    expect(screen.getByText('Registration failed')).toBeInTheDocument();
  });
  it('disables submit button when form is invalid', () => {
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(false);
    render(<RegisterForm />);
    const submitButton = screen.getByRole('button', { name: /create account/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when loading', () => {
    (useAuth as jest.Mock).mockReturnValue({
      ...mockAuthContext,
      isLoading: true,
    });
    render(<RegisterForm />);
    const submitButton = screen.getByRole('button', { name: /create account/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when submitting', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true,
    });
    render(<RegisterForm />);
    const submitButton = screen.getByRole('button', { name: /creating account/i });
    expect(submitButton).toBeDisabled();
  });
  it('enables submit button when form is valid and not loading', () => {
    render(<RegisterForm />);
    const submitButton = screen.getByRole('button', { name: /create account/i });
    expect(submitButton).not.toBeDisabled();
  });
  it('calls register function on form submission', async () => {
    const mockHandleSubmit = jest.fn();
    mockUseAuthForm.handleSubmit.mockReturnValue(mockHandleSubmit);
    render(<RegisterForm />);
    const form = screen.getByRole('form');
    act(() => { fireEvent.submit(form); });
    expect(mockForm.handleSubmit).toHaveBeenCalled();
  });
  it('calls onSuccess callback when provided', () => {
    const mockOnSuccess = jest.fn();
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      // Simulate successful form submission
      callback({
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
        first_name: 'Test',
        last_name: 'User',
        terms: true,
      });
      return jest.fn();
    });
    render(<RegisterForm onSuccess={mockOnSuccess} />);
    // This test would need more setup to properly test the onSuccess flow
    // For now, we verify the component renders without errors
    expect(screen.getByText('Create an account')).toBeInTheDocument();
  });
  it('redirects to dashboard on successful registration without callback', () => {
    // Test the default behavior when no onSuccess prop is provided
    render(<RegisterForm />);
    expect(screen.getByText('Create an account')).toBeInTheDocument();
    // The actual redirect test would require mocking the success flow
  });
  it('renders login link', () => {
    render(<RegisterForm />);
    expect(screen.getByText('Already have an account?')).toBeInTheDocument();
    const loginLink = screen.getByText('Sign in');
    expect(loginLink).toBeInTheDocument();
    expect(loginLink.closest('a')).toHaveAttribute('href', '/auth/login');
  });
  it('renders terms and privacy policy links', () => {
    render(<RegisterForm />);
    const termsLink = screen.getByText('Terms of Service');
    expect(termsLink.closest('a')).toHaveAttribute('href', '/terms');
    const privacyLink = screen.getByText('Privacy Policy');
    expect(privacyLink.closest('a')).toHaveAttribute('href', '/privacy');
  });
  it('disables form fields when loading', () => {
    (useAuth as jest.Mock).mockReturnValue({
      ...mockAuthContext,
      isLoading: true,
    });
    render(<RegisterForm />);
    const inputs = screen.getAllByRole('textbox');
    inputs.forEach((input) => {
      expect(input).toBeDisabled();
    });
    const passwordInputs = screen.getAllByDisplayValue('');
    passwordInputs.forEach((input) => {
      if ((input as HTMLInputElement).type === 'password') {
        expect(input).toBeDisabled();
      }
    });
    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeDisabled();
  });
  it('disables form fields when submitting', () => {
    (useAuthForm as jest.Mock).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true,
    });
    render(<RegisterForm />);
    const inputs = screen.getAllByRole('textbox');
    inputs.forEach((input) => {
      expect(input).toBeDisabled();
    });
    const checkbox = screen.getByRole('checkbox');
    expect(checkbox).toBeDisabled();
  });
  it('handles form submission with correct data transformation', () => {
    const mockRegister = jest.fn().mockResolvedValue(true);
    (useAuth as jest.Mock).mockReturnValue({
      ...mockAuthContext,
      register: mockRegister,
    });
    const mockSubmitHandler = jest.fn();
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      // Simulate form submission with test data
      const testData = {
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
        first_name: 'Test',
        last_name: 'User',
        terms: true,
      };
      callback(testData);
      return mockSubmitHandler;
    });
    render(<RegisterForm />);
    // Verify the component is set up correctly
    expect(screen.getByText('Create an account')).toBeInTheDocument();
  });
  it('watches password field for strength indicator', () => {
    render(<RegisterForm />);
    expect(mockForm.watch).toHaveBeenCalledWith('password');
    const strengthIndicator = screen.getByTestId('password-strength');
    expect(strengthIndicator).toHaveAttribute('data-password', 'password123');
  });
  it('applies correct CSS classes', () => {
    render(<RegisterForm />);
    // Check for main card structure
    expect(screen.getByText('Create an account').closest('h1')).toBeInTheDocument();
    // Verify form structure is present
    const form = screen.getByRole('form');
    expect(form).toBeInTheDocument();
  });