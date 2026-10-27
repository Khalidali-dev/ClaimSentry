# ClaimSentry 🛡️
### Autonomous Healthcare Claim Denial Auditing & Appeal Engine
**Open Agent Hackathon 2026 — Track 03: Reasoning Architecture**

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11+-green.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-teal.svg)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-Web%20SPA-02569B.svg)](https://flutter.dev/)
[![Serverless](https://img.shields.io/badge/Serverless-Mangum%20ASGI-orange.svg)](https://github.com/Kludex/mangum)
[![Deployment](https://img.shields.io/badge/Deployment-Vercel%20Production-black.svg)](https://claimsentry.vercel.app)
[![Track](https://img.shields.io/badge/Track-03%20Reasoning%20Architecture-purple.svg)](#)

---

## 🌐 Live Production Links

ClaimSentry is deployed as a unified single-origin application on **Vercel**:

| Service | Live URL | Description |
| :--- | :--- | :--- |
| **Frontend / Web App** | [https://claimsentry.vercel.app](https://claimsentry.vercel.app) | Interactive Flutter Web SPA dashboard |
| **Backend API & Docs** | [https://claimsentry.vercel.app/api/docs](https://claimsentry.vercel.app/api/docs) | Interactive Swagger UI API documentation |
| **API Health Check** | [https://claimsentry.vercel.app/api/health](https://claimsentry.vercel.app/api/health) | Real-time backend service status |
| **Audit Pipeline Endpoint** | `POST https://claimsentry.vercel.app/api/run` | Multi-agent reasoning and statutory appeal pipeline |

---

## 1. Executive Summary

Over **$260 billion in US healthcare insurance claims are denied annually**, with more than 65% never appealed due to complex payer billing codes, manual review bottlenecks, and the burden of citing federal statutory precedents. Automated insurer claim adjudication frequently triggers adverse benefit determinations (such as **CO-50 Medical Necessity**, **CO-16 Missing Information**, or **CO-18 Duplicate Claim**) by crosswalking superficial registration codes while ignoring physician progress notes in the EHR.

**ClaimSentry** resolves this challenge with an autonomous **multi-agent reasoning architecture**:
1. **Clinical & Statutory Triage**: Automatically parses Claim Adjustment Reason Codes (CARC) and clinical encounter notes.
2. **Strict Medical Necessity Verification**: Validates clinical evidence and physician documentation to prevent processing invalid or non-clinical text.
3. **Multi-Agent Reflection & Audit Loop**: Executes an iterative **Planner ↔ Executor ↔ Evaluator** critique cycle until the statutory appeal achieves an audit compliance score of 90+ out of 100.
4. **Statutory Appeal Synthesis**: Generates audit-proof, formal appeal packages citing binding federal laws including **ERISA 29 U.S.C. § 1133**, **ACA § 2719**, and **Social Security Act § 1862**.

---

## 2. Multi-Agent Reasoning Architecture (Track 03)

ClaimSentry avoids simple single-pass generation in favor of a reflective, verifiable multi-agent loop:

```
                      ┌───────────────────────────────────────┐
                      │       Input Denial Notice & EHR       │
                      └───────────────────────────────────────┘
                                          │
                                          ▼
                      ┌───────────────────────────────────────┐
                      │       Hierarchical Memory Engine      │
                      │  - L1: Working Case Facts & Codes     │
                      │  - L2: CMS Guidelines & Precedents    │
                      │  - L3: Reflective Critique History    │
                      └───────────────────────────────────────┘
                                     ▲         ▲
                        Reads Context│         │Stores Precedents & Plans
                                     │         │
                               ┌─────────────────┐
                               │  PlannerAgent   │
                               └─────────────────┘
                                        │
                                        │ Synthesizes Remediation Plan
                                        ▼
                        ┌───────────────────────────────┐
                        │         ExecutorAgent         │ ◄───┐
                        │   (Drafts Initial Appeal)     │     │
                        └───────────────────────────────┘     │
                                        │                     │ Critique
                           Appeal Draft │                     │ Revisions
                                        ▼                     │
                        ┌───────────────────────────────┐     │
                        │        EvaluatorAgent         │ ────┘
                        │ (Clinical & Statutory Audit)  │  [If Score < 90]
                        └───────────────────────────────┘
                                        │
                                        │ [Audit Score >= 90 & Passed]
                                        ▼
                      ┌───────────────────────────────────────┐
                      │  Audit-Proof Statutory Appeal Package │
                      └───────────────────────────────────────┘
```

### The Three Reasoning Agents:
* **`PlannerAgent` (Triage & Statutory Strategy)**:
  * Evaluates denial codes (CARC/RARC), dates of service, and clinical physician notes.
  * Checks coverage guidelines, LCD precedents, and CPT/ICD diagnostic crosswalks.
  * Formulates a structured **Remediation Plan** outlining required clinical quotations, diagnosis corrections, and statutory authorities.

* **`ExecutorAgent` (Drafting & Epistemic Revision)**:
  * Ingests the case facts, memory layers, and Planner directives.
  * Constructs the formal statutory appeal letter and supporting clinical documentation.
  * Iteratively revises drafts upon receiving structured critique from `EvaluatorAgent`.

* **`EvaluatorAgent` (Clinical & Statutory Compliance Auditor)**:
  * Performs strict clinical validation: confirms presence of medical encounter indicators and rejects non-clinical documents.
  * Audits clinical specificity, CPT/ICD consistency, and explicit citations of federal statutory rights (**ERISA § 503**, **ACA § 2719**, **45 C.F.R. § 147.136**).
  * Computes a verified audit scorecard (0–100). Iterations continue until the appeal package satisfies all criteria.

---

## 3. Technology Stack

* **Frontend Dashboard**:
  * **Flutter Web (Dart)**: Responsive Single Page Application (SPA) with real-time audit visualizers, presets, and tabbed appeal viewers.
* **Backend Reasoning Service**:
  * **Python 3.11+ / FastAPI**: Async REST API with strict Pydantic schemas.
* **Serverless Runtime Adapter**:
  * **Mangum**: ASGI adapter wrapping FastAPI for serverless execution on AWS Lambda / Vercel Functions.
* **Deployment & Hosting**:
  * **Vercel Monorepo**: Single-origin architecture unifying the compiled Flutter Web frontend (`/`) and serverless backend API (`/api/*`).

---

## 4. Repository Structure

```
ClaimSentry/
├── api/                      # Vercel Serverless Function Entrypoint
│   ├── index.py              # FastAPI application wrapped with Mangum handler
│   └── requirements.txt      # Serverless runtime dependencies
│
├── backend/                  # Multi-Agent Reasoning Core Service
│   ├── app/                  # Reasoning core (Agents, Tools, Hierarchical Memory)
│   │   ├── agents.py         # PlannerAgent, ExecutorAgent, EvaluatorAgent & Orchestrator
│   │   ├── llm.py            # LLM reasoning client with local synthesis fallback
│   │   ├── tracing.py        # Structured JSONL execution tracing (safe for serverless)
│   │   ├── engines/          # 3-tier hierarchical memory engine
│   │   └── adapters/         # Clinical policy & guideline lookup adapters
│   ├── data/                 # Clinical billing guidelines (CPT, ICD-10 crosswalks)
│   ├── input_examples/       # Sample denial notices (CO-50, CO-16, CO-18)
│   ├── output_examples/      # Audited statutory appeal packets and scorecards
│   ├── tests/                # Automated pytest suite (17 unit, epistemic & serverless tests)
│   ├── run.py                # FastAPI HTTP service entrypoint
│   └── requirements.txt      # Backend Python dependencies
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
├── requirements.txt          # Root Python dependencies for Vercel
├── .gitignore                # Unified Git ignore for Python & Flutter
└── README.md                 # System documentation
```

---

## 5. Local Development Guide

### Prerequisites
* Python 3.11+
* Flutter SDK (3.19+ or stable channel)
* Chrome (for Flutter Web testing)

---

### Step 1: Running the Backend Locally

```bash
cd backend

# Create and activate Python virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the FastAPI server (runs on port 7860)
python run.py
```

* **Service URL**: `http://localhost:7860`
* **Health Check**: `http://localhost:7860/api/health`
* **Interactive Swagger Docs**: `http://localhost:7860/api/docs`
* **Pipeline Audit Endpoint**: `POST http://localhost:7860/api/run`

#### Run Backend Automated Tests:
```bash
cd backend
source .venv/bin/activate
pytest
```
*17 comprehensive automated tests verifying the multi-agent reasoning loop, epistemic scorecard audit, clinical note rejection, and Mangum serverless execution.*

---

### Step 2: Running the Frontend Locally

```bash
cd frontend

# Install Flutter dependencies
flutter pub get

# Launch on Chrome
flutter run -d chrome
```

* **Automatic Environment Detection**: The frontend automatically routes to `http://localhost:7860` during local development, and to same-origin `/api` when deployed to Vercel.

#### Run Frontend Automated Tests:
```bash
cd frontend
flutter analyze
flutter test
```
*5 automated widget and service tests verifying the interactive dashboard, presets, document parser, and audit scorecard.*

---

## 6. Production Deployment (Vercel)

ClaimSentry is deployed to Vercel as a single-origin monorepo:
* **Root (`/`)**: Serves the compiled Flutter Web SPA from `build/web`.
* **API (`/api/*`)**: Routed to [`api/index.py`](file:///api/index.py) running FastAPI via Mangum.
* **SPA Routing**: All client routes (`/audit`, `/dashboard`) rewrite to `/index.html` to prevent 404s.

Deploy with the Vercel CLI:
```bash
vercel --prod
```
Or push to GitHub with Vercel Git integration connected to trigger automatic builds.

---

## 7. Statutory & Regulatory Authorities Cited

Every appeal synthesized by ClaimSentry cites applicable federal laws and administrative precedents:
* **ERISA 29 U.S.C. § 1133 & 29 C.F.R. § 2560.503-1(h)(2)**: Enforces full and fair review mandates.
* **Affordable Care Act (ACA) § 2719 / 45 C.F.R. § 147.136**: Internal appeal and independent external review protections.
* **Social Security Act § 1862(a)(1)(A)**: Codifies statutory medical necessity definitions.
* **CMS Local Coverage Determinations (LCDs)**: Thoracic, cardiology, and orthopedic necessity criteria.
