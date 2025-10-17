#!/usr/bin/env bash
# Pre-Commit Copilot Review Hook
# Uses GitHub Copilot CLI to review staged changes before commit

set -euo pipefail

LOG_FILE="/home/toowired/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [CopilotReview] $1" >> "$LOG_FILE"
}

main() {
  # Check if Copilot CLI is installed
  if ! command -v copilot &> /dev/null; then
    log "Copilot CLI not installed - skipping review"
    exit 0
  fi

  # Get staged changes
  STAGED_DIFF=$(git diff --cached)

  if [[ -z "$STAGED_DIFF" ]]; then
    log "No staged changes to review"
    exit 0
  fi

  log "Reviewing staged changes with Copilot..."

  # Ask Copilot to review the changes
  REVIEW_RESPONSE=$(copilot \
    --allow-tool 'shell(git*)' \
    "Review these staged git changes for potential issues, bugs, or improvements. Focus on: security issues, performance problems, code quality, and best practices. Here are the changes: $(git diff --cached --stat)" \
    2>&1) || {
      log "Copilot review failed"
      exit 0  # Don't block commit on review failure
    }

  log "Copilot review complete"

  # Show review to user
  echo "📝 GitHub Copilot Code Review:"
  echo ""
  echo "$REVIEW_RESPONSE"
  echo ""
  echo "---"
  echo "Continue with commit? (Ctrl+C to cancel)"

  # Brief pause to allow reading
  sleep 2

  exit 0
}

main
