'use client';

import { ReactNode } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';
import { ChevronRight, ChevronDown, AlertTriangle, CheckCircle } from 'lucide-react';
// import { div, div, div } from '@/components/ui/collapsible'; // Component not available
import { Button } from '@/components/ui/button';
import { useState } from 'react';

interface FormSectionProps {
  title?: string;
  description?: string;
  icon?: ReactNode;
  badge?: string;
  badgeVariant?: 'default' | 'secondary' | 'destructive' | 'outline';
  children: ReactNode;
  className?: string;
  variant?: 'card' | 'simple' | 'bordered';
  collapsible?: boolean;
  defaultCollapsed?: boolean;
  required?: boolean;
  error?: boolean;
  completed?: boolean;
}

export function FormSection({
  title,
  description,
  icon,
  badge,
  badgeVariant = 'secondary',
  children,
  className,
  variant = 'card',
  collapsible = false,
  defaultCollapsed = false,
  required = false,
  error = false,
  completed = false,
}: FormSectionProps) {
  const [isOpen, setIsOpen] = useState(!defaultCollapsed);

  const StatusIcon = error 
    ? AlertTriangle 
    : completed 
    ? CheckCircle 
    : undefined;

  const headerContent = (
    <div className="flex items-center justify-between w-full">
      <div className="flex items-center gap-3">
        {icon && <div className="flex-shrink-0">{icon}</div>}
        <div className="flex-1 min-w-0">
          {title && (
            <div className="flex items-center gap-2">
              <h3 className={cn(
                'font-semibold',
                variant === 'simple' ? 'text-lg' : 'text-base'
              )}>
                {title}
                {required && <span className="text-destructive">*</span>}
              </h3>
              {badge && (
                <Badge variant={badgeVariant} className="text-xs">
                  {badge}
                </Badge>
              )}
              {StatusIcon && (
                <StatusIcon className={cn(
                  'h-4 w-4',
                  error ? 'text-destructive' : completed ? 'text-green-500' : ''
                )} />
              )}
            </div>
          )}
          {description && (
            <p className={cn(
              'text-muted-foreground',
              variant === 'simple' ? 'text-sm' : 'text-xs'
            )}>
              {description}
            </p>
          )}
        </div>
      </div>
      
      {collapsible && (
        <div className="flex-shrink-0">
          {isOpen ? (
            <ChevronDown className="h-4 w-4 text-muted-foreground" />
          ) : (
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          )}
        </div>
      )}
    </div>
  );

  if (variant === 'simple') {
    const content = (
      <div className={cn('space-y-6', className)}>
        {(title || description) && (
          <div className="space-y-2">
            {headerContent}
            <Separator />
          </div>
        )}
        {children}
      </div>
    );

    if (collapsible) {
      return (
        <div>
          <div>
            <Button
              variant="ghost"
              className="w-full justify-start p-0 h-auto hover:bg-transparent"
              onClick={() => setIsOpen(!isOpen)}
            >
              {headerContent}
            </Button>
          </div>
          {isOpen && (
            <div className="space-y-6 pt-4">
              {children}
            </div>
          )}
        </div>
      );
    }

    return content;
  }

  if (variant === 'bordered') {
    const content = (
      <div className={cn(
        'p-4 border rounded-lg space-y-4',
        error && 'border-destructive',
        completed && 'border-green-500',
        className
      )}>
        {(title || description) && headerContent}
        {(title || description) && <Separator />}
        {children}
      </div>
    );

    if (collapsible) {
      return (
        <div >
          <div className={cn(
            'border rounded-lg',
            error && 'border-destructive',
            completed && 'border-green-500',
            className
          )}>
            <div>
              <Button
                variant="ghost"
                className="w-full justify-start p-4 h-auto rounded-none hover:bg-muted/50"
                onClick={() => setIsOpen(!isOpen)}
              >
                {headerContent}
              </Button>
            </div>
            {isOpen && (
              <div>
                <Separator />
                <div className="p-4 space-y-4">
                  {children}
                </div>
              </div>
            )}
          </div>
        </div>
      );
    }

    return content;
  }

  // Default: card variant
  const cardContent = (
    <Card className={cn(
      error && 'border-destructive',
      completed && 'border-green-500',
      className
    )}>
      {(title || description) && (
        <CardHeader>
          {title && (
            <CardTitle className="flex items-center gap-2">
              {icon}
              {title}
              {required && <span className="text-destructive">*</span>}
              {badge && (
                <Badge variant={badgeVariant} className="text-xs">
                  {badge}
                </Badge>
              )}
              {StatusIcon && (
                <StatusIcon className={cn(
                  'h-4 w-4',
                  error ? 'text-destructive' : completed ? 'text-green-500' : ''
                )} />
              )}
            </CardTitle>
          )}
          {description && <CardDescription>{description}</CardDescription>}
        </CardHeader>
      )}
      <CardContent className={cn(!title && !description && 'pt-6')}>
        {children}
      </CardContent>
    </Card>
  );

  if (collapsible) {
    return (
      <div >
        <Card className={cn(
          error && 'border-destructive',
          completed && 'border-green-500',
          className
        )}>
          <div>
            <CardHeader 
              className="hover:bg-muted/50 cursor-pointer transition-colors"
              onClick={() => setIsOpen(!isOpen)}
            >
              {headerContent}
            </CardHeader>
          </div>
          {isOpen && (
            <div>
              <CardContent>
                {children}
              </CardContent>
            </div>
          )}
        </Card>
      </div>
    );
  }

  return cardContent;
}

