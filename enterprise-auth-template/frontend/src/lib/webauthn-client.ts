/**
 * WebAuthn Client Service
 * 
 * Browser-side WebAuthn implementation that handles:
 * - Passkey registration (credential creation)
 * - Passkey authentication (credential assertion)
 * - Communication with backend WebAuthn API
 * - Browser compatibility checks
 * 
 * Implements FIDO2/WebAuthn standards for enterprise security.
 */

import apiClient from './api-client';

// Types for WebAuthn operations
export interface WebAuthnCredential {
  id: string;
  device_name: string;
  created_at: string;
  last_used: string | null;
  transports: string[];
  aaguid: string;
  credential_id_preview: string;
}

export interface WebAuthnRegistrationOptions {
  rp: { name: string; id: string };
  user: { id: string; name: string; displayName: string };
  challenge: string;
  pubKeyCredParams: Array<{ type: string; alg: number }>;
  timeout: number;
  excludeCredentials: Array<{
    type: string;
    id: string;
    transports: string[];
  }>;
  authenticatorSelection: {
    authenticatorAttachment?: string;
    residentKey?: string;
    userVerification: string;
  };
  attestation: string;
}

export interface WebAuthnAuthenticationOptions {
  challenge: string;
  timeout: number;
  rpId: string;
  allowCredentials: Array<{
    type: string;
    id: string;
    transports: string[];
  }>;
  userVerification: string;
}

interface AuthenticationResult {
  access_token: string;
  token_type: string;
  user: {
    id: string;
    email: string;
    first_name: string;
    last_name: string;
    full_name: string | null;
    is_verified: boolean;
    roles: string[];
  };
}

/**
 * WebAuthn Client Service
 * 
 * Handles all client-side WebAuthn operations including browser API calls
 * and communication with the backend authentication service.
 */
class WebAuthnClientService {
  constructor() {
    // baseUrl is handled by apiClient
  }

  /**
   * Check if WebAuthn is supported in the current browser
   */
  isSupported(): boolean {
    return (
      typeof window !== 'undefined' &&
      'navigator' in window &&
      'credentials' in navigator &&
      'create' in navigator.credentials &&
      'get' in navigator.credentials &&
      typeof PublicKeyCredential !== 'undefined'
    );
  }

  /**
   * Check if platform authenticator is available (Face ID, Touch ID, Windows Hello)
   */
  async isPlatformAuthenticatorAvailable(): Promise<boolean> {
    if (!this.isSupported()) return false;

    try {
      const available = await PublicKeyCredential.isUserVerifyingPlatformAuthenticatorAvailable();
      return available;
    } catch {
      return false;
    }
  }

  /**
   * Get browser/platform information for better UX messaging
   */
  getPlatformInfo(): {
    platform: string;
    authenticatorName: string;
    supportMessage: string;
  } {
    const userAgent = navigator.userAgent;
    
    if (userAgent.includes('iPhone') || userAgent.includes('iPad')) {
      return {
        platform: 'iOS',
        authenticatorName: 'Face ID or Touch ID',
        supportMessage: 'Use Face ID or Touch ID to create a passkey',
      };
    } else if (userAgent.includes('Mac')) {
      return {
        platform: 'macOS',
        authenticatorName: 'Touch ID or password',
        supportMessage: 'Use Touch ID or your Mac password to create a passkey',
      };
    } else if (userAgent.includes('Windows')) {
      return {
        platform: 'Windows',
        authenticatorName: 'Windows Hello',
        supportMessage: 'Use Windows Hello, PIN, or security key to create a passkey',
      };
    } else if (userAgent.includes('Android')) {
      return {
        platform: 'Android',
        authenticatorName: 'biometric or screen lock',
        supportMessage: 'Use fingerprint, face unlock, or screen lock to create a passkey',
      };
    }
    
    return {
      platform: 'Unknown',
      authenticatorName: 'device authentication',
      supportMessage: 'Use your device authentication to create a passkey',
    };
  }

