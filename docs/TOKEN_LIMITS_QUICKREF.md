# Token Limits Quick Reference

## Config File Location
```
~/.config/claude-code/automation.conf
```

## Quick Settings Reference

### Item Limits
```bash
MAX_INJECTED_DECISIONS=10      # Recent decisions (last 7 days)
MAX_INJECTED_BLOCKERS=5        # Active blockers
MAX_INJECTED_CONTEXT=3         # Context items (last 14 days)
MAX_INJECTED_PREFERENCES=10    # Project preferences
MAX_INJECTED_PROCEDURES=5      # Procedures (disabled by default)
```

### Token Budget
```bash
TOKEN_LIMIT_ESTIMATE=2000      # ~8000 characters
```

### Time Windows
```bash
DECISIONS_LOOKBACK_DAYS=7      # How far back for decisions
CONTEXT_LOOKBACK_DAYS=14       # How far back for context
BLOCKERS_ACTIVE_ONLY=true      # Only active blockers?
```

### Feature Toggles
```bash
INJECT_DECISIONS=true          # Enable/disable decisions
INJECT_BLOCKERS=true           # Enable/disable blockers
INJECT_CONTEXT=true            # Enable/disable context
INJECT_PREFERENCES=true        # Enable/disable preferences
INJECT_PROCEDURES=false        # Enable/disable procedures
INJECT_LAST_TOPIC=true         # Enable/disable last topic
```

### Logging
```bash
VERBOSE_LOGGING=false          # Debug output
SHOW_TOKEN_ESTIMATES=true      # Show token counts in logs
WARN_ON_LIMIT_EXCEEDED=true    # Warn on limit breach
```

## Common Adjustments

### Hitting Token Limits?
```bash
# Reduce limits
MAX_INJECTED_DECISIONS=5
MAX_INJECTED_CONTEXT=2
INJECT_PROCEDURES=false
```

### Need More Context?
```bash
# Increase limits
MAX_INJECTED_DECISIONS=15
MAX_INJECTED_BLOCKERS=8
TOKEN_LIMIT_ESTIMATE=3000
```

### Missing Recent Info?
```bash
# Extend lookback
DECISIONS_LOOKBACK_DAYS=14
CONTEXT_LOOKBACK_DAYS=21
```

## Check Token Usage
```bash
# View logs
tail -f ~/.claude-memories/automation.log

# Look for:
# [SessionStart] Estimated tokens: 1842 (limit: 2000)
```

## Priority Order
1. Active Blockers (highest)
2. Last Working Topic
3. Project Preferences
4. Recent Decisions
5. Context Items
6. Procedures (lowest)

## Token Estimation
- **4 characters ≈ 1 token**
- 2000 token limit ≈ 8000 characters
- Rough estimate, may vary ±20%

## Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| Too much context | Reduce `MAX_INJECTED_*` values |
| Missing context | Increase `MAX_INJECTED_*` values |
| Token warnings | Reduce limits or increase `TOKEN_LIMIT_ESTIMATE` |
| Old decisions | Decrease `DECISIONS_LOOKBACK_DAYS` |
| Config not loading | Check syntax in config file |

## Preset Configurations

### Minimal (1000 tokens)
```bash
MAX_INJECTED_DECISIONS=5
MAX_INJECTED_BLOCKERS=3
MAX_INJECTED_CONTEXT=2
TOKEN_LIMIT_ESTIMATE=1000
INJECT_PROCEDURES=false
```

### Standard (2000 tokens) - Default
```bash
MAX_INJECTED_DECISIONS=10
MAX_INJECTED_BLOCKERS=5
MAX_INJECTED_CONTEXT=3
TOKEN_LIMIT_ESTIMATE=2000
INJECT_PROCEDURES=false
```

### Generous (3000 tokens)
```bash
MAX_INJECTED_DECISIONS=15
MAX_INJECTED_BLOCKERS=8
MAX_INJECTED_CONTEXT=5
TOKEN_LIMIT_ESTIMATE=3000
INJECT_PROCEDURES=true
MAX_INJECTED_PROCEDURES=10
```

## Quick Edit
```bash
nano ~/.config/claude-code/automation.conf
```

## Test Changes
Changes take effect on next session start. Start a new Claude session to test.

---

For detailed documentation, see [TOKEN_LIMITS_GUIDE.md](TOKEN_LIMITS_GUIDE.md)
