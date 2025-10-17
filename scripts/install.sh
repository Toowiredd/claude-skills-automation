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

echo -e "${GREEN}✅ All directories created${NC}"

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
echo "2. ${YELLOW}Check automation logs:${NC}"
echo "   tail -f ~/.claude-memories/automation.log"
echo ""
echo "3. ${YELLOW}View extracted memories:${NC}"
echo "   tail -f ~/.claude-memories/auto-extracted.log"
echo ""
echo "4. ${YELLOW}Read the full guide:${NC}"
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
