/**
 * Feature flags management utility
 * Supports LaunchDarkly, Split.io, custom feature flags, and local overrides
 * Provides type-safe feature flag evaluation with fallback support
 */


// Feature flag types
export interface FeatureFlag {
  key: string;
  enabled: boolean;
  value?: unknown;
  variation?: string;
  reason?: 'TARGETING_MATCH' | 'FALLTHROUGH' | 'OFF' | 'ERROR' | 'RULE_MATCH';
  metadata?: Record<string, unknown>;
}

export interface FeatureFlagUser {
  id: string;
  key?: string;
  name?: string;
  email?: string;
  attributes?: Record<string, unknown>;
  groups?: string[];
}

export interface FeatureFlagContext {
  user?: FeatureFlagUser;
  environment?: string;
  device?: {
    type: 'mobile' | 'tablet' | 'desktop';
    os: string;
    browser: string;
  };
  location?: {
    country?: string;
    region?: string;
    city?: string;
  };
  custom?: Record<string, unknown>;
}

export interface FeatureFlagEvaluation {
  flags: Record<string, FeatureFlag>;
  context: FeatureFlagContext;
  timestamp: Date;
  provider: string;
}

// Configuration interfaces
export interface FeatureFlagConfig {
  launchDarkly?: {
    enabled: boolean;
    clientSideId: string;
    streaming?: boolean;
    bootstrap?: Record<string, unknown>;
    baseUrl?: string;
    eventsUrl?: string;
  };
  split?: {
    enabled: boolean;
    authorizationKey: string;
    core?: {
      authorizationKey: string;
      key: string;
    };
  };
  custom?: {
    enabled: boolean;
    endpoint?: string;
    apiKey?: string;
    pollInterval?: number;
    cache?: boolean;
  };
  local?: {
    enabled: boolean;
    overrides?: Record<string, boolean | string | number>;
    storageKey?: string;
    adminMode?: boolean;
  };
  defaults?: Record<string, boolean | string | number>;
  enabledInDevelopment?: boolean;
  enableLocalStorage?: boolean;
  enableAnalytics?: boolean;
  debug?: boolean;
}

// Global SDK interfaces
declare global {
  interface Window {
    LDClient?: {
      initialize: (clientSideId: string, context: unknown, options?: unknown) => Promise<unknown>;
      variation: (key: string, defaultValue?: unknown) => unknown;
      allFlags: () => Record<string, unknown>;
      identify: (context: unknown) => Promise<void>;
      on: (event: string, callback: (flags: Record<string, unknown>) => void) => void;
      off: (event: string, callback: (flags: Record<string, unknown>) => void) => void;
      close: () => void;
      track: (key: string, data?: unknown) => void;
    };
    splitSdk?: {
      factory: (config: unknown) => {
        client: () => {
          ready: () => Promise<void>;
          getTreatment: (key: string) => string;
          getTreatments: (keys: string[]) => Record<string, string>;
          track: (trafficType: string, eventType: string, value?: number) => boolean;
          destroy: () => Promise<void>;
        };
      };
    };
  }
}

/**
 * Feature flags manager singleton class
 * Handles multiple providers with fallback and caching
 */
class FeatureFlagsManager {
  private static instance: FeatureFlagsManager;
  private config: FeatureFlagConfig;
  // private _initialized = false;
  private context: FeatureFlagContext = {};
  private flags: Record<string, FeatureFlag> = {};
  private listeners: ((flags: Record<string, FeatureFlag>) => void)[] = [];
  private providers: string[] = [];
  private debug = false;
  private pollInterval: NodeJS.Timeout | null = null;

