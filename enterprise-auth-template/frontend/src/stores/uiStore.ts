import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { devtools } from 'zustand/middleware';

export type Theme = 'light' | 'dark' | 'system';
export type SidebarState = 'expanded' | 'collapsed' | 'hidden';
export type ViewMode = 'grid' | 'list' | 'card';
export type Language = 'en' | 'es' | 'fr' | 'de' | 'ja' | 'zh';

export interface Modal {
  id: string;
  component: string;
  props?: Record<string, unknown>;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
  closable?: boolean;
  priority?: number;
}

export interface Toast {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  title: string;
  message?: string;
  duration?: number;
  action?: {
    label: string;
    onClick: () => void;
  };
}

export interface Breadcrumb {
  label: string;
  href?: string;
  icon?: string;
  active?: boolean;
}

export interface UIPreferences {
  theme: Theme;
  sidebarState: SidebarState;
  sidebarWidth: number;
  compactMode: boolean;
  showAnimations: boolean;
  showTooltips: boolean;
  autoHideHeader: boolean;
  fontSize: 'small' | 'medium' | 'large';
  density: 'compact' | 'normal' | 'comfortable';
  roundedCorners: boolean;
  accentColor: string;
  fontFamily: string;
  language: Language;
  dateFormat: string;
  timeFormat: '12h' | '24h';
  firstDayOfWeek: 0 | 1 | 6; // Sunday, Monday, Saturday
  defaultViewMode: ViewMode;
}

export interface UIState {
  // Layout State
  sidebarOpen: boolean;
  sidebarState: SidebarState;
  headerVisible: boolean;
  footerVisible: boolean;
  mobileMenuOpen: boolean;
  searchOpen: boolean;
  commandPaletteOpen: boolean;
  helpPanelOpen: boolean;
  fullscreen: boolean;
  
  // Navigation State
  breadcrumbs: Breadcrumb[];
  activeRoute: string;
  previousRoute: string;
  navigationHistory: string[];
  
  // Modal State
  modals: Modal[];
  activeModal: Modal | null;
  modalStack: Modal[];
  
  // Toast State
  toasts: Toast[];
  
  // Loading State
  globalLoading: boolean;
  loadingMessage: string;
  loadingProgress: number;
  pageLoading: boolean;
  componentLoading: Record<string, boolean>;
  
  // View State
  viewMode: ViewMode;
  selectedItems: string[];
  expandedItems: string[];
  focusedItem: string | null;
  scrollPosition: Record<string, number>;
  
  // Form State
  unsavedChanges: boolean;
  formErrors: Record<string, string[]>;
  formTouched: Record<string, boolean>;
  
  // Preferences
  preferences: UIPreferences;
  
  // Responsive State
  isMobile: boolean;
  isTablet: boolean;
  isDesktop: boolean;
  screenWidth: number;
  screenHeight: number;
  orientation: 'portrait' | 'landscape';
  
  // Feature Flags
  features: Record<string, boolean>;
  
  // Actions - Layout
  toggleSidebar: () => void;
  setSidebarState: (state: SidebarState) => void;
  toggleHeader: () => void;
  toggleFooter: () => void;
  toggleMobileMenu: () => void;
  toggleSearch: () => void;
  toggleCommandPalette: () => void;
  toggleHelpPanel: () => void;
  toggleFullscreen: () => void;
  
  // Actions - Navigation
  setBreadcrumbs: (breadcrumbs: Breadcrumb[]) => void;
  addBreadcrumb: (breadcrumb: Breadcrumb) => void;
  removeBreadcrumb: (index: number) => void;
  setActiveRoute: (route: string) => void;
  navigateBack: () => void;
  clearNavigationHistory: () => void;
  
  // Actions - Modal
  openModal: (modal: Omit<Modal, 'id'>) => void;
  closeModal: (id?: string) => void;
  closeAllModals: () => void;
  updateModal: (id: string, updates: Partial<Modal>) => void;
  
  // Actions - Toast
  showToast: (toast: Omit<Toast, 'id'>) => void;
  removeToast: (id: string) => void;
  clearToasts: () => void;
  
  // Actions - Loading
  setGlobalLoading: (loading: boolean, message?: string) => void;
  setLoadingProgress: (progress: number) => void;
  setPageLoading: (loading: boolean) => void;
  setComponentLoading: (component: string, loading: boolean) => void;
  
