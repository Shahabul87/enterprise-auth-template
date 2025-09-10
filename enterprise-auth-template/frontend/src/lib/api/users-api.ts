import type {
  User,
  CreateUserRequest,
  UpdateUserRequest,
  UserListParams,
  PaginatedResponse,
  BulkUserOperation,
} from '@/types/user';

interface UserRole {
  id: string;
  name: string;
  description?: string;
  permissions?: string[];
}

const API_BASE_URL = process.env['NEXT_PUBLIC_API_URL'] || 'http://localhost:8000';

class UsersAPIError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'UsersAPIError';
  }
}

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const errorData = await response.json().catch(() => ({ message: 'Network error' }));
    throw new UsersAPIError(
      errorData.message || 'API request failed',
      response.status,
      errorData
    );
  }
  return response.json();
}

function getAuthHeader(token?: string): Record<string, string> {
  return token ? { Authorization: `Bearer ${token}` } : {};
}

export const usersApi = {
  async getUsers(
    params: UserListParams = {},
    token?: string
  ): Promise<PaginatedResponse<User>> {
    const searchParams = new URLSearchParams();
    
    Object.entries(params).forEach(([key, value]) => {
      if (value !== undefined && value !== null) {
        searchParams.append(key, String(value));
      }
    });

    const response = await fetch(`${API_BASE_URL}/api/users?${searchParams}`, {
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<PaginatedResponse<User>>(response);
  },

  async getUserById(id: string, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}`, {
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<User>(response);
  },

  async createUser(userData: CreateUserRequest, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeader(token),
      },
      body: JSON.stringify(userData),
    });

    return handleResponse<User>(response);
  },

  async updateUser(id: string, userData: UpdateUserRequest, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeader(token),
      },
      body: JSON.stringify(userData),
    });

    return handleResponse<User>(response);
  },

  async deleteUser(id: string, token?: string): Promise<{ message: string }> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}`, {
      method: 'DELETE',
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<{ message: string }>(response);
  },

  async bulkOperation(
    operation: BulkUserOperation,
    token?: string
  ): Promise<{ message: string; updated_count: number }> {
    const response = await fetch(`${API_BASE_URL}/api/users/bulk`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...getAuthHeader(token),
      },
      body: JSON.stringify(operation),
    });

    return handleResponse<{ message: string; updated_count: number }>(response);
  },

  async activateUser(id: string, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}/activate`, {
      method: 'POST',
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<User>(response);
  },

  async deactivateUser(id: string, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}/deactivate`, {
      method: 'POST',
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<User>(response);
  },

  async verifyUser(id: string, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}/verify`, {
      method: 'POST',
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<User>(response);
  },

  async unverifyUser(id: string, token?: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}/unverify`, {
      method: 'POST',
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<User>(response);
  },

  async getUserPermissions(id: string, token?: string): Promise<string[]> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}/permissions`, {
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<string[]>(response);
  },

  async getUserRoles(id: string, token?: string): Promise<UserRole[]> {
    const response = await fetch(`${API_BASE_URL}/api/users/${id}/roles`, {
      headers: {
        ...getAuthHeader(token),
      },
    });

    return handleResponse<UserRole[]>(response);
  },
};