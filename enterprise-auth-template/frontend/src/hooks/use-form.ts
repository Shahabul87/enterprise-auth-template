'use client';

import { useState, useCallback, useMemo, useRef, useEffect } from 'react';
import { useDebounce } from './use-debounce';

/**
 * Comprehensive form management hook with validation and state handling
 * 
 * Provides a complete form management solution with:
 * - Field-level validation with custom rules
 * - Async validation support
 * - Form-level validation
 * - Dirty state tracking
 * - Touch state management
 * - Error handling and display
 * - Submit handling with loading states
 * - Auto-save functionality
 * - Reset and restore capabilities
 * 
 * @example
 * ```typescript
 * interface LoginForm {
 *   email: string;
 *   password: string;
 * }
 * 
 * const {
 *   values,
 *   errors,
 *   touched,
 *   isValid,
 *   isSubmitting,
 *   setValue,
 *   setError,
 *   handleSubmit,
 *   reset,
 * } = useForm<LoginForm>({
 *   initialValues: { email: '', password: '' },
 *   validationRules: {
 *     email: [
 *       { required: true, message: 'Email is required' },
 *       { type: 'email', message: 'Invalid email format' }
 *     ],
 *     password: [
 *       { required: true, message: 'Password is required' },
 *       { minLength: 8, message: 'Password must be at least 8 characters' }
 *     ]
 *   },
 *   onSubmit: async (values) => {
 *     const result = await loginUser(values);
 *     return result.success;
 *   }
 * });
 * ```
 */

export type ValidationRule<T = unknown> = {
  required?: boolean;
  minLength?: number;
  maxLength?: number;
  min?: number;
  max?: number;
  pattern?: RegExp;
  type?: 'email' | 'url' | 'number' | 'tel';
  custom?: (value: T) => boolean | string | Promise<boolean | string>;
  message: string;
};

export type ValidationRules<T> = {
  [K in keyof T]?: ValidationRule<T[K]>[];
};

export type FormErrors<T> = {
  [K in keyof T]?: string;
};

export type FormTouched<T> = {
  [K in keyof T]?: boolean;
};

export interface FormConfig<T> {
  /** Initial form values */
  initialValues: T;
  /** Validation rules for each field */
  validationRules?: ValidationRules<T>;
  /** Whether to validate on change */
  validateOnChange?: boolean;
  /** Whether to validate on blur */
  validateOnBlur?: boolean;
  /** Debounce delay for validation (ms) */
  validationDelay?: number;
  /** Whether to enable auto-save */
  enableAutoSave?: boolean;
  /** Auto-save delay (ms) */
  autoSaveDelay?: number;
  /** Auto-save callback */
  onAutoSave?: (values: T) => void | Promise<void>;
  /** Submit handler */
  onSubmit?: (values: T) => boolean | Promise<boolean>;
  /** Success callback after successful submit */
  onSuccess?: (values: T) => void | Promise<void>;
  /** Error callback after failed submit */
  onError?: (error: string, values: T) => void;
  /** Reset callback */
  onReset?: (values: T) => void;
  /** Transform values before submit */
  transformOnSubmit?: (values: T) => T;
}

export interface FormState<T> {
  /** Current form values */
  values: T;
  /** Form errors */
  errors: FormErrors<T>;
  /** Touched fields */
  touched: FormTouched<T>;
  /** Whether form is valid */
  isValid: boolean;
  /** Whether form is dirty (changed from initial values) */
  isDirty: boolean;
  /** Whether form is submitting */
  isSubmitting: boolean;
  /** Whether form is validating */
  isValidating: boolean;
  /** Whether auto-save is in progress */
  isAutoSaving: boolean;
  /** General form error message */
  formError: string;
  /** Submit count for analytics */
  submitCount: number;
}

