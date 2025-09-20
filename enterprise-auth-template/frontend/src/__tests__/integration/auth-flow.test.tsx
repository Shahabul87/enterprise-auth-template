import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import { useRouter } from 'next/navigation';
import { UseFormReturn, FieldValues } from 'react-hook-form';
import { LoginForm } from '@/components/auth/login-form';
import { useAuthStore } from '@/stores/auth.store';
/**
 * @jest-environment jsdom
 */
// Mock dependencies
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
jest.mock('@/hooks/use-error-handler', () => ({
  useFormErrorHandler: jest.fn(() => ({
    handleFormError: jest.fn(),
    clearAllErrors: jest.fn(),
  })),
}));

jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: jest.fn(),
  validationRules: {
    email: { required: 'Email is required' },
    password: { required: 'Password is required' },
  },
  isFormValid: jest.fn(),
}));

jest.mock('@/components/ui/button', () => ({
  Button: ({ children, disabled, onClick, type, ...props }: {
    children: React.ReactNode;
    disabled?: boolean;
    onClick?: () => void;
    type?: 'button' | 'submit' | 'reset';
    [key: string]: unknown;
  }) => (
    <button disabled={disabled} onClick={onClick} type={type} {...props}>
      {children}
    </button>
  ),
}));

jest.mock('@/components/ui/input', () => ({
  Input: React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(
    ({ ...props }, ref) => <input ref={ref} {...props} />
  ),
}));

jest.mock('@/components/ui/password-input', () => ({
  PasswordInput: React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(
    ({ ...props }, ref) => <input ref={ref} type='password' {...props} />
  ),
}));

jest.mock('@/components/ui/alert', () => ({
  Alert: ({ children, variant, ...props }: {
    children: React.ReactNode;
    variant?: string;
    [key: string]: unknown;
  }) => (
    <div data-testid='alert' data-variant={variant} {...props}>
      {children}
    </div>
  ),
  AlertDescription: ({ children, ...props }: {
    children: React.ReactNode;
    [key: string]: unknown;
  }) => (
    <div data-testid='alert-description' {...props}>
      {children}
    </div>
  ),
}));

jest.mock('@/components/ui/card', () => ({
  Card: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='card' {...props}>{children}</div>,
  CardContent: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='card-content' {...props}>{children}</div>,
  CardDescription: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='card-description' {...props}>{children}</div>,
  CardHeader: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='card-header' {...props}>{children}</div>,
  CardTitle: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <h1 data-testid='card-title' {...props}>{children}</h1>,
}));

jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <form {...props}>{children}</form>,
  FormControl: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='form-control' {...props}>{children}</div>,
  FormField: ({ render, name }: {
    render?: (props: { field: { value: string | boolean; onChange: () => void; onBlur: () => void } }) => React.ReactNode;
    name?: string;
  }) => {
    const field = {
      value: name === 'rememberMe' ? false : '',
      onChange: jest.fn(),
      onBlur: jest.fn(),
    };
    return render ? render({ field }) : <div data-testid="form-field" />;
  },
  FormItem: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='form-item' {...props}>{children}</div>,
  FormLabel: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <label data-testid='form-label' {...props}>{children}</label>,
  FormMessage: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) =>
    <div data-testid='form-message' {...props}>{children}</div>,
}));

jest.mock('next/link', () => {
  const MockLink = ({ children, href, ...props }: {
    children: React.ReactNode;
    href: string;
    [key: string]: unknown;
  }) => (
    <a href={href} {...props}>{children}</a>
  );
  MockLink.displayName = 'MockLink';
  return MockLink;
});
jest.mock('@/components/ui/checkbox', () => ({
  Checkbox: ({ checked, onCheckedChange, ...props }: {
    checked?: boolean;
    onCheckedChange?: (checked: boolean) => void;
    [key: string]: unknown;
  }) => (
    <input
      type="checkbox"
      checked={checked}
      onChange={(e) => onCheckedChange?.(e.target.checked)}
      data-testid='checkbox'
      {...props}
    />
  ),
}));

jest.mock('@/components/ui/separator', () => ({
  Separator: ({ className, ...props }: { className?: string; [key: string]: unknown }) =>
    <hr data-testid='separator' className={className} {...props} />,
}));

