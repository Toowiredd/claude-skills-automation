#!/usr/bin/env bash
# SessionEnd Hook - Save session state and backup
# Fires when session ends
# Install to: ~/.config/claude-code/hooks/session-end.sh

set +e  # Don't exit on error - graceful degradation

CURRENT_SESSION="$HOME/.claude-sessions/current.json"
BACKUP_DIR="$HOME/.claude-memories/backups"
LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [SessionEnd] $1" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
  echo "[$(date -Iseconds)] [SessionEnd] ERROR: $1" >&2
  log "ERROR: $1"
}

# Safe directory creation
ensure_dirs() {
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  mkdir -p "$BACKUP_DIR" 2>/dev/null || true
  mkdir -p "$(dirname "$CURRENT_SESSION")" 2>/dev/null || true
}

# Safe file write with atomic operation
safe_write_json() {
  local file="$1"
  local content="$2"
  local temp_file="${file}.tmp.$$"

  # Write to temp file
  if ! echo "$content" > "$temp_file" 2>/dev/null; then
    log_error "Failed to write temporary file: $temp_file"
    rm -f "$temp_file" 2>/dev/null
    return 1
  fi

  # Validate JSON
  if ! echo "$content" | jq empty 2>/dev/null; then
    log_error "Invalid JSON, not writing to: $file"
    rm -f "$temp_file" 2>/dev/null
    return 1
  fi

  # Atomic move
  if ! mv "$temp_file" "$file" 2>/dev/null; then
    log_error "Failed to move temp file to: $file"
    rm -f "$temp_file" 2>/dev/null
    return 1
  fi

  return 0
}

main() {
  ensure_dirs
  log "Session ending..."

  # Read hook input from stdin with error handling
  HOOK_INPUT=$(cat 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$HOOK_INPUT" ]; then
    log_error "Failed to read hook input from stdin"
    exit 0
  fi

  # Parse input with safe defaults
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
  SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

  PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")
  TIMESTAMP=$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")

  log "Saving session: $PROJECT_NAME ($SESSION_ID)"

  # Save session state
  PROJECT_SESSION="$HOME/.claude-sessions/projects/${PROJECT_NAME}.json"
  mkdir -p "$(dirname "$PROJECT_SESSION")" 2>/dev/null

  if [ $? -ne 0 ]; then
    log_error "Failed to create project session directory"
  fi

  # Extract last user message as "last topic" with error handling
  LAST_TOPIC=""
  if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    LAST_TOPIC=$(tail -10 "$TRANSCRIPT_PATH" 2>/dev/null | \
      jq -r 'select(.type == "message" and .role == "user") | .content // empty' 2>/dev/null | \
      head -1 | cut -c1-100 2>/dev/null || echo "")

    if [ $? -ne 0 ]; then
      log_error "Failed to extract last topic from transcript"
      LAST_TOPIC=""
    fi
  else
    log_error "Transcript path not found: $TRANSCRIPT_PATH"
  fi

  # Create session state JSON
  SESSION_JSON=$(cat <<EOF
{
  "project": "$PROJECT_NAME",
  "project_path": "$CWD",
  "last_active": "$TIMESTAMP",
  "last_session_id": "$SESSION_ID",
  "last_topic": "$LAST_TOPIC"
}
EOF
)

  # Write session state with validation
  if safe_write_json "$PROJECT_SESSION" "$SESSION_JSON"; then
    log "Session state saved to: $PROJECT_SESSION"
  else
    log_error "Failed to save session state, but continuing"
  fi

  # Copy to current.json with error handling
  if [ -f "$PROJECT_SESSION" ]; then
    if ! cp "$PROJECT_SESSION" "$CURRENT_SESSION" 2>/dev/null; then
      log_error "Failed to copy session to current.json"
    fi
  fi

  # Backup transcript with error handling
  if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    if [ ! -d "$BACKUP_DIR" ]; then
      mkdir -p "$BACKUP_DIR" 2>/dev/null
      if [ $? -ne 0 ]; then
        log_error "Failed to create backup directory: $BACKUP_DIR"
        exit 0
      fi
    fi

    BACKUP_FILE="$BACKUP_DIR/session-$(date +%Y%m%d-%H%M%S 2>/dev/null || echo "backup").jsonl"

    if cp "$TRANSCRIPT_PATH" "$BACKUP_FILE" 2>/dev/null; then
      log "Transcript backed up to: $BACKUP_FILE"
    else
      log_error "Failed to backup transcript to: $BACKUP_FILE"
    fi
  else
    log "No transcript to backup"
  fi

  log "Session end processing complete"
  exit 0
}

main
