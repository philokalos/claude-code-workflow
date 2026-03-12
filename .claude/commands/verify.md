---
description: Auto-validate changes with project-type detection and tier-based quality gates.
allowed-tools: Bash(npm *), Bash(npx *), Bash(pnpm *), Bash(git *), Bash(grep *), Bash(find *), Read
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-computed Context

**Working Directory**: !`pwd`

**Changed Files**:

```
!`git diff --name-only HEAD 2>/dev/null | head -20 || echo "(no changes)"`
```

**Staged Files**:

```
!`git diff --name-only --cached 2>/dev/null | head -20 || echo "(none staged)"`
```

**Detected Projects** (from changed files):

```
!`git diff --name-only HEAD --cached 2>/dev/null | grep -oE "^[^/]+" | sort -u || echo "(root level)"`
```

**Package.json Scripts**: Read `package.json` in the detected project directory to find available scripts.

## Goal

"Give Claude a way to verify its work" — Auto-validate changes using domain-specific quality checks.

## Context

> "Probably the most important thing to get great results out of Claude Code:
> give Claude a way to verify its work. If Claude has that feedback loop,
> it will 2-3x the quality of the final result."
> — Boris Cherny, Claude Code creator

## Execution Steps

### 0. --fresh Mode Branch

If user input contains `--fresh`, use the Agent tool to create an Explore subagent
for independent verification in a fresh context:

```
Agent(subagent_type="Explore", prompt="
Verify this project's changes in a fresh context.
1. Check changed files with git diff --name-only HEAD
2. Run npx tsc --noEmit
3. Run npm run lint
4. Run npm test
Return summary only. Do not modify anything.
")
```

Without `--fresh`, execute the steps below directly.

### 1. Analysis (use Pre-computed Context above)

Check which projects and file types changed from the Pre-computed Context, then run appropriate verification.

### 2. Project Type Detection

Auto-detect project type from changed file paths and project configuration:

| Indicator | Type | Detection Method |
| --------- | ---- | ---------------- |
| `vite.config.*` | react_vite | Vite config file exists |
| `next.config.*` | nextjs | Next.js config file exists |
| `pnpm-workspace.yaml` | pnpm_monorepo | pnpm workspace file exists |
| `firebase.json` + `functions/` | firebase_functions | Firebase with functions |
| `package.json` only | node_project | Fallback |

### 2.5 Tier Detection (Optional)

If your CLAUDE.md defines project tiers, apply tier-based verification levels:

| Check | Tier 1 (production) | Tier 2 (active) | Tier 3 (utility) |
| ----- | -------------------- | --------------- | ---------------- |
| TSC | BLOCK | BLOCK | WARN |
| Lint | BLOCK (0 warnings) | WARN | info only |
| Test | BLOCK | WARN | skip |
| Zero tests | WARN | - | - |

### 3. Project-Specific Verification

#### React + Vite Projects

```bash
cd <project-dir>

# Step 1: TypeScript compile check (fast)
npx tsc --noEmit

# Step 2: Lint check
npm run lint

# Step 3: Unit tests (tier-dependent)
npm test

# Step 4: (Optional) E2E tests - related tests only
npx playwright test --grep "<related-pattern>"
```

#### pnpm Monorepo

```bash
cd <project-dir>

# Step 1: Full lint
pnpm run lint

# Step 2: Full test
pnpm run test

# Step 3: E2E (if available)
pnpm run test:e2e
```

#### Next.js Projects

```bash
cd <project-dir>

# Step 1: Production build (includes TypeScript)
npm run build

# Step 2: Lint check
npm run lint
```

#### Static + Functions

```bash
cd <project-dir>

# Step 1: Functions build
cd functions && npm run build

# Step 2: Functions lint (if available)
npm run lint 2>/dev/null || echo "No lint script"

# Step 3: E2E (if available)
cd .. && npx playwright test
```

### 3.5. Performance & Security Profiling

Common profiling across all project types:

#### Security Scan

```bash
# npm audit (vulnerability scan)
npm audit --audit-level=moderate 2>/dev/null || echo "No vulnerabilities found"

# Secret detection (simple version)
grep -rn "apiKey\s*[:=]\s*['\"][^process.env]" \
  --include="*.ts" --include="*.tsx" \
  --exclude-dir=node_modules 2>/dev/null | head -5 || true
```

#### Performance Analysis

```bash
# Bundle size analysis (after build)
if [ -d "dist" ]; then
  echo "Bundle sizes:"
  find dist -name "*.js" -exec du -h {} \; | sort -h | tail -10
fi
```

#### Firebase-Specific Checks (if firebase.json exists)

```bash
# Firestore security rules check
if [ -f "firestore.rules" ]; then
  echo "firestore.rules found"
  grep -q "request.auth != null" firestore.rules && echo "Auth check present" || echo "Missing auth check"
fi

# Region configuration check
grep -rn "getFunctions" --include="*.ts" src/ functions/ 2>/dev/null | head -3 || true
```

### 4. Results Output

Output verification results in a clear format (with Tier if applicable):

```
## Verification Results [Tier X]

| Step | Status | Strictness | Details |
|------|--------|------------|---------|
| TypeScript | PASS | BLOCK | No errors |
| Lint | PASS | BLOCK/WARN | 0 warnings |
| Unit Tests | PASS | BLOCK/WARN/SKIP | 45/45 passed |
| E2E Tests | SKIP | - | Skipped (not relevant) |
| Security | PASS | - | 0 vulnerabilities |
| Performance | PASS | - | Bundle < 500KB |

### Conclusion
PASS — All checks passed [Tier X] — Ready to commit

OR

### Conclusion
FAIL — Issues found

**TypeScript errors** (2):
- `src/components/Button.tsx:15` - Property 'onClick' is missing
- `src/utils/format.ts:8` - Type 'string' is not assignable

**Recommended fixes**:
1. Add onClick prop to Button component
2. Fix format function return type
```

## Operating Principles

### Verification Priority

1. **Fast feedback**: TypeScript → Lint → Unit Tests (fastest first)
2. **Progressive verification**: Stop on failure and suggest fixes
3. **Selective E2E**: Only run E2E when related changes exist

### Auto-Branch Logic

- Auto-detect project from changed file paths
- When multiple projects changed, verify each independently
- Root-level changes recommend full project verification

### On Failure

- Provide specific error messages with file locations
- Suggest possible fixes
- Classify by severity (error vs warning)

## Quick Reference

```bash
# Full verification (auto-detect)
/verify

# Specific project only
/verify my-project

# Specific step only
/verify --lint-only
/verify --test-only

# Include E2E
/verify --with-e2e
```

## Integration with /commit-push-pr

After verification passes, connect to commit workflow:

```
/verify → pass → /commit-push-pr
```
