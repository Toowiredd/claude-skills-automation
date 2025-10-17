# Claude Skills Automation - Research & Conceptualization

**Date**: 2025-10-17
**Purpose**: Investigate and design automation mechanisms for Claude Skills
**Goal**: Reduce friction and make memory/context management fully automatic

---

## Research Findings

### 1. Claude Skills Architecture

**Model-Invoked (Reactive)**:
- Skills activate based on conversational context
- Claude autonomously decides when to use skills
- Triggered by description keywords matching user requests
- **Cannot run in background or proactively**

**Limitations**:
- ❌ No built-in file watchers
- ❌ No scheduled execution
- ❌ No background processes
- ❌ No event-driven triggers
- ❌ No proactive monitoring

**Capabilities**:
- ✅ Contextual activation (description matching)
- ✅ Cross-skill communication (one skill can reference another)
- ✅ Access to full conversation context
- ✅ Can read/write files via Claude Code tools

### 2. Claude Code Hooks (KEY AUTOMATION MECHANISM)

**Available Hooks**:

| Hook | When It Fires | Automation Potential |
|------|---------------|---------------------|
| **SessionStart** | Conversation begins | ⭐⭐⭐⭐⭐ Auto-restore context |
| **SessionEnd** | Conversation ends | ⭐⭐⭐⭐⭐ Auto-save state |
| **UserPromptSubmit** | User sends message | ⭐⭐⭐⭐ Inject context, detect patterns |
| **Stop** | Claude finishes response | ⭐⭐⭐⭐ Auto-save memories |
| **PostToolUse** | After tool execution | ⭐⭐⭐ Auto-save after edits |
| **PreToolUse** | Before tool execution | ⭐⭐ Inject relevant memories |
| **PreCompact** | Before context compression | ⭐⭐ Save important context |
| **SubagentStop** | Subagent completes | ⭐ Track complex tasks |

**Hook Capabilities**:
- ✅ Execute arbitrary bash commands
- ✅ Receive JSON input via stdin
- ✅ Return JSON output for control
- ✅ Can block or allow operations (exit code 2 vs 0)
- ✅ Can inject additional context into conversation
- ❌ Cannot directly invoke skills (but can inject prompts)

**Hook Configuration**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/automation-script.sh"
          }
        ]
      }
    ]
  }
}
```

### 3. External Automation Possibilities

**File Watchers** (External tools):
- `inotifywait` (Linux) - Watch for file changes
- `fswatch` (macOS/Linux) - Cross-platform file monitoring
- Node.js `chokidar` - JavaScript file watching
- Can trigger scripts when files change

**Cron/Scheduled Tasks**:
- Daily backup of memories
- Weekly memory cleanup/archiving
- Periodic memory indexing/optimization

**Shell Scripts**:
- Pre-process context before session
- Post-process conversation logs
- Automated memory extraction from git commits

---

## Automation Levels

### Level 1: Hook-Based Automation (IMMEDIATE)

**Description**: Use Claude Code hooks to automate memory/context operations

**Capabilities**:
- Auto-restore context on session start
- Auto-save state on session end
- Auto-detect and save decisions during conversation
- Auto-inject relevant memories before tool use

**Implementation**: Configuration files + bash scripts

### Level 2: File-Based Automation (NEAR-TERM)

**Description**: External scripts monitor filesystem and maintain memory

**Capabilities**:
- Watch project files for changes
- Auto-extract decisions from git commits
- Auto-update memory index when files change
- Periodic backups and cleanup

**Implementation**: File watchers + automation scripts

### Level 3: Proactive Context Injection (MEDIUM-TERM)

**Description**: Analyze user prompts and inject context before Claude sees them

**Capabilities**:
- Detect topics mentioned in prompts
- Search memory for relevant context
- Inject context into prompt automatically
- Reduce need for explicit "recall" commands

**Implementation**: UserPromptSubmit hook + semantic search

### Level 4: Intelligent Memory Extraction (ADVANCED)

**Description**: AI-powered analysis of conversations to extract memories

**Capabilities**:
- Automatically detect decisions in conversation
- Extract blockers without explicit tagging
- Infer preferences from behavior
- Build knowledge graph of project decisions

**Implementation**: Post-conversation processing + LLM analysis

---

## Conceptual Automation Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Claude Code Session                       │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ SessionStart Hook                                       │ │
│  │ → Run: restore-context.sh                              │ │
│  │ → Loads: memory index, session state, recent decisions│ │
│  │ → Injects: "Context restored: {summary}"              │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ UserPromptSubmit Hook                                   │ │
│  │ → Analyzes: User prompt for keywords                   │ │
│  │ → Searches: Memory index for relevant context         │ │
│  │ → Injects: Related decisions/procedures automatically │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Conversation (Skills Active)                           │ │
│  │ • session-launcher skill                               │ │
│  │ • context-manager skill                                │ │
│  │ • error-debugger skill                                 │ │
│  │ • testing-builder skill                                │ │
│  │ • rapid-prototyper skill                               │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ PostToolUse Hook (after Edit, Write, etc.)            │ │
│  │ → Detects: File modifications                          │ │
│  │ → Extracts: Changes that look like decisions          │ │
│  │ → Saves: To memory if significant                     │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Stop Hook (conversation ends)                          │ │
│  │ → Analyzes: Conversation for decisions/blockers       │ │
│  │ → Extracts: Important memories automatically          │ │
│  │ → Saves: Session state, updated index                 │ │
│  └────────────────────────────────────────────────────────┘ │
│                           ↓                                  │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ SessionEnd Hook                                        │ │
│  │ → Saves: Final session state                          │ │
│  │ → Updates: Project-specific session files             │ │
│  │ → Triggers: Backup script                             │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              Background Automation (External)                │
│                                                              │
│  • File Watcher → Monitor project files for changes        │
│  • Daily Cron → Backup memories, optimize index            │
│  • Git Hook → Extract decisions from commits               │
│  • Memory Indexer → Update search indexes                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Automation Patterns

### Pattern 1: Automatic Context Restoration

**Problem**: User has to say "hi-ai" every session
**Solution**: SessionStart hook automatically injects context

**Implementation**:
```bash
# ~/.config/claude-code/hooks/session-start.sh
#!/bin/bash

