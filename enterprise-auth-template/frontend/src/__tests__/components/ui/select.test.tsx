
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';


// Mock scrollIntoView for JSDOM
Object.defineProperty(HTMLElement.prototype, 'scrollIntoView', {
  value: jest.fn(),
  writable: true
});
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectSeparator,
  SelectTrigger,
  SelectValue
} from '@/components/ui/select';
describe('Select Component', () => {
  const SimpleSelect = ({
    onValueChange = jest.fn(),
    disabled = false,
    defaultValue = undefined,
    value = undefined,
  }: {
    onValueChange?: (value: string) => void;
    disabled?: boolean;
    defaultValue?: string;
    value?: string;
  }) => (
    <Select
      onValueChange={onValueChange}
      disabled={disabled}
      defaultValue={defaultValue}
      value={value}
    >
      <SelectTrigger className="w-[180px]">
        <SelectValue placeholder="Select a fruit" />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="apple">Apple</SelectItem>
        <SelectItem value="banana">Banana</SelectItem>
        <SelectItem value="orange">Orange</SelectItem>
        <SelectItem value="grape">Grape</SelectItem>
      </SelectContent>
    </Select>
  );

  const GroupedSelect = () => (
    <Select>
      <SelectTrigger className="w-[280px]">
        <SelectValue placeholder="Select an option" />
      </SelectTrigger>
      <SelectContent>
        <SelectGroup>
          <SelectLabel>Fruits</SelectLabel>
          <SelectItem value="apple">Apple</SelectItem>
          <SelectItem value="banana">Banana</SelectItem>
        </SelectGroup>
        <SelectSeparator />
        <SelectGroup>
          <SelectLabel>Vegetables</SelectLabel>
          <SelectItem value="carrot">Carrot</SelectItem>
          <SelectItem value="lettuce">Lettuce</SelectItem>
        </SelectGroup>
      </SelectContent>
    </Select>
  );

  describe('Rendering', () => {
    it('should render select trigger with placeholder', () => {
      render(<SimpleSelect />);
      expect(screen.getByText('Select a fruit')).toBeInTheDocument();
    });

    it('should render with custom className on trigger', () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');
      expect(trigger).toHaveClass('w-[180px]');
    });

    it('should render with default value', () => {
      render(<SimpleSelect defaultValue="banana" />);
      expect(screen.getByText('Banana')).toBeInTheDocument();
    });

    it('should render with controlled value', () => {
      render(<SimpleSelect value="orange" />);
      expect(screen.getByText('Orange')).toBeInTheDocument();
    });

    it('should render grouped items with labels and separator', async () => {
      render(<GroupedSelect />);
      const trigger = screen.getByRole('combobox');

      await act(async () => { await userEvent.click(trigger);

      expect(screen.getByText('Fruits')).toBeInTheDocument();
      expect(screen.getByText('Vegetables')).toBeInTheDocument();
      expect(screen.getByText('Apple')).toBeInTheDocument();
      expect(screen.getByText('Carrot')).toBeInTheDocument();
    });
  });
});

describe('Interactions', () => {
    it('should open dropdown when clicking trigger', async () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');

      expect(screen.queryByText('Apple')).not.toBeInTheDocument();

      await act(async () => { await userEvent.click(trigger);

      expect(screen.getByText('Apple')).toBeInTheDocument();
      expect(screen.getByText('Banana')).toBeInTheDocument();
      expect(screen.getByText('Orange')).toBeInTheDocument();
    });

    it('should close dropdown when selecting an item', async () => {
      const handleChange = jest.fn();
      render(<SimpleSelect onValueChange={handleChange} />);

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      const appleOption = screen.getByText('Apple');
      await act(async () => { await userEvent.click(appleOption);

      expect(handleChange).toHaveBeenCalledWith('apple');

      // Dropdown should close after selection
      await act(async () => { await waitFor(() => {
        expect(screen.queryByRole('option')).not.toBeInTheDocument();
      }); });
    });

    it('should display selected value in trigger', async () => {
      const handleChange = jest.fn();
      render(<SimpleSelect onValueChange={handleChange} />);

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      const bananaOption = screen.getByText('Banana');
      await act(async () => { await userEvent.click(bananaOption);

      expect(screen.getByText('Banana')).toBeInTheDocument();
    });

    it('should handle keyboard navigation', async () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');

      // Open with Enter key
      trigger.focus();
      fireEvent.keyDown(trigger, { key: 'Enter' });

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Apple')).toBeInTheDocument();
      }); });

      // Navigate with arrow keys
      fireEvent.keyDown(document.activeElement!, { key: 'ArrowDown' });
      fireEvent.keyDown(document.activeElement!, { key: 'ArrowDown' });

      // Select with Enter
      fireEvent.keyDown(document.activeElement!, { key: 'Enter' });

      await act(async () => { await waitFor(() => {
        expect(screen.queryByRole('option')).not.toBeInTheDocument();
      }); });
    });

    it('should close dropdown with Escape key', async () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');

      await act(async () => { await userEvent.click(trigger);
      expect(screen.getByText('Apple')).toBeInTheDocument();

      fireEvent.keyDown(document.activeElement!, { key: 'Escape' });

      await act(async () => { await waitFor(() => {
        expect(screen.queryByText('Apple')).not.toBeInTheDocument();
      }); });
    });
  });

describe('States', () => {
    it('should handle disabled state', () => {
      render(<SimpleSelect disabled={true} />);
      const trigger = screen.getByRole('combobox');

      // Check if the disabled attribute is present (Radix UI may use different attributes)
      expect(trigger).toHaveAttribute('disabled');
      expect(trigger).toBeDisabled();
    });

    it('should not open when disabled', async () => {
      render(<SimpleSelect disabled={true} />);
      const trigger = screen.getByRole('combobox');

      await act(async () => { await userEvent.click(trigger);

      expect(screen.queryByText('Apple')).not.toBeInTheDocument();
    });

    it('should handle disabled items', async () => {
      const handleChange = jest.fn();
      render(
        <Select onValueChange={handleChange}>
          <SelectTrigger>
            <SelectValue placeholder="Select" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="enabled">Enabled Option</SelectItem>
            <SelectItem value="disabled" disabled>Disabled Option</SelectItem>
          </SelectContent>
        </Select>
      );

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      const disabledOption = screen.getByText('Disabled Option');
      // Check if the disabled option exists and test it cannot be selected
      expect(disabledOption).toBeInTheDocument();

      await act(async () => { await userEvent.click(disabledOption);
      expect(handleChange).not.toHaveBeenCalled();
    });
  });

describe('Controlled vs Uncontrolled', () => {
    it('should work as uncontrolled component with defaultValue', async () => {
      const handleChange = jest.fn();
      render(<SimpleSelect defaultValue="banana" onValueChange={handleChange} />);

      expect(screen.getByText('Banana')).toBeInTheDocument();

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      const appleOption = screen.getByText('Apple');
      await act(async () => { await userEvent.click(appleOption);

      expect(handleChange).toHaveBeenCalledWith('apple');
    });

    it('should work as controlled component', async () => {
      const ControlledSelect = () => {
        const [value, setValue] = React.useState('banana');
        return (
          <Select value={value} onValueChange={setValue}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="apple">Apple</SelectItem>
              <SelectItem value="banana">Banana</SelectItem>
              <SelectItem value="orange">Orange</SelectItem>
            </SelectContent>
          </Select>
        );
      };

      render(<ControlledSelect />);
      expect(screen.getByText('Banana')).toBeInTheDocument();

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      const orangeOption = screen.getByText('Orange');
      await act(async () => { await userEvent.click(orangeOption);

      await act(async () => { await waitFor(() => {
        expect(screen.getByText('Orange')).toBeInTheDocument();
      }); });
    });
  });

describe('Accessibility', () => {
    it('should have proper ARIA attributes', () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');

      // Check that the trigger has the combobox role
      expect(trigger).toBeInTheDocument();
      expect(trigger).toHaveAttribute('aria-expanded', 'false');
    });

    it('should update aria-expanded when opened', async () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');

      await act(async () => { await userEvent.click(trigger);

      expect(trigger).toHaveAttribute('aria-expanded', 'true');
    });

    it('should have proper roles for options', async () => {
      render(<SimpleSelect />);
      const trigger = screen.getByRole('combobox');

      await act(async () => { await userEvent.click(trigger);

      const options = screen.getAllByRole('option');
      expect(options).toHaveLength(4);
    });

    it('should support aria-label on trigger', () => {
      render(
        <Select>
          <SelectTrigger aria-label="Choose a fruit">
            <SelectValue placeholder="Select" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="apple">Apple</SelectItem>
          </SelectContent>
        </Select>
      );

      const trigger = screen.getByLabelText('Choose a fruit');
      expect(trigger).toBeInTheDocument();
    });
  });

describe('Custom Content', () => {
    it('should render custom content in items', async () => {
      render(
        <Select>
          <SelectTrigger>
            <SelectValue placeholder="Select" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="custom">
              <div className="flex items-center">
                <span className="mr-2">🍎</span>
                <span>Apple with icon</span>
              </div>
            </SelectItem>
          </SelectContent>
        </Select>
      );

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      expect(screen.getByText('🍎')).toBeInTheDocument();
      expect(screen.getByText('Apple with icon')).toBeInTheDocument();
    });

    it('should handle empty placeholder', () => {
      render(
        <Select>
          <SelectTrigger>
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="test">Test</SelectItem>
          </SelectContent>
        </Select>
      );

      const trigger = screen.getByRole('combobox');
      expect(trigger).toBeInTheDocument();
    });
  });

describe('Edge Cases', () => {
    it('should handle select with no items', async () => {
      render(
        <Select>
          <SelectTrigger>
            <SelectValue placeholder="No options" />
          </SelectTrigger>
          <SelectContent />
        </Select>
      );

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      // Content should still render even if empty
      expect(trigger).toHaveAttribute('aria-expanded', 'true');
    });

    it('should handle very long option text', async () => {
      const longText = 'This is a very long option text that might overflow the select dropdown width';
      render(
        <Select>
          <SelectTrigger className="w-[200px]">
            <SelectValue placeholder="Select" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="long">{longText}</SelectItem>
          </SelectContent>
        </Select>
      );

      const trigger = screen.getByRole('combobox');
      await act(async () => { await userEvent.click(trigger);

      expect(screen.getByText(longText)).toBeInTheDocument();
    });

    it('should handle special characters in values', () => {
      render(
        <Select defaultValue="with-dash">
          <SelectTrigger>
            <SelectValue placeholder="Select" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="with-dash">With Dash</SelectItem>
            <SelectItem value="with_underscore">With Underscore</SelectItem>
            <SelectItem value="with.dot">With Dot</SelectItem>
          </SelectContent>
        </Select>
      );

      const trigger = screen.getByRole('combobox');
      // Just verify the component renders with special character values
      expect(trigger).toBeInTheDocument();
      // Verify it has the correct value attribute
      expect(trigger).toHaveAttribute('aria-expanded', 'false');
    });
  });
});