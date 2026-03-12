---
description: Post-implementation review — architecture, coverage, anti-patterns.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Verify that implemented code matches the design (plan.md) and meets quality standards, preventing unnecessary fix commits.

## Context

> "Committing without code review increases fix commits up to 90%."
> — VVCS system audit (2026-01-15)

Run this command after `/implement` completes and before `/verify` and `/commit-push-pr`.

## Prerequisites

Pre-checks:
1. Confirm you are on a feature branch
2. Confirm `plan.md` exists
3. Confirm implemented code exists

## Execution Steps

### Phase 1: Context Loading

```bash
# Check feature directory
.specify/scripts/bash/check-prerequisites.sh --json

# List changed files
git diff --name-only HEAD~1 2>/dev/null || git diff --name-only --cached
```

**Required files to read:**
- `plan.md` - Technical design document
- `spec.md` - Requirements specification
- `tasks.md` (if exists) - Task list

### Phase 2: Architecture Review

Compare plan.md "Project Structure" section with actual code structure:

| Check Item | Method | Pass Criteria |
|----------|----------|----------|
| File locations | plan.md structure vs actual paths | 100% match |
| Module dependencies | Verify import directions | No circular dependencies |
| Layer separation | services/components/hooks separation | Layer boundaries respected |
| Naming conventions | File/function name patterns | CLAUDE.md rules followed |

**Verification logic:**
```
1. Extract expected file paths from plan.md Project Structure
2. Compare with actually created files
3. Identify missing/extra files
4. Analyze import statements to build dependency graph
5. Detect circular dependencies
```

### Phase 3: Requirements Traceability

Verify traceability between spec.md requirements and implemented code:

**Generate traceability matrix:**

| Requirement ID | Implementation File | Test File | Status |
|------------|----------|-----------|------|
| FR-001 | src/services/xxx.ts | tests/xxx.test.ts | ✅ Implemented |
| FR-002 | src/components/yyy.tsx | tests/yyy.test.tsx | ⚠️ No tests |
| FR-003 | (none) | (none) | ❌ Not implemented |

**Verification criteria:**
- All FR-xxx requirements must be implemented in code
- At least 80% of requirements should have corresponding tests

### Phase 4: Code Quality Check

#### 4.1 Security Anti-pattern Detection

```bash
# XSS vulnerabilities
grep -rn "innerHTML\s*=" --include="*.ts" --include="*.tsx"
grep -rn "dangerouslySetInnerHTML" --include="*.tsx"
grep -rn "eval(" --include="*.ts" --include="*.tsx"

# API key exposure
grep -rn "apiKey\s*[:=]" --include="*.ts" --include="*.tsx" | grep -v "process.env"
grep -rn "secret\s*[:=]" --include="*.ts" --include="*.tsx" | grep -v ".env"
```

#### 4.2 Performance Anti-pattern Detection

```bash
# React anti-patterns
grep -rn "new Date()" --include="*.tsx"  # recommend useMemo
grep -rn "\.map.*\.map" --include="*.tsx"  # nested map warning
grep -rn "useEffect.*\[\]" --include="*.tsx"  # check dependency array

# Firestore anti-patterns
grep -rn "getDocs.*getDocs" --include="*.ts"  # N+1 query
grep -rn "setDoc.*for\s*(" --include="*.ts"  # recommend batch processing
```

#### 4.3 Project-specific Rule Verification (CLAUDE.md based)

**Common rules:**
- Firestore queries include `where('userId', '==', uid)`
- API keys are only in Cloud Functions, never client-side

### Phase 5: Test Coverage Analysis

```bash
# Check test file existence
find . -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" | wc -l

# Test-to-implementation file ratio
IMPL_FILES=$(find src -name "*.ts" -o -name "*.tsx" | grep -v ".test" | wc -l)
TEST_FILES=$(find . -name "*.test.ts" -o -name "*.test.tsx" | wc -l)
echo "Coverage ratio: $TEST_FILES / $IMPL_FILES"
```

**Coverage criteria:**
- Minimum: Test files exist (0% to 1%)
- Recommended: Test/implementation file ratio 50% or higher
- Excellent: Test/implementation file ratio 80% or higher

### Phase 6: Report Generation

Output final review results in the following format:

```markdown
# Code Review Report

## Summary

| Category | Score | Status |
|----------|-------|--------|
| Architecture Alignment | X/10 | ✅/⚠️/❌ |
| Requirements Traceability | X/10 | ✅/⚠️/❌ |
| Security Patterns | X/10 | ✅/⚠️/❌ |
| Performance Patterns | X/10 | ✅/⚠️/❌ |
| Test Coverage | X/10 | ✅/⚠️/❌ |
| **Overall** | **X/50** | **Status** |

## Architecture Review

### Files Alignment
- ✅ Matched: X files
- ⚠️ Extra: Y files (not in plan)
- ❌ Missing: Z files (in plan but not implemented)

### Dependency Issues
[List of circular dependencies or layer violations]

## Requirements Traceability

### Traceability Matrix
[Implementation/test status table per FR-xxx]

### Coverage
- Implemented: X/Y (Z%)
- Tested: A/Y (B%)

## Security Issues

### Critical
[List of critical security issues]

### Warning
[List of warning-level security issues]

## Performance Issues

[List of performance anti-patterns]

## Recommendations

1. [Top priority fixes]
2. [Recommended fixes]
3. [Optional improvements]

## Verdict

✅ **PASS** - Ready to commit
or
⚠️ **CONDITIONAL** - Review warnings before proceeding
or
❌ **FAIL** - Fixes required, do not commit
```

## Pass/Fail Criteria

### PASS (Ready to commit)
- Architecture Alignment ≥ 8/10
- Requirements Traceability ≥ 7/10
- Security Issues = 0 Critical
- Overall ≥ 35/50

### CONDITIONAL (Conditional pass)
- Overall ≥ 25/50
- Security Issues = 0 Critical
- At least 1 Warning present

### FAIL (Fixes required)
- Overall < 25/50
- OR Security Critical ≥ 1
- OR Architecture < 5/10

## Integration

### Workflow Position
```
/implement → /review → /verify → /commit-push-pr
```

### Auto-trigger
When `/implement` completes, a message recommending `/review` is displayed (workflow-guide.sh).

## Quick Reference

```bash
# Basic review
/review

# Specific category only
/review --architecture-only
/review --security-only
/review --coverage-only

# Verbose report
/review --verbose
```
