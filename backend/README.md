---
title: ClaimSentry Backend API
emoji: 🛡️
colorFrom: blue
colorTo: indigo
sdk: docker
app_port: 7860
pinned: false
---

# ClaimSentry 🛡️
### Autonomous Agentic Reasoning for US Healthcare Claim Denial Auditing & Appeal Generation
**Open Agent Hackathon 2026 — Track 03: Reasoning Architecture**

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.11%20%7C%203.14-green.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-teal.svg)](https://fastapi.tiangolo.com/)
[![Track](https://img.shields.io/badge/Track-03%20Reasoning%20Architecture-orange.svg)](#)

---

## 1. Executive Summary & Problem Context

In the United States healthcare ecosystem, over **$260 billion in insurance claims are denied annually**. According to the American Medical Association (AMA) and Healthcare Financial Management Association (HFMA):
- Over **15% of all healthcare provider claims** are denied upon initial adjudication.
- **65% of denied claims are never appealed** due to provider administrative exhaustion, manual medical record review bottlenecks, and the complexity of citing federal statutory precedents.
- Denials frequently cite cryptic Claim Adjustment Reason Codes (CARC) such as:
  - **CO-50**: "These are non-covered services because this is not deemed a 'medical necessity' by the payer."
  - **CO-16**: "Claim/service lacks information or has submission/billing error(s) needed for adjudication."
  - **CO-18**: "Exact duplicate claim/service or bundled line item."

Commercial insurers often issue automated algorithmic denials relying on superficial intake diagnosis codes (e.g., patient intake registration lists "back stiffness"), ignoring treating physician progress notes (EHR) that document acute clinical necessity (e.g., STAT chest X-ray ordered for acute retrosternal chest pain `R07.9`).

**ClaimSentry** solves this crisis by deploying an autonomous **multi-agent reasoning architecture** that parses denial codes and EHR clinical notes, federates billing policies and coverage guidelines via **Zetaris**, maintains working facts and critique cycles in **Meterless H-MEM**, routes reasoning through **Meterless Nightshift**, and enforces a rigorous **Planner ↔ Executor ↔ Evaluator critique feedback loop** to generate statutory, audit-proof appeal packets.

---

## 2. Multi-Agent Reasoning Architecture (Track 03)

ClaimSentry does not rely on single-prompt generation. Instead, it enforces a structured multi-agent loop with active critique, audit verification, and reflective memory:

```
                      +---------------------------------------+
                      |       Input Denial Notice & EHR       |
                      +---------------------------------------+
                                          |
                                          v
                      +---------------------------------------+
                      |        Meterless H-MEM Engine         |
                      |  - L1: Working Memory (Case Facts)    |
                      |  - L2: Policy Precedents (Rules/LCD)  |
                      |  - L3: Critique History (Meta-Reason) |
                      +---------------------------------------+
                                     ^         ^
                        Reads Context|         |Stores Plan / Precedents
                                     |         |
                               +--------------------+
                               |    PlannerAgent    | <--- Queries Zetaris
                               +--------------------+      Federated Lakehouse
                                         |
                                         | Generates Remediation Plan
                                         v
                         +------------------------------+
                         |        ExecutorAgent         | <----+
                         |   (Drafts Initial Appeal)    |      |
                         +------------------------------+      |
                                         |                     | Revision
                            Appeal Draft |                     | Directives
                                         v                     |
                         +------------------------------+      |
                         |        EvaluatorAgent        | -----+
                         | (Clinical & Statutory Audit) |  [If Critique Flagged]
                         +------------------------------+
                                         |
                                         | [Audit Score >= 90 & Passed]
                                         v
                      +---------------------------------------+
                      | Audit-Proof Statutory Appeal Package  |
                      +---------------------------------------+
```

### The Three Reasoning Agents
1. **`PlannerAgent` (Triage & Statutory Strategy Synthesis)**:
   - Analyzes denial reason codes (CARC/RARC), dates of service, and raw clinical EHR text.
   - Dynamically parses clinical findings, physician credentials, and diagnostic indications.
   - Interrogates **Zetaris** for enterprise coverage guidelines (e.g. CMS LCD L33598, NCCI policy manual, CPT Assistant).
   - Synthesizes a structured **Remediation Plan** outlining mandatory clinical citations, diagnostic crosswalks, and applicable federal statutes.

2. **`ExecutorAgent` (Drafting & Iterative Revision)**:
   - Consumes the Planner's plan, H-MEM memory layers, and clinical EHR facts.
   - In **Iteration 1**, constructs an initial formal appeal package.
   - When receiving **Evaluator critiques**, executes targeted revisions incorporating direct verbatim physician quotes, qualifying ICD-10 crosswalks, and statutory review mandates.

3. **`EvaluatorAgent` (Clinical & Statutory Compliance Auditor)**:
   - Performs a multi-point audit on the draft:
     - **Clinical Evidence Specificity**: Are verbatim physician progress notes, symptoms, and timestamps cited?
     - **ICD-10 / CPT Crosswalk Validation**: Does the appeal cite approved qualifying ICD-10 codes matching the CPT procedure?
     - **Statutory & Regulatory Rigor**: Are federal statutes (ERISA 29 CFR § 2560.503-1, ACA § 2719, Social Security Act § 1862) explicitly invoked?
     - **Remedy & Timeline Notice**: Is there an immediate overturn demand and statutory 30-day compliance deadline?
   - **Enforces the Critique Loop**: On initial drafts, it flags deficiencies, prevents premature sign-off, and transmits structured critique directives back to `ExecutorAgent`. Upon satisfactory revision, it issues an `APPROVED` audit scorecard with a verified score (95+).

---

## 3. Technology Stack & Key Components

### 3.1 Meterless Nightshift (`app/llm.py`)
- Interfaces through an OpenAI-compatible runtime routing via `METERLESS_BASE_URL` with `METERLESS_RUNTIME_TOKEN`.
- Injects standard enterprise telemetry headers:
  - `meterless-app: ClaimSentry`
  - `meterless-scope: user`
- Supports dynamic model routing (`meterless/auto`, `meterless/fast`, `meterless/deep`).
- **Resilient Fallback**: Automatically activates dynamic local reasoning synthesis when `SAMPLE_MODE=true` or when the network daemon is offline, ensuring reliable demonstration in zero-network environments.

### 3.2 Meterless H-MEM Engine (`app/engines/h_mem.py`)
- **Layer 1: Working Memory**: Tracks parsed denial notices, patient identifiers, extracted CPT/ICD codes, and raw EHR progress notes.
- **Layer 2: Semantic Policy Precedents**: Caches CMS Local Coverage Determinations (LCD), National Correct Coding Initiative (NCCI) policy rules, and statutory citations.
- **Layer 3: Reflective Critique & Meta-Memory**: Records every draft iteration, evaluator scorecard, and critique directive to track convergence across the reasoning loop.

### 3.3 Zetaris REST Client Adapter (`app/adapters/zetaris.py`)
- Connects to the **Zetaris Federated Data Virtualization REST API**:
  - Endpoint: `POST {ZETARIS_REST_URL}/sql-editor/sqls/run`
  - Headers: `Authorization: Bearer {ZETARIS_API_KEY}`, `X-Org-ID: {ZETARIS_ORG_ID}`, `X-Request-ID: {UUID}`
- Executes federated SQL queries across healthcare lakehouse schemas to retrieve clinical coverage policies.
- **Structured Mock Fallback**: When `SAMPLE_MODE=true` or if API connectivity fails, parses `data/mock_billing_rules.csv` dynamically, mapping CPT codes (71045, 99244, 99214, etc.) to valid ICD-10 crosswalks.

### 3.4 JSONL Observability & Tracing (`app/tracing.py`)
- Records structured execution traces to `logs/claim_traces.jsonl` and stdout.
- Captures: `timestamp`, `trace_id`, `agent_name`, `action`, `target_agent`, `model`, `status`, and `details`.

---

## 4. Directory Structure

```
ClaimSentry/
├── app/
│   ├── __init__.py
│   ├── agents.py           # PlannerAgent, ExecutorAgent, EvaluatorAgent & Orchestrator
│   ├── llm.py              # Meterless Nightshift client with resilient sample reasoning
│   ├── tracing.py          # Structured JSONL audit trace logger
│   ├── engines/
│   │   ├── __init__.py
│   │   └── h_mem.py        # Meterless H-MEM 3-tier hierarchical memory engine
│   └── adapters/
│       ├── __init__.py
│       └── zetaris.py      # Zetaris REST client with local lakehouse fallback
├── data/
│   └── mock_billing_rules.csv # Billing guidelines (CPT, ICD-10, LCDs, precedents)
├── input_examples/
│   ├── example_1.json      # CO-50 Medical Necessity (Chest X-ray vs Back pain intake)
│   ├── example_2.json      # CO-16 Missing documentation (Specialty Consult CPT 99244)
│   └── example_3.json      # CO-18 Duplicate claim error (Modifier -25 / -59 evidence)
├── output_examples/
│   ├── example_1.json      # Verified audit-proof statutory appeal for Example 1
│   ├── example_2.json      # Verified audit-proof statutory appeal for Example 2
│   └── example_3.json      # Verified audit-proof statutory appeal for Example 3
├── logs/                   # Directory containing claim_traces.jsonl execution traces
├── tests/
│   ├── __init__.py
│   ├── test_engine.py      # Unit tests verifying H-MEM storage & retrieval
│   └── test_run.py         # Integration tests verifying FastAPI POST /run & audit loop
├── run.py                  # FastAPI application exposing POST /run on port 8000
├── requirements.txt        # Python dependencies
├── Dockerfile              # Production Python 3.11-slim container
├── .env.example            # Environment variable template
├── .env                    # Active local environment settings
└── README.md               # System documentation
```

---

## 5. Quick Start & Installation

### Option A: Local Virtual Environment Setup

1. **Clone and navigate to repository**:
   ```bash
   cd "ClaimSentry"
   ```

2. **Create Python virtual environment**:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**:
   ```bash
   cp .env.example .env
   ```
   *(By default, `SAMPLE_MODE=true` is enabled so the system runs immediately out of the box without external API keys).*

5. **Run the test suite**:
   ```bash
   pytest -v
   ```

6. **Start the ClaimSentry API server**:
   ```bash
   python run.py
   ```
   The API will start on `http://0.0.0.0:7860` (or the port specified by `$PORT`). Interactive documentation is available at `http://localhost:7860/docs`.

---

### Option B: Docker Container (Hugging Face Spaces & Local)

1. **Build the Docker image**:
   ```bash
   docker build -t claimsentry:latest .
   ```

2. **Run the container**:
   ```bash
   docker run -p 7860:7860 --env-file .env claimsentry:latest
   ```

---

## 6. API Verification & cURL Examples

### 6.1 Root Status & Health Checks
```bash
# Root status endpoint
curl -X GET http://localhost:7860/

# Health check
curl -X GET http://localhost:7860/health
```

### 6.2 Execute Appeal Generation (Example 1: CO-50 Medical Necessity)
```bash
curl -X POST http://localhost:7860/run \
  -H "Content-Type: application/json" \
  -d @input_examples/example_1.json
```

### 6.3 Execute Appeal Generation (Example 2: CO-16 Missing Documentation)
```bash
curl -X POST http://localhost:7860/run \
  -H "Content-Type: application/json" \
  -d @input_examples/example_2.json
```

### 6.4 Execute Appeal Generation (Example 3: CO-18 Duplicate Claim / Modifier)
```bash
curl -X POST http://localhost:7860/run \
  -H "Content-Type: application/json" \
  -d @input_examples/example_3.json
```

---

## 7. Audit & Critique Trace Example

When `POST /run` is invoked, ClaimSentry streams real-time agent execution traces to both stdout and `logs/claim_traces.jsonl`:

```
[TRACE] [Orchestrator]  -> [HMEMEngine]          | INITIALIZE_PIPELINE              | INITIALIZED | model=meterless/nightshift
[TRACE] [ZetarisAdapter] -> [HMEMEngine]          | MOCK_LAKEHOUSE_QUERY             | SUCCESS     | model=meterless/nightshift
[TRACE] [PlannerAgent]  -> [ExecutorAgent]       | SYNTHESIZE_REMEDIATION_PLAN      | SUCCESS     | model=meterless/auto-local-sample
[TRACE] [ExecutorAgent] -> [EvaluatorAgent]      | GENERATE_INITIAL_APPEAL_DRAFT    | SUCCESS     | model=meterless/auto-local-sample
[TRACE] [EvaluatorAgent]-> [ExecutorAgent]       | CRITIQUE_FLAG_REVISION_REQUESTED | CRITIQUE    | model=meterless/deep-local-sample
[TRACE] [ExecutorAgent] -> [EvaluatorAgent]      | REVISE_APPEAL_PACKAGE            | SUCCESS     | model=meterless/auto-local-sample
[TRACE] [EvaluatorAgent]-> [Orchestrator]        | APPROVE_APPEAL_PACKAGE           | APPROVED    | model=meterless/deep-local-sample
[TRACE] [Orchestrator]  -> [APIClient]           | PIPELINE_COMPLETE                | APPROVED    | model=meterless/nightshift
```

---

## 8. Statutory & Regulatory Authorities Cited

Every appeal generated by ClaimSentry cites applicable federal laws and administrative guidelines:
- **ERISA 29 U.S.C. § 1133 & 29 C.F.R. § 2560.503-1(h)(2)**: Enforces the claimant's right to a "full and fair review" taking into account all medical evidence submitted, irrespective of prior adjudication determinations.
- **Affordable Care Act (ACA) § 2719 / 45 C.F.R. § 147.136**: Mandates internal claim appeal rights and external independent review processes.
- **Social Security Act § 1862(a)(1)(A)**: Codifies standard medical necessity coverage criteria.
- **CMS Local Coverage Determinations (LCDs)**: Specific diagnostic crosswalk evidence (e.g. LCD L33598 for thoracic radiology).
- **NCCI Policy Manual Chapter 1, Section E**: Coding guidelines for Modifier -25 (distinct procedural service) and Modifier -59.

---

## 9. Current Limitations & Production Roadmap

- **EHR Direct Integration**: Current submission accepts structured JSON denial notices and raw progress notes; production deployment will connect via FHIR API (Fast Healthcare Interoperability Resources) to Epic Systems and Cerner.
- **Payer Portal Automation**: Direct clearinghouse submission via EDI 278 (Prior Authorization) and EDI 837/277 (Claims & Status).
- **OCR Ingestion**: Ingestion of scanned Explanation of Benefits (EOB) mailers via multimodal vision models.

---

## 10. Submission Metadata
- **Hackathon**: Open Agent Hackathon 2026
- **Track**: Track 03: Reasoning Architecture
- **Team Submission**: ClaimSentry
