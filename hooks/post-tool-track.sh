#!/usr/bin/env bash
# PostToolUse Hook - Track significant file changes
# Fires after Edit or Write tools complete
# Install to: ~/.config/claude-code/hooks/post-tool-track.sh

set -euo pipefail

LOG_FILE="/home/toowired/.claude-memories/automation.log"
CHANGES_LOG="/home/toowired/.claude-memories/file-changes.log"

log() {
  echo "[$(date -Iseconds)] [PostToolUse] $1" >> "$LOG_FILE"
}

main() {
  log "Post tool use triggered"

  # Read hook input from stdin
  HOOK_INPUT=$(cat)
  TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")
  TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // empty' 2>/dev/null || echo "")

  # Only track Edit and Write tools
  if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
    exit 0
  fi

  # Extract file path
  FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // empty' 2>/dev/null || echo "")

  if [ -z "$FILE_PATH" ]; then
    exit 0
  fi

  log "File modified: $FILE_PATH"

  # Check if this looks like a significant file
  case "$FILE_PATH" in
    */DECISIONS.md|*/README.md|*/ARCHITECTURE.md)
      log "Significant file detected: $FILE_PATH"
      echo "[$(date -Iseconds)] SIGNIFICANT EDIT: $FILE_PATH" >> "$CHANGES_LOG"
      ;;
    *.go|*.py|*.js|*.ts|*.rs|*.java|*.rb|*.php)
      log "Code file modified: $FILE_PATH"
      echo "[$(date -Iseconds)] CODE EDIT: $FILE_PATH" >> "$CHANGES_LOG"
      ;;
  esac

  exit 0
}

main
