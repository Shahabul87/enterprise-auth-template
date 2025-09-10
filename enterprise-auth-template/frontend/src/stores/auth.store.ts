/**
 * Unified Auth Store using Zustand
 * 
 * Consolidates all authentication state management into a single store
 * with proper error handling, persistence, and TypeScript support.
 */

import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { 
  User, 
  TokenPair, 
  LoginRequest, 
  RegisterRequest,
  ApiResponse,
  LoginResponse,
} from '@/types';

// Response types for various auth operations
interface MessageResponse {
  message: string;
}

interface TwoFactorSetupResponse {
  qr_code: string;
  backup_codes: string[];
}

interface TwoFactorVerifyResponse {
  enabled: boolean;
  message: string;
}
import AuthAPI from '@/lib/auth-api';
import {
  storeAuthTokens,
  getAuthTokens,
  clearAuthCookies,
  hasAuthCookies,
  isTokenExpired,
  getCookie,
  AUTH_COOKIES,
} from '@/lib/cookie-manager';

// Error types for better error handling
export interface AuthError {
  code: string;
  message: string;
  field?: string;
  details?: Record<string, unknown>;
  timestamp: Date;
}

// Session information
export interface SessionInfo {
  loginTime: Date;
  lastActivity: Date;
  device?: string;
  ipAddress?: string;
  location?: string;
}

// Auth state interface
export interface AuthState {
  // Core authentication state
  user: User | null;
  tokens: TokenPair | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  isInitialized: boolean;
  
  // Enhanced state
  permissions: string[];
  roles: string[];
  session: SessionInfo | null;
  
  // Error handling
  error: AuthError | null;
  authErrors: AuthError[];
  
  // Feature flags
  isEmailVerified: boolean;
  is2FAEnabled: boolean;
  requiresPasswordChange: boolean;
  isTokenValid: () => boolean;
  
  // Actions
  initialize: () => Promise<void>;
  login: (credentials: LoginRequest) => Promise<ApiResponse<LoginResponse>>;
  register: (userData: RegisterRequest) => Promise<ApiResponse<User>>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<boolean>;
  refreshAccessToken: () => Promise<string | null>;
  updateUser: (userData: Partial<User>) => void;
  
  // Permission & Role checks
  hasPermission: (permission: string) => boolean;
  hasRole: (role: string) => boolean;
  hasAnyRole: (roles: string[]) => boolean;
  hasAllPermissions: (permissions: string[]) => boolean;
  
  // Error management
  setError: (error: AuthError | null) => void;
  clearError: () => void;
  addAuthError: (error: AuthError) => void;
  clearAuthErrors: () => void;
  
  // Session management
  updateSession: (session: Partial<SessionInfo>) => void;
  checkSession: () => Promise<boolean>;
  extendSession: () => Promise<void>;
  
  // Utility actions
  fetchUserData: () => Promise<void>;
  fetchPermissions: () => Promise<void>;
  verifyEmail: (token: string) => Promise<ApiResponse<MessageResponse>>;
  resendVerification: () => Promise<ApiResponse<MessageResponse>>;
  changePassword: (oldPassword: string, newPassword: string) => Promise<ApiResponse<MessageResponse>>;
  requestPasswordReset: (email: string) => Promise<ApiResponse<MessageResponse>>;
  confirmPasswordReset: (token: string, newPassword: string) => Promise<ApiResponse<MessageResponse>>;
  
  // 2FA actions
  setup2FA: () => Promise<ApiResponse<TwoFactorSetupResponse>>;
  verify2FA: (code: string) => Promise<ApiResponse<TwoFactorVerifyResponse>>;
  disable2FA: (code: string) => Promise<ApiResponse<TwoFactorVerifyResponse>>;
  
  // Internal helper methods (exposed for API client)
  clearAuth: () => void;
  setupTokenRefresh: () => void;
  clearAuthData: () => void;
}

// Token refresh interval (5 minutes before expiry)
const TOKEN_REFRESH_INTERVAL = 5 * 60 * 1000;
let refreshTimer: NodeJS.Timeout | null = null;

