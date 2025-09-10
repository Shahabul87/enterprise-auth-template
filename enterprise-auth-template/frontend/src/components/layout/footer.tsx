'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { Badge } from '@/components/ui/badge';
import {
  ExternalLink,
  Github,
  Twitter,
  Mail,
  Shield,
  Heart,
  Zap,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface FooterProps {
  className?: string;
  minimal?: boolean;
}

interface FooterLink {
  label: string;
  href: string;
  external?: boolean;
}

const footerLinks: Record<string, FooterLink[]> = {
  product: [
    { label: 'Features', href: '/help' },
    { label: 'API Documentation', href: '/help/api' },
    { label: 'Tutorials', href: '/help/tutorials' },
    { label: 'System Status', href: 'https://status.example.com', external: true },
  ],
  company: [
    { label: 'About', href: '/about' },
    { label: 'Blog', href: '/blog' },
    { label: 'Careers', href: '/careers' },
    { label: 'Contact', href: '/help/contact' },
  ],
  support: [
    { label: 'Help Center', href: '/help' },
    { label: 'Community', href: 'https://community.example.com', external: true },
    { label: 'Contact Support', href: '/help/contact' },
    { label: 'Report Issue', href: '/help/contact?type=bug' },
  ],
  legal: [
    { label: 'Privacy Policy', href: '/privacy' },
    { label: 'Terms of Service', href: '/terms' },
    { label: 'Security', href: '/security' },
    { label: 'Compliance', href: '/compliance' },
  ],
};

const socialLinks = [
  { icon: Github, href: 'https://github.com/example', label: 'GitHub', external: true },
  { icon: Twitter, href: 'https://twitter.com/example', label: 'Twitter', external: true },
  { icon: Mail, href: 'mailto:support@example.com', label: 'Email', external: false },
];

export function Footer({ className, minimal = false }: FooterProps) {
  if (minimal) {
    return (
      <footer className={cn('border-t bg-background', className)}>
        <div className="container mx-auto px-4 py-6">
          <div className="flex flex-col items-center justify-between gap-4 md:flex-row">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 rounded bg-primary flex items-center justify-center">
                <Zap className="h-3 w-3 text-primary-foreground" />
              </div>
              <span className="text-sm font-medium">Enterprise Auth Template</span>
            </div>
            
            <div className="text-sm text-muted-foreground text-center md:text-right">
              <p>&copy; 2024 Enterprise Auth. All rights reserved.</p>
            </div>
          </div>
        </div>
      </footer>
    );
  }

  return (
    <footer className={cn('border-t bg-background', className)}>
      <div className="container mx-auto px-4 py-12">
        <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-5">
          {/* Brand Section */}
          <div className="lg:col-span-1">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
                <Zap className="h-4 w-4 text-primary-foreground" />
              </div>
              <span className="text-lg font-bold">Enterprise Auth</span>
            </div>
            <p className="text-sm text-muted-foreground mb-4">
              Secure, scalable authentication and authorization platform for modern applications.
            </p>
            <div className="flex items-center gap-2 mb-4">
              <Shield className="h-4 w-4 text-green-500" />
              <Badge variant="secondary" className="text-xs">
                SOC 2 Compliant
              </Badge>
            </div>
            <div className="flex items-center gap-2">
              {socialLinks.map((social) => {
                const Icon = social.icon;
                return (
                  <Button key={social.label} variant="ghost" size="icon" asChild>
                    <Link
                      href={social.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      aria-label={social.label}
                    >
                      <Icon className="h-4 w-4" />
                    </Link>
                  </Button>
                );
              })}
            </div>
          </div>

          {/* Product Links */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Product</h3>
            <ul className="space-y-3">
              {footerLinks['product']?.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    target={link.external ? '_blank' : undefined}
                    rel={link.external ? 'noopener noreferrer' : undefined}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
                  >
                    {link.label}
                    {link.external && <ExternalLink className="h-3 w-3" />}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Company Links */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Company</h3>
            <ul className="space-y-3">
              {footerLinks['company']?.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    target={link.external ? '_blank' : undefined}
                    rel={link.external ? 'noopener noreferrer' : undefined}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
                  >
                    {link.label}
                    {link.external && <ExternalLink className="h-3 w-3" />}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Support Links */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Support</h3>
            <ul className="space-y-3">
              {footerLinks['support']?.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    target={link.external ? '_blank' : undefined}
                    rel={link.external ? 'noopener noreferrer' : undefined}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1"
                  >
                    {link.label}
                    {link.external && <ExternalLink className="h-3 w-3" />}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Legal Links */}
          <div>
            <h3 className="font-semibold text-sm mb-4">Legal</h3>
            <ul className="space-y-3">
              {footerLinks['legal']?.map((link) => (
                <li key={link.label}>
                  <Link
                    href={link.href}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <Separator className="my-8" />

        {/* Bottom Section */}
        <div className="flex flex-col items-center justify-between gap-4 md:flex-row">
          <div className="text-sm text-muted-foreground">
            <p>&copy; 2024 Enterprise Auth Template. All rights reserved.</p>
          </div>
          
          <div className="flex items-center gap-4 text-sm text-muted-foreground">
            <div className="flex items-center gap-1">
              Made with <Heart className="h-3 w-3 text-red-500" /> by developers
            </div>
            <Separator orientation="vertical" className="h-4" />
            <div className="flex items-center gap-1">
              <div className="w-2 h-2 rounded-full bg-green-500" />
              <span>All systems operational</span>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}