// Pre-configured form section components
export function BasicFormSection({ 
  title, 
  children, 
  className 
}: { 
  title: string; 
  children: ReactNode; 
  className?: string;
}) {
  return (
    <FormSection
      title={title}
      variant="simple"
      {...(className ? { className } : {})}
    >
      {children}
    </FormSection>
  );
}

export function RequiredFormSection({ 
  title, 
  description,
  children, 
  className 
}: { 
  title: string; 
  description?: string;
  children: ReactNode; 
  className?: string;
}) {
  return (
    <FormSection
      title={title}
      {...(description ? { description } : {})}
      required={true}
      badge="Required"
      badgeVariant="destructive"
      {...(className ? { className } : {})}
    >
      {children}
    </FormSection>
  );
}

export function OptionalFormSection({ 
  title, 
  description,
  children, 
  className 
}: { 
  title: string; 
  description?: string;
  children: ReactNode; 
  className?: string;
}) {
  return (
    <FormSection
      title={title}
      {...(description ? { description } : {})}
      badge="Optional"
      badgeVariant="secondary"
      collapsible={true}
      defaultCollapsed={true}
      {...(className ? { className } : {})}
    >
      {children}
    </FormSection>
  );
}

export function ErrorFormSection({ 
  title, 
  // description,
  error,
  children, 
  className 
}: { 
  title: string; 
  description?: string;
  error: string;
  children: ReactNode; 
  className?: string;
}) {
  return (
    <FormSection
      title={title}
      description={error}
      error={true}
      icon={<AlertTriangle className="h-5 w-5 text-destructive" />}
      {...(className ? { className } : {})}
    >
      {children}
    </FormSection>
  );
}

export function CompletedFormSection({ 
  title, 
  description,
  children, 
  className 
}: { 
  title: string; 
  description?: string;
  children: ReactNode; 
  className?: string;
}) {
  return (
    <FormSection
      title={title}
      {...(description ? { description } : {})}
      completed={true}
      badge="Completed"
      badgeVariant="default"
      icon={<CheckCircle className="h-5 w-5 text-green-500" />}
      {...(className ? { className } : {})}
    >
      {children}
    </FormSection>
  );
}

// Multi-step form wrapper
interface MultiStepFormProps {
  steps: Array<{
    id: string;
    title: string;
    description?: string;
    completed?: boolean;
    error?: boolean;
    children: ReactNode;
  }>;
  currentStep: string;
  className?: string;
}

export function MultiStepForm({ 
  steps, 
  currentStep, 
  className 
}: MultiStepFormProps) {
  const currentStepIndex = steps.findIndex(step => step.id === currentStep);

  return (
    <div className={cn('space-y-6', className)}>
      {/* Progress indicator */}
      <div className="flex items-center justify-between">
        {steps.map((step, index) => {
          const isActive = step.id === currentStep;
          const isCompleted = step.completed || index < currentStepIndex;
          const hasError = step.error;

          return (
            <div
              key={step.id}
              className={cn(
                'flex items-center',
                index < steps.length - 1 && 'flex-1'
              )}
            >
              <div className="flex items-center gap-2">
                <div className={cn(
                  'w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium',
                  isCompleted && !hasError && 'bg-green-500 text-white',
                  hasError && 'bg-destructive text-white',
                  isActive && !hasError && !isCompleted && 'bg-primary text-primary-foreground',
                  !isActive && !isCompleted && !hasError && 'bg-muted text-muted-foreground'
                )}>
                  {isCompleted && !hasError ? (
                    <CheckCircle className="h-4 w-4" />
                  ) : hasError ? (
                    <AlertTriangle className="h-4 w-4" />
                  ) : (
                    index + 1
                  )}
                </div>
                <div className="hidden md:block">
                  <div className={cn(
                    'text-sm font-medium',
                    isActive && 'text-primary',
                    hasError && 'text-destructive'
                  )}>
                    {step.title}
                  </div>
                  {step.description && (
                    <div className="text-xs text-muted-foreground">
                      {step.description}
                    </div>
                  )}
                </div>
              </div>
              {index < steps.length - 1 && (
                <Separator 
                  className={cn(
                    'flex-1 mx-4',
                    isCompleted && 'bg-green-500'
                  )} 
                />
              )}
            </div>
          );
        })}
      </div>

      {/* Current step content */}
      {steps.map(step => (
        step.id === currentStep && (
          <FormSection
            key={step.id}
            title={step.title}
            {...(step.description ? { description: step.description } : {})}
            {...(step.completed ? { completed: step.completed } : {})}
            {...(step.error ? { error: step.error } : {})}
          >
            {step.children}
          </FormSection>
        )
      ))}
    </div>
  );
}