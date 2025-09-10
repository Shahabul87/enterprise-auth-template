/**
 * Settings Store using Zustand
 * 
 * Manages user settings, application preferences, account configuration,
 * privacy settings, security preferences, and integration settings.
 */

import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { ApiResponse } from '@/types';

// Account settings types
export interface AccountSettings {
  email: string;
  first_name: string;
  last_name: string;
  username?: string;
  phone?: string;
  date_of_birth?: string;
  gender?: 'male' | 'female' | 'other' | 'prefer_not_to_say';
  bio?: string;
  website?: string;
  location?: string;
  company?: string;
  job_title?: string;
  avatar_url?: string;
  timezone: string;
  language: string;
  country: string;
  currency: string;
}

// Privacy settings types
export interface PrivacySettings {
  profile_visibility: 'public' | 'private' | 'friends_only';
  email_visibility: 'public' | 'private' | 'friends_only';
  phone_visibility: 'public' | 'private' | 'friends_only';
  location_visibility: 'public' | 'private' | 'friends_only';
  online_status_visibility: boolean;
  activity_status_visibility: boolean;
  last_seen_visibility: boolean;
  search_engine_indexing: boolean;
  data_processing_consent: boolean;
  marketing_communications_consent: boolean;
  analytics_consent: boolean;
  personalization_consent: boolean;
}

// Security settings types
export interface SecuritySettings {
  two_factor_enabled: boolean;
  two_factor_method: 'authenticator' | 'sms' | 'email';
  backup_codes_generated: boolean;
  login_notifications: boolean;
  suspicious_activity_alerts: boolean;
  password_expiry_reminder: boolean;
  session_timeout: number; // in minutes
  concurrent_sessions_limit: number;
  trusted_devices: TrustedDevice[];
  login_history_retention: number; // in days
  auto_logout_on_close: boolean;
  require_password_for_sensitive_actions: boolean;
}

export interface TrustedDevice {
  id: string;
  name: string;
  device_type: string;
  browser: string;
  os: string;
  ip_address: string;
  location?: string;
  last_used: string;
  trusted_at: string;
}

// Notification preferences types (extended from notification store)
export interface NotificationSettings {
  email_notifications: boolean;
  push_notifications: boolean;
  browser_notifications: boolean;
  sms_notifications: boolean;
  in_app_notifications: boolean;
  
  // Category preferences
  security_alerts: boolean;
  account_activity: boolean;
  system_updates: boolean;
  feature_announcements: boolean;
  marketing_messages: boolean;
  newsletter_subscription: boolean;
  social_interactions: boolean;
  reminders: boolean;
  
  // Timing preferences
  immediate_notifications: boolean;
  daily_digest: boolean;
  weekly_digest: boolean;
  monthly_summary: boolean;
  
  // Quiet hours
  quiet_hours_enabled: boolean;
  quiet_hours_start: string; // "22:00"
  quiet_hours_end: string; // "08:00"
  quiet_hours_timezone: string;
  
  // Advanced preferences
  notification_sound: boolean;
  notification_vibration: boolean;
  group_similar_notifications: boolean;
  max_notifications_per_day: number;
  auto_mark_read_after_days: number;
}

// Application preferences types
export interface ApplicationSettings {
  theme: 'light' | 'dark' | 'system';
  color_scheme: 'default' | 'blue' | 'green' | 'purple' | 'orange' | 'red';
  language: string;
  date_format: 'MM/dd/yyyy' | 'dd/MM/yyyy' | 'yyyy-MM-dd' | 'dd-MM-yyyy';
  time_format: '12h' | '24h';
  number_format: 'US' | 'EU' | 'UK' | 'IN';
  currency_display: 'symbol' | 'code' | 'name';
  
  // UI preferences
  compact_mode: boolean;
  high_contrast: boolean;
  reduced_motion: boolean;
  large_fonts: boolean;
  show_tooltips: boolean;
  show_keyboard_shortcuts: boolean;
  auto_save: boolean;
  confirm_dangerous_actions: boolean;
  
  // Navigation preferences
  default_page_on_login: string;
  sidebar_collapsed: boolean;
  breadcrumb_navigation: boolean;
  quick_access_enabled: boolean;
  recent_items_count: number;
}

// Integration settings types
export interface IntegrationSettings {
  google_connected: boolean;
  google_email?: string;
  google_sync_calendar: boolean;
  google_sync_contacts: boolean;
  
