#!/bin/bash
# Claude Code Workflow Framework — Quick Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/philokalos/claude-code-workflow/main/install.sh | bash
#   curl -fsSL ... | bash -s /path/to/your-project
#   ./install.sh /path/to/your-project
#   ./install.sh --minimal /path/to/your-project

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_URL="https://github.com/philokalos/claude-code-workflow.git"
MINIMAL=false
TARGET_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --minimal|-m)
            MINIMAL=true
            shift
            ;;
        --help|-h)
            echo "Usage: install.sh [--minimal] [target-directory]"
            echo ""
            echo "Options:"
            echo "  --minimal, -m    Install only core pipeline (5 commands + 1 agent + 3 rules)"
            echo "  --help, -h       Show this help"
            echo ""
            echo "If no target directory is specified, installs to current directory."
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

TARGET_DIR="${TARGET_DIR:-.}"

# Resolve to absolute path
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

echo -e "${BLUE}Claude Code Workflow Framework${NC}"
echo "Installing to: $TARGET_DIR"
echo ""

# Check prerequisites
if ! command -v git &>/dev/null; then
    echo -e "${RED}Error: git is required but not installed.${NC}"
    exit 1
fi

if [ -d "$TARGET_DIR/.claude/commands" ] && [ "$(ls -A "$TARGET_DIR/.claude/commands" 2>/dev/null)" ]; then
    echo -e "${YELLOW}Warning: .claude/commands/ already exists in target.${NC}"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Clone to temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo -e "Downloading framework..."
git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR/ccw" 2>/dev/null || {
    echo -e "${RED}Failed to clone repository. Check the URL and your internet connection.${NC}"
    exit 1
}

# Create target .claude directory
mkdir -p "$TARGET_DIR/.claude"

if [ "$MINIMAL" = true ]; then
    echo -e "Installing ${YELLOW}minimal${NC} setup (core pipeline only)..."

    # Core commands (5)
    mkdir -p "$TARGET_DIR/.claude/commands"
    for cmd in specify plan implement verify commit-push-pr; do
        cp "$TEMP_DIR/ccw/.claude/commands/$cmd.md" "$TARGET_DIR/.claude/commands/" 2>/dev/null || true
    done

    # Core rules (3)
    mkdir -p "$TARGET_DIR/.claude/rules/core"
    cp -r "$TEMP_DIR/ccw/.claude/rules/core/"* "$TARGET_DIR/.claude/rules/core/" 2>/dev/null || true

    # Core agent (1)
    mkdir -p "$TARGET_DIR/.claude/agents/core"
    cp "$TEMP_DIR/ccw/.claude/agents/core/code-reviewer.md" "$TARGET_DIR/.claude/agents/core/" 2>/dev/null || true

    # Learn skill
    mkdir -p "$TARGET_DIR/.claude/skills"
    cp "$TEMP_DIR/ccw/.claude/skills/learn.md" "$TARGET_DIR/.claude/skills/" 2>/dev/null || true

    echo ""
    echo -e "${GREEN}Minimal install complete!${NC}"
    echo ""
    echo "  Installed:"
    echo "    5 commands: /specify, /plan, /implement, /verify, /commit-push-pr"
    echo "    1 agent:    code-reviewer"
    echo "    3 rules:    verification, commit-convention, coverage"
    echo "    1 skill:    /learn"

else
    echo -e "Installing ${GREEN}full${NC} framework..."

    # Copy everything except templates (user creates manually)
    for dir in commands skills agents hooks rules docs scripts; do
        if [ -d "$TEMP_DIR/ccw/.claude/$dir" ]; then
            cp -r "$TEMP_DIR/ccw/.claude/$dir" "$TARGET_DIR/.claude/"
        fi
    done

    # Copy templates
    mkdir -p "$TARGET_DIR/.claude/templates"
    cp -r "$TEMP_DIR/ccw/.claude/templates/"* "$TARGET_DIR/.claude/templates/" 2>/dev/null || true

    # Make hooks executable
    chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true

    echo ""
    echo -e "${GREEN}Full install complete!${NC}"
    echo ""
    echo "  Installed:"
    echo "    17 commands, 12 agents, 5 hooks, 6 rules, 3 skills"
fi

# Copy CLAUDE.md template if no CLAUDE.md exists
if [ ! -f "$TARGET_DIR/CLAUDE.md" ] && [ -f "$TEMP_DIR/ccw/.claude/templates/CLAUDE.md.template" ]; then
    cp "$TEMP_DIR/ccw/.claude/templates/CLAUDE.md.template" "$TARGET_DIR/CLAUDE.md"
    echo ""
    echo -e "  ${YELLOW}Created CLAUDE.md from template — edit it with your project details.${NC}"
fi

# Copy settings template if no settings.local.json exists
if [ ! -f "$TARGET_DIR/.claude/settings.local.json" ] && [ -f "$TEMP_DIR/ccw/.claude/templates/settings.local.json.template" ]; then
    cp "$TEMP_DIR/ccw/.claude/templates/settings.local.json.template" "$TARGET_DIR/.claude/settings.local.json"
    echo -e "  ${YELLOW}Created .claude/settings.local.json — hooks are pre-configured.${NC}"
fi

echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Edit CLAUDE.md with your project name, stack, and conventions"
echo "  2. cd $TARGET_DIR && claude"
echo "  3. Try: /specify add user authentication"
echo ""
echo -e "  Docs: ${BLUE}https://github.com/philokalos/claude-code-workflow${NC}"
