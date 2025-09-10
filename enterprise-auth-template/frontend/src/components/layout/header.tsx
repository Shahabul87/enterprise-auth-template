'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
// import { Input } from '@/components/ui/input';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
// Mock command components for TypeScript compilation
interface CommandProps extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

interface CommandInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  placeholder?: string;
  value?: string;
  onValueChange?: (value: string) => void;
}

const CommandDialog = ({ children, ...props }: CommandProps) => <div {...props}>{children}</div>;
const CommandEmpty = ({ children }: { children?: React.ReactNode }) => <div>{children || 'No results found.'}</div>;
const CommandGroup = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode; heading?: string }) => <div {...props}>{children}</div>;
const CommandInput = ({ ...props }: CommandInputProps) => <input {...props} />;
const CommandItem = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode; value?: string; onSelect?: () => void }) => <div {...props}>{children}</div>;
const CommandList = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
import { useRequireAuth } from '@/stores/auth.store';
import {
  Search,
  Bell,
  Settings,
  User,
  LogOut,
  Menu,
  Command,
  Shield,
  HelpCircle,
  Moon,
  Sun,
  Monitor,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface HeaderProps {
  className?: string;
  onMenuToggle?: () => void;
  showMenuToggle?: boolean;
}

interface SearchResult {
  id: string;
  title: string;
  description: string;
  href: string;
  type: 'page' | 'user' | 'setting';
}

// TODO: Replace with actual search results from API
const mockSearchResults: SearchResult[] = [
  {
    id: '1',
    title: 'Dashboard',
    description: 'Main dashboard overview',
    href: '/dashboard',
    type: 'page',
  },
  {
    id: '2',
    title: 'User Management',
    description: 'Manage system users',
    href: '/admin/users',
    type: 'page',
  },
  {
    id: '3',
    title: 'Security Settings',
    description: 'Configure security options',
    href: '/settings/security',
    type: 'setting',
  },
  {
    id: '4',
    title: 'Profile Settings',
    description: 'Update your profile information',
    href: '/settings',
    type: 'setting',
  },
  {
    id: '5',
    title: 'Analytics Dashboard',
    description: 'View platform analytics',
    href: '/analytics',
    type: 'page',
  },
];

export function Header({ className, onMenuToggle, showMenuToggle = true }: HeaderProps) {
  const router = useRouter();
  const { user, logout } = useRequireAuth();
  const [open, setOpen] = useState(false);
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [notifications] = useState(3); // TODO: Get from notifications store
  const [theme, setTheme] = useState<'light' | 'dark' | 'system'>('system');

  const handleSearch = (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }

    // TODO: Implement actual search API call
    const filtered = mockSearchResults.filter(
      result =>
        result.title.toLowerCase().includes(query.toLowerCase()) ||
        result.description.toLowerCase().includes(query.toLowerCase())
    );
    setSearchResults(filtered);
  };

  const handleSearchSelect = (href: string) => {
    setOpen(false);
    router.push(href);
  };

  const handleLogout = async () => {
    try {
      await logout();
      router.push('/auth/login');
    } catch {
      // Logout errors are handled gracefully by auth store
    }
  };

  const toggleTheme = () => {
    const nextTheme = theme === 'light' ? 'dark' : theme === 'dark' ? 'system' : 'light';
    setTheme(nextTheme);
    // TODO: Implement actual theme switching logic
    
  };

  const getThemeIcon = () => {
    switch (theme) {
      case 'light':
        return <Sun className="h-4 w-4" />;
      case 'dark':
        return <Moon className="h-4 w-4" />;
      default:
        return <Monitor className="h-4 w-4" />;
    }
  };

  if (!user) {
    return null; // Don't render header if no user
  }

  return (
    <>
      <header className={cn('border-b bg-background', className)}>
        <div className="flex h-16 items-center gap-4 px-4 lg:px-6">
          {/* Menu Toggle */}
          {showMenuToggle && (
            <>
              <Button variant="ghost" size="icon" onClick={onMenuToggle} className="lg:hidden">
                <Menu className="h-5 w-5" />
              </Button>
              <Separator orientation="vertical" className="h-6 lg:hidden" />
            </>
          )}

          {/* Search */}
          <div className="flex-1 max-w-md">
            <Button
              variant="outline"
              className="relative w-full justify-start text-muted-foreground"
              onClick={() => setOpen(true)}
            >
              <Search className="mr-2 h-4 w-4" />
              <span>Search...</span>
              <kbd className="pointer-events-none absolute right-2 top-2 hidden h-5 select-none items-center gap-1 rounded border bg-muted px-1.5 font-mono text-[10px] font-medium opacity-100 sm:flex">
                <Command className="h-3 w-3" />K
              </kbd>
            </Button>
          </div>

          <div className="flex items-center gap-2">
            {/* Theme Toggle */}
            <Button variant="ghost" size="icon" onClick={toggleTheme} className="hidden sm:flex">
              {getThemeIcon()}
            </Button>

            {/* Notifications */}
            <Button variant="ghost" size="icon" className="relative" asChild>
              <Link href="/notifications">
                <Bell className="h-5 w-5" />
                {notifications > 0 && (
                  <Badge className="absolute -top-1 -right-1 h-5 w-5 rounded-full p-0 text-xs">
                    {notifications > 9 ? '9+' : notifications}
                  </Badge>
                )}
              </Link>
            </Button>

            <Separator orientation="vertical" className="h-6" />

            {/* User Menu */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" className="relative h-10 w-10 rounded-full">
                  <Avatar className="h-9 w-9">
                    <AvatarImage src={undefined} alt={user.first_name || 'User'} />
                    <AvatarFallback>
                      {user.first_name?.charAt(0)?.toUpperCase()}
                      {user.last_name?.charAt(0)?.toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent className="w-56" align="end" forceMount>
                <DropdownMenuLabel className="font-normal">
                  <div className="flex flex-col space-y-1">
                    <p className="text-sm font-medium leading-none">
                      {user.first_name} {user.last_name}
                    </p>
                    <p className="text-xs leading-none text-muted-foreground">{user.email}</p>
                    {user.is_superuser && (
                      <Badge variant="secondary" className="w-fit text-xs">
                        Administrator
                      </Badge>
                    )}
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                
                <DropdownMenuItem asChild>
                  <Link href="/profile">
                    <User className="mr-2 h-4 w-4" />
                    Profile
                  </Link>
                </DropdownMenuItem>
                
                <DropdownMenuItem asChild>
                  <Link href="/settings">
                    <Settings className="mr-2 h-4 w-4" />
                    Settings
                  </Link>
                </DropdownMenuItem>
                
                <DropdownMenuItem asChild>
                  <Link href="/settings/security">
                    <Shield className="mr-2 h-4 w-4" />
                    Security
                  </Link>
                </DropdownMenuItem>
                
                <DropdownMenuSeparator />
                
                <DropdownMenuItem className="sm:hidden" onClick={toggleTheme}>
                  {getThemeIcon()}
                  <span className="ml-2">
                    Theme: {theme.charAt(0).toUpperCase() + theme.slice(1)}
                  </span>
                </DropdownMenuItem>
                
                <DropdownMenuItem asChild>
                  <Link href="/help">
                    <HelpCircle className="mr-2 h-4 w-4" />
                    Help & Support
                  </Link>
                </DropdownMenuItem>
                
                <DropdownMenuSeparator />
                
                <DropdownMenuItem onClick={handleLogout}>
                  <LogOut className="mr-2 h-4 w-4" />
                  Sign out
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>

      {/* Command Dialog for Search */}
      <CommandDialog open={open} onOpenChange={setOpen}>
        <CommandInput
          placeholder="Search for pages, users, settings..."
          onValueChange={handleSearch}
        />
        <CommandList>
          <CommandEmpty>No results found.</CommandEmpty>
          {searchResults.length > 0 && (
            <CommandGroup heading="Results">
              {searchResults.map(result => (
                <CommandItem
                  key={result.id}
                  value={result.title}
                  onSelect={() => handleSearchSelect(result.href)}
                >
                  <div className="flex items-center gap-2">
                    {result.type === 'page' && <Search className="h-4 w-4" />}
                    {result.type === 'user' && <User className="h-4 w-4" />}
                    {result.type === 'setting' && <Settings className="h-4 w-4" />}
                    <div>
                      <div className="text-sm font-medium">{result.title}</div>
                      <div className="text-xs text-muted-foreground">{result.description}</div>
                    </div>
                  </div>
                </CommandItem>
              ))}
            </CommandGroup>
          )}
        </CommandList>
      </CommandDialog>
    </>
  );
}