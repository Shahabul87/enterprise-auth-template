// jest.setup.js
import '@testing-library/jest-dom';

// Mock environment variables
process.env.NEXT_PUBLIC_API_URL = 'http://localhost:8000';
process.env.NEXT_PUBLIC_APP_NAME = 'Enterprise Auth Template';
process.env.NEXT_PUBLIC_APP_VERSION = '1.0.0';

// Mock window.matchMedia only if window is defined
if (typeof window !== 'undefined') {
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: jest.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: jest.fn(), // deprecated
      removeListener: jest.fn(), // deprecated
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
      dispatchEvent: jest.fn(),
    })),
  });

  // Mock hasPointerCapture and setPointerCapture for Radix UI
  Element.prototype.hasPointerCapture = Element.prototype.hasPointerCapture || function() { return false; };
  Element.prototype.setPointerCapture = Element.prototype.setPointerCapture || function() {};
  Element.prototype.releasePointerCapture = Element.prototype.releasePointerCapture || function() {};
}

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  unobserve() {}
  takeRecords() {
    return [];
  }
};

// Mock ResizeObserver
global.ResizeObserver = class ResizeObserver {
  constructor() {}
  disconnect() {}
  observe() {}
  unobserve() {}
};

// Mock for Radix UI Portals - ensure portals render in document
if (typeof document !== 'undefined') {
  // Create a container for all portals
  const portalContainer = document.createElement('div');
  portalContainer.setAttribute('id', 'radix-portal-container');
  document.body.appendChild(portalContainer);

  // Mock document.querySelector to find the portal container
  const originalQuerySelector = document.querySelector;
  document.querySelector = function(selector) {
    if (selector === '[data-radix-portal]' || selector === 'body') {
      return portalContainer;
    }
    return originalQuerySelector.call(this, selector);
  };
}

// Mock Radix UI Select for testing
jest.mock('@radix-ui/react-select', () => {
  const React = require('react');
  return {
    Root: ({ children, open, onOpenChange, value, onValueChange, defaultValue, disabled, ...props }) => {
      const [isOpen, setIsOpen] = React.useState(open || false);
      const [selectedValue, setSelectedValue] = React.useState(value || defaultValue || '');

      React.useEffect(() => {
        if (open !== undefined) {
          setIsOpen(open);
        }
      }, [open]);

      React.useEffect(() => {
        if (value !== undefined) {
          setSelectedValue(value);
        }
      }, [value]);

      const handleOpenChange = React.useCallback((newOpen) => {
        setIsOpen(newOpen);
        if (onOpenChange) {
          onOpenChange(newOpen);
        }
      }, [onOpenChange]);

      const handleValueChange = React.useCallback((newValue) => {
        setSelectedValue(newValue);
        if (onValueChange) {
          onValueChange(newValue);
        }
        // Close the select when a value is selected
        handleOpenChange(false);
      }, [onValueChange, handleOpenChange]);

      return React.Children.map(children, child =>
        React.isValidElement(child) ? React.cloneElement(child, {
          isOpen,
          onOpenChange: handleOpenChange,
          value: selectedValue,
          onValueChange: handleValueChange,
          disabled,
          ...props
        }) : child
      );
    },
    Trigger: React.forwardRef(({ children, isOpen, onOpenChange, value, disabled, ...props }, ref) => (
      <button
        ref={ref}
        role="combobox"
        aria-expanded={isOpen || false}
        onClick={() => !disabled && onOpenChange && onOpenChange(!isOpen)}
        disabled={disabled}
        value={value || ''}
        {...props}
      >
        {children}
      </button>
    )),
    Value: ({ children, placeholder, value }) => <span>{value ? (typeof children === 'function' ? children(value) : value) : placeholder || children}</span>,
    Icon: ({ children }) => children,
    Portal: ({ children }) => children,
    Content: ({ children, isOpen, onOpenChange }) => {
      // Handle escape key to close
      React.useEffect(() => {
        const handleEscape = (e) => {
          if (e.key === 'Escape' && isOpen && onOpenChange) {
            onOpenChange(false);
          }
        };
        if (isOpen) {
          document.addEventListener('keydown', handleEscape);
        }
        return () => document.removeEventListener('keydown', handleEscape);
      }, [isOpen, onOpenChange]);

      return isOpen ? (
        <div role="listbox">
          {React.Children.map(children, child =>
            React.isValidElement(child) ? React.cloneElement(child, { onOpenChange }) : child
          )}
        </div>
      ) : null;
    },
    Viewport: ({ children }) => <div>{children}</div>,
    Item: React.forwardRef(({ children, value, disabled, onValueChange, ...props }, ref) => (
      <div
        ref={ref}
        role="option"
        aria-disabled={disabled}
        onClick={() => !disabled && onValueChange && onValueChange(value)}
        {...props}
      >
        {children}
      </div>
    )),
    ItemText: ({ children }) => children,
    ItemIndicator: ({ children, value, selectedValue }) => value === selectedValue ? children : null,
    Group: ({ children }) => <div>{children}</div>,
    Label: ({ children }) => <div>{children}</div>,
    Separator: () => <div role="separator" className="bg-muted" />,
    ScrollUpButton: ({ children }) => children,
    ScrollDownButton: ({ children }) => children,
  };
});

// Mock crypto.randomUUID and other crypto methods
Object.defineProperty(global, 'crypto', {
  value: {
    randomUUID: () => 'test-uuid-' + Math.random().toString(36).substr(2, 9),
    random: () => Math.random(),
    getRandomValues: (arr) => {
      for (let i = 0; i < arr.length; i++) {
        arr[i] = Math.floor(Math.random() * 256);
      }
      return arr;
    },
  },
});

// Mock ClipboardEvent and DataTransfer for paste events
global.ClipboardEvent = class ClipboardEvent extends Event {
  constructor(type, eventInitDict = {}) {
    super(type, eventInitDict);
    this.clipboardData = eventInitDict.clipboardData || new DataTransfer();
  }
};

global.DataTransfer = class DataTransfer {
  constructor() {
    this.items = [];
    this.files = [];
  }

  setData(format, data) {
    this.items.push({ format, data });
  }

  getData(format) {
    const item = this.items.find(item => item.format === format);
    return item ? item.data : '';
  }
};

// Suppress console errors in tests (optional)
const originalError = console.error;
beforeAll(() => {
  console.error = (...args) => {
    if (
      typeof args[0] === 'string' &&
      (args[0].includes('Warning: ReactDOM.render') ||
       args[0].includes('Unknown event handler property') ||
       args[0].includes('onValueChange') ||
       args[0].includes('onOpenChange') ||
       args[0].includes('act(...)') ||
       args[0].includes('overlapping act() calls'))
    ) {
      return;
    }
    originalError.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
});

// Fix React 18 act() warnings for testing
global.IS_REACT_ACT_ENVIRONMENT = true;

// Make React available globally for tests
global.React = require('react');
