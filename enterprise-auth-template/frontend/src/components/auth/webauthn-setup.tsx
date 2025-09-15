'use client';

/**
 * WebAuthn Setup Component
 * 
 * Provides a comprehensive interface for users to manage their passkeys including:
 * - Registering new passkeys
 * - Viewing existing passkeys
 * - Deleting passkeys
 * - Device information and usage statistics
 * 
 * Supports enterprise security policies and user experience best practices.
 */

import React, { useState, useEffect } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Trash2,
  Plus,
  Shield,
  Smartphone,
  Monitor,
  Key,
  AlertTriangle,
  CheckCircle,
  Clock,
} from 'lucide-react';
import { useToast } from '@/hooks/use-toast';
import { webAuthnService } from '@/services/auth-api.service';

// Type for WebAuthn credentials
interface WebAuthnCredential {
  id: string;
  device_name: string;
  created_at: string;
  last_used: string | null;
  transports: string[];
  aaguid: string;
  credential_id_preview: string;
}

interface WebAuthnSetupProps {
  /** Current user information */
  user: {
    id: string;
    email: string;
    first_name: string;
    last_name: string;
  };
  /** Whether user has password backup */
  hasPasswordBackup?: boolean;
  /** Callback when credentials change */
  onCredentialsChange?: (credentials: WebAuthnCredential[]) => void;
}

