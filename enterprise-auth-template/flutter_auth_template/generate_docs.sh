#!/bin/bash

# Documentation Generation Script
# This script generates comprehensive API documentation using dartdoc

set -e

echo "🚀 Starting documentation generation..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if dartdoc is installed
if ! command -v dartdoc &> /dev/null; then
    echo -e "${YELLOW}dartdoc not found. Installing...${NC}"
    dart pub global activate dartdoc
fi

# Clean previous documentation
echo "🧹 Cleaning previous documentation..."
rm -rf doc/api

# Generate code first (if using build_runner)
echo "⚙️  Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs || true

# Run dartdoc
echo "📚 Generating API documentation..."
dartdoc \
    --output doc/api \
    --format html \
    --show-progress \
    --validate-links \
    --include-source \
    --footer-text "Enterprise Authentication Template - API Documentation"

# Check if documentation was generated successfully
if [ -d "doc/api" ]; then
    echo -e "${GREEN}✅ Documentation generated successfully!${NC}"
    echo "📂 Location: doc/api/index.html"

    # Open documentation in browser (optional)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        open doc/api/index.html
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        xdg-open doc/api/index.html
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        # Windows
        start doc/api/index.html
    fi
else
    echo -e "${RED}❌ Documentation generation failed!${NC}"
    exit 1
fi

# Generate documentation coverage report
echo "📊 Generating documentation coverage report..."
dartdoc --dry-run --report-format json > doc/coverage.json 2>/dev/null || true

# Create a simple HTML index for all documentation
echo "📝 Creating documentation index..."
cat > doc/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flutter Auth Template - Documentation</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
            background: #f5f5f5;
        }
        h1 {
            color: #2196F3;
            border-bottom: 3px solid #2196F3;
            padding-bottom: 0.5rem;
        }
        .doc-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        .doc-card {
            background: white;
            border-radius: 8px;
            padding: 1.5rem;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .doc-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        .doc-card h2 {
            color: #333;
            margin-top: 0;
        }
        .doc-card p {
            color: #666;
            line-height: 1.6;
        }
        .doc-card a {
            display: inline-block;
            margin-top: 1rem;
            color: #2196F3;
            text-decoration: none;
            font-weight: 500;
        }
        .doc-card a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h1>📚 Flutter Authentication Template - Documentation Hub</h1>

    <div class="doc-grid">
        <div class="doc-card">
            <h2>🏗 Architecture Guide</h2>
            <p>Comprehensive guide to the Clean Architecture implementation, layer responsibilities, and data flow.</p>
            <a href="../ARCHITECTURE.md">View Architecture Guide →</a>
        </div>

        <div class="doc-card">
            <h2>🚀 Developer Guide</h2>
            <p>Complete onboarding guide for new developers including setup, workflow, and best practices.</p>
            <a href="DEVELOPER_GUIDE.md">View Developer Guide →</a>
        </div>

        <div class="doc-card">
            <h2>📖 API Documentation</h2>
            <p>Auto-generated API documentation for all public classes, methods, and interfaces.</p>
            <a href="api/index.html">View API Docs →</a>
        </div>

        <div class="doc-card">
            <h2>📝 API Reference</h2>
            <p>Detailed documentation of all public APIs with examples and usage patterns.</p>
            <a href="API_DOCUMENTATION.md">View API Reference →</a>
        </div>

        <div class="doc-card">
            <h2>🔄 Migration Plan</h2>
            <p>Step-by-step plan for migrating to Clean Architecture with timelines and validation criteria.</p>
            <a href="../ARCHITECTURE_MIGRATION_PLAN.md">View Migration Plan →</a>
        </div>

        <div class="doc-card">
            <h2>🎯 Architecture Decisions</h2>
            <p>Record of important architectural decisions and their rationale.</p>
            <a href="adr/">View ADRs →</a>
        </div>
    </div>

    <div style="margin-top: 3rem; padding-top: 2rem; border-top: 1px solid #ddd; text-align: center; color: #666;">
        <p>Generated on: <script>document.write(new Date().toLocaleDateString());</script></p>
        <p>Enterprise Authentication Template v1.0.0</p>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}✨ Documentation generation complete!${NC}"
echo ""
echo "📚 Available documentation:"
echo "  • Main Index: doc/index.html"
echo "  • API Docs: doc/api/index.html"
echo "  • Architecture: ARCHITECTURE.md"
echo "  • Developer Guide: docs/DEVELOPER_GUIDE.md"
echo "  • API Reference: docs/API_DOCUMENTATION.md"
echo ""
echo "💡 Tip: Add this script to your CI/CD pipeline to keep docs up-to-date!"