'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useRequireAuth } from '@/stores/auth.store';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
// import { Progress } from '@/components/ui/progress'; // Component not available
import { Badge } from '@/components/ui/badge';
import { Separator } from '@/components/ui/separator';
import { 
  User, 
  Building, 
  Target, 
  CheckCircle, 
  ArrowRight, 
  ArrowLeft,
  Star,
  Users,
  Briefcase
} from 'lucide-react';
import { toast } from 'sonner';

interface OnboardingData {
  // Step 1: Personal Info
  firstName: string;
  lastName: string;
  jobTitle: string;
  department: string;
  
  // Step 2: Company Info
  companyName: string;
  companySize: string;
  industry: string;
  
  // Step 3: Goals & Preferences
  primaryGoal: string;
  useCase: string;
  teamSize: string;
  experience: string;
}

const STEPS = [
  {
    id: 1,
    title: 'Personal Information',
    description: 'Tell us about yourself',
    icon: User,
  },
  {
    id: 2,
    title: 'Company Details',
    description: 'About your organization',
    icon: Building,
  },
  {
    id: 3,
    title: 'Goals & Preferences',
    description: 'How we can help you succeed',
    icon: Target,
  },
  {
    id: 4,
    title: 'Complete Setup',
    description: 'Finalize your account',
    icon: CheckCircle,
  },
];

const COMPANY_SIZES = [
  '1-10 employees',
  '11-50 employees',
  '51-200 employees',
  '201-1000 employees',
  '1000+ employees',
];

const INDUSTRIES = [
  'Technology',
  'Healthcare',
  'Finance',
  'Education',
  'Retail',
  'Manufacturing',
  'Consulting',
  'Other',
];

const PRIMARY_GOALS = [
  'Improve team collaboration',
  'Enhance security',
  'Streamline workflows',
  'Scale operations',
  'Reduce costs',
  'Compliance requirements',
];

const EXPERIENCE_LEVELS = [
  'Beginner',
  'Intermediate',
  'Advanced',
  'Expert',
];

