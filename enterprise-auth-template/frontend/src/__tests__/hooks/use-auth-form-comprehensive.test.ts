/**
 * Comprehensive Auth Form Hook Tests
 *
 * Tests the useAuthForm hook with proper TypeScript types,
 * React hooks dependency management, and full coverage.
 */

import { renderHook, act, waitFor } from '@testing-library/react';
import { useForm } from 'react-hook-form';
import {
  useAuthForm,
  UseAuthFormOptions,
  UseAuthFormReturn,
  validationRules,
  getFieldError,
  isFormValid,
} from '@/hooks/use-auth-form';

// Type-safe interfaces for test data
interface LoginFormData {
  email: string;
  password: string;
  rememberMe?: boolean;
}

interface RegisterFormData {
  email: string;
  password: string;
  confirmPassword: string;
  firstName: string;
  lastName: string;
  terms: boolean;
}

interface ChangePasswordFormData {
  currentPassword: string;
  newPassword: string;
  confirmNewPassword: string;
}

// Mock react-hook-form for controlled testing
interface MockFormReturn {
  formState: {
    isValid: boolean;
    errors: Record<string, { message?: string }>;
    isDirty: boolean;
    isSubmitting: boolean;
    isSubmitSuccessful: boolean;
    isValidating: boolean;
    submitCount: number;
    touchedFields: Record<string, boolean>;
    dirtyFields: Record<string, boolean>;
  };
  watch: jest.MockedFunction<() => Record<string, unknown>>;
  setValue: jest.MockedFunction<(name: string, value: unknown) => void>;
  clearErrors: jest.MockedFunction<() => void>;
  reset: jest.MockedFunction<() => void>;
  handleSubmit: jest.MockedFunction<(callback: (data: unknown) => void) => (e?: React.BaseSyntheticEvent) => Promise<void>>;
  control: Record<string, unknown>;
  register: jest.MockedFunction<(name: string) => Record<string, unknown>>;
  unregister: jest.MockedFunction<(name: string) => void>;
  getValues: jest.MockedFunction<() => Record<string, unknown>>;
  trigger: jest.MockedFunction<() => Promise<boolean>>;
  setError: jest.MockedFunction<(name: string, error: { message: string }) => void>;
  setFocus: jest.MockedFunction<(name: string) => void>;
}

const mockForm: MockFormReturn = {
  formState: {
    isValid: true,
    errors: {},
    isDirty: false,
    isSubmitting: false,
    isSubmitSuccessful: false,
    isValidating: false,
    submitCount: 0,
    touchedFields: {},
    dirtyFields: {},
  },
  watch: jest.fn(),
  setValue: jest.fn(),
  clearErrors: jest.fn(),
  reset: jest.fn(),
  handleSubmit: jest.fn(),
  control: {},
  register: jest.fn(() => ({})),
  unregister: jest.fn(),
  getValues: jest.fn(() => ({})),
  trigger: jest.fn(() => Promise.resolve(true)),
  setError: jest.fn(),
  setFocus: jest.fn(),
};

jest.mock('react-hook-form', () => ({
  useForm: jest.fn(() => mockForm),
}));

