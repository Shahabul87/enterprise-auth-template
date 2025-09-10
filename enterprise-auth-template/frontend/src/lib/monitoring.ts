/**
 * Error monitoring and performance tracking utility
 * Integrates with Sentry, LogRocket, and custom error reporting
 * Provides structured error handling, user feedback, and performance metrics
 */


// Error monitoring types
export interface MonitoringEvent {
  level: 'error' | 'warning' | 'info' | 'debug';
  message: string;
  extra?: Record<string, unknown>;
  tags?: Record<string, string>;
  user?: {
    id?: string;
    email?: string;
    username?: string;
    ip_address?: string;
  };
  fingerprint?: string[];
  context?: {
    [key: string]: unknown;
  };
}

export interface PerformanceMetric {
  name: string;
  value: number;
  unit?: 'milliseconds' | 'bytes' | 'count' | 'percentage';
  tags?: Record<string, string>;
  timestamp?: Date;
}

export interface UserFeedback {
  name: string;
  email: string;
  comments: string;
  eventId?: string;
}

export interface BreadcrumbData {
  message: string;
  category?: string;
  level?: 'fatal' | 'error' | 'warning' | 'info' | 'debug';
  data?: Record<string, unknown>;
  timestamp?: Date;
}

// Configuration interfaces
export interface MonitoringConfig {
  sentry?: {
    enabled: boolean;
    dsn: string;
    environment?: string;
    release?: string;
    sampleRate?: number;
    tracesSampleRate?: number;
    attachScreenshot?: boolean;
    beforeSend?: (event: unknown) => unknown | null;
  };
  logRocket?: {
    enabled: boolean;
    appId: string;
    identifyUser?: boolean;
    captureConsole?: boolean;
    networkResponseSanitizer?: (response: unknown) => unknown;
  };
  custom?: {
    enabled: boolean;
    endpoint?: string;
    apiKey?: string;
    enablePerformanceTracking?: boolean;
  };
  enabledInDevelopment?: boolean;
  enableUserFeedback?: boolean;
  enablePerformanceMonitoring?: boolean;
  debug?: boolean;
}

// Proper TypeScript interfaces for monitoring libraries
interface SentryConfig {
  dsn?: string;
  environment?: string;
  release?: string;
  integrations?: unknown[];
  beforeSend?: (event: unknown) => unknown | null;
  sampleRate?: number;
}

interface SentryContext {
  tags?: Record<string, string>;
  extra?: Record<string, unknown>;
  user?: {
    id?: string;
    email?: string;
    username?: string;
  };
}

interface SentryBreadcrumb {
  message?: string;
  category?: string;
  level?: string;
  data?: Record<string, unknown>;
}

interface SentryScope {
  setTag: (key: string, value: string) => void;
  setUser: (user: Record<string, unknown>) => void;
  setContext: (key: string, context: Record<string, unknown>) => void;
}

interface LogRocketConfig {
  console?: boolean;
  network?: {
    requestSanitizer?: (request: unknown) => unknown;
    responseSanitizer?: (response: unknown) => unknown;
  };
}

// Global interface declarations
declare global {
  interface Window {
    Sentry?: {
      init: (config: SentryConfig) => void;
      captureException: (error: Error, context?: SentryContext) => string;
      captureMessage: (message: string, level?: string, context?: SentryContext) => string;
      addBreadcrumb: (breadcrumb: SentryBreadcrumb) => void;
      setUser: (user: Record<string, unknown>) => void;
      setTag: (key: string, value: string) => void;
      setContext: (key: string, context: Record<string, unknown>) => void;
      configureScope: (callback: (scope: SentryScope) => void) => void;
      withScope: (callback: (scope: SentryScope) => void) => void;
      captureUserFeedback: (feedback: Record<string, unknown>) => void;
      startTransaction: (context: Record<string, unknown>) => unknown;
      setLevel: (level: string) => void;
      showReportDialog: (options?: Record<string, unknown>) => void;
    };
    LogRocket?: {
      init: (appId: string, config?: LogRocketConfig) => void;
      identify: (uid: string, traits?: Record<string, unknown>) => void;
      track: (event: string, properties?: Record<string, unknown>) => void;
      captureException: (error: Error) => void;
      getSessionURL: (callback: (url: string) => void) => void;
    };
  }
}

