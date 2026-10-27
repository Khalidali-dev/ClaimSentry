import json
import os
import pytest
from fastapi.testclient import TestClient
from run import app

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "meterless_url" in data
    assert "zetaris_url" in data


def test_root_endpoint():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "ClaimSentry"
    assert data["status"] == "operational"


def test_run_endpoint_success():
    payload = {
        "request_id": "REQ-API-TEST-001",
        "denial_notice": {
            "claim_id": "CLM-API-TEST",
            "patient_name": "Eleanor Vance",
            "patient_dob": "1968-04-12",
            "member_id": "ANT-8829104",
            "payer_name": "Anthem Blue Cross Blue Shield",
            "date_of_service": "2026-02-14",
            "billed_cpt": "71045",
            "billed_cpt_description": "Radiologic examination, chest; single view",
            "billed_icd10": "M54.5",
            "billed_amount": 345.00,
            "denial_code": "CO-50",
            "denial_reason": "Medical necessity not established",
        },
        "clinical_notes": (
            "Physician Progress Note: Patient presents with acute retrosternal chest pain (R07.9) "
            "and dyspnea. Chest radiograph ordered STAT to rule out acute cardiothoracic pathology."
        ),
    }

    response = client.post("/run", json=payload)
    assert response.status_code == 200
    data = response.json()

    # Verify status and audit output
    assert data["request_id"] == "REQ-API-TEST-001"
    assert data["status"] == "APPROVED"
    assert data["iterations_count"] >= 2  # Proves Evaluator critique-revision loop ran!

    # Verify appeal package is non-empty and compliant
    appeal_package = data["appeal_package"]
    assert appeal_package is not None
    assert "appeal_letter" in appeal_package
    assert len(appeal_package["appeal_letter"]) > 100
    assert "statutory_citations" in appeal_package
    assert len(appeal_package["statutory_citations"]) > 0

    # Verify audit scorecard
    audit = data["audit_scorecard"]
    assert audit["passed"] is True
    assert audit["score"] >= 90

    # Verify critique history is present
    critique_history = data["critique_history"]
    assert len(critique_history) >= 2
    assert critique_history[0]["passed_audit"] is False  # Initial critique


def test_run_endpoint_validation_error():
    # Missing required billed_cpt field
    invalid_payload = {
        "request_id": "REQ-ERR-001",
        "denial_notice": {
            "claim_id": "CLM-INVALID",
            # missing billed_cpt and denial_code
        },
        "clinical_notes": "Some clinical notes",
    }
    response = client.post("/run", json=invalid_payload)
    assert response.status_code == 400


def test_run_endpoint_rejected_non_clinical_document():
    # Non-medical document: cooking recipe
    recipe_payload = {
        "request_id": "REQ-RECIPE-001",
        "denial_notice": {
            "claim_id": "CLM-RECIPE-99",
            "patient_name": "Eleanor Vance",
            "billed_cpt": "71045",
            "billed_icd10": "M54.5",
            "denial_code": "CO-50",
            "denial_reason": "Medical necessity not established",
        },
        "clinical_notes": (
            "Classic Italian Lasagna Recipe: Preheat oven to 375 degrees F. In a large skillet, "
            "cook ground beef with chopped onions and garlic until browned. Layer noodles, marinara "
            "sauce, ricotta cheese, and mozzarella. Bake for 45 minutes until bubbling and golden brown."
        ),
    }

    response = client.post("/run", json=recipe_payload)
    assert response.status_code == 200
    data = response.json()

    # EvaluatorAgent MUST REJECT the audit
    assert data["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert data["iterations_count"] == 1

    audit = data["audit_scorecard"]
    assert audit["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert audit["score"] == 0
    assert audit["passed"] is False
    assert (
        audit["critique"]
        == "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    )
    assert audit["critique_points"] == [
        "The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation."
    ]

    # Must NOT proceed to generate an approved appeal package
    assert data["appeal_package"]["appeal_letter"].startswith("REJECTED:")
    assert len(data["appeal_package"]["statutory_citations"]) == 0


def test_run_endpoint_rejected_scanned_pdf_without_text():
    # PDF fallback text notice
    scanned_pdf_payload = {
        "request_id": "REQ-SCAN-001",
        "denial_notice": {
            "claim_id": "CLM-SCAN-01",
            "billed_cpt": "99244",
            "denial_code": "CO-16",
        },
        "clinical_notes": (
            "[Notice: No selectable text stream found in scan.pdf. "
            "If this is a scanned document, OCR is recommended. "
            "Please verify or paste the clinical encounter text manually.]"
        ),
    }

    response = client.post("/run", json=scanned_pdf_payload)
    assert response.status_code == 200
    data = response.json()

    assert data["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert data["audit_scorecard"]["score"] == 0
    assert data["audit_scorecard"]["status"] == "REJECTED_NON_CLINICAL_DOCUMENT"
    assert data["audit_scorecard"]["passed"] is False

