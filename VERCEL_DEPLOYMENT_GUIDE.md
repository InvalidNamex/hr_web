# Flutter Web → Vercel Deployment Guide

A step-by-step reference for deploying a Flutter Web app (with WebAssembly) to Vercel and pushing subsequent updates.

---

## Prerequisites

| Tool | Install |
|---|---|
| Flutter SDK (stable) | https://docs.flutter.dev/get-started/install |
| Node.js (LTS) | https://nodejs.org |
| Vercel CLI | `npm install -g vercel` |
| A Vercel account | https://vercel.com/signup |

---

## Project Structure

Two key files are used for Vercel support:

```
vercel.json          ← routing / headers config (lives in repo root)
scripts/build_web.sh ← build helper that copies vercel.json into build/web/
```

---

## 1 · One-Time Setup (First Deploy)

### 1.1 · Install the Vercel CLI and log in

```bash
npm install -g vercel
vercel login
```

Follow the browser prompt to authenticate.

### 1.2 · Add `vercel.json` to the repo root

This file does three things:
- Disables Vercel's auto-detected framework (Flutter is not a recognized framework).
- Sets the COOP/COEP headers required for WebAssembly `SharedArrayBuffer`.
- Rewrites all unknown paths to `index.html` (required for Flutter's client-side router).

```json
{
  "version": 2,
  "framework": null,
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Cross-Origin-Opener-Policy", "value": "same-origin" },
        { "key": "Cross-Origin-Embedder-Policy", "value": "require-corp" }
      ]
    }
  ],
  "rewrites": [
    { "source": "/((?!.*\\.).*)", "destination": "/index.html" }
  ]
}
```

> If your app needs a backend API proxy (to avoid CORS or mixed-content issues), add a proxy rewrite **before** the catch-all:
> ```json
> { "source": "/api-proxy/:path*", "destination": "https://your-api-host.com/:path*" }
> ```
> Then set `API_BASE_URL=/api-proxy` at build time (see section 2).

### 1.3 · Add `scripts/build_web.sh`

This script builds the Flutter web app with WASM and copies `vercel.json` into the build output directory so you can deploy directly from `build/web/`.

```bash
#!/usr/bin/env bash
set -euo pipefail

API_URL="${1:-/api-proxy}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Building Flutter Web (WASM) ..."
flutter build web \
  --wasm \
  --release \
  --dart-define=API_BASE_URL="$API_URL"

cp "$ROOT_DIR/vercel.json" "$ROOT_DIR/build/web/vercel.json"

echo "Build complete → build/web/"
echo "Deploy: cd build/web && vercel --prod"
```

Make it executable:

```bash
chmod +x scripts/build_web.sh
```

### 1.4 · Build the app

```bash
# Using the helper script (recommended):
./scripts/build_web.sh

# Or manually:
flutter build web --wasm --release --dart-define=API_BASE_URL=/api-proxy
cp vercel.json build/web/vercel.json
```

### 1.5 · First deploy (creates the Vercel project)

```bash
cd build/web
vercel
```

Vercel CLI will prompt you interactively:

| Prompt | Answer |
|---|---|
| Set up and deploy? | `Y` |
| Which scope? | Select your account / team |
| Link to existing project? | `N` (first time) |
| Project name | e.g. `hr-requests` |
| In which directory is your code? | `.` (current directory = `build/web`) |
| Want to override settings? | `N` |

This creates a **preview** deployment. Open the printed URL to verify it works.

### 1.6 · Promote to production

```bash
vercel --prod
```

Your app is now live on `https://<project-name>.vercel.app`.

---

## 2 · Deploying Updates (Every Subsequent Release)

Each time you change the Dart/Flutter code:

```bash
# 1. Rebuild
./scripts/build_web.sh

# 2. Deploy to production
cd build/web
vercel --prod
```

That's it. Vercel creates a new immutable deployment and instantly points your production URL to it.

---

## 3 · Directing Vercel to Read from `build/web/`

Vercel needs to serve the files inside `build/web/`, not the repo root.
The approach used here is **deploy from the output folder directly**:

```bash
cd build/web   # ← change into the Flutter build output
vercel --prod  # ← Vercel sees this folder as the project root
```

Because `vercel.json` is copied into `build/web/` by the build script, Vercel picks up your routing config automatically every time.

> **Alternative (CI/CD):** If you want Vercel to build from a Git push, set the following in your Vercel project dashboard:
> - **Build Command:** `flutter build web --wasm --release`
> - **Output Directory:** `build/web`
> - **Install Command:** *(leave empty or add Flutter install steps via a custom script)*
>
> Note: Vercel's build machines do not have Flutter pre-installed, so a Git-based workflow requires additional setup (e.g., a custom Docker image or a GitHub Actions workflow that calls `vercel --prod` after building).

---

## 4 · Custom Domain (Optional)

```bash
vercel domains add yourdomain.com
```

Then follow the DNS instructions printed by the CLI. You can also manage domains in the Vercel dashboard under **Project → Settings → Domains**.

---

## 5 · Environment Variables (Optional)

If you need to inject different API URLs per environment without rebuilding:

```bash
vercel env add API_BASE_URL production
```

Or set them in **Project → Settings → Environment Variables** in the dashboard. Note that for Flutter Web, `--dart-define` values are compiled into the binary, so environment variables must be provided at **build time**, not at runtime.

---

## 6 · Quick Reference Cheat Sheet

```bash
# Full build + deploy in two commands
./scripts/build_web.sh && cd build/web && vercel --prod

# Build only (no deploy)
flutter build web --wasm --release

# Deploy already-built output
cd build/web && vercel --prod

# List your deployments
vercel ls

# Inspect a specific deployment
vercel inspect <deployment-url>

# Roll back (alias production to a previous deployment)
vercel alias set <old-deployment-url> <your-project>.vercel.app
```

---

## 7 · Troubleshooting

| Problem | Fix |
|---|---|
| Blank screen / WASM fails | Ensure `Cross-Origin-Opener-Policy` and `Cross-Origin-Embedder-Policy` headers are present in `vercel.json` |
| Deep-link returns 404 | Confirm the catch-all rewrite to `/index.html` is in `vercel.json` |
| CORS errors calling your API | Add an `/api-proxy/:path*` rewrite in `vercel.json` and build with `--dart-define=API_BASE_URL=/api-proxy` |
| `vercel` command not found | Run `npm install -g vercel` |
| Wrong project linked | Run `vercel unlink` then `vercel` again to re-link |