/**
 * Error monitoring manager singleton class
 * Handles error tracking, performance monitoring, and user feedback
 */
class MonitoringManager {
  private static instance: MonitoringManager;
  private config: MonitoringConfig;
  private initialized = false;
  private debug = false;
  private errorQueue: MonitoringEvent[] = [];
  private performanceQueue: PerformanceMetric[] = [];

  private constructor() {
    this.config = {
      sentry: {
        enabled: Boolean(process.env['NEXT_PUBLIC_SENTRY_DSN']),
        dsn: process.env['NEXT_PUBLIC_SENTRY_DSN'] || '',
        environment: process.env['NEXT_PUBLIC_SENTRY_ENVIRONMENT'] || process.env['NODE_ENV'],
        release: process.env['NEXT_PUBLIC_APP_VERSION'] || '1.0.0',
        sampleRate: parseFloat(process.env['NEXT_PUBLIC_SENTRY_SAMPLE_RATE'] || '1.0'),
        tracesSampleRate: parseFloat(process.env['NEXT_PUBLIC_SENTRY_TRACES_SAMPLE_RATE'] || '0.1'),
        attachScreenshot: process.env['NEXT_PUBLIC_SENTRY_ATTACH_SCREENSHOT'] === 'true',
      },
      logRocket: {
        enabled: Boolean(process.env['NEXT_PUBLIC_LOGROCKET_APP_ID']),
        appId: process.env['NEXT_PUBLIC_LOGROCKET_APP_ID'] || '',
        identifyUser: process.env['NEXT_PUBLIC_LOGROCKET_IDENTIFY_USER'] !== 'false',
        captureConsole: process.env['NEXT_PUBLIC_LOGROCKET_CAPTURE_CONSOLE'] !== 'false',
      },
      custom: {
        enabled: Boolean(process.env['NEXT_PUBLIC_MONITORING_ENDPOINT']),
        ...(process.env['NEXT_PUBLIC_MONITORING_ENDPOINT'] ? { endpoint: process.env['NEXT_PUBLIC_MONITORING_ENDPOINT'] } : {}),
        ...(process.env['NEXT_PUBLIC_MONITORING_API_KEY'] ? { apiKey: process.env['NEXT_PUBLIC_MONITORING_API_KEY'] } : {}),
        enablePerformanceTracking: process.env['NEXT_PUBLIC_ENABLE_PERFORMANCE_TRACKING'] !== 'false',
      },
      enabledInDevelopment: process.env['NEXT_PUBLIC_MONITORING_DEV'] === 'true',
      enableUserFeedback: process.env['NEXT_PUBLIC_ENABLE_USER_FEEDBACK'] !== 'false',
      enablePerformanceMonitoring: process.env['NEXT_PUBLIC_ENABLE_PERFORMANCE_MONITORING'] !== 'false',
      debug: process.env['NODE_ENV'] === 'development',
    };

    this.debug = this.config.debug || false;
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): MonitoringManager {
    if (!MonitoringManager.instance) {
      MonitoringManager.instance = new MonitoringManager();
    }
    return MonitoringManager.instance;
  }

