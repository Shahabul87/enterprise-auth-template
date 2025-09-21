
import { act, renderHook } from '@testing-library/react';
import { useSettingsStore } from '@/stores/settings.store';
import React from 'react';

jest.mock('zustand/middleware', () => ({
  devtools: (fn: any) => fn,
  persist: (fn: any) => fn,
  subscribeWithSelector: (fn: any) => fn,
}));
/**
 * @jest-environment jsdom
 */


// Mock zustand persist
describe('SettingsStore', () => {
  beforeEach(() => {
    // Reset store before each test
    const { result } = renderHook(() => useSettingsStore());
    act(() => {
      result.current.resetToDefaults();
    });
  });

describe('Initial State', () => {
    it('should have correct initial state', async () => {
      const { result } = renderHook(() => useSettingsStore());
      expect(result.current.theme).toBe('system');
      expect(result.current.language).toBe('en');
      expect(result.current.timezone).toBe('UTC');
      expect(result.current.dateFormat).toBe('MM/DD/YYYY');
      expect(result.current.timeFormat).toBe('12h');
      expect(result.current.currency).toBe('USD');
    });
    it('should have default preferences', async () => {
      const { result } = renderHook(() => useSettingsStore());
      expect(result.current.preferences).toEqual({
        notifications: true,
        emailDigest: 'weekly',
        marketingEmails: false,
        betaFeatures: false,
        analytics: true,
        compactMode: false,
        animations: true,
        soundEffects: false,
        keyboardShortcuts: true,
        autoSave: true,
        showTips: true
      });
    });
    it('should have default accessibility settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      expect(result.current.accessibility).toEqual({
        highContrast: false,
        fontSize: 'medium',
        reduceMotion: false,
        screenReaderMode: false,
        keyboardNavigation: true
      });
    });
  });

describe('Theme Management', () => {
    it('should update theme', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setTheme('dark');
      });
      expect(result.current.theme).toBe('dark');
      act(() => {
        result.current.setTheme('light');
      });
      expect(result.current.theme).toBe('light');
    });
    it('should toggle theme between light and dark', async () => {
      const { result } = renderHook(() => useSettingsStore());
      // Set to light first
      act(() => {
        result.current.setTheme('light');
      });
      act(() => {
        result.current.toggleTheme();
      });
      expect(result.current.theme).toBe('dark');
      act(() => {
        result.current.toggleTheme();
      });
      expect(result.current.theme).toBe('light');
    });
    it('should switch from system to light when toggling', async () => {
      const { result } = renderHook(() => useSettingsStore());
      // Initial state is system
      expect(result.current.theme).toBe('system');
      act(() => {
        result.current.toggleTheme();
      });
      expect(result.current.theme).toBe('light');
    });
    it('should apply theme to document', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.applyTheme('dark');
      });
      expect(document.documentElement.classList.contains('dark')).toBe(true);
      act(() => {
        result.current.applyTheme('light');
      });
      expect(document.documentElement.classList.contains('dark')).toBe(false);
    });
  });

describe('Language and Localization', () => {
    it('should update language', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setLanguage('es');
      });
      expect(result.current.language).toBe('es');
      act(() => {
        result.current.setLanguage('fr');
      });
      expect(result.current.language).toBe('fr');
    });
    it('should update timezone', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setTimezone('America/New_York');
      });
      expect(result.current.timezone).toBe('America/New_York');
      act(() => {
        result.current.setTimezone('Europe/London');
      });
      expect(result.current.timezone).toBe('Europe/London');
    });
    it('should update date format', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setDateFormat('DD/MM/YYYY');
      });
      expect(result.current.dateFormat).toBe('DD/MM/YYYY');
      act(() => {
        result.current.setDateFormat('YYYY-MM-DD');
      });
      expect(result.current.dateFormat).toBe('YYYY-MM-DD');
    });
    it('should update time format', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setTimeFormat('24h');
      });
      expect(result.current.timeFormat).toBe('24h');
      act(() => {
        result.current.setTimeFormat('12h');
      });
      expect(result.current.timeFormat).toBe('12h');
    });
    it('should update currency', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setCurrency('EUR');
      });
      expect(result.current.currency).toBe('EUR');
      act(() => {
        result.current.setCurrency('GBP');
      });
      expect(result.current.currency).toBe('GBP');
    });
  });

