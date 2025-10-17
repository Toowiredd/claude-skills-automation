#!/usr/bin/env bash
# Stop Hook - Automatically extract decisions and blockers from conversation
# Fires when Claude finishes responding
# Install to: ~/.config/claude-code/hooks/stop-extract-memories.sh

set +e  # Don't exit on error - graceful degradation

MEMORY_INDEX="/home/toowired/.claude-memories/index.json"
LOG_FILE="/home/toowired/.claude-memories/automation.log"
EXTRACT_LOG="/home/toowired/.claude-memories/auto-extracted.log"

log() {
  echo "[$(date -Iseconds)] [Stop] $1" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
  echo "[$(date -Iseconds)] [Stop] ERROR: $1" >&2
  log "ERROR: $1"
}

# Safe directory creation
ensure_dirs() {
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  mkdir -p "$(dirname "$EXTRACT_LOG")" 2>/dev/null || true
  mkdir -p "$(dirname "$MEMORY_INDEX")" 2>/dev/null || true
}

detect_project() {
  local project_id
  if git rev-parse --show-toplevel &>/dev/null; then
    project_id=$(git rev-parse --show-toplevel)
  else
    project_id="$PWD"
  fi
  echo "$project_id" | md5sum | cut -d' ' -f1
}

# Fuzzy matching function to detect similar content
fuzzy_match() {
  local new_content="$1"
  local existing_content="$2"

  # Normalize both strings (lowercase, remove special chars)
  local normalized_new=$(echo "$new_content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  local normalized_existing=$(echo "$existing_content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')

  # Skip if either normalized string is too short
  if [ ${#normalized_new} -lt 10 ] || [ ${#normalized_existing} -lt 10 ]; then
    return 1
  fi

  # Simple substring match (bidirectional)
  if echo "$normalized_existing" | grep -q "$normalized_new"; then
    return 0  # Match found
  fi

  if echo "$normalized_new" | grep -q "$normalized_existing"; then
    return 0  # Match found
  fi

  return 1  # No match
}

# Check if a decision/blocker is a duplicate
check_duplicate() {
  local new_decision="$1"
  local type="$2"

  # Return "NEW" if index doesn't exist
  if [ ! -f "$MEMORY_INDEX" ]; then
    echo "NEW"
    return 1
  fi

  # Get existing memories of same type
  local existing_memories
  existing_memories=$(jq -r --arg type "$type" '
    .memories[] |
    select(.type == $type) |
    .content
  ' "$MEMORY_INDEX" 2>/dev/null)

  if [ -z "$existing_memories" ]; then
    echo "NEW"
    return 1
  fi

  # Check each existing memory
  while IFS= read -r existing; do
    if [ -n "$existing" ] && fuzzy_match "$new_decision" "$existing"; then
      echo "DUPLICATE"
      return 0
    fi
  done <<< "$existing_memories"

  echo "NEW"
  return 1
}

# Update the last_mentioned timestamp for an existing memory
update_memory_timestamp() {
  local content="$1"
  local type="$2"

  if [ ! -f "$MEMORY_INDEX" ]; then
    return 1
  fi

  # Normalize content for matching
  local normalized=$(echo "$content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')

  # Update timestamp on matching memory
  jq --arg content "$content" \
     --arg normalized "$normalized" \
     --arg timestamp "$(date -Iseconds)" \
     --arg type "$type" '
    .memories |= map(
      if .type == $type then
        if ((.content | ascii_downcase | gsub("[^a-z0-9]"; "")) | contains($normalized)) or
           ($normalized | contains(.content | ascii_downcase | gsub("[^a-z0-9]"; ""))) then
          . + {last_mentioned: $timestamp}
        else
          .
        end
      else
        .
      end
    ) |
    .last_updated = $timestamp
  ' "$MEMORY_INDEX" > "$MEMORY_INDEX.tmp" && mv "$MEMORY_INDEX.tmp" "$MEMORY_INDEX"

  return 0
}

# Save a new decision or blocker to the memory index
save_new_memory() {
  local content="$1"
  local type="$2"
  local project_name="$3"
  local project_hash="$4"
  local cwd="$5"
  local git_repo="$6"

  if [ ! -f "$MEMORY_INDEX" ]; then
    log "Memory index not found, cannot save: $content"
    return 1
  fi

  local timestamp=$(date -Iseconds)
  local memory_id="mem_$(date +%s)_$$"

  # Add new memory to index with project context
  jq --arg id "$memory_id" \
     --arg type "$type" \
     --arg content "$content" \
     --arg project "$project_hash" \
     --arg cwd "$cwd" \
     --arg git_repo "$git_repo" \
     --arg timestamp "$timestamp" '
    .memories += [{
      "id": $id,
      "type": $type,
      "content": $content,
      "project": $project,
      "cwd": $cwd,
      "git_repo": (if $git_repo == "" then null else $git_repo end),
      "tags": [],
      "created": $timestamp,
      "last_mentioned": $timestamp,
      "source": "auto-extracted"
    }] |
    .total_memories = (.memories | length) |
    .memories_by_type[$type] = ((.memories_by_type[$type] // 0) + 1) |
    .last_updated = $timestamp
  ' "$MEMORY_INDEX" > "$MEMORY_INDEX.tmp" && mv "$MEMORY_INDEX.tmp" "$MEMORY_INDEX"

  log "Saved new $type: $content"
  return 0
}

extract_memories() {
  local transcript_path="$1"
  local cwd="$2"
  local project_name=$(basename "$cwd" 2>/dev/null || echo "unknown")

  # Detect project context with error handling
  local project_hash
  if [ -d "$cwd" ]; then
    project_hash=$(cd "$cwd" 2>/dev/null && detect_project 2>/dev/null || echo "unknown")
  else
    log_error "CWD not accessible: $cwd"
    project_hash="unknown"
  fi

  local git_repo=""
  if [ -d "$cwd" ]; then
    git_repo=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || echo "")
  fi

  log "Analyzing transcript: $transcript_path"
  log "Project hash: $project_hash, Git repo: ${git_repo:-none}, CWD: $cwd"

  # Validate transcript file exists
  if [ ! -f "$transcript_path" ]; then
    log_error "Transcript file not found: $transcript_path"
    return 0
  fi

  # Read last N messages from transcript with validation
  local recent_messages
  recent_messages=$(tail -20 "$transcript_path" 2>/dev/null | jq -r 'select(.type == "message") | .content // empty' 2>/dev/null || echo "")

  if [ $? -ne 0 ]; then
    log_error "Failed to parse transcript JSON from: $transcript_path"
    return 0
  fi

  if [ -z "$recent_messages" ]; then
    log "No recent messages to analyze"
    return 0
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

    # Extract decision (first 200 chars) with error handling
    local decision
    decision=$(echo "$line" | cut -c1-200 2>/dev/null || echo "$line")

    log "Detected decision: $decision"

    # Check for duplicates with error handling
    local duplicate_status
    duplicate_status=$(check_duplicate "$decision" "DECISION" 2>/dev/null || echo "NEW")

    if [ "$duplicate_status" = "DUPLICATE" ]; then
      echo "[$(date -Iseconds)] DUPLICATE: $decision (updated timestamp)" >> "$LOG_FILE" 2>/dev/null || true
      update_memory_timestamp "$decision" "DECISION" 2>/dev/null || \
        log_error "Failed to update timestamp for duplicate decision"

      # Log to extraction log as duplicate with error handling
      cat >> "$EXTRACT_LOG" 2>/dev/null <<EOF || log_error "Failed to write to extraction log"
[$(date -Iseconds)] DUPLICATE DECISION (timestamp updated): $decision
Project: $project_name
Project Hash: $project_hash
CWD: $cwd
Git Repo: ${git_repo:-none}

EOF
    else
      # Save new decision to memory index with error handling
      save_new_memory "$decision" "DECISION" "$project_name" "$project_hash" "$cwd" "$git_repo" 2>/dev/null || \
        log_error "Failed to save new decision to memory index"

      # Save to extraction log with project context and error handling
      cat >> "$EXTRACT_LOG" 2>/dev/null <<EOF || log_error "Failed to write to extraction log"
[$(date -Iseconds)] NEW DECISION: $decision
Project: $project_name
Project Hash: $project_hash
CWD: $cwd
Git Repo: ${git_repo:-none}

EOF
    fi
  done

  # Extract blockers
  echo "$recent_messages" | grep -iE "$blocker_patterns" 2>/dev/null | while read -r line; do
    if [ ${#line} -lt 20 ]; then
      continue
    fi

    # Extract blocker with error handling
    local blocker
    blocker=$(echo "$line" | cut -c1-200 2>/dev/null || echo "$line")

    log "Detected blocker: $blocker"

    # Check for duplicates with error handling
    local duplicate_status
    duplicate_status=$(check_duplicate "$blocker" "BLOCKER" 2>/dev/null || echo "NEW")

    if [ "$duplicate_status" = "DUPLICATE" ]; then
      echo "[$(date -Iseconds)] DUPLICATE: $blocker (updated timestamp)" >> "$LOG_FILE" 2>/dev/null || true
      update_memory_timestamp "$blocker" "BLOCKER" 2>/dev/null || \
        log_error "Failed to update timestamp for duplicate blocker"

      # Log to extraction log as duplicate with error handling
      cat >> "$EXTRACT_LOG" 2>/dev/null <<EOF || log_error "Failed to write to extraction log"
[$(date -Iseconds)] DUPLICATE BLOCKER (timestamp updated): $blocker
Project: $project_name
Project Hash: $project_hash
CWD: $cwd
Git Repo: ${git_repo:-none}

EOF
    else
      # Save new blocker to memory index with error handling
      save_new_memory "$blocker" "BLOCKER" "$project_name" "$project_hash" "$cwd" "$git_repo" 2>/dev/null || \
        log_error "Failed to save new blocker to memory index"

      # Save to extraction log with project context and error handling
      cat >> "$EXTRACT_LOG" 2>/dev/null <<EOF || log_error "Failed to write to extraction log"
[$(date -Iseconds)] NEW BLOCKER: $blocker
Project: $project_name
Project Hash: $project_hash
CWD: $cwd
Git Repo: ${git_repo:-none}

EOF
    fi
  done
}

main() {
  ensure_dirs
  log "Stop hook triggered"

  # Read hook input from stdin with error handling
  HOOK_INPUT=$(cat 2>/dev/null)
  if [ $? -ne 0 ] || [ -z "$HOOK_INPUT" ]; then
    log_error "Failed to read hook input from stdin"
    exit 0
  fi

  # Parse input with safe defaults
  TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")
  CWD=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")

  if [ -z "$TRANSCRIPT_PATH" ]; then
    log_error "No transcript path provided in hook input"
    exit 0
  fi

  if [ ! -f "$TRANSCRIPT_PATH" ]; then
    log_error "Transcript file not found: $TRANSCRIPT_PATH"
    exit 0
  fi

  # Extract memories with error handling (function handles its own errors)
  extract_memories "$TRANSCRIPT_PATH" "$CWD" || \
    log_error "Memory extraction encountered errors but continuing"

  log "Memory extraction complete"
  exit 0
}

main
