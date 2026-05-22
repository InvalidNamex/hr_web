#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Build Flutter Web with WebAssembly and deploy to Vercel.
# Usage:
#   ./scripts/build_web.sh [API_BASE_URL]
#
# Arguments:
#   API_BASE_URL  Optional. Overrides the production API URL at compile time.
#                 Defaults to https://natureccmpany.homeip.net:57571
# ---------------------------------------------------------------------------

API_URL="${1:-https://natureccmpany.homeip.net:57571}"

echo "Building Flutter Web (WASM) ..."
echo "  API_BASE_URL = $API_URL"
echo ""

flutter build web \
  --wasm \
  --release \
  --dart-define=API_BASE_URL="$API_URL"

echo ""
echo "Build complete → build/web/"
echo ""
echo "Deploy to Vercel:"
echo "  vercel --prod"
