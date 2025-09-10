/**
 * Notification Store using Zustand
 * 
 * Manages notifications, toasts, alerts, and in-app messaging system.
 * Provides a centralized way to handle user notifications and system messages.
 */

import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { ApiResponse, PaginatedResponse } from '@/types';

// Notification types
export type NotificationType = 
  | 'info' 
  | 'success' 
  | 'warning' 
  | 'error' 
  | 'security'
  | 'system'
  | 'marketing';

export type NotificationPriority = 'low' | 'medium' | 'high' | 'urgent';

export type ToastVariant = 'default' | 'success' | 'error' | 'warning' | 'info';

export type ToastPosition = 
  | 'top-left' 
  | 'top-center' 
  | 'top-right' 
  | 'bottom-left' 
  | 'bottom-center' 
  | 'bottom-right';

// Toast notification interface
export interface Toast {
  id: string;
  title?: string;
  message: string;
  variant: ToastVariant;
  duration?: number; // in milliseconds, null for persistent
  position?: ToastPosition;
  action?: {
    label: string;
    onClick: () => void;
  };
  dismissible?: boolean;
  timestamp: Date;
  isVisible: boolean;
}

// In-app notification interface
export interface Notification {
  id: string;
  type: NotificationType;
  priority: NotificationPriority;
  title: string;
  message: string;
  data?: Record<string, unknown>;
  read: boolean;
  action_url?: string;
  action_label?: string;
  expires_at?: string;
  created_at: string;
  updated_at: string;
  category?: string;
  sender?: {
    id: string;
    name: string;
    avatar?: string;
  };
  metadata?: {
    feature: string;
    source: string;
    campaign_id?: string;
  };
}

// System alert interface
export interface SystemAlert {
  id: string;
  type: 'maintenance' | 'security' | 'feature' | 'incident' | 'update';
  severity: 'low' | 'medium' | 'high' | 'critical';
  title: string;
  message: string;
  start_time: string;
  end_time?: string;
  is_active: boolean;
  affects_functionality: boolean;
  action_required: boolean;
  learn_more_url?: string;
  status_page_url?: string;
}

// Notification preferences interface
export interface NotificationPreferences {
  email_notifications: boolean;
  push_notifications: boolean;
  browser_notifications: boolean;
  sms_notifications: boolean;
  in_app_notifications: boolean;
  
  // Category preferences
  security_alerts: boolean;
  system_updates: boolean;
  feature_announcements: boolean;
  marketing_messages: boolean;
  account_activity: boolean;
  social_interactions: boolean;
  
  // Delivery preferences
  immediate_delivery: boolean;
  daily_digest: boolean;
  weekly_digest: boolean;
  quiet_hours_enabled: boolean;
  quiet_hours_start: string; // "22:00"
  quiet_hours_end: string; // "08:00"
  
  // Advanced preferences
  group_similar_notifications: boolean;
  auto_mark_read_after: number; // days
  max_notifications_per_day: number;
}

// Notification statistics interface
export interface NotificationStats {
  total_notifications: number;
  unread_count: number;
  read_count: number;
  notifications_today: number;
  notifications_this_week: number;
  notifications_this_month: number;
  most_common_type: NotificationType;
  avg_time_to_read: number; // in minutes
  categories_breakdown: Record<string, number>;
}

// Error handling for notifications
export interface NotificationError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: Date;
}

// Notification store state interface
export interface NotificationState {
  // Toast notifications
  toasts: Toast[];
  toastPosition: ToastPosition;
  toastDuration: number;
  maxToasts: number;
  
  // In-app notifications
  notifications: Notification[];
  unreadCount: number;
  notificationsPagination: {
    page: number;
    size: number;
    total: number;
    pages: number;
  };
  
  // System alerts
  systemAlerts: SystemAlert[];
  activeAlertsCount: number;
  
  // Notification preferences
  preferences: NotificationPreferences | null;
  
  // Statistics
  stats: NotificationStats | null;
  
  // UI state
  isNotificationPanelOpen: boolean;
  isPreferencesModalOpen: boolean;
  selectedNotificationId: string | null;
  
