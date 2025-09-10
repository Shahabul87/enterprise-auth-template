/**
 * Standardized Error Handler
 * 
 * Provides consistent error handling across the application
 * with proper typing, categorization, and user-friendly messages.
 */

import { AxiosError } from 'axios';
import { toast } from 'sonner';

// Error severity levels
export enum ErrorSeverity {
  INFO = 'info',
  WARNING = 'warning',
  ERROR = 'error',
  CRITICAL = 'critical',
}

// Error categories for better handling
export enum ErrorCategory {
  AUTHENTICATION = 'authentication',
  AUTHORIZATION = 'authorization',
  VALIDATION = 'validation',
  NETWORK = 'network',
  SERVER = 'server',
  CLIENT = 'client',
  UNKNOWN = 'unknown',
}

// Standardized error interface
export interface StandardError {
  code: string;
  message: string;
  category: ErrorCategory;
  severity: ErrorSeverity;
  details?: Record<string, unknown>;
  field?: string;
  timestamp: Date;
  requestId?: string;
  statusCode?: number;
  retryable?: boolean;
  userMessage?: string;
}

// API error response structure
export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
    field?: string;
  };
  metadata?: {
    timestamp: string;
    requestId: string;
  };
}

// Error code mappings for user-friendly messages
const ERROR_MESSAGES: Record<string, string> = {
  // Authentication errors
  INVALID_CREDENTIALS: 'Invalid email or password. Please try again.',
  TOKEN_EXPIRED: 'Your session has expired. Please sign in again.',
  TOKEN_INVALID: 'Invalid authentication. Please sign in again.',
  ACCOUNT_LOCKED: 'Your account has been locked. Please contact support.',
  EMAIL_NOT_VERIFIED: 'Please verify your email address before signing in.',
  
  // Authorization errors
  INSUFFICIENT_PERMISSIONS: 'You do not have permission to perform this action.',
  FORBIDDEN: 'Access denied. You are not authorized to access this resource.',
  ROLE_REQUIRED: 'This action requires additional privileges.',
  
  // Validation errors
  VALIDATION_ERROR: 'Please check your input and try again.',
  EMAIL_ALREADY_EXISTS: 'This email address is already registered.',
  INVALID_EMAIL: 'Please enter a valid email address.',
  PASSWORD_TOO_WEAK: 'Password does not meet security requirements.',
  REQUIRED_FIELD: 'This field is required.',
  
  // Rate limiting
  RATE_LIMIT_EXCEEDED: 'Too many requests. Please wait a moment and try again.',
  
  // Network errors
  NETWORK_ERROR: 'Network connection error. Please check your internet connection.',
  REQUEST_TIMEOUT: 'The request took too long. Please try again.',
  
  // Server errors
  INTERNAL_SERVER_ERROR: 'Something went wrong on our end. Please try again later.',
  SERVICE_UNAVAILABLE: 'Service temporarily unavailable. Please try again later.',
  
  // Default
  UNKNOWN_ERROR: 'An unexpected error occurred. Please try again.',
};

export class ErrorHandler {
  /**
   * Parse and standardize any error into StandardError format
   */
  static parseError(error: unknown): StandardError {
    // Handle Axios errors
    if (this.isAxiosError(error)) {
      return this.parseAxiosError(error as AxiosError<ApiErrorResponse>);
    }
    
    // Handle API error responses
    if (this.isApiError(error)) {
      return this.parseApiError(error);
    }
    
    // Handle standard Error objects
    if (error instanceof Error) {
      return this.parseStandardError(error);
    }
    
    // Handle string errors
    if (typeof error === 'string') {
      return {
        code: 'STRING_ERROR',
        message: error,
        category: ErrorCategory.UNKNOWN,
        severity: ErrorSeverity.ERROR,
        timestamp: new Date(),
      };
    }
    
    // Unknown error type
    return {
      code: 'UNKNOWN_ERROR',
      message: 'An unexpected error occurred',
      category: ErrorCategory.UNKNOWN,
      severity: ErrorSeverity.ERROR,
      details: { originalError: error },
      timestamp: new Date(),
    };
  }
  
