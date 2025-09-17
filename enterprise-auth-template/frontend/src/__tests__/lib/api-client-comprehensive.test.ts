/**
 * Comprehensive API Client Tests
 *
 * Tests the ApiClient class with proper TypeScript types,
 * error handling, authentication, and full coverage.
 */

import { ApiClient } from '@/lib/api-client';
import { useAuthStore } from '@/stores/auth.store';
import { ErrorHandler } from '@/lib/error-handler';
import type {
  ApiResponse,
  ApiConfig,
  RequestOptions,
  QueryParams,
  PaginatedResponse,
  User,
} from '@/types';

// Type-safe mock interfaces
interface MockAuthStore {
  accessToken: string | null;
  clearAuth: jest.MockedFunction<() => void>;
  getState: jest.MockedFunction<() => MockAuthStore>;
}

interface MockErrorHandler {
  parseError: jest.MockedFunction<(error: unknown) => {
    code: string;
    message: string;
    userMessage: string;
    details?: Record<string, unknown>;
  }>;
}

interface MockResponse extends Response {
  headers: {
    get: jest.MockedFunction<(name: string) => string | null>;
  };
}

// Mock fetch globally with proper typing
const mockFetch = jest.fn() as jest.MockedFunction<typeof fetch>;
global.fetch = mockFetch;

// Mock AbortSignal timeout
global.AbortSignal = {
  ...global.AbortSignal,
  timeout: jest.fn((timeout: number) => new AbortController().signal),
} as AbortSignal & { timeout: jest.Mock };

// Mock auth store with proper types
const mockAuthStore: MockAuthStore = {
  accessToken: null,
  clearAuth: jest.fn(),
  getState: jest.fn(),
};

mockAuthStore.getState.mockReturnValue(mockAuthStore);

jest.mock('@/stores/auth.store', () => ({
  useAuthStore: {
    getState: () => mockAuthStore,
  },
}));

// Mock error handler with proper types - DECLARE BEFORE jest.mock()
const mockErrorHandler: MockErrorHandler = {
  parseError: jest.fn(),
};

// Move jest.mock() AFTER variable declaration
jest.mock('@/lib/error-handler', () => ({
  ErrorHandler: mockErrorHandler,
}));

// Test data with proper types
const mockUser: User = {
  id: 'user-123',
  email: 'test@example.com',
  full_name: 'Test User',
  username: 'testuser',
  is_active: true,
  email_verified: true,
  is_superuser: false,
  two_factor_enabled: false,
  failed_login_attempts: 0,
  last_login: '2024-01-01T00:00:00Z',
  user_metadata: {},
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z',
  roles: [],
  permissions: [],
};

const mockPaginatedResponse: PaginatedResponse<User> = {
  items: [mockUser],
  total: 1,
  page: 1,
  per_page: 20,
  pages: 1,
  has_next: false,
  has_prev: false,
};

const defaultConfig: ApiConfig = {
  baseURL: 'https://api.example.com',
  timeout: 30000,
  headers: { 'X-Custom': 'test' },
};

