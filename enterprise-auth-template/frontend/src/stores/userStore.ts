import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { devtools } from 'zustand/middleware';

export interface UserProfile {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  phone?: string;
  bio?: string;
  timezone?: string;
  language?: string;
  theme?: 'light' | 'dark' | 'system';
  emailVerified: boolean;
  phoneVerified: boolean;
  twoFactorEnabled: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface UserPreferences {
  notifications: {
    email: boolean;
    push: boolean;
    sms: boolean;
    marketing: boolean;
    security: boolean;
    updates: boolean;
  };
  privacy: {
    profileVisibility: 'public' | 'private' | 'friends';
    showEmail: boolean;
    showPhone: boolean;
    showActivity: boolean;
    allowIndexing: boolean;
  };
  accessibility: {
    fontSize: 'small' | 'medium' | 'large';
    highContrast: boolean;
    reduceMotion: boolean;
    screenReaderMode: boolean;
  };
}

export interface UserSession {
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
  sessionId: string;
  deviceId?: string;
}

export interface UserActivity {
  lastLogin: string;
  lastPasswordChange: string;
  loginCount: number;
  failedLoginAttempts: number;
  accountLocked: boolean;
  lockoutUntil?: string;
}

interface UserState {
  // State
  user: UserProfile | null;
  preferences: UserPreferences | null;
  session: UserSession | null;
  activity: UserActivity | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  // Actions
  setUser: (user: UserProfile) => void;
  updateUser: (updates: Partial<UserProfile>) => Promise<void>;
  setPreferences: (preferences: UserPreferences) => void;
  updatePreferences: (updates: Partial<UserPreferences>) => Promise<void>;
  setSession: (session: UserSession) => void;
  clearSession: () => void;
  setActivity: (activity: UserActivity) => void;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<void>;
  fetchProfile: () => Promise<void>;
  updateProfile: (data: Partial<UserProfile>) => Promise<void>;
  changePassword: (currentPassword: string, newPassword: string) => Promise<void>;
  enable2FA: () => Promise<{ qrCode: string; secret: string }>;
  disable2FA: (code: string) => Promise<void>;
  verify2FA: (code: string) => Promise<void>;
  requestPasswordReset: (email: string) => Promise<void>;
  resetPassword: (token: string, newPassword: string) => Promise<void>;
  verifyEmail: (token: string) => Promise<void>;
  resendVerificationEmail: () => Promise<void>;
  deleteAccount: (password: string) => Promise<void>;
  exportData: () => Promise<Blob>;
  clearError: () => void;
}

const defaultPreferences: UserPreferences = {
  notifications: {
    email: true,
    push: true,
    sms: false,
    marketing: false,
    security: true,
    updates: true,
  },
  privacy: {
    profileVisibility: 'private',
    showEmail: false,
    showPhone: false,
    showActivity: true,
    allowIndexing: false,
  },
  accessibility: {
    fontSize: 'medium',
    highContrast: false,
    reduceMotion: false,
    screenReaderMode: false,
  },
};

export const useUserStore = create<UserState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial state
        user: null,
        preferences: null,
        session: null,
        activity: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,

        // Actions
        setUser: (user) => set({ user, isAuthenticated: true }),

