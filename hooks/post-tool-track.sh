#!/usr/bin/env bash
# PostToolUse Hook - Track significant file changes
# Fires after Edit or Write tools complete
# Install to: ~/.config/claude-code/hooks/post-tool-track.sh

set +e  # Don't exit on error - graceful degradation

LOG_FILE="$HOME/.claude-memories/automation.log"
CHANGES_LOG="$HOME/.claude-memories/file-changes.log"

log() {
  echo "[$(date -Iseconds)] [PostToolUse] $1" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
  echo "[$(date -Iseconds)] [PostToolUse] ERROR: $1" >&2
  log "ERROR: $1"
}

# Safe directory creation
ensure_dirs() {
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  mkdir -p "$(dirname "$CHANGES_LOG")" 2>/dev/null || true
}

# Safe file path validation
validate_file_path() {
  local file_path="$1"

  if [ -z "$file_path" ]; then
    return 1
  fi

  # Check if path contains suspicious patterns
  if echo "$file_path" | grep -qE '\.\.\/|^\/dev\/|^\/proc\/|^\/sys\/'; then
    log_error "Suspicious file path detected: $file_path"
    return 1
  fi

  return 0
}

main() {
  ensure_dirs
  log "Post tool use triggered"

  # Read hook input from stdin with error handling
  HOOK_INPUT=$(cat 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$HOOK_INPUT" ]; then
    log_error "Failed to read hook input from stdin"
    exit 0
  fi

  # Parse tool information with safe defaults
  TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
  if [ $? -ne 0 ]; then
    log_error "Failed to parse tool_name from hook input"
    exit 0
  fi

  # Only track Edit and Write tools
  if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
    exit 0
  fi

  # Extract tool input with error handling
  TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // empty' 2>/dev/null || echo "")
  if [ $? -ne 0 ]; then
    log_error "Failed to parse tool_input from hook input"
    exit 0
  fi

  # Extract file path with validation
  FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null || echo "")
  if [ $? -ne 0 ]; then
    log_error "Failed to parse file_path from tool_input"
    exit 0
  fi

  if [ -z "$FILE_PATH" ]; then
    log "No file path in tool input, skipping"
    exit 0
  fi

  # Validate file path for security
  if ! validate_file_path "$FILE_PATH"; then
    log_error "Invalid or suspicious file path, skipping: $FILE_PATH"
    exit 0
  fi

  log "File modified: $FILE_PATH"

  # Check if this looks like a significant file with error handling
  case "$FILE_PATH" in
    */DECISIONS.md|*/README.md|*/ARCHITECTURE.md)
      log "Significant file detected: $FILE_PATH"
      echo "[$(date -Iseconds)] SIGNIFICANT EDIT: $FILE_PATH" >> "$CHANGES_LOG" 2>/dev/null || \
        log_error "Failed to write to changes log"
      ;;
    *.go|*.py|*.js|*.ts|*.rs|*.java|*.rb|*.php|*.c|*.cpp|*.h|*.hpp)
      log "Code file modified: $FILE_PATH"
      echo "[$(date -Iseconds)] CODE EDIT: $FILE_PATH" >> "$CHANGES_LOG" 2>/dev/null || \
        log_error "Failed to write to changes log"
      ;;
    *)
      log "Non-significant file change: $FILE_PATH"
      ;;
  esac

  exit 0
}

main
