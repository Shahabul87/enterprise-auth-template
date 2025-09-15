import type {
  LoginRequest,
  RegisterRequest,
  LoginResponse,
  TokenRefreshResponse,
  PasswordResetRequest,
  PasswordResetConfirm,
  ChangePasswordRequest,
  User,
} from '@/types/auth';

const API_BASE_URL = process.env['NEXT_PUBLIC_API_URL'] || 'http://localhost:8000';

class AuthAPIError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'AuthAPIError';
  }
}

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({ message: 'Network error' }));
    throw new AuthAPIError(
      errorData.message || 'API request failed',
      response.status,
      errorData
    );
  }
  return response.json();
}

export const authApi = {
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        email: credentials.email,
        password: credentials.password,
      }),
    });

    return handleResponse<LoginResponse>(response);
  },

  async register(userData: RegisterRequest): Promise<LoginResponse> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(userData),
    });

    return handleResponse<LoginResponse>(response);
  },

  async refreshToken(): Promise<TokenRefreshResponse> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/refresh`, {
      method: 'POST',
      credentials: 'include',
    });

    return handleResponse<TokenRefreshResponse>(response);
  },

  async logout(): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/logout`, {
      method: 'POST',
      credentials: 'include',
    });

    if (!response.ok) {
      throw new AuthAPIError('Logout failed', response.status);
    }
  },

  async getCurrentUser(token: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/me`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    return handleResponse<User>(response);
  },

  async requestPasswordReset(data: PasswordResetRequest): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/password-reset/request`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    return handleResponse<{ message: string }>(response);
  },

  async confirmPasswordReset(data: PasswordResetConfirm): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/password-reset/confirm`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data),
    });

    return handleResponse<{ message: string }>(response);
  },

  async changePassword(data: ChangePasswordRequest, token: string): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/change-password`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(data),
    });

    return handleResponse<{ message: string }>(response);
  },

  async verifyEmail(token: string): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/verify-email?token=${token}`, {
      method: 'POST',
    });

    return handleResponse<{ message: string }>(response);
  },

  async resendVerificationEmail(email: string): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/api/v1/auth/resend-verification`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ email }),
    });

    return handleResponse<{ message: string }>(response);
  },
};