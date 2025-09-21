
import React from 'react';
import { render, screen } from '@testing-library/react';
import { PasswordStrengthIndicator } from '@/components/auth/password-strength-indicator';
import * as passwordStrengthHooks from '@/hooks/use-password-strength';


jest.mock('@/hooks/use-password-strength', () => ({
  usePasswordStrength: jest.fn(),
  getStrengthColor: jest.fn((strength: string) => {
    const colors: Record<string, string> = {
      'very-weak': 'text-red-500',
      'weak': 'text-orange-500',
      'fair': 'text-yellow-500',
      'good': 'text-blue-500',
      'strong': 'text-green-500',
    };
    return colors[strength] || 'text-gray-500';
  }),
  getStrengthBarColor: jest.fn((strength: string) => {
    const colors: Record<string, string> = {
      'very-weak': 'bg-red-500',
      'weak': 'bg-orange-500',
      'fair': 'bg-yellow-500',
      'good': 'bg-blue-500',
      'strong': 'bg-green-500',
    };
    return colors[strength] || 'bg-gray-500';
  }),
  getStrengthLabel: jest.fn((strength: string) => {
    const labels: Record<string, string> = {
      'very-weak': 'Very Weak',
      'weak': 'Weak',
      'fair': 'Fair',
      'good': 'Good',
      'strong': 'Strong',
    };
    return labels[strength] || 'Unknown';
  }),}));
/**
 * Comprehensive test suite for PasswordStrengthIndicator component
 * Tests password strength visualization and criteria checking
 */


describe('PasswordStrengthIndicator Component', () => {
  // Mock the password strength hook
  const mockUsePasswordStrength = passwordStrengthHooks.usePasswordStrength as jest.MockedFunction<
    typeof passwordStrengthHooks.usePasswordStrength
  >;
  const defaultPasswordStrength: passwordStrengthHooks.PasswordStrengthResult = {
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
    feedback: [],
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockUsePasswordStrength.mockReturnValue(defaultPasswordStrength);
  });

describe('Basic Rendering', () => {
    it('should render nothing when password is empty', () => {
      const { container } = render(<PasswordStrengthIndicator password="" />);
      expect(container.firstChild).toBeEmptyDOMElement();
    });
    it('should render strength indicator when password is provided', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 2,
        strength: 'weak'
      });
      render(<PasswordStrengthIndicator password="test123" />);
      expect(screen.getByText('Weak')).toBeInTheDocument();
    });
    it('should accept custom className', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 1,
        strength: 'very-weak'
      });
      const { container } = render(
        <PasswordStrengthIndicator password="test" className="custom-class" />
      );
      const mainDiv = container.querySelector('.custom-class');
      expect(mainDiv).toBeInTheDocument();
    });
  });

describe('Strength Bar Display', () => {
    it('should render 5 strength segments', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 3,
        strength: 'fair'
      });
      const { container } = render(<PasswordStrengthIndicator password="Test123!" />);
      // Find all strength bar segments
      const segments = container.querySelectorAll('.h-2.flex-1.rounded-full');
      expect(segments).toHaveLength(5);
    });
    it('should highlight correct number of segments based on score', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 3,
        strength: 'fair'
      });
      const { container } = render(<PasswordStrengthIndicator password="Test123!" />);
      const activeSegments = container.querySelectorAll('.bg-yellow-500');
      const inactiveSegments = container.querySelectorAll('.bg-muted');
      expect(activeSegments).toHaveLength(3);
      expect(inactiveSegments).toHaveLength(2);
    });
    it('should display all segments as active for strong password', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 5,
        strength: 'strong'
      });
      const { container } = render(<PasswordStrengthIndicator password="Test123!@#" />);
      const activeSegments = container.querySelectorAll('.bg-green-500');
      expect(activeSegments).toHaveLength(5);
    });
    it('should display correct strength label', () => {
      const testCases = [
        { strength: 'very-weak' as const, label: 'Very Weak' },
        { strength: 'weak' as const, label: 'Weak' },
        { strength: 'fair' as const, label: 'Fair' },
        { strength: 'good' as const, label: 'Good' },
        { strength: 'strong' as const, label: 'Strong' },
      ];
      testCases.forEach(({ strength, label }) => {
        mockUsePasswordStrength.mockReturnValue({
          ...defaultPasswordStrength,
          strength
        });
        const { rerender } = render(
          <PasswordStrengthIndicator password={`test${strength}`} />
        );
        expect(screen.getByText(label)).toBeInTheDocument();
        rerender(<PasswordStrengthIndicator password="" />);
      });
    });
  });

