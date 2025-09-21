'use client';

import { useEffect, useState } from 'react';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Globe, Check, Languages } from 'lucide-react';
import { toast } from 'sonner';
import {
  changeLanguage,
  getCurrentLanguage,
  getSupportedLanguages,
  initializeI18n,
  onLanguageChange,
  getDirection,
  type LanguageInfo,
} from '@/lib/i18n';

interface LanguageSwitcherProps {
  variant?: 'dropdown' | 'select' | 'button';
  showLabel?: boolean;
  className?: string;
}

export function LanguageSwitcher({
  variant = 'dropdown',
  showLabel = false,
  className = '',
}: LanguageSwitcherProps): React.ReactElement {
  const [currentLang, setCurrentLang] = useState<string>('en');
  const [languages, setLanguages] = useState<LanguageInfo[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isInitialized, setIsInitialized] = useState(false);

  useEffect(() => {
    // Initialize i18n on mount
    const init = async () => {
      try {
        await initializeI18n();
        setIsInitialized(true);
        setCurrentLang(getCurrentLanguage());
        setLanguages(getSupportedLanguages());
      } catch (_error) {
        toast.error('Language system initialization failed');
      }
    };

    init();

    // Subscribe to language changes
    const unsubscribe = onLanguageChange((newLang) => {
      setCurrentLang(newLang);
      // Update document direction for RTL languages
      document.documentElement.dir = getDirection(newLang);
    });

    return unsubscribe;
  }, []);

  const handleLanguageChange = async (languageCode: string) => {
    if (languageCode === currentLang) return;

    setIsLoading(true);
    try {
      await changeLanguage(languageCode);
      toast.success(`Language changed to ${languages.find(l => l.code === languageCode)?.name || languageCode}`);

      // Refresh the page to apply translations (if using server-side translations)
      // Uncomment the next line if you need a full page refresh
      // window.location.reload();
    } catch (_error) {
      toast.error('Failed to change language');
    } finally {
      setIsLoading(false);
    }
  };

  const getCurrentLanguageInfo = (): LanguageInfo | undefined => {
    return languages.find(lang => lang.code === currentLang);
  };

  if (!isInitialized) {
    return <></>;
  }

  // Dropdown variant (default)
  if (variant === 'dropdown') {
    return (
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            size="sm"
            className={`${className} ${isLoading ? 'opacity-50' : ''}`}
            disabled={isLoading}
          >
            <Globe className="h-4 w-4" />
            {showLabel && (
              <span className="ml-2">{getCurrentLanguageInfo()?.nativeName || currentLang}</span>
            )}
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuLabel>Select Language</DropdownMenuLabel>
          <DropdownMenuSeparator />
          {languages.map((lang) => (
            <DropdownMenuItem
              key={lang.code}
              onClick={() => handleLanguageChange(lang.code)}
              className="cursor-pointer"
            >
              <span className="flex items-center justify-between w-full">
                <span className="flex flex-col">
                  <span className="font-medium">{lang.nativeName}</span>
                  <span className="text-xs text-muted-foreground">{lang.name}</span>
                </span>
                {lang.code === currentLang && (
                  <Check className="h-4 w-4 ml-2 text-primary" />
                )}
              </span>
            </DropdownMenuItem>
          ))}
        </DropdownMenuContent>
      </DropdownMenu>
    );
  }

  // Select variant
  if (variant === 'select') {
    return (
      <div className={`flex items-center gap-2 ${className}`}>
        {showLabel && (
          <label htmlFor="language-select" className="text-sm font-medium">
            <Languages className="h-4 w-4 inline mr-1" />
            Language:
          </label>
        )}
        <Select
          value={currentLang}
          onValueChange={handleLanguageChange}
          disabled={isLoading}
        >
          <SelectTrigger id="language-select" className="w-[180px]">
            <SelectValue placeholder="Select language" />
          </SelectTrigger>
          <SelectContent>
            {languages.map((lang) => (
              <SelectItem key={lang.code} value={lang.code}>
                <span className="flex flex-col">
                  <span>{lang.nativeName}</span>
                  {lang.name !== lang.nativeName && (
                    <span className="text-xs text-muted-foreground">{lang.name}</span>
                  )}
                </span>
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>
    );
  }

  // Button variant - cycles through languages
  const handleCycleLanguage = () => {
    const currentIndex = languages.findIndex(lang => lang.code === currentLang);
    const nextIndex = (currentIndex + 1) % languages.length;
    handleLanguageChange(languages[nextIndex].code);
  };

  return (
    <Button
      variant="outline"
      size="sm"
      onClick={handleCycleLanguage}
      disabled={isLoading}
      className={className}
    >
      <Globe className="h-4 w-4" />
      <span className="ml-2">{getCurrentLanguageInfo()?.code.toUpperCase() || 'EN'}</span>
    </Button>
  );
}

// Compact language badge for mobile or tight spaces
export function LanguageBadge(): React.ReactElement {
  const [currentLang, setCurrentLang] = useState<string>('en');

  useEffect(() => {
    const init = async () => {
      await initializeI18n();
      setCurrentLang(getCurrentLanguage());
    };

    init();

    const unsubscribe = onLanguageChange(setCurrentLang);
    return unsubscribe;
  }, []);

  return (
    <div className="flex items-center text-xs text-muted-foreground">
      <Globe className="h-3 w-3 mr-1" />
      {currentLang.toUpperCase()}
    </div>
  );
}

// Hook for using i18n in components
export function useI18n() {
  const [currentLanguage, setCurrentLanguage] = useState<string>('en');
  const [isChanging, setIsChanging] = useState(false);

  useEffect(() => {
    const init = async () => {
      await initializeI18n();
      setCurrentLanguage(getCurrentLanguage());
    };

    init();

    const unsubscribe = onLanguageChange(setCurrentLanguage);
    return unsubscribe;
  }, []);

  const changeLanguageTo = async (languageCode: string) => {
    setIsChanging(true);
    try {
      await changeLanguage(languageCode);
    } finally {
      setIsChanging(false);
    }
  };

  return {
    currentLanguage,
    changeLanguage: changeLanguageTo,
    isChanging,
    languages: getSupportedLanguages(),
    direction: getDirection(currentLanguage),
  };
}