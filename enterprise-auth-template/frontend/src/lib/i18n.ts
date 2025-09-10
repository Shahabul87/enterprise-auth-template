/**
 * Internationalization (i18n) utility
 * Supports multiple i18n libraries, dynamic loading, pluralization, and date/number formatting
 * Provides type-safe translations with namespace support and fallback handling
 */


// i18n types
export interface TranslationResources {
  [language: string]: {
    [namespace: string]: {
      [key: string]: string | TranslationObject;
    };
  };
}

export interface TranslationObject {
  [key: string]: string | TranslationObject;
}

export interface InterpolationValues {
  [key: string]: string | number | boolean | Date;
}

export interface PluralOptions {
  count: number;
  [key: string]: unknown;
}

export interface FormatOptions {
  currency?: string;
  minimumFractionDigits?: number;
  maximumFractionDigits?: number;
  style?: 'currency' | 'percent' | 'decimal';
  useGrouping?: boolean;
}

export interface DateFormatOptions extends Intl.DateTimeFormatOptions {
  locale?: string;
}

export interface LanguageInfo {
  code: string;
  name: string;
  nativeName: string;
  rtl?: boolean;
  region?: string;
  fallback?: string;
}

// Configuration interfaces
export interface I18nConfig {
  defaultLanguage: string;
  fallbackLanguage?: string;
  supportedLanguages: LanguageInfo[];
  namespaces: string[];
  defaultNamespace?: string;
  storage?: {
    enabled: boolean;
    key: string;
    provider: 'localStorage' | 'sessionStorage' | 'cookie';
  };
  detection?: {
    order: ('localStorage' | 'sessionStorage' | 'cookie' | 'navigator' | 'header')[];
    caches: ('localStorage' | 'sessionStorage' | 'cookie')[];
    cookieOptions?: {
      domain?: string;
      path?: string;
      secure?: boolean;
      sameSite?: 'strict' | 'lax' | 'none';
    };
  };
  loading?: {
    loadPath: string;
    allowMultiLoading?: boolean;
    crossDomain?: boolean;
    parseLoadPayload?: (namespace: string, language: string) => string;
  };
  interpolation?: {
    prefix?: string;
    suffix?: string;
    escapeValue?: boolean;
    maxReplaces?: number;
  };
  pluralization?: {
    enabled: boolean;
    rules?: {
      [language: string]: (count: number) => number;
    };
  };
  formatting?: {
    currency?: {
      [language: string]: string;
    };
    dateFormats?: {
      [key: string]: DateFormatOptions;
    };
    numberFormats?: {
      [key: string]: FormatOptions;
    };
  };
  debug?: boolean;
  enabledInDevelopment?: boolean;
}

// Global i18next interface (if using i18next)
declare global {
  interface Window {
    i18next?: {
      init: (options: unknown) => Promise<unknown>;
      changeLanguage: (language: string) => Promise<void>;
      t: (key: string, options?: Record<string, unknown>) => string;
      exists: (key: string, options?: Record<string, unknown>) => boolean;
      getFixedT: (lng: string, ns?: string) => (key: string, options?: Record<string, unknown>) => string;
      loadResources: (lng: string, ns: string, callback?: () => void) => void;
      addResourceBundle: (lng: string, ns: string, resources: Record<string, unknown>, deep?: boolean, overwrite?: boolean) => void;
      on: (event: string, callback: (...args: unknown[]) => void) => void;
      off: (event: string, callback: (...args: unknown[]) => void) => void;
      language: string;
      languages: string[];
      dir: (lng?: string) => 'ltr' | 'rtl';
      format: (value: unknown, format: string, lng?: string, options?: Record<string, unknown>) => string;
    };
  }
}

/**
 * Internationalization manager singleton class
 * Handles translations, language switching, and formatting
 */
class I18nManager {
  private static instance: I18nManager;
  private config: I18nConfig;
  // private initialized = false;
  private currentLanguage = '';
  private resources: TranslationResources = {};
  private listeners: ((language: string) => void)[] = [];
  private loadedNamespaces = new Set<string>();
  private loadingPromises = new Map<string, Promise<void>>();
  private debug = false;

