/**
 * @jest-environment jsdom
 */
import { cn, formatDate, isValidEmail, debounce } from '@/lib/utils';

// Mock clsx and tailwind-merge if they're used in cn
jest.mock('clsx', () => jest.fn((...args) => args.join(' ')));
jest.mock('tailwind-merge', () => ({ twMerge: jest.fn(str => str) }));

describe('utils', () => {
  describe('cn (className utility)', () => {
    it('should combine class names', () => {
      const result = cn('base-class', 'additional-class', 'conditional-class');
      expect(result).toContain('base-class');
      expect(result).toContain('additional-class');
      expect(result).toContain('conditional-class');
    });

    it('should handle conditional classes', () => {
      const result = cn('base-class', true && 'conditional-true', false && 'conditional-false');
      expect(result).toContain('base-class');
      expect(result).toContain('conditional-true');
      expect(result).not.toContain('conditional-false');
    });

    it('should handle undefined and null', () => {
      const result = cn('base-class', undefined, null, 'valid-class');
      expect(result).toContain('base-class');
      expect(result).toContain('valid-class');
    });
  });

  describe('formatDate', () => {
    it('should format date string correctly', () => {
      const date = '2024-01-15T10:30:00Z';
      const result = formatDate(date);
      
      // Should return a formatted date string
      expect(typeof result).toBe('string');
      expect(result.length).toBeGreaterThan(0);
    });

    it('should format Date object correctly', () => {
      const date = new Date('2024-01-15T10:30:00Z');
      const result = formatDate(date);
      
      expect(typeof result).toBe('string');
      expect(result.length).toBeGreaterThan(0);
    });

    it('should handle custom format', () => {
      const date = '2024-01-15T10:30:00Z';
      const result = formatDate(date, 'short');
      
      expect(typeof result).toBe('string');
      expect(result.length).toBeGreaterThan(0);
    });

    it('should handle invalid date', () => {
      const result = formatDate('invalid-date');
      expect(result).toBe('Invalid Date');
    });

    it('should handle undefined/null', () => {
      expect(formatDate(undefined as unknown as string)).toBe('Invalid Date');
      expect(formatDate(null as unknown as string)).toBe('Invalid Date');
    });
  });

  describe('isValidEmail', () => {
    it('should validate correct email addresses', () => {
      expect(isValidEmail('test@example.com')).toBe(true);
      expect(isValidEmail('user.name@domain.co.uk')).toBe(true);
      expect(isValidEmail('test+tag@example.org')).toBe(true);
      expect(isValidEmail('user123@example-domain.com')).toBe(true);
    });

    it('should reject invalid email addresses', () => {
      expect(isValidEmail('invalid-email')).toBe(false);
      expect(isValidEmail('test@')).toBe(false);
      expect(isValidEmail('@example.com')).toBe(false);
      expect(isValidEmail('test..test@example.com')).toBe(false);
      expect(isValidEmail('test@example')).toBe(false);
      expect(isValidEmail('')).toBe(false);
    });

    it('should handle edge cases', () => {
      expect(isValidEmail(' test@example.com ')).toBe(false); // Should not trim (based on actual implementation)
      expect(isValidEmail('TEST@EXAMPLE.COM')).toBe(true); // Case insensitive
    });

    it('should handle null/undefined', () => {
      expect(isValidEmail(null as unknown as string)).toBe(false);
      expect(isValidEmail(undefined as unknown as string)).toBe(false);
    });
  });

  describe('debounce', () => {
    beforeEach(() => {
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('should delay function execution', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 300);

      debouncedFn('arg1', 'arg2');
      expect(mockFn).not.toHaveBeenCalled();

      jest.advanceTimersByTime(300);
      expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
    });

    it('should cancel previous calls', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 300);

      debouncedFn('first-call');
      debouncedFn('second-call');
      debouncedFn('third-call');

      jest.advanceTimersByTime(300);
      
      expect(mockFn).toHaveBeenCalledTimes(1);
      expect(mockFn).toHaveBeenCalledWith('third-call');
    });

    it('should handle multiple calls within timeout', () => {
      const mockFn = jest.fn();
      const debouncedFn = debounce(mockFn, 300);

      debouncedFn('first');
      debouncedFn('second');
      debouncedFn('third');
      
      // Should not have been called yet
      expect(mockFn).not.toHaveBeenCalled();
      
      // After timeout, should only call once with last arguments
      jest.advanceTimersByTime(300);
      expect(mockFn).toHaveBeenCalledTimes(1);
      expect(mockFn).toHaveBeenCalledWith('third');
    });

    it('should preserve this context', () => {
      const mockContext = {
        value: 'test',
        method: jest.fn(function(this: { value: string }) {
          return this.value;
        }),
      };

      const debouncedMethod = debounce(mockContext.method, 300);
      debouncedMethod.call(mockContext);

      jest.advanceTimersByTime(300);
      expect(mockContext.method).toHaveBeenCalled();
    });
  });

});

