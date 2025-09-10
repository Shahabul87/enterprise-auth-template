/**
 * Next.js Instrumentation File
 *
 * This file is executed when the Next.js server starts up and is used for
 * performance monitoring, telemetry, and observability setup.
 *
 * @see https://nextjs.org/docs/app/building-your-application/optimizing/instrumentation
 */

// Extend Window interface to include instrumentation globals
declare global {
  interface Window {
    __INSTRUMENTATION__?: {
      trackError: (error: {
        message: string;
        stack?: string;
        filename?: string;
        lineno?: number;
        colno?: number;
        type: string;
        userId?: string;
      }) => void;
      trackEvent: (data: Omit<TelemetryData, 'sessionId' | 'timestamp'>) => void;
      trackPerformance: (metric: PerformanceMetrics) => void;
    };
  }
}

// Performance monitoring and metrics collection
interface PerformanceMetrics {
  timestamp: number;
  route: string;
  method: string;
  duration: number;
  statusCode?: number;
  userAgent?: string;
  userId?: string;
  errorMessage?: string;
}

interface TelemetryData {
  sessionId: string;
  userId?: string;
  timestamp: number;
  event: string;
  properties?: Record<string, unknown>;
  metrics?: Record<string, number>;
}

class InstrumentationService {
  private static instance: InstrumentationService;
  private isEnabled: boolean;
  private metrics: PerformanceMetrics[] = [];
  private telemetryData: TelemetryData[] = [];
  private sessionId: string;

  constructor() {
    this.isEnabled =
      process.env.NODE_ENV === 'production' || process.env['ENABLE_INSTRUMENTATION'] === 'true';
    this.sessionId = this.generateSessionId();

    if (this.isEnabled) {
      this.initializePerformanceObserver();
      this.initializeErrorTracking();
    }
  }

  static getInstance(): InstrumentationService {
    if (!InstrumentationService.instance) {
      InstrumentationService.instance = new InstrumentationService();
    }
    return InstrumentationService.instance;
  }

  private generateSessionId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private initializePerformanceObserver(): void {
    if (typeof window === 'undefined') return;

    // Monitor Core Web Vitals
    this.observeWebVitals();

    // Monitor navigation timing
    this.observeNavigationTiming();

    // Monitor resource loading
    this.observeResourceTiming();
  }