  // Actions - View
  setViewMode: (mode: ViewMode) => void;
  selectItem: (id: string) => void;
  deselectItem: (id: string) => void;
  toggleItemSelection: (id: string) => void;
  selectAll: (ids: string[]) => void;
  clearSelection: () => void;
  expandItem: (id: string) => void;
  collapseItem: (id: string) => void;
  toggleItemExpansion: (id: string) => void;
  setFocusedItem: (id: string | null) => void;
  saveScrollPosition: (key: string, position: number) => void;
  restoreScrollPosition: (key: string) => number | undefined;
  
  // Actions - Form
  setUnsavedChanges: (hasChanges: boolean) => void;
  setFormError: (field: string, errors: string[]) => void;
  clearFormError: (field: string) => void;
  clearAllFormErrors: () => void;
  setFormTouched: (field: string, touched: boolean) => void;
  resetFormState: () => void;
  
  // Actions - Preferences
  setTheme: (theme: Theme) => void;
  setLanguage: (language: Language) => void;
  updatePreferences: (preferences: Partial<UIPreferences>) => void;
  resetPreferences: () => void;
  
  // Actions - Responsive
  updateScreenSize: (width: number, height: number) => void;
  setOrientation: (orientation: 'portrait' | 'landscape') => void;
  
  // Actions - Features
  setFeature: (feature: string, enabled: boolean) => void;
  setFeatures: (features: Record<string, boolean>) => void;
  
  // Actions - Utils
  reset: () => void;
  hydrate: () => void;
}

const defaultPreferences: UIPreferences = {
  theme: 'system',
  sidebarState: 'expanded',
  sidebarWidth: 256,
  compactMode: false,
  showAnimations: true,
  showTooltips: true,
  autoHideHeader: false,
  fontSize: 'medium',
  density: 'normal',
  roundedCorners: true,
  accentColor: '#6366f1',
  fontFamily: 'Inter',
  language: 'en',
  dateFormat: 'MM/DD/YYYY',
  timeFormat: '12h',
  firstDayOfWeek: 0,
  defaultViewMode: 'grid',
};

let toastIdCounter = 0;
let modalIdCounter = 0;

