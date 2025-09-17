/**
 * User Store using Zustand
 * 
 * Manages user profile data, settings, and user-related operations
 * separate from authentication state.
 */

import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { 
  User, 
  ApiResponse, 
  UpdateUserRequest, 
  PaginatedResponse,
  UserListParams 
} from '@/types';

// User profile settings interface
export interface UserProfile extends User {
  avatar_url?: string;
  timezone?: string;
  language?: string;
  phone?: string;
  bio?: string;
  website?: string;
  company?: string;
  location?: string;
  date_of_birth?: string;
  gender?: string;
  notification_preferences?: NotificationPreferences;
  privacy_settings?: PrivacySettings;
}

export interface NotificationPreferences {
  email_notifications: boolean;
  push_notifications: boolean;
  sms_notifications: boolean;
  marketing_emails: boolean;
  security_alerts: boolean;
  product_updates: boolean;
  weekly_digest: boolean;
}

export interface PrivacySettings {
  profile_visibility: 'public' | 'private' | 'friends';
  email_visibility: boolean;
  phone_visibility: boolean;
  location_visibility: boolean;
  activity_status: boolean;
  search_indexing: boolean;
}

export interface UserActivityLog {
  id: string;
  user_id: string;
  action: string;
  resource_type: string;
  resource_id?: string;
  ip_address: string;
  user_agent: string;
  timestamp: string;
  details?: Record<string, unknown>;
}

export interface UserStatistics {
  login_count: number;
  last_login: string;
  account_age_days: number;
  profile_completion: number;
  activity_score: number;
  total_sessions: number;
  average_session_duration: number;
  devices_used: number;
  countries_accessed: number;
}

// Error handling for user operations
export interface UserError {
  code: string;
  message: string;
  field?: string;
  details?: Record<string, unknown>;
  timestamp: Date;
}

// User store state interface
export interface UserState {
  // Core user profile data
  currentUser: UserProfile | null;
  users: User[];
  selectedUser: User | null;
  
  // Loading states
  isLoading: boolean;
  isUpdating: boolean;
  isFetchingUsers: boolean;
  isUploadingAvatar: boolean;
  
  // Error handling
  error: UserError | null;
  errors: UserError[];
  
  // User list management
  userList: {
    items: User[];
    total: number;
    page: number;
    size: number;
    pages: number;
    has_next: boolean;
    has_prev: boolean;
  };
  
  // Search and filtering
  searchQuery: string;
  filters: UserListParams;
  sortBy: string;
  sortOrder: 'asc' | 'desc';
  
  // User activity and stats
  activityLogs: UserActivityLog[];
  statistics: UserStatistics | null;
  
  // Profile completion tracking
  profileCompletion: {
    percentage: number;
    missing_fields: string[];
    recommendations: string[];
  };
  
  // Actions
  // Profile management
  fetchCurrentUser: () => Promise<void>;
  updateProfile: (data: Partial<UserProfile>) => Promise<boolean>;
  uploadAvatar: (file: File) => Promise<string | null>;
  deleteAvatar: () => Promise<boolean>;
  
  // User management (admin features)
  fetchUsers: (params?: UserListParams) => Promise<void>;
  fetchUser: (userId: string) => Promise<User | null>;
  createUser: (userData: UpdateUserRequest) => Promise<boolean>;
  updateUser: (userId: string, data: Partial<UpdateUserRequest>) => Promise<boolean>;
  deleteUser: (userId: string) => Promise<boolean>;
  
  // Search and filtering
  setSearchQuery: (query: string) => void;
  setFilters: (filters: Partial<UserListParams>) => void;
  setSorting: (field: string, order: 'asc' | 'desc') => void;
  clearFilters: () => void;
  
  // User selection
  selectUser: (user: User | null) => void;
  
  // Activity and statistics
  fetchUserActivity: (userId?: string) => Promise<void>;
  fetchUserStatistics: (userId?: string) => Promise<void>;
  
  // Profile completion
  calculateProfileCompletion: () => void;
  getProfileRecommendations: () => string[];
  
  // Notifications and privacy
  updateNotificationPreferences: (preferences: Partial<NotificationPreferences>) => Promise<boolean>;
  updatePrivacySettings: (settings: Partial<PrivacySettings>) => Promise<boolean>;
  
