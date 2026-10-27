"""ClaimSentry FastAPI application entrypoint alias inside app/.
Re-exports `app` from `run.py` to support `uvicorn app.main:app`.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from run import app

__all__ = ["app"]
