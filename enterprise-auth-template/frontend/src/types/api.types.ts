// API response types that match backend FastAPI responses

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  metadata?: ApiMetadata;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface ApiMetadata {
  timestamp: string;
  requestId: string;
  version: string;
}

// Pagination types
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  per_page: number;
  pages: number;
  has_next: boolean;
  has_prev: boolean;
}

export interface PaginationParams {
  page?: number;
  per_page?: number;
  skip?: number;
  limit?: number;
}

// Query parameters
export interface QueryParams extends Record<string, unknown> {
  search?: string;
  sort?: string;
  order?: 'asc' | 'desc';
  filters?: Record<string, unknown>;
}

// HTTP method types
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';

// API client configuration
export interface ApiConfig {
  baseURL: string;
  timeout?: number;
  headers?: Record<string, string>;
}

// Request options
export interface RequestOptions {
  headers?: Record<string, string>;
  params?: Record<string, unknown>;
  timeout?: number;
  signal?: AbortSignal;
}

// Upload types
export interface FileUpload {
  file: File;
  onProgress?: (progress: number) => void;
  metadata?: Record<string, unknown>;
}

export interface UploadResponse {
  url: string;
  filename: string;
  size: number;
  content_type: string;
  metadata?: Record<string, unknown>;
}

// Health check types
export interface HealthCheck {
  status: 'healthy' | 'unhealthy' | 'degraded';
  timestamp: string;
  version: string;
  uptime: number;
  database: {
    status: 'connected' | 'disconnected';
    response_time?: number;
  };
  redis?: {
    status: 'connected' | 'disconnected';
    response_time?: number;
  };
}

// ================================
// Notification Types
// ================================

/**
 * Notification types matching backend enum
 */
export enum NotificationType {
  EMAIL = 'email',
  SMS = 'sms',
  PUSH = 'push',
  IN_APP = 'in_app',
  WEBHOOK = 'webhook',
}

/**
 * Notification priority levels
 */
export enum NotificationPriority {
  LOW = 'low',
  NORMAL = 'normal',
  HIGH = 'high',
  URGENT = 'urgent',
}

/**
 * Notification delivery status
 */
export enum NotificationStatus {
  PENDING = 'pending',
  SENT = 'sent',
  DELIVERED = 'delivered',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
  READ = 'read',
}

/**
 * Notification categories
 */
export enum NotificationCategory {
  SECURITY = 'security',
  ACCOUNT = 'account',
  BILLING = 'billing',
  SYSTEM = 'system',
  MARKETING = 'marketing',
  GENERAL = 'general',
}

/**
 * Notification data structure from API
 */
export interface NotificationResponse {
  /** Notification ID */
  id: string;
  /** Notification title */
  title: string;
  /** Notification message */
  message: string;
  /** Notification type */
  type: string;
  /** Notification priority */
  priority: string;
  /** Notification category */
  category: string;
  /** Notification status */
  status: string;
  /** Additional structured data */
  data: Record<string, unknown>;
  /** Timestamp when read (null if unread) */
  read_at: string | null;
  /** Timestamp when sent */
  sent_at: string | null;
  /** Timestamp when delivered */
  delivered_at: string | null;
  /** Creation timestamp */
  created_at: string;
  /** Expiration timestamp */
  expires_at: string | null;
}

/**
 * Notification list response from API
 */
export interface NotificationListResponse {
  /** List of notifications */
  notifications: NotificationResponse[];
  /** Total number of notifications */
  total: number;
  /** Number of unread notifications */
  unread_count: number;
  /** Whether more notifications exist */
  has_more: boolean;
}

/**
 * User notification preferences
 */
export interface NotificationPreferencesResponse {
  /** Email notifications enabled */
  email_notifications: boolean;
  /** Push notifications enabled */
  push_notifications: boolean;
  /** SMS notifications enabled */
  sms_notifications: boolean;
  /** In-app notifications enabled */
  in_app_notifications: boolean;
  /** Marketing emails enabled */
  marketing_emails: boolean;
  /** Security alerts enabled */
  security_alerts: boolean;
  /** Frequency settings by category */
  frequency_settings: Record<string, string>;
}

/**
 * Notification creation request
 */
export interface NotificationCreateRequest {
  /** Target user ID (admin only) */
  user_id?: string;
  /** Notification title */
  title: string;
  /** Notification message */
  message: string;
  /** Notification delivery type */
  notification_type: NotificationType;
  /** Notification priority */
  priority?: NotificationPriority;
  /** Notification category */
  category?: NotificationCategory;
  /** Additional structured data */
  data?: Record<string, unknown>;
  /** Template ID for styled notifications */
  template_id?: string;
  /** Schedule delivery time */
  scheduled_at?: string;
  /** Expiration time */
  expires_at?: string;
}

/**
 * Query parameters for notification listing
 */
export interface NotificationQueryParams extends QueryParams {
  /** Number of notifications to return */
  limit?: number;
  /** Number of notifications to skip */
  offset?: number;
  /** Filter by status */
  status_filter?: NotificationStatus;
  /** Filter by category */
  category_filter?: NotificationCategory;
  /** Show only unread notifications */
  unread_only?: boolean;
}

/**
 * Generic message response
 */
export interface MessageResponse {
  /** Response message */
  message: string;
}
