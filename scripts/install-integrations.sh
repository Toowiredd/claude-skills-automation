#!/usr/bin/env bash
# Install Claude Skills Automation with Paid Subscriptions Integration
# Installs all hooks + integration hooks for paid subscriptions

set -euo pipefail

echo "🚀 Installing Claude Skills Automation with Integrations"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
CLAUDE_HOOKS_DIR="$HOME/.config/claude-code/hooks"
HOOKS_SOURCE_DIR="$REPO_DIR/hooks"

echo -e "${BLUE}📁 Installing to: $CLAUDE_HOOKS_DIR${NC}"
echo -e "${BLUE}📦 From source: $HOOKS_SOURCE_DIR${NC}"
echo ""

# Check source directory
if [ ! -d "$HOOKS_SOURCE_DIR" ]; then
  echo -e "${RED}❌ Error: Hooks directory not found${NC}"
  echo "Expected: $HOOKS_SOURCE_DIR"
  exit 1
fi

# Create hooks directory
echo "📁 Creating hooks directory..."
mkdir -p "$CLAUDE_HOOKS_DIR"
echo -e "${GREEN}✅ Created${NC}"
echo ""

# Core automation hooks
echo "📝 Installing core automation hooks..."
CORE_HOOKS=(
  "session-start.sh"
  "session-end.sh"
  "stop-extract-memories.sh"
  "post-tool-track.sh"
  "pre-compact-backup.sh"
)

for HOOK in "${CORE_HOOKS[@]}"; do
  if [ -f "$HOOKS_SOURCE_DIR/$HOOK" ]; then
    cp "$HOOKS_SOURCE_DIR/$HOOK" "$CLAUDE_HOOKS_DIR/$HOOK"
    chmod +x "$CLAUDE_HOOKS_DIR/$HOOK"
    echo -e "${GREEN}✅${NC} $HOOK"
  else
    echo -e "${YELLOW}⚠️${NC}  $HOOK not found"
  fi
done

echo ""

# Integration hooks
echo "🔌 Installing integration hooks..."
INTEGRATION_HOOKS=(
  "async-task-jules.sh"
  "post-session-jules-cleanup.sh"
  "error-lookup-copilot.sh"
  "pre-commit-copilot-review.sh"
  "pre-commit-codacy-check.sh"
  "post-tool-save-to-pieces.sh"
  "testing-docker-isolation.sh"
  "codegen-agent-trigger.sh"
)

for HOOK in "${INTEGRATION_HOOKS[@]}"; do
  if [ -f "$HOOKS_SOURCE_DIR/$HOOK" ]; then
    cp "$HOOKS_SOURCE_DIR/$HOOK" "$CLAUDE_HOOKS_DIR/$HOOK"
    chmod +x "$CLAUDE_HOOKS_DIR/$HOOK"
    echo -e "${GREEN}✅${NC} $HOOK"
  else
    echo -e "${YELLOW}⚠️${NC}  $HOOK not found"
  fi
done

echo ""
echo "📂 Creating memory directories..."
mkdir -p "$HOME/.claude-memories"/{decisions,blockers,context,preferences,procedures,notes,sessions,backups,pre-compact-backups}
mkdir -p "$HOME/.claude-sessions/projects"
mkdir -p "$HOME/.claude-artifacts"
echo -e "${GREEN}✅ All directories created${NC}"

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""

# Check which CLIs are installed
echo "🔍 Checking integration CLI tools..."
echo ""

# Jules CLI
if command -v jules &> /dev/null; then
  echo -e "${GREEN}✅ Jules CLI${NC} (installed)"
else
  echo -e "${YELLOW}⚠️  Jules CLI${NC} (not installed)"
  echo "   Install: npm install -g @google/jules-cli"
fi

# GitHub Copilot CLI
if command -v copilot &> /dev/null; then
  echo -e "${GREEN}✅ GitHub Copilot CLI${NC} (installed)"
else
  echo -e "${YELLOW}⚠️  GitHub Copilot CLI${NC} (not installed)"
  echo "   Install: npm install -g @github/copilot@latest"
fi

# Pieces CLI
if command -v pieces &> /dev/null; then
  echo -e "${GREEN}✅ Pieces CLI${NC} (installed)"
else
  echo -e "${YELLOW}⚠️  Pieces CLI${NC} (not installed)"
  echo "   Install: Download from pieces.app"
fi

# Codacy CLI
if command -v codacy-analysis-cli &> /dev/null; then
  echo -e "${GREEN}✅ Codacy CLI${NC} (installed)"
else
  echo -e "${YELLOW}⚠️  Codacy CLI${NC} (not installed)"
  echo "   Install: See docs/SUBSCRIPTIONS_INTEGRATION.md"
fi

# Docker
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✅ Docker${NC} (installed)"
else
  echo -e "${YELLOW}⚠️  Docker${NC} (not installed)"
  echo "   Install: Docker Desktop"
fi

# Codegen SDK
if command -v codegen-sdk &> /dev/null; then
  echo -e "${GREEN}✅ Codegen SDK${NC} (installed)"
else
  echo -e "${YELLOW}⚠️  Codegen SDK${NC} (not installed)"
  echo "   Install: npm install -g @codegen/sdk"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 NEXT STEPS:"
echo ""
echo -e "1. ${YELLOW}Install missing CLI tools${NC} (see above)"
echo ""
echo -e "2. ${YELLOW}Configure API keys:${NC}"
echo "   export CODEGEN_API_KEY='your-key'"
echo "   export CODACY_PROJECT_TOKEN='your-token'"
echo ""
echo -e "3. ${YELLOW}Setup Pieces MCP:${NC}"
echo "   pieces mcp setup --claude"
echo ""
echo -e "4. ${YELLOW}Read integration guide:${NC}"
echo "   cat $REPO_DIR/docs/SUBSCRIPTIONS_INTEGRATION.md"
echo ""
echo -e "5. ${YELLOW}Start Claude Code and test!${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "✨ Your development environment is now ${GREEN}supercharged${NC}!"
echo ""