  private constructor() {
    this.config = {
      launchDarkly: {
        enabled: Boolean(process.env['NEXT_PUBLIC_LAUNCHDARKLY_CLIENT_ID']),
        clientSideId: process.env['NEXT_PUBLIC_LAUNCHDARKLY_CLIENT_ID'] || '',
        streaming: process.env['NEXT_PUBLIC_LAUNCHDARKLY_STREAMING'] !== 'false',
      },
      split: {
        enabled: Boolean(process.env['NEXT_PUBLIC_SPLIT_BROWSER_API_KEY']),
        authorizationKey: process.env['NEXT_PUBLIC_SPLIT_BROWSER_API_KEY'] || '',
      },
      custom: {
        enabled: Boolean(process.env['NEXT_PUBLIC_FEATURE_FLAGS_ENDPOINT']),
        ...(process.env['NEXT_PUBLIC_FEATURE_FLAGS_ENDPOINT'] ? { endpoint: process.env['NEXT_PUBLIC_FEATURE_FLAGS_ENDPOINT'] } : {}),
        ...(process.env['NEXT_PUBLIC_FEATURE_FLAGS_API_KEY'] ? { apiKey: process.env['NEXT_PUBLIC_FEATURE_FLAGS_API_KEY'] } : {}),
        pollInterval: parseInt(process.env['NEXT_PUBLIC_FEATURE_FLAGS_POLL_INTERVAL'] || '60000'),
        cache: process.env['NEXT_PUBLIC_FEATURE_FLAGS_CACHE'] !== 'false',
      },
      local: {
        enabled: true,
        storageKey: 'feature-flags-overrides',
        adminMode: process.env['NEXT_PUBLIC_FEATURE_FLAGS_ADMIN_MODE'] === 'true',
      },
      defaults: {},
      enabledInDevelopment: process.env['NEXT_PUBLIC_FEATURE_FLAGS_DEV'] !== 'false',
      enableLocalStorage: process.env['NEXT_PUBLIC_FEATURE_FLAGS_STORAGE'] !== 'false',
      enableAnalytics: process.env['NEXT_PUBLIC_FEATURE_FLAGS_ANALYTICS'] !== 'false',
      debug: process.env['NODE_ENV'] === 'development',
    };

    this.debug = this.config.debug || false;
    this.loadDefaults();
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): FeatureFlagsManager {
    if (!FeatureFlagsManager.instance) {
      FeatureFlagsManager.instance = new FeatureFlagsManager();
    }
    return FeatureFlagsManager.instance;
  }

  /**
   * Initialize feature flags with configuration
   */
  public async initialize(
    config?: Partial<FeatureFlagConfig>,
    initialContext?: FeatureFlagContext
  ): Promise<void> {
    try {
      if (config) {
        this.config = { ...this.config, ...config };
      }

      if (initialContext) {
        this.context = { ...this.context, ...initialContext };
      }

      // Skip initialization in development unless explicitly enabled
      if (
        process.env['NODE_ENV'] === 'development' &&
        !this.config.enabledInDevelopment
      ) {
        this.log('Feature flags disabled in development');
        return;
      }

      // Detect device and environment context
      await this.detectContext();

      const promises: Promise<void>[] = [];

      // Initialize LaunchDarkly
      if (this.config.launchDarkly?.enabled && this.config.launchDarkly.clientSideId) {
        promises.push(this.initializeLaunchDarkly());
      }

      // Initialize Split.io
      if (this.config.split?.enabled && this.config.split.authorizationKey) {
        promises.push(this.initializeSplit());
      }

      // Initialize custom provider
      if (this.config.custom?.enabled) {
        promises.push(this.initializeCustomProvider());
      }

      await Promise.allSettled(promises);

      // Load local overrides
      if (this.config.local?.enabled) {
        this.loadLocalOverrides();
      }

      // this._initialized = true;
      this.log('Feature flags initialized successfully', {
        providers: this.providers,
        context: this.context,
      });

      // Notify listeners
      this.notifyListeners();
    } catch (error) {
      this.log('Failed to initialize feature flags:', error);
    }
  }

