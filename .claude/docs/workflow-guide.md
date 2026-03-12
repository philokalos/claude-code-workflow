# Developer Workflow Guide

**VVCS + Compounding Engineering Integrated Workflow**

---

## Overview

This workflow combines two core principles:

1. **VVCS (Verified Vibe Coding Protocol)**: Plan-First development to minimize fix commits
2. **Compounding Engineering**: Learn from failures and accumulate rules

```
[Failure] → [Learning] → [Rule] → [Auto-Apply] → [Prevent Recurrence]
```

---

## Daily Cycle

### 1. Session Start

```bash
claude
```

Auto-checks:
- `pending-rules.md` rule candidate notifications

### 2. Task Request

| Request Type | Keywords | Auto Action |
| ------------ | -------- | ----------- |
| Simple | "fix", "change" | Execute immediately |
| Implementation | "implement", "add", "create" | Plan-First recommended |
| Complex | "refactor", "architecture" | `think harder` recommended |
| Security/Perf | "security", "optimize" | `ultrathink` recommended |

### 3. Plan-First Workflow (Recommended)

```bash
# Step 1: Write specification
/specify

# Step 2: Technical design
/plan

# Step 3: Implementation
/implement

# Step 4: Verification
/verify

# Step 5: Commit
/commit-push-pr
```

### 4. Quick Execution (Simple Tasks)

```bash
# Skip Plan-First
"Just do it" or describe the simple change directly
```

---

## Learning Loop

### Automatic Error Detection

```
Session end → verify-on-stop.sh detects errors + records to failures.jsonl
Error pattern repeats (3x) → auto-adds rule candidate to pending-rules.md
```

### Manual Learning Capture

```bash
# Register a pattern discovered during session
/learn "learning content"

# Examples
/learn "Firestore compound queries require composite indexes"
/learn "pnpm workspace dependencies should use workspace:*"
```

### Rule Review

```bash
# Check pending rules
cat .claude/pending-rules.md

# Approve
/learn "rule content"

# Reject → delete the entry
```

---

## Analysis

### VVCS Dashboard

```bash
# Cost analysis (ccusage)
npx ccusage@latest daily --breakdown --compact   # Daily cost
npx ccusage@latest monthly --breakdown            # Monthly cost
```

Target metrics:
- Fix commits < 15% (manual check from git log)
- Plan-First > 50% (observe session patterns)

### Compounding Analysis

Error patterns are auto-recorded by `verify-on-stop.sh` → rule candidates added to `pending-rules.md`.

```bash
# Check error logs
cat ~/.claude/context/failures.jsonl | tail -20

# Check recurring error counts
cat ~/.claude/error-counts.json

# Review rule candidates
cat .claude/pending-rules.md
```

---

## Automation System

### Hooks

| Hook | Trigger | Purpose |
| ---- | ------- | ------- |
| `pre-implementation.sh` | PreToolUse (Edit/Write) | Version conflict prevention |
| `format-code.sh` | PostToolUse (Edit/Write) | **Auto-formatting** (prevent CI errors) |
| `verify-on-stop.sh` | Stop | **Comprehensive verification**: TSC + ESLint + Tests + Security + Error logging + Rule suggestions |
| `verify-subagent.sh` | SubagentStop | Subagent completion validation |

### Auto-Formatting

> "We use a PostToolUse hook to format Claude's code. Claude usually generates
> well-formatted code out of the box, and the hook handles the last 10% to
> avoid formatting errors in CI later." — Boris Cherny

**How it works:**
1. Auto-runs after Edit/Write
2. Prettier first (if `.prettierrc` exists)
3. ESLint --fix fallback (if no Prettier)
4. Skips files > 100KB (performance)

### Stop Hook Verification

> "For very long-running tasks, I will either (a) prompt Claude to verify its
> work with a background agent when it's done, (b) use an agent Stop hook to
> do that more deterministically." — Boris Cherny

**Verification items:**
1. TypeScript compile check (`tsc --noEmit --skipLibCheck`)
2. ESLint validation (changed files)
3. Test execution (vitest/jest, 30-second timeout)
4. Security pattern check (innerHTML/eval/dangerouslySetInnerHTML)
5. Error logging (`~/.claude/context/failures.jsonl`)
6. Error pattern counting + rule suggestions

### Skills

| Skill | Purpose |
| ----- | ------- |
| `/learn` | Manual learning capture |
| `/promptlint` | Prompt quality evaluation (GOLDEN checklist) |
| `/frontend-design` | Production-grade frontend interface generation |

### Key Commands

| Command | Purpose |
| ------- | ------- |
| `/specify` | Write specification |
| `/plan` | Technical design |
| `/implement` | Execute implementation |
| `/verify` | Quality verification |
| `/commit-push-pr` | Commit and PR |
| `/team` | Agent team parallel collaboration |

### Subagents

Specialized agents running in independent contexts.

| Subagent | Role | When Used |
| -------- | ---- | --------- |
| `code-reviewer` | Code quality/security review | After implementation (proactive) |
| `firebase-validator` | Firebase-specific validation | When Firestore/Functions change |
| `code-simplifier` | Code simplification proposals | After implementation (optional) |
| `test-suggester` | Test case proposals | After new features |
| `nextjs-validator` | Next.js framework validation | When Next.js project files change |
| `api-guardian` | API security/cost validation | When external API patterns detected |
| `dependency-auditor` | Dependency audit | When package.json changes |
| `migration-planner` | Migration planning (Opus) | Manual invocation only |
| `team-researcher` | Codebase exploration (team-only) | `/team research` |
| `team-implementer` | Task-based implementation (team-only) | `/team research` |

**Auto-routing**: Agents are auto-selected based on changed file patterns as defined in CLAUDE.md Agent Routing rules.

