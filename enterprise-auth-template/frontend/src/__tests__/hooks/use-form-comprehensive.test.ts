
import { renderHook, act, waitFor } from '@testing-library/react';
import { useForm, ValidationRule, FormConfig } from '../../hooks/use-form';
import React from 'react';

/**
 * @jest-environment jsdom
 */

jest.mock('../../hooks/use-debounce', () => ({
  useDebounce: jest.fn((value) => value),
}));

/**
 * Comprehensive test suite for useForm hook
 * Tests all form management functionality including validation, auto-save, and state management
 */


// Mock useDebounce hook
interface TestFormData {
  email: string;
  password: string;
  confirmPassword: string;
  name: string;
  age: number;
  website: string;
  bio: string;
}

describe('useForm Hook', () => {
  const defaultInitialValues: TestFormData = {
    email: '',
    password: '',
    confirmPassword: '',
    name: '',
    age: 0,
    website: '',
    bio: '',
  };
  const defaultValidationRules = {
    email: [
      { required: true, message: 'Email is required' },
      { type: 'email' as const, message: 'Invalid email format' },
    ],
    password: [
      { required: true, message: 'Password is required' },
      { minLength: 8, message: 'Password must be at least 8 characters' },
    ],
    confirmPassword: [
      { required: true, message: 'Confirm password is required' },
    ],
    name: [
      { required: true, message: 'Name is required' },
      { minLength: 2, message: 'Name must be at least 2 characters' },
      { maxLength: 50, message: 'Name must not exceed 50 characters' },
    ],
    age: [
      { required: true, message: 'Age is required' },
      { min: 18, message: 'Must be at least 18 years old' },
      { max: 120, message: 'Must be under 120 years old' },
    ],
    website: [
      { type: 'url' as const, message: 'Invalid website URL' },
    ],
    bio: [
      { maxLength: 500, message: 'Bio must not exceed 500 characters' },
    ],
  };
  const validFormData: TestFormData = {
    email: 'test@example.com',
    password: 'validpassword123',
    confirmPassword: 'validpassword123',
    name: 'John Doe',
    age: 25,
    website: '',
    bio: '',
  };
  beforeEach(() => {
    jest.clearAllMocks();
  });

describe('Basic Form Initialization', () => {
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
      expect(result.current.isValidating).toBe(false);
      expect(result.current.isAutoSaving).toBe(false);
      expect(result.current.formError).toBe('');
      expect(result.current.submitCount).toBe(0);
    });
    it('should initialize with custom configuration', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
        validateOnChange: false,
        validateOnBlur: false,
        validationDelay: 500,
        enableAutoSave: true,
        autoSaveDelay: 1000,
      };
      const { result } = renderHook(() => useForm(config));
      expect(result.current.values).toEqual(defaultInitialValues);
      expect(result.current.isValid).toBe(true);
    });
  });

describe('Value Management', () => {
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
      expect(result.current.formError).toBe('');
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
    it('should calculate isDirty correctly', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, email: 'initial@example.com' },
      };
      const { result } = renderHook(() => useForm(config));
      expect(result.current.isDirty).toBe(false);
      act(() => {
        result.current.setValue('email', 'new@example.com');
      });
      expect(result.current.isDirty).toBe(true);
      act(() => {
        result.current.setValue('email', 'initial@example.com');
      });
      expect(result.current.isDirty).toBe(false);
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
    it('should set multiple errors at once', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      const errors = {
        email: 'Invalid email',
        password: 'Weak password',
      };
      act(() => {
        result.current.setErrors(errors);
      });
      expect(result.current.errors).toEqual(errors);
      expect(result.current.isValid).toBe(false);
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
        result.current.setError('formError', 'General error');
      });
      act(() => {
        result.current.clearErrors();
      });
      expect(result.current.errors).toEqual({});
      expect(result.current.formError).toBe('');
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
      act(() => {
        result.current.setTouched('email', false);
      });
      expect(result.current.touched.email).toBe(false);
    });
    it('should touch field and trigger validation on blur', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
        validateOnBlur: true,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        result.current.touchField('email');
      });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.touched.email).toBe(true);
        expect(result.current.errors.email).toBe('Email is required');
      }); });
    });
    it('should not trigger validation on blur when disabled', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
        validateOnBlur: false,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.touchField('email');
      });
      expect(result.current.touched.email).toBe(true);
      expect(result.current.errors.email).toBeUndefined();
    });
  });