describe('useAuthForm Hook', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Reset mock form state
    mockForm.formState.isValid = true;
    mockForm.formState.errors = {};
    mockForm.formState.isDirty = false;
    mockForm.formState.isSubmitting = false;
    mockForm.formState.isSubmitSuccessful = false;
    mockForm.formState.isValidating = false;
    mockForm.formState.submitCount = 0;
    mockForm.formState.touchedFields = {};
    mockForm.formState.dirtyFields = {};
    mockForm.watch.mockReturnValue({});
    mockForm.getValues.mockReturnValue({});
    mockForm.trigger.mockResolvedValue(true);
  });

  describe('Hook Initialization', () => {
    it('initializes with correct default values', () => {
      const defaultValues: LoginFormData = {
        email: '',
        password: '',
        rememberMe: false,
      };

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues,
      };

      const { result } = renderHook(() => useAuthForm(options));

      expect(result.current.isSubmitting).toBe(false);
      expect(result.current.error).toBe('');
      expect(typeof result.current.form).toBe('object');
      expect(typeof result.current.setError).toBe('function');
      expect(typeof result.current.clearError).toBe('function');
      expect(typeof result.current.handleSubmit).toBe('function');

      expect(useForm).toHaveBeenCalledWith({
        defaultValues,
        mode: 'onChange',
      });
    });

    it('accepts onSuccess callback', () => {
      const onSuccess = jest.fn();
      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onSuccess,
      };

      const { result } = renderHook(() => useAuthForm(options));

      expect(result.current).toBeDefined();
      expect(onSuccess).not.toHaveBeenCalled();
    });

    it('accepts onError callback', () => {
      const onError = jest.fn();
      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onError,
      };

      const { result } = renderHook(() => useAuthForm(options));

      expect(result.current).toBeDefined();
      expect(onError).not.toHaveBeenCalled();
    });
  });

  describe('Error Management', () => {
    it('sets and clears errors', () => {
      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
      };

      const { result } = renderHook(() => useAuthForm(options));

      act(() => {
        result.current.setError('Test error message');
      });

      expect(result.current.error).toBe('Test error message');

      act(() => {
        result.current.clearError();
      });

      expect(result.current.error).toBe('');
    });

    it('clears error on new error set', () => {
      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
      };

      const { result } = renderHook(() => useAuthForm(options));

      act(() => {
        result.current.setError('First error');
      });

      expect(result.current.error).toBe('First error');

      act(() => {
        result.current.setError('Second error');
      });

      expect(result.current.error).toBe('Second error');
    });
  });

  describe('Form Submission', () => {
    it('handles successful submission', async () => {
      const onSuccess = jest.fn();
      const onSubmit = jest.fn().mockResolvedValue(true);

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onSuccess,
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'password123',
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(onSubmit).toHaveBeenCalledWith(formData);
      expect(onSuccess).toHaveBeenCalledWith(formData);
      expect(result.current.error).toBe('');
      expect(result.current.isSubmitting).toBe(false);
    });

    it('handles failed submission', async () => {
      const onError = jest.fn();
      const onSubmit = jest.fn().mockResolvedValue(false);

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onError,
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'wrongpassword',
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(onSubmit).toHaveBeenCalledWith(formData);
      expect(result.current.error).toBe('Operation failed. Please check your input and try again.');
      expect(onError).toHaveBeenCalledWith('Operation failed. Please check your input and try again.');
      expect(result.current.isSubmitting).toBe(false);
    });

    it('handles submission exceptions', async () => {
      const onError = jest.fn();
      const submitError = new Error('Network error');
      const onSubmit = jest.fn().mockRejectedValue(submitError);

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onError,
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'password123',
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(result.current.error).toBe('Network error');
      expect(onError).toHaveBeenCalledWith('Network error');
      expect(result.current.isSubmitting).toBe(false);
    });

    it('handles non-Error exceptions', async () => {
      const onSubmit = jest.fn().mockRejectedValue('String error');

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'password123',
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(result.current.error).toBe('An unexpected error occurred');
    });

    it('sets isSubmitting during submission', async () => {
      let resolveSubmit: (value: boolean) => void;
      const submitPromise = new Promise<boolean>((resolve) => {
        resolveSubmit = resolve;
      });

      const onSubmit = jest.fn().mockReturnValue(submitPromise);

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'password123',
      };

      act(() => {
        submitHandler(formData);
      });

      expect(result.current.isSubmitting).toBe(true);

      await act(async () => {
        resolveSubmit!(true);
        await submitPromise;
      });

      expect(result.current.isSubmitting).toBe(false);
    });

    it('clears error before submission', async () => {
      const onSubmit = jest.fn().mockResolvedValue(true);

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
      };

      const { result } = renderHook(() => useAuthForm(options));

      // Set an initial error
      act(() => {
        result.current.setError('Previous error');
      });

      expect(result.current.error).toBe('Previous error');

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'password123',
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(result.current.error).toBe('');
    });
  });

  describe('Async onSuccess Handling', () => {
    it('waits for async onSuccess completion', async () => {
      let resolveOnSuccess: () => void;
      const onSuccessPromise = new Promise<void>((resolve) => {
        resolveOnSuccess = resolve;
      });

      const onSuccess = jest.fn().mockReturnValue(onSuccessPromise);
      const onSubmit = jest.fn().mockResolvedValue(true);

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onSuccess,
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: LoginFormData = {
        email: 'test@example.com',
        password: 'password123',
      };

      // Start submission without awaiting to check isSubmitting state
      let submissionPromise: Promise<void>;

      await act(async () => {
        submissionPromise = submitHandler(formData);
        // Allow the hook to update state
        await new Promise(resolve => setTimeout(resolve, 0));
      });

      expect(result.current.isSubmitting).toBe(true);

      await act(async () => {
        resolveOnSuccess!();
        await onSuccessPromise;
        await submissionPromise!;
      });

      expect(result.current.isSubmitting).toBe(false);
      expect(onSuccess).toHaveBeenCalledWith(formData);
    });
  });

  describe('Hook Dependencies', () => {
    it('uses stable callbacks with proper dependencies', () => {
      const onSuccess = jest.fn();
      const onError = jest.fn();

      const options: UseAuthFormOptions<LoginFormData> = {
        defaultValues: { email: '', password: '' },
        onSuccess,
        onError,
      };

      const { result, rerender } = renderHook(() => useAuthForm(options));

      const firstHandleSubmit = result.current.handleSubmit;
      const firstClearError = result.current.clearError;

      // Rerender with same callbacks
      rerender();

      expect(result.current.handleSubmit).toBe(firstHandleSubmit);
      expect(result.current.clearError).toBe(firstClearError);
    });

    it('updates callbacks when dependencies change', () => {
      let onSuccess = jest.fn();
      let onError = jest.fn();

      const { result, rerender } = renderHook(
        ({ onSuccess, onError }) =>
          useAuthForm({
            defaultValues: { email: '', password: '' },
            onSuccess,
            onError,
          }),
        {
          initialProps: { onSuccess, onError },
        }
      );

      const firstHandleSubmit = result.current.handleSubmit;

      // Change the callbacks
      onSuccess = jest.fn();
      onError = jest.fn();

      rerender({ onSuccess, onError });

      expect(result.current.handleSubmit).not.toBe(firstHandleSubmit);
    });
  });

  describe('Complex Form Types', () => {
    it('works with complex registration form', async () => {
      const onSuccess = jest.fn();
      const onSubmit = jest.fn().mockResolvedValue(true);

      const options: UseAuthFormOptions<RegisterFormData> = {
        defaultValues: {
          email: '',
          password: '',
          confirmPassword: '',
          firstName: '',
          lastName: '',
          terms: false,
        },
        onSuccess,
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: RegisterFormData = {
        email: 'test@example.com',
        password: 'SecurePass123!',
        confirmPassword: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe',
        terms: true,
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(onSubmit).toHaveBeenCalledWith(formData);
      expect(onSuccess).toHaveBeenCalledWith(formData);
    });

    it('works with change password form', async () => {
      const onSuccess = jest.fn();
      const onSubmit = jest.fn().mockResolvedValue(true);

      const options: UseAuthFormOptions<ChangePasswordFormData> = {
        defaultValues: {
          currentPassword: '',
          newPassword: '',
          confirmNewPassword: '',
        },
        onSuccess,
      };

      const { result } = renderHook(() => useAuthForm(options));

      const submitHandler = result.current.handleSubmit(onSubmit);
      const formData: ChangePasswordFormData = {
        currentPassword: 'oldpass',
        newPassword: 'newpass123!',
        confirmNewPassword: 'newpass123!',
      };

      await act(async () => {
        await submitHandler(formData);
      });

      expect(onSubmit).toHaveBeenCalledWith(formData);
      expect(onSuccess).toHaveBeenCalledWith(formData);
    });
  });
});

