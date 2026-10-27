#!/usr/bin/env bash
set -e

echo "=== ClaimSentry Flutter Web Build ==="

# Check if flutter is installed
if ! command -v flutter &> /dev/null; then
  echo "Flutter not detected in PATH. Installing Flutter SDK (stable channel)..."
  FLUTTER_DIR="/tmp/flutter"
  if [ ! -d "$FLUTTER_DIR" ]; then
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

flutter --version
flutter config --no-analytics

echo "Fetching dependencies..."
flutter pub get

echo "Building Flutter Web release bundle..."
if [ -n "$BACKEND_URL" ]; then
  echo "Using custom BACKEND_URL: $BACKEND_URL"
  flutter build web --release --dart-define=BACKEND_URL="$BACKEND_URL"
else
  echo "Using production backend URL configuration."
  flutter build web --release
fi

echo "Flutter Web build complete! Output is located at build/web."