# Load memory index
MEMORY_INDEX="/home/toowired/.claude-memories/index.json"
CURRENT_SESSION="/home/toowired/.claude-sessions/current.json"

# Extract recent context
RECENT_DECISIONS=$(jq -r '.memories[] | select(.type == "DECISION") | select(.timestamp > (now - 604800)) | .content' "$MEMORY_INDEX" | head -5)

ACTIVE_BLOCKERS=$(jq -r '.memories[] | select(.type == "BLOCKER" and .status == "active") | .content' "$MEMORY_INDEX")

# Inject into conversation as invisible system context
cat <<EOF
{
  "type": "inject_context",
  "context": "Recent decisions: $RECENT_DECISIONS\nActive blockers: $ACTIVE_BLOCKERS"
}
EOF
```

**Claude Code Hook Config**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/home/toowired/.config/claude-code/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Result**: Context automatically restored without user saying "hi-ai"

### Pattern 2: Automatic Memory Extraction

**Problem**: User has to explicitly say "remember X"
**Solution**: Stop hook analyzes conversation and extracts memories

**Implementation**:
```bash
# ~/.config/claude-code/hooks/auto-extract-memories.sh
#!/bin/bash

# Receive conversation from stdin (JSON)
CONVERSATION=$(cat)

# Look for decision patterns
DECISIONS=$(echo "$CONVERSATION" | jq -r '.messages[] | select(.content | test("using|chose|decided|going with"; "i")) | .content')

# Extract and save to memory
if [ -n "$DECISIONS" ]; then
  MEMORY_INDEX="/home/toowired/.claude-memories/index.json"

  # Generate UUID for memory
  UUID=$(uuidgen)

  # Add to index (simplified - real version would be more robust)
  echo "Detected decision: $DECISIONS" >> /tmp/auto-memories.log

  # TODO: Update index.json with proper JSON manipulation
fi
```

**Result**: Decisions automatically detected and saved

### Pattern 3: Proactive Context Injection

**Problem**: Relevant past context not available when needed
**Solution**: UserPromptSubmit hook searches and injects context

**Implementation**:
```bash
# ~/.config/claude-code/hooks/inject-context.sh
#!/bin/bash

# Receive user prompt from stdin
USER_PROMPT=$(cat | jq -r '.prompt')

# Extract keywords
KEYWORDS=$(echo "$USER_PROMPT" | grep -oE '\w{4,}' | tr '[:upper:]' '[:lower:]')

# Search memory index for relevant context
MEMORY_INDEX="/home/toowired/.claude-memories/index.json"
RELEVANT_MEMORIES=""

for KEYWORD in $KEYWORDS; do
  MATCHES=$(jq -r --arg keyword "$KEYWORD" '.memories[] | select(.tags[]? | ascii_downcase | contains($keyword)) | .content' "$MEMORY_INDEX" 2>/dev/null)
  if [ -n "$MATCHES" ]; then
    RELEVANT_MEMORIES="$RELEVANT_MEMORIES\n$MATCHES"
  fi
done

# Inject context if found
if [ -n "$RELEVANT_MEMORIES" ]; then
  cat <<EOF
{
  "type": "inject_context",
  "context": "Relevant past context:\n$RELEVANT_MEMORIES"
}
EOF
fi
```

**Result**: Relevant memories automatically injected based on prompt keywords

### Pattern 4: Automatic File-Based Memory

**Problem**: Decisions in files (DECISIONS.md, README) not synced to memory
**Solution**: File watcher monitors project files and updates memory

**Implementation**:
```bash
# ~/bin/watch-project-files.sh
#!/bin/bash