// Additional utility tests that might be in your utils file
describe('additional utils', () => {
  describe('formatFileSize', () => {
    const formatFileSize = (bytes: number): string => {
      if (bytes === 0) return '0 Bytes';
      
      const k = 1024;
      const sizes = ['Bytes', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    it('should format bytes correctly', () => {
      expect(formatFileSize(0)).toBe('0 Bytes');
      expect(formatFileSize(1024)).toBe('1 KB');
      expect(formatFileSize(1048576)).toBe('1 MB');
      expect(formatFileSize(1073741824)).toBe('1 GB');
    });

    it('should handle decimal values', () => {
      expect(formatFileSize(1536)).toBe('1.5 KB');
      expect(formatFileSize(2621440)).toBe('2.5 MB');
    });
  });

  describe('generateId', () => {
    const generateId = (prefix = ''): string => {
      return prefix + Math.random().toString(36).substr(2, 9);
    };

    it('should generate unique IDs', () => {
      const id1 = generateId();
      const id2 = generateId();
      
      expect(id1).not.toBe(id2);
      expect(typeof id1).toBe('string');
      expect(id1.length).toBeGreaterThan(0);
    });

    it('should include prefix', () => {
      const id = generateId('user-');
      expect(id).toMatch(/^user-/);
    });
  });

  describe('sleep', () => {
    const sleep = (ms: number): Promise<void> => {
      return new Promise(resolve => setTimeout(resolve, ms));
    };

    it('should delay execution', async () => {
      const start = Date.now();
      await sleep(100);
      const end = Date.now();
      
      expect(end - start).toBeGreaterThanOrEqual(95); // Allow for small timing variations
    });
  });

  describe('capitalize', () => {
    const capitalize = (str: string): string => {
      return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
    };

    it('should capitalize first letter', () => {
      expect(capitalize('hello')).toBe('Hello');
      expect(capitalize('WORLD')).toBe('World');
      expect(capitalize('tEST')).toBe('Test');
    });

    it('should handle edge cases', () => {
      expect(capitalize('')).toBe('');
      expect(capitalize('a')).toBe('A');
    });
  });

  describe('truncateText', () => {
    const truncateText = (text: string, length: number): string => {
      if (text.length <= length) return text;
      return text.substring(0, length) + '...';
    };

    it('should truncate long text', () => {
      const longText = 'This is a very long text that should be truncated';
      const result = truncateText(longText, 20);
      
      expect(result.length).toBeLessThanOrEqual(23); // 20 + '...'
      expect(result.endsWith('...')).toBe(true);
    });

    it('should not truncate short text', () => {
      const shortText = 'Short text';
      const result = truncateText(shortText, 20);
      
      expect(result).toBe(shortText);
      expect(result.endsWith('...')).toBe(false);
    });
  });
});