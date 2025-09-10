# Multi-stage CI/CD Docker image
FROM python:3.11-slim as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install Docker CLI
RUN curl -fsSL https://get.docker.com | sh

# Install act (GitHub Actions runner)
RUN curl https://raw.githubusercontent.com/nektos/act/master/install.sh | bash

# Python CI stage
FROM base as python-ci
WORKDIR /workspace
COPY backend/requirements.txt ./backend/
RUN cd backend && pip install -r requirements.txt
RUN pip install pytest-xdist safety black isort flake8 mypy

# Node.js CI stage  
FROM base as node-ci
WORKDIR /workspace
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm ci

# Full CI stage
FROM base as ci-full
WORKDIR /workspace

# Install Python dependencies
COPY backend/requirements.txt ./backend/
RUN cd backend && pip install -r requirements.txt
RUN pip install pytest-xdist safety black isort flake8 mypy

# Install Node.js dependencies
COPY frontend/package*.json ./frontend/
RUN cd frontend && npm ci

# Install additional CI tools
RUN pip install pre-commit bandit semgrep
RUN npm install -g @eslint/config-inspector audit-ci

# Copy application code
COPY . .

# Set up pre-commit hooks
RUN pre-commit install

# Default command
CMD ["./scripts/local-ci.sh", "full"]