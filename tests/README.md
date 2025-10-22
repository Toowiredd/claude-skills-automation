# End-to-End Test Suite

Comprehensive E2E test suite for Claude Skills Automation.

## Overview

This test suite validates the entire automation workflow, including:

- Repository structure and documentation
- All hooks (core and integration)
- Hook execution and functionality
- Memory persistence and management
- Full workflow integration
- Skills structure

## Running Tests

### Quick Start

```bash
# Run all tests
./tests/e2e-test-suite.sh
```

### What Gets Tested

#### Test Suite 1: Repository Structure
- Verifies all required directories exist (hooks, skills, scripts, docs)
- Checks for essential files (README, CHANGELOG, CONTRIBUTING, LICENSE)

#### Test Suite 2: Hooks Validity
- Validates all 13 hooks exist
- Confirms hooks are executable
- Checks Bash syntax validity

#### Test Suite 3: No Hardcoded Paths
- Ensures no `/home/toowired` hardcoded paths remain
- Validates all hooks use `$HOME` variable

#### Test Suite 4: Memory Index Initialization
- Creates test memory index
- Validates JSON structure

#### Test Suite 5-9: Individual Hook Tests
- **session-start.sh**: Context restoration
- **session-end.sh**: Session state saving
- **stop-extract-memories.sh**: Decision/blocker extraction
- **post-tool-track.sh**: File change tracking
- **pre-compact-backup.sh**: Backup creation

#### Test Suite 10: Memory Persistence
- Validates memory index remains intact
- Checks data structure integrity

#### Test Suite 11: Full Workflow Integration
- Complete end-to-end workflow:
  1. Session start
  2. Memory extraction
  3. File tracking
  4. Session end
- Validates all components work together

#### Test Suite 12: Skills Structure
- Verifies all 8 skills exist
- Checks SKILL.md files are present

## Test Results

When all tests pass, you'll see:

```
==========================================
           Test Results Summary          
==========================================

Tests Run:    89
Tests Passed: 89
Tests Failed: 0

✓ All tests passed!
```

## Test Environment

Tests run in an isolated environment:
- Test root: `/tmp/claude-automation-e2e-test-$$`
- Test home: Separate from your actual `$HOME`
- Test project: Temporary Git repository

All test artifacts are cleaned up after execution.

## Dependencies

- `bash` (4.0+)
- `jq` (for JSON processing)
- `git` (for repository operations)

## Test Output

Tests use color-coded output:
- 🔵 **Blue [INFO]**: Informational messages
- 🟢 **Green [✓]**: Test passed
- 🔴 **Red [✗]**: Test failed
- 🟡 **Yellow [!]**: Warning

## Exit Codes

- `0`: All tests passed
- `1`: One or more tests failed

## Integration with CI/CD

This test suite is designed to run in CI/CD environments. See `.github/workflows/test-hooks.yml` for GitHub Actions integration.

## Troubleshooting

### Tests Failing?

1. **Check dependencies**: Ensure `jq` and `git` are installed
   ```bash
   jq --version
   git --version
   ```

2. **Verify hook permissions**: All hooks should be executable
   ```bash
   ls -l hooks/*.sh
   ```

3. **Check for hardcoded paths**: 
   ```bash
   grep -r "/home/toowired" hooks/
   ```
   Should return no results.

### Adding New Tests

To add new tests:

1. Create a new test function following the pattern:
   ```bash
   test_new_feature() {
     log_info "===== Test Suite N: New Feature ====="
     # Your test logic here
     assert_file_exists "$file" "Description"
   }
   ```

2. Add the function call in `main()`:
   ```bash
   test_new_feature
   ```

3. Use assertion functions:
   - `assert_file_exists`
   - `assert_dir_exists`
   - `assert_executable`
   - `assert_valid_json`
   - `assert_valid_bash_syntax`
   - `assert_contains`
   - `assert_not_contains`

## Test Coverage

Current coverage:
- ✅ All core hooks (5/5)
- ✅ All integration hooks (8/8)
- ✅ All skills (8/8)
- ✅ Repository structure
- ✅ No hardcoded paths
- ✅ Memory persistence
- ✅ Full workflow integration

## Performance

Test suite executes in approximately 5-10 seconds on average hardware.

## Contributing

When adding new features:
1. Add corresponding tests
2. Update this README
3. Ensure all tests pass before submitting PR

## Security

Tests run in isolated environments and do not affect your production configuration or data.

---

**Questions?** See [CONTRIBUTING.md](../CONTRIBUTING.md) or open an issue.