describe('Validation Rules', () => {
  describe('email validation', () => {
    it('has correct email validation rules', () => {
      expect(validationRules.email.required).toBe('Email is required');
      expect(validationRules.email.pattern.value).toBeInstanceOf(RegExp);
      expect(validationRules.email.pattern.message).toBe('Please enter a valid email address');
    });

    it('validates email pattern correctly', () => {
      const { pattern } = validationRules.email;

      expect(pattern.value.test('test@example.com')).toBe(true);
      expect(pattern.value.test('user.name@domain.co')).toBe(true);
      expect(pattern.value.test('invalid-email')).toBe(false);
      expect(pattern.value.test('@example.com')).toBe(false);
      expect(pattern.value.test('user@')).toBe(false);
    });
  });

  describe('password validation', () => {
    it('has correct password validation rules', () => {
      expect(validationRules.password.required).toBe('Password is required');
      expect(validationRules.password.minLength.value).toBe(8);
      expect(validationRules.password.pattern.value).toBeInstanceOf(RegExp);
    });

    it('validates password strength correctly', () => {
      const { pattern } = validationRules.password;

      expect(pattern.value.test('StrongPass123!')).toBe(true);
      expect(pattern.value.test('Complex#Pass1')).toBe(true);
      expect(pattern.value.test('weakpass')).toBe(false);
      expect(pattern.value.test('NOLOWER123!')).toBe(false);
      expect(pattern.value.test('noupper123!')).toBe(false);
      expect(pattern.value.test('NoNumber!')).toBe(false);
      expect(pattern.value.test('NoSpecial123')).toBe(false);
    });
  });

  describe('confirmPassword validation', () => {
    it('creates correct confirm password validation', () => {
      const password = 'testpass123';
      const rules = validationRules.confirmPassword(password);

      expect(rules.required).toBe('Please confirm your password');
      expect(typeof rules.validate).toBe('function');
    });

    it('validates password confirmation correctly', () => {
      const password = 'testpass123';
      const rules = validationRules.confirmPassword(password);

      expect(rules.validate('testpass123')).toBe(true);
      expect(rules.validate('differentpass')).toBe('Passwords do not match');
    });
  });

  describe('name validation', () => {
    it('has correct name validation rules', () => {
      expect(validationRules.name.required).toBe('Name is required');
      expect(validationRules.name.minLength.value).toBe(2);
      expect(validationRules.name.maxLength.value).toBe(100);
      expect(validationRules.name.pattern.value).toBeInstanceOf(RegExp);
    });

    it('validates name pattern correctly', () => {
      const { pattern } = validationRules.name;

      expect(pattern.value.test('John Doe')).toBe(true);
      expect(pattern.value.test('Mary Jane Smith')).toBe(true);
      expect(pattern.value.test('John123')).toBe(false);
      expect(pattern.value.test('John@Doe')).toBe(false);
      expect(pattern.value.test('John_Doe')).toBe(false);
    });
  });

  describe('firstName and lastName validation', () => {
    it('has correct firstName validation rules', () => {
      expect(validationRules.firstName.required).toBe('First name is required');
      expect(validationRules.firstName.minLength.value).toBe(2);
      expect(validationRules.firstName.maxLength.value).toBe(50);
    });

    it('has correct lastName validation rules', () => {
      expect(validationRules.lastName.required).toBe('Last name is required');
      expect(validationRules.lastName.minLength.value).toBe(2);
      expect(validationRules.lastName.maxLength.value).toBe(50);
    });

    it('validates firstName and lastName patterns correctly', () => {
      expect(validationRules.firstName.pattern.value.test('John')).toBe(true);
      expect(validationRules.firstName.pattern.value.test('John123')).toBe(false);

      expect(validationRules.lastName.pattern.value.test('Doe')).toBe(true);
      expect(validationRules.lastName.pattern.value.test('Doe123')).toBe(false);
    });
  });

  describe('terms validation', () => {
    it('has correct terms validation rules', () => {
      expect(validationRules.terms.required).toBe('You must accept the terms and conditions');
    });
  });
});

