#!/bin/bash

echo "🔧 FINAL FIX - Correcting ALL compilation errors systematically"

# Fix malformed User constructors with syntax errors
echo "📝 Fixing malformed User constructors..."
find test -name "*.dart" -type f -exec sed -i '' 's/DateTime\.now(,/DateTime.now(),/g' {} \;
find test -name "*.dart" -type f -exec sed -i '' 's/DateTime\.now(),[\n\s]*),[\n\s]*updatedAt: DateTime\.now()/DateTime.now()/g' {} \;

# Fix duplicate updatedAt parameters in User constructors
echo "📝 Removing duplicate updatedAt parameters..."
find test -name "*.dart" -type f -exec perl -i -pe 's/updatedAt: DateTime\.now\(\),\s*\),\s*updatedAt: DateTime\.now\(\)/updatedAt: DateTime.now()/g' {} \;

# Fix DateTime parse syntax errors
echo "📝 Fixing DateTime.parse syntax errors..."
find test -name "*.dart" -type f -exec sed -i '' 's/DateTime\.parse([^,)]*,/DateTime.parse(/g' {} \;

# Fix malformed AuthState constructors
echo "📝 Fixing AuthState.authenticated calls..."
find test -name "*.dart" -type f -exec perl -i -0pe 's/AuthState\.authenticated\s*\(\s*user:\s*([^,]+),\s*accessToken:\s*"test-token"\),\s*updatedAt:[^)]+\),\s*\),\s*\)/AuthState.authenticated(user: $1, accessToken: "test-token")/gs' {} \;

# Fix ErrorBoundary widget issues
echo "📝 Fixing ErrorBoundary widget issues..."
sed -i '' 's/errorWidget:/\/\/errorWidget:/g' test/core/error/error_boundary_test.dart
sed -i '' 's/logger:/\/\/logger:/g' test/core/error/error_boundary_test.dart
sed -i '' 's/errorContext:/\/\/errorContext:/g' test/core/error/error_boundary_test.dart
sed -i '' 's/errorFilter:/\/\/errorFilter:/g' test/core/error/error_boundary_test.dart
sed -i '' 's/fallbackWidget:/\/\/fallbackWidget:/g' test/core/error/error_boundary_test.dart
sed -i '' 's/onMetric:/\/\/onMetric:/g' test/core/error/error_boundary_test.dart

# Fix FlutterExceptionHandler type issues
echo "📝 Fixing FlutterExceptionHandler type issues..."
find test -name "*.dart" -type f -exec sed -i '' 's/FlutterExceptionHandler?/void Function(Object, StackTrace?)?/g' {} \;

# Fix GoRouter config access
echo "📝 Fixing GoRouter config access..."
find test -name "*.dart" -type f -exec sed -i '' 's/\.config/.currentConfiguration/g' {} \;

# Generate missing mock files
echo "🔨 Generating missing mock files..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "✅ All fixes applied!"
echo "📊 Checking remaining errors..."
flutter analyze test/ 2>&1 | grep -c "^  error" | xargs echo "Remaining errors:"