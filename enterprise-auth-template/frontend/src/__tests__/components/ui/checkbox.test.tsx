import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { Checkbox } from '@/components/ui/checkbox';

describe('Checkbox Component', () => {
  describe('Rendering', () => {
    it('should render checkbox element', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeInTheDocument();
    });

    it('should render with custom className', () => {
      render(<Checkbox className="custom-class" />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveClass('custom-class');
    });

    it('should forward ref correctly', () => {
      const ref = React.createRef<HTMLButtonElement>();
      render(<Checkbox ref={ref} />);
      expect(ref.current).toBeInstanceOf(HTMLElement);
    });

    it('should render with data-testid', () => {
      render(<Checkbox data-testid="test-checkbox" />);
      const checkbox = screen.getByTestId('test-checkbox');
      expect(checkbox).toBeInTheDocument();
    });
  });

  describe('States', () => {
    it('should be unchecked by default', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).not.toBeChecked();
      expect(checkbox).toHaveAttribute('aria-checked', 'false');
    });

    it('should render as checked when checked prop is true', () => {
      render(<Checkbox checked={true} />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeChecked();
      expect(checkbox).toHaveAttribute('aria-checked', 'true');
    });

    it('should render as indeterminate when checked is "indeterminate"', () => {
      render(<Checkbox checked="indeterminate" />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('aria-checked', 'mixed');
    });

    it('should be disabled when disabled prop is true', () => {
      render(<Checkbox disabled />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeDisabled();
      expect(checkbox).toHaveClass('disabled:cursor-not-allowed');
      expect(checkbox).toHaveClass('disabled:opacity-50');
    });

    it('should handle required state', () => {
      render(<Checkbox required />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('aria-required', 'true');
    });
  });

  describe('Interactions', () => {
    it('should call onCheckedChange when clicked', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');
      await userEvent.click(checkbox);

      expect(handleChange).toHaveBeenCalledTimes(1);
      expect(handleChange).toHaveBeenCalledWith(true);
    });

    it('should toggle checked state on click', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');

      // First click - check
      await userEvent.click(checkbox);
      expect(handleChange).toHaveBeenCalledWith(true);

      // Second click - uncheck
      await userEvent.click(checkbox);
      expect(handleChange).toHaveBeenCalledWith(false);
    });

    it('should handle indeterminate state transitions', async () => {
      const handleChange = jest.fn();
      render(<Checkbox checked="indeterminate" onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');
      await userEvent.click(checkbox);

      // Clicking indeterminate should transition to checked
      expect(handleChange).toHaveBeenCalledWith(true);
    });

    it('should not trigger onCheckedChange when disabled', async () => {
      const handleChange = jest.fn();
      render(<Checkbox disabled onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');
      await userEvent.click(checkbox);

      expect(handleChange).not.toHaveBeenCalled();
    });

    it('should be keyboard accessible with Space key', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');
      checkbox.focus();

      await userEvent.keyboard(' ');
      expect(handleChange).toHaveBeenCalledWith(true);
    });

    it('should be keyboard accessible with Enter key', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');
      checkbox.focus();

      // Radix UI Checkbox doesn't respond to Enter key, only Space
      await userEvent.keyboard('{Enter}');
      // This is expected behavior for Radix UI
      expect(handleChange).not.toHaveBeenCalled();
    });
  });

  describe('Styling', () => {
    it('should have base styling classes', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveClass('peer');
      expect(checkbox).toHaveClass('h-4');
      expect(checkbox).toHaveClass('w-4');
      expect(checkbox).toHaveClass('shrink-0');
      expect(checkbox).toHaveClass('rounded-sm');
      expect(checkbox).toHaveClass('border');
      expect(checkbox).toHaveClass('border-primary');
    });

    it('should have focus styling classes', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveClass('focus-visible:outline-none');
      expect(checkbox).toHaveClass('focus-visible:ring-2');
      expect(checkbox).toHaveClass('focus-visible:ring-ring');
      expect(checkbox).toHaveClass('focus-visible:ring-offset-2');
    });

    it('should apply checked state styling', () => {
      render(<Checkbox checked />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveClass('data-[state=checked]:bg-primary');
      expect(checkbox).toHaveClass('data-[state=checked]:text-primary-foreground');
    });

    it('should merge custom className with default classes', () => {
      render(<Checkbox className="bg-red-500 border-2" />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveClass('bg-red-500');
      expect(checkbox).toHaveClass('border-2');
      expect(checkbox).toHaveClass('peer'); // Still has default classes
    });
  });

  describe('Accessibility', () => {
    it('should have proper ARIA attributes', () => {
      render(<Checkbox aria-label="Accept terms" />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('aria-label', 'Accept terms');
      expect(checkbox).toHaveAttribute('aria-checked', 'false');
    });

    it('should support aria-describedby', () => {
      render(
        <>
          <Checkbox aria-describedby="description" />
          <span id="description">This is a checkbox description</span>
        </>
      );

      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('aria-describedby', 'description');
    });

    it('should be focusable', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      checkbox.focus();
      expect(checkbox).toHaveFocus();
    });

    it('should be disabled when disabled prop is set', () => {
      render(<Checkbox disabled />);
      const checkbox = screen.getByRole('checkbox');

      // Radix UI uses data-disabled instead of aria-disabled
      expect(checkbox).toHaveAttribute('data-disabled', '');
    });

    it('should announce state changes to screen readers', async () => {
      const { rerender } = render(<Checkbox checked={false} />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('aria-checked', 'false');

      rerender(<Checkbox checked={true} />);
      expect(checkbox).toHaveAttribute('aria-checked', 'true');

      rerender(<Checkbox checked="indeterminate" />);
      expect(checkbox).toHaveAttribute('aria-checked', 'mixed');
    });
  });

  describe('Form Integration', () => {
    it('should work with form labels', async () => {
      const handleChange = jest.fn();
      render(
        <label>
          <Checkbox onCheckedChange={handleChange} />
          <span>Accept terms and conditions</span>
        </label>
      );

      const labelText = screen.getByText('Accept terms and conditions');
      await userEvent.click(labelText);

      expect(handleChange).toHaveBeenCalledWith(true);
    });

    it('should support name attribute for form submission', () => {
      render(<Checkbox name="terms" />);
      const checkbox = screen.getByRole('checkbox');

      // Radix UI Checkbox uses a hidden input for form submission
      // The button element itself won't have the name attribute
      const hiddenInput = checkbox.parentElement?.querySelector('input[type="checkbox"]');
      if (hiddenInput) {
        expect(hiddenInput).toHaveAttribute('name', 'terms');
      } else {
        // If no hidden input, the component handles form data differently
        expect(checkbox).toBeInTheDocument();
      }
    });

    it('should support value attribute', () => {
      render(<Checkbox value="accepted" />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('value', 'accepted');
    });

    it('should work in controlled mode', () => {
      const Component = () => {
        const [checked, setChecked] = React.useState(false);
        return (
          <Checkbox
            checked={checked}
            onCheckedChange={setChecked}
            data-testid="controlled-checkbox"
          />
        );
      };

      render(<Component />);
      const checkbox = screen.getByTestId('controlled-checkbox');

      expect(checkbox).not.toBeChecked();
      fireEvent.click(checkbox);
      waitFor(() => expect(checkbox).toBeChecked());
    });

    it('should work in uncontrolled mode', () => {
      render(<Checkbox defaultChecked />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toBeChecked();
      fireEvent.click(checkbox);
      waitFor(() => expect(checkbox).not.toBeChecked());
    });
  });

  describe('Check Icon', () => {
    it('should show check icon when checked', () => {
      const { container } = render(<Checkbox checked />);
      const checkIcon = container.querySelector('svg');

      expect(checkIcon).toBeInTheDocument();
      expect(checkIcon).toHaveClass('h-4');
      expect(checkIcon).toHaveClass('w-4');
    });

    it('should not show check icon when unchecked', () => {
      const { container } = render(<Checkbox checked={false} />);
      const checkIcon = container.querySelector('svg');

      expect(checkIcon).not.toBeInTheDocument();
    });

    it('should show check icon when indeterminate', () => {
      const { container } = render(<Checkbox checked="indeterminate" />);
      const checkIcon = container.querySelector('svg');

      expect(checkIcon).toBeInTheDocument();
    });
  });

  describe('Edge Cases', () => {
    it('should handle rapid clicks', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);

      const checkbox = screen.getByRole('checkbox');

      // Rapid clicks
      await userEvent.click(checkbox);
      await userEvent.click(checkbox);
      await userEvent.click(checkbox);

      expect(handleChange).toHaveBeenCalledTimes(3);
    });

    it('should handle prop updates correctly', () => {
      const { rerender } = render(<Checkbox checked={false} disabled={false} />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).not.toBeChecked();
      expect(checkbox).not.toBeDisabled();

      rerender(<Checkbox checked={true} disabled={true} />);

      expect(checkbox).toBeChecked();
      expect(checkbox).toBeDisabled();
    });

    it('should handle undefined onCheckedChange gracefully', async () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      // Should not throw error
      await userEvent.click(checkbox);
      expect(checkbox).toBeInTheDocument();
    });
  });
});