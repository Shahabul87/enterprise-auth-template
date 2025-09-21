'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Progress } from '@/components/ui/progress';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import {
  User,
  Briefcase,
  MapPin,
  Globe,
  Award,
  CheckCircle2,
  ChevronRight,
  ChevronLeft,
  X
} from 'lucide-react';
import { toast } from 'sonner';
import { useAuthStore } from '@/stores/auth.store';

interface ProfileStep {
  id: string;
  title: string;
  description: string;
  icon: React.ElementType;
  fields: ProfileField[];
  optional?: boolean;
}

interface ProfileField {
  name: string;
  label: string;
  type: 'text' | 'email' | 'select' | 'textarea' | 'date';
  placeholder?: string;
  required?: boolean;
  options?: { value: string; label: string }[];
  validation?: (value: string) => boolean;
}

const profileSteps: ProfileStep[] = [
  {
    id: 'basic',
    title: 'Basic Information',
    description: 'Let us know a bit about you',
    icon: User,
    fields: [
      {
        name: 'full_name',
        label: 'Full Name',
        type: 'text',
        placeholder: 'John Doe',
        required: true,
      },
      {
        name: 'phone',
        label: 'Phone Number',
        type: 'text',
        placeholder: '+1 (555) 000-0000',
      },
      {
        name: 'birth_date',
        label: 'Date of Birth',
        type: 'date',
      },
    ],
  },
  {
    id: 'professional',
    title: 'Professional Details',
    description: 'Tell us about your work',
    icon: Briefcase,
    fields: [
      {
        name: 'job_title',
        label: 'Job Title',
        type: 'text',
        placeholder: 'Software Engineer',
      },
      {
        name: 'company',
        label: 'Company',
        type: 'text',
        placeholder: 'Acme Corp',
      },
      {
        name: 'industry',
        label: 'Industry',
        type: 'select',
        options: [
          { value: 'technology', label: 'Technology' },
          { value: 'finance', label: 'Finance' },
          { value: 'healthcare', label: 'Healthcare' },
          { value: 'education', label: 'Education' },
          { value: 'retail', label: 'Retail' },
          { value: 'other', label: 'Other' },
        ],
      },
    ],
  },
  {
    id: 'location',
    title: 'Location',
    description: 'Where are you based?',
    icon: MapPin,
    fields: [
      {
        name: 'city',
        label: 'City',
        type: 'text',
        placeholder: 'San Francisco',
      },
      {
        name: 'state',
        label: 'State/Province',
        type: 'text',
        placeholder: 'California',
      },
      {
        name: 'country',
        label: 'Country',
        type: 'select',
        options: [
          { value: 'us', label: 'United States' },
          { value: 'ca', label: 'Canada' },
          { value: 'uk', label: 'United Kingdom' },
          { value: 'au', label: 'Australia' },
          { value: 'de', label: 'Germany' },
          { value: 'fr', label: 'France' },
          { value: 'jp', label: 'Japan' },
          { value: 'other', label: 'Other' },
        ],
      },
    ],
  },
  {
    id: 'preferences',
    title: 'Preferences',
    description: 'Customize your experience',
    icon: Globe,
    optional: true,
    fields: [
      {
        name: 'language',
        label: 'Preferred Language',
        type: 'select',
        options: [
          { value: 'en', label: 'English' },
          { value: 'es', label: 'Spanish' },
          { value: 'fr', label: 'French' },
          { value: 'de', label: 'German' },
          { value: 'ja', label: 'Japanese' },
          { value: 'zh', label: 'Chinese' },
        ],
      },
      {
        name: 'timezone',
        label: 'Timezone',
        type: 'select',
        options: [
          { value: 'UTC-8', label: 'Pacific Time (PT)' },
          { value: 'UTC-5', label: 'Eastern Time (ET)' },
          { value: 'UTC', label: 'UTC' },
          { value: 'UTC+1', label: 'Central European Time (CET)' },
          { value: 'UTC+9', label: 'Japan Standard Time (JST)' },
        ],
      },
      {
        name: 'bio',
        label: 'Bio',
        type: 'textarea',
        placeholder: 'Tell us a bit about yourself...',
      },
    ],
  },
];

interface ProgressiveProfilingProps {
  onComplete?: () => void;
  onSkip?: () => void;
  isModal?: boolean;
}

