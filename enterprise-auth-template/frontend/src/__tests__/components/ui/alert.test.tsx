
import React from 'react';
import { render, screen, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { AlertCircle, CheckCircle2, XCircle, Info } from 'lucide-react';
/**
 * @jest-environment jsdom
 */


describe('Alert Component', () => {
  describe('Alert Container', () => {
    it('should render alert container', () => {
      render(<Alert data-testid="test-alert">Alert content</Alert>);
      const alert = screen.getByTestId('test-alert');
      expect(alert).toBeInTheDocument();
      expect(alert).toHaveTextContent('Alert content');
    });

    it('should apply custom className', () => {
      render(<Alert className="custom-alert-class" data-testid="custom-alert">Content</Alert>);
      const alert = screen.getByTestId('custom-alert');
      expect(alert).toHaveClass('custom-alert-class');
    });

    it('should have role="alert" by default', () => {
      render(<Alert>Important message</Alert>);
      const alert = screen.getByRole('alert');
      expect(alert).toBeInTheDocument();
    });

    it('should have default alert styles', () => {
      render(<Alert data-testid="styled-alert">Content</Alert>);
      const alert = screen.getByTestId('styled-alert');
      expect(alert.className).toContain('relative');
      expect(alert.className).toContain('w-full');
      expect(alert.className).toContain('rounded-lg');
      expect(alert.className).toContain('border');
      expect(alert.className).toContain('p-4');
    });
  });

describe('Alert Variants', () => {
    it('should render default variant', () => {
      render(<Alert>Default alert</Alert>);
      const alert = screen.getByRole('alert');
      expect(alert.className).toContain('bg-background');
      expect(alert.className).toContain('text-foreground');
    });

    it('should render destructive variant', () => {
      render(<Alert variant="destructive">Error alert</Alert>);
      const alert = screen.getByRole('alert');
      expect(alert.className).toContain('border-destructive/50');
      expect(alert.className).toContain('text-destructive');
    });

    it('should apply custom variant styles', () => {
      render(
        <Alert variant="destructive" data-testid="destructive-alert">
          Critical error
        </Alert>
      );
      const alert = screen.getByTestId('destructive-alert');
      expect(alert.className).toContain('dark:border-destructive');
    });
  });

describe('AlertTitle', () => {
    it('should render alert title', () => {
      render(
        <Alert>
          <AlertTitle>Alert Title</AlertTitle>
        </Alert>
      );
      expect(screen.getByText('Alert Title')).toBeInTheDocument();
    });

    it('should render as h5 element', () => {
      render(
        <Alert>
          <AlertTitle>Heading Title</AlertTitle>
        </Alert>
      );
      const title = screen.getByText('Heading Title');
      expect(title.tagName).toBe('H5');
    });

    it('should apply custom className to title', () => {
      render(
        <Alert>
          <AlertTitle className="custom-title-class">Title</AlertTitle>
        </Alert>
      );
      const title = screen.getByText('Title');
      expect(title).toHaveClass('custom-title-class');
    });

    it('should have default title styles', () => {
      render(
        <Alert>
          <AlertTitle>Styled Title</AlertTitle>
        </Alert>
      );
      const title = screen.getByText('Styled Title');
      expect(title.className).toContain('mb-1');
      expect(title.className).toContain('font-medium');
      expect(title.className).toContain('leading-none');
      expect(title.className).toContain('tracking-tight');
    });
  });

describe('AlertDescription', () => {
    it('should render alert description', () => {
      render(
        <Alert>
          <AlertDescription>Alert description text</AlertDescription>
        </Alert>
      );
      expect(screen.getByText('Alert description text')).toBeInTheDocument();
    });

    it('should render as div element', () => {
      render(
        <Alert>
          <AlertDescription>Description content</AlertDescription>
        </Alert>
      );
      const description = screen.getByText('Description content');
      expect(description.tagName).toBe('DIV');
    });

    it('should apply custom className to description', () => {
      render(
        <Alert>
          <AlertDescription className="custom-desc-class">
            Description
          </AlertDescription>
        </Alert>
      );
      const description = screen.getByText('Description');
      expect(description).toHaveClass('custom-desc-class');
    });

    it('should have default description styles', () => {
      render(
        <Alert>
          <AlertDescription>Styled Description</AlertDescription>
        </Alert>
      );
      const description = screen.getByText('Styled Description');
      expect(description.className).toContain('text-sm');
      expect(description.className).toContain('[&_p]:leading-relaxed');
    });
  });

describe('Complete Alert', () => {
    it('should render alert with title and description', () => {
      render(
        <Alert>
          <AlertTitle>Heads up!</AlertTitle>
          <AlertDescription>
            You can add components to your app using the cli.
          </AlertDescription>
        </Alert>
      );

      expect(screen.getByText('Heads up!')).toBeInTheDocument();
      expect(
        screen.getByText('You can add components to your app using the cli.')
      ).toBeInTheDocument();
    });

    it('should render alert with icon', () => {
      render(
        <Alert>
          <AlertCircle className="h-4 w-4" data-testid="alert-icon" />
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>Something went wrong!</AlertDescription>
        </Alert>
      );

      expect(screen.getByTestId('alert-icon')).toBeInTheDocument();
      expect(screen.getByText('Error')).toBeInTheDocument();
      expect(screen.getByText('Something went wrong!')).toBeInTheDocument();
    });

    it('should render different alert types with appropriate icons', () => {
      const { rerender } = render(
        <Alert variant="default">
          <Info className="h-4 w-4" data-testid="info-icon" />
          <AlertTitle>Info</AlertTitle>
          <AlertDescription>This is an informational message.</AlertDescription>
        </Alert>
      );

      expect(screen.getByTestId('info-icon')).toBeInTheDocument();
      expect(screen.getByText('Info')).toBeInTheDocument();

      rerender(
        <Alert variant="destructive">
          <XCircle className="h-4 w-4" data-testid="error-icon" />
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>An error occurred.</AlertDescription>
        </Alert>
      );

      expect(screen.getByTestId('error-icon')).toBeInTheDocument();
      expect(screen.getByText('Error')).toBeInTheDocument();
    });
  });

describe('Common Use Cases', () => {
    it('should render success alert', () => {
      render(
        <Alert>
          <CheckCircle2 className="h-4 w-4" data-testid="success-icon" />
          <AlertTitle>Success!</AlertTitle>
          <AlertDescription>Your action was completed successfully.</AlertDescription>
        </Alert>
      );

      expect(screen.getByTestId('success-icon')).toBeInTheDocument();
      expect(screen.getByText('Success!')).toBeInTheDocument();
      expect(screen.getByText('Your action was completed successfully.')).toBeInTheDocument();
    });

    it('should render warning alert', () => {
      render(
        <Alert>
          <AlertCircle className="h-4 w-4" data-testid="warning-icon" />
          <AlertTitle>Warning</AlertTitle>
          <AlertDescription>Please review before proceeding.</AlertDescription>
        </Alert>
      );

      expect(screen.getByTestId('warning-icon')).toBeInTheDocument();
      expect(screen.getByText('Warning')).toBeInTheDocument();
      expect(screen.getByText('Please review before proceeding.')).toBeInTheDocument();
    });

    it('should render alert with action button', () => {
      render(
        <Alert>
          <AlertTitle>Update Available</AlertTitle>
          <AlertDescription>
            A new version is available.
            <button className="ml-2 underline">Update now</button>
          </AlertDescription>
        </Alert>
      );

      expect(screen.getByText('Update Available')).toBeInTheDocument();
      expect(screen.getByText('Update now')).toBeInTheDocument();
    });

    it('should render alert with list content', () => {
      render(
        <Alert>
          <AlertTitle>Please fix the following errors:</AlertTitle>
          <AlertDescription>
            <ul className="list-disc pl-5">
              <li>Field 1 is required</li>
              <li>Field 2 must be a valid email</li>
              <li>Field 3 must be at least 8 characters</li>
            </ul>
          </AlertDescription>
        </Alert>
      );

      expect(screen.getByText('Please fix the following errors:')).toBeInTheDocument();
      expect(screen.getByText('Field 1 is required')).toBeInTheDocument();
      expect(screen.getByText('Field 2 must be a valid email')).toBeInTheDocument();
      expect(screen.getByText('Field 3 must be at least 8 characters')).toBeInTheDocument();
    });
  });

describe('Accessibility', () => {
    it('should have appropriate ARIA attributes', () => {
      render(<Alert>Accessible alert</Alert>);
      const alert = screen.getByRole('alert');
      expect(alert).toBeInTheDocument();
    });

    it('should support aria-live attribute', () => {
      render(<Alert aria-live="assertive">Urgent alert</Alert>);
      const alert = screen.getByRole('alert');
      expect(alert).toHaveAttribute('aria-live', 'assertive');
    });

    it('should support aria-label', () => {
      render(<Alert aria-label="System notification">Content</Alert>);
      const alert = screen.getByRole('alert');
      expect(alert).toHaveAttribute('aria-label', 'System notification');
    });

    it('should support aria-describedby', () => {
      render(
        <>
          <Alert aria-describedby="alert-desc">
            <AlertTitle>Title</AlertTitle>
          </Alert>
          <p id="alert-desc">Additional description</p>
        </>
      );
      const alert = screen.getByRole('alert');
      expect(alert).toHaveAttribute('aria-describedby', 'alert-desc');
    });

    it('should maintain semantic structure', () => {
      render(
        <Alert>
          <AlertTitle>Semantic Title</AlertTitle>
          <AlertDescription>Semantic description</AlertDescription>
        </Alert>
      );

      const title = screen.getByText('Semantic Title');
      const description = screen.getByText('Semantic description');

      expect(title.tagName).toBe('H5');
      expect(description.tagName).toBe('DIV');
    });
  });

describe('Edge Cases', () => {
    it('should handle empty alert', () => {
      const { container } = render(<Alert />);
      const alert = container.querySelector('[role="alert"]');
      expect(alert).toBeInTheDocument();
    });

    it('should handle alert with only title', () => {
      render(
        <Alert>
          <AlertTitle>Only Title</AlertTitle>
        </Alert>
      );
      expect(screen.getByText('Only Title')).toBeInTheDocument();
    });

    it('should handle alert with only description', () => {
      render(
        <Alert>
          <AlertDescription>Only Description</AlertDescription>
        </Alert>
      );
      expect(screen.getByText('Only Description')).toBeInTheDocument();
    });

    it('should handle long content', () => {
      const longText = 'Very long alert content '.repeat(50);
      render(
        <Alert>
          <AlertDescription>{longText}</AlertDescription>
        </Alert>
      );
      expect(screen.getByText(longText.trim())).toBeInTheDocument();
    });

    it('should handle HTML content in description', () => {
      render(
        <Alert>
          <AlertDescription>
            <div>
              <strong>Bold text</strong> and <em>italic text</em>
            </div>
          </AlertDescription>
        </Alert>
      );

      expect(screen.getByText('Bold text')).toBeInTheDocument();
      expect(screen.getByText('italic text')).toBeInTheDocument();
    });

    it('should handle multiple alerts', () => {
      render(
        <div>
          <Alert className="mb-4">
            <AlertTitle>Alert 1</AlertTitle>
          </Alert>
          <Alert variant="destructive">
            <AlertTitle>Alert 2</AlertTitle>
          </Alert>
        </div>
      );

      const alerts = screen.getAllByRole('alert');
      expect(alerts).toHaveLength(2);
      expect(screen.getByText('Alert 1')).toBeInTheDocument();
      expect(screen.getByText('Alert 2')).toBeInTheDocument();
    });

    it('should handle conditional rendering', () => {
      const ConditionalAlert = ({ show }: { show: boolean }) => (
        <>
          {show && (
            <Alert>
              <AlertTitle>Conditional Alert</AlertTitle>
            </Alert>
          )}
        </>
      );

      const { rerender } = render(<ConditionalAlert show={false} />);
      expect(screen.queryByRole('alert')).not.toBeInTheDocument();

      rerender(<ConditionalAlert show={true} />);
      expect(screen.getByRole('alert')).toBeInTheDocument();
      expect(screen.getByText('Conditional Alert')).toBeInTheDocument();
    });

    it('should handle custom icons with proper sizing', () => {
      render(
        <Alert>
          <svg
            className="h-4 w-4"
            data-testid="custom-icon"
            viewBox="0 0 24 24"
          >
            <circle cx="12" cy="12" r="10" />
          </svg>
          <AlertTitle>Custom Icon Alert</AlertTitle>
        </Alert>
      );

      const icon = screen.getByTestId('custom-icon');
      expect(icon).toHaveClass('h-4', 'w-4');
    });
  });
});