# Security UI Components Documentation

## Overview

This document describes the security UI components that have been implemented to enhance the Flutter authentication template with enterprise-grade security features.

## Components

### 1. Rate Limit Indicator (`rate_limit_indicator.dart`)

**Purpose**: Provides visual feedback when API rate limits are exceeded.

**Features**:
- ✅ Animated countdown timer
- ✅ Progress bar showing time remaining
- ✅ Pulse animation for warning icon
- ✅ Auto-retry callback when limit expires
- ✅ Inline badge for showing remaining attempts

**Usage**:
```dart
// Full indicator with countdown
RateLimitIndicator(
  retryAfterSeconds: 60,
  message: 'Too many attempts. Please try again in:',
  onRetryComplete: () {
    // Enable retry button
  },
)

// Simple badge showing attempts
RateLimitBadge(
  attemptsRemaining: 3,
  maxAttempts: 5,
)
```

### 2. Account Lockout Display (`account_lockout_display.dart`)

**Purpose**: Shows account lockout status with countdown timer when too many failed login attempts occur.

**Features**:
- ✅ Real-time countdown timer (minutes:seconds)
- ✅ Animated lock icon
- ✅ Account-specific lockout display
- ✅ Auto-unlock callback
- ✅ Color-coded attempt badges

**Usage**:
```dart
// Full lockout display
AccountLockoutDisplay(
  email: 'user@example.com',
  onUnlockComplete: () {
    // Re-enable login form
  },
)

// Inline badge for attempts warning
AccountLockoutBadge(
  failedAttempts: 3,
  maxAttempts: 5,
)
```

### 3. Session Timeout Warning (`session_timeout_warning.dart`)

**Purpose**: Warns users before their session expires and provides options to extend or logout.

**Features**:
- ✅ Modal warning dialog
- ✅ Countdown timer display
- ✅ Extend session option
- ✅ Graceful logout option
- ✅ Floating session timer widget
- ✅ Auto-logout countdown overlay

**Components**:

#### SessionTimeoutWarning
Main warning dialog that appears before timeout:
```dart
SessionTimeoutWarning(
  onExtendSession: () {
    // Reset session timer
  },
  onLogout: () {
    // Perform logout
  },
)
```

#### SessionTimerWidget
Floating timer showing remaining session time:
```dart
const SessionTimerWidget()
```

#### AutoLogoutCountdown
Full-screen countdown before auto-logout:
```dart
AutoLogoutCountdown(
  countdownSeconds: 10,
  onCancel: () {
    // Cancel auto-logout
  },
)
```

### 4. Secure App Wrapper (`secure_app_wrapper.dart`)

**Purpose**: Wraps the entire app with security features and activity tracking.

**Features**:
- ✅ Global activity detection
- ✅ Automatic session management
- ✅ Integrated timeout warnings
- ✅ Auto-logout functionality
- ✅ Activity-based session extension

**Usage**:
```dart
SecureAppWrapper(
  enableSessionTimer: true,
  enableTimeoutWarning: true,
  enableAutoLogout: true,
  child: YourAppContent(),
)
```

### 5. Secure Login Form (`secure_login_form.dart`)

**Purpose**: Enhanced login form with all security features integrated.

**Features**:
- ✅ Rate limit detection and display
- ✅ Account lockout handling
- ✅ Attempt tracking
- ✅ Real-time security status
- ✅ Disabled state management

**Usage**:
```dart
SecureLoginForm(
  onSuccess: () {
    // Navigate to dashboard
  },
)
```

## Integration Guide

### Step 1: Wrap Your App

In your main app widget:

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SecureAppWrapper(
      enableSessionTimer: true,
      enableTimeoutWarning: true,
      enableAutoLogout: true,
      child: MaterialApp(
        // Your app configuration
      ),
    );
  }
}
```

### Step 2: Use Secure Login Form

Replace your existing login form:

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SecureLoginForm(
        onSuccess: () {
          Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ),
    );
  }
}
```

### Step 3: Add Activity Detection

For sensitive screens:

```dart
ActivityDetector(
  inactivityDuration: Duration(minutes: 5),
  onInactivity: () {
    // Handle inactivity
  },
  child: YourSensitiveContent(),
)
```

## Configuration

### Session Timeout Settings

In `SessionTimeoutManager`:
```dart
static const int sessionTimeoutMinutes = 30; // Session duration
static const int warningBeforeTimeoutSeconds = 60; // Warning time
```

### Rate Limit Configuration

In `RateLimiter`:
```dart
static const Map<String, RateLimitConfig> _endpointConfigs = {
  '/api/auth/login': RateLimitConfig(
    maxAttempts: 5,
    windowDurationSeconds: 60,
    blockDurationSeconds: 300,
  ),
  // Add more endpoints
};
```

### Account Lockout Settings

In `AccountLockoutService`:
```dart
static const int maxFailedAttempts = 5;
static const Duration lockoutDuration = Duration(minutes: 15);
```

## Security Best Practices

1. **Always use SecureAppWrapper** at the root level
2. **Configure appropriate timeout values** based on your security requirements
3. **Test rate limiting** in development to ensure proper UX
4. **Monitor failed login attempts** and adjust lockout settings
5. **Implement proper error handling** for all security events
6. **Log security events** for audit purposes
7. **Provide clear user feedback** for all security states

## Testing

### Unit Tests
```dart
testWidgets('Rate limit indicator shows countdown', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RateLimitIndicator(
        retryAfterSeconds: 5,
        onRetryComplete: () {},
      ),
    ),
  );

  expect(find.text('5 seconds'), findsOneWidget);

  await tester.pump(Duration(seconds: 1));
  expect(find.text('4 seconds'), findsOneWidget);
});
```

### Integration Tests
```dart
test('Account lockout after failed attempts', () async {
  for (int i = 0; i < 5; i++) {
    await attemptLogin('wrong-password');
  }

  final isLocked = await lockoutService.isAccountLocked();
  expect(isLocked, true);
});
```

## Troubleshooting

### Common Issues

1. **Session timer not updating**
   - Ensure `SecureAppWrapper` is properly initialized
   - Check that activity detection is working

2. **Rate limit not triggering**
   - Verify endpoint configuration in `RateLimiter`
   - Check that the backend is returning proper rate limit headers

3. **Account lockout not displaying**
   - Ensure `AccountLockoutService` is properly configured
   - Check that failed attempts are being tracked

## Performance Considerations

- **Session timers** use periodic timers (1 second intervals)
- **Activity detection** uses gesture detectors (minimal overhead)
- **Animations** are hardware-accelerated
- **State management** uses Riverpod for efficient rebuilds

## Accessibility

All components support:
- ✅ Screen readers
- ✅ Keyboard navigation
- ✅ High contrast themes
- ✅ Text scaling
- ✅ Semantic labels

## Future Enhancements

- [ ] Biometric re-authentication on session extend
- [ ] Customizable timeout durations per user role
- [ ] Export security event logs
- [ ] Advanced threat detection
- [ ] Device trust management UI
- [ ] Multi-factor authentication flow indicators