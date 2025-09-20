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

// Mock crypto.randomUUID
Object.defineProperty(global, 'crypto', {
  value: {
    randomUUID: () => 'test-uuid-' + Math.random().toString(36).substr(2, 9),
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
       args[0].includes('onOpenChange'))
    ) {
      return;
    }
    originalError.call(console, ...args);
  };
});

afterAll(() => {
  console.error = originalError;
});

// Make React available globally for tests
global.React = require('react');

// Mock window.matchMedia
Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

// Mock IntersectionObserver
global.IntersectionObserver = class IntersectionObserver {
  constructor() {}
  observe() {}
  unobserve() {}
  disconnect() {}
};
