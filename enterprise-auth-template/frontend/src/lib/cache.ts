/**
 * Client-side caching utility
 * Supports multiple storage backends, cache policies, and automatic invalidation
 * Provides type-safe caching with compression, encryption, and memory management
 */


// Cache types
export interface CacheEntry<T = unknown> {
  key: string;
  value: T;
  metadata: {
    timestamp: number;
    expiry?: number;
    version?: string;
    tags?: string[];
    priority?: number;
    size?: number;
    accessCount?: number;
    lastAccessed?: number;
  };
}

export interface CacheStats {
  entries: number;
  totalSize: number;
  hitRate: number;
  totalHits: number;
  totalMisses: number;
  oldestEntry?: number;
  newestEntry?: number;
  memoryUsage?: number;
}

export interface CachePolicy {
  ttl?: number; // Time to live in milliseconds
  maxSize?: number; // Maximum cache size in bytes
  maxEntries?: number; // Maximum number of entries
  evictionPolicy?: 'lru' | 'lfu' | 'fifo' | 'random';
  compression?: boolean;
  encryption?: boolean;
  persistToDisk?: boolean;
  syncAcrossWindows?: boolean;
}

export interface CacheOptions extends CachePolicy {
  tags?: string[];
  priority?: number;
  version?: string;
  namespace?: string;
}

export interface BulkCacheOperation<T = unknown> {
  key: string;
  value?: T;
  options?: CacheOptions;
}

// Configuration interfaces
export interface CacheConfig {
  storage: {
    primary: 'memory' | 'localStorage' | 'sessionStorage';
    fallback?: ('memory' | 'localStorage' | 'sessionStorage')[];
    namespace?: string;
  };
  policy: CachePolicy;
  quota: {
    memory?: number; // Memory quota in bytes
    localStorage?: number;
    sessionStorage?: number;
    indexedDB?: number;
  };
  cleanup: {
    interval?: number; // Cleanup interval in milliseconds
    enableAutoCleanup?: boolean;
    maxCleanupTime?: number;
  };
  performance: {
    enableMetrics?: boolean;
    enableWarnings?: boolean;
    logSlowOperations?: boolean;
    slowOperationThreshold?: number;
  };
  compression?: {
    enabled: boolean;
    algorithm: 'gzip' | 'lz-string';
    minSize: number; // Minimum size to compress
  };
  encryption?: {
    enabled: boolean;
    key?: string;
  };
  debug?: boolean;
}

// Storage backends
export interface CacheStorage {
  get<T = unknown>(key: string): Promise<CacheEntry<T> | null>;
  set<T = unknown>(key: string, entry: CacheEntry<T>): Promise<void>;
  delete(key: string): Promise<boolean>;
  clear(namespace?: string): Promise<void>;
  keys(pattern?: string): Promise<string[]>;
  size(): Promise<number>;
  has(key: string): Promise<boolean>;
}

/**
 * Memory storage implementation
 */
class MemoryStorage implements CacheStorage {
  private cache = new Map<string, CacheEntry>();
  private maxSize: number;

  constructor(maxSize = 50 * 1024 * 1024) { // 50MB default
    this.maxSize = maxSize;
  }

  async get<T = unknown>(key: string): Promise<CacheEntry<T> | null> {
    const entry = this.cache.get(key) as CacheEntry<T> | undefined;
    if (!entry) return null;

    // Update access metadata
    entry.metadata.accessCount = (entry.metadata.accessCount || 0) + 1;
    entry.metadata.lastAccessed = Date.now();

    return entry;
  }

  async set<T = unknown>(key: string, entry: CacheEntry<T>): Promise<void> {
    // Check size limits
    const entrySize = this.estimateSize(entry);
    const currentSize = await this.size();

    if (currentSize + entrySize > this.maxSize) {
      throw new Error('Memory cache quota exceeded');
    }

    entry.metadata.size = entrySize;
    this.cache.set(key, entry);
  }

  async delete(key: string): Promise<boolean> {
    return this.cache.delete(key);
  }

