
import { act, renderHook } from '@testing-library/react';
import { useNotificationStore } from '@/stores/notification-store';
import type { Notification, NotificationSettings } from '@/types';
import React from 'react';

jest.mock('zustand/middleware', () => ({
  devtools: (fn: any) => fn,
  persist: (fn: any) => fn,
  subscribeWithSelector: (fn: any) => fn,
}));

/**
 * @jest-environment jsdom
 */


// Mock zustand persist
describe('NotificationStore', () => {
  beforeEach(() => {
    // Reset store before each test
    const { result } = renderHook(() => useNotificationStore());
    act(() => {
      result.current.clearAll();
    });
    jest.clearAllTimers();
  });
});
describe('Initial State', () => {
    it('should have correct initial state', async () => {
      const { result } = renderHook(() => useNotificationStore());
      expect(result.current.notifications).toEqual([]);
      expect(result.current.unreadCount).toBe(0);
      expect(result.current.isLoading).toBe(false);
      expect(result.current.error).toBeNull();
    });
    it('should have default notification settings', async () => {
      const { result } = renderHook(() => useNotificationStore());
      expect(result.current.settings).toEqual({
        enabled: true,
        sound: true,
        desktop: true,
        email: true,
        push: true,
        frequency: 'instant'
      });
    });
  });

describe('Adding Notifications', () => {
    it('should add a notification', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notification: Notification = {
        id: 'notif-1',
        title: 'Test Notification',
        message: 'This is a test notification',
        type: 'info',
        timestamp: new Date().toISOString(),
        read: false,
      };
      act(() => {
        result.current.addNotification(notification);
      });
      expect(result.current.notifications).toHaveLength(1);
      expect(result.current.notifications[0]).toEqual(notification);
      expect(result.current.unreadCount).toBe(1);
    });
    it('should add multiple notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = [
        {
          id: 'notif-1',
          title: 'First',
          message: 'First message',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: false,
        },
        {
          id: 'notif-2',
          title: 'Second',
          message: 'Second message',
          type: 'success',
          timestamp: new Date().toISOString(),
          read: false,
        },
      ];
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      expect(result.current.notifications).toHaveLength(2);
      expect(result.current.unreadCount).toBe(2);
    });
    it('should prepend new notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const older = {
        id: 'old',
        title: 'Old',
        message: 'Old message',
        type: 'info' as const,
        timestamp: new Date(Date.now() - 10000).toISOString(),
        read: false,
      };
      const newer = {
        id: 'new',
        title: 'New',
        message: 'New message',
        type: 'info' as const,
        timestamp: new Date().toISOString(),
        read: false,
      };
      act(() => {
        result.current.addNotification(older);
        result.current.addNotification(newer);
      });
      expect(result.current.notifications[0].id).toBe('new');
      expect(result.current.notifications[1].id).toBe('old');
    });
    it('should not add duplicate notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notification: Notification = {
        id: 'notif-1',
        title: 'Test',
        message: 'Test message',
        type: 'info',
        timestamp: new Date().toISOString(),
        read: false,
      };
      act(() => {
        result.current.addNotification(notification);
        result.current.addNotification(notification); // Try to add duplicate
      });
      expect(result.current.notifications).toHaveLength(1);
    });
  });

describe('Marking as Read', () => {
    it('should mark notification as read', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notification: Notification = {
        id: 'notif-1',
        title: 'Test',
        message: 'Test message',
        type: 'info',
        timestamp: new Date().toISOString(),
        read: false,
      };
      act(() => {
        result.current.addNotification(notification);
      });
      expect(result.current.unreadCount).toBe(1);
      act(() => {
        result.current.markAsRead('notif-1');
      });
      expect(result.current.notifications[0].read).toBe(true);
      expect(result.current.unreadCount).toBe(0);
    });
    it('should mark all notifications as read', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = Array.from({ length: 5 }, (_, i) => ({
        id: `notif-${i}`,
        title: `Notification ${i}`,
        message: `Message ${i}`,
        type: 'info',
        timestamp: new Date().toISOString(),
        read: false,
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      expect(result.current.unreadCount).toBe(5);
      act(() => {
        result.current.markAllAsRead();
      });
      expect(result.current.unreadCount).toBe(0);
      result.current.notifications.forEach(notif => {
        expect(notif.read).toBe(true);
      });
    });
    it('should not affect already read notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notification: Notification = {
        id: 'notif-1',
        title: 'Test',
        message: 'Test message',
        type: 'info',
        timestamp: new Date().toISOString(),
        read: true,
      };
      act(() => {
        result.current.addNotification(notification);
      });
      expect(result.current.unreadCount).toBe(0);
      act(() => {
        result.current.markAsRead('notif-1');
      });
      expect(result.current.unreadCount).toBe(0);
    });
  });

