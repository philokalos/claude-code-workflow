---
description: Auto-retry verification loop (max 3 retries with auto-fix).
allowed-tools: Bash(npm:*), Bash(npx:*), Bash(python:*), Bash(go:*), Bash(cargo:*), Bash(make:*), Bash(git:*), Bash(rm:*), Read, Edit, Grep, Glob
argument-hint: [intent description - required if no handoff.md] [--max-retries N] [--only build|test|lint]
---

## Task

### Step 0: Parse Settings

- `--max-retries N`: Maximum retry count (default: 3)
- `--only [type]`: Run specific verification only
- Remainder: Intent description

### Step 1: Collect Initial Environment

1. `git status --short` - Check for changes (abort if none)
2. `git diff --name-only` - List changed files
3. Read: `.claude/handoff.md` (if exists)
4. Read: `CLAUDE.md`, `spec.md`, `prompt_plan.md` (whichever exist)

### Step 2: Determine Intent

- If handoff.md exists: Use handoff.md
- If $ARGUMENTS contains intent: Use $ARGUMENTS
- If neither: Show guidance and abort:
  ```
  ⚠️ Cannot determine intent.
  Retry with: /verify-loop "description of change intent"
  ```

### Step 3: Start Verification Loop

```
════════════════════════════════════════════════════════════════
🔄 Verification Loop started (max_retries: [N])
════════════════════════════════════════════════════════════════
```

For each attempt:

**[Attempt X/N]**

1. **Code Review** (think hard):
   - Run `git diff`
   - Check if implementation matches intent
   - Logic errors, edge cases
   - Unnecessary code (console.log, dead code)
   - Security vulnerabilities

2. **Automated Verification** (by project type):
   - Node.js: `npm run build && npm test && npm run lint`
   - Python: `python -m pytest && python -m flake8`
   - Go: `go build ./... && go test ./...`
   - Rust: `cargo build && cargo test`

3. **Output Results**:
   ```
   ├── Build: ✅/❌
   ├── Test: ✅/❌ (N errors)
   ├── Lint: ✅/⚠️ (N fixable)
   └── TypeCheck: ✅/❌
   ```

### Step 4: Error Analysis on Failure

```
🔍 Analyzing errors...
├── Fixable: N items (type)
└── Manual: N items (type)
```

**Fixable Errors (auto-fix):**

- Missing imports: Auto-add
- Lint formatting: `eslint --fix` or `prettier`
- Unused variables: Delete or add `_` prefix
- Simple type errors: Fix type inference

```
🔧 Auto-fixing...
├── [Fix details]
└── Done
```

**Manual Errors (guidance only):**

```
⚠️ Manual fix required:
  1. [file:line] - [error message]
  2. ...

💡 Hint: [suggested fix]
```

### Step 5: Retry or Exit

**If retryable:**

- After fixing fixable errors: Proceed to next Attempt

**When max_retries reached:**

```
════════════════════════════════════════════════════════════════
❌ Verification Loop failed (all N attempts failed)
════════════════════════════════════════════════════════════════

Recurring errors:
  1. [Error details]
  2. ...

Recommended actions:
  1. Run /handoff - Record current state
  2. /clear and approach with fresh perspective
  3. /learn --from-error to record lessons

🎓 Auto-learn trigger: Consider recording pattern in CLAUDE.md
════════════════════════════════════════════════════════════════
```

Suggest adding to CLAUDE.md `## Learned Rules` section:

```markdown
- [date] [error pattern]: [prevention rule]
```

### Step 6: On Pass

1. `rm .claude/handoff.md` (if exists)
2. Suggest saving auto-checkpoint
3. Output:

```
════════════════════════════════════════════════════════════════
✅ Verification Loop complete (N attempts, success)
════════════════════════════════════════════════════════════════

Next step: /commit-push-pr --merge
```
