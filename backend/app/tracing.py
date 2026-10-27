import json
import os
import sys
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

LOGS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "logs")
os.makedirs(LOGS_DIR, exist_ok=True)

# Generate timestamped trace filename
SESSION_TIMESTAMP = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
ACTIVE_TRACE_FILE = os.path.join(LOGS_DIR, f"trace_{SESSION_TIMESTAMP}.jsonl")


def format_iso_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat()


def get_active_trace_file() -> str:
    return ACTIVE_TRACE_FILE


def trace_event(
    trace_id: str,
    agent_name: str,
    action: str,
    target_agent: Optional[str] = None,
    model: Optional[str] = None,
    status: str = "SUCCESS",
    details: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """Records a structured JSONL execution trace capturing agent reasoning steps,

    actions, target interactions, model metadata, and status to logs/trace_<timestamp>.jsonl and stdout.
    """
    record: Dict[str, Any] = {
        "timestamp": format_iso_timestamp(),
        "trace_id": str(trace_id),
        "agent_name": agent_name,
        "action": action,
        "target_agent": target_agent if target_agent else "None",
        "model": model if model else "meterless/nightshift",
        "status": status,
        "details": details or {},
    }

    serialized = json.dumps(record)

    # Write to timestamped JSONL log file
    try:
        with open(ACTIVE_TRACE_FILE, "a", encoding="utf-8") as f:
            f.write(serialized + "\n")
    except Exception as e:
        sys.stderr.write(f"[ClaimSentry Tracing Error] Failed to write trace to file: {e}\n")

    # Output to stdout
    sys.stdout.write(
        f"[TRACE] [{record['agent_name']}] -> [{record['target_agent']}] | "
        f"{record['action']} | {record['status']} | model={record['model']}\n"
    )
    sys.stdout.flush()

    return record


def get_traces_for_id(trace_id: str, file_path: Optional[str] = None) -> List[Dict[str, Any]]:
    """Retrieves all trace events recorded for a given trace_id."""
    results: List[Dict[str, Any]] = []
    target_file = file_path or ACTIVE_TRACE_FILE

    # If active file doesn't have it or is empty, check all trace_*.jsonl files in logs/
    files_to_check = [target_file] if os.path.exists(target_file) else []
    if os.path.exists(LOGS_DIR):
        for fname in sorted(os.listdir(LOGS_DIR), reverse=True):
            if fname.startswith("trace_") and fname.endswith(".jsonl"):
                fpath = os.path.join(LOGS_DIR, fname)
                if fpath not in files_to_check:
                    files_to_check.append(fpath)

    for fpath in files_to_check:
        try:
            with open(fpath, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        item = json.loads(line)
                        if item.get("trace_id") == str(trace_id):
                            results.append(item)
                    except json.JSONDecodeError:
                        continue
            if results:
                break
        except Exception as e:
            sys.stderr.write(f"[ClaimSentry Tracing Error] Failed to read traces from {fpath}: {e}\n")

    return results