export interface FormActions<T> {
  /** Set value for a specific field */
  setValue: <K extends keyof T>(name: K, value: T[K]) => void;
  /** Set multiple values at once */
  setValues: (values: Partial<T>) => void;
  /** Set error for a specific field */
  setError: <K extends keyof T>(name: K, error: string) => void;
  /** Set multiple errors at once */
  setErrors: (errors: FormErrors<T>) => void;
  /** Clear error for a specific field */
  clearError: <K extends keyof T>(name: K) => void;
  /** Clear all errors */
  clearErrors: () => void;
  /** Set touched state for a field */
  setTouched: <K extends keyof T>(name: K, touched?: boolean) => void;
  /** Mark field as touched */
  touchField: <K extends keyof T>(name: K) => void;
  /** Validate specific field */
  validateField: <K extends keyof T>(name: K) => Promise<boolean>;
  /** Validate entire form */
  validateForm: () => Promise<boolean>;
  /** Submit form */
  handleSubmit: (event?: React.FormEvent) => Promise<void>;
  /** Reset form to initial values */
  reset: () => void;
  /** Reset to specific values */
  resetTo: (values: T) => void;
  /** Get field props for input binding */
  getFieldProps: <K extends keyof T>(name: K) => {
    name: K;
    value: T[K];
    onChange: (value: T[K]) => void;
    onBlur: () => void;
    error?: string;
    touched?: boolean;
  };
  /** Get field state */
  getFieldState: <K extends keyof T>(name: K) => {
    value: T[K];
    error?: string;
    touched?: boolean;
    isDirty: boolean;
  };
  /** Manually trigger auto-save */
  triggerAutoSave: () => void;
}

export interface UseFormReturn<T> extends FormState<T>, FormActions<T> {}

