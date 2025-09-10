/**
 * Comprehensive API types for the Enterprise Authentication Template
 * 
 * This file contains all API request/response types, error handling types,
 * and utility types for communicating with the FastAPI backend.
 * 
 * @fileoverview API TypeScript type definitions
 * @version 1.0.0
 */

// ================================
// Base API Response Types
// ================================

/**
 * Standard API response wrapper that matches FastAPI backend format
 * @template T - The type of the data payload
 */
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  metadata?: ApiMetadata;
}

/**
 * API error structure with detailed error information
 */
export interface ApiError {
  /** Error code (e.g., 'VALIDATION_ERROR', 'AUTHENTICATION_FAILED') */
  code: string;
  /** Human-readable error message */
  message: string;
  /** Additional error details and context */
  details?: Record<string, unknown>;
  /** Field-specific validation errors */
  field_errors?: Record<string, string[]>;
}

/**
 * API response metadata for request tracking and debugging
 */
export interface ApiMetadata {
  /** ISO timestamp when response was generated */
  timestamp: string;
  /** Unique request identifier for tracing */
  requestId: string;
  /** API version */
  version: string;
  /** Request processing time in milliseconds */
  processing_time_ms?: number;
}

// ================================
// HTTP and Request Types
// ================================

/**
 * HTTP methods supported by the API
 */
export type HttpMethod = 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE' | 'OPTIONS' | 'HEAD';

/**
 * HTTP status codes with semantic meaning
 */
export enum HttpStatusCode {
  // Success
  OK = 200,
  CREATED = 201,
  NO_CONTENT = 204,
  
  // Client errors
  BAD_REQUEST = 400,
  UNAUTHORIZED = 401,
  FORBIDDEN = 403,
  NOT_FOUND = 404,
  METHOD_NOT_ALLOWED = 405,
  CONFLICT = 409,
  UNPROCESSABLE_ENTITY = 422,
  TOO_MANY_REQUESTS = 429,
  
  // Server errors
  INTERNAL_SERVER_ERROR = 500,
  BAD_GATEWAY = 502,
  SERVICE_UNAVAILABLE = 503,
  GATEWAY_TIMEOUT = 504,
}

/**
 * Request configuration options
 */
export interface RequestOptions {
  /** Custom headers for the request */
  headers?: Record<string, string>;
  /** URL query parameters */
  params?: Record<string, string | number | boolean>;
  /** Request timeout in milliseconds */
  timeout?: number;
  /** AbortController signal for cancellation */
  signal?: AbortSignal;
  /** Whether to include credentials (cookies) */
  withCredentials?: boolean;
}

/**
 * API client configuration
 */
export interface ApiConfig {
  /** Base URL for all API requests */
  baseURL: string;
  /** Default timeout for requests */
  timeout?: number;
  /** Default headers to include with all requests */
  headers?: Record<string, string>;
  /** Whether to include credentials by default */
  withCredentials?: boolean;
  /** API key for authentication */
  apiKey?: string;
}

// ================================
// Pagination and Filtering Types
// ================================

/**
 * Paginated response wrapper for list endpoints
 * @template T - The type of items in the list
 */
export interface PaginatedResponse<T> {
  /** Array of items for current page */
  items: T[];
  /** Total number of items across all pages */
  total: number;
  /** Current page number (1-based) */
  page: number;
  /** Number of items per page */
  per_page: number;
  /** Total number of pages */
  pages: number;
  /** Whether there is a next page */
  has_next: boolean;
  /** Whether there is a previous page */
  has_prev: boolean;
  /** URL for next page (if exists) */
  next_url?: string;
  /** URL for previous page (if exists) */
  prev_url?: string;
}

/**
 * Pagination parameters for list requests
 */
export interface PaginationParams {
  /** Page number (1-based, default: 1) */
  page?: number;
  /** Items per page (default: 20, max: 100) */
  per_page?: number;
  /** Alternative: number of items to skip */
  skip?: number;
  /** Alternative: maximum number of items to return */
  limit?: number;
}

/**
 * Generic query parameters for filtering and sorting
 */
export interface QueryParams extends Record<string, unknown> {
  /** Search term for text-based filtering */
  search?: string;
  /** Field to sort by */
  sort_by?: string;
  /** Sort order */
  sort_order?: 'asc' | 'desc';
  /** Generic filters object */
  filters?: Record<string, string | number | boolean | string[]>;
  /** Date range filter start */
  date_from?: string;
  /** Date range filter end */
  date_to?: string;
}

/**
 * Sort configuration
 */
export interface SortConfig {
  /** Field name to sort by */
  field: string;
  /** Sort direction */
  direction: 'asc' | 'desc';
}

// ================================
// File Upload Types
// ================================

/**
 * File upload request structure
 */