describe('Field Validation', () => {
    it('should validate required fields', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
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
        validationRules: defaultValidationRules,
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
        validationRules: defaultValidationRules,
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
        validationRules: defaultValidationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('age');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.age).toBe('Must be at least 18 years old');
    });
    it('should validate URL format', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: { ...defaultInitialValues, website: 'invalid-url' },
        validationRules: defaultValidationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('website');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.website).toBe('Invalid website URL');
    });
    it('should validate with custom validation function', async () => {
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
    it('should pass validation with valid values', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: {
          ...validFormData,
          website: 'https://example.com',
        },
        validationRules: defaultValidationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const emailValid = await act(async () => {
        return await result.current.validateField('email');
      });
      const passwordValid = await act(async () => {
        return await result.current.validateField('password');
      });
      const nameValid = await act(async () => {
        return await result.current.validateField('name');
      });
      expect(emailValid).toBe(true);
      expect(passwordValid).toBe(true);
      expect(nameValid).toBe(true);
      expect(result.current.errors.email).toBeUndefined();
      expect(result.current.errors.password).toBeUndefined();
      expect(result.current.errors.name).toBeUndefined();
    });
  });

describe('Form Validation', () => {
    it('should validate entire form', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
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
    it('should validate form with mixed valid and invalid fields', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: {
          ...defaultInitialValues,
          email: 'test@example.com',
          password: '123', // Invalid
          name: 'John Doe',
        },
        validationRules: defaultValidationRules,
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateForm();
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.email).toBeUndefined();
      expect(result.current.errors.password).toBe('Password must be at least 8 characters');
      expect(result.current.errors.name).toBeUndefined();
    });
  });

describe('Form Submission', () => {
    it('should handle successful form submission', async () => {
      const onSubmit = jest.fn().mockResolvedValue(true);
      const onSuccess = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: validFormData,
        validationRules: defaultValidationRules,
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
      const onError = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
        onSubmit,
        onError,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        await result.current.handleSubmit();
      });
      expect(onSubmit).not.toHaveBeenCalled();
      expect(result.current.formError).toBe('Please fix the errors above');
      expect(result.current.submitCount).toBe(1);
      // All fields should be marked as touched
      expect(result.current.touched.email).toBe(true);
      expect(result.current.touched.password).toBe(true);
      expect(result.current.touched.name).toBe(true);
    });
    it('should handle submission failure', async () => {
      const onSubmit = jest.fn().mockResolvedValue(false);
      const onError = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: validFormData,
        validationRules: defaultValidationRules,
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
    it('should handle submission exception', async () => {
      const error = new Error('Network error');
      const onSubmit = jest.fn().mockRejectedValue(error);
      const onError = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: validFormData,
        validationRules: defaultValidationRules,
        onSubmit,
        onError,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        await result.current.handleSubmit();
      });
      expect(result.current.formError).toBe('Network error');
      expect(onError).toHaveBeenCalledWith('Network error', expect.any(Object));
    });
    it('should transform values before submission', async () => {
      const onSubmit = jest.fn().mockResolvedValue(true);
      const transformOnSubmit = jest.fn((values: TestFormData) => ({
        ...values,
        email: values.email.toLowerCase(),
}));
      const config: FormConfig<TestFormData> = {
        initialValues: {
          ...validFormData,
          email: 'TEST@EXAMPLE.COM',
        },
        validationRules: defaultValidationRules,
        onSubmit,
        transformOnSubmit,
      };
      const { result } = renderHook(() => useForm(config));
      await act(async () => {
        await result.current.handleSubmit();
      });
      expect(transformOnSubmit).toHaveBeenCalled();
      expect(onSubmit).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@example.com',
        })
      );
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
      expect(result.current.submitCount).toBe(0);
      expect(onReset).toHaveBeenCalledWith(defaultInitialValues);
    });
    it('should reset form to specific values', async () => {
      const newValues: TestFormData = {
        ...defaultInitialValues,
        email: 'new@example.com',
        name: 'New User',
      };
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
      });
      // Reset to new values
      act(() => {
        result.current.resetTo(newValues);
      });
      expect(result.current.values).toEqual(newValues);
      expect(result.current.errors).toEqual({});
      expect(result.current.touched).toEqual({});
      expect(result.current.isDirty).toBe(false);
      expect(onReset).toHaveBeenCalledWith(newValues);
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
      // Test onChange and onBlur
      act(() => {
        fieldProps.onChange('new@example.com');
      });
      expect(result.current.values.email).toBe('new@example.com');
      act(() => {
        fieldProps.onBlur();
      });
      expect(result.current.touched.email).toBe(true);
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
    it('should not include undefined error and touched in field props', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
      };
      const { result } = renderHook(() => useForm(config));
      const fieldProps = result.current.getFieldProps('email');
      expect(fieldProps.error).toBeUndefined();
      expect(fieldProps.touched).toBeUndefined();
      expect(fieldProps).not.toHaveProperty('error');
      expect(fieldProps).not.toHaveProperty('touched');
    });
  });

