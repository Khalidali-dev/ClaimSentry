"""ClaimSentry FastAPI application entrypoint alias.
Re-exports `app` from `run.py` to support `uvicorn main:app` as well as `uvicorn run:app`.
"""

from run import app

__all__ = ["app"]

if __name__ == "__main__":
    import os
    import uvicorn
    port = int(os.getenv("PORT", "7860"))
    host = os.getenv("HOST", "0.0.0.0")
    print(f"Starting ClaimSentry server on {host}:{port}...")
    uvicorn.run("run:app", host=host, port=port, reload=False)
