/**
 * Global Type Declarations for Enterprise Authentication Template
 * 
 * This file contains global type declarations, window augmentations,
 * module declarations, and ambient type definitions used throughout
 * the application.
 * 
 * @fileoverview Global TypeScript type declarations
 * @version 1.0.0
 */

// ================================
// Window and Global Augmentations
// ================================

declare global {
  /**
   * Window object augmentations
   */
  interface Window {
    /** Google Analytics global function */
    gtag?: (
      command: string,
      targetId: string,
      config?: Record<string, unknown>
    ) => void;
    
    /** Google reCAPTCHA */
    grecaptcha?: {
      ready: (callback: () => void) => void;
      execute: (siteKey: string, options?: { action: string }) => Promise<string>;
      render: (container: string | HTMLElement, parameters: Record<string, unknown>) => number;
      reset: (widgetId?: number) => void;
    };
    
    /** Microsoft Clarity analytics */
    clarity?: (action: string, ...args: unknown[]) => void;
    
    /** Hotjar analytics */
    hj?: (event: string, data?: Record<string, unknown>) => void;
    
    /** Stripe.js */
    Stripe?: (publishableKey: string) => {
      elements: () => {
        create: (type: string, options?: Record<string, unknown>) => HTMLElement;
        getElement: (type: string) => HTMLElement | null;
      };
      createToken: (element: HTMLElement) => Promise<{
        token?: { id: string };
        error?: { message: string };
      }>;
    };
    
    /** WebAuthn/FIDO2 Support Check */
    PublicKeyCredential?: {
      create: (options: Record<string, unknown>) => Promise<unknown>;
      get: (options: Record<string, unknown>) => Promise<unknown>;
      isUserVerifyingPlatformAuthenticatorAvailable?: () => Promise<boolean>;
    };
    
    /** Service Worker Registration */
    swRegistration?: ServiceWorkerRegistration;
    
    /** Push Notification Support */
    PushManager?: {
      supportedContentEncodings?: string[];
    };
    
    /** Web Share API */
    navigator: Navigator & {
      share?: (data: {
        title?: string;
        text?: string;
        url?: string;
      }) => Promise<void>;
    };
    
    /** Environment variables (injected at build time) */
    __APP_VERSION__?: string;
    __BUILD_TIME__?: string;
    __COMMIT_HASH__?: string;
    __ENVIRONMENT__?: string;
    
    /** Development mode flag */
    __DEV__?: boolean;
    
    /** Feature flags */
    __FEATURES__?: {
      ENABLE_ANALYTICS?: boolean;
      ENABLE_PUSH_NOTIFICATIONS?: boolean;
      ENABLE_WEBAUTHN?: boolean;
      ENABLE_PWA?: boolean;
      ENABLE_OFFLINE_MODE?: boolean;
    };
  }

  /**
   * Global constants and utilities
   */
  namespace globalThis {
    /** Application name */
    const APP_NAME: string;
    /** API base URL */
    const API_BASE_URL: string;
    /** Current environment */
    const NODE_ENV: 'development' | 'staging' | 'production';
  }

  /**
   * Console augmentations for better debugging
   */
  interface Console {
    /** Debug information (only in development) */
    debug: (message?: unknown, ...optionalParams: unknown[]) => void;
    /** Performance timing */
    time: (label: string) => void;
    timeEnd: (label: string) => void;
    /** Stack trace */
    trace: (message?: unknown, ...optionalParams: unknown[]) => void;
  }
}

// ================================
// Module Declarations
// ================================

/**
 * CSS Module declarations
 */
declare module '*.module.css' {
  const classes: { readonly [key: string]: string };
  export default classes;
}

declare module '*.module.scss' {
  const classes: { readonly [key: string]: string };
  export default classes;
}

declare module '*.module.sass' {
  const classes: { readonly [key: string]: string };
  export default classes;
}

/**
 * Image file declarations
 */
declare module '*.png' {
  const src: string;
  export default src;
}

declare module '*.jpg' {
  const src: string;
  export default src;
}

declare module '*.jpeg' {
  const src: string;
  export default src;
}

declare module '*.gif' {
  const src: string;
  export default src;
}

declare module '*.svg' {
  const src: string;
  export default src;
}

declare module '*.webp' {
  const src: string;
  export default src;
}

declare module '*.ico' {
  const src: string;
  export default src;
}

/**
 * Video file declarations
 */
declare module '*.mp4' {
  const src: string;
  export default src;
}

declare module '*.webm' {
  const src: string;
  export default src;
}

/**
 * Audio file declarations
 */
declare module '*.mp3' {
  const src: string;
  export default src;
}

declare module '*.wav' {
  const src: string;
  export default src;
}

/**
 * Font file declarations
 */
declare module '*.woff' {
  const src: string;
  export default src;
}

