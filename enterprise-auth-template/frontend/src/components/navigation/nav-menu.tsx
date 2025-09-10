'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
// Mock navigation-menu components for TypeScript compilation
interface NavigationMenuProps extends React.HTMLAttributes<HTMLElement> {
  children: React.ReactNode;
  orientation?: 'horizontal' | 'vertical';
  value?: string;
  onValueChange?: (value: string) => void;
}

interface NavigationMenuLinkProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  children: React.ReactNode;
  asChild?: boolean;
  active?: boolean;
}

const NavigationMenu = ({ children, ...props }: NavigationMenuProps) => <nav {...props}>{children}</nav>;
const NavigationMenuContent = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
const NavigationMenuItem = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
const NavigationMenuLink = ({ children, ...props }: NavigationMenuLinkProps) => <a {...props}>{children}</a>;
const NavigationMenuList = ({ children, ...props }: React.HTMLAttributes<HTMLUListElement> & { children: React.ReactNode }) => <ul {...props}>{children}</ul>;
const NavigationMenuTrigger = ({ children, ...props }: React.ButtonHTMLAttributes<HTMLButtonElement> & { children: React.ReactNode }) => <button {...props}>{children}</button>;
const navigationMenuTriggerStyle = () => 'trigger-style';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  Settings,
  Shield,
  // Activity,
  Bell,
  HelpCircle,
  Menu,
  X,
  User,
  Key,
  FileText,
  BarChart3,
  ChevronDown,
} from 'lucide-react';

interface NavItem {
  title: string;
  href?: string;
  description?: string;
  icon?: React.ComponentType<React.SVGProps<SVGSVGElement>>;
  badge?: string;
  children?: NavItem[];
  external?: boolean;
}

const navigationItems: NavItem[] = [
  {
    title: 'Dashboard',
    href: '/dashboard',
    description: 'Overview and key metrics',
    icon: LayoutDashboard,
  },
  {
    title: 'Administration',
    description: 'Manage users, roles, and system settings',
    icon: Shield,
    children: [
      {
        title: 'Users',
        href: '/admin/users',
        description: 'Manage user accounts and permissions',
        icon: Users,
      },
      {
        title: 'Roles & Permissions',
        href: '/admin/roles',
        description: 'Configure access control and permissions',
        icon: Key,
      },
      {
        title: 'Audit Logs',
        href: '/admin/audit-logs',
        description: 'View system activity and security events',
        icon: FileText,
      },
      {
        title: 'System Settings',
        href: '/admin/settings',
        description: 'Configure global system settings',
        icon: Settings,
      },
    ],
  },
  {
    title: 'Analytics',
    href: '/analytics',
    description: 'Platform usage and performance metrics',
    icon: BarChart3,
  },
  {
    title: 'Settings',
    description: 'Personal and account settings',
    icon: Settings,
    children: [
      {
        title: 'Profile',
        href: '/settings',
        description: 'Update your personal information',
        icon: User,
      },
      {
        title: 'Security',
        href: '/settings/security',
        description: 'Password and authentication settings',
        icon: Shield,
      },
      {
        title: 'Notifications',
        href: '/settings/notifications',
        description: 'Configure notification preferences',
        icon: Bell,
      },
      {
        title: 'API Keys',
        href: '/settings/api-keys',
        description: 'Manage your API access keys',
        icon: Key,
      },
    ],
  },
  {
    title: 'Help',
    href: '/help',
    description: 'Documentation and support',
    icon: HelpCircle,
  },
];

interface NavMenuProps {
  className?: string;
  onNavigate?: (href: string) => void;
}

export function NavMenu({ className, onNavigate }: NavMenuProps) {
  const pathname = usePathname();

  const isActive = (href?: string) => {
    if (!href) return false;
    return pathname === href || pathname.startsWith(href + '/');
  };

  const handleNavigate = (href: string) => {
    onNavigate?.(href);
  };

  return (
    <NavigationMenu className={className}>
      <NavigationMenuList>
        {navigationItems.map((item) => (
          <NavigationMenuItem key={item.title}>
            {item.children ? (
              <>
                <NavigationMenuTrigger className="flex items-center gap-2">
                  {item.icon && <item.icon className="h-4 w-4" />}
                  {item.title}
                  {item.badge && (
                    <Badge variant="secondary" className="text-xs">
                      {item.badge}
                    </Badge>
                  )}
                </NavigationMenuTrigger>
                <NavigationMenuContent>
                  <div className="grid gap-3 p-4 w-80">
                    <div className="grid gap-1">
                      <div className="flex items-center gap-2 text-sm font-medium">
                        {item.icon && <item.icon className="h-4 w-4" />}
                        {item.title}
                      </div>
                      {item.description && (
                        <p className="text-xs text-muted-foreground">
                          {item.description}
                        </p>
                      )}
                    </div>
                    <Separator />
                    <div className="grid gap-2">
                      {item.children.map((child) => (
                        <Link
                          key={child.href}
                          href={child.href!}
                          onClick={() => handleNavigate(child.href!)}
                        >
                          <NavigationMenuLink
                            className={cn(
                              'flex items-start gap-3 p-3 rounded-lg hover:bg-accent hover:text-accent-foreground transition-colors',
                              isActive(child.href) && 'bg-accent text-accent-foreground'
                            )}
                          >
                            {child.icon && (
                              <child.icon className="h-4 w-4 mt-0.5 flex-shrink-0" />
                            )}
                            <div className="grid gap-1">
                              <div className="text-sm font-medium">{child.title}</div>
                              {child.description && (
                                <div className="text-xs text-muted-foreground">
                                  {child.description}
                                </div>
                              )}
                            </div>
                            {child.badge && (
                              <Badge variant="secondary" className="text-xs ml-auto">
                                {child.badge}
                              </Badge>
                            )}
                          </NavigationMenuLink>
                        </Link>
                      ))}
                    </div>
                  </div>
                </NavigationMenuContent>
              </>
            ) : (
              <Link href={item.href!} onClick={() => handleNavigate(item.href!)}>
                <NavigationMenuLink
                  className={cn(
                    navigationMenuTriggerStyle(),
                    'flex items-center gap-2',
                    isActive(item.href) && 'bg-accent text-accent-foreground'
                  )}
                >
                  {item.icon && <item.icon className="h-4 w-4" />}
                  {item.title}
                  {item.badge && (
                    <Badge variant="secondary" className="text-xs">
                      {item.badge}
                    </Badge>
                  )}
                </NavigationMenuLink>
              </Link>
            )}
          </NavigationMenuItem>
        ))}
      </NavigationMenuList>
    </NavigationMenu>
  );
}