  /**
   * Initialize monitoring with configuration
   */
  public async initialize(config?: Partial<MonitoringConfig>): Promise<void> {
    try {
      if (config) {
        this.config = { ...this.config, ...config };
      }

      // Skip initialization in development unless explicitly enabled
      if (
        process.env['NODE_ENV'] === 'development' &&
        !this.config.enabledInDevelopment
      ) {
        this.log('Monitoring disabled in development');
        return;
      }

      const promises: Promise<void>[] = [];

      // Initialize Sentry
      if (this.config.sentry?.enabled && this.config.sentry.dsn) {
        promises.push(this.initializeSentry());
      }

      // Initialize LogRocket
      if (this.config.logRocket?.enabled && this.config.logRocket.appId) {
        promises.push(this.initializeLogRocket());
      }

      await Promise.allSettled(promises);

      this.initialized = true;
      this.log('Monitoring initialized successfully');

      // Setup global error handlers
      this.setupGlobalErrorHandlers();

      // Process queued events
      this.processQueues();
    } catch (error) {
      this.log('Failed to initialize monitoring:', error);
    }
  }

  /**
   * Initialize Sentry
   */
  private async initializeSentry(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      // Load Sentry script
      const script = document.createElement('script');
      script.async = true;
      script.src = 'https://browser.sentry-cdn.com/7.x.x/bundle.tracing.min.js';
      document.head.appendChild(script);

      await new Promise((resolve) => {
        script.onload = resolve;
      });

      if (!window.Sentry) {
        throw new Error('Sentry failed to load');
      }

      // Initialize Sentry
      const sentryConfig: Record<string, unknown> = {};
      if (this.config.sentry?.dsn) sentryConfig['dsn'] = this.config.sentry.dsn;
      if (this.config.sentry?.environment) sentryConfig['environment'] = this.config.sentry.environment;
      if (this.config.sentry?.release) sentryConfig['release'] = this.config.sentry.release;
      if (this.config.sentry?.sampleRate) sentryConfig['sampleRate'] = this.config.sentry.sampleRate;
      
      window.Sentry.init({
        ...sentryConfig,
        // tracesSampleRate: this.config.sentry?.tracesSampleRate,
        // attachScreenshot: this.config.sentry?.attachScreenshot,
        beforeSend: (event: unknown) => {
          // Allow custom filtering
          if (this.config.sentry?.beforeSend) {
            return this.config.sentry.beforeSend(event);
          }
          
          // Filter out development errors
          if (this.config.debug && (event as Record<string, unknown>)['exception']) {
            // Development error logged internally by Sentry
            // Details available in Sentry dashboard or local logs
          }
          
          return event;
        },
        integrations: [
          // Add performance monitoring
          window.Sentry && 'BrowserTracing' in window.Sentry 
            ? new (window.Sentry as unknown as { BrowserTracing: new () => unknown }).BrowserTracing() 
            : undefined,
        ].filter(Boolean),
      });

      this.log('Sentry initialized');
    } catch {
      
    }
  }

  /**
   * Initialize LogRocket
   */
  private async initializeLogRocket(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      // Load LogRocket script
      const script = document.createElement('script');
      script.async = true;
      script.src = 'https://cdn.lr-ingest.com/LogRocket.min.js';
      document.head.appendChild(script);

      await new Promise((resolve) => {
        script.onload = resolve;
      });

      if (!window.LogRocket) {
        throw new Error('LogRocket failed to load');
      }

      // Initialize LogRocket
      const logRocketOptions: Record<string, unknown> = {
        console: true,
      };
      
      if (this.config.logRocket?.networkResponseSanitizer) {
        logRocketOptions['network'] = {
          responseSanitizer: this.config.logRocket.networkResponseSanitizer,
        };
      }
      
      window.LogRocket.init(this.config.logRocket?.appId || '', logRocketOptions);

      // Integrate with Sentry
      if (this.config.sentry?.enabled && window.Sentry) {
        window.LogRocket.getSessionURL((sessionURL: string) => {
          window.Sentry?.setContext('LogRocket', { sessionURL });
        });
      }

      this.log('LogRocket initialized');
    } catch {
      
    }
  }

  /**
   * Set up global error handlers
   */
  private setupGlobalErrorHandlers(): void {
    if (typeof window === 'undefined') return;

    // Handle unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.captureException(
        new Error(`Unhandled promise rejection: ${event.reason}`),
        {
          level: 'error',
          tags: { type: 'unhandled_rejection' },
          extra: { reason: event.reason },
        }
      );
    });

    // Handle global errors
    window.addEventListener('error', (event) => {
      this.captureException(
        event.error || new Error(event.message),
        {
          level: 'error',
          tags: { type: 'global_error' },
          extra: {
            filename: event.filename,
            lineno: event.lineno,
            colno: event.colno,
          },
        }
      );
    });

    // Monitor performance
    if (this.config.enablePerformanceMonitoring) {
      this.setupPerformanceMonitoring();
    }
  }

  /**
   * Set up performance monitoring
   */
  private setupPerformanceMonitoring(): void {
    if (typeof window === 'undefined' || !('performance' in window)) return;

    // Monitor page load metrics
    window.addEventListener('load', () => {
      setTimeout(() => {
        const navigation = performance.getEntriesByType('navigation')[0] as PerformanceNavigationTiming;
        
        if (navigation) {
          this.recordPerformanceMetric({
            name: 'page_load_time',
            value: navigation.loadEventEnd - navigation.loadEventStart,
            unit: 'milliseconds',
            tags: { type: 'navigation' },
          });

          this.recordPerformanceMetric({
            name: 'dom_content_loaded',
            value: navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart,
            unit: 'milliseconds',
            tags: { type: 'navigation' },
          });

          this.recordPerformanceMetric({
            name: 'first_contentful_paint',
            value: navigation.responseEnd - navigation.responseStart,
            unit: 'milliseconds',
            tags: { type: 'navigation' },
          });
        }
      }, 0);
    });

    // Monitor resource loading
    new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        if (entry.entryType === 'resource') {
          const resource = entry as PerformanceResourceTiming;
          this.recordPerformanceMetric({
            name: 'resource_load_time',
            value: resource.responseEnd - resource.requestStart,
            unit: 'milliseconds',
            tags: {
              type: 'resource',
              resource_type: resource.initiatorType,
              resource_name: resource.name,
            },
          });
        }
      });
    }).observe({ entryTypes: ['resource'] });

    // Monitor long tasks
    if ('PerformanceObserver' in window) {
      try {
        new PerformanceObserver((list) => {
          list.getEntries().forEach((entry) => {
            this.recordPerformanceMetric({
              name: 'long_task_duration',
              value: entry.duration,
              unit: 'milliseconds',
              tags: { type: 'long_task' },
            });
          });
        }).observe({ entryTypes: ['longtask'] });
      } catch {
        // Long task observer not supported
        this.log('Long task observer not supported');
      }
    }
  }

  /**
   * Capture an exception
   */
  public captureException(error: Error | string, context?: Partial<MonitoringEvent>): string | null {
    try {
      const errorObj = typeof error === 'string' ? new Error(error) : error;
      const eventData: MonitoringEvent = {
        level: 'error',
        message: errorObj.message,
        extra: {
          ...(errorObj.stack ? { stack: errorObj.stack } : {}),
          name: errorObj.name,
          ...context?.extra,
        },
        tags: context?.tags || {},
        ...(context?.user ? { user: context.user } : {}),
        ...(context?.fingerprint ? { fingerprint: context.fingerprint } : {}),
        ...(context?.context ? { context: context.context } : {}),
      };

      if (!this.initialized) {
        this.errorQueue.push(eventData);
        return null;
      }

      this.log('Capturing exception:', errorObj, context);

      let sentryEventId: string | null = null;

      // Capture with Sentry
      if (this.config.sentry?.enabled && window.Sentry) {
        const sentryContext: Record<string, unknown> = {};
        if (eventData.tags) sentryContext['tags'] = eventData.tags;
        if (eventData.user) sentryContext['user'] = eventData.user;
        if (eventData.extra) sentryContext['extra'] = eventData.extra;
        
        sentryEventId = window.Sentry.captureException(errorObj, sentryContext);
      }

      // Capture with LogRocket
      if (this.config.logRocket?.enabled && window.LogRocket) {
        window.LogRocket.captureException(errorObj);
      }

      // Send to custom endpoint
      if (this.config.custom?.enabled) {
        this.sendToCustomEndpoint('error', eventData);
      }

      return sentryEventId;
    } catch {
      
      return null;
    }
  }

  /**
   * Capture a message
   */
  public captureMessage(message: string, level: 'error' | 'warning' | 'info' | 'debug' = 'info', context?: Partial<MonitoringEvent>): string | null {
    try {
      const eventData: MonitoringEvent = {
        level,
        message,
        extra: context?.extra || {},
        tags: context?.tags || {},
        ...(context?.user ? { user: context.user } : {}),
        ...(context?.context ? { context: context.context } : {}),
      };

      if (!this.initialized) {
        this.errorQueue.push(eventData);
        return null;
      }

      this.log('Capturing message:', message, level, context);

      let sentryEventId: string | null = null;

      // Capture with Sentry
      if (this.config.sentry?.enabled && window.Sentry) {
        const messageContext: Record<string, unknown> = {};
        if (eventData.tags) messageContext['tags'] = eventData.tags;
        if (eventData.user) messageContext['user'] = eventData.user;
        if (eventData.extra) messageContext['extra'] = eventData.extra;
        
        sentryEventId = window.Sentry.captureMessage(message, level, messageContext);
      }

      // Send to custom endpoint
      if (this.config.custom?.enabled) {
        this.sendToCustomEndpoint('message', eventData);
      }

      return sentryEventId;
    } catch {
      
      return null;
    }
  }

  /**
   * Add breadcrumb for debugging context
   */
  public addBreadcrumb(data: BreadcrumbData): void {
    try {
      if (!this.initialized) return;

      this.log('Adding breadcrumb:', data);

      // Add to Sentry
      if (this.config.sentry?.enabled && window.Sentry) {
        window.Sentry.addBreadcrumb({
          message: data.message,
          category: data.category || 'custom',
          level: data.level || 'info',
          data: data.data || {},
          // Timestamp is automatically added by Sentry
        });
      }
    } catch {
      
    }
  }

  /**
   * Set user context for error reporting
   */
  public setUser(user: MonitoringEvent['user']): void {
    try {
      if (!user) return;

      this.log('Setting user context:', user);

      // Set user in Sentry
      if (this.config.sentry?.enabled && window.Sentry) {
        window.Sentry.setUser(user);
      }

      // Identify user in LogRocket
      if (this.config.logRocket?.enabled && this.config.logRocket.identifyUser && window.LogRocket && user.id) {
        window.LogRocket.identify(user.id, {
          name: user.username,
          email: user.email,
        });
      }
    } catch {
      
    }
  }

  /**
   * Set tags for error context
   */
  public setTags(tags: Record<string, string>): void {
    try {
      if (!this.initialized) return;

      Object.entries(tags).forEach(([key, value]) => {
        if (this.config.sentry?.enabled && window.Sentry) {
          window.Sentry.setTag(key, value);
        }
      });

      this.log('Set tags:', tags);
    } catch {
      
    }
  }

  /**
   * Record performance metric
   */
  public recordPerformanceMetric(metric: PerformanceMetric): void {
    try {
      const metricData = {
        ...metric,
        timestamp: metric.timestamp || new Date(),
      };

      if (!this.initialized) {
        this.performanceQueue.push(metricData);
        return;
      }

      this.log('Recording performance metric:', metricData);

      // Send to custom endpoint
      if (this.config.custom?.enabled && this.config.custom.enablePerformanceTracking) {
        this.sendToCustomEndpoint('performance', metricData);
      }
    } catch {
      
    }
  }

  /**
   * Capture user feedback
   */
  public captureUserFeedback(feedback: UserFeedback): void {
    try {
      if (!this.config.enableUserFeedback) return;

      this.log('Capturing user feedback:', feedback);

      // Submit to Sentry
      if (this.config.sentry?.enabled && window.Sentry) {
        window.Sentry.captureUserFeedback({
          event_id: feedback.eventId,
          name: feedback.name,
          email: feedback.email,
          comments: feedback.comments,
        });
      }

      // Send to custom endpoint
      if (this.config.custom?.enabled) {
        this.sendToCustomEndpoint('feedback', feedback);
      }
    } catch {
      
    }
  }

  /**
   * Show user feedback dialog (Sentry)
   */
  public showFeedbackDialog(eventId?: string): void {
    try {
      if (!this.config.enableUserFeedback) return;

      if (this.config.sentry?.enabled && window.Sentry) {
        window.Sentry.showReportDialog({
          eventId,
        });
      }
    } catch {
      
    }
  }

  /**
   * Send data to custom monitoring endpoint
   */
  private async sendToCustomEndpoint(type: string, data: unknown): Promise<void> {
    try {
      if (!this.config.custom?.endpoint) return;

      await fetch(this.config.custom.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(this.config.custom.apiKey && {
            'Authorization': `Bearer ${this.config.custom.apiKey}`,
          }),
        },
        body: JSON.stringify({
          type,
          data,
          timestamp: new Date().toISOString(),
        }),
      });
    } catch {
      
    }
  }

  /**
   * Process queued events and metrics
   */
  private processQueues(): void {
    try {
      // Process error queue
      const errorQueue = [...this.errorQueue];
      this.errorQueue = [];

      errorQueue.forEach((event) => {
        if (event.level === 'error') {
          this.captureException(new Error(event.message), event);
        } else {
          this.captureMessage(event.message, event.level, event);
        }
      });

      // Process performance queue
      const performanceQueue = [...this.performanceQueue];
      this.performanceQueue = [];

      performanceQueue.forEach((metric) => {
        this.recordPerformanceMetric(metric);
      });

      this.log(`Processed ${errorQueue.length} error events and ${performanceQueue.length} performance metrics`);
    } catch {
      
    }
  }

  /**
   * Debug logging
   */
  private log(..._unusedArgs: unknown[]): void {
    if (this.debug) {
      
    }
  }

  /**
   * Clean up resources
   */
  public cleanup(): void {
    this.errorQueue = [];
    this.performanceQueue = [];
    this.initialized = false;
  }
}