PROJECT_DIR="$1"
MEMORY_INDEX="/home/toowired/.claude-memories/index.json"

# Watch for changes to decision-related files
inotifywait -m -e modify,create "$PROJECT_DIR/DECISIONS.md" "$PROJECT_DIR/README.md" |
while read -r directory event filename; do
  echo "Detected change in $filename"

  # Extract new content
  NEW_CONTENT=$(tail -n 10 "$directory/$filename")

  # Check if it looks like a decision
  if echo "$NEW_CONTENT" | grep -qiE "(decided|using|chose|implemented)"; then
    # Add to memory index
    # TODO: Proper JSON manipulation
    echo "Auto-adding to memory: $NEW_CONTENT"
  fi
done
```

**Start on boot**:
```bash
# Add to ~/.profile or systemd service
~/bin/watch-project-files.sh ~/projects/boostbox &
```

**Result**: File changes automatically reflected in memory system

### Pattern 5: Git Commit Memory Extraction

**Problem**: Commit messages contain decisions but aren't captured
**Solution**: Git hook extracts decisions from commits

**Implementation**:
```bash
# .git/hooks/post-commit
#!/bin/bash

COMMIT_MSG=$(git log -1 --pretty=%B)
MEMORY_INDEX="/home/toowired/.claude-memories/index.json"

# Check if commit message contains decision keywords
if echo "$COMMIT_MSG" | grep -qiE "(implement|add|switch to|migrate to|refactor to)"; then
  UUID=$(uuidgen)
  TIMESTAMP=$(date -Iseconds)

  # Extract decision from commit message
  DECISION=$(echo "$COMMIT_MSG" | head -1)

  echo "Auto-saving commit as decision: $DECISION"

  # TODO: Update memory index properly
  # For now, log it
  echo "$TIMESTAMP - $DECISION" >> /home/toowired/.claude-memories/git-extracted-decisions.log
fi
```

**Result**: Git commits automatically create memory entries

---

## Implementation Priority

### Phase 1: Essential Hooks (Week 1)

**Goal**: Automatic session management

**Tasks**:
1. ✅ Create SessionStart hook script
   - Load memory index
   - Load session state
   - Inject context summary

2. ✅ Create SessionEnd hook script
   - Save session state
   - Update current.json
   - Trigger backup

3. ✅ Create Stop hook script
   - Analyze conversation for decisions
   - Extract blockers
   - Update memory index

**Deliverables**:
- 3 bash scripts in ~/.config/claude-code/hooks/
- Hook configuration in Claude Code settings
- Testing and validation

**Impact**:
- 🎯 Zero manual "hi-ai" needed
- 🎯 Automatic session saving
- 🎯 Basic memory extraction

### Phase 2: Proactive Context (Week 2)

**Goal**: Automatic memory injection

**Tasks**:
1. ✅ Create UserPromptSubmit hook
   - Keyword extraction from prompts
   - Memory search by keywords
   - Context injection

2. ✅ Create PostToolUse hook
   - Detect file modifications
   - Extract decisions from code changes
   - Auto-save significant changes

3. ✅ Improve memory search
   - Fuzzy matching
   - Relevance scoring
   - Tag-based search

**Deliverables**:
- 2 additional hook scripts
- Enhanced memory search algorithm
- Relevance scoring system

**Impact**:
- 🎯 Context automatically available when needed
- 🎯 Reduced need for explicit "recall" commands
- 🎯 File changes tracked automatically

### Phase 3: External Automation (Week 3)

**Goal**: Background memory maintenance

**Tasks**:
1. ✅ File watcher for project files
   - Monitor DECISIONS.md, README.md, etc.
   - Extract and index changes
   - Update memory automatically

2. ✅ Git hook integration
   - post-commit hook
   - Extract decisions from commits
   - Add to memory index

3. ✅ Scheduled maintenance
   - Daily backups (cron)
   - Weekly memory optimization
   - Index rebuilding

**Deliverables**:
- File watcher daemon/service
- Git hooks (post-commit, post-merge)
- Cron jobs for maintenance

**Impact**:
- 🎯 Complete automation of memory system
- 🎯 Zero manual memory management
- 🎯 Bulletproof backups

### Phase 4: Advanced Automation (Week 4+)

**Goal**: Intelligent memory extraction

**Tasks**:
1. 🔮 AI-powered decision extraction
   - Use Claude API to analyze conversations
   - Extract decisions/blockers/context
   - Auto-categorize and tag

2. 🔮 Semantic search
   - Embeddings for memory content
   - Similarity-based search
   - Better context matching

3. 🔮 Knowledge graph
   - Link related memories
   - Track decision dependencies
   - Visualize project knowledge

**Deliverables**:
- LLM-powered memory extraction
- Vector database for semantic search
- Knowledge graph visualization

**Impact**:
- 🎯 Near-perfect memory extraction
- 🎯 Intelligent context suggestions
- 🎯 Project knowledge visualization

---

## Technical Specifications

### Hook Script Structure

**Standard template**:
```bash
#!/bin/bash
set -euo pipefail

