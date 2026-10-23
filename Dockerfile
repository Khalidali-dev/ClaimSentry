# ClaimSentry: Autonomous Agentic Reasoning for Healthcare Claim Denial Auditing & Appeal Generation
# Open Agent Hackathon 2026 - Track 03: Reasoning Architecture

FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered logging
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code, data, examples, and tests
COPY app/ app/
COPY data/ data/
COPY input_examples/ input_examples/
COPY output_examples/ output_examples/
COPY tests/ tests/
COPY run.py .
COPY .env.example .env

# Expose API port
EXPOSE 8000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Launch the FastAPI application
CMD ["python", "run.py"]
