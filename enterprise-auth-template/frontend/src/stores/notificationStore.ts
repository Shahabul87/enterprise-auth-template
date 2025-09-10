import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

export type NotificationType = 'info' | 'success' | 'warning' | 'error';
export type NotificationPriority = 'low' | 'medium' | 'high' | 'urgent';

export interface Notification {
  id: string;
  type: NotificationType;
  title: string;
  message: string;
  priority: NotificationPriority;
  read: boolean;
  archived: boolean;
  persistent: boolean;
  actionable: boolean;
  actions?: NotificationAction[];
  metadata?: Record<string, unknown>;
  createdAt: string;
  readAt: string | null;
  expiresAt?: string;
  source: 'system' | 'user' | 'admin' | 'security' | 'marketing';
  category: string;
  icon?: string;
  image?: string;
  link?: string;
}

export interface NotificationAction {
  id: string;
  label: string;
  action: () => void;
  variant?: 'outline' | 'default' | 'destructive' | 'secondary' | 'ghost' | 'link';
  style: 'primary' | 'secondary' | 'danger';
  data?: Record<string, unknown>;
}

export interface NotificationPreferences {
  enabled: boolean;
  sound: boolean;
  soundEnabled: boolean;
  notificationsEnabled: boolean;
  pushEnabled: boolean;
  emailEnabled: boolean;
  desktop: boolean;
  email: boolean;
  push: boolean;
  inApp: boolean;
  categories: {
    system: boolean;
    security: boolean;
    updates: boolean;
    marketing: boolean;
    social: boolean;
  };
  quietHours: {
    enabled: boolean;
    start: string;
    end: string;
  };
  grouping: boolean;
  autoMarkAsRead: boolean;
  autoArchive: boolean;
  autoArchiveAfterDays: number;
}

export interface NotificationStats {
  total: number;
  unread: number;
  unreadByType: Record<NotificationType, number>;
  unreadByPriority: Record<NotificationPriority, number>;
  todayCount: number;
  weekCount: number;
}

interface NotificationState {
  // State
  notifications: Notification[];
  preferences: NotificationPreferences;
  stats: NotificationStats;
  isLoading: boolean;
  error: string | null;
  lastFetchTime: string | null;
  hasMore: boolean;
  page: number;
  pageSize: number;
  unreadCount: number;
  isConnected: boolean;
  filters: {
    type: NotificationType | 'all';
    priority: NotificationPriority | 'all';
    read: boolean | null;
    category: string | 'all';
    dateFrom: string | null;
    dateTo: string | null;
    search: string;
  };
  selectedNotification: Notification | null;
  soundEnabled: boolean;
  desktopPermission: NotificationPermission;

  // Actions - Core
  addNotification: (notification: Omit<Notification, 'id' | 'createdAt'>) => void;
  removeNotification: (id: string) => void;
  deleteNotification: (id: string) => void;
  updateNotification: (id: string, updates: Partial<Notification>) => void;
  clearNotifications: () => void;
  clearAll: () => void;

  // Actions - Fetch
  fetchNotifications: (page?: number) => Promise<void>;
  fetchMoreNotifications: () => Promise<void>;
  refreshNotifications: () => Promise<void>;
  fetchNotificationStats: () => Promise<void>;

  // Actions - Mark
  markAsRead: (id: string) => Promise<void>;
  markAsUnread: (id: string) => Promise<void>;
  markAllAsRead: () => Promise<void>;
  markMultipleAsRead: (ids: string[]) => Promise<void>;

  // Actions - Archive
  archiveNotification: (id: string) => Promise<void>;
  unarchiveNotification: (id: string) => Promise<void>;
  archiveAll: () => Promise<void>;
  archiveOld: (days: number) => Promise<void>;

  // Actions - Preferences
  fetchPreferences: () => Promise<void>;
  updatePreferences: (preferences: Partial<NotificationPreferences>) => Promise<void>;
  toggleSound: () => void;
  requestDesktopPermission: () => Promise<void>;

  // Actions - Filters
  setFilter: (key: keyof NotificationState['filters'], value: unknown) => void;
  clearFilters: () => void;
  applyFilters: () => void;

  // Actions - Real-time
  subscribeToNotifications: () => void;
  unsubscribeFromNotifications: () => void;
  handleIncomingNotification: (notification: Notification) => void;

  // Actions - Actions
  executeAction: (notificationId: string, actionId: string) => Promise<void>;
  dismissNotification: (id: string) => void;