  // Bulk operations
  bulkUpdateUsers: (userIds: string[], updates: Partial<UpdateUserRequest>) => Promise<boolean>;
  bulkDeleteUsers: (userIds: string[]) => Promise<boolean>;
  
  // Export and import
  exportUserData: (format: 'json' | 'csv') => Promise<string>;
  importUsers: (file: File) => Promise<boolean>;
  
  // Error management
  setError: (error: UserError | null) => void;
  clearError: () => void;
  addError: (error: UserError) => void;
  clearErrors: () => void;
  
  // Utility actions
  refreshData: () => Promise<void>;
  clearUserData: () => void;
}

// Mock API functions - replace with actual API calls
const UserAPI = {
  async getCurrentUser(): Promise<ApiResponse<UserProfile | null>> {
    // Mock implementation - replace with actual API call
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: null };
  },
  
  async updateProfile(data: Partial<UserProfile>): Promise<ApiResponse<UserProfile | null>> {
    console.debug('Updating profile with:', data);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: null };
  },
  
  async uploadAvatar(file: File): Promise<ApiResponse<{ url: string }>> {
    console.debug('Uploading avatar:', file.name, 'size:', file.size);
    await new Promise(resolve => setTimeout(resolve, 1000));
    return { success: true, data: { url: '/api/placeholder-avatar.jpg' } };
  },
  
  async fetchUsers(params: UserListParams): Promise<ApiResponse<PaginatedResponse<User>>> {
    console.debug('Fetching users with params:', params);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { 
      success: true, 
      data: { 
        items: [], 
        total: 0, 
        page: 1, 
        per_page: 10, 
        pages: 0, 
        has_next: false, 
        has_prev: false 
      } 
    };
  },
  
  async fetchUser(userId: string): Promise<ApiResponse<User | null>> {
    console.debug('Fetching user:', userId);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: null };
  },
  
  async updateUser(userId: string, data: Partial<UpdateUserRequest>): Promise<ApiResponse<User | null>> {
    console.debug('Updating user:', userId, 'with data:', data);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: null };
  },
  
  async deleteUser(userId: string): Promise<ApiResponse<{ message: string }>> {
    console.debug('Deleting user:', userId);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: { message: 'User deleted successfully' } };
  },
  
  async fetchUserActivity(userId: string): Promise<ApiResponse<UserActivityLog[]>> {
    console.debug('Fetching activity for user:', userId);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: [] };
  },
  
  async fetchUserStatistics(userId: string): Promise<ApiResponse<UserStatistics | null>> {
    console.debug('Fetching statistics for user:', userId);
    await new Promise(resolve => setTimeout(resolve, 500));
    return { success: true, data: null };
  }
};

