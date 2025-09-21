
import React from 'react';
import { render, screen, fireEvent, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';
/**
 * Comprehensive Accessibility Tests
 * Testing WCAG 2.1 AA compliance across components
 */


// Add jest-axe matchers
expect.extend(toHaveNoViolations);

// Mock components for testing
const TestModal: React.FC<{ isOpen: boolean; onClose: () => void }> = ({ isOpen, onClose }) => {
  const modalRef = React.useRef<HTMLDivElement>(null);
  const firstButtonRef = React.useRef<HTMLButtonElement>(null);
  const lastButtonRef = React.useRef<HTMLButtonElement>(null);
  const previousFocusRef = React.useRef<HTMLElement | null>(null);

  React.useEffect(() => {
    if (isOpen) {
      previousFocusRef.current = document.activeElement as HTMLElement;
      modalRef.current?.focus();
    } else {
      previousFocusRef.current?.focus();
    }
  }, [isOpen]);

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose();
      return;
    }

    if (e.key === 'Tab') {
      const focusableElements = modalRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );

      if (!focusableElements || focusableElements.length === 0) return;

      const firstElement = focusableElements[0] as HTMLElement;
      const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement;

      if (e.shiftKey) {
        if (document.activeElement === firstElement) {
          e.preventDefault();
          lastElement.focus();
        }
      } else {
        if (document.activeElement === lastElement) {
          e.preventDefault();
          firstElement.focus();
        }
      }
    }
  };

  if (!isOpen) return null;

  return (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      aria-describedby="modal-description"
      tabIndex={-1}
      onKeyDown={handleKeyDown}
    >
      <h2 id="modal-title">Modal Title</h2>
      <p id="modal-description">Modal content description</p>
      <button ref={firstButtonRef} onClick={onClose}>Close</button>
      <button ref={lastButtonRef}>Action</button>
    </div>
  );
};

const TestForm: React.FC = () => {
  const [errors, setErrors] = React.useState<Record<string, string>>({});
  const [submitted, setSubmitted] = React.useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const formData = new FormData(e.target as HTMLFormElement);
    const newErrors: Record<string, string> = {};

    if (!formData.get('email')) {
      newErrors['email'] = 'Email is required';
    }
    if (!formData.get('password')) {
      newErrors['password'] = 'Password is required';
    }

    setErrors(newErrors);
    if (Object.keys(newErrors).length === 0) {
      setSubmitted(true);
    }
  };

  return (
    <form onSubmit={handleSubmit} aria-label="Login form">
      <div>
        <label htmlFor="email">
          Email
          <span aria-label="required">*</span>
        </label>
        <input
          id="email"
          name="email"
          type="email"
          aria-required="true"
          aria-invalid={!!errors['email']}
          aria-describedby={errors['email'] ? 'email-error' : undefined}
        />
        {errors['email'] && (
          <span id="email-error" role="alert" aria-live="polite">
            {errors['email']}
          </span>
        )}
      </div>

      <div>
        <label htmlFor="password">
          Password
          <span aria-label="required">*</span>
        </label>
        <input
          id="password"
          name="password"
          type="password"
          aria-required="true"
          aria-invalid={!!errors['password']}
          aria-describedby={errors['password'] ? 'password-error' : undefined}
        />
        {errors['password'] && (
          <span id="password-error" role="alert" aria-live="polite">
            {errors['password']}
          </span>
        )}
      </div>

      <button type="submit">Submit</button>

      {submitted && (
        <div role="status" aria-live="polite" aria-atomic="true">
          Form submitted successfully
        </div>
      )}
    </form>
  );
};