  microsoft_connected: boolean;
  microsoft_email?: string;
  microsoft_sync_calendar: boolean;
  microsoft_sync_contacts: boolean;
  
  github_connected: boolean;
  github_username?: string;
  github_sync_repos: boolean;
  
  slack_connected: boolean;
  slack_workspace?: string;
  slack_notifications: boolean;
  
  discord_connected: boolean;
  discord_username?: string;
  discord_notifications: boolean;
  
  // API integrations
  webhook_url?: string;
  webhook_events: string[];
  api_keys: ApiKey[];
}

export interface ApiKey {
  id: string;
  name: string;
  key: string; // Encrypted/masked in UI
  scopes: string[];
  created_at: string;
  last_used?: string;
  expires_at?: string;
  is_active: boolean;
}

// Data export/import settings
export interface DataSettings {
  export_format: 'json' | 'csv' | 'xml';
  include_metadata: boolean;
  include_deleted_items: boolean;
  data_retention_days: number;
  auto_backup_enabled: boolean;
  auto_backup_frequency: 'daily' | 'weekly' | 'monthly';
  backup_location: 'local' | 'cloud' | 'both';
}

// Settings categories
export type SettingsCategory = 
  | 'account' 
  | 'privacy' 
  | 'security' 
  | 'notifications' 
  | 'application' 
  | 'integrations' 
  | 'data';

// Settings error interface
export interface SettingsError {
  code: string;
  message: string;
  category?: SettingsCategory;
  field?: string;
  details?: Record<string, unknown>;
  timestamp: Date;
}

// Settings store state interface
export interface SettingsState {
  // Current settings by category
  account: AccountSettings | null;
  privacy: PrivacySettings | null;
  security: SecuritySettings | null;
  notifications: NotificationSettings | null;
  application: ApplicationSettings | null;
  integrations: IntegrationSettings | null;
  data: DataSettings | null;
  
  // UI state
  activeCategory: SettingsCategory;
  isLoading: boolean;
  isSaving: boolean;
  hasUnsavedChanges: boolean;
  
  // Form state
  formData: Record<SettingsCategory, Record<string, unknown>>;
  originalData: Record<SettingsCategory, Record<string, unknown>>;
  validationErrors: Record<string, string>;
  
  // Import/export state
  isExporting: boolean;
  isImporting: boolean;
  exportProgress: number;
  importProgress: number;
  
  // Error handling
  error: SettingsError | null;
  errors: SettingsError[];
  
  // Actions
  // Category navigation
  setActiveCategory: (category: SettingsCategory) => void;
  
  // Data loading
  loadAllSettings: () => Promise<void>;
  loadCategorySettings: (category: SettingsCategory) => Promise<void>;
  refreshSettings: () => Promise<void>;
  
  // Settings management
  updateCategorySettings: (category: SettingsCategory, settings: Record<string, unknown>) => Promise<boolean>;
  updateAccountSettings: (settings: Partial<AccountSettings>) => Promise<boolean>;
  updatePrivacySettings: (settings: Partial<PrivacySettings>) => Promise<boolean>;
  updateSecuritySettings: (settings: Partial<SecuritySettings>) => Promise<boolean>;
  updateNotificationSettings: (settings: Partial<NotificationSettings>) => Promise<boolean>;
  updateApplicationSettings: (settings: Partial<ApplicationSettings>) => Promise<boolean>;
  updateIntegrationSettings: (settings: Partial<IntegrationSettings>) => Promise<boolean>;
  updateDataSettings: (settings: Partial<DataSettings>) => Promise<boolean>;
  
  // Form management
  updateFormData: (category: SettingsCategory, field: string, value: unknown) => void;
  resetFormData: (category?: SettingsCategory) => void;
  saveFormData: (category: SettingsCategory) => Promise<boolean>;
  discardChanges: (category?: SettingsCategory) => void;
  
  // Validation
  validateField: (category: SettingsCategory, field: string, value: unknown) => string | null;
  validateCategory: (category: SettingsCategory) => Record<string, string>;
  clearValidationErrors: (category?: SettingsCategory) => void;
  
