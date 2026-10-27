import pytest
from app.engines.h_mem import HMEMEngine


def test_hmem_initialization():
    engine = HMEMEngine(request_id="REQ-TEST-001")
    assert engine.request_id == "REQ-TEST-001"

    denial_notice = {
        "claim_id": "CLM-TEST-01",
        "patient_name": "John Doe",
        "patient_dob": "1975-05-15",
        "member_id": "MBR-9988",
        "payer_name": "Test Payer",
        "date_of_service": "2026-03-01",
        "billed_cpt": "71045",
        "billed_icd10": "M54.5",
        "billed_amount": 350.00,
        "denial_code": "CO-50",
        "denial_reason": "Medical necessity not established",
    }
    clinical_notes = "Patient presents with acute chest pain (R07.9). Chest X-ray ordered STAT."

    engine.initialize_claim(denial_notice=denial_notice, clinical_notes=clinical_notes)

    wm = engine.get_working_memory()
    assert wm["claim_id"] == "CLM-TEST-01"
    assert wm["patient_info"]["name"] == "John Doe"
    assert "71045" in wm["extracted_entities"]["cpt_codes"]
    assert "M54.5" in wm["extracted_entities"]["icd10_codes"]
    assert wm["raw_clinical_notes"] == clinical_notes


def test_hmem_working_facts():
    engine = HMEMEngine(request_id="REQ-TEST-002")
    engine.store_working_fact("target_icd10", "R07.9")
    engine.store_working_fact("provider_npi", "1234567890")

    wm = engine.get_working_memory()
    assert wm["dynamic_facts"]["target_icd10"] == "R07.9"
    assert wm["dynamic_facts"]["provider_npi"] == "1234567890"


def test_hmem_layer2_policy_precedents():
    engine = HMEMEngine(request_id="REQ-TEST-003")
    rules = [
        {
            "cpt_code": "71045",
            "denial_code": "CO-50",
            "valid_icd10_codes": "R07.9|R05",
            "medical_policy_id": "CMS-LCD-L33598",
        }
    ]
    statutes = ["ERISA 29 U.S.C. § 1133", "ACA § 2719"]
    remedies = ["Establish diagnosis mismatch between registration and physician note"]

    engine.store_policy_precedents(cpt_rules=rules, statutes=statutes, remedies=remedies)

    precedents = engine.get_policy_precedents()
    assert len(precedents["cpt_rules"]) == 1
    assert precedents["cpt_rules"][0]["medical_policy_id"] == "CMS-LCD-L33598"
    assert "ACA § 2719" in precedents["applicable_statutes"]
    assert len(precedents["appeal_remedies"]) == 1


def test_hmem_layer3_iteration_critiques():
    engine = HMEMEngine(request_id="REQ-TEST-004")

    # Iteration 1: Critique
    draft_1 = {"summary": "Initial draft", "appeal_letter": "Short draft without direct clinical quote"}
    critique_1 = {
        "passed": False,
        "score": 68,
        "status": "CRITIQUE_REVISION_REQUESTED",
        "critique_points": ["Include verbatim physician quote", "Add statutory citation"],
    }
    engine.record_iteration(iteration_num=1, draft=draft_1, critique=critique_1, status="CRITIQUE_REVISION_REQUESTED")

    assert len(engine.get_critique_history()) == 1
    latest = engine.get_latest_iteration()
    assert latest["passed_audit"] is False
    assert latest["audit_score"] == 68

    # Iteration 2: Approval
    draft_2 = {"summary": "Revised draft", "appeal_letter": "Comprehensive draft with quotes and citations"}
    critique_2 = {
        "passed": True,
        "score": 96,
        "status": "APPROVED",
        "critique_points": [],
    }
    engine.record_iteration(iteration_num=2, draft=draft_2, critique=critique_2, status="APPROVED")

    assert len(engine.get_critique_history()) == 2
    latest_2 = engine.get_latest_iteration()
    assert latest_2["passed_audit"] is True
    assert latest_2["audit_score"] == 96

    # Test summary
    summary = engine.summary()
    assert summary["request_id"] == "REQ-TEST-004"
    assert summary["iteration_count"] == 2
    assert summary["latest_audit_score"] == 96
    assert summary["final_status"] == "APPROVED"
