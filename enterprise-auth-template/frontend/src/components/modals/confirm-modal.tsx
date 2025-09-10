'use client';

import { ReactNode, useState } from 'react';
// Mock alert-dialog components for TypeScript compilation
interface AlertDialogProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

interface AlertDialogButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  asChild?: boolean;
}

const AlertDialog = ({ children, ...props }: AlertDialogProps) => <div {...props}>{children}</div>;
const AlertDialogAction = ({ children, ...props }: AlertDialogButtonProps) => <button {...props}>{children}</button>;
const AlertDialogCancel = ({ children, ...props }: AlertDialogButtonProps) => <button {...props}>{children}</button>;
const AlertDialogContent = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
const AlertDialogDescription = ({ children, ...props }: React.HTMLAttributes<HTMLParagraphElement> & { children: React.ReactNode }) => <p {...props}>{children}</p>;
const AlertDialogFooter = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
const AlertDialogHeader = ({ children, ...props }: React.HTMLAttributes<HTMLDivElement> & { children: React.ReactNode }) => <div {...props}>{children}</div>;
const AlertDialogTitle = ({ children, ...props }: React.HTMLAttributes<HTMLHeadingElement> & { children: React.ReactNode }) => <h2 {...props}>{children}</h2>;
const AlertDialogTrigger = ({ children, ...props }: AlertDialogButtonProps) => <button {...props}>{children}</button>;
// import { Button } from '@/components/ui/button';
// import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import {
  AlertTriangle,
  Trash2,
  Check,
  // X,
  Info,
  Shield,
  Download,
  Upload,
  RefreshCw,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface ConfirmModalProps {
  trigger: ReactNode;
  title: string;
  description: string;
  confirmText?: string;
  cancelText?: string;
  variant?: 'destructive' | 'default' | 'warning' | 'info';
  icon?: ReactNode;
  details?: string[];
  onConfirm: () => Promise<void> | void;
  onCancel?: () => void;
  disabled?: boolean;
  loading?: boolean;
  className?: string;
}

const variantConfig = {
  destructive: {
    icon: AlertTriangle,
    iconColor: 'text-destructive',
    confirmVariant: 'destructive' as const,
    badgeVariant: 'destructive' as const,
  },
  warning: {
    icon: AlertTriangle,
    iconColor: 'text-yellow-500',
    confirmVariant: 'default' as const,
    badgeVariant: 'secondary' as const,
  },
  info: {
    icon: Info,
    iconColor: 'text-blue-500',
    confirmVariant: 'default' as const,
    badgeVariant: 'secondary' as const,
  },
  default: {
    icon: Check,
    iconColor: 'text-primary',
    confirmVariant: 'default' as const,
    badgeVariant: 'default' as const,
  },
};