export interface FileUploadRequest {
  /** File to upload */
  file: File;
  /** Upload progress callback */
  onProgress?: (progress: number) => void;
  /** Additional metadata */
  metadata?: Record<string, unknown>;
  /** Allowed file types */
  allowed_types?: string[];
  /** Maximum file size in bytes */
  max_size?: number;
}

/**
 * File upload response
 */
export interface FileUploadResponse {
  /** Public URL of uploaded file */
  url: string;
  /** Original filename */
  filename: string;
  /** File size in bytes */
  size: number;
  /** MIME type */
  content_type: string;
  /** Upload timestamp */
  uploaded_at: string;
  /** File hash/checksum */
  hash?: string;
  /** Additional metadata */
  metadata?: Record<string, unknown>;
}

/**
 * Bulk file upload request
 */
export interface BulkFileUploadRequest {
  /** Array of files to upload */
  files: FileUploadRequest[];
  /** Overall progress callback */
  onProgress?: (overall: number, individual: Record<string, number>) => void;
}

/**
 * Bulk file upload response
 */
export interface BulkFileUploadResponse {
  /** Successfully uploaded files */
  uploaded: FileUploadResponse[];
  /** Failed uploads with error details */
  failed: Array<{
    filename: string;
    error: string;
  }>;
  /** Overall statistics */
  stats: {
    total: number;
    successful: number;
    failed: number;
  };
}

// ================================
// Health Check Types
// ================================

/**
 * System health check response
 */
export interface HealthCheckResponse {
  /** Overall system status */
  status: 'healthy' | 'unhealthy' | 'degraded';
  /** Health check timestamp */
  timestamp: string;
  /** Application version */
  version: string;
  /** System uptime in seconds */
  uptime: number;
  /** Environment (development, staging, production) */
  environment: string;
  /** Individual service statuses */
  services: {
    /** Database connection status */
    database: ServiceHealth;
    /** Redis connection status */
    redis: ServiceHealth;
    /** Email service status */
    email?: ServiceHealth;
    /** External API dependencies */
    external_apis?: Record<string, ServiceHealth>;
  };
}

/**
 * Individual service health status
 */
export interface ServiceHealth {
  /** Service status */
  status: 'connected' | 'disconnected' | 'degraded';
  /** Response time in milliseconds */
  response_time_ms?: number;
  /** Last successful connection */
  last_success?: string;
  /** Error message if disconnected */
  error?: string;
}

// ================================
// Bulk Operations Types
// ================================

/**
 * Generic bulk operation request
 * @template T - Type of the operation data
 */
export interface BulkOperationRequest<T = unknown> {
  /** Array of item IDs to process */
  item_ids: string[];
  /** Operation to perform */
  operation: string;
  /** Additional operation data */
  data?: T;
  /** Whether to continue on individual failures */
  continue_on_error?: boolean;
}

/**
 * Bulk operation result
 */
export interface BulkOperationResult {
  /** Overall operation success */
  success: boolean;
  /** Number of items successfully processed */
  processed: number;
  /** Number of items that failed */
  failed: number;
  /** Total number of items attempted */
  total: number;
  /** Individual item results */
  results: BulkItemResult[];
  /** Overall error if operation failed completely */
  error?: string;
}

/**
 * Individual item result within bulk operation
 */
export interface BulkItemResult {
  /** Item ID that was processed */
  item_id: string;
  /** Whether this item was successful */
  success: boolean;
  /** Error message if failed */
  error?: string;
  /** Additional result data */
  data?: unknown;
}

// ================================
// Search and Filter Types
// ================================

/**
 * Full-text search request parameters
 */
export interface SearchRequest {
  /** Search query string */
  query: string;
  /** Fields to search in */
  fields?: string[];
  /** Search type (exact, fuzzy, partial) */
  search_type?: 'exact' | 'fuzzy' | 'partial';
  /** Fuzzy search threshold (0-1) */
  fuzzy_threshold?: number;
  /** Highlight search terms in results */
  highlight?: boolean;
  /** Additional filters to apply */
  filters?: Record<string, unknown>;
  /** Pagination */
  pagination?: PaginationParams;
  /** Sorting */
  sort?: SortConfig;
}

/**
 * Search result with highlighting
 * @template T - Type of the search result item
 */
export interface SearchResult<T> {
  /** The actual result item */
  item: T;
  /** Relevance score (0-1) */
  score: number;
  /** Highlighted fields with search terms marked */
  highlights?: Record<string, string>;
}

/**
 * Search response wrapper
 * @template T - Type of the search result items
 */
export interface SearchResponse<T> extends PaginatedResponse<SearchResult<T>> {
  /** Search query that was executed */
  query: string;
  /** Search execution time in milliseconds */
  search_time_ms: number;
  /** Search suggestions for typos/alternatives */
  suggestions?: string[];
}

