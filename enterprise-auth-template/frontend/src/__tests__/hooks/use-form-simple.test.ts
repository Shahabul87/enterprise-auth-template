
import { renderHook, act, waitFor } from '@testing-library/react';
import { useForm, ValidationRule, FormConfig } from '../../hooks/use-form';
import React from 'react';


jest.mock('../../hooks/use-debounce', () => ({
  useDebounce: jest.fn((value) => value),
}));

/**
 * Core test suite for useForm hook
 * Tests essential form management functionality with proper TypeScript typing
 */


// Mock useDebounce hook
interface TestFormData {
  email: string;
  password: string;
  name: string;
  age: number;
  website: string;
}

describe('useForm Hook - Core Functionality', () => {
  const defaultInitialValues: TestFormData = {
    email: '',
    password: '',
    name: '',
    age: 0,
    website: '',
  };
  const validationRules = {
    email: [
      { required: true, message: 'Email is required' },
      { type: 'email' as const, message: 'Invalid email format' },
    ],
    password: [
      { required: true, message: 'Password is required' },
      { minLength: 8, message: 'Password must be at least 8 characters' },
    ],
    name: [
      { required: true, message: 'Name is required' },
      { minLength: 2, message: 'Name must be at least 2 characters' },
    ],
    age: [
      { min: 18, message: 'Must be at least 18 years old' },
      { max: 120, message: 'Must be under 120 years old' },
    ],
    website: [
      { type: 'url' as const, message: 'Invalid website URL' },
    ],
  };
  const validFormData: TestFormData = {
    email: 'test@example.com',
    password: 'validpassword123',
    name: 'John Doe',
    age: 25,
    website: '',
  };
  beforeEach(() => {
    jest.clearAllMocks();
  });
});
describe('Basic Form State', () => {
    it('should initialize with default values and empty state', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      expect(result.current.values).toEqual(defaultInitialValues);
      expect(result.current.errors).toEqual({});
      expect(result.current.touched).toEqual({});
      expect(result.current.isValid).toBe(true);
      expect(result.current.isDirty).toBe(false);
      expect(result.current.isSubmitting).toBe(false);
      expect(result.current.formError).toBe('');
    });
    it('should set individual field values', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setValue('email', 'test@example.com');
      });
      expect(result.current.values.email).toBe('test@example.com');
      expect(result.current.isDirty).toBe(true);
    });
    it('should set multiple values at once', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setValues({
          email: 'test@example.com',
          name: 'John Doe'
        });
      });
      expect(result.current.values.email).toBe('test@example.com');
      expect(result.current.values.name).toBe('John Doe');
      expect(result.current.isDirty).toBe(true);
    });
  });

describe('Error Management', () => {
    it('should set and clear individual field errors', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setError('email', 'Invalid email');
      });
      expect(result.current.errors.email).toBe('Invalid email');
      expect(result.current.isValid).toBe(false);
      act(() => {
        result.current.clearError('email');
      });
      expect(result.current.errors.email).toBeUndefined();
      expect(result.current.isValid).toBe(true);
    });
    it('should clear all errors', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setErrors({
          email: 'Invalid email',
          password: 'Weak password'
        });
      });
      act(() => {
        result.current.clearErrors();
      });
      expect(result.current.errors).toEqual({});
      expect(result.current.isValid).toBe(true);
    });
  });

describe('Touch State Management', () => {
    it('should set field as touched', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setTouched('email', true);
      });
      expect(result.current.touched.email).toBe(true);
    });
    it('should touch field with validation on blur', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules,
        validateOnBlur: true,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        result.current.touchField('email');
      });
      expect(result.current.touched.email).toBe(true);
      await act(async () => { await waitFor(() => {
        expect(result.current.errors.email).toBe('Email is required');
      }); });
    });
  });

describe('Field Validation', () => {
    it('should validate required fields', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('email');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.email).toBe('Email is required');
    });
    it('should validate email format', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, email: 'invalid-email' },
        validationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('email');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.email).toBe('Invalid email format');
    });
    it('should validate string length constraints', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, password: '123' },
        validationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('password');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.password).toBe('Password must be at least 8 characters');
    });
    it('should validate number range constraints', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, age: 15 },
        validationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('age');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.age).toBe('Must be at least 18 years old');
    });
    it('should pass validation with valid values', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: validFormData,
        validationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const emailValid = await act(async () => {
        return await result.current.validateField('email');
      });
      const passwordValid = await act(async () => {
        return await result.current.validateField('password');
      });
      expect(emailValid).toBe(true);
      expect(passwordValid).toBe(true);
      expect(result.current.errors.email).toBeUndefined();
      expect(result.current.errors.password).toBeUndefined();
    });
  });

describe('Form Validation', () => {
    it('should validate entire form', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateForm();
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.email).toBe('Email is required');
      expect(result.current.errors.password).toBe('Password is required');
      expect(result.current.errors.name).toBe('Name is required');
    });
  });

