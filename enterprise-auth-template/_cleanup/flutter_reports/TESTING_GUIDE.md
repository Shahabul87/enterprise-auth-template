# Flutter Testing Guide

## 📖 Overview

This guide provides comprehensive instructions for testing the Flutter authentication template application. The test suite covers unit tests, widget tests, integration tests, and security testing.

## 🏗️ Test Architecture

```
test/
├── unit/                    # Unit tests for business logic
│   ├── core/               # Core services and utilities
│   │   ├── network/        # API client tests
│   │   └── security/       # Security features tests
│   ├── data/               # Data layer tests
│   │   ├── services/       # Service tests
│   │   └── repositories/   # Repository tests
│   ├── domain/             # Domain layer tests
│   │   └── use_cases/      # Use case tests
│   └── providers/          # State management tests
├── widget/                 # Widget tests for UI components
│   └── auth/              # Authentication UI tests
├── integration/           # Integration tests
└── test_helpers/          # Test utilities and mocks
```

## 🚀 Quick Start

### Prerequisites

1. **Install Flutter**
   ```bash
   flutter doctor
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Mocks**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Running Tests

#### Run All Tests
```bash
./run_all_tests.sh
```

#### Run Specific Test Categories
```bash
# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/

# Integration tests (requires emulator/device)
flutter test integration_test/
```

#### Run Individual Test Files
```bash
flutter test test/unit/core/security/token_manager_test.dart
```

#### Run Tests with Coverage
```bash
flutter test --coverage
```

## 📝 Writing Tests

### Unit Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ServiceToMock])
void main() {
  late ServiceUnderTest service;
  late MockServiceToMock mockService;

  setUp(() {
    mockService = MockServiceToMock();
    service = ServiceUnderTest(mockService);
  });

  tearDown(() {
    // Cleanup if needed
  });

  group('ServiceUnderTest', () {
    test('should do something when condition is met', () async {
      // Arrange
      when(mockService.someMethod()).thenAnswer((_) async => expectedValue);

      // Act
      final result = await service.methodToTest();

      // Assert
      expect(result, equals(expectedValue));
      verify(mockService.someMethod()).called(1);
    });
  });
}
```

### Widget Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget should display correctly', (tester) async {
    // Arrange
    await tester.pumpWidget(
      MaterialApp(
        home: WidgetToTest(),
      ),
    );

    // Act
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Assert
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

### Integration Test Template

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_auth_template/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user flow test', (tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();

    // Perform actions
    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Verify results
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

## 🧪 Test Categories

### 1. Core Services Tests

**Location**: `test/unit/core/`

- **Token Manager**: Token storage and validation
- **Biometric Service**: Biometric authentication
- **API Client**: Network requests and responses
- **Security**: CSRF, input sanitization, device security

### 2. Data Layer Tests

**Location**: `test/unit/data/`

- **Services**: API service implementations
- **Repositories**: Data repository logic
- **Models**: Data model serialization/deserialization

### 3. Domain Layer Tests

**Location**: `test/unit/domain/`

- **Use Cases**: Business logic implementation
- **Entities**: Domain entity behavior
- **Value Objects**: Value object validation

### 4. Provider Tests

**Location**: `test/unit/providers/`

- **State Management**: Riverpod provider logic
- **State Transitions**: Auth state changes
- **Error Handling**: Error state management

### 5. Widget Tests

**Location**: `test/widget/`

- **Forms**: Input validation and submission
- **Navigation**: Screen navigation
- **Error Display**: Error message rendering
- **Loading States**: Loading indicator display

### 6. Integration Tests

**Location**: `integration_test/`

- **Auth Flow**: Complete authentication journey
- **Session Management**: Token refresh and persistence
- **Error Recovery**: Network error handling
- **Deep Links**: URL navigation

## 🔍 Test Coverage

### Current Coverage Areas

✅ **Fully Tested**
- Authentication services
- Token management
- Input validation
- Error handling
- State management

⚠️ **Partial Coverage**
- OAuth integration (platform-specific)
- Push notifications (requires device)
- Offline sync (complex scenarios)

❌ **Not Yet Tested**
- WebAuthn (browser-specific)
- Payment integration (if applicable)
- Analytics tracking