        updateUser: async (updates) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/users/profile', {
              method: 'PATCH',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
              body: JSON.stringify(updates),
            });

            if (!response.ok) throw new Error('Failed to update profile');

            const updatedUser = await response.json();
            set({ user: updatedUser, isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        setPreferences: (preferences) => set({ preferences }),

        updatePreferences: async (updates) => {
          set({ isLoading: true, error: null });
          try {
            const currentPreferences = get().preferences || defaultPreferences;
            const newPreferences = {
              ...currentPreferences,
              ...updates,
              notifications: {
                ...currentPreferences.notifications,
                ...(updates.notifications || {}),
              },
              privacy: {
                ...currentPreferences.privacy,
                ...(updates.privacy || {}),
              },
              accessibility: {
                ...currentPreferences.accessibility,
                ...(updates.accessibility || {}),
              },
            };

            const response = await fetch('/api/v1/users/preferences', {
              method: 'PUT',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
              body: JSON.stringify(newPreferences),
            });

            if (!response.ok) throw new Error('Failed to update preferences');

            set({ preferences: newPreferences, isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        setSession: (session) => set({ session, isAuthenticated: true }),

        clearSession: () =>
          set({
            session: null,
            user: null,
            isAuthenticated: false,
            preferences: null,
            activity: null,
          }),

        setActivity: (activity) => set({ activity }),

        login: async (email, password) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ username: email, password }),
            });

            if (!response.ok) {
              const error = await response.json();
              throw new Error(error.detail || 'Login failed');
            }

            const data = await response.json();
            
            set({
              session: {
                accessToken: data.access_token,
                refreshToken: data.refresh_token,
                expiresAt: Date.now() + data.expires_in * 1000,
                sessionId: data.session_id,
              },
              user: data.user,
              isAuthenticated: true,
              isLoading: false,
            });

            // Fetch additional data
            get().fetchProfile();
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        logout: async () => {
          set({ isLoading: true });
          try {
            const session = get().session;
            if (session?.accessToken) {
              await fetch('/api/v1/auth/logout', {
                method: 'POST',
                headers: {
                  Authorization: `Bearer ${session.accessToken}`,
                },
              });
            }
          } catch {
            
          } finally {
            get().clearSession();
            set({ isLoading: false });
          }
        },

        refreshToken: async () => {
          const session = get().session;
          if (!session?.refreshToken) {
            throw new Error('No refresh token available');
          }

          try {
            const response = await fetch('/api/v1/auth/refresh', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
              },
              body: JSON.stringify({ refresh_token: session.refreshToken }),
            });

            if (!response.ok) throw new Error('Token refresh failed');

            const data = await response.json();
            set({
              session: {
                ...session,
                accessToken: data.access_token,
                expiresAt: Date.now() + data.expires_in * 1000,
              },
            });
          } catch (error) {
            get().clearSession();
            throw error;
          }
        },

        fetchProfile: async () => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/users/profile', {
              headers: {
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
            });

            if (!response.ok) throw new Error('Failed to fetch profile');

            const profile = await response.json();
            set({ user: profile, isLoading: false });

            // Fetch preferences
            const prefsResponse = await fetch('/api/v1/users/preferences', {
              headers: {
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
            });

            if (prefsResponse.ok) {
              const preferences = await prefsResponse.json();
              set({ preferences });
            }
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
          }
        },

        updateProfile: async (data) => {
          await get().updateUser(data);
        },

        changePassword: async (currentPassword, newPassword) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/change-password', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
              body: JSON.stringify({
                current_password: currentPassword,
                new_password: newPassword,
              }),
            });

            if (!response.ok) throw new Error('Failed to change password');

            set({ isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        enable2FA: async () => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/2fa/enable', {
              method: 'POST',
              headers: {
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
            });

            if (!response.ok) throw new Error('Failed to enable 2FA');

            const data = await response.json();
            set({ isLoading: false });
            return data;
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        disable2FA: async (code) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/2fa/disable', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
              body: JSON.stringify({ code }),
            });

            if (!response.ok) throw new Error('Failed to disable 2FA');

            set({ isLoading: false });
            if (get().user) {
              set({ user: { ...get().user!, twoFactorEnabled: false } });
            }
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        verify2FA: async (code) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/2fa/verify', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
              body: JSON.stringify({ code }),
            });

            if (!response.ok) throw new Error('Invalid 2FA code');

            set({ isLoading: false });
            if (get().user) {
              set({ user: { ...get().user!, twoFactorEnabled: true } });
            }
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        requestPasswordReset: async (email) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/forgot-password', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email }),
            });

            if (!response.ok) throw new Error('Failed to request password reset');

            set({ isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        resetPassword: async (token, newPassword) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/reset-password', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ token, new_password: newPassword }),
            });

            if (!response.ok) throw new Error('Failed to reset password');

            set({ isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        verifyEmail: async (token) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/verify-email', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ token }),
            });

            if (!response.ok) throw new Error('Failed to verify email');

            set({ isLoading: false });
            if (get().user) {
              set({ user: { ...get().user!, emailVerified: true } });
            }
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        resendVerificationEmail: async () => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/auth/resend-verification', {
              method: 'POST',
              headers: {
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
            });

            if (!response.ok) throw new Error('Failed to resend verification email');

            set({ isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        deleteAccount: async (password) => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/users/delete-account', {
              method: 'DELETE',
              headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
              body: JSON.stringify({ password }),
            });

            if (!response.ok) throw new Error('Failed to delete account');

            get().clearSession();
            set({ isLoading: false });
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        exportData: async () => {
          set({ isLoading: true, error: null });
          try {
            const response = await fetch('/api/v1/users/export-data', {
              headers: {
                Authorization: `Bearer ${get().session?.accessToken}`,
              },
            });

            if (!response.ok) throw new Error('Failed to export data');

            const blob = await response.blob();
            set({ isLoading: false });
            return blob;
          } catch (error) {
            set({ error: (error as Error).message, isLoading: false });
            throw error;
          }
        },

        clearError: () => set({ error: null }),
      }),
      {
        name: 'user-storage',
        storage: createJSONStorage(() => localStorage),
        partialize: (state) => ({
          user: state.user,
          preferences: state.preferences,
          session: state.session,
          isAuthenticated: state.isAuthenticated,
        }),
      }
    ),
    {
      name: 'UserStore',
    }
  )
);