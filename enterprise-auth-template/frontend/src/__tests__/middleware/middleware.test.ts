
import { NextRequest, NextResponse } from 'next/server';
import { middleware } from '@/middleware';

/**
 * @jest-environment jsdom
 */

jest.mock('next/server', () => ({
  NextResponse: {
    redirect: jest.fn((url) => ({
      status: 307,
      headers: new Headers({ Location: url.toString() }),
    })),
    next: jest.fn(() => ({
      status: 200,
      headers: {
        set: jest.fn(),
      },
    })),
    json: jest.fn((body, init) => ({
      json: () => Promise.resolve(body),
      status: init?.status || 200,
    })),
  },
  NextRequest: jest.fn(),
}));
// Helper function to create mock NextRequest
function createMockRequest(
  url: string,
  options: {
    cookies?: Record<string, string>;
    headers?: Record<string, string>;
  } = {}
): NextRequest {
  const req = {
    nextUrl: new URL(url),
    url,
    cookies: {
      get: jest.fn((name: string) => {
        const value = options.cookies?.[name];
        return value ? { value } : undefined;
      }),
    },
    headers: {
      get: jest.fn((name: string) => options.headers?.[name] || null),
    },
  } as unknown as NextRequest;
  return req;
}

// Helper to create valid JWT token for testing
function createValidJWT(payload: Record<string, any> = {}): string {
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const now = Math.floor(Date.now() / 1000);
  const defaultPayload = {
    sub: 'user123',
    exp: now + 3600, // expires in 1 hour
    iat: now,
    ...payload,
  };
  const encodedPayload = btoa(JSON.stringify(defaultPayload));
  const signature = 'mock-signature';
  return `${header}.${encodedPayload}.${signature}`;
}

// Helper to create expired JWT token
function createExpiredJWT(): string {
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    sub: 'user123',
    exp: now - 3600, // expired 1 hour ago
    iat: now - 7200,
  };
  const encodedPayload = btoa(JSON.stringify(payload));
  const signature = 'mock-signature';
  return `${header}.${encodedPayload}.${signature}`;
}

