# Token Limits Guide

## Overview

The Claude Skills Automation system now includes **configurable token limits** to prevent context window overflow. This ensures that automatic context injection stays within reasonable bounds and doesn't overwhelm your Claude sessions.

## Quick Start

### Default Configuration
The system comes with sensible defaults that work for most use cases:
- **10 recent decisions** (last 7 days)
- **5 active blockers**
- **3 context items** (last 14 days)
- **10 project preferences**
- **5 procedures** (disabled by default)
- **~2000 token budget** (~8000 characters)

### Configuration File Location
```
~/.config/claude-code/automation.conf
```

## Configuration Options

### Token Limit Controls

#### `MAX_INJECTED_DECISIONS` (default: 10)
Maximum number of recent decisions to inject into session context.
- **Recommended range:** 5-20
- **When to increase:** If you make many small decisions and need more history
- **When to decrease:** If decisions are verbose or you're hitting token limits

#### `MAX_INJECTED_BLOCKERS` (default: 5)
Maximum number of blockers to show.
- **Recommended range:** 3-10
- **When to increase:** If you typically have many active blockers
- **When to decrease:** If blockers are detailed and consuming too much space

#### `MAX_INJECTED_CONTEXT` (default: 3)
Maximum number of context items to inject.
- **Recommended range:** 2-5
- **When to increase:** For complex projects with many moving parts
- **When to decrease:** If context items are lengthy

#### `MAX_INJECTED_PREFERENCES` (default: 10)
Maximum number of project preferences to inject.
- **Recommended range:** 5-15
- **When to increase:** If you have many specific project conventions
- **When to decrease:** Rarely needed

#### `MAX_INJECTED_PROCEDURES` (default: 5)
Maximum number of procedures to inject.
- **Recommended range:** 3-10
- **Note:** Procedures are disabled by default (`INJECT_PROCEDURES=false`)

#### `TOKEN_LIMIT_ESTIMATE` (default: 2000)
Rough estimate of maximum tokens to inject (4 characters ≈ 1 token).
- **Recommended range:** 1000-3000
- **When to increase:** If you have a large context window and need more context
- **When to decrease:** If you're experiencing context overflow or want to be conservative

### Time-Based Filtering

#### `DECISIONS_LOOKBACK_DAYS` (default: 7)
How many days back to look for relevant decisions.
- **Recommended range:** 3-14 days
- **Use case:** Shorter for fast-moving projects, longer for slower projects

#### `BLOCKERS_ACTIVE_ONLY` (default: true)
Whether to show only active blockers or include recent resolved ones.
- **Set to `true`:** Only show active blockers (recommended)
- **Set to `false`:** Show all blockers from the last `DECISIONS_LOOKBACK_DAYS`

#### `CONTEXT_LOOKBACK_DAYS` (default: 14)
How many days back to look for context items.
- **Recommended range:** 7-30 days
- **Use case:** Longer for projects with stable context, shorter for rapidly evolving projects

### Feature Toggles

Enable or disable specific types of context injection:

```bash
INJECT_DECISIONS=true       # Recent decisions
INJECT_BLOCKERS=true        # Active blockers
INJECT_CONTEXT=true         # Context items
INJECT_PREFERENCES=true     # Project preferences
INJECT_PROCEDURES=false     # Standard procedures (verbose)
INJECT_LAST_TOPIC=true      # Last working topic
```

**Pro tip:** If you're hitting token limits, disable `INJECT_PROCEDURES` and `INJECT_CONTEXT` first.

### Advanced Settings

#### `VERBOSE_LOGGING` (default: false)
Enable detailed logging for debugging configuration issues.
```bash
VERBOSE_LOGGING=true
```

#### `SHOW_TOKEN_ESTIMATES` (default: true)
Log estimated token usage with each session start.
```bash
SHOW_TOKEN_ESTIMATES=true
```

#### `WARN_ON_LIMIT_EXCEEDED` (default: true)
Log warnings when estimated tokens exceed the configured limit.
```bash
WARN_ON_LIMIT_EXCEEDED=true
```

## Usage Examples

### Example 1: Conservative Configuration (Low Token Usage)
```bash
# ~/.config/claude-code/automation.conf
MAX_INJECTED_DECISIONS=5
MAX_INJECTED_BLOCKERS=3
MAX_INJECTED_CONTEXT=2
MAX_INJECTED_PREFERENCES=5
TOKEN_LIMIT_ESTIMATE=1000
INJECT_PROCEDURES=false
```

**Best for:** Simple projects, limited context needs

### Example 2: Generous Configuration (High Context)
```bash
# ~/.config/claude-code/automation.conf
MAX_INJECTED_DECISIONS=20
MAX_INJECTED_BLOCKERS=10
MAX_INJECTED_CONTEXT=5
MAX_INJECTED_PREFERENCES=15
MAX_INJECTED_PROCEDURES=10
TOKEN_LIMIT_ESTIMATE=3000
INJECT_PROCEDURES=true
```

**Best for:** Complex projects, large context windows

### Example 3: Blocker-Focused Configuration
```bash
# ~/.config/claude-code/automation.conf
MAX_INJECTED_DECISIONS=5
MAX_INJECTED_BLOCKERS=15
MAX_INJECTED_CONTEXT=2
INJECT_PREFERENCES=false
INJECT_PROCEDURES=false
```

**Best for:** Projects with many blockers, focused troubleshooting

