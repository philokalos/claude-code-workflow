#!/bin/bash
# Workflow Guide Hook - SessionStart and UserPromptSubmit
# Token minimization: only emit short recommendation messages when needed

set -euo pipefail

# Read JSON input
INPUT=$(cat)
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""' 2>/dev/null || echo "")
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""' 2>/dev/null || echo "")

# Default event name for output payloads
OUTPUT_EVENT="${EVENT:-UserPromptSubmit}"

# Pending rules notification (Compounding Loop integration) — runs on every event
MONOREPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PENDING_FILE="$MONOREPO_ROOT/.claude/pending-rules.md"
if [ -f "$PENDING_FILE" ]; then
    PENDING_COUNT="$(grep -c "^### \[" "$PENDING_FILE" 2>/dev/null)" || PENDING_COUNT=0
    if [ "$PENDING_COUNT" -gt 0 ]; then
        cat <<PENDINGEOF
{
    "continue": true,
    "hookSpecificOutput": {
        "hookEventName": "$OUTPUT_EVENT",
        "additionalContext": "📋 ${PENDING_COUNT} rule candidate(s) pending review in pending-rules.md. Check: cat .claude/pending-rules.md"
    }
}
PENDINGEOF
    fi
fi

# SessionStart only emits the pending-rules notification above; skip prompt analysis
if [ "$EVENT" = "SessionStart" ]; then
    exit 0
fi

# Skip when no prompt text is available (e.g., non-prompt events)
if [ -z "$PROMPT" ]; then
    exit 0
fi

PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Analyze prompt complexity
WORD_COUNT=$(echo "$PROMPT" | wc -w | xargs)
QUESTION_COUNT=$(echo "$PROMPT" | tr -cd '?' | wc -c | xargs)
QUESTION_COUNT=${QUESTION_COUNT:-0}

# Implementation-related keywords (based on user patterns)
IMPLEMENT_KEYWORDS="implement|create|add|write|build|modify|change|update|setup|configure"

# Think mode recommended keywords (complex tasks)
COMPLEX_KEYWORDS="refactor|architecture|migration|optimize|security|analyze|design|system|multiple files"

# Check if already using slash command or think mode
if echo "$PROMPT_LOWER" | grep -qE "(/specify|/plan|/implement|/spec|think hard|think harder|ultrathink)"; then
    exit 0
fi

# Think mode auto-trigger conditions
THINK_NEEDED=false

# Condition 1: Word count > 80
if [ "$WORD_COUNT" -gt 80 ]; then
    THINK_NEEDED=true
fi

# Condition 2: Complex task keyword combination
if echo "$PROMPT_LOWER" | grep -qE "(implement.*feature|feature.*implement)"; then
    THINK_NEEDED=true
fi

# Condition 3: Multiple questions (>=2)
if [ "$QUESTION_COUNT" -ge 2 ]; then
    THINK_NEEDED=true
fi

# Condition 4: Complex keywords detected
if echo "$PROMPT_LOWER" | grep -qE "($COMPLEX_KEYWORDS)"; then
    THINK_NEEDED=true
fi

ADDITIONAL_CONTEXT=""

# 1. Think mode auto-trigger (high priority)
if [ "$THINK_NEEDED" = true ]; then
    ADDITIONAL_CONTEXT="🧠 Complex task detected. Processing in deep analysis mode."
fi

# 2. Detect implementation request (without plan mention) - Phase 3 enhanced
if echo "$PROMPT_LOWER" | grep -qE "($IMPLEMENT_KEYWORDS)"; then
    if ! echo "$PROMPT_LOWER" | grep -qE "(plan|design|spec)"; then
        # Silent Auto-Planner: Generate draft spec in background (VVCS Phase 2)
        if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
            # Launch async spec generation (non-blocking)
            nohup "$CLAUDE_PROJECT_DIR/.claude/scripts/generate-mini-spec.sh" "$PROMPT" > /dev/null 2>&1 &
        fi

        # Phase 3 enhanced: differentiate recommendation level by complexity
        if [ "$THINK_NEEDED" = true ]; then
            # Complex task + no plan = strongly recommended
            ADDITIONAL_CONTEXT="⚠️ Complex implementation request detected. Plan-First approach strongly recommended.\n\n💡 Recommended workflow:\n  1. /specify - Write spec\n  2. /plan - Technical design\n  3. /implement - Implementation\n\n📊 VVCS goal: Plan-First > 85%, Fix commits < 15%"
        elif [ -z "$ADDITIONAL_CONTEXT" ]; then
            ADDITIONAL_CONTEXT="💡 Recommended: Write spec with /specify (draft generating in background...)"
        fi
    fi
fi

# 3. Team workflow suggestion (compound pattern - false positive prevention)
CODE_KEYWORDS="implement|refactor|fix|migration|review"
PARALLEL_KEYWORDS="parallel|concurrent|team"
if echo "$PROMPT_LOWER" | grep -qE "($CODE_KEYWORDS)" && \
   echo "$PROMPT_LOWER" | grep -qE "($PARALLEL_KEYWORDS)"; then
    if [ -z "$ADDITIONAL_CONTEXT" ]; then
        ADDITIONAL_CONTEXT="🤝 Parallel work detected. Check /team for appropriate team configuration."
    else
        ADDITIONAL_CONTEXT="$ADDITIONAL_CONTEXT\n🤝 Parallel work also detected: check /team for team configuration"
    fi
fi

# 4. Phase 3: Recommend code review (completion keywords detected)
COMPLETION_KEYWORDS="done|finished|implemented|completed"
if echo "$PROMPT_LOWER" | grep -qE "($COMPLETION_KEYWORDS)"; then
    if [ -z "$ADDITIONAL_CONTEXT" ]; then
        ADDITIONAL_CONTEXT="✅ Implementation done? Recommended next steps:\n  1. /review - Code review\n  2. /verify - Quality verification\n  3. /commit-push-pr - Commit and PR"
    fi
fi

# Output message if present (token minimization)
if [ -n "$ADDITIONAL_CONTEXT" ]; then
    cat <<EOF
{
    "continue": true,
    "hookSpecificOutput": {
        "hookEventName": "$OUTPUT_EVENT",
        "additionalContext": "$ADDITIONAL_CONTEXT"
    }
}
EOF
fi

exit 0