describe('Criteria Display', () => {
    it('should display all criteria when showDetails is true', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        criteria: {
          minLength: false,
          hasUpperCase: false,
          hasLowerCase: false,
          hasNumber: false,
          hasSpecialChar: false,
        }
      });
      render(<PasswordStrengthIndicator password="test" showDetails={true} />);
      expect(screen.getByText('Password requirements:')).toBeInTheDocument();
      expect(screen.getByText('At least 8 characters')).toBeInTheDocument();
      expect(screen.getByText('One uppercase letter')).toBeInTheDocument();
      expect(screen.getByText('One lowercase letter')).toBeInTheDocument();
      expect(screen.getByText('One number')).toBeInTheDocument();
      expect(screen.getByText('One special character (@$!%*?&)')).toBeInTheDocument();
    });
    it('should not display criteria when showDetails is false', () => {
      mockUsePasswordStrength.mockReturnValue(defaultPasswordStrength);
      render(<PasswordStrengthIndicator password="test" showDetails={false} />);
      expect(screen.queryByText('Password requirements:')).not.toBeInTheDocument();
      expect(screen.queryByText('At least 8 characters')).not.toBeInTheDocument();
    });
    it('should show checkmarks for met criteria', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        criteria: {
          minLength: true,
          hasUpperCase: true,
          hasLowerCase: false,
          hasNumber: false,
          hasSpecialChar: false,
        }
      });
      const { container } = render(<PasswordStrengthIndicator password="TestTest" />);
      // Check for checkmark icons (using the Check component from lucide-react)
      const checkmarks = container.querySelectorAll('.text-green-600');
      expect(checkmarks.length).toBeGreaterThan(0);
    });
    it('should show empty circles for unmet criteria', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        criteria: {
          minLength: false,
          hasUpperCase: false,
          hasLowerCase: true,
          hasNumber: true,
          hasSpecialChar: false,
        }
      });
      const { container } = render(<PasswordStrengthIndicator password="test123" />);
      // Check for empty circle indicators
      const emptyCircles = container.querySelectorAll('.rounded-full.border.border-muted-foreground');
      expect(emptyCircles.length).toBeGreaterThan(0);
    });
  });

describe('Feedback Display', () => {
    it('should display feedback messages when available', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        feedback: [
          'Password must be at least 8 characters long',
          'Add at least one uppercase letter',
          'Add at least one number',
        ]
      });
      render(<PasswordStrengthIndicator password="test" showDetails={true} />);
      expect(screen.getByText('Password must be at least 8 characters long')).toBeInTheDocument();
      expect(screen.getByText('Add at least one uppercase letter')).toBeInTheDocument();
      expect(screen.getByText('Add at least one number')).toBeInTheDocument();
    });
    it('should limit feedback messages to 3', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        feedback: [
          'Feedback 1',
          'Feedback 2',
          'Feedback 3',
          'Feedback 4',
          'Feedback 5',
        ]
      });
      render(<PasswordStrengthIndicator password="test" showDetails={true} />);
      expect(screen.getByText('Feedback 1')).toBeInTheDocument();
      expect(screen.getByText('Feedback 2')).toBeInTheDocument();
      expect(screen.getByText('Feedback 3')).toBeInTheDocument();
      expect(screen.queryByText('Feedback 4')).not.toBeInTheDocument();
      expect(screen.queryByText('Feedback 5')).not.toBeInTheDocument();
    });
    it('should not display feedback when showDetails is false', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        feedback: ['Password must be at least 8 characters long']
      });
      render(<PasswordStrengthIndicator password="test" showDetails={false} />);
      expect(
        screen.queryByText('Password must be at least 8 characters long')
      ).not.toBeInTheDocument();
    });
    it('should display X icons next to feedback messages', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        feedback: ['Password must be at least 8 characters long']
      });
      const { container } = render(<PasswordStrengthIndicator password="test" showDetails={true} />);
      // Check for X icon (using the X component from lucide-react)
      const xIcons = container.querySelectorAll('.text-destructive');
      expect(xIcons.length).toBeGreaterThan(0);
    });
  });

