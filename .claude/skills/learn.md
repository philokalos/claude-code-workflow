---
name: learn
description: Capture patterns, rules, and lessons into CLAUDE.md for compounding improvement.
---

# /learn - Compounding Engineering Learning Capture

Capture patterns, rules, and lessons discovered during sessions and accumulate them in CLAUDE.md.

## Usage

```bash
/learn "learning content"
/learn                    # Interactive mode
```

## Execution Instructions

When the user invokes `/learn`:

### 1. With Arguments

```bash
/learn "Firestore compound queries require composite indexes"
```

1. Analyze the learning content and categorize:
   - `firebase/` - Firestore, Functions, Auth related
   - `typescript/` - Types, compiler related
   - `testing/` - Test patterns
   - `git/` - Version control
   - `patterns/` - Code patterns, architecture
   - `pitfalls/` - Gotchas, caveats

2. Determine scope:
   - **Global rule**: Applies to all projects → `.claude/rules/{category}/` or root `CLAUDE.md`
   - **Project rule**: Specific project only → that project's `CLAUDE.md`

3. Check for duplicate rules:
   - Search `.claude/rules/` directory
   - Search root and project CLAUDE.md files
   - If duplicate found, inform "A similar rule already exists"

4. Add the rule:
   - Simple rule → Add to CLAUDE.md `## Common Pitfalls` table
   - Detailed rule → Create new file in `.claude/rules/{category}/`

### 2. Without Arguments (Interactive)

```bash
/learn
```

Ask interactively:
1. "What did you learn?"
2. "Should this rule apply to all projects or just the current one?"
3. Confirm after adding

## Output Format

```markdown
## Learning Captured

**Content**: Firestore compound queries require composite indexes
**Category**: firebase
**Scope**: Global
**Added to**: `.claude/rules/firebase/firestore-security.md`

---
Total accumulated rules: N (firebase: X, typescript: Y, testing: Z, ...)
```

## Automatic Learning Suggestions

This skill may be auto-suggested when:
- The same error occurs 3+ times
- Pattern detected by `verify-on-stop.sh`
- Uncaptured learning detected at session end

## Examples

```bash
# General patterns
/learn "Functions 404 errors are caused by missing region configuration"
/learn "Generic types: use satisfies instead of extends to preserve type inference"

# Project-specific
/learn "In this project, pnpm workspace dependencies should use workspace:* instead of *"
```

## Related

- `/review` - Post-implementation code verification
- `/verify` - Quality verification
- `/commit-push-pr` - Commit and PR
