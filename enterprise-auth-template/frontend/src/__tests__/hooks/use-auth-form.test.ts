/**
 * @jest-environment jsdom
 */
import { renderHook, act } from '@testing-library/react';
import { useAuthForm, validationRules, isFormValid } from '@/hooks/use-auth-form';
import { useForm, UseFormReturn, FieldValues } from 'react-hook-form';

// Mock react-hook-form
jest.mock('react-hook-form', () => ({
  useForm: jest.fn(),
  Controller: jest.fn(),
}));

const mockUseForm = useForm as jest.MockedFunction<typeof useForm>;

describe('useAuthForm', () => {
  const mockForm = {
    control: {} as unknown,
    handleSubmit: jest.fn(),
    watch: jest.fn(),
    reset: jest.fn(),
    setError: jest.fn(),
    clearErrors: jest.fn(),
    getValues: jest.fn(),
    setValue: jest.fn(),
    getFieldState: jest.fn(),
    trigger: jest.fn(),
    resetField: jest.fn(),
    unregister: jest.fn(),
    setFocus: jest.fn(),
    register: jest.fn(),
    subscribe: jest.fn(),
    formState: { 
      errors: {},
      isValid: false,
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
  } as UseFormReturn<FieldValues>;

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseForm.mockReturnValue(mockForm);
  });

  it('should initialize with default values', () => {
    const defaultValues = { email: '', password: '' };
    const onSuccess = jest.fn();

    const { result } = renderHook(() =>
      useAuthForm({ defaultValues, onSuccess })
    );

    expect(result.current.form).toBeDefined();
    expect(result.current.isSubmitting).toBe(false);
    expect(result.current.error).toBeNull();
    expect(mockUseForm).toHaveBeenCalledWith({
      defaultValues,
      mode: 'onBlur',
    });
  });

  it('should handle form submission success', async () => {
    const onSuccess = jest.fn();
    const mockCallback = jest.fn().mockResolvedValue(true);

    (mockForm.handleSubmit as jest.Mock).mockImplementation((callback: (data: Record<string, unknown>) => Promise<boolean>) => {
      return async (data: Record<string, unknown>) => {
        const result = await callback(data);
        if (result) {
          onSuccess();
        }
      };
    });

    const { result } = renderHook(() =>
      useAuthForm({ defaultValues: { email: '', password: '' }, onSuccess })
    );

    const submitHandler = result.current.handleSubmit(mockCallback);

    await act(async () => {
      await submitHandler({ email: 'test@example.com', password: 'password123' });
    });

    expect(onSuccess).toHaveBeenCalled();
  });

  it('should handle form submission failure', async () => {
    const onSuccess = jest.fn();
    const mockCallback = jest.fn().mockResolvedValue(false);

    (mockForm.handleSubmit as jest.Mock).mockImplementation((callback: (data: Record<string, unknown>) => Promise<boolean>) => {
      return async (data: Record<string, unknown>) => {
        const result = await callback(data);
        if (result) {
          onSuccess();
        }
      };
    });

    const { result } = renderHook(() =>
      useAuthForm({ defaultValues: { email: '', password: '' }, onSuccess })
    );

    const submitHandler = result.current.handleSubmit(mockCallback);

    await act(async () => {
      await submitHandler({ email: 'test@example.com', password: 'wrong' });
    });

    expect(onSuccess).not.toHaveBeenCalled();
  });

  it('should handle form submission with exception', async () => {
    const onSuccess = jest.fn();
    const mockCallback = jest.fn().mockRejectedValue(new Error('Network error'));

    (mockForm.handleSubmit as jest.Mock).mockImplementation((callback: (data: Record<string, unknown>) => Promise<boolean>) => {
      return async (data: Record<string, unknown>) => {
        try {
          const result = await callback(data);
          if (result) {
            onSuccess();
          }
        } catch {
          // Handle error in the hook
          // Form submission error handled in test
        }
      };
    });

    const { result } = renderHook(() =>
      useAuthForm({ defaultValues: { email: '', password: '' }, onSuccess })
    );

    const submitHandler = result.current.handleSubmit(mockCallback);

    await act(async () => {
      await submitHandler({ email: 'test@example.com', password: 'password123' });
    });

    expect(onSuccess).not.toHaveBeenCalled();
  });

  it('should set and clear errors', () => {
    const { result } = renderHook(() =>
      useAuthForm({ defaultValues: { email: '', password: '' } })
    );

    act(() => {
      result.current.setError('Test error message');
    });

    expect(result.current.error).toBe('Test error message');

    act(() => {
      result.current.setError('');
    });

    expect(result.current.error).toBeNull();
  });

  it('should track submitting state', async () => {
    const onSuccess = jest.fn();
    const mockCallback = jest.fn().mockImplementation(() => {
      return new Promise((resolve) => {
        setTimeout(() => resolve(true), 100);
      });
    });

    (mockForm.handleSubmit as jest.Mock).mockImplementation((callback: (data: Record<string, unknown>) => Promise<boolean>) => {
      return async (data: Record<string, unknown>) => {
        const result = await callback(data);
        if (result) {
          onSuccess();
        }
      };
    });

    const { result } = renderHook(() =>
      useAuthForm({ defaultValues: { email: '', password: '' }, onSuccess })
    );

    const submitHandler = result.current.handleSubmit(mockCallback);

    // Start submission
    const submissionPromise = act(async () => {
      await submitHandler({ email: 'test@example.com', password: 'password123' });
    });

    // Should be submitting
    expect(result.current.isSubmitting).toBe(true);

    // Wait for completion
    await submissionPromise;

    // Should not be submitting
    expect(result.current.isSubmitting).toBe(false);
  });
});

