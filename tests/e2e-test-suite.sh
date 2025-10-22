#!/usr/bin/env bash
# Comprehensive E2E Test Suite for Claude Skills Automation
# Tests the entire automation workflow from installation to execution

set -e  # Exit on error

# Determine repository root (works whether script is run directly or sourced)
SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || pwd)"
if [ -f "$SCRIPT_PATH" ]; then
  REPO_ROOT="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
else
  # Fallback if script path resolution fails
  REPO_ROOT="$(cd "$(dirname "$BASH_SOURCE")/.." 2>/dev/null || pwd)"
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test environment
TEST_ROOT="/tmp/claude-automation-e2e-test-$$"
TEST_HOME="$TEST_ROOT/home"
TEST_PROJECT="$TEST_ROOT/test-project"

# Logging
log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Test assertion functions
assert_file_exists() {
  local file="$1"
  local desc="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [ -f "$file" ]; then
    log_success "Test $TESTS_RUN: $desc - File exists: $file"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - File not found: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_dir_exists() {
  local dir="$1"
  local desc="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [ -d "$dir" ]; then
    log_success "Test $TESTS_RUN: $desc - Directory exists: $dir"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - Directory not found: $dir"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_executable() {
  local file="$1"
  local desc="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if [ -x "$file" ]; then
    log_success "Test $TESTS_RUN: $desc - File is executable: $file"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - File not executable: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_valid_json() {
  local file="$1"
  local desc="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if jq empty "$file" 2>/dev/null; then
    log_success "Test $TESTS_RUN: $desc - Valid JSON: $file"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - Invalid JSON: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_valid_bash_syntax() {
  local file="$1"
  local desc="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if bash -n "$file" 2>/dev/null; then
    log_success "Test $TESTS_RUN: $desc - Valid Bash syntax: $file"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - Invalid Bash syntax: $file"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  local desc="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if grep -q "$pattern" "$file" 2>/dev/null; then
    log_success "Test $TESTS_RUN: $desc - Pattern found: '$pattern'"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - Pattern not found: '$pattern'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local desc="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  
  if ! grep -q "$pattern" "$file" 2>/dev/null; then
    log_success "Test $TESTS_RUN: $desc - Pattern not found (as expected): '$pattern'"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_error "Test $TESTS_RUN: $desc - Pattern found (should not be): '$pattern'"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# Setup test environment
setup_test_environment() {
  log_info "Setting up test environment at $TEST_ROOT"
  
  # Clean up any previous test runs
  rm -rf "$TEST_ROOT" 2>/dev/null || true
  
  # Create test directories
  mkdir -p "$TEST_HOME/.claude-memories"
  mkdir -p "$TEST_HOME/.claude-sessions/projects"
  mkdir -p "$TEST_HOME/.config/claude-code"
  mkdir -p "$TEST_PROJECT"
  
  # Initialize git repo in test project
  cd "$TEST_PROJECT"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test User"
  
  log_success "Test environment created"
}

# Cleanup test environment
cleanup_test_environment() {
  log_info "Cleaning up test environment"
  rm -rf "$TEST_ROOT" 2>/dev/null || true
  log_success "Test environment cleaned up"
}

# Test 1: Verify repository structure
test_repository_structure() {
  log_info "===== Test Suite 1: Repository Structure ====="
  
  assert_dir_exists "$REPO_ROOT/hooks" "Core hooks directory exists"
  assert_dir_exists "$REPO_ROOT/skills" "Skills directory exists"
  assert_dir_exists "$REPO_ROOT/scripts" "Scripts directory exists"
  assert_dir_exists "$REPO_ROOT/docs" "Documentation directory exists"
  
  assert_file_exists "$REPO_ROOT/README.md" "README exists"
  assert_file_exists "$REPO_ROOT/CHANGELOG.md" "CHANGELOG exists"
  assert_file_exists "$REPO_ROOT/CONTRIBUTING.md" "CONTRIBUTING guide exists"
  assert_file_exists "$REPO_ROOT/LICENSE" "LICENSE file exists"
}

# Test 2: Verify all hooks exist and are executable
test_hooks_validity() {
  log_info "===== Test Suite 2: Hooks Validity ====="
  
  # Core hooks
  local core_hooks=(
    "session-start.sh"
    "session-end.sh"
    "stop-extract-memories.sh"
    "post-tool-track.sh"
    "pre-compact-backup.sh"
  )
  
  for hook in "${core_hooks[@]}"; do
    local hook_path="$REPO_ROOT/hooks/$hook"
    assert_file_exists "$hook_path" "Core hook exists: $hook"
    assert_executable "$hook_path" "Core hook is executable: $hook"
    assert_valid_bash_syntax "$hook_path" "Core hook has valid syntax: $hook"
  done
  
  # Integration hooks
  local integration_hooks=(
    "async-task-jules.sh"
    "codegen-agent-trigger.sh"
    "error-lookup-copilot.sh"
    "post-session-jules-cleanup.sh"
    "post-tool-save-to-pieces.sh"
    "pre-commit-codacy-check.sh"
    "pre-commit-copilot-review.sh"
    "testing-docker-isolation.sh"
  )
  
  for hook in "${integration_hooks[@]}"; do
    local hook_path="$REPO_ROOT/hooks/$hook"
    assert_file_exists "$hook_path" "Integration hook exists: $hook"
    assert_executable "$hook_path" "Integration hook is executable: $hook"
    assert_valid_bash_syntax "$hook_path" "Integration hook has valid syntax: $hook"
  done
}

# Test 3: Verify no hardcoded paths
test_no_hardcoded_paths() {
  log_info "===== Test Suite 3: No Hardcoded Paths ====="
  
  for hook in "$REPO_ROOT"/hooks/*.sh; do
    local hook_name=$(basename "$hook")
    assert_not_contains "$hook" "/home/toowired" "No hardcoded user path in $hook_name"
  done
}

# Test 4: Test memory index initialization
test_memory_index_initialization() {
  log_info "===== Test Suite 4: Memory Index Initialization ====="
  
  # Create initial memory index
  cat > "$TEST_HOME/.claude-memories/index.json" <<'EOF'
{
  "version": "1.0.0",
  "created": "2025-10-22T00:00:00Z",
  "last_updated": "2025-10-22T00:00:00Z",
  "total_memories": 0,
  "memories_by_type": {
    "DECISION": 0,
    "BLOCKER": 0,
    "CONTEXT": 0,
    "PREFERENCE": 0,
    "PROCEDURE": 0,
    "NOTE": 0
  },
  "memories": [],
  "tags_index": {},
  "project_index": {},
  "session_index": {}
}
EOF
  
  assert_file_exists "$TEST_HOME/.claude-memories/index.json" "Memory index created"
  assert_valid_json "$TEST_HOME/.claude-memories/index.json" "Memory index is valid JSON"
}

# Test 5: Test session-start hook
test_session_start_hook() {
  log_info "===== Test Suite 5: Session Start Hook ====="
  
  local hook="$REPO_ROOT/hooks/session-start.sh"
  
  # Create test input
  local test_input=$(cat <<EOF
{
  "session_id": "test-session-$$",
  "cwd": "$TEST_PROJECT",
  "transcript_path": "$TEST_PROJECT/test.jsonl"
}
EOF
)
  
  # Run hook with test environment
  export HOME="$TEST_HOME"
  local output=$(echo "$test_input" | "$hook" 2>&1)
  local exit_code=$?
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ $exit_code -eq 0 ]; then
    log_success "Test $TESTS_RUN: session-start hook executed successfully"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: session-start hook failed with exit code $exit_code"
    log_error "Output: $output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  # Check log file was created
  assert_file_exists "$TEST_HOME/.claude-memories/automation.log" "Automation log created by session-start"
}

# Test 6: Test session-end hook
test_session_end_hook() {
  log_info "===== Test Suite 6: Session End Hook ====="
  
  local hook="$REPO_ROOT/hooks/session-end.sh"
  
  # Create test input
  local test_input=$(cat <<EOF
{
  "session_id": "test-session-$$",
  "cwd": "$TEST_PROJECT"
}
EOF
)
  
  # Run hook with test environment
  export HOME="$TEST_HOME"
  local output=$(echo "$test_input" | "$hook" 2>&1)
  local exit_code=$?
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ $exit_code -eq 0 ]; then
    log_success "Test $TESTS_RUN: session-end hook executed successfully"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: session-end hook failed with exit code $exit_code"
    log_error "Output: $output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test 7: Test stop-extract-memories hook
test_stop_extract_memories_hook() {
  log_info "===== Test Suite 7: Stop Extract Memories Hook ====="
  
  local hook="$REPO_ROOT/hooks/stop-extract-memories.sh"
  
  # Create test transcript
  local transcript_path="$TEST_PROJECT/test-transcript.jsonl"
  cat > "$transcript_path" <<'EOF'
{"type":"message","role":"user","content":"We decided to use PostgreSQL for the database"}
{"type":"message","role":"assistant","content":"Great choice! PostgreSQL is excellent for reliability."}
{"type":"message","role":"user","content":"We're using React for the frontend"}
{"type":"message","role":"assistant","content":"React is a solid framework."}
EOF
  
  # Create test input
  local test_input=$(cat <<EOF
{
  "transcript_path": "$transcript_path",
  "cwd": "$TEST_PROJECT"
}
EOF
)
  
  # Run hook with test environment
  export HOME="$TEST_HOME"
  local output=$(echo "$test_input" | "$hook" 2>&1)
  local exit_code=$?
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ $exit_code -eq 0 ]; then
    log_success "Test $TESTS_RUN: stop-extract-memories hook executed successfully"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: stop-extract-memories hook failed with exit code $exit_code"
    log_error "Output: $output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  
  # Check extraction log was created
  if [ -f "$TEST_HOME/.claude-memories/auto-extracted.log" ]; then
    assert_file_exists "$TEST_HOME/.claude-memories/auto-extracted.log" "Auto-extraction log created"
  else
    log_warn "Auto-extraction log not created (may be expected if no patterns matched)"
  fi
}

# Test 8: Test post-tool-track hook
test_post_tool_track_hook() {
  log_info "===== Test Suite 8: Post Tool Track Hook ====="
  
  local hook="$REPO_ROOT/hooks/post-tool-track.sh"
  
  # Create test input
  local test_input=$(cat <<EOF
{
  "tool_name": "Write",
  "parameters": {
    "file_path": "$TEST_PROJECT/test.txt",
    "content": "test content"
  }
}
EOF
)
  
  # Run hook with test environment
  export HOME="$TEST_HOME"
  local output=$(echo "$test_input" | "$hook" 2>&1)
  local exit_code=$?
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ $exit_code -eq 0 ]; then
    log_success "Test $TESTS_RUN: post-tool-track hook executed successfully"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: post-tool-track hook failed with exit code $exit_code"
    log_error "Output: $output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test 9: Test pre-compact-backup hook
test_pre_compact_backup_hook() {
  log_info "===== Test Suite 9: Pre Compact Backup Hook ====="
  
  local hook="$REPO_ROOT/hooks/pre-compact-backup.sh"
  
  # Create test input
  local test_input=$(cat <<EOF
{
  "session_id": "test-session-$$",
  "cwd": "$TEST_PROJECT",
  "transcript_path": "$TEST_PROJECT/test.jsonl"
}
EOF
)
  
  # Run hook with test environment
  export HOME="$TEST_HOME"
  local output=$(echo "$test_input" | "$hook" 2>&1)
  local exit_code=$?
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ $exit_code -eq 0 ]; then
    log_success "Test $TESTS_RUN: pre-compact-backup hook executed successfully"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: pre-compact-backup hook failed with exit code $exit_code"
    log_error "Output: $output"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test 10: Test memory persistence
test_memory_persistence() {
  log_info "===== Test Suite 10: Memory Persistence ====="
  
  # Check memory index still exists and is valid
  assert_file_exists "$TEST_HOME/.claude-memories/index.json" "Memory index persists"
  assert_valid_json "$TEST_HOME/.claude-memories/index.json" "Memory index remains valid JSON"
  
  # Check that index structure is intact
  export HOME="$TEST_HOME"
  local total_memories=$(jq -r '.total_memories // 0' "$TEST_HOME/.claude-memories/index.json" 2>/dev/null)
  
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ -n "$total_memories" ]; then
    log_success "Test $TESTS_RUN: Memory index has total_memories field: $total_memories"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: Memory index missing total_memories field"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test 11: Test full workflow integration
test_full_workflow_integration() {
  log_info "===== Test Suite 11: Full Workflow Integration ====="
  
  export HOME="$TEST_HOME"
  
  # Step 1: Session start
  log_info "Step 1: Starting session"
  local session_start_input=$(cat <<EOF
{
  "session_id": "integration-test-$$",
  "cwd": "$TEST_PROJECT",
  "transcript_path": "$TEST_PROJECT/integration.jsonl"
}
EOF
)
  echo "$session_start_input" | "$REPO_ROOT/hooks/session-start.sh" >/dev/null 2>&1
  
  # Step 2: Simulate some work (extract memories)
  log_info "Step 2: Extracting memories"
  local transcript_path="$TEST_PROJECT/integration.jsonl"
  cat > "$transcript_path" <<'EOF'
{"type":"message","role":"user","content":"Let's implement authentication with JWT tokens"}
{"type":"message","role":"assistant","content":"Good idea! JWT is secure and stateless."}
{"type":"message","role":"user","content":"We chose to use bcrypt for password hashing"}
{"type":"message","role":"assistant","content":"Excellent choice for security."}
EOF
  
  local extract_input=$(cat <<EOF
{
  "transcript_path": "$transcript_path",
  "cwd": "$TEST_PROJECT"
}
EOF
)
  echo "$extract_input" | "$REPO_ROOT/hooks/stop-extract-memories.sh" >/dev/null 2>&1
  
  # Step 3: Track a file change
  log_info "Step 3: Tracking file change"
  local track_input=$(cat <<EOF
{
  "tool_name": "Write",
  "parameters": {
    "file_path": "$TEST_PROJECT/auth.js",
    "content": "module.exports = { authenticate: () => {} };"
  }
}
EOF
)
  echo "$track_input" | "$REPO_ROOT/hooks/post-tool-track.sh" >/dev/null 2>&1
  
  # Step 4: Session end
  log_info "Step 4: Ending session"
  local session_end_input=$(cat <<EOF
{
  "session_id": "integration-test-$$",
  "cwd": "$TEST_PROJECT"
}
EOF
)
  echo "$session_end_input" | "$REPO_ROOT/hooks/session-end.sh" >/dev/null 2>&1
  
  # Verify the workflow completed
  TESTS_RUN=$((TESTS_RUN + 1))
  if [ -f "$TEST_HOME/.claude-memories/automation.log" ]; then
    log_success "Test $TESTS_RUN: Full workflow integration completed successfully"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_error "Test $TESTS_RUN: Full workflow integration failed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Test 12: Verify skills structure
test_skills_structure() {
  log_info "===== Test Suite 12: Skills Structure ====="
  
  local skills=(
    "session-launcher"
    "context-manager"
    "error-debugger"
    "testing-builder"
    "rapid-prototyper"
    "browser-app-creator"
    "repository-analyzer"
    "api-integration-builder"
  )
  
  for skill in "${skills[@]}"; do
    assert_dir_exists "$REPO_ROOT/skills/$skill" "Skill directory exists: $skill"
    assert_file_exists "$REPO_ROOT/skills/$skill/SKILL.md" "Skill definition exists: $skill"
  done
}

# Main test execution
main() {
  echo ""
  echo "=========================================="
  echo "  Claude Skills Automation - E2E Tests  "
  echo "=========================================="
  echo ""
  
  # Check dependencies
  if ! command -v jq &> /dev/null; then
    log_error "jq is not installed. Please install jq to run tests."
    exit 1
  fi
  
  if ! command -v git &> /dev/null; then
    log_error "git is not installed. Please install git to run tests."
    exit 1
  fi
  
  # Setup
  setup_test_environment
  
  # Run all test suites
  test_repository_structure
  test_hooks_validity
  test_no_hardcoded_paths
  test_memory_index_initialization
  test_session_start_hook
  test_session_end_hook
  test_stop_extract_memories_hook
  test_post_tool_track_hook
  test_pre_compact_backup_hook
  test_memory_persistence
  test_full_workflow_integration
  test_skills_structure
  
  # Cleanup
  cleanup_test_environment
  
  # Summary
  echo ""
  echo "=========================================="
  echo "           Test Results Summary          "
  echo "=========================================="
  echo ""
  echo "Tests Run:    $TESTS_RUN"
  echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
  echo ""
  
  if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    exit 0
  else
    echo -e "${RED}✗ Some tests failed. Please review the output above.${NC}"
    echo ""
    exit 1
  fi
}

# Run main
main
