#!/bin/bash
# Verify on Stop Hook - Stop event
# Automatically verifies changes when Claude session ends
# Trigger: Stop event (session termination)
#
# Consolidates: verify-on-stop + persist-context + suggest-rules
# - TSC, ESLint, test checks (original)
# - Security pattern check (merged from persist-context.sh, now deleted)
# - Error logging to JSONL (merged from persist-context.sh, now deleted)
# - Error pattern counting + rule suggestion (merged from suggest-rules.sh, now deleted)

set -euo pipefail

# Read JSON input
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")

# Determine monorepo root
MONOREPO_ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$MONOREPO_ROOT" 2>/dev/null || exit 0

# Collect changed files (staged + unstaged)
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || git status --porcelain 2>/dev/null | awk '{print $2}' || echo "")

# Skip if no changes
if [ -z "$CHANGED_FILES" ]; then
    echo '{"hookSpecificOutput": "✅ No changes to verify"}'
    exit 0
fi

# Auto-detect sub-project (same pattern as format-code.sh)
find_project_root() {
    local dir="$1"
    while [ "$dir" != "/" ] && [ "$dir" != "$MONOREPO_ROOT" ]; do
        if [ -f "$dir/tsconfig.json" ] || [ -f "$dir/package.json" ] || \
           [ -f "$dir/pyproject.toml" ] || [ -f "$dir/requirements.txt" ] || [ -f "$dir/setup.py" ]; then
            echo "$dir"
            return
        fi
        dir=$(dirname "$dir")
    done
    echo ""
}

# Detect sub-project from changed files
DETECTED_ROOT=""
for file in $CHANGED_FILES; do
    abs_file="$MONOREPO_ROOT/$file"
    [ -f "$abs_file" ] || continue
    root=$(find_project_root "$(dirname "$abs_file")")
    if [ -n "$root" ]; then
        if [ -z "$DETECTED_ROOT" ]; then
            DETECTED_ROOT="$root"
        elif [ "$DETECTED_ROOT" != "$root" ]; then
            # Multiple sub-projects -> use monorepo root
            DETECTED_ROOT=""
            break
        fi
    fi
done

PROJECT_ROOT="${DETECTED_ROOT:-$MONOREPO_ROOT}"
cd "$PROJECT_ROOT" 2>/dev/null || exit 0

# Error pattern classifier (from persist-context.sh)
classify_error_pattern() {
    local error_msg="$1"
    local clean_msg=$(echo "$error_msg" | sed 's/[^a-zA-Z0-9 .,:\-_/\\(){}[\]'\''""]//g')

    if echo "$error_msg" | grep -qE "TS2339|does not exist on type"; then
        echo "typescript_missing_property"
    elif echo "$error_msg" | grep -qE "TS2307|Cannot find module"; then
        echo "typescript_missing_import"
    elif echo "$error_msg" | grep -qE "TS2554|Expected.*arguments"; then
        echo "typescript_wrong_arity"
    elif echo "$error_msg" | grep -qE "TS2322|is not assignable to type"; then
        echo "typescript_type_mismatch"
    elif echo "$error_msg" | grep -qE "TS2304|Cannot find name"; then
        echo "typescript_undefined_name"
    elif echo "$error_msg" | grep -qE "TS2345|Argument.*is not assignable"; then
        echo "typescript_argument_mismatch"
    elif echo "$error_msg" | grep -qE "TS7006|implicitly has.*any.*type"; then
        echo "typescript_implicit_any"
    elif echo "$error_msg" | grep -qE "TS1005|TS1002|TS1003"; then
        echo "typescript_syntax_error"
    elif echo "$error_msg" | grep -qE "error TS[0-9]+"; then
        echo "typescript_compile_error"
    elif echo "$error_msg" | grep -qiE "mypy.*error|Incompatible types|has no attribute"; then
        echo "python_type_error"
    elif echo "$error_msg" | grep -qiE "ImportError|ModuleNotFoundError|No module named"; then
        echo "python_import_error"
    elif echo "$error_msg" | grep -qiE "SyntaxError|IndentationError"; then
        echo "python_syntax_error"
    elif echo "$error_msg" | grep -qiE "FAILED.*pytest\|pytest.*failed\|AssertionError"; then
        echo "python_test_failure"
    elif echo "$clean_msg" | grep -qiE "innerHTML|eval\(|dangerouslySetInnerHTML"; then
        echo "security_xss"
    elif echo "$clean_msg" | grep -qiE "no-unused-vars"; then
        echo "eslint_unused_vars"
    elif echo "$clean_msg" | grep -qiE "ESLint|eslint"; then
        echo "eslint_warning"
    else
        echo "other"
    fi
}

