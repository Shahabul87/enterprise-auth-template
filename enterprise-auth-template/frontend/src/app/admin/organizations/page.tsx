'use client';

import { useState, useEffect } from 'react';
import { useRequireAuth } from '@/stores/auth.store';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Building2,
  Plus,
  MoreHorizontal,
  Users,
  Globe,
  UserPlus,
  Crown,
  Settings,
  Trash2,
  Mail,
  ExternalLink,
  CheckCircle,
  XCircle,
  Clock,
} from 'lucide-react';
import { toast } from 'sonner';

// Types based on backend API
type OrganizationRole = 'owner' | 'admin' | 'member' | 'viewer';
type OrganizationSize = 'startup' | 'small' | 'medium' | 'large' | 'enterprise';

interface OrganizationResponse {
  id: string;
  name: string;
  description: string | null;
  website: string | null;
  industry: string | null;
  size: OrganizationSize | null;
  country: string | null;
  timezone: string | null;
  is_active: boolean;
  member_count: number;
  created_at: string;
  updated_at: string;
  current_user_role: OrganizationRole | null;
}

interface OrganizationMember {
  id: string;
  user_id: string;
  email: string;
  name: string;
  role: OrganizationRole;
  status: 'active' | 'invited' | 'suspended';
  joined_at: string | null;
  invited_at: string;
  invited_by: string;
}

interface OrganizationCreateRequest {
  name: string;
  description?: string;
  website?: string;
  industry?: string;
  size?: OrganizationSize;
  country?: string;
  timezone?: string;
}

interface OrganizationMemberInviteRequest {
  email: string;
  role: OrganizationRole;
  message?: string;
}

const ORGANIZATION_SIZES: Record<OrganizationSize, string> = {
  startup: '1-10 employees',
  small: '11-50 employees',
  medium: '51-200 employees',
  large: '201-1000 employees',
  enterprise: '1000+ employees',
};

const ORGANIZATION_ROLES: Record<OrganizationRole, { label: string; description: string }> = {
  owner: { label: 'Owner', description: 'Full control over the organization' },
  admin: { label: 'Admin', description: 'Manage members and organization settings' },
  member: { label: 'Member', description: 'Access organization resources' },
  viewer: { label: 'Viewer', description: 'Read-only access to organization' },
};

