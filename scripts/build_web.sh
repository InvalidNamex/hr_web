#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Build Flutter Web with WebAssembly and prepare for Vercel deployment.
# Usage:
#   ./scripts/build_web.sh [API_BASE_URL]
#
# Arguments:
#   API_BASE_URL  Optional. Overrides the production API URL at compile time.
#                 Defaults to https://natureccmpany.homeip.net:57571
# ---------------------------------------------------------------------------

API_URL="${1:-/api-proxy}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Building Flutter Web (WASM) ..."
echo "  API_BASE_URL = $API_URL"
echo ""

flutter build web \
  --wasm \
  --release \
  --dart-define=API_BASE_URL="$API_URL"

# Copy Vercel routing config into the build output so you can deploy
# directly from build/web with: cd build/web && vercel --prod
cp "$ROOT_DIR/vercel.json" "$ROOT_DIR/build/web/vercel.json"

echo ""
echo "Build complete → build/web/"
echo ""
echo "Deploy to Vercel:"
echo "  cd build/web"
echo "  vercel --prod"
