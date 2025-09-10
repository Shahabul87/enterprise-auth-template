/**
 * Analytics tracking utility for Google Analytics, Mixpanel, and custom events
 * Provides type-safe event tracking with privacy controls and consent management
 */


// Analytics event types
export interface AnalyticsEvent {
  name: string;
  properties?: Record<string, unknown>;
  userId?: string;
  timestamp?: Date;
}

export interface PageViewEvent {
  page: string;
  title?: string;
  referrer?: string;
  userId?: string;
  properties?: Record<string, unknown>;
}

export interface UserEvent {
  userId: string;
  event: string;
  properties?: Record<string, unknown>;
}

export interface ConversionEvent {
  event: string;
  value?: number;
  currency?: string;
  transactionId?: string;
  properties?: Record<string, unknown>;
}

// Configuration interfaces
export interface AnalyticsConfig {
  gtag?: {
    enabled: boolean;
    measurementId: string;
    config?: Record<string, unknown>;
  };
  mixpanel?: {
    enabled: boolean;
    token: string;
    config?: {
      debug?: boolean;
      persistence?: 'localStorage' | 'cookie' | 'sessionStorage';
      property_blacklist?: string[];
      opt_out_tracking_by_default?: boolean;
    };
  };
  custom?: {
    enabled: boolean;
    endpoint?: string;
    apiKey?: string;
  };
  consent?: {
    required: boolean;
    storageKey: string;
    defaultValue: boolean;
  };
  debug?: boolean;
  enabledInDevelopment?: boolean;
}

// Consent management
export interface ConsentState {
  analytics: boolean;
  marketing: boolean;
  functional: boolean;
  timestamp: Date;
}

// Global gtag interface (for TypeScript)
declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
    mixpanel?: {
      init: (token: string, config?: unknown) => void;
      track: (event: string, properties?: Record<string, unknown>) => void;
      identify: (userId: string) => void;
      people: {
        set: (properties: Record<string, unknown>) => void;
        set_once: (properties: Record<string, unknown>) => void;
      };
      register: (properties: Record<string, unknown>) => void;
      opt_out_tracking: () => void;
      opt_in_tracking: () => void;
      has_opted_out_tracking: () => boolean;
    };
  }
}

/**
 * Analytics manager singleton class
 * Handles multiple analytics providers with consent management
 */
class AnalyticsManager {
  private static instance: AnalyticsManager;
  private config: AnalyticsConfig;
  private initialized = false;
  private consentState: ConsentState | null = null;
  private eventQueue: AnalyticsEvent[] = [];
  private debug = false;

  private constructor() {
    this.config = {
      gtag: {
        enabled: false,
        measurementId: process.env['NEXT_PUBLIC_GOOGLE_ANALYTICS_ID'] || '',
      },
      mixpanel: {
        enabled: false,
        token: process.env['NEXT_PUBLIC_MIXPANEL_TOKEN'] || '',
      },
      custom: {
        enabled: false,
        ...(process.env['NEXT_PUBLIC_ANALYTICS_ENDPOINT'] ? { endpoint: process.env['NEXT_PUBLIC_ANALYTICS_ENDPOINT'] } : {}),
        ...(process.env['NEXT_PUBLIC_ANALYTICS_API_KEY'] ? { apiKey: process.env['NEXT_PUBLIC_ANALYTICS_API_KEY'] } : {}),
      },
      consent: {
        required: process.env['NEXT_PUBLIC_REQUIRE_ANALYTICS_CONSENT'] === 'true',
        storageKey: 'analytics-consent',
        defaultValue: false,
      },
      debug: process.env['NODE_ENV'] === 'development',
      enabledInDevelopment: process.env['NEXT_PUBLIC_ANALYTICS_DEV'] === 'true',
    };

    this.debug = this.config.debug || false;
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): AnalyticsManager {
    if (!AnalyticsManager.instance) {
      AnalyticsManager.instance = new AnalyticsManager();
    }
    return AnalyticsManager.instance;
  }

