#!/bin/bash

# Script to update Firebase configuration for new project: civicissue-aae6d

echo "🔄 Updating Firebase Configuration to civicissue-aae6d"
echo "=================================================="

# Check if google-services.json exists
if [ -f "departmentselection/departmentselection/android/app/google-services.json" ]; then
    echo "✅ Found google-services.json"
    echo "   Please make sure it's for project: civicissue-aae6d"
else
    echo "⚠️  google-services.json not found"
    echo "   Please download it from Firebase Console"
fi

# Check if service account key exists
if [ -f "service-account-key.json" ]; then
    echo "✅ Found service-account-key.json"
else
    echo "⚠️  service-account-key.json not found"
    echo "   You may need to generate a new one for the new project"
fi

echo ""
echo "📝 Next steps:"
echo "   1. Download google-services.json from Firebase Console"
echo "   2. Place it in: departmentselection/departmentselection/android/app/"
echo "   3. Get Web app config and update Admin/Admin/lib/main.dart"
echo "   4. Run: flutter clean && flutter pub get"