export function ProgressiveProfiling({
  onComplete,
  onSkip,
  isModal = false
}: ProgressiveProfilingProps): React.ReactElement {
  const { user, updateUser } = useAuthStore();
  const [currentStep, setCurrentStep] = useState(0);
  const [formData, setFormData] = useState<Record<string, string>>({});
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const totalSteps = profileSteps.length;
  const progress = ((currentStep + 1) / totalSteps) * 100;
  const currentStepData = profileSteps[currentStep];
  const isLastStep = currentStep === totalSteps - 1;

  useEffect(() => {
    // Prefill with existing user data
    if (user) {
      setFormData({
        full_name: user.full_name || '',
        ...user.user_metadata,
      });
    }
  }, [user]);

  const handleFieldChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    // Clear error for this field
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  const validateStep = (): boolean => {
    const stepErrors: Record<string, string> = {};

    currentStepData.fields.forEach(field => {
      const value = formData[field.name];

      if (field.required && !value) {
        stepErrors[field.name] = `${field.label} is required`;
      }

      if (field.validation && value && !field.validation(value)) {
        stepErrors[field.name] = `Invalid ${field.label.toLowerCase()}`;
      }
    });

    setErrors(stepErrors);
    return Object.keys(stepErrors).length === 0;
  };

  const handleNext = () => {
    if (validateStep()) {
      if (isLastStep) {
        handleSubmit();
      } else {
        setCurrentStep(prev => prev + 1);
      }
    }
  };

  const handlePrevious = () => {
    setCurrentStep(prev => prev - 1);
  };

  const handleSkipStep = () => {
    if (currentStepData.optional || isLastStep) {
      if (isLastStep) {
        handleSubmit(true);
      } else {
        setCurrentStep(prev => prev + 1);
      }
    }
  };

  const handleSubmit = async (isSkipping = false) => {
    if (!isSkipping && !validateStep()) return;

    setIsSubmitting(true);
    try {
      // Update user profile with collected data
      await updateUser({
        full_name: formData.full_name,
        user_metadata: {
          ...formData,
          profile_completed: true,
          profile_completion_date: new Date().toISOString(),
        },
      });

      toast.success('Profile updated successfully!');
      onComplete?.();
    } catch (_error) {
      toast.error('Failed to update profile');
    } finally {
      setIsSubmitting(false);
    }
  };

  const renderField = (field: ProfileField) => {
    const error = errors[field.name];
    const value = formData[field.name] || '';

    switch (field.type) {
      case 'select':
        return (
          <div key={field.name} className="space-y-2">
            <Label htmlFor={field.name}>{field.label}</Label>
            <Select value={value} onValueChange={(val) => handleFieldChange(field.name, val)}>
              <SelectTrigger id={field.name} className={error ? 'border-red-500' : ''}>
                <SelectValue placeholder={`Select ${field.label.toLowerCase()}`} />
              </SelectTrigger>
              <SelectContent>
                {field.options?.map(option => (
                  <SelectItem key={option.value} value={option.value}>
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            {error && <p className="text-sm text-red-500">{error}</p>}
          </div>
        );

      case 'textarea':
        return (
          <div key={field.name} className="space-y-2">
            <Label htmlFor={field.name}>{field.label}</Label>
            <Textarea
              id={field.name}
              value={value}
              onChange={(e) => handleFieldChange(field.name, e.target.value)}
              placeholder={field.placeholder}
              className={error ? 'border-red-500' : ''}
              rows={3}
            />
            {error && <p className="text-sm text-red-500">{error}</p>}
          </div>
        );

      default:
        return (
          <div key={field.name} className="space-y-2">
            <Label htmlFor={field.name}>
              {field.label}
              {field.required && <span className="text-red-500 ml-1">*</span>}
            </Label>
            <Input
              id={field.name}
              type={field.type}
              value={value}
              onChange={(e) => handleFieldChange(field.name, e.target.value)}
              placeholder={field.placeholder}
              className={error ? 'border-red-500' : ''}
            />
            {error && <p className="text-sm text-red-500">{error}</p>}
          </div>
        );
    }
  };

  const content = (
    <div className="space-y-6">
      {/* Progress Bar */}
      <div className="space-y-2">
        <div className="flex justify-between items-center">
          <span className="text-sm text-muted-foreground">
            Step {currentStep + 1} of {totalSteps}
          </span>
          {currentStepData.optional && (
            <Badge variant="secondary">Optional</Badge>
          )}
        </div>
        <Progress value={progress} className="h-2" />
      </div>

      {/* Step Content */}
      <AnimatePresence mode="wait">
        <motion.div
          key={currentStep}
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          transition={{ duration: 0.3 }}
          className="space-y-4"
        >
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-primary/10 rounded-lg">
              <currentStepData.icon className="h-6 w-6 text-primary" />
            </div>
            <div>
              <h3 className="text-lg font-semibold">{currentStepData.title}</h3>
              <p className="text-sm text-muted-foreground">{currentStepData.description}</p>
            </div>
          </div>

          <div className="space-y-4">
            {currentStepData.fields.map(renderField)}
          </div>
        </motion.div>
      </AnimatePresence>

      {/* Actions */}
      <div className="flex justify-between items-center pt-4">
        <div className="flex gap-2">
          {currentStep > 0 && (
            <Button
              variant="outline"
              onClick={handlePrevious}
              disabled={isSubmitting}
            >
              <ChevronLeft className="h-4 w-4 mr-1" />
              Previous
            </Button>
          )}
          {onSkip && currentStep === 0 && (
            <Button
              variant="ghost"
              onClick={onSkip}
              disabled={isSubmitting}
            >
              Skip for now
            </Button>
          )}
        </div>

        <div className="flex gap-2">
          {(currentStepData.optional || isLastStep) && (
            <Button
              variant="outline"
              onClick={handleSkipStep}
              disabled={isSubmitting}
            >
              {isLastStep ? 'Skip & Finish' : 'Skip Step'}
            </Button>
          )}
          <Button
            onClick={handleNext}
            disabled={isSubmitting}
          >
            {isLastStep ? (
              <>
                <CheckCircle2 className="h-4 w-4 mr-1" />
                Complete Profile
              </>
            ) : (
              <>
                Next
                <ChevronRight className="h-4 w-4 ml-1" />
              </>
            )}
          </Button>
        </div>
      </div>
    </div>
  );

  if (isModal) {
    return (
      <Card className="w-full max-w-2xl">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Complete Your Profile</CardTitle>
            <CardDescription>
              Help us personalize your experience by completing your profile
            </CardDescription>
          </div>
          {onSkip && (
            <Button
              variant="ghost"
              size="icon"
              onClick={onSkip}
              className="h-8 w-8"
            >
              <X className="h-4 w-4" />
            </Button>
          )}
        </CardHeader>
        <CardContent>{content}</CardContent>
      </Card>
    );
  }

  return content;
}

// Profile Completion Status Component
export function ProfileCompletionStatus(): React.ReactElement {
  const { user } = useAuthStore();
  const [showProfiling, setShowProfiling] = useState(false);

  const calculateCompletion = (): number => {
    if (!user) return 0;

    const fields = [
      'full_name',
      'email',
      'phone',
      'job_title',
      'company',
      'city',
      'country',
      'bio',
    ];

    const metadata = user.user_metadata || {};
    const completed = fields.filter(field =>
      user[field as keyof typeof user] || metadata[field]
    ).length;

    return Math.round((completed / fields.length) * 100);
  };

  const completion = calculateCompletion();
  const isComplete = completion >= 80;

  if (isComplete) {
    return (
      <div className="flex items-center space-x-2 text-sm text-green-600">
        <CheckCircle2 className="h-4 w-4" />
        <span>Profile Complete</span>
      </div>
    );
  }

  return (
    <>
      <Card
        className="cursor-pointer hover:shadow-md transition-shadow"
        onClick={() => setShowProfiling(true)}
      >
        <CardContent className="p-4">
          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <p className="text-sm font-medium">Complete your profile</p>
              <p className="text-xs text-muted-foreground">
                {completion}% complete - Add more details to unlock features
              </p>
            </div>
            <div className="flex items-center space-x-3">
              <Progress value={completion} className="w-20 h-2" />
              <Award className={`h-5 w-5 ${completion > 50 ? 'text-yellow-500' : 'text-gray-400'}`} />
            </div>
          </div>
        </CardContent>
      </Card>

      {showProfiling && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <ProgressiveProfiling
            isModal
            onComplete={() => setShowProfiling(false)}
            onSkip={() => setShowProfiling(false)}
          />
        </div>
      )}
    </>
  );
}