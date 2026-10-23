import os
import uuid
from typing import Any, Dict, List, Optional
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn

from app.agents import ClaimSentryOrchestrator

load_dotenv()

app = FastAPI(
    title="ClaimSentry",
    description="Autonomous Agentic Reasoning for US Healthcare Claim Denial Auditing & Appeal Generation (Track 03: Reasoning Architecture)",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

orchestrator = ClaimSentryOrchestrator()


class DenialNoticeModel(BaseModel):
    claim_id: str = Field(..., description="Unique insurance claim identifier")
    patient_name: Optional[str] = Field(None, description="Patient full name")
    patient_dob: Optional[str] = Field(None, description="Patient Date of Birth (YYYY-MM-DD)")
    member_id: Optional[str] = Field(None, description="Insurance subscriber/member ID")
    payer_name: Optional[str] = Field(None, description="Health plan or insurance carrier name")
    payer_id: Optional[str] = Field(None, description="Electronic Payer ID")
    date_of_service: Optional[str] = Field(None, description="Service encounter date (YYYY-MM-DD)")
    billed_cpt: str = Field(..., description="CPT procedure code billed")
    billed_cpt_description: Optional[str] = Field(None, description="Description of procedure code")
    billed_icd10: Optional[str] = Field(None, description="Primary ICD-10 diagnosis code billed")
    billed_icd10_description: Optional[str] = Field(None, description="Description of diagnosis code")
    billed_amount: Optional[float] = Field(None, description="Total billed charge amount in USD")
    denial_code: str = Field(..., description="CARC / RARC denial reason code (e.g., CO-50, CO-16, CO-18)")
    denial_reason: Optional[str] = Field(None, description="Payer explanation of benefits reason text")
    timely_filing_deadline_days: Optional[int] = Field(180, description="Appeals submission deadline in days")


class RunRequest(BaseModel):
    request_id: Optional[str] = Field(default_factory=lambda: f"REQ-{uuid.uuid4().hex[:8].upper()}")
    denial_notice: Dict[str, Any] = Field(..., description="Structured claim denial notice")
    clinical_notes: Any = Field(..., description="Unstructured physician progress note or EHR text")


class RunResponse(BaseModel):
    request_id: str
    status: str
    iterations_count: int
    remediation_plan: Dict[str, Any]
    audit_scorecard: Dict[str, Any]
    critique_history: List[Dict[str, Any]]
    appeal_package: Dict[str, Any]
    h_mem_summary: Dict[str, Any]
    trace_summary: List[Dict[str, Any]]


@app.get("/")
def read_root():
    return {
        "service": "ClaimSentry",
        "description": "Autonomous Healthcare Claim Denial Auditing & Appeal Engine",
        "track": "Track 03: Reasoning Architecture",
        "status": "operational",
        "endpoints": {
            "run": "POST /run",
            "health": "GET /health",
            "docs": "GET /docs",
        },
    }


@app.get("/health")
def health_check():
    sample_mode = os.getenv("SAMPLE_MODE", "false").lower() in ("true", "1", "yes")
    return {
        "status": "healthy",
        "sample_mode": sample_mode,
        "meterless_url": os.getenv("METERLESS_BASE_URL", "http://127.0.0.1:8088/v1"),
        "zetaris_url": os.getenv("ZETARIS_REST_URL", "http://localhost:8888/api/v1.0"),
    }



@app.post("/run", response_model=RunResponse)
def run_appeal_pipeline(payload: RunRequest):
    req_id = payload.request_id or f"REQ-{uuid.uuid4().hex[:8].upper()}"

    denial_data = payload.denial_notice
    if isinstance(denial_data, dict):
        if "billed_cpt" not in denial_data or "denial_code" not in denial_data:
            raise HTTPException(
                status_code=400,
                detail="denial_notice must include at least 'billed_cpt' and 'denial_code'",
            )
    else:
        raise HTTPException(status_code=400, detail="denial_notice must be a valid object")

    raw_notes = payload.clinical_notes
    if isinstance(raw_notes, dict):
        notes_text = "\n".join([f"{k}: {v}" for k, v in raw_notes.items()])
    else:
        notes_text = str(raw_notes)

    try:
        result = orchestrator.run_pipeline(
            request_id=req_id,
            denial_notice=denial_data,
            clinical_notes=notes_text,
            max_iterations=3,
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Pipeline execution failure: {str(e)}")


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    host = os.getenv("HOST", "0.0.0.0")
    print(f"Starting ClaimSentry server on {host}:{port}...")
    uvicorn.run("run:app", host=host, port=port, reload=False)
