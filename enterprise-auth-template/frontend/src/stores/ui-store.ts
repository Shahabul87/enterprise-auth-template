/**
 * UI Store using Zustand
 * 
 * Manages UI state including modals, drawers, sidebars, loading states,
 * theme preferences, responsive breakpoints, and global UI interactions.
 */

import { create } from 'zustand';
import { devtools, persist, subscribeWithSelector } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

// Theme types
export type Theme = 'light' | 'dark' | 'system';
export type ColorScheme = 'default' | 'blue' | 'green' | 'purple' | 'orange' | 'red';

// Modal types
export interface ModalConfig {
  id: string;
  type: string;
  title?: string;
  data?: Record<string, unknown>;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  closable?: boolean;
  persistent?: boolean;
  backdrop?: boolean;
  onClose?: () => void;
  onConfirm?: (data?: unknown) => void;
}

// Drawer types
export interface DrawerConfig {
  id: string;
  type: string;
  title?: string;
  data?: Record<string, unknown>;
  position?: 'left' | 'right' | 'top' | 'bottom';
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  closable?: boolean;
  persistent?: boolean;
  backdrop?: boolean;
  onClose?: () => void;
}

// Loading state types
export interface LoadingState {
  id: string;
  message?: string;
  progress?: number;
  cancellable?: boolean;
  onCancel?: () => void;
}

// Layout types
export type LayoutType = 'default' | 'minimal' | 'dashboard' | 'auth' | 'landing';
export type SidebarState = 'open' | 'closed' | 'collapsed';
export type HeaderState = 'visible' | 'hidden' | 'minimized';

// Responsive breakpoint types
export type Breakpoint = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | '2xl';

// Command palette types
export interface Command {
  id: string;
  title: string;
  subtitle?: string;
  keywords: string[];
  icon?: string;
  shortcut?: string[];
  action: () => void;
  category?: string;
  disabled?: boolean;
}

// Breadcrumb types
export interface Breadcrumb {
  label: string;
  href?: string;
  icon?: string;
  current?: boolean;
}

// Toast position from notification store (for consistency)
export type ToastPosition = 
  | 'top-left' 
  | 'top-center' 
  | 'top-right' 
  | 'bottom-left' 
  | 'bottom-center' 
  | 'bottom-right';

// UI preferences interface
export interface UIPreferences {
  theme: Theme;
  colorScheme: ColorScheme;
  reducedMotion: boolean;
  highContrast: boolean;
  fontSize: 'small' | 'medium' | 'large';
  compactMode: boolean;
  showTooltips: boolean;
  autoSave: boolean;
  confirmDangerousActions: boolean;
  keyboardShortcutsEnabled: boolean;
}

// UI error interface
export interface UIError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: Date;
}

// UI store state interface
export interface UIState {
  // Theme and appearance
  theme: Theme;
  colorScheme: ColorScheme;
  isDarkMode: boolean;
  preferences: UIPreferences;
  
  // Layout state
  layoutType: LayoutType;
  sidebarState: SidebarState;
  headerState: HeaderState;
  isFullscreen: boolean;
  
  // Responsive state
  currentBreakpoint: Breakpoint;
  isMobile: boolean;
  isTablet: boolean;
  isDesktop: boolean;
  screenWidth: number;
  screenHeight: number;
  
  // Modal management
  modals: ModalConfig[];
  activeModalId: string | null;
  modalCount: number;
  
  // Drawer management
  drawers: DrawerConfig[];
  activeDrawerId: string | null;
  drawerCount: number;
  
  // Loading states
  loadingStates: LoadingState[];
  globalLoading: boolean;
  globalLoadingMessage: string;
  
  // Command palette
  isCommandPaletteOpen: boolean;
  commands: Command[];
  commandQuery: string;
  filteredCommands: Command[];
  
  // Navigation
  breadcrumbs: Breadcrumb[];
  currentPage: string;
  previousPage: string;
  navigationHistory: string[];
  