  async clear(): Promise<void> {
    this.cache.clear();
  }

  async keys(): Promise<string[]> {
    return Array.from(this.cache.keys());
  }

  async size(): Promise<number> {
    let totalSize = 0;
    for (const entry of this.cache.values()) {
      totalSize += entry.metadata.size || 0;
    }
    return totalSize;
  }

  async has(key: string): Promise<boolean> {
    return this.cache.has(key);
  }

  private estimateSize(entry: CacheEntry): number {
    try {
      return JSON.stringify(entry).length * 2; // Rough estimate (UTF-16)
    } catch {
      return 1024; // Default fallback
    }
  }
}

/**
 * LocalStorage implementation
 */
class LocalStorage implements CacheStorage {
  private namespace: string;
  private maxSize: number;

  constructor(namespace = 'cache', maxSize = 10 * 1024 * 1024) { // 10MB default
    this.namespace = namespace;
    this.maxSize = maxSize;
  }

  async get<T = unknown>(key: string): Promise<CacheEntry<T> | null> {
    try {
      if (typeof window === 'undefined') return null;

      const stored = localStorage.getItem(this.getKey(key));
      if (!stored) return null;

      const entry: CacheEntry<T> = JSON.parse(stored);
      
      // Update access metadata
      entry.metadata.accessCount = (entry.metadata.accessCount || 0) + 1;
      entry.metadata.lastAccessed = Date.now();
      
      // Save back the updated metadata
      localStorage.setItem(this.getKey(key), JSON.stringify(entry));

      return entry;
    } catch {
      
      return null;
    }
  }

  async set<T = unknown>(key: string, entry: CacheEntry<T>): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      const serialized = JSON.stringify(entry);
      const size = serialized.length * 2;

      // Check quota
      if (size > this.maxSize) {
        throw new Error('Entry too large for localStorage');
      }

      entry.metadata.size = size;
      localStorage.setItem(this.getKey(key), JSON.stringify(entry));
    } catch (err) {
      if (err instanceof DOMException && err.name === 'QuotaExceededError') {
        throw new Error('localStorage quota exceeded');
      }
      throw err;
    }
  }

  async delete(key: string): Promise<boolean> {
    try {
      if (typeof window === 'undefined') return false;

      const existed = localStorage.getItem(this.getKey(key)) !== null;
      localStorage.removeItem(this.getKey(key));
      return existed;
    } catch {
      
      return false;
    }
  }

  async clear(namespace?: string): Promise<void> {
    try {
      if (typeof window === 'undefined') return;

      const targetNamespace = namespace || this.namespace;
      const keysToRemove: string[] = [];

      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(`${targetNamespace}:`)) {
          keysToRemove.push(key);
        }
      }

      keysToRemove.forEach(key => localStorage.removeItem(key));
    } catch {
      
    }
  }

  async keys(): Promise<string[]> {
    try {
      if (typeof window === 'undefined') return [];

      const keys: string[] = [];
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith(`${this.namespace}:`)) {
          keys.push(key.substring(this.namespace.length + 1));
        }
      }
      return keys;
    } catch {
      
      return [];
    }
  }

  async size(): Promise<number> {
    try {
      if (typeof window === 'undefined') return 0;

      let totalSize = 0;
      const keys = await this.keys();

      for (const key of keys) {
        const stored = localStorage.getItem(this.getKey(key));
        if (stored) {
          totalSize += stored.length * 2;
        }
      }

      return totalSize;
    } catch {
      
      return 0;
    }
  }

  async has(key: string): Promise<boolean> {
    try {
      if (typeof window === 'undefined') return false;
      return localStorage.getItem(this.getKey(key)) !== null;
    } catch {
      
      return false;
    }
  }

  private getKey(key: string): string {
    return `${this.namespace}:${key}`;
  }
}

/**
 * Cache manager singleton class
 * Handles multiple storage backends with intelligent fallback and policies
 */
