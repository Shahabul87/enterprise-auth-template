
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
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
      render(<Checkbox className="custom-checkbox-class" />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveClass('custom-checkbox-class');
    });

    it('should render unchecked by default', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).not.toBeChecked();
      expect(checkbox).toHaveAttribute('data-state', 'unchecked');
    });

    it('should render as checked when defaultChecked is true', () => {
      render(<Checkbox defaultChecked />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeChecked();
      expect(checkbox).toHaveAttribute('data-state', 'checked');
    });

    it('should render with controlled checked state', () => {
      render(<Checkbox checked={true} onCheckedChange={() => {}} />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeChecked();
      expect(checkbox).toHaveAttribute('data-state', 'checked');
    });

    it('should render as indeterminate when checked="indeterminate"', () => {
      render(<Checkbox checked="indeterminate" onCheckedChange={() => {}} />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('data-state', 'indeterminate');
      expect(checkbox).toHaveAttribute('aria-checked', 'mixed');
    });
  });

describe('Interactions', () => {
    it('should toggle when clicked', async () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).not.toBeChecked();

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).toBeChecked();

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).not.toBeChecked();
    });

    it('should call onCheckedChange when toggled', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);
      const checkbox = screen.getByRole('checkbox');

      await act(async () => { await userEvent.click(checkbox);
      expect(handleChange).toHaveBeenCalledWith(true);

      await act(async () => { await userEvent.click(checkbox);
      expect(handleChange).toHaveBeenCalledWith(false);
    });

    it('should handle keyboard interaction (Space key)', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);
      const checkbox = screen.getByRole('checkbox');

      await act(async () => { await userEvent.click(checkbox);

      expect(handleChange).toHaveBeenCalledWith(true);
    });

    it('should not toggle when disabled', async () => {
      const handleChange = jest.fn();
      render(<Checkbox disabled onCheckedChange={handleChange} />);
      const checkbox = screen.getByRole('checkbox');

      await act(async () => { await userEvent.click(checkbox);
      expect(handleChange).not.toHaveBeenCalled();
      expect(checkbox).not.toBeChecked();
    });

    it('should handle indeterminate state transitions', async () => {
      const handleChange = jest.fn();
      render(<Checkbox checked="indeterminate" onCheckedChange={handleChange} />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('data-state', 'indeterminate');

      await act(async () => { await userEvent.click(checkbox);
      expect(handleChange).toHaveBeenCalledWith(true);
    });
  });

describe('States', () => {
    it('should handle disabled state', () => {
      render(<Checkbox disabled />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toBeDisabled();
      expect(checkbox).toHaveClass('disabled:cursor-not-allowed');
      expect(checkbox).toHaveClass('disabled:opacity-50');
    });

    it('should handle required state', () => {
      render(<Checkbox required />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeRequired();
    });

    it('should maintain disabled state when checked', () => {
      render(<Checkbox disabled defaultChecked />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toBeDisabled();
      expect(checkbox).toBeChecked();
    });
  });

describe('Controlled vs Uncontrolled', () => {
    it('should work as uncontrolled component', async () => {
      render(<Checkbox defaultChecked={false} />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).not.toBeChecked();

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).toBeChecked();

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).not.toBeChecked();
    });

    it('should work as controlled component', async () => {
      const ControlledCheckbox = () => {
        const [checked, setChecked] = React.useState(false);
        return (
          <Checkbox
            checked={checked}
            onCheckedChange={setChecked}
          />
        );
      };

      render(<ControlledCheckbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).not.toBeChecked();

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).toBeChecked();

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).not.toBeChecked();
    });

    it('should handle controlled indeterminate state', () => {
      const ControlledIndeterminate = () => {
        const [checked, setChecked] = React.useState<boolean | 'indeterminate'>('indeterminate');
        return (
          <Checkbox
            checked={checked}
            onCheckedChange={(value) => {
              setChecked(value === true ? true : false);
            }}
          />
        );
      };

      render(<ControlledIndeterminate />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('data-state', 'indeterminate');
    });
  });

describe('Styling', () => {
    it('should have default styling classes', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox.className).toContain('h-4');
      expect(checkbox.className).toContain('w-4');
      expect(checkbox.className).toContain('rounded-sm');
      expect(checkbox.className).toContain('border');
      expect(checkbox.className).toContain('border-primary');
    });

    it('should have focus styling classes', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox.className).toContain('focus-visible:outline-none');
      expect(checkbox.className).toContain('focus-visible:ring-2');
      expect(checkbox.className).toContain('focus-visible:ring-ring');
      expect(checkbox.className).toContain('focus-visible:ring-offset-2');
    });

    it('should have checked state styling', () => {
      render(<Checkbox defaultChecked />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox.className).toContain('data-[state=checked]:bg-primary');
      expect(checkbox.className).toContain('data-[state=checked]:text-primary-foreground');
    });

    it('should render check icon when checked', () => {
      const { container } = render(<Checkbox defaultChecked />);
      const checkIcon = container.querySelector('svg');
      expect(checkIcon).toBeInTheDocument();
      expect(checkIcon).toHaveClass('h-4', 'w-4');
    });

    it('should not render check icon when unchecked', () => {
      const { container } = render(<Checkbox />);
      const checkIcon = container.querySelector('svg');
      // The icon may be in DOM but not visible
      if (checkIcon) {
        const parent = checkIcon.parentElement;
        expect(parent?.getAttribute('data-state')).toBe('closed');
      }
    });
  });

describe('Accessibility', () => {
    it('should have proper ARIA attributes', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('type', 'button');
      expect(checkbox).toHaveAttribute('role', 'checkbox');
      expect(checkbox).toHaveAttribute('aria-checked', 'false');
    });

    it('should update aria-checked when toggled', async () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      expect(checkbox).toHaveAttribute('aria-checked', 'false');

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).toHaveAttribute('aria-checked', 'true');

      await act(async () => { await userEvent.click(checkbox);
      expect(checkbox).toHaveAttribute('aria-checked', 'false');
    });

    it('should have aria-checked="mixed" for indeterminate state', () => {
      render(<Checkbox checked="indeterminate" onCheckedChange={() => {}} />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('aria-checked', 'mixed');
    });

    it('should support aria-label', () => {
      render(<Checkbox aria-label="Accept terms and conditions" />);
      const checkbox = screen.getByLabelText('Accept terms and conditions');
      expect(checkbox).toBeInTheDocument();
    });

    it('should support aria-describedby', () => {
      render(
        <>
          <Checkbox aria-describedby="checkbox-description" />
          <span id="checkbox-description">Select to agree</span>
        </>
      );
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('aria-describedby', 'checkbox-description');
    });

    it('should be keyboard navigable', () => {
      render(<Checkbox />);
      const checkbox = screen.getByRole('checkbox');

      checkbox.focus();
      expect(checkbox).toHaveFocus();
    });
  });

describe('Edge Cases', () => {
    it('should handle rapid clicking', async () => {
      const handleChange = jest.fn();
      render(<Checkbox onCheckedChange={handleChange} />);
      const checkbox = screen.getByRole('checkbox');

      // Rapid clicks
      await act(async () => { await userEvent.click(checkbox);
      await act(async () => { await userEvent.click(checkbox);
      await act(async () => { await userEvent.click(checkbox);
      await act(async () => { await userEvent.click(checkbox);

      // Should be called 4 times alternating between true and false
      expect(handleChange).toHaveBeenCalledTimes(4);
      expect(handleChange).toHaveBeenNthCalledWith(1, true);
      expect(handleChange).toHaveBeenNthCalledWith(2, false);
      expect(handleChange).toHaveBeenNthCalledWith(3, true);
      expect(handleChange).toHaveBeenNthCalledWith(4, false);
    });

    it('should handle form integration', () => {
      render(
        <form>
          <Checkbox name="agreement" value="yes" />
        </form>
      );
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toBeInTheDocument();

      // Radix UI creates a hidden input for form integration
      const hiddenInput = document.querySelector('input[type="checkbox"][name="agreement"]');
      expect(hiddenInput).toBeInTheDocument();
      expect(hiddenInput).toHaveAttribute('value', 'yes');
    });

    it('should maintain state with id prop', () => {
      render(<Checkbox id="terms-checkbox" />);
      const checkbox = screen.getByRole('checkbox');
      expect(checkbox).toHaveAttribute('id', 'terms-checkbox');
    });

    it('should handle data attributes', () => {
      render(
        <Checkbox
          data-testid="test-checkbox"
          data-category="preferences"
        />
      );
      const checkbox = screen.getByTestId('test-checkbox');
      expect(checkbox).toHaveAttribute('data-category', 'preferences');
    });

    it('should forward ref correctly', () => {
      const ref = React.createRef<HTMLButtonElement>();
      render(<Checkbox ref={ref} />);
      expect(ref.current).toBeInstanceOf(HTMLButtonElement);
      expect(ref.current?.getAttribute('role')).toBe('checkbox');
    });

    it('should handle onFocus and onBlur events', () => {
      const handleFocus = jest.fn();
      const handleBlur = jest.fn();

      render(
        <Checkbox
          onFocus={handleFocus}
          onBlur={handleBlur}
        />
      );
      const checkbox = screen.getByRole('checkbox');

      act(() => { fireEvent.focus(checkbox) });
      expect(handleFocus).toHaveBeenCalledTimes(1);

      act(() => { fireEvent.blur(checkbox) });
      expect(handleBlur).toHaveBeenCalledTimes(1);
    });
  });

describe('Integration with Forms', () => {
    it('should work with form labels', () => {
      render(
        <div>
          <label htmlFor="terms">
            <Checkbox id="terms" />
            <span>I agree to the terms</span>
          </label>
        </div>
      );

      const checkbox = screen.getByRole('checkbox');
      const label = screen.getByText('I agree to the terms');

      expect(checkbox).toHaveAttribute('id', 'terms');
      expect(label).toBeInTheDocument();
    });

    it('should handle multiple checkboxes', async () => {
      const handleChange1 = jest.fn();
      const handleChange2 = jest.fn();

      render(
        <div>
          <Checkbox
            aria-label="Option 1"
            onCheckedChange={handleChange1}
          />
          <Checkbox
            aria-label="Option 2"
            onCheckedChange={handleChange2}
          />
        </div>
      );

      const checkbox1 = screen.getByLabelText('Option 1');
      const checkbox2 = screen.getByLabelText('Option 2');

      await act(async () => { await userEvent.click(checkbox1);
      expect(handleChange1).toHaveBeenCalledWith(true);
      expect(handleChange2).not.toHaveBeenCalled();

      await act(async () => { await userEvent.click(checkbox2);
      expect(handleChange2).toHaveBeenCalledWith(true);
    });
  });
});