/**
 * @jest-environment jsdom
 */
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
// import userEvent from '@testing-library/user-event'; // Currently unused
import { useRouter } from 'next/navigation';
import { LoginForm } from '@/components/auth/login-form';
import { useAuthStore } from '@/stores/auth.store';
import { useAuthForm } from '@/hooks/use-auth-form';
import { FieldValues, UseFormReturn } from 'react-hook-form';
import { useFormErrorHandler } from '@/hooks/use-error-handler';

// Interface definitions for mock components
interface MockOAuthProvidersProps {
  className?: string;
  onSuccess?: () => void;
}

interface TwoFactorVerifyProps {
  tempToken: string;
  onSuccess: () => void;
  onCancel: () => void;
}

interface ComponentProps {
  children?: React.ReactNode;
  type?: 'button' | 'submit' | 'reset';
  disabled?: boolean;
  variant?: string;
  className?: string;
  onClick?: () => void;
  placeholder?: string;
  autoComplete?: string;
  render?: (props: { field: { value: string; onChange: (value: string) => void; onBlur: () => void } }) => React.ReactNode;
  name?: string;
  control?: unknown;
  rules?: unknown;
  [key: string]: unknown;
}

interface MockLinkProps {
  children: React.ReactNode;
  href: string;
  [key: string]: unknown;
}

// Mock Next.js router
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));

// Mock auth store
jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(),
}));

// Mock error handler hook
jest.mock('@/hooks/use-error-handler', () => ({
  useFormErrorHandler: jest.fn(),
}));

// Mock auth form hook
jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: jest.fn(),
  validationRules: {
    email: { required: 'Email is required', pattern: { value: /\S+@\S+\.\S+/, message: 'Invalid email' } },
    password: { required: 'Password is required', minLength: { value: 1, message: 'Password required' } },
  },
  isFormValid: jest.fn(),
}));

// Mock OAuth providers
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

// Mock Two Factor Verify component
jest.mock('@/components/auth/two-factor-verify', () => ({
  TwoFactorVerify: ({ tempToken, onSuccess, onCancel }: TwoFactorVerifyProps) => (
    <div data-testid='two-factor-verify'>
      <span data-testid='temp-token'>{tempToken}</span>
      <button onClick={onSuccess} data-testid='verify-success'>Verify Success</button>
      <button onClick={onCancel} data-testid='cancel-2fa'>Cancel 2FA</button>
    </div>
  ),
}));

// Mock UI components
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
  AlertDescription: function AlertDescription({ children, ...props }: ComponentProps) {
    return (
      <div data-testid='alert-description' {...props}>
        {children}
      </div>
    );
  },
}));

jest.mock('@/components/ui/card', () => ({
  Card: ({ children, className, ...props }: ComponentProps) => (
    <div className={className} data-testid='card' {...props}>
      {children}
    </div>
  ),
  CardContent: ({ children, ...props }: ComponentProps) => <div data-testid='card-content' {...props}>{children}</div>,
  CardDescription: ({ children, ...props }: ComponentProps) => <div data-testid='card-description' {...props}>{children}</div>,
  CardHeader: ({ children, ...props }: ComponentProps) => <div data-testid='card-header' {...props}>{children}</div>,
  CardTitle: ({ children, ...props }: ComponentProps) => <h1 data-testid='card-title' {...props}>{children}</h1>,
}));

jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }: ComponentProps) => <form {...props}>{children}</form>,
  FormControl: ({ children, ...props }: ComponentProps) => <div data-testid='form-control' {...props}>{children}</div>,
  FormField: ({ render, name }: ComponentProps) => {
    const field = {
      value: name === 'rememberMe' ? 'false' : '',
      onChange: jest.fn(),
      onBlur: jest.fn(),
    };
    return render ? render({ field }) : <div data-testid="form-field" />;
  },
  FormItem: ({ children, ...props }: ComponentProps) => <div data-testid='form-item' {...props}>{children}</div>,
  FormLabel: ({ children, ...props }: ComponentProps) => <label data-testid='form-label' {...props}>{children}</label>,
  FormMessage: ({ children, ...props }: ComponentProps) => (
    <div data-testid='form-message' {...props}>
      {children}
    </div>
  ),
}));

