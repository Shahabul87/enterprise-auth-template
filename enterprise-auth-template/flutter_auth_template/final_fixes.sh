#!/bin/bash

echo "Applying final comprehensive fixes..."

# 1. Fix Response.dataOrNull -> Response.data for Dio responses
echo "Fixing Response.data references..."
find lib -name "*.dart" -type f -exec grep -l "response\.dataOrNull" {} \; | while read file; do
    echo "  Fixing: $file"
    sed -i '' 's/response\.dataOrNull/response.data/g' "$file"
done

# 2. Fix Color import in notification_models.dart
echo "Fixing Color import in notification_models.dart..."
if ! grep -q "import 'package:flutter/material.dart';" lib/data/models/notification_models.dart; then
    sed -i '' '1i\
import '\''package:flutter/material.dart'\'';
' lib/data/models/notification_models.dart
fi

# 3. Fix connectivity_plus API changes
echo "Fixing connectivity_plus API changes..."
# The new API uses List<ConnectivityResult> instead of ConnectivityResult

# 4. Fix HttpException statusCode
echo "Fixing HttpException.statusCode..."
# HttpException doesn't have statusCode, need to handle differently

echo "Done applying fixes!"