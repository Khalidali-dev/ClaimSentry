#!/usr/bin/env bash
set -e

# ClaimSentry Backend -> Hugging Face Spaces Deployment Automation
# Usage: ./backend/deploy_hf.sh [HF_USERNAME] [SPACE_NAME]
# Example: ./backend/deploy_hf.sh Khalidali-dev claimsentry-backend

HF_USERNAME="${1:-Khalidali-dev}"
SPACE_NAME="${2:-claimsentry-backend}"
SPACE_REPO="https://huggingface.co/spaces/${HF_USERNAME}/${SPACE_NAME}"

echo "============================================================"
echo " ClaimSentry Multi-Agent Backend -> Hugging Face Spaces"
echo " Target Space: $SPACE_REPO"
echo "============================================================"

# Verify git and curl
command -v git >/dev/null 2>&1 || { echo "git is required but not installed."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BACKEND_DIR="$PROJECT_ROOT/backend"

TMP_DIR="$(mktemp -d -t hf-claimsentry-XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning Hugging Face Space repository..."
if git clone "$SPACE_REPO" "$TMP_DIR"; then
  echo "Space repository cloned."
else
  echo ""
  echo "ERROR: Unable to clone Space from $SPACE_REPO."
  echo "Please make sure you have created the Space at https://huggingface.co/new-space"
  echo "Settings:"
  echo "  - Name: $SPACE_NAME"
  echo "  - SDK: Docker (Blank)"
  echo "  - Visibility: Public"
  echo ""
  exit 1
fi

echo "Copying backend application files..."
cp -r "$BACKEND_DIR/app" "$TMP_DIR/"
cp -r "$BACKEND_DIR/data" "$TMP_DIR/"
cp -r "$BACKEND_DIR/input_examples" "$TMP_DIR/"
cp -r "$BACKEND_DIR/output_examples" "$TMP_DIR/"
cp -r "$BACKEND_DIR/tests" "$TMP_DIR/"
cp "$BACKEND_DIR/requirements.txt" "$TMP_DIR/"
cp "$BACKEND_DIR/Dockerfile" "$TMP_DIR/"
cp "$BACKEND_DIR/run.py" "$TMP_DIR/"
cp "$BACKEND_DIR/main.py" "$TMP_DIR/"
cp "$BACKEND_DIR/README.md" "$TMP_DIR/"
cp "$BACKEND_DIR/.env.example" "$TMP_DIR/.env"

cd "$TMP_DIR"
git config user.email "${GIT_AUTHOR_EMAIL:-dev@claimsentry.ai}"
git config user.name "${GIT_AUTHOR_NAME:-ClaimSentry Agent}"

git add .
if git diff --staged --quiet; then
  echo "No changes detected. Space repository is already up to date."
else
  git commit -m "Deploy ClaimSentry multi-agent backend (FastAPI, Docker SDK, Port 7860)"
  echo "Pushing release to Hugging Face Spaces..."
  git push origin main
  echo "Deployment pushed successfully!"
fi

HF_SUBDOMAIN="$(echo "${HF_USERNAME}-${SPACE_NAME}" | tr '[:upper:]' '[:lower:]')"

echo ""
echo "============================================================"
echo " Deployment Complete!"
echo " Space Dashboard: https://huggingface.co/spaces/${HF_USERNAME}/${SPACE_NAME}"
echo " Live API Endpoint: https://${HF_SUBDOMAIN}.hf.space"
echo " Health Check:     https://${HF_SUBDOMAIN}.hf.space/health"
echo " Swagger Docs:     https://${HF_SUBDOMAIN}.hf.space/docs"
echo "============================================================"