  private constructor() {
    this.config = {
      defaultLanguage: process.env['NEXT_PUBLIC_DEFAULT_LANGUAGE'] || 'en',
      fallbackLanguage: process.env['NEXT_PUBLIC_FALLBACK_LANGUAGE'] || 'en',
      supportedLanguages: [
        { code: 'en', name: 'English', nativeName: 'English' },
        { code: 'es', name: 'Spanish', nativeName: 'Español' },
        { code: 'fr', name: 'French', nativeName: 'Français' },
        { code: 'de', name: 'German', nativeName: 'Deutsch' },
        { code: 'ja', name: 'Japanese', nativeName: '日本語' },
        { code: 'zh', name: 'Chinese', nativeName: '中文' },
        { code: 'ar', name: 'Arabic', nativeName: 'العربية', rtl: true },
      ],
      namespaces: ['common', 'auth', 'dashboard', 'errors'],
      defaultNamespace: 'common',
      storage: {
        enabled: process.env['NEXT_PUBLIC_I18N_STORAGE'] !== 'false',
        key: 'i18n-language',
        provider: 'localStorage',
      },
      detection: {
        order: ['localStorage', 'navigator'],
        caches: ['localStorage'],
      },
      loading: {
        loadPath: '/locales/{{lng}}/{{ns}}.json',
        allowMultiLoading: false,
        crossDomain: false,
      },
      interpolation: {
        prefix: '{{',
        suffix: '}}',
        escapeValue: false,
        maxReplaces: 1000,
      },
      pluralization: {
        enabled: true,
      },
      formatting: {
        currency: {
          en: 'USD',
          es: 'EUR',
          fr: 'EUR',
          de: 'EUR',
          ja: 'JPY',
          zh: 'CNY',
        },
        dateFormats: {
          short: { dateStyle: 'short' },
          medium: { dateStyle: 'medium' },
          long: { dateStyle: 'long' },
          full: { dateStyle: 'full' },
        },
        numberFormats: {
          decimal: { style: 'decimal' },
          currency: { style: 'currency' },
          percent: { style: 'percent' },
        },
      },
      debug: process.env['NODE_ENV'] === 'development',
      enabledInDevelopment: process.env['NEXT_PUBLIC_I18N_DEV'] !== 'false',
    };

    this.debug = this.config.debug || false;
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): I18nManager {
    if (!I18nManager.instance) {
      I18nManager.instance = new I18nManager();
    }
    return I18nManager.instance;
  }

  /**
   * Initialize i18n with configuration
   */
  public async initialize(config?: Partial<I18nConfig>): Promise<void> {
    try {
      if (config) {
        this.config = { ...this.config, ...config };
      }

      // Skip initialization in development unless explicitly enabled
      if (
        process.env['NODE_ENV'] === 'development' &&
        !this.config.enabledInDevelopment
      ) {
        this.log('I18n disabled in development');
        return;
      }

      // Detect initial language
      this.currentLanguage = await this.detectLanguage();

      // Load initial resources
      await this.loadNamespace(this.config.defaultNamespace || 'common', this.currentLanguage);

      // Try to initialize i18next if available
      await this.tryInitializeI18next();

      // this.initialized = true;
      this.log('I18n initialized successfully', {
        language: this.currentLanguage,
        namespaces: Array.from(this.loadedNamespaces),
      });

      // Notify listeners
      this.notifyListeners();
    } catch (error) {
      this.log('Failed to initialize i18n:', error);
    }
  }

  /**
   * Try to initialize i18next if available
   */
  private async tryInitializeI18next(): Promise<void> {
    try {
      if (typeof window !== 'undefined' && window.i18next) {
        await window.i18next.init({
          lng: this.currentLanguage,
          fallbackLng: this.config.fallbackLanguage,
          debug: this.debug,
          ns: this.config.namespaces,
          defaultNS: this.config.defaultNamespace,
          resources: this.convertResourcesToI18next(),
          interpolation: this.config.interpolation,
        });

        // Listen for language changes
        window.i18next.on('languageChanged', ((...args: unknown[]) => {
          const lng = args[0] as string;
          this.currentLanguage = lng;
          this.notifyListeners();
        }) as (...args: unknown[]) => void);

        this.log('i18next initialized');
      }
    } catch (error) {
      this.log('i18next not available or failed to initialize:', error);
    }
  }

