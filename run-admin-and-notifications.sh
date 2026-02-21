#!/bin/bash
# Run Admin app + Notification service locally (SMS/email when you change status)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔔 Starting CivicHero Notification Service (port 3000)..."
node notification-server.js &
NODE_PID=$!

# Stop node when script exits (e.g. Ctrl+C)
trap "kill $NODE_PID 2>/dev/null" EXIT

# Give the server a moment to bind
sleep 2

echo "🖥️  Starting Admin app (Flutter web)..."
echo "   Admin will call http://127.0.0.1:3000 for notifications."
echo ""
cd Admin/Admin
flutter run -d chrome