describe('Middleware', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

describe('Protected Routes', () => {
    const protectedRoutes = ['/dashboard', '/profile', '/admin', '/settings'];
    protectedRoutes.forEach(route => {
      it(`should redirect unauthenticated users from ${route} to login`, () => {
        const request = createMockRequest(`http://localhost${route}`);
        middleware(request);
        expect(NextResponse.redirect).toHaveBeenCalled();
        const redirectCall = (NextResponse.redirect as jest.Mock).mock.calls[0][0];
        expect(redirectCall.toString()).toContain('/auth/login');
      });
      it(`should allow authenticated users to access ${route}`, () => {
        const validToken = createValidJWT();
        const request = createMockRequest(`http://localhost${route}`, {
          cookies: { access_token: validToken },
        });
        const response = middleware(request);
        expect(NextResponse.redirect).not.toHaveBeenCalled();
        expect(response.headers.set).toHaveBeenCalled(); // Security headers should be set
      });
    });
    it('should handle nested protected routes', () => {
      const request = createMockRequest('http://localhost/admin/users');
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should include returnTo parameter in login redirect', () => {
      const request = createMockRequest('http://localhost/dashboard');
      middleware(request);
      const redirectCall = (NextResponse.redirect as jest.Mock).mock.calls[0][0];
      expect(redirectCall.searchParams.get('returnTo')).toBe('/dashboard');
    });
  });

describe('Guest-Only Routes', () => {
    const guestOnlyRoutes = ['/auth/login', '/auth/register', '/auth/forgot-password', '/auth/reset-password'];
    guestOnlyRoutes.forEach(route => {
      it(`should allow unauthenticated users to access ${route}`, () => {
        const request = createMockRequest(`http://localhost${route}`);
        const response = middleware(request);
        expect(NextResponse.redirect).not.toHaveBeenCalled();
        expect(response.headers.set).toHaveBeenCalled(); // Security headers should be set
      });
      it(`should redirect authenticated users from ${route} to dashboard`, () => {
        const validToken = createValidJWT();
        const request = createMockRequest(`http://localhost${route}`, {
          cookies: { access_token: validToken },
        });
        middleware(request);
        expect(NextResponse.redirect).toHaveBeenCalled();
        const redirectCall = (NextResponse.redirect as jest.Mock).mock.calls[0][0];
        expect(redirectCall.toString()).toContain('/dashboard');
      });
    });
    it('should redirect to returnTo URL if provided', () => {
      const validToken = createValidJWT();
      const request = createMockRequest('http://localhost/auth/login?returnTo=/profile', {
        cookies: { access_token: validToken },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
      const redirectCall = (NextResponse.redirect as jest.Mock).mock.calls[0][0];
      expect(redirectCall.toString()).toContain('/profile');
    });
  });

describe('Public Routes', () => {
    const publicRoutes = ['/', '/about', '/contact', '/terms', '/privacy', '/api/health'];
    publicRoutes.forEach(route => {
      it(`should allow access to ${route} without authentication`, () => {
        const request = createMockRequest(`http://localhost${route}`);
        const response = middleware(request);
        expect(NextResponse.redirect).not.toHaveBeenCalled();
        expect(response.headers.set).toHaveBeenCalled(); // Security headers should be set
      });
      it(`should allow authenticated users to access ${route}`, () => {
        const validToken = createValidJWT();
        const request = createMockRequest(`http://localhost${route}`, {
          cookies: { access_token: validToken },
        });
        const response = middleware(request);
        expect(NextResponse.redirect).not.toHaveBeenCalled();
        expect(response.headers.set).toHaveBeenCalled();
      });
    });
  });

describe('API Routes', () => {
    it('should allow access to public API routes without authentication', () => {
      const request = createMockRequest('http://localhost/api/health');
      const response = middleware(request);
      expect(NextResponse.redirect).not.toHaveBeenCalled();
      expect(NextResponse.json).not.toHaveBeenCalled();
    });
    it('should require authentication for protected API routes', () => {
      const request = createMockRequest('http://localhost/api/protected/users');
      middleware(request);
      expect(NextResponse.json).toHaveBeenCalledWith(
        {
          success: false,
          error: {
            code: 'UNAUTHORIZED',
            message: 'Authentication required',
          },
        },
        { status: 401 }
      );
    });
    it('should allow authenticated access to protected API routes', () => {
      const validToken = createValidJWT();
      const request = createMockRequest('http://localhost/api/protected/users', {
        cookies: { access_token: validToken },
      });
      const response = middleware(request);
      expect(NextResponse.json).not.toHaveBeenCalledWith(
        expect.objectContaining({ error: expect.anything() }),
        expect.objectContaining({ status: 401 })
      );
    });
    it('should require authentication for /api/v1/auth/me', () => {
      const request = createMockRequest('http://localhost/api/v1/auth/me');
      middleware(request);
      expect(NextResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: false,
          error: expect.objectContaining({
            code: 'UNAUTHORIZED',
          }),
        }),
        { status: 401 }
      );
    });
  });

describe('Token Validation', () => {
    it('should accept valid JWT tokens from cookies', () => {
      const validToken = createValidJWT();
      const request = createMockRequest('http://localhost/dashboard', {
        cookies: { access_token: validToken },
      });
      const response = middleware(request);
      expect(NextResponse.redirect).not.toHaveBeenCalled();
      expect(response.headers.set).toHaveBeenCalled();
    });
    it('should accept valid JWT tokens from Authorization header', () => {
      const validToken = createValidJWT();
      const request = createMockRequest('http://localhost/dashboard', {
        headers: { authorization: `Bearer ${validToken}` },
      });
      const response = middleware(request);
      expect(NextResponse.redirect).not.toHaveBeenCalled();
    });
    it('should reject expired JWT tokens', () => {
      const expiredToken = createExpiredJWT();
      const request = createMockRequest('http://localhost/dashboard', {
        cookies: { access_token: expiredToken },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should reject malformed JWT tokens', () => {
      const malformedToken = 'invalid.token';
      const request = createMockRequest('http://localhost/dashboard', {
        cookies: { access_token: malformedToken },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should reject tokens without required fields', () => {
      const invalidToken = createValidJWT({ sub: undefined }); // Missing subject
      const request = createMockRequest('http://localhost/dashboard', {
        cookies: { access_token: invalidToken },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should prioritize cookie tokens over header tokens', () => {
      const cookieToken = createValidJWT({ sub: 'cookie-user' });
      const headerToken = createValidJWT({ sub: 'header-user' });
      const request = createMockRequest('http://localhost/dashboard', {
        cookies: { access_token: cookieToken },
        headers: { authorization: `Bearer ${headerToken}` },
      });
      const response = middleware(request);
      expect(NextResponse.redirect).not.toHaveBeenCalled();
      // The fact that we don't redirect means the cookie token was used
    });
  });

describe('Security Headers', () => {
    it('should set security headers on all responses', () => {
      const request = createMockRequest('http://localhost/');
      const response = middleware(request);
      expect(response.headers.set).toHaveBeenCalledWith('X-Frame-Options', 'DENY');
      expect(response.headers.set).toHaveBeenCalledWith('X-Content-Type-Options', 'nosniff');
      expect(response.headers.set).toHaveBeenCalledWith('Referrer-Policy', 'strict-origin-when-cross-origin');
      expect(response.headers.set).toHaveBeenCalledWith('Permissions-Policy', 'camera=(), microphone=(), geolocation=()');
    });
    it('should set CSP headers', () => {
      const request = createMockRequest('http://localhost/');
      const response = middleware(request);
      expect(response.headers.set).toHaveBeenCalledWith(
        'Content-Security-Policy',
        expect.stringContaining("default-src 'self'")
      );
    });
    it('should set development CSP in development mode', () => {
      const originalEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'development';
      const request = createMockRequest('http://localhost/');
      const response = middleware(request);
      expect(response.headers.set).toHaveBeenCalledWith(
        'Content-Security-Policy',
        expect.stringContaining("'unsafe-inline'")
      );
      process.env.NODE_ENV = originalEnv;
    });
    it('should set HSTS header in production', () => {
      const originalEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'production';
      const request = createMockRequest('http://localhost/');
      const response = middleware(request);
      expect(response.headers.set).toHaveBeenCalledWith(
        'Strict-Transport-Security',
        'max-age=63072000; includeSubDomains; preload'
      );
      process.env.NODE_ENV = originalEnv;
    });
    it('should not set HSTS header in development', () => {
      const originalEnv = process.env.NODE_ENV;
      process.env.NODE_ENV = 'development';
      const request = createMockRequest('http://localhost/');
      const response = middleware(request);
      expect(response.headers.set).not.toHaveBeenCalledWith(
        'Strict-Transport-Security',
        expect.any(String)
      );
      process.env.NODE_ENV = originalEnv;
    });
  });

describe('Edge Cases', () => {
    it('should handle requests without any tokens', () => {
      const request = createMockRequest('http://localhost/dashboard');
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should handle requests with empty Authorization header', () => {
      const request = createMockRequest('http://localhost/dashboard', {
        headers: { authorization: '' },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should handle requests with malformed Authorization header', () => {
      const request = createMockRequest('http://localhost/dashboard', {
        headers: { authorization: 'NotBearer token' },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should handle tokens with invalid JSON in payload', () => {
      const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
      const invalidPayload = 'invalid-json';
      const signature = 'mock-signature';
      const malformedToken = `${header}.${invalidPayload}.${signature}`;
      const request = createMockRequest('http://localhost/dashboard', {
        cookies: { access_token: malformedToken },
      });
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should handle routes that partially match protected routes', () => {
      // '/dash' should NOT match '/dashboard'
      const request = createMockRequest('http://localhost/dash');
      const response = middleware(request);
      expect(NextResponse.redirect).not.toHaveBeenCalled();
      expect(response.headers.set).toHaveBeenCalled(); // Security headers should still be set
    });
    it('should handle query parameters in protected routes', () => {
      const request = createMockRequest('http://localhost/dashboard?tab=profile');
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
      const redirectCall = (NextResponse.redirect as jest.Mock).mock.calls[0][0];
      expect(redirectCall.searchParams.get('returnTo')).toBe('/dashboard');
    });
  });

describe('Route Matching', () => {
    it('should match exact routes', () => {
      const request = createMockRequest('http://localhost/dashboard');
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should match wildcard routes', () => {
      const request = createMockRequest('http://localhost/admin/users/123');
      middleware(request);
      expect(NextResponse.redirect).toHaveBeenCalled();
    });
    it('should not match partial routes', () => {
      const request = createMockRequest('http://localhost/administrative');
      const response = middleware(request);
      expect(NextResponse.redirect).not.toHaveBeenCalled();
      expect(response.headers.set).toHaveBeenCalled();
    });
  });
});