#!/bin/bash
# Format Code Hook - PostToolUse
# Automatically formats code after Edit/Write operations
# Trigger: PostToolUse event (after tool execution)
#
# Boris Cherny Tip: "We use a PostToolUse hook to format Claude's code.
# Claude usually generates well-formatted code out of the box, and the
# hook handles the last 10% to avoid formatting errors in CI later."

set -euo pipefail

# Read JSON input
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // ""' 2>/dev/null || echo "")

# Skip if no file path
if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Skip if file does not exist
if [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Check file extension for formatting targets
case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.json|*.md|*.css|*.scss)
        ;;
    *)
        exit 0  # Skip non-target files
        ;;
esac

# File size check (skip if > 100KB for performance)
FILE_SIZE=$(wc -c < "$FILE_PATH" 2>/dev/null || echo 0)
if [ "$FILE_SIZE" -gt 102400 ]; then
    exit 0
fi

# Find project root (based on package.json, bounded by CLAUDE_PROJECT_DIR)
MONOREPO_ROOT="${CLAUDE_PROJECT_DIR:-}"
find_project_root() {
    local current_dir="$1"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/package.json" ]; then
            echo "$current_dir"
            return
        fi
        # Stop at MONOREPO_ROOT boundary (do not traverse into parent project)
        if [ -n "$MONOREPO_ROOT" ] && [ "$current_dir" = "$MONOREPO_ROOT" ]; then
            break
        fi
        current_dir=$(dirname "$current_dir")
    done
    echo ""
}

PROJECT_ROOT=$(find_project_root "$(dirname "$FILE_PATH")")

# Skip if project root not found
if [ -z "$PROJECT_ROOT" ]; then
    exit 0
fi

cd "$PROJECT_ROOT" 2>/dev/null || exit 0

# Run formatting (order: Prettier > ESLint --fix)
FORMAT_SUCCESS=false

# 1. Try Prettier first (project or monorepo root)
if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ] || \
   [ -f "${CLAUDE_PROJECT_DIR:-}/.prettierrc" ]; then
    if npx prettier --write "$FILE_PATH" 2>/dev/null; then
        FORMAT_SUCCESS=true
    fi
fi

# 2. Fall back to ESLint --fix if Prettier unavailable or failed
if [ "$FORMAT_SUCCESS" = false ]; then
    if [ -f "eslint.config.js" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || \
       { [ -n "$MONOREPO_ROOT" ] && { [ -f "$MONOREPO_ROOT/eslint.config.js" ] || [ -f "$MONOREPO_ROOT/.eslintrc.js" ]; }; }; then
        npx eslint --fix "$FILE_PATH" 2>/dev/null || true
    fi
fi

# Always succeed (formatting failure should not block work)
exit 0