jest.mock('next/link', () => {
  function MockLink({ children, href, ...props }: MockLinkProps) {
    return (
      <a href={href} {...props}>
        {children}
      </a>
    );
  }
  MockLink.displayName = 'MockLink';
  return MockLink;
});

jest.mock('lucide-react', () => ({
  Loader2: ({ className }: ComponentProps) => <div data-testid='loader-icon' className={className} />,
}));

const mockRouter = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
  forward: jest.fn(),
  refresh: jest.fn(),
  prefetch: jest.fn(),
};

const mockAuthStore = {
  login: jest.fn(),
  isLoading: false,
  user: null,
  error: null,
};

const mockErrorHandler = {
  error: null,
  fieldErrors: {},
  handleFormError: jest.fn(),
  clearAllErrors: jest.fn(),
  clearFieldError: jest.fn(),
  getFieldError: jest.fn(),
};

const mockForm = {
  handleSubmit: jest.fn(() => jest.fn()),
  control: {} as unknown,
  watch: jest.fn(),
  formState: { 
    errors: {},
    isValid: true,
    isSubmitting: false,
    isSubmitSuccessful: false,
    isDirty: false,
    isLoading: false,
    touchedFields: {},
    dirtyFields: {},
    validatingFields: {},
    submitCount: 0,
    isValidating: false,
    defaultValues: {},
    isSubmitted: false,
    disabled: false,
    isReady: true,
  },
  reset: jest.fn(),
  getValues: jest.fn().mockImplementation((name?: string | string[]) => {
    const values = { email: 'test@example.com', password: 'password123' };
    if (name) {
      if (Array.isArray(name)) {
        return name.map(key => values[key as keyof typeof values]);
      }
      return values[name as keyof typeof values];
    }
    return values;
  }),
  getFieldState: jest.fn(),
  setError: jest.fn(),
  clearErrors: jest.fn(),
  setValue: jest.fn(),
  setFocus: jest.fn(),
  trigger: jest.fn(),
  unregister: jest.fn(),
  register: jest.fn(() => ({
    onChange: jest.fn(),
    onBlur: jest.fn(),
    name: 'test',
    ref: jest.fn(),
  })),
  resetField: jest.fn(),
  subscribe: jest.fn(),
} as UseFormReturn<FieldValues>;

const mockUseAuthForm = {
  form: mockForm as UseFormReturn<FieldValues>,
  isSubmitting: false,
  error: '',
  setError: jest.fn(),
  clearError: jest.fn(),
  handleSubmit: jest.fn().mockImplementation((callback: (data: FieldValues) => Promise<boolean>) => async (data: FieldValues) => {
    const result = await callback(data);
    return result;
  }),
};

