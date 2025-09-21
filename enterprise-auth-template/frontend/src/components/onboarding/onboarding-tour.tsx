'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import {
  HelpCircle,
  X,
  ChevronRight,
  ChevronLeft,
  Target,
  CheckCircle2,
  Sparkles,
  SkipForward
} from 'lucide-react';
import { toast } from 'sonner';

interface TourStep {
  id: string;
  title: string;
  content: string;
  target?: string; // CSS selector for the target element
  placement?: 'top' | 'bottom' | 'left' | 'right' | 'center';
  action?: () => void | Promise<void>; // Optional action to perform
  highlightClickable?: boolean; // If true, allows clicking the highlighted element
  nextButtonText?: string;
  showSkip?: boolean;
}

const defaultTourSteps: TourStep[] = [
  {
    id: 'welcome',
    title: 'Welcome to Your Dashboard! 🎉',
    content: 'Let us show you around and help you get started with the key features.',
    placement: 'center',
    nextButtonText: 'Start Tour',
    showSkip: true,
  },
  {
    id: 'navigation',
    title: 'Navigation Menu',
    content: 'Use the sidebar to navigate between different sections of the application.',
    target: '[data-tour="sidebar"]',
    placement: 'right',
  },
  {
    id: 'profile',
    title: 'Your Profile',
    content: 'Click here to view and edit your profile information, settings, and preferences.',
    target: '[data-tour="profile-menu"]',
    placement: 'bottom',
    highlightClickable: true,
  },
  {
    id: 'notifications',
    title: 'Notifications',
    content: 'Stay updated with real-time notifications about important events and updates.',
    target: '[data-tour="notifications"]',
    placement: 'bottom',
  },
  {
    id: 'quick-actions',
    title: 'Quick Actions',
    content: 'Access frequently used actions and features from this quick access panel.',
    target: '[data-tour="quick-actions"]',
    placement: 'left',
  },
  {
    id: 'help',
    title: 'Need Help?',
    content: 'Click the help button anytime to access documentation, tutorials, and support.',
    target: '[data-tour="help-button"]',
    placement: 'bottom',
  },
  {
    id: 'complete',
    title: 'Tour Complete! 🎊',
    content: 'You&apos;re all set! Explore the dashboard at your own pace. You can restart this tour anytime from the help menu.',
    placement: 'center',
    nextButtonText: 'Get Started',
  },
];

interface OnboardingTourProps {
  steps?: TourStep[];
  onComplete?: () => void;
  onSkip?: () => void;
  autoStart?: boolean;
  showOnFirstVisit?: boolean;
  storageKey?: string;
}

