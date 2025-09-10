import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { devtools } from 'zustand/middleware';

export interface OfflineQueueItem {
  id: string;
  type: 'api_call' | 'form_submission' | 'data_sync';
  method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  endpoint: string;
  payload?: Record<string, unknown>;
  headers?: Record<string, string>;
  timestamp: number;
  retryCount: number;
  maxRetries: number;
  priority: 'high' | 'medium' | 'low';
  status: 'pending' | 'processing' | 'failed' | 'completed';
  error?: string;
}

export interface CachedData {
  key: string;
  data: unknown;
  timestamp: number;
  expiresAt?: number;
  version: string;
  syncStatus: 'synced' | 'pending' | 'conflict';
}

export interface ConflictResolution {
  id: string;
  localData: unknown;
  serverData: unknown;
  resolvedData?: unknown;
  strategy: 'local_wins' | 'server_wins' | 'manual' | 'merge';
  timestamp: number;
}

interface OfflineState {
  // State
  isOnline: boolean;
  isRehydrated: boolean;
  syncInProgress: boolean;
  lastSyncTime: number | null;
  offlineQueue: OfflineQueueItem[];
  cachedData: Map<string, CachedData>;
  conflicts: ConflictResolution[];
  syncErrors: Array<{ timestamp: number; error: string; context?: unknown }>;
  
  // Metrics
  queueMetrics: {
    totalQueued: number;
    successfulSyncs: number;
    failedSyncs: number;
    averageSyncTime: number;
  };
  
  // Settings
  settings: {
    enableOfflineMode: boolean;
    autoSync: boolean;
    syncInterval: number; // in milliseconds
    maxQueueSize: number;
    maxCacheSize: number;
    cacheExpirationTime: number; // in milliseconds
    conflictResolutionStrategy: 'local_wins' | 'server_wins' | 'manual';
  };
  
  // Actions
  setOnlineStatus: (isOnline: boolean) => void;
  addToQueue: (item: Omit<OfflineQueueItem, 'id' | 'timestamp' | 'retryCount' | 'status'>) => void;
  removeFromQueue: (id: string) => void;
  updateQueueItem: (id: string, updates: Partial<OfflineQueueItem>) => void;
  processQueue: () => Promise<void>;
  retryQueueItem: (id: string) => Promise<void>;
  clearQueue: () => void;
  
  // Cache actions
  setCachedData: (key: string, data: unknown, expiresIn?: number) => void;
  getCachedData: <T = unknown>(key: string) => T | null;
  invalidateCache: (key: string) => void;
  clearCache: () => void;
  syncCache: () => Promise<void>;
  
  // Conflict resolution
  addConflict: (conflict: Omit<ConflictResolution, 'id' | 'timestamp'>) => void;
  resolveConflict: (id: string, resolvedData: unknown) => void;
  clearConflicts: () => void;
  
  // Sync actions
  startSync: () => Promise<void>;
  stopSync: () => void;
  forceSync: () => Promise<void>;
  
  // Settings
  updateSettings: (settings: Partial<OfflineState['settings']>) => void;
  
  // Utilities
  getQueueSize: () => number;
  getCacheSize: () => number;
  exportOfflineData: () => Promise<Blob>;
  importOfflineData: (data: Blob) => Promise<void>;
  clearAllOfflineData: () => void;
}

// Service Worker registration helper
const registerServiceWorker = async () => {
  if ('serviceWorker' in navigator && process.env.NODE_ENV === 'production') {
    try {
      const registration = await navigator.serviceWorker.register('/sw.js');
      
      return registration;
    } catch (error) {
      
      return null;
    }
  }
  return null;
};

// IndexedDB helper for large data storage
class IndexedDBStorage {
  private dbName = 'enterprise_auth_offline';
  private version = 1;
  private db: IDBDatabase | null = null;