export const useUIStore = create<UIState>()(
  devtools(
    persist(
      (set, get) => ({
        // Initial State
        sidebarOpen: true,
        sidebarState: 'expanded',
        headerVisible: true,
        footerVisible: true,
        mobileMenuOpen: false,
        searchOpen: false,
        commandPaletteOpen: false,
        helpPanelOpen: false,
        fullscreen: false,
        
        breadcrumbs: [],
        activeRoute: '',
        previousRoute: '',
        navigationHistory: [],
        
        modals: [],
        activeModal: null,
        modalStack: [],
        
        toasts: [],
        
        globalLoading: false,
        loadingMessage: '',
        loadingProgress: 0,
        pageLoading: false,
        componentLoading: {},
        
        viewMode: 'grid',
        selectedItems: [],
        expandedItems: [],
        focusedItem: null,
        scrollPosition: {},
        
        unsavedChanges: false,
        formErrors: {},
        formTouched: {},
        
        preferences: defaultPreferences,
        
        isMobile: false,
        isTablet: false,
        isDesktop: true,
        screenWidth: 1920,
        screenHeight: 1080,
        orientation: 'landscape',
        
        features: {},
        
        // Layout Actions
        toggleSidebar: () => {
          set((state) => ({
            sidebarOpen: !state.sidebarOpen,
            sidebarState: !state.sidebarOpen ? 'expanded' : 'collapsed',
          }));
        },
        
        setSidebarState: (sidebarState) => {
          set({
            sidebarState,
            sidebarOpen: sidebarState === 'expanded',
          });
        },
        
        toggleHeader: () => {
          set((state) => ({ headerVisible: !state.headerVisible }));
        },
        
        toggleFooter: () => {
          set((state) => ({ footerVisible: !state.footerVisible }));
        },
        
        toggleMobileMenu: () => {
          set((state) => ({ mobileMenuOpen: !state.mobileMenuOpen }));
        },
        
        toggleSearch: () => {
          set((state) => ({ searchOpen: !state.searchOpen }));
        },
        
        toggleCommandPalette: () => {
          set((state) => ({ commandPaletteOpen: !state.commandPaletteOpen }));
        },
        
        toggleHelpPanel: () => {
          set((state) => ({ helpPanelOpen: !state.helpPanelOpen }));
        },
        
        toggleFullscreen: () => {
          const isFullscreen = !document.fullscreenElement;
          
          if (isFullscreen) {
            document.documentElement.requestFullscreen();
          } else {
            document.exitFullscreen();
          }
          
          set({ fullscreen: isFullscreen });
        },
        
        // Navigation Actions
        setBreadcrumbs: (breadcrumbs) => set({ breadcrumbs }),
        
        addBreadcrumb: (breadcrumb) => {
          set((state) => ({
            breadcrumbs: [...state.breadcrumbs, breadcrumb],
          }));
        },
        
        removeBreadcrumb: (index) => {
          set((state) => ({
            breadcrumbs: state.breadcrumbs.filter((_, i) => i !== index),
          }));
        },
        
        setActiveRoute: (route) => {
          set((state) => ({
            activeRoute: route,
            previousRoute: state.activeRoute,
            navigationHistory: [...state.navigationHistory, route].slice(-10),
          }));
        },
        
        navigateBack: () => {
          const history = get().navigationHistory;
          if (history.length > 1) {
            const previousRoute = history[history.length - 2];
            set({
              activeRoute: previousRoute || '',
              navigationHistory: history.slice(0, -1),
            });
          }
        },
        
        clearNavigationHistory: () => {
          set({ navigationHistory: [], previousRoute: '' });
        },
        
        // Modal Actions
        openModal: (modal) => {
          const id = `modal-${++modalIdCounter}`;
          const newModal = { ...modal, id };
          
          set((state) => ({
            modals: [...state.modals, newModal],
            activeModal: newModal,
            modalStack: [...state.modalStack, newModal],
          }));
        },
        
        closeModal: (id) => {
          set((state) => {
            const modals = id
              ? state.modals.filter((m) => m.id !== id)
              : state.modals.slice(0, -1);
            
            const modalStack = id
              ? state.modalStack.filter((m) => m.id !== id)
              : state.modalStack.slice(0, -1);
            
            return {
              modals,
              modalStack,
              activeModal: modalStack[modalStack.length - 1] || null,
            };
          });
        },
        
        closeAllModals: () => {
          set({ modals: [], activeModal: null, modalStack: [] });
        },
        
        updateModal: (id, updates) => {
          set((state) => ({
            modals: state.modals.map((m) =>
              m.id === id ? { ...m, ...updates } : m
            ),
            activeModal:
              state.activeModal?.id === id
                ? { ...state.activeModal, ...updates }
                : state.activeModal,
            modalStack: state.modalStack.map((m) =>
              m.id === id ? { ...m, ...updates } : m
            ),
          }));
        },
        
        // Toast Actions
        showToast: (toast) => {
          const id = `toast-${++toastIdCounter}`;
          const newToast = { ...toast, id };
          
          set((state) => ({
            toasts: [...state.toasts, newToast],
          }));
          
          // Auto-remove toast after duration
          if (toast.duration !== 0) {
            setTimeout(() => {
              get().removeToast(id);
            }, toast.duration || 5000);
          }
        },
        
        removeToast: (id) => {
          set((state) => ({
            toasts: state.toasts.filter((t) => t.id !== id),
          }));
        },
        
        clearToasts: () => set({ toasts: [] }),
        
        // Loading Actions
        setGlobalLoading: (globalLoading, loadingMessage = '') => {
          set({ globalLoading, loadingMessage, loadingProgress: 0 });
        },
        
        setLoadingProgress: (loadingProgress) => set({ loadingProgress }),
        
        setPageLoading: (pageLoading) => set({ pageLoading }),
        
        setComponentLoading: (component, loading) => {
          set((state) => ({
            componentLoading: {
              ...state.componentLoading,
              [component]: loading,
            },
          }));
        },
        
        // View Actions
        setViewMode: (viewMode) => set({ viewMode }),
        
        selectItem: (id) => {
          set((state) => ({
            selectedItems: [...state.selectedItems, id],
          }));
        },
        
        deselectItem: (id) => {
          set((state) => ({
            selectedItems: state.selectedItems.filter((item) => item !== id),
          }));
        },
        
        toggleItemSelection: (id) => {
          set((state) => ({
            selectedItems: state.selectedItems.includes(id)
              ? state.selectedItems.filter((item) => item !== id)
              : [...state.selectedItems, id],
          }));
        },
        
        selectAll: (ids) => set({ selectedItems: ids }),
        
        clearSelection: () => set({ selectedItems: [] }),
        
        expandItem: (id) => {
          set((state) => ({
            expandedItems: [...state.expandedItems, id],
          }));
        },
        
        collapseItem: (id) => {
          set((state) => ({
            expandedItems: state.expandedItems.filter((item) => item !== id),
          }));
        },
        
        toggleItemExpansion: (id) => {
          set((state) => ({
            expandedItems: state.expandedItems.includes(id)
              ? state.expandedItems.filter((item) => item !== id)
              : [...state.expandedItems, id],
          }));
        },
        
        setFocusedItem: (focusedItem) => set({ focusedItem }),
        
        saveScrollPosition: (key, position) => {
          set((state) => ({
            scrollPosition: {
              ...state.scrollPosition,
              [key]: position,
            },
          }));
        },
        
        restoreScrollPosition: (key) => {
          return get().scrollPosition[key];
        },
        
        // Form Actions
        setUnsavedChanges: (unsavedChanges) => set({ unsavedChanges }),
        
        setFormError: (field, errors) => {
          set((state) => ({
            formErrors: {
              ...state.formErrors,
              [field]: errors,
            },
          }));
        },
        
        clearFormError: (field) => {
          set((state) => {
            const { [field]: _, ...rest } = state.formErrors;
            return { formErrors: rest };
          });
        },
        
        clearAllFormErrors: () => set({ formErrors: {} }),
        
        setFormTouched: (field, touched) => {
          set((state) => ({
            formTouched: {
              ...state.formTouched,
              [field]: touched,
            },
          }));
        },
        
        resetFormState: () => {
          set({
            unsavedChanges: false,
            formErrors: {},
            formTouched: {},
          });
        },
        
        // Preferences Actions
        setTheme: (theme) => {
          set((state) => ({
            preferences: { ...state.preferences, theme },
          }));
          
          // Apply theme to document
          if (theme === 'dark' || (theme === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
            document.documentElement.classList.add('dark');
          } else {
            document.documentElement.classList.remove('dark');
          }
        },
        
        setLanguage: (language) => {
          set((state) => ({
            preferences: { ...state.preferences, language },
          }));
        },
        
        updatePreferences: (preferences) => {
          set((state) => ({
            preferences: { ...state.preferences, ...preferences },
          }));
        },
        
        resetPreferences: () => set({ preferences: defaultPreferences }),
        
        // Responsive Actions
        updateScreenSize: (width, height) => {
          const isMobile = width < 640;
          const isTablet = width >= 640 && width < 1024;
          const isDesktop = width >= 1024;
          const orientation = width > height ? 'landscape' : 'portrait';
          
          set({
            screenWidth: width,
            screenHeight: height,
            isMobile,
            isTablet,
            isDesktop,
            orientation,
          });
        },
        
        setOrientation: (orientation) => set({ orientation }),
        
        // Feature Actions
        setFeature: (feature, enabled) => {
          set((state) => ({
            features: {
              ...state.features,
              [feature]: enabled,
            },
          }));
        },
        
        setFeatures: (features) => set({ features }),
        
        // Utility Actions
        reset: () => {
          set({
            sidebarOpen: true,
            sidebarState: 'expanded',
            headerVisible: true,
            footerVisible: true,
            mobileMenuOpen: false,
            searchOpen: false,
            commandPaletteOpen: false,
            helpPanelOpen: false,
            fullscreen: false,
            breadcrumbs: [],
            activeRoute: '',
            previousRoute: '',
            navigationHistory: [],
            modals: [],
            activeModal: null,
            modalStack: [],
            toasts: [],
            globalLoading: false,
            loadingMessage: '',
            loadingProgress: 0,
            pageLoading: false,
            componentLoading: {},
            viewMode: 'grid',
            selectedItems: [],
            expandedItems: [],
            focusedItem: null,
            scrollPosition: {},
            unsavedChanges: false,
            formErrors: {},
            formTouched: {},
            preferences: defaultPreferences,
            features: {},
          });
        },
        
        hydrate: () => {
          // Initialize responsive state
          const width = window.innerWidth;
          const height = window.innerHeight;
          get().updateScreenSize(width, height);
          
          // Apply saved theme
          const theme = get().preferences.theme;
          get().setTheme(theme);
          
          // Set up resize listener
          window.addEventListener('resize', () => {
            get().updateScreenSize(window.innerWidth, window.innerHeight);
          });
        },
      }),
      {
        name: 'ui-storage',
        storage: createJSONStorage(() => localStorage),
        partialize: (state) => ({
          preferences: state.preferences,
          sidebarState: state.sidebarState,
          viewMode: state.viewMode,
          features: state.features,
        }),
      }
    ),
    {
      name: 'UIStore',
    }
  )
);