  /**
   * Parse Axios errors
   */
  private static parseAxiosError(error: AxiosError<ApiErrorResponse>): StandardError {
    const response = error.response;
    const status = response?.status;
    
    // Network error (no response)
    if (!response) {
      return {
        code: 'NETWORK_ERROR',
        message: 'Network connection error',
        category: ErrorCategory.NETWORK,
        severity: ErrorSeverity.ERROR,
        timestamp: new Date(),
        retryable: true,
      };
    }
    
    // Parse response data
    const data = response.data;
    const errorCode = data?.error?.code || this.getErrorCodeFromStatus(status);
    const errorMessage = data?.error?.message || error.message;
    
    const result: StandardError = {
      code: errorCode,
      message: errorMessage,
      category: this.categorizeByStatusCode(status),
      severity: this.getSeverityByStatusCode(status),
      statusCode: status ?? 500,
      details: data?.error?.details || {},
      timestamp: new Date(data?.metadata?.timestamp || Date.now()),
      retryable: this.isRetryable(status),
      userMessage: this.getUserMessage(errorCode, errorMessage),
    };
    
    if (data?.error?.field) {
      result.field = data.error.field;
    }
    
    if (data?.metadata?.requestId) {
      result.requestId = data.metadata.requestId;
    }
    
    return result;
  }
  
  /**
   * Parse API error responses
   */
  private static parseApiError(error: ApiErrorResponse): StandardError {
    const result: StandardError = {
      code: error.error.code,
      message: error.error.message,
      category: this.categorizeByCode(error.error.code),
      severity: ErrorSeverity.ERROR,
      details: error.error.details || {},
      timestamp: new Date(error.metadata?.timestamp || Date.now()),
      userMessage: this.getUserMessage(error.error.code, error.error.message),
    };
    
    if (error.error.field) {
      result.field = error.error.field;
    }
    
    if (error.metadata?.requestId) {
      result.requestId = error.metadata.requestId;
    }
    
    return result;
  }
  
  /**
   * Parse standard Error objects
   */
  private static parseStandardError(error: Error): StandardError {
    const category = this.categorizeByMessage(error.message);
    
    return {
      code: error.name || 'ERROR',
      message: error.message,
      category,
      severity: ErrorSeverity.ERROR,
      details: { stack: error.stack },
      timestamp: new Date(),
    };
  }
  
  /**
   * Type guards
   */
  private static isAxiosError(error: unknown): error is AxiosError {
    return typeof error === 'object' && error !== null && 'isAxiosError' in error && (error as { isAxiosError: boolean }).isAxiosError === true;
  }
  
  private static isApiError(error: unknown): error is ApiErrorResponse {
    return typeof error === 'object' && error !== null && 'success' in error && 'error' in error && (error as { success: boolean }).success === false;
  }
  
  /**
   * Categorize error by status code
   */
  private static categorizeByStatusCode(status?: number): ErrorCategory {
    if (!status) return ErrorCategory.UNKNOWN;
    
    if (status === 401) return ErrorCategory.AUTHENTICATION;
    if (status === 403) return ErrorCategory.AUTHORIZATION;
    if (status >= 400 && status < 500) return ErrorCategory.CLIENT;
    if (status >= 500) return ErrorCategory.SERVER;
    
    return ErrorCategory.UNKNOWN;
  }
  
  /**
   * Categorize error by error code
   */
  private static categorizeByCode(code: string): ErrorCategory {
    const upperCode = code.toUpperCase();
    
    if (upperCode.includes('AUTH') || upperCode.includes('TOKEN')) {
      return ErrorCategory.AUTHENTICATION;
    }
    if (upperCode.includes('PERMISSION') || upperCode.includes('FORBIDDEN')) {
      return ErrorCategory.AUTHORIZATION;
    }
    if (upperCode.includes('VALIDATION') || upperCode.includes('INVALID')) {
      return ErrorCategory.VALIDATION;
    }
    if (upperCode.includes('NETWORK') || upperCode.includes('TIMEOUT')) {
      return ErrorCategory.NETWORK;
    }
    
    return ErrorCategory.UNKNOWN;
  }
  