export function OnboardingTour({
  steps = defaultTourSteps,
  onComplete,
  onSkip,
  autoStart = false,
  showOnFirstVisit = true,
  storageKey = 'onboarding-tour-completed',
}: OnboardingTourProps): React.ReactElement | null {
  const [isActive, setIsActive] = useState(false);
  const [currentStep, setCurrentStep] = useState(0);
  const [highlightPosition, setHighlightPosition] = useState<DOMRect | null>(null);
  const overlayRef = useRef<HTMLDivElement>(null);

  const currentStepData = steps[currentStep];
  const isFirstStep = currentStep === 0;
  const isLastStep = currentStep === steps.length - 1;

  // Check if tour should start automatically
  useEffect(() => {
    if (showOnFirstVisit) {
      const hasCompleted = localStorage.getItem(storageKey);
      if (!hasCompleted && autoStart) {
        setIsActive(true);
      }
    } else if (autoStart) {
      setIsActive(true);
    }
  }, [autoStart, showOnFirstVisit, storageKey]);

  // Update highlight position when step changes
  useEffect(() => {
    if (!isActive || !currentStepData.target) {
      setHighlightPosition(null);
      return;
    }

    const updatePosition = () => {
      const targetElement = document.querySelector(currentStepData.target!);
      if (targetElement) {
        const rect = targetElement.getBoundingClientRect();
        setHighlightPosition(rect);

        // Scroll element into view if needed
        targetElement.scrollIntoView({
          behavior: 'smooth',
          block: 'center',
          inline: 'center',
        });
      } else {
        setHighlightPosition(null);
      }
    };

    // Initial position
    updatePosition();

    // Update on scroll or resize
    window.addEventListener('scroll', updatePosition);
    window.addEventListener('resize', updatePosition);

    return () => {
      window.removeEventListener('scroll', updatePosition);
      window.removeEventListener('resize', updatePosition);
    };
  }, [currentStep, isActive, currentStepData.target]);

  const handleNext = useCallback(async () => {
    // Execute step action if defined
    if (currentStepData.action) {
      try {
        await currentStepData.action();
      } catch (_error) {
        // Tour step action failed
      }
    }

    if (isLastStep) {
      handleComplete();
    } else {
      setCurrentStep((prev) => prev + 1);
    }
  }, [currentStepData, isLastStep, handleComplete]);

  const handlePrevious = useCallback(() => {
    setCurrentStep((prev) => Math.max(0, prev - 1));
  }, []);

  const handleSkip = useCallback(() => {
    setIsActive(false);
    setCurrentStep(0);
    onSkip?.();
    toast.info('Tour skipped. You can restart it from the help menu.');
  }, [onSkip]);

  const handleComplete = useCallback(() => {
    setIsActive(false);
    setCurrentStep(0);
    localStorage.setItem(storageKey, 'true');
    onComplete?.();
    toast.success('Onboarding complete! Welcome aboard! 🎉');
  }, [storageKey, onComplete]);

  const startTour = useCallback(() => {
    setIsActive(true);
    setCurrentStep(0);
  }, []);

  // Get tooltip position based on placement and target
  const getTooltipPosition = (): React.CSSProperties => {
    if (!highlightPosition || currentStepData.placement === 'center') {
      return {
        position: 'fixed',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        zIndex: 10002,
      };
    }

    const padding = 16;
    const tooltipWidth = 360;
    const tooltipHeight = 200; // Approximate height

    const position: React.CSSProperties = {
      position: 'fixed',
      zIndex: 10002,
    };

    switch (currentStepData.placement) {
      case 'top':
        position.left = highlightPosition.left + highlightPosition.width / 2 - tooltipWidth / 2;
        position.bottom = window.innerHeight - highlightPosition.top + padding;
        break;
      case 'bottom':
        position.left = highlightPosition.left + highlightPosition.width / 2 - tooltipWidth / 2;
        position.top = highlightPosition.bottom + padding;
        break;
      case 'left':
        position.right = window.innerWidth - highlightPosition.left + padding;
        position.top = highlightPosition.top + highlightPosition.height / 2 - tooltipHeight / 2;
        break;
      case 'right':
        position.left = highlightPosition.right + padding;
        position.top = highlightPosition.top + highlightPosition.height / 2 - tooltipHeight / 2;
        break;
    }

    // Ensure tooltip stays within viewport
    if (position.left && typeof position.left === 'number') {
      position.left = Math.max(padding, Math.min(position.left, window.innerWidth - tooltipWidth - padding));
    }
    if (position.top && typeof position.top === 'number') {
      position.top = Math.max(padding, Math.min(position.top, window.innerHeight - tooltipHeight - padding));
    }

    return position;
  };

  // Render tour button for manual activation
  const TourButton = () => (
    <Button
      variant="outline"
      size="sm"
      onClick={startTour}
      className="fixed bottom-4 right-4 z-50"
      data-tour="help-button"
    >
      <HelpCircle className="h-4 w-4 mr-2" />
      Start Tour
    </Button>
  );

  if (!isActive) {
    return <TourButton />;
  }

  return (
    <AnimatePresence>
      {isActive && (
        <>
          {/* Overlay */}
          <motion.div
            ref={overlayRef}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-10000"
            onClick={currentStepData.highlightClickable ? undefined : (e) => e.stopPropagation()}
          >
            {/* Dark backdrop */}
            <div className="absolute inset-0 bg-black/75" />

            {/* Highlight cutout */}
            {highlightPosition && (
              <motion.div
                initial={{ opacity: 0, scale: 0.8 }}
                animate={{ opacity: 1, scale: 1 }}
                className="absolute border-2 border-primary rounded-lg"
                style={{
                  left: highlightPosition.left - 4,
                  top: highlightPosition.top - 4,
                  width: highlightPosition.width + 8,
                  height: highlightPosition.height + 8,
                  boxShadow: '0 0 0 9999px rgba(0, 0, 0, 0.75)',
                }}
              >
                {/* Pulse animation */}
                <div className="absolute inset-0 rounded-lg animate-pulse bg-primary/20" />
              </motion.div>
            )}
          </motion.div>

          {/* Tooltip */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            style={getTooltipPosition()}
            className="w-[360px]"
          >
            <Card className="shadow-2xl">
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex items-center space-x-2">
                    <div className="p-1 bg-primary/10 rounded">
                      <Sparkles className="h-4 w-4 text-primary" />
                    </div>
                    <CardTitle className="text-lg">{currentStepData.title}</CardTitle>
                  </div>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={handleSkip}
                    className="h-6 w-6"
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="pb-4">
                <CardDescription className="text-sm mb-4">
                  {currentStepData.content}
                </CardDescription>

                {/* Step indicator */}
                <div className="flex items-center justify-between mb-4">
                  <div className="flex space-x-1">
                    {steps.map((_, index) => (
                      <div
                        key={index}
                        className={`h-1.5 w-6 rounded-full transition-colors ${
                          index === currentStep
                            ? 'bg-primary'
                            : index < currentStep
                            ? 'bg-primary/50'
                            : 'bg-gray-300'
                        }`}
                      />
                    ))}
                  </div>
                  <span className="text-xs text-muted-foreground">
                    {currentStep + 1} / {steps.length}
                  </span>
                </div>

                {/* Actions */}
                <div className="flex justify-between items-center">
                  <div>
                    {!isFirstStep && (
                      <Button
                        variant="outline"
                        size="sm"
                        onClick={handlePrevious}
                      >
                        <ChevronLeft className="h-4 w-4 mr-1" />
                        Previous
                      </Button>
                    )}
                  </div>
                  <div className="flex gap-2">
                    {currentStepData.showSkip && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={handleSkip}
                      >
                        <SkipForward className="h-4 w-4 mr-1" />
                        Skip Tour
                      </Button>
                    )}
                    <Button
                      size="sm"
                      onClick={handleNext}
                    >
                      {isLastStep ? (
                        <>
                          <CheckCircle2 className="h-4 w-4 mr-1" />
                          {currentStepData.nextButtonText || 'Complete'}
                        </>
                      ) : (
                        <>
                          {currentStepData.nextButtonText || 'Next'}
                          <ChevronRight className="h-4 w-4 ml-1" />
                        </>
                      )}
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

// Quick start guide component for first-time users
export function QuickStartGuide(): React.ReactElement {
  const [dismissed, setDismissed] = useState(false);
  const [completed, setCompleted] = useState<string[]>([]);

  const tasks = [
    { id: 'profile', label: 'Complete your profile', href: '/profile' },
    { id: 'security', label: 'Set up two-factor authentication', href: '/settings/security' },
    { id: 'team', label: 'Invite team members', href: '/settings/team' },
    { id: 'explore', label: 'Explore the dashboard', href: '/dashboard' },
  ];

  useEffect(() => {
    const savedState = localStorage.getItem('quick-start-completed');
    if (savedState) {
      setCompleted(JSON.parse(savedState));
    }
  }, []);

  const handleComplete = (taskId: string) => {
    const newCompleted = [...completed, taskId];
    setCompleted(newCompleted);
    localStorage.setItem('quick-start-completed', JSON.stringify(newCompleted));

    if (newCompleted.length === tasks.length) {
      toast.success('Quick start guide complete! You&apos;re all set up! 🎉');
      setDismissed(true);
    }
  };

  if (dismissed || completed.length === tasks.length) {
    return <></>;
  }

  return (
    <Card className="mb-6">
      <CardHeader className="flex flex-row items-center justify-between pb-3">
        <div className="flex items-center space-x-2">
          <Target className="h-5 w-5 text-primary" />
          <CardTitle className="text-base">Quick Start Guide</CardTitle>
        </div>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setDismissed(true)}
        >
          Dismiss
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          {tasks.map((task) => (
            <div
              key={task.id}
              className="flex items-center justify-between p-2 rounded hover:bg-muted/50"
            >
              <a
                href={task.href}
                className="flex items-center space-x-2 flex-1"
              >
                <CheckCircle2
                  className={`h-4 w-4 ${
                    completed.includes(task.id)
                      ? 'text-green-500'
                      : 'text-gray-400'
                  }`}
                />
                <span
                  className={`text-sm ${
                    completed.includes(task.id)
                      ? 'line-through text-muted-foreground'
                      : ''
                  }`}
                >
                  {task.label}
                </span>
              </a>
              {!completed.includes(task.id) && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => handleComplete(task.id)}
                >
                  Mark Complete
                </Button>
              )}
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}