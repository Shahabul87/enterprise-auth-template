#!/bin/bash

# Flutter App Structure Migration Script
# This script migrates the folder structure to Clean Architecture

set -e

echo "🚀 Starting Flutter app structure migration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup function
backup_project() {
    echo -e "${BLUE}📦 Creating backup...${NC}"
    cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)
    echo -e "${GREEN}✅ Backup created${NC}"
}

# Function to safely move files
safe_move() {
    local src=$1
    local dst=$2

    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        if [ -e "$dst" ]; then
            echo -e "${YELLOW}⚠️  Conflict: $dst already exists, renaming...${NC}"
            mv "$dst" "${dst}.old"
        fi
        mv "$src" "$dst"
        echo -e "${GREEN}✓${NC} Moved: $src → $dst"
    fi
}

# Function to update imports in all Dart files
update_imports() {
    local old_import=$1
    local new_import=$2

    echo "  Updating: $old_import → $new_import"

    # Find all Dart files and update imports
    find lib -name "*.dart" -type f -exec sed -i.bak "s|$old_import|$new_import|g" {} \;

    # Clean up backup files
    find lib -name "*.dart.bak" -type f -delete
}

# Start migration
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
echo -e "${BLUE}     Clean Architecture Migration Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════${NC}"

# Create backup
backup_project

# ═══════════════════════════════════════════════
# STEP 1: Merge screens into presentation/pages
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}📁 Step 1: Merging screens into presentation/pages${NC}"

# Move auth screens
if [ -d "lib/screens/auth" ]; then
    for file in lib/screens/auth/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/pages/auth/$filename"
        fi
    done
    rmdir lib/screens/auth 2>/dev/null || true
fi

# Move home screens
if [ -d "lib/screens/home" ]; then
    mkdir -p lib/presentation/pages/home
    for file in lib/screens/home/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/pages/home/$filename"
        fi
    done
    rmdir lib/screens/home 2>/dev/null || true
fi

# Move profile screens
if [ -d "lib/screens/profile" ]; then
    for file in lib/screens/profile/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/pages/profile/$filename"
        fi
    done
    rmdir lib/screens/profile 2>/dev/null || true
fi

# Move settings screens
if [ -d "lib/screens/settings" ]; then
    for file in lib/screens/settings/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/pages/settings/$filename"
        fi
    done
    rmdir lib/screens/settings 2>/dev/null || true
fi

# Move admin screens
if [ -d "lib/screens/admin" ]; then
    for file in lib/screens/admin/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/pages/admin/$filename"
        fi
    done
    rmdir lib/screens/admin 2>/dev/null || true
fi

# Move onboarding screens
if [ -d "lib/screens/onboarding" ]; then
    mkdir -p lib/presentation/pages/onboarding
    for file in lib/screens/onboarding/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/pages/onboarding/$filename"
        fi
    done
    rmdir lib/screens/onboarding 2>/dev/null || true
fi

# Move root level screens
safe_move "lib/screens/dashboard_screen.dart" "lib/presentation/pages/dashboard/dashboard_screen.dart"
safe_move "lib/screens/splash_screen.dart" "lib/presentation/pages/splash_screen.dart"

# Remove empty screens directory
rmdir lib/screens 2>/dev/null || true

# ═══════════════════════════════════════════════
# STEP 2: Move services to infrastructure layer
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}📁 Step 2: Moving services to infrastructure layer${NC}"

# Create infrastructure directories
mkdir -p lib/infrastructure/services/auth
mkdir -p lib/infrastructure/services/storage
mkdir -p lib/infrastructure/services/network
mkdir -p lib/infrastructure/services/api

# Move auth related services
safe_move "lib/services/auth_service.dart" "lib/infrastructure/services/auth/auth_service.dart"
safe_move "lib/services/oauth_service.dart" "lib/infrastructure/services/auth/oauth_service.dart"
safe_move "lib/services/biometric_service.dart" "lib/infrastructure/services/auth/biometric_service.dart"
safe_move "lib/services/two_factor_service.dart" "lib/infrastructure/services/auth/two_factor_service.dart"

# Move storage services
safe_move "lib/services/secure_storage_service.dart" "lib/infrastructure/services/storage/secure_storage_service.dart"
safe_move "lib/services/offline_service.dart" "lib/infrastructure/services/storage/offline_service.dart"

# Move network services
safe_move "lib/services/websocket_service.dart" "lib/infrastructure/services/network/websocket_service.dart"

# Move API related services
if [ -d "lib/services/api" ]; then
    for file in lib/services/api/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/infrastructure/services/api/$filename"
        fi
    done
    rmdir lib/services/api 2>/dev/null || true
fi

# Move any remaining services
if [ -d "lib/services" ]; then
    for file in lib/services/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/infrastructure/services/$filename"
        fi
    done
    rmdir lib/services 2>/dev/null || true
fi

# ═══════════════════════════════════════════════
# STEP 3: Reorganize widgets
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}📁 Step 3: Reorganizing widgets${NC}"

