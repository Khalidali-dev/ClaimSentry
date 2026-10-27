import json
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional


class HMEMEngine:
    """Meterless H-MEM: Hierarchical Working & Meta-Memory Engine.

    Maintains 3 distinct memory tiers across the multi-agent reasoning loop:
      1. Working / Episodic Memory: Current claim under audit, patient data, raw EHR clinical notes, and dynamic working facts.
      2. Domain Memory: ICD-10 and CPT coding precedents, CMS LCD guidelines, and payer policy rules.
      3. Critique Memory: Evaluator compliance feedback, audit scorecards, and multi-round iteration history.
    """

    def __init__(self, request_id: str):
        self.request_id = request_id
        self.created_at = datetime.now(timezone.utc).isoformat()

        # Tier 1: Working / Episodic Memory
        self.working_memory: Dict[str, Any] = {
            "claim_id": None,
            "patient_info": {},
            "denial_notice": {},
            "clinical_facts": {},
            "raw_clinical_notes": "",
            "extracted_entities": {
                "cpt_codes": [],
                "icd10_codes": [],
                "physician_names": [],
                "dates_of_service": [],
            },
            "dynamic_facts": {},
        }

        # Tier 2: Domain Memory (Coding precedents & payer policies)
        self.domain_memory: Dict[str, Any] = {
            "cpt_rules": [],
            "applicable_statutes": [],
            "appeal_remedies": [],
            "payer_specific_guidelines": {},
        }

        # Tier 3: Critique Memory (Evaluator feedback & iteration history)
        self.critique_memory: List[Dict[str, Any]] = []

    # Aliases for backward compatibility
    @property
    def l1_working_memory(self) -> Dict[str, Any]:
        return self.working_memory

    @property
    def l2_policy_precedents(self) -> Dict[str, Any]:
        return self.domain_memory

    @property
    def l3_iteration_history(self) -> List[Dict[str, Any]]:
        return self.critique_memory

    def initialize_claim(
        self,
        denial_notice: Dict[str, Any],
        clinical_notes: str,
    ) -> None:
        """Initializes working/episodic memory with parsed denial notice and raw clinical EHR notes."""
        self.working_memory["denial_notice"] = denial_notice
        self.working_memory["claim_id"] = denial_notice.get("claim_id")
        self.working_memory["patient_info"] = {
            "name": denial_notice.get("patient_name"),
            "dob": denial_notice.get("patient_dob"),
            "member_id": denial_notice.get("member_id"),
            "payer": denial_notice.get("payer_name"),
        }
        self.working_memory["raw_clinical_notes"] = clinical_notes

        # Seed initial entities from denial notice
        billed_cpt = denial_notice.get("billed_cpt")
        billed_icd = denial_notice.get("billed_icd10")
        dos = denial_notice.get("date_of_service")

        if billed_cpt:
            self.working_memory["extracted_entities"]["cpt_codes"].append(billed_cpt)
        if billed_icd:
            self.working_memory["extracted_entities"]["icd10_codes"].append(billed_icd)
        if dos:
            self.working_memory["extracted_entities"]["dates_of_service"].append(dos)

    def store_working_fact(self, key: str, value: Any) -> None:
        """Stores or updates a specific working fact in working/episodic memory."""
        self.working_memory["dynamic_facts"][key] = value

    def get_working_memory(self) -> Dict[str, Any]:
        """Returns the current working/episodic memory."""
        return self.working_memory

    def get_episodic_memory(self) -> Dict[str, Any]:
        """Returns episodic memory (alias)."""
        return self.working_memory

    def store_policy_precedents(
        self,
        cpt_rules: List[Dict[str, Any]],
        statutes: Optional[List[str]] = None,
        remedies: Optional[List[str]] = None,
    ) -> None:
        """Registers verified billing guidelines, LCD coverage policies, and

        statutory regulations into domain memory.
        """
        self.domain_memory["cpt_rules"] = cpt_rules
        if statutes:
            self.domain_memory["applicable_statutes"] = list(
                set(self.domain_memory["applicable_statutes"] + statutes)
            )
        if remedies:
            self.domain_memory["appeal_remedies"] = list(
                set(self.domain_memory["appeal_remedies"] + remedies)
            )

    def store_domain_precedents(
        self,
        cpt_rules: List[Dict[str, Any]],
        statutes: Optional[List[str]] = None,
        remedies: Optional[List[str]] = None,
    ) -> None:
        """Alias for store_policy_precedents."""
        self.store_policy_precedents(cpt_rules, statutes, remedies)

    def get_domain_memory(self) -> Dict[str, Any]:
        """Returns domain memory (ICD-10, CPT precedents, payer policies)."""
        return self.domain_memory

    def get_policy_precedents(self) -> Dict[str, Any]:
        """Alias for get_domain_memory."""
        return self.domain_memory

    def record_iteration(
        self,
        iteration_num: int,
        draft: Dict[str, Any],
        critique: Dict[str, Any],
        status: str,
    ) -> Dict[str, Any]:
        """Appends an evaluation and revision cycle into critique memory."""
        record = {
            "iteration": iteration_num,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "draft_summary": draft.get("summary", ""),
            "draft_package": draft,
            "critique": critique,
            "status": status,
            "passed_audit": critique.get("passed", False),
            "audit_score": critique.get("score", 0),
        }
        self.critique_memory.append(record)
        return record

    def get_critique_memory(self) -> List[Dict[str, Any]]:
        """Returns critique memory (evaluator feedback and iteration history)."""
        return self.critique_memory

    def get_critique_history(self) -> List[Dict[str, Any]]:
        """Alias for get_critique_memory."""
        return self.critique_memory

    def get_latest_iteration(self) -> Optional[Dict[str, Any]]:
        """Returns the most recent critique/iteration record, if any."""
        if self.critique_memory:
            return self.critique_memory[-1]
        return None

    def to_context_prompt(self) -> str:
        """Serializes the hierarchical memory state into a structured prompt context."""
        dn = self.working_memory.get("denial_notice", {})
        cpt_rules = self.domain_memory.get("cpt_rules", [])
        history = self.critique_memory

        critique_summary = "None (Initial Planning Phase)"
        if history:
            latest = history[-1]
            critique_summary = (
                f"Iteration {latest['iteration']} Result: {latest['status']} (Audit Score: {latest['audit_score']}/100)\n"
                f"Critique Directives:\n- " + "\n- ".join(latest['critique'].get("critique_points", ["None"]))
            )

        context_str = f"""### H-MEM HIERARCHICAL CONTEXT
[TIER 1: WORKING / EPISODIC MEMORY - CLAIM FACTS]
- Claim ID: {dn.get('claim_id')}
- Patient: {dn.get('patient_name')} (DOB: {dn.get('patient_dob')}) | Member ID: {dn.get('member_id')}
- Payer: {dn.get('payer_name')}
- Date of Service: {dn.get('date_of_service')}
- Billed CPT: {dn.get('billed_cpt')} ({dn.get('billed_cpt_description', 'N/A')})
- Billed ICD-10: {dn.get('billed_icd10')} ({dn.get('billed_icd10_description', 'N/A')})
- Billed Amount: ${dn.get('billed_amount', 0.00)}
- Denial Code: {dn.get('denial_code')} - {dn.get('denial_reason')}

[TIER 2: DOMAIN MEMORY - POLICY PRECEDENTS & RULES]
- Matched Guidelines: {json.dumps(cpt_rules, indent=2)}
- Statutory Citations: {', '.join(self.domain_memory.get('applicable_statutes', []))}
- Appeal Remedies: {', '.join(self.domain_memory.get('appeal_remedies', []))}

[TIER 3: CRITIQUE MEMORY - EVALUATOR FEEDBACK & ITERATION STATE]
- Prior Critique State:
{critique_summary}
"""
        return context_str

    def summary(self) -> Dict[str, Any]:
        """Provides an executive summary of H-MEM memory state for audit reporting."""
        latest = self.get_latest_iteration()
        return {
            "request_id": self.request_id,
            "created_at": self.created_at,
            "claim_id": self.working_memory.get("claim_id"),
            "denial_code": self.working_memory.get("denial_notice", {}).get("denial_code"),
            "matched_policy_count": len(self.domain_memory.get("cpt_rules", [])),
            "iteration_count": len(self.critique_memory),
            "latest_audit_score": latest["audit_score"] if latest else None,
            "final_status": latest["status"] if latest else "INITIALIZED",
        }
