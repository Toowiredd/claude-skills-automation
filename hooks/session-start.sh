#!/usr/bin/env bash
# SessionStart Hook - Automatically restore context with token limits
# Fires when Claude Code session starts or resumes
# Install to: ~/.config/claude-code/hooks/session-start.sh

set +e  # Don't exit on error - graceful degradation

MEMORY_INDEX="$HOME/.claude-memories/index.json"
CURRENT_SESSION="$HOME/.claude-sessions/current.json"
LOG_FILE="$HOME/.claude-memories/automation.log"
CONFIG_FILE="$HOME/.config/claude-code/automation.conf"

log() {
  echo "[$(date -Iseconds)] [SessionStart] $1" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
  echo "[$(date -Iseconds)] [SessionStart] ERROR: $1" >&2
  log "ERROR: $1"
}

# Safe directory creation
ensure_dirs() {
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  mkdir -p "$(dirname "$CURRENT_SESSION")" 2>/dev/null || true
}

# Load configuration with defaults
load_config() {
  # Set defaults first
  MAX_INJECTED_DECISIONS=10
  MAX_INJECTED_BLOCKERS=5
  MAX_INJECTED_CONTEXT=3
  MAX_INJECTED_PROCEDURES=5
  MAX_INJECTED_PREFERENCES=10
  TOKEN_LIMIT_ESTIMATE=2000
  DECISIONS_LOOKBACK_DAYS=7
  BLOCKERS_ACTIVE_ONLY=true
  CONTEXT_LOOKBACK_DAYS=14
  INJECT_DECISIONS=true
  INJECT_BLOCKERS=true
  INJECT_CONTEXT=true
  INJECT_PREFERENCES=true
  INJECT_PROCEDURES=false
  INJECT_LAST_TOPIC=true
  VERBOSE_LOGGING=false
  SHOW_TOKEN_ESTIMATES=true
  WARN_ON_LIMIT_EXCEEDED=true

  # Load config file if it exists
  if [ -f "$CONFIG_FILE" ]; then
    # Source the config file safely (ignore comments and blank lines)
    while IFS='=' read -r key value; do
      # Skip comments and blank lines
      [[ "$key" =~ ^#.*$ ]] && continue
      [[ -z "$key" ]] && continue
      # Remove leading/trailing whitespace
      key=$(echo "$key" | xargs)
      value=$(echo "$value" | xargs)
      # Export the variable
      [[ -n "$key" ]] && [[ -n "$value" ]] && eval "$key=\"$value\""
    done < <(grep -v '^[[:space:]]*#' "$CONFIG_FILE" 2>/dev/null | grep '=')

    log "Config loaded from $CONFIG_FILE"
  else
    log "No config file found at $CONFIG_FILE, using defaults"
  fi

  # Log config values if verbose
  if [ "$VERBOSE_LOGGING" = "true" ]; then
    log "Config: MAX_DECISIONS=$MAX_INJECTED_DECISIONS, MAX_BLOCKERS=$MAX_INJECTED_BLOCKERS"
    log "Config: TOKEN_LIMIT=$TOKEN_LIMIT_ESTIMATE, LOOKBACK=$DECISIONS_LOOKBACK_DAYS days"
  fi
}

# Estimate token count (rough: 4 chars ≈ 1 token)
estimate_tokens() {
  local text="$1"
  local char_count=$(echo -e "$text" | wc -c)
  echo $((char_count / 4))
}

# Detect project hash for filtering
detect_project() {
  local project_id
  if git rev-parse --show-toplevel &>/dev/null; then
    project_id=$(git rev-parse --show-toplevel)
  else
    project_id="$PWD"
  fi
  echo "$project_id" | md5sum | cut -d' ' -f1
}

# Read and validate memory index
read_memory_index() {
  if [ ! -f "$MEMORY_INDEX" ]; then
    log_error "Memory index not found at $MEMORY_INDEX, starting with empty state"
    echo '{"memories":[]}'
    return 0
  fi

  local content
  content=$(cat "$MEMORY_INDEX" 2>/dev/null)

  if [ $? -ne 0 ]; then
    log_error "Could not read memory index file"
    echo '{"memories":[]}'
    return 0
  fi

  # Validate JSON structure
  if ! echo "$content" | jq empty 2>/dev/null; then
    log_error "Corrupted memory index detected, backing up and resetting"
    local backup_file="${MEMORY_INDEX}.corrupted.$(date +%s)"
    cp "$MEMORY_INDEX" "$backup_file" 2>/dev/null && \
      log "Corrupted index backed up to: $backup_file"
    echo '{"memories":[]}'
    return 0
  fi

  echo "$content"
}

main() {
  ensure_dirs

  # Load configuration
  load_config

  log "Session starting with limits: decisions=$MAX_INJECTED_DECISIONS, blockers=$MAX_INJECTED_BLOCKERS"

  # Read hook input from stdin with error handling
  HOOK_INPUT=$(cat 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$HOOK_INPUT" ]; then
    log_error "Failed to read hook input from stdin"
    exit 0
  fi

  # Parse input with safe defaults
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
  SESSION_ID=$(echo "$HOOK_INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")

  # Determine current project from working directory
  PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "unknown")

  # Detect current project hash for filtering
  CURRENT_PROJECT=$(cd "$CWD" 2>/dev/null && detect_project)

  log "Project: $PROJECT_NAME, Hash: $CURRENT_PROJECT, Session: $SESSION_ID"

  # Load memory index with validation
  MEMORY_DATA=$(read_memory_index)
  if [ -z "$MEMORY_DATA" ]; then
    log_error "Memory index read returned empty, continuing without context"
    exit 0
  fi

  # Calculate cutoff dates
  DECISIONS_CUTOFF=$(date -d "$DECISIONS_LOOKBACK_DAYS days ago" -Iseconds 2>/dev/null || \
                     date -v-${DECISIONS_LOOKBACK_DAYS}d -Iseconds 2>/dev/null || \
                     date -Iseconds)
  CONTEXT_CUTOFF=$(date -d "$CONTEXT_LOOKBACK_DAYS days ago" -Iseconds 2>/dev/null || \
                   date -v-${CONTEXT_LOOKBACK_DAYS}d -Iseconds 2>/dev/null || \
                   date -Iseconds)

  # Extract recent decisions with limit (if enabled)
  RECENT_DECISIONS=""
  if [ "$INJECT_DECISIONS" = "true" ]; then
    RECENT_DECISIONS=$(echo "$MEMORY_DATA" | jq -r --arg cutoff "$DECISIONS_CUTOFF" --arg project "$CURRENT_PROJECT" --argjson limit "$MAX_INJECTED_DECISIONS" \
      '[.memories[]? | select(.type == "DECISION" and .timestamp > $cutoff) | select(.project == $project or .project == null)] |
       sort_by(.timestamp) | reverse |
       limit($limit; .[]) |
       "• " + .content + " (" + (.timestamp | fromdateiso8601 | (now - .) / 86400 | floor | tostring) + "d ago)"' \
      2>/dev/null || echo "")

    if [ $? -ne 0 ]; then
      log_error "Failed to extract recent decisions, continuing without them"
      RECENT_DECISIONS=""
    elif [ -n "$RECENT_DECISIONS" ]; then
      local count=$(echo "$RECENT_DECISIONS" | wc -l)
      log "Extracted $count decisions (limit: $MAX_INJECTED_DECISIONS)"
    fi
  fi

  # Extract active blockers with limit (if enabled)
  ACTIVE_BLOCKERS=""
  if [ "$INJECT_BLOCKERS" = "true" ]; then
    if [ "$BLOCKERS_ACTIVE_ONLY" = "true" ]; then
      ACTIVE_BLOCKERS=$(echo "$MEMORY_DATA" | jq -r --arg project "$CURRENT_PROJECT" --argjson limit "$MAX_INJECTED_BLOCKERS" \
        '[.memories[]? | select(.type == "BLOCKER" and .status == "active") | select(.project == $project or .project == null)] |
         limit($limit; .[]) |
         "⚠️  " + .content' 2>/dev/null || echo "")
    else
      ACTIVE_BLOCKERS=$(echo "$MEMORY_DATA" | jq -r --arg cutoff "$DECISIONS_CUTOFF" --arg project "$CURRENT_PROJECT" --argjson limit "$MAX_INJECTED_BLOCKERS" \
        '[.memories[]? | select(.type == "BLOCKER" and .timestamp > $cutoff) | select(.project == $project or .project == null)] |
         limit($limit; .[]) |
         "⚠️  " + .content' 2>/dev/null || echo "")
    fi

    if [ $? -ne 0 ]; then
      log_error "Failed to extract active blockers, continuing without them"
      ACTIVE_BLOCKERS=""
    elif [ -n "$ACTIVE_BLOCKERS" ]; then
      local count=$(echo "$ACTIVE_BLOCKERS" | wc -l)
      log "Extracted $count blockers (limit: $MAX_INJECTED_BLOCKERS)"
    fi
  fi

  # Extract project-specific preferences with limit (if enabled)
  PROJECT_PREFS=""
  if [ "$INJECT_PREFERENCES" = "true" ]; then
    PROJECT_PREFS=$(echo "$MEMORY_DATA" | jq -r --arg proj "$PROJECT_NAME" --arg project "$CURRENT_PROJECT" --argjson limit "$MAX_INJECTED_PREFERENCES" \
      '[.memories[]? | select(.type == "PREFERENCE") | select((.project == $project or .project == null) or (.project == $proj or .project == "all"))] |
       limit($limit; .[]) |
       "• " + .content' 2>/dev/null || echo "")

    if [ $? -ne 0 ]; then
      log_error "Failed to extract project preferences, continuing without them"
      PROJECT_PREFS=""
    elif [ -n "$PROJECT_PREFS" ]; then
      local count=$(echo "$PROJECT_PREFS" | wc -l)
      log "Extracted $count preferences (limit: $MAX_INJECTED_PREFERENCES)"
    fi
  fi

  # Extract relevant context items with limit (if enabled)
  CONTEXT_ITEMS=""
  if [ "$INJECT_CONTEXT" = "true" ]; then
    CONTEXT_ITEMS=$(echo "$MEMORY_DATA" | jq -r --arg cutoff "$CONTEXT_CUTOFF" --arg project "$CURRENT_PROJECT" --argjson limit "$MAX_INJECTED_CONTEXT" \
      '[.memories[]? | select(.type == "CONTEXT" and .timestamp > $cutoff) | select(.project == $project or .project == null)] |
       sort_by(.timestamp) | reverse |
       limit($limit; .[]) |
       "• " + .content' 2>/dev/null || echo "")

    if [ $? -ne 0 ]; then
      log_error "Failed to extract context items, continuing without them"
      CONTEXT_ITEMS=""
    elif [ -n "$CONTEXT_ITEMS" ]; then
      local count=$(echo "$CONTEXT_ITEMS" | wc -l)
      log "Extracted $count context items (limit: $MAX_INJECTED_CONTEXT)"
    fi
  fi

  # Extract procedures with limit (if enabled)
  PROCEDURES=""
  if [ "$INJECT_PROCEDURES" = "true" ]; then
    PROCEDURES=$(echo "$MEMORY_DATA" | jq -r --arg proj "$PROJECT_NAME" --arg project "$CURRENT_PROJECT" --argjson limit "$MAX_INJECTED_PROCEDURES" \
      '[.memories[]? | select(.type == "PROCEDURE") | select((.project == $project or .project == null) or (.project == $proj or .project == "all"))] |
       limit($limit; .[]) |
       "• " + .content' 2>/dev/null || echo "")

    if [ $? -ne 0 ]; then
      log_error "Failed to extract procedures, continuing without them"
      PROCEDURES=""
    elif [ -n "$PROCEDURES" ]; then
      local count=$(echo "$PROCEDURES" | wc -l)
      log "Extracted $count procedures (limit: $MAX_INJECTED_PROCEDURES)"
    fi
  fi

  # Load previous session state if exists with error handling
  LAST_TOPIC=""
  if [ "$INJECT_LAST_TOPIC" = "true" ]; then
    PROJECT_SESSION="$HOME/.claude-sessions/projects/${PROJECT_NAME}.json"
    if [ -f "$PROJECT_SESSION" ]; then
      LAST_TOPIC=$(jq -r '.last_topic // empty' "$PROJECT_SESSION" 2>/dev/null || echo "")
      if [ $? -ne 0 ]; then
        log_error "Failed to read last topic from project session"
        LAST_TOPIC=""
      fi
    fi
  fi

  # Build context injection (in priority order)
  CONTEXT=""

  if [ -n "$ACTIVE_BLOCKERS" ]; then
    CONTEXT="${CONTEXT}**Active Blockers:**\n${ACTIVE_BLOCKERS}\n\n"
  fi

  if [ -n "$LAST_TOPIC" ]; then
    CONTEXT="${CONTEXT}**Last Working On:** ${LAST_TOPIC}\n\n"
  fi

  if [ -n "$PROJECT_PREFS" ]; then
    CONTEXT="${CONTEXT}**Project Preferences:**\n${PROJECT_PREFS}\n\n"
  fi

  if [ -n "$RECENT_DECISIONS" ]; then
    CONTEXT="${CONTEXT}**Recent Decisions:**\n${RECENT_DECISIONS}\n\n"
  fi

  if [ -n "$CONTEXT_ITEMS" ]; then
    CONTEXT="${CONTEXT}**Context:**\n${CONTEXT_ITEMS}\n\n"
  fi

  if [ -n "$PROCEDURES" ]; then
    CONTEXT="${CONTEXT}**Procedures:**\n${PROCEDURES}\n\n"
  fi

  # Calculate token estimate
  ESTIMATED_TOKENS=0
  if [ -n "$CONTEXT" ]; then
    ESTIMATED_TOKENS=$(estimate_tokens "$CONTEXT")

    if [ "$SHOW_TOKEN_ESTIMATES" = "true" ]; then
      log "Estimated tokens: $ESTIMATED_TOKENS (limit: $TOKEN_LIMIT_ESTIMATE)"
    fi

    # Warn if exceeding limit
    if [ "$WARN_ON_LIMIT_EXCEEDED" = "true" ] && [ "$ESTIMATED_TOKENS" -gt "$TOKEN_LIMIT_ESTIMATE" ]; then
      log_error "WARNING: Estimated tokens ($ESTIMATED_TOKENS) exceeds limit ($TOKEN_LIMIT_ESTIMATE)"
      log_error "Consider reducing MAX_INJECTED_* values in $CONFIG_FILE"
    fi
  fi

  # Log what we're injecting
  CONTEXT_LINES=$(echo -e "$CONTEXT" | wc -l 2>/dev/null || echo "0")
  log "Injecting context: $CONTEXT_LINES lines, ~$ESTIMATED_TOKENS tokens"

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
