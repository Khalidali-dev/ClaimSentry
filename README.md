# ClaimSentry 🛡️
### Autonomous Multi-Agent Reasoning Architecture for US Healthcare Claim Denial Auditing & Statutory Appeal Synthesis
**Open Agent Hackathon 2026 — Track 03: Reasoning Architecture**

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11+-green.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-teal.svg)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-Web%20SPA-02569B.svg)](https://flutter.dev/)
[![Deployment](https://img.shields.io/badge/Deployment-Vercel%20Monorepo-black.svg)](https://claimsentry.vercel.app)
[![Track](https://img.shields.io/badge/Track-03%20Reasoning%20Architecture-orange.svg)](#)

ClaimSentry is an autonomous multi-agent healthcare insurance denial auditor and statutory appeal synthesizer. It replaces manual, error-prone denial management with a closed-loop **Planner ↔ Executor ↔ Evaluator** reasoning architecture integrated with **Zetaris** federated policy retrieval, **Meterless H-MEM** hierarchical memory, and **Meterless Nightshift** non-metered background reasoning.

---

## 🌐 Live Production Links (Unified Vercel Monorepo)

ClaimSentry is deployed as a unified single-origin monorepo on **Vercel**:

| Service | Endpoint | Description |
| :--- | :--- | :--- |
| **Frontend Web App** | [https://claimsentry.vercel.app](https://claimsentry.vercel.app) | Flutter Web SPA Dashboard |
| **Serverless API Base** | [https://claimsentry.vercel.app/api](https://claimsentry.vercel.app/api) | FastAPI Backend API info & health |
| **API Health Check** | [https://claimsentry.vercel.app/api/health](https://claimsentry.vercel.app/api/health) | System health & lakehouse status |
| **Interactive API Docs** | [https://claimsentry.vercel.app/docs](https://claimsentry.vercel.app/docs) | Swagger UI (OpenAPI 3.0) |
| **Multi-Agent Pipeline** | `POST https://claimsentry.vercel.app/api/run` | Autonomous claim denial audit & appeal engine |

---

## 📁 Repository Structure

The monorepo unites the Flutter Web client and Python serverless backend in a unified structure:

```
ClaimSentry/
├── api/                      # Vercel Serverless Function Entrypoint
│   ├── index.py              # FastAPI application wrapped with Mangum ASGI handler
│   └── requirements.txt      # Python serverless runtime dependencies
│
├── backend/                  # Multi-Agent Reasoning Core Service
│   ├── app/                  # Reasoning core (Agents, Tools, Hierarchical Memory, Adapters)
│   │   ├── agents.py         # PlannerAgent, ExecutorAgent, EvaluatorAgent & Orchestrator
│   │   ├── llm.py            # Meterless Nightshift client with local reasoning synthesis
│   │   ├── tracing.py        # Structured JSONL execution tracing (safe for serverless)
│   │   ├── engines/          # Meterless H-MEM 3-tier hierarchical memory engine
│   │   └── adapters/         # Zetaris federated lakehouse REST adapter & policy fallback
│   ├── data/                 # Clinical billing guidelines (CPT, ICD-10, LCDs, precedents)
│   ├── input_examples/       # Sample claim denial notices (CO-50, CO-16, CO-18) and clinical notes
│   ├── output_examples/      # Audited statutory appeal packets and scorecards
│   ├── tests/                # Automated pytest suite (17 unit, epistemic & serverless tests)
│   ├── run.py                # Standalone FastAPI service entrypoint
│   ├── requirements.txt      # Backend Python dependencies
│   └── README.md             # In-depth Track 03 Reasoning Architecture guide
│
├── frontend/                 # Flutter Web Production Dashboard
│   ├── lib/                  # Application source code (UI, Models, Services, Config)
│   │   ├── config/           # AppConfig (auto-configured for same-origin /api routing)
│   │   ├── services/         # ApiService (REST client with automatic endpoint resolution)
│   │   ├── models/           # Data transfer objects for denial notices and scorecards
│   │   └── widgets/          # UI components (Header, Forms, Visualizer, Appeal Tabs)
│   ├── web/                  # Web entry point, manifest, index.html
│   ├── test/                 # Automated Flutter widget test suite
│   ├── build.sh              # Flutter Web compilation script
│   └── pubspec.yaml          # Flutter package dependencies
│
├── build.sh                  # Root monorepo build script for Vercel
├── vercel.json               # Vercel routing rules (/api/* -> serverless, /(.*) -> SPA)
├── .vercelignore             # Exclusion rules to optimize serverless bundle size
├── requirements.txt          # Root Python dependencies for Vercel build
├── .gitignore                # Unified Git ignore for Python & Flutter
└── README.md                 # System documentation (this file)
```

---

## 🚀 Unified Vercel Architecture & Deployment Guide

ClaimSentry is engineered for a **Single-Origin Monorepo Architecture** deployed entirely on **Vercel**:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     Vercel Unified Monorepo (Single Origin)                     │
│                                                                                 │
│   Flutter Web SPA (Root /)                   Python Serverless Function (/api)  │
│   Static Assets & Client Routing     <====>  FastAPI + Mangum ASGI Handler      │
│   https://claimsentry.vercel.app/            https://claimsentry.vercel.app/api │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Why Single-Origin Architecture?
* **Zero CORS Configuration**: Both the Flutter Web client and the FastAPI backend share the exact same origin (`https://claimsentry.vercel.app`). All API calls use relative paths (`/api/run`, `/api/health`), eliminating cross-origin preflight latency and CORS errors.
* **Atomic Monorepo Deployments**: Frontend dashboard and backend reasoning logic are deployed together in a single Git push.
* **Serverless Scale**: The FastAPI backend runs on AWS Lambda / Vercel Serverless via **Mangum**, scaling to zero when idle and instantly spinning up to handle concurrent audit requests.

### Configuration (`vercel.json`)
Routing and function execution are orchestrated via [`vercel.json`](file:///vercel.json):
1. **`/api` & `/api/(.*)`** ➔ Routed to [`api/index.py`](file:///api/index.py) (FastAPI Serverless Handler).
2. **`/docs` & `/openapi.json`** ➔ Routed to [`api/index.py`](file:///api/index.py) (Swagger UI).
3. **`/(.*)`** ➔ Rewritten to `/index.html` for client-side Flutter SPA navigation (prevents 404 on browser refresh).

### Deploying to Production

#### Option A: Automatic Git Integration (Recommended)
1. Push your repository to GitHub: `https://github.com/Khalidali-dev/ClaimSentry`.
2. Connect your repository to Vercel at [vercel.com/new](https://vercel.com/new).
3. Vercel automatically detects [`vercel.json`](file:///vercel.json), executes [`build.sh`](file:///build.sh) to compile Flutter Web into `build/web`, provisions [`api/index.py`](file:///api/index.py) as a serverless function, and deploys to production.

#### Option B: Deploying via Vercel CLI
```bash
# Deploy to Vercel production
vercel --prod
```

---

## 💻 Local Development Guide

### 1. Running the Backend Locally

```bash
cd backend

# Create and activate Python 3.11+ virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the development server (runs on port 7860)
python run.py
```

* **Service URL**: `http://localhost:7860`
* **Health Check**: `http://localhost:7860/health` (or `http://localhost:7860/api/health`)
* **Swagger API Docs**: `http://localhost:7860/docs`
* **Pipeline Audit Endpoint**: `POST http://localhost:7860/run`

#### Running Backend Automated Tests
```bash
cd backend
source .venv/bin/activate
pytest
```
*17 comprehensive automated tests covering multi-agent reasoning, epistemic evaluation, clinical validation, and Mangum serverless execution.*

---

### 2. Running the Frontend Locally

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

* **Environment Auto-Detection**: [`frontend/lib/config/app_config.dart`](file:///frontend/lib/config/app_config.dart) automatically detects localhost in development and points to `http://localhost:7860`. In production on Vercel, it resolves seamlessly to same-origin `/api`.
* **Custom Backend Override** (Optional):
  ```bash
  flutter run -d chrome --dart-define=BACKEND_URL=https://claimsentry.vercel.app/api
  ```

#### Running Frontend Automated Tests
```bash
cd frontend
flutter analyze
flutter test
```
*5 automated widget and unit tests verifying the interactive dashboard, presets, document parser, and audit scorecard.*

---

## 🔬 Multi-Agent Reasoning Architecture (Track 03)

For an in-depth explanation of the multi-agent reasoning loop, Zetaris federated queries, Meterless H-MEM hierarchical memory, and mathematical critique convergence:
👉 Please refer to [backend/README.md](file:///backend/README.md).
