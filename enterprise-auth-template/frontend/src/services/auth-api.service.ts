import apiClient from '@/lib/api-client';
import { ApiResponse } from '@/types';

// Magic Link Types
interface MagicLinkRequestData {
  email: string;
}

interface MagicLinkResponse {
  success: boolean;
  message: string;
}

interface MagicLinkVerifyData {
  token: string;
}

interface MagicLinkVerifyResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
  user: {
    id: string;
    email: string;
    name: string;
    is_active: boolean;
    is_verified: boolean;
  };
}

// WebAuthn Types
interface WebAuthnRegistrationOptions {
  publicKey: {
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
      type: string;
      alg: number;
    }>;
    authenticatorSelection?: {
      authenticatorAttachment?: string;
      requireResidentKey?: boolean;
      userVerification?: string;
    };
    timeout?: number;
    attestation?: string;
  };
}

interface WebAuthnAuthenticationOptions {
  publicKey: {
    challenge: string;
    timeout?: number;
    rpId?: string;
    allowCredentials?: Array<{
      id: string;
      type: string;
      transports?: string[];
    }>;
    userVerification?: string;
  };
}

interface WebAuthnCredential {
  id: string;
  device_name: string;
  created_at: string;
  last_used: string | null;
  transports: string[];
  aaguid: string;
  credential_id_preview: string;
}

// Magic Link API Service
export const magicLinkService = {
  // Request a magic link
  async requestMagicLink(email: string): Promise<ApiResponse<MagicLinkResponse>> {
    return apiClient.post<MagicLinkResponse>('/api/v1/magic-links/request', { email });
  },

  // Verify magic link token
  async verifyMagicLink(token: string): Promise<ApiResponse<MagicLinkVerifyResponse>> {
    return apiClient.post<MagicLinkVerifyResponse>('/api/v1/magic-links/verify', { token });
  }
};

// WebAuthn API Service
export const webAuthnService = {
  // Get registration options
  async getRegistrationOptions(deviceName?: string): Promise<ApiResponse<WebAuthnRegistrationOptions>> {
    return apiClient.post<WebAuthnRegistrationOptions>('/api/v1/webauthn/register/options', {
      device_name: deviceName
    });
  },

  // Verify registration
  async verifyRegistration(
    credential: any,
    challenge: string,
    deviceName?: string
  ): Promise<ApiResponse<{ success: boolean; message: string }>> {
    return apiClient.post('/api/v1/webauthn/register/verify', {
      credential,
      challenge,
      device_name: deviceName
    });
  },

  // Get authentication options
  async getAuthenticationOptions(email?: string): Promise<ApiResponse<WebAuthnAuthenticationOptions>> {
    return apiClient.post<WebAuthnAuthenticationOptions>('/api/v1/webauthn/authenticate/options', {
      email
    });
  },

  // Verify authentication
  async verifyAuthentication(
    credential: any,
    challenge: string
  ): Promise<ApiResponse<MagicLinkVerifyResponse>> {
    return apiClient.post<MagicLinkVerifyResponse>('/api/v1/webauthn/authenticate/verify', {
      credential,
      challenge
    });
  },

  // Get user's credentials
  async getCredentials(): Promise<ApiResponse<WebAuthnCredential[]>> {
    return apiClient.get<WebAuthnCredential[]>('/api/v1/webauthn/credentials');
  },

  // Get user's credentials (compatibility method for WebAuthnSetup)
  async getUserCredentials(): Promise<WebAuthnCredential[]> {
    const response = await apiClient.get<WebAuthnCredential[]>('/api/v1/webauthn/credentials');
    if (response.success && response.data) {
      return response.data;
    }
    throw new Error(response.error?.message || 'Failed to get credentials');
  },

  // Delete a credential
  async deleteCredential(credentialId: string): Promise<ApiResponse<{ success: boolean; message: string }>> {
    return apiClient.delete(`/api/v1/webauthn/credentials/${credentialId}`);
  },

  // Register new credential (full flow)
  async registerCredential(deviceName: string): Promise<WebAuthnCredential> {
    // Step 1: Get registration options
    const optionsResponse = await webAuthnService.getRegistrationOptions(deviceName);
    if (!optionsResponse.success || !optionsResponse.data) {
      throw new Error(optionsResponse.error?.message || 'Failed to get registration options');
    }

    const options = optionsResponse.data;

    // Step 2: Convert challenge and user ID to ArrayBuffer
    const publicKeyOptions = {
      ...options.publicKey,
      challenge: base64ToArrayBuffer(options.publicKey.challenge),
      user: {
        ...options.publicKey.user,
        id: base64ToArrayBuffer(options.publicKey.user.id),
      },
    };

    // Step 3: Request credential from browser
    const credential = await navigator.credentials.create({
      publicKey: publicKeyOptions,
    }) as PublicKeyCredential;

    if (!credential) {
      throw new Error('Registration cancelled');
    }

    // Step 4: Prepare credential response for server
    const response = credential.response as AuthenticatorAttestationResponse;
    const credentialData = {
      id: credential.id,
      rawId: arrayBufferToBase64(credential.rawId),
      type: credential.type,
      response: {
        attestationObject: arrayBufferToBase64(response.attestationObject),
        clientDataJSON: arrayBufferToBase64(response.clientDataJSON),
      },
    };

    // Step 5: Verify with server
    const verifyResponse = await webAuthnService.verifyRegistration(
      credentialData,
      options.publicKey.challenge,
      deviceName
    );

    if (!verifyResponse.success) {
      throw new Error(verifyResponse.error?.message || 'Registration failed');
    }

    // Step 6: Get updated credentials list
    const credentials = await webAuthnService.getUserCredentials();
    // Return the newly created credential (should be the last one)
    return credentials[credentials.length - 1];
  }
};

// Helper function to convert base64 to ArrayBuffer
export function base64ToArrayBuffer(base64: string): ArrayBuffer {
  const binaryString = window.atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// Helper function to convert ArrayBuffer to base64
export function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return window.btoa(binary);
}