export const useUserStore = create<UserState>()(
  devtools(
    subscribeWithSelector(
      persist(
        immer((set, get) => ({
          // Initial state
          currentUser: null,
          users: [],
          selectedUser: null,
          isLoading: false,
          isUpdating: false,
          isFetchingUsers: false,
          isUploadingAvatar: false,
          error: null,
          errors: [],
          userList: {
            items: [],
            total: 0,
            page: 1,
            size: 10,
            pages: 0,
            has_next: false,
            has_prev: false,
          },
          searchQuery: '',
          filters: {},
          sortBy: 'created_at',
          sortOrder: 'desc',
          activityLogs: [],
          statistics: null,
          profileCompletion: {
            percentage: 0,
            missing_fields: [],
            recommendations: [],
          },
          
          // Profile management actions
          fetchCurrentUser: async () => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await UserAPI.getCurrentUser();
              if (response.success && response.data) {
                set((state) => {
                  state.currentUser = response.data || null;
                });
                get().calculateProfileCompletion();
              }
            } catch (error) {
              const userError: UserError = {
                code: 'FETCH_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch user profile',
                timestamp: new Date(),
              };
              get().setError(userError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          updateProfile: async (data: Partial<UserProfile>) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              const response = await UserAPI.updateProfile(data);
              if (response.success && response.data) {
                set((state) => {
                  if (state.currentUser) {
                    state.currentUser = { ...state.currentUser, ...response.data };
                  }
                });
                get().calculateProfileCompletion();
                return true;
              }
              return false;
            } catch (error) {
              const userError: UserError = {
                code: 'UPDATE_PROFILE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update profile',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          uploadAvatar: async (file: File) => {
            set((state) => {
              state.isUploadingAvatar = true;
              state.error = null;
            });
            
            try {
              const response = await UserAPI.uploadAvatar(file);
              if (response.success && response.data) {
                const avatarUrl = response.data.url;
                set((state) => {
                  if (state.currentUser) {
                    state.currentUser.avatar_url = avatarUrl;
                  }
                });
                return avatarUrl;
              }
              return null;
            } catch (error) {
              const userError: UserError = {
                code: 'UPLOAD_AVATAR_ERROR',
                message: error instanceof Error ? error.message : 'Failed to upload avatar',
                timestamp: new Date(),
              };
              get().setError(userError);
              return null;
            } finally {
              set((state) => {
                state.isUploadingAvatar = false;
              });
            }
          },
          
          deleteAvatar: async () => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              // In a real implementation, make API call to delete avatar
              set((state) => {
                if (state.currentUser) {
                  delete state.currentUser.avatar_url;
                }
              });
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'DELETE_AVATAR_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete avatar',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          // User management actions
          fetchUsers: async (params: UserListParams = {}) => {
            set((state) => {
              state.isFetchingUsers = true;
              state.error = null;
            });
            
            try {
              const searchQuery = get().searchQuery || params.search;
              const searchParams: UserListParams = {
                ...get().filters,
                ...params,
                sort_by: get().sortBy,
                sort_order: get().sortOrder,
                ...(searchQuery && { search: searchQuery }),
              };
              
              const response = await UserAPI.fetchUsers(searchParams);
              if (response.success && response.data) {
                set((state) => {
                  if (response.data) {
                    state.userList.items = response.data.items;
                    state.userList.total = response.data.total;
                    state.userList.page = response.data.page;
                    state.userList.size = response.data.per_page;
                    state.userList.pages = response.data.pages;
                    state.userList.has_next = response.data.page < response.data.pages;
                    state.userList.has_prev = response.data.page > 1;
                    state.users = response.data.items;
                  }
                });
              }
            } catch (error) {
              const userError: UserError = {
                code: 'FETCH_USERS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch users',
                timestamp: new Date(),
              };
              get().setError(userError);
            } finally {
              set((state) => {
                state.isFetchingUsers = false;
              });
            }
          },
          
          fetchUser: async (userId: string) => {
            try {
              const response = await UserAPI.fetchUser(userId);
              if (response.success && response.data) {
                return response.data;
              }
              return null;
            } catch (error) {
              const userError: UserError = {
                code: 'FETCH_SINGLE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to fetch user',
                timestamp: new Date(),
              };
              get().setError(userError);
              return null;
            }
          },
          
          createUser: async (userData: UpdateUserRequest) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              // In real implementation, make API call to create user
              console.debug('Creating user with data:', userData);
              await new Promise(resolve => setTimeout(resolve, 500));
              await get().fetchUsers(); // Refresh user list
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'CREATE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create user',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          updateUser: async (userId: string, data: Partial<UpdateUserRequest>) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              const response = await UserAPI.updateUser(userId, data);
              if (response.success) {
                await get().fetchUsers(); // Refresh user list
                return true;
              }
              return false;
            } catch (error) {
              const userError: UserError = {
                code: 'UPDATE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update user',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          deleteUser: async (userId: string) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              const response = await UserAPI.deleteUser(userId);
              if (response.success) {
                set((state) => {
                  state.users = state.users.filter(user => user.id !== userId);
                  if (state.selectedUser?.id === userId) {
                    state.selectedUser = null;
                  }
                });
                await get().fetchUsers(); // Refresh user list
                return true;
              }
              return false;
            } catch (error) {
              const userError: UserError = {
                code: 'DELETE_USER_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete user',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          // Search and filtering actions
          setSearchQuery: (query: string) => {
            set((state) => {
              state.searchQuery = query;
            });
          },
          
          setFilters: (filters: Partial<UserListParams>) => {
            set((state) => {
              state.filters = { ...state.filters, ...filters };
            });
          },
          
          setSorting: (field: string, order: 'asc' | 'desc') => {
            set((state) => {
              state.sortBy = field;
              state.sortOrder = order;
            });
          },
          
          clearFilters: () => {
            set((state) => {
              state.searchQuery = '';
              state.filters = {};
            });
          },
          
          // User selection
          selectUser: (user: User | null) => {
            set((state) => {
              state.selectedUser = user;
            });
          },
          
          // Activity and statistics
          fetchUserActivity: async (userId?: string) => {
            const targetUserId = userId || get().currentUser?.id;
            if (!targetUserId) return;
            
            try {
              const response = await UserAPI.fetchUserActivity(targetUserId);
              if (response.success && response.data) {
                set((state) => {
                  state.activityLogs = response.data || [];
                });
              }
            } catch (error) {
              console.debug('Error fetching user activity:', error);
            }
          },
          
          fetchUserStatistics: async (userId?: string) => {
            const targetUserId = userId || get().currentUser?.id;
            if (!targetUserId) return;
            
            try {
              const response = await UserAPI.fetchUserStatistics(targetUserId);
              if (response.success && response.data) {
                set((state) => {
                  state.statistics = response.data || null;
                });
              }
            } catch (error) {
              console.debug('Error fetching user activity:', error);
            }
          },
          
          // Profile completion
          calculateProfileCompletion: () => {
            const user = get().currentUser;
            if (!user) return;
            
            const requiredFields = [
              'first_name',
              'last_name',
              'email',
              'avatar_url',
              'phone',
              'bio',
              'timezone',
              'language',
            ];
            
            const completedFields = requiredFields.filter(field => {
              const value = user[field as keyof UserProfile];
              return value !== undefined && value !== null && value !== '';
            });
            
            const percentage = Math.round((completedFields.length / requiredFields.length) * 100);
            const missingFields = requiredFields.filter(field => {
              const value = user[field as keyof UserProfile];
              return value === undefined || value === null || value === '';
            });
            
            set((state) => {
              state.profileCompletion = {
                percentage,
                missing_fields: missingFields,
                recommendations: get().getProfileRecommendations(),
              };
            });
          },
          
          getProfileRecommendations: () => {
            const completion = get().profileCompletion;
            const recommendations: string[] = [];
            
            if (completion.missing_fields.includes('avatar_url')) {
              recommendations.push('Add a profile picture to make your account more recognizable');
            }
            if (completion.missing_fields.includes('bio')) {
              recommendations.push('Write a short bio to tell others about yourself');
            }
            if (completion.missing_fields.includes('phone')) {
              recommendations.push('Add your phone number for account security');
            }
            if (completion.missing_fields.includes('timezone')) {
              recommendations.push('Set your timezone for better scheduling');
            }
            
            return recommendations;
          },
          
          // Notification and privacy settings
          updateNotificationPreferences: async (preferences: Partial<NotificationPreferences>) => {
            try {
              // In real implementation, make API call
              set((state) => {
                if (state.currentUser?.notification_preferences) {
                  state.currentUser.notification_preferences = {
                    ...state.currentUser.notification_preferences,
                    ...preferences,
                  };
                }
              });
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'UPDATE_NOTIFICATIONS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update notification preferences',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            }
          },
          
          updatePrivacySettings: async (settings: Partial<PrivacySettings>) => {
            try {
              // In real implementation, make API call
              set((state) => {
                if (state.currentUser?.privacy_settings) {
                  state.currentUser.privacy_settings = {
                    ...state.currentUser.privacy_settings,
                    ...settings,
                  };
                }
              });
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'UPDATE_PRIVACY_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update privacy settings',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            }
          },
          
          // Bulk operations
          bulkUpdateUsers: async (userIds: string[], updates: Partial<UpdateUserRequest>) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              // In real implementation, make API call for bulk update
              console.debug('Bulk updating users:', userIds, 'with updates:', updates);
              await new Promise(resolve => setTimeout(resolve, 1000));
              await get().fetchUsers(); // Refresh user list
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'BULK_UPDATE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to update users',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          bulkDeleteUsers: async (userIds: string[]) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              // In real implementation, make API call for bulk delete
              console.debug('Bulk deleting users:', userIds);
              await new Promise(resolve => setTimeout(resolve, 1000));
              await get().fetchUsers(); // Refresh user list
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'BULK_DELETE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete users',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          // Export and import
          exportUserData: async (format: 'json' | 'csv') => {
            try {
              // In real implementation, make API call to export data
              const data = format === 'json' 
                ? JSON.stringify(get().users, null, 2)
                : 'id,email,full_name,is_active\n' +
                  get().users.map(user => `${user.id},${user.email},${user.full_name},${user.is_active}`).join('\n');
              
              return data;
            } catch (error) {
              const userError: UserError = {
                code: 'EXPORT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to export user data',
                timestamp: new Date(),
              };
              get().setError(userError);
              return '';
            }
          },
          
          importUsers: async (file: File) => {
            set((state) => {
              state.isUpdating = true;
              state.error = null;
            });
            
            try {
              // In real implementation, make API call to import users
              console.debug('Importing users from file:', file.name, 'size:', file.size);
              await new Promise(resolve => setTimeout(resolve, 2000));
              await get().fetchUsers(); // Refresh user list
              return true;
            } catch (error) {
              const userError: UserError = {
                code: 'IMPORT_ERROR',
                message: error instanceof Error ? error.message : 'Failed to import users',
                timestamp: new Date(),
              };
              get().setError(userError);
              return false;
            } finally {
              set((state) => {
                state.isUpdating = false;
              });
            }
          },
          
          // Error management
          setError: (error: UserError | null) => {
            set((state) => {
              state.error = error;
              if (error) {
                state.errors.push(error);
                // Keep only last 5 errors
                if (state.errors.length > 5) {
                  state.errors = state.errors.slice(-5);
                }
              }
            });
          },
          
          clearError: () => {
            set((state) => {
              state.error = null;
            });
          },
          
          addError: (error: UserError) => {
            set((state) => {
              state.errors.push(error);
              // Keep only last 5 errors
              if (state.errors.length > 5) {
                state.errors = state.errors.slice(-5);
              }
            });
          },
          
          clearErrors: () => {
            set((state) => {
              state.errors = [];
            });
          },
          
          // Utility actions
          refreshData: async () => {
            await Promise.all([
              get().fetchCurrentUser(),
              get().fetchUsers(),
              get().fetchUserActivity(),
              get().fetchUserStatistics(),
            ]);
          },
          
          clearUserData: () => {
            set((state) => {
              state.currentUser = null;
              state.users = [];
              state.selectedUser = null;
              state.userList = {
                items: [],
                total: 0,
                page: 1,
                size: 10,
                pages: 0,
                has_next: false,
                has_prev: false,
              };
              state.activityLogs = [];
              state.statistics = null;
              state.profileCompletion = {
                percentage: 0,
                missing_fields: [],
                recommendations: [],
              };
              state.error = null;
              state.errors = [];
            });
          },
        })),
        {
          name: 'user-storage',
          // Persist only safe data, avoid sensitive information
          partialize: (state) => ({
            searchQuery: state.searchQuery,
            filters: state.filters,
            sortBy: state.sortBy,
            sortOrder: state.sortOrder,
            profileCompletion: state.profileCompletion,
          }),
        }
      )
    ),
    {
      name: 'UserStore',
    }
  )
);

// Selector hooks for common use cases
export const useCurrentUser = () => useUserStore((state) => state.currentUser);
export const useUsers = () => useUserStore((state) => state.users);
export const useSelectedUser = () => useUserStore((state) => state.selectedUser);
export const useUserLoading = () => useUserStore((state) => state.isLoading);
export const useUserError = () => useUserStore((state) => state.error);
export const useProfileCompletion = () => useUserStore((state) => state.profileCompletion);
export const useUserStatistics = () => useUserStore((state) => state.statistics);

// Helper hooks for common patterns
export const useUser = useUserStore;

export function useUserProfile() {
  const store = useUserStore();
  
  return {
    user: store.currentUser,
    isLoading: store.isLoading,
    error: store.error,
    completion: store.profileCompletion,
    updateProfile: store.updateProfile,
    uploadAvatar: store.uploadAvatar,
    deleteAvatar: store.deleteAvatar,
    fetchUser: store.fetchCurrentUser,
  };
}

export function useUserManagement() {
  const store = useUserStore();
  
  return {
    users: store.users,
    userList: store.userList,
    selectedUser: store.selectedUser,
    isLoading: store.isFetchingUsers,
    error: store.error,
    searchQuery: store.searchQuery,
    filters: store.filters,
    sorting: { field: store.sortBy, order: store.sortOrder },
    
    // Actions
    fetchUsers: store.fetchUsers,
    selectUser: store.selectUser,
    createUser: store.createUser,
    updateUser: store.updateUser,
    deleteUser: store.deleteUser,
    setSearchQuery: store.setSearchQuery,
    setFilters: store.setFilters,
    setSorting: store.setSorting,
    clearFilters: store.clearFilters,
    bulkUpdateUsers: store.bulkUpdateUsers,
    bulkDeleteUsers: store.bulkDeleteUsers,
  };
}