  // Loading states
  isLoading: boolean;
  isSaving: boolean;
  isMarkingAsRead: boolean;
  
  // Error handling
  error: NotificationError | null;
  errors: NotificationError[];
  
  // Browser notifications
  browserNotificationsPermission: NotificationPermission;
  browserNotificationsEnabled: boolean;
  
  // Actions
  // Toast management
  addToast: (toast: Omit<Toast, 'id' | 'timestamp' | 'isVisible'>) => string;
  removeToast: (id: string) => void;
  clearAllToasts: () => void;
  updateToast: (id: string, updates: Partial<Toast>) => void;
  showSuccessToast: (message: string, options?: Partial<Toast>) => string;
  showErrorToast: (message: string, options?: Partial<Toast>) => string;
  showWarningToast: (message: string, options?: Partial<Toast>) => string;
  showInfoToast: (message: string, options?: Partial<Toast>) => string;
  
  // Toast configuration
  setToastPosition: (position: ToastPosition) => void;
  setToastDuration: (duration: number) => void;
  setMaxToasts: (max: number) => void;
  
  // In-app notification management
  fetchNotifications: (params?: { page?: number; unread_only?: boolean; type?: NotificationType }) => Promise<void>;
  markAsRead: (notificationId: string) => Promise<boolean>;
  markAllAsRead: () => Promise<boolean>;
  deleteNotification: (notificationId: string) => Promise<boolean>;
  deleteAllRead: () => Promise<boolean>;
  archiveNotification: (notificationId: string) => Promise<boolean>;
  
  // Bulk operations
  markMultipleAsRead: (notificationIds: string[]) => Promise<boolean>;
  deleteMultiple: (notificationIds: string[]) => Promise<boolean>;
  
  // System alerts
  fetchSystemAlerts: () => Promise<void>;
  dismissSystemAlert: (alertId: string) => Promise<boolean>;
  acknowledgeAlert: (alertId: string) => Promise<boolean>;
  
  // Notification preferences
  fetchPreferences: () => Promise<void>;
  updatePreferences: (preferences: Partial<NotificationPreferences>) => Promise<boolean>;
  resetPreferences: () => Promise<boolean>;
  
  // Statistics
  fetchStats: () => Promise<void>;
  
  // UI state management
  openNotificationPanel: () => void;
  closeNotificationPanel: () => void;
  toggleNotificationPanel: () => void;
  openPreferencesModal: () => void;
  closePreferencesModal: () => void;
  selectNotification: (notificationId: string | null) => void;
  
  // Browser notifications
  requestBrowserPermission: () => Promise<NotificationPermission>;
  enableBrowserNotifications: () => void;
  disableBrowserNotifications: () => void;
  showBrowserNotification: (title: string, options?: NotificationOptions) => void;
  
  // Real-time features
  connectWebSocket: () => void;
  disconnectWebSocket: () => void;
  subscribeToNotifications: (userId: string) => void;
  unsubscribeFromNotifications: () => void;
  
  // Error management
  setError: (error: NotificationError | null) => void;
  clearError: () => void;
  addError: (error: NotificationError) => void;
  clearErrors: () => void;
  
  // Utility actions
  refreshData: () => Promise<void>;
  clearAllData: () => void;
  exportNotifications: (format: 'json' | 'csv') => Promise<string>;
}

