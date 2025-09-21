
import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Button, buttonVariants } from '@/components/ui/button';
describe('Button Component', () => {
  describe('Rendering', () => {
    it('should render button with text content', () => {
      render(<Button>Click me</Button>);
      const button = screen.getByRole('button', { name: 'Click me' });
      expect(button).toBeInTheDocument();
    });

    it('should render with children elements', () => {
      render(
        <Button>
          <span data-testid="icon">🔔</span>
          <span>Notifications</span>
        </Button>
      );
      expect(screen.getByTestId('icon')).toBeInTheDocument();
      expect(screen.getByText('Notifications')).toBeInTheDocument();
    });

    it('should render as a child component when asChild is true', () => {
      render(
        <Button asChild>
          <a href="/test">Link Button</a>
        </Button>
      );
      const link = screen.getByRole('link', { name: 'Link Button' });
      expect(link).toBeInTheDocument();
      expect(link).toHaveAttribute('href', '/test');
    });
  });

describe('Variants', () => {
    const variants: Array<'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link'> = [
      'default',
      'destructive',
      'outline',
      'secondary',
      'ghost',
      'link',
    ];

    variants.forEach((variant) => {
      it(`should apply ${variant} variant classes`, () => {
        render(<Button variant={variant}>Button</Button>);
        const button = screen.getByRole('button');
        const expectedClasses = buttonVariants({ variant });

        // Check if button has the variant classes
        expectedClasses.split(' ').forEach((className) => {
          if (className && !className.includes(':')) {
            expect(button.className).toContain(className);
          }
        });
      });
    });
  });

describe('Sizes', () => {
    const sizes: Array<'default' | 'sm' | 'lg' | 'icon'> = ['default', 'sm', 'lg', 'icon'];

    sizes.forEach((size) => {
      it(`should apply ${size} size classes`, () => {
        render(<Button size={size}>Button</Button>);
        const button = screen.getByRole('button');

        // Check for size-specific classes
        if (size === 'icon') {
          expect(button.className).toContain('h-10');
          expect(button.className).toContain('w-10');
        } else {
          expect(button.className).toMatch(/h-\d+/);
          expect(button.className).toMatch(/px-\d+/);
        }
      });
    });
  });

describe('Props and Attributes', () => {
    it('should apply custom className', () => {
      render(<Button className="custom-class">Button</Button>);
      const button = screen.getByRole('button');
      expect(button).toHaveClass('custom-class');
    });

    it('should handle disabled state', () => {
      render(<Button disabled>Disabled Button</Button>);
      const button = screen.getByRole('button');
      expect(button).toBeDisabled();
      expect(button.className).toContain('disabled:opacity-50');
    });

    it('should pass through HTML button attributes', () => {
      render(
        <Button
          type="submit"
          form="test-form"
          aria-label="Submit form"
          data-testid="submit-btn"
        >
          Submit
        </Button>
      );
      const button = screen.getByRole('button');
      expect(button).toHaveAttribute('type', 'submit');
      expect(button).toHaveAttribute('form', 'test-form');
      expect(button).toHaveAttribute('aria-label', 'Submit form');
      expect(button).toHaveAttribute('data-testid', 'submit-btn');
    });

    it('should forward ref correctly', () => {
      const ref = React.createRef<HTMLButtonElement>();
      render(<Button ref={ref}>Button</Button>);
      expect(ref.current).toBeInstanceOf(HTMLButtonElement);
      expect(ref.current?.tagName).toBe('BUTTON');
    });
  });

describe('Interactions', () => {
    it('should handle click events', () => {
      const handleClick = jest.fn();
      render(<Button onClick={handleClick}>Click me</Button>);

      const button = screen.getByRole('button');
      act(() => { fireEvent.click(button) });

      expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('should not trigger click when disabled', () => {
      const handleClick = jest.fn();
      render(
        <Button disabled onClick={handleClick}>
          Disabled
        </Button>
      );

      const button = screen.getByRole('button');
      act(() => { fireEvent.click(button) });

      expect(handleClick).not.toHaveBeenCalled();
    });

    it('should handle keyboard events', () => {
      const handleKeyDown = jest.fn();
      render(<Button onKeyDown={handleKeyDown}>Button</Button>);

      const button = screen.getByRole('button');
      fireEvent.keyDown(button, { key: 'Enter' });

      expect(handleKeyDown).toHaveBeenCalledTimes(1);
    });

    it('should handle focus and blur events', () => {
      const handleFocus = jest.fn();
      const handleBlur = jest.fn();

      render(
        <Button onFocus={handleFocus} onBlur={handleBlur}>
          Button
        </Button>
      );

      const button = screen.getByRole('button');

      act(() => { fireEvent.focus(button) });
      expect(handleFocus).toHaveBeenCalledTimes(1);

      act(() => { fireEvent.blur(button) });
      expect(handleBlur).toHaveBeenCalledTimes(1);
    });
  });

describe('Accessibility', () => {
    it('should have proper focus styles', () => {
      render(<Button>Accessible Button</Button>);
      const button = screen.getByRole('button');

      expect(button.className).toContain('focus-visible:outline-none');
      expect(button.className).toContain('focus-visible:ring-2');
    });

    it('should support aria attributes', () => {
      render(
        <Button
          aria-pressed="true"
          aria-expanded="false"
          aria-describedby="description"
        >
          Toggle Button
        </Button>
      );

      const button = screen.getByRole('button');
      expect(button).toHaveAttribute('aria-pressed', 'true');
      expect(button).toHaveAttribute('aria-expanded', 'false');
      expect(button).toHaveAttribute('aria-describedby', 'description');
    });

    it('should have proper disabled styles and attributes', () => {
      render(<Button disabled>Disabled</Button>);
      const button = screen.getByRole('button');

      expect(button).toHaveAttribute('disabled');
      expect(button.className).toContain('disabled:pointer-events-none');
    });
  });

describe('Edge Cases', () => {
    it('should handle empty children', () => {
      render(<Button />);
      const button = screen.getByRole('button');
      expect(button).toBeInTheDocument();
    });

    it('should handle multiple variant and size combinations', () => {
      const combinations: Array<{
        variant: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
        size: 'default' | 'sm' | 'lg' | 'icon';
      }> = [
        { variant: 'destructive', size: 'lg' },
        { variant: 'outline', size: 'sm' },
        { variant: 'ghost', size: 'icon' },
      ];

      combinations.forEach(({ variant, size }) => {
        const { container } = render(
          <Button variant={variant} size={size}>
            Test
          </Button>
        );
        const button = container.querySelector('button');
        expect(button).toBeInTheDocument();

        expect(button?.className).toBeTruthy();
      });
    });

    it('should maintain button behavior with complex children', () => {
      const handleClick = jest.fn();

      render(
        <Button onClick={handleClick}>
          <div>
            <span>Complex</span>
            <span>Children</span>
          </div>
        </Button>
      );

      const button = screen.getByRole('button');
      act(() => { fireEvent.click(button) });

      expect(handleClick).toHaveBeenCalledTimes(1);
    });
  });
});