# Collect verification results
ERRORS=""
WARNINGS=""
TS_FILES=""
JS_FILES=""

# Filter TypeScript/JavaScript/Python files (convert to absolute paths)
PY_FILES=""
for file in $CHANGED_FILES; do
    abs_file="$MONOREPO_ROOT/$file"
    [ -f "$abs_file" ] || continue
    if [[ "$file" =~ \.(ts|tsx)$ ]]; then
        TS_FILES="$TS_FILES $abs_file"
    elif [[ "$file" =~ \.(js|jsx)$ ]]; then
        JS_FILES="$JS_FILES $abs_file"
    elif [[ "$file" =~ \.py$ ]]; then
        PY_FILES="$PY_FILES $abs_file"
    fi
done

# 1. TypeScript compilation check
if [ -f "tsconfig.json" ] && [ -n "$TS_FILES" ]; then
    TS_OUTPUT=$(npx tsc --noEmit --skipLibCheck 2>&1 || true)
    if echo "$TS_OUTPUT" | grep -q "error TS"; then
        ERROR_COUNT=$(echo "$TS_OUTPUT" | grep -c "error TS" || echo "0")
        FIRST_ERROR=$(echo "$TS_OUTPUT" | grep -m1 "error TS" | head -c 150)
        ERRORS="$ERRORS\n❌ TypeScript: $ERROR_COUNT errors - $FIRST_ERROR"
    fi
fi

# 2. ESLint check (run if config exists in PROJECT_ROOT or MONOREPO_ROOT)
HAS_ESLINT=false
if [ -f "eslint.config.js" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ]; then
    HAS_ESLINT=true
elif [ -f "$MONOREPO_ROOT/eslint.config.js" ] || [ -f "$MONOREPO_ROOT/.eslintrc.js" ]; then
    HAS_ESLINT=true
fi
if [ "$HAS_ESLINT" = true ]; then
    ALL_CODE_FILES="$TS_FILES $JS_FILES"
    if [ -n "$ALL_CODE_FILES" ]; then
        ESLINT_OUTPUT=$(npx eslint $ALL_CODE_FILES --quiet 2>&1 || true)
        if [ -n "$ESLINT_OUTPUT" ]; then
            LINT_COUNT=$(echo "$ESLINT_OUTPUT" | grep -cE "error|warning" || echo "0")
            WARNINGS="$WARNINGS\n⚠️ ESLint: $LINT_COUNT issues found"
        fi
    fi
fi

# 3. Test execution (detect correct runner from scripts.test)
if [ -f "package.json" ]; then
    TEST_SCRIPT=$(jq -r '.scripts.test // ""' package.json 2>/dev/null || echo "")
    if echo "$TEST_SCRIPT" | grep -q "vitest"; then
        TEST_OUTPUT=$(timeout 30 npx vitest --run --passWithNoTests 2>&1 || true)
        if echo "$TEST_OUTPUT" | grep -qE "FAIL|failed"; then
            FAIL_COUNT=$(echo "$TEST_OUTPUT" | grep -cE "FAIL" || echo "0")
            ERRORS="$ERRORS\n❌ Tests: $FAIL_COUNT test(s) failed"
        fi
    elif echo "$TEST_SCRIPT" | grep -q "jest"; then
        TEST_OUTPUT=$(timeout 30 npx jest --passWithNoTests --bail 2>&1 || true)
        if echo "$TEST_OUTPUT" | grep -qE "FAIL|failed"; then
            ERRORS="$ERRORS\n❌ Tests: Some tests failed"
        fi
    elif echo "$TEST_SCRIPT" | grep -q "pytest"; then
        : # pytest handled in separate section below
    elif [ -n "$TEST_SCRIPT" ]; then
        # Other test commands (run npm test)
        TEST_OUTPUT=$(timeout 30 npm test -- --passWithNoTests 2>&1 || true)
        if echo "$TEST_OUTPUT" | grep -qE "FAIL|failed"; then
            ERRORS="$ERRORS\n❌ Tests: Some tests failed"
        fi
    fi
