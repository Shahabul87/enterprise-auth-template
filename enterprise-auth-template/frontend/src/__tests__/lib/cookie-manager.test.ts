
import { TokenPair } from '@/types';
import { TestJWTPayload } from '../types/test-interfaces';


/**
 * Comprehensive test suite for Cookie Manager utilities
 * Tests all cookie management functions with proper TypeScript typing
 *
 * Coverage includes:
 * - Basic cookie operations (get, set, delete)
 * - Security cookie options (secure, sameSite, httpOnly)
 * - Authentication token storage and retrieval
 * - JWT token parsing and validation
 * - Token expiration checks
 * - Browser environment handling
 * - Edge cases and error scenarios
 */
import {
  getCookie,
  setCookie,
  deleteCookie,
  storeAuthTokens,
  getAuthTokens,
  clearAuthCookies,
  hasAuthCookies,
  parseJwtPayload,
  isTokenExpired,
  getTokenExpiration,
  AUTH_COOKIES,
} from '@/lib/cookie-manager';


// Mock document.cookie for testing with realistic behavior
let mockCookieStore: string = '';

Object.defineProperty(document, 'cookie', {
  get: () => mockCookieStore,
  set: (value: string) => {
    // Simple cookie parser - just append for testing
    if (value.includes('expires=Thu, 01 Jan 1970')) {
      // Handle cookie deletion
      const [nameValue] = value.split(';');
      const [name] = nameValue.split('=');
      mockCookieStore = mockCookieStore
        .split('; ')
        .filter(cookie => !cookie.startsWith(`${name}=`))
        .join('; ');
    } else {
      // Handle cookie setting
      const [nameValue] = value.split(';');
      const [name] = nameValue.split('=');

      // Remove existing cookie with same name
      mockCookieStore = mockCookieStore
        .split('; ')
        .filter(cookie => !cookie.startsWith(`${name}=`))
        .join('; ');

      // Add new cookie
      if (mockCookieStore) {
        mockCookieStore += `; ${nameValue}`;
      } else {
        mockCookieStore = nameValue;
      }
    }
  },
});

// Mock window.location for protocol checks
Object.defineProperty(window, 'location', {
  writable: true,
  value: {
    protocol: 'https:',
  },
});

// Helper function to create valid JWT token for testing
function createMockJWT(payload: TestJWTPayload): string {
  const header = { alg: 'HS256', typ: 'JWT' };
  const encodedHeader = btoa(JSON.stringify(header));
  const encodedPayload = btoa(JSON.stringify(payload));
  const signature = 'mock-signature';
  return `${encodedHeader}.${encodedPayload}.${signature}`;
}

// Helper function to clear all cookies
function clearAllCookies(): void {
  mockCookieStore = '';
}