declare module '*.woff2' {
  const src: string;
  export default src;
}

declare module '*.eot' {
  const src: string;
  export default src;
}

declare module '*.ttf' {
  const src: string;
  export default src;
}

declare module '*.otf' {
  const src: string;
  export default src;
}

/**
 * Document file declarations
 */
declare module '*.pdf' {
  const src: string;
  export default src;
}

/**
 * Data file declarations
 */
declare module '*.json' {
  const value: Record<string, unknown>;
  export default value;
}

declare module '*.yaml' {
  const value: Record<string, unknown>;
  export default value;
}

declare module '*.yml' {
  const value: Record<string, unknown>;
  export default value;
}

/**
 * Web Worker declarations
 */
declare module '*.worker.ts' {
  class WebpackWorker extends Worker {
    constructor();
  }
  export default WebpackWorker;
}

declare module '*.worker.js' {
  class WebpackWorker extends Worker {
    constructor();
  }
  export default WebpackWorker;
}

// ================================
// Third-Party Library Augmentations
// ================================

/**
 * React Router DOM augmentations
 */
declare module 'react-router-dom' {
  interface RouteObject {
    /** Custom metadata for routes */
    meta?: {
      title?: string;
      description?: string;
      requiresAuth?: boolean;
      roles?: string[];
      permissions?: string[];
    };
  }
}

/**
 * Next.js augmentations
 */
declare module 'next' {
  interface NextApiRequest {
    /** User information from middleware */
    user?: {
      id: string;
      email: string;
      roles: string[];
      permissions: string[];
    };
    
    /** Rate limiting information */
    rateLimit?: {
      limit: number;
      remaining: number;
      reset: number;
    };
  }
}

/**
 * Next.js App Router augmentations
 */
declare module 'next/navigation' {
  interface NavigateOptions {
    /** Custom navigation metadata */
    meta?: Record<string, unknown>;
  }
}

// ================================
// Custom Element Declarations
// ================================

/**
 * Custom HTML elements
 */
declare namespace JSX {
  interface IntrinsicElements {
    /** Custom loading spinner element */
    'loading-spinner': React.DetailedHTMLProps<
      React.HTMLAttributes<HTMLElement> & {
        size?: 'small' | 'medium' | 'large';
        color?: string;
      },
      HTMLElement
    >;
    
    /** Custom toast notification element */
    'toast-notification': React.DetailedHTMLProps<
      React.HTMLAttributes<HTMLElement> & {
        type?: 'info' | 'success' | 'warning' | 'error';
        duration?: number;
        dismissible?: boolean;
      },
      HTMLElement
    >;
  }
}

// ================================
// Utility Types
// ================================

/**
 * Utility type to extract keys from an object type that have specific value types
 * @template T - Object type
 * @template U - Value type to match
 */
type KeysOfType<T, U> = {
  [K in keyof T]: T[K] extends U ? K : never;
}[keyof T];

/**
 * Utility type to make specific properties optional
 * @template T - Original type
 * @template K - Keys to make optional
 */
type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

/**
 * Utility type to make specific properties required
 * @template T - Original type
 * @template K - Keys to make required
 */
type RequiredBy<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

/**
 * Deep readonly utility type
 * @template T - Type to make deeply readonly
 */
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};

/**
 * Deep partial utility type
 * @template T - Type to make deeply partial
 */
type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

/**
 * NonNullable for nested properties
 * @template T - Type to process
 */
type DeepNonNullable<T> = {
  [P in keyof T]-?: T[P] extends object ? DeepNonNullable<T[P]> : NonNullable<T[P]>;
};

/**
 * Extract function parameter types
 * @template T - Function type
 */
type FunctionParams<T extends (...args: unknown[]) => unknown> = T extends (
  ...args: infer P
) => unknown
  ? P
  : never;

/**
 * Extract function return type
 * @template T - Function type
 */
type FunctionReturn<T extends (...args: unknown[]) => unknown> = T extends (
  ...args: unknown[]
) => infer R
  ? R
  : never;

/**
 * Utility type for component props with children
 * @template T - Additional props
 */
type WithChildren<T = Record<string, unknown>> = T & {
  children?: React.ReactNode;
};

/**
 * Utility type for component props with className
 * @template T - Additional props
 */
type WithClassName<T = Record<string, unknown>> = T & {
  className?: string;
};

/**
 * Utility type for component props with common HTML attributes
 * @template T - Additional props
 */
type WithHTMLAttributes<T = Record<string, unknown>> = T & {
  id?: string;
  className?: string;
  style?: React.CSSProperties;
  'data-testid'?: string;
};

// ================================
// Event Handler Types
// ================================

/**
 * Generic event handler type
 * @template T - Event type
 */
