#!/bin/bash

# Enable Identity Toolkit API for Firebase Authentication Admin SDK

echo "🔧 Enabling Identity Toolkit API..."
echo "This is required to delete authentication users via Admin SDK"
echo ""

# Try using gcloud if available
if command -v gcloud &> /dev/null; then
    echo "Using gcloud to enable API..."
    gcloud services enable identitytoolkit.googleapis.com --project=civichero-480a3
    echo "✅ API enabled! Wait 1-2 minutes for it to propagate."
else
    echo "⚠️  gcloud not found. Please enable manually:"
    echo ""
    echo "1. Go to: https://console.cloud.google.com/apis/library/identitytoolkit.googleapis.com?project=civichero-480a3"
    echo "2. Click 'Enable' button"
    echo "3. Wait 1-2 minutes"
    echo "4. Then run: node clear-firebase-data.js"
fi








