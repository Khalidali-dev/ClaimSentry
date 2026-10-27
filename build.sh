#!/usr/bin/env bash
set -e

echo "=== ClaimSentry Monorepo Build ==="

# Build the Flutter web bundle
cd frontend
bash build.sh
cd ..

# Ensure build/web is populated at root as well as in frontend/build/web
mkdir -p build
rm -rf build/web
cp -r frontend/build/web build/web

echo "Monorepo build completed. Assets available at frontend/build/web and build/web."