type EventHandler<T = Event> = (event: T) => void;

/**
 * Async event handler type
 * @template T - Event type
 */
type AsyncEventHandler<T = Event> = (event: T) => Promise<void>;

/**
 * Form event handlers
 */
type FormEventHandler = EventHandler<React.FormEvent<HTMLFormElement>>;
type InputEventHandler = EventHandler<React.ChangeEvent<HTMLInputElement>>;
type TextAreaEventHandler = EventHandler<React.ChangeEvent<HTMLTextAreaElement>>;
type SelectEventHandler = EventHandler<React.ChangeEvent<HTMLSelectElement>>;

/**
 * Mouse event handlers
 */
type ClickEventHandler = EventHandler<React.MouseEvent<HTMLElement>>;
type DoubleClickEventHandler = EventHandler<React.MouseEvent<HTMLElement>>;
type MouseEventHandler = EventHandler<React.MouseEvent<HTMLElement>>;

/**
 * Keyboard event handlers
 */
type KeyboardEventHandler = EventHandler<React.KeyboardEvent<HTMLElement>>;
type KeyDownEventHandler = EventHandler<React.KeyboardEvent<HTMLElement>>;
type KeyUpEventHandler = EventHandler<React.KeyboardEvent<HTMLElement>>;

// ================================
// API and Networking Types
// ================================

/**
 * Generic API endpoint configuration
 */
interface ApiEndpointConfig {
  url: string;
  method: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  headers?: Record<string, string>;
  timeout?: number;
  retry?: {
    attempts: number;
    delay: number;
  };
}

/**
 * WebSocket message type
 * @template T - Message payload type
 */
interface WebSocketMessage<T = unknown> {
  type: string;
  payload: T;
  id?: string;
  timestamp: string;
}

/**
 * Server-Sent Events type
 * @template T - Event data type
 */
interface ServerSentEvent<T = unknown> {
  type: string;
  data: T;
  id?: string;
  retry?: number;
}

// ================================
// Error Types
// ================================

/**
 * Application error with context
 */
interface AppError extends Error {
  code?: string;
  statusCode?: number;
  context?: Record<string, unknown>;
  timestamp?: string;
}

/**
 * Validation error
 */
interface ValidationError extends AppError {
  field?: string;
  value?: unknown;
  constraint?: string;
}

/**
 * Network error
 */
interface NetworkError extends AppError {
  url?: string;
  method?: string;
  response?: {
    status: number;
    statusText: string;
    data?: unknown;
  };
}

// ================================
// Performance and Analytics Types
// ================================

/**
 * Performance metrics
 */
interface PerformanceMetrics {
  /** Page load time */
  loadTime: number;
  /** First contentful paint */
  fcp: number;
  /** Largest contentful paint */
  lcp: number;
  /** Cumulative layout shift */
  cls: number;
  /** First input delay */
  fid: number;
  /** Time to interactive */
  tti: number;
}

/**
 * Analytics event
 */
interface AnalyticsEvent {
  /** Event category */
  category: string;
  /** Event action */
  action: string;
  /** Event label */
  label?: string;
  /** Event value */
  value?: number;
  /** Custom dimensions */
  customDimensions?: Record<string, string>;
  /** Custom metrics */
  customMetrics?: Record<string, number>;
}

/**
 * User analytics data
 */
interface UserAnalytics {
  /** User ID */
  userId: string;
  /** Session ID */
  sessionId: string;
  /** Page views */
  pageViews: string[];
  /** Events triggered */
  events: AnalyticsEvent[];
  /** Time spent on site */
  timeOnSite: number;
  /** Device information */
  device: {
    type: 'desktop' | 'mobile' | 'tablet';
    os: string;
    browser: string;
  };
  /** Geographic location */
  location?: {
    country: string;
    region: string;
    city: string;
  };
}

// ================================
// Export Global Types
// ================================

/**
 * Re-export utility types for use in other modules
 */
export type {
  KeysOfType,
  PartialBy,
  RequiredBy,
  DeepReadonly,
  DeepPartial,
  DeepNonNullable,
  FunctionParams,
  FunctionReturn,
  WithChildren,
  WithClassName,
  WithHTMLAttributes,
  EventHandler,
  AsyncEventHandler,
  FormEventHandler,
  InputEventHandler,
  TextAreaEventHandler,
  SelectEventHandler,
  ClickEventHandler,
  DoubleClickEventHandler,
  MouseEventHandler,
  KeyboardEventHandler,
  KeyDownEventHandler,
  KeyUpEventHandler,
  ApiEndpointConfig,
  WebSocketMessage,
  ServerSentEvent,
  AppError,
  ValidationError,
  NetworkError,
  PerformanceMetrics,
  AnalyticsEvent,
  UserAnalytics,
};

// Make this file a module
export {};