  open(): Promise<IDBDatabase> {
    return new Promise((resolve, reject) => {
      const request = globalThis.indexedDB.open(this.dbName, this.version);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  async init(): Promise<void> {
    return new Promise((resolve, reject) => {
      const request = globalThis.indexedDB.open(this.dbName, this.version);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = (event: IDBVersionChangeEvent) => {
        const db = (event.target as IDBOpenDBRequest).result;
        
        // Create object stores
        if (!db.objectStoreNames.contains('queue')) {
          db.createObjectStore('queue', { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains('cache')) {
          const cacheStore = db.createObjectStore('cache', { keyPath: 'key' });
          cacheStore.createIndex('timestamp', 'timestamp', { unique: false });
        }
        if (!db.objectStoreNames.contains('conflicts')) {
          db.createObjectStore('conflicts', { keyPath: 'id' });
        }
      };
    });
  }

  async get<T>(storeName: string, key: string): Promise<T | null> {
    if (!this.db) await this.init();
    
    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([storeName], 'readonly');
      const store = transaction.objectStore(storeName);
      const request = store.get(key);
      
      request.onsuccess = () => resolve(request.result || null);
      request.onerror = () => reject(request.error);
    });
  }

  async set(storeName: string, value: unknown): Promise<void> {
    if (!this.db) await this.init();
    
    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([storeName], 'readwrite');
      const store = transaction.objectStore(storeName);
      const request = store.put(value);
      
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  async delete(storeName: string, key: string): Promise<void> {
    if (!this.db) await this.init();
    
    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([storeName], 'readwrite');
      const store = transaction.objectStore(storeName);
      const request = store.delete(key);
      
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  async clear(storeName: string): Promise<void> {
    if (!this.db) await this.init();
    
    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([storeName], 'readwrite');
      const store = transaction.objectStore(storeName);
      const request = store.clear();
      
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  async getAll<T>(storeName: string): Promise<T[]> {
    if (!this.db) await this.init();
    
    return new Promise((resolve, reject) => {
      const transaction = this.db!.transaction([storeName], 'readonly');
      const store = transaction.objectStore(storeName);
      const request = store.getAll();
      
      request.onsuccess = () => resolve(request.result || []);
      request.onerror = () => reject(request.error);
    });
  }
}

const indexedDBStorage = new IndexedDBStorage();

export const useOfflineStore = create<OfflineState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial state
        isOnline: typeof navigator !== 'undefined' ? navigator.onLine : true,
        isRehydrated: false,
        syncInProgress: false,
        lastSyncTime: null,
        offlineQueue: [],
        cachedData: new Map(),
        conflicts: [],
        syncErrors: [],
        
        queueMetrics: {
          totalQueued: 0,
          successfulSyncs: 0,
          failedSyncs: 0,
          averageSyncTime: 0,
        },
        
        settings: {
          enableOfflineMode: true,
          autoSync: true,
          syncInterval: 30000, // 30 seconds
          maxQueueSize: 100,
          maxCacheSize: 50 * 1024 * 1024, // 50MB
          cacheExpirationTime: 3600000, // 1 hour
          conflictResolutionStrategy: 'manual',
        },

        // Actions
        setOnlineStatus: (isOnline) => {
          set({ isOnline });
          if (isOnline && get().settings.autoSync) {
            get().startSync();
          }
        },

        addToQueue: (item) => {
          const { offlineQueue, settings } = get();
          
          if (offlineQueue.length >= settings.maxQueueSize) {
            // Remove oldest low-priority items
            const sortedQueue = [...offlineQueue].sort((a, b) => {
              const priorityOrder = { low: 0, medium: 1, high: 2 };
              return priorityOrder[a.priority] - priorityOrder[b.priority];
            });
            
            set({ offlineQueue: sortedQueue.slice(1) });
          }

          const newItem: OfflineQueueItem = {
            ...item,
            id: `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            timestamp: Date.now(),
            retryCount: 0,
            status: 'pending',
          };

          set({
            offlineQueue: [...get().offlineQueue, newItem],
            queueMetrics: {
              ...get().queueMetrics,
              totalQueued: get().queueMetrics.totalQueued + 1,
            },
          });

          // Store in IndexedDB for persistence
          indexedDBStorage.set('queue', newItem);
        },

        removeFromQueue: (id) => {
          set({
            offlineQueue: get().offlineQueue.filter(item => item.id !== id),
          });
          indexedDBStorage.delete('queue', id);
        },

        updateQueueItem: (id, updates) => {
          const queue = get().offlineQueue.map(item =>
            item.id === id ? { ...item, ...updates } : item
          );
          set({ offlineQueue: queue });
          
          const updatedItem = queue.find(item => item.id === id);
          if (updatedItem) {
            indexedDBStorage.set('queue', updatedItem);
          }
        },

        processQueue: async () => {
          const { offlineQueue, isOnline } = get();
          
          if (!isOnline || offlineQueue.length === 0) return;

          set({ syncInProgress: true });
          const startTime = Date.now();

          for (const item of offlineQueue.filter(i => i.status === 'pending')) {
            try {
              get().updateQueueItem(item.id, { status: 'processing' });

              const response = await fetch(item.endpoint, {
                method: item.method,
                headers: {
                  'Content-Type': 'application/json',
                  ...item.headers,
                },
                body: item.payload ? JSON.stringify(item.payload) : null,
              });

              if (response.ok) {
                get().updateQueueItem(item.id, { status: 'completed' });
                get().removeFromQueue(item.id);
                
                set({
                  queueMetrics: {
                    ...get().queueMetrics,
                    successfulSyncs: get().queueMetrics.successfulSyncs + 1,
                  },
                });
              } else {
                throw new Error(`Request failed with status ${response.status}`);
              }
            } catch (error) {
              const errorMessage = error instanceof Error ? error.message : 'Unknown error';
              
              get().updateQueueItem(item.id, {
                status: 'failed',
                error: errorMessage,
                retryCount: item.retryCount + 1,
              });

              if (item.retryCount >= item.maxRetries) {
                get().removeFromQueue(item.id);
                set({
                  syncErrors: [
                    ...get().syncErrors,
                    { timestamp: Date.now(), error: errorMessage, context: item },
                  ],
                  queueMetrics: {
                    ...get().queueMetrics,
                    failedSyncs: get().queueMetrics.failedSyncs + 1,
                  },
                });
              }
            }
          }

          const syncTime = Date.now() - startTime;
          const metrics = get().queueMetrics;
          
          set({
            syncInProgress: false,
            lastSyncTime: Date.now(),
            queueMetrics: {
              ...metrics,
              averageSyncTime:
                (metrics.averageSyncTime * metrics.successfulSyncs + syncTime) /
                (metrics.successfulSyncs + 1),
            },
          });
        },

        retryQueueItem: async (id) => {
          const item = get().offlineQueue.find(i => i.id === id);
          if (item) {
            get().updateQueueItem(id, { status: 'pending', retryCount: 0 });
            await get().processQueue();
          }
        },

        clearQueue: () => {
          set({ offlineQueue: [] });
          indexedDBStorage.clear('queue');
        },

        setCachedData: (key, data, expiresIn) => {
          const cachedData = get().cachedData;
          const cacheItem: CachedData = {
            key,
            data,
            timestamp: Date.now(),
            expiresAt: expiresIn ? Date.now() + expiresIn : 0,
            version: '1.0.0',
            syncStatus: 'pending',
          };
          
          cachedData.set(key, cacheItem);
          set({ cachedData: new Map(cachedData) });
          
          // Store in IndexedDB for large data
          indexedDBStorage.set('cache', cacheItem);
        },

        getCachedData: <T = unknown>(key: string): T | null => {
          const cacheItem = get().cachedData.get(key);
          
          if (!cacheItem) return null;
          
          // Check expiration
          if (cacheItem.expiresAt && Date.now() > cacheItem.expiresAt) {
            get().invalidateCache(key);
            return null;
          }
          
          return cacheItem.data as T;
        },

        invalidateCache: (key) => {
          const cachedData = get().cachedData;
          cachedData.delete(key);
          set({ cachedData: new Map(cachedData) });
          indexedDBStorage.delete('cache', key);
        },

        clearCache: () => {
          set({ cachedData: new Map() });
          indexedDBStorage.clear('cache');
        },

        syncCache: async () => {
          const { cachedData, isOnline } = get();
          
          if (!isOnline) return;

          for (const [key, item] of cachedData.entries()) {
            if (item.syncStatus === 'pending') {
              try {
                // Implement actual sync logic based on your API
                // This is a placeholder
                const response = await fetch(`/api/sync/${key}`, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify(item.data),
                });

                if (response.ok) {
                  item.syncStatus = 'synced';
                  cachedData.set(key, item);
                }
              } catch (error) {
                
              }
            }
          }

          set({ cachedData: new Map(cachedData) });
        },

        addConflict: (conflict) => {
          const newConflict: ConflictResolution = {
            ...conflict,
            id: `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            timestamp: Date.now(),
          };
          
          set({ conflicts: [...get().conflicts, newConflict] });
          indexedDBStorage.set('conflicts', newConflict);
        },

        resolveConflict: (id, resolvedData) => {
          const conflicts = get().conflicts.map(c =>
            c.id === id ? { ...c, resolvedData } : c
          );
          set({ conflicts });
          
          const resolved = conflicts.find(c => c.id === id);
          if (resolved) {
            indexedDBStorage.set('conflicts', resolved);
          }
        },

        clearConflicts: () => {
          set({ conflicts: [] });
          indexedDBStorage.clear('conflicts');
        },

        startSync: async () => {
          const { syncInProgress, settings } = get();
          
          if (syncInProgress || !settings.enableOfflineMode) return;

          // Process queue
          await get().processQueue();
          
          // Sync cache
          await get().syncCache();

          // Schedule next sync if auto-sync is enabled
          if (settings.autoSync) {
            setTimeout(() => {
              if (get().isOnline) {
                get().startSync();
              }
            }, settings.syncInterval);
          }
        },

        stopSync: () => {
          set({ syncInProgress: false });
        },

        forceSync: async () => {
          const { isOnline } = get();
          
          if (!isOnline) {
            throw new Error('Cannot sync while offline');
          }

          await get().startSync();
        },

        updateSettings: (newSettings) => {
          set({ settings: { ...get().settings, ...newSettings } });
        },

        getQueueSize: () => get().offlineQueue.length,

        getCacheSize: () => {
          const cache = get().cachedData;
          let size = 0;
          
          for (const item of cache.values()) {
            size += JSON.stringify(item).length;
          }
          
          return size;
        },

        exportOfflineData: async () => {
          const data = {
            queue: get().offlineQueue,
            cache: Array.from(get().cachedData.entries()),
            conflicts: get().conflicts,
            settings: get().settings,
            metrics: get().queueMetrics,
            timestamp: Date.now(),
          };

          return new Blob([JSON.stringify(data, null, 2)], {
            type: 'application/json',
          });
        },

        importOfflineData: async (blob) => {
          const text = await blob.text();
          const data = JSON.parse(text);

          set({
            offlineQueue: data.queue || [],
            cachedData: new Map(data.cache || []),
            conflicts: data.conflicts || [],
            settings: { ...get().settings, ...data.settings },
            queueMetrics: data.metrics || get().queueMetrics,
          });

          // Store in IndexedDB
          for (const item of data.queue || []) {
            await indexedDBStorage.set('queue', item);
          }
          for (const [, item] of data.cache || []) {
            await indexedDBStorage.set('cache', item);
          }
          for (const item of data.conflicts || []) {
            await indexedDBStorage.set('conflicts', item);
          }
        },

        clearAllOfflineData: () => {
          set({
            offlineQueue: [],
            cachedData: new Map(),
            conflicts: [],
            syncErrors: [],
            lastSyncTime: null,
            queueMetrics: {
              totalQueued: 0,
              successfulSyncs: 0,
              failedSyncs: 0,
              averageSyncTime: 0,
            },
          });

          // Clear IndexedDB
          indexedDBStorage.clear('queue');
          indexedDBStorage.clear('cache');
          indexedDBStorage.clear('conflicts');
        },
      }),
      {
        name: 'offline-storage',
        storage: createJSONStorage(() => localStorage),
        partialize: (state) => ({
          settings: state.settings,
          queueMetrics: state.queueMetrics,
          lastSyncTime: state.lastSyncTime,
        }),
        onRehydrateStorage: () => (state) => {
          if (state) {
            state.isRehydrated = true;
            
            // Initialize IndexedDB and load persisted data
            indexedDBStorage.init().then(async () => {
              const queue = await indexedDBStorage.getAll<OfflineQueueItem>('queue');
              const cache = await indexedDBStorage.getAll<CachedData>('cache');
              const conflicts = await indexedDBStorage.getAll<ConflictResolution>('conflicts');
              
              state.offlineQueue = queue;
              state.cachedData = new Map(cache.map(c => [c.key, c]));
              state.conflicts = conflicts;
            });

            // Register service worker
            registerServiceWorker();

            // Set up online/offline listeners
            if (typeof window !== 'undefined') {
              window.addEventListener('online', () => state.setOnlineStatus(true));
              window.addEventListener('offline', () => state.setOnlineStatus(false));
            }
          }
        },
      }
    ),
    {
      name: 'OfflineStore',
    }
  )
);

// Export helper hooks
export const useIsOnline = () => useOfflineStore((state) => state.isOnline);
export const useOfflineQueue = () => useOfflineStore((state) => state.offlineQueue);
export const useSyncStatus = () => useOfflineStore((state) => ({
  inProgress: state.syncInProgress,
  lastSync: state.lastSyncTime,
}));