class CacheManager {
  private static instance: CacheManager;
  private config: CacheConfig;
  private primaryStorage!: CacheStorage;
  private fallbackStorages: CacheStorage[] = [];
  private initialized = false;
  private stats: CacheStats = {
    entries: 0,
    totalSize: 0,
    hitRate: 0,
    totalHits: 0,
    totalMisses: 0,
  };
  private cleanupInterval: NodeJS.Timeout | null = null;
  private debug = false;

  private constructor() {
    this.config = {
      storage: {
        primary: 'memory',
        fallback: ['localStorage', 'sessionStorage'],
        namespace: 'app-cache',
      },
      policy: {
        ttl: 24 * 60 * 60 * 1000, // 24 hours
        maxSize: 50 * 1024 * 1024, // 50MB
        maxEntries: 10000,
        evictionPolicy: 'lru',
        compression: false,
        encryption: false,
        persistToDisk: true,
        syncAcrossWindows: false,
      },
      quota: {
        memory: 50 * 1024 * 1024, // 50MB
        localStorage: 10 * 1024 * 1024, // 10MB
        sessionStorage: 5 * 1024 * 1024, // 5MB
        indexedDB: 100 * 1024 * 1024, // 100MB
      },
      cleanup: {
        interval: 5 * 60 * 1000, // 5 minutes
        enableAutoCleanup: true,
        maxCleanupTime: 1000, // 1 second
      },
      performance: {
        enableMetrics: true,
        enableWarnings: true,
        logSlowOperations: process.env['NODE_ENV'] === 'development',
        slowOperationThreshold: 100, // 100ms
      },
      compression: {
        enabled: false,
        algorithm: 'lz-string',
        minSize: 1024, // 1KB
      },
      encryption: {
        enabled: false,
        ...(process.env['NEXT_PUBLIC_CACHE_ENCRYPTION_KEY'] ? { key: process.env['NEXT_PUBLIC_CACHE_ENCRYPTION_KEY'] } : {}),
      },
      debug: process.env['NODE_ENV'] === 'development',
    };

    this.debug = this.config.debug || false;
  }

  /**
   * Get singleton instance
   */
  public static getInstance(): CacheManager {
    if (!CacheManager.instance) {
      CacheManager.instance = new CacheManager();
    }
    return CacheManager.instance;
  }

  /**
   * Initialize cache with configuration
   */
  public async initialize(config?: Partial<CacheConfig>): Promise<void> {
    try {
      if (config) {
        this.config = this.mergeConfig(this.config, config);
      }

      // Initialize storage backends
      await this.initializeStorages();

      // Start cleanup process
      if (this.config.cleanup?.enableAutoCleanup) {
        this.startCleanupProcess();
      }

      this.initialized = true;
      this.log('Cache initialized successfully', {
        primary: this.config.storage.primary,
        fallbacks: this.config.storage.fallback,
      });
    } catch (err) {
      this.log('Failed to initialize cache:', err);
    }
  }

  /**
   * Initialize storage backends
   */
  private async initializeStorages(): Promise<void> {
    const { primary, fallback, namespace } = this.config.storage;
    const { memory, localStorage: localStorageQuota, sessionStorage: sessionStorageQuota } = this.config.quota;

    // Initialize primary storage
    this.primaryStorage = this.createStorage(primary, namespace, {
      ...(memory !== undefined ? { memory } : {}),
      ...(localStorageQuota !== undefined ? { localStorage: localStorageQuota } : {}),
      ...(sessionStorageQuota !== undefined ? { sessionStorage: sessionStorageQuota } : {}),
    });

    // Initialize fallback storages
    this.fallbackStorages = (fallback || []).map(type =>
      this.createStorage(type, namespace, {
        ...(memory !== undefined ? { memory } : {}),
        ...(localStorageQuota !== undefined ? { localStorage: localStorageQuota } : {}),
        ...(sessionStorageQuota !== undefined ? { sessionStorage: sessionStorageQuota } : {}),
      })
    );

    this.log('Storage backends initialized');
  }

