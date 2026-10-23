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
    assert "sample_mode" in data


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