  /**
   * Initialize analytics with configuration
   */
  public async initialize(config?: Partial<AnalyticsConfig>): Promise<void> {
    try {
      if (config) {
        this.config = { ...this.config, ...config };
      }

      // Skip initialization in development unless explicitly enabled
      if (
        process.env['NODE_ENV'] === 'development' &&
        !this.config.enabledInDevelopment
      ) {
        this.log('Analytics disabled in development');
        return;
      }

      // Load consent state
      await this.loadConsentState();

      // Initialize providers if consent is given or not required
      if (!this.config.consent?.required || this.hasConsent('analytics')) {
        await this.initializeProviders();
      }

      this.initialized = true;
      this.log('Analytics initialized successfully');

      // Process queued events
      this.processEventQueue();
    } catch (err) {
      this.log('Failed to initialize analytics:', err);
    }
  }

  /**
   * Initialize analytics providers
   */
  private async initializeProviders(): Promise<void> {
    const promises: Promise<void>[] = [];

    // Initialize Google Analytics
    if (this.config.gtag?.enabled && this.config.gtag.measurementId) {
      promises.push(this.initializeGoogleAnalytics());
    }

    // Initialize Mixpanel
    if (this.config.mixpanel?.enabled && this.config.mixpanel.token) {
      promises.push(this.initializeMixpanel());
    }

    await Promise.allSettled(promises);
  }

