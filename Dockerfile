# ClaimSentry: Autonomous Agentic Reasoning for Healthcare Claim Denial Auditing & Appeal Generation
# Open Agent Hackathon 2026 - Track 03: Reasoning Architecture
# Root Dockerfile for Direct Hugging Face Spaces GitHub Repository Linking

FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered output
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=7860

WORKDIR /app

# Install system dependencies (curl for healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set up a non-root user with UID 1000 (standard requirement for Hugging Face Spaces)
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

WORKDIR $HOME/app

# Install Python dependencies first for optimal Docker layer caching
COPY --chown=user backend/requirements.txt requirements.txt
RUN pip install --no-cache-dir --user -U pip && \
    pip install --no-cache-dir --user -r requirements.txt

# Copy backend application source code, data, examples, and tests
COPY --chown=user backend/app/ app/
COPY --chown=user backend/data/ data/
COPY --chown=user backend/input_examples/ input_examples/
COPY --chown=user backend/output_examples/ output_examples/
COPY --chown=user backend/tests/ tests/
COPY --chown=user backend/run.py .
COPY --chown=user backend/main.py .
COPY --chown=user backend/.env.example .env

# Expose default Hugging Face Spaces HTTP port
EXPOSE 7860

# Healthcheck targeting FastAPI /health endpoint on port 7860
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:7860/health || exit 1

# Launch FastAPI with uvicorn listening on all interfaces at port 7860
CMD ["uvicorn", "run:app", "--host", "0.0.0.0", "--port", "7860"]
