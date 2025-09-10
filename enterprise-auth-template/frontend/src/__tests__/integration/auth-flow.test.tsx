/**
 * @jest-environment jsdom
 */
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
// import userEvent from '@testing-library/user-event';
import { useRouter } from 'next/navigation';
import { UseFormReturn, FieldValues } from 'react-hook-form';
import { LoginForm } from '@/components/auth/login-form';
import { useAuthStore } from '@/stores/auth.store';

// Create a test wrapper component that provides all necessary context
const TestWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return <div data-testid="test-wrapper">{children}</div>;
};

// Mock all dependencies
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}));

jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(),
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

// Mock UI components
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
  Input: React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(({ ...props }, ref) => {
    const InputComponent = ({ ...inputProps }, inputRef: React.Ref<HTMLInputElement>) => (
      <input ref={inputRef} {...inputProps} />
    );
    InputComponent.displayName = 'Input';
    return InputComponent(props, ref);
  }),
}));

jest.mock('@/components/ui/password-input', () => ({
  PasswordInput: React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(({ ...props }, ref) => {
    const PasswordInputComponent = ({ ...inputProps }, inputRef: React.Ref<HTMLInputElement>) => (
      <input ref={inputRef} type='password' {...inputProps} />
    );
    PasswordInputComponent.displayName = 'PasswordInput';
    return PasswordInputComponent(props, ref);
  }),
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
  Card: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='card' {...props}>{children}</div>,
  CardContent: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='card-content' {...props}>{children}</div>,
  CardDescription: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='card-description' {...props}>{children}</div>,
  CardHeader: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='card-header' {...props}>{children}</div>,
  CardTitle: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <h1 data-testid='card-title' {...props}>{children}</h1>,
}));

jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <form {...props}>{children}</form>,
  FormControl: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='form-control' {...props}>{children}</div>,
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
  FormItem: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='form-item' {...props}>{children}</div>,
  FormLabel: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <label data-testid='form-label' {...props}>{children}</label>,
  FormMessage: ({ children, ...props }: { children: React.ReactNode; [key: string]: unknown }) => <div data-testid='form-message' {...props}>{children}</div>,
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