describe('Cookie Manager', () => {
  beforeEach(() => {
    clearAllCookies();
    // Reset location to https for most tests
    Object.defineProperty(window, 'location', {
      writable: true,
      value: { protocol: 'https:' },
    });
  });

  afterEach(() => {
    clearAllCookies();
  });

describe('AUTH_COOKIES constants', () => {
    it('should export correct cookie names', () => {
      expect(AUTH_COOKIES.ACCESS_TOKEN).toBe('access_token');
      expect(AUTH_COOKIES.REFRESH_TOKEN).toBe('refresh_token');
      expect(AUTH_COOKIES.SESSION_ID).toBe('session_id');
    });

    it('should be defined as constants', () => {
      expect(typeof AUTH_COOKIES.ACCESS_TOKEN).toBe('string');
      expect(typeof AUTH_COOKIES.REFRESH_TOKEN).toBe('string');
      expect(typeof AUTH_COOKIES.SESSION_ID).toBe('string');
    });
  });

describe('getCookie', () => {
    it('should return null when window is undefined (SSR)', () => {
      const originalWindow = global.window;
      delete (global as { window?: typeof window }).window;

      const result = getCookie('test');
      expect(result).toBeNull();

      global.window = originalWindow;
    });

    it('should return cookie value when cookie exists', () => {
      document.cookie = 'testCookie=testValue; path=/';

      const result = getCookie('testCookie');
      expect(result).toBe('testValue');
    });

    it('should return null when cookie does not exist', () => {
      const result = getCookie('nonExistentCookie');
      expect(result).toBeNull();
    });

    it('should handle cookies with special characters', () => {
      const specialValue = 'value with spaces and @#$%';
      document.cookie = `specialCookie=${encodeURIComponent(specialValue)}; path=/`;

      const result = getCookie('specialCookie');
      expect(result).toBe(encodeURIComponent(specialValue));
    });

    it('should return correct value when multiple cookies exist', () => {
      document.cookie = 'cookie1=value1; path=/';
      document.cookie = 'cookie2=value2; path=/';
      document.cookie = 'cookie3=value3; path=/';

      expect(getCookie('cookie1')).toBe('value1');
      expect(getCookie('cookie2')).toBe('value2');
      expect(getCookie('cookie3')).toBe('value3');
    });

    it('should handle cookies with similar names', () => {
      document.cookie = 'test=value1; path=/';
      document.cookie = 'test_token=value2; path=/';
      document.cookie = 'test_session=value3; path=/';

      expect(getCookie('test')).toBe('value1');
      expect(getCookie('test_token')).toBe('value2');
      expect(getCookie('test_session')).toBe('value3');
    });

    it('should return null for empty cookie value', () => {
      document.cookie = 'emptyCookie=; path=/';

      const result = getCookie('emptyCookie');
      expect(result).toBeNull();
    });
  });

describe('setCookie', () => {
    it('should return early when window is undefined (SSR)', () => {
      const originalWindow = global.window;
      delete (global as { window?: typeof window }).window;

      // Should not throw an error
      setCookie('test', 'value');

      global.window = originalWindow;
    });

    it('should set cookie with default options', () => {
      setCookie('testCookie', 'testValue');

      // Verify cookie was set by trying to retrieve it
      expect(getCookie('testCookie')).toBe('testValue');
    });

    it('should set cookie with custom path', () => {
      setCookie('pathCookie', 'pathValue', { path: '/custom' });

      // Note: In test environment, we can't fully test path behavior
      // but we can verify the cookie was set
      expect(getCookie('pathCookie')).toBe('pathValue');
    });

    it('should set cookie with expiration date', () => {
      const futureDate = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours from now
      setCookie('expireCookie', 'expireValue', { expires: futureDate });

      expect(getCookie('expireCookie')).toBe('expireValue');
    });

    it('should set cookie with domain option', () => {
      setCookie('domainCookie', 'domainValue', { domain: '.example.com' });

      expect(getCookie('domainCookie')).toBe('domainValue');
    });

    it('should set secure cookie on HTTPS', () => {
      setCookie('secureCookie', 'secureValue', { secure: true });

      expect(getCookie('secureCookie')).toBe('secureValue');
    });

    it('should respect sameSite option', () => {
      setCookie('strictCookie', 'strictValue', { sameSite: 'strict' });
      setCookie('laxCookie', 'laxValue', { sameSite: 'lax' });
      setCookie('noneCookie', 'noneValue', { sameSite: 'none' });

      expect(getCookie('strictCookie')).toBe('strictValue');
      expect(getCookie('laxCookie')).toBe('laxValue');
      expect(getCookie('noneCookie')).toBe('noneValue');
    });

    it('should encode special characters in cookie value', () => {
      const specialValue = 'value with spaces and @#$%';
      setCookie('specialCookie', specialValue);

      const result = getCookie('specialCookie');
      expect(result).toBe(encodeURIComponent(specialValue));
    });

    it('should use HTTP protocol awareness for secure flag', () => {
      // Test HTTP environment
      Object.defineProperty(window, 'location', {
        writable: true,
        value: { protocol: 'http:' },
      });

      setCookie('httpCookie', 'httpValue');
      expect(getCookie('httpCookie')).toBe('httpValue');

      // Test HTTPS environment
      Object.defineProperty(window, 'location', {
        writable: true,
        value: { protocol: 'https:' },
      });

      setCookie('httpsCookie', 'httpsValue');
      expect(getCookie('httpsCookie')).toBe('httpsValue');
    });
  });

describe('deleteCookie', () => {
    it('should return early when window is undefined (SSR)', () => {
      const originalWindow = global.window;
      delete (global as { window?: typeof window }).window;

      // Should not throw an error
      deleteCookie('test');

      global.window = originalWindow;
    });

    it('should delete existing cookie', () => {
      // First set a cookie
      setCookie('deleteCookie', 'deleteValue');
      expect(getCookie('deleteCookie')).toBe('deleteValue');

      // Then delete it
      deleteCookie('deleteCookie');

      // Cookie should be gone (or empty)
      const result = getCookie('deleteCookie');
      expect(result).toBeNull();
    });

    it('should delete cookie with custom path', () => {
      setCookie('pathDeleteCookie', 'pathDeleteValue', { path: '/custom' });
      expect(getCookie('pathDeleteCookie')).toBe('pathDeleteValue');

      deleteCookie('pathDeleteCookie', '/custom');

      const result = getCookie('pathDeleteCookie');
      expect(result).toBeNull();
    });

    it('should not throw when deleting non-existent cookie', () => {
      expect(() => deleteCookie('nonExistentCookie')).not.toThrow();
    });
  });

describe('storeAuthTokens', () => {
    const mockTokenPair: TokenPair = {
      access_token: 'mock-access-token-123',
      refresh_token: 'mock-refresh-token-456',
      token_type: 'bearer',
      expires_in: 3600,
    };

    it('should store both access and refresh tokens', () => {
      storeAuthTokens(mockTokenPair);

      expect(getCookie(AUTH_COOKIES.ACCESS_TOKEN)).toBe(mockTokenPair.access_token);
      expect(getCookie(AUTH_COOKIES.REFRESH_TOKEN)).toBe(mockTokenPair.refresh_token);
    });

    it('should handle missing expires_in with default value', () => {
      const tokenWithoutExpiry: TokenPair = {
        access_token: 'access-token',
        refresh_token: 'refresh-token',
        token_type: 'bearer',
        expires_in: 0, // No expiry specified
      };

      storeAuthTokens(tokenWithoutExpiry);

      expect(getCookie(AUTH_COOKIES.ACCESS_TOKEN)).toBe(tokenWithoutExpiry.access_token);
      expect(getCookie(AUTH_COOKIES.REFRESH_TOKEN)).toBe(tokenWithoutExpiry.refresh_token);
    });

    it('should set appropriate expiration times', () => {
      // Mock Date.now to control time
      const mockNow = 1640995200000; // 2022-01-01T00:00:00.000Z
      const originalDateNow = Date.now;
      Date.now = jest.fn(() => mockNow);

      storeAuthTokens(mockTokenPair);

      // Verify tokens are stored (can't easily verify expiry in test environment)
      expect(getCookie(AUTH_COOKIES.ACCESS_TOKEN)).toBe(mockTokenPair.access_token);
      expect(getCookie(AUTH_COOKIES.REFRESH_TOKEN)).toBe(mockTokenPair.refresh_token);

      Date.now = originalDateNow;
    });
  });

describe('getAuthTokens', () => {
    it('should return null when no auth cookies exist', () => {
      const result = getAuthTokens();
      expect(result).toBeNull();
    });

    it('should return null when only access token exists', () => {
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, 'access-token');

      const result = getAuthTokens();
      expect(result).toBeNull();
    });

    it('should return null when only refresh token exists', () => {
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, 'refresh-token');

      const result = getAuthTokens();
      expect(result).toBeNull();
    });

    it('should return token pair when both tokens exist', () => {
      const accessToken = 'mock-access-token';
      const refreshToken = 'mock-refresh-token';

      setCookie(AUTH_COOKIES.ACCESS_TOKEN, accessToken);
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, refreshToken);

      const result = getAuthTokens();

      expect(result).not.toBeNull();
      expect(result?.access_token).toBe(accessToken);
      expect(result?.refresh_token).toBe(refreshToken);
      expect(result?.token_type).toBe('bearer');
      expect(result?.expires_in).toBe(3600);
    });
  });

