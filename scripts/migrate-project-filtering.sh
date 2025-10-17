#!/usr/bin/env bash
# Migration Script - Add project filtering fields to existing memories
# This script adds 'project: null', 'cwd: null', and 'git_repo: null' to existing memories
# that don't have these fields yet.

set -euo pipefail

MEMORY_INDEX="${HOME}/.claude-memories/index.json"
BACKUP_DIR="${HOME}/.claude-memories/backups"

log() {
  echo "[$(date -Iseconds)] $1"
}

log_error() {
  echo "[$(date -Iseconds)] ERROR: $1" >&2
}

main() {
  log "Starting project filtering migration..."

  # Check if memory index exists
  if [ ! -f "$MEMORY_INDEX" ]; then
    log_error "Memory index not found at: $MEMORY_INDEX"
    log "No migration needed - index will be created with correct schema"
    exit 0
  fi

  # Create backup directory
  mkdir -p "$BACKUP_DIR"

  # Create backup
  BACKUP_FILE="${BACKUP_DIR}/index-pre-project-filtering-$(date +%s).json"
  cp "$MEMORY_INDEX" "$BACKUP_FILE"
  log "Created backup at: $BACKUP_FILE"

  # Check current structure
  TOTAL_MEMORIES=$(jq '.memories | length' "$MEMORY_INDEX")
  log "Found $TOTAL_MEMORIES memories to process"

  # Count memories missing project field
  MISSING_PROJECT=$(jq '[.memories[] | select(.project == null or (.project | type) == "null" or has("project") | not)] | length' "$MEMORY_INDEX")
  log "Memories missing project field: $MISSING_PROJECT"

  # Migrate: Add project, cwd, and git_repo fields to memories that don't have them
  log "Adding project filtering fields to existing memories..."

  jq '
    .memories |= map(
      if has("project") | not then
        . + {"project": null, "cwd": null, "git_repo": null}
      elif .project == null or (.project | type) == "null" then
        . + {"cwd": (.cwd // null), "git_repo": (.git_repo // null)}
      else
        .
      end
    ) |
    .last_updated = (now | todate)
  ' "$MEMORY_INDEX" > "${MEMORY_INDEX}.tmp"

  # Validate the new JSON
  if jq empty "${MEMORY_INDEX}.tmp" 2>/dev/null; then
    mv "${MEMORY_INDEX}.tmp" "$MEMORY_INDEX"
    log "Migration completed successfully!"

    # Show updated stats
    UPDATED_MEMORIES=$(jq '[.memories[] | select(.project == null)] | length' "$MEMORY_INDEX")
    log "Memories with project=null: $UPDATED_MEMORIES"
    log "These memories will be accessible from all projects"
  else
    log_error "Migration failed - JSON validation error"
    log "Backup preserved at: $BACKUP_FILE"
    rm -f "${MEMORY_INDEX}.tmp"
    exit 1
  fi

  log ""
  log "Migration complete!"
  log "Backup saved to: $BACKUP_FILE"
  log ""
  log "Next steps:"
  log "1. New memories will automatically include project context"
  log "2. Old memories with project=null will appear in all projects"
  log "3. Run 'jq . ~/.claude-memories/index.json | head -50' to verify"
}

main "$@"