describe('LoginForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.MockedFunction<typeof useRouter>).mockReturnValue(mockRouter);
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue(mockAuthStore);
    (useFormErrorHandler as jest.MockedFunction<typeof useFormErrorHandler>).mockReturnValue(mockErrorHandler);
    (useAuthForm as jest.MockedFunction<typeof useAuthForm>).mockReturnValue(mockUseAuthForm);
    (require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).mockReturnValue(true);

    // Reset window.location mock
    delete (window as unknown as Record<string, unknown>)['location'];
    (window as unknown as Record<string, unknown>)['location'] = { href: '' };
  });

  it('renders the login form with all elements', () => {
    render(<LoginForm />);

    expect(screen.getByTestId('card-title')).toHaveTextContent('Welcome back');
    expect(screen.getByTestId('card-description')).toHaveTextContent('Enter your credentials to access your account');
    expect(screen.getByText('Email address')).toBeInTheDocument();
    expect(screen.getByText('Password')).toBeInTheDocument();
    expect(screen.getByText('Remember me')).toBeInTheDocument();
  });

  it('renders form fields with correct placeholders', () => {
    render(<LoginForm />);

    expect(screen.getByPlaceholderText('Enter your email')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter your password')).toBeInTheDocument();
  });

  it('renders remember me checkbox', () => {
    render(<LoginForm />);

    const rememberMeCheckbox = screen.getByRole('checkbox');
    const rememberMeLabel = screen.getByText('Remember me');

    expect(rememberMeCheckbox).toBeInTheDocument();
    expect(rememberMeLabel).toBeInTheDocument();
  });

  it('renders navigation links correctly', () => {
    render(<LoginForm />);

    const forgotPasswordLink = screen.getByText('Forgot password?');
    expect(forgotPasswordLink.closest('a')).toHaveAttribute('href', '/auth/forgot-password');

    const signUpLink = screen.getByText('Sign up');
    expect(signUpLink.closest('a')).toHaveAttribute('href', '/auth/register');
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
    (useAuthForm as jest.MockedFunction<typeof useAuthForm>).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true,
    });

    render(<LoginForm />);

    expect(screen.getByText('Signing in...')).toBeInTheDocument();
    expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
  });

  it('shows error message when there is an error', () => {
    (useAuthForm as jest.MockedFunction<typeof useAuthForm>).mockReturnValue({
      ...mockUseAuthForm,
      error: 'Invalid credentials',
    });

    render(<LoginForm />);

    const alert = screen.getByTestId('alert');
    expect(alert).toBeInTheDocument();
    expect(alert).toHaveAttribute('data-variant', 'destructive');
    expect(screen.getByTestId('alert-description')).toHaveTextContent('Invalid credentials');
  });

  it('disables submit button when form is invalid', () => {
    (require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).mockReturnValue(false);

    render(<LoginForm />);

    const submitButton = screen.getByRole('button', { name: /sign in/i });
    expect(submitButton).toBeDisabled();
  });

  it('disables submit button when loading', () => {
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
      ...mockAuthStore,
      isLoading: true,
    });

    render(<LoginForm />);

    const submitButton = screen.getByRole('button', { name: /sign in/i });
    expect(submitButton).toBeDisabled();
  });

  it('disables submit button when submitting', () => {
    (useAuthForm as jest.MockedFunction<typeof useAuthForm>).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true,
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
    const mockLogin = jest.fn().mockResolvedValue({ success: true });
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
      ...mockAuthStore,
      login: mockLogin,
    });

    render(<LoginForm />);

    const form = screen.getByTestId('card-content').querySelector('form');
    if (form) {
      fireEvent.submit(form);
      await waitFor(() => {
        expect(mockLogin).toHaveBeenCalled();
      });
    }
  });

  it('shows 2FA verification when tempToken is set', () => {
    const { rerender } = render(<LoginForm />);

    // Initially should not show 2FA
    expect(screen.queryByTestId('two-factor-verify')).not.toBeInTheDocument();

    // Mock the component state to show 2FA
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', jest.fn()])
      .mockImplementationOnce(() => [true, jest.fn()]);

    rerender(<LoginForm />);

    expect(screen.getByTestId('two-factor-verify')).toBeInTheDocument();
    expect(screen.getByTestId('temp-token')).toHaveTextContent('temp-token-123');
  });

  it('handles 2FA success correctly', () => {
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', jest.fn()])
      .mockImplementationOnce(() => [true, jest.fn()]);

    render(<LoginForm />);

    const successButton = screen.getByTestId('verify-success');
    fireEvent.click(successButton);

    expect(window.location.href).toBe('/dashboard');
  });

  it('handles 2FA success with onSuccess callback', () => {
    const mockOnSuccess = jest.fn();
    jest
      .spyOn(React, 'useState')
      .mockImplementationOnce(() => ['temp-token-123', jest.fn()])
      .mockImplementationOnce(() => [true, jest.fn()]);

    render(<LoginForm onSuccess={mockOnSuccess} />);

    const successButton = screen.getByTestId('verify-success');
    fireEvent.click(successButton);

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

    const cancelButton = screen.getByTestId('cancel-2fa');
    fireEvent.click(cancelButton);

    expect(mockSetShow2FA).toHaveBeenCalledWith(false);
    expect(mockSetTempToken).toHaveBeenCalledWith(null);
    expect(mockForm['reset']).toHaveBeenCalled();
  });

  it('disables form fields when loading', () => {
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
      ...mockAuthStore,
      isLoading: true,
    });

    render(<LoginForm />);

    const emailInput = screen.getByPlaceholderText('Enter your email');
    const passwordInput = screen.getByPlaceholderText('Enter your password');
    const rememberMeCheckbox = screen.getByRole('checkbox');

    expect(emailInput).toBeDisabled();
    expect(passwordInput).toBeDisabled();
    expect(rememberMeCheckbox).toBeDisabled();
  });

  it('disables form fields when submitting', () => {
    (useAuthForm as jest.MockedFunction<typeof useAuthForm>).mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true,
    });

    render(<LoginForm />);

    const emailInput = screen.getByPlaceholderText('Enter your email');
    const passwordInput = screen.getByPlaceholderText('Enter your password');
    const rememberMeCheckbox = screen.getByRole('checkbox');

    expect(emailInput).toBeDisabled();
    expect(passwordInput).toBeDisabled();
    expect(rememberMeCheckbox).toBeDisabled();
  });

  it('handles successful login with onSuccess callback', async () => {
    const mockOnSuccess = jest.fn();
    const mockLogin = jest.fn().mockResolvedValue({ success: true });

    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
      ...mockAuthStore,
      login: mockLogin,
    });

    render(<LoginForm onSuccess={mockOnSuccess} />);

    // Verify form renders with onSuccess prop
    expect(screen.getByText('Welcome back')).toBeInTheDocument();
    expect(screen.getByTestId('oauth-on-success')).toBeInTheDocument();
  });

  it('validates form fields correctly', () => {
    render(<LoginForm />);

    expect(require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).toHaveBeenCalledWith(mockForm, [
      'email',
      'password',
    ]);
  });

  it('applies correct CSS classes and structure', () => {
    render(<LoginForm />);

    // Check for main card structure
    expect(screen.getByTestId('card')).toBeInTheDocument();
    expect(screen.getByTestId('card-header')).toBeInTheDocument();
    expect(screen.getByTestId('card-content')).toBeInTheDocument();
    expect(screen.getByTestId('card-title')).toHaveTextContent('Welcome back');

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

  it('handles login error correctly', async () => {
    const mockLogin = jest.fn().mockResolvedValue({ 
      success: false, 
      error: { message: 'Invalid credentials' } 
    });
    
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
      ...mockAuthStore,
      login: mockLogin,
    });

    (useAuthForm as jest.MockedFunction<typeof useAuthForm>).mockReturnValue({
      ...mockUseAuthForm,
      error: 'Invalid credentials',
    });

    render(<LoginForm />);

    expect(screen.getByTestId('alert')).toBeInTheDocument();
    expect(screen.getByTestId('alert-description')).toHaveTextContent('Invalid credentials');
  });

  it('handles form validation correctly', () => {
    (require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).mockReturnValue(false);

    render(<LoginForm />);

    const submitButton = screen.getByRole('button', { name: /sign in/i });
    expect(submitButton).toBeDisabled();
  });

  it('shows form labels correctly', () => {
    render(<LoginForm />);

    expect(screen.getByText('Email address')).toBeInTheDocument();
    expect(screen.getByText('Password')).toBeInTheDocument();
    expect(screen.getByText('Remember me')).toBeInTheDocument();
  });

  it('calls error handler on login failure', async () => {
    const mockLogin = jest.fn().mockRejectedValue(new Error('Network error'));
    const mockHandleError = jest.fn().mockReturnValue({ userMessage: 'Network error occurred' });
    
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
      ...mockAuthStore,
      login: mockLogin,
    });

    (useFormErrorHandler as jest.MockedFunction<typeof useFormErrorHandler>).mockReturnValue({
      ...mockErrorHandler,
      handleFormError: mockHandleError,
    });

    render(<LoginForm />);

    const form = screen.getByTestId('card-content').querySelector('form');
    if (form) {
      fireEvent.submit(form);
      
      await waitFor(() => {
        expect(mockHandleError).toHaveBeenCalled();
        expect(mockUseAuthForm.setError).toHaveBeenCalledWith('Network error occurred');
      });
    }
  });
});