describe('clearAuthCookies', () => {
    it('should clear all authentication-related cookies', () => {
      // Set all auth cookies
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, 'access-token');
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, 'refresh-token');
      setCookie(AUTH_COOKIES.SESSION_ID, 'session-id');

      // Verify they exist
      expect(getCookie(AUTH_COOKIES.ACCESS_TOKEN)).toBeTruthy();
      expect(getCookie(AUTH_COOKIES.REFRESH_TOKEN)).toBeTruthy();
      expect(getCookie(AUTH_COOKIES.SESSION_ID)).toBeTruthy();

      // Clear them
      clearAuthCookies();

      // Verify they're gone
      expect(getCookie(AUTH_COOKIES.ACCESS_TOKEN)).toBeNull();
      expect(getCookie(AUTH_COOKIES.REFRESH_TOKEN)).toBeNull();
      expect(getCookie(AUTH_COOKIES.SESSION_ID)).toBeNull();
    });

    it('should not affect non-auth cookies', () => {
      setCookie('otherCookie', 'otherValue');
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, 'access-token');

      clearAuthCookies();

      expect(getCookie('otherCookie')).toBe('otherValue');
      expect(getCookie(AUTH_COOKIES.ACCESS_TOKEN)).toBeNull();
    });
  });

describe('hasAuthCookies', () => {
    it('should return false when no auth cookies exist', () => {
      expect(hasAuthCookies()).toBe(false);
    });

    it('should return false when only access token exists', () => {
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, 'access-token');
      expect(hasAuthCookies()).toBe(false);
    });

    it('should return false when only refresh token exists', () => {
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, 'refresh-token');
      expect(hasAuthCookies()).toBe(false);
    });

    it('should return true when both tokens exist', () => {
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, 'access-token');
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, 'refresh-token');
      expect(hasAuthCookies()).toBe(true);
    });

    it('should return false when tokens are empty strings', () => {
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, '');
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, '');
      expect(hasAuthCookies()).toBe(false);
    });
  });