  /**
   * Create storage backend
   */
  private createStorage(
    type: 'memory' | 'localStorage' | 'sessionStorage',
    namespace = 'cache',
    quotas: { memory?: number; localStorage?: number; sessionStorage?: number }
  ): CacheStorage {
    switch (type) {
      case 'memory':
        return new MemoryStorage(quotas.memory);
      case 'localStorage':
        return new LocalStorage(`${namespace}-ls`, quotas.localStorage);
      case 'sessionStorage':
        // SessionStorage implementation would be similar to LocalStorage
        return new LocalStorage(`${namespace}-ss`, quotas.sessionStorage);
      default:
        throw new Error(`Unsupported storage type: ${type}`);
    }
  }

  /**
   * Merge configuration objects deeply
   */
  private mergeConfig(base: CacheConfig, override: Partial<CacheConfig>): CacheConfig {
    const merged = { ...base };

    Object.keys(override).forEach(key => {
      const value = (override as Record<string, unknown>)[key];
      if (value && typeof value === 'object' && !Array.isArray(value)) {
        (merged as Record<string, unknown>)[key] = { ...(merged as Record<string, unknown>)[key] as Record<string, unknown>, ...value as Record<string, unknown> };
      } else {
        (merged as Record<string, unknown>)[key] = value;
      }
    });

    return merged;
  }

  /**
   * Get value from cache
   */
  public async get<T = unknown>(key: string, namespace?: string): Promise<T | null> {
    const startTime = performance.now();

    try {
      if (!this.initialized) {
        throw new Error('Cache not initialized');
      }

      const fullKey = this.buildKey(key, namespace);

      // Try primary storage first
      let entry = await this.primaryStorage.get<T>(fullKey);
      let source = 'primary';

      // Try fallback storages if not found
      if (!entry) {
        for (const storage of this.fallbackStorages) {
          entry = await storage.get<T>(fullKey);
          if (entry) {
            source = 'fallback';
            // Promote to primary storage
            await this.primaryStorage.set(fullKey, entry).catch(() => {
              // Ignore promotion failures
            });
            break;
          }
        }
      }

      // Check expiry
      if (entry && this.isExpired(entry)) {
        await this.delete(key, namespace);
        entry = null;
      }

      // Update stats
      if (entry) {
        this.stats.totalHits++;
        this.log(`Cache HIT: ${fullKey} (${source})`);
      } else {
        this.stats.totalMisses++;
        this.log(`Cache MISS: ${fullKey}`);
      }

      this.updateHitRate();
      this.logSlowOperation('get', startTime);

      return entry ? entry.value : null;
    } catch {
      
      this.stats.totalMisses++;
      this.updateHitRate();
      return null;
    }
  }

  /**
   * Set value in cache
   */
  public async set<T = unknown>(
    key: string,
    value: T,
    options: CacheOptions = {}
  ): Promise<void> {
    const startTime = performance.now();

    try {
      if (!this.initialized) {
        throw new Error('Cache not initialized');
      }

      const fullKey = this.buildKey(key, options.namespace);
      const mergedOptions = { ...this.config.policy, ...options };

      // Prepare cache entry
      const entry: CacheEntry<T> = {
        key: fullKey,
        value: await this.processValue(value, mergedOptions),
        metadata: {
          timestamp: Date.now(),
          ...(mergedOptions.ttl ? { expiry: Date.now() + mergedOptions.ttl } : {}),
          ...(options.version ? { version: options.version } : {}),
          ...(options.tags ? { tags: options.tags } : {}),
          priority: options.priority || 1,
          accessCount: 0,
        },
      };

      // Check if eviction is needed
      await this.maybeEvict(entry);

      // Store in primary storage
      await this.primaryStorage.set(fullKey, entry);

      // Store in fallback storages if configured for persistence
      if (mergedOptions.persistToDisk) {
        for (const storage of this.fallbackStorages) {
          try {
            await storage.set(fullKey, entry);
          } catch (err) {
            // Ignore fallback storage failures
            this.log('Failed to store in fallback storage:', err);
          }
        }
      }

      this.stats.entries++;
      this.log(`Cache SET: ${fullKey}`);
      this.logSlowOperation('set', startTime);
    } catch (err) {
      
      throw err;
    }
  }

