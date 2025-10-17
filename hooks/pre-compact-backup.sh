#!/usr/bin/env bash
# PreCompact Hook - Backup transcript before context compaction
# Fires before Claude Code compresses conversation context
# Install to: ~/.config/claude-code/hooks/pre-compact-backup.sh

set -euo pipefail

BACKUP_DIR="/home/toowired/.claude-memories/pre-compact-backups"
LOG_FILE="/home/toowired/.claude-memories/automation.log"
DECISIONS_LOG="/home/toowired/.claude-memories/pre-compact-decisions.log"

log() {
  echo "[$(date -Iseconds)] [PreCompact] $1" >> "$LOG_FILE"
}

main() {
  log "Pre-compact backup triggered"

  # Read hook input from stdin
  HOOK_INPUT=$(cat)
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

  if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    log "No transcript to backup"
    exit 0
  fi

  # Create backup
  mkdir -p "$BACKUP_DIR"
  BACKUP_FILE="$BACKUP_DIR/pre-compact-$(date +%Y%m%d-%H%M%S).jsonl"
  cp "$TRANSCRIPT_PATH" "$BACKUP_FILE"

  log "Transcript backed up to: $BACKUP_FILE"

  # Extract important context before compaction
  DECISIONS=$(jq -r 'select(.content | test("decided|using|chose"; "i")) | .content' "$TRANSCRIPT_PATH" 2>/dev/null | tail -5 || echo "")

  if [ -n "$DECISIONS" ]; then
    echo "[$(date -Iseconds)] Pre-compact extracted decisions:" >> "$DECISIONS_LOG"
    echo "$DECISIONS" >> "$DECISIONS_LOG"
    echo "---" >> "$DECISIONS_LOG"
  fi

  log "Pre-compact backup complete"
  exit 0
}

main
