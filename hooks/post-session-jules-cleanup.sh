#!/usr/bin/env bash
# Post-Session Jules Cleanup Hook
# Triggers code improvements after Claude Code session ends

set -euo pipefail

LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [JulesCleanup] $1" >> "$LOG_FILE"
}

main() {
  # Check if Jules CLI is installed
  if ! command -v jules &> /dev/null; then
    log "Jules CLI not installed - skipping cleanup"
    exit 0
  fi

  # Read session data from stdin
  local session_data=$(cat)
  local project_path=$(echo "$session_data" | jq -r '.cwd // ""')

  if [[ -z "$project_path" || "$project_path" == "null" ]]; then
    log "No project path found - skipping Jules cleanup"
    exit 0
  fi

  log "Session ended for project: $project_path"

  # Check if we want automated cleanup (look for flag file)
  if [[ -f "$project_path/.jules-auto-cleanup" ]]; then
    log "Auto-cleanup enabled - triggering Jules tasks"

    # Read cleanup preferences
    CLEANUP_TASKS=$(cat "$project_path/.jules-auto-cleanup")

    # Trigger each cleanup task
    while IFS= read -r task; do
      if [[ -n "$task" && ! "$task" =~ ^# ]]; then
        log "Triggering Jules task: $task"

        jules task create \
          --description "$task" \
          --repo "$project_path" \
          --auto-pr false \
          --format json >> "$LOG_FILE" 2>&1 &
      fi
    done <<< "$CLEANUP_TASKS"

    echo "🧹 Jules cleanup tasks triggered. Check: jules task list"
  else
    log "No .jules-auto-cleanup file - skipping automated tasks"
  fi

  exit 0
}

main
