'use client';

import { ReactNode } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  User,
  Shield,
  Bell,
  Smartphone,
  Key,
  Globe,
  CreditCard,
  Archive,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface SettingsLayoutProps {
  children: ReactNode;
}

const sidebarNavItems = [
  {
    title: 'Profile',
    href: '/settings',
    icon: User,
    description: 'Manage your profile information',
  },
  {
    title: 'Security',
    href: '/settings/security',
    icon: Shield,
    description: 'Password and authentication settings',
  },
  {
    title: 'Notifications',
    href: '/settings/notifications',
    icon: Bell,
    description: 'Configure notification preferences',
  },
  {
    title: 'Two-Factor Auth',
    href: '/settings/2fa',
    icon: Smartphone,
    description: 'Set up two-factor authentication',
  },
  {
    title: 'API Keys',
    href: '/settings/api-keys',
    icon: Key,
    description: 'Manage your API keys',
  },
  {
    title: 'Privacy',
    href: '/settings/privacy',
    icon: Globe,
    description: 'Privacy and data settings',
  },
  {
    title: 'Billing',
    href: '/settings/billing',
    icon: CreditCard,
    description: 'Subscription and billing information',
  },
  {
    title: 'Data Export',
    href: '/settings/data-export',
    icon: Archive,
    description: 'Download your data',
  },
];

export default function SettingsLayout({ children }: SettingsLayoutProps): React.ReactElement {
  const pathname = usePathname();

  return (
    <div className="min-h-screen bg-muted/50">
      {/* Header */}
      <header className="border-b bg-background">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center space-x-2">
            <Button asChild variant="ghost" size="sm">
              <Link href="/dashboard">← Back to Dashboard</Link>
            </Button>
            <Separator orientation="vertical" className="h-6" />
            <h1 className="text-2xl font-bold text-primary">Settings</h1>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="flex flex-col gap-8 lg:flex-row">
          {/* Sidebar Navigation */}
          <aside className="lg:w-1/4">
            <Card>
              <CardContent className="p-4">
                <nav className="space-y-2">
                  {sidebarNavItems.map((item) => {
                    const Icon = item.icon;
                    const isActive = pathname === item.href;
                    
                    return (
                      <Link
                        key={item.href}
                        href={item.href}
                        className={cn(
                          'flex items-start gap-3 p-3 rounded-lg transition-colors hover:bg-accent hover:text-accent-foreground',
                          isActive ? 'bg-accent text-accent-foreground' : 'text-muted-foreground'
                        )}
                      >
                        <Icon className="h-5 w-5 mt-0.5 flex-shrink-0" />
                        <div className="flex-1 min-w-0">
                          <div className={cn('text-sm font-medium', isActive && 'text-foreground')}>
                            {item.title}
                          </div>
                          <div className="text-xs text-muted-foreground mt-1">
                            {item.description}
                          </div>
                        </div>
                      </Link>
                    );
                  })}
                </nav>
              </CardContent>
            </Card>
          </aside>

          {/* Main Content */}
          <main className="flex-1 lg:w-3/4">
            {children}
          </main>
        </div>
      </div>
    </div>
  );
}