export const useAuthStore = create<AuthState>()(
  devtools(
    subscribeWithSelector(
      persist(
        immer((set, get) => ({
          // Initial state
          user: null,
          tokens: null,
          accessToken: null,
          isAuthenticated: false,
          isLoading: false,
          isInitialized: false,
          permissions: [],
          roles: [],
          session: null,
          error: null,
          authErrors: [],
          isEmailVerified: false,
          is2FAEnabled: false,
          requiresPasswordChange: false,
          isTokenValid: () => false,
          refreshAccessToken: async () => null,
          
          // Initialize auth state
          initialize: async () => {
            set((state) => {
              state.isLoading = true;
            });
            
            try {
              // Check for stored tokens
              const storedTokens = getAuthTokens();
              
              if (storedTokens) {
                // Validate and refresh if needed
                const accessToken = getCookie(AUTH_COOKIES.ACCESS_TOKEN);
                
                if (accessToken && !isTokenExpired(accessToken)) {
                  // Token is valid, fetch user data
                  await get().fetchUserData();
                  await get().fetchPermissions();
                  
                  set((state) => {
                    state.tokens = storedTokens;
                    state.isAuthenticated = true;
                    state.session = {
                      loginTime: new Date(),
                      lastActivity: new Date(),
                    };
                  });
                  
                  // Setup token refresh
                  get().setupTokenRefresh();
                } else if (storedTokens.refresh_token) {
                  // Try to refresh token
                  const refreshed = await get().refreshToken();
                  if (!refreshed) {
                    get().clearAuthData();
                  }
                }
              } else if (hasAuthCookies()) {
                // Have cookies but no tokens, try to fetch user
                await get().fetchUserData();
              }
            } catch (error) {
              // Error during auth initialization
              get().clearAuthData();
            } finally {
              set((state) => {
                state.isLoading = false;
                state.isInitialized = true;
              });
            }
          },
          
          // Login action
          login: async (credentials: LoginRequest) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AuthAPI.login(credentials);
              
              if (response.success && response.data) {
                const { user, access_token, refresh_token, token_type, expires_in } = response.data;
                
                const tokenPair: TokenPair = {
                  access_token,
                  refresh_token,
                  token_type,
                  expires_in,
                };
                
                // Store tokens
                storeAuthTokens(tokenPair);
                
                // Update state
                set((state) => {
                  state.user = user;
                  state.tokens = tokenPair;
                  state.accessToken = access_token;
                  state.isAuthenticated = true;
                  state.isEmailVerified = user.is_verified ?? false;
                  state.session = {
                    loginTime: new Date(),
                    lastActivity: new Date(),
                  };
                });
                
                // Fetch additional data
                await get().fetchPermissions();
                
                // Setup token refresh
                get().setupTokenRefresh();
                
                return response;
              } else {
                const error: AuthError = {
                  code: response.error?.code || 'LOGIN_FAILED',
                  message: response.error?.message || 'Login failed',
                  timestamp: new Date(),
                };
                
                set((state) => {
                  state.error = error;
                  state.authErrors.push(error);
                });
                
                return response;
              }
            } catch (error) {
              const authError: AuthError = {
                code: 'LOGIN_ERROR',
                message: error instanceof Error ? error.message : 'An error occurred during login',
                timestamp: new Date(),
              };
              
              set((state) => {
                state.error = authError;
                state.authErrors.push(authError);
              });
              
              throw error;
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          // Register action
          register: async (userData: RegisterRequest) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await AuthAPI.register(userData);
              
              if (response.success) {
                // Auto-login after registration
                await get().login({
                  email: userData.email,
                  password: userData.password,
                });
                
                return response;
              } else {
                const error: AuthError = {
                  code: response.error?.code || 'REGISTRATION_FAILED',
                  message: response.error?.message || 'Registration failed',
                  timestamp: new Date(),
                };
                
                set((state) => {
                  state.error = error;
                  state.authErrors.push(error);
                });
                
                return response;
              }
            } catch (error) {
              const authError: AuthError = {
                code: 'REGISTRATION_ERROR',
                message: error instanceof Error ? error.message : 'An error occurred during registration',
                timestamp: new Date(),
              };
              
              set((state) => {
                state.error = authError;
                state.authErrors.push(authError);
              });
              
              throw error;
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          // Logout action
          logout: async () => {
            try {
              await AuthAPI.logout();
            } catch {
              // Continue with local logout even if API call fails
            }
            
            get().clearAuthData();
            
            if (typeof window !== 'undefined') {
              window.location.href = '/auth/login';
            }
          },
          
          // Refresh token
          refreshToken: async () => {
            const currentTokens = get().tokens;
            if (!currentTokens?.refresh_token) return false;
            
            try {
              const response = await AuthAPI.refreshToken({
                refresh_token: currentTokens.refresh_token,
              });
              
              if (response.success && response.data) {
                const newTokens = response.data;
                
                // Store new tokens
                storeAuthTokens(newTokens);
                
                set((state) => {
                  state.tokens = newTokens;
                });
                
                // Reset refresh timer
                get().setupTokenRefresh();
                
                return true;
              }
              
              return false;
            } catch (error) {
              // Error during token refresh
              get().clearAuthData();
              return false;
            }
          },
          
          // Update user
          updateUser: (userData: Partial<User>) => {
            set((state) => {
              if (state.user) {
                state.user = { ...state.user, ...userData };
              }
            });
          },
          
          // Permission checks
          hasPermission: (permission: string) => {
            const permissions = get().permissions;
            if (!permissions.length) return false;
            
            // Check exact match
            if (permissions.includes(permission)) return true;
            
            // Check wildcard permissions
            return permissions.some((perm) => {
              if (perm.endsWith(':*')) {
                const base = perm.slice(0, -1);
                return permission.startsWith(base);
              }
              return false;
            });
          },
          
          // Role checks
          hasRole: (role: string) => {
            return get().roles.includes(role);
          },
          
          hasAnyRole: (roles: string[]) => {
            const userRoles = get().roles;
            return roles.some(role => userRoles.includes(role));
          },
          
          hasAllPermissions: (permissions: string[]) => {
            return permissions.every(perm => get().hasPermission(perm));
          },
          
          // Error management
          setError: (error: AuthError | null) => {
            set((state) => {
              state.error = error;
              if (error) {
                state.authErrors.push(error);
              }
            });
          },
          
          clearError: () => {
            set((state) => {
              state.error = null;
            });
          },
          
          addAuthError: (error: AuthError) => {
            set((state) => {
              state.authErrors.push(error);
              // Keep only last 10 errors
              if (state.authErrors.length > 10) {
                state.authErrors = state.authErrors.slice(-10);
              }
            });
          },
          
          clearAuthErrors: () => {
            set((state) => {
              state.authErrors = [];
            });
          },
          
          // Session management
          updateSession: (session: Partial<SessionInfo>) => {
            set((state) => {
              if (state.session) {
                state.session = { ...state.session, ...session };
              } else {
                state.session = {
                  loginTime: new Date(),
                  lastActivity: new Date(),
                  ...session,
                };
              }
            });
          },
          
          checkSession: async () => {
            if (!get().isAuthenticated) return false;
            
            // Update last activity
            get().updateSession({ lastActivity: new Date() });
            
            // Check if token needs refresh
            const tokens = get().tokens;
            if (tokens) {
              const accessToken = getCookie(AUTH_COOKIES.ACCESS_TOKEN);
              if (accessToken && isTokenExpired(accessToken)) {
                return await get().refreshToken();
              }
            }
            
            return true;
          },
          
          extendSession: async () => {
            await get().refreshToken();
            get().updateSession({ lastActivity: new Date() });
          },
          
          // Utility actions
          fetchUserData: async () => {
            try {
              const response = await AuthAPI.getCurrentUser();
              if (response.success && response.data) {
                set((state) => {
                  state.user = response.data || null;
                  state.isEmailVerified = response.data?.is_verified ?? false;
                });
              }
            } catch (error) {
              // Error fetching user data
            }
          },
          
          fetchPermissions: async () => {
            try {
              const [permResponse, rolesResponse] = await Promise.all([
                AuthAPI.getUserPermissions(),
                AuthAPI.getUserRoles(),
              ]);
              
              set((state) => {
                if (permResponse.success && permResponse.data) {
                  state.permissions = permResponse.data;
                }
                if (rolesResponse.success && rolesResponse.data) {
                  state.roles = rolesResponse.data;
                }
              });
            } catch (error) {
              // Error fetching user data
            }
          },
          
          // Email verification
          verifyEmail: async (token: string) => {
            return await AuthAPI.verifyEmail(token);
          },
          
          resendVerification: async () => {
            const email = get().user?.email;
            if (!email) {
              return {
                success: false,
                error: {
                  code: 'NO_EMAIL',
                  message: 'No email address found',
                },
              };
            }
            return await AuthAPI.resendVerification(email);
          },
          
          // Password management
          changePassword: async (oldPassword: string, newPassword: string) => {
            return await AuthAPI.changePassword({
              current_password: oldPassword,
              new_password: newPassword,
            });
          },
          
          requestPasswordReset: async (email: string) => {
            return await AuthAPI.requestPasswordReset({ email });
          },
          
          confirmPasswordReset: async (token: string, newPassword: string) => {
            return await AuthAPI.confirmPasswordReset({
              token,
              new_password: newPassword,
            });
          },
          
          // 2FA management
          setup2FA: async () => {
            const response = await AuthAPI.setup2FA();
            if (response.success) {
              set((state) => {
                state.is2FAEnabled = true;
              });
            }
            return response;
          },
          
          verify2FA: async (code: string): Promise<ApiResponse<TwoFactorVerifyResponse>> => {
            const response = await AuthAPI.verify2FA(code, '');
            if (response.success) {
              return { success: true, data: { enabled: true, message: 'Two-factor authentication verified' } };
            }
            return response.error ? { success: false, error: response.error } : { success: false };
          },
          
          disable2FA: async (code: string): Promise<ApiResponse<TwoFactorVerifyResponse>> => {
            const response = await AuthAPI.disable2FA(code);
            if (response.success) {
              set((state) => {
                state.is2FAEnabled = false;
              });
              return { success: true, data: { enabled: false, message: 'Two-factor authentication disabled' } };
            }
            return response.error ? { success: false, error: response.error } : { success: false };
          },
          
          // Clear auth method for API client
          clearAuth: () => {
            get().clearAuthData();
          },
          
          // Helper method exposed
          clearAuthData: () => {
            if (refreshTimer) {
              clearTimeout(refreshTimer);
              refreshTimer = null;
            }
            
            clearAuthCookies();
            
            set((state) => {
              state.user = null;
              state.tokens = null;
              state.accessToken = null;
              state.isAuthenticated = false;
              state.permissions = [];
              state.roles = [];
              state.session = null;
              state.isEmailVerified = false;
              state.is2FAEnabled = false;
              state.requiresPasswordChange = false;
            });
          },
          
          setupTokenRefresh: () => {
            if (refreshTimer) {
              clearTimeout(refreshTimer);
            }
            
            const tokens = get().tokens;
            if (!tokens) return;
            
            // Calculate when to refresh (5 minutes before expiry)
            const expiresIn = tokens.expires_in || 900; // Default 15 minutes
            const refreshIn = Math.max((expiresIn * 1000) - TOKEN_REFRESH_INTERVAL, 60000); // Min 1 minute
            
            refreshTimer = setTimeout(() => {
              get().refreshToken();
            }, refreshIn);
          },
        })),
        {
          name: 'auth-storage',
          // Only persist non-sensitive data
          partialize: (state) => ({
            user: state.user,
            permissions: state.permissions,
            roles: state.roles,
            isEmailVerified: state.isEmailVerified,
            is2FAEnabled: state.is2FAEnabled,
          }),
        }
      )
    ),
    {
      name: 'AuthStore',
    }
  )
);