  // Security actions
  enable2FA: () => Promise<{ qr_code: string; backup_codes: string[] } | null>;
  disable2FA: (code: string) => Promise<boolean>;
  generateBackupCodes: () => Promise<string[] | null>;
  addTrustedDevice: (device: Omit<TrustedDevice, 'id' | 'trusted_at'>) => Promise<boolean>;
  removeTrustedDevice: (deviceId: string) => Promise<boolean>;
  revokeAllSessions: () => Promise<boolean>;
  
  // Integration actions
  connectIntegration: (provider: string, authData: Record<string, unknown>) => Promise<boolean>;
  disconnectIntegration: (provider: string) => Promise<boolean>;
  testWebhook: (url: string) => Promise<boolean>;
  createApiKey: (name: string, scopes: string[]) => Promise<ApiKey | null>;
  revokeApiKey: (keyId: string) => Promise<boolean>;
  
  // Data management
  exportSettings: (categories?: SettingsCategory[], format?: 'json' | 'csv') => Promise<string>;
  importSettings: (data: string, format: 'json' | 'csv') => Promise<boolean>;
  resetToDefaults: (category?: SettingsCategory) => Promise<boolean>;
  deleteAllData: () => Promise<boolean>;
  
  // Error management
  setError: (error: SettingsError | null) => void;
  clearError: () => void;
  addError: (error: SettingsError) => void;
  clearErrors: () => void;
  
  // Utility actions
  clearAllData: () => void;
}

// Default settings
const defaultAccountSettings: AccountSettings = {
  email: '',
  first_name: '',
  last_name: '',
  timezone: 'UTC',
  language: 'en',
  country: 'US',
  currency: 'USD',
};

const defaultPrivacySettings: PrivacySettings = {
  profile_visibility: 'public',
  email_visibility: 'private',
  phone_visibility: 'private',
  location_visibility: 'private',
  online_status_visibility: true,
  activity_status_visibility: true,
  last_seen_visibility: true,
  search_engine_indexing: true,
  data_processing_consent: false,
  marketing_communications_consent: false,
  analytics_consent: false,
  personalization_consent: false,
};

const defaultSecuritySettings: SecuritySettings = {
  two_factor_enabled: false,
  two_factor_method: 'authenticator',
  backup_codes_generated: false,
  login_notifications: true,
  suspicious_activity_alerts: true,
  password_expiry_reminder: true,
  session_timeout: 30,
  concurrent_sessions_limit: 5,
  trusted_devices: [],
  login_history_retention: 90,
  auto_logout_on_close: false,
  require_password_for_sensitive_actions: true,
};

const defaultNotificationSettings: NotificationSettings = {
  email_notifications: true,
  push_notifications: true,
  browser_notifications: false,
  sms_notifications: false,
  in_app_notifications: true,
  security_alerts: true,
  account_activity: true,
  system_updates: true,
  feature_announcements: true,
  marketing_messages: false,
  newsletter_subscription: false,
  social_interactions: true,
  reminders: true,
  immediate_notifications: true,
  daily_digest: false,
  weekly_digest: false,
  monthly_summary: false,
  quiet_hours_enabled: false,
  quiet_hours_start: '22:00',
  quiet_hours_end: '08:00',
  quiet_hours_timezone: 'UTC',
  notification_sound: true,
  notification_vibration: true,
  group_similar_notifications: true,
  max_notifications_per_day: 50,
  auto_mark_read_after_days: 30,
};

const defaultApplicationSettings: ApplicationSettings = {
  theme: 'system',
  color_scheme: 'default',
  language: 'en',
  date_format: 'MM/dd/yyyy',
  time_format: '12h',
  number_format: 'US',
  currency_display: 'symbol',
  compact_mode: false,
  high_contrast: false,
  reduced_motion: false,
  large_fonts: false,
  show_tooltips: true,
  show_keyboard_shortcuts: true,
  auto_save: true,
  confirm_dangerous_actions: true,
  default_page_on_login: '/dashboard',
  sidebar_collapsed: false,
  breadcrumb_navigation: true,
  quick_access_enabled: true,
  recent_items_count: 10,
};

const defaultIntegrationSettings: IntegrationSettings = {
  google_connected: false,
  google_sync_calendar: false,
  google_sync_contacts: false,
  microsoft_connected: false,
  microsoft_sync_calendar: false,
  microsoft_sync_contacts: false,
  github_connected: false,
  github_sync_repos: false,
  slack_connected: false,
  slack_notifications: false,
  discord_connected: false,
  discord_notifications: false,
  webhook_events: [],
  api_keys: [],
};

