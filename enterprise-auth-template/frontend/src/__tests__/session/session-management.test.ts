import { useAuthStore } from '@/stores/auth.store';
import { SessionManager } from '@/lib/session-manager';
import { EventEmitter } from 'events';
import React from 'react';
jest.mock('@/stores/auth.store');
jest.mock('@/lib/session-manager', () => ({
  SessionManager: jest.fn().mockImplementation(() => ({
    startSession: jest.fn(),
    endSession: jest.fn(),
    refreshSession: jest.fn(),
    getTimeRemaining: jest.fn().mockReturnValue(3600),
    isExpired: jest.fn().mockReturnValue(false),
    onWarning: jest.fn(),
    onExpired: jest.fn(),
  }))
}));
jest.mock('@/stores/auth.store', () => ({
  useAuthStore: jest.fn(() => ({
    user: null,
    tokens: null,
    accessToken: null,
    isAuthenticated: false,
    isLoading: false,
    isInitialized: true,
    permissions: [],
    roles: [],
    session: null,
    error: null,
    authErrors: [],
    isEmailVerified: false,
    is2FAEnabled: false,
    requiresPasswordChange: false,
    isTokenValid: () => true,
    initialize: async () => {},
    login: async () => ({ success: true, data: { user: null, tokens: null } }),
    register: async () => ({ success: true, data: { message: 'Success' } }),
    logout: async () => {},
    refreshToken: async () => true,
    refreshAccessToken: async () => null,
    updateUser: () => {},
    hasPermission: () => false,
    hasRole: () => false,
    hasAnyRole: () => false,
    hasAllPermissions: () => false,
    setError: () => {},
    clearError: () => {},
    addAuthError: () => {},
    clearAuthErrors: () => {},
    updateSession: () => {},
    checkSession: async () => true,
    extendSession: async () => {},
    fetchUserData: async () => {},
    fetchPermissions: async () => {},
    verifyEmail: async () => ({ success: true, data: { message: 'Success' } }),
    resendVerification: async () => ({ success: true, data: { message: 'Success' } }),
    changePassword: async () => ({ success: true, data: { message: 'Success' } }),
    requestPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    confirmPasswordReset: async () => ({ success: true, data: { message: 'Success' } }),
    setup2FA: async () => ({ success: true, data: { qr_code: '', backup_codes: [] } }),
    verify2FA: async () => ({ success: true, data: { enabled: true, message: 'Success' } }),
    disable2FA: async () => ({ success: true, data: { enabled: false, message: 'Success' } }),
    clearAuth: () => {},
    setupTokenRefresh: () => {},
    clearAuthData: () => {},
    setAuth: () => {},
    user: null,
    isAuthenticated: false,
    isLoading: false,
    permissions: [],
    hasPermission: jest.fn(() => false),
    hasRole: jest.fn(() => false),
  useGuestOnly: jest.fn(() => ({
    isLoading: false,
  }))}}))));,
})),
// Mock auth store
// Mock session manager
/**
 * Session Management Tests
 * Comprehensive tests for session handling, timeout, refresh, and multi-tab sync
 */