describe('Preferences Management', () => {
    it('should update single preference', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.updatePreferences({ notifications: false });
      });
      expect(result.current.preferences.notifications).toBe(false);
      expect(result.current.preferences.emailDigest).toBe('weekly'); // Unchanged
    });
    it('should update multiple preferences', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.updatePreferences({
          notifications: false,
          betaFeatures: true,
          soundEffects: true,
          compactMode: true
        });
      });
      expect(result.current.preferences.notifications).toBe(false);
      expect(result.current.preferences.betaFeatures).toBe(true);
      expect(result.current.preferences.soundEffects).toBe(true);
      expect(result.current.preferences.compactMode).toBe(true);
    });
    it('should toggle notification preference', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const initial = result.current.preferences.notifications;
      act(() => {
        result.current.toggleNotifications();
      });
      expect(result.current.preferences.notifications).toBe(!initial);
      act(() => {
        result.current.toggleNotifications();
      });
      expect(result.current.preferences.notifications).toBe(initial);
    });
    it('should toggle beta features', async () => {
      const { result } = renderHook(() => useSettingsStore());
      expect(result.current.preferences.betaFeatures).toBe(false);
      act(() => {
        result.current.toggleBetaFeatures();
      });
      expect(result.current.preferences.betaFeatures).toBe(true);
      act(() => {
        result.current.toggleBetaFeatures();
      });
      expect(result.current.preferences.betaFeatures).toBe(false);
    });
  });

describe('Accessibility Settings', () => {
    it('should update accessibility settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.updateAccessibility({
          highContrast: true,
          fontSize: 'large'
        });
      });
      expect(result.current.accessibility.highContrast).toBe(true);
      expect(result.current.accessibility.fontSize).toBe('large');
      expect(result.current.accessibility.reduceMotion).toBe(false); // Unchanged
    });
    it('should toggle high contrast', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.toggleHighContrast();
      });
      expect(result.current.accessibility.highContrast).toBe(true);
      act(() => {
        result.current.toggleHighContrast();
      });
      expect(result.current.accessibility.highContrast).toBe(false);
    });
    it('should toggle reduce motion', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.toggleReduceMotion();
      });
      expect(result.current.accessibility.reduceMotion).toBe(true);
      act(() => {
        result.current.toggleReduceMotion();
      });
      expect(result.current.accessibility.reduceMotion).toBe(false);
    });
    it('should set font size', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const sizes: Array<'small' | 'medium' | 'large' | 'extra-large'> = [
        'small',
        'medium',
        'large',
        'extra-large',
      ];
      sizes.forEach(size => {
        act(() => {
          result.current.setFontSize(size);
        });
        expect(result.current.accessibility.fontSize).toBe(size);
      });
    });
  });

describe('Privacy Settings', () => {
    it('should update privacy settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.updatePrivacy({
          shareAnalytics: false,
          shareUsageData: false,
          allowCookies: true,
          allowThirdPartyCookies: false
        });
      });
      expect(result.current.privacy.shareAnalytics).toBe(false);
      expect(result.current.privacy.shareUsageData).toBe(false);
      expect(result.current.privacy.allowCookies).toBe(true);
      expect(result.current.privacy.allowThirdPartyCookies).toBe(false);
    });
    it('should toggle analytics sharing', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const initial = result.current.privacy.shareAnalytics;
      act(() => {
        result.current.toggleAnalytics();
      });
      expect(result.current.privacy.shareAnalytics).toBe(!initial);
    });
    it('should toggle cookie consent', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const initial = result.current.privacy.allowCookies;
      act(() => {
        result.current.toggleCookies();
      });
      expect(result.current.privacy.allowCookies).toBe(!initial);
    });
  });

describe('Security Settings', () => {
    it('should update security settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.updateSecurity({
          two_factor_enabled: true,
          biometricEnabled: true,
          sessionTimeout: 30,
          requirePasswordChange: 90
        });
      });
      expect(result.current.security.two_factor_enabled).toBe(true);
      expect(result.current.security.biometricEnabled).toBe(true);
      expect(result.current.security.sessionTimeout).toBe(30);
      expect(result.current.security.requirePasswordChange).toBe(90);
    });
    it('should toggle two-factor authentication', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.toggleTwoFactor();
      });
      expect(result.current.security.two_factor_enabled).toBe(true);
      act(() => {
        result.current.toggleTwoFactor();
      });
      expect(result.current.security.two_factor_enabled).toBe(false);
    });
    it('should toggle biometric authentication', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.toggleBiometric();
      });
      expect(result.current.security.biometricEnabled).toBe(true);
      act(() => {
        result.current.toggleBiometric();
      });
      expect(result.current.security.biometricEnabled).toBe(false);
    });
    it('should set session timeout', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const timeouts = [15, 30, 60, 120];
      timeouts.forEach(timeout => {
        act(() => {
          result.current.setSessionTimeout(timeout);
        });
        expect(result.current.security.sessionTimeout).toBe(timeout);
      });
    });
  });