// Selector hooks for common use cases
export const useUser = () => useAuthStore((state) => state.user);
export const useIsAuthenticated = () => useAuthStore((state) => state.isAuthenticated);
export const useAuthLoading = () => useAuthStore((state) => state.isLoading);
export const useAuthError = () => useAuthStore((state) => state.error);
export const usePermissions = () => useAuthStore((state) => state.permissions);
export const useRoles = () => useAuthStore((state) => state.roles);

// Helper hooks for common auth patterns
export const useAuth = useAuthStore;

export function useRequireAuth(redirectTo = '/auth/login') {
  const store = useAuthStore();
  const router = typeof window !== 'undefined' ? require('next/navigation').useRouter() : null;

  // Redirect if not authenticated after initialization
  if (store.isInitialized && !store.isAuthenticated && router) {
    router.push(`${redirectTo}?from=${encodeURIComponent(window.location.pathname)}`);
  }

  return store;
}

export function useGuestOnly(redirectTo = '/dashboard') {
  const store = useAuthStore();
  const router = typeof window !== 'undefined' ? require('next/navigation').useRouter() : null;

  // Redirect if authenticated after initialization
  if (store.isInitialized && store.isAuthenticated && router) {
    router.push(redirectTo);
  }

  return store;
}

// Initialize auth on app start
if (typeof window !== 'undefined') {
  useAuthStore.getState().initialize();
}