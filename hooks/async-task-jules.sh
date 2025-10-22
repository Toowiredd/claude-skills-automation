#!/usr/bin/env bash
# Jules CLI Integration Hook
# Triggers async tasks for long-running operations

set -euo pipefail

TASK_DESCRIPTION="$1"
REPO_PATH="${2:-$PWD}"

LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [Jules] $1" >> "$LOG_FILE"
}

main() {
  # Check if Jules CLI is installed
  if ! command -v jules &> /dev/null; then
    log "Jules CLI not installed - skipping async task"
    echo "⚠️  Jules CLI not installed. Install with: npm install -g @google/jules-cli"
    exit 0
  fi

  log "Triggering Jules async task: $TASK_DESCRIPTION"

  # Trigger Jules task via CLI
  TASK_RESPONSE=$(jules task create \
    --description "$TASK_DESCRIPTION" \
    --repo "$REPO_PATH" \
    --auto-pr true \
    --format json 2>&1) || {
      log "Jules task creation failed: $TASK_RESPONSE"
      echo "⚠️  Jules task creation failed. Check logs."
      exit 1
    }

  TASK_ID=$(echo "$TASK_RESPONSE" | jq -r '.task_id')

  if [[ -z "$TASK_ID" || "$TASK_ID" == "null" ]]; then
    log "Could not parse task ID from Jules response"
    exit 1
  fi

  log "Jules task created: $TASK_ID"

  # Monitor in background
  (
    while true; do
      sleep 30
      STATUS_RESPONSE=$(jules task status "$TASK_ID" --format json 2>/dev/null) || continue

      STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')

      if [[ "$STATUS" == "completed" ]]; then
        PR_URL=$(echo "$STATUS_RESPONSE" | jq -r '.pr_url // "No PR created"')
        log "Jules task complete. PR: $PR_URL"

        # Send desktop notification if notify-send available
        if command -v notify-send &> /dev/null; then
          notify-send "Jules Task Complete" "Review PR: $PR_URL" --icon=dialog-information
        fi

        echo "✅ Jules completed task. Review PR: $PR_URL" >> /tmp/jules-status-$TASK_ID.log
        break
      elif [[ "$STATUS" == "failed" ]]; then
        log "Jules task failed: $TASK_ID"
        if command -v notify-send &> /dev/null; then
          notify-send "Jules Task Failed" "Task ID: $TASK_ID" --icon=dialog-error
        fi
        break
      fi
    done
  ) &

  echo "🤖 Jules working on: $TASK_DESCRIPTION"
  echo "📋 Task ID: $TASK_ID"
  echo "⏳ Monitoring in background..."
  echo ""
  echo "Check status: jules task status $TASK_ID"
  echo "View dashboard: jules /remote"
}

main