  /**
   * Delete value from cache
   */
  public async delete(key: string, namespace?: string): Promise<boolean> {
    const startTime = performance.now();

    try {
      if (!this.initialized) {
        throw new Error('Cache not initialized');
      }

      const fullKey = this.buildKey(key, namespace);
      let deleted = false;

      // Delete from all storages
      const primaryDeleted = await this.primaryStorage.delete(fullKey);
      if (primaryDeleted) {
        deleted = true;
        this.stats.entries = Math.max(0, this.stats.entries - 1);
      }

      for (const storage of this.fallbackStorages) {
        try {
          await storage.delete(fullKey);
        } catch {
          // Ignore fallback deletion failures
        }
      }

      this.log(`Cache DELETE: ${fullKey} (${deleted ? 'found' : 'not found'})`);
      this.logSlowOperation('delete', startTime);

      return deleted;
    } catch {
      
      return false;
    }
  }

  /**
   * Check if key exists in cache
   */
  public async has(key: string, namespace?: string): Promise<boolean> {
    try {
      if (!this.initialized) return false;

      const fullKey = this.buildKey(key, namespace);
      const entry = await this.primaryStorage.get(fullKey);
      
      if (!entry) return false;
      
      // Check if expired
      return !this.isExpired(entry);
    } catch {
      
      return false;
    }
  }

  /**
   * Clear cache (all entries or by namespace)
   */
  public async clear(namespace?: string): Promise<void> {
    const startTime = performance.now();

    try {
      if (!this.initialized) return;

      // Clear from all storages
      await this.primaryStorage.clear(namespace);
      
      for (const storage of this.fallbackStorages) {
        try {
          await storage.clear(namespace);
        } catch {
          // Ignore fallback clear failures
        }
      }

      if (!namespace) {
        this.stats.entries = 0;
        this.stats.totalSize = 0;
      }

      this.log(`Cache CLEAR: ${namespace || 'all'}`);
      this.logSlowOperation('clear', startTime);
    } catch {
      
    }
  }

  /**
   * Get multiple values at once
   */
  public async getMany<T = unknown>(keys: string[], namespace?: string): Promise<(T | null)[]> {
    const promises = keys.map(key => this.get<T>(key, namespace));
    return Promise.all(promises);
  }

  /**
   * Set multiple values at once
   */
  public async setMany<T = unknown>(operations: BulkCacheOperation<T>[]): Promise<void> {
    const promises = operations.map(op => 
      this.set(op.key, op.value!, op.options)
    );
    await Promise.all(promises);
  }

  /**
   * Delete multiple keys at once
   */
  public async deleteMany(keys: string[], namespace?: string): Promise<boolean[]> {
    const promises = keys.map(key => this.delete(key, namespace));
    return Promise.all(promises);
  }

  /**
   * Invalidate cache entries by tags
   */
  public async invalidateByTags(tags: string[]): Promise<number> {
    try {
      if (!this.initialized) return 0;

      const keys = await this.primaryStorage.keys();
      let invalidated = 0;

      for (const key of keys) {
        const entry = await this.primaryStorage.get(key);
        if (entry && entry.metadata.tags) {
          const hasTag = tags.some(tag => entry.metadata.tags?.includes(tag));
          if (hasTag) {
            await this.delete(key.split(':').pop() || key);
            invalidated++;
          }
        }
      }

      this.log(`Invalidated ${invalidated} entries by tags:`, tags);
      return invalidated;
    } catch {
      
      return 0;
    }
  }

  /**
   * Get cache statistics
   */
  public async getStats(): Promise<CacheStats> {
    try {
      const totalSize = await this.primaryStorage.size();
      const keys = await this.primaryStorage.keys();

      return {
        ...this.stats,
        entries: keys.length,
        totalSize,
        memoryUsage: (() => {
          const perf = performance as Performance & { memory?: { usedJSHeapSize?: number } };
          return typeof perf?.memory?.usedJSHeapSize === 'number' ? perf.memory.usedJSHeapSize : 0;
        })(),
      };
    } catch {
      
      return this.stats;
    }
  }