  // Actions - UI
  setSelectedNotification: (notification: Notification | null) => void;
  showNotification: (notification: Notification) => void;
  showToast: (type: NotificationType, title: string, message: string) => void;

  // Actions - Utils
  clearError: () => void;
  playNotificationSound: () => void;
  showDesktopNotification: (notification: Notification) => void;
}

const defaultPreferences: NotificationPreferences = {
  enabled: true,
  sound: true,
  soundEnabled: true,
  notificationsEnabled: true,
  pushEnabled: true,
  emailEnabled: true,
  desktop: true,
  email: true,
  push: true,
  inApp: true,
  categories: {
    system: true,
    security: true,
    updates: true,
    marketing: false,
    social: true,
  },
  quietHours: {
    enabled: false,
    start: '22:00',
    end: '08:00',
  },
  grouping: true,
  autoMarkAsRead: false,
  autoArchive: true,
  autoArchiveAfterDays: 30,
};

const defaultStats: NotificationStats = {
  total: 0,
  unread: 0,
  unreadByType: {
    info: 0,
    success: 0,
    warning: 0,
    error: 0,
  },
  unreadByPriority: {
    low: 0,
    medium: 0,
    high: 0,
    urgent: 0,
  },
  todayCount: 0,
  weekCount: 0,
};

let notificationSound: HTMLAudioElement | null = null;
let eventSource: EventSource | null = null;

