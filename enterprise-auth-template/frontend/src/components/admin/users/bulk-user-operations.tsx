'use client';

import React, { useState, useRef } from 'react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Progress } from '@/components/ui/progress';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Upload,
  Download,
  FileText,
  AlertCircle,
  CheckCircle,
  XCircle,
  FileSpreadsheet,
  Users,
  Info,
  Copy,
  RefreshCw,
} from 'lucide-react';
import { BulkUserOperation } from '@/types/admin.types';
import AdminAPI from '@/lib/admin-api';
import { useToast } from '@/components/ui/use-toast';

interface BulkUserOperationsProps {
  open: boolean;
  onClose: () => void;
  selectedUsers?: string[];
  onSuccess?: () => void;
}

interface ImportResult {
  total: number;
  successful: number;
  failed: number;
  errors: Array<{
    row: number;
    email: string;
    error: string;
  }>;
}

interface ExportOptions {
  format: 'csv' | 'json';
  includeFields: string[];
  filters?: {
    status?: 'active' | 'inactive' | 'all';
    verified?: boolean;
    roles?: string[];
  };
}

const CSV_TEMPLATE = `email,first_name,last_name,role,department
john.doe@example.com,John,Doe,user,Engineering
jane.smith@example.com,Jane,Smith,admin,Management
bob.wilson@example.com,Bob,Wilson,user,Sales`;

const JSON_TEMPLATE = `[
  {
    "email": "john.doe@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "user",
    "department": "Engineering"
  },
  {
    "email": "jane.smith@example.com",
    "first_name": "Jane",
    "last_name": "Smith",
    "role": "admin",
    "department": "Management"
  }
]`;

