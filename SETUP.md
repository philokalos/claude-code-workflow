# Setup Guide

How to adopt this workflow framework in your own project.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- Git repository initialized
- (Optional) [speckit](https://github.com/speckit/speckit) for enhanced spec/plan/task management

## Installation

### Option A: One-Line Install (Recommended)

```bash
# Full framework
curl -fsSL https://raw.githubusercontent.com/philokalos/claude-code-workflow/main/install.sh | bash -s /path/to/your-project

# Minimal (5 core commands + 1 agent + 3 rules)
curl -fsSL https://raw.githubusercontent.com/philokalos/claude-code-workflow/main/install.sh | bash -s -- --minimal /path/to/your-project
```

The install script automatically:
- Copies the framework to your project
- Creates `CLAUDE.md` from template (if none exists)
- Creates `settings.local.json` with hooks pre-configured
- Makes hook scripts executable

### Option B: Manual Full Install

```bash
git clone https://github.com/philokalos/claude-code-workflow.git /tmp/ccw
cp -r /tmp/ccw/.claude/ /path/to/your-project/.claude/
cp /tmp/ccw/.claude/templates/CLAUDE.md.template /path/to/your-project/CLAUDE.md
cp /tmp/ccw/.claude/templates/settings.local.json.template /path/to/your-project/.claude/settings.local.json
chmod +x /path/to/your-project/.claude/hooks/*.sh
rm -rf /tmp/ccw
```

### Option C: Minimal Manual Setup

Pick only what you need:

```bash
# Core commands only (specify → plan → implement → verify → commit)
mkdir -p your-project/.claude/commands
cp ccw/.claude/commands/{specify,plan,implement,verify,commit-push-pr}.md your-project/.claude/commands/

# Core rules
mkdir -p your-project/.claude/rules/core
cp ccw/.claude/rules/core/* your-project/.claude/rules/core/

# One agent
mkdir -p your-project/.claude/agents/core
cp ccw/.claude/agents/core/code-reviewer.md your-project/.claude/agents/core/
```

## Configuration

### 1. Create CLAUDE.md

```bash
cp .claude/templates/CLAUDE.md.template CLAUDE.md
```

Edit `CLAUDE.md` and replace all `{{PLACEHOLDER}}` values with your project details.

### 2. Configure Hooks

```bash
cp .claude/templates/settings.local.json.template .claude/settings.local.json
```

Hooks are configured in `.claude/settings.local.json`. Each event uses the matcher format (`{ "matcher": "...", "hooks": [...] }`); hook scripts read JSON from stdin.

| Hook | Event(s) | Matcher | Purpose |
|------|----------|---------|---------|
| `workflow-guide.sh` | SessionStart, UserPromptSubmit | — | Pending-rule notice + workflow suggestions |
| `pre-implementation.sh` | PreToolUse | `Edit\|Write\|MultiEdit` | Block version conflicts before writes |
| `format-code.sh` | PostToolUse | `Edit\|Write\|MultiEdit` | Auto-format after file edits |
| `verify-on-stop.sh` | Stop | — | Run quality checks when Claude stops |
| `verify-subagent.sh` | SubagentStop | — | Validate subagent completion |

**To disable a hook**: Remove its entry from `settings.local.json`.

### 3. Set Up Rules

Rules in `.claude/rules/` are automatically loaded by Claude Code.

**Core rules** (recommended for all projects):
- `verification.md` — "No claim without proof" enforcement
- `git/commit-convention.md` — Conventional commit messages
- `testing/coverage.md` — Test standards

**Stack-specific rules** (copy from examples if applicable):
```bash
# For TypeScript projects
cp .claude/rules/examples/typescript-strict-mode.md .claude/rules/typescript/strict-mode.md

# For Firebase projects
cp .claude/rules/examples/firebase-*.md .claude/rules/firebase/
```

### 4. Choose Agents

**Core agents** work with any tech stack:
- `code-reviewer.md` — Code quality and security review
- `api-guardian.md` — External API security/cost validation
- `code-simplifier.md` — Complexity reduction proposals
- `dependency-auditor.md` — Cross-project dependency audit
- `migration-planner.md` — Framework/library migration planning
- `test-suggester.md` — Test case proposals

**Team agents** (for parallel collaboration):
- `team-researcher.md` — Read-only codebase exploration
- `team-implementer.md` — Task-based implementation
- `batch-worker.md` — Cross-project batch execution
- `health-scanner.md` — Project health scanning

**Stack-specific agents** (copy and customize from examples):
- `firebase-validator.md` — Firebase-specific checks
- `nextjs-validator.md` — Next.js pattern validation

## Customization Guide

### Adding Agent Routing

In your `CLAUDE.md`, define which agents auto-trigger for which files:

```markdown
## Agent Routing

| File Pattern | Agent | Priority |
|---|---|---|
| `src/api/**` | api-guardian | high |
| `*.test.*` | test-suggester | medium |
| `package.json` | dependency-auditor | low |
| All code | code-reviewer | default |
```

### Creating Custom Agents

Create `.claude/agents/my-agent.md`:

```markdown
---
model: sonnet
description: My custom validator
allowed-tools: Read, Grep, Glob, Bash
---

# My Custom Validator

## Role
[What this agent does]

## When Used
[Trigger conditions]

## Checklist
- [ ] Check 1
- [ ] Check 2

## Output Format
[Expected output structure]

## Constraints
- Read-only
- [Other constraints]
```

### Creating Custom Rules

Create `.claude/rules/my-rule.md`:

```markdown
# My Rule Name

## Required Pattern
[What must always be done]

## Why This Matters
[Explanation]

## Examples
[Good and bad examples]
```

### Customizing Hooks

#### pre-implementation.sh

The hook checks for version conflicts before file writes. To add project-specific frozen versions:

1. Define frozen versions in your `CLAUDE.md`:
   ```markdown
   ## Frozen Versions
   - React: 18.3.1 (do not upgrade)
   - Node: 20.x
   ```

2. The hook will detect and enforce these constraints.

#### verify-on-stop.sh

The stop hook runs quality checks. It auto-detects:
- TypeScript projects (runs `tsc --noEmit`)
- ESLint configuration (runs `eslint`)
- Test frameworks (runs `vitest`/`jest`/`pytest`)
- Next.js projects (checks `use client` directives)
- Security patterns (innerHTML, eval)

To add custom checks, edit the "Custom Checks" section in the hook.

## Without speckit

Several commands (`/specify`, `/plan`, `/implement`, `/tasks`, `/analyze`, `/clarify`, `/checklist`) reference [speckit](https://github.com/speckit/speckit) for structured document management. Without speckit:

- **`/specify`** — Still works; creates spec files in the project root
- **`/plan`** — Still works; creates plan files in the project root
- **`/implement`** — Read task lists from wherever you define them
- **`/verify`** — Fully independent, no speckit needed
- **`/commit-push-pr`** — Fully independent

The commands gracefully degrade when speckit is not installed.

## Recommended Workflow

### Day 1: Minimal
1. Copy core commands + code-reviewer agent
2. Create CLAUDE.md from template
3. Use: `/specify` → `/plan` → `/implement` → `/verify`

### Week 1: Add Quality
4. Enable hooks (format-code, verify-on-stop)
5. Add `/learn` skill for error pattern detection
6. Add `/review` for post-implementation checks

### Month 1: Full Framework
7. Enable all hooks
8. Add team workflows for complex tasks
9. Customize agents for your stack
10. Build your own rules from patterns `/learn` discovers

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Hooks not running | Check `.claude/settings.local.json` hook paths |
| Permission denied on hooks | `chmod +x .claude/hooks/*.sh` |
| Commands not appearing | Ensure `.claude/commands/` files have YAML frontmatter |
| Agents not loading | Check YAML frontmatter in agent `.md` files |
| speckit errors | Install speckit or remove `.specify/` references |
