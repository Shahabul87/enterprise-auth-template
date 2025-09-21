

import React from 'react';

/**
 * @jest-environment jsdom
 */
import {
  validateEmail,
  validatePassword,
  validateName,
  validatePhone,
  validateURL,
  validateRequired,
  validateLength,
  validatePattern,
  createValidator,
  ValidationResult,
  ValidationRule
} from '@/lib/validation';
describe('Email Validation', () => {
  it('should validate correct email addresses', () => {
    const validEmails = [
      'test@example.com',
      'user.name@domain.co.uk',
      'first+last@company.org',
      'user123@test-domain.com',
      'a@b.c',
    ];

    validEmails.forEach(email => {
      const result = validateEmail(email);
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });
  });

  it('should reject invalid email addresses', () => {
    const invalidEmails = [
      '',
      'invalid',
      '@domain.com',
      'user@',
      'user space@domain.com',
      'user@domain',
      'user..double@domain.com',
      'user@domain..com',
    ];

    invalidEmails.forEach(email => {
      const result = validateEmail(email);
      expect(result.isValid).toBe(false);
      expect(result.error).toBeDefined();
    });
  });

  it('should handle edge cases', () => {
    expect(validateEmail(null as jest.Mocked<any>).isValid).toBe(false);
    expect(validateEmail(undefined as jest.Mocked<any>).isValid).toBe(false);
    expect(validateEmail('').isValid).toBe(false);
  });
});

describe('Password Validation', () => {
  it('should validate strong passwords', () => {
    const strongPasswords = [
      'SecurePass123!',
      'Another@Strong1',
      'Complex#Password2024',
      'MyP@ssw0rd!',
    ];

    strongPasswords.forEach(password => {
      const result = validatePassword(password);
      expect(result.isValid).toBe(true);
      expect(result.error).toBeUndefined();
    });
  });

  it('should reject weak passwords', () => {
    const weakPasswords = [
      '',
      '123456',
      'password',
      'PASSWORD',
      'Password',
      'Pass123',
      'Password!',
      'password123',
      'PASSWORD123',
    ];

    weakPasswords.forEach(password => {
      const result = validatePassword(password);
      expect(result.isValid).toBe(false);
      expect(result.error).toBeDefined();
    });
  });

  it('should validate password with custom requirements', () => {
    const customRules = {
      minLength: 12,
      requireUppercase: true,
      requireLowercase: true,
      requireNumbers: true,
      requireSpecialChars: true,
      allowSpaces: false,
    };

    const result = validatePassword('VeryLongPassword123!', customRules);
    expect(result.isValid).toBe(true);

    const shortResult = validatePassword('Short1!', customRules);
    expect(shortResult.isValid).toBe(false);
    expect(shortResult.error).toContain('12 characters');
  });

  it('should provide helpful error messages', () => {
    const result = validatePassword('weak');
    expect(result.error).toContain('8 characters');
    expect(result.error).toContain('uppercase');
    expect(result.error).toContain('number');
    expect(result.error).toContain('special character');
  });
});

describe('Name Validation', () => {
  it('should validate proper names', () => {
    const validNames = [
      'John',
      'Mary Jane',
      'Jean-Pierre',
      "O'Connor",
      'José',
      'João',
      'François',
    ];

    validNames.forEach(name => {
      const result = validateName(name);
      expect(result.isValid).toBe(true);
    });
  });

  it('should reject invalid names', () => {
    const invalidNames = [
      '',
      '123',
      'John123',
      'Name@',
      'A',
      'A'.repeat(101), // Too long
    ];

    invalidNames.forEach(name => {
      const result = validateName(name);
      expect(result.isValid).toBe(false);
    });
  });

  it('should handle different name formats', () => {
    expect(validateName('John Doe').isValid).toBe(true);
    expect(validateName('John Doe Smith').isValid).toBe(true);
    expect(validateName('Jean-Pierre').isValid).toBe(true);
    expect(validateName("O'Connor").isValid).toBe(true);
  });
});

describe('Phone Validation', () => {
  it('should validate various phone formats', () => {
    const validPhones = [
      '+1234567890',
      '+1 (234) 567-8900',
      '(234) 567-8900',
      '234-567-8900',
      '234.567.8900',
      '2345678900',
      '+44 20 7946 0958',
      '+33 1 42 86 83 26',
    ];

    validPhones.forEach(phone => {
      const result = validatePhone(phone);
      expect(result.isValid).toBe(true);
    });
  });

  it('should reject invalid phone numbers', () => {
    const invalidPhones = [
      '',
      '123',
      'abcdefghij',
      '123-456-789',
      '+1 123',
      '(123) 456-78901', // Too long
    ];

    invalidPhones.forEach(phone => {
      const result = validatePhone(phone);
      expect(result.isValid).toBe(false);
    });
  });
});