export default function BulkUserOperations({
  open,
  onClose,
  selectedUsers = [],
  onSuccess
}: BulkUserOperationsProps): React.ReactElement {
  const { toast } = useToast();
  const fileInputRef = useRef<HTMLInputElement>(null);

  // State
  const [activeTab, setActiveTab] = useState<'import' | 'export' | 'bulk'>('import');
  const [loading, setLoading] = useState(false);
  const [progress, setProgress] = useState(0);

  // Import state
  const [importFile, setImportFile] = useState<File | null>(null);
  const [importFormat, setImportFormat] = useState<'csv' | 'json'>('csv');
  const [importResult, setImportResult] = useState<ImportResult | null>(null);
  const [importPreview, setImportPreview] = useState<any[]>([]);

  // Export state
  const [exportFormat, setExportFormat] = useState<'csv' | 'json'>('csv');
  const [exportFields] = useState([
    'email', 'first_name', 'last_name', 'roles', 'is_active',
    'is_verified', 'created_at', 'last_login'
  ]);
  const [selectedExportFields, setSelectedExportFields] = useState<string[]>([
    'email', 'first_name', 'last_name', 'roles'
  ]);

  // Bulk operation state
  const [bulkOperation, setBulkOperation] = useState<BulkUserOperation['operation']>('activate');
  const [bulkRoleId, setBulkRoleId] = useState<string>('');

  // Handle file upload
  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>): Promise<void> => {
    const file = event.target.files?.[0];
    if (!file) return;

    setImportFile(file);
    setImportResult(null);

    // Read and preview file content
    const reader = new FileReader();
    reader.onload = (e) => {
      const content = e.target?.result as string;
      try {
        let preview: any[] = [];

        if (importFormat === 'json') {
          preview = JSON.parse(content).slice(0, 5);
        } else {
          // Parse CSV
          const lines = content.split('\n');
          const headers = lines[0].split(',').map(h => h.trim());
          preview = lines.slice(1, 6).map(line => {
            const values = line.split(',').map(v => v.trim());
            return headers.reduce((obj, header, index) => {
              obj[header] = values[index];
              return obj;
            }, {} as any);
          });
        }

        setImportPreview(preview);
      } catch (err) {
        toast({
          title: 'Invalid file format',
          description: 'Please check your file format and try again',
          variant: 'destructive'
        });
      }
    };
    reader.readAsText(file);
  };

  // Handle import
  const handleImport = async (): Promise<void> => {
    if (!importFile) return;

    setLoading(true);
    setProgress(0);

    try {
      const formData = new FormData();
      formData.append('file', importFile);
      formData.append('format', importFormat);

      // Simulate progress
      const progressInterval = setInterval(() => {
        setProgress(prev => Math.min(prev + 10, 90));
      }, 500);

      const response = await AdminAPI.importUsers(formData);

      clearInterval(progressInterval);
      setProgress(100);

      if (response.success && response.data) {
        setImportResult(response.data as ImportResult);
        toast({
          title: 'Import completed',
          description: `Successfully imported ${response.data.successful} out of ${response.data.total} users`,
        });
        onSuccess?.();
      } else {
        throw new Error(response.error?.message || 'Import failed');
      }
    } catch (error) {
      toast({
        title: 'Import failed',
        description: error instanceof Error ? error.message : 'Failed to import users',
        variant: 'destructive'
      });
    } finally {
      setLoading(false);
      setProgress(0);
    }
  };

  // Handle export
  const handleExport = async (): Promise<void> => {
    setLoading(true);

    try {
      const options: ExportOptions = {
        format: exportFormat,
        includeFields: selectedExportFields,
      };

      const response = await AdminAPI.exportUsers(options);

      if (response.success && response.data) {
        // Download the file
        const blob = new Blob([response.data.content], {
          type: exportFormat === 'csv' ? 'text/csv' : 'application/json'
        });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `users_export_${new Date().getTime()}.${exportFormat}`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        toast({
          title: 'Export successful',
          description: `Exported ${response.data.count} users`,
        });
      }
    } catch (error) {
      toast({
        title: 'Export failed',
        description: error instanceof Error ? error.message : 'Failed to export users',
        variant: 'destructive'
      });
    } finally {
      setLoading(false);
    }
  };

  // Handle bulk operation
  const handleBulkOperation = async (): Promise<void> => {
    if (selectedUsers.length === 0) {
      toast({
        title: 'No users selected',
        description: 'Please select users to perform bulk operations',
        variant: 'destructive'
      });
      return;
    }

    setLoading(true);

    try {
      const operation: BulkUserOperation = {
        user_ids: selectedUsers,
        operation: bulkOperation,
        ...(bulkOperation === 'assign_role' && { role_id: bulkRoleId })
      };

      const response = await AdminAPI.bulkUserOperation(operation);

      if (response.success) {
        toast({
          title: 'Bulk operation completed',
          description: `Successfully processed ${response.data?.successful} users`,
        });
        onSuccess?.();
        onClose();
      }
    } catch (error) {
      toast({
        title: 'Bulk operation failed',
        description: error instanceof Error ? error.message : 'Failed to process bulk operation',
        variant: 'destructive'
      });
    } finally {
      setLoading(false);
    }
  };

  // Copy template to clipboard
  const copyTemplate = (template: string): void => {
    navigator.clipboard.writeText(template);
    toast({
      title: 'Copied to clipboard',
      description: 'Template has been copied to your clipboard',
    });
  };

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className='max-w-4xl max-h-[80vh] overflow-hidden'>
        <DialogHeader>
          <DialogTitle>Bulk User Operations</DialogTitle>
          <DialogDescription>
            Import, export, or perform bulk operations on users
          </DialogDescription>
        </DialogHeader>

        <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as any)}>
          <TabsList className='grid w-full grid-cols-3'>
            <TabsTrigger value='import'>
              <Upload className='h-4 w-4 mr-2' />
              Import Users
            </TabsTrigger>
            <TabsTrigger value='export'>
              <Download className='h-4 w-4 mr-2' />
              Export Users
            </TabsTrigger>
            <TabsTrigger value='bulk'>
              <Users className='h-4 w-4 mr-2' />
              Bulk Actions
            </TabsTrigger>
          </TabsList>

          {/* Import Tab */}
          <TabsContent value='import' className='space-y-4'>
            <div className='space-y-4'>
              {/* Format Selection */}
              <div className='space-y-2'>
                <Label>Import Format</Label>
                <Select value={importFormat} onValueChange={(v) => setImportFormat(v as any)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value='csv'>
                      <div className='flex items-center'>
                        <FileSpreadsheet className='h-4 w-4 mr-2' />
                        CSV Format
                      </div>
                    </SelectItem>
                    <SelectItem value='json'>
                      <div className='flex items-center'>
                        <FileText className='h-4 w-4 mr-2' />
                        JSON Format
                      </div>
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* File Upload */}
              <div className='space-y-2'>
                <Label>Select File</Label>
                <div className='flex gap-2'>
                  <Input
                    ref={fileInputRef}
                    type='file'
                    accept={importFormat === 'csv' ? '.csv' : '.json'}
                    onChange={handleFileUpload}
                    disabled={loading}
                  />
                  {importFile && (
                    <Badge variant='secondary'>
                      {importFile.name}
                    </Badge>
                  )}
                </div>
              </div>

              {/* Template Section */}
              <div className='space-y-2'>
                <div className='flex items-center justify-between'>
                  <Label>Template</Label>
                  <Button
                    variant='ghost'
                    size='sm'
                    onClick={() => copyTemplate(importFormat === 'csv' ? CSV_TEMPLATE : JSON_TEMPLATE)}
                  >
                    <Copy className='h-4 w-4 mr-2' />
                    Copy Template
                  </Button>
                </div>
                <Textarea
                  value={importFormat === 'csv' ? CSV_TEMPLATE : JSON_TEMPLATE}
                  readOnly
                  className='font-mono text-xs'
                  rows={6}
                />
              </div>

              {/* Preview */}
              {importPreview.length > 0 && (
                <div className='space-y-2'>
                  <Label>Preview (First 5 records)</Label>
                  <ScrollArea className='h-48 rounded-md border p-4'>
                    <pre className='text-xs'>
                      {JSON.stringify(importPreview, null, 2)}
                    </pre>
                  </ScrollArea>
                </div>
              )}

              {/* Progress */}
              {loading && (
                <div className='space-y-2'>
                  <Label>Import Progress</Label>
                  <Progress value={progress} />
                  <p className='text-sm text-muted-foreground'>
                    Processing... {progress}%
                  </p>
                </div>
              )}

              {/* Import Result */}
              {importResult && (
                <Alert>
                  <Info className='h-4 w-4' />
                  <AlertDescription>
                    <div className='space-y-2'>
                      <div className='flex items-center gap-4'>
                        <Badge variant='default'>
                          Total: {importResult.total}
                        </Badge>
                        <Badge variant='default' className='bg-green-600'>
                          <CheckCircle className='h-3 w-3 mr-1' />
                          Success: {importResult.successful}
                        </Badge>
                        <Badge variant='destructive'>
                          <XCircle className='h-3 w-3 mr-1' />
                          Failed: {importResult.failed}
                        </Badge>
                      </div>
                      {importResult.errors.length > 0 && (
                        <ScrollArea className='h-32 mt-2'>
                          <div className='space-y-1'>
                            {importResult.errors.map((error, idx) => (
                              <div key={idx} className='text-xs text-destructive'>
                                Row {error.row} ({error.email}): {error.error}
                              </div>
                            ))}
                          </div>
                        </ScrollArea>
                      )}
                    </div>
                  </AlertDescription>
                </Alert>
              )}
            </div>
          </TabsContent>

          {/* Export Tab */}
          <TabsContent value='export' className='space-y-4'>
            <div className='space-y-4'>
              {/* Format Selection */}
              <div className='space-y-2'>
                <Label>Export Format</Label>
                <Select value={exportFormat} onValueChange={(v) => setExportFormat(v as any)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value='csv'>CSV Format</SelectItem>
                    <SelectItem value='json'>JSON Format</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Field Selection */}
              <div className='space-y-2'>
                <Label>Fields to Export</Label>
                <div className='grid grid-cols-2 gap-2'>
                  {exportFields.map(field => (
                    <label key={field} className='flex items-center space-x-2'>
                      <input
                        type='checkbox'
                        checked={selectedExportFields.includes(field)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedExportFields([...selectedExportFields, field]);
                          } else {
                            setSelectedExportFields(selectedExportFields.filter(f => f !== field));
                          }
                        }}
                        className='rounded border-gray-300'
                      />
                      <span className='text-sm'>{field.replace('_', ' ')}</span>
                    </label>
                  ))}
                </div>
              </div>

              <Alert>
                <Info className='h-4 w-4' />
                <AlertDescription>
                  Export will include all users based on current filters.
                  The file will be downloaded to your device.
                </AlertDescription>
              </Alert>
            </div>
          </TabsContent>

          {/* Bulk Actions Tab */}
          <TabsContent value='bulk' className='space-y-4'>
            <div className='space-y-4'>
              {/* Selected Users Info */}
              <Alert>
                <Users className='h-4 w-4' />
                <AlertDescription>
                  {selectedUsers.length > 0 ? (
                    <span>{selectedUsers.length} users selected for bulk operation</span>
                  ) : (
                    <span>No users selected. Please select users from the table first.</span>
                  )}
                </AlertDescription>
              </Alert>

              {/* Operation Selection */}
              <div className='space-y-2'>
                <Label>Bulk Operation</Label>
                <Select value={bulkOperation} onValueChange={(v) => setBulkOperation(v as any)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value='activate'>Activate Users</SelectItem>
                    <SelectItem value='deactivate'>Deactivate Users</SelectItem>
                    <SelectItem value='verify'>Verify Users</SelectItem>
                    <SelectItem value='unverify'>Unverify Users</SelectItem>
                    <SelectItem value='assign_role'>Assign Role</SelectItem>
                    <SelectItem value='remove_role'>Remove Role</SelectItem>
                    <SelectItem value='delete'>Delete Users</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Role Selection for role operations */}
              {(bulkOperation === 'assign_role' || bulkOperation === 'remove_role') && (
                <div className='space-y-2'>
                  <Label>Select Role</Label>
                  <Select value={bulkRoleId} onValueChange={setBulkRoleId}>
                    <SelectTrigger>
                      <SelectValue placeholder='Choose a role' />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value='admin'>Admin</SelectItem>
                      <SelectItem value='user'>User</SelectItem>
                      <SelectItem value='moderator'>Moderator</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              )}

              {/* Warning for destructive operations */}
              {bulkOperation === 'delete' && (
                <Alert variant='destructive'>
                  <AlertCircle className='h-4 w-4' />
                  <AlertDescription>
                    This action cannot be undone. Users will be permanently deleted.
                  </AlertDescription>
                </Alert>
              )}
            </div>
          </TabsContent>
        </Tabs>

        <Separator className='my-4' />

        <DialogFooter>
          <Button variant='outline' onClick={onClose} disabled={loading}>
            Cancel
          </Button>
          {activeTab === 'import' && (
            <Button
              onClick={handleImport}
              disabled={!importFile || loading}
            >
              {loading ? (
                <>
                  <RefreshCw className='h-4 w-4 mr-2 animate-spin' />
                  Importing...
                </>
              ) : (
                <>
                  <Upload className='h-4 w-4 mr-2' />
                  Import Users
                </>
              )}
            </Button>
          )}
          {activeTab === 'export' && (
            <Button
              onClick={handleExport}
              disabled={selectedExportFields.length === 0 || loading}
            >
              {loading ? (
                <>
                  <RefreshCw className='h-4 w-4 mr-2 animate-spin' />
                  Exporting...
                </>
              ) : (
                <>
                  <Download className='h-4 w-4 mr-2' />
                  Export Users
                </>
              )}
            </Button>
          )}
          {activeTab === 'bulk' && (
            <Button
              onClick={handleBulkOperation}
              disabled={selectedUsers.length === 0 || loading}
              variant={bulkOperation === 'delete' ? 'destructive' : 'default'}
            >
              {loading ? (
                <>
                  <RefreshCw className='h-4 w-4 mr-2 animate-spin' />
                  Processing...
                </>
              ) : (
                <>
                  <Users className='h-4 w-4 mr-2' />
                  Execute Operation
                </>
              )}
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}