// Mock API functions - replace with actual API calls
const NotificationAPI = {
  async fetchNotifications(_params: { page?: number; unread_only?: boolean; type?: NotificationType }): Promise<ApiResponse<PaginatedResponse<Notification>>> {
    // Mock implementation - log params for debugging
    // Fetching notifications with params
    await new Promise(resolve => setTimeout(resolve, 500));
    return { 
      success: true, 
      data: { 
        items: [], 
        total: 0, 
        page: 1, 
        per_page: 10, 
        pages: 0, 
        has_next: false, 
        has_prev: false 
      } 
    };
  },
  
  async markAsRead(_notificationId: string): Promise<ApiResponse<{ success: boolean }>> {
    // Mock implementation - log notification ID for debugging
    // Marking notification as read
    await new Promise(resolve => setTimeout(resolve, 200));
    return { success: true, data: { success: true } };
  },
  
  async markAllAsRead(): Promise<ApiResponse<{ count: number }>> {
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: { count: 0 } };
  },
  
  async deleteNotification(_notificationId: string): Promise<ApiResponse<{ success: boolean }>> {
    // Mock implementation - log notification ID for debugging
    // Deleting notification
    await new Promise(resolve => setTimeout(resolve, 300));
    return { success: true, data: { success: true } };
  },
  
  async fetchSystemAlerts(): Promise<ApiResponse<SystemAlert[]>> {
    await new Promise(resolve => setTimeout(resolve, 400));
    return { success: true, data: [] };
  },
  
  async fetchPreferences(): Promise<ApiResponse<NotificationPreferences>> {
    await new Promise(resolve => setTimeout(resolve, 300));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async updatePreferences(_preferences: Partial<NotificationPreferences>): Promise<ApiResponse<NotificationPreferences>> {
    // Mock implementation - log preferences for debugging
    // Updating notification preferences
    await new Promise(resolve => setTimeout(resolve, 600));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  },
  
  async fetchStats(): Promise<ApiResponse<NotificationStats>> {
    await new Promise(resolve => setTimeout(resolve, 400));
    return { success: false, error: { code: 'NOT_IMPLEMENTED', message: 'Mock API not implemented' } };
  }
};

