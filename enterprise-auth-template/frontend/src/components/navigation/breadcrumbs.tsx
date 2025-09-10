'use client';

import { Fragment } from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Button } from '@/components/ui/button';
// Mock breadcrumb components for TypeScript compilation
interface BreadcrumbProps extends React.HTMLAttributes<HTMLElement> {
  children: React.ReactNode;
}

interface BreadcrumbLinkProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  children: React.ReactNode;
  asChild?: boolean;
}

const Breadcrumb = ({ children, ...props }: BreadcrumbProps) => <nav {...props}>{children}</nav>;
const BreadcrumbItem = ({ children }: { children: React.ReactNode }) => <span>{children}</span>;
const BreadcrumbLink = ({ children, ...props }: BreadcrumbLinkProps) => <a {...props}>{children}</a>;
const BreadcrumbList = ({ children }: { children: React.ReactNode }) => <div>{children}</div>;
const BreadcrumbPage = ({ children, ...props }: React.HTMLAttributes<HTMLSpanElement> & { children: React.ReactNode }) => <span {...props}>{children}</span>;
const BreadcrumbSeparator = ({ children }: { children?: React.ReactNode }) => <span>{children || '/'}</span>;
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';
import {
  ChevronRight,
  // ChevronDown,
  Home,
  MoreHorizontal,
  ArrowLeft,
} from 'lucide-react';

interface BreadcrumbItemData {
  title: string;
  href?: string;
  icon?: React.ComponentType<React.SVGProps<SVGSVGElement>>;
  disabled?: boolean;
}

interface BreadcrumbsProps {
  items?: BreadcrumbItemData[];
  showHomeIcon?: boolean;
  showBackButton?: boolean;
  maxItems?: number;
  className?: string;
  onBackClick?: () => void;
  separator?: 'chevron' | 'slash' | 'dot';
}

// Default breadcrumb mappings based on pathname
const getDefaultBreadcrumbs = (pathname: string): BreadcrumbItemData[] => {
  const segments = pathname.split('/').filter(Boolean);
  const breadcrumbs: BreadcrumbItemData[] = [];

  // Always start with home
  breadcrumbs.push({ title: 'Home', href: '/dashboard', icon: Home });

  let currentPath = '';
  segments.forEach((segment, index) => {
    currentPath += `/${segment}`;
    
    // Generate human-readable titles
    let title = segment
      .split('-')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ');

    // Custom title mappings
    const titleMappings: Record<string, string> = {
      'admin': 'Administration',
      'auth': 'Authentication',
      'api': 'API',
      '2fa': 'Two-Factor Auth',
      'api-keys': 'API Keys',
      'audit-logs': 'Audit Logs',
      'user-guide': 'User Guide',
      'magic-link': 'Magic Link',
      'webauthn-setup': 'WebAuthn Setup',
    };

    title = titleMappings[segment] || title;

    // Don't add href for the last item (current page)
    const href = index === segments.length - 1 ? undefined : currentPath;
    
    breadcrumbs.push({
      title,
      ...(href ? { href } : {}),
    });
  });

  return breadcrumbs;
};