  /**
   * Initialize Google Analytics
   */
  private async initializeGoogleAnalytics(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      // Load gtag script
      const script = document.createElement('script');
      script.async = true;
      script.src = `https://www.googletagmanager.com/gtag/js?id=${this.config.gtag?.measurementId}`;
      document.head.appendChild(script);

      await new Promise((resolve) => {
        script.onload = resolve;
      });

      // Initialize gtag
      window.gtag = window.gtag || ((...args: unknown[]) => {
        (window.gtag as unknown as Record<string, unknown>)['q'] = (window.gtag as unknown as Record<string, unknown>)['q'] || [];
        ((window.gtag as unknown as Record<string, unknown>)['q'] as unknown[]).push(args);
      });

      window.gtag('js', new Date());
      window.gtag('config', this.config.gtag?.measurementId || '', {
        send_page_view: false, // We'll handle page views manually
        ...this.config.gtag?.config,
      });

      this.log('Google Analytics initialized');
    } catch {
      
    }
  }

  /**
   * Initialize Mixpanel
   */
  private async initializeMixpanel(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      // Load Mixpanel script
      const script = document.createElement('script');
      script.async = true;
      script.src = 'https://cdn.mxpnl.com/libs/mixpanel-2-latest.min.js';
      document.head.appendChild(script);

      await new Promise((resolve) => {
        script.onload = resolve;
      });

      // Initialize Mixpanel
      if (window.mixpanel && this.config.mixpanel?.token) {
        window.mixpanel.init(this.config.mixpanel.token, {
          debug: this.debug,
          persistence: 'localStorage',
          opt_out_tracking_by_default: this.config.consent?.required || false,
          ...this.config.mixpanel.config,
        });
      }

      this.log('Mixpanel initialized');
    } catch {
      
    }
  }

  /**
   * Track a custom event
   */
  public track(event: AnalyticsEvent): void {
    try {
      if (!this.shouldTrack()) {
        this.eventQueue.push(event);
        return;
      }

      const eventData = {
        ...event,
        timestamp: event.timestamp || new Date(),
      };

      this.log('Tracking event:', eventData);

      // Track with Google Analytics
      if (this.config.gtag?.enabled && window.gtag) {
        window.gtag('event', event.name, {
          custom_parameter_1: event.userId,
          ...event.properties,
        });
      }

      // Track with Mixpanel
      if (this.config.mixpanel?.enabled && window.mixpanel) {
        window.mixpanel.track(event.name, {
          distinct_id: event.userId,
          ...event.properties,
        });
      }

      // Track with custom analytics
      if (this.config.custom?.enabled) {
        this.trackCustomEvent(eventData);
      }
    } catch (err) {
      this.log('Failed to track event:', err);
    }
  }

  /**
   * Track a page view
   */
  public trackPageView(event: PageViewEvent): void {
    try {
      if (!this.shouldTrack()) {
        this.eventQueue.push({
          name: 'page_view',
          properties: event as unknown as Record<string, unknown>,
          ...(event.userId ? { userId: event.userId } : {}),
        });
        return;
      }

      this.log('Tracking page view:', event);

      // Track with Google Analytics
      if (this.config.gtag?.enabled && window.gtag) {
        window.gtag('config', this.config.gtag.measurementId || '', {
          page_path: event.page,
          page_title: event.title,
          custom_parameter_1: event.userId,
        });
      }

      // Track with Mixpanel
      if (this.config.mixpanel?.enabled && window.mixpanel) {
        window.mixpanel.track('Page View', {
          page: event.page,
          title: event.title,
          referrer: event.referrer,
          distinct_id: event.userId,
          ...event.properties,
        });
      }

      // Track with custom analytics
      if (this.config.custom?.enabled) {
        this.trackCustomEvent({
          name: 'page_view',
          properties: event as unknown as Record<string, unknown>,
          ...(event.userId ? { userId: event.userId } : {}),
          timestamp: new Date(),
        });
      }
    } catch (err) {
      this.log('Failed to track page view:', err);
    }
  }

  /**
   * Track a conversion event
   */
  public trackConversion(event: ConversionEvent): void {
    this.track({
      name: 'conversion',
      properties: {
        event: event.event,
        value: event.value,
        currency: event.currency || 'USD',
        transaction_id: event.transactionId,
        ...event.properties,
      },
    });
  }

  /**
   * Identify a user
   */
  public identify(userId: string, properties?: Record<string, unknown>): void {
    try {
      if (!this.shouldTrack()) return;

      this.log('Identifying user:', userId, properties);

      // Identify with Google Analytics
      if (this.config.gtag?.enabled && window.gtag) {
        window.gtag('config', this.config.gtag.measurementId || '', {
          user_id: userId,
        });
      }

      // Identify with Mixpanel
      if (this.config.mixpanel?.enabled && window.mixpanel) {
        window.mixpanel.identify(userId);
        if (properties) {
          window.mixpanel.people.set(properties);
        }
      }

      // Track with custom analytics
      if (this.config.custom?.enabled) {
        this.trackCustomEvent({
          name: 'identify',
          properties: { userId, ...properties },
          userId,
          timestamp: new Date(),
        });
      }
    } catch (err) {
      this.log('Failed to identify user:', err);
    }
  }

  /**
   * Set user properties
   */
  public setUserProperties(userId: string, properties: Record<string, unknown>): void {
    try {
      if (!this.shouldTrack()) return;

      this.log('Setting user properties:', userId, properties);

      // Set with Mixpanel
      if (this.config.mixpanel?.enabled && window.mixpanel) {
        window.mixpanel.people.set(properties);
      }

      // Track with custom analytics
      if (this.config.custom?.enabled) {
        this.trackCustomEvent({
          name: 'set_user_properties',
          properties: { userId, ...properties },
          userId,
          timestamp: new Date(),
        });
      }
    } catch (err) {
      this.log('Failed to set user properties:', err);
    }
  }

  /**
   * Update consent state
   */
  public updateConsent(consent: Partial<ConsentState>): void {
    try {
      this.consentState = {
        ...this.consentState,
        ...consent,
        timestamp: new Date(),
      } as ConsentState;

      // Store consent in localStorage
      if (typeof window !== 'undefined') {
        localStorage.setItem(
          this.config.consent?.storageKey || 'analytics-consent',
          JSON.stringify(this.consentState)
        );
      }

      // Initialize providers if consent was given
      if (consent.analytics && !this.initialized) {
        this.initializeProviders();
        this.processEventQueue();
      }

      // Update Mixpanel opt-out status
      if (this.config.mixpanel?.enabled && window.mixpanel) {
        if (consent.analytics) {
          window.mixpanel.opt_in_tracking();
        } else {
          window.mixpanel.opt_out_tracking();
        }
      }

      this.log('Consent updated:', this.consentState);
    } catch (err) {
      this.log('Failed to update consent:', err);
    }
  }

  /**
   * Get current consent state
   */
  public getConsent(): ConsentState | null {
    return this.consentState;
  }

  /**
   * Check if analytics consent is given
   */
  public hasConsent(type: 'analytics' | 'marketing' | 'functional' = 'analytics'): boolean {
    if (!this.config.consent?.required) return true;
    return this.consentState?.[type] || false;
  }

  /**
   * Load consent state from storage
   */
  private async loadConsentState(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      const stored = localStorage.getItem(
        this.config.consent?.storageKey || 'analytics-consent'
      );
      
      if (stored) {
        const parsed = JSON.parse(stored);
        this.consentState = {
          ...parsed,
          timestamp: new Date(parsed.timestamp),
        };
      } else if (this.config.consent?.defaultValue !== undefined) {
        this.consentState = {
          analytics: this.config.consent.defaultValue,
          marketing: this.config.consent.defaultValue,
          functional: true, // Functional cookies usually default to true
          timestamp: new Date(),
        };
      }
    } catch {
      
    }
  }

  /**
   * Track custom event via API
   */
  private async trackCustomEvent(event: AnalyticsEvent): Promise<void> {
    try {
      if (!this.config.custom?.endpoint) return;

      const response = await fetch(this.config.custom.endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...(this.config.custom.apiKey && {
            'Authorization': `Bearer ${this.config.custom.apiKey}`,
          }),
        },
        body: JSON.stringify(event),
      });

      if (!response.ok) {
        throw new Error(`Custom analytics request failed: ${response.status}`);
      }
    } catch {
      
    }
  }

  /**
   * Process queued events
   */
  private processEventQueue(): void {
    try {
      if (!this.shouldTrack()) return;

      const queue = [...this.eventQueue];
      this.eventQueue = [];

      queue.forEach((event) => {
        this.track(event);
      });

      this.log(`Processed ${queue.length} queued events`);
    } catch {
      
    }
  }

  /**
   * Check if tracking should happen
   */
  private shouldTrack(): boolean {
    if (!this.initialized) return false;
    if (this.config.consent?.required && !this.hasConsent('analytics')) return false;
    
    // Skip in development unless explicitly enabled
    if (
      process.env['NODE_ENV'] === 'development' &&
      !this.config.enabledInDevelopment
    ) {
      return false;
    }

    return true;
  }

  /**
   * Debug logging
   */
  private log(..._args: unknown[]): void {
    if (this.debug) {
      // Debug: [Analytics] ${args.join(' ')}
    }
  }

  /**
   * Clean up resources
   */
  public cleanup(): void {
    this.eventQueue = [];
    this.initialized = false;
    this.consentState = null;
  }
}

