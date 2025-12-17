FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libcairo2 \
    libcairo2-dev \
    libpango-1.0-0 \
    libpango1.0-dev \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libgdk-pixbuf2.0-dev \
    shared-mime-info \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --upgrade pip && pip install poetry

# Configure Poetry: Don't create a virtual environment, install dependencies system-wide
RUN poetry config virtualenvs.create false

# Set working directory
WORKDIR /app

# Copy Poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies (use --no-root to avoid installing the package itself until we copy all files)
RUN if [ -f poetry.lock ]; then \
        poetry install --with dev --no-interaction --no-ansi --no-root; \
    else \
        poetry lock --no-update && poetry install --with dev --no-interaction --no-ansi --no-root; \
    fi

# Copy the rest of the application
COPY . .

# Install the package itself (dependencies are already installed, so this is fast)
RUN poetry install --with dev --no-interaction --no-ansi

# Create uploads directory
RUN mkdir -p ./uploads

# Expose the port the server runs on
EXPOSE 8000

# Run the server
CMD ["poetry", "run", "python", "marker_server.py"]