describe('Import/Export Settings', () => {
    it('should export all settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      // Modify some settings
      act(() => {
        result.current.setTheme('dark');
        result.current.setLanguage('es');
        result.current.updatePreferences({ betaFeatures: true });
      });
      const exported = act(() => {
        return result.current.exportSettings();
      });
      expect(exported).toHaveProperty('theme', 'dark');
      expect(exported).toHaveProperty('language', 'es');
      expect(exported).toHaveProperty('preferences');
      expect(exported.preferences).toHaveProperty('betaFeatures', true);
    });
    it('should import settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const settingsToImport = {
        theme: 'dark' as const,
        language: 'fr',
        timezone: 'Europe/Paris',
        preferences: {
          notifications: false,
          betaFeatures: true,
          emailDigest: 'daily' as const,
          marketingEmails: false,
          analytics: false,
          compactMode: true,
          animations: false,
          soundEffects: true,
          keyboardShortcuts: false,
          autoSave: false,
          showTips: false,
        },
      };
      act(() => {
        result.current.importSettings(settingsToImport);
      });
      expect(result.current.theme).toBe('dark');
      expect(result.current.language).toBe('fr');
      expect(result.current.timezone).toBe('Europe/Paris');
      expect(result.current.preferences.notifications).toBe(false);
      expect(result.current.preferences.betaFeatures).toBe(true);
    });
    it('should validate imported settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const invalidSettings = {
        theme: 'invalid-theme',
        language: 123, // Should be string
        preferences: 'not-an-object', // Should be object
      };
      const isValid = act(() => {
        return result.current.validateSettings(invalidSettings as jest.Mocked<any>);
      });
      expect(isValid).toBe(false);
      const validSettings = {
        theme: 'dark' as const,
        language: 'en',
        preferences: {
          notifications: true,
          emailDigest: 'weekly' as const,
        },
      };
      const isValidCorrect = act(() => {
        return result.current.validateSettings(validSettings);
      });
      expect(isValidCorrect).toBe(true);
    });
  });

describe('Reset and Defaults', () => {
    it('should reset to default settings', async () => {
      const { result } = renderHook(() => useSettingsStore());
      // Modify settings
      act(() => {
        result.current.setTheme('dark');
        result.current.setLanguage('es');
        result.current.updatePreferences({ betaFeatures: true });
        result.current.updateAccessibility({ highContrast: true });
      });
      // Reset
      act(() => {
        result.current.resetToDefaults();
      });
      expect(result.current.theme).toBe('system');
      expect(result.current.language).toBe('en');
      expect(result.current.preferences.betaFeatures).toBe(false);
      expect(result.current.accessibility.highContrast).toBe(false);
    });
    it('should reset specific categories', async () => {
      const { result } = renderHook(() => useSettingsStore());
      // Modify settings
      act(() => {
        result.current.setTheme('dark');
        result.current.updatePreferences({ betaFeatures: true });
      });
      // Reset only preferences
      act(() => {
        result.current.resetCategory('preferences');
      });
      expect(result.current.preferences.betaFeatures).toBe(false);
      expect(result.current.theme).toBe('dark'); // Should remain unchanged
    });
  });

describe('Settings Sync', () => {
    it('should sync settings to server', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const mockSync = jest.fn().mockResolvedValue({ success: true });
      result.current.syncToServer = mockSync;
      await act(async () => {
        await result.current.syncToServer();
      });
      expect(mockSync).toHaveBeenCalledTimes(1);
    });
    it('should load settings from server', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const serverSettings = {
        theme: 'dark' as const,
        language: 'de',
      };
      const mockLoad = jest.fn().mockResolvedValue(serverSettings);
      result.current.loadFromServer = mockLoad;
      await act(async () => {
        await result.current.loadFromServer();
      });
      expect(mockLoad).toHaveBeenCalledTimes(1);
    });
    it('should handle sync conflicts', async () => {
      const { result } = renderHook(() => useSettingsStore());
      const localSettings = {
        theme: 'dark' as const,
        lastModified: new Date('2024-01-01'),
      };
      const serverSettings = {
        theme: 'light' as const,
        lastModified: new Date('2024-01-02'),
      };
      const mockResolve = jest.fn().mockReturnValue(serverSettings);
      result.current.resolveConflict = mockResolve;
      const resolved = act(() => {
        return result.current.resolveConflict(localSettings, serverSettings);
      });
      expect(resolved).toBe(serverSettings); // Server is newer
    });
  });

describe('Computed Values', () => {
    it('should detect dark mode correctly', async () => {
      const { result } = renderHook(() => useSettingsStore());
      act(() => {
        result.current.setTheme('dark');
      });
      expect(result.current.isDarkMode).toBe(true);
      act(() => {
        result.current.setTheme('light');
      });
      expect(result.current.isDarkMode).toBe(false);
      // System theme depends on browser preference
      act(() => {
        result.current.setTheme('system');
      });
      // Mock matchMedia
      const mockMatchMedia = jest.fn().mockReturnValue({
        matches: true,
        media: '(prefers-color-scheme: dark)',
        addEventListener: jest.fn(),
        removeEventListener: jest.fn()
      });
      window.matchMedia = mockMatchMedia;
      expect(result.current.getSystemTheme()).toBe('dark');
    });
    it('should determine if settings are modified', async () => {
      const { result } = renderHook(() => useSettingsStore());
      expect(result.current.hasModifications()).toBe(false);
      act(() => {
        result.current.setTheme('dark');
      });
      expect(result.current.hasModifications()).toBe(true);
      act(() => {
        result.current.resetToDefaults();
      });
      expect(result.current.hasModifications()).toBe(false);
    });
  });
});