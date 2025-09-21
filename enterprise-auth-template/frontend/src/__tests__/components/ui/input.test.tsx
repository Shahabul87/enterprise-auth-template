import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { Input } from '@/components/ui/input';

describe('Input Component', () => {
  describe('Rendering', () => {
    it('should render input element', () => {
      render(<Input />);
      const input = screen.getByRole('textbox');
      expect(input).toBeInTheDocument();
    });

    it('should render with custom className', () => {
      render(<Input className="custom-class" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveClass('custom-class');
    });

    it('should forward ref correctly', () => {
      const ref = React.createRef<HTMLInputElement>();
      render(<Input ref={ref} />);
      expect(ref.current).toBeInstanceOf(HTMLInputElement);
      expect(ref.current?.tagName).toBe('INPUT');
    });

    it('should render with data-testid', () => {
      render(<Input data-testid="test-input" />);
      const input = screen.getByTestId('test-input');
      expect(input).toBeInTheDocument();
    });

    it('should render with id attribute', () => {
      render(<Input id="email-input" />);
      const input = document.getElementById('email-input');
      expect(input).toBeInTheDocument();
    });
  });

  describe('Input Types', () => {
     it('should render as text input by default', () => {
       render(<Input />);
       const input = screen.getByRole('textbox');
       // Input components may not have explicit type="text" attribute when it's the default
       const inputType = input.getAttribute('type');
       expect(inputType === null || inputType === 'text').toBe(true);
     });

    it('should render as email input', () => {
      render(<Input type="email" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('type', 'email');
    });

    it('should render as password input', () => {
      render(<Input type="password" placeholder="Password" />);
      const input = screen.getByPlaceholderText('Password');
      expect(input).toHaveAttribute('type', 'password');
    });

    it('should render as number input', () => {
      render(<Input type="number" />);
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveAttribute('type', 'number');
    });

    it('should render as search input', () => {
      render(<Input type="search" />);
      const input = screen.getByRole('searchbox');
      expect(input).toHaveAttribute('type', 'search');
    });

    it('should render as tel input', () => {
      render(<Input type="tel" placeholder="Phone" />);
      const input = screen.getByPlaceholderText('Phone');
      expect(input).toHaveAttribute('type', 'tel');
    });

    it('should render as url input', () => {
      render(<Input type="url" placeholder="Website" />);
      const input = screen.getByPlaceholderText('Website');
      expect(input).toHaveAttribute('type', 'url');
    });

    it('should render as date input', () => {
      render(<Input type="date" data-testid="date-input" />);
      const input = screen.getByTestId('date-input');
      expect(input).toHaveAttribute('type', 'date');
    });

    it('should render as file input', () => {
      render(<Input type="file" data-testid="file-input" />);
      const input = screen.getByTestId('file-input');
      expect(input).toHaveAttribute('type', 'file');
    });
  });

  describe('Value and Change Handling', () => {
    it('should accept and display value', () => {
      render(<Input value="test value" onChange={() => {}} />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveValue('test value');
    });

    it('should accept defaultValue', () => {
      render(<Input defaultValue="default value" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveValue('default value');
    });

    it('should call onChange when value changes', async () => {
      const handleChange = jest.fn();
      render(<Input onChange={handleChange} />);

      const input = screen.getByRole('textbox');
      await userEvent.type(input, 'test');

      expect(handleChange).toHaveBeenCalled();
      expect(input).toHaveValue('test');
    });

    it('should work in controlled mode', () => {
      const Component = () => {
        const [value, setValue] = React.useState('');
        return (
          <Input
            value={value}
            onChange={(e) => setValue(e.target.value)}
            data-testid="controlled-input"
          />
        );
      };

      render(<Component />);
      const input = screen.getByTestId('controlled-input');

      expect(input).toHaveValue('');
      fireEvent.change(input, { target: { value: 'new value' } });
      expect(input).toHaveValue('new value');
    });

    it('should work in uncontrolled mode', async () => {
      render(<Input defaultValue="initial" />);
      const input = screen.getByRole('textbox');

      expect(input).toHaveValue('initial');
      await userEvent.clear(input);
      await userEvent.type(input, 'changed');
      expect(input).toHaveValue('changed');
    });
  });

  describe('Input Attributes', () => {
    it('should support placeholder', () => {
      render(<Input placeholder="Enter your name" />);
      const input = screen.getByPlaceholderText('Enter your name');
      expect(input).toBeInTheDocument();
    });

    it('should support name attribute', () => {
      render(<Input name="username" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('name', 'username');
    });

    it('should support disabled state', () => {
      render(<Input disabled />);
      const input = screen.getByRole('textbox');
      expect(input).toBeDisabled();
      expect(input).toHaveClass('disabled:cursor-not-allowed');
      expect(input).toHaveClass('disabled:opacity-50');
    });

    it('should support readonly state', () => {
      render(<Input readOnly value="readonly value" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('readonly');
      expect(input).toHaveValue('readonly value');
    });

    it('should support required attribute', () => {
      render(<Input required />);
      const input = screen.getByRole('textbox');
      expect(input).toBeRequired();
    });

    it('should support autoComplete attribute', () => {
      render(<Input autoComplete="email" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('autocomplete', 'email');
    });

    it('should support autoFocus attribute', () => {
      render(<Input autoFocus />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveFocus();
    });

    it('should support maxLength attribute', () => {
      render(<Input maxLength={10} />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('maxlength', '10');
    });

    it('should support minLength attribute', () => {
      render(<Input minLength={5} />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('minlength', '5');
    });

    it('should support pattern attribute', () => {
      render(<Input pattern="[0-9]{3}" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('pattern', '[0-9]{3}');
    });
  });

  describe('Number Input Attributes', () => {
    it('should support min attribute for number input', () => {
      render(<Input type="number" min={0} />);
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveAttribute('min', '0');
    });

    it('should support max attribute for number input', () => {
      render(<Input type="number" max={100} />);
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveAttribute('max', '100');
    });

    it('should support step attribute for number input', () => {
      render(<Input type="number" step={0.5} />);
      const input = screen.getByRole('spinbutton');
      expect(input).toHaveAttribute('step', '0.5');
    });
  });

  describe('Event Handlers', () => {
    it('should call onFocus when focused', () => {
      const handleFocus = jest.fn();
      render(<Input onFocus={handleFocus} />);

      const input = screen.getByRole('textbox');
      fireEvent.focus(input);

      expect(handleFocus).toHaveBeenCalledTimes(1);
    });

    it('should call onBlur when blurred', () => {
      const handleBlur = jest.fn();
      render(<Input onBlur={handleBlur} />);

      const input = screen.getByRole('textbox');
      fireEvent.focus(input);
      fireEvent.blur(input);

      expect(handleBlur).toHaveBeenCalledTimes(1);
    });

    it('should call onKeyDown when key is pressed', async () => {
      const handleKeyDown = jest.fn();
      render(<Input onKeyDown={handleKeyDown} />);

      const input = screen.getByRole('textbox');
      await userEvent.type(input, '{Enter}');

      expect(handleKeyDown).toHaveBeenCalled();
    });

    it('should call onKeyUp when key is released', () => {
      const handleKeyUp = jest.fn();
      render(<Input onKeyUp={handleKeyUp} />);

      const input = screen.getByRole('textbox');
      fireEvent.keyUp(input, { key: 'a' });

      expect(handleKeyUp).toHaveBeenCalledTimes(1);
    });

    it('should call onInput when input event occurs', () => {
      const handleInput = jest.fn();
      render(<Input onInput={handleInput} />);

      const input = screen.getByRole('textbox');
      fireEvent.input(input, { target: { value: 'test' } });

      expect(handleInput).toHaveBeenCalledTimes(1);
    });

     it('should call onPaste when content is pasted', () => {
       const handlePaste = jest.fn();
       render(<Input onPaste={handlePaste} />);

       const input = screen.getByRole('textbox');
       fireEvent.paste(input);
       
       expect(handlePaste).toHaveBeenCalledTimes(1);
     });
  });

  describe('Styling', () => {
    it('should have base styling classes', () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      expect(input).toHaveClass('flex');
      expect(input).toHaveClass('h-10');
      expect(input).toHaveClass('w-full');
      expect(input).toHaveClass('rounded-md');
      expect(input).toHaveClass('border');
      expect(input).toHaveClass('border-input');
      expect(input).toHaveClass('bg-background');
      expect(input).toHaveClass('px-3');
      expect(input).toHaveClass('py-2');
      expect(input).toHaveClass('text-sm');
    });

    it('should have focus styling classes', () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      expect(input).toHaveClass('focus-visible:outline-none');
      expect(input).toHaveClass('focus-visible:ring-2');
      expect(input).toHaveClass('focus-visible:ring-ring');
      expect(input).toHaveClass('focus-visible:ring-offset-2');
    });

    it('should have placeholder styling', () => {
      render(<Input placeholder="test" />);
      const input = screen.getByRole('textbox');

      expect(input).toHaveClass('placeholder:text-muted-foreground');
    });

    it('should have file input styling', () => {
      render(<Input type="file" data-testid="file-input" />);
      const input = screen.getByTestId('file-input');

      expect(input).toHaveClass('file:border-0');
      expect(input).toHaveClass('file:bg-transparent');
      expect(input).toHaveClass('file:text-sm');
      expect(input).toHaveClass('file:font-medium');
    });

    it('should merge custom className with default classes', () => {
      render(<Input className="bg-red-500 text-white" />);
      const input = screen.getByRole('textbox');

      expect(input).toHaveClass('bg-red-500');
      expect(input).toHaveClass('text-white');
      expect(input).toHaveClass('flex'); // Still has default classes
    });
  });

  describe('Accessibility', () => {
    it('should support aria-label', () => {
      render(<Input aria-label="Email address" />);
      const input = screen.getByRole('textbox', { name: 'Email address' });
      expect(input).toBeInTheDocument();
    });

    it('should support aria-describedby', () => {
      render(
        <>
          <Input aria-describedby="help-text" />
          <span id="help-text">Enter your email address</span>
        </>
      );

      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('aria-describedby', 'help-text');
    });

    it('should support aria-invalid', () => {
      render(<Input aria-invalid="true" />);
      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('aria-invalid', 'true');
    });

    it('should work with label element', () => {
      render(
        <label>
          Email
          <Input type="email" />
        </label>
      );

      const input = screen.getByRole('textbox');
      expect(input).toBeInTheDocument();
    });

    it('should work with label for attribute', () => {
      render(
        <>
          <label htmlFor="email-field">Email</label>
          <Input id="email-field" type="email" />
        </>
      );

      const input = screen.getByRole('textbox');
      const label = screen.getByText('Email');
      expect(input).toHaveAttribute('id', 'email-field');
      expect(label).toHaveAttribute('for', 'email-field');
    });
  });

  describe('Form Integration', () => {
    it('should submit form data', () => {
      const handleSubmit = jest.fn((e) => e.preventDefault());

      render(
        <form onSubmit={handleSubmit}>
          <Input name="username" defaultValue="testuser" />
          <button type="submit">Submit</button>
        </form>
      );

      const submitButton = screen.getByText('Submit');
      fireEvent.click(submitButton);

      expect(handleSubmit).toHaveBeenCalledTimes(1);
    });

    it('should respect form validation', () => {
      render(
        <form>
          <Input required data-testid="required-input" />
          <button type="submit">Submit</button>
        </form>
      );

      const input = screen.getByTestId('required-input') as HTMLInputElement;
      expect(input.validity.valid).toBe(false);

      fireEvent.change(input, { target: { value: 'value' } });
      expect(input.validity.valid).toBe(true);
    });

    it('should handle form reset', () => {
      render(
        <form>
          <Input defaultValue="initial" data-testid="reset-input" />
          <button type="reset">Reset</button>
        </form>
      );

      const input = screen.getByTestId('reset-input');
      const resetButton = screen.getByText('Reset');

      fireEvent.change(input, { target: { value: 'changed' } });
      expect(input).toHaveValue('changed');

      fireEvent.click(resetButton);
      expect(input).toHaveValue('initial');
    });
  });

  describe('Edge Cases', () => {
    it('should handle undefined onChange gracefully', async () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      // Should not throw error
      await userEvent.type(input, 'test');
      expect(input).toHaveValue('test');
    });

    it('should not change value when disabled', async () => {
      const handleChange = jest.fn();
      render(<Input disabled value="disabled" onChange={handleChange} />);

      const input = screen.getByRole('textbox');
      await userEvent.type(input, 'test');

      expect(handleChange).not.toHaveBeenCalled();
      expect(input).toHaveValue('disabled');
    });

    it('should not change value when readonly', async () => {
      const handleChange = jest.fn();
      render(<Input readOnly value="readonly" onChange={handleChange} />);

      const input = screen.getByRole('textbox');
      await userEvent.type(input, 'test');

      expect(input).toHaveValue('readonly');
    });

    it('should handle rapid typing', async () => {
      const handleChange = jest.fn();
      render(<Input onChange={handleChange} />);

      const input = screen.getByRole('textbox');
      await userEvent.type(input, 'rapidtyping');

      expect(input).toHaveValue('rapidtyping');
      expect(handleChange).toHaveBeenCalled();
    });

    it('should handle special characters', async () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      await userEvent.type(input, '!@#$%^&*()');
      expect(input).toHaveValue('!@#$%^&*()');
    });

    it('should handle emoji input', async () => {
      render(<Input />);
      const input = screen.getByRole('textbox');

      fireEvent.change(input, { target: { value: '😀🎉🚀' } });
      expect(input).toHaveValue('😀🎉🚀');
    });
  });
});