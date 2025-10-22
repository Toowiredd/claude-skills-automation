#!/usr/bin/env bash
# Docker Pro Integration Hook
# Runs tests in isolated Docker container

set -euo pipefail

PROJECT_DIR="${1:-$PWD}"
TEST_COMMAND="${2:-npm test}"

LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [DockerTest] $1" >> "$LOG_FILE"
}

main() {
  # Check if Docker is installed
  if ! command -v docker &> /dev/null; then
    log "Docker not installed - skipping isolated testing"
    echo "⚠️  Docker not installed. Install Docker Desktop for isolated testing."
    exit 0
  fi

  log "Creating test container for $PROJECT_DIR..."
  echo "🐳 Creating isolated test environment..."

  # Detect project type
  if [[ -f "$PROJECT_DIR/package.json" ]]; then
    DOCKERFILE_CONTENT=$(cat <<'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --quiet
COPY . .
EOF
)
  elif [[ -f "$PROJECT_DIR/requirements.txt" ]]; then
    DOCKERFILE_CONTENT=$(cat <<'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EOF
)
  else
    log "Unknown project type - no package.json or requirements.txt"
    echo "⚠️  Unknown project type. Add package.json or requirements.txt."
    exit 0
  fi

  # Build test image
  IMAGE_NAME="test-$(basename $PROJECT_DIR)-$(date +%s)"

  echo "$DOCKERFILE_CONTENT" | docker build -t "$IMAGE_NAME" -f- "$PROJECT_DIR" 2>&1 | \
    grep -v "DEPRECATED" || {
      log "Docker build failed"
      echo "❌ Docker build failed"
      exit 1
    }

  log "Running tests in container..."
  echo "🧪 Running tests in isolated container..."

  # Run tests in container
  docker run --rm "$IMAGE_NAME" $TEST_COMMAND
  TEST_EXIT_CODE=$?

  # Cleanup
  docker rmi "$IMAGE_NAME" > /dev/null 2>&1

  if [[ $TEST_EXIT_CODE -eq 0 ]]; then
    log "Tests passed in isolation ✅"
    echo "✅ All tests passed in isolated environment"
  else
    log "Tests failed in isolation (exit code: $TEST_EXIT_CODE)"
    echo "❌ Tests failed (exit code: $TEST_EXIT_CODE)"
  fi

  exit $TEST_EXIT_CODE
}

main
