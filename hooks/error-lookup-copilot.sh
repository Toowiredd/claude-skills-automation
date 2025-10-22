#!/usr/bin/env bash
# GitHub Copilot CLI Integration Hook
# Searches GitHub for solutions to errors

set -euo pipefail

ERROR_TEXT="$1"
PROJECT_DIR="${2:-$PWD}"

LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [Copilot] $1" >> "$LOG_FILE"
}

main() {
  # Check if Copilot CLI is installed
  if ! command -v copilot &> /dev/null; then
    log "Copilot CLI not installed"
    echo "⚠️  GitHub Copilot CLI not installed"
    echo "   Install with: npm install -g @github/copilot@latest"
    exit 0
  fi

  log "Searching GitHub for error solution: $ERROR_TEXT"

  # Use Copilot CLI to search for similar errors
  COPILOT_RESPONSE=$(copilot \
    --allow-tool 'github(*)' \
    "Search GitHub issues and PRs in $PROJECT_DIR and related public repositories for solutions to this error: $ERROR_TEXT. Provide the most relevant solution with code examples." \
    2>&1) || {
      log "Copilot search failed"
      echo "⚠️  Copilot search failed"
      exit 1
    }

  log "Copilot search complete"

  # Output response
  echo "🔍 GitHub Copilot Search Results:"
  echo ""
  echo "$COPILOT_RESPONSE"
  echo ""
  echo "---"
  echo "💡 If solution helpful, save to memory with: remember [solution details]"
}

main