export function WebAuthnSetup({ 
  user: _user, // eslint-disable-line @typescript-eslint/no-unused-vars
  hasPasswordBackup = true,
  onCredentialsChange 
}: WebAuthnSetupProps) {
  // Note: _user prop available for future use
  const [credentials, setCredentials] = useState<WebAuthnCredential[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isRegistering, setIsRegistering] = useState(false);
  const [isDeletingId, setIsDeletingId] = useState<string | null>(null);
  const [showDeleteDialog, setShowDeleteDialog] = useState<string | null>(null);
  const [showAddDialog, setShowAddDialog] = useState(false);
  const [deviceName, setDeviceName] = useState('');
  const [error, setError] = useState<string | null>(null);
  const { toast } = useToast();

  // Load user's existing credentials
  useEffect(() => {
    loadCredentials();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const loadCredentials = async () => {
    try {
      setIsLoading(true);
      setError(null);
      
      const userCredentials = await webAuthnService.getUserCredentials();
      setCredentials(userCredentials);
      onCredentialsChange?.(userCredentials);
      
    } catch (_err) { // eslint-disable-line @typescript-eslint/no-unused-vars
      // Failed to load WebAuthn credentials - error already handled
      setError('Failed to load your passkeys. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleRegisterPasskey = async () => {
    if (!deviceName.trim()) {
      toast({
        title: 'Device name required',
        description: 'Please enter a name for this passkey.',
        variant: 'destructive',
      });
      return;
    }

    try {
      setIsRegistering(true);
      setError(null);

      await webAuthnService.registerCredential(deviceName.trim());
      
      toast({
        title: 'Passkey registered',
        description: `Successfully registered passkey for ${deviceName}`,
      });

      // Reload credentials and close dialog
      await loadCredentials();
      setShowAddDialog(false);
      setDeviceName('');
      
    } catch (err: unknown) {
      // WebAuthn registration failed - error already handled
      
      let errorMessage = 'Failed to register passkey. Please try again.';
      
      // Handle specific WebAuthn errors
      if (err instanceof Error) {
        if (err.name === 'NotAllowedError') {
          errorMessage = 'Registration was cancelled or timed out.';
        } else if (err.name === 'NotSupportedError') {
          errorMessage = 'Passkeys are not supported on this device/browser.';
        } else if (err.name === 'InvalidStateError') {
          errorMessage = 'A passkey for this account already exists on this device.';
        } else if (err.message) {
          errorMessage = err.message;
        }
      }

      toast({
        title: 'Registration failed',
        description: errorMessage,
        variant: 'destructive',
      });
      
    } finally {
      setIsRegistering(false);
    }
  };

  const handleDeleteCredential = async (credentialId: string) => {
    try {
      setIsDeletingId(credentialId);
      setError(null);

      const response = await webAuthnService.deleteCredential(credentialId);

      if (response.success) {
        toast({
          title: 'Passkey deleted',
          description: 'The passkey has been removed from your account.',
        });

        // Reload credentials and close dialog
        await loadCredentials();
        setShowDeleteDialog(null);
      } else {
        throw new Error(response.error?.message || 'Failed to delete passkey');
      }

    } catch (err: unknown) {
      // Failed to delete WebAuthn credential - error already handled
      
      let errorMessage = 'Failed to delete passkey. Please try again.';
      if (err instanceof Error) {
        if (err.message?.includes('LAST_CREDENTIAL')) {
          errorMessage = 'Cannot delete your last passkey without a password backup.';
        } else if (err.message) {
          errorMessage = err.message;
        }
      }

      toast({
        title: 'Deletion failed',
        description: errorMessage,
        variant: 'destructive',
      });
      
    } finally {
      setIsDeletingId(null);
    }
  };

  const getDeviceIcon = (transports: string[]) => {
    if (transports.includes('internal')) {
      return <Smartphone className="h-4 w-4" />;
    } else if (transports.includes('usb')) {
      return <Key className="h-4 w-4" />;
    } else {
      return <Monitor className="h-4 w-4" />;
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const canDeleteCredential = () => {
    // Can delete if user has password backup OR more than one credential  
    return hasPasswordBackup || credentials.length > 1;
  };

  if (isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Passkeys
          </CardTitle>
          <CardDescription>
            Loading your passkeys...
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center justify-center py-8">
            <div className="animate-pulse">Loading...</div>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <>
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5" />
            Passkeys
            <Badge variant="secondary">{credentials.length}</Badge>
          </CardTitle>
          <CardDescription>
            Secure, passwordless authentication using your device&apos;s built-in security.
            Use Face ID, Touch ID, Windows Hello, or hardware security keys.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {error && (
            <Alert variant="destructive">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          {!hasPasswordBackup && credentials.length === 0 && (
            <Alert>
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>
                You don&apos;t have a password set. We recommend adding a passkey as your primary 
                authentication method.
              </AlertDescription>
            </Alert>
          )}

          {credentials.length === 0 ? (
            <div className="text-center py-8">
              <Shield className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
              <h3 className="text-lg font-medium mb-2">No passkeys registered</h3>
              <p className="text-muted-foreground mb-4">
                Add a passkey for secure, passwordless access to your account.
              </p>
              <Button onClick={() => setShowAddDialog(true)}>
                <Plus className="h-4 w-4 mr-2" />
                Add your first passkey
              </Button>
            </div>
          ) : (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-lg font-medium">Your passkeys</h3>
                <Button 
                  onClick={() => setShowAddDialog(true)}
                  size="sm"
                  disabled={credentials.length >= 10} // Enterprise limit
                >
                  <Plus className="h-4 w-4 mr-2" />
                  Add passkey
                </Button>
              </div>

              {credentials.length >= 10 && (
                <Alert>
                  <AlertTriangle className="h-4 w-4" />
                  <AlertDescription>
                    You&apos;ve reached the maximum limit of 10 passkeys. Please remove unused 
                    passkeys to add new ones.
                  </AlertDescription>
                </Alert>
              )}

              <div className="space-y-3">
                {credentials.map((credential) => (
                  <div
                    key={credential.id}
                    className="flex items-center justify-between p-4 border rounded-lg"
                  >
                    <div className="flex items-center gap-3">
                      {getDeviceIcon(credential.transports)}
                      <div>
                        <div className="font-medium">{credential.device_name}</div>
                        <div className="text-sm text-muted-foreground flex items-center gap-4">
                          <span className="flex items-center gap-1">
                            <Clock className="h-3 w-3" />
                            Added {formatDate(credential.created_at)}
                          </span>
                          {credential.last_used && (
                            <span className="flex items-center gap-1">
                              <CheckCircle className="h-3 w-3" />
                              Last used {formatDate(credential.last_used)}
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                    
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setShowDeleteDialog(credential.id)}
                      disabled={
                        isDeletingId === credential.id || 
                        !canDeleteCredential()
                      }
                      className="text-destructive hover:text-destructive"
                    >
                      {isDeletingId === credential.id ? (
                        'Removing...'
                      ) : (
                        <>
                          <Trash2 className="h-4 w-4 mr-2" />
                          Remove
                        </>
                      )}
                    </Button>
                  </div>
                ))}
              </div>

              {credentials.length === 1 && !hasPasswordBackup && (
                <Alert>
                  <AlertTriangle className="h-4 w-4" />
                  <AlertDescription>
                    This is your only authentication method. Consider setting up a password 
                    backup or adding another passkey to avoid being locked out.
                  </AlertDescription>
                </Alert>
              )}
            </div>
          )}

          <Separator />
          
          <div className="text-sm text-muted-foreground space-y-2">
            <h4 className="font-medium text-foreground">About passkeys:</h4>
            <ul className="space-y-1 ml-4">
              <li>• More secure than passwords - protected by your device&apos;s biometrics</li>
              <li>• Works across devices when synced (iCloud, Google Password Manager)</li>
              <li>• Phishing-resistant - works only on the correct website</li>
              <li>• Faster login - no need to remember or type passwords</li>
            </ul>
          </div>
        </CardContent>
      </Card>

      {/* Add Passkey Dialog */}
      <Dialog open={showAddDialog} onOpenChange={setShowAddDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Add a new passkey</DialogTitle>
            <DialogDescription>
              Give your passkey a name to help you identify it later.
            </DialogDescription>
          </DialogHeader>
          
          <div className="space-y-4">
            <div>
              <Label htmlFor="device-name">Device name</Label>
              <Input
                id="device-name"
                value={deviceName}
                onChange={(e) => setDeviceName(e.target.value)}
                placeholder="e.g., iPhone, MacBook, YubiKey"
                maxLength={50}
              />
            </div>
          </div>

          <DialogFooter>
            <Button 
              variant="outline" 
              onClick={() => setShowAddDialog(false)}
              disabled={isRegistering}
            >
              Cancel
            </Button>
            <Button 
              onClick={handleRegisterPasskey}
              disabled={isRegistering || !deviceName.trim()}
            >
              {isRegistering ? 'Creating passkey...' : 'Create passkey'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog 
        open={showDeleteDialog !== null} 
        onOpenChange={() => setShowDeleteDialog(null)}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Remove passkey</DialogTitle>
            <DialogDescription>
              Are you sure you want to remove this passkey? You won&apos;t be able to use it 
              to sign in anymore.
            </DialogDescription>
          </DialogHeader>

          {showDeleteDialog && (
            <div className="py-4">
              <div className="font-medium">
                {credentials.find(c => c.id === showDeleteDialog)?.device_name}
              </div>
              <div className="text-sm text-muted-foreground">
                Added {formatDate(
                  credentials.find(c => c.id === showDeleteDialog)?.created_at || ''
                )}
              </div>
            </div>
          )}

          <DialogFooter>
            <Button 
              variant="outline" 
              onClick={() => setShowDeleteDialog(null)}
              disabled={isDeletingId !== null}
            >
              Cancel
            </Button>
            <Button 
              variant="destructive"
              onClick={() => showDeleteDialog && handleDeleteCredential(showDeleteDialog)}
              disabled={isDeletingId !== null}
            >
              {isDeletingId ? 'Removing...' : 'Remove passkey'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}