fi

# 4. Python type check (mypy)
if [ -n "$PY_FILES" ]; then
    if command -v mypy &>/dev/null || [ -f "$PROJECT_ROOT/venv/bin/mypy" ]; then
        MYPY_CMD="mypy"
        [ -f "$PROJECT_ROOT/venv/bin/mypy" ] && MYPY_CMD="$PROJECT_ROOT/venv/bin/mypy"
        MYPY_OUTPUT=$($MYPY_CMD --ignore-missing-imports $PY_FILES 2>&1 || true)
        if echo "$MYPY_OUTPUT" | grep -qE "error:"; then
            MYPY_COUNT=$(echo "$MYPY_OUTPUT" | grep -c "error:" || echo "0")
            FIRST_MYPY=$(echo "$MYPY_OUTPUT" | grep -m1 "error:" | head -c 150)
            ERRORS="$ERRORS\n❌ mypy: $MYPY_COUNT error(s) - $FIRST_MYPY"
        fi
    fi
fi

# 5. Python test check (pytest)
if [ -n "$PY_FILES" ]; then
    if [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ]; then
        PYTEST_CMD=""
        if [ -f "$PROJECT_ROOT/venv/bin/pytest" ]; then
            PYTEST_CMD="$PROJECT_ROOT/venv/bin/pytest"
        elif command -v pytest &>/dev/null; then
            PYTEST_CMD="pytest"
        fi
        if [ -n "$PYTEST_CMD" ]; then
            PYTEST_OUTPUT=$(cd "$PROJECT_ROOT" && timeout 30 $PYTEST_CMD --tb=no -q 2>&1 || true)
            if echo "$PYTEST_OUTPUT" | grep -qE "failed|error"; then
                FAIL_COUNT=$(echo "$PYTEST_OUTPUT" | grep -oE "[0-9]+ failed" | head -1 || echo "some")
                ERRORS="$ERRORS\n❌ pytest: $FAIL_COUNT"
            fi
        fi
    fi
fi

# 6. Python security pattern check
if [ -n "$PY_FILES" ]; then
    for file in $PY_FILES; do
        if [ -f "$file" ] && grep -qE "eval\(|exec\(|subprocess\.call.*shell=True|pickle\.loads|__import__" "$file" 2>/dev/null; then
            WARNINGS="$WARNINGS\n⚠️ Security: eval/exec/shell=True/pickle.loads in $file"
        fi
    done
fi

# 7. Security pattern check (JS/TS)
ALL_CODE_FILES="$TS_FILES $JS_FILES"
if [ -n "$ALL_CODE_FILES" ]; then
    for file in $ALL_CODE_FILES; do
        if [ -f "$file" ] && grep -qE "innerHTML\s*=|eval\(|dangerouslySetInnerHTML" "$file" 2>/dev/null; then
            WARNINGS="$WARNINGS\n⚠️ Security: innerHTML/eval/dangerouslySetInnerHTML in $file"
        fi
    done
fi

# 7.5. Next.js 'use client' directive check (auto-detect Next.js projects)
# Detect Next.js projects by checking for next.config.* files
NEXTJS_DIRS=""
for dir in $(find "$MONOREPO_ROOT" -maxdepth 2 -name "next.config.*" -exec dirname {} \; 2>/dev/null); do
    NEXTJS_DIRS="$NEXTJS_DIRS|$(basename "$dir")"
done
NEXTJS_DIRS="${NEXTJS_DIRS#|}"  # Remove leading pipe

if [ -n "$NEXTJS_DIRS" ] && echo "$CHANGED_FILES" | grep -qE "^($NEXTJS_DIRS)/"; then
    for file in $CHANGED_FILES; do
        abs_file="$MONOREPO_ROOT/$file"
        if echo "$file" | grep -qE "^($NEXTJS_DIRS)/" && [[ "$file" =~ \.tsx$ ]] && [ -f "$abs_file" ]; then
            # Check if file uses client-side patterns but lacks 'use client'
            if grep -qE "useState|useEffect|useRef|useCallback|useMemo|onClick|onChange|onSubmit" "$abs_file" 2>/dev/null; then
                if ! head -5 "$abs_file" | grep -q "'use client'" 2>/dev/null; then
                    WARNINGS="$WARNINGS\n⚠️ Next.js: Missing 'use client' in $file (uses hooks/handlers)"
                fi
            fi
        fi
    done
