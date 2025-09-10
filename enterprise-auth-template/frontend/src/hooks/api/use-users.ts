/**
 * User Management API Hooks
 * 
 * TanStack Query hooks for user CRUD operations with optimistic updates,
 * pagination, filtering, and intelligent caching.
 */

import { useMutation, useQuery, useQueryClient, useInfiniteQuery } from '@tanstack/react-query';
import { 
  queryKeys, 
  invalidateQueries, 
  handleQueryError
} from '@/lib/api/react-query-client';
import { User, CreateUserRequest, UpdateUserRequest, UserListParams, PaginatedResponse, BulkUserActionType } from '@/types/user';
import { usersApi } from '@/lib/api/users-api';

// Paginated users list with filtering
export const useUsers = (params: UserListParams = {}, token?: string) => {
  return useQuery({
    queryKey: queryKeys.users.list(params),
    queryFn: () => usersApi.getUsers(params, token),
    staleTime: 2 * 60 * 1000, // 2 minutes
    placeholderData: (previousData) => previousData, // For smooth pagination (replaces keepPreviousData)
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// Infinite scroll users list
export const useInfiniteUsers = (filters: UserListParams = {}, token?: string) => {
  return useInfiniteQuery({
    queryKey: queryKeys.users.list({ infinite: true, ...filters }),
    queryFn: ({ pageParam = 1 }) =>
      usersApi.getUsers({ page: pageParam, per_page: 20, ...filters }, token),
    initialPageParam: 1,
    getNextPageParam: (lastPage: PaginatedResponse<User>) => {
      if (lastPage.has_next) {
        return lastPage.page + 1;
      }
      return undefined;
    },
    staleTime: 2 * 60 * 1000,
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// Single user details
export const useUser = (userId: string | undefined, token?: string) => {
  return useQuery({
    queryKey: queryKeys.users.detail(userId || ''),
    queryFn: () => usersApi.getUserById(userId!, token),
    enabled: !!userId,
    staleTime: 5 * 60 * 1000, // 5 minutes
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// User permissions
export const useUserPermissions = (userId: string | undefined, token?: string) => {
  return useQuery({
    queryKey: queryKeys.users.permissions(userId || ''),
    queryFn: () => usersApi.getUserPermissions(userId!, token),
    enabled: !!userId,
    staleTime: 5 * 60 * 1000,
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// User roles
export const useUserRoles = (userId: string | undefined, token?: string) => {
  return useQuery({
    queryKey: queryKeys.users.roles(userId || ''),
    queryFn: () => usersApi.getUserRoles(userId!, token),
    enabled: !!userId,
    staleTime: 5 * 60 * 1000,
    meta: {
      errorHandler: handleQueryError,
    },
  });
};

// Create user mutation with optimistic updates
export const useCreateUser = (token?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (userData: CreateUserRequest) => usersApi.createUser(userData, token),
    onSuccess: (newUser: User) => {
      // Update the cache with new user data
      queryClient.setQueryData(queryKeys.users.detail(newUser.id), newUser);
      
      // Invalidate and refetch users list
      invalidateQueries.users();
    },
    onError: handleQueryError,
  });
};

// Update user mutation with optimistic updates
export const useUpdateUser = (token?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ userId, userData }: { userId: string; userData: UpdateUserRequest }) =>
      usersApi.updateUser(userId, userData, token),
    onSuccess: (updatedUser: User, { userId }) => {
      // Update cache with server response
      queryClient.setQueryData(queryKeys.users.detail(userId), updatedUser);
      
      // Invalidate related queries
      queryClient.invalidateQueries({ queryKey: queryKeys.users.roles(userId) });
      queryClient.invalidateQueries({ queryKey: queryKeys.users.permissions(userId) });
      invalidateQueries.users();
    },
    onError: handleQueryError,
  });
};

// Delete user mutation
export const useDeleteUser = (token?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (userId: string) => usersApi.deleteUser(userId, token),
    onSuccess: (_, userId) => {
      // Remove user from cache completely
      queryClient.removeQueries({ queryKey: queryKeys.users.detail(userId) });
      invalidateQueries.users();
    },
    onError: handleQueryError,
  });
};

// Bulk operations
export const useBulkOperation = (token?: string) => {
  return useMutation({
    mutationFn: (operation: { user_ids: string[]; action: BulkUserActionType }) =>
      usersApi.bulkOperation(operation, token),
    onSuccess: () => {
      // Invalidate all user-related queries after bulk update
      invalidateQueries.users();
    },
    onError: handleQueryError,
  });
};

// User activation/deactivation
export const useToggleUserActivation = (token?: string) => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ userId, activate }: { userId: string; activate: boolean }) =>
      activate ? usersApi.activateUser(userId, token) : usersApi.deactivateUser(userId, token),
    onSuccess: (updatedUser: User, { userId }) => {
      queryClient.setQueryData(queryKeys.users.detail(userId), updatedUser);
      invalidateQueries.users();
    },
    onError: handleQueryError,
  });
};

// Export statistics for performance monitoring
export const useUsersQueryStats = () => {
  const queryClient = useQueryClient();
  
  return {
    getCacheStats: () => {
      const cache = queryClient.getQueryCache();
      const userQueries = cache.getAll().filter(query => 
        Array.isArray(query.queryKey) && query.queryKey[0] === 'users'
      );
      
      return {
        totalUserQueries: userQueries.length,
        staleUserQueries: userQueries.filter(q => q.isStale()).length,
        fetchingUserQueries: userQueries.filter(q => q.state.status === 'pending').length,
      };
    },
  };
};