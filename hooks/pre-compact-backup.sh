#!/usr/bin/env bash
# PreCompact Hook - Backup transcript before context compaction
# Fires before Claude Code compresses conversation context
# Install to: ~/.config/claude-code/hooks/pre-compact-backup.sh

set +e  # Don't exit on error - graceful degradation

BACKUP_DIR="$HOME/.claude-memories/pre-compact-backups"
LOG_FILE="$HOME/.claude-memories/automation.log"
DECISIONS_LOG="$HOME/.claude-memories/pre-compact-decisions.log"

log() {
  echo "[$(date -Iseconds)] [PreCompact] $1" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
  echo "[$(date -Iseconds)] [PreCompact] ERROR: $1" >&2
  log "ERROR: $1"
}

# Safe directory creation
ensure_dirs() {
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  mkdir -p "$BACKUP_DIR" 2>/dev/null || true
  mkdir -p "$(dirname "$DECISIONS_LOG")" 2>/dev/null || true
}

# Safe file copy with validation
safe_copy_file() {
  local src="$1"
  local dest="$2"

  if [ ! -f "$src" ]; then
    log_error "Source file does not exist: $src"
    return 1
  fi

  if ! cp "$src" "$dest" 2>/dev/null; then
    log_error "Failed to copy $src to $dest"
    return 1
  fi

  # Verify copy
  if [ ! -f "$dest" ]; then
    log_error "Destination file not created: $dest"
    return 1
  fi

  return 0
}

main() {
  ensure_dirs
  log "Pre-compact backup triggered"

  # Read hook input from stdin with error handling
  HOOK_INPUT=$(cat 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$HOOK_INPUT" ]; then
    log_error "Failed to read hook input from stdin"
    exit 0
  fi

  # Parse transcript path with error handling
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
  if [ $? -ne 0 ]; then
    log_error "Failed to parse transcript_path from hook input"
    exit 0
  fi

  if [ -z "$TRANSCRIPT_PATH" ]; then
    log "No transcript path provided in hook input"
    exit 0
  fi

  if [ ! -f "$TRANSCRIPT_PATH" ]; then
    log_error "Transcript file not found: $TRANSCRIPT_PATH"
    exit 0
  fi

  # Generate backup filename with error handling
  BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S 2>/dev/null || echo "backup")
  BACKUP_FILE="$BACKUP_DIR/pre-compact-${BACKUP_TIMESTAMP}.jsonl"

  # Verify backup directory exists
  if [ ! -d "$BACKUP_DIR" ]; then
    log_error "Backup directory does not exist: $BACKUP_DIR"
    exit 0
  fi

  # Create backup with validation
  if safe_copy_file "$TRANSCRIPT_PATH" "$BACKUP_FILE"; then
    log "Transcript backed up to: $BACKUP_FILE"
  else
    log_error "Failed to backup transcript, but continuing"
  fi

  # Extract important context before compaction with error handling
  DECISIONS=$(jq -r 'select(.content | test("decided|using|chose"; "i")) | .content' "$TRANSCRIPT_PATH" 2>/dev/null | tail -5 2>/dev/null || echo "")

  if [ $? -ne 0 ]; then
    log_error "Failed to extract decisions from transcript"
  elif [ -n "$DECISIONS" ]; then
    # Write decisions to log with error handling
    {
      echo "[$(date -Iseconds)] Pre-compact extracted decisions:"
      echo "$DECISIONS"
      echo "---"
    } >> "$DECISIONS_LOG" 2>/dev/null || log_error "Failed to write decisions to log"

    log "Extracted $(echo "$DECISIONS" | wc -l) decisions from transcript"
  else
    log "No decisions found in transcript"
  fi

  log "Pre-compact backup complete"
  exit 0
}

main