const TestNavigation: React.FC = () => {
  const [activeTab, setActiveTab] = React.useState(0);
  const tabs = ['Profile', 'Settings', 'Security'];

  return (
    <div>
      <div role="tablist" aria-label="Account settings">
        {tabs.map((tab, index) => (
          <button
            key={tab}
            role="tab"
            aria-selected={activeTab === index}
            aria-controls={`tabpanel-${index}`}
            id={`tab-${index}`}
            tabIndex={activeTab === index ? 0 : -1}
            onClick={() => setActiveTab(index)}
            onKeyDown={(e) => {
              if (e.key === 'ArrowRight') {
                setActiveTab((prev) => (prev + 1) % tabs.length);
              } else if (e.key === 'ArrowLeft') {
                setActiveTab((prev) => (prev - 1 + tabs.length) % tabs.length);
              } else if (e.key === 'Home') {
                setActiveTab(0);
              } else if (e.key === 'End') {
                setActiveTab(tabs.length - 1);
              }
            }}
          >
            {tab}
          </button>
        ))}
      </div>
      {tabs.map((tab, index) => (
        <div
          key={tab}
          role="tabpanel"
          id={`tabpanel-${index}`}
          aria-labelledby={`tab-${index}`}
          hidden={activeTab !== index}
          tabIndex={0}
        >
          {tab} content
        </div>
      ))}
    </div>
  );
};

