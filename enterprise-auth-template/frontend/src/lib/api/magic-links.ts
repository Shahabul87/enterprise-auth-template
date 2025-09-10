/**
 * Magic Link API Client
 * 
 * API client functions for magic link authentication
 */

import apiClient from '@/lib/api-client';

export interface MagicLinkRequestResponse {
  success: boolean;
  message: string;
}

export interface MagicLinkVerifyResponse {
  success: boolean;
  access_token?: string;
  refresh_token?: string;
  token_type?: string;
  message?: string;
  user?: {
    id: string;
    email: string;
    name: string;
    is_active: boolean;
    email_verified: boolean;
    roles: string[];
  };
}

/**
 * Request a magic link for passwordless authentication
 * @param email - Email address to send magic link to
 * @returns Response indicating if the request was successful
 */
export async function requestMagicLink(email: string): Promise<MagicLinkRequestResponse> {
  try {
    const response = await apiClient.post<MagicLinkRequestResponse>(
      '/v1/magic-links/request',
      { email }
    );
    return response.data || {
      success: true,
      message: 'If an account exists with this email, a magic link has been sent.',
    };
  } catch {
    // Magic link request error occurred
    // Always return success to prevent email enumeration
    return {
      success: true,
      message: 'If an account exists with this email, a magic link has been sent.',
    };
  }
}

/**
 * Verify a magic link token
 * @param token - Magic link token from email
 * @returns Authentication response with tokens and user data
 */
export async function verifyMagicLink(token: string): Promise<MagicLinkVerifyResponse> {
  try {
    const response = await apiClient.post<MagicLinkVerifyResponse>(
      '/v1/magic-links/verify',
      { token }
    );
    return response.data ?? {
      success: false,
      message: 'Invalid response from server'
    };
  } catch (error: unknown) {
    
    
    // Handle specific error cases with type guards
    if (error && typeof error === 'object' && 'response' in error) {
      const axiosError = error as { response?: { status?: number; data?: { detail?: string } } };
      
      if (axiosError.response?.status === 401) {
        throw new Error('Invalid or expired magic link');
      }
      
      if (axiosError.response?.data?.detail) {
        throw new Error(axiosError.response.data.detail);
      }
    }
    
    throw new Error('Failed to verify magic link');
  }
}