describe('Auto-Save Functionality', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });
    afterEach(() => {
      jest.useRealTimers();
    });
    it('should trigger auto-save when enabled and form is dirty', async () => {
      const onAutoSave = jest.fn().mockResolvedValue(undefined);
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        enableAutoSave: true,
        autoSaveDelay: 1000,
        onAutoSave,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setValue('email', 'test@example.com');
      });
      expect(result.current.isDirty).toBe(true);
      act(() => {
        jest.advanceTimersByTime(1000);
      });
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(onAutoSave).toHaveBeenCalledWith({
          ...defaultInitialValues,
          email: 'test@example.com'
        }); });
      }); });
    });
    it('should not trigger auto-save when form is not dirty', async () => {
      const onAutoSave = jest.fn();
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        enableAutoSave: true,
        autoSaveDelay: 1000,
        onAutoSave,
      };
      renderHook(() => useForm(config));
      act(() => {
        jest.advanceTimersByTime(1000);
      });
      expect(onAutoSave).not.toHaveBeenCalled();
    });
    it('should handle manual auto-save trigger', async () => {
      const onAutoSave = jest.fn().mockResolvedValue(undefined);
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        onAutoSave,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setValue('email', 'test@example.com');
      });
      await act(async () => {
        await result.current.triggerAutoSave();
      });
      expect(onAutoSave).toHaveBeenCalledWith({
        ...defaultInitialValues,
        email: 'test@example.com'
      });
    });
    it('should handle auto-save errors gracefully', async () => {
      const onAutoSave = jest.fn().mockRejectedValue(new Error('Save failed'));
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        enableAutoSave: true,
        autoSaveDelay: 10,
        onAutoSave,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setValue('email', 'test@example.com');
      });
      // Wait for auto-save to be triggered
      await act(async () => {
        jest.advanceTimersByTime(10);
        await jest.runAllTimersAsync();
      });
      expect(onAutoSave).toHaveBeenCalled();
      expect(result.current.isAutoSaving).toBe(false);
    }, 10000);
  });

describe('Pattern Validation', () => {
    it('should validate with regex pattern', async () => {
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

describe('Edge Cases and Error Handling', () => {
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
    it('should handle validation of non-string, non-number values', async () => {
      interface CustomForm {
        is_active: boolean;
        tags: string[];
      }
      const config: FormConfig<CustomForm> = {
        initialValues: { is_active: false, tags: [] },
        validationRules: {
          is_active: [
            {
              custom: (value) => value === true,
              message: 'Must be active',
            },
          ],
        },
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('is_active');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.is_active).toBe('Must be active');
    });
    it('should handle async custom validation errors', async () => {
      interface UsernameForm {
        username: string;
      }
      const asyncValidation: ValidationRule<string> = {
        custom: async (value) => {
          // Return false to indicate validation failure
          if (value === 'test') {
            return false;
          }
          return true;
        },
        message: 'Async validation failed',
      };
      const config: FormConfig<UsernameForm> = {
        initialValues: { username: 'test' },
        validationRules: {
          username: [asyncValidation],
        },
      };
      const { result } = renderHook(() => useForm(config));
      const isValid = await act(async () => {
        return await result.current.validateField('username');
      });
      expect(isValid).toBe(false);
      expect(result.current.errors.username).toBe('Async validation failed');
    });
  });

describe('Memory Management and Cleanup', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });
    afterEach(() => {
      jest.useRealTimers();
    });
    it('should cleanup timeouts on unmount', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
        enableAutoSave: true,
        autoSaveDelay: 1000,
        onAutoSave: jest.fn(),
      };
      const clearTimeoutSpy = jest.spyOn(global, 'clearTimeout');
      const { result, unmount } = renderHook(() => useForm(config));
      // Trigger auto-save to create timeouts
      act(() => {
        result.current.setValue('email', 'test@example.com');
        result.current.setTouched('email', true);
      });
      unmount();
      // clearTimeout should be called for validation and auto-save timeouts
      expect(clearTimeoutSpy).toHaveBeenCalled();
      clearTimeoutSpy.mockRestore();
    });
    it('should debounce validation properly', async () => {
      const config: FormConfig<TestFormData> = {
        initialValues: defaultInitialValues,
        validationRules: defaultValidationRules,
        validationDelay: 500,
      };
      const { result } = renderHook(() => useForm(config));
      act(() => {
        result.current.setTouched('email', true);
        result.current.setValue('email', 'test1');
      });
      act(() => {
        result.current.setValue('email', 'test2');
      });
      act(() => {
        result.current.setValue('email', 'test3');
      });
      // Before timeout, no validation should be triggered
      expect(result.current.errors.email).toBeUndefined();
      act(() => {
        jest.advanceTimersByTime(500);
      });
      // Wait for validation to complete
      await act(async () => { await act(async () => { await waitFor(() => {
        expect(result.current.errors.email).toBe('Invalid email format');
      }); });
    });
  });
});
}}