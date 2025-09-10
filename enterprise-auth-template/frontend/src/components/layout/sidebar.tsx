'use client';

import { useState } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
// Mock collapsible components for TypeScript compilation
interface CollapsibleProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  disabled?: boolean;
}

const Collapsible = ({ children, ...props }: CollapsibleProps) => <div {...props}>{children}</div>;
const CollapsibleContent = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
const CollapsibleTrigger = ({ children, ...props }: React.ButtonHTMLAttributes<HTMLButtonElement> & { children: React.ReactNode; asChild?: boolean }) => <button {...props}>{children}</button>;
import { cn } from '@/lib/utils';
import {
  LayoutDashboard,
  Users,
  Settings,
  Shield,
  // Activity,
  Bell,
  HelpCircle,
  ChevronDown,
  ChevronRight,
  User,
  Key,
  FileText,
  BarChart3,
  Zap,
} from 'lucide-react';

interface SidebarProps {
  className?: string;
  collapsed?: boolean;
  onCollapsedChange?: (collapsed: boolean) => void;
}

interface NavItem {
  title: string;
  href?: string;
  icon: React.ComponentType<React.SVGProps<SVGSVGElement>>;
  badge?: string;
  children?: NavItem[];
  permission?: string;
}

// TODO: Filter navigation items based on user permissions
const navigationItems: NavItem[] = [
  {
    title: 'Dashboard',
    href: '/dashboard',
    icon: LayoutDashboard,
  },
  {
    title: 'Profile',
    href: '/profile',
    icon: User,
  },
  {
    title: 'Analytics',
    href: '/analytics',
    icon: BarChart3,
    permission: 'analytics:read',
  },
  {
    title: 'Administration',
    icon: Shield,
    permission: 'admin:read',
    children: [
      {
        title: 'Users',
        href: '/admin/users',
        icon: Users,
        permission: 'users:read',
      },
      {
        title: 'Roles',
        href: '/admin/roles',
        icon: Key,
        permission: 'roles:read',
      },
      {
        title: 'Audit Logs',
        href: '/admin/audit-logs',
        icon: FileText,
        permission: 'audit:read',
      },
      {
        title: 'Settings',
        href: '/admin/settings',
        icon: Settings,
        permission: 'admin:write',
      },
    ],
  },
  {
    title: 'Settings',
    icon: Settings,
    children: [
      {
        title: 'Profile',
        href: '/settings',
        icon: User,
      },
      {
        title: 'Security',
        href: '/settings/security',
        icon: Shield,
      },
      {
        title: 'Notifications',
        href: '/settings/notifications',
        icon: Bell,
      },
      {
        title: 'API Keys',
        href: '/settings/api-keys',
        icon: Key,
      },
    ],
  },
  {
    title: 'Notifications',
    href: '/notifications',
    icon: Bell,
    badge: '3', // TODO: Get actual unread count from store/API
  },
  {
    title: 'Help',
    href: '/help',
    icon: HelpCircle,
  },
];

export function Sidebar({ className, collapsed = false, onCollapsedChange }: SidebarProps) {
  const pathname = usePathname();
  const [openItems, setOpenItems] = useState<string[]>(['Administration', 'Settings']);

  const toggleItem = (title: string) => {
    setOpenItems(prev =>
      prev.includes(title)
        ? prev.filter(item => item !== title)
        : [...prev, title]
    );
  };

  const renderNavItem = (item: NavItem, depth = 0) => {
    const Icon = item.icon;
    const isActive = item.href ? pathname === item.href : false;
    const hasChildren = item.children && item.children.length > 0;
    const isOpen = openItems.includes(item.title);

    if (hasChildren) {
      return (
        <Collapsible key={item.title} open={isOpen} onOpenChange={() => toggleItem(item.title)}>
          <CollapsibleTrigger asChild>
            <Button
              variant="ghost"
              className={cn(
                'w-full justify-start gap-2 h-10',
                depth > 0 && 'ml-4 w-[calc(100%-1rem)]',
                collapsed && 'justify-center'
              )}
            >
              <Icon className="h-4 w-4 flex-shrink-0" />
              {!collapsed && (
                <>
                  <span className="flex-1 text-left">{item.title}</span>
                  {isOpen ? (
                    <ChevronDown className="h-4 w-4" />
                  ) : (
                    <ChevronRight className="h-4 w-4" />
                  )}
                </>
              )}
            </Button>
          </CollapsibleTrigger>
          {!collapsed && (
            <CollapsibleContent className="space-y-1">
              {item.children?.map(child => renderNavItem(child, depth + 1))}
            </CollapsibleContent>
          )}
        </Collapsible>
      );
    }

    if (!item.href) return null;

    return (
      <Button
        key={item.title}
        variant={isActive ? 'secondary' : 'ghost'}
        className={cn(
          'w-full justify-start gap-2 h-10',
          depth > 0 && 'ml-4 w-[calc(100%-1rem)]',
          collapsed && 'justify-center',
          isActive && 'bg-accent text-accent-foreground'
        )}
        asChild
      >
        <Link href={item.href}>
          <Icon className="h-4 w-4 flex-shrink-0" />
          {!collapsed && (
            <>
              <span className="flex-1 text-left">{item.title}</span>
              {item.badge && (
                <Badge variant="secondary" className="ml-auto text-xs">
                  {item.badge}
                </Badge>
              )}
            </>
          )}
        </Link>
      </Button>
    );
  };

  return (
    <div className={cn('flex flex-col h-full bg-background border-r', className)}>
      {/* Header */}
      <div className="p-4 border-b">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
            <Zap className="h-4 w-4 text-primary-foreground" />
          </div>
          {!collapsed && (
            <div>
              <h2 className="text-lg font-semibold">Enterprise Auth</h2>
              <p className="text-xs text-muted-foreground">Admin Panel</p>
            </div>
          )}
        </div>
      </div>

      {/* Navigation */}
      <ScrollArea className="flex-1 p-4">
        <nav className="space-y-1">
          {navigationItems.map(item => renderNavItem(item))}
        </nav>
      </ScrollArea>

      {/* Footer */}
      <div className="p-4 border-t">
        <Separator className="mb-4" />
        {!collapsed && (
          <div className="space-y-2">
            <div className="text-xs text-muted-foreground">
              Version 1.0.0
            </div>
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-green-500" />
              <span className="text-xs text-muted-foreground">All systems operational</span>
            </div>
          </div>
        )}
        
        {/* Collapse Toggle */}
        <Button
          variant="ghost"
          size="sm"
          className="w-full mt-2"
          onClick={() => onCollapsedChange?.(!collapsed)}
        >
          <ChevronRight className={cn('h-4 w-4 transition-transform', !collapsed && 'rotate-180')} />
          {!collapsed && <span className="ml-2">Collapse</span>}
        </Button>
      </div>
    </div>
  );
}