/**
 * WebAuthn/Passkey API Client
 *
 * API client functions for WebAuthn/Passkey authentication
 */

import apiClient from '@/lib/api-client';
import {
  startAuthentication,
  startRegistration,
  browserSupportsWebAuthn
} from '@simplewebauthn/browser';

export interface WebAuthnRegistrationOptions {
  challenge: string;
  rp: {
    name: string;
    id: string;
  };
  user: {
    id: string;
    name: string;
    displayName: string;
  };
  pubKeyCredParams: Array<{
    alg: number;
    type: string;
  }>;
  timeout?: number;
  attestation?: string;
  authenticatorSelection?: {
    authenticatorAttachment?: string;
    requireResidentKey?: boolean;
    residentKey?: string;
    userVerification?: string;
  };
}

export interface WebAuthnAuthenticationOptions {
  challenge: string;
  timeout?: number;
  rpId: string;
  userVerification?: string;
  allowCredentials?: Array<{
    id: string;
    type: string;
    transports?: string[];
  }>;
}

export interface WebAuthnCredential {
  id: string;
  device_name: string;
  created_at: string;
  last_used: string | null;
  transports: string[];
  aaguid: string;
  credential_id_preview: string;
}

/**
 * Check if the browser supports WebAuthn
 */
export function isWebAuthnSupported(): boolean {
  return browserSupportsWebAuthn();
}

/**
 * Register a new passkey for the current user
 * @param deviceName - Optional name for the device
 * @returns Registration result
 */
export async function registerPasskey(deviceName?: string) {
  try {
    // Check browser support
    if (!isWebAuthnSupported()) {
      throw new Error('WebAuthn is not supported in this browser');
    }

    // Get registration options from backend
    const optionsResponse = await apiClient.post<{
      options: WebAuthnRegistrationOptions;
      challenge: string;
    }>('/api/v1/webauthn/register/options', { device_name: deviceName });

    if (!optionsResponse.success || !optionsResponse.data) {
      throw new Error('Failed to get registration options');
    }

    const { options, challenge } = optionsResponse.data;

    // Start WebAuthn registration
    const attResp = await startRegistration(options);

    // Verify registration with backend
    const verifyResponse = await apiClient.post<{
      success: boolean;
      credential_id: string;
      message: string;
    }>('/api/v1/webauthn/register/verify', {
      credential: attResp,
      challenge,
      device_name: deviceName,
    });

    return verifyResponse;
  } catch (error) {
    console.error('Passkey registration error:', error);
    throw error;
  }
}

/**
 * Authenticate using a passkey
 * @param email - User email (optional, for username-less flow)
 * @returns Authentication result with tokens
 */
export async function authenticateWithPasskey(email?: string) {
  try {
    // Check browser support
    if (!isWebAuthnSupported()) {
      throw new Error('WebAuthn is not supported in this browser');
    }

    // Get authentication options from backend
    const optionsResponse = await apiClient.post<{
      options: WebAuthnAuthenticationOptions;
      challenge: string;
    }>('/api/v1/webauthn/authenticate/options', { email });

    if (!optionsResponse.success || !optionsResponse.data) {
      throw new Error('Failed to get authentication options');
    }

    const { options, challenge } = optionsResponse.data;

    // Start WebAuthn authentication
    const assertionResp = await startAuthentication(options);

    // Verify authentication with backend
    const verifyResponse = await apiClient.post<{
      success: boolean;
      access_token: string;
      refresh_token: string;
      token_type: string;
      user: {
        id: string;
        email: string;
        name: string;
        is_active: boolean;
        email_verified: boolean;
        roles: string[];
      };
    }>('/api/v1/webauthn/authenticate/verify', {
      credential: assertionResp,
      challenge,
      email,
    });

    return verifyResponse;
  } catch (error) {
    console.error('Passkey authentication error:', error);
    throw error;
  }
}

/**
 * Get list of user's registered passkeys
 * @returns List of passkey credentials
 */
export async function getUserPasskeys(): Promise<WebAuthnCredential[]> {
  try {
    const response = await apiClient.get<WebAuthnCredential[]>('/api/v1/webauthn/credentials');

    if (response.success && response.data) {
      return response.data;
    }

    return [];
  } catch (error) {
    console.error('Failed to fetch passkeys:', error);
    return [];
  }
}

/**
 * Delete a passkey credential
 * @param credentialId - ID of the credential to delete
 * @returns Deletion result
 */
export async function deletePasskey(credentialId: string) {
  try {
    const response = await apiClient.delete(`/api/v1/webauthn/credentials/${credentialId}`);
    return response;
  } catch (error) {
    console.error('Failed to delete passkey:', error);
    throw error;
  }
}

/**
 * Update passkey device name
 * @param credentialId - ID of the credential to update
 * @param deviceName - New device name
 * @returns Update result
 */
export async function updatePasskeyName(credentialId: string, deviceName: string) {
  try {
    const response = await apiClient.patch(`/api/v1/webauthn/credentials/${credentialId}`, {
      device_name: deviceName,
    });
    return response;
  } catch (error) {
    console.error('Failed to update passkey name:', error);
    throw error;
  }
}