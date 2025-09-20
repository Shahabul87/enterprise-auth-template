

import React from 'react';

/**
 * Comprehensive Utils Tests
 *
 * Tests utility functions with proper TypeScript types,
 * edge cases, and full coverage.
 */
import {
  cn,
  formatDate,
  isValidEmail,
  isStrongPassword,
  capitalizeFirst,
  truncate,
  getErrorMessage,
  debounce,
  getLocalStorageItem,
  setLocalStorageItem,
  removeLocalStorageItem,
  createSearchParams,
  isNotNull,
  isNotUndefined,
} from '@/lib/utils';

// Mock localStorage for testing
interface MockStorage {
  getItem: jest.MockedFunction<(key: string) => string | null>;
  setItem: jest.MockedFunction<(key: string, value: string) => void>;
  removeItem: jest.MockedFunction<(key: string) => void>;
  clear: jest.MockedFunction<() => void>;
  length: number;
  key: jest.MockedFunction<(index: number) => string | null>;
}

const mockLocalStorage: MockStorage = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
  length: 0,
  key: jest.fn(),
};

// Setup window mock for localStorage tests
const originalWindow = global.window;
const mockWindow = {
  localStorage: mockLocalStorage,
};

describe('Utils', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.clearAllTimers();
    jest.useFakeTimers();

    // Reset localStorage mock
    mockLocalStorage.getItem.mockReturnValue(null);
    mockLocalStorage.setItem.mockImplementation(() => {});
    mockLocalStorage.removeItem.mockImplementation(() => {});
  });

  afterEach(() => {
    jest.useRealTimers();
  });

describe('cn (className merger)', () => {
    it('merges class names correctly', () => {
      const result = cn('btn', 'btn-primary', 'active');
      expect(typeof result).toBe('string');
      expect(result).toContain('btn');
    });

    it('handles conditional classes', () => {
      const is_active = true;
      const isDisabled = false;

      const result = cn(
        'btn',
        is_active && 'active',
        isDisabled && 'disabled'
      );

      expect(result).toContain('btn');
      expect(result).toContain('active');
      expect(result).not.toContain('disabled');
    });

    it('handles arrays of classes', () => {
      const result = cn(['btn', 'btn-primary'], 'active');
      expect(result).toContain('btn');
    });

    it('handles empty input', () => {
      const result = cn();
      expect(result).toBe('');
    });

    it('filters out falsy values', () => {
      const result = cn('btn', null, undefined, false, '', 'active');
      expect(result).toContain('btn');
      expect(result).toContain('active');
      expect(result).not.toContain('null');
      expect(result).not.toContain('undefined');
    });
  });

describe('formatDate', () => {
    const testDate = new Date('2024-01-15T10:30:00Z');
    const testDateString = '2024-01-15T10:30:00Z';

    beforeEach(() => {
      // Mock current date for consistent relative time tests
      jest.setSystemTime(new Date('2024-01-15T11:30:00Z'));
    });

    it('formats date in short format by default', () => {
      const result = formatDate(testDate);
      expect(result).toMatch(/\d{1,2}\/\d{1,2}\/\d{4}/);
    });

    it('formats date in long format', () => {
      const result = formatDate(testDate, 'long');
      expect(result).toContain('Monday');
      expect(result).toContain('January');
      expect(result).toContain('15');
      expect(result).toContain('2024');
    });

    it('handles string date input', () => {
      const result = formatDate(testDateString);
      expect(typeof result).toBe('string');
      expect(result).toMatch(/\d{1,2}\/\d{1,2}\/\d{4}/);
    });

describe('relative format', () => {
      it('shows "Just now" for very recent dates', () => {
        const now = new Date();
        const result = formatDate(now, 'relative');
        expect(result).toBe('Just now');
      });

      it('shows minutes ago for recent dates', () => {
        const minutesAgo = new Date(Date.now() - 5 * 60 * 1000); // 5 minutes ago
        const result = formatDate(minutesAgo, 'relative');
        expect(result).toBe('5 minutes ago');
      });

      it('shows singular minute for 1 minute ago', () => {
        const oneMinuteAgo = new Date(Date.now() - 1 * 60 * 1000);
        const result = formatDate(oneMinuteAgo, 'relative');
        expect(result).toBe('1 minute ago');
      });

      it('shows hours ago for older dates', () => {
        const hoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000); // 2 hours ago
        const result = formatDate(hoursAgo, 'relative');
        expect(result).toBe('2 hours ago');
      });

      it('shows singular hour for 1 hour ago', () => {
        const oneHourAgo = new Date(Date.now() - 1 * 60 * 60 * 1000);
        const result = formatDate(oneHourAgo, 'relative');
        expect(result).toBe('1 hour ago');
      });

      it('shows days ago for recent days', () => {
        const daysAgo = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000); // 3 days ago
        const result = formatDate(daysAgo, 'relative');
        expect(result).toBe('3 days ago');
      });

      it('shows singular day for 1 day ago', () => {
        const oneDayAgo = new Date(Date.now() - 1 * 24 * 60 * 60 * 1000);
        const result = formatDate(oneDayAgo, 'relative');
        expect(result).toBe('1 day ago');
      });

      it('shows absolute date for old dates', () => {
        const oldDate = new Date(Date.now() - 35 * 24 * 60 * 60 * 1000); // 35 days ago
        const result = formatDate(oldDate, 'relative');
        expect(result).toMatch(/\d{1,2}\/\d{1,2}\/\d{4}/);
      });
    });
  });