### Example 4: Decision History Configuration
```bash
# ~/.config/claude-code/automation.conf
MAX_INJECTED_DECISIONS=25
DECISIONS_LOOKBACK_DAYS=14
MAX_INJECTED_BLOCKERS=3
INJECT_CONTEXT=false
INJECT_PROCEDURES=false
```

**Best for:** Design-heavy projects, architecture decisions

## Priority Order

When building context, items are injected in this priority order:

1. **Active Blockers** (highest priority)
2. **Last Working Topic**
3. **Project Preferences**
4. **Recent Decisions**
5. **Context Items**
6. **Procedures** (lowest priority)

This ensures critical information appears first, even if token limits require truncation.

## Monitoring Token Usage

### Check Logs
```bash
tail -f ~/.claude-memories/automation.log
```

Look for lines like:
```
[2025-10-17T10:30:00+00:00] [SessionStart] Estimated tokens: 1842 (limit: 2000)
[2025-10-17T10:30:00+00:00] [SessionStart] Injecting context: 156 lines, ~1842 tokens
```

### Enable Verbose Logging
Add to your config:
```bash
VERBOSE_LOGGING=true
SHOW_TOKEN_ESTIMATES=true
```

### Watch for Warnings
If you see:
```
WARNING: Estimated tokens (2543) exceeds limit (2000)
Consider reducing MAX_INJECTED_* values
```

Then adjust your configuration accordingly.

## Troubleshooting

### Problem: Context is too verbose
**Solution:** Reduce `MAX_INJECTED_*` values or disable `INJECT_PROCEDURES`

### Problem: Missing important context
**Solution:** Increase `MAX_INJECTED_DECISIONS` or relevant category limits

### Problem: Token limit warnings
**Solution:** Either increase `TOKEN_LIMIT_ESTIMATE` or reduce injection limits

### Problem: Not seeing recent decisions
**Solution:** Increase `DECISIONS_LOOKBACK_DAYS`

### Problem: Too many old context items
**Solution:** Decrease `CONTEXT_LOOKBACK_DAYS`

### Problem: Configuration not loading
**Solution:** Check file exists at `~/.config/claude-code/automation.conf` and has no syntax errors

## How Token Estimation Works

The system uses a simple heuristic:
- **4 characters ≈ 1 token**
- This is a rough estimate and may vary

**Why this works:**
- English text averages ~4-5 characters per token
- This gives a conservative estimate
- Better to underestimate than overflow

**Limitations:**
- Actual token count may vary by ±20%
- Special characters and code may use fewer tokens
- Long words may use more tokens

## Performance Considerations

### Memory vs Performance
- Higher limits = more context but slower processing
- Lower limits = less context but faster sessions

### Recommended Settings by Use Case

| Use Case | Token Limit | Decisions | Blockers | Context |
|----------|-------------|-----------|----------|---------|
| **Quick Scripts** | 1000 | 5 | 3 | 2 |
| **Standard Project** | 2000 | 10 | 5 | 3 |
| **Complex System** | 3000 | 15 | 8 | 5 |
| **Enterprise** | 4000 | 20 | 10 | 7 |

## Best Practices

1. **Start with defaults** - They work for 80% of use cases
2. **Monitor logs** - Watch token usage for a few sessions
3. **Adjust gradually** - Change one setting at a time
4. **Test changes** - Start a new session to see effects
5. **Document changes** - Add comments in your config file
6. **Review periodically** - As projects evolve, so should limits

## Advanced: Per-Project Configuration

While not directly supported, you can create a wrapper script:

```bash
#!/bin/bash
# ~/.config/claude-code/hooks/session-start-wrapper.sh

PROJECT_CONFIG="$HOME/.claude-memories/$(basename "$PWD")-config.conf"

# Load project-specific config if it exists
if [ -f "$PROJECT_CONFIG" ]; then
  source "$PROJECT_CONFIG"
fi

# Run the actual session-start hook
~/.config/claude-code/hooks/session-start.sh
```

Then create project-specific configs:
```bash
# ~/.claude-memories/my-project-config.conf
MAX_INJECTED_DECISIONS=20
TOKEN_LIMIT_ESTIMATE=3000
```

## FAQ

**Q: What happens if I exceed the token limit?**
A: The system logs a warning but still injects the context. Claude will handle it, but you may experience performance issues.

**Q: Can I disable all context injection?**
A: Yes, set all `INJECT_*` flags to `false`.

**Q: Does this affect manual context injection?**
A: No, only automatic session-start injection is affected.

**Q: How do I reset to defaults?**
A: Delete `~/.config/claude-code/automation.conf` and run `install.sh` again.

**Q: Can I use different limits for different projects?**
A: Not directly, but see "Advanced: Per-Project Configuration" above.

## Related Documentation

- [AUTOMATION_IMPLEMENTATION.md](../AUTOMATION_IMPLEMENTATION.md) - Full automation guide
- [USAGE_GUIDE.md](../USAGE_GUIDE.md) - General usage instructions
- [config/automation.conf](../config/automation.conf) - Default configuration file

## Support

If you encounter issues:
1. Check logs: `~/.claude-memories/automation.log`
2. Enable verbose logging: `VERBOSE_LOGGING=true`
3. Verify config syntax: `cat ~/.config/claude-code/automation.conf`
4. Test with defaults: Temporarily rename your config file
5. Review this guide for troubleshooting tips

---

**Remember:** The goal is to provide helpful context without overwhelming Claude. Start conservative and adjust based on your actual needs.
