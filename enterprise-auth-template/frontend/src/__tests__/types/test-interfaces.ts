/**
 * Shared TypeScript interfaces for test files
 * Replaces generic `unknown` types with specific, meaningful interfaces
 */

// Component Props Interfaces
export interface ButtonProps {
  children: React.ReactNode;
  disabled?: boolean;
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  className?: string;
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
  type?: 'button' | 'submit' | 'reset';
}

export interface InputProps {
  placeholder?: string;
  value?: string;
  onChange?: React.ChangeEventHandler<HTMLInputElement>;
  className?: string;
  type?: 'text' | 'email' | 'password' | 'number' | 'tel' | 'url';
  disabled?: boolean;
  required?: boolean;
  name?: string;
  id?: string;
}

export interface AlertProps {
  children: React.ReactNode;
  variant?: 'default' | 'destructive' | 'success' | 'warning';
  className?: string;
}

export interface AlertDescriptionProps {
  children: React.ReactNode;
  className?: string;
}

export interface SeparatorProps {
  orientation?: 'horizontal' | 'vertical';
  decorative?: boolean;
  className?: string;
}

export interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'secondary' | 'destructive' | 'outline';
  className?: string;
}

export interface CheckboxProps {
  checked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  disabled?: boolean;
  name?: string;
  id?: string;
  className?: string;
}

export interface CardProps {
  children: React.ReactNode;
  className?: string;
}

export interface CardHeaderProps {
  children: React.ReactNode;
  className?: string;
}

export interface CardTitleProps {
  children: React.ReactNode;
  className?: string;
}

export interface CardDescriptionProps {
  children: React.ReactNode;
  className?: string;
}

export interface CardContentProps {
  children: React.ReactNode;
  className?: string;
}

export interface CardFooterProps {
  children: React.ReactNode;
  className?: string;
}

// Table Component Props
export interface TableProps {
  children: React.ReactNode;
  className?: string;
}

export interface TableHeaderProps {
  children: React.ReactNode;
  className?: string;
}

export interface TableBodyProps {
  children: React.ReactNode;
  className?: string;
}

export interface TableRowProps {
  children: React.ReactNode;
  className?: string;
}

export interface TableHeadProps {
  children: React.ReactNode;
  className?: string;
}

export interface TableCellProps {
  children: React.ReactNode;
  className?: string;
  colSpan?: number;
}

// Form Data Interfaces
export interface AuthFormData {
  email: string;
  password: string;
  rememberMe?: boolean;
  name?: string;
  acceptTerms?: boolean;
}

export interface RegisterFormData {
  email: string;
  password: string;
  confirmPassword: string;
  name: string;
  terms?: boolean;
}

export interface ProfileFormData {
  name: string;
  email: string;
  bio?: string;
  avatar?: string;
  phone?: string;
  location?: string;
}

export interface ChangePasswordFormData {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export interface TwoFactorFormData {
  code: string;
  trustDevice?: boolean;
}

// API Response Interfaces
export interface AuthResponse {
  success: boolean;
  user?: {
    id: string;
    email: string;
    name: string;
    role: string;
    isEmailVerified: boolean;
  };
  tokens?: {
    accessToken: string;
    refreshToken: string;
  };
  error?: {
    code: string;
    message: string;
    details?: Record<string, string>;
  };
}

export interface UserResponse {
  success: boolean;
  data?: {
    id: string;
    email: string;
    name: string;
    role: string;
    isEmailVerified: boolean;
    createdAt: string;
    updatedAt: string;
    lastLoginAt?: string;
  };
  error?: {
    code: string;
    message: string;
  };
}

export interface UsersListResponse {
  success: boolean;
  data?: {
    users: Array<{
      id: string;
      email: string;
      name: string;
      role: string;
      isEmailVerified: boolean;
      createdAt: string;
      lastLoginAt?: string;
    }>;
    total: number;
    page: number;
    pageSize: number;
  };
  error?: {
    code: string;
    message: string;
  };
}

export interface OAuthResponse {
  success: boolean;
  authUrl?: string;
  error?: {
    code: string;
    message: string;
  };
}

// Mock Response Interface
export interface MockResponse {
  ok: boolean;
  status?: number;
  statusText?: string;
  headers?: Headers;
  data?: Record<string, any>;
}

// React Hook Form Interfaces
export interface FormFieldProps {
  control?: any; // react-hook-form Control type
  name: string;
  render: ({ field }: { field: any }) => React.ReactElement;
  rules?: {
    required?: string | boolean;
    minLength?: { value: number; message: string };
    maxLength?: { value: number; message: string };
    pattern?: { value: RegExp; message: string };
    validate?: (value: any) => boolean | string;
  };
}

export interface ControllerProps {
  control?: any;
  name: string;
  render: ({ field }: { field: any }) => React.ReactElement;
  rules?: Record<string, any>;
}

// Test Utility Interfaces
export interface MockUser {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'admin' | 'moderator';
  isEmailVerified: boolean;
  createdAt: string;
  updatedAt: string;
  lastLoginAt?: string;
  first_name?: string;
  last_name?: string;
  avatar?: string;
  phone?: string;
  location?: string;
}

// Admin-specific interfaces
export interface MockAdminUser extends MockUser {
  role: 'admin';
  permissions: string[];
  lastAction?: string;
}

export interface TestJWTPayload {
  sub: string;
  email: string;
  name: string;
  role: string;
  iat: number;
  exp: number;
}

// Mock Environment Variables
export interface TestEnvironment {
  NEXT_PUBLIC_API_URL?: string;
  NEXT_PUBLIC_GOOGLE_CLIENT_ID?: string;
  NEXT_PUBLIC_GITHUB_CLIENT_ID?: string;
  NODE_ENV?: 'test' | 'development' | 'production';
}

// Global Window extensions for tests
export interface TestWindow extends Window {
  location: Location & {
    href: string;
    pathname: string;
    search: string;
  };
}

// Storage Interfaces
export interface LocalStorageTestData {
  user?: MockUser;
  tokens?: {
    accessToken: string;
    refreshToken: string;
  };
  preferences?: {
    theme: 'light' | 'dark';
    language: string;
  };
}

// Icon Component Props
export interface IconProps {
  className?: string;
  size?: number | string;
  color?: string;
}