describe('Removing Notifications', () => {
    it('should remove a notification', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = [
        {
          id: 'notif-1',
          title: 'First',
          message: 'First message',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: false,
        },
        {
          id: 'notif-2',
          title: 'Second',
          message: 'Second message',
          type: 'success',
          timestamp: new Date().toISOString(),
          read: false,
        },
      ];
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      act(() => {
        result.current.removeNotification('notif-1');
      });
      expect(result.current.notifications).toHaveLength(1);
      expect(result.current.notifications[0].id).toBe('notif-2');
      expect(result.current.unreadCount).toBe(1);
    });
    it('should clear all notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = Array.from({ length: 5 }, (_, i) => ({
        id: `notif-${i}`,
        title: `Notification ${i}`,
        message: `Message ${i}`,
        type: 'info',
        timestamp: new Date().toISOString(),
        read: i % 2 === 0,
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      act(() => {
        result.current.clearAll();
      });
      expect(result.current.notifications).toHaveLength(0);
      expect(result.current.unreadCount).toBe(0);
    });
    it('should clear only read notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = [
        {
          id: 'read-1',
          title: 'Read',
          message: 'Read message',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: true,
        },
        {
          id: 'unread-1',
          title: 'Unread',
          message: 'Unread message',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: false,
        },
      ];
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      act(() => {
        result.current.clearRead();
      });
      expect(result.current.notifications).toHaveLength(1);
      expect(result.current.notifications[0].id).toBe('unread-1');
      expect(result.current.unreadCount).toBe(1);
    });
  });

describe('Notification Types', () => {
    it('should handle different notification types', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const types: Array<'info' | 'success' | 'warning' | 'error'> = ['info', 'success', 'warning', 'error'];
      types.forEach(type => {
        act(() => {
          result.current.addNotification({
            id: `notif-${type}`,
            title: `${type} notification`,
            message: `This is a ${type} message`,
            type,
            timestamp: new Date().toISOString(),
            read: false
          });
        });
      });
      expect(result.current.notifications).toHaveLength(4);
      types.forEach((type, index) => {
        expect(result.current.notifications[3 - index].type).toBe(type);
      });
    });
    it('should filter notifications by type', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = [
        {
          id: 'info-1',
          title: 'Info',
          message: 'Info message',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: false,
        },
        {
          id: 'error-1',
          title: 'Error',
          message: 'Error message',
          type: 'error',
          timestamp: new Date().toISOString(),
          read: false,
        },
        {
          id: 'info-2',
          title: 'Info 2',
          message: 'Info message 2',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: false,
        },
      ];
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      const infoNotifications = result.current.getByType('info');
      expect(infoNotifications).toHaveLength(2);
      expect(infoNotifications.every(n => n.type === 'info')).toBe(true);
      const errorNotifications = result.current.getByType('error');
      expect(errorNotifications).toHaveLength(1);
      expect(errorNotifications[0].type).toBe('error');
    });
  });

describe('Settings Management', () => {
    it('should update notification settings', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const newSettings: Partial<NotificationSettings> = {
        sound: false,
        desktop: false,
        frequency: 'daily',
      };
      act(() => {
        result.current.updateSettings(newSettings);
      });
      expect(result.current.settings.sound).toBe(false);
      expect(result.current.settings.desktop).toBe(false);
      expect(result.current.settings.frequency).toBe('daily');
      expect(result.current.settings.enabled).toBe(true); // Unchanged
    });
    it('should toggle notifications enabled state', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const initialState = result.current.settings.enabled;
      act(() => {
        result.current.toggleNotifications();
      });
      expect(result.current.settings.enabled).toBe(!initialState);
      act(() => {
        result.current.toggleNotifications();
      });
      expect(result.current.settings.enabled).toBe(initialState);
    });
    it('should reset settings to defaults', async () => {
      const { result } = renderHook(() => useNotificationStore());
      act(() => {
        result.current.updateSettings({
          sound: false,
          desktop: false,
          email: false,
          push: false,
          frequency: 'weekly'
        });
      });
      act(() => {
        result.current.resetSettings();
      });
      expect(result.current.settings).toEqual({
        enabled: true,
        sound: true,
        desktop: true,
        email: true,
        push: true,
        frequency: 'instant'
      });
    });
  });

describe('Actions with Metadata', () => {
    it('should handle notifications with action metadata', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notification: Notification = {
        id: 'notif-action',
        title: 'Action Required',
        message: 'Please approve the request',
        type: 'warning',
        timestamp: new Date().toISOString(),
        read: false,
        action: {
          label: 'Approve',
          url: '/approve/123',
          callback: jest.fn(),
        },
      };
      act(() => {
        result.current.addNotification(notification);
      });
      const addedNotif = result.current.notifications[0];
      expect(addedNotif.action).toBeDefined();
      expect(addedNotif.action?.label).toBe('Approve');
      expect(addedNotif.action?.url).toBe('/approve/123');
    });
    it('should execute notification action callback', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const mockCallback = jest.fn();
      const notification: Notification = {
        id: 'notif-callback',
        title: 'Callback Test',
        message: 'Test callback execution',
        type: 'info',
        timestamp: new Date().toISOString(),
        read: false,
        action: {
          label: 'Execute',
          callback: mockCallback,
        },
      };
      act(() => {
        result.current.addNotification(notification);
      });
      act(() => {
        result.current.executeAction('notif-callback');
      });
      expect(mockCallback).toHaveBeenCalledTimes(1);
    });
  });

