
import { renderHook, act } from '@testing-library/react';
import React from 'react';


/**
 * @jest-environment jsdom
 */
import {
  usePasswordStrength,
  getStrengthColor,
  getStrengthBarColor,
  getStrengthLabel
} from '@/hooks/use-password-strength';
describe('usePasswordStrength', () => {
  describe('Empty password', () => {
    it('should return very weak strength for empty password', () => {
      const { result } = renderHook(() => usePasswordStrength(''));

      expect(result.current).toEqual({
        score: 0,
        strength: 'very-weak',
        criteria: {
          minLength: false,
          hasUpperCase: false,
          hasLowerCase: false,
          hasNumber: false,
          hasSpecialChar: false,
        },
        isValid: false,
        feedback: ['Password is required']
      });
    });
  });

describe('Criteria validation', () => {
    it('should check minimum length', () => {
      const { result: shortResult } = renderHook(() => usePasswordStrength('abc'));
      expect(shortResult.current.criteria.minLength).toBe(false);

      const { result: validResult } = renderHook(() => usePasswordStrength('abcdefgh'));
      expect(validResult.current.criteria.minLength).toBe(true);
    });

    it('should check uppercase letters', () => {
      const { result: noUpperResult } = renderHook(() => usePasswordStrength('abcdefgh'));
      expect(noUpperResult.current.criteria.hasUpperCase).toBe(false);

      const { result: hasUpperResult } = renderHook(() => usePasswordStrength('Abcdefgh'));
      expect(hasUpperResult.current.criteria.hasUpperCase).toBe(true);
    });

    it('should check lowercase letters', () => {
      const { result: noLowerResult } = renderHook(() => usePasswordStrength('ABCDEFGH'));
      expect(noLowerResult.current.criteria.hasLowerCase).toBe(false);

      const { result: hasLowerResult } = renderHook(() => usePasswordStrength('ABCDEFGh'));
      expect(hasLowerResult.current.criteria.hasLowerCase).toBe(true);
    });

    it('should check numbers', () => {
      const { result: noNumberResult } = renderHook(() => usePasswordStrength('Abcdefgh'));
      expect(noNumberResult.current.criteria.hasNumber).toBe(false);

      const { result: hasNumberResult } = renderHook(() => usePasswordStrength('Abcdefg1'));
      expect(hasNumberResult.current.criteria.hasNumber).toBe(true);
    });

    it('should check special characters', () => {
      const { result: noSpecialResult } = renderHook(() => usePasswordStrength('Abcdefg1'));
      expect(noSpecialResult.current.criteria.hasSpecialChar).toBe(false);

      const { result: hasSpecialResult } = renderHook(() => usePasswordStrength('Abcdefg1!'));
      expect(hasSpecialResult.current.criteria.hasSpecialChar).toBe(true);
    });
  });

describe('Strength scoring', () => {
    it('should score 0 for no criteria met', () => {
      const { result } = renderHook(() => usePasswordStrength('a'));
      expect(result.current.score).toBe(1); // has lowercase
      expect(result.current.strength).toBe('very-weak');
    });

    it('should score 1 for one criterion met', () => {
      const { result } = renderHook(() => usePasswordStrength('abcdefgh'));
      expect(result.current.score).toBe(2); // minLength + hasLowerCase
      expect(result.current.strength).toBe('weak');
    });

    it('should score 2 for weak password', () => {
      const { result } = renderHook(() => usePasswordStrength('abc'));
      expect(result.current.score).toBe(1); // Only hasLowerCase
      expect(result.current.strength).toBe('very-weak');
    });

    it('should score 3 for fair password', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefgh'));
      expect(result.current.score).toBe(3); // minLength + hasUpperCase + hasLowerCase
      expect(result.current.strength).toBe('fair');
    });

    it('should score 4 for good password', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefg1'));
      expect(result.current.score).toBe(4); // minLength + hasUpperCase + hasLowerCase + hasNumber
      expect(result.current.strength).toBe('good');
    });

    it('should score 5 for strong password', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefg1!'));
      expect(result.current.score).toBe(5); // All criteria met
      expect(result.current.strength).toBe('strong');
      expect(result.current.isValid).toBe(true);
    });
  });

describe('Feedback generation', () => {
    it('should provide feedback for missing criteria', () => {
      const { result } = renderHook(() => usePasswordStrength('abc'));

      expect(result.current.feedback).toContain('Password must be at least 8 characters long');
      expect(result.current.feedback).toContain('Add at least one uppercase letter');
      expect(result.current.feedback).toContain('Add at least one number');
      expect(result.current.feedback).toContain('Add at least one special character (@$!%*?&)');
    });

    it('should suggest longer password for better security', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefg1'));
      expect(result.current.feedback).toContain('Consider using a longer password for better security');
    });

    it('should have no feedback for strong password', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefghijk1!'));
      expect(result.current.feedback).toHaveLength(0);
    });
  });

describe('Validation', () => {
    it('should be invalid when not all criteria are met', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefg1'));
      expect(result.current.isValid).toBe(false);
    });

    it('should be valid when all criteria are met', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcdefg1!'));
      expect(result.current.isValid).toBe(true);
    });
  });