// Mobile navigation menu
interface MobileNavMenuProps {
  trigger?: React.ReactNode;
  onNavigate?: (href: string) => void;
}

export function MobileNavMenu({ trigger, onNavigate }: MobileNavMenuProps) {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();

  const isActive = (href?: string) => {
    if (!href) return false;
    return pathname === href || pathname.startsWith(href + '/');
  };

  const handleNavigate = (href: string) => {
    setOpen(false);
    onNavigate?.(href);
  };

  const renderNavItem = (item: NavItem, depth = 0) => {
    if (item.children) {
      return (
        <div key={item.title} className="space-y-2">
          <div className={cn('flex items-center gap-2 p-3 text-sm font-medium', depth > 0 && 'ml-4')}>
            {item.icon && <item.icon className="h-4 w-4" />}
            {item.title}
            {item.badge && (
              <Badge variant="secondary" className="text-xs">
                {item.badge}
              </Badge>
            )}
          </div>
          <div className="space-y-1">
            {item.children.map(child => renderNavItem(child, depth + 1))}
          </div>
        </div>
      );
    }

    return (
      <Link
        key={item.href}
        href={item.href!}
        onClick={() => handleNavigate(item.href!)}
      >
        <Button
          variant={isActive(item.href) ? 'secondary' : 'ghost'}
          className={cn(
            'w-full justify-start gap-2',
            depth > 0 && 'ml-4 w-[calc(100%-1rem)]'
          )}
        >
          {item.icon && <item.icon className="h-4 w-4" />}
          <span className="flex-1 text-left">{item.title}</span>
          {item.badge && (
            <Badge variant="secondary" className="text-xs">
              {item.badge}
            </Badge>
          )}
        </Button>
      </Link>
    );
  };

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        {trigger || (
          <Button variant="ghost" size="icon" className="lg:hidden">
            <Menu className="h-5 w-5" />
          </Button>
        )}
      </SheetTrigger>
      <SheetContent side="left" className="w-72">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold">Navigation</h2>
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setOpen(false)}
            className="h-6 w-6"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
        
        <Separator className="mb-4" />
        
        <nav className="space-y-2">
          {navigationItems.map(item => renderNavItem(item))}
        </nav>
        
        <Separator className="my-4" />
        
        <div className="space-y-2">
          <div className="text-xs text-muted-foreground px-3">
            Quick Actions
          </div>
          <Link href="/notifications">
            <Button variant="ghost" className="w-full justify-start gap-2">
              <Bell className="h-4 w-4" />
              <span className="flex-1 text-left">Notifications</span>
              <Badge variant="secondary" className="text-xs">3</Badge>
            </Button>
          </Link>
          <Link href="/profile">
            <Button variant="ghost" className="w-full justify-start gap-2">
              <User className="h-4 w-4" />
              Profile
            </Button>
          </Link>
        </div>
      </SheetContent>
    </Sheet>
  );
}

// Breadcrumb navigation component
interface BreadcrumbItem {
  title: string;
  href?: string;
}

interface BreadcrumbNavProps {
  items: BreadcrumbItem[];
  className?: string;
}

export function BreadcrumbNav({ items, className }: BreadcrumbNavProps) {
  return (
    <nav className={cn('flex items-center space-x-2 text-sm', className)}>
      {items.map((item, index) => (
        <div key={index} className="flex items-center">
          {index > 0 && (
            <ChevronDown className="h-4 w-4 rotate-[-90deg] text-muted-foreground mx-2" />
          )}
          {item.href ? (
            <Link
              href={item.href}
              className="text-muted-foreground hover:text-foreground transition-colors"
            >
              {item.title}
            </Link>
          ) : (
            <span className="text-foreground font-medium">{item.title}</span>
          )}
        </div>
      ))}
    </nav>
  );
}