/**
 * Enhanced Authentication Error Handler
 *
 * Provides comprehensive error handling for authentication operations
 * with user-friendly messages and proper error categorization.
 */

import { ApiResponse } from '@/types';

export interface AuthErrorDetails {
  code: string;
  message: string;
  userMessage: string;
  category: 'validation' | 'security' | 'network' | 'server' | 'unknown';
  retryable: boolean;
  actionRequired?: string;
  field?: string;
}

export interface EmailVerificationError extends AuthErrorDetails {
  resendAvailable: boolean;
  resendCooldown?: number;
}

/**
 * Map API error codes to user-friendly messages and action guidance
 */
const ERROR_MAPPINGS: Record<string, Partial<AuthErrorDetails>> = {
  // Authentication Errors
  'INVALID_CREDENTIALS': {
    userMessage: 'Invalid email or password. Please check your credentials and try again.',
    category: 'validation',
    retryable: true,
  },
  'EMAIL_NOT_VERIFIED': {
    userMessage: 'Please verify your email address before logging in.',
    category: 'security',
    retryable: false,
    actionRequired: 'verify_email',
  },
  'ACCOUNT_LOCKED': {
    userMessage: 'Your account has been temporarily locked due to multiple failed login attempts.',
    category: 'security',
    retryable: false,
    actionRequired: 'wait_or_contact_support',
  },
  'ACCOUNT_INACTIVE': {
    userMessage: 'Your account is not active. Please contact support for assistance.',
    category: 'security',
    retryable: false,
    actionRequired: 'contact_support',
  },

  // Registration Errors
  'EMAIL_ALREADY_EXISTS': {
    userMessage: 'An account with this email address already exists.',
    category: 'validation',
    retryable: false,
    field: 'email',
    actionRequired: 'login_or_reset',
  },
  'WEAK_PASSWORD': {
    userMessage: 'Password does not meet security requirements.',
    category: 'validation',
    retryable: true,
    field: 'password',
  },
  'INVALID_EMAIL': {
    userMessage: 'Please enter a valid email address.',
    category: 'validation',
    retryable: true,
    field: 'email',
  },

  // Token Errors
  'TOKEN_EXPIRED': {
    userMessage: 'Your session has expired. Please log in again.',
    category: 'security',
    retryable: false,
    actionRequired: 'login_required',
  },
  'INVALID_TOKEN': {
    userMessage: 'Invalid authentication token. Please log in again.',
    category: 'security',
    retryable: false,
    actionRequired: 'login_required',
  },
  'REFRESH_TOKEN_EXPIRED': {
    userMessage: 'Your session has expired. Please log in again.',
    category: 'security',
    retryable: false,
    actionRequired: 'login_required',
  },

  // Email Verification Errors
  'VERIFICATION_TOKEN_EXPIRED': {
    userMessage: 'Verification link has expired. Please request a new one.',
    category: 'validation',
    retryable: false,
    actionRequired: 'resend_verification',
  },
  'VERIFICATION_TOKEN_INVALID': {
    userMessage: 'Invalid verification link. Please request a new one.',
    category: 'validation',
    retryable: false,
    actionRequired: 'resend_verification',
  },
  'ALREADY_VERIFIED': {
    userMessage: 'Your email address is already verified.',
    category: 'validation',
    retryable: false,
  },

  // Rate Limiting
  'RATE_LIMIT_EXCEEDED': {
    userMessage: 'Too many requests. Please wait a moment and try again.',
    category: 'validation',
    retryable: true,
    actionRequired: 'wait_and_retry',
  },
  'TOO_MANY_ATTEMPTS': {
    userMessage: 'Too many failed attempts. Please wait before trying again.',
    category: 'security',
    retryable: true,
    actionRequired: 'wait_and_retry',
  },

  // Server Errors
  'INTERNAL_ERROR': {
    userMessage: 'An unexpected error occurred. Please try again later.',
    category: 'server',
    retryable: true,
    actionRequired: 'retry_or_contact_support',
  },
  'SERVICE_UNAVAILABLE': {
    userMessage: 'Service is temporarily unavailable. Please try again later.',
    category: 'server',
    retryable: true,
    actionRequired: 'retry_later',
  },

  // Network Errors
  'NETWORK_ERROR': {
    userMessage: 'Network connection error. Please check your internet connection.',
    category: 'network',
    retryable: true,
    actionRequired: 'check_connection',
  },
  'TIMEOUT': {
    userMessage: 'Request timed out. Please try again.',
    category: 'network',
    retryable: true,
    actionRequired: 'retry',
  },
};

/**
 * Enhanced auth error handler
 */
export class AuthErrorHandler {
  /**
   * Process authentication errors and return user-friendly error details
   */
  static handleAuthError(error: unknown): AuthErrorDetails {
    // Handle API response errors
    if (this.isApiResponse(error)) {
      return this.handleApiError(error);
    }

    // Handle JavaScript errors
    if (error instanceof Error) {
      return this.handleJavaScriptError(error);
    }

    // Handle network errors
    if (this.isNetworkError(error)) {
      return this.handleNetworkError(error);
    }

    // Default unknown error
    return this.createDefaultError(error);
  }

  /**
   * Handle email verification specific errors
   */
  static handleEmailVerificationError(error: unknown): EmailVerificationError {
    const baseError = this.handleAuthError(error);

    return {
      ...baseError,
      resendAvailable: this.isResendAvailable(baseError.code),
      resendCooldown: this.getResendCooldown(baseError.code),
    };
  }