  /**
   * Register a new WebAuthn credential (passkey)
   */
  async registerCredential(deviceName?: string): Promise<void> {
    if (!this.isSupported()) {
      throw new Error('WebAuthn is not supported in this browser');
    }

    try {
      // Step 1: Get registration options from server
      const optionsResponse = await apiClient.post('/api/v1/webauthn/register/options', {
        device_name: deviceName,
      });

      const { options, challenge } = optionsResponse.data as {
        options: WebAuthnRegistrationOptions;
        challenge: string;
      };

      // Step 2: Convert server response to browser-compatible format
      const publicKeyCredentialCreationOptions: PublicKeyCredentialCreationOptions = {
        rp: options.rp,
        user: {
          id: this.base64urlToBuffer(options.user.id),
          name: options.user.name,
          displayName: options.user.displayName,
        },
        challenge: this.base64urlToBuffer(options.challenge),
        pubKeyCredParams: options.pubKeyCredParams as PublicKeyCredentialParameters[],
        timeout: options.timeout,
        excludeCredentials: options.excludeCredentials?.map((cred: {
          type: string;
          id: string;
          transports: string[];
        }) => ({
          type: cred.type as PublicKeyCredentialType,
          id: this.base64urlToBuffer(cred.id),
          transports: cred.transports as AuthenticatorTransport[],
        })) || [],
        authenticatorSelection: {
          ...(options.authenticatorSelection.authenticatorAttachment ? { authenticatorAttachment: options.authenticatorSelection.authenticatorAttachment } : {}),
          ...(options.authenticatorSelection.residentKey ? { residentKey: options.authenticatorSelection.residentKey } : {}),
          userVerification: options.authenticatorSelection.userVerification,
        } as AuthenticatorSelectionCriteria,
        attestation: options.attestation as AttestationConveyancePreference,
      };

      // Step 3: Create credential using browser WebAuthn API
      const credential = await navigator.credentials.create({
        publicKey: publicKeyCredentialCreationOptions,
      }) as PublicKeyCredential;

      if (!credential) {
        throw new Error('Failed to create credential');
      }

      // Step 4: Prepare credential data for server verification
      const attestationResponse = credential.response as AuthenticatorAttestationResponse;
      const credentialData = {
        id: credential.id,
        rawId: this.bufferToBase64url(credential.rawId),
        response: {
          attestationObject: this.bufferToBase64url(attestationResponse.attestationObject),
          clientDataJSON: this.bufferToBase64url(attestationResponse.clientDataJSON),
          transports: (attestationResponse as AuthenticatorAttestationResponse & {
            getTransports?: () => string[];
          }).getTransports?.() || [],
        },
        type: credential.type,
      };

      // Step 5: Send credential to server for verification and storage
      await apiClient.post('/api/v1/webauthn/register/verify', {
        credential: credentialData,
        challenge: challenge,
        device_name: deviceName,
      });

    } catch (error: unknown) {
      // WebAuthn registration failed - error already handled
      
      // Handle specific WebAuthn errors with user-friendly messages
      if (error instanceof Error) {
        if (error.name === 'NotAllowedError') {
          throw new Error('Registration was cancelled or timed out');
        } else if (error.name === 'NotSupportedError') {
          throw new Error('Passkeys are not supported on this device');
        } else if (error.name === 'InvalidStateError') {
          throw new Error('A passkey for this account already exists on this device');
        } else if (error.name === 'SecurityError') {
          throw new Error('Registration failed due to security restrictions');
        }
        throw new Error(error.message || 'Failed to register passkey');
      } else if (typeof error === 'object' && error !== null && 'response' in error) {
        const apiError = error as { response?: { data?: { error?: { message?: string } } } };
        if (apiError.response?.data?.error?.message) {
          throw new Error(apiError.response.data.error.message);
        }
      }
      throw new Error('Failed to register passkey');
    }
  }

  /**
   * Authenticate using WebAuthn credential (passkey login)
   */
  async authenticate(email?: string): Promise<AuthenticationResult> {
    if (!this.isSupported()) {
      throw new Error('WebAuthn is not supported in this browser');
    }

    try {
      // Step 1: Get authentication options from server
      const optionsResponse = await apiClient.post('/api/v1/webauthn/authenticate/options', {
        email: email,
      });

      const { options, challenge } = optionsResponse.data as {
        options: WebAuthnAuthenticationOptions;
        challenge: string;
      };

      // Step 2: Convert server response to browser-compatible format
      const publicKeyCredentialRequestOptions: PublicKeyCredentialRequestOptions = {
        challenge: this.base64urlToBuffer(options.challenge),
        timeout: options.timeout,
        rpId: options.rpId,
        allowCredentials: options.allowCredentials?.map((cred: {
          type: string;
          id: string;
          transports: string[];
        }) => ({
          type: cred.type as PublicKeyCredentialType,
          id: this.base64urlToBuffer(cred.id),
          transports: cred.transports as AuthenticatorTransport[],
        })) || [],
        userVerification: options.userVerification as UserVerificationRequirement,
      };

      // Step 3: Get credential using browser WebAuthn API
      const credential = await navigator.credentials.get({
        publicKey: publicKeyCredentialRequestOptions,
      }) as PublicKeyCredential;

      if (!credential) {
        throw new Error('Failed to get credential');
      }

      // Step 4: Prepare credential data for server verification
      const assertionResponse = credential.response as AuthenticatorAssertionResponse;
      const credentialData = {
        id: credential.id,
        rawId: this.bufferToBase64url(credential.rawId),
        response: {
          authenticatorData: this.bufferToBase64url(assertionResponse.authenticatorData),
          clientDataJSON: this.bufferToBase64url(assertionResponse.clientDataJSON),
          signature: this.bufferToBase64url(assertionResponse.signature),
          userHandle: assertionResponse.userHandle 
            ? this.bufferToBase64url(assertionResponse.userHandle)
            : null,
        },
        type: credential.type,
      };

      // Step 5: Send credential to server for verification and authentication
      const authResponse = await apiClient.post('/api/v1/webauthn/authenticate/verify', {
        credential: credentialData,
        challenge: challenge,
      });

      return authResponse.data as AuthenticationResult;

    } catch (error: unknown) {
      // WebAuthn authentication failed - error already handled
      
      // Handle specific WebAuthn errors
      if (error instanceof Error) {
        if (error.name === 'NotAllowedError') {
          throw new Error('Authentication was cancelled or timed out');
        } else if (error.name === 'NotSupportedError') {
          throw new Error('Passkeys are not supported on this device');
        } else if (error.name === 'SecurityError') {
          throw new Error('Authentication failed due to security restrictions');
        }
        throw new Error(error.message || 'Authentication failed');
      } else if (typeof error === 'object' && error !== null && 'response' in error) {
        const apiError = error as { response?: { data?: { error?: { message?: string } } } };
        if (apiError.response?.data?.error?.message) {
          throw new Error(apiError.response.data.error.message);
        }
      }
      throw new Error('Authentication failed');
    }
  }