describe('isValidEmail', () => {
    it('validates correct email addresses', () => {
      const validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'user+tag@example.org',
        'firstname.lastname@company.io',
        'a@b.co',
      ];

      validEmails.forEach(email => {
        expect(isValidEmail(email)).toBe(true);
      });
    });

    it('rejects invalid email addresses', () => {
      const invalidEmails = [
        '',
        'invalid',
        '@example.com',
        'user@',
        'user@domain',
        'user.domain.com',
        'user @example.com',
        'user@exam ple.com',
        'user@@example.com',
        'user@.com',
        '.user@example.com',
      ];

      invalidEmails.forEach(email => {
        expect(isValidEmail(email)).toBe(false);
      });
    });
  });

describe('isStrongPassword', () => {
    it('validates strong passwords', () => {
      const strongPasswords = [
        'Password123!',
        'MySecure#Pass1',
        'Strong@Pass9',
        'Complex&Password1',
        'Secure$123Pass',
      ];

      strongPasswords.forEach(password => {
        expect(isStrongPassword(password)).toBe(true);
      });
    });

    it('rejects weak passwords', () => {
      const weakPasswords = [
        '',
        'password',
        'PASSWORD',
        '12345678',
        'Password',
        'password123',
        'PASSWORD123',
        'Password!',
        'Pass12!', // Too short (7 characters)
        'password123!', // No uppercase
        'PASSWORD123!', // No lowercase
        'Password!', // No number
        'Password123', // No special character
      ];

      weakPasswords.forEach(password => {
        expect(isStrongPassword(password)).toBe(false);
      });
    });
  });

describe('capitalizeFirst', () => {
    it('capitalizes the first letter', () => {
      expect(capitalizeFirst('hello')).toBe('Hello');
      expect(capitalizeFirst('world')).toBe('World');
      expect(capitalizeFirst('test string')).toBe('Test string');
    });

    it('handles already capitalized strings', () => {
      expect(capitalizeFirst('Hello')).toBe('Hello');
      expect(capitalizeFirst('HELLO')).toBe('HELLO');
    });

    it('handles empty and edge cases', () => {
      expect(capitalizeFirst('')).toBe('');
      expect(capitalizeFirst('a')).toBe('A');
      expect(capitalizeFirst('1hello')).toBe('1hello');
    });

    it('handles non-alphabetic first characters', () => {
      expect(capitalizeFirst('123abc')).toBe('123abc');
      expect(capitalizeFirst('!hello')).toBe('!hello');
    });
  });

describe('truncate', () => {
    it('truncates long strings', () => {
      const longString = 'This is a very long string that should be truncated';
      const result = truncate(longString, 20);

      expect(result).toBe('This is a very long ...');
      expect(result.length).toBe(23); // 20 + '...'
    });

    it('returns original string if shorter than limit', () => {
      const shortString = 'Short';
      const result = truncate(shortString, 20);

      expect(result).toBe('Short');
    });

    it('handles exact length match', () => {
      const exactString = 'Exact';
      const result = truncate(exactString, 5);

      expect(result).toBe('Exact');
    });

    it('handles empty string', () => {
      expect(truncate('', 10)).toBe('');
    });

    it('handles zero length limit', () => {
      expect(truncate('hello', 0)).toBe('...');
    });
  });

describe('getErrorMessage', () => {
    it('extracts message from Error objects', () => {
      const error = new Error('Test error message');
      expect(getErrorMessage(error)).toBe('Test error message');
    });

    it('returns string errors directly', () => {
      expect(getErrorMessage('String error')).toBe('String error');
    });

    it('extracts message from objects with message property', () => {
      const errorObj = { message: 'Object error message' };
      expect(getErrorMessage(errorObj)).toBe('Object error message');
    });

    it('handles unknown error types', () => {
      expect(getErrorMessage(null)).toBe('An unknown error occurred');
      expect(getErrorMessage(undefined)).toBe('An unknown error occurred');
      expect(getErrorMessage(123)).toBe('An unknown error occurred');
      expect(getErrorMessage({})).toBe('An unknown error occurred');
    });

    it('handles nested error structures', () => {
      const complexError = {
        message: {
          toString: () => 'Nested error message'
        }
      };
      expect(getErrorMessage(complexError)).toBe('Nested error message');
    });
  });

