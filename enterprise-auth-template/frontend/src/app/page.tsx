'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/stores/auth.store';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Shield,
  Users,
  Zap,
  Code2,
  Cloud,
  Key,
  ArrowRight,
  CheckCircle,
  Sparkles,
  Lock,
  Layers,
  Globe
} from 'lucide-react';

export default function HomePage(): React.ReactElement {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && isAuthenticated) {
      router.push('/dashboard');
    }
  }, [isAuthenticated, isLoading, router]);

  if (isLoading) {
    return (
      <div className='flex items-center justify-center min-h-screen bg-gradient-to-br from-background to-muted'>
        <div className='animate-spin rounded-full h-12 w-12 border-4 border-primary border-t-transparent'></div>
      </div>
    );
  }

  return (
    <div className='flex flex-col min-h-screen bg-gradient-to-b from-background via-background to-muted/20'>
      {/* Header */}
      <header className='backdrop-blur-md bg-background/80 sticky top-0 z-50 border-b border-border/40'>
        <div className='container mx-auto px-6 py-5'>
          <nav className='flex justify-between items-center'>
            <div className='flex items-center space-x-2'>
              <div className='w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-primary/80 flex items-center justify-center'>
                <Shield className='w-6 h-6 text-primary-foreground' />
              </div>
              <div>
                <h1 className='text-xl font-semibold tracking-tight'>AuthCore</h1>
                <p className='text-xs text-muted-foreground'>Enterprise Authentication</p>
              </div>
            </div>

            <div className='flex items-center gap-6'>
              <nav className='hidden md:flex items-center gap-8'>
                <button className='text-sm font-medium text-muted-foreground hover:text-foreground transition-colors'>
                  Features
                </button>
                <button className='text-sm font-medium text-muted-foreground hover:text-foreground transition-colors'>
                  Documentation
                </button>
                <button className='text-sm font-medium text-muted-foreground hover:text-foreground transition-colors'>
                  Pricing
                </button>
              </nav>

              <div className='flex items-center gap-3'>
                <Button
                  variant='ghost'
                  size='sm'
                  onClick={() => router.push('/auth/login')}
                  className='font-medium'
                >
                  Sign In
                </Button>
                <Button
                  size='sm'
                  onClick={() => router.push('/auth/register')}
                  className='font-medium bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary shadow-lg shadow-primary/20'
                >
                  Get Started
                  <ArrowRight className='w-4 h-4 ml-1' />
                </Button>
              </div>
            </div>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className='relative flex items-center justify-center py-32 px-6 overflow-hidden'>
        {/* Background decoration */}
        <div className='absolute inset-0 -z-10'>
          <div className='absolute top-20 left-20 w-72 h-72 bg-primary/10 rounded-full blur-3xl'></div>
          <div className='absolute bottom-20 right-20 w-96 h-96 bg-purple-500/10 rounded-full blur-3xl'></div>
        </div>

        <div className='container mx-auto text-center max-w-5xl'>
          <div className='inline-flex items-center gap-2 px-4 py-2 rounded-full bg-muted/80 backdrop-blur-sm mb-8'>
            <Sparkles className='w-4 h-4 text-primary' />
            <span className='text-sm font-medium'>Production-ready authentication system</span>
          </div>

          <h1 className='text-5xl md:text-7xl font-bold tracking-tight mb-6 bg-gradient-to-br from-foreground to-foreground/70 bg-clip-text text-transparent'>
            Secure Your Application
            <span className='block text-3xl md:text-5xl mt-2 text-primary'>
              With Enterprise Auth
            </span>
          </h1>

          <p className='text-lg md:text-xl text-muted-foreground mb-12 max-w-3xl mx-auto leading-relaxed'>
            A complete authentication solution built with modern best practices.
            Features JWT tokens, role-based access control, OAuth integration, and comprehensive security measures.
          </p>

          <div className='flex flex-col sm:flex-row gap-4 justify-center items-center'>
            <Button
              size='lg'
              onClick={() => router.push('/auth/register')}
              className='min-w-[200px] h-12 text-base font-medium bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary shadow-xl shadow-primary/20'
            >
              Start Free Trial
              <ArrowRight className='w-5 h-5 ml-2' />
            </Button>
            <Button
              variant='outline'
              size='lg'
              onClick={() => router.push('/test-auth')}
              className='min-w-[200px] h-12 text-base font-medium border-2'
            >
              View Demo
            </Button>
          </div>

          <div className='flex items-center justify-center gap-8 mt-12 text-sm text-muted-foreground'>
            <div className='flex items-center gap-2'>
              <CheckCircle className='w-4 h-4 text-green-500' />
              <span>No credit card required</span>
            </div>
            <div className='flex items-center gap-2'>
              <CheckCircle className='w-4 h-4 text-green-500' />
              <span>14-day free trial</span>
            </div>
            <div className='flex items-center gap-2'>
              <CheckCircle className='w-4 h-4 text-green-500' />
              <span>Cancel anytime</span>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className='py-24 px-6'>
        <div className='container mx-auto max-w-7xl'>
          <div className='text-center mb-16'>
            <div className='inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 mb-6'>
              <Layers className='w-4 h-4 text-primary' />
              <span className='text-sm font-medium text-primary'>Core Features</span>
            </div>
            <h2 className='text-4xl md:text-5xl font-bold tracking-tight mb-4'>
              Everything You Need
            </h2>
            <p className='text-lg text-muted-foreground max-w-2xl mx-auto'>
              Built with security and scalability in mind, our authentication system provides all the tools you need for enterprise applications.
            </p>
          </div>

          <div className='grid md:grid-cols-2 lg:grid-cols-3 gap-6'>
            <Card className='group hover:shadow-xl transition-all duration-300 border-muted hover:border-primary/20 bg-gradient-to-br from-background to-muted/5'>
              <CardHeader>
                <div className='w-12 h-12 rounded-lg bg-gradient-to-br from-blue-500/20 to-blue-600/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform'>
                  <Shield className='w-6 h-6 text-blue-600' />
                </div>
                <CardTitle className='text-xl'>Enterprise Security</CardTitle>
                <CardDescription>
                  Bank-grade security with industry standards
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className='space-y-2 text-sm text-muted-foreground'>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>JWT with refresh token rotation</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Bcrypt password hashing</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Account lockout protection</span>
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className='group hover:shadow-xl transition-all duration-300 border-muted hover:border-primary/20 bg-gradient-to-br from-background to-muted/5'>
              <CardHeader>
                <div className='w-12 h-12 rounded-lg bg-gradient-to-br from-purple-500/20 to-purple-600/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform'>
                  <Users className='w-6 h-6 text-purple-600' />
                </div>
                <CardTitle className='text-xl'>Role-Based Access</CardTitle>
                <CardDescription>
                  Flexible permission management system
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className='space-y-2 text-sm text-muted-foreground'>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Granular permission control</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Role inheritance support</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Dynamic permission checking</span>
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className='group hover:shadow-xl transition-all duration-300 border-muted hover:border-primary/20 bg-gradient-to-br from-background to-muted/5'>
              <CardHeader>
                <div className='w-12 h-12 rounded-lg bg-gradient-to-br from-green-500/20 to-green-600/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform'>
                  <Zap className='w-6 h-6 text-green-600' />
                </div>
                <CardTitle className='text-xl'>High Performance</CardTitle>
                <CardDescription>
                  Built for speed and scalability
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className='space-y-2 text-sm text-muted-foreground'>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Async/await architecture</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Redis session caching</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Optimized database queries</span>
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className='group hover:shadow-xl transition-all duration-300 border-muted hover:border-primary/20 bg-gradient-to-br from-background to-muted/5'>
              <CardHeader>
                <div className='w-12 h-12 rounded-lg bg-gradient-to-br from-orange-500/20 to-orange-600/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform'>
                  <Code2 className='w-6 h-6 text-orange-600' />
                </div>
                <CardTitle className='text-xl'>Developer Friendly</CardTitle>
                <CardDescription>
                  Clean code with excellent DX
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className='space-y-2 text-sm text-muted-foreground'>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>TypeScript with strict mode</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Comprehensive documentation</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Auto-generated API docs</span>
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className='group hover:shadow-xl transition-all duration-300 border-muted hover:border-primary/20 bg-gradient-to-br from-background to-muted/5'>
              <CardHeader>
                <div className='w-12 h-12 rounded-lg bg-gradient-to-br from-cyan-500/20 to-cyan-600/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform'>
                  <Cloud className='w-6 h-6 text-cyan-600' />
                </div>
                <CardTitle className='text-xl'>Cloud Native</CardTitle>
                <CardDescription>
                  Ready for modern deployments
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className='space-y-2 text-sm text-muted-foreground'>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Docker containerization</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Kubernetes ready</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Environment-based config</span>
                  </li>
                </ul>
              </CardContent>
            </Card>

            <Card className='group hover:shadow-xl transition-all duration-300 border-muted hover:border-primary/20 bg-gradient-to-br from-background to-muted/5'>
              <CardHeader>
                <div className='w-12 h-12 rounded-lg bg-gradient-to-br from-pink-500/20 to-pink-600/20 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform'>
                  <Key className='w-6 h-6 text-pink-600' />
                </div>
                <CardTitle className='text-xl'>OAuth & SSO</CardTitle>
                <CardDescription>
                  Multiple authentication methods
                </CardDescription>
              </CardHeader>
              <CardContent>
                <ul className='space-y-2 text-sm text-muted-foreground'>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Google & GitHub OAuth</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>WebAuthn/Passkey support</span>
                  </li>
                  <li className='flex items-start gap-2'>
                    <CheckCircle className='w-4 h-4 text-green-500 mt-0.5 flex-shrink-0' />
                    <span>Magic link authentication</span>
                  </li>
                </ul>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Tech Stack Section */}
      <section className='py-24 px-6 bg-muted/30'>
        <div className='container mx-auto max-w-7xl'>
          <div className='text-center mb-16'>
            <div className='inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 mb-6'>
              <Globe className='w-4 h-4 text-primary' />
              <span className='text-sm font-medium text-primary'>Technology Stack</span>
            </div>
            <h2 className='text-4xl md:text-5xl font-bold tracking-tight mb-4'>
              Built with Modern Tools
            </h2>
            <p className='text-lg text-muted-foreground max-w-2xl mx-auto'>
              Leveraging the best technologies to deliver a robust and scalable authentication solution.
            </p>
          </div>

          <div className='grid grid-cols-2 md:grid-cols-4 gap-8 max-w-4xl mx-auto'>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-500/10 to-blue-600/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-blue-600'>Next</span>
              </div>
              <span className='text-sm font-medium'>Next.js 14</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-green-500/10 to-green-600/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-green-600'>Fast</span>
              </div>
              <span className='text-sm font-medium'>FastAPI</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-400/10 to-blue-500/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-blue-500'>TS</span>
              </div>
              <span className='text-sm font-medium'>TypeScript</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-indigo-500/10 to-indigo-600/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-indigo-600'>PG</span>
              </div>
              <span className='text-sm font-medium'>PostgreSQL</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-red-500/10 to-red-600/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-red-600'>R</span>
              </div>
              <span className='text-sm font-medium'>Redis</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-cyan-500/10 to-cyan-600/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-cyan-600'>Tw</span>
              </div>
              <span className='text-sm font-medium'>Tailwind CSS</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-600/10 to-blue-700/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-blue-700'>D</span>
              </div>
              <span className='text-sm font-medium'>Docker</span>
            </div>
            <div className='flex flex-col items-center gap-3 group'>
              <div className='w-16 h-16 rounded-2xl bg-gradient-to-br from-purple-500/10 to-purple-600/10 flex items-center justify-center group-hover:scale-110 transition-transform'>
                <span className='text-2xl font-bold text-purple-600'>Py</span>
              </div>
              <span className='text-sm font-medium'>Python 3.11</span>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className='py-24 px-6'>
        <div className='container mx-auto max-w-4xl'>
          <div className='relative rounded-3xl bg-gradient-to-br from-primary/10 via-primary/5 to-background border border-primary/20 p-12 md:p-16 text-center overflow-hidden'>
            <div className='absolute inset-0 -z-10'>
              <div className='absolute top-0 right-0 w-64 h-64 bg-primary/10 rounded-full blur-3xl'></div>
              <div className='absolute bottom-0 left-0 w-64 h-64 bg-purple-500/10 rounded-full blur-3xl'></div>
            </div>

            <h2 className='text-3xl md:text-4xl font-bold tracking-tight mb-4'>
              Ready to Secure Your Application?
            </h2>
            <p className='text-lg text-muted-foreground mb-8 max-w-2xl mx-auto'>
              Join thousands of developers who trust our authentication system for their applications.
            </p>

            <div className='flex flex-col sm:flex-row gap-4 justify-center'>
              <Button
                size='lg'
                onClick={() => router.push('/auth/register')}
                className='min-w-[200px] h-12 text-base font-medium bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary shadow-xl shadow-primary/20'
              >
                Get Started Free
                <ArrowRight className='w-5 h-5 ml-2' />
              </Button>
              <Button
                variant='outline'
                size='lg'
                onClick={() => router.push('/auth/login')}
                className='min-w-[200px] h-12 text-base font-medium bg-background/50 backdrop-blur-sm'
              >
                Contact Sales
              </Button>
            </div>

            <p className='text-sm text-muted-foreground mt-8'>
              <Lock className='w-4 h-4 inline mr-1' />
              SSL encrypted • SOC2 compliant • GDPR ready
            </p>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className='border-t bg-muted/30'>
        <div className='container mx-auto px-6 py-12'>
          <div className='grid grid-cols-2 md:grid-cols-4 gap-8 mb-8'>
            <div>
              <h3 className='font-semibold mb-4'>Product</h3>
              <ul className='space-y-2 text-sm text-muted-foreground'>
                <li><button className='hover:text-foreground transition-colors'>Features</button></li>
                <li><button className='hover:text-foreground transition-colors'>Pricing</button></li>
                <li><button className='hover:text-foreground transition-colors'>Security</button></li>
                <li><button className='hover:text-foreground transition-colors'>Roadmap</button></li>
              </ul>
            </div>
            <div>
              <h3 className='font-semibold mb-4'>Developers</h3>
              <ul className='space-y-2 text-sm text-muted-foreground'>
                <li><button className='hover:text-foreground transition-colors'>Documentation</button></li>
                <li><button className='hover:text-foreground transition-colors'>API Reference</button></li>
                <li><button className='hover:text-foreground transition-colors'>Guides</button></li>
                <li><button className='hover:text-foreground transition-colors'>SDKs</button></li>
              </ul>
            </div>
            <div>
              <h3 className='font-semibold mb-4'>Company</h3>
              <ul className='space-y-2 text-sm text-muted-foreground'>
                <li><button className='hover:text-foreground transition-colors'>About</button></li>
                <li><button className='hover:text-foreground transition-colors'>Blog</button></li>
                <li><button className='hover:text-foreground transition-colors'>Careers</button></li>
                <li><button className='hover:text-foreground transition-colors'>Contact</button></li>
              </ul>
            </div>
            <div>
              <h3 className='font-semibold mb-4'>Legal</h3>
              <ul className='space-y-2 text-sm text-muted-foreground'>
                <li><button className='hover:text-foreground transition-colors'>Privacy</button></li>
                <li><button className='hover:text-foreground transition-colors'>Terms</button></li>
                <li><button className='hover:text-foreground transition-colors'>Security</button></li>
                <li><button className='hover:text-foreground transition-colors'>Compliance</button></li>
              </ul>
            </div>
          </div>

          <div className='pt-8 border-t text-center'>
            <p className='text-sm text-muted-foreground'>
              © 2025 AuthCore. All rights reserved. Built with Next.js and FastAPI.
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}