export default function OrganizationsPage(): JSX.Element {
  const { user } = useRequireAuth();
  const [organizations, setOrganizations] = useState<OrganizationResponse[]>([]);
  const [selectedOrganization, setSelectedOrganization] = useState<OrganizationResponse | null>(null);
  const [organizationMembers, setOrganizationMembers] = useState<OrganizationMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [inviteDialogOpen, setInviteDialogOpen] = useState(false);
  const [membersDialogOpen, setMembersDialogOpen] = useState(false);
  const [createForm, setCreateForm] = useState<OrganizationCreateRequest>({
    name: '',
    description: '',
    website: '',
    industry: '',
    size: 'small',
    country: 'US',
    timezone: 'America/New_York',
  });
  const [inviteForm, setInviteForm] = useState<OrganizationMemberInviteRequest>({
    email: '',
    role: 'member',
    message: '',
  });

  useEffect(() => {
    loadOrganizations();
  }, []);

  const loadOrganizations = async (): Promise<void> => {
    try {
      setLoading(true);
      // TODO: Replace with actual API call
      const mockData: OrganizationResponse[] = [
        {
          id: '1',
          name: 'Acme Corporation',
          description: 'Leading provider of innovative solutions in the tech industry',
          website: 'https://acme.com',
          industry: 'Technology',
          size: 'medium',
          country: 'US',
          timezone: 'America/New_York',
          is_active: true,
          member_count: 45,
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 180).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 7).toISOString(),
          current_user_role: 'admin',
        },
        {
          id: '2',
          name: 'StartupXYZ',
          description: 'Fast-growing startup disrupting the fintech space',
          website: 'https://startupxyz.com',
          industry: 'Financial Services',
          size: 'startup',
          country: 'US',
          timezone: 'America/Los_Angeles',
          is_active: true,
          member_count: 8,
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 90).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 2).toISOString(),
          current_user_role: 'owner',
        },
        {
          id: '3',
          name: 'Global Enterprises Inc',
          description: 'Multinational corporation with operations worldwide',
          website: 'https://globalenterprises.com',
          industry: 'Manufacturing',
          size: 'enterprise',
          country: 'US',
          timezone: 'America/New_York',
          is_active: false,
          member_count: 1250,
          created_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 365).toISOString(),
          updated_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30).toISOString(),
          current_user_role: 'member',
        },
      ];
      setOrganizations(mockData);
    } catch {
      toast.error('Failed to load organizations');
    } finally {
      setLoading(false);
    }
  };

  const loadOrganizationMembers = async (): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      const mockMembers: OrganizationMember[] = [
        {
          id: '1',
          user_id: 'user1',
          email: 'john.doe@acme.com',
          name: 'John Doe',
          role: 'owner',
          status: 'active',
          joined_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 180).toISOString(),
          invited_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 180).toISOString(),
          invited_by: 'system',
        },
        {
          id: '2',
          user_id: 'user2',
          email: 'jane.smith@acme.com',
          name: 'Jane Smith',
          role: 'admin',
          status: 'active',
          joined_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 120).toISOString(),
          invited_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 125).toISOString(),
          invited_by: 'john.doe@acme.com',
        },
        {
          id: '3',
          user_id: 'user3',
          email: 'bob.wilson@acme.com',
          name: 'Bob Wilson',
          role: 'member',
          status: 'invited',
          joined_at: null,
          invited_at: new Date(Date.now() - 1000 * 60 * 60 * 24 * 3).toISOString(),
          invited_by: 'jane.smith@acme.com',
        },
      ];
      setOrganizationMembers(mockMembers);
    } catch {
      toast.error('Failed to load organization members');
    }
  };

  const handleCreateOrganization = async (): Promise<void> => {
    try {
      if (!createForm.name.trim()) {
        toast.error('Organization name is required');
        return;
      }

      // TODO: Replace with actual API call
      const newOrganization: OrganizationResponse = {
        id: String(organizations.length + 1),
        name: createForm.name,
        description: createForm.description || null,
        website: createForm.website || null,
        industry: createForm.industry || null,
        size: createForm.size || null,
        country: createForm.country || null,
        timezone: createForm.timezone || null,
        is_active: true,
        member_count: 1,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
        current_user_role: 'owner',
      };

      setOrganizations(prev => [...prev, newOrganization]);
      setCreateDialogOpen(false);
      
      // Reset form
      setCreateForm({
        name: '',
        description: '',
        website: '',
        industry: '',
        size: 'small',
        country: 'US',
        timezone: 'America/New_York',
      });
      
      toast.success('Organization created successfully');
    } catch {
      toast.error('Failed to create organization');
    }
  };

  const handleInviteMember = async (): Promise<void> => {
    try {
      if (!inviteForm.email.trim()) {
        toast.error('Email address is required');
        return;
      }

      if (!selectedOrganization) {
        toast.error('No organization selected');
        return;
      }

      // TODO: Replace with actual API call
      const newMember: OrganizationMember = {
        id: String(organizationMembers.length + 1),
        user_id: `user${organizationMembers.length + 1}`,
        email: inviteForm.email,
        name: inviteForm.email.split('@')[0] || inviteForm.email,
        role: inviteForm.role,
        status: 'invited',
        joined_at: null,
        invited_at: new Date().toISOString(),
        invited_by: user?.email || 'current-user',
      };

      setOrganizationMembers(prev => [...prev, newMember]);
      setInviteDialogOpen(false);
      
      // Reset form
      setInviteForm({
        email: '',
        role: 'member',
        message: '',
      });
      
      toast.success('Invitation sent successfully');
    } catch {
      toast.error('Failed to send invitation');
    }
  };

  const handleToggleOrganization = async (orgId: string, isActive: boolean): Promise<void> => {
    try {
      // TODO: Replace with actual API call
      setOrganizations(prev => 
        prev.map(org => 
          org.id === orgId ? { ...org, is_active: !isActive } : org
        )
      );
      toast.success(isActive ? 'Organization deactivated' : 'Organization activated');
    } catch {
      toast.error('Failed to update organization');
    }
  };

  const handleViewMembers = (organization: OrganizationResponse): void => {
    setSelectedOrganization(organization);
    loadOrganizationMembers();
    setMembersDialogOpen(true);
  };

  const formatDate = (dateString: string): string => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const getRoleIcon = (role: OrganizationRole): JSX.Element => {
    switch (role) {
      case 'owner':
        return <Crown className="h-4 w-4 text-yellow-500" />;
      case 'admin':
        return <Settings className="h-4 w-4 text-blue-500" />;
      case 'member':
        return <Users className="h-4 w-4 text-green-500" />;
      case 'viewer':
        return <Users className="h-4 w-4 text-gray-500" />;
      default:
        return <Users className="h-4 w-4" />;
    }
  };

  const getStatusIcon = (status: 'active' | 'invited' | 'suspended'): JSX.Element => {
    switch (status) {
      case 'active':
        return <CheckCircle className="h-4 w-4 text-green-500" />;
      case 'invited':
        return <Clock className="h-4 w-4 text-yellow-500" />;
      case 'suspended':
        return <XCircle className="h-4 w-4 text-red-500" />;
      default:
        return <Clock className="h-4 w-4" />;
    }
  };

  if (!user) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  if (loading) {
    return (
      <Card>
        <CardContent className="py-12 text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading organizations...</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center gap-2">
                <Building2 className="h-5 w-5" />
                Organizations Management
              </CardTitle>
              <CardDescription>
                Create and manage organizations for multi-tenant access control.
                Organizations allow you to group users and manage permissions at scale.
              </CardDescription>
            </div>
            <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="h-4 w-4 mr-2" />
                  Create Organization
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-2xl">
                <DialogHeader>
                  <DialogTitle>Create New Organization</DialogTitle>
                  <DialogDescription>
                    Create a new organization to group users and manage permissions.
                  </DialogDescription>
                </DialogHeader>
                
                <div className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="name">Name *</Label>
                      <Input
                        id="name"
                        placeholder="Acme Corporation"
                        value={createForm.name}
                        onChange={(e) => setCreateForm(prev => ({ ...prev, name: e.target.value }))}
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="industry">Industry</Label>
                      <Input
                        id="industry"
                        placeholder="Technology, Healthcare, etc."
                        value={createForm.industry}
                        onChange={(e) => setCreateForm(prev => ({ ...prev, industry: e.target.value }))}
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="description">Description</Label>
                    <Textarea
                      id="description"
                      placeholder="Brief description of the organization"
                      value={createForm.description}
                      onChange={(e) => setCreateForm(prev => ({ ...prev, description: e.target.value }))}
                      rows={3}
                    />
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="website">Website</Label>
                      <Input
                        id="website"
                        placeholder="https://example.com"
                        value={createForm.website}
                        onChange={(e) => setCreateForm(prev => ({ ...prev, website: e.target.value }))}
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="size">Organization Size</Label>
                      <Select
                        {...(createForm.size ? { value: createForm.size } : {})}
                        onValueChange={(value: string) => {
                          setCreateForm(prev => ({ ...prev, size: value as OrganizationSize }));
                        }}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          {Object.entries(ORGANIZATION_SIZES).map(([value, label]) => (
                            <SelectItem key={value} value={value}>
                              {label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label htmlFor="country">Country</Label>
                      <Select
                        {...(createForm.country ? { value: createForm.country } : {})}
                        onValueChange={(value: string) => {
                          setCreateForm(prev => ({ ...prev, country: value }));
                        }}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="US">United States</SelectItem>
                          <SelectItem value="CA">Canada</SelectItem>
                          <SelectItem value="UK">United Kingdom</SelectItem>
                          <SelectItem value="DE">Germany</SelectItem>
                          <SelectItem value="FR">France</SelectItem>
                          <SelectItem value="JP">Japan</SelectItem>
                          <SelectItem value="AU">Australia</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="timezone">Timezone</Label>
                      <Select
                        {...(createForm.timezone ? { value: createForm.timezone } : {})}
                        onValueChange={(value: string) => {
                          setCreateForm(prev => ({ ...prev, timezone: value }));
                        }}
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="America/New_York">Eastern Time</SelectItem>
                          <SelectItem value="America/Chicago">Central Time</SelectItem>
                          <SelectItem value="America/Denver">Mountain Time</SelectItem>
                          <SelectItem value="America/Los_Angeles">Pacific Time</SelectItem>
                          <SelectItem value="Europe/London">London</SelectItem>
                          <SelectItem value="Europe/Paris">Paris</SelectItem>
                          <SelectItem value="Asia/Tokyo">Tokyo</SelectItem>
                          <SelectItem value="Australia/Sydney">Sydney</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                </div>

                <DialogFooter>
                  <Button variant="outline" onClick={() => setCreateDialogOpen(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleCreateOrganization}>
                    Create Organization
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
      </Card>

      {/* Organizations Table */}
      <Card>
        <CardHeader>
          <CardTitle>Organizations ({organizations.length})</CardTitle>
        </CardHeader>
        <CardContent>
          {organizations.length === 0 ? (
            <div className="text-center py-12">
              <Building2 className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-medium text-muted-foreground mb-2">No organizations yet</h3>
              <p className="text-sm text-muted-foreground mb-4">
                Create your first organization to start managing users and permissions.
              </p>
              <Button onClick={() => setCreateDialogOpen(true)}>
                <Plus className="h-4 w-4 mr-2" />
                Create Your First Organization
              </Button>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Organization</TableHead>
                  <TableHead>Industry</TableHead>
                  <TableHead>Size</TableHead>
                  <TableHead>Members</TableHead>
                  <TableHead>Your Role</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {organizations.map((org) => (
                  <TableRow key={org.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium flex items-center gap-2">
                          {org.name}
                          {org.website && (
                            <a 
                              href={org.website} 
                              target="_blank" 
                              rel="noopener noreferrer"
                              className="text-muted-foreground hover:text-primary"
                            >
                              <ExternalLink className="h-3 w-3" />
                            </a>
                          )}
                        </div>
                        {org.description && (
                          <div className="text-sm text-muted-foreground max-w-xs truncate">
                            {org.description}
                          </div>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>{org.industry || '-'}</TableCell>
                    <TableCell>
                      {org.size ? (
                        <Badge variant="secondary">
                          {ORGANIZATION_SIZES[org.size]}
                        </Badge>
                      ) : '-'}
                    </TableCell>
                    <TableCell>
                      <Button
                        variant="link"
                        className="p-0 h-auto"
                        onClick={() => handleViewMembers(org)}
                      >
                        {org.member_count} member{org.member_count !== 1 ? 's' : ''}
                      </Button>
                    </TableCell>
                    <TableCell>
                      {org.current_user_role ? (
                        <div className="flex items-center gap-1">
                          {getRoleIcon(org.current_user_role)}
                          <span className="text-sm">{ORGANIZATION_ROLES[org.current_user_role].label}</span>
                        </div>
                      ) : '-'}
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <Switch
                          checked={org.is_active}
                          onCheckedChange={() => handleToggleOrganization(org.id, org.is_active)}
                          disabled={org.current_user_role !== 'owner' && org.current_user_role !== 'admin'}
                        />
                        <span className={`text-sm ${org.is_active ? 'text-green-600' : 'text-gray-500'}`}>
                          {org.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {formatDate(org.created_at)}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="sm">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleViewMembers(org)}>
                            <Users className="h-4 w-4 mr-2" />
                            Manage Members
                          </DropdownMenuItem>
                          <DropdownMenuItem 
                            onClick={() => {
                              setSelectedOrganization(org);
                              setInviteDialogOpen(true);
                            }}
                            disabled={org.current_user_role !== 'owner' && org.current_user_role !== 'admin'}
                          >
                            <UserPlus className="h-4 w-4 mr-2" />
                            Invite Member
                          </DropdownMenuItem>
                          {org.website && (
                            <DropdownMenuItem asChild>
                              <a href={org.website} target="_blank" rel="noopener noreferrer">
                                <Globe className="h-4 w-4 mr-2" />
                                Visit Website
                              </a>
                            </DropdownMenuItem>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Invite Member Dialog */}
      <Dialog open={inviteDialogOpen} onOpenChange={setInviteDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Invite Member</DialogTitle>
            <DialogDescription>
              Invite a new member to {selectedOrganization?.name}.
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="invite-email">Email Address *</Label>
              <Input
                id="invite-email"
                type="email"
                placeholder="user@example.com"
                value={inviteForm.email}
                onChange={(e) => setInviteForm(prev => ({ ...prev, email: e.target.value }))}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="invite-role">Role</Label>
              <Select
                value={inviteForm.role}
                onValueChange={(value: OrganizationRole) => {
                  setInviteForm(prev => ({ ...prev, role: value }));
                }}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {Object.entries(ORGANIZATION_ROLES).map(([value, info]) => (
                    <SelectItem key={value} value={value}>
                      <div className="flex items-center gap-2">
                        {getRoleIcon(value as OrganizationRole)}
                        <div>
                          <div className="font-medium">{info.label}</div>
                          <div className="text-xs text-muted-foreground">{info.description}</div>
                        </div>
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="invite-message">Custom Message (optional)</Label>
              <Textarea
                id="invite-message"
                placeholder="Welcome to our organization!"
                value={inviteForm.message}
                onChange={(e) => setInviteForm(prev => ({ ...prev, message: e.target.value }))}
                rows={3}
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setInviteDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleInviteMember}>
              <Mail className="h-4 w-4 mr-2" />
              Send Invitation
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Members Management Dialog */}
      <Dialog open={membersDialogOpen} onOpenChange={setMembersDialogOpen}>
        <DialogContent className="max-w-4xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Users className="h-5 w-5" />
              {selectedOrganization?.name} Members
            </DialogTitle>
            <DialogDescription>
              Manage members and their roles in this organization.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div className="text-sm text-muted-foreground">
                {organizationMembers.length} member{organizationMembers.length !== 1 ? 's' : ''}
              </div>
              <Button
                size="sm"
                onClick={() => {
                  setMembersDialogOpen(false);
                  setInviteDialogOpen(true);
                }}
                disabled={selectedOrganization?.current_user_role !== 'owner' && selectedOrganization?.current_user_role !== 'admin'}
              >
                <UserPlus className="h-4 w-4 mr-2" />
                Invite Member
              </Button>
            </div>

            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Member</TableHead>
                  <TableHead>Role</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Joined</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {organizationMembers.map((member) => (
                  <TableRow key={member.id}>
                    <TableCell>
                      <div>
                        <div className="font-medium">{member.name}</div>
                        <div className="text-sm text-muted-foreground">{member.email}</div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {getRoleIcon(member.role)}
                        <span>{ORGANIZATION_ROLES[member.role].label}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {getStatusIcon(member.status)}
                        <span className="capitalize">{member.status}</span>
                      </div>
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {member.joined_at ? formatDate(member.joined_at) : 'Pending'}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="sm">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem disabled>
                            <Settings className="h-4 w-4 mr-2" />
                            Change Role
                          </DropdownMenuItem>
                          <DropdownMenuItem 
                            className="text-destructive"
                            disabled={member.role === 'owner'}
                          >
                            <Trash2 className="h-4 w-4 mr-2" />
                            Remove Member
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>

          <DialogFooter>
            <Button onClick={() => setMembersDialogOpen(false)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}