describe('debounce', () => {
    it('delays function execution', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 100);

      debouncedFn('arg1', 'arg2');

      expect(mockFn).not.toHaveBeenCalled();

      jest.advanceTimersByTime(100);

      expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
      expect(mockFn).toHaveBeenCalledTimes(1);
    });

    it('cancels previous executions', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 100);

      debouncedFn('first');
      jest.advanceTimersByTime(50);

      debouncedFn('second');
      jest.advanceTimersByTime(50);

      expect(mockFn).not.toHaveBeenCalled();

      jest.advanceTimersByTime(50);

      expect(mockFn).toHaveBeenCalledWith('second');
      expect(mockFn).toHaveBeenCalledTimes(1);
    });

    it('preserves function context and arguments', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 100);

      debouncedFn(1, 'test', { prop: 'value' });

      jest.advanceTimersByTime(100);

      expect(mockFn).toHaveBeenCalledWith(1, 'test', { prop: 'value' });
    });

    it('handles multiple rapid calls', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 100);

      for (let i = 0; i < 5; i++) {
        debouncedFn(`call${i}`);
        jest.advanceTimersByTime(20);
      }

      expect(mockFn).not.toHaveBeenCalled();

      jest.advanceTimersByTime(100);

      expect(mockFn).toHaveBeenCalledWith('call4');
      expect(mockFn).toHaveBeenCalledTimes(1);
    });
  });

describe('localStorage utilities', () => {
    beforeEach(() => {
      global.window = mockWindow as Window & typeof globalThis;
      Object.defineProperty(global, 'localStorage', {
        value: mockLocalStorage,
        writable: true,
      });
    });

    afterEach(() => {
      global.window = originalWindow;
      if (originalWindow?.localStorage) {
        Object.defineProperty(global, 'localStorage', {
          value: originalWindow.localStorage,
          writable: true,
        });
      }
    });

describe('getLocalStorageItem', () => {
      it('retrieves item from localStorage', () => {
        mockLocalStorage.getItem.mockReturnValue('stored value');

        const result = getLocalStorageItem('test-key');

        expect(result).toBe('stored value');
        expect(mockLocalStorage.getItem).toHaveBeenCalledWith('test-key');
      });

      it('returns null when item does not exist', () => {
        mockLocalStorage.getItem.mockReturnValue(null);

        const result = getLocalStorageItem('nonexistent');

        expect(result).toBeNull();
      });

      it('handles localStorage errors gracefully', () => {
        mockLocalStorage.getItem.mockImplementation(() => {
          throw new Error('localStorage not available');
        });

        const result = getLocalStorageItem('test-key');

        expect(result).toBeNull();
      });

      it('returns null in SSR environment', () => {
        delete (global as { window?: Window }).window;

        const result = getLocalStorageItem('test-key');

        expect(result).toBeNull();
      });
    });

describe('setLocalStorageItem', () => {
      it('stores item in localStorage', () => {
        const success = setLocalStorageItem('test-key', 'test-value');

        expect(success).toBe(true);
        expect(mockLocalStorage.setItem).toHaveBeenCalledWith('test-key', 'test-value');
      });

      it('handles localStorage errors gracefully', () => {
        mockLocalStorage.setItem.mockImplementation(() => {
          throw new Error('localStorage quota exceeded');
        });

        const success = setLocalStorageItem('test-key', 'test-value');

        expect(success).toBe(false);
      });

      it('returns false in SSR environment', () => {
        delete (global as { window?: Window }).window;

        const success = setLocalStorageItem('test-key', 'test-value');

        expect(success).toBe(false);
      });
    });

describe('removeLocalStorageItem', () => {
      it('removes item from localStorage', () => {
        const success = removeLocalStorageItem('test-key');

        expect(success).toBe(true);
        expect(mockLocalStorage.removeItem).toHaveBeenCalledWith('test-key');
      });

      it('handles localStorage errors gracefully', () => {
        mockLocalStorage.removeItem.mockImplementation(() => {
          throw new Error('localStorage not available');
        });

        const success = removeLocalStorageItem('test-key');

        expect(success).toBe(false);
      });

      it('returns false in SSR environment', () => {
        delete (global as { window?: Window }).window;

        const success = removeLocalStorageItem('test-key');

        expect(success).toBe(false);
      });
    });
  });

