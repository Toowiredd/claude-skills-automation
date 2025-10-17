#!/usr/bin/env bash
# SessionEnd Hook - Save session state and backup
# Fires when session ends
# Install to: ~/.config/claude-code/hooks/session-end.sh

set -euo pipefail

CURRENT_SESSION="/home/toowired/.claude-sessions/current.json"
BACKUP_DIR="/home/toowired/.claude-memories/backups"
LOG_FILE="/home/toowired/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [SessionEnd] $1" >> "$LOG_FILE"
}

main() {
  log "Session ending..."

  # Read hook input from stdin
  HOOK_INPUT=$(cat)
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
  SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

  PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")
  TIMESTAMP=$(date -Iseconds)

  log "Saving session: $PROJECT_NAME ($SESSION_ID)"

  # Save session state
  PROJECT_SESSION="/home/toowired/.claude-sessions/projects/${PROJECT_NAME}.json"
  mkdir -p "$(dirname "$PROJECT_SESSION")"

  # Extract last user message as "last topic"
  LAST_TOPIC=""
  if [ -f "$TRANSCRIPT_PATH" ]; then
    LAST_TOPIC=$(tail -10 "$TRANSCRIPT_PATH" 2>/dev/null | jq -r 'select(.type == "message" and .role == "user") | .content // empty' 2>/dev/null | head -1 | cut -c1-100 || echo "")
  fi

  # Create session state
  cat > "$PROJECT_SESSION" <<EOF
{
  "project": "$PROJECT_NAME",
  "project_path": "$CWD",
  "last_active": "$TIMESTAMP",
  "last_session_id": "$SESSION_ID",
  "last_topic": "$LAST_TOPIC"
}
EOF

  # Copy to current.json
  cp "$PROJECT_SESSION" "$CURRENT_SESSION" 2>/dev/null || true

  # Backup transcript
  if [ -f "$TRANSCRIPT_PATH" ]; then
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/session-$(date +%Y%m%d-%H%M%S).jsonl"
    cp "$TRANSCRIPT_PATH" "$BACKUP_FILE"
    log "Transcript backed up to: $BACKUP_FILE"
  fi

  log "Session saved successfully"
  exit 0
}

main