  // Focus management
  focusTrapEnabled: boolean;
  lastFocusedElement: HTMLElement | null;
  
  // Scroll management
  scrollPositions: Record<string, number>;
  isScrolling: boolean;
  scrollDirection: 'up' | 'down' | null;
  
  // Error handling
  error: UIError | null;
  errors: UIError[];
  
  // Actions
  // Theme management
  setTheme: (theme: Theme) => void;
  setColorScheme: (scheme: ColorScheme) => void;
  toggleTheme: () => void;
  updatePreferences: (preferences: Partial<UIPreferences>) => void;
  resetPreferences: () => void;
  
  // Layout management
  setLayoutType: (layout: LayoutType) => void;
  setSidebarState: (state: SidebarState) => void;
  toggleSidebar: () => void;
  setHeaderState: (state: HeaderState) => void;
  toggleHeader: () => void;
  enterFullscreen: () => void;
  exitFullscreen: () => void;
  toggleFullscreen: () => void;
  
  // Responsive management
  updateScreenSize: (width: number, height: number) => void;
  setBreakpoint: (breakpoint: Breakpoint) => void;
  
  // Modal management
  openModal: (modal: Omit<ModalConfig, 'id'>) => string;
  closeModal: (modalId?: string) => void;
  closeAllModals: () => void;
  updateModal: (modalId: string, updates: Partial<ModalConfig>) => void;
  getModal: (modalId: string) => ModalConfig | null;
  
  // Drawer management
  openDrawer: (drawer: Omit<DrawerConfig, 'id'>) => string;
  closeDrawer: (drawerId?: string) => void;
  closeAllDrawers: () => void;
  updateDrawer: (drawerId: string, updates: Partial<DrawerConfig>) => void;
  getDrawer: (drawerId: string) => DrawerConfig | null;
  
  // Loading state management
  startLoading: (config?: Omit<LoadingState, 'id'>) => string;
  stopLoading: (loadingId?: string) => void;
  updateLoading: (loadingId: string, updates: Partial<LoadingState>) => void;
  setGlobalLoading: (loading: boolean, message?: string) => void;
  clearAllLoading: () => void;
  
  // Command palette management
  openCommandPalette: () => void;
  closeCommandPalette: () => void;
  toggleCommandPalette: () => void;
  setCommandQuery: (query: string) => void;
  registerCommand: (command: Command) => void;
  unregisterCommand: (commandId: string) => void;
  executeCommand: (commandId: string) => void;
  filterCommands: (query: string) => void;
  
  // Navigation management
  setBreadcrumbs: (breadcrumbs: Breadcrumb[]) => void;
  addBreadcrumb: (breadcrumb: Breadcrumb) => void;
  setCurrentPage: (page: string) => void;
  navigateBack: () => void;
  clearNavigationHistory: () => void;
  
  // Focus management
  enableFocusTrap: () => void;
  disableFocusTrap: () => void;
  setLastFocusedElement: (element: HTMLElement | null) => void;
  restoreFocus: () => void;
  
  // Scroll management
  saveScrollPosition: (key: string, position: number) => void;
  restoreScrollPosition: (key: string) => number;
  setScrollDirection: (direction: 'up' | 'down' | null) => void;
  setScrolling: (isScrolling: boolean) => void;
  
  // Error management
  setError: (error: UIError | null) => void;
  clearError: () => void;
  addError: (error: UIError) => void;
  clearErrors: () => void;
  
  // Utility actions
  reset: () => void;
  initialize: () => void;
}