  private observeWebVitals(): void {
    if (typeof window === 'undefined' || !('PerformanceObserver' in window)) return;

    try {
      // Largest Contentful Paint (LCP)
      const lcpObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        const lastEntry = entries[entries.length - 1] as PerformanceEntry & { startTime: number };

        this.trackMetric({
          name: 'lcp',
          value: lastEntry.startTime,
          rating:
            lastEntry.startTime > 2500
              ? 'poor'
              : lastEntry.startTime > 1200
                ? 'needs-improvement'
                : 'good',
        });
      });
      lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] });

      // First Input Delay (FID)
      const fidObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        entries.forEach((entry) => {
          const fidEntry = entry as PerformanceEventTiming;
          const fid = fidEntry.processingStart - fidEntry.startTime;

          this.trackMetric({
            name: 'fid',
            value: fid,
            rating: fid > 300 ? 'poor' : fid > 100 ? 'needs-improvement' : 'good',
          });
        });
      });
      fidObserver.observe({ entryTypes: ['first-input'] });

      // Cumulative Layout Shift (CLS)
      let clsValue = 0;
      const clsObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        entries.forEach((entry) => {
          const layoutShiftEntry = entry as PerformanceEntry & {
            value: number;
            hadRecentInput: boolean;
          };
          if (!layoutShiftEntry.hadRecentInput) {
            clsValue += layoutShiftEntry.value;
          }
        });

        this.trackMetric({
          name: 'cls',
          value: clsValue,
          rating: clsValue > 0.25 ? 'poor' : clsValue > 0.1 ? 'needs-improvement' : 'good',
        });
      });
      clsObserver.observe({ entryTypes: ['layout-shift'] });
    } catch {
      
    }
  }

  private observeNavigationTiming(): void {
    if (typeof window === 'undefined' || !window.performance) return;

    window.addEventListener('load', () => {
      setTimeout(() => {
        const navigation = performance.getEntriesByType(
          'navigation'
        )[0] as PerformanceNavigationTiming;

        if (navigation) {
          this.trackPerformance({
            route: window.location.pathname,
            method: 'GET',
            duration: navigation.loadEventEnd - navigation.startTime,
            statusCode: 200,
          });

          // Track specific timing metrics
          const timingMetrics = {
            ttfb: navigation.responseStart - navigation.startTime, // Time to First Byte
            domContentLoaded: navigation.domContentLoadedEventEnd - navigation.startTime,
            loadComplete: navigation.loadEventEnd - navigation.startTime,
            domInteractive: navigation.domInteractive - navigation.startTime,
          };

          Object.entries(timingMetrics).forEach(([name, value]) => {
            this.trackMetric({ name, value });
          });
        }
      }, 0);
    });
  }

  private observeResourceTiming(): void {
    if (typeof window === 'undefined' || !('PerformanceObserver' in window)) return;

    try {
      const resourceObserver = new PerformanceObserver((list) => {
        const entries = list.getEntries();
        entries.forEach((entry) => {
          const resource = entry as PerformanceResourceTiming;

          // Track slow resources (>1s)
          if (resource.duration > 1000) {
            this.trackTelemetry({
              event: 'slow_resource',
              properties: {
                name: resource.name,
                duration: resource.duration,
                type: resource.initiatorType,
                size: resource.transferSize || 0,
              },
            });
          }
        });
      });
      resourceObserver.observe({ entryTypes: ['resource'] });
    } catch {
      
    }
  }

  private initializeErrorTracking(): void {
    if (typeof window === 'undefined') return;

    // Global error handler
    window.addEventListener('error', (event) => {
      this.trackError({
        message: event.message,
        filename: event.filename,
        lineno: event.lineno,
        colno: event.colno,
        stack: event.error?.stack,
        type: 'javascript_error',
      });
    });

    // Unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      this.trackError({
        message: event.reason?.message || String(event.reason),
        stack: event.reason?.stack,
        type: 'unhandled_promise_rejection',
      });
    });

    // React error boundary integration
    if (typeof window !== 'undefined') {
      window.__INSTRUMENTATION__ = {
        trackError: this.trackError.bind(this),
        trackEvent: this.trackTelemetry.bind(this),
        trackPerformance: this.trackPerformance.bind(this),
      };
    }
  }

  public trackPerformance(metrics: Omit<PerformanceMetrics, 'timestamp'>): void {
    if (!this.isEnabled) return;

    const performanceData: PerformanceMetrics = {
      timestamp: Date.now(),
      ...metrics,
    };

    this.metrics.push(performanceData);

    // In production, send to analytics service
    if (process.env.NODE_ENV === 'production') {
      this.sendToAnalytics('performance', performanceData);
    } else {
      
    }
  }

  public trackTelemetry(data: Omit<TelemetryData, 'sessionId' | 'timestamp'>): void {
    if (!this.isEnabled) return;

    const telemetryData: TelemetryData = {
      sessionId: this.sessionId,
      timestamp: Date.now(),
      ...data,
    };

    this.telemetryData.push(telemetryData);

    // In production, send to analytics service
    if (process.env.NODE_ENV === 'production') {
      this.sendToAnalytics('telemetry', telemetryData);
    } else {
      
    }
  }

  public trackError(error: {
    message: string;
    stack?: string;
    filename?: string;
    lineno?: number;
    colno?: number;
    type: string;
    userId?: string;
  }): void {
    if (!this.isEnabled) return;

    const errorData = {
      ...error,
      timestamp: Date.now(),
      sessionId: this.sessionId,
      url: typeof window !== 'undefined' ? window.location.href : 'unknown',
      userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : 'unknown',
    };

    // In production, send to error tracking service
    if (process.env.NODE_ENV === 'production') {
      this.sendToAnalytics('error', errorData);
    } else {
      
    }
  }

  public trackMetric(metric: {
    name: string;
    value: number;
    rating?: string;
    properties?: Record<string, unknown>;
  }): void {
    if (!this.isEnabled) return;

    const metricData = {
      ...metric,
      timestamp: Date.now(),
      sessionId: this.sessionId,
    };

    // In production, send to metrics service
    if (process.env.NODE_ENV === 'production') {
      this.sendToAnalytics('metric', metricData);
    } else {
      
    }
  }

  public trackUserInteraction(interaction: {
    action: string;
    element?: string;
    value?: string | number;
    properties?: Record<string, unknown>;
  }): void {
    this.trackTelemetry({
      event: 'user_interaction',
      properties: interaction,
    });
  }

  private async sendToAnalytics(type: string, data: unknown): Promise<void> {
    try {
      // Replace with your analytics service endpoint
      const endpoint = process.env['NEXT_PUBLIC_ANALYTICS_ENDPOINT'];

      if (!endpoint) return;

      await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          type,
          data,
          timestamp: Date.now(),
        }),
      });
    } catch {
      
    }
  }

  public getMetrics(): PerformanceMetrics[] {
    return [...this.metrics];
  }

  public getTelemetryData(): TelemetryData[] {
    return [...this.telemetryData];
  }

  public clearMetrics(): void {
    this.metrics = [];
    this.telemetryData = [];
  }
}

// Global instrumentation instance
let instrumentationService: InstrumentationService;

/**
 * Register function called by Next.js when the server starts
 */
export function register(): void {
  if (process.env.NEXT_RUNTIME === 'nodejs') {
    // Server-side initialization
    

    // Initialize any server-side monitoring here
    // Example: APM agents, distributed tracing, etc.
  } else {
    // Edge runtime initialization
    
  }
}

/**
 * Get the instrumentation service instance
 */
export function getInstrumentation(): InstrumentationService {
  if (!instrumentationService) {
    instrumentationService = InstrumentationService.getInstance();
  }
  return instrumentationService;
}

/**
 * Utility functions for easier tracking
 */
export const instrumentation = {
  trackPageView: (page: string, properties?: Record<string, unknown>) => {
    getInstrumentation().trackTelemetry({
      event: 'page_view',
      properties: { page, ...properties },
    });
  },

  trackButtonClick: (buttonId: string, properties?: Record<string, unknown>) => {
    getInstrumentation().trackUserInteraction({
      action: 'click',
      element: buttonId,
      ...(properties ? { properties } : {}),
    });
  },

  trackFormSubmission: (formId: string, success: boolean, properties?: Record<string, unknown>) => {
    getInstrumentation().trackTelemetry({
      event: 'form_submission',
      properties: { formId, success, ...properties },
    });
  },

  trackApiCall: (endpoint: string, method: string, duration: number, statusCode: number) => {
    getInstrumentation().trackPerformance({
      route: endpoint,
      method,
      duration,
      statusCode,
    });
  },

  trackAuthEvent: (event: string, properties?: Record<string, unknown>) => {
    getInstrumentation().trackTelemetry({
      event: 'auth_event',
      properties: { authEvent: event, ...properties },
    });
  },
};

// Initialize instrumentation service for client-side
if (typeof window !== 'undefined') {
  instrumentationService = InstrumentationService.getInstance();
}

// Export types for external use
export type { PerformanceMetrics, TelemetryData };