# Move root level widgets to presentation/widgets
if [ -d "lib/widgets" ]; then
    for dir in lib/widgets/*/; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            mkdir -p "lib/presentation/widgets/$dirname"
            for file in "$dir"*.dart; do
                if [ -f "$file" ]; then
                    filename=$(basename "$file")
                    safe_move "$file" "lib/presentation/widgets/$dirname/$filename"
                fi
            done
            rmdir "$dir" 2>/dev/null || true
        fi
    done

    # Move any root level widget files
    for file in lib/widgets/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/widgets/$filename"
        fi
    done

    rmdir lib/widgets 2>/dev/null || true
fi

# ═══════════════════════════════════════════════
# STEP 4: Move providers to presentation layer
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}📁 Step 4: Moving providers to presentation layer${NC}"

if [ -d "lib/providers" ]; then
    for file in lib/providers/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/presentation/providers/$filename"
        fi
    done

    # Move modules subdirectory if exists
    if [ -d "lib/providers/modules" ]; then
        mkdir -p lib/presentation/providers/modules
        for file in lib/providers/modules/*.dart; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                safe_move "$file" "lib/presentation/providers/modules/$filename"
            fi
        done
        rmdir lib/providers/modules 2>/dev/null || true
    fi

    rmdir lib/providers 2>/dev/null || true
fi

# ═══════════════════════════════════════════════
# STEP 5: Move models to data layer
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}📁 Step 5: Consolidating models${NC}"

if [ -d "lib/models" ]; then
    for file in lib/models/*.dart; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            safe_move "$file" "lib/data/models/$filename"
        fi
    done
    rmdir lib/models 2>/dev/null || true
fi

# ═══════════════════════════════════════════════
# STEP 6: Update all import statements
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}🔄 Step 6: Updating import statements${NC}"

# Update screens imports
update_imports "import '.*\/screens\/auth\/" "import 'package:flutter_auth_template/presentation/pages/auth/"
update_imports "import '.*\/screens\/home\/" "import 'package:flutter_auth_template/presentation/pages/home/"
update_imports "import '.*\/screens\/profile\/" "import 'package:flutter_auth_template/presentation/pages/profile/"
update_imports "import '.*\/screens\/settings\/" "import 'package:flutter_auth_template/presentation/pages/settings/"
update_imports "import '.*\/screens\/admin\/" "import 'package:flutter_auth_template/presentation/pages/admin/"
update_imports "import '.*\/screens\/onboarding\/" "import 'package:flutter_auth_template/presentation/pages/onboarding/"
update_imports "import '.*\/screens\/dashboard_screen" "import 'package:flutter_auth_template/presentation/pages/dashboard/dashboard_screen"
update_imports "import '.*\/screens\/splash_screen" "import 'package:flutter_auth_template/presentation/pages/splash_screen"

# Update services imports
update_imports "import '.*\/services\/auth_service" "import 'package:flutter_auth_template/infrastructure/services/auth/auth_service"
update_imports "import '.*\/services\/oauth_service" "import 'package:flutter_auth_template/infrastructure/services/auth/oauth_service"
update_imports "import '.*\/services\/biometric_service" "import 'package:flutter_auth_template/infrastructure/services/auth/biometric_service"
update_imports "import '.*\/services\/two_factor_service" "import 'package:flutter_auth_template/infrastructure/services/auth/two_factor_service"
update_imports "import '.*\/services\/secure_storage_service" "import 'package:flutter_auth_template/infrastructure/services/storage/secure_storage_service"
update_imports "import '.*\/services\/offline_service" "import 'package:flutter_auth_template/infrastructure/services/storage/offline_service"
update_imports "import '.*\/services\/websocket_service" "import 'package:flutter_auth_template/infrastructure/services/network/websocket_service"
update_imports "import '.*\/services\/api\/" "import 'package:flutter_auth_template/infrastructure/services/api/"

# Update widgets imports
update_imports "import '.*\/widgets\/" "import 'package:flutter_auth_template/presentation/widgets/"

# Update providers imports
update_imports "import '.*\/providers\/" "import 'package:flutter_auth_template/presentation/providers/"

# Update models imports
update_imports "import '.*\/models\/" "import 'package:flutter_auth_template/data/models/"

# Fix relative imports to absolute imports
update_imports "import '\.\.\/" "import 'package:flutter_auth_template/"
update_imports 'import "\.\.\/' 'import "package:flutter_auth_template/'

# ═══════════════════════════════════════════════
# STEP 7: Clean up and verify
# ═══════════════════════════════════════════════
echo -e "\n${BLUE}🧹 Step 7: Cleaning up${NC}"

# Remove any .bak files
find lib -name "*.bak" -type f -delete

# Check for broken imports
echo -e "\n${YELLOW}🔍 Checking for potential issues...${NC}"

# Count remaining relative imports
RELATIVE_IMPORTS=$(grep -r "import '\.\." lib --include="*.dart" | wc -l)
if [ $RELATIVE_IMPORTS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $RELATIVE_IMPORTS relative imports that may need attention${NC}"
fi

# Check if old directories still exist
if [ -d "lib/screens" ] || [ -d "lib/services" ] || [ -d "lib/widgets" ] || [ -d "lib/providers" ] || [ -d "lib/models" ]; then
    echo -e "${YELLOW}⚠️  Some old directories still exist - manual cleanup may be needed${NC}"
fi

echo -e "\n${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Migration completed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"

echo -e "\n${BLUE}📋 Next steps:${NC}"
echo "1. Run 'flutter pub get' to ensure dependencies are resolved"
echo "2. Run 'flutter analyze' to check for any issues"
echo "3. Run 'flutter test' to ensure all tests pass"
echo "4. If everything works, you can delete the backup: rm -rf lib_backup_*"

echo -e "\n${YELLOW}⚠️  Important:${NC}"
echo "- Review any '.old' files created due to conflicts"
echo "- Check and fix any remaining relative imports"
echo "- Update any hardcoded paths in configuration files"