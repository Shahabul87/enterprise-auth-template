/**
 * Authentication API Hooks
 * 
 * TanStack Query hooks for authentication operations with caching,
 * error handling, and optimistic updates.
 */

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { 
  queryKeys, 
  invalidateQueries, 
  handleQueryError,
  prefetchQueries 
} from '@/lib/api/react-query-client';
import { LoginRequest, RegisterRequest, LoginResponse } from '@/types/auth';
import { authApi } from '@/lib/api/auth-api';

// Authentication status query
export const useAuth = (token?: string) => {
  return useQuery({
    queryKey: queryKeys.auth.me(),
    queryFn: () => authApi.getCurrentUser(token || ''),
    enabled: !!token,
    staleTime: 5 * 60 * 1000, // 5 minutes
    retry: false, // Don't retry auth checks
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// User permissions query with caching - moved to users API
export const useUserPermissions = (userId?: string, token?: string) => {
  const { usersApi } = require('@/lib/api/users-api');
  return useQuery({
    queryKey: queryKeys.auth.permissions(userId || ''),
    queryFn: () => usersApi.getUserPermissions(userId!, token),
    enabled: !!userId && !!token,
    staleTime: 5 * 60 * 1000, // 5 minutes - matches backend cache
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// User roles query with caching - moved to users API  
export const useUserRoles = (userId?: string, token?: string) => {
  const { usersApi } = require('@/lib/api/users-api');
  return useQuery({
    queryKey: queryKeys.auth.roles(userId || ''),
    queryFn: () => usersApi.getUserRoles(userId!, token),
    enabled: !!userId && !!token,
    staleTime: 5 * 60 * 1000, // 5 minutes - matches backend cache
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// Login mutation with cache updates
export const useLogin = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (credentials: LoginRequest) => authApi.login(credentials),
    onSuccess: async (data: LoginResponse) => {
      // Update auth cache immediately
      queryClient.setQueryData(queryKeys.auth.me(), data.user);
      
      // Cache user permissions if available
      if (data.user.permissions) {
        queryClient.setQueryData(
          queryKeys.auth.permissions(data.user.id),
          data.user.permissions
        );
      }

      // Cache user roles if available
      if (data.user.roles) {
        queryClient.setQueryData(
          queryKeys.auth.roles(data.user.id),
          data.user.roles
        );
      }

      // Prefetch dashboard data after successful login
      await prefetchQueries.dashboard();
    },
    onError: handleQueryError,
  });
};

// Register mutation
export const useRegister = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: RegisterRequest) => authApi.register(data),
    onSuccess: (response: LoginResponse) => {
      // Update auth cache with new user
      queryClient.setQueryData(queryKeys.auth.me(), response.user);
      
      // Invalidate user list to include new user
      invalidateQueries.users();
    },
    onError: handleQueryError,
  });
};

// Logout mutation with cache cleanup
export const useLogout = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: authApi.logout,
    onSuccess: () => {
      // Clear all cached data
      queryClient.clear();
    },
    onError: handleQueryError,
  });
};

// Password reset request
export const usePasswordReset = () => {
  return useMutation({
    mutationFn: (email: string) => authApi.requestPasswordReset({ email }),
    onError: handleQueryError,
  });
};

// Password reset confirmation
export const usePasswordResetConfirm = () => {
  return useMutation({
    mutationFn: ({ token, new_password }: { token: string; new_password: string }) =>
      authApi.confirmPasswordReset({ token, new_password }),
    onError: handleQueryError,
  });
};

// Email verification
export const useEmailVerification = () => {
  return useMutation({
    mutationFn: (token: string) => authApi.verifyEmail(token),
    onSuccess: () => {
      // Refresh user data to update verification status
      invalidateQueries.auth();
    },
    onError: handleQueryError,
  });
};

// Resend verification email
export const useResendVerification = () => {
  return useMutation({
    mutationFn: (email: string) => authApi.resendVerificationEmail(email),
    onError: handleQueryError,
  });
};

// Token refresh (typically handled automatically by interceptors)
export const useRefreshToken = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: authApi.refreshToken,
    onSuccess: () => {
      // Update tokens in storage or context
      // This would typically be handled by axios interceptors
    },
    onError: (error) => {
      // If refresh fails, redirect to login
      queryClient.clear();
      handleQueryError(error);
    },
  });
};

// Check specific permission
export const useHasPermission = (permission: string, userId?: string) => {
  const { data: permissions } = useUserPermissions(userId);
  
  return {
    hasPermission: permissions?.includes(permission) || false,
    isLoading: !permissions,
  };
};

// Check multiple permissions
export const useHasPermissions = (requiredPermissions: string[], userId?: string) => {
  const { data: permissions } = useUserPermissions(userId);
  
  const hasAllPermissions = requiredPermissions.every(
    permission => permissions?.includes(permission)
  );
  
  const hasAnyPermissions = requiredPermissions.some(
    permission => permissions?.includes(permission)
  );

  return {
    hasAllPermissions,
    hasAnyPermissions,
    missingPermissions: requiredPermissions.filter(
      permission => !permissions?.includes(permission)
    ),
    isLoading: !permissions,
  };
};

// Check specific role
export const useHasRole = (role: string, userId?: string) => {
  const { data: roles } = useUserRoles(userId);
  
  return {
    hasRole: roles?.includes(role) || false,
    isLoading: !roles,
  };
};

// Check multiple roles
export const useHasRoles = (requiredRoles: string[], userId?: string) => {
  const { data: roles } = useUserRoles(userId);
  
  const hasAllRoles = requiredRoles.every(role => roles?.includes(role));
  const hasAnyRoles = requiredRoles.some(role => roles?.includes(role));

  return {
    hasAllRoles,
    hasAnyRoles,
    missingRoles: requiredRoles.filter(role => !roles?.includes(role)),
    isLoading: !roles,
  };
};

// Authentication state with derived data
export const useAuthState = (token?: string) => {
  const { data: user, isLoading, error } = useAuth(token);
  const { data: permissions } = useUserPermissions(user?.id, token);
  const { data: roles } = useUserRoles(user?.id, token);

  return {
    user,
    permissions: permissions || [],
    roles: roles || [],
    isAuthenticated: !!user,
    isLoading,
    error,
    isAdmin: roles?.includes('admin') || user?.is_superuser || false,
    isSuperuser: user?.is_superuser || false,
    isVerified: user?.email_verified || false,
    isActive: user?.is_active || false,
  };
};