const defaultDataSettings: DataSettings = {
  export_format: 'json',
  include_metadata: true,
  include_deleted_items: false,
  data_retention_days: 365,
  auto_backup_enabled: false,
  auto_backup_frequency: 'weekly',
  backup_location: 'cloud',
};

// Mock API functions - replace with actual API calls
const SettingsAPI = {
  async fetchSettings(category: SettingsCategory): Promise<ApiResponse<Record<string, unknown>>> {
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // Return default settings for now
    const defaults = {
      account: defaultAccountSettings,
      privacy: defaultPrivacySettings,
      security: defaultSecuritySettings,
      notifications: defaultNotificationSettings,
      application: defaultApplicationSettings,
      integrations: defaultIntegrationSettings,
      data: defaultDataSettings,
    };
    
    return { success: true, data: defaults[category] as unknown as Record<string, unknown> };
  },
  
  async updateSettings(_category: SettingsCategory, settings: Record<string, unknown>): Promise<ApiResponse<Record<string, unknown>>> {
    await new Promise(resolve => setTimeout(resolve, 600));
    return { success: true, data: settings };
  },
  
  async enable2FA(): Promise<ApiResponse<{ qr_code: string; backup_codes: string[] }>> {
    await new Promise(resolve => setTimeout(resolve, 800));
    return { 
      success: true, 
      data: { 
        qr_code: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        backup_codes: ['12345678', '87654321', '11111111', '22222222', '33333333']
      }
    };
  },
  
  async createApiKey(name: string, scopes: string[]): Promise<ApiResponse<ApiKey>> {
    await new Promise(resolve => setTimeout(resolve, 400));
    return {
      success: true,
      data: {
        id: `api_${Date.now()}`,
        name,
        key: 'sk_test_' + Math.random().toString(36).substr(2, 32),
        scopes,
        created_at: new Date().toISOString(),
        is_active: true,
      }
    };
  },
  
  async exportData(categories: SettingsCategory[]): Promise<ApiResponse<string>> {
    await new Promise(resolve => setTimeout(resolve, 1500));
    return { success: true, data: JSON.stringify({ categories, exported_at: new Date().toISOString() }, null, 2) };
  },
};