  /**
   * Convert internal resources to i18next format
   */
  private convertResourcesToI18next(): Record<string, unknown> {
    const i18nextResources: Record<string, unknown> = {};
    
    Object.entries(this.resources).forEach(([language, namespaces]) => {
      i18nextResources[language] = namespaces;
    });

    return i18nextResources;
  }

  /**
   * Detect user's preferred language
   */
  private async detectLanguage(): Promise<string> {
    try {
      for (const method of this.config.detection?.order || ['localStorage', 'navigator']) {
        let detectedLanguage: string | null = null;

        switch (method) {
          case 'localStorage':
            if (typeof window !== 'undefined' && this.config.storage?.enabled) {
              detectedLanguage = localStorage.getItem(this.config.storage.key);
            }
            break;

          case 'sessionStorage':
            if (typeof window !== 'undefined' && this.config.storage?.enabled) {
              detectedLanguage = sessionStorage.getItem(this.config.storage.key);
            }
            break;

          case 'cookie':
            if (typeof window !== 'undefined' && this.config.storage?.enabled) {
              detectedLanguage = this.getCookie(this.config.storage.key);
            }
            break;

          case 'navigator':
            if (typeof window !== 'undefined') {
              const navigatorLanguage = navigator.language || (navigator as Navigator & { userLanguage?: string }).userLanguage;
              detectedLanguage = navigatorLanguage?.split('-')[0] || null;
            }
            break;
        }

        if (detectedLanguage && this.isLanguageSupported(detectedLanguage)) {
          this.log('Detected language:', detectedLanguage, 'from', method);
          return detectedLanguage;
        }
      }

      this.log('No supported language detected, using default:', this.config.defaultLanguage);
      return this.config.defaultLanguage;
    } catch {
      
      return this.config.defaultLanguage;
    }
  }

  /**
   * Check if language is supported
   */
  private isLanguageSupported(language: string): boolean {
    return this.config.supportedLanguages.some(lang => lang.code === language);
  }

