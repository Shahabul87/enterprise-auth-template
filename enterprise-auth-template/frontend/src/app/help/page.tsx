'use client';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
// import { Progress } from '@/components/ui/progress'; // Component not available
import Link from 'next/link';
import {
  BookOpen,
  PlayCircle,
  MessageCircle,
  Star,
  Clock,
  Users,
  Shield,
  Zap,
  CheckCircle,
  ArrowRight,
  Download,
  ExternalLink,
} from 'lucide-react';

const quickStartSteps = [
  {
    id: 1,
    title: 'Create Your Account',
    description: 'Sign up and verify your email address',
    completed: true,
    duration: '2 min',
  },
  {
    id: 2,
    title: 'Complete Your Profile',
    description: 'Add your personal and company information',
    completed: true,
    duration: '5 min',
  },
  {
    id: 3,
    title: 'Set Up Security',
    description: 'Enable two-factor authentication and security settings',
    completed: false,
    duration: '3 min',
    actionUrl: '/settings/security',
  },
  {
    id: 4,
    title: 'Invite Team Members',
    description: 'Add colleagues to collaborate on your projects',
    completed: false,
    duration: '5 min',
    actionUrl: '/admin/users',
  },
  {
    id: 5,
    title: 'Explore Features',
    description: 'Take a tour of the main features and capabilities',
    completed: false,
    duration: '10 min',
    actionUrl: '/help/tutorials',
  },
];

const popularArticles = [
  {
    title: 'Getting Started with Authentication',
    description: 'Learn how to set up and manage user authentication',
    category: 'Security',
    readTime: '5 min read',
    rating: 4.8,
    views: '12.5k',
    href: '/help/user-guide/authentication',
  },
  {
    title: 'Role-Based Access Control (RBAC)',
    description: 'Understanding permissions and roles in the system',
    category: 'Administration',
    readTime: '8 min read',
    rating: 4.9,
    views: '8.2k',
    href: '/help/user-guide/rbac',
  },
  {
    title: 'API Integration Guide',
    description: 'How to integrate with our REST API endpoints',
    category: 'Development',
    readTime: '12 min read',
    rating: 4.7,
    views: '15.3k',
    href: '/help/api/integration',
  },
  {
    title: 'Troubleshooting Common Issues',
    description: 'Solutions to frequently encountered problems',
    category: 'Support',
    readTime: '6 min read',
    rating: 4.6,
    views: '9.8k',
    href: '/help/faq/troubleshooting',
  },
];

const featureHighlights = [
  {
    icon: Shield,
    title: 'Enterprise Security',
    description: 'Multi-factor authentication, SSO, and advanced security features',
    features: ['2FA/MFA', 'WebAuthn', 'OAuth2', 'Audit Logs'],
  },
  {
    icon: Users,
    title: 'Team Collaboration',
    description: 'Invite team members and manage permissions with role-based access',
    features: ['User Management', 'Role Assignment', 'Team Invites', 'Activity Tracking'],
  },
  {
    icon: Zap,
    title: 'Developer Tools',
    description: 'Comprehensive API access and developer-friendly integrations',
    features: ['REST API', 'Webhooks', 'SDK Libraries', 'Documentation'],
  },
];

const resources = [
  {
    type: 'Video',
    title: 'Platform Overview (10 min)',
    description: 'Complete walkthrough of all features',
    icon: PlayCircle,
    href: '/help/tutorials/overview',
  },
  {
    type: 'Guide',
    title: 'Admin Quick Start',
    description: 'Essential setup for administrators',
    icon: BookOpen,
    href: '/help/user-guide/admin',
  },
  {
    type: 'PDF',
    title: 'Security Best Practices',
    description: 'Downloadable security guidelines',
    icon: Download,
    href: '/resources/security-guide.pdf',
  },
  {
    type: 'External',
    title: 'Community Forum',
    description: 'Connect with other users',
    icon: ExternalLink,
    href: 'https://community.example.com',
  },
];

