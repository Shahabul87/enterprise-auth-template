
import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Badge } from '@/components/ui/badge';


describe('Badge Component', () => {
  describe('Rendering', () => {
    it('should render badge with text content', () => {
      render(<Badge>New</Badge>);
      expect(screen.getByText('New')).toBeInTheDocument();
    });

    it('should render with children elements', () => {
      render(
        <Badge>
          <span data-testid="icon">✓</span>
          <span>Complete</span>
        </Badge>
      );
      expect(screen.getByTestId('icon')).toBeInTheDocument();
      expect(screen.getByText('Complete')).toBeInTheDocument();
    });

    it('should render as div by default', () => {
      render(<Badge>Default Badge</Badge>);
      const badge = screen.getByText('Default Badge');
      expect(badge.tagName).toBe('DIV');
    });

    it('should apply custom className', () => {
      render(<Badge className="custom-badge-class">Custom</Badge>);
      const badge = screen.getByText('Custom');
      expect(badge).toHaveClass('custom-badge-class');
    });
  });

describe('Variants', () => {
    const variants: Array<'default' | 'secondary' | 'destructive' | 'outline'> = [
      'default',
      'secondary',
      'destructive',
      'outline',
    ];

    variants.forEach((variant) => {
      it(`should apply ${variant} variant classes`, () => {
        render(<Badge variant={variant}>{variant} Badge</Badge>);
        const badge = screen.getByText(`${variant} Badge`);

        // Check if badge has variant-specific classes
        if (variant === 'default') {
          expect(badge.className).toContain('bg-primary');
          expect(badge.className).toContain('text-primary-foreground');
        } else if (variant === 'secondary') {
          expect(badge.className).toContain('bg-secondary');
          expect(badge.className).toContain('text-secondary-foreground');
        } else if (variant === 'destructive') {
          expect(badge.className).toContain('bg-destructive');
          expect(badge.className).toContain('text-destructive-foreground');
        } else if (variant === 'outline') {
          expect(badge.className).toContain('border');
        }
      });
    });

    it('should use default variant when not specified', () => {
      render(<Badge>Default</Badge>);
      const badge = screen.getByText('Default');
      expect(badge.className).toContain('bg-primary');
      expect(badge.className).toContain('text-primary-foreground');
    });
  });

describe('Styling', () => {
    it('should have base styling classes', () => {
      render(<Badge>Styled Badge</Badge>);
      const badge = screen.getByText('Styled Badge');

      expect(badge.className).toContain('inline-flex');
      expect(badge.className).toContain('items-center');
      expect(badge.className).toContain('rounded');
      expect(badge.className).toContain('px-2.5');
      expect(badge.className).toContain('py-0.5');
      expect(badge.className).toContain('text-xs');
      expect(badge.className).toContain('font-semibold');
    });

    it('should apply hover styles for default variant', () => {
      render(<Badge variant="default">Hoverable</Badge>);
      const badge = screen.getByText('Hoverable');
      expect(badge.className).toContain('hover:bg-primary/80');
    });

    it('should apply hover styles for secondary variant', () => {
      render(<Badge variant="secondary">Secondary Hover</Badge>);
      const badge = screen.getByText('Secondary Hover');
      expect(badge.className).toContain('hover:bg-secondary/80');
    });

    it('should apply hover styles for destructive variant', () => {
      render(<Badge variant="destructive">Destructive Hover</Badge>);
      const badge = screen.getByText('Destructive Hover');
      expect(badge.className).toContain('hover:bg-destructive/80');
    });
  });

describe('Common Use Cases', () => {
    it('should render status badges', () => {
      render(
        <div>
          <Badge variant="default">Active</Badge>
          <Badge variant="secondary">Pending</Badge>
          <Badge variant="destructive">Error</Badge>
          <Badge variant="outline">Draft</Badge>
        </div>
      );

      expect(screen.getByText('Active')).toBeInTheDocument();
      expect(screen.getByText('Pending')).toBeInTheDocument();
      expect(screen.getByText('Error')).toBeInTheDocument();
      expect(screen.getByText('Draft')).toBeInTheDocument();
    });

    it('should render count badges', () => {
      render(
        <div>
          <Badge>5</Badge>
          <Badge>99+</Badge>
          <Badge>NEW</Badge>
        </div>
      );

      expect(screen.getByText('5')).toBeInTheDocument();
      expect(screen.getByText('99+')).toBeInTheDocument();
      expect(screen.getByText('NEW')).toBeInTheDocument();
    });

    it('should render with icons', () => {
      render(
        <Badge>
          <svg
            data-testid="check-icon"
            className="mr-1 h-3 w-3"
            fill="none"
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="2"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path d="M5 13l4 4L19 7" />
          </svg>
          Verified
        </Badge>
      );

      expect(screen.getByTestId('check-icon')).toBeInTheDocument();
      expect(screen.getByText('Verified')).toBeInTheDocument();
    });
  });

describe('Accessibility', () => {
    it('should support aria-label', () => {
      render(<Badge aria-label="New feature badge">NEW</Badge>);
      const badge = screen.getByText('NEW');
      expect(badge).toHaveAttribute('aria-label', 'New feature badge');
    });

    it('should support role attribute', () => {
      render(<Badge role="status">Online</Badge>);
      const badge = screen.getByRole('status');
      expect(badge).toHaveTextContent('Online');
    });

    it('should support aria-live for dynamic updates', () => {
      render(<Badge aria-live="polite">3 new messages</Badge>);
      const badge = screen.getByText('3 new messages');
      expect(badge).toHaveAttribute('aria-live', 'polite');
    });

    it('should support data attributes', () => {
      render(
        <Badge data-testid="test-badge" data-status="active">
          Active
        </Badge>
      );
      const badge = screen.getByTestId('test-badge');
      expect(badge).toHaveAttribute('data-status', 'active');
    });
  });

describe('Edge Cases', () => {
    it('should handle empty badge', () => {
      const { container } = render(<Badge />);
      const badge = container.firstChild;
      expect(badge).toBeInTheDocument();
      expect(badge).toHaveClass('inline-flex');
    });

    it('should handle long text content', () => {
      const longText = 'This is a very long badge text that might wrap';
      render(<Badge>{longText}</Badge>);
      expect(screen.getByText(longText)).toBeInTheDocument();
    });

    it('should handle numeric content', () => {
      render(<Badge>{42}</Badge>);
      expect(screen.getByText('42')).toBeInTheDocument();
    });

    it('should handle multiple badges in a container', () => {
      render(
        <div className="flex gap-2">
          <Badge>Badge 1</Badge>
          <Badge variant="secondary">Badge 2</Badge>
          <Badge variant="destructive">Badge 3</Badge>
        </div>
      );

      expect(screen.getByText('Badge 1')).toBeInTheDocument();
      expect(screen.getByText('Badge 2')).toBeInTheDocument();
      expect(screen.getByText('Badge 3')).toBeInTheDocument();
    });

    it('should handle click events', () => {
      const handleClick = jest.fn();
      render(<Badge onClick={handleClick}>Clickable</Badge>);

      const badge = screen.getByText('Clickable');
      badge.click();

      expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('should handle as part of a larger component', () => {
      render(
        <div className="flex items-center">
          <span>User Status:</span>
          <Badge className="ml-2">Online</Badge>
        </div>
      );

      expect(screen.getByText('User Status:')).toBeInTheDocument();
      expect(screen.getByText('Online')).toBeInTheDocument();
      expect(screen.getByText('Online')).toHaveClass('ml-2');
    });

    it('should handle special characters', () => {
      render(<Badge>★ Featured ★</Badge>);
      expect(screen.getByText('★ Featured ★')).toBeInTheDocument();
    });

    it('should work with conditional rendering', () => {
      const ConditionalBadge = ({ show }: { show: boolean }) => (
        <div>{show && <Badge>Visible</Badge>}</div>
      );

      const { rerender } = render(<ConditionalBadge show={false} />);
      expect(screen.queryByText('Visible')).not.toBeInTheDocument();

      rerender(<ConditionalBadge show={true} />);
      expect(screen.getByText('Visible')).toBeInTheDocument();
    });
  });

describe('Integration', () => {
    it('should work within a table cell', () => {
      render(
        <table>
          <tbody>
            <tr>
              <td>
                <Badge>Active</Badge>
              </td>
            </tr>
          </tbody>
        </table>
      );

      expect(screen.getByText('Active')).toBeInTheDocument();
    });

    it('should work within a list', () => {
      render(
        <ul>
          <li>
            Item 1 <Badge>New</Badge>
          </li>
          <li>
            Item 2 <Badge variant="secondary">Updated</Badge>
          </li>
        </ul>
      );

      expect(screen.getByText('New')).toBeInTheDocument();
      expect(screen.getByText('Updated')).toBeInTheDocument();
    });

    it('should work with tooltips', () => {
      render(
        <div title="This item is featured">
          <Badge>Featured</Badge>
        </div>
      );

      const badge = screen.getByText('Featured');
      const container = badge.parentElement;
      expect(container).toHaveAttribute('title', 'This item is featured');
    });
  });
});