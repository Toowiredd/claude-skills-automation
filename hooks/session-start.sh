#!/usr/bin/env bash
# SessionStart Hook - Automatically restore context
# Fires when Claude Code session starts or resumes
# Install to: ~/.config/claude-code/hooks/session-start.sh

set -euo pipefail

MEMORY_INDEX="/home/toowired/.claude-memories/index.json"
CURRENT_SESSION="/home/toowired/.claude-sessions/current.json"
LOG_FILE="/home/toowired/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [SessionStart] $1" >> "$LOG_FILE"
}

main() {
  log "Session starting..."

  # Read hook input from stdin
  HOOK_INPUT=$(cat)
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
  SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")

  # Determine current project from working directory
  PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

  log "Project: $PROJECT_NAME, Session: $SESSION_ID"

  # Load memory index
  if [ ! -f "$MEMORY_INDEX" ]; then
    log "No memory index found, skipping context load"
    exit 0
  fi

  # Extract recent decisions (last 7 days)
  SEVEN_DAYS_AGO=$(date -d '7 days ago' -Iseconds 2>/dev/null || date -v-7d -Iseconds 2>/dev/null || date -Iseconds)
  RECENT_DECISIONS=$(jq -r --arg cutoff "$SEVEN_DAYS_AGO" \
    '.memories[] | select(.type == "DECISION" and .timestamp > $cutoff) |
     "• " + .content + " (" + (.timestamp | fromdateiso8601 | (now - .) / 86400 | floor | tostring) + "d ago)"' \
    "$MEMORY_INDEX" 2>/dev/null | head -5 || echo "")

  # Extract active blockers
  ACTIVE_BLOCKERS=$(jq -r '.memories[] | select(.type == "BLOCKER" and .status == "active") |
    "⚠️  " + .content' "$MEMORY_INDEX" 2>/dev/null || echo "")

  # Extract project-specific preferences
  PROJECT_PREFS=$(jq -r --arg proj "$PROJECT_NAME" \
    '.memories[] | select(.type == "PREFERENCE" and (.project == $proj or .project == "all")) |
     "• " + .content' "$MEMORY_INDEX" 2>/dev/null || echo "")

  # Load previous session state if exists
  PROJECT_SESSION="/home/toowired/.claude-sessions/projects/${PROJECT_NAME}.json"
  LAST_TOPIC=""
  if [ -f "$PROJECT_SESSION" ]; then
    LAST_TOPIC=$(jq -r '.last_topic // empty' "$PROJECT_SESSION" 2>/dev/null || echo "")
  fi

  # Build context injection
  CONTEXT=""

  if [ -n "$RECENT_DECISIONS" ]; then
    CONTEXT="${CONTEXT}**Recent Decisions:**\n${RECENT_DECISIONS}\n\n"
  fi

  if [ -n "$ACTIVE_BLOCKERS" ]; then
    CONTEXT="${CONTEXT}**Active Blockers:**\n${ACTIVE_BLOCKERS}\n\n"
  fi

  if [ -n "$PROJECT_PREFS" ]; then
    CONTEXT="${CONTEXT}**Project Preferences:**\n${PROJECT_PREFS}\n\n"
  fi

  if [ -n "$LAST_TOPIC" ]; then
    CONTEXT="${CONTEXT}**Last Working On:** ${LAST_TOPIC}\n\n"
  fi

  # Log what we're injecting
  log "Injecting context: $(echo -e "$CONTEXT" | wc -l) lines"

  # Output context injection (Claude Code will add this to conversation)
  if [ -n "$CONTEXT" ]; then
    cat <<EOF
{
  "type": "inject_system_message",
  "message": "# Session Context Restored\n\n${CONTEXT}**Memory system active** - All past decisions and context loaded."
}
EOF
  fi

  log "Context restoration complete"
  exit 0
}

main