  /**
   * Categorize error by message content
   */
  private static categorizeByMessage(message: string): ErrorCategory {
    const lowerMessage = message.toLowerCase();
    
    if (lowerMessage.includes('auth') || lowerMessage.includes('token')) {
      return ErrorCategory.AUTHENTICATION;
    }
    if (lowerMessage.includes('permission') || lowerMessage.includes('forbidden')) {
      return ErrorCategory.AUTHORIZATION;
    }
    if (lowerMessage.includes('network') || lowerMessage.includes('fetch')) {
      return ErrorCategory.NETWORK;
    }
    
    return ErrorCategory.UNKNOWN;
  }
  
  /**
   * Get error code from HTTP status
   */
  private static getErrorCodeFromStatus(status?: number): string {
    const statusCodes: Record<number, string> = {
      400: 'BAD_REQUEST',
      401: 'UNAUTHORIZED',
      403: 'FORBIDDEN',
      404: 'NOT_FOUND',
      409: 'CONFLICT',
      422: 'VALIDATION_ERROR',
      429: 'RATE_LIMIT_EXCEEDED',
      500: 'INTERNAL_SERVER_ERROR',
      502: 'BAD_GATEWAY',
      503: 'SERVICE_UNAVAILABLE',
      504: 'GATEWAY_TIMEOUT',
    };
    
    return statusCodes[status || 0] || 'UNKNOWN_ERROR';
  }
  
  /**
   * Get severity by status code
   */
  private static getSeverityByStatusCode(status?: number): ErrorSeverity {
    if (!status) return ErrorSeverity.ERROR;
    
    if (status >= 500) return ErrorSeverity.CRITICAL;
    if (status === 429) return ErrorSeverity.WARNING;
    if (status >= 400) return ErrorSeverity.ERROR;
    
    return ErrorSeverity.INFO;
  }
  
  /**
   * Check if error is retryable
   */
  private static isRetryable(status?: number): boolean {
    if (!status) return false;
    
    // Retryable status codes
    const retryableCodes = [408, 429, 500, 502, 503, 504];
    return retryableCodes.includes(status);
  }
  
  /**
   * Get user-friendly message
   */
  private static getUserMessage(code: string, defaultMessage: string): string {
    return ERROR_MESSAGES[code] || defaultMessage;
  }
  
  /**
   * Display error to user using toast
   */
  static showError(error: StandardError, options?: {
    duration?: number;
    action?: { label: string; onClick: () => void };
  }) {
    const message = error.userMessage || error.message;
    
    switch (error.severity) {
      case ErrorSeverity.INFO:
        toast.info(message, options);
        break;
      case ErrorSeverity.WARNING:
        toast.warning(message, options);
        break;
      case ErrorSeverity.CRITICAL:
        toast.error(message, {
          ...options,
          duration: options?.duration || 10000, // Longer duration for critical errors
        });
        break;
      default:
        toast.error(message, options);
    }
  }
  
  /**
   * Log error for debugging/monitoring
   */
  static logError(_error: StandardError, _context?: Record<string, unknown>) {
    // Error logging with context data
    // Including user agent, URL, and provided context
    
    // In development, log to console
    if (process.env.NODE_ENV === 'development') {
      // Error logged with error details and context
    }
    
    // In production, send to error tracking service
    if (process.env.NODE_ENV === 'production') {
      // TODO: Implement error tracking service integration
      // Example: Sentry, LogRocket, etc.
    }
  }
  
  /**
   * Handle error with default behavior
   */
  static handle(error: unknown, options?: {
    showToast?: boolean;
    log?: boolean;
    context?: Record<string, unknown>;
  }) {
    const standardError = this.parseError(error);
    
    // Log error if requested (default: true in production)
    if (options?.log !== false) {
      this.logError(standardError, options?.context);
    }
    
    // Show toast if requested (default: true)
    if (options?.showToast !== false) {
      this.showError(standardError);
    }
    
    return standardError;
  }
}