export function Breadcrumbs({
  items,
  showHomeIcon = true,
  showBackButton = false,
  maxItems = 3,
  className,
  onBackClick,
  separator = 'chevron',
}: BreadcrumbsProps) {
  const pathname = usePathname();
  
  // Use provided items or generate from pathname
  const breadcrumbItems = items || getDefaultBreadcrumbs(pathname);
  
  // If we have more items than maxItems, collapse middle items
  const shouldCollapse = breadcrumbItems.length > maxItems;
  const visibleItems = shouldCollapse
    ? [
        breadcrumbItems[0]!, // First item (usually Home)
        ...breadcrumbItems.slice(-2), // Last 2 items
      ].filter(Boolean)
    : breadcrumbItems;
  
  const collapsedItems = shouldCollapse
    ? breadcrumbItems.slice(1, -2) // Middle items
    : [];

  const getSeparatorIcon = () => {
    switch (separator) {
      case 'slash':
        return '/';
      case 'dot':
        return '·';
      default:
        return <ChevronRight className="h-4 w-4" />;
    }
  };

  const handleBackClick = () => {
    if (onBackClick) {
      onBackClick();
    } else {
      window.history.back();
    }
  };

  if (!breadcrumbItems.length) {
    return null;
  }

  return (
    <div className={cn('flex items-center gap-2', className)}>
      {/* Back Button */}
      {showBackButton && (
        <Button
          variant="ghost"
          size="sm"
          onClick={handleBackClick}
          className="flex items-center gap-1 px-2"
        >
          <ArrowLeft className="h-4 w-4" />
          <span className="hidden sm:inline">Back</span>
        </Button>
      )}

      {/* Breadcrumbs */}
      <Breadcrumb>
        <BreadcrumbList>
          {visibleItems.map((item, index) => {
            const isLast = index === visibleItems.length - 1;
            const Icon = item.icon;

            return (
              <Fragment key={`${item.title}-${index}`}>
                <BreadcrumbItem>
                  {isLast || !item.href ? (
                    <BreadcrumbPage className="flex items-center gap-1.5">
                      {Icon && index === 0 && showHomeIcon && (
                        <Icon className="h-4 w-4" />
                      )}
                      <span className="max-w-20 truncate sm:max-w-none">
                        {item.title}
                      </span>
                    </BreadcrumbPage>
                  ) : (
                    <BreadcrumbLink
                      asChild
                      className={cn(
                        'flex items-center gap-1.5',
                        item.disabled && 'pointer-events-none opacity-50'
                      )}
                    >
                      <Link href={item.href}>
                        {Icon && index === 0 && showHomeIcon && (
                          <Icon className="h-4 w-4" />
                        )}
                        <span className="max-w-20 truncate sm:max-w-none">
                          {item.title}
                        </span>
                      </Link>
                    </BreadcrumbLink>
                  )}
                </BreadcrumbItem>

                {/* Collapsed Items Dropdown */}
                {index === 0 && collapsedItems.length > 0 && (
                  <>
                    <BreadcrumbSeparator>
                      {getSeparatorIcon()}
                    </BreadcrumbSeparator>
                    <BreadcrumbItem>
                      <DropdownMenu>
                        <DropdownMenuTrigger className="flex h-9 w-9 items-center justify-center">
                          <MoreHorizontal className="h-4 w-4" />
                          <span className="sr-only">More</span>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="start">
                          {collapsedItems.map((collapsedItem) => (
                            <DropdownMenuItem key={collapsedItem.title} asChild>
                              <Link href={collapsedItem.href || '#'}>
                                {collapsedItem.title}
                              </Link>
                            </DropdownMenuItem>
                          ))}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </BreadcrumbItem>
                  </>
                )}

                {!isLast && (
                  <BreadcrumbSeparator>
                    {getSeparatorIcon()}
                  </BreadcrumbSeparator>
                )}
              </Fragment>
            );
          })}
        </BreadcrumbList>
      </Breadcrumb>
    </div>
  );
}

// Enhanced breadcrumbs with page actions
interface PageBreadcrumbsProps extends BreadcrumbsProps {
  title?: string;
  description?: string;
  actions?: React.ReactNode;
}

export function PageBreadcrumbs({
  title,
  description,
  actions,
  ...breadcrumbProps
}: PageBreadcrumbsProps) {
  return (
    <div className="space-y-4">
      <Breadcrumbs {...breadcrumbProps} />
      
      {(title || description || actions) && (
        <div className="flex items-center justify-between">
          <div className="space-y-1">
            {title && (
              <h1 className="text-2xl font-bold tracking-tight">{title}</h1>
            )}
            {description && (
              <p className="text-muted-foreground">{description}</p>
            )}
          </div>
          {actions && (
            <div className="flex items-center gap-2">
              {actions}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// Simple breadcrumb component for common use cases
interface SimpleBreadcrumbsProps {
  pages: Array<{ name: string; href?: string }>;
  className?: string;
}

export function SimpleBreadcrumbs({ pages, className }: SimpleBreadcrumbsProps) {
  return (
    <nav className={cn('flex', className)} aria-label="Breadcrumb">
      <ol className="flex items-center space-x-2 text-sm">
        {pages.map((page, index) => (
          <li key={page.name} className="flex items-center">
            {index > 0 && (
              <ChevronRight className="h-4 w-4 text-muted-foreground mx-2 flex-shrink-0" />
            )}
            {page.href ? (
              <Link
                href={page.href}
                className="text-muted-foreground hover:text-foreground transition-colors"
              >
                {page.name}
              </Link>
            ) : (
              <span className="text-foreground font-medium">{page.name}</span>
            )}
          </li>
        ))}
      </ol>
    </nav>
  );
}

// Hook to generate breadcrumbs from current route
export function useBreadcrumbs() {
  const pathname = usePathname();
  return getDefaultBreadcrumbs(pathname);
}