describe('URL Validation', () => {
  it('should validate proper URLs', () => {
    const validURLs = [
      'https://example.com',
      'http://localhost:3000',
      'https://sub.domain.com/path?query=value',
      'ftp://files.example.com',
      'https://example.com:8080/path',
    ];

    validURLs.forEach(url => {
      const result = validateURL(url);
      expect(result.isValid).toBe(true);
    });
  });

  it('should reject invalid URLs', () => {
    const invalidURLs = [
      '',
      'invalid-url',
      'just-text',
      'http://',
      'https://',
      'example.com', // Missing protocol
    ];

    invalidURLs.forEach(url => {
      const result = validateURL(url);
      expect(result.isValid).toBe(false);
    });
  });

  it('should validate URLs with specific protocols', () => {
    const httpsOnly = validateURL('https://example.com', { protocols: ['https'] });
    expect(httpsOnly.isValid).toBe(true);

    const httpNotAllowed = validateURL('http://example.com', { protocols: ['https'] });
    expect(httpNotAllowed.isValid).toBe(false);
  });
});

describe('Basic Validators', () => {
  describe('validateRequired', () => {
    it('should validate required fields', () => {
      expect(validateRequired('value').isValid).toBe(true);
      expect(validateRequired('').isValid).toBe(false);
      expect(validateRequired(null).isValid).toBe(false);
      expect(validateRequired(undefined).isValid).toBe(false);
      expect(validateRequired('   ').isValid).toBe(false); // Whitespace only
    });

    it('should handle arrays and objects', () => {
      expect(validateRequired([1, 2, 3]).isValid).toBe(true);
      expect(validateRequired([]).isValid).toBe(false);
      expect(validateRequired({ key: 'value' }).isValid).toBe(true);
      expect(validateRequired({}).isValid).toBe(false);
    });
  });

describe('validateLength', () => {
    it('should validate string length', () => {
      expect(validateLength('hello', { min: 3, max: 10 }).isValid).toBe(true);
      expect(validateLength('hi', { min: 3 }).isValid).toBe(false);
      expect(validateLength('very long string', { max: 10 }).isValid).toBe(false);
    });

    it('should validate array length', () => {
      expect(validateLength([1, 2, 3], { min: 2, max: 5 }).isValid).toBe(true);
      expect(validateLength([1], { min: 2 }).isValid).toBe(false);
    });
  });

describe('validatePattern', () => {
    it('should validate against regex patterns', () => {
      const numberPattern = /^\d+$/;
      expect(validatePattern('123', numberPattern).isValid).toBe(true);
      expect(validatePattern('abc', numberPattern).isValid).toBe(false);
    });

    it('should validate against string patterns', () => {
      expect(validatePattern('ABC123', '^[A-Z0-9]+$').isValid).toBe(true);
      expect(validatePattern('abc123', '^[A-Z0-9]+$').isValid).toBe(false);
    });
  });
});

describe('Validator Creation', () => {
  it('should create custom validators', () => {
    const rules: ValidationRule[] = [
      { type: 'required', message: 'Field is required' },
      { type: 'length', options: { min: 3, max: 10 }, message: 'Must be 3-10 characters' },
      { type: 'pattern', options: /^[a-zA-Z]+$/, message: 'Only letters allowed' },
    ];

    const validator = createValidator(rules);

    expect(validator('hello').isValid).toBe(true);
    expect(validator('').isValid).toBe(false);
    expect(validator('hi').isValid).toBe(false);
    expect(validator('hello123').isValid).toBe(false);
  });

  it('should stop at first validation error', () => {
    const rules: ValidationRule[] = [
      { type: 'required', message: 'Required' },
      { type: 'length', options: { min: 10 }, message: 'Too short' },
    ];

    const validator = createValidator(rules, { stopOnFirstError: true });
    const result = validator('');

    expect(result.isValid).toBe(false);
    expect(result.error).toBe('Required');
  });

  it('should collect all validation errors', () => {
    const rules: ValidationRule[] = [
      { type: 'length', options: { min: 10 }, message: 'Too short' },
      { type: 'pattern', options: /\d/, message: 'Must contain number' },
    ];

    const validator = createValidator(rules, { stopOnFirstError: false });
    const result = validator('hello');

    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('Too short');
    expect(result.errors).toContain('Must contain number');
  });
});