export default function OnboardingPage(): React.ReactElement {
  const router = useRouter();
  const { user } = useRequireAuth();
  const [currentStep, setCurrentStep] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  
  const [formData, setFormData] = useState<OnboardingData>({
    firstName: user?.full_name?.split(' ')[0] || '',
    lastName: user?.full_name?.split(' ').slice(1).join(' ') || '',
    jobTitle: '',
    department: '',
    companyName: '',
    companySize: '',
    industry: '',
    primaryGoal: '',
    useCase: '',
    teamSize: '',
    experience: '',
  });

  const updateFormData = (field: keyof OnboardingData, value: string) => {
    setFormData((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const nextStep = () => {
    if (currentStep < STEPS.length) {
      setCurrentStep(currentStep + 1);
    }
  };

  const previousStep = () => {
    if (currentStep > 1) {
      setCurrentStep(currentStep - 1);
    }
  };

  const completeOnboarding = async () => {
    setIsLoading(true);
    try {
      // TODO: Implement onboarding completion API call
      await new Promise((resolve) => setTimeout(resolve, 2000));
      
      toast.success('Welcome aboard! Your account is now set up.');
      router.push('/dashboard');
    } catch {
      // Error handled via toast notification
      toast.error('Failed to complete setup. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const renderStepContent = () => {
    switch (currentStep) {
      case 1:
        return (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-2">Let&apos;s get to know you</h3>
              <p className="text-muted-foreground">
                We&apos;ll use this information to personalize your experience.
              </p>
            </div>
            
            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="firstName">First Name</Label>
                <Input
                  id="firstName"
                  value={formData.firstName}
                  onChange={(e) => updateFormData('firstName', e.target.value)}
                  placeholder="Enter your first name"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="lastName">Last Name</Label>
                <Input
                  id="lastName"
                  value={formData.lastName}
                  onChange={(e) => updateFormData('lastName', e.target.value)}
                  placeholder="Enter your last name"
                />
              </div>
            </div>

            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="jobTitle">Job Title</Label>
                <Input
                  id="jobTitle"
                  value={formData.jobTitle}
                  onChange={(e) => updateFormData('jobTitle', e.target.value)}
                  placeholder="e.g. Software Engineer"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="department">Department</Label>
                <Input
                  id="department"
                  value={formData.department}
                  onChange={(e) => updateFormData('department', e.target.value)}
                  placeholder="e.g. Engineering"
                />
              </div>
            </div>
          </div>
        );

      case 2:
        return (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-2">Tell us about your company</h3>
              <p className="text-muted-foreground">
                This helps us tailor features to your organization&apos;s needs.
              </p>
            </div>
            
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="companyName">Company Name</Label>
                <Input
                  id="companyName"
                  value={formData.companyName}
                  onChange={(e) => updateFormData('companyName', e.target.value)}
                  placeholder="Enter your company name"
                />
              </div>

              <div className="space-y-2">
                <Label>Company Size</Label>
                <div className="grid gap-2 md:grid-cols-2">
                  {COMPANY_SIZES.map((size) => (
                    <Button
                      key={size}
                      variant={formData.companySize === size ? 'default' : 'outline'}
                      className="justify-start"
                      onClick={() => updateFormData('companySize', size)}
                    >
                      <Users className="h-4 w-4 mr-2" />
                      {size}
                    </Button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <Label>Industry</Label>
                <div className="grid gap-2 md:grid-cols-2 lg:grid-cols-3">
                  {INDUSTRIES.map((industry) => (
                    <Button
                      key={industry}
                      variant={formData.industry === industry ? 'default' : 'outline'}
                      className="justify-start"
                      onClick={() => updateFormData('industry', industry)}
                    >
                      <Briefcase className="h-4 w-4 mr-2" />
                      {industry}
                    </Button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        );

      case 3:
        return (
          <div className="space-y-6">
            <div>
              <h3 className="text-lg font-semibold mb-2">What are your goals?</h3>
              <p className="text-muted-foreground">
                Help us understand how we can best serve your needs.
              </p>
            </div>
            
            <div className="space-y-4">
              <div className="space-y-2">
                <Label>Primary Goal</Label>
                <div className="grid gap-2 md:grid-cols-2">
                  {PRIMARY_GOALS.map((goal) => (
                    <Button
                      key={goal}
                      variant={formData.primaryGoal === goal ? 'default' : 'outline'}
                      className="justify-start"
                      onClick={() => updateFormData('primaryGoal', goal)}
                    >
                      <Target className="h-4 w-4 mr-2" />
                      {goal}
                    </Button>
                  ))}
                </div>
              </div>

              <div className="space-y-2">
                <Label htmlFor="useCase">Describe your use case (optional)</Label>
                <Textarea
                  id="useCase"
                  value={formData.useCase}
                  onChange={(e) => updateFormData('useCase', e.target.value)}
                  placeholder="Tell us more about how you plan to use our platform..."
                  className="resize-none"
                  rows={3}
                />
              </div>

              <div className="space-y-2">
                <Label>Your experience level with similar tools</Label>
                <div className="grid gap-2 md:grid-cols-2">
                  {EXPERIENCE_LEVELS.map((level) => (
                    <Button
                      key={level}
                      variant={formData.experience === level ? 'default' : 'outline'}
                      className="justify-start"
                      onClick={() => updateFormData('experience', level)}
                    >
                      <Star className="h-4 w-4 mr-2" />
                      {level}
                    </Button>
                  ))}
                </div>
              </div>
            </div>
          </div>
        );

      case 4:
        return (
          <div className="space-y-6">
            <div className="text-center">
              <CheckCircle className="h-16 w-16 text-green-500 mx-auto mb-4" />
              <h3 className="text-2xl font-semibold mb-2">You&apos;re all set!</h3>
              <p className="text-muted-foreground">
                Review your information and complete your account setup.
              </p>
            </div>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Setup Summary</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4 md:grid-cols-2">
                  <div>
                    <h4 className="font-medium mb-2">Personal Information</h4>
                    <div className="space-y-1 text-sm text-muted-foreground">
                      <p>Name: {formData.firstName} {formData.lastName}</p>
                      <p>Title: {formData.jobTitle || 'Not specified'}</p>
                      <p>Department: {formData.department || 'Not specified'}</p>
                    </div>
                  </div>
                  <div>
                    <h4 className="font-medium mb-2">Company Details</h4>
                    <div className="space-y-1 text-sm text-muted-foreground">
                      <p>Company: {formData.companyName || 'Not specified'}</p>
                      <p>Size: {formData.companySize || 'Not specified'}</p>
                      <p>Industry: {formData.industry || 'Not specified'}</p>
                    </div>
                  </div>
                </div>
                <Separator />
                <div>
                  <h4 className="font-medium mb-2">Goals & Preferences</h4>
                  <div className="space-y-1 text-sm text-muted-foreground">
                    <p>Primary Goal: {formData.primaryGoal || 'Not specified'}</p>
                    <p>Experience: {formData.experience || 'Not specified'}</p>
                    {formData.useCase && <p>Use Case: {formData.useCase}</p>}
                  </div>
                </div>
              </CardContent>
            </Card>

            <div className="text-center">
              <Button 
                onClick={completeOnboarding} 
                disabled={isLoading} 
                size="lg"
                className="min-w-32"
              >
                {isLoading ? 'Setting up...' : 'Complete Setup'}
              </Button>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  if (!user) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-muted/50">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-3xl font-bold text-foreground mb-2">Welcome to the Platform</h1>
            <p className="text-muted-foreground">
              Let&apos;s set up your account to get the most out of our platform.
            </p>
          </div>

          {/* Progress Bar */}
          <div className="mb-8">
            <div className="flex items-center justify-between mb-4">
              {STEPS.map((step, index) => {
                const Icon = step.icon;
                const isActive = currentStep === step.id;
                const isCompleted = currentStep > step.id;
                
                return (
                  <div key={step.id} className="flex items-center">
                    <div className="flex flex-col items-center">
                      <div
                        className={`w-10 h-10 rounded-full border-2 flex items-center justify-center mb-2 ${
                          isCompleted
                            ? 'bg-green-500 border-green-500 text-white'
                            : isActive
                            ? 'bg-primary border-primary text-primary-foreground'
                            : 'border-muted-foreground text-muted-foreground'
                        }`}
                      >
                        {isCompleted ? (
                          <CheckCircle className="h-5 w-5" />
                        ) : (
                          <Icon className="h-5 w-5" />
                        )}
                      </div>
                      <div className="text-center">
                        <div className={`text-sm font-medium ${isActive ? 'text-primary' : 'text-muted-foreground'}`}>
                          {step.title}
                        </div>
                        <div className="text-xs text-muted-foreground hidden sm:block">
                          {step.description}
                        </div>
                      </div>
                    </div>
                    {index < STEPS.length - 1 && (
                      <div className={`flex-1 h-0.5 mx-4 ${isCompleted ? 'bg-green-500' : 'bg-muted-foreground/30'}`} />
                    )}
                  </div>
                );
              })}
            </div>
            <div className="w-full bg-gray-200 rounded-full h-2">
              <div 
                className="bg-blue-600 h-2 rounded-full transition-all duration-300" 
                style={{ width: `${(currentStep / STEPS.length) * 100}%` }}
              />
            </div>
          </div>

          {/* Step Content */}
          <Card className="mb-8">
            <CardHeader>
              <div className="flex items-center gap-2">
                <Badge variant="outline">Step {currentStep} of {STEPS.length}</Badge>
                <CardTitle>{STEPS[currentStep - 1]?.title}</CardTitle>
              </div>
              <CardDescription>{STEPS[currentStep - 1]?.description}</CardDescription>
            </CardHeader>
            <CardContent>
              {renderStepContent()}
            </CardContent>
          </Card>

          {/* Navigation */}
          <div className="flex justify-between">
            <Button
              onClick={previousStep}
              disabled={currentStep === 1}
              variant="outline"
              className="min-w-32"
            >
              <ArrowLeft className="h-4 w-4 mr-2" />
              Previous
            </Button>
            
            {currentStep < STEPS.length ? (
              <Button
                onClick={nextStep}
                className="min-w-32"
              >
                Next
                <ArrowRight className="h-4 w-4 ml-2" />
              </Button>
            ) : (
              <div /> // Placeholder for alignment
            )}
          </div>
        </div>
      </div>
    </div>
  );
}