describe('Form Submission', () => {
    it('should handle successful form submission', async () => {
      const onSubmit = jest.fn().mockResolvedValue(true);
      const onSuccess = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: validFormData,
        validationRules,
        onSubmit,
        onSuccess,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        await result.current.handleSubmit();
      });
      expect(onSubmit).toHaveBeenCalledWith(validFormData);
      expect(onSuccess).toHaveBeenCalled();
      expect(result.current.submitCount).toBe(1);
    });
    it('should prevent submission with validation errors', async () => {
      const onSubmit = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules,
        onSubmit,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        await result.current.handleSubmit();
      });
      expect(onSubmit).not.toHaveBeenCalled();
      expect(result.current.formError).toBe('Please fix the errors above');
      expect(result.current.submitCount).toBe(1);
    });
    it('should handle submission failure', async () => {
      const onSubmit = jest.fn().mockResolvedValue(false);
      const onError = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: validFormData,
        validationRules,
        onSubmit,
        onError,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        await result.current.handleSubmit();
      });
      expect(onSubmit).toHaveBeenCalled();
      expect(onError).toHaveBeenCalledWith('Submission failed', expect.any(Object));
    });
  });

describe('Form Reset', () => {
    it('should reset form to initial values', async () => {
      const onReset = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        onReset,
      };
      const { result } = renderHook(() => useForm(config));
      // Modify form state
      act(() => {
        result.current.setValue('email', 'test@example.com');
        result.current.setError('password', 'Weak password');
        result.current.setTouched('name', true);
      });
      // Reset form
      act(() => {
        result.current.reset();
      });
      expect(result.current.values).toEqual(defaultInitialValues);
      expect(result.current.errors).toEqual({});
      expect(result.current.touched).toEqual({});
      expect(result.current.formError).toBe('');
      expect(onReset).toHaveBeenCalledWith(defaultInitialValues);
    });
    it('should reset form to specific values', async () => {
      const newValues: TestFormData = {
        ...defaultInitialValues,
        email: 'new@example.com',
        name: 'New User',
      };
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.resetTo(newValues);
      });
      expect(result.current.values).toEqual(newValues);
      expect(result.current.isDirty).toBe(false);
    });
  });

describe('Field Props and State', () => {
    it('should provide field props for input binding', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, email: 'test@example.com' },
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setError('email', 'Invalid email');
        result.current.setTouched('email', true);
      });
      const fieldProps = result.current.getFieldProps('email');
      expect(fieldProps).toEqual({
        name: 'email',
        value: 'test@example.com',
        onChange: expect.any(Function),
        onBlur: expect.any(Function),
        error: 'Invalid email',
        touched: true
      });
    });
    it('should provide field state information', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, email: 'initial@example.com' },
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setValue('email', 'modified@example.com');
        result.current.setError('email', 'Invalid email');
        result.current.setTouched('email', true);
      });
      const fieldState = result.current.getFieldState('email');
      expect(fieldState).toEqual({
        value: 'modified@example.com',
        error: 'Invalid email',
        touched: true,
        isDirty: true
      });
    });
  });

describe('Custom Validation', () => {
    it('should validate with custom function', async () => {
      const customRule: ValidationRule<string> = {
        custom: async (value) => {
          if (value === 'forbidden') {
            return 'This value is not allowed';
          }
          return true;
        },
        message: 'Custom validation failed',
      };
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, name: 'forbidden' },
        validationRules: {
          name: [customRule],
        },
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('name');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.name).toBe('This value is not allowed');
    });
    it('should validate with pattern regex', async () => {
      interface PhoneForm {
        phone: string;
      }
      const phonePattern = /^\d{3}-\d{3}-\d{4}$/;
      const phoneRule: ValidationRule<string> = {
        pattern: phonePattern,
        message: 'Phone must be in format XXX-XXX-XXXX',
      };
      const config: FormConfig<PhoneForm> = {
        initialValues: { phone: '123-456-789' },
        validationRules: {
          phone: [phoneRule],
        },
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('phone');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.phone).toBe('Phone must be in format XXX-XXX-XXXX');
      act(() => {
        result.current.setValue('phone', '123-456-7890');
      });
      const isValidAfter = await act(async () => {
        return await result.current.validateField('phone');
      });
      expect(isValidAfter).toBe(true);
      expect(result.current.errors.phone).toBeUndefined();
    });
  });

describe('Edge Cases', () => {
    it('should handle empty validation rules', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: {},
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('email');
      });
      expect(isValid).toBe(true);
      expect(result.current.errors.email).toBeUndefined();
    });
    it('should handle non-required empty values', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, website: '' },
        validationRules: {
          website: [
            { type: 'url' as const, message: 'Invalid URL' },
          ],
        },
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('website');
      });
      expect(isValid).toBe(true);
      expect(result.current.errors.website).toBeUndefined();
    });
  });
});