#!/bin/bash

# Build Release Script with Security Hardening
# This script builds the Flutter app with obfuscation and security features

set -e  # Exit on error

echo "═══════════════════════════════════════════════════════"
echo "   Flutter Release Build with Security Hardening"
echo "═══════════════════════════════════════════════════════"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUILD_TYPE=${1:-"apk"}  # Default to APK
ENVIRONMENT=${2:-"production"}  # Default to production

# Paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEBUG_INFO_DIR="$PROJECT_ROOT/debug_symbols"
OUTPUT_DIR="$PROJECT_ROOT/build/output"

# Create necessary directories
mkdir -p "$DEBUG_INFO_DIR"
mkdir -p "$OUTPUT_DIR"

echo -e "${YELLOW}Build Type: $BUILD_TYPE${NC}"
echo -e "${YELLOW}Environment: $ENVIRONMENT${NC}"

# Build command with obfuscation
if [ "$BUILD_TYPE" == "apk" ]; then
    flutter build apk --release --obfuscate --split-debug-info="$DEBUG_INFO_DIR"
elif [ "$BUILD_TYPE" == "ios" ]; then
    flutter build ios --release --obfuscate --split-debug-info="$DEBUG_INFO_DIR"
fi

echo -e "${GREEN}Build completed with obfuscation!${NC}"
