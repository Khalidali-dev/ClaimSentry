# ClaimSentry 🛡️
### Autonomous Multi-Agent Reasoning Architecture for US Healthcare Claim Denial Auditing & Statutory Appeal Synthesis
**Open Agent Hackathon 2026 — Track 03: Reasoning Architecture**

ClaimSentry is an autonomous multi-agent healthcare insurance denial auditor and statutory appeal synthesizer. It replaces manual, error-prone denial management with a closed-loop **Planner ↔ Executor ↔ Evaluator** reasoning architecture integrated with **Zetaris** federated policy retrieval, **Meterless H-MEM** hierarchical memory, and **Meterless Nightshift** non-metered background reasoning.

---

## 📁 Repository Structure

The monorepo is cleanly separated into backend service and frontend dashboard directories:

```
ClaimSentry/
├── backend/                  # Python FastAPI Backend & Multi-Agent Reasoning Engine
│   ├── app/                  # Multi-agent core (Agents, Tools, Memory, Orchestrator)
│   ├── data/                 # Local CMS policies, CARC mappings, appeal templates
│   ├── input_examples/       # Sample claim denial notices and clinical notes
│   ├── output_examples/      # Audited appeal packets and scorecard examples
│   ├── tests/                # Automated pytest suite (14 unit & integration tests)
│   ├── run.py                # FastAPI HTTP service with universal CORS (/run, /health)
│   ├── requirements.txt      # Python dependencies (fastapi, uvicorn, pydantic, openai, etc.)
│   ├── Dockerfile            # Hugging Face Spaces (Docker SDK) production container (port 7860)
│   ├── .env.example          # Environment variable template
│   └── README.md             # In-depth Track 03 Reasoning Architecture & Space metadata
│
├── frontend/                 # Flutter Web Production Dashboard
│   ├── lib/                  # Application source code (UI, Models, Services, Config)
│   │   └── config/           # AppConfig (auto-configured for Hugging Face Spaces backend)
│   ├── web/                  # Web entry point, manifest, index.html
│   ├── test/                 # Automated Flutter widget test suite
│   ├── build.sh              # Zero-config automated Flutter Web build script for CI/Vercel
│   ├── vercel.json           # Vercel SPA routing rewrite rules and caching headers
│   ├── pubspec.yaml          # Flutter package dependencies
│   └── analysis_options.yaml # Dart analysis configuration
│
├── vercel.json               # Monorepo root Vercel configuration fallback
├── .gitignore                # Unified Git ignore for Python & Flutter
└── README.md                 # Deployment and architecture guide (this file)
```

---

## ☁️ Production Deployment Guide