describe('Form Helper Functions', () => {
  // Mock form for helper function tests
  const createMockForm = (errors: Record<string, { message?: string }> = {}): any => ({
    formState: { errors },
  });

  describe('getFieldError', () => {
    it('extracts field error message', () => {
      const form = createMockForm({
        email: { message: 'Email is required' },
        password: { message: 'Password is too weak' },
      });

      expect(getFieldError(form, 'email')).toBe('Email is required');
      expect(getFieldError(form, 'password')).toBe('Password is too weak');
      expect(getFieldError(form, 'nonexistent' as any)).toBeUndefined();
    });

    it('handles missing error message', () => {
      const form = createMockForm({
        email: {},
      });

      expect(getFieldError(form, 'email')).toBeUndefined();
    });

    it('handles no errors', () => {
      const form = createMockForm();

      expect(getFieldError(form, 'email')).toBeUndefined();
    });
  });

  describe('isFormValid', () => {
    const createMockFormWithState = (
      isValid: boolean,
      errors: Record<string, { message?: string }>,
      watchValues: Record<string, unknown>
    ): any => ({
      formState: { isValid, errors },
      watch: () => watchValues,
    });

    it('returns true for valid form with all required fields', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          email: 'test@example.com',
          password: 'password123',
          terms: true,
        }
      );

      const result = isFormValid(form, ['email', 'password', 'terms']);
      expect(result).toBe(true);
    });

    it('returns false when form is invalid', () => {
      const form = createMockFormWithState(
        false,
        { email: { message: 'Invalid email' } },
        {
          email: 'invalid-email',
          password: 'password123',
        }
      );

      const result = isFormValid(form, ['email', 'password']);
      expect(result).toBe(false);
    });

    it('returns false when required fields are empty', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          email: '',
          password: 'password123',
        }
      );

      const result = isFormValid(form, ['email', 'password']);
      expect(result).toBe(false);
    });

    it('returns false when required boolean field is false', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          email: 'test@example.com',
          password: 'password123',
          terms: false,
        }
      );

      const result = isFormValid(form, ['email', 'password', 'terms']);
      expect(result).toBe(false);
    });

    it('returns true when required boolean field is true', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          email: 'test@example.com',
          password: 'password123',
          terms: true,
        }
      );

      const result = isFormValid(form, ['email', 'password', 'terms']);
      expect(result).toBe(true);
    });

    it('handles null and undefined values', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          email: null,
          password: undefined,
          name: '',
        }
      );

      const result = isFormValid(form, ['email', 'password', 'name']);
      expect(result).toBe(false);
    });

    it('handles zero values correctly', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          count: 0,
          name: 'test',
        }
      );

      const result = isFormValid(form, ['count', 'name']);
      expect(result).toBe(false); // 0 is considered empty for required fields
    });

    it('returns false when there are validation errors', () => {
      const form = createMockFormWithState(
        true,
        { email: { message: 'Invalid email' } },
        {
          email: 'test@example.com',
          password: 'password123',
        }
      );

      const result = isFormValid(form, ['email', 'password']);
      expect(result).toBe(false);
    });

    it('handles empty required fields array', () => {
      const form = createMockFormWithState(
        true,
        {},
        {
          email: 'test@example.com',
        }
      );

      const result = isFormValid(form, []);
      expect(result).toBe(true);
    });
  });
});