**Project context**: Subagents reference the current project's `CLAUDE.md` based on the working directory (pwd).

### Agent Teams (Parallel Collaboration)

Teams use inter-agent communication + shared tasks for parallel work.
Use 3-5x more tokens than subagents, but enable communication and continuous context sharing.

**Subagent vs Team decision:**
```
Q1. Need inter-agent communication?  NO → Subagent
Q2. Expect 5+ sequential steps?     NO → Parallel subagents
                                     YES → Team
```

| Template | Composition | Use Case |
| -------- | ----------- | -------- |
| `/team research` | lead + researcher + implementer | Exploration → implementation |
| `/team audit` | lead + dep-auditor + api-auditor | Comprehensive audit |
| `/team review` | lead + security-reviewer + quality-reviewer | Multi-angle review |
| `/team debug` | lead + hypothesis-1 + hypothesis-2 | Complex bug debugging |

**Key principles:**
1. Only team-lead commits (team members cannot commit)
2. Run `/verify` after team completes
3. Read-only team members use Sonnet, implementers use Opus
4. Clean up with `TeamDelete` after completion

Details: `.claude/docs/team-workflows.md`

---

## Directory Structure

```
.claude/
├── agents/             # Subagent/Team agent definitions
├── rules/              # Detailed rules
│   ├── core/           # Universal rules
│   └── examples/       # Stack-specific example rules
├── skills/
│   └── learn.md        # /learn skill
├── hooks/
│   ├── workflow-guide.sh      # UserPromptSubmit
│   ├── pre-implementation.sh  # PreToolUse: version conflict prevention
│   ├── format-code.sh         # PostToolUse: auto-formatting
│   ├── verify-on-stop.sh      # Stop: comprehensive verification
│   └── verify-subagent.sh     # SubagentStop: subagent verification
├── scripts/
│   └── generate-mini-spec.sh  # Auto spec draft (called by workflow-guide.sh)
├── commands/
│   └── team.md                # /team integrated command
└── docs/
    ├── workflow-guide.md      # This document
    └── team-workflows.md      # Team workflow details

CLAUDE.md                      # Project rules and common pitfalls
```

---

## Workflow Diagram

```
┌──────────────┐
│ Session Start │
└──────┬───────┘
       │
       ▼
┌──────────────┐     ┌─────────────┐
│ Review Rule  │────▶│ /learn      │
│ Candidates   │     └─────────────┘
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ Task Request  │
└──────┬───────┘
       │
   ┌───┴───┬───────────┐
   ▼       ▼           ▼
[Simple] [Complex]  [Parallel]
   │       │           │
   │       ▼           ▼
   │  ┌──────────┐  ┌──────────┐
   │  │Plan-First│  │ /team    │
   │  │specify → │  │ research │
   │  │plan →    │  │ review   │
   │  │implement │  │ debug    │
   │  └────┬─────┘  └────┬────┘
   │       │              │
   └───┬───┘──────────────┘
       │
       ▼
┌──────────────┐
│ Implementation│◀─────────┐
└──────┬───────┘           │
       │                   │
   ┌───┴───┐              │
   ▼       ▼              │
[Pass]  [Fail]─────────────┤
   │       │               │
   │       ▼               │
   │  ┌──────────────┐    │
   │  │ Error Analysis│    │
   │  │ (3x repeat?) │    │
   │  └──────┬───────┘    │
   │         │             │
   │         ▼             │
   │  ┌──────────────┐    │
   │  │ Rule Suggest  │────┘
   │  │ /learn        │
   │  └───────────────┘
   │
   ▼
┌────────────────────────────┐
│    Subagent Review          │
│  Auto-selected by routing  │
└──────────┬─────────────────┘
           │
           ▼
    ┌──────────────┐
    │   /verify    │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │  /commit     │
    └──────┬───────┘
           │
           ▼
    ┌──────────────┐
    │  Session End  │
    └──────┬───────┘
           │
           ▼
┌─────────────────────────────────────┐
│     Stop Hook Verification           │
│  verify-on-stop.sh                   │
│  (TSC + ESLint + Tests + Security)   │
└──────────────────────────────────────┘
```

---

## Target Metrics

| Metric | Target | How to Measure |
| ------ | ------ | -------------- |
| Fix commit ratio | < 15% | `git log --oneline` manual analysis |
| Plan-First ratio | > 50% | Observe session patterns |
| Recurring errors | 0 | `~/.claude/error-counts.json` |
| Accumulated rules | Growing | `.claude/rules/` count |
| Daily cost | Track | `npx ccusage@latest daily --breakdown` |

---

## Quick Reference

```bash
# Daily commands
/learn "rule"          # Learning capture
/specify               # Write spec
/plan                  # Technical design
/implement             # Implementation
/verify                # Verification
/commit-push-pr        # Commit

# Subagent commands (auto-routing)
"review the code"              # code-reviewer
"validate Firebase"            # firebase-validator
"simplify the code"            # code-simplifier
"suggest test cases"           # test-suggester
"security review"              # api-guardian + firebase-validator
"audit dependencies"           # dependency-auditor
"create migration plan"        # migration-planner (Opus)

# Team commands
/team                  # Analyze context and recommend
/team research         # Explore → implement team
/team review           # Parallel review team
/team debug "h1" "h2"  # Hypothesis debugging team
/team audit            # Dependency + API audit

# Analysis
npx ccusage@latest daily --breakdown --compact  # Cost analysis
cat ~/.claude/error-counts.json                  # Recurring errors
cat .claude/pending-rules.md                     # Rule candidates

# Think modes
think hard             # Multi-file
think harder           # Architecture
ultrathink             # Security/performance
```

---

## References

- [Dan Shipper's Compounding Engineering](https://every.to/chain-of-thought/compounding-engineering)
- [Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)
