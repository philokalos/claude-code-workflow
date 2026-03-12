---
description: Explore codebase structure with keyword expansion.
allowed-tools: Read, Grep, Glob, Bash(git:*)
argument-hint: [path] [--deps]
---

# /explore - Iterative Codebase Exploration (v6)

---

## Step 0: Parse Parameters

| Argument        | Description                                    | Default      |
| --------------- | ---------------------------------------------- | ------------ |
| search term     | Keyword, function name, or pattern (required)  | -            |
| `--auto`        | Auto-refinement mode (3 iterations)            | off          |
| `--interactive` | Interactive refinement mode                    | default      |
| `--depth N`     | Maximum exploration depth                      | 3            |
| `--scope path`  | Limit search scope                             | project root |
| `--deps`        | Include dependency tracking                    | off          |

---

## Step 1: Keyword Expansion

Automatically expand related keywords from input:

| Input    | Expansion                                        |
| -------- | ------------------------------------------------ |
| auth     | login, logout, session, jwt, token, authenticate |
| payment  | checkout, order, cart, invoice, billing          |
| database | query, model, schema, migration, connection      |
| user     | profile, account, member, customer               |
| api      | endpoint, route, handler, controller             |

---

## Step 2: Initial Exploration (broad scope)

### 2-1. Filename Search

```bash
find {scope} -type f -name "*{search term}*" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/.next/*"
```

### 2-2. Code Content Search

Use the Grep tool to search for patterns in code.

Pattern: `{search term}`
Scope: `{scope}` or project root
Exclude: node_modules, .git, dist, .next, build

### 2-3. Git History Search

```bash
git log --all --oneline --grep="{search term}" -10
```

### 2-4. Organize Initial Results

Classify results by category:

- **Files**: Files with search term in filename
- **Definitions**: Function/class/type definitions
- **Usage**: Imports, calls, references
- **Commits**: Related Git history

Relevance scoring:

- Filename match: +30 points
- Content match (keyword count): +10 points/keyword
- Directory match: +20 points
- Import/export frequency: +5 points/occurrence

---

## Step 3: First-pass Filtering and Summary

Select top 15 files:

1. Read first 50 lines of each file
2. Analyze structure (functions, classes, exports)
3. Classify by category

Categories:

- core: Core logic
- api: API handlers
- ui: Components
- types: Type definitions
- utils: Utilities
- test: Tests

---

## Step 4: Refinement Rounds (iterative)

### --interactive mode (default)

Show initial results to user and ask for refinement direction:

```
Exploration results (round 1):
  Files [N] | Definitions [N] | Usage [N] | Commits [N]

  Refinement options:
    1. View specific files in detail
    2. Narrow scope (directory/file type)
    3. Explore related patterns
    4. Trace dependency tree
    5. End exploration
```

Execute next round based on user selection.
Repeat up to `--depth` times.

### --auto mode

Automatically perform 3 refinement rounds:

**Round 1**: Broad scope exploration (Step 2 above)

**Round 2**: Cross-reference definitions and usage

- Check export patterns in definition files
- Check import patterns at usage sites
- Determine dependency direction

**Round 3**: Deep analysis of key files

- Read top 3 most relevant files with Read
- Extract function signatures, type definitions, key logic
- Check for related test files

---

## Step 5: Dependency Tracking (--deps or depth 2+)

Track dependencies of code related to the search term.

### Upstream Tracking (what uses this code)

```bash
grep -rl "import.*{search term}" {scope} --include="*.ts" --include="*.tsx"
```

### Downstream Tracking (what this code depends on)

Analyze import statements in target files to determine dependencies.

### Dependency Graph

```
{search term} dependencies:
  Upstream (consumers):
    src/pages/login.tsx
    src/hooks/useAuth.ts
  Downstream (dependencies):
    src/lib/supabase.ts
    src/types/user.ts
```

---

## Step 6: Build Context

### File Relationship Map

```
  src/auth/index.ts
        |
  ------+------
  |     |     |
login session jwt
  |     |     |
  ------+------
        |
  authGuard.ts
```

### Key Function/Class Summary

```
src/auth/index.ts
  export class AuthService
    - login(email, password): Promise<Session>
    - logout(): void
    - refreshSession(): Promise<Session>
  Called by: src/api/auth.ts, src/hooks/useAuth.ts
  Depends on: src/lib/supabase/auth.ts
```

---

## Step 7: Output

### On Exploration Complete

```
════════════════════════════════════════════════════════════════
  Explore v6 (Codebase Exploration)
════════════════════════════════════════════════════════════════

  Search term: "{search term}"
  Mode: [auto / interactive]
  Scope: {scope}
  Rounds: {N}

  -- Results -------------------------------------------------

  Files ({N}):
    src/auth/login.ts
    src/auth/register.ts
    src/hooks/useAuth.ts

  Definitions ({N}):
    login.ts:15    export async function loginUser(...)
    register.ts:8  export async function registerUser(...)

  Usage ({N}):
    pages/login.tsx:3    import { loginUser } from '@/auth/login'
    hooks/useAuth.ts:5   import { loginUser, registerUser } from '@/auth'

  Dependencies:
    Upstream: 2 files use this code
    Downstream: depends on 3 modules

  -- Summary -------------------------------------------------

  [{search term}] is defined in [N] files, used in [N] files.
  Main entry point: [file path]
  Related tests: [test file path or "none"]

  Impact analysis:
    Modifying [key file]:
      Affected files: [N]
      Tests to re-run: [N]

════════════════════════════════════════════════════════════════
```

### --auto Mode Output

```
════════════════════════════════════════════════════════════════
  Explore v6 (Auto): "{search term}"
════════════════════════════════════════════════════════════════

  [Phase 1-3 auto-executed...]

  Exploration summary:
    Files searched: [N]
    After filtering: [N]
    Loaded: [N]

  Key findings:
    1. [Finding 1 summary]
    2. [Finding 2 summary]
    3. [Finding 3 summary]

  Context loaded

  For further exploration:
    /explore "{search term}" --interactive

════════════════════════════════════════════════════════════════
```

### No Results

```
════════════════════════════════════════════════════════════════
  Explore v6 (Codebase Exploration)
════════════════════════════════════════════════════════════════

  Search term: "{search term}"
  Result: No matches found

  Try:
    - Change search term (check for typos)
    - Expand --scope range
    - Search with related keywords

════════════════════════════════════════════════════════════════
```

---

## Next Steps

| After understanding the code | Command      |
| :--------------------------- | :----------- |
| Create a modification plan   | `/plan`      |
| Start modifying immediately  | `/implement` |
