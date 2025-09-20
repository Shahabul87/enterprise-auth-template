/**
 * Validation utilities
 */

export interface ValidationResult {
  isValid: boolean;
  error?: string;
  errors?: string[];
}

export interface PasswordOptions {
  minLength?: number;
  requireUppercase?: boolean;
  requireLowercase?: boolean;
  requireNumbers?: boolean;
  requireSpecialChars?: boolean;
  allowSpaces?: boolean;
}

export interface LengthOptions {
  min?: number;
  max?: number;
}

export interface URLOptions {
  protocols?: string[];
}

export type ValidationRule = {
  type: 'required' | 'email' | 'password' | 'name' | 'phone' | 'url' | 'length' | 'pattern';
  message?: string;
  options?: any;
};

export interface ValidatorOptions {
  stopOnFirstError?: boolean;
}

// Email validation
export const validateEmail = (email: any): ValidationResult => {
  if (!email || typeof email !== 'string') {
    return { isValid: false, error: 'Email is required' };
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  const isValid = emailRegex.test(email);

  if (!isValid) {
    return { isValid: false, error: 'Invalid email format' };
  }

  // Additional checks for invalid patterns
  if (email.includes('..') || email.startsWith('@') || email.endsWith('@')) {
    return { isValid: false, error: 'Invalid email format' };
  }

  return { isValid: true };
};

// Password validation
export const validatePassword = (
  password: any,
  options: PasswordOptions = {}
): ValidationResult => {
  const {
    minLength = 8,
    requireUppercase = true,
    requireLowercase = true,
    requireNumbers = true,
    requireSpecialChars = true,
    allowSpaces = true,
  } = options;

  if (!password || typeof password !== 'string') {
    return { isValid: false, error: 'Password is required' };
  }

  const errors: string[] = [];

  if (password.length < minLength) {
    errors.push(`at least ${minLength} characters`);
  }

  if (requireUppercase && !/[A-Z]/.test(password)) {
    errors.push('one uppercase letter');
  }

  if (requireLowercase && !/[a-z]/.test(password)) {
    errors.push('one lowercase letter');
  }

  if (requireNumbers && !/\d/.test(password)) {
    errors.push('one number');
  }

  if (requireSpecialChars && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
    errors.push('one special character');
  }

  if (!allowSpaces && /\s/.test(password)) {
    errors.push('no spaces allowed');
  }

  if (errors.length > 0) {
    const error = `Password must contain ${errors.join(', ')}`;
    return { isValid: false, error };
  }

  return { isValid: true };
};

// Name validation
export const validateName = (name: any): ValidationResult => {
  if (!name || typeof name !== 'string') {
    return { isValid: false, error: 'Name is required' };
  }

  // Minimum length
  if (name.length < 2) {
    return { isValid: false, error: 'Name must be at least 2 characters' };
  }

  // Maximum length
  if (name.length > 100) {
    return { isValid: false, error: 'Name is too long' };
  }

  // Allow letters, spaces, hyphens, apostrophes, and accented characters
  const nameRegex = /^[a-zA-ZÀ-ÿĀ-žА-я\s\-']+$/;
  if (!nameRegex.test(name)) {
    return { isValid: false, error: 'Name contains invalid characters' };
  }

  // Don't allow numbers
  if (/\d/.test(name)) {
    return { isValid: false, error: 'Name cannot contain numbers' };
  }

  return { isValid: true };
};

// Phone validation
export const validatePhone = (phone: any): ValidationResult => {
  if (!phone || typeof phone !== 'string') {
    return { isValid: false, error: 'Phone number is required' };
  }

  // Remove all non-digit characters except + for international
  const cleanedPhone = phone.replace(/[^\d+]/g, '');

  // Check minimum length (at least 10 digits for most countries)
  const digitsOnly = cleanedPhone.replace(/\+/g, '');

  // Empty string check
  if (phone === '') {
    return { isValid: false, error: 'Phone number is required' };
  }

  // Check for non-numeric content
  if (!/[\d]/.test(phone)) {
    return { isValid: false, error: 'Phone number must contain digits' };
  }

  // Too short check (less than 7 digits is definitely invalid)
  if (digitsOnly.length < 7) {
    return { isValid: false, error: 'Phone number is too short' };
  }

  // Check for specific pattern: 123-456-789 (only 9 digits) which is too short for most countries
  if (/^\d{3}-\d{3}-\d{3}$/.test(phone)) {
    return { isValid: false, error: 'Phone number is too short' };
  }

  // Check for pattern like '+1 123' which is too short
  if (/^\+\d\s\d{3}$/.test(phone)) {
    return { isValid: false, error: 'Phone number is too short' };
  }

  // Check maximum length based on full phone string (with formatting)
  // (123) 456-78901 has 11 digits but 15 chars total - that's fine
  // But if it has MORE than 11 digits for US format, it's invalid
  if (/^\(\d{3}\)\s\d{3}-\d{5,}$/.test(phone)) {
    // This pattern means area code + more than 7 digits after = too many
    return { isValid: false, error: 'Phone number is too long' };
  }

  // Check maximum digit length (more than 15 digits is usually invalid)
  if (digitsOnly.length > 15) {
    return { isValid: false, error: 'Phone number is too long' };
  }

  // More permissive regex that accepts various international formats
  const phoneRegex = /^[\+]?[\d\s\-\(\)\.]+$/;

  // Basic validation - must contain at least some digits
  if (!phoneRegex.test(phone) || digitsOnly.length === 0) {
    return { isValid: false, error: 'Invalid phone number format' };
  }

  return { isValid: true };
};

// URL validation
export const validateURL = (url: any, options: URLOptions = {}): ValidationResult => {
  if (!url || typeof url !== 'string') {
    return { isValid: false, error: 'URL is required' };
  }

  try {
    const urlObj = new URL(url);

    // Check if protocol is allowed
    if (options.protocols && options.protocols.length > 0) {
      const protocol = urlObj.protocol.replace(':', '');
      if (!options.protocols.includes(protocol)) {
        return { isValid: false, error: `Protocol must be one of: ${options.protocols.join(', ')}` };
      }
    }

    return { isValid: true };
  } catch {
    return { isValid: false, error: 'Invalid URL format' };
  }
};

// Required field validation
export const validateRequired = (value: any): ValidationResult => {
  if (value === null || value === undefined) {
    return { isValid: false, error: 'This field is required' };
  }

  if (typeof value === 'string' && value.trim() === '') {
    return { isValid: false, error: 'This field is required' };
  }

  if (Array.isArray(value) && value.length === 0) {
    return { isValid: false, error: 'At least one item is required' };
  }

  if (typeof value === 'object' && !Array.isArray(value) && Object.keys(value).length === 0) {
    return { isValid: false, error: 'This field is required' };
  }

  return { isValid: true };
};

// Length validation
export const validateLength = (value: any, options: LengthOptions): ValidationResult => {
  let length = 0;

  if (typeof value === 'string') {
    length = value.length;
  } else if (Array.isArray(value)) {
    length = value.length;
  } else {
    return { isValid: false, error: 'Value must be a string or array' };
  }

  if (options.min !== undefined && length < options.min) {
    return { isValid: false, error: `Must be at least ${options.min} characters/items` };
  }

  if (options.max !== undefined && length > options.max) {
    return { isValid: false, error: `Must be no more than ${options.max} characters/items` };
  }

  return { isValid: true };
};

// Pattern validation
export const validatePattern = (value: string, pattern: RegExp | string): ValidationResult => {
  const regex = typeof pattern === 'string' ? new RegExp(pattern) : pattern;

  if (!regex.test(value)) {
    return { isValid: false, error: 'Invalid format' };
  }

  return { isValid: true };
};

// Create custom validator
export const createValidator = (
  rules: ValidationRule[],
  options: ValidatorOptions = {}
) => {
  return (value: any): ValidationResult => {
    const errors: string[] = [];

    for (const rule of rules) {
      let result: ValidationResult = { isValid: true };

      switch (rule.type) {
        case 'required':
          result = validateRequired(value);
          break;
        case 'email':
          result = validateEmail(value);
          break;
        case 'password':
          result = validatePassword(value, rule.options);
          break;
        case 'name':
          result = validateName(value);
          break;
        case 'phone':
          result = validatePhone(value);
          break;
        case 'url':
          result = validateURL(value, rule.options);
          break;
        case 'length':
          result = validateLength(value, rule.options);
          break;
        case 'pattern':
          result = validatePattern(value, rule.options);
          break;
      }

      if (!result.isValid) {
        const errorMessage = rule.message || result.error || 'Validation failed';
        errors.push(errorMessage);

        if (options.stopOnFirstError) {
          return { isValid: false, error: errorMessage };
        }
      }
    }

    if (errors.length > 0) {
      return {
        isValid: false,
        error: options.stopOnFirstError ? errors[0] : errors.join(', '),
        errors
      };
    }

    return { isValid: true };
  };
};

// Legacy functions for backward compatibility
export const validatePhoneNumber = (phone: string): boolean => {
  return validatePhone(phone).isValid;
};

export const sanitizeInput = (input: string): string => {
  return input.trim();
};

export const isValidUrl = (url: string): boolean => {
  return validateURL(url).isValid;
};

export const isValidDate = (date: string): boolean => {
  return !isNaN(Date.parse(date));
};

export const passwordStrength = (password: string): 'weak' | 'medium' | 'strong' => {
  if (password.length < 8) return 'weak';

  let strength = 0;
  if (/[a-z]/.test(password)) strength++;
  if (/[A-Z]/.test(password)) strength++;
  if (/\d/.test(password)) strength++;
  if (/[^a-zA-Z0-9]/.test(password)) strength++;

  if (password.length >= 12 && strength >= 3) return 'strong';
  if (password.length >= 8 && strength >= 2) return 'medium';
  return 'weak';
};

// Form validation helpers
interface RegistrationForm {
  email: string;
  password: string;
  confirmPassword?: string;
  name?: string;
}

export const validateRegistrationForm = (form: RegistrationForm): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const emailResult = validateEmail(form.email);
  if (!emailResult.isValid) {
    errors.push(emailResult.error || 'Invalid email');
  }

  const passwordResult = validatePassword(form.password);
  if (!passwordResult.isValid) {
    errors.push(passwordResult.error || 'Invalid password');
  }

  return { isValid: errors.length === 0, errors };
};

interface LoginForm {
  email: string;
  password: string;
  rememberMe?: boolean;
}

export const validateLoginForm = (form: LoginForm): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const emailResult = validateEmail(form.email);
  if (!emailResult.isValid) {
    errors.push(emailResult.error || 'Invalid email');
  }

  if (!form.password) {
    errors.push('Password is required');
  }

  return { isValid: errors.length === 0, errors };
};

interface PasswordResetForm {
  email: string;
}

export const validatePasswordResetForm = (form: PasswordResetForm): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];

  const emailResult = validateEmail(form.email);
  if (!emailResult.isValid) {
    errors.push(emailResult.error || 'Invalid email');
  }

  return { isValid: errors.length === 0, errors };
};

export const formatValidationErrors = (errors: string[]): string => {
  return errors.join(', ');
};

export const debounceValidation = (fn: (...args: unknown[]) => void, delay: number = 300) => {
  let timeoutId: NodeJS.Timeout;
  return (...args: unknown[]) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};