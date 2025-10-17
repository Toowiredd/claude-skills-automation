#!/usr/bin/env bash
# Stop Hook - Automatically extract decisions and blockers from conversation
# Fires when Claude finishes responding
# Install to: ~/.config/claude-code/hooks/stop-extract-memories.sh

set -euo pipefail

MEMORY_INDEX="/home/toowired/.claude-memories/index.json"
LOG_FILE="/home/toowired/.claude-memories/automation.log"
EXTRACT_LOG="/home/toowired/.claude-memories/auto-extracted.log"

log() {
  echo "[$(date -Iseconds)] [Stop] $1" >> "$LOG_FILE"
}

extract_memories() {
  local transcript_path="$1"
  local cwd="$2"
  local project_name=$(basename "$cwd" 2>/dev/null || echo "unknown")

  log "Analyzing transcript: $transcript_path"

  # Read last N messages from transcript
  local recent_messages=$(tail -20 "$transcript_path" 2>/dev/null | jq -r 'select(.type == "message") | .content // empty' 2>/dev/null || echo "")

  if [ -z "$recent_messages" ]; then
    log "No recent messages to analyze"
    return
  fi

  # Decision patterns (community-tested)
  local decision_patterns="using|chose|decided|going with|switching to|implemented|added|created|built|will use|plan to use|let's use"

  # Blocker patterns
  local blocker_patterns="can't|cannot|unable to|blocked by|waiting for|need to get|missing|error|failed|not working"

  # Extract decisions
  echo "$recent_messages" | grep -iE "$decision_patterns" 2>/dev/null | while read -r line; do
    # Skip if too short or looks like code
    if [ ${#line} -lt 20 ] || echo "$line" | grep -q '^\s*{'; then
      continue
    fi

    # Extract decision (first 200 chars)
    local decision=$(echo "$line" | cut -c1-200)

    log "Detected decision: $decision"

    # Save to extraction log
    echo "[$(date -Iseconds)] DECISION: $decision (Project: $project_name)" >> "$EXTRACT_LOG"
  done

  # Extract blockers
  echo "$recent_messages" | grep -iE "$blocker_patterns" 2>/dev/null | while read -r line; do
    if [ ${#line} -lt 20 ]; then
      continue
    fi

    local blocker=$(echo "$line" | cut -c1-200)

    log "Detected blocker: $blocker"

    echo "[$(date -Iseconds)] BLOCKER: $blocker (Project: $project_name)" >> "$EXTRACT_LOG"
  done
}

main() {
  log "Stop hook triggered"

  # Read hook input from stdin
  HOOK_INPUT=$(cat)
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")

  if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    log "No transcript found"
    exit 0
  fi

  extract_memories "$TRANSCRIPT_PATH" "$CWD"

  log "Memory extraction complete"
  exit 0
}

main
