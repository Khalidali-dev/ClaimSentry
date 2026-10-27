"""ClaimSentry FastAPI application entrypoint alias.
Re-exports `app` from `run.py` to support `uvicorn main:app` as well as `uvicorn run:app`.
"""

from run import app

__all__ = ["app"]