// Generate unique IDs for UI components
const generateId = (prefix: string): string => {
  return `${prefix}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

// Default UI preferences
const defaultPreferences: UIPreferences = {
  theme: 'system',
  colorScheme: 'default',
  reducedMotion: false,
  highContrast: false,
  fontSize: 'medium',
  compactMode: false,
  showTooltips: true,
  autoSave: true,
  confirmDangerousActions: true,
  keyboardShortcutsEnabled: true,
};

// Breakpoint utilities
const getBreakpointFromWidth = (width: number): Breakpoint => {
  if (width < 640) return 'xs';
  if (width < 768) return 'sm';
  if (width < 1024) return 'md';
  if (width < 1280) return 'lg';
  if (width < 1536) return 'xl';
  return '2xl';
};

const getResponsiveFlags = (breakpoint: Breakpoint) => ({
  isMobile: breakpoint === 'xs' || breakpoint === 'sm',
  isTablet: breakpoint === 'md',
  isDesktop: breakpoint === 'lg' || breakpoint === 'xl' || breakpoint === '2xl',
});

// Default commands
const defaultCommands: Command[] = [
  {
    id: 'theme-toggle',
    title: 'Toggle Theme',
    subtitle: 'Switch between light and dark mode',
    keywords: ['theme', 'dark', 'light', 'mode'],
    icon: 'sun-moon',
    shortcut: ['⌘', 'K', 'T'],
    action: () => {}, // Will be set in the store
    category: 'Appearance',
  },
  {
    id: 'fullscreen-toggle',
    title: 'Toggle Fullscreen',
    subtitle: 'Enter or exit fullscreen mode',
    keywords: ['fullscreen', 'full', 'screen'],
    icon: 'expand',
    shortcut: ['F11'],
    action: () => {}, // Will be set in the store
    category: 'View',
  },
  {
    id: 'sidebar-toggle',
    title: 'Toggle Sidebar',
    subtitle: 'Show or hide the sidebar',
    keywords: ['sidebar', 'menu', 'navigation'],
    icon: 'sidebar',
    shortcut: ['⌘', 'B'],
    action: () => {}, // Will be set in the store
    category: 'Navigation',
  },
];

export const useUIStore = create<UIState>()(
  devtools(
    subscribeWithSelector(
      persist(
        immer((set, get) => ({
          // Initial state
          theme: 'system',
          colorScheme: 'default',
          isDarkMode: false,
          preferences: defaultPreferences,
          
          layoutType: 'default',
          sidebarState: 'open',
          headerState: 'visible',
          isFullscreen: false,
          
          currentBreakpoint: 'lg',
          isMobile: false,
          isTablet: false,
          isDesktop: true,
          screenWidth: typeof window !== 'undefined' ? window.innerWidth : 1024,
          screenHeight: typeof window !== 'undefined' ? window.innerHeight : 768,
          
          modals: [],
          activeModalId: null,
          modalCount: 0,
          
          drawers: [],
          activeDrawerId: null,
          drawerCount: 0,
          
          loadingStates: [],
          globalLoading: false,
          globalLoadingMessage: '',
          
          isCommandPaletteOpen: false,
          commands: [...defaultCommands],
          commandQuery: '',
          filteredCommands: [...defaultCommands],
          
          breadcrumbs: [],
          currentPage: '',
          previousPage: '',
          navigationHistory: [],
          
          focusTrapEnabled: false,
          lastFocusedElement: null,
          
          scrollPositions: {},
          isScrolling: false,
          scrollDirection: null,
          
          error: null,
          errors: [],
          
          // Theme management actions
          setTheme: (theme: Theme) => {
            set((state) => {
              state.theme = theme;
              state.preferences.theme = theme;
              
              if (typeof window !== 'undefined') {
                if (theme === 'system') {
                  state.isDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
                } else {
                  state.isDarkMode = theme === 'dark';
                }
                
                // Apply theme to document
                document.documentElement.classList.toggle('dark', state.isDarkMode);
                document.documentElement.setAttribute('data-theme', theme);
              }
            });
          },
          
          setColorScheme: (scheme: ColorScheme) => {
            set((state) => {
              state.colorScheme = scheme;
              state.preferences.colorScheme = scheme;
              
              if (typeof window !== 'undefined') {
                document.documentElement.setAttribute('data-color-scheme', scheme);
              }
            });
          },
          
          toggleTheme: () => {
            const currentTheme = get().theme;
            const newTheme = currentTheme === 'light' ? 'dark' : 'light';
            get().setTheme(newTheme);
          },
          
          updatePreferences: (preferences: Partial<UIPreferences>) => {
            set((state) => {
              state.preferences = { ...state.preferences, ...preferences };
              
              // Apply preferences to document
              if (typeof window !== 'undefined') {
                if (preferences.theme) {
                  get().setTheme(preferences.theme);
                }
                if (preferences.colorScheme) {
                  get().setColorScheme(preferences.colorScheme);
                }
                if (preferences.reducedMotion !== undefined) {
                  document.documentElement.classList.toggle('reduce-motion', preferences.reducedMotion);
                }
                if (preferences.highContrast !== undefined) {
                  document.documentElement.classList.toggle('high-contrast', preferences.highContrast);
                }
                if (preferences.fontSize) {
                  document.documentElement.setAttribute('data-font-size', preferences.fontSize);
                }
                if (preferences.compactMode !== undefined) {
                  document.documentElement.classList.toggle('compact', preferences.compactMode);
                }
              }
            });
          },
          
          resetPreferences: () => {
            get().updatePreferences(defaultPreferences);
          },
          
          // Layout management actions
          setLayoutType: (layout: LayoutType) => {
            set((state) => {
              state.layoutType = layout;
              
              if (typeof window !== 'undefined') {
                document.documentElement.setAttribute('data-layout', layout);
              }
            });
          },
          
          setSidebarState: (state: SidebarState) => {
            set((draft) => {
              draft.sidebarState = state;
            });
          },
          
          toggleSidebar: () => {
            const currentState = get().sidebarState;
            const newState = currentState === 'open' ? 'closed' : 'open';
            get().setSidebarState(newState);
          },
          
          setHeaderState: (state: HeaderState) => {
            set((draft) => {
              draft.headerState = state;
            });
          },
          
          toggleHeader: () => {
            const currentState = get().headerState;
            const newState = currentState === 'visible' ? 'hidden' : 'visible';
            get().setHeaderState(newState);
          },
          
          enterFullscreen: () => {
            if (typeof window !== 'undefined' && document.documentElement.requestFullscreen) {
              document.documentElement.requestFullscreen();
              set((state) => {
                state.isFullscreen = true;
              });
            }
          },
          
          exitFullscreen: () => {
            if (typeof window !== 'undefined' && document.exitFullscreen) {
              document.exitFullscreen();
              set((state) => {
                state.isFullscreen = false;
              });
            }
          },
          
          toggleFullscreen: () => {
            const isFullscreen = get().isFullscreen;
            if (isFullscreen) {
              get().exitFullscreen();
            } else {
              get().enterFullscreen();
            }
          },
          
          // Responsive management
          updateScreenSize: (width: number, height: number) => {
            const breakpoint = getBreakpointFromWidth(width);
            const responsiveFlags = getResponsiveFlags(breakpoint);
            
            set((state) => {
              state.screenWidth = width;
              state.screenHeight = height;
              state.currentBreakpoint = breakpoint;
              state.isMobile = responsiveFlags.isMobile;
              state.isTablet = responsiveFlags.isTablet;
              state.isDesktop = responsiveFlags.isDesktop;
            });
          },
          
          setBreakpoint: (breakpoint: Breakpoint) => {
            const responsiveFlags = getResponsiveFlags(breakpoint);
            
            set((state) => {
              state.currentBreakpoint = breakpoint;
              state.isMobile = responsiveFlags.isMobile;
              state.isTablet = responsiveFlags.isTablet;
              state.isDesktop = responsiveFlags.isDesktop;
            });
          },
          
          // Modal management actions
          openModal: (modalData: Omit<ModalConfig, 'id'>) => {
            const id = generateId('modal');
            const modal: ModalConfig = {
              id,
              size: 'md',
              closable: true,
              persistent: false,
              backdrop: true,
              ...modalData,
            };
            
            set((state) => {
              state.modals.push(modal);
              state.activeModalId = id;
              state.modalCount = state.modals.length;
            });
            
            return id;
          },
          
          closeModal: (modalId?: string) => {
            const targetId = modalId || get().activeModalId;
            if (!targetId) return;
            
            set((state) => {
              const modalIndex = state.modals.findIndex(m => m.id === targetId);
              if (modalIndex !== -1) {
                const modal = state.modals[modalIndex];
                if (modal && modal.onClose) {
                  modal.onClose();
                }
                
                state.modals.splice(modalIndex, 1);
                state.modalCount = state.modals.length;
                
                // Set active modal to the last one in stack
                state.activeModalId = state.modals.length > 0 
                  ? state.modals[state.modals.length - 1]?.id || null
                  : null;
              }
            });
          },
          
          closeAllModals: () => {
            const modals = get().modals;
            modals.forEach(modal => {
              if (modal.onClose) {
                modal.onClose();
              }
            });
            
            set((state) => {
              state.modals = [];
              state.activeModalId = null;
              state.modalCount = 0;
            });
          },
          
          updateModal: (modalId: string, updates: Partial<ModalConfig>) => {
            set((state) => {
              const modal = state.modals.find(m => m.id === modalId);
              if (modal) {
                Object.assign(modal, updates);
              }
            });
          },
          
          getModal: (modalId: string) => {
            return get().modals.find(m => m.id === modalId) || null;
          },
          
          // Drawer management actions (similar to modals)
          openDrawer: (drawerData: Omit<DrawerConfig, 'id'>) => {
            const id = generateId('drawer');
            const drawer: DrawerConfig = {
              id,
              position: 'right',
              size: 'md',
              closable: true,
              persistent: false,
              backdrop: true,
              ...drawerData,
            };
            
            set((state) => {
              state.drawers.push(drawer);
              state.activeDrawerId = id;
              state.drawerCount = state.drawers.length;
            });
            
            return id;
          },
          
          closeDrawer: (drawerId?: string) => {
            const targetId = drawerId || get().activeDrawerId;
            if (!targetId) return;
            
            set((state) => {
              const drawerIndex = state.drawers.findIndex(d => d.id === targetId);
              if (drawerIndex !== -1) {
                const drawer = state.drawers[drawerIndex];
                if (drawer && drawer.onClose) {
                  drawer.onClose();
                }
                
                state.drawers.splice(drawerIndex, 1);
                state.drawerCount = state.drawers.length;
                
                // Set active drawer to the last one in stack
                state.activeDrawerId = state.drawers.length > 0 
                  ? state.drawers[state.drawers.length - 1]?.id || null
                  : null;
              }
            });
          },
          
          closeAllDrawers: () => {
            const drawers = get().drawers;
            drawers.forEach(drawer => {
              if (drawer.onClose) {
                drawer.onClose();
              }
            });
            
            set((state) => {
              state.drawers = [];
              state.activeDrawerId = null;
              state.drawerCount = 0;
            });
          },
          
          updateDrawer: (drawerId: string, updates: Partial<DrawerConfig>) => {
            set((state) => {
              const drawer = state.drawers.find(d => d.id === drawerId);
              if (drawer) {
                Object.assign(drawer, updates);
              }
            });
          },
          
          getDrawer: (drawerId: string) => {
            return get().drawers.find(d => d.id === drawerId) || null;
          },
          
          // Loading state management
          startLoading: (config?: Omit<LoadingState, 'id'>) => {
            const id = generateId('loading');
            const loadingState: LoadingState = {
              id,
              message: 'Loading...',
              cancellable: false,
              ...config,
            };
            
            set((state) => {
              state.loadingStates.push(loadingState);
            });
            
            return id;
          },
          
          stopLoading: (loadingId?: string) => {
            if (!loadingId) {
              // Stop all loading if no specific ID provided
              set((state) => {
                state.loadingStates = [];
              });
              return;
            }
            
            set((state) => {
              const index = state.loadingStates.findIndex(ls => ls.id === loadingId);
              if (index !== -1) {
                state.loadingStates.splice(index, 1);
              }
            });
          },
          
          updateLoading: (loadingId: string, updates: Partial<LoadingState>) => {
            set((state) => {
              const loadingState = state.loadingStates.find(ls => ls.id === loadingId);
              if (loadingState) {
                Object.assign(loadingState, updates);
              }
            });
          },
          
          setGlobalLoading: (loading: boolean, message = 'Loading...') => {
            set((state) => {
              state.globalLoading = loading;
              state.globalLoadingMessage = loading ? message : '';
            });
          },
          
          clearAllLoading: () => {
            set((state) => {
              state.loadingStates = [];
              state.globalLoading = false;
              state.globalLoadingMessage = '';
            });
          },
          
          // Command palette management
          openCommandPalette: () => {
            set((state) => {
              state.isCommandPaletteOpen = true;
            });
          },
          
          closeCommandPalette: () => {
            set((state) => {
              state.isCommandPaletteOpen = false;
              state.commandQuery = '';
              state.filteredCommands = state.commands;
            });
          },
          
          toggleCommandPalette: () => {
            const isOpen = get().isCommandPaletteOpen;
            if (isOpen) {
              get().closeCommandPalette();
            } else {
              get().openCommandPalette();
            }
          },
          
          setCommandQuery: (query: string) => {
            set((state) => {
              state.commandQuery = query;
            });
            get().filterCommands(query);
          },
          
          registerCommand: (command: Command) => {
            set((state) => {
              // Remove existing command with same ID
              const existingIndex = state.commands.findIndex(c => c.id === command.id);
              if (existingIndex !== -1) {
                state.commands.splice(existingIndex, 1);
              }
              
              state.commands.push(command);
            });
            
            // Re-filter if there's an active query
            const query = get().commandQuery;
            if (query) {
              get().filterCommands(query);
            } else {
              set((state) => {
                state.filteredCommands = state.commands;
              });
            }
          },
          
          unregisterCommand: (commandId: string) => {
            set((state) => {
              state.commands = state.commands.filter(c => c.id !== commandId);
              state.filteredCommands = state.filteredCommands.filter(c => c.id !== commandId);
            });
          },
          
          executeCommand: (commandId: string) => {
            const command = get().commands.find(c => c.id === commandId);
            if (command && !command.disabled) {
              command.action();
              get().closeCommandPalette();
            }
          },
          
          filterCommands: (query: string) => {
            const commands = get().commands;
            
            if (!query.trim()) {
              set((state) => {
                state.filteredCommands = commands;
              });
              return;
            }
            
            const lowerQuery = query.toLowerCase();
            const filtered = commands.filter(command => {
              if (command.disabled) return false;
              
              const titleMatch = command.title.toLowerCase().includes(lowerQuery);
              const subtitleMatch = command.subtitle?.toLowerCase().includes(lowerQuery);
              const keywordMatch = command.keywords.some(keyword => 
                keyword.toLowerCase().includes(lowerQuery)
              );
              const categoryMatch = command.category?.toLowerCase().includes(lowerQuery);
              
              return titleMatch || subtitleMatch || keywordMatch || categoryMatch;
            });
            
            // Sort by relevance (exact matches first, then partial matches)
            filtered.sort((a, b) => {
              const aExactTitle = a.title.toLowerCase() === lowerQuery ? 1 : 0;
              const bExactTitle = b.title.toLowerCase() === lowerQuery ? 1 : 0;
              const aStartsWithTitle = a.title.toLowerCase().startsWith(lowerQuery) ? 1 : 0;
              const bStartsWithTitle = b.title.toLowerCase().startsWith(lowerQuery) ? 1 : 0;
              
              if (aExactTitle !== bExactTitle) return bExactTitle - aExactTitle;
              if (aStartsWithTitle !== bStartsWithTitle) return bStartsWithTitle - aStartsWithTitle;
              
              return a.title.localeCompare(b.title);
            });
            
            set((state) => {
              state.filteredCommands = filtered;
            });
          },
          
          // Navigation management
          setBreadcrumbs: (breadcrumbs: Breadcrumb[]) => {
            set((state) => {
              state.breadcrumbs = breadcrumbs;
            });
          },
          
          addBreadcrumb: (breadcrumb: Breadcrumb) => {
            set((state) => {
              // Mark previous breadcrumbs as not current
              state.breadcrumbs.forEach(b => b.current = false);
              // Add new breadcrumb
              state.breadcrumbs.push({ ...breadcrumb, current: true });
            });
          },
          
          setCurrentPage: (page: string) => {
            set((state) => {
              state.previousPage = state.currentPage;
              state.currentPage = page;
              
              // Add to navigation history
              if (page && !state.navigationHistory.includes(page)) {
                state.navigationHistory.push(page);
                // Keep only last 50 pages
                if (state.navigationHistory.length > 50) {
                  state.navigationHistory = state.navigationHistory.slice(-50);
                }
              }
            });
          },
          
          navigateBack: () => {
            const previousPage = get().previousPage;
            if (previousPage && typeof window !== 'undefined') {
              window.history.back();
            }
          },
          
          clearNavigationHistory: () => {
            set((state) => {
              state.navigationHistory = [];
            });
          },
          
          // Focus management
          enableFocusTrap: () => {
            set((state) => {
              state.focusTrapEnabled = true;
            });
          },
          
          disableFocusTrap: () => {
            set((state) => {
              state.focusTrapEnabled = false;
            });
          },
          
          setLastFocusedElement: (element: HTMLElement | null) => {
            set((state) => {
              (state as { lastFocusedElement: HTMLElement | null }).lastFocusedElement = element;
            });
          },
          
          restoreFocus: () => {
            const lastFocused = get().lastFocusedElement;
            if (lastFocused && typeof lastFocused.focus === 'function') {
              try {
                lastFocused.focus();
              } catch (error) {
                
              }
            }
          },
          
          // Scroll management
          saveScrollPosition: (key: string, position: number) => {
            set((state) => {
              state.scrollPositions[key] = position;
            });
          },
          
          restoreScrollPosition: (key: string) => {
            const position = get().scrollPositions[key];
            return position || 0;
          },
          
          setScrollDirection: (direction: 'up' | 'down' | null) => {
            set((state) => {
              state.scrollDirection = direction;
            });
          },
          
          setScrolling: (isScrolling: boolean) => {
            set((state) => {
              state.isScrolling = isScrolling;
            });
          },
          
          // Error management
          setError: (error: UIError | null) => {
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
          
          addError: (error: UIError) => {
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
          reset: () => {
            set((state) => {
              // Reset to initial state while preserving theme preferences
              const currentPreferences = state.preferences;
              
              // Reset everything except preferences
              state.modals = [];
              state.drawers = [];
              state.loadingStates = [];
              state.activeModalId = null;
              state.activeDrawerId = null;
              state.modalCount = 0;
              state.drawerCount = 0;
              state.globalLoading = false;
              state.globalLoadingMessage = '';
              state.isCommandPaletteOpen = false;
              state.commandQuery = '';
              state.breadcrumbs = [];
              state.focusTrapEnabled = false;
              state.lastFocusedElement = null;
              state.scrollPositions = {};
              state.isScrolling = false;
              state.scrollDirection = null;
              state.error = null;
              state.errors = [];
              
              // Keep preferences
              state.preferences = currentPreferences;
            });
          },
          
          initialize: () => {
            // Set up command actions
            set((state) => {
              state.commands = state.commands.map(command => {
                switch (command.id) {
                  case 'theme-toggle':
                    return { ...command, action: get().toggleTheme };
                  case 'fullscreen-toggle':
                    return { ...command, action: get().toggleFullscreen };
                  case 'sidebar-toggle':
                    return { ...command, action: get().toggleSidebar };
                  default:
                    return command;
                }
              });
              state.filteredCommands = state.commands;
            });
            
            // Apply initial theme
            if (typeof window !== 'undefined') {
              const preferences = get().preferences;
              get().updatePreferences(preferences);
            }
          },
        })),
        {
          name: 'ui-storage',
          // Persist UI preferences and some state
          partialize: (state) => ({
            theme: state.theme,
            colorScheme: state.colorScheme,
            preferences: state.preferences,
            layoutType: state.layoutType,
            sidebarState: state.sidebarState,
            scrollPositions: state.scrollPositions,
          }),
        }
      )
    ),
    {
      name: 'UIStore',
    }
  )
);

// Initialize the store when created
if (typeof window !== 'undefined') {
  useUIStore.getState().initialize();
  
  // Set up window resize listener
  const handleResize = () => {
    useUIStore.getState().updateScreenSize(window.innerWidth, window.innerHeight);
  };
  
  window.addEventListener('resize', handleResize);
  
  // Set up fullscreen change listener
  const handleFullscreenChange = () => {
    const isFullscreen = !!document.fullscreenElement;
    useUIStore.setState({ isFullscreen });
  };
  
  document.addEventListener('fullscreenchange', handleFullscreenChange);
}

// Selector hooks for common use cases
export const useTheme = () => useUIStore((state) => ({ theme: state.theme, isDarkMode: state.isDarkMode }));
export const useLayout = () => useUIStore((state) => ({ 
  layoutType: state.layoutType, 
  sidebarState: state.sidebarState, 
  headerState: state.headerState 
}));
export const useResponsive = () => useUIStore((state) => ({
  breakpoint: state.currentBreakpoint,
  isMobile: state.isMobile,
  isTablet: state.isTablet,
  isDesktop: state.isDesktop,
  screenWidth: state.screenWidth,
  screenHeight: state.screenHeight,
}));
export const useModals = () => useUIStore((state) => ({
  modals: state.modals,
  activeModalId: state.activeModalId,
  modalCount: state.modalCount,
}));
export const useDrawers = () => useUIStore((state) => ({
  drawers: state.drawers,
  activeDrawerId: state.activeDrawerId,
  drawerCount: state.drawerCount,
}));
export const useLoading = () => useUIStore((state) => ({
  loadingStates: state.loadingStates,
  globalLoading: state.globalLoading,
  globalLoadingMessage: state.globalLoadingMessage,
}));
export const useCommandPalette = () => useUIStore((state) => ({
  isOpen: state.isCommandPaletteOpen,
  commands: state.filteredCommands,
  query: state.commandQuery,
}));

// Helper hooks for common UI patterns
export const useUI = useUIStore;

export function useModal() {
  const store = useUIStore();
  
  return {
    modals: store.modals,
    activeModalId: store.activeModalId,
    count: store.modalCount,
    
    open: store.openModal,
    close: store.closeModal,
    closeAll: store.closeAllModals,
    update: store.updateModal,
    get: store.getModal,
  };
}

export function useDrawer() {
  const store = useUIStore();
  
  return {
    drawers: store.drawers,
    activeDrawerId: store.activeDrawerId,
    count: store.drawerCount,
    
    open: store.openDrawer,
    close: store.closeDrawer,
    closeAll: store.closeAllDrawers,
    update: store.updateDrawer,
    get: store.getDrawer,
  };
}

export function useLoadingState() {
  const store = useUIStore();
  
  return {
    states: store.loadingStates,
    globalLoading: store.globalLoading,
    globalMessage: store.globalLoadingMessage,
    
    start: store.startLoading,
    stop: store.stopLoading,
    update: store.updateLoading,
    setGlobal: store.setGlobalLoading,
    clearAll: store.clearAllLoading,
  };
}

export function useThemePreferences() {
  const store = useUIStore();
  
  return {
    theme: store.theme,
    colorScheme: store.colorScheme,
    isDarkMode: store.isDarkMode,
    preferences: store.preferences,
    
    setTheme: store.setTheme,
    setColorScheme: store.setColorScheme,
    toggle: store.toggleTheme,
    updatePreferences: store.updatePreferences,
    reset: store.resetPreferences,
  };
}