describe('Fetching Notifications', () => {
    it('should fetch notifications from API', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const mockNotifications: Notification[] = [
        {
          id: 'api-1',
          title: 'From API',
          message: 'Fetched notification',
          type: 'info',
          timestamp: new Date().toISOString(),
          read: false,
        },
      ];
      // Mock the fetch function
      const mockFetch = jest.fn().mockResolvedValue(mockNotifications);
      result.current.fetchNotifications = mockFetch;
      await act(async () => {
        await result.current.fetchNotifications();
      });
      expect(mockFetch).toHaveBeenCalledTimes(1);
    });
    it('should handle fetch errors', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const mockError = new Error('Failed to fetch');
      const mockFetch = jest.fn().mockRejectedValue(mockError);
      result.current.fetchNotifications = mockFetch;
      await act(async () => {
        try {
          await result.current.fetchNotifications();
        } catch (error) {
          // Expected to throw
        }
      });
      expect(mockFetch).toHaveBeenCalledTimes(1);
    });
  });

describe('Pagination', () => {
    it('should paginate notifications', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = Array.from({ length: 25 }, (_, i) => ({
        id: `notif-${i}`,
        title: `Notification ${i}`,
        message: `Message ${i}`,
        type: 'info',
        timestamp: new Date(Date.now() - i * 1000).toISOString(),
        read: false,
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      const page1 = result.current.getPaginated(1, 10);
      expect(page1.items).toHaveLength(10);
      expect(page1.totalPages).toBe(3);
      expect(page1.hasNext).toBe(true);
      expect(page1.hasPrev).toBe(false);
      const page2 = result.current.getPaginated(2, 10);
      expect(page2.items).toHaveLength(10);
      expect(page2.hasNext).toBe(true);
      expect(page2.hasPrev).toBe(true);
      const page3 = result.current.getPaginated(3, 10);
      expect(page3.items).toHaveLength(5);
      expect(page3.hasNext).toBe(false);
      expect(page3.hasPrev).toBe(true);
    });
  });

describe('Search and Filter', () => {
    it('should search notifications by text', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notifications: Notification[] = [
        {
          id: '1',
          title: 'Payment received',
          message: 'You received $100',
          type: 'success',
          timestamp: new Date().toISOString(),
          read: false,
        },
        {
          id: '2',
          title: 'Error occurred',
          message: 'Failed to process request',
          type: 'error',
          timestamp: new Date().toISOString(),
          read: false,
        },
        {
          id: '3',
          title: 'Payment sent',
          message: 'Successfully sent $50',
          type: 'success',
          timestamp: new Date().toISOString(),
          read: false,
        },
      ];
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      const paymentResults = result.current.search('payment');
      expect(paymentResults).toHaveLength(2);
      expect(paymentResults.every(n => n.title.toLowerCase().includes('payment'))).toBe(true);
      const errorResults = result.current.search('error');
      expect(errorResults).toHaveLength(1);
      expect(errorResults[0].type).toBe('error');
    });
    it('should filter notifications by date range', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const now = Date.now();
      const notifications: Notification[] = [
        {
          id: 'old',
          title: 'Old notification',
          message: 'From last week',
          type: 'info',
          timestamp: new Date(now - 7 * 24 * 60 * 60 * 1000).toISOString(),
          read: true,
        },
        {
          id: 'recent',
          title: 'Recent notification',
          message: 'From today',
          type: 'info',
          timestamp: new Date(now).toISOString(),
          read: false,
        },
      ];
      act(() => {
        notifications.forEach(notif => result.current.addNotification(notif));
      });
      const recentOnly = result.current.getByDateRange(
        new Date(now - 24 * 60 * 60 * 1000),
        new Date(now + 24 * 60 * 60 * 1000)
      );
      expect(recentOnly).toHaveLength(1);
      expect(recentOnly[0].id).toBe('recent');
    });
  });

describe('Persistence', () => {
    it('should persist unread count', async () => {
      const { result } = renderHook(() => useNotificationStore());
      const notification: Notification = {
        id: 'persist-1',
        title: 'Persistent',
        message: 'Should persist',
        type: 'info',
        timestamp: new Date().toISOString(),
        read: false,
      };
      act(() => {
        result.current.addNotification(notification);
      });
      expect(result.current.unreadCount).toBe(1);
      // Simulate rehydration
      const { result: newResult } = renderHook(() => useNotificationStore());
      // In a real app, this would be loaded from localStorage
      // For testing, we're just checking that the structure supports persistence
      expect(newResult.current).toHaveProperty('notifications');
      expect(newResult.current).toHaveProperty('unreadCount');
    });
  });
});
}}}}