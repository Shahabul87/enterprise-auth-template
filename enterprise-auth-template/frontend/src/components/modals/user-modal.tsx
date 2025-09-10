'use client';

import { useState, useEffect } from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
// import { Separator } from '@/components/ui/separator';
import { ScrollArea } from '@/components/ui/scroll-area';
import { TextField, SwitchField, MultiSelectField } from '@/components/forms/form-field';
import { FormSection } from '@/components/forms/form-section';
import {
  // User,
  Mail,
  Calendar,
  // Shield,
  // Key,
  Activity,
  // Settings,
  Plus,
  Edit,
  Save,
  X,
  RefreshCw,
} from 'lucide-react';
import { toast } from 'sonner';

// TODO: Replace with actual types from your API
interface UserData {
  id?: string;
  email: string;
  first_name: string;
  last_name: string;
  is_active: boolean;
  is_verified: boolean;
  is_superuser: boolean;
  roles?: Array<{
    id: string;
    name: string;
    description?: string;
    is_active: boolean;
  }>;
  permissions?: string[];
  created_at?: string;
  last_login?: string;
  profile?: {
    phone?: string;
    department?: string;
    job_title?: string;
    bio?: string;
  };
}

interface UserModalProps {
  trigger: React.ReactNode;
  user?: UserData | null;
  mode: 'create' | 'edit' | 'view';
  onSave?: (userData: UserData) => Promise<void>;
  onDelete?: (userId: string) => Promise<void>;
  availableRoles?: Array<{ label: string; value: string; disabled?: boolean }>;
  disabled?: boolean;
}

const initialUserData: UserData = {
  email: '',
  first_name: '',
  last_name: '',
  is_active: true,
  is_verified: false,
  is_superuser: false,
  roles: [],
  permissions: [],
  profile: {
    phone: '',
    department: '',
    job_title: '',
    bio: '',
  },
};

