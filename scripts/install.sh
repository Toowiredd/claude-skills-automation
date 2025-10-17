#!/usr/bin/env bash
# Install Claude Skills Automation Hooks
# Installs all automation hooks for memory and context management

set -euo pipefail

echo "🚀 Installing Claude Skills Automation..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_HOOKS_DIR="$HOME/.config/claude-code/hooks"
SKILLS_DIR="/home/toowired/Downloads/universal-claude-skills"
HOOKS_SOURCE_DIR="$SKILLS_DIR/hooks"

# Check if running from correct location
if [ ! -d "$HOOKS_SOURCE_DIR" ]; then
  echo -e "${RED}❌ Error: Hook scripts not found at $HOOKS_SOURCE_DIR${NC}"
  echo "Please run this script from: $SKILLS_DIR"
  exit 1
fi

echo "📁 Creating hooks directory..."
mkdir -p "$CLAUDE_HOOKS_DIR"
echo -e "${GREEN}✅ Created: $CLAUDE_HOOKS_DIR${NC}"
echo ""

# Install hook scripts
echo "📝 Installing hook scripts..."

HOOKS=(
  "session-start.sh"
  "session-end.sh"
  "stop-extract-memories.sh"
  "post-tool-track.sh"
  "pre-compact-backup.sh"
)

for HOOK in "${HOOKS[@]}"; do
  SOURCE="$HOOKS_SOURCE_DIR/$HOOK"
  DEST="$CLAUDE_HOOKS_DIR/$HOOK"

  if [ -f "$SOURCE" ]; then
    cp "$SOURCE" "$DEST"
    chmod +x "$DEST"
    echo -e "${GREEN}✅ Installed: $HOOK${NC}"
  else
    echo -e "${RED}❌ Warning: $SOURCE not found${NC}"
  fi
done

echo ""
echo "🔧 Verifying installations..."

# Verify hooks are executable
for HOOK in "${HOOKS[@]}"; do
  DEST="$CLAUDE_HOOKS_DIR/$HOOK"
  if [ -x "$DEST" ]; then
    echo -e "${GREEN}✅ $HOOK is executable${NC}"
  else
    echo -e "${YELLOW}⚠️  $HOOK exists but is not executable${NC}"
    chmod +x "$DEST"
  fi
done

echo ""
echo "📋 Checking Claude Code configuration..."

SETTINGS_FILE="$HOME/.config/claude-code/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo -e "${YELLOW}⚠️  Claude Code settings.json not found${NC}"
  echo "Creating default settings with hooks configuration..."

  cat > "$SETTINGS_FILE" <<'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/claude-code/hooks/session-start.sh",
            "description": "Auto-restore context from memory"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/claude-code/hooks/session-end.sh",
            "description": "Auto-save session state"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/claude-code/hooks/stop-extract-memories.sh",
            "description": "Auto-extract decisions and blockers"
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
            "command": "~/.config/claude-code/hooks/post-tool-track.sh",
            "description": "Track significant file changes"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/claude-code/hooks/pre-compact-backup.sh",
            "description": "Backup context before compaction"
          }
        ]
      }
    ]
  }
}
EOF

  echo -e "${GREEN}✅ Created settings.json with hooks configuration${NC}"
else
  echo -e "${YELLOW}⚠️  settings.json already exists${NC}"
  echo "You'll need to manually add hooks configuration."
  echo "See: $SKILLS_DIR/AUTOMATION_IMPLEMENTATION.md for configuration"
fi

echo ""
echo "📂 Ensuring memory directories exist..."

mkdir -p "$HOME/.claude-memories"/{decisions,blockers,context,preferences,procedures,notes,sessions,backups,pre-compact-backups}
mkdir -p "$HOME/.claude-sessions/projects"
mkdir -p "$HOME/.claude-artifacts"
mkdir -p "$HOME/.config/claude-code"

echo -e "${GREEN}✅ All directories created${NC}"

echo ""
echo "⚙️  Creating default configuration..."

# Create default automation.conf if it doesn't exist
CONFIG_FILE="$HOME/.config/claude-code/automation.conf"
CONFIG_SOURCE="$SKILLS_DIR/config/automation.conf"

if [ ! -f "$CONFIG_FILE" ]; then
  if [ -f "$CONFIG_SOURCE" ]; then
    cp "$CONFIG_SOURCE" "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    echo -e "${GREEN}✅ Created automation config: $CONFIG_FILE${NC}"
  else
    # Create default config inline if source not found
    cat > "$CONFIG_FILE" <<'CONFIGEOF'
# Claude Skills Automation Configuration
# This file controls the behavior of automatic context injection