jest.mock('@/components/ui/label', () => ({
  Label: ({ children, ...props }: { children?: React.ReactNode; [key: string]: unknown }) =>
    <label data-testid='label' {...props}>{children}</label>,
}));

jest.mock('lucide-react', () => ({
  Loader2: ({ className }: { className?: string }) =>
    <div data-testid='loader-icon' className={className} />,
  Mail: ({ className }: { className?: string }) =>
    <div data-testid='mail-icon' className={className} />,
  Lock: ({ className }: { className?: string }) =>
    <div data-testid='lock-icon' className={className} />,
  ArrowRight: ({ className }: { className?: string }) =>
    <div data-testid='arrow-right-icon' className={className} />,
  Shield: ({ className }: { className?: string }) =>
    <div data-testid='shield-icon' className={className} />,
  Sparkles: ({ className }: { className?: string }) =>
    <div data-testid='sparkles-icon' className={className} />,
}));

jest.mock('@/components/auth/oauth-providers', () => {
  return function MockOAuthProviders({ className, onSuccess }: {
    className?: string;
    onSuccess?: () => void;
  }) {
    return (
      <div data-testid='oauth-providers' className={className}>
        <button onClick={onSuccess} data-testid='oauth-google'>Google Sign In</button>
        <button onClick={onSuccess} data-testid='oauth-github'>GitHub Sign In</button>
      </div>
    );
  };
});
jest.mock('@/components/auth/two-factor-verify', () => ({
  TwoFactorVerify: ({ tempToken, onSuccess, onCancel }: {
    tempToken: string;
    onSuccess: () => void;
    onCancel: () => void;
  }) => (
    <div data-testid='two-factor-verify'>
      <span data-testid='temp-token'>{tempToken}</span>
      <button onClick={onSuccess} data-testid='verify-success'>Verify Success</button>
      <button onClick={onCancel} data-testid='cancel-2fa'>Cancel 2FA</button>
    </div>
  ),
}));

// Create a test wrapper component that provides all necessary context
const TestWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return <div data-testid="test-wrapper">{children}</div>;
};
describe('Auth Flow Integration Tests', () => {
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
      isReady: true
    },
    reset: jest.fn(),
    getValues: jest.fn(),
    setValue: jest.fn(),
    getFieldState: jest.fn(),
    trigger: jest.fn(),
    resetField: jest.fn(),
    unregister: jest.fn(),
    setFocus: jest.fn(),
    register: jest.fn(),
    setError: jest.fn(),
    clearErrors: jest.fn(),
    subscribe: jest.fn(),
  } as UseFormReturn<FieldValues>;
  const mockUseAuthForm = {
    form: mockForm as UseFormReturn<FieldValues>,
    isSubmitting: false,
    error: '',
    setError: jest.fn(),
    handleSubmit: jest.fn(),
  };
  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.MockedFunction<typeof useRouter>).mockReturnValue(mockRouter);
    (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue(mockAuthStore);
    (require('@/hooks/use-auth-form').useAuthForm as jest.MockedFunction<typeof import('@/hooks/use-auth-form').useAuthForm>).mockReturnValue(mockUseAuthForm);
    (require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).mockReturnValue(true);
    // Mock form submission handling
    (mockForm['handleSubmit'] as unknown as jest.MockedFunction<(callback: (data: Record<string, unknown>) => void) => (event?: React.FormEvent) => void>).mockImplementation((callback: (data: Record<string, unknown>) => void) => (event?: React.FormEvent) => {
      event?.preventDefault?.();
      return callback({
        email: 'test@example.com',
        password: 'password123',
        rememberMe: false,
      });
    });
    mockUseAuthForm.handleSubmit.mockImplementation((callback: (data: Record<string, unknown>) => void) => callback);
  });