// Generate unique ID for toasts
const generateToastId = (): string => {
  return `toast_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

export const useNotificationStore = create<NotificationState>()(
  devtools(
    subscribeWithSelector(
      persist(
        immer((set, get) => ({
          // Initial state
          toasts: [],
          toastPosition: 'top-right',
          toastDuration: 5000,
          maxToasts: 5,
          
          notifications: [],
          unreadCount: 0,
          notificationsPagination: {
            page: 1,
            size: 20,
            total: 0,
            pages: 0,
          },
          
          systemAlerts: [],
          activeAlertsCount: 0,
          
          preferences: null,
          stats: null,
          
          isNotificationPanelOpen: false,
          isPreferencesModalOpen: false,
          selectedNotificationId: null,
          
          isLoading: false,
          isSaving: false,
          isMarkingAsRead: false,
          
          error: null,
          errors: [],
          
          browserNotificationsPermission: typeof window !== 'undefined' ? Notification.permission : 'default',
          browserNotificationsEnabled: false,
          
          // Toast management actions
          addToast: (toastData: Omit<Toast, 'id' | 'timestamp' | 'isVisible'>) => {
            const id = generateToastId();
            const toast: Toast = {
              id,
              timestamp: new Date(),
              isVisible: true,
              duration: get().toastDuration,
              position: get().toastPosition,
              dismissible: true,
              ...toastData,
            };
            
            set((state) => {
              // Add new toast
              state.toasts.unshift(toast);
              
              // Limit number of toasts
              if (state.toasts.length > state.maxToasts) {
                state.toasts = state.toasts.slice(0, state.maxToasts);
              }
            });
            
            // Auto-remove toast after duration (if not persistent)
            if (toast.duration && toast.duration > 0) {
              setTimeout(() => {
                get().removeToast(id);
              }, toast.duration);
            }
            
            return id;
          },
          
          removeToast: (id: string) => {
            set((state) => {
              const toastIndex = state.toasts.findIndex(toast => toast.id === id);
              if (toastIndex !== -1) {
                const toast = state.toasts[toastIndex];
                if (toast) {
                  toast.isVisible = false;
                }
                // Remove after animation
                setTimeout(() => {
                  const currentToasts = get().toasts;
                  set((state) => {
                    state.toasts = currentToasts.filter(toast => toast.id !== id);
                  });
                }, 300);
              }
            });
          },
          
          clearAllToasts: () => {
            set((state) => {
              state.toasts.forEach(toast => {
                toast.isVisible = false;
              });
            });
            
            // Clear after animation
            setTimeout(() => {
              set((state) => {
                state.toasts = [];
              });
            }, 300);
          },
          
          updateToast: (id: string, updates: Partial<Toast>) => {
            set((state) => {
              const toastIndex = state.toasts.findIndex(toast => toast.id === id);
              if (toastIndex !== -1) {
                Object.keys(updates).forEach(key => {
                  const value = updates[key as keyof Toast];
                  if (value !== undefined) {
                    (state.toasts[toastIndex] as Record<string, unknown>)[key] = value;
                  }
                });
              }
            });
          },
          
          showSuccessToast: (message: string, options?: Partial<Toast>) => {
            return get().addToast({
              message,
              variant: 'success',
              ...options,
            });
          },
          
          showErrorToast: (message: string, options?: Partial<Toast>) => {
            return get().addToast({
              message,
              variant: 'error',
              duration: 8000, // Longer duration for errors
              ...options,
            });
          },
          
          showWarningToast: (message: string, options?: Partial<Toast>) => {
            return get().addToast({
              message,
              variant: 'warning',
              duration: 7000,
              ...options,
            });
          },
          
          showInfoToast: (message: string, options?: Partial<Toast>) => {
            return get().addToast({
              message,
              variant: 'info',
              ...options,
            });
          },
          
          // Toast configuration
          setToastPosition: (position: ToastPosition) => {
            set((state) => {
              state.toastPosition = position;
            });
          },
          
          setToastDuration: (duration: number) => {
            set((state) => {
              state.toastDuration = duration;
            });
          },
          
          setMaxToasts: (max: number) => {
            set((state) => {
              state.maxToasts = Math.max(1, Math.min(10, max));
              // Trim existing toasts if necessary
              if (state.toasts.length > state.maxToasts) {
                state.toasts = state.toasts.slice(0, state.maxToasts);
              }
            });
          },
          
          // In-app notification management
          fetchNotifications: async (params = {}) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await NotificationAPI.fetchNotifications(params);
              if (response.success && response.data) {
                set((state) => {
                  state.notifications = response.data?.items || [];
                  state.notificationsPagination = {
                    page: response.data?.page || 1,
                    size: response.data?.per_page || 20,
                    total: response.data?.total || 0,
                    pages: response.data?.pages || 0,
                  };
                  state.unreadCount = state.notifications.filter(n => !n.read).length;
                });
              }
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'FETCH_NOTIFICATIONS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch notifications',
                timestamp: new Date(),
              };
              get().setError(notificationError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          markAsRead: async (notificationId: string) => {
            set((state) => {
              state.isMarkingAsRead = true;
              state.error = null;
            });
            
            try {
              const response = await NotificationAPI.markAsRead(notificationId);
              if (response.success) {
                set((state) => {
                  const notification = state.notifications.find(n => n.id === notificationId);
                  if (notification && !notification.read) {
                    notification.read = true;
                    state.unreadCount = Math.max(0, state.unreadCount - 1);
                  }
                });
                return true;
              }
              return false;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'MARK_READ_ERROR',
                message: error instanceof Error ? error.message : 'Failed to mark notification as read',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isMarkingAsRead = false;
              });
            }
          },
          
          markAllAsRead: async () => {
            set((state) => {
              state.isMarkingAsRead = true;
              state.error = null;
            });
            
            try {
              const response = await NotificationAPI.markAllAsRead();
              if (response.success) {
                set((state) => {
                  state.notifications.forEach(notification => {
                    notification.read = true;
                  });
                  state.unreadCount = 0;
                });
                return true;
              }
              return false;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'MARK_ALL_READ_ERROR',
                message: error instanceof Error ? error.message : 'Failed to mark all notifications as read',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isMarkingAsRead = false;
              });
            }
          },
          
          deleteNotification: async (notificationId: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await NotificationAPI.deleteNotification(notificationId);
              if (response.success) {
                set((state) => {
                  const notificationIndex = state.notifications.findIndex(n => n.id === notificationId);
                  if (notificationIndex !== -1) {
                    const notification = state.notifications[notificationIndex]!;
                    if (!notification.read) {
                      state.unreadCount = Math.max(0, state.unreadCount - 1);
                    }
                    state.notifications.splice(notificationIndex, 1);
                  }
                });
                return true;
              }
              return false;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'DELETE_NOTIFICATION_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete notification',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          deleteAllRead: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - in real app, make API call
              await new Promise(resolve => setTimeout(resolve, 800));
              
              set((state) => {
                state.notifications = state.notifications.filter(n => !n.read);
              });
              return true;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'DELETE_READ_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete read notifications',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          archiveNotification: async (notificationId: string) => {
            // Similar implementation to deleteNotification
            return await get().deleteNotification(notificationId);
          },
          
          // Bulk operations
          markMultipleAsRead: async (notificationIds: string[]) => {
            set((state) => {
              state.isMarkingAsRead = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - in real app, make batch API call
              await new Promise(resolve => setTimeout(resolve, 1000));
              
              let unreadDecrement = 0;
              set((state) => {
                notificationIds.forEach(id => {
                  const notification = state.notifications.find(n => n.id === id);
                  if (notification && !notification.read) {
                    notification.read = true;
                    unreadDecrement++;
                  }
                });
                state.unreadCount = Math.max(0, state.unreadCount - unreadDecrement);
              });
              return true;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'BULK_MARK_READ_ERROR',
                message: error instanceof Error ? error.message : 'Failed to mark multiple notifications as read',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isMarkingAsRead = false;
              });
            }
          },
          
          deleteMultiple: async (notificationIds: string[]) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - in real app, make batch API call
              await new Promise(resolve => setTimeout(resolve, 1200));
              
              let unreadDecrement = 0;
              set((state) => {
                state.notifications = state.notifications.filter(notification => {
                  if (notificationIds.includes(notification.id)) {
                    if (!notification.read) {
                      unreadDecrement++;
                    }
                    return false;
                  }
                  return true;
                });
                state.unreadCount = Math.max(0, state.unreadCount - unreadDecrement);
              });
              return true;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'BULK_DELETE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete multiple notifications',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // System alerts
          fetchSystemAlerts: async () => {
            try {
              const response = await NotificationAPI.fetchSystemAlerts();
              if (response.success && response.data) {
                set((state) => {
                  state.systemAlerts = response.data || [];
                  state.activeAlertsCount = state.systemAlerts.filter(alert => alert.is_active).length;
                });
              }
            } catch {
              
            }
          },
          
          dismissSystemAlert: async (alertId: string) => {
            try {
              // Mock implementation - in real app, make API call
              await new Promise(resolve => setTimeout(resolve, 300));
              
              set((state) => {
                const alertIndex = state.systemAlerts.findIndex(alert => alert.id === alertId);
                if (alertIndex !== -1) {
                  const alert = state.systemAlerts[alertIndex];
                  if (alert) {
                    alert.is_active = false;
                  }
                  state.activeAlertsCount = Math.max(0, state.activeAlertsCount - 1);
                }
              });
              return true;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'DISMISS_ALERT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to dismiss alert',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            }
          },
          
          acknowledgeAlert: async (alertId: string) => {
            // Similar to dismissSystemAlert
            return await get().dismissSystemAlert(alertId);
          },
          
          // Notification preferences
          fetchPreferences: async () => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await NotificationAPI.fetchPreferences();
              if (response.success && response.data) {
                set((state) => {
                  state.preferences = response.data || null;
                });
              }
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'FETCH_PREFERENCES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch notification preferences',
                timestamp: new Date(),
              };
              get().setError(notificationError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          updatePreferences: async (preferences: Partial<NotificationPreferences>) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await NotificationAPI.updatePreferences(preferences);
              if (response.success && response.data) {
                set((state) => {
                  state.preferences = response.data || null;
                });
                return true;
              }
              return false;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'UPDATE_PREFERENCES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update notification preferences',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          resetPreferences: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - reset to defaults
              await new Promise(resolve => setTimeout(resolve, 600));
              
              const defaultPreferences: NotificationPreferences = {
                email_notifications: true,
                push_notifications: true,
                browser_notifications: false,
                sms_notifications: false,
                in_app_notifications: true,
                security_alerts: true,
                system_updates: true,
                feature_announcements: true,
                marketing_messages: false,
                account_activity: true,
                social_interactions: true,
                immediate_delivery: true,
                daily_digest: false,
                weekly_digest: false,
                quiet_hours_enabled: false,
                quiet_hours_start: '22:00',
                quiet_hours_end: '08:00',
                group_similar_notifications: true,
                auto_mark_read_after: 30,
                max_notifications_per_day: 50,
              };
              
              set((state) => {
                state.preferences = defaultPreferences;
              });
              return true;
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'RESET_PREFERENCES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to reset notification preferences',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // Statistics
          fetchStats: async () => {
            try {
              const response = await NotificationAPI.fetchStats();
              if (response.success && response.data) {
                set((state) => {
                  state.stats = response.data || null;
                });
              }
            } catch {
              
            }
          },
          
          // UI state management
          openNotificationPanel: () => {
            set((state) => {
              state.isNotificationPanelOpen = true;
            });
          },
          
          closeNotificationPanel: () => {
            set((state) => {
              state.isNotificationPanelOpen = false;
            });
          },
          
          toggleNotificationPanel: () => {
            set((state) => {
              state.isNotificationPanelOpen = !state.isNotificationPanelOpen;
            });
          },
          
          openPreferencesModal: () => {
            set((state) => {
              state.isPreferencesModalOpen = true;
            });
          },
          
          closePreferencesModal: () => {
            set((state) => {
              state.isPreferencesModalOpen = false;
            });
          },
          
          selectNotification: (notificationId: string | null) => {
            set((state) => {
              state.selectedNotificationId = notificationId;
            });
          },
          
          // Browser notifications
          requestBrowserPermission: async () => {
            if (typeof window === 'undefined' || !('Notification' in window)) {
              return 'denied';
            }
            
            try {
              const permission = await Notification.requestPermission();
              set((state) => {
                state.browserNotificationsPermission = permission;
                if (permission === 'granted') {
                  state.browserNotificationsEnabled = true;
                }
              });
              return permission;
            } catch (error) {
              
              return 'denied';
            }
          },
          
          enableBrowserNotifications: () => {
            set((state) => {
              state.browserNotificationsEnabled = true;
            });
          },
          
          disableBrowserNotifications: () => {
            set((state) => {
              state.browserNotificationsEnabled = false;
            });
          },
          
          showBrowserNotification: (title: string, options?: NotificationOptions) => {
            if (
              typeof window === 'undefined' ||
              !('Notification' in window) ||
              Notification.permission !== 'granted' ||
              !get().browserNotificationsEnabled
            ) {
              return;
            }
            
            try {
              new Notification(title, {
                icon: '/favicon.ico',
                badge: '/badge-icon.png',
                ...options,
              });
            } catch {
              
            }
          },
          
          // Real-time features (WebSocket implementation would go here)
          connectWebSocket: () => {
            // Mock implementation - in real app, establish WebSocket connection
            
          },
          
          disconnectWebSocket: () => {
            // Mock implementation - in real app, close WebSocket connection
            
          },
          
          subscribeToNotifications: (_userId: string) => {
            // Mock implementation - in real app, subscribe to user-specific notifications
            
          },
          
          unsubscribeFromNotifications: () => {
            // Mock implementation - in real app, unsubscribe from notifications
            
          },
          
          // Error management
          setError: (error: NotificationError | null) => {
            set((state) => {
              state.error = error;
              if (error) {
                state.errors.push(error);
                // Keep only last 5 errors
                if (state.errors.length > 5) {
                  state.errors = state.errors.slice(-5);
                }
              }
            });
          },
          
          clearError: () => {
            set((state) => {
              state.error = null;
            });
          },
          
          addError: (error: NotificationError) => {
            set((state) => {
              state.errors.push(error);
              // Keep only last 5 errors
              if (state.errors.length > 5) {
                state.errors = state.errors.slice(-5);
              }
            });
          },
          
          clearErrors: () => {
            set((state) => {
              state.errors = [];
            });
          },
          
          // Utility actions
          refreshData: async () => {
            await Promise.all([
              get().fetchNotifications(),
              get().fetchSystemAlerts(),
              get().fetchPreferences(),
              get().fetchStats(),
            ]);
          },
          
          clearAllData: () => {
            set((state) => {
              state.notifications = [];
              state.systemAlerts = [];
              state.unreadCount = 0;
              state.activeAlertsCount = 0;
              state.stats = null;
              state.selectedNotificationId = null;
              state.error = null;
              state.errors = [];
            });
          },
          
          exportNotifications: async (format: 'json' | 'csv') => {
            try {
              const notifications = get().notifications;
              
              if (format === 'json') {
                return JSON.stringify(notifications, null, 2);
              } else {
                const csvHeaders = 'id,type,title,message,read,created_at\n';
                const csvRows = notifications.map(n => 
                  `${n.id},${n.type},"${n.title}","${n.message}",${n.read},${n.created_at}`
                ).join('\n');
                return csvHeaders + csvRows;
              }
            } catch (error) {
              const notificationError: NotificationError = {
                code: 'EXPORT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to export notifications',
                timestamp: new Date(),
              };
              get().setError(notificationError);
              return '';
            }
          },
        })),
        {
          name: 'notification-storage',
          // Persist UI preferences and settings
          partialize: (state) => ({
            toastPosition: state.toastPosition,
            toastDuration: state.toastDuration,
            maxToasts: state.maxToasts,
            browserNotificationsEnabled: state.browserNotificationsEnabled,
            preferences: state.preferences,
          }),
        }
      )
    ),
    {
      name: 'NotificationStore',
    }
  )
);

// Selector hooks for common use cases
export const useToasts = () => useNotificationStore((state) => state.toasts);
export const useNotifications = () => useNotificationStore((state) => state.notifications);
export const useUnreadCount = () => useNotificationStore((state) => state.unreadCount);
export const useSystemAlerts = () => useNotificationStore((state) => state.systemAlerts);
export const useNotificationPreferences = () => useNotificationStore((state) => state.preferences);
export const useNotificationStats = () => useNotificationStore((state) => state.stats);
export const useNotificationLoading = () => useNotificationStore((state) => state.isLoading);
export const useNotificationError = () => useNotificationStore((state) => state.error);

// Helper hooks for common notification patterns
export const useNotification = useNotificationStore;

export function useToast() {
  const store = useNotificationStore();
  
  return {
    toasts: store.toasts,
    position: store.toastPosition,
    duration: store.toastDuration,
    maxToasts: store.maxToasts,
    
    // Actions
    add: store.addToast,
    remove: store.removeToast,
    clear: store.clearAllToasts,
    update: store.updateToast,
    success: store.showSuccessToast,
    error: store.showErrorToast,
    warning: store.showWarningToast,
    info: store.showInfoToast,
    
    // Configuration
    setPosition: store.setToastPosition,
    setDuration: store.setToastDuration,
    setMaxToasts: store.setMaxToasts,
  };
}

export function useNotificationPanel() {
  const store = useNotificationStore();
  
  return {
    isOpen: store.isNotificationPanelOpen,
    notifications: store.notifications,
    unreadCount: store.unreadCount,
    pagination: store.notificationsPagination,
    isLoading: store.isLoading,
    error: store.error,
    selectedId: store.selectedNotificationId,
    
    // Actions
    open: store.openNotificationPanel,
    close: store.closeNotificationPanel,
    toggle: store.toggleNotificationPanel,
    fetch: store.fetchNotifications,
    markAsRead: store.markAsRead,
    markAllAsRead: store.markAllAsRead,
    delete: store.deleteNotification,
    deleteAllRead: store.deleteAllRead,
    select: store.selectNotification,
  };
}

export function useBrowserNotifications() {
  const store = useNotificationStore();
  
  return {
    permission: store.browserNotificationsPermission,
    enabled: store.browserNotificationsEnabled,
    
    // Actions
    requestPermission: store.requestBrowserPermission,
    enable: store.enableBrowserNotifications,
    disable: store.disableBrowserNotifications,
    show: store.showBrowserNotification,
  };
}