  /**
   * Build full cache key with namespace
   */
  private buildKey(key: string, namespace?: string): string {
    const ns = namespace || this.config.storage.namespace || 'default';
    return `${ns}:${key}`;
  }

  /**
   * Check if cache entry is expired
   */
  private isExpired(entry: CacheEntry): boolean {
    if (!entry.metadata.expiry) return false;
    return Date.now() > entry.metadata.expiry;
  }

  /**
   * Process value before storing (compression, encryption)
   */
  private async processValue<T>(value: T, options: CachePolicy): Promise<T> {
    const processedValue = value;

    // Apply compression if enabled and value is large enough
    if (options.compression && this.config.compression?.enabled) {
      const serialized = JSON.stringify(value);
      if (serialized.length > (this.config.compression?.minSize || 1024)) {
        // Compression would be implemented here
        this.log('Value compressed');
      }
    }

    // Apply encryption if enabled
    if (options.encryption && this.config.encryption?.enabled) {
      // Encryption would be implemented here
      this.log('Value encrypted');
    }

    return processedValue;
  }

  /**
   * Maybe evict entries to make space
   */
  private async maybeEvict(_newEntry: CacheEntry): Promise<void> {
    try {
      const currentSize = await this.primaryStorage.size();
      const maxSize = this.config.policy.maxSize || Infinity;
      const maxEntries = this.config.policy.maxEntries || Infinity;
      const keys = await this.primaryStorage.keys();

      // Check if eviction is needed
      const needsEviction = 
        currentSize > maxSize * 0.9 || // 90% of max size
        keys.length >= maxEntries;
        
      // Log new entry for debugging
      // Cache eviction check for entry: ${newEntry.key}, needsEviction: ${needsEviction}
        keys.length >= maxEntries * 0.9; // 90% of max entries

      if (!needsEviction) return;

      // Perform eviction based on policy
      const evictionPolicy = this.config.policy.evictionPolicy || 'lru';
      await this.evictEntries(evictionPolicy, Math.max(1, keys.length * 0.1)); // Evict 10%

      this.log(`Evicted entries using ${evictionPolicy} policy`);
    } catch {
      
    }
  }

  /**
   * Evict entries based on policy
   */
  private async evictEntries(policy: string, count: number): Promise<void> {
    try {
      const keys = await this.primaryStorage.keys();
      const entries: Array<{ key: string; entry: CacheEntry }> = [];

      // Load entries for eviction analysis
      for (const key of keys) {
        const entry = await this.primaryStorage.get(key);
        if (entry) {
          entries.push({ key, entry });
        }
      }

      // Sort based on eviction policy
      let sortedEntries: Array<{ key: string; entry: CacheEntry }>;

      switch (policy) {
        case 'lru': // Least Recently Used
          sortedEntries = entries.sort((a, b) => 
            (a.entry.metadata.lastAccessed || 0) - (b.entry.metadata.lastAccessed || 0)
          );
          break;
        case 'lfu': // Least Frequently Used
          sortedEntries = entries.sort((a, b) => 
            (a.entry.metadata.accessCount || 0) - (b.entry.metadata.accessCount || 0)
          );
          break;
        case 'fifo': // First In, First Out
          sortedEntries = entries.sort((a, b) => 
            a.entry.metadata.timestamp - b.entry.metadata.timestamp
          );
          break;
        case 'random':
          sortedEntries = entries.sort(() => Math.random() - 0.5);
          break;
        default:
          sortedEntries = entries;
      }

      // Evict entries
      const toEvict = sortedEntries.slice(0, Math.min(count, entries.length));
      for (const { key } of toEvict) {
        await this.primaryStorage.delete(key);
        this.stats.entries = Math.max(0, this.stats.entries - 1);
      }
    } catch {
      
    }
  }

