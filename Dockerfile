FROM python:3.11-slim

# Install only essential build tools and libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libxml2-dev \
        libxslt1-dev \
        libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

# Configure Poetry
RUN poetry config virtualenvs.create false

# Set working directory
WORKDIR /app

# Copy Poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies (server needs dev dependencies for FastAPI/uvicorn)
# Use --no-root first to install deps, then install package after copying code
RUN poetry install --with dev --no-interaction --no-ansi --no-root

# Copy application code
COPY . .

# Install the package itself (deps already installed)
RUN poetry install --with dev --no-interaction --no-ansi

# Create uploads directory
RUN mkdir -p ./uploads

# Expose port
EXPOSE 8000

# Run server
CMD ["poetry", "run", "python", "marker_server.py"]