# Configuration
MEMORY_INDEX="/home/toowired/.claude-memories/index.json"
LOG_FILE="/home/toowired/.claude-memories/automation.log"

# Logging function
log() {
  echo "[$(date -Iseconds)] $1" >> "$LOG_FILE"
}

# Main logic
main() {
  # Read input from stdin if available
  if [ ! -t 0 ]; then
    INPUT=$(cat)
  fi

  # Process...
  log "Hook executed: $0"

  # Output JSON if needed
  if [ -n "${OUTPUT:-}" ]; then
    echo "$OUTPUT"
  fi

  exit 0
}

main "$@"
```

### Memory Index Manipulation

**Using jq for safe JSON updates**:
```bash
# Add new memory
jq --arg id "$UUID" \
   --arg type "DECISION" \
   --arg content "$DECISION" \
   --arg timestamp "$(date -Iseconds)" \
   '.memories += [{
     id: $id,
     type: $type,
     content: $content,
     timestamp: $timestamp,
     tags: [],
     status: "active"
   }] | .total_memories += 1 | .memories_by_type[$type] += 1' \
   "$MEMORY_INDEX" > "$MEMORY_INDEX.tmp" && mv "$MEMORY_INDEX.tmp" "$MEMORY_INDEX"
```

### Hook Configuration

**~/.config/claude-code/settings.json**:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/home/toowired/.config/claude-code/hooks/session-start.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/home/toowired/.config/claude-code/hooks/session-end.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/home/toowired/.config/claude-code/hooks/inject-context.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/home/toowired/.config/claude-code/hooks/extract-memories.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/home/toowired/.config/claude-code/hooks/track-changes.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Automation Benefits

### For ADHD Users
- ✅ **Zero manual overhead** - Everything automatic
- ✅ **No "what was I doing?"** - Context always restored
- ✅ **No friction** - Memory system invisible
- ✅ **Immediate continuation** - Session start is instant

### For SDAM Users
- ✅ **Complete external memory** - No reliance on biological memory
- ✅ **Automatic capture** - All decisions saved without effort
- ✅ **Permanent record** - Nothing is lost
- ✅ **Instant recall** - Past context always available

### For All Users
- ✅ **Reduced cognitive load** - Don't think about memory management
- ✅ **Faster development** - Context always ready
- ✅ **Better decisions** - Past context always visible
- ✅ **Learning system** - Gets smarter over time

---

## Next Steps

### Immediate (Today)
1. ✅ Create automation research document (this file)
2. 📝 Design hook scripts (Phase 1)
3. 📝 Create proof-of-concept SessionStart hook

### This Week
1. 📝 Implement all Phase 1 hooks
2. 📝 Test hook automation
3. 📝 Document hook usage

### Next Week
1. 📝 Implement Phase 2 hooks
2. 📝 Create file watcher system
3. 📝 Build git hook integration

### Ongoing
1. 📝 Monitor and refine automation
2. 📝 Collect user feedback
3. 📝 Iterate on intelligence

---

## Questions for User

1. **Priority**: Which automation is most important?
   - [ ] SessionStart (auto-restore context)
   - [ ] Automatic memory extraction
   - [ ] File watching
   - [ ] All of the above

2. **Invasiveness**: How automatic should it be?
   - [ ] Fully automatic (invisible)
   - [ ] Automatic with notifications
   - [ ] Automatic with confirmation prompts

3. **Git Integration**: Auto-extract from commits?
   - [ ] Yes, automatically
   - [ ] Yes, but ask first
   - [ ] No, manual only

4. **Context Injection**: Auto-inject memories?
   - [ ] Always (aggressive)
   - [ ] Only when relevant (conservative)
   - [ ] Never (manual recall only)

---

## Conclusion

**Automation is possible and practical** through:

1. ✅ **Claude Code Hooks** - 8 lifecycle events for automation
2. ✅ **External Scripts** - File watchers, cron jobs, git hooks
3. ✅ **Memory System** - File-based storage perfect for automation
4. ✅ **Skills Integration** - Skills work with automated context

**Key Insight**: While skills themselves can't be automated (model-invoked only), we can automate the **context and memory system** that skills rely on, making the entire experience feel automatic.

**Next Action**: Begin Phase 1 implementation - create SessionStart, SessionEnd, and Stop hooks.
