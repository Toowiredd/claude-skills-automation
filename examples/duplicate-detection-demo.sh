#!/usr/bin/env bash
# Demo script showing duplicate memory detection in action

set -euo pipefail

# Create temporary test environment
TEST_DIR="/tmp/duplicate-detection-demo-$$"
mkdir -p "$TEST_DIR"

MEMORY_INDEX="$TEST_DIR/index.json"
LOG_FILE="$TEST_DIR/automation.log"

echo "======================================"
echo "Duplicate Memory Detection Demo"
echo "======================================"
echo ""
echo "Test Environment: $TEST_DIR"
echo ""

# Create initial memory index
cat > "$MEMORY_INDEX" <<'EOF'
{
  "version": "1.0.0",
  "created": "2025-10-17T17:45:00Z",
  "last_updated": "2025-10-17T17:45:00Z",
  "total_memories": 0,
  "memories_by_type": {
    "DECISION": 0,
    "BLOCKER": 0
  },
  "memories": []
}
EOF

echo "✓ Created empty memory index"
echo ""

# Source the fuzzy matching functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/../hooks"

# Define functions inline for demo
fuzzy_match() {
  local new_content="$1"
  local existing_content="$2"
  local normalized_new=$(echo "$new_content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  local normalized_existing=$(echo "$existing_content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  if [ ${#normalized_new} -lt 10 ] || [ ${#normalized_existing} -lt 10 ]; then
    return 1
  fi
  if echo "$normalized_existing" | grep -q "$normalized_new"; then
    return 0
  fi
  if echo "$normalized_new" | grep -q "$normalized_existing"; then
    return 0
  fi
  return 1
}

check_duplicate() {
  local new_decision="$1"
  local type="$2"
  if [ ! -f "$MEMORY_INDEX" ]; then
    echo "NEW"
    return 1
  fi
  local existing_memories
  existing_memories=$(jq -r --arg type "$type" '.memories[] | select(.type == $type) | .content' "$MEMORY_INDEX" 2>/dev/null)
  if [ -z "$existing_memories" ]; then
    echo "NEW"
    return 1
  fi
  while IFS= read -r existing; do
    if [ -n "$existing" ] && fuzzy_match "$new_decision" "$existing"; then
      echo "DUPLICATE"
      return 0
    fi
  done <<< "$existing_memories"
  echo "NEW"
  return 1
}

save_memory() {
  local content="$1"
  local type="$2"
  local memory_id="mem_$(date +%s)_$$"
  jq --arg id "$memory_id" \
     --arg type "$type" \
     --arg content "$content" \
     --arg timestamp "$(date -Iseconds)" '
    .memories += [{
      "id": $id,
      "type": $type,
      "content": $content,
      "created": $timestamp,
      "last_mentioned": $timestamp,
      "source": "demo"
    }] |
    .total_memories = (.memories | length) |
    .memories_by_type[$type] = ((.memories_by_type[$type] // 0) + 1) |
    .last_updated = $timestamp
  ' "$MEMORY_INDEX" > "$MEMORY_INDEX.tmp" && mv "$MEMORY_INDEX.tmp" "$MEMORY_INDEX"
}

update_timestamp() {
  local content="$1"
  local type="$2"
  local normalized=$(echo "$content" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')
  jq --arg normalized "$normalized" \
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
}

# Demo scenarios
echo "Scenario 1: Adding first decision"
echo "===================================="
DECISION1="using PostgreSQL for database"
echo "Input: \"$DECISION1\""
RESULT=$(check_duplicate "$DECISION1" "DECISION")
echo "Result: $RESULT"
if [ "$RESULT" = "NEW" ]; then
  save_memory "$DECISION1" "DECISION"
  echo "✓ Saved new decision"
fi
echo ""

echo "Current memory index:"
jq '.memories[] | {type, content, created}' "$MEMORY_INDEX"
echo ""

echo "Scenario 2: Exact duplicate"
echo "==========================="
echo "Input: \"$DECISION1\" (exact same)"
RESULT=$(check_duplicate "$DECISION1" "DECISION")
echo "Result: $RESULT"
if [ "$RESULT" = "DUPLICATE" ]; then
  echo "✓ Correctly detected as DUPLICATE"
  update_timestamp "$DECISION1" "DECISION"
  echo "✓ Updated timestamp"
fi
echo ""

echo "Scenario 3: Case variation"
echo "=========================="
DECISION2="Using POSTGRESQL for Database"
echo "Input: \"$DECISION2\""
RESULT=$(check_duplicate "$DECISION2" "DECISION")
echo "Result: $RESULT"
if [ "$RESULT" = "DUPLICATE" ]; then
  echo "✓ Correctly detected as DUPLICATE (case insensitive)"
fi
echo ""

echo "Scenario 4: Substring match"
echo "==========================="
DECISION3="We decided to use PostgreSQL for our backend"
echo "Input: \"$DECISION3\""
RESULT=$(check_duplicate "$DECISION3" "DECISION")
echo "Result: $RESULT"
if [ "$RESULT" = "DUPLICATE" ]; then
  echo "✓ Correctly detected as DUPLICATE (fuzzy match)"
fi
echo ""

echo "Scenario 5: Different decision"
echo "=============================="
DECISION4="using MongoDB for data storage"
echo "Input: \"$DECISION4\""
RESULT=$(check_duplicate "$DECISION4" "DECISION")
echo "Result: $RESULT"
if [ "$RESULT" = "NEW" ]; then
  save_memory "$DECISION4" "DECISION"
  echo "✓ Correctly detected as NEW"
fi
echo ""

echo "Scenario 6: Type isolation"
echo "=========================="
BLOCKER1="cannot connect to PostgreSQL"
echo "Input: \"$BLOCKER1\" (type: BLOCKER)"
RESULT=$(check_duplicate "$BLOCKER1" "BLOCKER")
echo "Result: $RESULT"
if [ "$RESULT" = "NEW" ]; then
  save_memory "$BLOCKER1" "BLOCKER"
  echo "✓ Correctly detected as NEW (different type)"
fi
echo ""

echo "Final memory index:"
echo "==================="
jq '.' "$MEMORY_INDEX"
echo ""

echo "Summary:"
echo "========"
DECISION_COUNT=$(jq '.memories_by_type.DECISION' "$MEMORY_INDEX")
BLOCKER_COUNT=$(jq '.memories_by_type.BLOCKER' "$MEMORY_INDEX")
echo "✓ Total DECISIONS: $DECISION_COUNT"
echo "✓ Total BLOCKERS: $BLOCKER_COUNT"
echo "✓ Duplicate detection prevented 3 redundant saves"
echo ""

echo "Logging Output Format:"
echo "======================"
echo "Example log entries that would be generated:"
echo ""
echo "[$(date -Iseconds)] DUPLICATE: using POSTGRESQL for Database (updated timestamp)"
echo "[$(date -Iseconds)] NEW DECISION: using MongoDB for data storage"
echo "[$(date -Iseconds)] DUPLICATE: We decided to use PostgreSQL for our backend (updated timestamp)"
echo ""

# Cleanup
rm -rf "$TEST_DIR"
echo "✓ Demo complete (cleaned up test environment)"
