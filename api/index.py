"""ClaimSentry FastAPI Serverless Handler for Vercel / AWS Lambda.
Wraps the core ClaimSentry FastAPI application using Mangum to provide
a robust serverless entrypoint alongside the Flutter web frontend.
"""

import os
import sys

# Ensure backend and project root directories are in sys.path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(CURRENT_DIR)
BACKEND_DIR = os.path.join(PROJECT_ROOT, "backend")

if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

# Set serverless environment defaults if not explicitly set
if "SAMPLE_MODE" not in os.environ:
    os.environ["SAMPLE_MODE"] = "true"

from mangum import Mangum
from run import app

# Wrap the FastAPI application with Mangum for Vercel serverless execution
handler = Mangum(app, lifespan="off")

__all__ = ["app", "handler"]

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "7860"))
    host = os.getenv("HOST", "0.0.0.0")
    print(f"Starting ClaimSentry API server on {host}:{port}...")
    uvicorn.run(app, host=host, port=port)