// Create and export singleton instance
const analytics = AnalyticsManager.getInstance();

// Convenience functions for common tracking scenarios
export const trackEvent = (name: string, properties?: Record<string, unknown>, userId?: string): void => {
  analytics.track({ 
    name, 
    ...(properties ? { properties } : {}),
    ...(userId ? { userId } : {})
  });
};

export const trackPageView = (page: string, title?: string, userId?: string): void => {
  analytics.trackPageView({ 
    page, 
    ...(title ? { title } : {}),
    ...(userId ? { userId } : {})
  });
};

export const trackUserAction = (action: string, userId: string, properties?: Record<string, unknown>): void => {
  analytics.track({ 
    name: action, 
    ...(properties ? { properties } : {}),
    userId
  });
};

export const trackConversion = (event: string, value?: number, properties?: Record<string, unknown>): void => {
  analytics.trackConversion({ 
    event, 
    ...(value !== undefined ? { value } : {}),
    ...(properties ? { properties } : {})
  });
};

export const identifyUser = (userId: string, properties?: Record<string, unknown>): void => {
  analytics.identify(userId, properties);
};

export const updateAnalyticsConsent = (consent: Partial<ConsentState>): void => {
  analytics.updateConsent(consent);
};

export const initializeAnalytics = (config?: Partial<AnalyticsConfig>): Promise<void> => {
  return analytics.initialize(config);
};

// Export the analytics instance for advanced usage
export { analytics };
export default analytics;