describe('Different Password Scenarios', () => {
    it('should handle very weak password correctly', () => {
      mockUsePasswordStrength.mockReturnValue({
        score: 1,
        strength: 'very-weak',
        criteria: {
          minLength: false,
          hasUpperCase: false,
          hasLowerCase: true,
          hasNumber: false,
          hasSpecialChar: false,
        },
        isValid: false,
        feedback: [
          'Password must be at least 8 characters long',
          'Add at least one uppercase letter',
          'Add at least one number',
          'Add at least one special character (@$!%*?&)',
        ]
      });
      render(<PasswordStrengthIndicator password="test" />);
      expect(screen.getByText('Very Weak')).toBeInTheDocument();
      expect(passwordStrengthHooks.getStrengthColor).toHaveBeenCalledWith('very-weak');
      expect(passwordStrengthHooks.getStrengthBarColor).toHaveBeenCalledWith('very-weak');
    });
    it('should handle strong password correctly', () => {
      mockUsePasswordStrength.mockReturnValue({
        score: 5,
        strength: 'strong',
        criteria: {
          minLength: true,
          hasUpperCase: true,
          hasLowerCase: true,
          hasNumber: true,
          hasSpecialChar: true,
        },
        isValid: true,
        feedback: []
      });
      render(<PasswordStrengthIndicator password="Test123!@#" />);
      expect(screen.getByText('Strong')).toBeInTheDocument();
      expect(passwordStrengthHooks.getStrengthColor).toHaveBeenCalledWith('strong');
      expect(passwordStrengthHooks.getStrengthBarColor).toHaveBeenCalledWith('strong');
    });
    it('should handle medium strength password correctly', () => {
      mockUsePasswordStrength.mockReturnValue({
        score: 3,
        strength: 'fair',
        criteria: {
          minLength: true,
          hasUpperCase: true,
          hasLowerCase: true,
          hasNumber: false,
          hasSpecialChar: false,
        },
        isValid: false,
        feedback: [
          'Add at least one number',
          'Add at least one special character (@$!%*?&)',
        ]
      });
      render(<PasswordStrengthIndicator password="TestTest" />);
      expect(screen.getByText('Fair')).toBeInTheDocument();
    });
  });

describe('Integration with Password Hook', () => {
    it('should call usePasswordStrength with the provided password', () => {
      render(<PasswordStrengthIndicator password="myPassword123" />);
      expect(mockUsePasswordStrength).toHaveBeenCalledWith('myPassword123');
    });
    it('should re-render when password changes', () => {
      const { rerender } = render(<PasswordStrengthIndicator password="test1" />);
      expect(mockUsePasswordStrength).toHaveBeenCalledWith('test1');
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 3,
        strength: 'fair'
      });
      rerender(<PasswordStrengthIndicator password="Test123" />);
      expect(mockUsePasswordStrength).toHaveBeenCalledWith('Test123');
      expect(screen.getByText('Fair')).toBeInTheDocument();
    });
  });

describe('Accessibility', () => {
    it('should have appropriate text hierarchy', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        score: 2,
        strength: 'weak',
        feedback: ['Add more characters']
      });
      render(<PasswordStrengthIndicator password="test" />);
      // Check for text size classes
      const smallText = document.querySelectorAll('.text-xs');
      const mediumText = document.querySelectorAll('.text-sm');
      expect(smallText.length).toBeGreaterThan(0);
      expect(mediumText.length).toBeGreaterThan(0);
    });
    it('should use semantic colors for feedback', () => {
      mockUsePasswordStrength.mockReturnValue({
        ...defaultPasswordStrength,
        criteria: {
          minLength: true,
          hasUpperCase: false,
          hasLowerCase: true,
          hasNumber: false,
          hasSpecialChar: false,
        }
      });
      const { container } = render(<PasswordStrengthIndicator password="testtest" />);
      // Met criteria should use success color
      const successElements = container.querySelectorAll('.text-green-600');
      expect(successElements.length).toBeGreaterThan(0);
      // Unmet criteria should use muted color
      const mutedElements = container.querySelectorAll('.text-muted-foreground');
      expect(mutedElements.length).toBeGreaterThan(0);
    });
  });
});
}}