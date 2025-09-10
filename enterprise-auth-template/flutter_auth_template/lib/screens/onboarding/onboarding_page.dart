import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../widgets/buttons/custom_buttons.dart';
import '../../core/responsive/responsive.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _pages = [
    OnboardingContent(
      title: 'Welcome to Our App',
      description:
          'Your secure gateway to amazing features and seamless experiences.',
      image: Icons.rocket_launch,
      backgroundColor: Colors.blue,
    ),
    OnboardingContent(
      title: 'Secure Authentication',
      description:
          'Advanced security with biometrics, 2FA, and passwordless login options.',
      image: Icons.security,
      backgroundColor: Colors.green,
    ),
    OnboardingContent(
      title: 'Complete Control',
      description:
          'Manage your profile, sessions, and privacy settings with ease.',
      image: Icons.settings,
      backgroundColor: Colors.purple,
    ),
    OnboardingContent(
      title: 'Ready to Start?',
      description:
          'Join thousands of users who trust us with their digital experience.',
      image: Icons.celebration,
      backgroundColor: Colors.orange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    // Save onboarding completion to preferences
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                // Page View
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(context, _pages[index], deviceType);
                  },
                ),

                // Skip Button
                if (_currentPage < _pages.length - 1)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControls(context, deviceType),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    OnboardingContent content,
    DeviceType deviceType,
  ) {
    final theme = Theme.of(context);
    final isTablet = deviceType == DeviceType.tablet;
    final isDesktop = deviceType == DeviceType.desktop;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            content.backgroundColor.withValues(alpha: 0.1),
            theme.colorScheme.surface,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : (isTablet ? 48 : 24),
        vertical: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: isDesktop ? 300 : (isTablet ? 250 : 200),
            height: isDesktop ? 300 : (isTablet ? 250 : 200),
            decoration: BoxDecoration(
              color: content.backgroundColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              content.image,
              size: isDesktop ? 150 : (isTablet ? 120 : 100),
              color: content.backgroundColor,
            ),
          ),

          SizedBox(height: isDesktop ? 60 : 40),

          // Title
          Text(
            content.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          SizedBox(
            width: isDesktop ? 500 : double.infinity,
            child: Text(
              content.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: isDesktop ? 18 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Extra spacing for bottom controls
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, DeviceType deviceType) {
    final theme = Theme.of(context);
    final isDesktop = deviceType == DeviceType.desktop;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Page Indicator
          SmoothPageIndicator(
            controller: _pageController,
            count: _pages.length,
            effect: WormEffect(
              dotWidth: 10,
              dotHeight: 10,
              spacing: 16,
              activeDotColor: theme.colorScheme.primary,
              dotColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button (visible after first page)
              AnimatedOpacity(
                opacity: _currentPage > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                ),
              ),

              // Next/Get Started Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _nextPage,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    isFullWidth: true,
                  ),
                ),
              ),

              // Placeholder for alignment
              const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData image;
  final Color backgroundColor;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.image,
    required this.backgroundColor,
  });
}

/// Feature tour for existing users
class FeatureTourPage extends ConsumerStatefulWidget {
  const FeatureTourPage({Key? key}) : super(key: key);

  @override
  ConsumerState<FeatureTourPage> createState() => _FeatureTourPageState();
}

class _FeatureTourPageState extends ConsumerState<FeatureTourPage> {
  int _currentStep = 0;

  final List<TourStep> _tourSteps = [
    TourStep(
      title: 'New Security Features',
      description:
          'Enhanced 2FA with backup codes and biometric authentication.',
      target: 'security_settings',
      icon: Icons.security,
    ),
    TourStep(
      title: 'Session Management',
      description:
          'Monitor and control all active sessions across your devices.',
      target: 'sessions',
      icon: Icons.devices,
    ),
    TourStep(
      title: 'Privacy Controls',
      description:
          'Fine-tune your privacy settings and data sharing preferences.',
      target: 'privacy',
      icon: Icons.privacy_tip,
    ),
    TourStep(
      title: 'Customization',
      description: 'Personalize your experience with themes and preferences.',
      target: 'appearance',
      icon: Icons.palette,
    ),
  ];

  void _nextStep() {
    if (_currentStep < _tourSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _completeTour();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _skipTour() {
    _completeTour();
  }

  void _completeTour() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStep = _tourSteps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(onPressed: _skipTour, child: const Text('Skip Tour')),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress Indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / _tourSteps.length,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 40),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentStep.icon,
                  size: 60,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                currentStep.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                currentStep.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  TextButton(
                    onPressed: _currentStep > 0 ? _previousStep : null,
                    child: const Text('Previous'),
                  ),

                  // Step Indicator
                  Text(
                    '${_currentStep + 1} of ${_tourSteps.length}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),

                  // Next/Complete Button
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == _tourSteps.length - 1
                          ? 'Complete'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final String target;
  final IconData icon;

  const TourStep({
    required this.title,
    required this.description,
    required this.target,
    required this.icon,
  });
}

/// Welcome back screen for returning users
class WelcomeBackPage extends StatelessWidget {
  final String userName;

  const WelcomeBackPage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.waving_hand,
                  size: 60,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(height: 32),

              // Welcome Message
              Text(
                'Welcome Back',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                userName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'We\'re glad to see you again!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),

              // What's New Button
              TextButton(
                onPressed: () => context.push('/feature-tour'),
                child: const Text('See What\'s New'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