// ================================
// WebSocket Types
// ================================

/**
 * WebSocket message structure
 * @template T - Type of the message payload
 */
export interface WebSocketMessage<T = unknown> {
  /** Message type identifier */
  type: string;
  /** Message payload */
  payload: T;
  /** Message ID for tracking */
  id?: string;
  /** Timestamp when message was sent */
  timestamp: string;
  /** Sender information */
  sender?: string;
}

/**
 * WebSocket connection options
 */
export interface WebSocketOptions {
  /** Reconnection settings */
  reconnect?: {
    /** Whether to auto-reconnect */
    enabled: boolean;
    /** Maximum reconnection attempts */
    maxAttempts: number;
    /** Delay between attempts in milliseconds */
    delay: number;
    /** Backoff multiplier */
    backoffMultiplier: number;
  };
  /** Heartbeat/ping settings */
  heartbeat?: {
    /** Heartbeat interval in milliseconds */
    interval: number;
    /** Timeout for heartbeat response */
    timeout: number;
  };
}

// ================================
// Rate Limiting Types
// ================================

/**
 * Rate limit information from API headers
 */
export interface RateLimitInfo {
  /** Maximum requests allowed in time window */
  limit: number;
  /** Remaining requests in current window */
  remaining: number;
  /** Time window duration in seconds */
  window_seconds: number;
  /** Timestamp when window resets */
  reset_time: string;
  /** Whether rate limit is currently exceeded */
  exceeded: boolean;
}

// ================================
// Export and Import Types
// ================================

/**
 * Data export request
 */
export interface ExportRequest {
  /** Format for export */
  format: 'json' | 'csv' | 'xlsx' | 'pdf';
  /** Fields to include in export */
  fields?: string[];
  /** Filters to apply before export */
  filters?: Record<string, unknown>;
  /** Whether to include metadata */
  include_metadata?: boolean;
  /** Compression type */
  compression?: 'none' | 'zip' | 'gzip';
}

/**
 * Data export response
 */
export interface ExportResponse {
  /** Download URL for exported data */
  download_url: string;
  /** Export filename */
  filename: string;
  /** File size in bytes */
  size: number;
  /** Export format */
  format: string;
  /** Number of records exported */
  record_count: number;
  /** Export timestamp */
  created_at: string;
  /** Expiration time for download URL */
  expires_at: string;
}

/**
 * Data import request
 */
export interface ImportRequest {
  /** File to import */
  file: File;
  /** Import format */
  format: 'json' | 'csv' | 'xlsx';
  /** Field mapping configuration */
  field_mapping?: Record<string, string>;
  /** Whether to validate before importing */
  validate_only?: boolean;
  /** Import options */
  options?: {
    /** Skip header row for CSV/Excel */
    skip_header?: boolean;
    /** Update existing records if found */
    update_existing?: boolean;
    /** Create new records if not found */
    create_new?: boolean;
  };
}

/**
 * Data import response
 */
export interface ImportResponse {
  /** Whether import was successful */
  success: boolean;
  /** Import job ID for tracking */
  job_id: string;
  /** Number of records processed */
  records_processed: number;
  /** Number of records successfully imported */
  records_imported: number;
  /** Number of records that failed */
  records_failed: number;
  /** Validation errors */
  errors: Array<{
    row: number;
    field: string;
    error: string;
  }>;
  /** Import statistics */
  stats: {
    created: number;
    updated: number;
    skipped: number;
  };
}

// ================================
// Generic Utility Types
// ================================

/**
 * Generic ID type (string UUID)
 */
export type ID = string;

/**
 * ISO timestamp string
 */
export type Timestamp = string;

/**
 * Generic key-value pairs
 */
export type KeyValuePair = Record<string, unknown>;

/**
 * Optional fields utility type
 * @template T - Original type
 * @template K - Keys to make optional
 */
export type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

/**
 * Required fields utility type
 * @template T - Original type
 * @template K - Keys to make required
 */
export type RequiredBy<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

/**
 * Deep partial type
 */
export type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object ? DeepPartial<T[P]> : T[P];
};

/**
 * API endpoint paths as literal types
 */
export type ApiEndpoint = 
  | '/api/auth/login'
  | '/api/auth/register'
  | '/api/auth/refresh'
  | '/api/auth/logout'
  | '/api/users'
  | '/api/users/{id}'
  | '/api/admin/users'
  | '/api/admin/roles'
  | '/api/admin/permissions'
  | '/api/health'
  | '/api/metrics'
  | string; // Allow custom endpoints

/**
 * Content types for API requests
 */
export type ContentType =
  | 'application/json'
  | 'application/x-www-form-urlencoded'
  | 'multipart/form-data'
  | 'text/plain'
  | 'text/html'
  | 'application/octet-stream';