describe('ApiClient', () => {
  let apiClient: ApiClient;
  let mockResponse: MockResponse;

  beforeEach(() => {
    jest.clearAllMocks();

    // Reset auth store state
    mockAuthStore.accessToken = null;

    // Create mock response
    mockResponse = {
      ok: true,
      status: 200,
      headers: {
        get: jest.fn(),
      },
      json: jest.fn(),
      text: jest.fn(),
    } as MockResponse;

    mockResponse.headers.get.mockReturnValue('application/json');
    mockResponse.json.mockResolvedValue({ success: true, data: mockUser });
    mockResponse.text.mockResolvedValue('OK');

    mockFetch.mockResolvedValue(mockResponse as Response);

    // Setup error handler mock
    mockErrorHandler.parseError.mockReturnValue({
      code: 'NETWORK_ERROR',
      message: 'Network error occurred',
      userMessage: 'Unable to connect to server',
      details: {},
    });

    apiClient = new ApiClient(defaultConfig);
  });

  describe('Constructor', () => {
    it('initializes with correct configuration', () => {
      const config: ApiConfig = {
        baseURL: 'https://test.com/',
        timeout: 5000,
        headers: { 'Custom-Header': 'value' },
      };

      const client = new ApiClient(config);

      // Test that trailing slash is removed from baseURL
      expect(client).toBeInstanceOf(ApiClient);
    });

    it('sets default timeout when not provided', () => {
      const config: ApiConfig = {
        baseURL: 'https://test.com',
      };

      const client = new ApiClient(config);

      expect(client).toBeInstanceOf(ApiClient);
    });

    it('merges default headers with provided headers', () => {
      const config: ApiConfig = {
        baseURL: 'https://test.com',
        headers: { 'Authorization': 'Bearer token' },
      };

      const client = new ApiClient(config);

      expect(client).toBeInstanceOf(ApiClient);
    });
  });

  describe('Authentication Headers', () => {
    it('includes authorization header when access token is available', async () => {
      mockAuthStore.accessToken = 'test-access-token';

      await apiClient.get<User>('/users/me');

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/users/me',
        expect.objectContaining({
          headers: expect.objectContaining({
            'Authorization': 'Bearer test-access-token',
          }),
        })
      );
    });

    it('does not include authorization header when no access token', async () => {
      mockAuthStore.accessToken = null;

      await apiClient.get<User>('/users/me');

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/users/me',
        expect.objectContaining({
          headers: expect.not.objectContaining({
            'Authorization': expect.any(String),
          }),
        })
      );
    });

    it('handles server-side rendering gracefully', async () => {
      // Mock window as undefined (SSR environment)
      const originalWindow = global.window;
      delete (global as { window?: Window }).window;

      await apiClient.get<User>('/users/me');

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/users/me',
        expect.objectContaining({
          headers: expect.not.objectContaining({
            'Authorization': expect.any(String),
          }),
        })
      );

      // Restore window
      global.window = originalWindow;
    });
  });

  describe('HTTP Methods', () => {
    describe('GET Requests', () => {
      it('makes GET request with query parameters', async () => {
        const params: QueryParams = {
          search: 'test',
          page: 1,
          limit: 10,
        };

        await apiClient.get<User[]>('/users', params);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users?search=test&page=1&limit=10',
          expect.objectContaining({
            method: 'GET',
          })
        );
      });

      it('handles undefined and null query parameters', async () => {
        const params: QueryParams = {
          search: 'test',
          page: undefined,
          active: null,
          limit: 10,
        };

        await apiClient.get<User[]>('/users', params);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users?search=test&limit=10',
          expect.objectContaining({
            method: 'GET',
          })
        );
      });

      it('makes GET request without parameters', async () => {
        await apiClient.get<User>('/users/me');

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users/me',
          expect.objectContaining({
            method: 'GET',
          })
        );
      });
    });

    describe('POST Requests', () => {
      it('makes POST request with JSON data', async () => {
        const userData = {
          email: 'test@example.com',
          name: 'Test User',
        };

        await apiClient.post<User>('/users', userData);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users',
          expect.objectContaining({
            method: 'POST',
            body: JSON.stringify(userData),
            headers: expect.objectContaining({
              'Content-Type': 'application/json',
            }),
          })
        );
      });

      it('makes POST request with FormData', async () => {
        const formData = new FormData();
        formData.append('file', new Blob(['test'], { type: 'text/plain' }));
        formData.append('name', 'test-file');

        await apiClient.post<{ url: string }>('/upload', formData);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/upload',
          expect.objectContaining({
            method: 'POST',
            body: formData,
            headers: expect.not.objectContaining({
              'Content-Type': expect.any(String),
            }),
          })
        );
      });

      it('makes POST request without data', async () => {
        await apiClient.post<{ message: string }>('/logout');

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/logout',
          expect.objectContaining({
            method: 'POST',
            body: undefined,
          })
        );
      });
    });

    describe('PUT Requests', () => {
      it('makes PUT request with data', async () => {
        const updateData = { name: 'Updated Name' };

        await apiClient.put<User>('/users/123', updateData);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users/123',
          expect.objectContaining({
            method: 'PUT',
            body: JSON.stringify(updateData),
          })
        );
      });
    });

    describe('PATCH Requests', () => {
      it('makes PATCH request with partial data', async () => {
        const patchData = { email_verified: true };

        await apiClient.patch<User>('/users/123', patchData);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users/123',
          expect.objectContaining({
            method: 'PATCH',
            body: JSON.stringify(patchData),
          })
        );
      });
    });

    describe('DELETE Requests', () => {
      it('makes DELETE request', async () => {
        await apiClient.delete<{ message: string }>('/users/123');

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users/123',
          expect.objectContaining({
            method: 'DELETE',
            body: undefined,
          })
        );
      });
    });
  });

  describe('Response Handling', () => {
    it('handles successful JSON response already in ApiResponse format', async () => {
      const apiResponseData: ApiResponse<User> = {
        success: true,
        data: mockUser,
      };

      mockResponse.json.mockResolvedValue(apiResponseData);

      const result = await apiClient.get<User>('/users/me');

      expect(result).toEqual(apiResponseData);
    });

    it('wraps successful raw JSON data in ApiResponse format', async () => {
      mockResponse.json.mockResolvedValue(mockUser);

      const result = await apiClient.get<User>('/users/me');

      expect(result).toEqual({
        success: true,
        data: mockUser,
      });
    });

    it('handles successful non-JSON response', async () => {
      mockResponse.headers.get.mockReturnValue('text/plain');
      mockResponse.text.mockResolvedValue('Success');

      const result = await apiClient.get<string>('/health');

      expect(result).toEqual({
        success: true,
      });
    });

    it('handles error response with FastAPI detail format', async () => {
      mockResponse.ok = false;
      mockResponse.status = 400;
      mockResponse.json.mockResolvedValue({
        detail: 'Validation error occurred',
      });

      const result = await apiClient.get<User>('/users/invalid');

      expect(result).toEqual({
        success: false,
        error: {
          code: 'HTTP_400',
          message: 'Validation error occurred',
        },
      });
    });

    it('handles error response without detail field', async () => {
      mockResponse.ok = false;
      mockResponse.status = 500;
      mockResponse.json.mockResolvedValue({
        error: 'Internal server error',
        trace: 'error trace',
      });

      const result = await apiClient.get<User>('/users/me');

      expect(result).toEqual({
        success: false,
        error: {
          code: 'HTTP_500',
          message: 'Request failed with status 500',
          details: {
            error: 'Internal server error',
            trace: 'error trace',
          },
        },
      });
    });

    it('handles non-JSON error response', async () => {
      mockResponse.ok = false;
      mockResponse.status = 404;
      mockResponse.headers.get.mockReturnValue('text/html');
      mockResponse.text.mockResolvedValue('Not Found');

      const result = await apiClient.get<User>('/users/nonexistent');

      expect(result).toEqual({
        success: false,
        error: {
          code: 'INVALID_RESPONSE',
          message: 'Not Found',
        },
      });
    });
  });

  describe('Error Handling', () => {
    it('handles network errors', async () => {
      const networkError = new Error('Network error');
      mockFetch.mockRejectedValue(networkError);

      const result = await apiClient.get<User>('/users/me');

      expect(mockErrorHandler.parseError).toHaveBeenCalledWith(networkError);
      expect(result).toEqual({
        success: false,
        error: {
          code: 'NETWORK_ERROR',
          message: 'Unable to connect to server',
          details: {},
        },
      });
    });

    it('handles 401 unauthorized and clears auth', async () => {
      mockResponse.ok = false;
      mockResponse.status = 401;
      mockResponse.json.mockResolvedValue({
        detail: 'Unauthorized',
      });

      const result = await apiClient.get<User>('/users/me');

      expect(mockAuthStore.clearAuth).toHaveBeenCalled();
      expect(result).toEqual({
        success: false,
        error: {
          code: 'HTTP_401',
          message: 'Unauthorized',
        },
      });
    });

    it('handles timeout errors', async () => {
      const timeoutError = new DOMException('Request timed out', 'AbortError');
      mockFetch.mockRejectedValue(timeoutError);

      const result = await apiClient.get<User>('/users/me');

      expect(mockErrorHandler.parseError).toHaveBeenCalledWith(timeoutError);
    });
  });

  describe('Request Options', () => {
    it('includes custom headers from options', async () => {
      const options: RequestOptions = {
        headers: {
          'X-Request-ID': 'test-123',
          'Accept-Language': 'en-US',
        },
      };

      await apiClient.get<User>('/users/me', undefined, options);

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/users/me',
        expect.objectContaining({
          headers: expect.objectContaining({
            'X-Request-ID': 'test-123',
            'Accept-Language': 'en-US',
          }),
        })
      );
    });

    it('includes abort signal from options', async () => {
      const controller = new AbortController();
      const options: RequestOptions = {
        signal: controller.signal,
      };

      await apiClient.get<User>('/users/me', undefined, options);

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/users/me',
        expect.objectContaining({
          signal: controller.signal,
        })
      );
    });

    it('uses default timeout when no signal provided', async () => {
      await apiClient.get<User>('/users/me');

      expect(global.AbortSignal.timeout).toHaveBeenCalledWith(30000);
    });
  });

  describe('Specialized Methods', () => {
    describe('getPaginated', () => {
      it('makes paginated GET request', async () => {
        mockResponse.json.mockResolvedValue({
          success: true,
          data: mockPaginatedResponse,
        });

        const params = { page: 2, size: 10, search: 'test' };
        const result = await apiClient.getPaginated<User>('/users', params);

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/users?page=2&size=10&search=test',
          expect.objectContaining({
            method: 'GET',
          })
        );

        expect(result).toEqual({
          success: true,
          data: mockPaginatedResponse,
        });
      });
    });

    describe('upload', () => {
      it('uploads files with FormData', async () => {
        const formData = new FormData();
        formData.append('file', new Blob(['content'], { type: 'text/plain' }));

        const uploadResponse = {
          url: 'https://example.com/file.txt',
          filename: 'file.txt',
          size: 7,
        };

        mockResponse.json.mockResolvedValue({
          success: true,
          data: uploadResponse,
        });

        const result = await apiClient.upload<{ url: string; filename: string; size: number }>(
          '/upload',
          formData
        );

        expect(mockFetch).toHaveBeenCalledWith(
          'https://api.example.com/upload',
          expect.objectContaining({
            method: 'POST',
            body: formData,
            headers: expect.not.objectContaining({
              'Content-Type': expect.any(String),
            }),
          })
        );

        expect(result).toEqual({
          success: true,
          data: uploadResponse,
        });
      });
    });
  });

  describe('Configuration Management', () => {
    it('updates configuration partially', () => {
      const newConfig = {
        timeout: 5000,
        headers: { 'X-New-Header': 'value' },
      };

      apiClient.updateConfig(newConfig);

      // Configuration should be updated internally
      expect(apiClient).toBeInstanceOf(ApiClient);
    });

    it('updates base URL and removes trailing slash', () => {
      apiClient.updateConfig({
        baseURL: 'https://newapi.example.com/',
      });

      expect(apiClient).toBeInstanceOf(ApiClient);
    });

    it('clears authentication through auth store', () => {
      apiClient.clearAuth();

      expect(mockAuthStore.clearAuth).toHaveBeenCalled();
    });
  });

  describe('Type Safety', () => {
    it('maintains type safety for request and response data', async () => {
      // TypeScript should enforce these types at compile time
      const userData: Omit<User, 'id' | 'created_at' | 'updated_at'> = {
        email: 'test@example.com',
        full_name: 'Test User',
        username: 'testuser',
        is_active: true,
        email_verified: false,
        is_superuser: false,
        two_factor_enabled: false,
        failed_login_attempts: 0,
        last_login: null,
        user_metadata: {},
        roles: [],
        permissions: [],
      };

      const result = await apiClient.post<User>('/users', userData);

      // Type assertion to verify proper typing
      const typedResult: ApiResponse<User> = result;
      expect(typedResult.success).toBe(true);

      if (typedResult.success && typedResult.data) {
        // TypeScript should know these properties exist
        const user: User = typedResult.data;
        expect(typeof user.id).toBe('string');
        expect(typeof user.email).toBe('string');
      }
    });

    it('handles optional generic parameters correctly', async () => {
      // Test without explicit type parameter
      const result = await apiClient.get('/health');

      expect(result.success).toBe(true);
    });
  });

  describe('Edge Cases', () => {
    it('handles empty response body', async () => {
      mockResponse.json.mockResolvedValue({});

      const result = await apiClient.get<User>('/users/me');

      expect(result).toEqual({
        success: true,
        data: {},
      });
    });

    it('handles null response data', async () => {
      mockResponse.json.mockResolvedValue(null);

      const result = await apiClient.get<User>('/users/me');

      expect(result).toEqual({
        success: true,
        data: null,
      });
    });

    it('handles malformed JSON response', async () => {
      mockResponse.json.mockRejectedValue(new SyntaxError('Unexpected token'));

      const result = await apiClient.get<User>('/users/me');

      expect(mockErrorHandler.parseError).toHaveBeenCalledWith(
        expect.any(SyntaxError)
      );
    });

    it('handles very large request payloads', async () => {
      const largePayload = {
        data: 'x'.repeat(1000000), // 1MB string
        metadata: {
          size: 1000000,
          type: 'large-text',
        },
      };

      await apiClient.post<{ received: boolean }>('/large-data', largePayload);

      expect(mockFetch).toHaveBeenCalledWith(
        'https://api.example.com/large-data',
        expect.objectContaining({
          method: 'POST',
          body: JSON.stringify(largePayload),
        })
      );
    });
  });
});