export default function HelpPage(): React.ReactElement {
  const completedSteps = quickStartSteps.filter(step => step.completed).length;
  const progressPercentage = (completedSteps / quickStartSteps.length) * 100;

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div>
        <h2 className="text-3xl font-bold text-foreground mb-2">Welcome to the Help Center</h2>
        <p className="text-muted-foreground text-lg">
          Find guides, tutorials, and answers to help you get the most out of our platform.
        </p>
      </div>

      {/* Quick Start Progress */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="flex items-center gap-2">
                <CheckCircle className="h-5 w-5 text-green-500" />
                Quick Start Guide
              </CardTitle>
              <CardDescription>
                Complete these steps to get fully set up
              </CardDescription>
            </div>
            <Badge variant="secondary">
              {completedSteps}/{quickStartSteps.length} Complete
            </Badge>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2.5 mt-4">
            <div 
              className="bg-blue-600 h-2.5 rounded-full transition-all duration-300" 
              style={{ width: `${progressPercentage}%` }}
            />
          </div>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4">
            {quickStartSteps.map((step) => (
              <div
                key={step.id}
                className={`flex items-center gap-4 p-4 border rounded-lg ${
                  step.completed ? 'bg-green-50 border-green-200' : 'bg-muted/50'
                }`}
              >
                <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
                  step.completed ? 'bg-green-500 text-white' : 'bg-muted text-muted-foreground'
                }`}>
                  {step.completed ? (
                    <CheckCircle className="h-4 w-4" />
                  ) : (
                    <span className="text-sm font-medium">{step.id}</span>
                  )}
                </div>
                
                <div className="flex-1">
                  <h3 className="font-medium text-sm">{step.title}</h3>
                  <p className="text-xs text-muted-foreground">{step.description}</p>
                </div>
                
                <div className="flex items-center gap-2">
                  <div className="flex items-center gap-1 text-xs text-muted-foreground">
                    <Clock className="h-3 w-3" />
                    {step.duration}
                  </div>
                  {!step.completed && step.actionUrl && (
                    <Button asChild size="sm" variant="outline">
                      <Link href={step.actionUrl}>
                        Start
                        <ArrowRight className="h-3 w-3 ml-1" />
                      </Link>
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Feature Highlights */}
      <div>
        <h3 className="text-2xl font-bold text-foreground mb-6">Platform Features</h3>
        <div className="grid gap-6 md:grid-cols-3">
          {featureHighlights.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <Card key={index}>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-lg">
                    <Icon className="h-5 w-5 text-primary" />
                    {feature.title}
                  </CardTitle>
                  <CardDescription>{feature.description}</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {feature.features.map((item, itemIndex) => (
                      <div key={itemIndex} className="flex items-center gap-2">
                        <CheckCircle className="h-4 w-4 text-green-500" />
                        <span className="text-sm">{item}</span>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>

      {/* Popular Articles */}
      <div>
        <div className="flex items-center justify-between mb-6">
          <h3 className="text-2xl font-bold text-foreground">Popular Articles</h3>
          <Button asChild variant="outline">
            <Link href="/help/user-guide">
              View All Articles
              <ArrowRight className="h-4 w-4 ml-2" />
            </Link>
          </Button>
        </div>
        
        <div className="grid gap-4 md:grid-cols-2">
          {popularArticles.map((article, index) => (
            <Card key={index} className="hover:shadow-md transition-shadow">
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <Badge variant="secondary" className="text-xs">
                    {article.category}
                  </Badge>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Star className="h-3 w-3 fill-yellow-400 text-yellow-400" />
                      {article.rating}
                    </div>
                    <span>•</span>
                    <div className="flex items-center gap-1">
                      <Users className="h-3 w-3" />
                      {article.views}
                    </div>
                  </div>
                </div>
                <CardTitle className="text-lg">
                  <Link href={article.href} className="hover:text-primary transition-colors">
                    {article.title}
                  </Link>
                </CardTitle>
                <CardDescription>{article.description}</CardDescription>
              </CardHeader>
              <CardContent className="pt-0">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-1 text-xs text-muted-foreground">
                    <Clock className="h-3 w-3" />
                    {article.readTime}
                  </div>
                  <Button asChild variant="link" size="sm" className="p-0 h-auto">
                    <Link href={article.href}>
                      Read Article
                      <ArrowRight className="h-3 w-3 ml-1" />
                    </Link>
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Resources */}
      <div>
        <h3 className="text-2xl font-bold text-foreground mb-6">Additional Resources</h3>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {resources.map((resource, index) => {
            const Icon = resource.icon;
            return (
              <Card key={index} className="hover:shadow-md transition-shadow">
                <CardContent className="p-6 text-center">
                  <div className="mb-4">
                    <Icon className="h-8 w-8 text-primary mx-auto" />
                  </div>
                  <Badge variant="outline" className="mb-2">
                    {resource.type}
                  </Badge>
                  <h4 className="font-medium text-sm mb-2">{resource.title}</h4>
                  <p className="text-xs text-muted-foreground mb-4">{resource.description}</p>
                  <Button asChild size="sm" variant="outline" className="w-full">
                    <Link 
                      href={resource.href}
                      target={resource.type === 'External' || resource.type === 'PDF' ? '_blank' : undefined}
                      rel={resource.type === 'External' || resource.type === 'PDF' ? 'noopener noreferrer' : undefined}
                    >
                      {resource.type === 'PDF' ? 'Download' : 'View'}
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>

      {/* Contact Support */}
      <Card>
        <CardContent className="p-8 text-center">
          <MessageCircle className="h-12 w-12 text-primary mx-auto mb-4" />
          <h3 className="text-xl font-semibold mb-2">Still Need Help?</h3>
          <p className="text-muted-foreground mb-6">
            Our support team is here to help you with any questions or issues you might have.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button asChild>
              <Link href="/help/contact">Contact Support</Link>
            </Button>
            <Button asChild variant="outline">
              <Link href="/help/faq">Browse FAQ</Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}