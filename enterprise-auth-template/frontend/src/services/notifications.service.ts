/**
 * Notifications Service - API integration for notification management
 * 
 * This service handles all notification-related API calls including:
 * - Fetching user notifications with filtering and pagination
 * - Marking notifications as read
 * - Deleting notifications
 * - Managing notification preferences
 */

import apiClient from '@/lib/api-client';
import {
  ApiResponse,
  NotificationListResponse,
  NotificationResponse,
  NotificationQueryParams,
  NotificationPreferencesResponse,
  MessageResponse,
} from '@/types/api.types';

/**
 * Notifications API service class
 */
class NotificationsService {
  private readonly baseEndpoint = '/api/v1/notifications';

  /**
   * Get user notifications with filtering and pagination
   */
  async getNotifications(params?: NotificationQueryParams): Promise<ApiResponse<NotificationListResponse>> {
    return apiClient.get<NotificationListResponse>(this.baseEndpoint, params);
  }

  /**
   * Get notifications by category
   */
  async getNotificationsByCategory(
    category: string,
    params?: Omit<NotificationQueryParams, 'category_filter'>
  ): Promise<ApiResponse<NotificationListResponse>> {
    return apiClient.get<NotificationListResponse>(this.baseEndpoint, {
      ...params,
      category_filter: category,
    });
  }

  /**
   * Get unread notifications only
   */
  async getUnreadNotifications(params?: Omit<NotificationQueryParams, 'unread_only'>): Promise<ApiResponse<NotificationListResponse>> {
    return apiClient.get<NotificationListResponse>(this.baseEndpoint, {
      ...params,
      unread_only: true,
    });
  }

  /**
   * Mark a specific notification as read
   */
  async markAsRead(notificationId: string): Promise<ApiResponse<MessageResponse>> {
    return apiClient.put<MessageResponse>(`${this.baseEndpoint}/${notificationId}/read`);
  }

  /**
   * Mark all notifications as read
   */
  async markAllAsRead(): Promise<ApiResponse<MessageResponse>> {
    return apiClient.put<MessageResponse>(`${this.baseEndpoint}/read-all`);
  }

  /**
   * Delete a specific notification
   */
  async deleteNotification(notificationId: string): Promise<ApiResponse<MessageResponse>> {
    return apiClient.delete<MessageResponse>(`${this.baseEndpoint}/${notificationId}`);
  }

  /**
   * Get user notification preferences
   */
  async getPreferences(): Promise<ApiResponse<NotificationPreferencesResponse>> {
    return apiClient.get<NotificationPreferencesResponse>(`${this.baseEndpoint}/preferences`);
  }

  /**
   * Update user notification preferences
   */
  async updatePreferences(preferences: NotificationPreferencesResponse): Promise<ApiResponse<MessageResponse>> {
    return apiClient.put<MessageResponse>(`${this.baseEndpoint}/preferences`, preferences);
  }

  /**
   * Helper method to transform frontend notification structure to match API
   */
  private transformNotificationToFrontend(notification: NotificationResponse): NotificationForFrontend {
    return {
      id: notification.id,
      title: notification.title,
      message: notification.message,
      type: this.mapTypeToFrontend(notification.type),
      category: this.mapCategoryToFrontend(notification.category),
      priority: notification.priority,
      status: notification.status,
      isRead: notification.read_at !== null,
      createdAt: notification.created_at,
      readAt: notification.read_at,
      deliveredAt: notification.delivered_at,
      expiresAt: notification.expires_at,
      data: notification.data,
      ...(notification.data?.['action_url'] ? { actionUrl: notification.data['action_url'] as string } : {}),
      ...(notification.data?.['action_text'] ? { actionText: notification.data['action_text'] as string } : {}),
    };
  }

  /**
   * Map backend notification type to frontend type
   */
  private mapTypeToFrontend(type: string): 'info' | 'success' | 'warning' | 'error' {
    switch (type) {
      case 'email':
      case 'in_app':
        return 'info';
      case 'sms':
      case 'push':
        return 'info';
      default:
        return 'info';
    }
  }

  /**
   * Map backend notification category to frontend category
   */
  private mapCategoryToFrontend(category: string): 'security' | 'system' | 'social' | 'account' {
    switch (category) {
      case 'security':
        return 'security';
      case 'system':
        return 'system';
      case 'billing':
      case 'account':
        return 'account';
      case 'marketing':
      case 'general':
        return 'social';
      default:
        return 'account';
    }
  }

  /**
   * Get notifications with frontend-compatible format
   */
  async getNotificationsForFrontend(params?: NotificationQueryParams): Promise<ApiResponse<NotificationListForFrontend>> {
    const response = await this.getNotifications(params);
    
    if (!response.success || !response.data) {
      return response as unknown as ApiResponse<NotificationListForFrontend>;
    }

    const transformedNotifications = response.data.notifications.map(notification =>
      this.transformNotificationToFrontend(notification)
    );

    return {
      success: true,
      data: {
        notifications: transformedNotifications,
        total: response.data.total,
        unread_count: response.data.unread_count,
        has_more: response.data.has_more,
      },
    };
  }
}

/**
 * Frontend-compatible notification structure
 */
export interface NotificationForFrontend {
  id: string;
  title: string;
  message: string;
  type: 'info' | 'success' | 'warning' | 'error';
  category: 'security' | 'system' | 'social' | 'account';
  priority: string;
  status: string;
  isRead: boolean;
  createdAt: string;
  readAt: string | null;
  deliveredAt: string | null;
  expiresAt: string | null;
  actionUrl?: string;
  actionText?: string;
  data: Record<string, unknown>;
}

/**
 * Frontend-compatible notification list
 */
export interface NotificationListForFrontend {
  notifications: NotificationForFrontend[];
  total: number;
  unread_count: number;
  has_more: boolean;
}

// Export service instance
export const notificationsService = new NotificationsService();
export default notificationsService;