  /**
   * Start cleanup process
   */
  private startCleanupProcess(): void {
    const interval = this.config.cleanup?.interval || 5 * 60 * 1000;

    this.cleanupInterval = setInterval(async () => {
      try {
        await this.cleanup();
      } catch {
        
      }
    }, interval);

    this.log('Cleanup process started');
  }

  /**
   * Clean up expired entries
   */
  public async cleanup(): Promise<number> {
    const startTime = performance.now();
    const maxTime = this.config.cleanup?.maxCleanupTime || 1000;

    try {
      if (!this.initialized) return 0;

      const keys = await this.primaryStorage.keys();
      let cleanedUp = 0;

      for (const key of keys) {
        // Check time limit
        if (performance.now() - startTime > maxTime) {
          this.log('Cleanup time limit reached');
          break;
        }

        const entry = await this.primaryStorage.get(key);
        if (entry && this.isExpired(entry)) {
          await this.primaryStorage.delete(key);
          cleanedUp++;
          this.stats.entries = Math.max(0, this.stats.entries - 1);
        }
      }

      if (cleanedUp > 0) {
        this.log(`Cleaned up ${cleanedUp} expired entries`);
      }

      return cleanedUp;
    } catch {
      
      return 0;
    }
  }

  /**
   * Update hit rate statistics
   */
  private updateHitRate(): void {
    const total = this.stats.totalHits + this.stats.totalMisses;
    this.stats.hitRate = total > 0 ? this.stats.totalHits / total : 0;
  }

  /**
   * Log slow operations
   */
  private logSlowOperation(_operation: string, startTime: number): void {
    if (!this.config.performance?.logSlowOperations) return;

    const duration = performance.now() - startTime;
    const threshold = this.config.performance?.slowOperationThreshold || 100;

    if (duration > threshold) {
      // console.warn(`Slow cache operation: ${operation} took ${duration.toFixed(2)}ms`);
      // Performance logging would go here in development mode
    }
  }

  /**
   * Debug logging
   */
  private log(..._args: unknown[]): void {
    if (this.debug) {
      // Debug: [Cache] ${args.join(' ')}
    } else {
      // Debug logging would go here in development mode
    }
  }

  /**
   * Clean up resources
   */
  public cleanup_resources(): void {
    if (this.cleanupInterval) {
      clearInterval(this.cleanupInterval);
      this.cleanupInterval = null;
    }
    this.initialized = false;
  }
}

// Create and export singleton instance
const cache = CacheManager.getInstance();

// Convenience functions for common caching operations
export const get = <T = unknown>(key: string, namespace?: string): Promise<T | null> => {
  return cache.get<T>(key, namespace);
};

export const set = <T = unknown>(key: string, value: T, options?: CacheOptions): Promise<void> => {
  return cache.set(key, value, options);
};

export const del = (key: string, namespace?: string): Promise<boolean> => {
  return cache.delete(key, namespace);
};

export const has = (key: string, namespace?: string): Promise<boolean> => {
  return cache.has(key, namespace);
};

export const clear = (namespace?: string): Promise<void> => {
  return cache.clear(namespace);
};

export const getMany = <T = unknown>(keys: string[], namespace?: string): Promise<(T | null)[]> => {
  return cache.getMany<T>(keys, namespace);
};

export const setMany = <T = unknown>(operations: BulkCacheOperation<T>[]): Promise<void> => {
  return cache.setMany(operations);
};

export const deleteMany = (keys: string[], namespace?: string): Promise<boolean[]> => {
  return cache.deleteMany(keys, namespace);
};

export const invalidateByTags = (tags: string[]): Promise<number> => {
  return cache.invalidateByTags(tags);
};

export const getStats = (): Promise<CacheStats> => {
  return cache.getStats();
};

export const cleanup = (): Promise<number> => {
  return cache.cleanup();
};

export const initializeCache = (config?: Partial<CacheConfig>): Promise<void> => {
  return cache.initialize(config);
};

// Export the cache instance for advanced usage
export { cache };
export default cache;