describe('createSearchParams', () => {
    it('creates URL search params from object', () => {
      const params = {
        page: 1,
        limit: 10,
        search: 'test query',
        active: true,
      };

      const result = createSearchParams(params);

      expect(result).toContain('page=1');
      expect(result).toContain('limit=10');
      expect(result).toContain('search=test+query');
      expect(result).toContain('active=true');
    });

    it('handles special characters in values', () => {
      const params = {
        query: 'test & special chars!',
        email: 'user@example.com',
      };

      const result = createSearchParams(params);

      expect(result).toContain('query=');
      expect(result).toContain('email=');
    });

    it('filters out undefined, null, and empty values', () => {
      const params = {
        valid: 'value',
        undefined: undefined,
        null: null,
        empty: '',
        zero: 0,
        false: false,
      };

      const result = createSearchParams(params);

      expect(result).toContain('valid=value');
      expect(result).toContain('zero=0');
      expect(result).toContain('false=false');
      expect(result).not.toContain('undefined');
      expect(result).not.toContain('null');
      expect(result).not.toContain('empty');
    });

    it('handles empty object', () => {
      const result = createSearchParams({});
      expect(result).toBe('');
    });

    it('converts numbers and booleans to strings', () => {
      const params = {
        num: 42,
        bool: true,
        str: 'string',
      };

      const result = createSearchParams(params);

      expect(result).toContain('num=42');
      expect(result).toContain('bool=true');
      expect(result).toContain('str=string');
    });
  });

describe('Type Guards', () => {
    describe('isNotNull', () => {
      it('returns true for non-null values', () => {
        expect(isNotNull('string')).toBe(true);
        expect(isNotNull(0)).toBe(true);
        expect(isNotNull(false)).toBe(true);
        expect(isNotNull({})).toBe(true);
        expect(isNotNull([])).toBe(true);
        expect(isNotNull(undefined)).toBe(true);
      });

      it('returns false for null values', () => {
        expect(isNotNull(null)).toBe(false);
      });

      it('provides proper type narrowing', () => {
        const value: string | null = 'test';

        if (isNotNull(value)) {
          // TypeScript should know value is string here
          expect(value.toUpperCase()).toBe('TEST');
        }
      });

      it('works with arrays and filtering', () => {
        const values = ['a', null, 'b', null, 'c'];
        const filtered = values.filter(isNotNull);

        expect(filtered).toEqual(['a', 'b', 'c']);
        // TypeScript should know filtered is string[] here
        expect(filtered.every(v => typeof v === 'string')).toBe(true);
      });
    });

describe('isNotUndefined', () => {
      it('returns true for defined values', () => {
        expect(isNotUndefined('string')).toBe(true);
        expect(isNotUndefined(0)).toBe(true);
        expect(isNotUndefined(false)).toBe(true);
        expect(isNotUndefined({})).toBe(true);
        expect(isNotUndefined([])).toBe(true);
        expect(isNotUndefined(null)).toBe(true);
      });

      it('returns false for undefined values', () => {
        expect(isNotUndefined(undefined)).toBe(false);
      });

      it('provides proper type narrowing', () => {
        const value: string | undefined = 'test';

        if (isNotUndefined(value)) {
          // TypeScript should know value is string here
          expect(value.toUpperCase()).toBe('TEST');
        }
      });

      it('works with arrays and filtering', () => {
        const values = ['a', undefined, 'b', undefined, 'c'];
        const filtered = values.filter(isNotUndefined);

        expect(filtered).toEqual(['a', 'b', 'c']);
        // TypeScript should know filtered is string[] here
        expect(filtered.every(v => typeof v === 'string')).toBe(true);
      });
    });
  });

describe('Edge Cases and Error Handling', () => {
    it('handles extremely large inputs gracefully', () => {
      const largeString = 'a'.repeat(10000);

      expect(() => truncate(largeString, 100)).not.toThrow();
      expect(() => capitalizeFirst(largeString)).not.toThrow();
      expect(() => isValidEmail(largeString)).not.toThrow();
    });

    it('handles special Unicode characters', () => {
      const unicodeString = 'Héllo Wörld 🌍';

      expect(capitalizeFirst(unicodeString.toLowerCase())).toBe('Héllo wörld 🌍');
      expect(truncate(unicodeString, 10)).toBe('Héllo Wörl...');
    });

    it('handles extremely small debounce delays', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 1);

      debouncedFn('test');

      jest.advanceTimersByTime(1);

      expect(mockFn).toHaveBeenCalledWith('test');
    });

    it('handles very large debounce delays', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 1000000);

      debouncedFn('test');

      jest.advanceTimersByTime(999999);
      expect(mockFn).not.toHaveBeenCalled();

      jest.advanceTimersByTime(1);
      expect(mockFn).toHaveBeenCalledWith('test');
    });

    it('handles invalid date objects', () => {
      const invalidDate = new Date('invalid');

      expect(() => formatDate(invalidDate)).not.toThrow();
      const result = formatDate(invalidDate);
      expect(result).toContain('Invalid Date');
    });
  });
});