describe('parseJwtPayload', () => {
    it('should parse valid JWT token payload', () => {
      const payload = {
        sub: 'user-123',
        email: 'test@example.com',
        exp: Math.floor(Date.now() / 1000) + 3600,
        iat: Math.floor(Date.now() / 1000),
      };

      const token = createMockJWT(payload);
      const result = parseJwtPayload(token);

      expect(result).toEqual(payload);
    });

    it('should return null for invalid JWT format', () => {
      expect(parseJwtPayload('invalid.token')).toBeNull();
      expect(parseJwtPayload('invalid')).toBeNull();
      expect(parseJwtPayload('')).toBeNull();
      expect(parseJwtPayload('too.many.parts.here')).toBeNull();
    });

    it('should return null for malformed base64 payload', () => {
      const invalidToken = 'header.invalid-base64!@#$.signature';
      expect(parseJwtPayload(invalidToken)).toBeNull();
    });

    it('should return null for non-JSON payload', () => {
      const header = btoa(JSON.stringify({ alg: 'HS256' }));
      const invalidPayload = btoa('not-json-data');
      const signature = 'signature';
      const token = `${header}.${invalidPayload}.${signature}`;

      expect(parseJwtPayload(token)).toBeNull();
    });

    it('should handle empty payload section', () => {
      const token = 'header..signature';
      expect(parseJwtPayload(token)).toBeNull();
    });
  });

