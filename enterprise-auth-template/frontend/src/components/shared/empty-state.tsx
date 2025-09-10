'use client';

import { ReactNode } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { cn } from '@/lib/utils';
import { 
  FileX, 
  Search, 
  Users, 
  Plus, 
  RefreshCw,
  AlertTriangle,
  Inbox,
  Database,
  Settings,
  Shield,
} from 'lucide-react';

interface EmptyStateProps {
  icon?: 'file' | 'search' | 'users' | 'inbox' | 'database' | 'settings' | 'shield' | 'error';
  title: string;
  description: string;
  action?: {
    label: string;
    onClick: () => void;
    variant?: 'default' | 'outline' | 'secondary';
    icon?: ReactNode;
  };
  secondaryAction?: {
    label: string;
    onClick: () => void;
    variant?: 'default' | 'outline' | 'secondary';
    icon?: ReactNode;
  };
  className?: string;
  size?: 'sm' | 'md' | 'lg';
}

const iconMap = {
  file: FileX,
  search: Search,
  users: Users,
  inbox: Inbox,
  database: Database,
  settings: Settings,
  shield: Shield,
  error: AlertTriangle,
};

const sizeConfig = {
  sm: {
    iconSize: 'h-8 w-8',
    titleSize: 'text-lg',
    padding: 'p-8',
  },
  md: {
    iconSize: 'h-12 w-12',
    titleSize: 'text-xl',
    padding: 'p-12',
  },
  lg: {
    iconSize: 'h-16 w-16',
    titleSize: 'text-2xl',
    padding: 'p-16',
  },
};

export function EmptyState({
  icon = 'file',
  title,
  description,
  action,
  secondaryAction,
  className,
  size = 'md',
}: EmptyStateProps) {
  const IconComponent = iconMap[icon];
  const config = sizeConfig[size];

  return (
    <Card className={cn('border-dashed', className)}>
      <CardContent className={cn('text-center', config.padding)}>
        <div className="mx-auto mb-4 flex items-center justify-center">
          <IconComponent className={cn(config.iconSize, 'text-muted-foreground')} />
        </div>
        
        <h3 className={cn('font-semibold text-foreground mb-2', config.titleSize)}>
          {title}
        </h3>
        
        <p className="text-muted-foreground mb-6 max-w-md mx-auto">
          {description}
        </p>
        
        {(action || secondaryAction) && (
          <div className="flex flex-col sm:flex-row gap-3 justify-center">
            {action && (
              <Button
                onClick={action.onClick}
                variant={action.variant || 'default'}
                className="min-w-32"
              >
                {action.icon}
                {action.label}
              </Button>
            )}
            
            {secondaryAction && (
              <Button
                onClick={secondaryAction.onClick}
                variant={secondaryAction.variant || 'outline'}
                className="min-w-32"
              >
                {secondaryAction.icon}
                {secondaryAction.label}
              </Button>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

// Pre-configured empty state components for common use cases
export function NoDataFound({ 
  entity = 'data',
  onRefresh,
  onCreate,
}: { 
  entity?: string; 
  onRefresh?: () => void;
  onCreate?: () => void;
}) {
  return (
    <EmptyState
      icon="database"
      title={`No ${entity} found`}
      description={`There are no ${entity} items to display at the moment.`}
      {...(onCreate ? {
        action: {
          label: `Add ${entity}`,
          onClick: onCreate,
          icon: <Plus className="h-4 w-4 mr-2" />,
        },
      } : {})}
      {...(onRefresh ? {
        secondaryAction: {
          label: 'Refresh',
          onClick: onRefresh,
          variant: 'outline' as const,
          icon: <RefreshCw className="h-4 w-4 mr-2" />,
        },
      } : {})}
    />
  );
}

export function NoSearchResults({ 
  searchTerm,
  onClearSearch,
}: { 
  searchTerm: string;
  onClearSearch: () => void;
}) {
  return (
    <EmptyState
      icon="search"
      title="No results found"
      description={`We couldn't find any results for "${searchTerm}". Try adjusting your search terms.`}
      action={{
        label: 'Clear search',
        onClick: onClearSearch,
        variant: 'outline',
        icon: <RefreshCw className="h-4 w-4 mr-2" />,
      }}
    />
  );
}

export function AccessDenied({ 
  resource = 'this resource',
  onContactSupport,
}: { 
  resource?: string;
  onContactSupport?: () => void;
}) {
  return (
    <EmptyState
      icon="shield"
      title="Access Denied"
      description={`You don't have permission to view ${resource}. Contact your administrator if you believe this is an error.`}
      {...(onContactSupport ? {
        action: {
          label: 'Contact Support',
          onClick: onContactSupport,
          variant: 'outline',
        },
      } : {})}
    />
  );
}

export function LoadingError({ 
  error,
  onRetry,
}: { 
  error: string;
  onRetry: () => void;
}) {
  return (
    <EmptyState
      icon="error"
      title="Something went wrong"
      description={error || 'An unexpected error occurred while loading the data.'}
      action={{
        label: 'Try again',
        onClick: onRetry,
        icon: <RefreshCw className="h-4 w-4 mr-2" />,
      }}
    />
  );
}

export function EmptyInbox({ 
  onRefresh,
}: { 
  onRefresh?: () => void;
}) {
  return (
    <EmptyState
      icon="inbox"
      title="Your inbox is empty"
      description="You're all caught up! Check back later for new messages."
      {...(onRefresh ? {
        action: {
          label: 'Refresh',
          onClick: onRefresh,
          variant: 'outline',
          icon: <RefreshCw className="h-4 w-4 mr-2" />,
        },
      } : {})}
      size="sm"
    />
  );
}