  /**
   * Get cookie value
   */
  private getCookie(name: string): string | null {
    if (typeof document === 'undefined') return null;
    
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) {
      return parts.pop()?.split(';').shift() || null;
    }
    return null;
  }

  /**
   * Set cookie value
   */
  private setCookie(name: string, value: string, options = {}): void {
    if (typeof document === 'undefined') return;

    const defaultOptions = {
      path: '/',
      'max-age': 31536000, // 1 year
      ...this.config.detection?.cookieOptions,
      ...options,
    };

    const cookieString = `${name}=${value}; ${Object.entries(defaultOptions)
      .map(([key, val]) => `${key}=${val}`)
      .join('; ')}`;

    document.cookie = cookieString;
  }

  /**
   * Load translation namespace
   */
  public async loadNamespace(namespace: string, language?: string): Promise<void> {
    try {
      const targetLanguage = language || this.currentLanguage;
      const key = `${targetLanguage}-${namespace}`;

      // Check if already loaded
      if (this.loadedNamespaces.has(key)) {
        return;
      }

      // Check if already loading
      if (this.loadingPromises.has(key)) {
        return this.loadingPromises.get(key);
      }

      // Create loading promise
      const loadingPromise = this.loadNamespaceResources(namespace, targetLanguage);
      this.loadingPromises.set(key, loadingPromise);

      await loadingPromise;

      this.loadedNamespaces.add(key);
      this.loadingPromises.delete(key);

      this.log('Loaded namespace:', namespace, 'for language:', targetLanguage);
    } catch {
      
      this.loadingPromises.delete(`${language || this.currentLanguage}-${namespace}`);
    }
  }

  /**
   * Load namespace resources from server
   */
  private async loadNamespaceResources(namespace: string, language: string): Promise<void> {
    try {
      const url = this.config.loading?.loadPath
        ?.replace('{{lng}}', language)
        ?.replace('{{ns}}', namespace);

      if (!url) {
        throw new Error('No load path configured');
      }

      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      });

      if (!response.ok) {
        throw new Error(`Failed to load translations: ${response.status}`);
      }

      const translations = await response.json();

      // Store in resources
      if (!this.resources[language]) {
        this.resources[language] = {};
      }
      this.resources[language][namespace] = translations;

      // Add to i18next if available
      if (typeof window !== 'undefined' && window.i18next) {
        window.i18next.addResourceBundle(language, namespace, translations, true, false);
      }
    } catch (error) {
      // Try to load fallback language resources
      if (language !== this.config.fallbackLanguage) {
        this.log(`Failed to load ${namespace} for ${language}, trying fallback`);
        await this.loadNamespaceResources(namespace, this.config.fallbackLanguage || 'en');
      } else {
        throw error;
      }
    }
  }

  /**
   * Change current language
   */
  public async changeLanguage(language: string): Promise<void> {
    try {
      if (!this.isLanguageSupported(language)) {
        throw new Error(`Language ${language} is not supported`);
      }

      const previousLanguage = this.currentLanguage;
      this.currentLanguage = language;

      // Load required namespaces for new language
      const loadPromises = this.config.namespaces.map(ns => 
        this.loadNamespace(ns, language)
      );
      await Promise.all(loadPromises);

      // Update storage
      await this.saveLanguagePreference(language);

      // Update i18next if available
      if (typeof window !== 'undefined' && window.i18next) {
        await window.i18next.changeLanguage(language);
      }

      // Update document language and direction
      this.updateDocumentLanguage(language);

      this.log('Changed language from', previousLanguage, 'to', language);
      this.notifyListeners();
    } catch {
      
      this.currentLanguage = this.config.fallbackLanguage || 'en';
    }
  }

  /**
   * Save language preference to storage
   */
  private async saveLanguagePreference(language: string): Promise<void> {
    try {
      if (!this.config.storage?.enabled || typeof window === 'undefined') return;

      const { provider, key } = this.config.storage;

      switch (provider) {
        case 'localStorage':
          localStorage.setItem(key, language);
          break;
        case 'sessionStorage':
          sessionStorage.setItem(key, language);
          break;
        case 'cookie':
          this.setCookie(key, language);
          break;
      }
    } catch {
      // i18n operation error occurred
    }
  }

  /**
   * Update document language attributes
   */
  private updateDocumentLanguage(language: string): void {
    try {
      if (typeof document === 'undefined') return;

      const languageInfo = this.config.supportedLanguages.find(lang => lang.code === language);
      
      document.documentElement.lang = language;
      document.documentElement.dir = languageInfo?.rtl ? 'rtl' : 'ltr';
    } catch {
      // i18n operation error occurred
    }
  }

  /**
   * Translate a key with interpolation
   */
  public t(key: string, options: InterpolationValues & { ns?: string; count?: number } = {}): string {
    try {
      const { ns = this.config.defaultNamespace, count, ...interpolationValues } = options;

      // Use i18next if available
      if (typeof window !== 'undefined' && window.i18next) {
        return window.i18next.t(key, options);
      }

      // Fallback to custom implementation
      let translation = this.getTranslation(key, ns, this.currentLanguage);

      // Try fallback language if not found
      if (!translation && this.config.fallbackLanguage && this.currentLanguage !== this.config.fallbackLanguage) {
        translation = this.getTranslation(key, ns, this.config.fallbackLanguage);
      }

      // Handle pluralization
      if (count !== undefined && typeof translation === 'object') {
        translation = this.handlePluralization(translation as TranslationObject, count, this.currentLanguage);
      }

      if (typeof translation !== 'string') {
        this.log(`Translation not found for key: ${key}, namespace: ${ns}`);
        return key; // Return key if translation not found
      }

      // Interpolate values
      return this.interpolate(translation, interpolationValues);
    } catch {
      
      return key;
    }
  }

  /**
   * Get translation from resources
   */
  private getTranslation(key: string, namespace: string = 'common', language: string): string | TranslationObject | null {
    try {
      const namespaceResources = this.resources[language]?.[namespace];
      if (!namespaceResources) return null;

      const keyParts = key.split('.');
      let current: unknown = namespaceResources;

      for (const part of keyParts) {
        if (current && typeof current === 'object' && part in current) {
          current = (current as Record<string, unknown>)[part];
        } else {
          return null;
        }
      }

      return current as string | TranslationObject | null;
    } catch {
      
      return null;
    }
  }

  /**
   * Handle pluralization
   */
  private handlePluralization(translations: TranslationObject, count: number, language: string): string {
    try {
      // Use custom pluralization rules if available
      const pluralRule = this.config.pluralization?.rules?.[language];
      const pluralIndex = pluralRule ? pluralRule(count) : this.getDefaultPluralIndex(count, language);

      const pluralKeys = ['zero', 'one', 'two', 'few', 'many', 'other'];
      const fallbackKeys = ['one', 'other'];

      // Try to find appropriate plural form
      for (const key of pluralKeys) {
        if (key in translations && typeof translations[key] === 'string') {
          if (this.shouldUsePluralKey(key, pluralIndex, count)) {
            return translations[key] as string;
          }
        }
      }

      // Fallback to basic plural forms
      for (const key of fallbackKeys) {
        if (key in translations && typeof translations[key] === 'string') {
          return translations[key] as string;
        }
      }

      // Return first available string value
      for (const value of Object.values(translations)) {
        if (typeof value === 'string') {
          return value;
        }
      }

      return '[Plural form not found]';
    } catch {
      
      return '[Pluralization error]';
    }
  }

  /**
   * Get default plural index based on language rules
   */
  private getDefaultPluralIndex(count: number, language: string): number {
    // Simplified plural rules for common languages
    switch (language) {
      case 'en':
      case 'de':
      case 'es':
      case 'fr':
        return count === 1 ? 0 : 1;
      case 'ja':
      case 'zh':
        return 0; // No pluralization
      case 'ar':
        if (count === 0) return 0;
        if (count === 1) return 1;
        if (count === 2) return 2;
        if (count >= 3 && count <= 10) return 3;
        if (count >= 11 && count <= 99) return 4;
        return 5;
      default:
        return count === 1 ? 0 : 1;
    }
  }

  /**
   * Check if plural key should be used
   */
  private shouldUsePluralKey(key: string, pluralIndex: number, count: number): boolean {
    switch (key) {
      case 'zero': return count === 0;
      case 'one': return pluralIndex === 0 || count === 1;
      case 'two': return count === 2;
      case 'few': return pluralIndex === 3;
      case 'many': return pluralIndex === 4;
      case 'other': return true; // Always use as fallback
      default: return false;
    }
  }

  /**
   * Interpolate values in translation string
   */
  private interpolate(translation: string, values: InterpolationValues): string {
    try {
      const { prefix = '{{', suffix = '}}', maxReplaces = 1000 } = this.config.interpolation || {};
      let result = translation;
      let replaceCount = 0;

      Object.entries(values).forEach(([key, value]) => {
        if (replaceCount >= maxReplaces) return;

        const placeholder = `${prefix}${key}${suffix}`;
        const stringValue = this.formatValue(value);
        
        while (result.includes(placeholder) && replaceCount < maxReplaces) {
          result = result.replace(placeholder, stringValue);
          replaceCount++;
        }
      });

      return result;
    } catch {
      
      return translation;
    }
  }

  /**
   * Format value for interpolation
   */
  private formatValue(value: unknown): string {
    if (value === null || value === undefined) {
      return '';
    }

    if (value instanceof Date) {
      return this.formatDate(value);
    }

    if (typeof value === 'number') {
      return this.formatNumber(value);
    }

    return String(value);
  }

  /**
   * Format date according to current locale
   */
  public formatDate(date: Date, format: string = 'medium', options?: DateFormatOptions): string {
    try {
      const formatOptions = {
        ...this.config.formatting?.dateFormats?.[format],
        ...options,
      };

      const locale = options?.locale || this.currentLanguage;
      return new Intl.DateTimeFormat(locale, formatOptions).format(date);
    } catch {
      
      return date.toLocaleDateString();
    }
  }

  /**
   * Format number according to current locale
   */
  public formatNumber(
    number: number,
    format: string = 'decimal',
    options?: FormatOptions
  ): string {
    try {
      const formatOptions: Intl.NumberFormatOptions = {
        ...this.config.formatting?.numberFormats?.[format],
        ...options,
      };

      // Set currency if using currency format
      if (formatOptions.style === 'currency' && !formatOptions.currency) {
        formatOptions.currency = this.config.formatting?.currency?.[this.currentLanguage] || 'USD';
      }

      return new Intl.NumberFormat(this.currentLanguage, formatOptions).format(number);
    } catch {
      
      return number.toString();
    }
  }

  /**
   * Get current language
   */
  public getCurrentLanguage(): string {
    return this.currentLanguage;
  }

  /**
   * Get supported languages
   */
  public getSupportedLanguages(): LanguageInfo[] {
    return [...this.config.supportedLanguages];
  }

  /**
   * Check if key exists
   */
  public exists(key: string, namespace?: string): boolean {
    try {
      if (typeof window !== 'undefined' && window.i18next) {
        return window.i18next.exists(key, { ns: namespace });
      }

      const translation = this.getTranslation(key, namespace || this.config.defaultNamespace || 'common', this.currentLanguage);
      return translation !== null;
    } catch {
      
      return false;
    }
  }

  /**
   * Get direction for language (LTR/RTL)
   */
  public getDirection(language?: string): 'ltr' | 'rtl' {
    const targetLanguage = language || this.currentLanguage;
    const languageInfo = this.config.supportedLanguages.find(lang => lang.code === targetLanguage);
    return languageInfo?.rtl ? 'rtl' : 'ltr';
  }

  /**
   * Add language change listener
   */
  public onLanguageChange(callback: (language: string) => void): () => void {
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
   * Notify all listeners of language changes
   */
  private notifyListeners(): void {
    this.listeners.forEach((callback) => {
      try {
        callback(this.currentLanguage);
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
    this.listeners = [];
    this.resources = {};
    this.loadedNamespaces.clear();
    this.loadingPromises.clear();
    // this.initialized = false;
  }
}

// Create and export singleton instance
const i18n = I18nManager.getInstance();

// Convenience functions for common i18n operations
export const t = (key: string, options?: InterpolationValues & { ns?: string; count?: number }): string => {
  return i18n.t(key, options);
};

export const changeLanguage = (language: string): Promise<void> => {
  return i18n.changeLanguage(language);
};

export const getCurrentLanguage = (): string => {
  return i18n.getCurrentLanguage();
};

export const getSupportedLanguages = (): LanguageInfo[] => {
  return i18n.getSupportedLanguages();
};

export const formatDate = (date: Date, format?: string, options?: DateFormatOptions): string => {
  return i18n.formatDate(date, format, options);
};

export const formatNumber = (number: number, format?: string, options?: FormatOptions): string => {
  return i18n.formatNumber(number, format, options);
};

export const getDirection = (language?: string): 'ltr' | 'rtl' => {
  return i18n.getDirection(language);
};

export const loadNamespace = (namespace: string, language?: string): Promise<void> => {
  return i18n.loadNamespace(namespace, language);
};

export const exists = (key: string, namespace?: string): boolean => {
  return i18n.exists(key, namespace);
};

export const onLanguageChange = (callback: (language: string) => void): (() => void) => {
  return i18n.onLanguageChange(callback);
};

export const initializeI18n = (config?: Partial<I18nConfig>): Promise<void> => {
  return i18n.initialize(config);
};

// Export the i18n instance for advanced usage
export { i18n };
export default i18n;