fi

# 8. Error logging
if [ -n "$ERRORS" ]; then
    CONTEXT_FILE="$HOME/.claude/context/failures.jsonl"
    mkdir -p "$(dirname "$CONTEXT_FILE")"
    TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Classify the primary error pattern
    ERROR_PATTERN=$(classify_error_pattern "$ERRORS")

    jq -n \
        --arg ts "$TIMESTAMP" \
        --arg sid "$SESSION_ID" \
        --arg proj "$PROJECT_ROOT" \
        --arg emsg "$(echo -e "$ERRORS" | head -c 500)" \
        --arg pattern "$ERROR_PATTERN" \
        '{
            timestamp: $ts,
            session_id: $sid,
            project: $proj,
            error_message: $emsg,
            pattern: $pattern
        }' >> "$CONTEXT_FILE" 2>/dev/null || true
fi

# 9. Error pattern counting + rule suggestion
if [ -n "$ERRORS" ] || [ -n "$WARNINGS" ]; then
    ERROR_COUNT_FILE="${HOME}/.claude/error-counts.json"
    if [ ! -f "$ERROR_COUNT_FILE" ]; then
        mkdir -p "$(dirname "$ERROR_COUNT_FILE")"
        echo '{}' > "$ERROR_COUNT_FILE"
    fi

    ERROR_PATTERN=$(classify_error_pattern "$ERRORS$WARNINGS")
    PATTERN_KEY="$ERROR_PATTERN"
    CURRENT_COUNT=$(jq -r ".\"$PATTERN_KEY\" // 0" "$ERROR_COUNT_FILE" 2>/dev/null || echo "0")
    NEW_COUNT=$((CURRENT_COUNT + 1))

    jq ".\"$PATTERN_KEY\" = $NEW_COUNT" "$ERROR_COUNT_FILE" > "${ERROR_COUNT_FILE}.tmp" 2>/dev/null && \
        mv "${ERROR_COUNT_FILE}.tmp" "$ERROR_COUNT_FILE" || true

    # Suggest rule if pattern repeated 3+ times
    if [ "$NEW_COUNT" -ge 3 ]; then
        PENDING_FILE="${MONOREPO_ROOT}/.claude/pending-rules.md"
        if [ -f "$PENDING_FILE" ] && ! grep -q "$PATTERN_KEY" "$PENDING_FILE" 2>/dev/null; then
            RULE_TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
            cat >> "$PENDING_FILE" << RULEEOF

### [$RULE_TIMESTAMP] Pattern #$PATTERN_KEY (${NEW_COUNT}x)

**Type**: $ERROR_PATTERN
**Sample**: $(echo -e "$ERRORS$WARNINGS" | head -c 200 | tr '\n' ' ')

RULEEOF
            # Reset count after suggestion
            jq ".\"$PATTERN_KEY\" = 0" "$ERROR_COUNT_FILE" > "${ERROR_COUNT_FILE}.tmp" 2>/dev/null && \
                mv "${ERROR_COUNT_FILE}.tmp" "$ERROR_COUNT_FILE" || true

            WARNINGS="$WARNINGS\n📚 Repeated error pattern (${NEW_COUNT}x) → rule candidate added to .claude/pending-rules.md"
        fi
    fi
fi

# Output results
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -w | xargs)

if [ -n "$ERRORS" ]; then
    # Output detailed errors
    OUTPUT="⚠️ Verification found issues in $FILE_COUNT file(s):$ERRORS"
    if [ -n "$WARNINGS" ]; then
        OUTPUT="$OUTPUT$WARNINGS"
    fi

    # Log failure
    LOG_FILE="$HOME/.claude/context/stop-verification.log"
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Session: $SESSION_ID - Issues found" >> "$LOG_FILE"

    echo "{\"hookSpecificOutput\": \"$(echo -e "$OUTPUT" | tr '\n' ' ')\"}"
else
    # Success
    OUTPUT="✅ Verified $FILE_COUNT file(s) - No issues found"
    if [ -n "$WARNINGS" ]; then
        OUTPUT="$OUTPUT (minor warnings)"
    fi
    echo "{\"hookSpecificOutput\": \"$OUTPUT\"}"
fi

exit 0
