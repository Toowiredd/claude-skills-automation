#!/usr/bin/env bash
# Pieces.app Integration Hook
# Auto-saves significant code changes to Pieces

set -euo pipefail

LOG_FILE="/home/toowired/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [PiecesSync] $1" >> "$LOG_FILE"
}

main() {
  # Check if Pieces CLI is installed
  if ! command -v pieces &> /dev/null; then
    log "Pieces CLI not installed - skipping sync"
    exit 0
  fi

  # Read tool use from stdin
  local tool_use=$(cat)
  local tool_name=$(echo "$tool_use" | jq -r '.tool_name // ""')

  # Only process Write and Edit tools
  if [[ ! "$tool_name" =~ ^(Write|Edit)$ ]]; then
    exit 0
  fi

  local file_path=$(echo "$tool_use" | jq -r '.parameters.file_path // ""')

  if [[ -z "$file_path" || "$file_path" == "null" ]]; then
    exit 0
  fi

  log "Saving $file_path to Pieces..."

  # Read file content
  if [[ ! -f "$file_path" ]]; then
    log "File not found: $file_path"
    exit 0
  fi

  # Get file extension for language detection
  FILE_EXT="${file_path##*.}"

  # Save to Pieces (non-blocking)
  (
    pieces save-snippet \
      --file "$file_path" \
      --tags "claude-code,auto-saved,$(date +%Y-%m-%d)" \
      --context "Auto-saved from Claude Code session on $(date)" \
      >> "$LOG_FILE" 2>&1
  ) &

  log "Queued save to Pieces: $file_path"
  exit 0
}

main
