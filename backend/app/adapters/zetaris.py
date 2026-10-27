import csv
import os
import uuid
from typing import Any, Dict, List, Optional
import requests
from dotenv import load_dotenv

from app.tracing import trace_event

load_dotenv()

CSV_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "data",
    "mock_billing_rules.csv",
)
if not os.path.exists(CSV_PATH):
    alt_paths = [
        os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "backend", "data", "mock_billing_rules.csv"),
        os.path.join(os.getcwd(), "backend", "data", "mock_billing_rules.csv"),
        os.path.join(os.getcwd(), "data", "mock_billing_rules.csv"),
    ]
    for p in alt_paths:
        if os.path.exists(p):
            CSV_PATH = p
            break


class ZetarisClient:
    """Enterprise Data Virtualization Adapter connecting to Zetaris REST API.

    Queries federated clinical billing rules, LCD guidelines, and statutory precedents.
    Gracefully falls back to mock_billing_rules.csv if SAMPLE_MODE=true or connection fails,
    ensuring zero unhandled network crashes.
    """

    def __init__(
        self,
        base_url: Optional[str] = None,
        api_key: Optional[str] = None,
        org_id: Optional[str] = None,
    ):
        self.base_url = (base_url or os.getenv("ZETARIS_REST_URL", "http://localhost:8888/api/v1.0")).rstrip("/")
        self.api_key = api_key or os.getenv("ZETARIS_API_KEY", "local_token")
        self.org_id = org_id or os.getenv("ZETARIS_ORG_ID", "1")

    def query_billing_rules(
        self,
        cpt_code: str,
        denial_code: Optional[str] = None,
        trace_id: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """Queries billing guidelines for a given CPT code and optional denial reason code."""
        sql = f"SELECT * FROM healthcare_lakehouse.billing_rules WHERE cpt_code = '{cpt_code}'"
        if denial_code:
            sql += f" AND denial_code = '{denial_code}'"

        return self.run_query(sql, trace_id=trace_id, fallback_cpt=cpt_code, fallback_denial=denial_code)

    def run_query(
        self,
        sql_query: str,
        trace_id: Optional[str] = None,
        fallback_cpt: Optional[str] = None,
        fallback_denial: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """Executes a SQL query against Zetaris endpoint with full audit headers,

        falling back to local structured CSV if connection fails or container is unreachable.
        """
        request_uuid = str(uuid.uuid4())
        tid = trace_id or request_uuid

        endpoint = f"{self.base_url}/sql-editor/sqls/run"
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "X-Org-ID": str(self.org_id),
            "X-Request-ID": request_uuid,
            "Content-Type": "application/json",
        }
        payload = {"sql": sql_query}

        try:
            response = requests.post(endpoint, json=payload, headers=headers, timeout=2.5)
            if response.status_code == 200:
                data = response.json()
                rows = data.get("rows") or data.get("data") or []
                trace_event(
                    trace_id=tid,
                    agent_name="ZetarisAdapter",
                    action="EXECUTE_FEDERATED_SQL",
                    target_agent="ZetarisEngine",
                    status="SUCCESS",
                    details={"endpoint": endpoint, "rows_returned": len(rows), "request_uuid": request_uuid},
                )
                return rows
            else:
                trace_event(
                    trace_id=tid,
                    agent_name="ZetarisAdapter",
                    action="ZETARIS_API_HTTP_ERROR",
                    target_agent="ZetarisEngine",
                    status="FALLBACK_TRIGGERED",
                    details={"status_code": response.status_code, "msg": response.text[:200]},
                )
        except Exception as e:
            trace_event(
                trace_id=tid,
                agent_name="ZetarisAdapter",
                action="ZETARIS_CONNECTION_FAILURE",
                target_agent="ZetarisEngine",
                status="FALLBACK_TRIGGERED",
                details={"error": str(e), "endpoint": endpoint, "msg": "Docker container unreachable; falling back to local lakehouse dataset."},
            )

        # Fallback execution using structured mock billing dataset
        results = self._query_csv_dataset(fallback_cpt, fallback_denial)
        trace_event(
            trace_id=tid,
            agent_name="ZetarisAdapter",
            action="MOCK_LAKEHOUSE_QUERY",
            target_agent="HMEMEngine",
            status="SUCCESS",
            details={
                "source": "mock_billing_rules.csv",
                "cpt_code": fallback_cpt,
                "denial_code": fallback_denial,
                "matched_records": len(results),
            },
        )
        return results

    def _query_csv_dataset(
        self,
        cpt_code: Optional[str] = None,
        denial_code: Optional[str] = None,
    ) -> List[Dict[str, Any]]:
        """Parses local mock_billing_rules.csv to resolve guidelines and statutory rules."""
        matched: List[Dict[str, Any]] = []
        if not os.path.exists(CSV_PATH):
            return matched

        try:
            with open(CSV_PATH, mode="r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    cpt_match = True
                    denial_match = True

                    if cpt_code and row.get("cpt_code") != str(cpt_code):
                        cpt_match = False
                    if denial_code and row.get("denial_code") != str(denial_code):
                        denial_match = False

                    if cpt_match and (denial_match or not denial_code):
                        item = dict(row)
                        if "valid_icd10_codes" in item and item["valid_icd10_codes"]:
                            item["valid_icd10_list"] = [code.strip() for code in item["valid_icd10_codes"].split("|")]
                        matched.append(item)
        except Exception as e:
            trace_event(
                trace_id="system-bootstrap",
                agent_name="ZetarisAdapter",
                action="CSV_READ_ERROR",
                status="ERROR",
                details={"error": str(e), "path": CSV_PATH},
            )

        return matched
