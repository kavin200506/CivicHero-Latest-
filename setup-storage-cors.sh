#!/bin/bash

# Script to configure CORS for Firebase Storage
# This allows Flutter web to access Storage images

echo "🔧 Setting up CORS for Firebase Storage..."
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed."
    echo ""
    echo "Please install it:"
    echo "  macOS: brew install google-cloud-sdk"
    echo "  Or visit: https://cloud.google.com/sdk/docs/install"
    echo ""
    echo "After installing, run:"
    echo "  gcloud auth login"
    echo "  gcloud config set project civicissue-aae6d"
    echo ""
    exit 1
fi

# Create CORS configuration file
cat > cors-config.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "responseHeader": ["Content-Type", "Authorization"],
    "maxAgeSeconds": 3600
  }
]
EOF

echo "📝 Created CORS configuration file: cors-config.json"
echo ""

# Set the project
echo "🔧 Setting project to civicissue-aae6d..."
gcloud config set project civicissue-aae6d

# Apply CORS configuration
echo "🚀 Applying CORS configuration to Firebase Storage bucket..."
gsutil cors set cors-config.json gs://civicissue-aae6d.firebasestorage.app

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ CORS configuration applied successfully!"
    echo ""
    echo "Your Flutter web app should now be able to access Firebase Storage images."
    echo "You may need to restart your Flutter app for changes to take effect."
else
    echo ""
    echo "❌ Failed to apply CORS configuration."
    echo "Make sure you have the correct permissions and gsutil is configured."
fi

# Clean up
rm -f cors-config.json


