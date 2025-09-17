#!/bin/bash

# Script to run tests with coverage and generate reports

echo "🧪 Running Flutter tests with coverage..."

# Clean previous coverage
rm -rf coverage

# Run tests with coverage
flutter test --coverage

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo "⚠️ lcov is not installed. Please install it to generate HTML reports."
    echo "  On macOS: brew install lcov"
    echo "  On Ubuntu: sudo apt-get install lcov"
else
    # Generate HTML coverage report
    genhtml coverage/lcov.info -o coverage/html
    echo "📊 HTML coverage report generated in coverage/html/"
fi

# Calculate coverage percentage
if [ -f coverage/lcov.info ]; then
    # Extract coverage percentage
    COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep lines | grep -oE '[0-9]+\.[0-9]+%' | head -1)

    echo ""
    echo "📈 Test Coverage: $COVERAGE"

    # Check if coverage meets threshold
    THRESHOLD=80
    COVERAGE_NUM=$(echo $COVERAGE | tr -d '%')

    if (( $(echo "$COVERAGE_NUM >= $THRESHOLD" | bc -l) )); then
        echo "✅ Coverage meets the threshold of $THRESHOLD%"
    else
        echo "❌ Coverage is below the threshold of $THRESHOLD%"
        echo "   Please add more tests to improve coverage."
        exit 1
    fi
fi

echo ""
echo "✨ Test coverage analysis complete!"