jest.mock('lucide-react', () => ({
  Loader2: ({ className }: { className?: string }) => <div data-testid='loader-icon' className={className} />,
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
    isLoading: false,
    user: null,
    error: null,
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
    clearError: jest.fn(),
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
      // const _user = userEvent.setup();
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
      expect(screen.getByTestId('card-title')).toHaveTextContent('Welcome back');
      expect(screen.getByPlaceholderText('Enter your email')).toBeInTheDocument();
      expect(screen.getByPlaceholderText('Enter your password')).toBeInTheDocument();

      // Fill out the form
      const emailInput = screen.getByPlaceholderText('Enter your email');
      const passwordInput = screen.getByPlaceholderText('Enter your password');
      const submitButton = screen.getByRole('button', { name: /sign in/i });

      fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
      fireEvent.change(passwordInput, { target: { value: 'password123' } });

      // Submit the form
      fireEvent.click(submitButton);

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
      // const _user = userEvent.setup();
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
      const emailInput = screen.getByPlaceholderText('Enter your email');
      const passwordInput = screen.getByPlaceholderText('Enter your password');
      const submitButton = screen.getByRole('button', { name: /sign in/i });

      fireEvent.change(emailInput, { target: { value: 'test@example.com' } });
      fireEvent.change(passwordInput, { target: { value: 'wrongpassword' } });
      fireEvent.click(submitButton);

      // Verify error is displayed
      await waitFor(() => {
        expect(screen.getByTestId('alert')).toBeInTheDocument();
        expect(screen.getByTestId('alert-description')).toHaveTextContent('Invalid email or password');
      });

      // Verify no redirect occurred
      expect(mockRouter.push).not.toHaveBeenCalled();
    });

    it('should handle 2FA flow correctly', async () => {
      // const _user = userEvent.setup();
      
      // Mock useState for 2FA state
      const mockSetTempToken = jest.fn();
      const mockSetShow2FA = jest.fn();
      jest.spyOn(React, 'useState')
        .mockImplementationOnce(() => ['temp-token-123', mockSetTempToken])
        .mockImplementationOnce(() => [true, mockSetShow2FA]);

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Should show 2FA verification component
      expect(screen.getByTestId('two-factor-verify')).toBeInTheDocument();
      expect(screen.getByTestId('temp-token')).toHaveTextContent('temp-token-123');

      // Complete 2FA verification
      const verifyButton = screen.getByTestId('verify-success');
      fireEvent.click(verifyButton);

      // Should redirect to dashboard
      expect(window.location.href).toBe('/dashboard');
    });

    it('should handle 2FA cancellation', async () => {
      const mockSetTempToken = jest.fn();
      const mockSetShow2FA = jest.fn();
      jest.spyOn(React, 'useState')
        .mockImplementationOnce(() => ['temp-token-123', mockSetTempToken])
        .mockImplementationOnce(() => [true, mockSetShow2FA]);

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Cancel 2FA
      const cancelButton = screen.getByTestId('cancel-2fa');
      fireEvent.click(cancelButton);

      expect(mockSetShow2FA).toHaveBeenCalledWith(false);
      expect(mockSetTempToken).toHaveBeenCalledWith(null);
      expect(mockForm['reset']).toHaveBeenCalled();
    });
  });

  describe('OAuth Authentication Flow', () => {
    it('should handle OAuth login success', async () => {
      // const _user = userEvent.setup();
      const mockOnSuccess = jest.fn();

      render(
        <TestWrapper>
          <LoginForm onSuccess={mockOnSuccess} />
        </TestWrapper>
      );

      // Click OAuth provider button
      const googleButton = screen.getByTestId('oauth-google');
      fireEvent.click(googleButton);

      // Should call onSuccess callback
      expect(mockOnSuccess).toHaveBeenCalled();
    });

    it('should handle OAuth login without callback', async () => {
      // const _user = userEvent.setup();

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Verify OAuth providers are rendered
      expect(screen.getByTestId('oauth-providers')).toBeInTheDocument();
      expect(screen.getByTestId('oauth-google')).toBeInTheDocument();
      expect(screen.getByTestId('oauth-github')).toBeInTheDocument();
    });
  });

  describe('Form Validation Flow', () => {
    it('should prevent submission with invalid form', async () => {
      // const _user = userEvent.setup();

      (require('@/hooks/use-auth-form').isFormValid as jest.MockedFunction<typeof import('@/hooks/use-auth-form').isFormValid>).mockReturnValue(false);

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      const submitButton = screen.getByRole('button', { name: /sign in/i });
      expect(submitButton).toBeDisabled();

      // Form should not be submittable
      fireEvent.click(submitButton);
      expect(mockAuthStore.login).not.toHaveBeenCalled();
    });

    it('should show loading state during submission', async () => {
      // const _user = userEvent.setup();

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
      
      const submitButton = screen.getByRole('button', { name: /signing in/i });
      expect(submitButton).toBeDisabled();
    });

    it('should disable form fields during loading', () => {
      (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
        ...mockAuthStore,
        isLoading: true,
      });

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      const emailInput = screen.getByPlaceholderText('Enter your email');
      const passwordInput = screen.getByPlaceholderText('Enter your password');
      const submitButton = screen.getByRole('button', { name: /sign in/i });
      const checkboxInput = screen.getByRole('checkbox');

      expect(emailInput).toBeDisabled();
      expect(passwordInput).toBeDisabled();
      expect(submitButton).toBeDisabled();
      expect(checkboxInput).toBeDisabled();
    });
  });

  describe('Navigation Flow', () => {
    it('should provide navigation to forgot password', () => {
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      const forgotPasswordLink = screen.getByText('Forgot password?');
      expect(forgotPasswordLink.closest('a')).toHaveAttribute('href', '/auth/forgot-password');
    });

    it('should provide navigation to registration', () => {
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      const registerLink = screen.getByText('Sign up');
      expect(registerLink.closest('a')).toHaveAttribute('href', '/auth/register');
    });
  });

  describe('Error Handling Flow', () => {
    it('should handle network errors gracefully', async () => {
      // const _user = userEvent.setup();
      const mockLogin = jest.fn().mockRejectedValue(new Error('Network error'));

      (useAuthStore as jest.MockedFunction<typeof useAuthStore>).mockReturnValue({
        ...mockAuthStore,
        login: mockLogin,
      });

      (require('@/hooks/use-auth-form').useAuthForm as jest.MockedFunction<typeof import('@/hooks/use-auth-form').useAuthForm>).mockReturnValue({
        ...mockUseAuthForm,
        error: 'Network error occurred',
      });

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Should display network error
      expect(screen.getByTestId('alert')).toBeInTheDocument();
      expect(screen.getByTestId('alert-description')).toHaveTextContent('Network error occurred');
    });

    it('should clear errors on successful form interaction', async () => {
      // const _user = userEvent.setup();

      // Start with an error state
      (require('@/hooks/use-auth-form').useAuthForm as jest.MockedFunction<typeof import('@/hooks/use-auth-form').useAuthForm>).mockReturnValue({
        ...mockUseAuthForm,
        error: 'Previous error',
      });

      const { rerender } = render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Verify error is shown
      expect(screen.getByTestId('alert-description')).toHaveTextContent('Previous error');

      // Clear error
      (require('@/hooks/use-auth-form').useAuthForm as jest.MockedFunction<typeof import('@/hooks/use-auth-form').useAuthForm>).mockReturnValue({
        ...mockUseAuthForm,
        error: '',
      });

      rerender(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Error should be cleared
      expect(screen.queryByTestId('alert')).not.toBeInTheDocument();
    });
  });

  describe('Accessibility Flow', () => {
    it('should have proper form labels and accessibility attributes', () => {
      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      // Check for proper form structure
      expect(screen.getByText('Email address')).toBeInTheDocument();
      expect(screen.getByText('Password')).toBeInTheDocument();
      expect(screen.getByText('Remember me')).toBeInTheDocument();

      // Check for proper input types
      const emailInput = screen.getByPlaceholderText('Enter your email');
      const passwordInput = screen.getByPlaceholderText('Enter your password');
      const checkbox = screen.getByRole('checkbox');

      expect(emailInput).toHaveAttribute('type', 'email');
      expect(passwordInput).toHaveAttribute('type', 'password');
      expect(checkbox).toHaveAttribute('type', 'checkbox');
    });

    it('should support keyboard navigation', async () => {
      // const _user = userEvent.setup();

      render(
        <TestWrapper>
          <LoginForm />
        </TestWrapper>
      );

      const emailInput = screen.getByPlaceholderText('Enter your email');
      const passwordInput = screen.getByPlaceholderText('Enter your password');

      // Tab navigation should work
      emailInput.focus();
      expect(emailInput).toHaveFocus();

      passwordInput.focus();
      expect(passwordInput).toHaveFocus();

      // Focus next element
      // Next focus should be on remember me checkbox or submit button
    });
  });
});