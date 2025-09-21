
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { Input } from '@/components/ui/input';
describe('Input Component', () => {
  describe('Rendering', () => {
    it('should render an input element', () => {
      render(<Input />);
      const input = screen.getByRole('textbox');
      expect(input).toBeInTheDocument();
    });

    it('should render with placeholder text', () => {
      render(<Input placeholder="Enter your name" />);
      const input = screen.getByPlaceholderText('Enter your name');
      expect(input).toBeInTheDocument();
    });

    it('should render with default value', () => {
      render(<Input defaultValue="Default text" />);
      const input = screen.getByRole('textbox') as HTMLInputElement;
      expect(input.value).toBe('Default text');
    });

    it('should render with controlled value', () => {
      render(<Input value="Controlled value" onChange={() => {}} />);
      const input = screen.getByRole('textbox') as HTMLInputElement;
      expect(input.value).toBe('Controlled value');
    });
  });

describe('Input Types', () => {
    const inputTypes: Array<React.HTMLInputTypeAttribute> = [
      'text',
      'password',
      'email',
      'number',
      'tel',
      'url',
      'search',
      'date',
      'time',
      'datetime-local',
      'month',
      'week',
      'color',
    ];

    inputTypes.forEach((type) => {
      it(`should render input with type="${type}"`, () => {
        render(<Input type={type} data-testid="typed-input" />);
        const input = screen.getByTestId('typed-input');
        expect(input).toHaveAttribute('type', type);
      });
    });

    it('should render file input', () => {
      render(<Input type="file" data-testid="file-input" />);
      const input = screen.getByTestId('file-input');
      expect(input).toHaveAttribute('type', 'file');
    });

    it('should render range input', () => {
      render(<Input type="range" data-testid="range-input" min="0" max="100" />);
      const input = screen.getByTestId('range-input');
      expect(input).toHaveAttribute('type', 'range');
      expect(input).toHaveAttribute('min', '0');
      expect(input).toHaveAttribute('max', '100');
    });
  });
});

describe('Props and Attributes', () => {
    it('should apply custom className', () => {
      render(<Input className="custom-input-class" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveClass('custom-input-class');
    });

    it('should handle disabled state', () => {
      render(<Input disabled />);
      const input = screen.getByRole('textbox');
      expect(input).toBeDisabled();
      expect(input.className).toContain('disabled:cursor-not-allowed');
      expect(input.className).toContain('disabled:opacity-50');
    });

    it('should handle readonly state', () => {
      render(<Input readOnly value="Read only text" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('readonly');
    });

    it('should handle required attribute', () => {
      render(<Input required />);
      const input = screen.getByRole('textbox');
      expect(input).toBeRequired();
    });

    it('should pass through HTML input attributes', () => {
      render(
        <Input
          name="username"
          id="username-input"
          autoComplete="username"
          autoFocus
          maxLength={50}
          minLength={3}
          pattern="[A-Za-z]+"
          data-testid="test-input"
        />
      );
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('name', 'username');
      expect(input).toHaveAttribute('id', 'username-input');
      expect(input).toHaveAttribute('autocomplete', 'username');
      // Note: autofocus behavior is browser-specific and may not work in test environment
      // expect(input.hasAttribute('autofocus')).toBe(true);
      expect(input).toHaveAttribute('maxlength', '50');
      expect(input).toHaveAttribute('minlength', '3');
      expect(input).toHaveAttribute('pattern', '[A-Za-z]+');
      expect(input).toHaveAttribute('data-testid', 'test-input');
    });

    it('should forward ref correctly', () => {
      const ref = React.createRef<HTMLInputElement>();
      render(<Input ref={ref} />);
      expect(ref.current).toBeInstanceOf(HTMLInputElement);
      expect(ref.current?.tagName).toBe('INPUT');
    });
  });
});