  /**
   * Initialize LaunchDarkly
   */
  private async initializeLaunchDarkly(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      // Load LaunchDarkly script
      const script = document.createElement('script');
      script.async = true;
      script.src = 'https://unpkg.com/launchdarkly-js-client-sdk/dist/ldclient.min.js';
      document.head.appendChild(script);

      await new Promise((resolve) => {
        script.onload = resolve;
      });

      if (!window.LDClient) {
        throw new Error('LaunchDarkly SDK failed to load');
      }

      // Convert context to LaunchDarkly format
      const ldContext = {
        kind: 'user',
        key: this.context.user?.id || 'anonymous',
        name: this.context.user?.name,
        email: this.context.user?.email,
        custom: {
          ...this.context.user?.attributes,
          ...this.context.custom,
          device: this.context.device,
          location: this.context.location,
        },
      };

      // Initialize client
      const ldClient = await window.LDClient.initialize(
        this.config.launchDarkly?.clientSideId || '',
        ldContext,
        {
          streaming: this.config.launchDarkly?.streaming,
          bootstrap: this.config.launchDarkly?.bootstrap,
          baseUrl: this.config.launchDarkly?.baseUrl,
          eventsUrl: this.config.launchDarkly?.eventsUrl,
        }
      );

      // Get all flags
      const allFlags = (ldClient as unknown as { allFlags: () => Record<string, unknown> }).allFlags();
      Object.entries(allFlags).forEach(([key, value]) => {
        this.flags[key] = {
          key,
          enabled: Boolean(value),
          value,
          variation: String(value),
          reason: 'TARGETING_MATCH',
          metadata: { provider: 'LaunchDarkly' },
        };
      });

      // Listen for flag changes
      (ldClient as unknown as { on: (event: string, callback: (flags: Record<string, unknown>) => void) => void }).on('change', (flags: Record<string, unknown>) => {
        Object.entries(flags).forEach(([key, value]) => {
          this.flags[key] = {
            key,
            enabled: Boolean(value),
            value,
            variation: String(value),
            reason: 'TARGETING_MATCH',
            metadata: { provider: 'LaunchDarkly' },
          };
        });
        this.notifyListeners();
      });

      this.providers.push('LaunchDarkly');
      this.log('LaunchDarkly initialized');
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Initialize Split.io
   */
  private async initializeSplit(): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      // Load Split.io script
      const script = document.createElement('script');
      script.async = true;
      script.src = 'https://cdn.split.io/sdk/split-10.x.x.min.js';
      document.head.appendChild(script);

      await new Promise((resolve) => {
        script.onload = resolve;
      });

      if (!window.splitSdk) {
        throw new Error('Split.io SDK failed to load');
      }

      // Initialize Split factory
      const factory = window.splitSdk.factory({
        core: {
          authorizationKey: this.config.split?.authorizationKey,
          key: this.context.user?.id || 'anonymous',
        },
        startup: {
          readyTimeout: 5000,
        },
        features: {
          [this.context.user?.id || 'anonymous']: this.context.user?.attributes || {},
        },
      });

      const client = factory.client();
      await client.ready();

      // Get initial treatments (Split.io term for flag evaluations)
      // Note: This would need to be expanded with actual flag keys from your Split.io setup
      const flagKeys = Object.keys(this.config.defaults || {});
      const treatments = client.getTreatments(flagKeys);

      Object.entries(treatments).forEach(([key, treatment]) => {
        this.flags[key] = {
          key,
          enabled: treatment === 'on' || treatment === 'true',
          value: treatment,
          variation: treatment,
          reason: 'TARGETING_MATCH',
          metadata: { provider: 'Split.io' },
        };
      });

      this.providers.push('Split.io');
      this.log('Split.io initialized');
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Initialize custom feature flags provider
   */
  private async initializeCustomProvider(): Promise<void> {
    try {
      if (!this.config.custom?.endpoint) return;

      await this.fetchCustomFlags();

      // Set up polling if enabled
      if (this.config.custom.pollInterval && this.config.custom.pollInterval > 0) {
        this.pollInterval = setInterval(() => {
          this.fetchCustomFlags();
        }, this.config.custom.pollInterval);
      }

      this.providers.push('Custom');
      this.log('Custom provider initialized');
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Fetch flags from custom endpoint
   */
  private async fetchCustomFlags(): Promise<void> {
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
        body: JSON.stringify({
          context: this.context,
          timestamp: new Date().toISOString(),
        }),
      });

      if (!response.ok) {
        throw new Error(`Custom provider request failed: ${response.status}`);
      }

      const data = await response.json();
      
      if (data.flags && typeof data.flags === 'object') {
        Object.entries(data.flags).forEach(([key, value]: [string, unknown]) => {
          this.flags[key] = {
            key,
            enabled: Boolean(value),
            value,
            variation: String(value),
            reason: 'TARGETING_MATCH',
            metadata: { provider: 'Custom', ...data.metadata },
          };
        });

        this.notifyListeners();
      }
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Detect device and environment context
   */
  private async detectContext(): Promise<void> {
    if (typeof window === 'undefined') return;

    // Detect device type
    const userAgent = navigator.userAgent;
    let deviceType: 'mobile' | 'tablet' | 'desktop' = 'desktop';

    if (/Mobile|Android|iPhone/.test(userAgent)) {
      deviceType = 'mobile';
    } else if (/Tablet|iPad/.test(userAgent)) {
      deviceType = 'tablet';
    }

    // Detect OS and browser
    const os = /Windows/.test(userAgent) ? 'Windows' :
              /Mac/.test(userAgent) ? 'macOS' :
              /Linux/.test(userAgent) ? 'Linux' :
              /Android/.test(userAgent) ? 'Android' :
              /iOS/.test(userAgent) ? 'iOS' : 'Unknown';

    const browser = /Chrome/.test(userAgent) ? 'Chrome' :
                   /Firefox/.test(userAgent) ? 'Firefox' :
                   /Safari/.test(userAgent) ? 'Safari' :
                   /Edge/.test(userAgent) ? 'Edge' : 'Unknown';

    this.context = {
      ...this.context,
      environment: process.env['NODE_ENV'],
      device: {
        type: deviceType,
        os,
        browser,
      },
    };

    // Try to detect location (requires permission)
    try {
      // This would typically integrate with a geolocation service
      // For now, we'll leave it empty or use IP-based detection
      this.context.location = {};
    } catch {
      // Location detection failed - continue without it
    }
  }

  /**
   * Load default flag values
   */
  private loadDefaults(): void {
    if (!this.config.defaults) return;

    Object.entries(this.config.defaults).forEach(([key, value]) => {
      this.flags[key] = {
        key,
        enabled: Boolean(value),
        value,
        variation: String(value),
        reason: 'FALLTHROUGH',
        metadata: { provider: 'Default' },
      };
    });
  }

  /**
   * Load local overrides from localStorage
   */
  private loadLocalOverrides(): void {
    try {
      if (typeof window === 'undefined' || !this.config.enableLocalStorage) return;

      const stored = localStorage.getItem(this.config.local?.storageKey || 'feature-flags-overrides');
      if (!stored) return;

      const overrides = JSON.parse(stored);
      Object.entries(overrides).forEach(([key, value]: [string, unknown]) => {
        this.flags[key] = {
          key,
          enabled: Boolean(value),
          value,
          variation: String(value),
          reason: 'RULE_MATCH',
          metadata: { provider: 'LocalOverride' },
        };
      });

      this.log('Loaded local overrides:', overrides);
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Set local override for a feature flag
   */
  public setLocalOverride(key: string, value: boolean | string | number): void {
    try {
      if (!this.config.local?.adminMode || typeof window === 'undefined') {
        
        return;
      }

      // Update in-memory flag
      this.flags[key] = {
        key,
        enabled: Boolean(value),
        value,
        variation: String(value),
        reason: 'RULE_MATCH',
        metadata: { provider: 'LocalOverride' },
      };

      // Save to localStorage
      if (this.config.enableLocalStorage) {
        const stored = localStorage.getItem(this.config.local?.storageKey || 'feature-flags-overrides') || '{}';
        const overrides = JSON.parse(stored);
        overrides[key] = value;
        localStorage.setItem(
          this.config.local?.storageKey || 'feature-flags-overrides',
          JSON.stringify(overrides)
        );
      }

      this.log('Set local override:', { key, value });
      this.notifyListeners();
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Clear local override for a feature flag
   */
  public clearLocalOverride(key: string): void {
    try {
      if (!this.config.local?.adminMode || typeof window === 'undefined') return;

      // Remove from localStorage
      if (this.config.enableLocalStorage) {
        const stored = localStorage.getItem(this.config.local?.storageKey || 'feature-flags-overrides') || '{}';
        const overrides = JSON.parse(stored);
        delete overrides[key];
        localStorage.setItem(
          this.config.local?.storageKey || 'feature-flags-overrides',
          JSON.stringify(overrides)
        );
      }

      // Re-evaluate flag from providers
      delete this.flags[key];
      this.loadDefaults(); // This will restore the default if no provider override exists

      this.log('Cleared local override:', key);
      this.notifyListeners();
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Evaluate a feature flag
   */
  public isEnabled(key: string, defaultValue = false): boolean {
    try {
      const flag = this.flags[key];
      if (!flag) {
        this.log(`Flag not found: ${key}, using default: ${defaultValue}`);
        return defaultValue;
      }

      this.log(`Flag evaluation: ${key} = ${flag.enabled} (${flag.reason})`);
      return flag.enabled;
    } catch {
      
      return defaultValue;
    }
  }

  /**
   * Get feature flag value (for multivariate flags)
   */
  public getValue<T = unknown>(key: string, defaultValue: T): T {
    try {
      const flag = this.flags[key];
      if (!flag || flag.value === undefined) {
        this.log(`Flag value not found: ${key}, using default:`, defaultValue);
        return defaultValue;
      }

      this.log(`Flag value: ${key} =`, flag.value);
      return flag.value as T;
    } catch {
      
      return defaultValue;
    }
  }

  /**
   * Get feature flag variation
   */
  public getVariation(key: string, defaultValue = 'control'): string {
    try {
      const flag = this.flags[key];
      if (!flag || !flag.variation) {
        this.log(`Flag variation not found: ${key}, using default: ${defaultValue}`);
        return defaultValue;
      }

      this.log(`Flag variation: ${key} = ${flag.variation}`);
      return flag.variation;
    } catch {
      
      return defaultValue;
    }
  }

  /**
   * Get all feature flags
   */
  public getAllFlags(): Record<string, FeatureFlag> {
    return { ...this.flags };
  }

  /**
   * Update user context
   */
  public async updateContext(newContext: Partial<FeatureFlagContext>): Promise<void> {
    try {
      this.context = { ...this.context, ...newContext };
      this.log('Updated context:', this.context);

      // Re-evaluate flags with new context
      if (this.config.custom?.enabled) {
        await this.fetchCustomFlags();
      }

      this.notifyListeners();
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Track feature flag usage (for analytics)
   */
  public track(key: string, eventType = 'flag_evaluated', value?: number): void {
    try {
      if (!this.config.enableAnalytics) return;

      const flag = this.flags[key];
      const eventData = {
        flag_key: key,
        flag_value: flag?.value,
        flag_variation: flag?.variation,
        event_type: eventType,
        user_id: this.context.user?.id,
        timestamp: new Date().toISOString(),
        value,
      };

      this.log('Tracking flag usage:', eventData);

      // Track with LaunchDarkly
      if (this.config.launchDarkly?.enabled && window.LDClient) {
        window.LDClient.track(eventType, eventData);
      }

      // Custom tracking could be added here
    } catch {
      // Feature flag provider error occurred
    }
  }

  /**
   * Add flag change listener
   */
  public onChange(callback: (flags: Record<string, FeatureFlag>) => void): () => void {
    this.listeners.push(callback);
    
    // Return unsubscribe function
    return () => {
      const index = this.listeners.indexOf(callback);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  /**
   * Notify all listeners of flag changes
   */
  private notifyListeners(): void {
    this.listeners.forEach((callback) => {
      try {
        callback({ ...this.flags });
      } catch {
        
      }
    });
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
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }
    this.listeners = [];
    this.flags = {};
    // this._initialized = false;
  }
}

// Create and export singleton instance
const featureFlags = FeatureFlagsManager.getInstance();

// Convenience functions for common feature flag operations
export const isFeatureEnabled = (key: string, defaultValue = false): boolean => {
  return featureFlags.isEnabled(key, defaultValue);
};

export const getFeatureValue = <T = unknown>(key: string, defaultValue: T): T => {
  return featureFlags.getValue(key, defaultValue);
};

export const getFeatureVariation = (key: string, defaultValue = 'control'): string => {
  return featureFlags.getVariation(key, defaultValue);
};

export const trackFeatureUsage = (key: string, eventType?: string, value?: number): void => {
  featureFlags.track(key, eventType, value);
};

export const onFlagsChange = (callback: (flags: Record<string, FeatureFlag>) => void): (() => void) => {
  return featureFlags.onChange(callback);
};

export const updateUserContext = (context: Partial<FeatureFlagContext>): Promise<void> => {
  return featureFlags.updateContext(context);
};

export const setFeatureOverride = (key: string, value: boolean | string | number): void => {
  featureFlags.setLocalOverride(key, value);
};

export const clearFeatureOverride = (key: string): void => {
  featureFlags.clearLocalOverride(key);
};

export const initializeFeatureFlags = (
  config?: Partial<FeatureFlagConfig>,
  context?: FeatureFlagContext
): Promise<void> => {
  return featureFlags.initialize(config, context);
};

// Export the feature flags instance for advanced usage
export { featureFlags };
export default featureFlags;