export const useSettingsStore = create<SettingsState>()(
  devtools(
    subscribeWithSelector(
      persist(
        immer((set, get) => ({
          // Initial state
          account: null,
          privacy: null,
          security: null,
          notifications: null,
          application: null,
          integrations: null,
          data: null,
          
          activeCategory: 'account',
          isLoading: false,
          isSaving: false,
          hasUnsavedChanges: false,
          
          formData: {
            account: {},
            privacy: {},
            security: {},
            notifications: {},
            application: {},
            integrations: {},
            data: {},
          },
          originalData: {
            account: {},
            privacy: {},
            security: {},
            notifications: {},
            application: {},
            integrations: {},
            data: {},
          },
          validationErrors: {},
          
          isExporting: false,
          isImporting: false,
          exportProgress: 0,
          importProgress: 0,
          
          error: null,
          errors: [],
          
          // Category navigation
          setActiveCategory: (category: SettingsCategory) => {
            set((state) => {
              state.activeCategory = category;
            });
          },
          
          // Data loading
          loadAllSettings: async () => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const categories: SettingsCategory[] = [
                'account', 'privacy', 'security', 'notifications',
                'application', 'integrations', 'data'
              ];
              
              const promises = categories.map(async (category) => {
                const response = await SettingsAPI.fetchSettings(category);
                return { category, data: response.success ? response.data : null };
              });
              
              const results = await Promise.all(promises);
              
              set((state) => {
                results.forEach(({ category, data }) => {
                  if (data) {
                    (state as Record<string, unknown>)[category] = data;
                    state.formData[category] = { ...data };
                    state.originalData[category] = { ...data };
                  }
                });
              });
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'LOAD_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to load settings',
                timestamp: new Date(),
              };
              get().setError(settingsError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          loadCategorySettings: async (category: SettingsCategory) => {
            set((state) => {
              state.isLoading = true;
              state.error = null;
            });
            
            try {
              const response = await SettingsAPI.fetchSettings(category);
              if (response.success && response.data) {
                set((state) => {
                  (state as Record<string, unknown>)[category] = response.data || {};
                  state.formData[category] = { ...response.data };
                  state.originalData[category] = { ...response.data };
                });
              }
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'LOAD_CATEGORY_ERROR',
                message: error instanceof Error ? error.message : `Failed to load ${category} settings`,
                category,
                timestamp: new Date(),
              };
              get().setError(settingsError);
            } finally {
              set((state) => {
                state.isLoading = false;
              });
            }
          },
          
          refreshSettings: async () => {
            await get().loadAllSettings();
          },
          
          // Generic settings update function
          updateCategorySettings: async (category: SettingsCategory, settings: Record<string, unknown>) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await SettingsAPI.updateSettings(category, settings);
              if (response.success && response.data) {
                set((state) => {
                  (state as Record<string, unknown>)[category] = response.data || {};
                  state.formData[category] = { ...response.data };
                  state.originalData[category] = { ...response.data };
                  state.hasUnsavedChanges = false;
                });
                return true;
              }
              return false;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'UPDATE_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : `Failed to update ${category} settings`,
                category,
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // Specific settings update methods
          updateAccountSettings: async (settings: Partial<AccountSettings>) => {
            return await get().updateCategorySettings('account', settings);
          },
          
          updatePrivacySettings: async (settings: Partial<PrivacySettings>) => {
            return await get().updateCategorySettings('privacy', settings);
          },
          
          updateSecuritySettings: async (settings: Partial<SecuritySettings>) => {
            return await get().updateCategorySettings('security', settings);
          },
          
          updateNotificationSettings: async (settings: Partial<NotificationSettings>) => {
            return await get().updateCategorySettings('notifications', settings);
          },
          
          updateApplicationSettings: async (settings: Partial<ApplicationSettings>) => {
            return await get().updateCategorySettings('application', settings);
          },
          
          updateIntegrationSettings: async (settings: Partial<IntegrationSettings>) => {
            return await get().updateCategorySettings('integrations', settings);
          },
          
          updateDataSettings: async (settings: Partial<DataSettings>) => {
            return await get().updateCategorySettings('data', settings);
          },
          
          // Form management
          updateFormData: (category: SettingsCategory, field: string, value: unknown) => {
            set((state) => {
              state.formData[category][field] = value;
              
              // Check if data has changed
              const original = state.originalData[category];
              const current = state.formData[category];
              state.hasUnsavedChanges = JSON.stringify(original) !== JSON.stringify(current);
            });
            
            // Validate field
            const error = get().validateField(category, field, value);
            if (error) {
              set((state) => {
                state.validationErrors[`${category}.${field}`] = error;
              });
            } else {
              set((state) => {
                delete state.validationErrors[`${category}.${field}`];
              });
            }
          },
          
          resetFormData: (category?: SettingsCategory) => {
            set((state) => {
              if (category) {
                state.formData[category] = { ...state.originalData[category] };
              } else {
                Object.keys(state.formData).forEach(cat => {
                  state.formData[cat as SettingsCategory] = { ...state.originalData[cat as SettingsCategory] };
                });
              }
              state.hasUnsavedChanges = false;
            });
          },
          
          saveFormData: async (category: SettingsCategory) => {
            const formData = get().formData[category];
            return await get().updateCategorySettings(category, formData);
          },
          
          discardChanges: (category?: SettingsCategory) => {
            get().resetFormData(category);
            get().clearValidationErrors(category);
          },
          
          // Validation
          validateField: (category: SettingsCategory, field: string, value: unknown): string | null => {
            // Basic validation rules - extend as needed
            if (category === 'account') {
              if (field === 'email' && typeof value === 'string') {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(value)) {
                  return 'Invalid email format';
                }
              }
              if ((field === 'first_name' || field === 'last_name') && typeof value === 'string') {
                if (value.length < 2) {
                  return 'Name must be at least 2 characters long';
                }
              }
            }
            
            if (category === 'security') {
              if (field === 'session_timeout' && typeof value === 'number') {
                if (value < 5 || value > 480) {
                  return 'Session timeout must be between 5 and 480 minutes';
                }
              }
              if (field === 'concurrent_sessions_limit' && typeof value === 'number') {
                if (value < 1 || value > 20) {
                  return 'Concurrent sessions limit must be between 1 and 20';
                }
              }
            }
            
            return null;
          },
          
          validateCategory: (category: SettingsCategory): Record<string, string> => {
            const formData = get().formData[category];
            const errors: Record<string, string> = {};
            
            Object.entries(formData).forEach(([field, value]) => {
              const error = get().validateField(category, field, value);
              if (error) {
                errors[`${category}.${field}`] = error;
              }
            });
            
            return errors;
          },
          
          clearValidationErrors: (category?: SettingsCategory) => {
            set((state) => {
              if (category) {
                Object.keys(state.validationErrors).forEach(key => {
                  if (key.startsWith(`${category}.`)) {
                    delete state.validationErrors[key];
                  }
                });
              } else {
                state.validationErrors = {};
              }
            });
          },
          
          // Security actions
          enable2FA: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const response = await SettingsAPI.enable2FA();
              if (response.success && response.data) {
                // Update security settings
                set((state) => {
                  if (state.security) {
                    state.security.two_factor_enabled = true;
                    state.security.backup_codes_generated = true;
                  }
                });
                
                return response.data;
              }
              return null;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'ENABLE_2FA_ERROR',
                message: error instanceof Error ? error.message : 'Failed to enable 2FA',
                category: 'security',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return null;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          disable2FA: async (_code: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - log code for debugging
              // Disabling 2FA with provided code
              await new Promise(resolve => setTimeout(resolve, 600));
              
              set((state) => {
                if (state.security) {
                  state.security.two_factor_enabled = false;
                  state.security.backup_codes_generated = false;
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'DISABLE_2FA_ERROR',
                message: error instanceof Error ? error.message : 'Failed to disable 2FA',
                category: 'security',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          generateBackupCodes: async () => {
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 400));
              return ['12345678', '87654321', '11111111', '22222222', '33333333'];
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'GENERATE_BACKUP_CODES_ERROR',
                message: error instanceof Error ? error.message : 'Failed to generate backup codes',
                category: 'security',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return null;
            }
          },
          
          addTrustedDevice: async (device: Omit<TrustedDevice, 'id' | 'trusted_at'>) => {
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 500));
              
              const newDevice: TrustedDevice = {
                ...device,
                id: `device_${Date.now()}`,
                trusted_at: new Date().toISOString(),
              };
              
              set((state) => {
                if (state.security) {
                  state.security.trusted_devices.push(newDevice);
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'ADD_TRUSTED_DEVICE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to add trusted device',
                category: 'security',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            }
          },
          
          removeTrustedDevice: async (deviceId: string) => {
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 300));
              
              set((state) => {
                if (state.security) {
                  state.security.trusted_devices = state.security.trusted_devices.filter(
                    device => device.id !== deviceId
                  );
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'REMOVE_TRUSTED_DEVICE_ERROR',
                message: error instanceof Error ? error.message : 'Failed to remove trusted device',
                category: 'security',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            }
          },
          
          revokeAllSessions: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 800));
              
              // Clear trusted devices
              set((state) => {
                if (state.security) {
                  state.security.trusted_devices = [];
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'REVOKE_SESSIONS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to revoke all sessions',
                category: 'security',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // Integration actions
          connectIntegration: async (provider: string, authData: Record<string, unknown>) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 1000));
              
              set((state) => {
                if (state.integrations) {
                  (state.integrations as Record<string, unknown>)[`${provider}_connected`] = true;
                  if (authData['email']) {
                    (state.integrations as Record<string, unknown>)[`${provider}_email`] = authData['email'];
                  }
                  if (authData['username']) {
                    (state.integrations as Record<string, unknown>)[`${provider}_username`] = authData['username'];
                  }
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'CONNECT_INTEGRATION_ERROR',
                message: error instanceof Error ? error.message : `Failed to connect ${provider}`,
                category: 'integrations',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          disconnectIntegration: async (provider: string) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 500));
              
              set((state) => {
                if (state.integrations) {
                  const integrations = state.integrations as Record<string, unknown>;
                  integrations[`${provider}_connected`] = false;
                  delete integrations[`${provider}_email`];
                  delete integrations[`${provider}_username`];
                  delete integrations[`${provider}_workspace`];
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'DISCONNECT_INTEGRATION_ERROR',
                message: error instanceof Error ? error.message : `Failed to disconnect ${provider}`,
                category: 'integrations',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          testWebhook: async (_url: string) => {
            try {
              // Mock implementation - log URL for debugging
              // Testing webhook URL
              await new Promise(resolve => setTimeout(resolve, 1000));
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'TEST_WEBHOOK_ERROR',
                message: error instanceof Error ? error.message : 'Failed to test webhook',
                category: 'integrations',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            }
          },
          
          createApiKey: async (name: string, scopes: string[]) => {
            try {
              const response = await SettingsAPI.createApiKey(name, scopes);
              if (response.success && response.data) {
                set((state) => {
                  if (state.integrations) {
                    state.integrations.api_keys.push(response.data!);
                  }
                });
                return response.data;
              }
              return null;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'CREATE_API_KEY_ERROR',
                message: error instanceof Error ? error.message : 'Failed to create API key',
                category: 'integrations',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return null;
            }
          },
          
          revokeApiKey: async (keyId: string) => {
            try {
              // Mock implementation
              await new Promise(resolve => setTimeout(resolve, 400));
              
              set((state) => {
                if (state.integrations) {
                  state.integrations.api_keys = state.integrations.api_keys.filter(
                    key => key.id !== keyId
                  );
                }
              });
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'REVOKE_API_KEY_ERROR',
                message: error instanceof Error ? error.message : 'Failed to revoke API key',
                category: 'integrations',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            }
          },
          
          // Data management
          exportSettings: async (categories?: SettingsCategory[], _format = 'json') => {
            set((state) => {
              state.isExporting = true;
              state.exportProgress = 0;
              state.error = null;
            });
            
            try {
              const categoriesToExport = categories || [
                'account', 'privacy', 'security', 'notifications',
                'application', 'integrations', 'data'
              ];
              
              // Exporting settings in specified format
              
              // Simulate progress
              for (let i = 0; i <= 100; i += 20) {
                set((state) => {
                  state.exportProgress = i;
                });
                await new Promise(resolve => setTimeout(resolve, 100));
              }
              
              const response = await SettingsAPI.exportData(categoriesToExport);
              if (response.success && response.data) {
                return response.data;
              }
              
              return '';
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'EXPORT_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to export settings',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return '';
            } finally {
              set((state) => {
                state.isExporting = false;
                state.exportProgress = 0;
              });
            }
          },
          
          importSettings: async (_data: string, format: 'json' | 'csv') => {
            set((state) => {
              state.isImporting = true;
              state.importProgress = 0;
              state.error = null;
            });
            
            try {
              // Simulate progress
              for (let i = 0; i <= 100; i += 25) {
                set((state) => {
                  state.importProgress = i;
                });
                await new Promise(resolve => setTimeout(resolve, 200));
              }
              
              // Mock implementation - parse and validate data
              if (format === 'json') {
                // const parsed = JSON.parse(_data);
                // Importing parsed settings
                // Validate and import settings - future implementation
              }
              
              // Reload settings after import
              await get().loadAllSettings();
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'IMPORT_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to import settings',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isImporting = false;
                state.importProgress = 0;
              });
            }
          },
          
          resetToDefaults: async (category?: SettingsCategory) => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              const defaults = {
                account: defaultAccountSettings,
                privacy: defaultPrivacySettings,
                security: defaultSecuritySettings,
                notifications: defaultNotificationSettings,
                application: defaultApplicationSettings,
                integrations: defaultIntegrationSettings,
                data: defaultDataSettings,
              };
              
              if (category) {
                const success = await get().updateCategorySettings(category, defaults[category] as unknown as Record<string, unknown>);
                return success;
              } else {
                // Reset all categories
                const promises = Object.keys(defaults).map(cat => 
                  get().updateCategorySettings(cat as SettingsCategory, defaults[cat as SettingsCategory] as unknown as Record<string, unknown>)
                );
                
                const results = await Promise.all(promises);
                return results.every((result: boolean) => result);
              }
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'RESET_SETTINGS_ERROR',
                message: error instanceof Error ? error.message : 'Failed to reset settings to defaults',
                ...(category ? { category } : {}),
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          deleteAllData: async () => {
            set((state) => {
              state.isSaving = true;
              state.error = null;
            });
            
            try {
              // Mock implementation - this would be a dangerous operation
              await new Promise(resolve => setTimeout(resolve, 2000));
              
              // Clear all settings
              get().clearAllData();
              
              return true;
            } catch (error) {
              const settingsError: SettingsError = {
                code: 'DELETE_DATA_ERROR',
                message: error instanceof Error ? error.message : 'Failed to delete all data',
                timestamp: new Date(),
              };
              get().setError(settingsError);
              return false;
            } finally {
              set((state) => {
                state.isSaving = false;
              });
            }
          },
          
          // Error management
          setError: (error: SettingsError | null) => {
            set((state) => {
              state.error = error;
              if (error) {
                state.errors.push(error);
                // Keep only last 10 errors
                if (state.errors.length > 10) {
                  state.errors = state.errors.slice(-10);
                }
              }
            });
          },
          
          clearError: () => {
            set((state) => {
              state.error = null;
            });
          },
          
          addError: (error: SettingsError) => {
            set((state) => {
              state.errors.push(error);
              // Keep only last 10 errors
              if (state.errors.length > 10) {
                state.errors = state.errors.slice(-10);
              }
            });
          },
          
          clearErrors: () => {
            set((state) => {
              state.errors = [];
            });
          },
          
          // Utility actions
          clearAllData: () => {
            set((state) => {
              state.account = null;
              state.privacy = null;
              state.security = null;
              state.notifications = null;
              state.application = null;
              state.integrations = null;
              state.data = null;
              
              state.formData = {
                account: {},
                privacy: {},
                security: {},
                notifications: {},
                application: {},
                integrations: {},
                data: {},
              };
              state.originalData = {
                account: {},
                privacy: {},
                security: {},
                notifications: {},
                application: {},
                integrations: {},
                data: {},
              };
              
              state.hasUnsavedChanges = false;
              state.validationErrors = {};
              state.error = null;
              state.errors = [];
            });
          },
        })),
        {
          name: 'settings-storage',
          // Persist only safe preferences data
          partialize: (state) => ({
            activeCategory: state.activeCategory,
            application: state.application,
            // Don't persist sensitive data like API keys, security settings, etc.
          }),
        }
      )
    ),
    {
      name: 'SettingsStore',
    }
  )
);