ClaimSentry is configured for cloud deployment:
* **Frontend (Live Production)**: [https://claimsentry.vercel.app](https://claimsentry.vercel.app)
* **Backend (Hugging Face Space)**: [https://khalidali-dev-claimsentry-backend.hf.space](https://khalidali-dev-claimsentry-backend.hf.space)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Unified Vercel Monorepo Deployment                    │
│                                                                                 │
│   Flutter Web SPA (Root /)                   Python Serverless Handler (/api/*) │
│   Static Assets & Client Routing     <====>  FastAPI + Mangum ASGI Adapter      │
│   https://claimsentry.vercel.app/            https://claimsentry.vercel.app/api │
└─────────────────────────────────────────────────────────────────────────────────┘
```

> [!TIP]
> **Zero CORS / Single-Origin Architecture**: ClaimSentry supports deploying both the Flutter Web frontend and the FastAPI backend directly on **Vercel**. All API requests resolve to `/api/*` on the same origin, eliminating external hosting requirements and CORS configurations. Standalone container deployment on **Hugging Face Spaces** remains fully supported.

---

### Part 1: Unified Monorepo Deployment on Vercel (Recommended)

The repository root includes [`vercel.json`](file:///vercel.json) and [`api/index.py`](file:///api/index.py) configured with `mangum` to execute the FastAPI backend as a serverless function:
* **Frontend**: Built via `cd frontend && bash build.sh` with output at `frontend/build/web`.
* **Backend API**: All requests to `/api/*` route to [`api/index.py`](file:///api/index.py).
* **SPA Routing**: All other routes rewrite to `/index.html`.

#### Deploying with Vercel CLI:
```bash
# Deploy entire monorepo (frontend + serverless backend) to Vercel production
vercel --prod
```

---

### Part 2: Standalone Backend on Hugging Face Spaces (Alternative)

The backend is packaged with a dedicated [`backend/Dockerfile`](file:///backend/Dockerfile) following Hugging Face Spaces Docker SDK guidelines (non-root user UID 1000 and HTTP port `7860`).

#### Step-by-Step Setup:
1. **Create a Space on Hugging Face**:
   * Navigate to [Hugging Face Spaces](https://huggingface.co/new-space).
   * **Space Name**: e.g. `claimsentry-backend`.
   * **License**: Apache 2.0.
   * **Space SDK**: Select **Docker** (`Blank` template).
   * Set Space Hardware to **CPU basic** (Free tier) or upgrade as needed.
   * Set Space to **Public**.

2. **Deploy via Git / CLI**:
   Clone your new Space repository and copy the `backend/` contents into it:
   ```bash
   # Clone your empty Hugging Face Space
   git clone https://huggingface.co/spaces/<YOUR_HF_USERNAME>/claimsentry-backend hf-space
   cd hf-space

   # Copy backend files from ClaimSentry
   cp -r /path/to/ClaimSentry/backend/* .
   cp /path/to/ClaimSentry/backend/.env.example .env

   # Commit and push to Hugging Face
   git add .
   git commit -m "Deploy ClaimSentry Multi-Agent Backend to Hugging Face Space"
   git push
   ```

3. **Configure Space Secrets / Variables** (Optional):
   In your Space **Settings** → **Variables and secrets**, configure if needed:
   * `CORS_ORIGINS`: `*` (or your frontend Vercel domain `https://frontend-liard-rho-psi7h6f8u2.vercel.app`)
   * `METERLESS_BASE_URL`: Meterless inference gateway URL (default: `http://127.0.0.1:8088/v1`)
   * `METERLESS_MODEL`: Model identifier (default: `meterless/auto`)
   * `ZETARIS_REST_URL`: Zetaris federated lakehouse endpoint (default: `http://localhost:8888/api/v1.0`)

4. **Verify Deployment**:
   * Once built, Hugging Face will mark the Space **Running**.
   * Direct API endpoint: `https://<YOUR_HF_USERNAME>-claimsentry-backend.hf.space`
   * Health Check: `https://<YOUR_HF_USERNAME>-claimsentry-backend.hf.space/health`
   * Interactive Swagger Documentation: `https://<YOUR_HF_USERNAME>-claimsentry-backend.hf.space/docs`

---

### Part 2: Deploying the Frontend to Vercel

The frontend includes [`frontend/vercel.json`](file:///frontend/vercel.json) with SPA URL rewrites and [`frontend/build.sh`](file:///frontend/build.sh) for automated builds.

#### Option A: Vercel Dashboard (From Git)
1. In the [Vercel Dashboard](https://vercel.com/new), import your GitHub repository.
2. Under **Project Settings**:
   * **Framework Preset**: Select `Other`.
   * **Root Directory**: Click *Edit* and select **`frontend`**.
   * **Build Command**: `bash build.sh`
   * **Output Directory**: `build/web`
3. Under **Environment Variables**, configure your backend URL:
   * **`BACKEND_URL`**: `https://<YOUR_HF_USERNAME>-claimsentry-backend.hf.space`
4. Click **Deploy**. Vercel will install Flutter, build the optimized Web release, and deploy the application.

#### Option B: Deploying via Vercel CLI (Local Pre-Build)
If you prefer building locally and deploying directly via the Vercel CLI:

```bash
# 1. Build the Flutter Web bundle pointing to your Hugging Face Space backend
cd frontend
flutter build web --release --dart-define=BACKEND_URL=https://<YOUR_HF_USERNAME>-claimsentry-backend.hf.space

# 2. Deploy the build output to Vercel production
vercel --prod
```

#### SPA Routing Verification
When users navigate directly to sub-routes (e.g., `/dashboard`) or refresh the browser, [`frontend/vercel.json`](file:///frontend/vercel.json) ensures all requests rewrite to `/index.html`, eliminating 404 errors.

---

## 💻 Local Development Guide

### 1. Running the Backend Locally

```bash
cd backend

# Create and activate Python 3.11 virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the development server (runs on port 7860)
python run.py
```

* **Service URL**: `http://localhost:7860`
* **Health Check**: `http://localhost:7860/health`
* **Swagger API Docs**: `http://localhost:7860/docs`
* **Pipeline Audit Endpoint**: `POST http://localhost:7860/run`

#### Running Backend Automated Tests
```bash
cd backend
source .venv/bin/activate
pytest
```
*14 comprehensive unit and integration tests covering agent reasoning loops, epistemic evaluation, clinical validation, and API routes.*

---

### 2. Running the Frontend Locally

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

* **Environment Auto-Detection**: Uses `AppConfig` to target the live Hugging Face Space backend.
* **Custom Backend Flag**: To point local development to a custom backend:
  ```bash
  flutter run -d chrome --dart-define=BACKEND_URL=https://<YOUR_HF_USERNAME>-claimsentry-backend.hf.space
  ```

#### Running Frontend Automated Tests
```bash
cd frontend
flutter analyze
flutter test
```

---

## 🐳 Docker Deployment (Local Container)

To test the containerized Hugging Face Space backend locally on port 7860:

```bash
cd backend
docker build -t claimsentry-backend .
docker run -p 7860:7860 --env-file .env.example claimsentry-backend
```

Test container healthcheck:
```bash
curl http://localhost:7860/health
```

---

## 🔬 Multi-Agent Reasoning Architecture

For detailed information on the multi-agent reasoning architecture, Zetaris federated queries, Meterless H-MEM hierarchical memory, and mathematical critique convergence:
👉 Please refer to [backend/README.md](file:///backend/README.md).
