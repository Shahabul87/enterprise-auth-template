/**
 * Validation utilities stub
 * TODO: Implement actual validation logic
 */

export const validateEmail = (email: string): { isValid: boolean; error?: string } => {
  const isValid = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  return isValid ? { isValid } : { isValid, error: 'Invalid email format' };
};

export const validatePassword = (password: string): { isValid: boolean; error?: string } => {
  const isValid = password.length >= 8;
  return isValid ? { isValid } : { isValid, error: 'Password must be at least 8 characters' };
};

export const validateName = (name: string): boolean => {
  return name.length >= 2;
};

export const validatePhoneNumber = (phone: string): boolean => {
  return /^\+?[\d\s-()]{10,}$/.test(phone);
};

export const sanitizeInput = (input: string): string => {
  return input.trim();
};

export const isValidUrl = (url: string): boolean => {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
};

export const isValidDate = (date: string): boolean => {
  return !isNaN(Date.parse(date));
};

export const passwordStrength = (password: string): 'weak' | 'medium' | 'strong' => {
  if (password.length < 8) return 'weak';
  if (password.length < 12) return 'medium';
  return 'strong';
};

interface RegistrationForm {
  email: string;
  password: string;
  confirmPassword?: string;
  name?: string;
}

export const validateRegistrationForm = (form: RegistrationForm): { isValid: boolean; errors: string[] } => {
  const errors: string[] = [];
  
  if (!validateEmail(form.email)) {
    errors.push('Invalid email format');
  }
  
  if (!validatePassword(form.password)) {
    errors.push('Password must be at least 8 characters');
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
  
  if (!validateEmail(form.email)) {
    errors.push('Invalid email format');
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
  
  if (!validateEmail(form.email)) {
    errors.push('Invalid email format');
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