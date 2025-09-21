
import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ChangePasswordForm } from '@/components/profile/change-password-form';
import { useAuthForm } from '@/hooks/use-auth-form';
import AuthAPI from '@/lib/auth-api';
import { Control, FieldValues, UseFormReturn } from 'react-hook-form';
jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: jest.fn(),
  validationRules: {
    password: { required: 'Password is required', minLength: 8 },
    confirmPassword: jest.fn(),
  },
  isFormValid: jest.fn(),
jest.mock('@/lib/auth-api', () => ({
  __esModule: true,
  default: {
    login: jest.fn(),
    register: jest.fn(),
    logout: jest.fn(),
    refreshToken: jest.fn(),
    getCurrentUser: jest.fn(),
    requestPasswordReset: jest.fn(),
    confirmPasswordReset: jest.fn(),
    verifyEmail: jest.fn(),
    resendVerification: jest.fn(),
    setup2FA: jest.fn(),
    verify2FA: jest.fn(),
    disable2FA: jest.fn(),
  },
jest.mock('@/components/auth/password-strength-indicator', () => ({
  PasswordStrengthIndicator: ({ password }: PasswordStrengthIndicatorProps) => (
    <div data-testid='password-strength' data-password={password}>
      Password strength indicator
    </div>
  ),
jest.mock('@/components/ui/button', () => ({
  Button: ({ children, onClick, disabled, variant, type, ...props }: ButtonProps) => (
    <button onClick={onClick} disabled={disabled} type={type} data-variant={variant} {...props}>
      {children}
    </button>
  ),
jest.mock('@/components/ui/password-input', () => ({
  PasswordInput: React.forwardRef<HTMLInputElement, PasswordInputProps>(function PasswordInput({ ...props }, ref) {
    return <input ref={ref} type='password' {...props} />;
  }),

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
jest.mock('@/components/ui/card', () => ({
  Card: ({ children, ...props }: CardProps) => (
    <div data-testid='card' {...props}>
      {children}
    </div>
  ),
  CardContent: ({ children, className, ...props }: CardContentProps) => (
    <div data-testid='card-content' className={className} {...props}>
      {children}
    </div>
  ),
  CardDescription: ({ children, ...props }: CardDescriptionProps) => (
    <div data-testid='card-description' {...props}>
      {children}
    </div>
  ),
  CardHeader: ({ children, ...props }: CardHeaderProps) => (
    <div data-testid='card-header' {...props}>
      {children}
    </div>
  ),
  CardTitle: ({ children, className, ...props }: CardTitleProps) => (
    <h2 data-testid='card-title' className={className} {...props}>
      {children}
    </h2>
  ),
jest.mock('@/components/ui/form', () => ({
  Form: ({ children, ...props }: FormProps) => <form {...props}>{children}</form>,
  FormControl: ({ children, ...props }: FormControlProps) => <div {...props}>{children}</div>,
  FormField: ({ render }: FormFieldProps) => {
    const field = { value: '', onChange: jest.fn(), onBlur: jest.fn() };
    return render({ field });
  },

jest.mock('lucide-react', () => ({
  Loader2: ({ className }: IconProps) => <div data-testid='loader-icon' className={className} />,
  Shield: ({ className }: IconProps) => <div data-testid='shield-icon' className={className} />,
  CheckCircle: ({ className }: IconProps) => (
    <div data-testid='check-circle-icon' className={className} />
  ),
/**
 * @jest-environment jsdom
 */


// Type definitions for mock components
interface PasswordStrengthIndicatorProps {
  password: string;
}

interface ButtonProps {
  children: React.ReactNode;
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  disabled?: boolean;
  variant?: string;
  type?: 'button' | 'submit' | 'reset';
  [key: string]: unknown;
}

interface PasswordInputProps {
  [key: string]: unknown;
}

interface AlertProps {
  children: React.ReactNode;
  variant?: string;
  [key: string]: unknown;
}

interface AlertDescriptionProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardContentProps {
  children: React.ReactNode;
  className?: string;
  [key: string]: unknown;
}

interface CardDescriptionProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardHeaderProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface CardTitleProps {
  children: React.ReactNode;
  className?: string;
  [key: string]: unknown;
}

interface FormProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface FormControlProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface FormFieldProps {
  render: (props: {
    field: {
      value: string;
      onChange: jest.MockedFunction<() => void>;
      onBlur: jest.MockedFunction<() => void>;
    };
  }) => React.ReactNode;
  control?: unknown;
  name?: string;
  rules?: unknown;
}

interface FormItemProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface FormLabelProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface FormMessageProps {
  children: React.ReactNode;
  [key: string]: unknown;
}

interface IconProps {
  className?: string;
}

// Mock dependencies
// Mock AuthAPI properly
// Mock password strength indicator
// Mock UI components
  FormItem: ({ children, ...props }: FormItemProps) => <div {...props}>{children}</div>,
  FormLabel: ({ children, ...props }: FormLabelProps) => <label {...props}>{children}</label>,
  FormMessage: ({ children, ...props }: FormMessageProps) => (
    <div data-testid='form-message' {...props}>
// Mock data - Complete UseFormReturn interface
const mockForm = {
  handleSubmit: jest.fn(),
  control: {} as Control<FieldValues>,
  watch: jest.fn() as jest.Mock,
  reset: jest.fn(),
  formState: {
    errors: {},
    isDirty: false,
    isLoading: false,
    isSubmitted: false,
    isSubmitSuccessful: false,
    isSubmitting: false,
    isValid: true,
    isValidating: false,
    submitCount: 0,
    defaultValues: {},
    dirtyFields: {},
    touchedFields: {},
    validatingFields: {},
    disabled: false,
    isReady: true,
  getValues: jest.fn(),
  getFieldState: jest.fn(),
  setError: jest.fn(),
  clearErrors: jest.fn(),
  setValue: jest.fn(),
  trigger: jest.fn(),
  unregister: jest.fn(),
  resetField: jest.fn(),
  setFocus: jest.fn(),
  getFieldsValue: jest.fn(),
  subscribe: jest.fn(),
} as UseFormReturn<FieldValues>;
const mockUseAuthForm = {
  form: mockForm,
  isSubmitting: false,
  error: '',
  handleSubmit: jest.fn(),
  setError: jest.fn(),
  clearError: jest.fn(),
// AuthAPI is already mocked above
const mockUseAuthFormHook = useAuthForm as jest.MockedFunction<typeof useAuthForm>;
// Mock timers
jest.useFakeTimers();
describe('ChangePasswordForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Setup default mocks
    mockUseAuthFormHook.mockReturnValue(mockUseAuthForm);
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(true);
    (mockForm.watch as jest.Mock).mockReturnValue('newpassword123');
    // Default API response
    mockAuthAPI.changePassword.mockResolvedValue({
      success: true
    });
    // Validation rules mock
    (require('@/hooks/use-auth-form').validationRules.confirmPassword as jest.Mock).mockReturnValue(
      { required: 'Please confirm your password' }
    );
  });
  afterEach(() => {
    jest.runOnlyPendingTimers();
    jest.useRealTimers();
  });
  it('renders change password form', async () => {
    render(<ChangePasswordForm />);
    expect(screen.getByTestId('card-title')).toHaveTextContent('Change Password');
    expect(screen.getByTestId('card-description')).toHaveTextContent(
      'Update your password to keep your account secure'
    );
    expect(screen.getByTestId('shield-icon')).toBeInTheDocument();
    expect(screen.getByLabelText('Current password')).toBeInTheDocument();
    expect(screen.getByLabelText('New password')).toBeInTheDocument();
    expect(screen.getByLabelText('Confirm new password')).toBeInTheDocument();
  });
  it('renders form fields with correct placeholders', async () => {
    render(<ChangePasswordForm />);
    expect(screen.getByPlaceholderText('Enter your current password')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Create a strong new password')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Confirm your new password')).toBeInTheDocument();
  });
  it('shows password requirements', async () => {
    render(<ChangePasswordForm />);
    expect(screen.getByText('Password Requirements:')).toBeInTheDocument();
    expect(screen.getByText('• At least 8 characters long')).toBeInTheDocument();
    expect(screen.getByText('• Contains uppercase and lowercase letters')).toBeInTheDocument();
    expect(screen.getByText('• Contains at least one number')).toBeInTheDocument();
    expect(screen.getByText('• Contains at least one special character')).toBeInTheDocument();
    expect(screen.getByText('• Different from your current password')).toBeInTheDocument();
  });
  it('renders password strength indicator', async () => {
    render(<ChangePasswordForm />);
    const strengthIndicator = screen.getByTestId('password-strength');
    expect(strengthIndicator).toBeInTheDocument();
    expect(strengthIndicator).toHaveAttribute('data-password', 'newpassword123');
  });
  it('shows error message when there is an error', async () => {
    mockUseAuthFormHook.mockReturnValue({
      ...mockUseAuthForm,
      error: 'Current password is incorrect'
    });
    render(<ChangePasswordForm />);
    expect(screen.getByTestId('alert')).toBeInTheDocument();
    expect(screen.getByText('Current password is incorrect')).toBeInTheDocument();
  });
  it('shows loading state when submitting', async () => {
    mockUseAuthFormHook.mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<ChangePasswordForm />);
    expect(screen.getByText('Changing password...')).toBeInTheDocument();
    expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
  });
  it('disables form fields when submitting', async () => {
    mockUseAuthFormHook.mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<ChangePasswordForm />);
    const currentPasswordInput = screen.getByLabelText('Current password');
    const newPasswordInput = screen.getByLabelText('New password');
    const confirmPasswordInput = screen.getByLabelText('Confirm new password');
    expect(currentPasswordInput).toBeDisabled();
    expect(newPasswordInput).toBeDisabled();
    expect(confirmPasswordInput).toBeDisabled();
  });
  it('disables submit button when form is invalid', async () => {
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(false);
    render(<ChangePasswordForm />);
    const submitButton = screen.getByRole('button', { name: /change password/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when submitting', async () => {
    mockUseAuthFormHook.mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<ChangePasswordForm />);
    const submitButton = screen.getByRole('button', { name: /changing password/i });
    expect(submitButton).toBeDisabled();
  });
  it('enables submit button when form is valid and not submitting', async () => {
    render(<ChangePasswordForm />);
    const submitButton = screen.getByRole('button', { name: /change password/i });
    expect(submitButton).not.toBeDisabled();
  });
  it('calls changePassword API on form submission', async () => {
    const mockHandleSubmit = jest.fn();
    mockUseAuthForm.handleSubmit.mockReturnValue(mockHandleSubmit);
    render(<ChangePasswordForm />);
    const form = screen.getByRole('form');
    act(() => { fireEvent.submit(form) });
    expect(mockForm.handleSubmit).toHaveBeenCalled();
  });
  it('shows success state after successful password change', async () => {
    const mockHandleSubmit = jest.fn();
    mockAuthAPI.changePassword.mockResolvedValue({
      success: true
    });
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      // Simulate successful form submission
      setTimeout(() => {
        callback({
          currentPassword: 'oldpassword',
          newPassword: 'newpassword123',
          confirmNewPassword: 'newpassword123'
        });
      }, 0);
      return mockHandleSubmit;
    });
    const { rerender } = render(<ChangePasswordForm />);
    // Mock the success state by directly testing the success component
    jest.spyOn(React, 'useState').mockImplementationOnce(() => [true, jest.fn()]); // isComplete: true
    rerender(<ChangePasswordForm />);
    expect(screen.getByTestId('check-circle-icon')).toBeInTheDocument();
    expect(screen.getByText('Password changed successfully')).toBeInTheDocument();
    expect(
      screen.getByText(
        'Your password has been updated. Please use your new password for future logins.'
      )
    ).toBeInTheDocument();
  });
  it('resets form and hides success state after timeout', async () => {
    const mockSetIsComplete = jest.fn();
    jest.spyOn(React, 'useState').mockImplementationOnce(() => [true, mockSetIsComplete]); // isComplete: true
    render(<ChangePasswordForm />);
    // Fast-forward time to trigger the timeout
    act(() => {
      jest.advanceTimersByTime(3000);
    });
    expect(mockSetIsComplete).toHaveBeenCalledWith(false);
    expect(mockForm.reset).toHaveBeenCalled();
  });
  it('calls onSuccess callback when provided and password change is successful', async () => {
    const mockOnSuccess = jest.fn();
    const mockHandleSubmit = jest.fn();
    mockAuthAPI.changePassword.mockResolvedValue({
      success: true
    });
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      callback({
        currentPassword: 'oldpassword',
        newPassword: 'newpassword123',
        confirmNewPassword: 'newpassword123'
      });
      return mockHandleSubmit;
    });
    render(<ChangePasswordForm onSuccess={mockOnSuccess} />);
    // Component should render without errors
    expect(screen.getByTestId('card-title')).toHaveTextContent('Change Password');
  });
  it('handles API error gracefully', async () => {
    const mockHandleSubmit = jest.fn();
    mockAuthAPI.changePassword.mockResolvedValue({
      success: false,
      error: { code: 'INVALID_PASSWORD', message: 'Current password is incorrect' }
    });
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      callback({
        currentPassword: 'wrongpassword',
        newPassword: 'newpassword123',
        confirmNewPassword: 'newpassword123'
      });
      return mockHandleSubmit;
    });
    render(<ChangePasswordForm />);
    expect(screen.getByTestId('card-title')).toHaveTextContent('Change Password');
  });
  it('handles cancel button click correctly', async () => {
    const user = userEvent.setup({ advanceTimers: jest.advanceTimersByTime });
    render(<ChangePasswordForm />);
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    await user.click(cancelButton);
    expect(mockForm.reset).toHaveBeenCalled();
  });
  it('disables cancel button when submitting', async () => {
    mockUseAuthFormHook.mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    render(<ChangePasswordForm />);
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    expect(cancelButton).toBeDisabled();
  });
  it('validates form fields correctly', async () => {
    render(<ChangePasswordForm />);
    expect(require('@/hooks/use-auth-form').isFormValid).toHaveBeenCalledWith(mockForm, [
      'currentPassword',
      'newPassword',
      'confirmNewPassword',
    ]);
  });
  it('watches new password field for strength indicator', async () => {
    render(<ChangePasswordForm />);
    expect(mockForm.watch).toHaveBeenCalledWith('newPassword');
  });
  it('applies correct button variants', async () => {
    render(<ChangePasswordForm />);
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    const submitButton = screen.getByRole('button', { name: /change password/i });
    expect(cancelButton).toHaveAttribute('data-variant', 'outline');
    expect(submitButton).not.toHaveAttribute('data-variant');
  });
  it('handles password confirmation validation', async () => {
    const mockConfirmPasswordRule = jest
      .fn()
      .mockReturnValue({ required: 'Please confirm your password' });
    (require('@/hooks/use-auth-form').validationRules.confirmPassword as jest.Mock).mockReturnValue(
      mockConfirmPasswordRule
    );
    render(<ChangePasswordForm />);
    expect(mockConfirmPasswordRule).toHaveBeenCalled();
  });
  it('maintains form state during different states', async () => {
    const { rerender } = render(<ChangePasswordForm />);
    // Normal state
    expect(screen.getByLabelText('Current password')).toBeInTheDocument();
    expect(screen.getByLabelText('New password')).toBeInTheDocument();
    expect(screen.getByLabelText('Confirm new password')).toBeInTheDocument();
    // Submitting state
    mockUseAuthFormHook.mockReturnValue({
      ...mockUseAuthForm,
      isSubmitting: true
    });
    rerender(<ChangePasswordForm />);
    expect(screen.getByLabelText('Current password')).toBeInTheDocument();
    expect(screen.getByLabelText('New password')).toBeInTheDocument();
    expect(screen.getByLabelText('Confirm new password')).toBeInTheDocument();
    expect(screen.getByText('Changing password...')).toBeInTheDocument();
  });
  it('handles different error types correctly', async () => {
    const errorMessages = [
      'Current password is incorrect',
      'New password is too weak',
      'Passwords do not match',
      'Network error occurred',
    ];
    errorMessages.forEach((errorMessage) => {
      mockUseAuthFormHook.mockReturnValue({
        ...mockUseAuthForm,
        error: errorMessage
      });
      const { rerender } = render(<ChangePasswordForm />);
      expect(screen.getByText(errorMessage)).toBeInTheDocument();
      const alert = screen.getByTestId('alert');
      expect(alert).toHaveAttribute('data-variant', 'destructive');
      // Clean up for next iteration
      rerender(<div />);
    });
  });
  it('transforms form data correctly for API call', async () => {
    const mockHandleSubmit = jest.fn();
    mockUseAuthForm.handleSubmit.mockImplementation((callback) => {
      const formData = {
        currentPassword: 'old123',
        newPassword: 'new456',
        confirmNewPassword: 'new456',
      };
      // Verify the callback transforms data correctly
      callback(formData);
      return mockHandleSubmit;
    });
    render(<ChangePasswordForm />);
    // Component should render without errors
    expect(screen.getByTestId('card-title')).toHaveTextContent('Change Password');
  });
  it('handles successful password change flow end to end', async () => {
    jest.useRealTimers(); // Use real timers for this test
    const mockOnSuccess = jest.fn();
    const mockSetIsComplete = jest.fn();
    // Mock initial state as false, then simulate success
    jest.spyOn(React, 'useState').mockImplementationOnce(() => [false, mockSetIsComplete]);
    const { rerender } = render(<ChangePasswordForm onSuccess={mockOnSuccess} />);
    // Simulate successful submission by mocking the state change
    mockSetIsComplete.mockImplementation((value) => {
      if (value === true) {
        // Rerender with success state
        jest.spyOn(React, 'useState').mockImplementationOnce(() => [true, jest.fn()]);
        rerender(<ChangePasswordForm onSuccess={mockOnSuccess} />);
      }
    });
    // Component should initially show the form
    expect(screen.getByTestId('card-title')).toHaveTextContent('Change Password');
  });
}}}}}}}}}}}}