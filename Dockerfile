# ─────────────────────────────────────────────
# Stage 1: Build the React frontend
# ─────────────────────────────────────────────
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Install deps first for better layer caching
COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build
# Output: /app/frontend/dist/


# ─────────────────────────────────────────────
# Stage 2: Production image — FastAPI + static
# ─────────────────────────────────────────────
FROM python:3.13-slim

# libpq-dev is required by psycopg2-binary at runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/backend

# Install Python dependencies
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend source code
COPY backend/ ./

# Copy built frontend into backend/static
# main.py already detects this directory and serves it
COPY --from=frontend-builder /app/frontend/dist ./static

# Render injects $PORT at runtime (usually 10000)
EXPOSE 10000

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-10000}"]