# =============================================================================
# TOKEN LIMIT CONTROLS
# =============================================================================
# These settings prevent context window overflow by limiting the amount of
# information injected into each session

# Maximum number of items to inject per category
MAX_INJECTED_DECISIONS=10
MAX_INJECTED_BLOCKERS=5
MAX_INJECTED_CONTEXT=3
MAX_INJECTED_PROCEDURES=5
MAX_INJECTED_PREFERENCES=10

# Rough token limit estimate for total context injection (4 chars ≈ 1 token)
# Default: 2000 tokens (~8000 characters)
TOKEN_LIMIT_ESTIMATE=2000

# =============================================================================
# TIME-BASED FILTERING
# =============================================================================
# How far back to look for relevant context

# Days to look back for decisions (default: 7)
DECISIONS_LOOKBACK_DAYS=7

# Only show active blockers (or set to false to show all recent blockers)
BLOCKERS_ACTIVE_ONLY=true

# Days to look back for context items (default: 14)
CONTEXT_LOOKBACK_DAYS=14

# =============================================================================
# FEATURE TOGGLES
# =============================================================================
# Enable/disable specific types of context injection

# Inject recent decisions into session context
INJECT_DECISIONS=true

# Inject active/recent blockers
INJECT_BLOCKERS=true

# Inject relevant context items
INJECT_CONTEXT=true

# Inject project preferences
INJECT_PREFERENCES=true

# Inject standard procedures (can be verbose, disabled by default)
INJECT_PROCEDURES=false

# Inject last working topic
INJECT_LAST_TOPIC=true

# =============================================================================
# ADVANCED SETTINGS
# =============================================================================

# Enable verbose logging for debugging
VERBOSE_LOGGING=false

# Show token usage estimates in logs
SHOW_TOKEN_ESTIMATES=true

# Warn if injected context exceeds token limit
WARN_ON_LIMIT_EXCEEDED=true
CONFIGEOF
    chmod 644 "$CONFIG_FILE"
    echo -e "${GREEN}✅ Created default automation config: $CONFIG_FILE${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Config file already exists, keeping existing: $CONFIG_FILE${NC}"
fi

echo ""
echo "📝 Creating default memory index..."

# Create default index.json if it doesn't exist
if [ ! -f "$HOME/.claude-memories/index.json" ]; then
  cat > "$HOME/.claude-memories/index.json" <<'EOF'
{
  "version": "1.0.0",
  "created": "'$(date -Iseconds)'",
  "last_updated": "'$(date -Iseconds)'",
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
  chmod 644 "$HOME/.claude-memories/index.json"
  echo -e "${GREEN}✅ Created default memory index${NC}"
else
  echo -e "${YELLOW}⚠️  Memory index already exists, keeping existing${NC}"
fi

echo ""
echo "🧪 Testing hooks..."

# Test session-start hook
if [ -x "$CLAUDE_HOOKS_DIR/session-start.sh" ]; then
  TEST_INPUT='{"session_id":"test","cwd":"'"$PWD"'","transcript_path":"'"$PWD"'/test.jsonl"}'
  echo "$TEST_INPUT" | "$CLAUDE_HOOKS_DIR/session-start.sh" > /dev/null 2>&1 && \
    echo -e "${GREEN}✅ session-start.sh test passed${NC}" || \
    echo -e "${YELLOW}⚠️  session-start.sh test failed (may be normal if no memories exist yet)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Installation complete!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 NEXT STEPS:"
echo ""
echo "1. ${YELLOW}Start a new Claude Code session${NC}"
echo "   → Hooks will run automatically"
echo ""
echo "2. ${YELLOW}Configure token limits (optional):${NC}"
echo "   nano ~/.config/claude-code/automation.conf"
echo ""
echo "3. ${YELLOW}Check automation logs:${NC}"
echo "   tail -f ~/.claude-memories/automation.log"
echo ""
echo "4. ${YELLOW}View extracted memories:${NC}"
echo "   tail -f ~/.claude-memories/auto-extracted.log"
echo ""
echo "5. ${YELLOW}Read the full guide:${NC}"
echo "   cat $SKILLS_DIR/AUTOMATION_IMPLEMENTATION.md"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Your memory/context system is now ${GREEN}fully automated${NC}!"
echo ""
echo "What's automated:"
echo "  ✅ Session context restoration (automatic)"
echo "  ✅ Decision extraction (automatic)"
echo "  ✅ Blocker detection (automatic)"
echo "  ✅ Session state saving (automatic)"
echo "  ✅ File change tracking (automatic)"
echo "  ✅ Pre-compaction backup (automatic)"
echo ""
echo "No more manual 'hi-ai' or 'remember' commands needed!"
echo ""