describe('Complex Validation Scenarios', () => {
  it('should validate user registration form', () => {
    const userValidator = createValidator([
      { type: 'required', message: 'Email is required' },
      { type: 'email', message: 'Invalid email format' },
    ]);

    const passwordValidator = createValidator([
      { type: 'required', message: 'Password is required' },
      { type: 'password', message: 'Password too weak' },
    ]);

    const nameValidator = createValidator([
      { type: 'required', message: 'Name is required' },
      { type: 'name', message: 'Invalid name format' },
    ]);

    // Valid data
    expect(userValidator('user@example.com').isValid).toBe(true);
    expect(passwordValidator('SecurePass123!').isValid).toBe(true);
    expect(nameValidator('John Doe').isValid).toBe(true);

    // Invalid data
    expect(userValidator('invalid-email').isValid).toBe(false);
    expect(passwordValidator('weak').isValid).toBe(false);
    expect(nameValidator('').isValid).toBe(false);
  });

  it('should validate conditional fields', () => {
    const createConditionalValidator = (condition: boolean) => {
      const rules: ValidationRule[] = [];

      if (condition) {
        rules.push({ type: 'required', message: 'Required when condition is true' });
      }

      return createValidator(rules);
    };

    const requiredValidator = createConditionalValidator(true);
    const optionalValidator = createConditionalValidator(false);

    expect(requiredValidator('').isValid).toBe(false);
    expect(optionalValidator('').isValid).toBe(true);
  });

  it('should validate dependent fields', () => {
    const validateConfirmPassword = (password: string, confirmPassword: string): ValidationResult => {
      if (!confirmPassword) {
        return { isValid: false, error: 'Please confirm your password' };
      }

      if (password !== confirmPassword) {
        return { isValid: false, error: 'Passwords do not match' };
      }

      return { isValid: true };
    };

    expect(validateConfirmPassword('password123', 'password123').isValid).toBe(true);
    expect(validateConfirmPassword('password123', 'different').isValid).toBe(false);
    expect(validateConfirmPassword('password123', '').isValid).toBe(false);
  });

  it('should validate form with multiple interdependent fields', () => {
    const validateUserForm = (data: {
      email: string;
      password: string;
      confirmPassword: string;
      acceptTerms: boolean;
    }) => {
      const errors: Record<string, string> = {};

      const emailResult = validateEmail(data.email);
      if (!emailResult.isValid) {
        errors.email = emailResult.error!;
      }

      const passwordResult = validatePassword(data.password);
      if (!passwordResult.isValid) {
        errors.password = passwordResult.error!;
      }

      if (data.password !== data.confirmPassword) {
        errors.confirmPassword = 'Passwords do not match';
      }

      if (!data.acceptTerms) {
        errors.acceptTerms = 'You must accept the terms and conditions';
      }

      return {
        isValid: Object.keys(errors).length === 0,
        errors,
      };
    };

    // Valid form
    const validForm = {
      email: 'user@example.com',
      password: 'SecurePass123!',
      confirmPassword: 'SecurePass123!',
      acceptTerms: true,
    };
    expect(validateUserForm(validForm).isValid).toBe(true);

    // Invalid form
    const invalidForm = {
      email: 'invalid-email',
      password: 'weak',
      confirmPassword: 'different',
      acceptTerms: false,
    };
    const result = validateUserForm(invalidForm);
    expect(result.isValid).toBe(false);
    expect(Object.keys(result.errors)).toHaveLength(4);
  });
});

describe('Performance', () => {
  it('should handle large datasets efficiently', () => {
    const largeString = 'a'.repeat(10000);
    const start = performance.now();

    for (let i = 0; i < 1000; i++) {
      validateLength(largeString, { min: 1, max: 20000 });
    }

    const end = performance.now();
    expect(end - start).toBeLessThan(100); // Should be fast
  });

  it('should cache validation results when possible', () => {
    const email = 'test@example.com';

    const start = performance.now();
    for (let i = 0; i < 1000; i++) {
      validateEmail(email);
    }
    const end = performance.now();

    expect(end - start).toBeLessThan(50); // Should be very fast with caching
  });
});