// Selector hooks for common use cases
export const useSettingsCategory = (category: SettingsCategory) => 
  useSettingsStore((state) => state[category]);
export const useSettingsLoading = () => useSettingsStore((state) => state.isLoading);
export const useSettingsSaving = () => useSettingsStore((state) => state.isSaving);
export const useSettingsError = () => useSettingsStore((state) => state.error);
export const useSettingsValidation = () => useSettingsStore((state) => state.validationErrors);
export const useSettingsUnsaved = () => useSettingsStore((state) => state.hasUnsavedChanges);

// Helper hooks for common settings patterns
export const useSettings = useSettingsStore;

export function useSettingsForm(category: SettingsCategory) {
  const store = useSettingsStore();
  
  return {
    data: store.formData[category],
    originalData: store.originalData[category],
    errors: Object.entries(store.validationErrors)
      .filter(([key]) => key.startsWith(`${category}.`))
      .reduce((acc, [key, value]) => {
        acc[key.replace(`${category}.`, '')] = value;
        return acc;
      }, {} as Record<string, string>),
    hasChanges: store.hasUnsavedChanges,
    isLoading: store.isLoading,
    isSaving: store.isSaving,
    
    updateField: (field: string, value: unknown) => store.updateFormData(category, field, value),
    reset: () => store.resetFormData(category),
    save: () => store.saveFormData(category),
    discard: () => store.discardChanges(category),
    validate: () => store.validateCategory(category),
  };
}

export function useAccountSettings() {
  const store = useSettingsStore();
  
  return {
    settings: store.account,
    isLoading: store.isLoading,
    isSaving: store.isSaving,
    error: store.error,
    
    load: () => store.loadCategorySettings('account'),
    update: store.updateAccountSettings,
    form: useSettingsForm('account'),
  };
}

export function useSecuritySettings() {
  const store = useSettingsStore();
  
  return {
    settings: store.security,
    isLoading: store.isLoading,
    isSaving: store.isSaving,
    error: store.error,
    
    load: () => store.loadCategorySettings('security'),
    update: store.updateSecuritySettings,
    enable2FA: store.enable2FA,
    disable2FA: store.disable2FA,
    generateBackupCodes: store.generateBackupCodes,
    addTrustedDevice: store.addTrustedDevice,
    removeTrustedDevice: store.removeTrustedDevice,
    revokeAllSessions: store.revokeAllSessions,
    form: useSettingsForm('security'),
  };
}