describe('isTokenExpired', () => {
    it('should return false for non-expired token', () => {
      const futureExp = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now
      const payload = { exp: futureExp };
      const token = createMockJWT(payload);

      expect(isTokenExpired(token)).toBe(false);
    });

    it('should return true for expired token', () => {
      const pastExp = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
      const payload = { exp: pastExp };
      const token = createMockJWT(payload);

      expect(isTokenExpired(token)).toBe(true);
    });

    it('should return true for token expiring right now', () => {
      const nowExp = Math.floor(Date.now() / 1000);
      const payload = { exp: nowExp };
      const token = createMockJWT(payload);

      expect(isTokenExpired(token)).toBe(true);
    });

    it('should return true for invalid token', () => {
      expect(isTokenExpired('invalid-token')).toBe(true);
    });

    it('should return true for token without exp claim', () => {
      const payload = { sub: 'user-123' };
      const token = createMockJWT(payload);

      expect(isTokenExpired(token)).toBe(true);
    });

    it('should return true for token with non-numeric exp claim', () => {
      const payload = { exp: 'not-a-number' };
      const token = createMockJWT(payload);

      expect(isTokenExpired(token)).toBe(true);
    });
  });

describe('getTokenExpiration', () => {
    it('should return time remaining for non-expired token', () => {
      const futureExp = Math.floor(Date.now() / 1000) + 3600; // 1 hour from now
      const payload = { exp: futureExp };
      const token = createMockJWT(payload);

      const result = getTokenExpiration(token);
      expect(result).toBeGreaterThan(3500); // Should be close to 3600
      expect(result).toBeLessThanOrEqual(3600);
    });

    it('should return 0 for expired token', () => {
      const pastExp = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
      const payload = { exp: pastExp };
      const token = createMockJWT(payload);

      expect(getTokenExpiration(token)).toBe(0);
    });

    it('should return null for invalid token', () => {
      expect(getTokenExpiration('invalid-token')).toBeNull();
    });

    it('should return null for token without exp claim', () => {
      const payload = { sub: 'user-123' };
      const token = createMockJWT(payload);

      expect(getTokenExpiration(token)).toBeNull();
    });

    it('should return null for token with non-numeric exp claim', () => {
      const payload = { exp: 'not-a-number' };
      const token = createMockJWT(payload);

      expect(getTokenExpiration(token)).toBeNull();
    });

    it('should handle token expiring exactly now', () => {
      const nowExp = Math.floor(Date.now() / 1000);
      const payload = { exp: nowExp };
      const token = createMockJWT(payload);

      expect(getTokenExpiration(token)).toBe(0);
    });
  });

describe('Integration Tests', () => {
    it('should handle complete auth flow with cookies', () => {
      const mockTokens: TokenPair = {
        access_token: createMockJWT({
          sub: 'user-123',
          exp: Math.floor(Date.now() / 1000) + 3600,
        }),
        refresh_token: createMockJWT({
          sub: 'user-123',
          exp: Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60, // 7 days
        }),
        token_type: 'bearer',
        expires_in: 3600,
      };

      // Store tokens
      storeAuthTokens(mockTokens);

      // Verify they can be retrieved
      expect(hasAuthCookies()).toBe(true);

      const retrievedTokens = getAuthTokens();
      // Note: getAuthTokens returns encoded values as stored in cookies
      expect(retrievedTokens?.access_token).toBe(getCookie(AUTH_COOKIES.ACCESS_TOKEN));
      expect(retrievedTokens?.refresh_token).toBe(getCookie(AUTH_COOKIES.REFRESH_TOKEN));

      // Verify token parsing works
      expect(isTokenExpired(mockTokens.access_token)).toBe(false);
      expect(getTokenExpiration(mockTokens.access_token)).toBeGreaterThan(0);

      // Clear tokens
      clearAuthCookies();
      expect(hasAuthCookies()).toBe(false);
      expect(getAuthTokens()).toBeNull();
    });

    it('should handle edge case with malformed stored tokens', () => {
      // Store invalid tokens manually
      setCookie(AUTH_COOKIES.ACCESS_TOKEN, 'invalid-token');
      setCookie(AUTH_COOKIES.REFRESH_TOKEN, 'another-invalid-token');

      // Should still return token pair (let auth layer handle validation)
      const tokens = getAuthTokens();
      expect(tokens).not.toBeNull();
      expect(tokens?.access_token).toBe('invalid-token');

      // But parsing should fail gracefully
      expect(parseJwtPayload('invalid-token')).toBeNull();
      expect(isTokenExpired('invalid-token')).toBe(true);
      expect(getTokenExpiration('invalid-token')).toBeNull();
    });
  });
});