// Session types
interface Session {
  id: string;
  user_id: string;
  token: string;
  refreshToken: string;
  expiresAt: Date;
  lastActivity: Date;
  is_active: boolean;
interface SessionConfig {
  maxIdleTime: number; // milliseconds
  sessionDuration: number; // milliseconds
  warningTime: number; // milliseconds before expiry to show warning
  refreshThreshold: number; // milliseconds before expiry to auto-refresh
// Session Manager Implementation
class SessionManager extends EventEmitter {
  private session: Session | null = null;
  private config: SessionConfig;
  private idleTimer: NodeJS.Timeout | null = null;
  private expiryTimer: NodeJS.Timeout | null = null;
  private warningTimer: NodeJS.Timeout | null = null;
  private refreshTimer: NodeJS.Timeout | null = null;
  private activityListeners: Array<() => void> = [];
  private storage: Storage;
  constructor(config: SessionConfig, storage: Storage = localStorage) {
    super();
    this.config = config;
    this.storage = storage;
    this.initializeFromStorage();
    this.setupActivityListeners();
    this.setupStorageSync();
  private initializeFromStorage(): void {
    const stored = this.storage.getItem('session');
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        this.session = {
          ...parsed,
          expiresAt: new Date(parsed.expiresAt),
          lastActivity: new Date(parsed.lastActivity),
        };
        this.scheduleTimers();
      } catch {
        this.storage.removeItem('session');
      }
    }
  private setupActivityListeners(): void {
    const events = ['mousedown', 'keydown', 'scroll', 'touchstart'];
    const activityHandler = () => {
      this.updateActivity();
    };
    events.forEach(event => {
      const listener = () => activityHandler();
      document.addEventListener(event, listener);
      this.activityListeners.push(() => document.removeEventListener(event, listener));
    });
  private setupStorageSync(): void {
    // Listen for storage changes (other tabs)
    window.addEventListener('storage', (e) => {
      if (e.key === 'session') {
        if (e.newValue === null) {
          // Session deleted in another tab
          this.handleRemoteLogout();
        } else {
          // Session updated in another tab
          this.initializeFromStorage();
          this.emit('session-synced');
        }
      }
    });
  private updateActivity(): void {
    if (!this.session || !this.session.is_active) return;
    this.session.lastActivity = new Date();
    this.saveToStorage();
    this.resetIdleTimer();
    this.emit('activity');
  private resetIdleTimer(): void {
    if (this.idleTimer) {
      clearTimeout(this.idleTimer);
    }
    this.idleTimer = setTimeout(() => {
      this.handleIdleTimeout();
    }, this.config.maxIdleTime);
  private scheduleTimers(): void {
    if (!this.session) return;
    const now = Date.now();
    const expiryTime = this.session.expiresAt.getTime();
    const timeToExpiry = expiryTime - now;
    // Clear existing timers
    this.clearTimers();
    if (timeToExpiry > 0) {
      // Schedule expiry
      this.expiryTimer = setTimeout(() => {
        this.handleSessionExpiry();
      }, timeToExpiry);
      // Schedule warning
      const timeToWarning = timeToExpiry - this.config.warningTime;
      if (timeToWarning > 0) {
        this.warningTimer = setTimeout(() => {
          this.emit('session-warning', Math.floor(this.config.warningTime / 1000));
        }, timeToWarning);
      }
      // Schedule refresh
      const timeToRefresh = timeToExpiry - this.config.refreshThreshold;
      if (timeToRefresh > 0) {
        this.refreshTimer = setTimeout(() => {
          this.refreshSession();
        }, timeToRefresh);
      }
      // Reset idle timer
      this.resetIdleTimer();
    } else {
      this.handleSessionExpiry();
    }
  private clearTimers(): void {
    if (this.idleTimer) clearTimeout(this.idleTimer);
    if (this.expiryTimer) clearTimeout(this.expiryTimer);
    if (this.warningTimer) clearTimeout(this.warningTimer);
    if (this.refreshTimer) clearTimeout(this.refreshTimer);
  private saveToStorage(): void {
    if (this.session) {
      this.storage.setItem('session', JSON.stringify(this.session));
    }
  private handleIdleTimeout(): void {
    this.emit('idle-timeout');
    this.endSession('idle_timeout');
  private handleSessionExpiry(): void {
    this.emit('session-expired');
    this.endSession('expired');
  private handleRemoteLogout(): void {
    this.session = null;
    this.clearTimers();
    this.emit('remote-logout');
  async createSession(user_id: string, token: string, refreshToken: string): Promise<Session> {
    const session: Session = {
      id: this.generateSessionId(),
      user_id,
      token,
      refreshToken,
      expiresAt: new Date(Date.now() + this.config.sessionDuration),
      lastActivity: new Date(),
      is_active: true,
    };
    this.session = session;
    this.saveToStorage();
    this.scheduleTimers();
    this.emit('session-created', session);
    return session;
  async refreshSession(): Promise<Session | null> {
    if (!this.session) return null;
    try {
      // Simulate API call to refresh token
      const newToken = await this.mockRefreshToken(this.session.refreshToken);
      if (newToken) {
        this.session.token = newToken;
        this.session.expiresAt = new Date(Date.now() + this.config.sessionDuration);
        this.session.lastActivity = new Date();
        this.saveToStorage();
        this.scheduleTimers();
        this.emit('session-refreshed', this.session);
        return this.session;
      }
    } catch (error) {
      this.emit('refresh-failed', error);
    }
    return null;
  endSession(reason: string): void {
    if (!this.session) return;
    this.session.is_active = false;
    this.storage.removeItem('session');
    this.clearTimers();
    this.emit('session-ended', { session: this.session, reason });
    this.session = null;
  extendSession(minutes: number): void {
    if (!this.session || !this.session.is_active) return;
    const extension = minutes * 60 * 1000;
    this.session.expiresAt = new Date(this.session.expiresAt.getTime() + extension);
    this.saveToStorage();
    this.scheduleTimers();
    this.emit('session-extended', { minutes, newExpiry: this.session.expiresAt });
  getSession(): Session | null {
    return this.session;
  isSessionValid(): boolean {
    return !!(
      this.session &&
      this.session.is_active &&
      this.session.expiresAt.getTime() > Date.now()
    );
  getTimeRemaining(): number {
    if (!this.session) return 0;
    const remaining = this.session.expiresAt.getTime() - Date.now();
    return Math.max(0, remaining);
  private generateSessionId(): string {
    return `sess_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  private async mockRefreshToken(refreshToken: string): Promise<string | null> {
    // Simulate API call
    return new Promise((resolve) => {
      setTimeout(() => {
        if (refreshToken.startsWith('valid_')) {
          resolve(`new_token_${Date.now()}`);
        } else {
          resolve(null);
        }
      }, 100);
    });
  destroy(): void {
    this.clearTimers();
    this.activityListeners.forEach(remove => remove());
    this.removeAllListeners();
// Mock auth store
}}}}}}}}}}}}}}}}}}}}}}}}}})));
describe('Session Management', () => {
  let sessionManager: SessionManager;
  let mockStorage: Storage;
  beforeEach(() => {
    // Mock localStorage
    mockStorage = {
      getItem: jest.fn(),
      setItem: jest.fn(),
      removeItem: jest.fn(),
      clear: jest.fn(),
      key: jest.fn(),
      length: 0,
    };
    jest.useFakeTimers();
  });
  afterEach(() => {
    if (sessionManager) {
      sessionManager.destroy();
    }
    jest.clearAllTimers();
    jest.useRealTimers();
  });

describe('Session Creation', () => {
    it('should create a new session', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 15 * 60 * 1000, // 15 minutes
          sessionDuration: 60 * 60 * 1000, // 1 hour
          warningTime: 5 * 60 * 1000, // 5 minutes
          refreshThreshold: 10 * 60 * 1000, // 10 minutes
        },
        mockStorage
      );
      const sessionCreatedSpy = jest.fn();
      sessionManager.on('session-created', sessionCreatedSpy);
      const session = await sessionManager.createSession('user123', 'token123', 'valid_refresh');
      expect(session).toMatchObject({
        user_id: 'user123',
        token: 'token123',
        refreshToken: 'valid_refresh',
        is_active: true,
      });
      expect(sessionCreatedSpy).toHaveBeenCalledWith(session);
      expect(mockStorage.setItem).toHaveBeenCalledWith('session', expect.any(String));
    });
    it('should restore session from storage', async () => {
      const storedSession = {
        id: 'sess_123',
        user_id: 'user123',
        token: 'token123',
        refreshToken: 'refresh123',
        expiresAt: new Date(Date.now() + 30 * 60 * 1000).toISOString(),
        lastActivity: new Date().toISOString(),
        is_active: true,
      };
      mockStorage.getItem = jest.fn().mockReturnValue(JSON.stringify(storedSession));
      sessionManager = new SessionManager(
        {
          maxIdleTime: 15 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const session = sessionManager.getSession();
      expect(session).toMatchObject({
        id: 'sess_123',
        user_id: 'user123',
        token: 'token123',
      });
    });
  });

describe('Session Timeout', () => {
    it('should expire session after duration', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 15 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000, // 1 hour
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const expiredSpy = jest.fn();
      sessionManager.on('session-expired', expiredSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      // Fast-forward to expiry
      jest.advanceTimersByTime(60 * 60 * 1000);
      expect(expiredSpy).toHaveBeenCalled();
      expect(sessionManager.isSessionValid()).toBe(false);
    });
    it('should timeout on idle', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 15 * 60 * 1000, // 15 minutes
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const idleTimeoutSpy = jest.fn();
      sessionManager.on('idle-timeout', idleTimeoutSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      // Fast-forward past idle timeout
      jest.advanceTimersByTime(15 * 60 * 1000);
      expect(idleTimeoutSpy).toHaveBeenCalled();
      expect(sessionManager.isSessionValid()).toBe(false);
    });
    it('should reset idle timer on activity', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 15 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const idleTimeoutSpy = jest.fn();
      sessionManager.on('idle-timeout', idleTimeoutSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      // Simulate activity after 10 minutes
      jest.advanceTimersByTime(10 * 60 * 1000);
      document.dispatchEvent(new Event('mousedown'));
      // Fast-forward another 10 minutes (total 20, but only 10 since last activity)
      jest.advanceTimersByTime(10 * 60 * 1000);
      expect(idleTimeoutSpy).not.toHaveBeenCalled();
      expect(sessionManager.isSessionValid()).toBe(true);
    });
    it('should show warning before expiry', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000, // 5 minutes warning
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const warningSpy = jest.fn();
      sessionManager.on('session-warning', warningSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      // Fast-forward to warning time
      jest.advanceTimersByTime(55 * 60 * 1000); // 55 minutes
      expect(warningSpy).toHaveBeenCalledWith(300); // 5 minutes in seconds
    });
  });

describe('Session Refresh', () => {
    it('should auto-refresh before expiry', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000, // Refresh 10 minutes before expiry
        },
        mockStorage
      );
      const refreshedSpy = jest.fn();
      sessionManager.on('session-refreshed', refreshedSpy);
      await sessionManager.createSession('user123', 'token123', 'valid_refresh');
      // Fast-forward to refresh time (50 minutes)
      jest.advanceTimersByTime(50 * 60 * 1000);
      // Wait for async refresh
      await jest.runAllTimersAsync();
      expect(refreshedSpy).toHaveBeenCalled();
      const session = sessionManager.getSession();
      expect(session?.token).toContain('new_token_');
    });
    it('should handle failed refresh', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const refreshFailedSpy = jest.fn();
      sessionManager.on('refresh-failed', refreshFailedSpy);
      await sessionManager.createSession('user123', 'token123', 'invalid_refresh');
      // Manually trigger refresh
      await sessionManager.refreshSession();
      expect(refreshFailedSpy).not.toHaveBeenCalled(); // Returns null but doesn't emit error
      expect(sessionManager.getSession()?.token).toBe('token123'); // Token unchanged
    });
    it('should manually refresh session', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      await sessionManager.createSession('user123', 'token123', 'valid_refresh');
      const refreshed = await sessionManager.refreshSession();
      expect(refreshed).not.toBeNull();
      expect(refreshed?.token).toContain('new_token_');
    });
  });

describe('Session Extension', () => {
    it('should extend session duration', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const extendedSpy = jest.fn();
      sessionManager.on('session-extended', extendedSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      const originalExpiry = sessionManager.getSession()?.expiresAt;
      sessionManager.extendSession(30); // Extend by 30 minutes
      expect(extendedSpy).toHaveBeenCalledWith({
        minutes: 30,
        newExpiry: expect.any(Date),
      });
      const newExpiry = sessionManager.getSession()?.expiresAt;
      const diff = (newExpiry!.getTime() - originalExpiry!.getTime()) / (60 * 1000);
      expect(Math.round(diff)).toBe(30);
    });
  });

describe('Multi-Tab Synchronization', () => {
    it('should sync session across tabs', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const syncedSpy = jest.fn();
      sessionManager.on('session-synced', syncedSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      // Simulate storage event from another tab
      const updatedSession = {
        id: 'sess_updated',
        user_id: 'user123',
        token: 'updated_token',
        refreshToken: 'refresh123',
        expiresAt: new Date(Date.now() + 45 * 60 * 1000).toISOString(),
        lastActivity: new Date().toISOString(),
        is_active: true,
      };
      mockStorage.getItem = jest.fn().mockReturnValue(JSON.stringify(updatedSession));
      const storageEvent = new StorageEvent('storage', {
        key: 'session',
        newValue: JSON.stringify(updatedSession),
        oldValue: null,
        storageArea: mockStorage,
      });
      window.dispatchEvent(storageEvent);
      expect(syncedSpy).toHaveBeenCalled();
      expect(sessionManager.getSession()?.token).toBe('updated_token');
    });
    it('should handle remote logout', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const remoteLogoutSpy = jest.fn();
      sessionManager.on('remote-logout', remoteLogoutSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      // Simulate storage removal from another tab
      const storageEvent = new StorageEvent('storage', {
        key: 'session',
        newValue: null,
        oldValue: 'some_value',
        storageArea: mockStorage,
      });
      window.dispatchEvent(storageEvent);
      expect(remoteLogoutSpy).toHaveBeenCalled();
      expect(sessionManager.getSession()).toBeNull();
    });
  });

describe('Session Utilities', () => {
    it('should check if session is valid', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      expect(sessionManager.isSessionValid()).toBe(false);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      expect(sessionManager.isSessionValid()).toBe(true);
      sessionManager.endSession('manual');
      expect(sessionManager.isSessionValid()).toBe(false);
    });
    it('should calculate time remaining', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000, // 1 hour
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      const remaining = sessionManager.getTimeRemaining();
      expect(remaining).toBeGreaterThan(59 * 60 * 1000);
      expect(remaining).toBeLessThanOrEqual(60 * 60 * 1000);
      // Advance time
      jest.advanceTimersByTime(30 * 60 * 1000);
      const newRemaining = sessionManager.getTimeRemaining();
      expect(newRemaining).toBeGreaterThan(29 * 60 * 1000);
      expect(newRemaining).toBeLessThanOrEqual(30 * 60 * 1000);
    });
    it('should end session manually', async () => {
      sessionManager = new SessionManager(
        {
          maxIdleTime: 30 * 60 * 1000,
          sessionDuration: 60 * 60 * 1000,
          warningTime: 5 * 60 * 1000,
          refreshThreshold: 10 * 60 * 1000,
        },
        mockStorage
      );
      const endedSpy = jest.fn();
      sessionManager.on('session-ended', endedSpy);
      await sessionManager.createSession('user123', 'token123', 'refresh123');
      sessionManager.endSession('user_logout');
      expect(endedSpy).toHaveBeenCalledWith({
        session: expect.objectContaining({ user_id: 'user123' }),
        reason: 'user_logout',
      });
      expect(sessionManager.getSession()).toBeNull();
      expect(mockStorage.removeItem).toHaveBeenCalledWith('session');
    });
  });
});