describe('validationRules', () => {
  it('should have email validation rules', () => {
    expect(validationRules.email).toEqual({
      required: 'Email is required',
      pattern: {
        value: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
        message: 'Please enter a valid email address',
      },
    });
  });

  it('should have password validation rules', () => {
    expect(validationRules.password).toEqual({
      required: 'Password is required',
      minLength: {
        value: 8,
        message: 'Password must be at least 8 characters long',
      },
      pattern: {
        value: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]+$/,
        message: 'Password must contain uppercase, lowercase, number, and special character',
      },
    });
  });

  it('should have firstName validation rules', () => {
    expect(validationRules.firstName).toEqual({
      required: 'First name is required',
      minLength: {
        value: 2,
        message: 'First name must be at least 2 characters',
      },
      maxLength: {
        value: 50,
        message: 'First name must not exceed 50 characters',
      },
      pattern: {
        value: /^[a-zA-Z\s]+$/,
        message: 'First name can only contain letters and spaces',
      },
    });
  });

  it('should have confirmPassword validation function', () => {
    const confirmPasswordRule = validationRules.confirmPassword('password123');
    
    expect(confirmPasswordRule).toEqual({
      required: 'Please confirm your password',
      validate: expect.any(Function),
    });

    // Test the validate function
    const validateFn = confirmPasswordRule.validate as Function;
    expect(validateFn('password123')).toBe(true);
    expect(validateFn('different')).toBe('Passwords do not match');
  });
});

describe('isFormValid', () => {
  it('should return true when all required fields are valid', () => {
    const mockForm = {
      watch: jest.fn((fields) => {
        const values: Record<string, unknown> = {
          email: 'test@example.com',
          password: 'ValidPass123!',
          name: 'Test User',
        };
        if (Array.isArray(fields)) {
          return fields.map(field => values[field]);
        }
        return values;
      }),
      formState: {
        errors: {},
        isValid: true,
      },
    } as unknown as UseFormReturn<FieldValues>;

    const result = isFormValid(mockForm, ['email', 'password', 'name']);
    expect(result).toBe(true);
  });

  it('should return false when required fields are empty', () => {
    const mockForm = {
      watch: jest.fn((fields) => {
        const values: Record<string, unknown> = {
          email: '',
          password: 'ValidPass123!',
          name: 'Test User',
        };
        if (Array.isArray(fields)) {
          return fields.map(field => values[field]);
        }
        return values;
      }),
      formState: {
        errors: {},
        isValid: false,
      },
    } as unknown as UseFormReturn<FieldValues>;

    const result = isFormValid(mockForm, ['email', 'password', 'name']);
    expect(result).toBe(false);
  });

  it('should return false when form has validation errors', () => {
    const mockForm = {
      watch: jest.fn((fields) => {
        const values: Record<string, unknown> = {
          email: 'test@example.com',
          password: 'ValidPass123!',
          name: 'Test User',
        };
        if (Array.isArray(fields)) {
          return fields.map(field => values[field]);
        }
        return values;
      }),
      formState: {
        errors: {
          email: { message: 'Invalid email format' },
        },
        isValid: false,
      },
    } as unknown as UseFormReturn<FieldValues>;

    const result = isFormValid(mockForm, ['email', 'password', 'name']);
    expect(result).toBe(false);
  });

  it('should handle boolean fields correctly', () => {
    const mockForm = {
      watch: jest.fn((fields) => {
        const values: Record<string, unknown> = {
          email: 'test@example.com',
          password: 'ValidPass123!',
          acceptTerms: false,
        };
        if (Array.isArray(fields)) {
          return fields.map(field => values[field]);
        }
        return values;
      }),
      formState: {
        errors: {},
        isValid: true,
      },
    } as unknown as UseFormReturn<FieldValues>;

    // Boolean fields should be valid even when false for optional fields
    const result = isFormValid(mockForm, ['email', 'password']);
    expect(result).toBe(true);
  });

  it('should handle undefined/null values', () => {
    const mockForm = {
      watch: jest.fn((fields) => {
        const values: Record<string, unknown> = {
          email: null,
          password: undefined,
          name: 'Test User',
        };
        if (Array.isArray(fields)) {
          return fields.map(field => values[field]);
        }
        return values;
      }),
      formState: {
        errors: {},
        isValid: false,
      },
    } as unknown as UseFormReturn<FieldValues>;

    const result = isFormValid(mockForm, ['email', 'password', 'name']);
    expect(result).toBe(false);
  });

  it('should handle single field validation', () => {
    const mockForm = {
      watch: jest.fn(() => 'test@example.com'),
      formState: {
        errors: {},
        isValid: true,
      },
    } as unknown as UseFormReturn<FieldValues>;

    const result = isFormValid(mockForm, ['email']);
    expect(result).toBe(true);
  });

  it('should return true for empty field list', () => {
    const mockForm = {
      watch: jest.fn(() => ({})),
      formState: {
        errors: {},
        isValid: true,
      },
    } as unknown as UseFormReturn<FieldValues>;

    const result = isFormValid(mockForm, []);
    expect(result).toBe(true);
  });
});