describe('Complete Login Flow', () => {
    it('should complete successful login flow', async () => {
      const mockLogin = jest.fn().mockResolvedValue({
        success: true,
        data: {
          user: {
            id: '1',
            email: 'test@example.com',
            name: 'Test User',
            role: 'user',
            isEmailVerified: true,
          },
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        },
      });
      (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
        ...mockAuthStore,
        login: mockLogin,
      });
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );
      // Verify login form is rendered
      expect(screen.getByText('Welcome back')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('name@company.com')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('••••••••')).toBeInTheDocument();
      // Fill out the form
      const emailInput = screen.getByPlaceholderText('name@company.com');
      const passwordInput = screen.getByPlaceholderText('••••••••');
      const submitButton = screen.getByRole('button', { name: /^Sign in$/ });
      act(() => {
        act(() => { fireEvent.change(emailInput, { target: { value: 'test@example.com' } }) });
      });
      act(() => {
        act(() => { fireEvent.change(passwordInput, { target: { value: 'password123' } }) });
      });
      // Submit the form
      act(() => {
        act(() => { fireEvent.click(submitButton) });
      });
      // Verify login was called
      await waitFor(() => {
        expect(mockLogin).toHaveBeenCalledWith({
          email: 'test@example.com',
          password: 'password123',
        });
      });
      // Verify redirect to dashboard
      expect(mockRouter.push).toHaveBeenCalledWith('/dashboard');
    });
    it('should handle login failure with error display', async () => {
      const mockLogin = jest.fn().mockResolvedValue({
        success: false,
        error: {
          code: 'INVALID_CREDENTIALS',
          message: 'Invalid email or password',
        },
      });
      (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
        ...mockAuthStore,
        login: mockLogin,
      });
      (require('@/hooks/use-auth-form').useAuthForm as jest.MockedFunction<typeof import('@/hooks/use-auth-form').useAuthForm>).mockReturnValue({
        ...mockUseAuthForm,
        error: 'Invalid email or password',
      });
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );
      // Fill out and submit the form
      const emailInput = screen.getByPlaceholderText('name@company.com');
      const passwordInput = screen.getByPlaceholderText('••••••••');
      const submitButton = screen.getByRole('button', { name: /^Sign in$/ });
      act(() => {
        act(() => { fireEvent.change(emailInput, { target: { value: 'test@example.com' } }) });
      });
      act(() => {
        act(() => { fireEvent.change(passwordInput, { target: { value: 'wrongpassword' } }) });
      });
      act(() => {
        act(() => { fireEvent.click(submitButton) });
      });
      // Verify error is displayed
      await waitFor(() => {
        expect(screen.getByTestId('alert')).toBeInTheDocument();
        expect(screen.getByTestId('alert-description')).toHaveTextContent('Invalid email or password');
      });
      // Verify no redirect occurred
      expect(mockRouter.push).not.toHaveBeenCalled();
    });
  });

describe('OAuth Authentication Flow', () => {
    it('should handle OAuth login success', async () => {
      const mockOnSuccess = jest.fn();
      render(
        <TestWrapper>
          <LoginForm onSuccess={mockOnSuccess} />
        </TestWrapper>
      );
      // Click OAuth provider button
      const googleButton = screen.getByTestId('oauth-google');
      act(() => {
        act(() => { fireEvent.click(googleButton) });
      });
      // Should call onSuccess callback
      expect(mockOnSuccess).toHaveBeenCalled();
    });
  });

describe('Form Validation Flow', () => {
    it('should prevent submission with invalid form', async () => {
      (require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).mockReturnValue(false);
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );
      const submitButton = screen.getByRole('button', { name: /^Sign in$/ });
      expect(submitButton).toBeDisabled();
      // Form should not be submittable
      act(() => {
        act(() => { fireEvent.click(submitButton) });
      });
      expect(mockAuthStore.login).not.toHaveBeenCalled();
    });
    it('should show loading state during submission', async () => {
      (require('@/hooks/use-auth-form').useAuthForm as jest.MockedFunction<typeof import('@/hooks/use-auth-form').useAuthForm>).mockReturnValue({
        ...mockUseAuthForm,
        isSubmitting: true,
      });
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );
      expect(screen.getByText('Signing in...')).toBeInTheDocument();
      expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
      const submitButton = screen.getByRole('button', { name: /Signing in/ });
      expect(submitButton).toBeDisabled();
    });
  });
});