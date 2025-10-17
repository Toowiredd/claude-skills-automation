# Contributing to Claude Skills Automation

Thank you for your interest in contributing! This project was built for and by the neurodivergent developer community.

## 🎯 Ways to Contribute

### 1. Report Issues
- Bug reports
- Feature requests
- Documentation improvements
- Performance issues

### 2. Submit Pull Requests
- New extraction patterns
- Additional hooks
- New skills
- Documentation updates
- Bug fixes

### 3. Share Feedback
- What's working well
- What could be improved
- Your use cases
- Success stories

---

## 🚀 Quick Start for Contributors

### Setup Development Environment

```bash
# Fork and clone
git clone https://github.com/toowiredd/claude-skills-automation
cd claude-skills-automation

# Install (to test hooks)
bash scripts/install.sh

# Make changes
# Test thoroughly
# Submit PR
```

### Testing Changes

1. **Test hooks locally**:
   ```bash
   # Test manually
   echo '{"session_id":"test","cwd":"'$PWD'"}' | hooks/session-start.sh
   ```

2. **Test in Claude Code**:
   - Install your changes
   - Start new Claude Code session
   - Verify automation works
   - Check logs: `tail -f ~/.claude-memories/automation.log`

---

## 📝 Contribution Guidelines

### Code Style

**Bash Scripts**:
- Use `#!/usr/bin/env bash`
- Enable strict mode: `set -euo pipefail`
- Add logging to automation.log
- Handle errors gracefully
- Add comments for complex logic

**Example**:
```bash
#!/usr/bin/env bash
# Description of what this hook does

set -euo pipefail

LOG_FILE="/home/toowired/.claude-memories/automation.log"

log() {
  echo "[$(date -Iseconds)] [HookName] $1" >> "$LOG_FILE"
}

main() {
  log "Hook starting..."

  # Hook logic here

  log "Hook complete"
  exit 0
}

main
```

### Documentation

- Update README.md if adding features
- Add comments in code
- Update relevant docs/ files
- Include examples

### Commit Messages

Use conventional commits:
```
feat: add new decision extraction pattern
fix: resolve memory index corruption issue
docs: improve installation instructions
test: add hook testing script
```

---

## 🎯 Priority Areas

### High Priority

1. **New Extraction Patterns**
   - Language-specific patterns (Python, JavaScript, etc.)
   - Framework-specific patterns (React, Django, etc.)
   - Domain-specific patterns (DevOps, data science, etc.)

2. **Additional Hooks**
   - UserPromptSubmit (context injection)
   - Notification hook examples
   - SubagentStop integration

3. **Testing Infrastructure**
   - Automated hook testing
   - Integration tests
   - Performance benchmarks

### Medium Priority

1. **New Skills**
   - Additional properly-formatted Claude Skills
   - Skills for specific workflows

2. **Documentation**
   - Video tutorials
   - Blog posts
   - Translations

3. **Integrations**
   - Pieces.app implementation
   - Other tool integrations

---

## 🔍 Pull Request Process

### Before Submitting

1. **Test thoroughly**
   - Test your changes locally
   - Verify no regressions
   - Check performance impact
   - Update documentation

2. **Code quality**
   - Follow code style guidelines
   - Add comments
   - Handle errors
   - Add logging

3. **Documentation**
   - Update README if needed
   - Add examples
   - Update changelog

### Submitting

1. **Create PR with clear description**:
   ```markdown
   ## What
   Brief description of changes

   ## Why
   Problem being solved

   ## How
   Technical approach

   ## Testing
   How you tested it

   ## Screenshots
   If UI changes
   ```

2. **Reference related issues**: "Fixes #123" or "Closes #456"

3. **Request review**

### After Submission

1. **Respond to feedback**
2. **Make requested changes**
3. **Re-test after updates**
4. **Merge after approval**

---

## 🐛 Bug Reports

### Good Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., Ubuntu 22.04]
- Claude Code version: [e.g., 1.0.0]
- Bash version: `bash --version`
- jq version: `jq --version`

## Logs
```
# Relevant logs from automation.log
```

## Screenshots
If applicable
```

---

## 💡 Feature Requests

### Good Feature Request Template

```markdown
## Feature Description
Clear description of the feature

## Use Case
Why is this needed? What problem does it solve?

## Proposed Solution
How might this work?

## Alternatives Considered
Other approaches you thought about

## Additional Context
Anything else relevant
```

---

## 🧪 Testing Guidelines

### Manual Testing Checklist

Before submitting PR, test:

- [ ] Hooks install correctly
- [ ] Hooks execute without errors
- [ ] Hooks produce expected output
- [ ] Logs are created properly
- [ ] Memory is saved/loaded correctly
- [ ] No performance regression
- [ ] Documentation is accurate
- [ ] Examples work as described

### Automated Testing (Future)

We plan to add:
- Hook unit tests
- Integration tests
- Performance benchmarks

---

## 📚 Documentation Standards

### Code Comments

```bash
# What this function does
function_name() {
  # Why this step is necessary
  step_one

  # Edge case handling
  if [ condition ]; then
    handle_edge_case
  fi
}
```

### Documentation Files

- Use markdown
- Include code examples
- Add visual diagrams when helpful
- Keep examples realistic
- Test all examples

---

## 🌍 Translation Guidelines

Translations welcome for:
- README.md
- Documentation files
- Hook messages (if language-specific)

### Translation Checklist

- [ ] Maintain formatting
- [ ] Keep code blocks in English
- [ ] Translate examples contextually
- [ ] Update file links
- [ ] Native speaker review

---

## 🤝 Community Guidelines

### Be Respectful

- Assume good intent
- Be patient with newcomers
- Provide constructive feedback
- Celebrate contributions

### Neurodivergent-Friendly

This project prioritizes:
- Clear, direct communication
- Written over verbal
- Explicit over implicit
- Concrete examples over abstractions

### Code of Conduct

- Be kind and respectful
- Welcome diverse perspectives
- Focus on what's best for the community
- No harassment or discrimination

---

## 📞 Questions?

- **General questions**: [GitHub Discussions](https://github.com/toowiredd/claude-skills-automation/discussions)
- **Bug reports**: [GitHub Issues](https://github.com/toowiredd/claude-skills-automation/issues)
- **Security issues**: Email lewistys420@gmail.com

---

## 🎉 Recognition

All contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Thanked publicly

Thank you for helping make development more accessible for neurodivergent developers! 🙏