// Create and export singleton instance
const monitoring = MonitoringManager.getInstance();

// Convenience functions for common monitoring scenarios
export const captureError = (error: Error | string, context?: Partial<MonitoringEvent>): string | null => {
  return monitoring.captureException(error, context);
};

export const captureWarning = (message: string, context?: Partial<MonitoringEvent>): string | null => {
  return monitoring.captureMessage(message, 'warning', context);
};

export const captureInfo = (message: string, context?: Partial<MonitoringEvent>): string | null => {
  return monitoring.captureMessage(message, 'info', context);
};

export const recordPerformance = (
  name: string, 
  value: number, 
  unit?: 'count' | 'milliseconds' | 'bytes' | 'percentage', 
  tags?: Record<string, string>
): void => {
  monitoring.recordPerformanceMetric({ name, value, ...(unit !== undefined ? { unit } : {}), ...(tags !== undefined ? { tags } : {}) });
};

export const addDebugContext = (message: string, data?: Record<string, unknown>): void => {
  monitoring.addBreadcrumb({ message, level: 'info', ...(data !== undefined ? { data } : {}) });
};

export const setUserContext = (user: MonitoringEvent['user']): void => {
  monitoring.setUser(user);
};

export const setErrorTags = (tags: Record<string, string>): void => {
  monitoring.setTags(tags);
};

export const showUserFeedback = (eventId?: string): void => {
  monitoring.showFeedbackDialog(eventId);
};

export const initializeMonitoring = (config?: Partial<MonitoringConfig>): Promise<void> => {
  return monitoring.initialize(config);
};

// Export the monitoring instance for advanced usage
export { monitoring };
export default monitoring;