  /**
   * Check if error is from API response
   */
  private static isApiResponse(error: unknown): error is ApiResponse<any> {
    return (
      typeof error === 'object' &&
      error !== null &&
      'success' in error &&
      typeof (error as any).success === 'boolean'
    );
  }

  /**
   * Handle API response errors
   */
  private static handleApiError(response: ApiResponse<any>): AuthErrorDetails {
    const errorCode = response.error?.code || 'UNKNOWN_API_ERROR';
    const errorMessage = response.error?.message || 'An unknown error occurred';

    const mapping = ERROR_MAPPINGS[errorCode] || {};

    return {
      code: errorCode,
      message: errorMessage,
      userMessage: mapping.userMessage || errorMessage,
      category: mapping.category || 'unknown',
      retryable: mapping.retryable ?? false,
      actionRequired: mapping.actionRequired,
      field: mapping.field,
    };
  }

  /**
   * Handle JavaScript/runtime errors
   */
  private static handleJavaScriptError(error: Error): AuthErrorDetails {
    // Check for specific error types
    if (error.name === 'TypeError' && error.message.includes('fetch')) {
      return {
        code: 'NETWORK_ERROR',
        message: error.message,
        userMessage: 'Network connection error. Please check your internet connection.',
        category: 'network',
        retryable: true,
        actionRequired: 'check_connection',
      };
    }

    if (error.name === 'AbortError') {
      return {
        code: 'REQUEST_CANCELLED',
        message: 'Request was cancelled',
        userMessage: 'Request was cancelled. Please try again.',
        category: 'network',
        retryable: true,
      };
    }

    return {
      code: 'CLIENT_ERROR',
      message: error.message,
      userMessage: 'An unexpected error occurred. Please try again.',
      category: 'unknown',
      retryable: true,
    };
  }

  /**
   * Check if error is network-related
   */
  private static isNetworkError(error: unknown): boolean {
    if (typeof error === 'object' && error !== null) {
      const err = error as any;
      return (
        err.name === 'NetworkError' ||
        err.code === 'NETWORK_ERROR' ||
        (typeof err.message === 'string' &&
         (err.message.includes('network') ||
          err.message.includes('connection') ||
          err.message.includes('timeout')))
      );
    }
    return false;
  }

  /**
   * Handle network errors
   */
  private static handleNetworkError(error: unknown): AuthErrorDetails {
    return {
      code: 'NETWORK_ERROR',
      message: 'Network connection failed',
      userMessage: 'Unable to connect to the server. Please check your internet connection.',
      category: 'network',
      retryable: true,
      actionRequired: 'check_connection',
    };
  }

  /**
   * Create default error for unknown error types
   */
  private static createDefaultError(error: unknown): AuthErrorDetails {
    const errorMessage = typeof error === 'string' ? error : 'An unknown error occurred';

    return {
      code: 'UNKNOWN_ERROR',
      message: errorMessage,
      userMessage: 'An unexpected error occurred. Please try again or contact support.',
      category: 'unknown',
      retryable: true,
      actionRequired: 'retry_or_contact_support',
    };
  }

  /**
   * Check if resend verification is available for this error
   */
  private static isResendAvailable(errorCode: string): boolean {
    const resendAvailableErrors = [
      'EMAIL_NOT_VERIFIED',
      'VERIFICATION_TOKEN_EXPIRED',
      'VERIFICATION_TOKEN_INVALID',
    ];
    return resendAvailableErrors.includes(errorCode);
  }

  /**
   * Get resend cooldown period in seconds
   */
  private static getResendCooldown(errorCode: string): number | undefined {
    const cooldowns: Record<string, number> = {
      'RATE_LIMIT_EXCEEDED': 60,
      'TOO_MANY_ATTEMPTS': 300,
    };
    return cooldowns[errorCode];
  }

  /**
   * Get action-specific guidance
   */
  static getActionGuidance(actionRequired?: string): string {
    const actions: Record<string, string> = {
      'verify_email': 'Please check your email and click the verification link.',
      'login_required': 'Please log in again to continue.',
      'resend_verification': 'Request a new verification email.',
      'wait_and_retry': 'Please wait a moment before trying again.',
      'check_connection': 'Check your internet connection and try again.',
      'contact_support': 'Please contact our support team for assistance.',
      'retry': 'Please try again.',
      'retry_later': 'Please try again in a few minutes.',
      'login_or_reset': 'Try logging in, or reset your password if you forgot it.',
      'wait_or_contact_support': 'Wait for the lockout to expire or contact support.',
      'retry_or_contact_support': 'Try again, or contact support if the problem persists.',
    };

    return actionRequired ? actions[actionRequired] || '' : '';
  }

  /**
   * Format error for display to users
   */
  static formatErrorForUser(error: AuthErrorDetails): string {
    let message = error.userMessage;

    const guidance = this.getActionGuidance(error.actionRequired);
    if (guidance) {
      message += ` ${guidance}`;
    }

    return message;
  }

  /**
   * Check if error should trigger automatic retry
   */
  static shouldAutoRetry(error: AuthErrorDetails): boolean {
    return (
      error.retryable &&
      error.category === 'network' &&
      !error.actionRequired
    );
  }

  /**
   * Get retry delay for automatic retries (in milliseconds)
   */
  static getRetryDelay(attempt: number): number {
    // Exponential backoff: 1s, 2s, 4s, 8s, max 30s
    return Math.min(1000 * Math.pow(2, attempt), 30000);
  }
}

export default AuthErrorHandler;