describe('Memoization', () => {
    it('should memoize result for same password', () => {
      const { result, rerender } = renderHook(
        ({ password }) => usePasswordStrength(password),
        { initialProps: { password: 'Abcdefg1!' } }
      );

      const firstResult = result.current;

      rerender({ password: 'Abcdefg1!' });

      expect(result.current).toBe(firstResult);
    });

    it('should recalculate for different password', () => {
      const { result, rerender } = renderHook(
        ({ password }) => usePasswordStrength(password),
        { initialProps: { password: 'Abcdefg1!' } }
      );

      const firstResult = result.current;

      rerender({ password: 'Different1!' });

      expect(result.current).not.toBe(firstResult);
      expect(result.current.strength).toBe('strong'); // Different1! has all criteria
    });
  });

describe('Edge cases', () => {
    it('should handle passwords with only special characters', () => {
      const { result } = renderHook(() => usePasswordStrength('@$!%*?&'));
      expect(result.current.score).toBe(1);
      expect(result.current.criteria.hasSpecialChar).toBe(true);
    });

    it('should handle very long passwords', () => {
      const longPassword = 'A'.repeat(100) + 'a1!';
      const { result } = renderHook(() => usePasswordStrength(longPassword));
      expect(result.current.score).toBe(5);
      expect(result.current.strength).toBe('strong');
    });

    it('should handle passwords with unicode characters', () => {
      const { result } = renderHook(() => usePasswordStrength('Abcd1!你好'));
      expect(result.current.score).toBe(5);
    });

    it('should handle passwords with spaces', () => {
      const { result } = renderHook(() => usePasswordStrength('Abc def 1!'));
      expect(result.current.score).toBe(5);
    });
  });
});

describe('Helper functions', () => {
  describe('getStrengthColor', () => {
    it('should return correct colors for each strength level', () => {
      expect(getStrengthColor('very-weak')).toBe('text-red-600');
      expect(getStrengthColor('weak')).toBe('text-red-500');
      expect(getStrengthColor('fair')).toBe('text-yellow-500');
      expect(getStrengthColor('good')).toBe('text-blue-500');
      expect(getStrengthColor('strong')).toBe('text-green-500');
      expect(getStrengthColor('unknown' as jest.Mocked<any>)).toBe('text-gray-500');
    });
  });

describe('getStrengthBarColor', () => {
    it('should return correct bar colors for each strength level', () => {
      expect(getStrengthBarColor('very-weak')).toBe('bg-red-600');
      expect(getStrengthBarColor('weak')).toBe('bg-red-500');
      expect(getStrengthBarColor('fair')).toBe('bg-yellow-500');
      expect(getStrengthBarColor('good')).toBe('bg-blue-500');
      expect(getStrengthBarColor('strong')).toBe('bg-green-500');
      expect(getStrengthBarColor('unknown' as jest.Mocked<any>)).toBe('bg-gray-300');
    });
  });

describe('getStrengthLabel', () => {
    it('should return correct labels for each strength level', () => {
      expect(getStrengthLabel('very-weak')).toBe('Very Weak');
      expect(getStrengthLabel('weak')).toBe('Weak');
      expect(getStrengthLabel('fair')).toBe('Fair');
      expect(getStrengthLabel('good')).toBe('Good');
      expect(getStrengthLabel('strong')).toBe('Strong');
      expect(getStrengthLabel('unknown' as jest.Mocked<any>)).toBe('Unknown');
    });
  });
});

describe('Real-world password examples', () => {
  const testCases = [
    { password: '123456', expectedStrength: 'very-weak', expectedScore: 1 },
    { password: 'password', expectedStrength: 'weak', expectedScore: 2 },
    { password: 'Password', expectedStrength: 'fair', expectedScore: 3 },
    { password: 'Password1', expectedStrength: 'good', expectedScore: 4 },
    { password: 'Password1!', expectedStrength: 'strong', expectedScore: 5 },
    { password: 'P@ssw0rd', expectedStrength: 'strong', expectedScore: 5 },
    { password: 'P@ssw0rd!', expectedStrength: 'strong', expectedScore: 5 },
    { password: 'MyP@ssw0rd!', expectedStrength: 'strong', expectedScore: 5 },
    { password: 'abc123', expectedStrength: 'weak', expectedScore: 2 },
    { password: 'ABC123', expectedStrength: 'weak', expectedScore: 2 },
    { password: 'Aa1!', expectedStrength: 'good', expectedScore: 4 },
    { password: 'Aa1!Aa1!', expectedStrength: 'strong', expectedScore: 5 },
  ];

  testCases.forEach(({ password, expectedStrength, expectedScore }) => {
    it(`should evaluate "${password}" as ${expectedStrength} with score ${expectedScore}`, () => {
      const { result } = renderHook(() => usePasswordStrength(password));
      expect(result.current.strength).toBe(expectedStrength);
      expect(result.current.score).toBe(expectedScore);
    });
  });
});