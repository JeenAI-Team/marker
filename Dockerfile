FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install poetry

# Configure Poetry: Don't create a virtual environment, install dependencies system-wide
RUN poetry config virtualenvs.create false

# Set working directory
WORKDIR /app

# Copy Poetry files
COPY pyproject.toml poetry.lock* ./

# Install dependencies
RUN poetry install --with dev --no-interaction --no-ansi

# Copy the rest of the application
COPY . .

# Create uploads directory
RUN mkdir -p ./uploads

# Expose the port the server runs on
EXPOSE 8000

# Run the server
CMD ["poetry", "run", "python", "marker_server.py"]