export const useNotificationStore = create<NotificationState>()(
  devtools(
    (set, get) => ({
      // Initial state
      notifications: [],
      preferences: defaultPreferences,
      stats: defaultStats,
      isLoading: false,
      error: null,
      lastFetchTime: null,
      hasMore: true,
      page: 1,
      pageSize: 20,
      unreadCount: 0,
      isConnected: true,
      filters: {
        type: 'all',
        priority: 'all',
        read: null,
        category: 'all',
        dateFrom: null,
        dateTo: null,
        search: '',
      },
      selectedNotification: null,
      soundEnabled: true,
      desktopPermission: 'default',

      // Core Actions
      addNotification: (notification) => {
        const newNotification: Notification = {
          ...notification,
          id: `notif-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
          createdAt: new Date().toISOString(),
        };

        set((state) => ({
          notifications: [newNotification, ...state.notifications],
          stats: {
            ...state.stats,
            total: state.stats.total + 1,
            unread: notification.read ? state.stats.unread : state.stats.unread + 1,
          },
        }));

        // Show notification
        get().showNotification(newNotification);
      },

      removeNotification: (id) => {
        set((state) => ({
          notifications: state.notifications.filter((n) => n.id !== id),
        }));
      },

      deleteNotification: (id) => {
        set((state) => ({
          notifications: state.notifications.filter((n) => n.id !== id),
          unreadCount: state.unreadCount - (state.notifications.find(n => n.id === id && !n.read) ? 1 : 0),
        }));
      },

      updateNotification: (id, updates) => {
        set((state) => ({
          notifications: state.notifications.map((n) =>
            n.id === id ? { ...n, ...updates } : n
          ),
        }));
      },

      clearNotifications: () => {
        set({ notifications: [], stats: defaultStats });
      },

      clearAll: () => {
        set({
          notifications: [],
          stats: defaultStats,
          filters: {
            type: 'all',
            priority: 'all',
            read: null,
            category: 'all',
            dateFrom: null,
            dateTo: null,
            search: '',
          },
          selectedNotification: null,
          page: 1,
          hasMore: true,
        });
      },

      // Fetch Actions
      fetchNotifications: async (page = 1) => {
        set({ isLoading: true, error: null, page });
        try {
          const filters = get().filters;
          const params = new URLSearchParams({
            page: page.toString(),
            limit: get().pageSize.toString(),
            ...(filters.type !== 'all' && { type: filters.type }),
            ...(filters.priority !== 'all' && { priority: filters.priority }),
            ...(filters.read !== null && { read: filters.read.toString() }),
            ...(filters.category !== 'all' && { category: filters.category }),
            ...(filters.dateFrom && { date_from: filters.dateFrom }),
            ...(filters.dateTo && { date_to: filters.dateTo }),
            ...(filters.search && { search: filters.search }),
          });

          const response = await fetch(`/api/v1/notifications?${params}`, {
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to fetch notifications');

          const data = await response.json();
          set({
            notifications: page === 1 ? data.notifications : [...get().notifications, ...data.notifications],
            hasMore: data.has_more,
            lastFetchTime: new Date().toISOString(),
            isLoading: false,
          });

          // Fetch stats
          await get().fetchNotificationStats();
        } catch (error) {
          set({ error: (error as Error).message, isLoading: false });
        }
      },

      fetchMoreNotifications: async () => {
        if (!get().hasMore || get().isLoading) return;
        await get().fetchNotifications(get().page + 1);
      },

      refreshNotifications: async () => {
        await get().fetchNotifications(1);
      },

      fetchNotificationStats: async () => {
        try {
          const response = await fetch('/api/v1/notifications/stats', {
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to fetch notification stats');

          const stats = await response.json();
          set({ stats });
        } catch (error) {
          
        }
      },

      // Mark Actions
      markAsRead: async (id) => {
        try {
          const response = await fetch(`/api/v1/notifications/${id}/read`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to mark as read');

          set((state) => ({
            notifications: state.notifications.map((n) =>
              n.id === id ? { ...n, read: true, readAt: new Date().toISOString() } : n
            ),
            stats: {
              ...state.stats,
              unread: Math.max(0, state.stats.unread - 1),
            },
          }));
        } catch (error) {
          
        }
      },

      markAsUnread: async (id) => {
        try {
          const response = await fetch(`/api/v1/notifications/${id}/unread`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to mark as unread');

          set((state) => ({
            notifications: state.notifications.map((n) =>
              n.id === id ? { ...n, read: false, readAt: null } : n
            ),
            stats: {
              ...state.stats,
              unread: state.stats.unread + 1,
            },
          }));
        } catch (error) {
          
        }
      },

      markAllAsRead: async () => {
        try {
          const response = await fetch('/api/v1/notifications/read-all', {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to mark all as read');

          set((state) => ({
            notifications: state.notifications.map((n) => ({
              ...n,
              read: true,
              readAt: n.readAt || new Date().toISOString(),
            })),
            stats: {
              ...state.stats,
              unread: 0,
              unreadByType: {
                info: 0,
                success: 0,
                warning: 0,
                error: 0,
              },
              unreadByPriority: {
                low: 0,
                medium: 0,
                high: 0,
                urgent: 0,
              },
            },
          }));
        } catch (error) {
          
        }
      },

      markMultipleAsRead: async (ids) => {
        try {
          const response = await fetch('/api/v1/notifications/read-multiple', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
            body: JSON.stringify({ notification_ids: ids }),
          });

          if (!response.ok) throw new Error('Failed to mark multiple as read');

          set((state) => ({
            notifications: state.notifications.map((n) =>
              ids.includes(n.id) ? { ...n, read: true, readAt: new Date().toISOString() } : n
            ),
            stats: {
              ...state.stats,
              unread: Math.max(0, state.stats.unread - ids.length),
            },
          }));
        } catch (error) {
          
        }
      },

      // Archive Actions
      archiveNotification: async (id) => {
        try {
          const response = await fetch(`/api/v1/notifications/${id}/archive`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to archive notification');

          set((state) => ({
            notifications: state.notifications.map((n) =>
              n.id === id ? { ...n, archived: true } : n
            ),
          }));
        } catch (error) {
          
        }
      },

      unarchiveNotification: async (id) => {
        try {
          const response = await fetch(`/api/v1/notifications/${id}/unarchive`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to unarchive notification');

          set((state) => ({
            notifications: state.notifications.map((n) =>
              n.id === id ? { ...n, archived: false } : n
            ),
          }));
        } catch (error) {
          
        }
      },

      archiveAll: async () => {
        try {
          const response = await fetch('/api/v1/notifications/archive-all', {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to archive all notifications');

          set((state) => ({
            notifications: state.notifications.map((n) => ({ ...n, archived: true })),
          }));
        } catch (error) {
          
        }
      },

      archiveOld: async (days) => {
        try {
          const response = await fetch(`/api/v1/notifications/archive-old?days=${days}`, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to archive old notifications');

          const cutoffDate = new Date();
          cutoffDate.setDate(cutoffDate.getDate() - days);

          set((state) => ({
            notifications: state.notifications.map((n) =>
              new Date(n.createdAt) < cutoffDate ? { ...n, archived: true } : n
            ),
          }));
        } catch (error) {
          
        }
      },

      // Preferences Actions
      fetchPreferences: async () => {
        try {
          const response = await fetch('/api/v1/notifications/preferences', {
            headers: {
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
          });

          if (!response.ok) throw new Error('Failed to fetch preferences');

          const preferences = await response.json();
          set({ preferences });
        } catch (error) {
          
        }
      },

      updatePreferences: async (preferences) => {
        try {
          const currentPreferences = get().preferences;
          const updatedPreferences = { ...currentPreferences, ...preferences };

          const response = await fetch('/api/v1/notifications/preferences', {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
            body: JSON.stringify(updatedPreferences),
          });

          if (!response.ok) throw new Error('Failed to update preferences');

          set({ preferences: updatedPreferences });
        } catch (error) {
          
        }
      },

      toggleSound: () => {
        set((state) => ({ soundEnabled: !state.soundEnabled }));
      },

      requestDesktopPermission: async () => {
        if ('Notification' in window) {
          const permission = await Notification.requestPermission();
          set({ desktopPermission: permission });
        }
      },

      // Filter Actions
      setFilter: (key, value) => {
        set((state) => ({
          filters: {
            ...state.filters,
            [key]: value,
          },
        }));
      },

      clearFilters: () => {
        set({
          filters: {
            type: 'all',
            priority: 'all',
            read: null,
            category: 'all',
            dateFrom: null,
            dateTo: null,
            search: '',
          },
        });
      },

      applyFilters: () => {
        get().fetchNotifications(1);
      },

      // Real-time Actions
      subscribeToNotifications: () => {
        if (eventSource) return;

        const token = localStorage.getItem('access_token');
        if (!token) return;

        eventSource = new EventSource(`/api/v1/notifications/stream?token=${token}`);

        eventSource.onmessage = (event) => {
          const notification = JSON.parse(event.data);
          get().handleIncomingNotification(notification);
        };

        eventSource.onerror = () => {
          
          eventSource?.close();
          eventSource = null;
          // Retry after 5 seconds
          setTimeout(() => get().subscribeToNotifications(), 5000);
        };
      },

      unsubscribeFromNotifications: () => {
        eventSource?.close();
        eventSource = null;
      },

      handleIncomingNotification: (notification) => {
        get().addNotification(notification);
      },

      // Action Execution
      executeAction: async (notificationId, actionId) => {
        try {
          const notification = get().notifications.find((n) => n.id === notificationId);
          const action = notification?.actions?.find((a) => a.id === actionId);

          if (!action) throw new Error('Action not found');

          const response = await fetch(`/api/v1/notifications/${notificationId}/actions/${actionId}`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${localStorage.getItem('access_token')}`,
            },
            body: JSON.stringify(action.data || {}),
          });

          if (!response.ok) throw new Error('Failed to execute action');

          // Mark notification as read
          await get().markAsRead(notificationId);
        } catch (error) {
          
        }
      },

      dismissNotification: (id) => {
        get().removeNotification(id);
      },

      // UI Actions
      setSelectedNotification: (notification) => {
        set({ selectedNotification: notification });
        if (notification && !notification.read) {
          get().markAsRead(notification.id);
        }
      },

      showNotification: (notification) => {
        const { soundEnabled, desktopPermission, preferences } = get();

        // Play sound
        if (soundEnabled && preferences.sound) {
          get().playNotificationSound();
        }

        // Show desktop notification
        if (desktopPermission === 'granted' && preferences.desktop) {
          get().showDesktopNotification(notification);
        }
      },

      showToast: (type, title, message) => {
        get().addNotification({
          type,
          title,
          message,
          priority: type === 'error' ? 'high' : 'medium',
          read: false,
          readAt: null,
          archived: false,
          persistent: false,
          actionable: false,
          source: 'system',
          category: 'system',
        });
      },

      // Utility Actions
      clearError: () => set({ error: null }),

      playNotificationSound: () => {
        if (!notificationSound) {
          notificationSound = new Audio('/sounds/notification.mp3');
        }
        notificationSound.play().catch(() => {
          // Sound playback error - silently fail
        });
      },

      showDesktopNotification: (notification) => {
        if ('Notification' in window && Notification.permission === 'granted') {
          const notif = new Notification(notification.title, {
            body: notification.message,
            icon: notification.icon || '/icon-192.png',
            badge: '/badge-72.png',
            tag: notification.id,
            data: notification,
          });

          notif.onclick = () => {
            window.focus();
            get().setSelectedNotification(notification);
            if (notification.link) {
              window.location.href = notification.link;
            }
          };
        }
      },
    }),
    {
      name: 'NotificationStore',
    }
  )
);