FROM python:3.11-slim

# Install only essential build tools and libraries for lxml
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libxml2-dev \
        libxslt1-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

# Configure Poetry
RUN poetry config virtualenvs.create false

# Set working directory
WORKDIR /app

# Copy Poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies
RUN poetry install --no-interaction --no-ansi

# Copy application code
COPY . .

# Create uploads directory
RUN mkdir -p ./uploads

# Expose port
EXPOSE 8000

# Run server
CMD ["poetry", "run", "python", "marker_server.py"]
