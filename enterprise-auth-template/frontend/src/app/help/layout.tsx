'use client';

import { ReactNode } from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Separator } from '@/components/ui/separator';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  HelpCircle,
  BookOpen,
  MessageCircle,
  FileText,
  Video,
  Mail,
  Search,
  ExternalLink,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useState } from 'react';

interface HelpLayoutProps {
  children: ReactNode;
}

const sidebarNavItems = [
  {
    title: 'Getting Started',
    href: '/help',
    icon: BookOpen,
    description: 'Quick start guide and basics',
  },
  {
    title: 'User Guide',
    href: '/help/user-guide',
    icon: FileText,
    description: 'Comprehensive user documentation',
  },
  {
    title: 'FAQ',
    href: '/help/faq',
    icon: HelpCircle,
    description: 'Frequently asked questions',
  },
  {
    title: 'Video Tutorials',
    href: '/help/tutorials',
    icon: Video,
    description: 'Step-by-step video guides',
  },
  {
    title: 'API Documentation',
    href: '/help/api',
    icon: FileText,
    description: 'Developer resources and API docs',
  },
  {
    title: 'Contact Support',
    href: '/help/contact',
    icon: MessageCircle,
    description: 'Get help from our support team',
  },
];

const quickLinks = [
  {
    title: 'System Status',
    href: 'https://status.example.com',
    icon: ExternalLink,
    external: true,
  },
  {
    title: 'Community Forum',
    href: 'https://community.example.com',
    icon: ExternalLink,
    external: true,
  },
  {
    title: 'Feature Requests',
    href: '/help/feedback',
    icon: MessageCircle,
  },
];

export default function HelpLayout({ children }: HelpLayoutProps): JSX.Element {
  const pathname = usePathname();
  const [searchQuery, setSearchQuery] = useState('');

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    // TODO: Implement search functionality
    // Search query will be processed here: searchQuery
  };

  return (
    <div className="min-h-screen bg-muted/50">
      {/* Header */}
      <header className="border-b bg-background">
        <div className="container mx-auto px-4 py-4">
          <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div className="flex items-center space-x-2">
              <Button asChild variant="ghost" size="sm">
                <Link href="/dashboard">← Back to Dashboard</Link>
              </Button>
              <Separator orientation="vertical" className="h-6" />
              <div className="flex items-center gap-2">
                <HelpCircle className="h-6 w-6 text-primary" />
                <h1 className="text-2xl font-bold text-primary">Help Center</h1>
              </div>
            </div>
            
            {/* Search Bar */}
            <div className="w-full md:w-80">
              <form onSubmit={handleSearch} className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  type="search"
                  placeholder="Search for help articles..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-10 pr-4"
                />
              </form>
            </div>
          </div>
        </div>
      </header>

      <div className="container mx-auto px-4 py-8">
        <div className="flex flex-col gap-8 lg:flex-row">
          {/* Sidebar Navigation */}
          <aside className="lg:w-1/4">
            <div className="space-y-6">
              {/* Main Navigation */}
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

              {/* Quick Links */}
              <Card>
                <CardContent className="p-4">
                  <h3 className="font-medium text-sm mb-3">Quick Links</h3>
                  <nav className="space-y-2">
                    {quickLinks.map((link) => {
                      const Icon = link.icon;
                      
                      return (
                        <Link
                          key={link.href}
                          href={link.href}
                          target={link.external ? '_blank' : undefined}
                          rel={link.external ? 'noopener noreferrer' : undefined}
                          className="flex items-center gap-3 p-2 rounded-lg transition-colors hover:bg-accent hover:text-accent-foreground text-muted-foreground"
                        >
                          <Icon className="h-4 w-4 flex-shrink-0" />
                          <span className="text-sm">{link.title}</span>
                        </Link>
                      );
                    })}
                  </nav>
                </CardContent>
              </Card>

              {/* Contact Information */}
              <Card>
                <CardContent className="p-4">
                  <h3 className="font-medium text-sm mb-3 flex items-center gap-2">
                    <Mail className="h-4 w-4" />
                    Need More Help?
                  </h3>
                  <div className="space-y-2 text-xs text-muted-foreground">
                    <p>Can&apos;t find what you&apos;re looking for?</p>
                    <Button asChild size="sm" className="w-full">
                      <Link href="/help/contact">Contact Support</Link>
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </div>
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