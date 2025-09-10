'use client';

import { forwardRef, ReactNode } from 'react';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { Checkbox } from '@/components/ui/checkbox';
// import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group'; // Component not available
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';
import { AlertCircle, Info, CheckCircle, Eye, EyeOff } from 'lucide-react';
import { useState } from 'react';

interface BaseFormFieldProps {
  label?: string;
  description?: string;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  className?: string;
  id?: string;
}

// Text Input Field
interface TextFieldProps extends BaseFormFieldProps {
  type?: 'text' | 'email' | 'password' | 'url' | 'tel' | 'number';
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  showPasswordToggle?: boolean;
  prefix?: ReactNode;
  suffix?: ReactNode;
}

export const TextField = forwardRef<HTMLInputElement, TextFieldProps>(
  ({ 
    label, 
    description, 
    error, 
    required, 
    disabled, 
    className, 
    id,
    type = 'text',
    placeholder,
    value,
    onChange,
    showPasswordToggle = false,
    prefix,
    suffix,
    ...props 
  }, ref) => {
    const [showPassword, setShowPassword] = useState(false);
    const inputType = type === 'password' && showPassword ? 'text' : type;

    return (
      <div className={cn('space-y-2', className)}>
        {label && (
          <Label htmlFor={id} className="text-sm font-medium">
            {label}
            {required && <span className="text-destructive ml-1">*</span>}
          </Label>
        )}
        
        <div className="relative">
          {prefix && (
            <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground">
              {prefix}
            </div>
          )}
          
          <Input
            ref={ref}
            id={id}
            type={inputType}
            placeholder={placeholder}
            value={value}
            onChange={(e) => onChange?.(e.target.value)}
            disabled={disabled}
            className={cn(
              error && 'border-destructive focus-visible:ring-destructive',
              prefix && 'pl-10',
              (suffix || (showPasswordToggle && type === 'password')) && 'pr-10'
            )}
            {...props}
          />
          
          {(suffix || (showPasswordToggle && type === 'password')) && (
            <div className="absolute right-3 top-1/2 transform -translate-y-1/2">
              {showPasswordToggle && type === 'password' ? (
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="text-muted-foreground hover:text-foreground"
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              ) : (
                suffix
              )}
            </div>
          )}
        </div>
        
        {(description || error) && (
          <div className="space-y-1">
            {description && !error && (
              <div className="flex items-start gap-1 text-xs text-muted-foreground">
                <Info className="h-3 w-3 mt-0.5 flex-shrink-0" />
                <span>{description}</span>
              </div>
            )}
            {error && (
              <div className="flex items-start gap-1 text-xs text-destructive">
                <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
                <span>{error}</span>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }
);
TextField.displayName = 'TextField';

// Textarea Field
interface TextareaFieldProps extends BaseFormFieldProps {
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  rows?: number;
  maxLength?: number;
  showCharCount?: boolean;
}

export function TextareaField({
  label,
  description,
  error,
  required,
  disabled,
  className,
  id,
  placeholder,
  value = '',
  onChange,
  rows = 3,
  maxLength,
  showCharCount = false,
}: TextareaFieldProps) {
  return (
    <div className={cn('space-y-2', className)}>
      {label && (
        <Label htmlFor={id} className="text-sm font-medium">
          {label}
          {required && <span className="text-destructive ml-1">*</span>}
        </Label>
      )}
      
      <Textarea
        id={id}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
        disabled={disabled}
        rows={rows}
        maxLength={maxLength}
        className={cn(
          error && 'border-destructive focus-visible:ring-destructive',
          'resize-none'
        )}
      />
      
      {(showCharCount || description || error) && (
        <div className="flex justify-between items-start">
          <div>
            {description && !error && (
              <div className="flex items-start gap-1 text-xs text-muted-foreground">
                <Info className="h-3 w-3 mt-0.5 flex-shrink-0" />
                <span>{description}</span>
              </div>
            )}
            {error && (
              <div className="flex items-start gap-1 text-xs text-destructive">
                <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
                <span>{error}</span>
              </div>
            )}
          </div>
          {showCharCount && maxLength && (
            <div className="text-xs text-muted-foreground">
              {value.length}/{maxLength}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// Select Field
interface SelectFieldProps extends BaseFormFieldProps {
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
  options: Array<{ label: string; value: string; disabled?: boolean }>;
}

export function SelectField({
  label,
  description,
  error,
  required,
  disabled,
  className,
  id,
  placeholder = 'Select an option...',
  value,
  onChange,
  options,
}: SelectFieldProps) {
  return (
    <div className={cn('space-y-2', className)}>
      {label && (
        <Label htmlFor={id} className="text-sm font-medium">
          {label}
          {required && <span className="text-destructive ml-1">*</span>}
        </Label>
      )}
      
      <Select 
        {...(value ? { value } : {})} 
        {...(onChange ? { onValueChange: onChange } : {})} 
        {...(disabled ? { disabled } : {})}
      >
        <SelectTrigger
          id={id}
          className={cn(error && 'border-destructive focus:ring-destructive')}
        >
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent>
          {options.map((option) => (
            <SelectItem 
              key={option.value} 
              value={option.value} 
              {...(option.disabled ? { disabled: option.disabled } : {})}
            >
              {option.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      
      {(description || error) && (
        <div className="space-y-1">
          {description && !error && (
            <div className="flex items-start gap-1 text-xs text-muted-foreground">
              <Info className="h-3 w-3 mt-0.5 flex-shrink-0" />
              <span>{description}</span>
            </div>
          )}
          {error && (
            <div className="flex items-start gap-1 text-xs text-destructive">
              <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
              <span>{error}</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

// Switch Field
interface SwitchFieldProps extends BaseFormFieldProps {
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  size?: 'sm' | 'default' | 'lg';
}

export function SwitchField({
  label,
  description,
  error,
  required,
  disabled,
  className,
  id,
  checked = false,
  onChange,
}: SwitchFieldProps) {
  return (
    <div className={cn('space-y-2', className)}>
      <div className="flex items-center justify-between">
        <div className="space-y-1">
          {label && (
            <Label htmlFor={id} className="text-sm font-medium">
              {label}
              {required && <span className="text-destructive ml-1">*</span>}
            </Label>
          )}
          {description && (
            <div className="text-xs text-muted-foreground">{description}</div>
          )}
        </div>
        <Switch
          {...(id ? { id } : {})}
          checked={checked}
          {...(onChange ? { onCheckedChange: onChange } : {})}
          {...(disabled ? { disabled } : {})}
        />
      </div>
      
      {error && (
        <div className="flex items-start gap-1 text-xs text-destructive">
          <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}
    </div>
  );
}

// Checkbox Field
interface CheckboxFieldProps extends BaseFormFieldProps {
  checked?: boolean;
  onChange?: (checked: boolean) => void;
  children?: ReactNode;
}

export function CheckboxField({
  label,
  description,
  error,
  required,
  disabled,
  className,
  id,
  checked = false,
  onChange,
  children,
}: CheckboxFieldProps) {
  return (
    <div className={cn('space-y-2', className)}>
      <div className="flex items-start space-x-2">
        <Checkbox
          id={id}
          checked={checked}
          onCheckedChange={(checked) => onChange?.(!!checked)}
          disabled={disabled}
        />
        <div className="space-y-1 flex-1">
          {label && (
            <Label htmlFor={id} className="text-sm font-medium">
              {label}
              {required && <span className="text-destructive ml-1">*</span>}
            </Label>
          )}
          {children}
          {description && (
            <div className="text-xs text-muted-foreground">{description}</div>
          )}
        </div>
      </div>
      
      {error && (
        <div className="flex items-start gap-1 text-xs text-destructive ml-6">
          <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}
    </div>
  );
}

// Radio Group Field
interface RadioGroupFieldProps extends BaseFormFieldProps {
  value?: string;
  onChange?: (value: string) => void;
  options: Array<{ label: string; value: string; description?: string; disabled?: boolean }>;
  orientation?: 'horizontal' | 'vertical';
}

export function RadioGroupField({
  label,
  description,
  error,
  required,
  disabled,
  className,
  id,
  value,
  onChange,
  options,
  orientation = 'vertical',
}: RadioGroupFieldProps) {
  return (
    <div className={cn('space-y-3', className)}>
      {label && (
        <Label className="text-sm font-medium">
          {label}
          {required && <span className="text-destructive ml-1">*</span>}
        </Label>
      )}
      
      {description && (
        <div className="text-xs text-muted-foreground">{description}</div>
      )}
      
      {/* RadioGroup component not available - using basic radio inputs */}
      <div className={cn(
          'space-y-2',
          orientation === 'horizontal' && 'flex space-y-0 space-x-6'
        )}>
        {options.map((option) => (
          <div key={option.value} className="flex items-center space-x-2">
            <input
              type="radio"
              value={option.value}
              id={`${id}-${option.value}`}
              checked={value === option.value}
              onChange={(e) => onChange?.(e.target.value)}
              disabled={option.disabled || disabled}
              className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300"
            />
            <div className="space-y-1">
              <Label
                htmlFor={`${id}-${option.value}`}
                className="text-sm font-medium"
              >
                {option.label}
              </Label>
              {option.description && (
                <div className="text-xs text-muted-foreground">
                  {option.description}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
      
      {error && (
        <div className="flex items-start gap-1 text-xs text-destructive">
          <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}
    </div>
  );
}

// Multi-select Field with Tags
interface MultiSelectFieldProps extends BaseFormFieldProps {
  value?: string[];
  onChange?: (value: string[]) => void;
  options: Array<{ label: string; value: string; disabled?: boolean }>;
  placeholder?: string;
  maxItems?: number;
}

export function MultiSelectField({
  label,
  description,
  error,
  required,
  disabled,
  className,
  id,
  value = [],
  onChange,
  options,
  placeholder = 'Select options...',
  maxItems,
}: MultiSelectFieldProps) {
  const [isOpen, setIsOpen] = useState(false);

  const handleSelect = (optionValue: string) => {
    const newValue = value.includes(optionValue)
      ? value.filter(v => v !== optionValue)
      : [...value, optionValue];
    onChange?.(newValue);
  };

  const removeItem = (optionValue: string) => {
    onChange?.(value.filter(v => v !== optionValue));
  };

  return (
    <div className={cn('space-y-2', className)}>
      {label && (
        <Label htmlFor={id} className="text-sm font-medium">
          {label}
          {required && <span className="text-destructive ml-1">*</span>}
          {maxItems && (
            <Badge variant="secondary" className="ml-2 text-xs">
              {value.length}/{maxItems}
            </Badge>
          )}
        </Label>
      )}
      
      {/* Selected items */}
      {value.length > 0 && (
        <div className="flex flex-wrap gap-1">
          {value.map((selectedValue) => {
            const option = options.find(opt => opt.value === selectedValue);
            return (
              <Badge key={selectedValue} variant="secondary" className="text-xs">
                {option?.label || selectedValue}
                <button
                  type="button"
                  onClick={() => removeItem(selectedValue)}
                  className="ml-1 hover:text-destructive"
                  disabled={disabled}
                >
                  ×
                </button>
              </Badge>
            );
          })}
        </div>
      )}
      
      {/* Selection dropdown */}
      <Select 
        open={isOpen} 
        onOpenChange={setIsOpen} 
        {...(disabled ? { disabled } : {})}
      >
        <SelectTrigger
          id={id}
          className={cn(error && 'border-destructive focus:ring-destructive')}
        >
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent>
          {options.map((option) => {
            const isSelected = value.includes(option.value);
            const isDisabled = option.disabled || 
              (maxItems !== undefined && !isSelected && value.length >= maxItems);
            
            return (
              <SelectItem
                key={option.value}
                value={option.value}
                disabled={isDisabled}
                onClick={() => handleSelect(option.value)}
              >
                <div className="flex items-center gap-2">
                  {isSelected && <CheckCircle className="h-4 w-4 text-primary" />}
                  {option.label}
                </div>
              </SelectItem>
            );
          })}
        </SelectContent>
      </Select>
      
      {(description || error) && (
        <div className="space-y-1">
          {description && !error && (
            <div className="flex items-start gap-1 text-xs text-muted-foreground">
              <Info className="h-3 w-3 mt-0.5 flex-shrink-0" />
              <span>{description}</span>
            </div>
          )}
          {error && (
            <div className="flex items-start gap-1 text-xs text-destructive">
              <AlertCircle className="h-3 w-3 mt-0.5 flex-shrink-0" />
              <span>{error}</span>
            </div>
          )}
        </div>
      )}
    </div>
  );
}