### Coverage Goals

- **Minimum**: 70% code coverage
- **Target**: 80% code coverage
- **Ideal**: 90% code coverage

### Generating Coverage Reports

1. **Run tests with coverage**
   ```bash
   flutter test --coverage
   ```

2. **Generate HTML report** (requires lcov)
   ```bash
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html
   ```

3. **View coverage in VS Code**
   - Install "Coverage Gutters" extension
   - Run tests with coverage
   - Click "Watch" in status bar

## 🐛 Debugging Tests

### Common Issues and Solutions

#### 1. Mock Generation Fails
```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Test Timeout
```dart
// Increase timeout for slow operations
test('slow test', () async {
  // test code
}, timeout: Timeout(Duration(minutes: 2)));
```

#### 3. Widget Test Failures
```dart
// Use pumpAndSettle for animations
await tester.pumpAndSettle();

// Debug widget tree
debugDumpApp();
```

#### 4. Async Issues
```dart
// Properly await async operations
await tester.runAsync(() async {
  await Future.delayed(Duration(seconds: 1));
});
```

### Debugging Commands

```bash
# Verbose output
flutter test --verbose

# Run specific test by name
flutter test --name "should login successfully"

# Run tests in specific order
flutter test --test-randomize-ordering-seed=12345

# Debug mode
flutter test --start-paused
```

## 📊 Test Metrics

### Key Performance Indicators

| Metric | Target | Current |
|--------|--------|---------|
| Code Coverage | >80% | ~70% |
| Test Execution Time | <30s | ~25s |
| Test Reliability | 100% | 95% |
| Mock Coverage | 100% | 100% |

### Test Pyramid

```
        /\
       /  \  E2E Tests (5%)
      /----\
     /      \  Integration Tests (15%)
    /--------\
   /          \  Widget Tests (30%)
  /------------\
 /              \  Unit Tests (50%)
/________________\
```

## 🔧 CI/CD Integration

### GitHub Actions Example

```yaml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
        with:
          file: coverage/lcov.info
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

flutter test --no-pub
if [ $? -ne 0 ]; then
  echo "Tests failed. Commit aborted."
  exit 1
fi
```

## 📚 Best Practices

### 1. Test Naming
- Use descriptive names
- Follow "should [do something] when [condition]" pattern
- Group related tests

### 2. Test Independence
- Each test should run independently
- Use setUp/tearDown for initialization
- Avoid shared state between tests

### 3. Mocking Strategy
- Mock external dependencies
- Use real implementations for value objects
- Prefer fakes over mocks when appropriate

### 4. Assertion Guidelines
- One logical assertion per test
- Use appropriate matchers
- Verify both positive and negative cases

### 5. Performance Testing
- Keep tests fast (<100ms per test)
- Use test tags for slow tests
- Run slow tests separately in CI

## 🎯 Testing Checklist

### Before Committing
- [ ] All tests pass locally
- [ ] New code has tests
- [ ] Coverage hasn't decreased
- [ ] No skipped tests
- [ ] Mocks are up to date

### Before Release
- [ ] All tests pass in CI
- [ ] Integration tests pass
- [ ] Performance tests pass
- [ ] Security tests pass
- [ ] Coverage meets target

### Code Review
- [ ] Tests are readable
- [ ] Tests cover edge cases
- [ ] Tests follow conventions
- [ ] No flaky tests
- [ ] Appropriate test types used

## 📈 Continuous Improvement

### Monthly Review
1. Analyze test failures
2. Identify flaky tests
3. Update test documentation
4. Review coverage gaps
5. Optimize slow tests

### Quarterly Goals
1. Increase coverage by 5%
2. Reduce test execution time by 10%
3. Eliminate all flaky tests
4. Add new test categories as needed

## 🆘 Support

### Resources
- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Integration Test Package](https://pub.dev/packages/integration_test)

### Common Commands Reference
```bash
# Generate mocks
flutter pub run build_runner build

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific directory
flutter test test/unit/

# Run specific file
flutter test test/unit/auth_test.dart

# Run by name pattern
flutter test --name "login"

# Update golden files
flutter test --update-goldens
```

---

*Last Updated: January 2025*
*Version: 1.0.0*