export function ConfirmModal({
  trigger,
  title,
  description,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'default',
  icon,
  details,
  onConfirm,
  onCancel,
  disabled = false,
  loading = false,
  className,
}: ConfirmModalProps) {
  const [isLoading, setIsLoading] = useState(false);
  const [open, setOpen] = useState(false);
  
  const config = variantConfig[variant];
  const IconComponent = (icon || config.icon) as React.ComponentType<{ className?: string }>;

  const handleConfirm = async () => {
    setIsLoading(true);
    try {
      await onConfirm();
      setOpen(false);
    } catch {
      
      // Keep modal open on error
    } finally {
      setIsLoading(false);
    }
  };

  const handleCancel = () => {
    onCancel?.();
    setOpen(false);
  };

  return (
    <AlertDialog open={open} onOpenChange={setOpen}>
      <AlertDialogTrigger asChild disabled={disabled}>
        {trigger}
      </AlertDialogTrigger>
      <AlertDialogContent className={className}>
        <AlertDialogHeader>
          <AlertDialogTitle className="flex items-center gap-3">
            <div className={cn('flex-shrink-0', config.iconColor)}>
              <IconComponent className="h-5 w-5" />
            </div>
            {title}
          </AlertDialogTitle>
          <AlertDialogDescription className="text-left">
            {description}
            
            {details && details.length > 0 && (
              <>
                <Separator className="my-4" />
                <div className="space-y-2">
                  <div className="text-sm font-medium text-foreground">
                    Details:
                  </div>
                  <ul className="space-y-1 text-sm">
                    {details.map((detail, index) => (
                      <li key={index} className="flex items-start gap-2">
                        <span className="text-muted-foreground">•</span>
                        <span>{detail}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </>
            )}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel onClick={handleCancel} disabled={isLoading || loading}>
            {cancelText}
          </AlertDialogCancel>
          <AlertDialogAction
            onClick={handleConfirm}
            disabled={isLoading || loading}
            variant={config.confirmVariant}
          >
            {(isLoading || loading) && (
              <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
            )}
            {confirmText}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}

// Pre-configured confirm modals for common use cases

interface DeleteConfirmModalProps {
  trigger: ReactNode;
  itemName: string;
  itemType?: string;
  onConfirm: () => Promise<void> | void;
  additionalWarnings?: string[];
  disabled?: boolean;
}

export function DeleteConfirmModal({
  trigger,
  itemName,
  itemType = 'item',
  onConfirm,
  additionalWarnings = [],
  disabled = false,
}: DeleteConfirmModalProps) {
  const details = [
    `The ${itemType} "${itemName}" will be permanently deleted`,
    'This action cannot be undone',
    ...additionalWarnings,
  ];

  return (
    <ConfirmModal
      trigger={trigger}
      title={`Delete ${itemType}`}
      description={`Are you sure you want to delete this ${itemType}? This action cannot be undone.`}
      confirmText="Delete"
      cancelText="Cancel"
      variant="destructive"
      icon={<Trash2 className="h-5 w-5" />}
      details={details}
      onConfirm={onConfirm}
      disabled={disabled}
    />
  );
}

interface LogoutConfirmModalProps {
  trigger: ReactNode;
  onConfirm: () => Promise<void> | void;
  unsavedChanges?: boolean;
}

export function LogoutConfirmModal({
  trigger,
  onConfirm,
  unsavedChanges = false,
}: LogoutConfirmModalProps) {
  const details = unsavedChanges
    ? [
        'You have unsaved changes that will be lost',
        'You will need to sign in again to access your account',
      ]
    : [
        'You will need to sign in again to access your account',
      ];

  return (
    <ConfirmModal
      trigger={trigger}
      title="Sign out"
      description="Are you sure you want to sign out of your account?"
      confirmText="Sign out"
      cancelText="Stay signed in"
      variant={unsavedChanges ? 'warning' : 'default'}
      details={details}
      onConfirm={onConfirm}
    />
  );
}

interface SaveChangesModalProps {
  trigger: ReactNode;
  onConfirm: () => Promise<void> | void;
  onDiscard?: () => void;
  changesCount?: number;
}

export function SaveChangesModal({
  trigger,
  onConfirm,
  // onDiscard,
  changesCount,
}: SaveChangesModalProps) {
  const details = changesCount
    ? [`You have ${changesCount} unsaved changes`]
    : ['You have unsaved changes'];

  return (
    <ConfirmModal
      trigger={trigger}
      title="Save changes"
      description="You have unsaved changes. What would you like to do?"
      confirmText="Save changes"
      cancelText="Continue editing"
      variant="warning"
      icon={<Download className="h-5 w-5" />}
      details={details}
      onConfirm={onConfirm}
    />
  );
}

interface ResetConfirmModalProps {
  trigger: ReactNode;
  title?: string;
  description?: string;
  onConfirm: () => Promise<void> | void;
  resetType?: string;
}

export function ResetConfirmModal({
  trigger,
  title = 'Reset settings',
  description = 'Are you sure you want to reset to default settings?',
  onConfirm,
  resetType = 'settings',
}: ResetConfirmModalProps) {
  const details = [
    `All ${resetType} will be restored to their default values`,
    'This action cannot be undone',
  ];

  return (
    <ConfirmModal
      trigger={trigger}
      title={title}
      description={description}
      confirmText="Reset"
      cancelText="Cancel"
      variant="warning"
      icon={<RefreshCw className="h-5 w-5" />}
      details={details}
      onConfirm={onConfirm}
    />
  );
}

interface PublishConfirmModalProps {
  trigger: ReactNode;
  itemName: string;
  itemType?: string;
  onConfirm: () => Promise<void> | void;
  visibility?: 'public' | 'private' | 'restricted';
}

export function PublishConfirmModal({
  trigger,
  itemName,
  itemType = 'content',
  onConfirm,
  visibility = 'public',
}: PublishConfirmModalProps) {
  const visibilityDetails = {
    public: 'will be visible to everyone',
    private: 'will only be visible to you',
    restricted: 'will only be visible to authorized users',
  };

  const details = [
    `The ${itemType} "${itemName}" ${visibilityDetails[visibility]}`,
    'You can change the visibility later if needed',
  ];

  return (
    <ConfirmModal
      trigger={trigger}
      title={`Publish ${itemType}`}
      description={`Are you ready to publish this ${itemType}?`}
      confirmText="Publish"
      cancelText="Continue editing"
      variant="default"
      icon={<Upload className="h-5 w-5" />}
      details={details}
      onConfirm={onConfirm}
    />
  );
}

interface SecurityActionModalProps {
  trigger: ReactNode;
  action: string;
  description: string;
  onConfirm: () => Promise<void> | void;
  requiresReauth?: boolean;
}

export function SecurityActionModal({
  trigger,
  action,
  description,
  onConfirm,
  requiresReauth = false,
}: SecurityActionModalProps) {
  const details = requiresReauth
    ? [
        'This is a sensitive security action',
        'You may need to re-authenticate to complete this action',
        'This change will take effect immediately',
      ]
    : [
        'This is a sensitive security action',
        'This change will take effect immediately',
      ];

  return (
    <ConfirmModal
      trigger={trigger}
      title={`Security Action: ${action}`}
      description={description}
      confirmText="Confirm"
      cancelText="Cancel"
      variant="warning"
      icon={<Shield className="h-5 w-5" />}
      details={details}
      onConfirm={onConfirm}
    />
  );
}