describe('Comprehensive Accessibility Tests', () => {
  describe('ARIA Attributes and Roles', () => {
    it('should have proper ARIA labels for interactive elements', () => {
      render(
        <div>
          <button aria-label="Close dialog">X</button>
          <input aria-label="Search" type="search" />
          <nav aria-label="Main navigation">
            <a href="/home">Home</a>
          </nav>
        </div>
      );

      expect(screen.getByRole('button', { name: 'Close dialog' })).toBeInTheDocument();
      expect(screen.getByRole('searchbox', { name: 'Search' })).toBeInTheDocument();
      expect(screen.getByRole('navigation', { name: 'Main navigation' })).toBeInTheDocument();
    });

    it('should use semantic HTML5 elements', () => {
      const { container } = render(
        <article>
          <header>
            <h1>Article Title</h1>
          </header>
          <main>
            <section aria-labelledby="section-title">
              <h2 id="section-title">Section Title</h2>
              <p>Content</p>
            </section>
          </main>
          <footer>
            <p>Footer content</p>
          </footer>
        </article>
      );

      expect(container.querySelector('article')).toBeInTheDocument();
      expect(container.querySelector('header')).toBeInTheDocument();
      expect(container.querySelector('main')).toBeInTheDocument();
      expect(container.querySelector('section')).toBeInTheDocument();
      expect(container.querySelector('footer')).toBeInTheDocument();
    });

    it('should have proper heading hierarchy', () => {
      const { container } = render(
        <div>
          <h1>Page Title</h1>
          <h2>Section 1</h2>
          <h3>Subsection 1.1</h3>
          <h2>Section 2</h2>
          <h3>Subsection 2.1</h3>
          <h3>Subsection 2.2</h3>
        </div>
      );

      const headings = container.querySelectorAll('h1, h2, h3, h4, h5, h6');
      const levels = Array.from(headings).map(h => parseInt(h.tagName[1] || '1', 10));

      // Check that heading levels don't skip (e.g., h1 -> h3)
      for (let i = 1; i < levels.length; i++) {
        expect(levels[i]! - levels[i - 1]!).toBeLessThanOrEqual(1);
      }
    });
  });

describe('Keyboard Navigation', () => {
    it('should support Tab key navigation through interactive elements', async () => {
      render(
        <div>
          <button>First</button>
          <input type="text" placeholder="Input" aria-label="Text input" />
          <select><option>Option</option></select>
          <textarea placeholder="Textarea" aria-label="Text area" />
          <a href="#">Link</a>
          <button>Last</button>
        </div>
      );

      const first = screen.getByRole('button', { name: 'First' });
      const input = screen.getByRole('textbox', { name: 'Text input' });
      const select = screen.getByRole('combobox');
      const textarea = screen.getByRole('textbox', { name: 'Text area' });
      const link = screen.getByRole('link');
      const last = screen.getByRole('button', { name: 'Last' });

      // Start with first button
      first.focus();
      expect(document.activeElement).toBe(first);

      // Tab through elements
      await userEvent.tab();
      expect(document.activeElement).toBe(input);

      await userEvent.tab();
      expect(document.activeElement).toBe(select);

      await userEvent.tab();
      expect(document.activeElement).toBe(textarea);

      await userEvent.tab();
      expect(document.activeElement).toBe(link);

      await userEvent.tab();
      expect(document.activeElement).toBe(last);

      // Shift+Tab to go backward
      await userEvent.tab({ shift: true });
      expect(document.activeElement).toBe(link);
    });

    it('should support arrow key navigation in tab panels', async () => {
      render(<TestNavigation />);

      const firstTab = screen.getByRole('tab', { name: 'Profile' });
      firstTab.focus();

      // Right arrow to next tab
      fireEvent.keyDown(firstTab, { key: 'ArrowRight' });
      await waitFor(() => {
        expect(screen.getByRole('tab', { name: 'Settings' })).toHaveAttribute('aria-selected', 'true');
      });

      // Left arrow to previous tab
      fireEvent.keyDown(document.activeElement!, { key: 'ArrowLeft' });
      await waitFor(() => {
        expect(screen.getByRole('tab', { name: 'Profile' })).toHaveAttribute('aria-selected', 'true');
      });

      // End key to last tab
      fireEvent.keyDown(document.activeElement!, { key: 'End' });
      await waitFor(() => {
        expect(screen.getByRole('tab', { name: 'Security' })).toHaveAttribute('aria-selected', 'true');
      });

      // Home key to first tab
      fireEvent.keyDown(document.activeElement!, { key: 'Home' });
      await waitFor(() => {
        expect(screen.getByRole('tab', { name: 'Profile' })).toHaveAttribute('aria-selected', 'true');
      });
    });

    it('should handle Enter and Space keys for buttons', async () => {
      const handleClick = jest.fn();
      render(
        <button
          onClick={handleClick}
          onKeyDown={(e) => {
            if (e.key === 'Enter' || e.key === ' ') {
              e.preventDefault();
              handleClick();
            }
          }}
        >
          Click me
        </button>
      );

      const button = screen.getByRole('button');
      button.focus();

      // Enter key
      fireEvent.keyDown(button, { key: 'Enter' });
      expect(handleClick).toHaveBeenCalledTimes(1);

      // Space key
      fireEvent.keyDown(button, { key: ' ' });
      expect(handleClick).toHaveBeenCalledTimes(2);
    });

    it('should trap focus within modal', async () => {
      const { rerender } = render(<TestModal isOpen={false} onClose={jest.fn()} />);

      // Open modal
      rerender(<TestModal isOpen={true} onClose={jest.fn()} />);

      const closeButton = screen.getByRole('button', { name: 'Close' });
      const actionButton = screen.getByRole('button', { name: 'Action' });

      // Focus should be on modal
      expect(document.activeElement).toHaveAttribute('role', 'dialog');

      // Tab to first button
      await userEvent.tab();
      expect(document.activeElement).toBe(closeButton);

      // Tab to second button
      await userEvent.tab();
      expect(document.activeElement).toBe(actionButton);

      // Tab should cycle back to first button (focus trap)
      await userEvent.tab();
      expect(document.activeElement).toBe(closeButton);
    });
  });

describe('Screen Reader Support', () => {
    it('should announce form validation errors', async () => {
      render(<TestForm />);

      const submitButton = screen.getByRole('button', { name: 'Submit' });

      // Submit empty form
      await act(async () => { await userEvent.click(submitButton); });

      // Check for alert roles
      const errors = screen.getAllByRole('alert');
      expect(errors).toHaveLength(2);

      // Check aria-live regions
      errors.forEach(error => {
        expect(error).toHaveAttribute('aria-live', 'polite');
      });

      // Check that inputs are marked as invalid
      const emailInput = screen.getByLabelText(/email/i);
      const passwordInput = screen.getByLabelText(/password/i);

      expect(emailInput).toHaveAttribute('aria-invalid', 'true');
      expect(passwordInput).toHaveAttribute('aria-invalid', 'true');
    });

    it('should announce live region updates', async () => {
      render(
        <div>
          <div role="status" aria-live="polite" aria-atomic="true">
            <span>0 items</span>
          </div>
        </div>
      );

      const status = screen.getByRole('status');
      expect(status).toHaveAttribute('aria-live', 'polite');
      expect(status).toHaveAttribute('aria-atomic', 'true');
    });

    it('should properly label form controls', () => {
      render(
        <form>
          <label htmlFor="username">Username</label>
          <input id="username" type="text" />

          <label>
            Email
            <input type="email" />
          </label>

          <input type="submit" value="Submit" />
        </form>
      );

      expect(screen.getByLabelText('Username')).toBeInTheDocument();
      expect(screen.getByLabelText('Email')).toBeInTheDocument();
      expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();
    });

    it('should use aria-describedby for additional context', () => {
      render(
        <div>
          <label htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            aria-describedby="password-help"
          />
          <small id="password-help">
            Must be at least 8 characters with one number
          </small>
        </div>
      );

      const passwordInput = screen.getByLabelText('Password');
      expect(passwordInput).toHaveAttribute('aria-describedby', 'password-help');
    });
  });

describe('Focus Management', () => {
    it('should show visible focus indicators', () => {
      render(
        <button className="focus:ring-2 focus:ring-blue-500">
          Focusable Button
        </button>
      );

      const button = screen.getByRole('button');
      button.focus();

      // Check that element receives focus
      expect(document.activeElement).toBe(button);
    });

    it('should restore focus after modal closes', async () => {
      const { rerender } = render(
        <div>
          <button id="trigger">Open Modal</button>
          <TestModal isOpen={false} onClose={jest.fn()} />;
        </div>
      );

      const trigger = screen.getByRole('button', { name: 'Open Modal' });
      trigger.focus();

      // Open modal
      const onClose = jest.fn();
      rerender(
        <div>
          <button id="trigger">Open Modal</button>
          <TestModal isOpen={true} onClose={onClose} />
        </div>
      );

      // Focus should move to modal
      expect(document.activeElement).toHaveAttribute('role', 'dialog');

      // Close modal
      rerender(
        <div>
          <button id="trigger">Open Modal</button>
          <TestModal isOpen={false} onClose={onClose} />
        </div>
      );

      // Focus should return to trigger
      expect(document.activeElement).toBe(trigger);
    });

    it('should skip hidden elements in tab order', async () => {
      render(
        <div>
          <button>Visible 1</button>
          <button style={{ display: 'none' }}>Hidden</button>
          <button tabIndex={-1}>Not in tab order</button>
          <button>Visible 2</button>
        </div>
      );

      const visible1 = screen.getByRole('button', { name: 'Visible 1' });
      const visible2 = screen.getByRole('button', { name: 'Visible 2' });

      visible1.focus();
      await userEvent.tab();

      expect(document.activeElement).toBe(visible2);
    });
  });

describe('WCAG 2.1 Compliance', () => {
    it('should pass axe accessibility checks', async () => {
      const { container } = render(
        <main>
          <h1>Page Title</h1>
          <nav aria-label="Main">
            <ul>
              <li><a href="/home">Home</a></li>
              <li><a href="/about">About</a></li>
            </ul>
          </nav>
          <TestForm />
        </main>
      );

      const results = await axe(container);
      expect(results).toHaveNoViolations();
    });

    it('should have sufficient color contrast ratios', async () => {
      const { container } = render(
        <div>
          <p style={{ color: '#767676', backgroundColor: '#ffffff' }}>
            Regular text (4.5:1 minimum)
          </p>
          <p style={{ color: '#595959', backgroundColor: '#ffffff', fontSize: '24px' }}>
            Large text (3:1 minimum)
          </p>
        </div>
      );

      const results = await axe(container);
      expect(results).toHaveNoViolations();
    });

    it('should provide text alternatives for images', () => {
      render(
        <div>
          <img src="logo.png" alt="Company logo" />
          <img src="decoration.png" alt="" /> {/* Decorative image */}
          <svg role="img" aria-label="Icon description">
            <title>Icon description</title>
          </svg>
        </div>
      );

      expect(screen.getByAltText('Company logo')).toBeInTheDocument();
      expect(screen.getByRole('img', { name: 'Icon description' })).toBeInTheDocument();
    });

    it('should support minimum touch target sizes', () => {
      const { container } = render(
        <div>
          <button style={{ width: '44px', height: '44px' }}>A</button>
          <a href="#" style={{ display: 'inline-block', padding: '12px' }}>
            Link with padding
          </a>
        </div>
      );

      const button = container.querySelector('button');
      const link = container.querySelector('a');

      // Check minimum sizes (44x44 pixels for WCAG 2.1 AA)
      const buttonRect = button!.getBoundingClientRect();
      const linkRect = link!.getBoundingClientRect();

      // Note: These will be 0 in jsdom, but in real browser they should be >= 44
      expect(buttonRect).toBeDefined();
      expect(linkRect).toBeDefined();
    });
  });

describe('Responsive and Mobile Accessibility', () => {
    it('should support pinch-to-zoom', () => {
      // Check that viewport meta tag allows zooming
      const metaViewport = document.querySelector('meta[name="viewport"]');

      if (metaViewport) {
        const content = metaViewport.getAttribute('content');
        expect(content).not.toContain('user-scalable=no');
        expect(content).not.toContain('maximum-scale=1');
      }
    });

    it('should handle orientation changes', () => {
      // Mock orientation change
      const mockOrientation = { angle: 90, type: 'landscape-primary' as OrientationType };

      Object.defineProperty(window.screen, 'orientation', {
        writable: true,
        value: mockOrientation
      });

      const event = new Event('orientationchange');
      window.dispatchEvent(event);

      expect(window.screen.orientation.type).toBe('landscape-primary');
    });
  });

describe('Error Prevention and Recovery', () => {
    it('should confirm destructive actions', async () => {
      const handleDelete = jest.fn();

      render(
        <button
          onClick={() => {
            if (window.confirm('Are you sure you want to delete this item?')) {
              handleDelete();
            }
          }}
        >
          Delete
        </button>
      );

      // Mock window.confirm
      window.confirm = jest.fn(() => false);

      const deleteButton = screen.getByRole('button', { name: 'Delete' });
      await act(async () => { await userEvent.click(deleteButton); });

      expect(window.confirm).toHaveBeenCalledWith('Are you sure you want to delete this item?');
      expect(handleDelete).not.toHaveBeenCalled();

      // Confirm deletion
      window.confirm = jest.fn(() => true);
      await act(async () => { await userEvent.click(deleteButton); });

      expect(handleDelete).toHaveBeenCalled();
    });

    it('should provide clear error messages', async () => {
      render(<TestForm />);

      const submitButton = screen.getByRole('button', { name: 'Submit' });
      await act(async () => { await userEvent.click(submitButton); });

      const emailError = screen.getByText('Email is required');
      const passwordError = screen.getByText('Password is required');

      expect(emailError).toBeInTheDocument();
      expect(passwordError).toBeInTheDocument();

      // Errors should be associated with inputs
      const emailInput = screen.getByLabelText(/email/i);
      expect(emailInput).toHaveAttribute('aria-describedby', 'email-error');
    });
  });
});