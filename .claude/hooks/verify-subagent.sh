#!/bin/bash
# Verify Subagent Hook - SubagentStop event
# Validates subagent output when it completes
# Trigger: SubagentStop event (subagent termination)
#
# Purpose: Ensure subagent completed successfully and detect
# any errors that might have been missed during execution

set -euo pipefail

# Read JSON input
INPUT=$(cat)
SUBAGENT_ID=$(echo "$INPUT" | jq -r '.subagent_id // "unknown"' 2>/dev/null || echo "unknown")
SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.subagent_type // "unknown"' 2>/dev/null || echo "unknown")
EXIT_REASON=$(echo "$INPUT" | jq -r '.exit_reason // ""' 2>/dev/null || echo "")

# Determine monorepo root
MONOREPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Auto-detect sub-project
find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ] && [ "$dir" != "$MONOREPO_ROOT" ]; do
        if [ -f "$dir/tsconfig.json" ] || [ -f "$dir/package.json" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo ""
}

detect_project_root() {
    local changed_files
    changed_files=$(git -C "$MONOREPO_ROOT" status --porcelain 2>/dev/null | awk '{print $2}' || echo "")
    local detected=""
    for file in $changed_files; do
        local abs_file="$MONOREPO_ROOT/$file"
        [ -f "$abs_file" ] || continue
        local root
        root=$(find_project_root "$(dirname "$abs_file")")
        if [ -n "$root" ]; then
            if [ -z "$detected" ]; then
                detected="$root"
            elif [ "$detected" != "$root" ]; then
                echo ""
                return
            fi
        fi
    done
    echo "$detected"
}

DETECTED_ROOT=$(detect_project_root)
PROJECT_ROOT="${DETECTED_ROOT:-$MONOREPO_ROOT}"

# Set up log directory
LOG_DIR="$HOME/.claude/context"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ISSUES=""

# 1. Detect abnormal exit
if [ "$EXIT_REASON" = "error" ] || [ "$EXIT_REASON" = "timeout" ]; then
    ISSUES="$ISSUES\n❌ Subagent $SUBAGENT_TYPE ($SUBAGENT_ID) exited with: $EXIT_REASON"

    # Log failure
    echo "{\"timestamp\": \"$TIMESTAMP\", \"subagent_id\": \"$SUBAGENT_ID\", \"type\": \"$SUBAGENT_TYPE\", \"exit_reason\": \"$EXIT_REASON\"}" \
        >> "$LOG_DIR/subagent-failures.jsonl"
fi

# 2. Post-processing by subagent type
case "$SUBAGENT_TYPE" in
    "code-reviewer")
        # Code reviewer completed - no additional verification needed
        ;;
    "firebase-validator")
        # Firebase validator completed - no additional verification needed
        ;;
    "team-researcher")
        # Read-only team agent - no additional verification needed
        ;;
    "team-implementer")
        # Implementation team agent - check for uncommitted changes
        cd "$PROJECT_ROOT" 2>/dev/null || exit 0
        DIRTY_FILES=$(git status --porcelain 2>/dev/null | wc -l | xargs)
        if [ "$DIRTY_FILES" -gt 0 ]; then
            ISSUES="$ISSUES\n⚠️ Team implementer left $DIRTY_FILES uncommitted changes (team-lead should commit)"
        fi
        ;;
    "batch-worker")
        # Batch worker - should not modify files (read-only)
        cd "$PROJECT_ROOT" 2>/dev/null || exit 0
        DIRTY_FILES=$(git status --porcelain 2>/dev/null | wc -l | xargs)
        if [ "$DIRTY_FILES" -gt 0 ]; then
            ISSUES="$ISSUES\n❌ Batch worker modified $DIRTY_FILES files (should be read-only)"
        fi
        ;;
    "health-scanner")
        # Health scanner - fully read-only, should not modify files
        cd "$PROJECT_ROOT" 2>/dev/null || exit 0
        DIRTY_FILES=$(git status --porcelain 2>/dev/null | wc -l | xargs)
        if [ "$DIRTY_FILES" -gt 0 ]; then
            ISSUES="$ISSUES\n❌ Health scanner modified $DIRTY_FILES files (should be read-only)"
        fi
        ;;
    "Explore"|"general-purpose")
        # Explore/general-purpose agent completed - check for changes
        cd "$PROJECT_ROOT" 2>/dev/null || exit 0
        DIRTY_FILES=$(git status --porcelain 2>/dev/null | wc -l | xargs)
        if [ "$DIRTY_FILES" -gt 0 ]; then
            ISSUES="$ISSUES\n⚠️ Agent left $DIRTY_FILES uncommitted changes"
        fi
        ;;
    *)
        # Other agents
        ;;
esac

# 3. Output results
if [ -n "$ISSUES" ]; then
    echo "{\"hookSpecificOutput\": \"$(echo -e "Subagent ($SUBAGENT_TYPE) completed with issues:$ISSUES" | tr '\n' ' ')\"}"
else
    echo "{\"hookSpecificOutput\": \"✅ Subagent ($SUBAGENT_TYPE) completed successfully\"}"
fi

exit 0
