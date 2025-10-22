#!/usr/bin/env bash
# Codegen-ai Integration Hook
# Triggers autonomous agent for feature implementation

set -euo pipefail

FEATURE_SPEC="$1"
REPO_PATH="${2:-$PWD}"

LOG_FILE="$HOME/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [Codegen] $1" >> "$LOG_FILE"
}

main() {
  # Check if API key is set
  if [[ -z "${CODEGEN_API_KEY:-}" ]]; then
    log "CODEGEN_API_KEY not set"
    echo "⚠️  CODEGEN_API_KEY environment variable not set"
    echo "   Set it with: export CODEGEN_API_KEY='your-api-key'"
    exit 0
  fi

  # Check if codegen-sdk is installed
  if ! command -v codegen-sdk &> /dev/null; then
    log "Codegen SDK not installed"
    echo "⚠️  Codegen SDK not installed"
    echo "   Install with: npm install -g @codegen/sdk"
    exit 0
  fi

  log "Triggering Codegen agent for: $FEATURE_SPEC"
  echo "🤖 Triggering Codegen autonomous agent..."

  # Call Codegen API
  AGENT_RESPONSE=$(curl -s -X POST https://api.codegen.com/v1/agents/run \
    -H "Authorization: Bearer $CODEGEN_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
      \"task\": \"$FEATURE_SPEC\",
      \"repo_path\": \"$REPO_PATH\",
      \"create_pr\": true,
      \"run_tests\": true
    }") || {
      log "Codegen API call failed"
      echo "❌ Codegen API call failed"
      exit 1
    }

  AGENT_ID=$(echo "$AGENT_RESPONSE" | jq -r '.agent_id // ""')
  PR_URL=$(echo "$AGENT_RESPONSE" | jq -r '.pr_url // "TBD"')

  if [[ -z "$AGENT_ID" || "$AGENT_ID" == "null" ]]; then
    log "Failed to create Codegen agent"
    echo "❌ Failed to create agent. Response: $AGENT_RESPONSE"
    exit 1
  fi

  log "Agent $AGENT_ID started. PR will be created at: $PR_URL"

  echo "✅ Codegen agent started"
  echo "📋 Agent ID: $AGENT_ID"
  echo "🔗 PR will be created at: $PR_URL"
  echo ""
  echo "Track progress:"
  echo "  codegen-sdk agent status $AGENT_ID"
  echo "  codegen-sdk agent logs $AGENT_ID"
}

main
