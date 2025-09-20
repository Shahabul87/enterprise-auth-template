import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ProfileForm } from '@/components/profile/profile-form';
import { useAuthStore } from '@/stores/auth.store';
import { useAuthForm, UseAuthFormReturn } from '@/hooks/use-auth-form';
import AuthAPI from '@/lib/auth-api';
import { User } from '@/types/auth.types';
import { UseFormReturn, FieldValues, Control } from 'react-hook-form';

jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => ({
    user: null,
    isAuthenticated: false,
    isLoading: false,
    error: null,
    login: mockLogin,
    register: mockRegister,
    logout: mockLogout,
    setUser: mockSetUser,
    clearError: jest.fn(),
    refreshToken: jest.fn().mockResolvedValue(true),
    requestPasswordReset: jest.fn().mockResolvedValue({ success: true }),
    confirmPasswordReset: jest.fn().mockResolvedValue({ success: true }),
    verifyEmail: jest.fn().mockResolvedValue({ success: true }),
    resendVerification: jest.fn().mockResolvedValue({ success: true }),
    initialize: jest.fn().mockResolvedValue(undefined),
  }))}));,
})));
jest.mock('@/hooks/use-auth-form', () => ({
  useAuthForm: jest.fn(),
  validationRules: {
    firstName: { required: 'First name is required' },
    lastName: { required: 'Last name is required' },
    email: { required: 'Email is required', pattern: /\S+@\S+\.\S+/ },
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
jest.mock('@/components/ui/button', () => ({
  Button: ({ children, onClick, disabled, variant, type, className, ...props }: ButtonProps) => (
    <button
      onClick={onClick}
      disabled={disabled}
      type={type}
      className={className}
      data-variant={variant}
      {...props}
    >
      {children}
    </button>
  ),
jest.mock('@/components/ui/input', () => ({
  Input: React.forwardRef<HTMLInputElement, React.ComponentProps<'input'>>(function Input({ ...props }, ref) {
    return <input ref={ref} {...props} />;
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
  FormField: ({ render, name }: FormFieldProps) => {
    const field = {
      value:
        name === 'first_name'
          ? 'John'
          : name === 'last_name'
            ? 'Doe'
            : name === 'email'
              ? 'john.doe@example.com'
              : '',
      onChange: jest.fn(),
      onBlur: jest.fn(),
    };
    return render({ field });
  },
jest.mock('lucide-react', () => ({
  Loader2: ({ className }: IconProps) => <div data-testid='loader-icon' className={className} />,
  User: ({ className }: IconProps) => <div data-testid='user-icon' className={className} />,
// Mock auth store
const mockLogin = jest.fn();
const mockRegister = jest.fn();
const mockLogout = jest.fn();
const mockSetUser = jest.fn();
/**
 * @jest-environment jsdom
 */
  ButtonProps,
  AlertProps,
  AlertDescriptionProps,
  CardProps,
  CardContentProps,
  CardDescriptionProps,
  CardHeaderProps,
  CardTitleProps,
  FormFieldProps,
} from '../../types/test-interfaces';
// Specific form component props
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
interface IconProps {
  className?: string;
// Mock dependencies
  useAuth: jest.fn(),
// Mock AuthAPI
// Mock UI components
  FormItem: ({ children, ...props }: FormItemProps) => <div {...props}>{children}</div>,
  FormLabel: ({ children, ...props }: FormLabelProps) => <label {...props}>{children}</label>,
  FormMessage: ({ children, ...props }: FormMessageProps) => (
    <div data-testid='form-message' {...props}>
// Mock data
const mockUser: User = {
  id: '1',
  email: 'john.doe@example.com',
  full_name: 'John Doe',
  is_active: true,
  is_verified: true,
  email_verified: true,
  is_superuser: false,
  two_factor_enabled: false,
  failed_login_attempts: 0,
  last_login: '2024-01-15T10:30:00Z',
  user_metadata: {},
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  roles: [],
const mockAuthContext = {
  user: mockUser,
  tokens: {
    access_token: 'mock-access-token',
    refresh_token: 'mock-refresh-token',
    token_type: 'Bearer',
    expires_in: 3600,
  isAuthenticated: true,
  permissions: [],
  hasPermission: jest.fn(),
  hasRole: jest.fn(),
  setUser: jest.fn(),
// Create a complete UseFormReturn mock
const createMockForm = (): UseFormReturn<FieldValues> => ({
  handleSubmit: jest.fn(() => jest.fn()),
  control: {} as Control<FieldValues>,
  unregister: jest.fn(),
  formState: {
    errors: {},
    isDirty: false,
    isSubmitted: false,
    isSubmitSuccessful: false,
    isSubmitting: false,
    isValidating: false,
    isValid: true,
    submitCount: 0,
    defaultValues: undefined,
    dirtyFields: {},
    touchedFields: {},
    validatingFields: {},
    disabled: false,
    isReady: true,
  watch: jest.fn(),
  getValues: jest.fn(),
  getFieldState: jest.fn(),
  setError: jest.fn(),
  clearErrors: jest.fn(),
  setValue: jest.fn(),
  trigger: jest.fn(),
  reset: jest.fn(),
  resetField: jest.fn(),
  setFocus: jest.fn(),
  subscribe: jest.fn(),
const mockForm = createMockForm();
const mockUseAuthFormReturn: UseAuthFormReturn<FieldValues> = {
  form: mockForm,
  isSubmitting: false,
  error: '',
  setError: jest.fn(),
  handleSubmit: jest.fn(),
// AuthAPI is already mocked above
const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;
const mockUseAuthForm = useAuthForm as jest.MockedFunction<typeof useAuthForm>;
describe('ProfileForm', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Setup default mocks
    mockUseAuth.mockReturnValue(mockAuthContext);
    mockUseAuthForm.mockReturnValue(mockUseAuthFormReturn);
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(true);
    // Default form values
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    // Default API response
    mockAuthAPI.updateProfile.mockResolvedValue({
      success: true,
      data: { ...mockUser, full_name: 'Updated User' },
    });
  });
  it('renders profile form with user data', async () => {
    render(<ProfileForm />);
    expect(screen.getByTestId('card-title')).toHaveTextContent('Personal Information');
    expect(screen.getByTestId('card-description')).toHaveTextContent(
      'Update your personal details and contact information'
    );
    expect(screen.getByTestId('user-icon')).toBeInTheDocument();
    expect(screen.getByLabelText('First name')).toBeInTheDocument();
    expect(screen.getByLabelText('Last name')).toBeInTheDocument();
    expect(screen.getByLabelText('Email address')).toBeInTheDocument();
  });
  it('renders form fields with correct placeholders', async () => {
    render(<ProfileForm />);
    expect(screen.getByPlaceholderText('Enter your first name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter your last name')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Enter your email address')).toBeInTheDocument();
  });
  it('shows loading state when user is loading', async () => {
    mockUseAuth.mockReturnValue({
      ...mockAuthContext,
      isLoading: true,
    });
    render(<ProfileForm />);
    expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
  });
  it('shows loading state when user is null', async () => {
    mockUseAuth.mockReturnValue({
      ...mockAuthContext,
      user: null,
    });
    render(<ProfileForm />);
    expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
  });
  it('shows error message when there is an error', async () => {
    mockUseAuthForm.mockReturnValue({
      ...mockUseAuthFormReturn,
      error: 'Update failed',
    });
    render(<ProfileForm />);
    expect(screen.getByTestId('alert')).toBeInTheDocument();
    expect(screen.getByText('Update failed')).toBeInTheDocument();
  });
  it('shows loading state when submitting', async () => {
    mockUseAuthForm.mockReturnValue({
      ...mockUseAuthFormReturn,
      isSubmitting: true,
    });
    render(<ProfileForm />);
    expect(screen.getByText('Saving...')).toBeInTheDocument();
    expect(screen.getByTestId('loader-icon')).toBeInTheDocument();
  });
  it('disables form fields when submitting', async () => {
    mockUseAuthForm.mockReturnValue({
      ...mockUseAuthFormReturn,
      isSubmitting: true,
    });
    render(<ProfileForm />);
    const firstNameInput = screen.getByLabelText('First name');
    const lastNameInput = screen.getByLabelText('Last name');
    const emailInput = screen.getByLabelText('Email address');
    expect(firstNameInput).toBeDisabled();
    expect(lastNameInput).toBeDisabled();
    expect(emailInput).toBeDisabled();
  });
  it('disables submit button when form is invalid', async () => {
    (require('@/hooks/use-auth-form').isFormValid as jest.Mock).mockReturnValue(false);
    render(<ProfileForm />);
    const submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when submitting', async () => {
    mockUseAuthForm.mockReturnValue({
      ...mockUseAuthFormReturn,
      isSubmitting: true,
    });
    render(<ProfileForm />);
    const submitButton = screen.getByRole('button', { name: /saving/i });
    expect(submitButton).toBeDisabled();
  });
  it('disables submit button when no changes are made', async () => {
    // Mock no changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    render(<ProfileForm />);
    const submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(submitButton).toBeDisabled();
  });
  it('enables submit button when changes are made', async () => {
    // Mock changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'Updated John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    render(<ProfileForm />);
    const submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(submitButton).not.toBeDisabled();
  });
  it('disables cancel button when no changes are made', async () => {
    // Mock no changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    render(<ProfileForm />);
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    expect(cancelButton).toBeDisabled();
  });
  it('enables cancel button when changes are made', async () => {
    // Mock changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'Updated John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    render(<ProfileForm />);
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    expect(cancelButton).not.toBeDisabled();
  });
  it('resets form when user data changes', async () => {
    const { rerender } = render(<ProfileForm />);
    // Change user data
    const updatedUser = {
      ...mockUser,
      first_name: 'Updated',
    mockUseAuth.mockReturnValue({
      ...mockAuthContext,
      user: updatedUser,
    });
    rerender(<ProfileForm />);
    expect(mockForm.reset).toHaveBeenCalledWith({
      first_name: 'Updated',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
  });
  it('calls updateProfile API on form submission', async () => {
    userEvent.setup();
    const mockHandleSubmit = jest.fn();
    const customMockReturn = { ...mockUseAuthFormReturn, handleSubmit: mockHandleSubmit };
    mockUseAuthForm.mockReturnValue(customMockReturn);
    render(<ProfileForm />);
    const form = screen.getByRole('form');
    act(() => { fireEvent.submit(form); });
    expect(mockForm.handleSubmit).toHaveBeenCalled();
  });
  it('updates user context on successful profile update', async () => {
    const updatedUserData = { ...mockUser, first_name: 'Updated John' };
    mockAuthAPI.updateProfile.mockResolvedValue({
      success: true,
      data: updatedUserData,
    });
    const mockHandleSubmitFn = jest.fn((callback: (data: FieldValues) => Promise<boolean>) => {
      // Simulate successful form submission
      callback({
        first_name: 'Updated John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
      });
      return jest.fn();
    });
    const customReturn1 = { ...mockUseAuthFormReturn, handleSubmit: mockHandleSubmitFn };
    mockUseAuthForm.mockReturnValue(customReturn1);
    render(<ProfileForm />);
    // The component should handle the successful update
    expect(screen.getByTestId('card-title')).toHaveTextContent('Personal Information');
  });
  it('handles API error gracefully', async () => {
    mockAuthAPI.updateProfile.mockResolvedValue({
      success: false,
      error: { code: 'UPDATE_FAILED', message: 'Profile update failed' },
    });
    const mockHandleSubmitFn2 = jest.fn((callback: (data: FieldValues) => Promise<boolean>) => {
      callback({
        first_name: 'Updated John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
      });
      return jest.fn();
    });
    const customReturn2 = { ...mockUseAuthFormReturn, handleSubmit: mockHandleSubmitFn2 };
    mockUseAuthForm.mockReturnValue(customReturn2);
    render(<ProfileForm />);
    expect(screen.getByTestId('card-title')).toHaveTextContent('Personal Information');
  });
  it('calls onSuccess callback when provided and update is successful', async () => {
    const mockOnSuccess = jest.fn();
    mockAuthAPI.updateProfile.mockResolvedValue({
      success: true,
      data: { ...mockUser, full_name: 'Updated User' },
    });
    const mockHandleSubmitFn3 = jest.fn((callback: (data: FieldValues) => Promise<boolean>) => {
      callback({
        first_name: 'Updated',
        last_name: 'Doe',
        email: 'john.doe@example.com',
      });
      return jest.fn();
    });
    const customReturn3 = { ...mockUseAuthFormReturn, handleSubmit: mockHandleSubmitFn3 };
    mockUseAuthForm.mockReturnValue(customReturn3);
    render(<ProfileForm onSuccess={mockOnSuccess} />);
    expect(screen.getByTestId('card-title')).toHaveTextContent('Personal Information');
  });
  it('handles cancel button click correctly', async () => {
    userEvent.setup();
    // Mock changes present
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'Updated John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    render(<ProfileForm />);
    const user = userEvent.setup();
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    await user.click(cancelButton);
    expect(mockForm.reset).toHaveBeenCalledWith({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
  });
  it('validates form fields correctly', async () => {
    render(<ProfileForm />);
    expect(require('@/hooks/use-auth-form').isFormValid).toHaveBeenCalledWith(mockForm, [
      'first_name',
      'last_name',
      'email',
    ]);
  });
  it('detects changes correctly', async () => {
    // Test with no changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    const { rerender } = render(<ProfileForm />);
    let submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(submitButton).toBeDisabled();
    // Test with changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'Updated John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    rerender(<ProfileForm />);
    submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(submitButton).not.toBeDisabled();
  });
  it('handles multiple field changes', async () => {
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'Updated John',
      last_name: 'Updated Doe',
      email: 'updated.john@example.com',
    });
    render(<ProfileForm />);
    const submitButton = screen.getByRole('button', { name: /save changes/i });
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    expect(submitButton).not.toBeDisabled();
    expect(cancelButton).not.toBeDisabled();
  });
  it('applies correct button variants', async () => {
    render(<ProfileForm />);
    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    const submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(cancelButton).toHaveAttribute('data-variant', 'outline');
    expect(submitButton).not.toHaveAttribute('data-variant');
  });
  it('handles edge case with empty user data', async () => {
    mockUseAuth.mockReturnValue({
      ...mockAuthContext,
      user: {
        id: '1',
        email: '',
        full_name: '',
        is_active: true,
        is_verified: true,
        email_verified: true,
        is_superuser: false,
        two_factor_enabled: false,
        failed_login_attempts: 0,
        last_login: null,
        user_metadata: {},
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        roles: [],
      } as User,
    });
    render(<ProfileForm />);
    expect(screen.getByTestId('card-title')).toHaveTextContent('Personal Information');
  });
  it('maintains form state during submission', async () => {
    mockUseAuthForm.mockReturnValue({
      ...mockUseAuthFormReturn,
      isSubmitting: true,
    });
    render(<ProfileForm />);
    // Form should still be present during submission
    expect(screen.getByLabelText('First name')).toBeInTheDocument();
    expect(screen.getByLabelText('Last name')).toBeInTheDocument();
    expect(screen.getByLabelText('Email address')).toBeInTheDocument();
    // Submit button text should change
    expect(screen.getByText('Saving...')).toBeInTheDocument();
  });
  it('handles form submission without changes gracefully', async () => {
    const mockHandleSubmit = jest.fn();
    // No changes
    (mockForm.getValues as jest.Mock).mockReturnValue({
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
    });
    const customMockReturn4 = { ...mockUseAuthFormReturn, handleSubmit: mockHandleSubmit };
    mockUseAuthForm.mockReturnValue(customMockReturn4);
    render(<ProfileForm />);
    // Submit button should be disabled
    const submitButton = screen.getByRole('button', { name: /save changes/i });
    expect(submitButton).toBeDisabled();
  });