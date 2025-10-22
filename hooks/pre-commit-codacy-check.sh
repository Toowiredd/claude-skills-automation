#!/usr/bin/env bash
# Pre-Commit Codacy Quality Gate Hook
# Runs Codacy analysis on staged files before commit

set -euo pipefail

LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [Codacy] $1" >> "$LOG_FILE"
}

main() {
  # Check if Codacy CLI is installed
  if ! command -v codacy-analysis-cli &> /dev/null; then
    log "Codacy CLI not installed - skipping quality check"
    exit 0
  fi

  log "Running Codacy quality analysis..."

  # Get staged files
  STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

  if [[ -z "$STAGED_FILES" ]]; then
    log "No staged files to analyze"
    exit 0
  fi

  echo "🔍 Running Codacy quality analysis..."

  # Create temporary results file
  RESULTS_FILE="/tmp/codacy-results-$(date +%s).json"

  # Run Codacy CLI on current directory
  codacy-analysis-cli analyze \
    --tool eslint \
    --tool pylint \
    --tool shellcheck \
    --directory . \
    --format json \
    > "$RESULTS_FILE" 2>&1 || {
      log "Codacy analysis failed"
      rm -f "$RESULTS_FILE"
      exit 0  # Don't block commit if analysis fails
    }

  # Parse results
  ISSUE_COUNT=$(jq '. | length' "$RESULTS_FILE" 2>/dev/null || echo "0")

  if [[ "$ISSUE_COUNT" -gt 0 ]]; then
    log "Found $ISSUE_COUNT quality issues"

    echo ""
    echo "❌ Codacy found $ISSUE_COUNT quality issues:"
    echo ""

    # Format issues for display
    jq -r '.[] | "  📁 \(.filename):\(.line) - \(.level): \(.message)"' "$RESULTS_FILE" | head -10

    if [[ "$ISSUE_COUNT" -gt 10 ]]; then
      echo "  ... and $((ISSUE_COUNT - 10)) more issues"
    fi

    echo ""
    echo "Full report: $RESULTS_FILE"
    echo ""
    echo "❓ Proceed with commit anyway? (y/N)"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "Commit cancelled. Fix issues and try again."
      rm -f "$RESULTS_FILE"
      exit 1
    fi
  else
    log "No quality issues found ✅"
    echo "✅ Codacy: No quality issues found"
  fi

  rm -f "$RESULTS_FILE"
  exit 0
}

main