export function UserModal({
  trigger,
  user,
  mode,
  onSave,
  onDelete,
  availableRoles = [],
  disabled = false,
}: UserModalProps) {
  const [open, setOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [formData, setFormData] = useState<UserData>(user || initialUserData);
  const [activeTab, setActiveTab] = useState('general');
  const [errors, setErrors] = useState<Record<string, string>>({});

  const isEditing = mode === 'edit' || mode === 'create';
  const isCreating = mode === 'create';

  useEffect(() => {
    if (user) {
      setFormData(user);
    } else {
      setFormData(initialUserData);
    }
    setErrors({});
  }, [user, open]);

  const updateFormData = (field: string, value: unknown) => {
    setFormData(prev => {
      if (field.includes('.')) {
        const [parent, child] = field.split('.');
        return {
          ...prev,
          [parent as string]: {
            ...(prev[parent as keyof UserData] as Record<string, unknown>),
            [child as string]: value,
          },
        };
      }
      return {
        ...prev,
        [field]: value,
      };
    });
    
    // Clear error when field is updated
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData['email'].trim()) {
      newErrors['email'] = 'Email is required';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData['email'])) {
      newErrors['email'] = 'Invalid email format';
    }

    if (!formData['first_name'].trim()) {
      newErrors['first_name'] = 'First name is required';
    }

    if (!formData['last_name'].trim()) {
      newErrors['last_name'] = 'Last name is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSave = async () => {
    if (!validateForm()) {
      toast.error('Please fix the errors before saving');
      return;
    }

    setIsLoading(true);
    try {
      await onSave?.(formData);
      toast.success(`User ${isCreating ? 'created' : 'updated'} successfully`);
      setOpen(false);
    } catch {
      
      toast.error(`Failed to ${isCreating ? 'create' : 'update'} user`);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!user?.id) return;
    
    setIsLoading(true);
    try {
      await onDelete?.(user.id);
      toast.success('User deleted successfully');
      setOpen(false);
    } catch {
      
      toast.error('Failed to delete user');
    } finally {
      setIsLoading(false);
    }
  };

  const formatDate = (dateString?: string) => {
    if (!dateString) return 'Never';
    return new Date(dateString).toLocaleDateString();
  };

  const getUserInitials = (user: UserData) => {
    return `${user.first_name.charAt(0)}${user.last_name.charAt(0)}`.toUpperCase();
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild disabled={disabled}>
        {trigger}
      </DialogTrigger>
      <DialogContent className="max-w-2xl max-h-[90vh]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-3">
            {!isCreating && (
              <Avatar className="h-10 w-10">
                <AvatarImage src={undefined} alt={`${formData.first_name} ${formData.last_name}`} />
                <AvatarFallback>{getUserInitials(formData)}</AvatarFallback>
              </Avatar>
            )}
            <div>
              {isCreating ? (
                <span className="flex items-center gap-2">
                  <Plus className="h-5 w-5" />
                  Create New User
                </span>
              ) : mode === 'edit' ? (
                <span className="flex items-center gap-2">
                  <Edit className="h-5 w-5" />
                  Edit User
                </span>
              ) : (
                <span>{formData.first_name} {formData.last_name}</span>
              )}
            </div>
          </DialogTitle>
          <DialogDescription>
            {isCreating && 'Create a new user account with roles and permissions.'}
            {mode === 'edit' && 'Update user information, roles, and permissions.'}
            {mode === 'view' && 'View user details and account information.'}
          </DialogDescription>
        </DialogHeader>

        <Tabs value={activeTab} onValueChange={setActiveTab} className="flex-1">
          <TabsList className="grid w-full grid-cols-4">
            <TabsTrigger value="general">General</TabsTrigger>
            <TabsTrigger value="profile">Profile</TabsTrigger>
            <TabsTrigger value="roles">Roles</TabsTrigger>
            <TabsTrigger value="activity">Activity</TabsTrigger>
          </TabsList>

          <ScrollArea className="max-h-96 mt-4">
            <TabsContent value="general" className="space-y-4">
              <FormSection title="Basic Information" variant="simple">
                <div className="grid gap-4 md:grid-cols-2">
                  <TextField
                    label="First Name"
                    value={formData['first_name']}
                    onChange={(value) => updateFormData('first_name', value)}
                    {...(errors['first_name'] ? { error: errors['first_name'] } : {})}
                    disabled={!isEditing}
                    required
                  />
                  <TextField
                    label="Last Name"
                    value={formData['last_name']}
                    onChange={(value) => updateFormData('last_name', value)}
                    {...(errors['last_name'] ? { error: errors['last_name'] } : {})}
                    disabled={!isEditing}
                    required
                  />
                </div>
                
                <TextField
                  label="Email Address"
                  type="email"
                  value={formData['email']}
                  onChange={(value) => updateFormData('email', value)}
                  {...(errors['email'] ? { error: errors['email'] } : {})}
                  disabled={!isEditing}
                  required
                  prefix={<Mail className="h-4 w-4" />}
                />
              </FormSection>

              <FormSection title="Account Status" variant="simple">
                <div className="space-y-4">
                  <SwitchField
                    label="Active Account"
                    description="User can sign in and access the system"
                    checked={formData.is_active}
                    onChange={(value) => updateFormData('is_active', value)}
                    disabled={!isEditing}
                  />
                  
                  <SwitchField
                    label="Email Verified"
                    description="User has verified their email address"
                    checked={formData.is_verified}
                    onChange={(value) => updateFormData('is_verified', value)}
                    disabled={!isEditing}
                  />
                  
                  <SwitchField
                    label="Administrator"
                    description="User has full system access and permissions"
                    checked={formData.is_superuser}
                    onChange={(value) => updateFormData('is_superuser', value)}
                    disabled={!isEditing}
                  />
                </div>
              </FormSection>
            </TabsContent>

            <TabsContent value="profile" className="space-y-4">
              <FormSection title="Contact Information" variant="simple">
                <TextField
                  label="Phone Number"
                  type="tel"
                  value={formData.profile?.phone || ''}
                  onChange={(value) => updateFormData('profile.phone', value)}
                  disabled={!isEditing}
                  placeholder="+1 (555) 123-4567"
                />
              </FormSection>

              <FormSection title="Work Information" variant="simple">
                <div className="grid gap-4 md:grid-cols-2">
                  <TextField
                    label="Job Title"
                    value={formData.profile?.job_title || ''}
                    onChange={(value) => updateFormData('profile.job_title', value)}
                    disabled={!isEditing}
                    placeholder="e.g. Software Engineer"
                  />
                  <TextField
                    label="Department"
                    value={formData.profile?.department || ''}
                    onChange={(value) => updateFormData('profile.department', value)}
                    disabled={!isEditing}
                    placeholder="e.g. Engineering"
                  />
                </div>
              </FormSection>
            </TabsContent>

            <TabsContent value="roles" className="space-y-4">
              <FormSection title="Role Assignment" variant="simple">
                {isEditing && (
                  <MultiSelectField
                    label="Assigned Roles"
                    description="Select the roles to assign to this user"
                    value={formData.roles?.map(r => r.id) || []}
                    onChange={(roleIds) => {
                      // TODO: Map role IDs back to role objects
                      // This is a simplified implementation
                      const selectedRoles = availableRoles
                        .filter(role => roleIds.includes(role.value))
                        .map(role => ({
                          id: role.value,
                          name: role.label,
                          is_active: true,
                        }));
                      updateFormData('roles', selectedRoles);
                    }}
                    options={availableRoles}
                    placeholder="Select roles..."
                  />
                )}
                
                {!isEditing && (
                  <div className="space-y-2">
                    {formData.roles && formData.roles.length > 0 ? (
                      formData.roles.map((role) => (
                        <div key={role.id} className="flex items-center justify-between p-3 border rounded-lg">
                          <div>
                            <div className="font-medium">{role.name}</div>
                            {role.description && (
                              <div className="text-sm text-muted-foreground">{role.description}</div>
                            )}
                          </div>
                          <Badge variant={role.is_active ? 'default' : 'secondary'}>
                            {role.is_active ? 'Active' : 'Inactive'}
                          </Badge>
                        </div>
                      ))
                    ) : (
                      <div className="text-center py-4 text-muted-foreground">
                        No roles assigned
                      </div>
                    )}
                  </div>
                )}
              </FormSection>

              <FormSection title="Permissions" variant="simple">
                <div className="space-y-2">
                  {formData.permissions && formData.permissions.length > 0 ? (
                    <div className="flex flex-wrap gap-1">
                      {formData.permissions.map((permission) => (
                        <Badge key={permission} variant="outline" className="text-xs">
                          {permission}
                        </Badge>
                      ))}
                    </div>
                  ) : (
                    <div className="text-center py-4 text-muted-foreground">
                      No permissions assigned
                    </div>
                  )}
                </div>
              </FormSection>
            </TabsContent>

            <TabsContent value="activity" className="space-y-4">
              <FormSection title="Account Activity" variant="simple">
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <div className="text-sm font-medium flex items-center gap-2">
                      <Calendar className="h-4 w-4" />
                      Created
                    </div>
                    <div className="text-sm text-muted-foreground">
                      {formatDate(formData.created_at)}
                    </div>
                  </div>
                  
                  <div className="space-y-2">
                    <div className="text-sm font-medium flex items-center gap-2">
                      <Activity className="h-4 w-4" />
                      Last Login
                    </div>
                    <div className="text-sm text-muted-foreground">
                      {formatDate(formData.last_login)}
                    </div>
                  </div>
                </div>
              </FormSection>

              {/* TODO: Add activity log, login history, etc. */}
              <FormSection title="Recent Activity" variant="simple">
                <div className="text-center py-4 text-muted-foreground">
                  Activity log coming soon...
                </div>
              </FormSection>
            </TabsContent>
          </ScrollArea>
        </Tabs>

        <DialogFooter>
          <div className="flex justify-between w-full">
            <div>
              {mode === 'edit' && !isCreating && onDelete && (
                <Button
                  variant="destructive"
                  onClick={handleDelete}
                  disabled={isLoading}
                >
                  <RefreshCw className={`h-4 w-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
                  Delete User
                </Button>
              )}
            </div>
            
            <div className="flex gap-2">
              <Button
                variant="outline"
                onClick={() => setOpen(false)}
                disabled={isLoading}
              >
                <X className="h-4 w-4 mr-2" />
                {isEditing ? 'Cancel' : 'Close'}
              </Button>
              
              {isEditing && (
                <Button
                  onClick={handleSave}
                  disabled={isLoading}
                >
                  <Save className="h-4 w-4 mr-2" />
                  {isLoading ? 'Saving...' : isCreating ? 'Create User' : 'Save Changes'}
                </Button>
              )}
            </div>
          </div>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}