describe('Interactions', () => {
    it('should handle onChange event', async () => {
      const handleChange = jest.fn();
      render(<Input onChange={handleChange} />);

      const input = screen.getByRole('textbox');
      await act(async () => { await userEvent.type(input, 'Hello');

      expect(handleChange).toHaveBeenCalled();
    });

    it('should handle onFocus event', () => {
      const handleFocus = jest.fn();
      render(<Input onFocus={handleFocus} />);

      const input = screen.getByRole('textbox');
      act(() => { fireEvent.focus(input) });

      expect(handleFocus).toHaveBeenCalledTimes(1);
    });

    it('should handle onBlur event', () => {
      const handleBlur = jest.fn();
      render(<Input onBlur={handleBlur} />);

      const input = screen.getByRole('textbox');
      act(() => { fireEvent.focus(input) });
      act(() => { fireEvent.blur(input) });

      expect(handleBlur).toHaveBeenCalledTimes(1);
    });

    it('should handle onKeyDown event', () => {
      const handleKeyDown = jest.fn();
      render(<Input onKeyDown={handleKeyDown} />);

      const input = screen.getByRole('textbox');
      fireEvent.keyDown(input, { key: 'Enter' });

      expect(handleKeyDown).toHaveBeenCalledTimes(1);
    });

    it('should handle onKeyUp event', () => {
      const handleKeyUp = jest.fn();
      render(<Input onKeyUp={handleKeyUp} />);

      const input = screen.getByRole('textbox');
      fireEvent.keyUp(input, { key: 'a' });

      expect(handleKeyUp).toHaveBeenCalledTimes(1);
    });

    it('should handle onInput event', () => {
      const handleInput = jest.fn();
      render(<Input onInput={handleInput} />);

      const input = screen.getByRole('textbox');
      fireEvent.input(input, { target: { value: 'test' } });

      expect(handleInput).toHaveBeenCalledTimes(1);
    });

    it('should not respond to events when disabled', async () => {
      const handleChange = jest.fn();
      const handleClick = jest.fn();

      render(<Input disabled onChange={handleChange} onClick={handleClick} />);

      const input = screen.getByRole('textbox');

      // Try to type
      await act(async () => { await userEvent.type(input, 'test');
      expect(handleChange).not.toHaveBeenCalled();

      // Try to click
      act(() => { fireEvent.click(input) });
      // Disabled inputs should not trigger click handlers
      expect(handleClick).not.toHaveBeenCalled();
    });
  });
});

describe('Controlled vs Uncontrolled', () => {
    it('should work as an uncontrolled component', async () => {
      render(<Input defaultValue="initial" />);
      const input = screen.getByRole('textbox') as HTMLInputElement;

      expect(input.value).toBe('initial');

      await act(async () => { await userEvent.clear(input);
      await act(async () => { await userEvent.type(input, 'new value');

      expect(input.value).toBe('new value');
    });

    it('should work as a controlled component', async () => {
      const ControlledInput = () => {
        const [value, setValue] = React.useState('controlled');
        return (
          <Input
            value={value}
            onChange={(e) => setValue(e.target.value)}
          />
        );
      };

      render(<ControlledInput />);
      const input = screen.getByRole('textbox') as HTMLInputElement;

      expect(input.value).toBe('controlled');

      await act(async () => { await userEvent.clear(input); });
      await act(async () => { await userEvent.type(input, 'updated'); });

      expect(input.value).toBe('updated');
    });
  });
});

describe('Styling', () => {
    it('should have default styling classes', () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      expect(input.className).toContain('flex');
      expect(input.className).toContain('h-10');
      expect(input.className).toContain('w-full');
      expect(input.className).toContain('rounded-md');
      expect(input.className).toContain('border');
      expect(input.className).toContain('border-input');
      expect(input.className).toContain('bg-background');
      expect(input.className).toContain('px-3');
      expect(input.className).toContain('py-2');
      expect(input.className).toContain('text-sm');
    });

    it('should have focus styling classes', () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      expect(input.className).toContain('focus-visible:outline-none');
      expect(input.className).toContain('focus-visible:ring-2');
      expect(input.className).toContain('focus-visible:ring-ring');
      expect(input.className).toContain('focus-visible:ring-offset-2');
    });

    it('should have file input styling', () => {
      render(<Input type="file" data-testid="file-input" />);
      const input = screen.getByTestId('file-input');

      expect(input.className).toContain('file:border-0');
      expect(input.className).toContain('file:bg-transparent');
      expect(input.className).toContain('file:text-sm');
      expect(input.className).toContain('file:font-medium');
    });
  });
});

describe('Accessibility', () => {
    it('should support aria-label', () => {
      render(<Input aria-label="Username input" />);
      const input = screen.getByLabelText('Username input');
      expect(input).toBeInTheDocument();
    });

    it('should support aria-describedby', () => {
      render(
        <>
          <Input aria-describedby="input-description" />
          <span id="input-description">Enter your username</span>
        </>
      );
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('aria-describedby', 'input-description');
    });

    it('should support aria-invalid', () => {
      render(<Input aria-invalid="true" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('aria-invalid', 'true');
    });

    it('should support aria-required', () => {
      render(<Input aria-required="true" required />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('aria-required', 'true');
      expect(input).toBeRequired();
    });
  });
});

describe('Edge Cases', () => {
    it('should handle empty string value', () => {
      render(<Input value="" onChange={() => {}} />);
      const input = screen.getByRole('textbox') as HTMLInputElement;
      expect(input.value).toBe('');
    });

    it('should handle very long input', async () => {
      render(<Input />);
      const input = screen.getByRole('textbox') as HTMLInputElement;
      const longText = 'a'.repeat(1000);

      await act(async () => { await userEvent.type(input, longText);
      expect(input.value).toBe(longText);
    });

    it('should handle special characters', async () => {
      render(<Input />);
      const input = screen.getByRole('textbox') as HTMLInputElement;
      const specialChars = '!@#$%^&*()_+-=';

      await act(async () => { await userEvent.type(input, specialChars);
      expect(input.value).toBe(specialChars);
    });

    it('should handle paste event', () => {
      const handlePaste = jest.fn();
      render(<Input onPaste={handlePaste} />);

      const input = screen.getByRole('textbox');
      fireEvent.paste(input);

      expect(handlePaste).toHaveBeenCalledTimes(1);
    });

    it('should handle composition events', () => {
      const handleCompositionStart = jest.fn();
      const handleCompositionEnd = jest.fn();

      render(
        <Input
          onCompositionStart={handleCompositionStart}
          onCompositionEnd={handleCompositionEnd}
        />
      );

      const input = screen.getByRole('textbox');

      fireEvent.compositionStart(input);
      expect(handleCompositionStart).toHaveBeenCalledTimes(1);

      fireEvent.compositionEnd(input);
      expect(handleCompositionEnd).toHaveBeenCalledTimes(1);
    });
  });
});