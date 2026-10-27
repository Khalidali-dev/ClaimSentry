"""ClaimSentry FastAPI application entrypoint alias inside app/.
Re-exports `app` from `run.py` to support `uvicorn app.main:app`.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from run import app

__all__ = ["app"]

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "7860"))
    host = os.getenv("HOST", "0.0.0.0")
    print(f"Starting ClaimSentry server on {host}:{port}...")
    uvicorn.run("run:app", host=host, port=port, reload=False)