export function useForm<T extends Record<string, unknown>>(
  config: FormConfig<T>
): UseFormReturn<T> {
  const {
    initialValues,
    validationRules = {},
    validateOnChange = true,
    validateOnBlur = true,
    validationDelay = 300,
    enableAutoSave = false,
    autoSaveDelay = 2000,
    onAutoSave,
    onSubmit,
    onSuccess,
    onError,
    onReset,
    transformOnSubmit,
  } = config;

  const [values, setValuesState] = useState<T>(initialValues);
  const [errors, setErrorsState] = useState<FormErrors<T>>({});
  const [touched, setTouchedState] = useState<FormTouched<T>>({});
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [isValidating, setIsValidating] = useState<boolean>(false);
  const [isAutoSaving, setIsAutoSaving] = useState<boolean>(false);
  const [formError, setFormError] = useState<string>('');
  const [submitCount, setSubmitCount] = useState<number>(0);

  const initialValuesRef = useRef<T>(initialValues);
  const validationTimeoutRef = useRef<NodeJS.Timeout>();
  const autoSaveTimeoutRef = useRef<NodeJS.Timeout>();

  // Debounced values for validation
  const debouncedValues = useDebounce(values, validationDelay);

  // Computed states
  const isValid = useMemo(() => {
    return Object.keys(errors).length === 0;
  }, [errors]);

  const isDirty = useMemo(() => {
    return JSON.stringify(values) !== JSON.stringify(initialValuesRef.current);
  }, [values]);

  // Validation function
  const validateValue = useCallback(
    async <K extends keyof T>(name: K, value: T[K]): Promise<string | undefined> => {
      const fieldRules = (validationRules as Record<keyof T, ValidationRule<T[K]>[]>)[name];
      if (!fieldRules || fieldRules.length === 0) return undefined;

      for (const rule of fieldRules) {
        // Required validation
        if (rule.required && (!value || (typeof value === 'string' && value.trim() === ''))) {
          return rule.message;
        }

        // Skip other validations if value is empty and not required
        if (!value && !rule.required) continue;

        // String validations
        if (typeof value === 'string') {
          if (rule.minLength && value.length < rule.minLength) {
            return rule.message;
          }
          if (rule.maxLength && value.length > rule.maxLength) {
            return rule.message;
          }
          if (rule.pattern && !rule.pattern.test(value)) {
            return rule.message;
          }
          if (rule.type === 'email' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
            return rule.message;
          }
          if (rule.type === 'url' && !/^https?:\/\/.+/.test(value)) {
            return rule.message;
          }
        }

        // Number validations
        if (typeof value === 'number') {
          if (rule.min !== undefined && value < rule.min) {
            return rule.message;
          }
          if (rule.max !== undefined && value > rule.max) {
            return rule.message;
          }
        }

        // Custom validation
        if (rule.custom) {
          const result = await rule.custom(value);
          if (typeof result === 'string') {
            return result;
          }
          if (result === false) {
            return rule.message;
          }
        }
      }

      return undefined;
    },
    [validationRules]
  );

  // Field validation
  const validateField = useCallback(
    async <K extends keyof T>(name: K): Promise<boolean> => {
      setIsValidating(true);
      try {
        const error = await validateValue(name, values[name]);
        setErrorsState(prev => ({
          ...prev,
          [name]: error,
        }));
        return !error;
      } finally {
        setIsValidating(false);
      }
    },
    [values, validateValue]
  );

  // Form validation
  const validateForm = useCallback(async (): Promise<boolean> => {
    setIsValidating(true);
    const newErrors: FormErrors<T> = {};
    
    try {
      const validationPromises = Object.keys(values).map(async (key) => {
        const fieldKey = key as keyof T;
        const error = await validateValue(fieldKey, values[fieldKey]);
        if (error) {
          newErrors[fieldKey] = error;
        }
      });

      await Promise.all(validationPromises);
      setErrorsState(newErrors);
      return Object.keys(newErrors).length === 0;
    } finally {
      setIsValidating(false);
    }
  }, [values, validateValue]);

  // Auto-validation on value change
  useEffect(() => {
    if (!validateOnChange) return;

    if (validationTimeoutRef.current) {
      clearTimeout(validationTimeoutRef.current);
    }

    validationTimeoutRef.current = setTimeout(() => {
      Object.keys(touched).forEach((key) => {
        if (touched[key as keyof T]) {
          validateField(key as keyof T);
        }
      });
    }, validationDelay);

    return () => {
      if (validationTimeoutRef.current) {
        clearTimeout(validationTimeoutRef.current);
      }
    };
  }, [debouncedValues, validateField, validateOnChange, touched, validationDelay]);

  // Auto-save functionality
  useEffect(() => {
    if (!enableAutoSave || !onAutoSave || !isDirty) return;

    if (autoSaveTimeoutRef.current) {
      clearTimeout(autoSaveTimeoutRef.current);
    }

    autoSaveTimeoutRef.current = setTimeout(async () => {
      setIsAutoSaving(true);
      try {
        await onAutoSave(values);
      } catch {
        
      } finally {
        setIsAutoSaving(false);
      }
    }, autoSaveDelay);

    return () => {
      if (autoSaveTimeoutRef.current) {
        clearTimeout(autoSaveTimeoutRef.current);
      }
    };
  }, [values, enableAutoSave, onAutoSave, isDirty, autoSaveDelay]);

  // Actions
  const setValue = useCallback(<K extends keyof T>(name: K, value: T[K]) => {
    setValuesState(prev => ({ ...prev, [name]: value }));
    setFormError('');
  }, []);

  const setValues = useCallback((newValues: Partial<T>) => {
    setValuesState(prev => ({ ...prev, ...newValues }));
    setFormError('');
  }, []);

  const setError = useCallback(<K extends keyof T>(name: K, error: string) => {
    setErrorsState(prev => ({ ...prev, [name]: error }));
  }, []);

  const setErrors = useCallback((newErrors: FormErrors<T>) => {
    setErrorsState(newErrors);
  }, []);

  const clearError = useCallback(<K extends keyof T>(name: K) => {
    setErrorsState(prev => {
      const { [name]: _unused, ...rest } = prev;
      return rest as FormErrors<T>;
    });
  }, []);

  const clearErrors = useCallback(() => {
    setErrorsState({});
    setFormError('');
  }, []);

  const setTouched = useCallback(<K extends keyof T>(name: K, isTouched = true) => {
    setTouchedState(prev => ({ ...prev, [name]: isTouched }));
  }, []);

  const touchField = useCallback(<K extends keyof T>(name: K) => {
    setTouched(name, true);
    if (validateOnBlur) {
      validateField(name);
    }
  }, [setTouched, validateOnBlur, validateField]);

  const handleSubmit = useCallback(
    async (event?: React.FormEvent) => {
      if (event) {
        event.preventDefault();
      }

      setIsSubmitting(true);
      setFormError('');
      setSubmitCount(prev => prev + 1);

      // Mark all fields as touched
      const allTouched: FormTouched<T> = {};
      Object.keys(values).forEach(key => {
        allTouched[key as keyof T] = true;
      });
      setTouchedState(allTouched);

      try {
        // Validate form
        const isFormValid = await validateForm();
        if (!isFormValid) {
          setFormError('Please fix the errors above');
          return;
        }

        if (onSubmit) {
          const submitValues = transformOnSubmit ? transformOnSubmit(values) : values;
          const success = await onSubmit(submitValues);

          if (success) {
            if (onSuccess) {
              await onSuccess(submitValues);
            }
          } else {
            if (onError) {
              onError('Submission failed', submitValues);
            }
          }
        }
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'An unexpected error occurred';
        setFormError(errorMessage);
        if (onError) {
          onError(errorMessage, values);
        }
      } finally {
        setIsSubmitting(false);
      }
    },
    [values, validateForm, onSubmit, onSuccess, onError, transformOnSubmit]
  );

  const reset = useCallback(() => {
    setValuesState(initialValuesRef.current);
    setErrorsState({});
    setTouchedState({});
    setFormError('');
    setSubmitCount(0);
    
    if (onReset) {
      onReset(initialValuesRef.current);
    }
  }, [onReset]);

  const resetTo = useCallback((newValues: T) => {
    initialValuesRef.current = newValues;
    setValuesState(newValues);
    setErrorsState({});
    setTouchedState({});
    setFormError('');
    setSubmitCount(0);
    
    if (onReset) {
      onReset(newValues);
    }
  }, [onReset]);

  const getFieldProps = useCallback(
    <K extends keyof T>(name: K) => {
      const fieldError = errors[name];
      const fieldTouched = touched[name];
      return {
        name,
        value: values[name],
        onChange: (value: T[K]) => setValue(name, value),
        onBlur: () => touchField(name),
        ...(fieldError ? { error: fieldError } : {}),
        ...(fieldTouched ? { touched: fieldTouched } : {}),
      };
    },
    [values, errors, touched, setValue, touchField]
  );

  const getFieldState = useCallback(
    <K extends keyof T>(name: K) => {
      const fieldError = errors[name];
      const fieldTouched = touched[name];
      return {
        value: values[name],
        ...(fieldError ? { error: fieldError } : {}),
        ...(fieldTouched ? { touched: fieldTouched } : {}),
        isDirty: values[name] !== initialValuesRef.current[name],
      };
    },
    [values, errors, touched]
  );

  const triggerAutoSave = useCallback(async () => {
    if (onAutoSave && isDirty) {
      setIsAutoSaving(true);
      try {
        await onAutoSave(values);
      } catch {
        
      } finally {
        setIsAutoSaving(false);
      }
    }
  }, [onAutoSave, values, isDirty]);

  // Cleanup timeouts on unmount
  useEffect(() => {
    return () => {
      if (validationTimeoutRef.current) {
        clearTimeout(validationTimeoutRef.current);
      }
      if (autoSaveTimeoutRef.current) {
        clearTimeout(autoSaveTimeoutRef.current);
      }
    };
  }, []);

  return {
    // State
    values,
    errors,
    touched,
    isValid,
    isDirty,
    isSubmitting,
    isValidating,
    isAutoSaving,
    formError,
    submitCount,
    
    // Actions
    setValue,
    setValues,
    setError,
    setErrors,
    clearError,
    clearErrors,
    setTouched,
    touchField,
    validateField,
    validateForm,
    handleSubmit,
    reset,
    resetTo,
    getFieldProps,
    getFieldState,
    triggerAutoSave,
  };
}