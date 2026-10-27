import pytest
from app.agents import (
    EvaluatorAgent,
    PlannerAgent,
    is_clinical_document,
    REJECTION_STATUS_NON_CLINICAL,
    REJECTION_CRITIQUE_NON_CLINICAL,
)
from app.engines.h_mem import HMEMEngine
from app.llm import MeterlessLLMClient
from app.adapters.zetaris import ZetarisClient


def test_is_clinical_document_detection():
    # Valid clinical notes
    assert is_clinical_document(
        "Patient presents with acute chest pain (R07.9). Chest X-ray ordered STAT by attending physician Dr. Marcus."
    )
    assert is_clinical_document(
        "Patient encounter: Chief complaint of chronic dyspnea. Physical examination revealed wheezing. Rx albuterol."
    )
    assert is_clinical_document(
        "Vitals: BP 140/90, HR 88. Assessment: Low back pain (M54.5). Treatment plan: physical therapy."
    )

    # Non-medical documents
    assert not is_clinical_document("")
    assert not is_clinical_document("   ")
    assert not is_clinical_document("Too short")
    assert not is_clinical_document(
        "This is a recipe for homemade pizza dough: Mix 2 cups of flour with active dry yeast, warm water, and olive oil."
    )
    assert not is_clinical_document(
        "Docker container configuration for Python and FastAPI backend. Install requirements with pip and run uvicorn."
    )
    assert not is_clinical_document(
        "Commercial real estate lease contract agreement between landlord and tenant. Monthly rent is $3,500 due on the first."
    )
    assert not is_clinical_document(
        "[Notice: No selectable text stream found in scan.pdf. If this is a scanned document, OCR is recommended.]"
    )
    # Trivial non-clinical match
    assert not is_clinical_document("Please be patient while the server downloads the latest software update.")

    # Non-clinical keywords (masterclass, webinar, course, curriculum, ai advisor, dilaton)
    assert not is_clinical_document(
        "Join our executive masterclass webinar on leadership strategies for engineering directors."
    )
    assert not is_clinical_document(
        "Online course curriculum for machine learning and deep neural networks certification."
    )
    assert not is_clinical_document(
        "Deploying an enterprise AI advisor to optimize cloud computing infrastructure costs."
    )
    assert not is_clinical_document(
        "Theoretical analysis of the dilaton scalar field in conformal gravity and cosmology."
    )


def test_evaluator_agent_rejection():
    llm = MeterlessLLMClient()
    evaluator = EvaluatorAgent(llm)

    engine = HMEMEngine(request_id="REQ-TEST-EVAL-REJECT")
    denial_notice = {
        "claim_id": "CLM-NON-MED-01",
        "billed_cpt": "71045",
        "denial_code": "CO-50",
    }
    non_medical_notes = (
        "Quarterly financial shareholder letter: Revenue increased by 14% year over year. Operating margins expanded."
    )
    engine.initialize_claim(denial_notice=denial_notice, clinical_notes=non_medical_notes)

    draft_package = {
        "summary": "Sample Draft",
        "appeal_letter": "Generic letter text",
    }

    audit_result = evaluator.audit(
        h_mem=engine,
        draft_package=draft_package,
        iteration=1,
        trace_id="REQ-TEST-EVAL-REJECT",
    )

    assert audit_result["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert audit_result["score"] == 0
    assert audit_result["passed"] is False
    assert (
        audit_result["critique"]
        == "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    )
    assert audit_result["critique_points"] == [
        "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    ]

    # Verify H-MEM Layer 3 recorded the rejection
    iterations = engine.get_critique_history()
    assert len(iterations) == 1
    assert iterations[0]["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert iterations[0]["audit_score"] == 0
    assert iterations[0]["passed_audit"] is False


def test_planner_agent_rejection():
    llm = MeterlessLLMClient()
    zetaris = ZetarisClient()
    planner = PlannerAgent(llm, zetaris)

    engine = HMEMEngine(request_id="REQ-TEST-PLAN-REJECT")
    denial_notice = {
        "claim_id": "CLM-NON-MED-02",
        "billed_cpt": "99244",
        "denial_code": "CO-16",
    }
    non_medical_notes = (
        "Hardware repair manual: Disassemble the casing using a Phillips #0 screwdriver. Replace battery and reconnect ribbon cable."
    )
    engine.initialize_claim(denial_notice=denial_notice, clinical_notes=non_medical_notes)

    plan = planner.plan(h_mem=engine, trace_id="REQ-TEST-PLAN-REJECT")

    assert plan["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert plan["is_clinical_document"] is False
    assert plan["matched_guidelines_count"] == 0
    assert (
        plan["critique"]
        == "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    )

    # Check working memory
    wm = engine.get_working_memory()
    assert wm["dynamic_facts"]["is_clinical_document"] is False
    assert wm["dynamic_facts"]["clinical_validation_status"] == "REJECTED_NON_CLINICAL_DOCUMENT"


def test_orchestrator_rejects_non_clinical_keywords():
    from app.agents import ClaimSentryOrchestrator

    orchestrator = ClaimSentryOrchestrator()
    denial_notice = {
        "claim_id": "CLM-NON-MED-03",
        "billed_cpt": "71045",
        "denial_code": "CO-50",
    }
    course_notes = (
        "Executive masterclass webinar curriculum: Reviewing deep learning algorithms, "
        "autonomous AI advisor design, and dilaton field dynamics for software engineers."
    )

    result = orchestrator.run_pipeline(
        request_id="REQ-NON-CLINICAL-KEYWORD",
        denial_notice=denial_notice,
        clinical_notes=course_notes,
    )

    assert result["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert result["iterations_count"] == 1
    assert result["audit_scorecard"]["score"] == 0
    assert result["audit_scorecard"]["passed"] is False
    assert (
        result["audit_scorecard"]["critique"]
        == "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    )
    assert len(result["critique_history"]) >= 1
    assert (
        result["critique_history"][0]["critique"]["summary"]
        == "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    )
    assert result["appeal_package"]["appeal_letter"].startswith("REJECTED:")
    assert len(result["appeal_package"]["statutory_citations"]) == 0