  /**
   * Get user's registered WebAuthn credentials
   */
  async getUserCredentials(): Promise<WebAuthnCredential[]> {
    try {
      const response = await apiClient.get('/api/v1/webauthn/credentials');
      return (response.data as { credentials: WebAuthnCredential[] }).credentials || [];
    } catch (error: unknown) {
      // Failed to get WebAuthn credentials - error already handled
      if (typeof error === 'object' && error !== null && 'response' in error) {
        const apiError = error as { response?: { data?: { error?: { message?: string } } } };
        throw new Error(apiError.response?.data?.error?.message || 'Failed to load passkeys');
      }
      throw new Error('Failed to load passkeys');
    }
  }

  /**
   * Delete a user's WebAuthn credential
   */
  async deleteCredential(credentialId: string): Promise<void> {
    try {
      await apiClient.delete(`/api/v1/webauthn/credentials/${credentialId}`);
    } catch (error: unknown) {
      // Failed to delete WebAuthn credential - error already handled
      if (typeof error === 'object' && error !== null && 'response' in error) {
        const apiError = error as { response?: { data?: { error?: { message?: string } } } };
        throw new Error(apiError.response?.data?.error?.message || 'Failed to delete passkey');
      }
      throw new Error('Failed to delete passkey');
    }
  }

  /**
   * Get WebAuthn service status and capabilities
   */
  async getServiceStatus(): Promise<{
    webauthn_enabled: boolean;
    rp_id: string;
    rp_name: string;
    supported_algorithms: string[];
  }> {
    try {
      const response = await apiClient.get('/api/v1/webauthn/status');
      return response.data as {
        webauthn_enabled: boolean;
        rp_id: string;
        rp_name: string;
        supported_algorithms: string[];
      };
    } catch (_error) { // eslint-disable-line @typescript-eslint/no-unused-vars
      // Failed to get WebAuthn status - error already handled
      throw new Error('Failed to check WebAuthn availability');
    }
  }

  // Helper methods for base64url encoding/decoding

  private base64urlToBuffer(base64url: string): ArrayBuffer {
    // Convert base64url to base64
    const base64 = base64url.replace(/-/g, '+').replace(/_/g, '/');
    const padded = base64.padEnd(base64.length + (4 - (base64.length % 4)) % 4, '=');
    
    // Convert to buffer
    const binary = atob(padded);
    const buffer = new ArrayBuffer(binary.length);
    const view = new Uint8Array(buffer);
    
    for (let i = 0; i < binary.length; i++) {
      view[i] = binary.charCodeAt(i);
    }
    
    return buffer;
  }

  private bufferToBase64url(buffer: ArrayBuffer): string {
    const binary = String.fromCharCode(...new Uint8Array(buffer));
    const base64 = btoa(binary);
    
    // Convert base64 to base64url
    return base64
      .replace(/\+/g, '-')
      .replace(/\//g, '_')
      .replace(/=/g, '');
  }
}

// Export singleton instance
export const webAuthnService = new WebAuthnClientService();

// Export additional utilities
export const webAuthnUtils = {
  /**
   * Check if the current environment supports WebAuthn
   */
  isSupported: () => webAuthnService.isSupported(),

  /**
   * Get user-friendly error message for WebAuthn errors
   */
  getErrorMessage: (error: unknown): string => {
    if (error instanceof Error) {
      if (error.name === 'NotAllowedError') {
        return 'Operation was cancelled or timed out';
      } else if (error.name === 'NotSupportedError') {
        return 'Passkeys are not supported on this device/browser';
      } else if (error.name === 'InvalidStateError') {
        return 'A passkey already exists for this account on this device';
      } else if (error.name === 'SecurityError') {
        return 'Security restrictions prevent this operation';
      } else if (error.name === 'NetworkError') {
        return 'Network error - please check your connection';
      } else {
        return error.message || 'An unexpected error occurred';
      }
    } else {
      return 'An unexpected error occurred';
    }
  },

  /**
   * Get platform-specific messaging for better UX
   */
  getPlatformInfo: () => webAuthnService.getPlatformInfo(),
};