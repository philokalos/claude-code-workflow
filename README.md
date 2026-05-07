# Claude Code Workflow Framework

A production-tested workflow framework for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

**17 slash commands** | **12 agents** | **5 hooks** | **3 skills** | **6 rules**

Built and refined across 18 production projects over months of daily use.

## The Problem

You're a solo developer running multiple projects. You don't have a team to review your code, catch repeated mistakes, or keep quality consistent across repos. Every time you switch projects, you lose context. Every time you return to an old project, you start from scratch.

Claude Code is powerful, but without structure it becomes an ad-hoc conversation — different quality every time, same mistakes repeated, no institutional memory.

## The Solution

This framework gives you:

- **A consistent pipeline** — `/specify` → `/plan` → `/implement` → `/verify` → `/commit-push-pr`. Same quality gates, every project, every time.
- **A virtual team** — 12 AI agents that review your code, audit dependencies, check security, and validate patterns. No human team required.
- **A memory that improves** — errors detected 3+ times automatically become rules via `/learn`. Your Claude gets smarter with every session.
- **Cross-project operations** — `/team batch lint --tier1` runs linting across all your projects in parallel. `/team health` gives you a dashboard of every project's status.

## Quick Start

### One-Line Install

```bash
# Full framework
curl -fsSL https://raw.githubusercontent.com/philokalos/claude-code-workflow/main/install.sh | bash -s /path/to/your-project

# Minimal (5 core commands + 1 agent)
curl -fsSL https://raw.githubusercontent.com/philokalos/claude-code-workflow/main/install.sh | bash -s -- --minimal /path/to/your-project
```

### Manual Install

```bash
git clone https://github.com/philokalos/claude-code-workflow.git /tmp/ccw
cp -r /tmp/ccw/.claude/ /path/to/your-project/.claude/
cp /tmp/ccw/.claude/templates/CLAUDE.md.template /path/to/your-project/CLAUDE.md
# Edit CLAUDE.md with your project details
```

### Start Using

```bash
cd your-project
claude

# Describe a feature in plain language
/specify add user authentication with email and OAuth

# Generate an implementation plan
/plan

# Execute the plan
/implement

# Auto-validate (runs tsc, eslint, tests, security checks)
/verify

# Commit, push, and create PR
/commit-push-pr
```

## What Makes This Different

### 1. Self-Improving System (Compounding Loop)

Most workflow tools are static. This one learns:

```
Session 1: You hit a Firestore permission error
Session 2: Same error again
Session 3: Same error → /learn detects the pattern
Session 4+: Claude automatically prevents the error before it happens
```

The `verify-on-stop` hook logs error patterns to JSONL. When a pattern appears 3+ times, it's added to `pending-rules.md`. Run `/learn` to promote it to a permanent rule that applies across all future sessions.

### 2. Pre-Implementation Safety Nets

Other tools check after you've already written the code. This framework checks **before**:

```
You: "Upgrade React to 19"
Hook: ⚠️ React 18.3.1 is frozen in this project (defined in CLAUDE.md)
→ Write blocked. No broken code to clean up.
```

The `pre-implementation.sh` hook intercepts `package.json` edits and validates:
- Major version upgrades against frozen versions
- Lock file consistency (npm vs yarn vs pnpm)
- Node engine constraints
- Duplicate dependency conflicts

### 3. Solo Developer "Team" Mode

You're one person, but `/team` gives you parallel collaboration:

```
/team review     → 2 agents review your code simultaneously (quality + security)
/team debug      → 2 agents investigate different hypotheses in parallel
/team health     → 2 agents scan all your projects and compile a dashboard
/team batch lint → 2 agents run linting across your entire portfolio
```

Each team completes in one command. No coordination overhead.

### 4. Zero-Config Project Detection

The hooks auto-detect your project type. No configuration needed:

| Detected By | Checks Run |
|---|---|
| `tsconfig.json` | `tsc --noEmit` |
| `.eslintrc.*` / `eslint.config.js` | `eslint` |
| `vitest` in package.json scripts | `vitest --run` |
| `jest` in package.json scripts | `jest --bail` |
| `pyproject.toml` / `requirements.txt` | `mypy`, `pytest` |
| `next.config.*` | `'use client'` directive check |
| `innerHTML` / `eval()` in code | Security warning |

## The Pipeline

```
 ┌─────────┐    ┌──────┐    ┌───────────┐    ┌────────┐    ┌────────┐
 │ /specify │───>│ /plan │───>│/implement │───>│/verify │───>│/commit │
 └─────────┘    └──────┘    └───────────┘    └────────┘    └────────┘
      │              │             │               │             │
   spec.md      plan.md      tasks.md        lint/test      git push
                                              build          PR create
```

**Each step is optional.** Quick fix? Just `/verify` → `/commit-push-pr`. Complex feature? Use the full pipeline.

### All Commands

| Command | Purpose |
|---|---|
| `/specify` | Create structured spec from plain language |
| `/plan` | Generate implementation plan with dependencies |
| `/implement` | Execute tasks from plan |
| `/verify` | Auto-validate with project-type detection |
| `/commit-push-pr` | Git workflow automation |
| `/review` | Post-implementation architecture review |
| `/explore` | Iterative codebase exploration |
| `/team` | Agent team parallel collaboration |
| `/audit` | Security and compliance checks |
| `/deploy` | Pre/post-deploy validation |
| `/docs` | Auto-generate API, architecture, user guide docs |
| `/verify-loop` | Auto-retry verification (max 3 attempts with auto-fix) |
| `/analyze` | Cross-artifact consistency analysis |
| `/clarify` | Identify underspecified areas in specs |
| `/checklist` | Generate custom checklists |
| `/tasks` | Create dependency-ordered task lists |
| `/constitution` | Create project conventions document |

### All Agents

**Core** (work with any stack):

| Agent | Role |
|---|---|
| `code-reviewer` | Code quality and security review |
| `api-guardian` | External API security and cost validation |
| `dependency-auditor` | Cross-project dependency audit |
| `code-simplifier` | Complexity reduction proposals |
| `test-suggester` | Test case recommendations |
| `migration-planner` | Framework/library migration planning |

**Team** (for parallel collaboration):

| Agent | Role |
|---|---|
| `team-researcher` | Read-only codebase exploration |
| `team-implementer` | Task-based implementation |
| `batch-worker` | Cross-project batch execution |
| `health-scanner` | Project health scanning |

**Examples** (stack-specific, customize for your stack):

| Agent | Role |
|---|---|
| `firebase-validator` | Firebase security rules, region, auth patterns |
| `nextjs-validator` | Next.js server/client component patterns |

## Directory Structure

```
.claude/
├── commands/          # 17 slash commands
├── skills/            # learn, promptlint, frontend-design
├── agents/
│   ├── core/          # 6 universal agents
│   ├── team/          # 4 team collaboration agents
│   └── examples/      # Stack-specific examples
├── hooks/             # 5 automation hooks
│   ├── workflow-guide.sh       # Smart workflow suggestions (UserPromptSubmit)
│   ├── pre-implementation.sh   # Version conflict prevention (PreToolUse)
│   ├── format-code.sh          # Auto-format on edit (PostToolUse)
│   ├── verify-on-stop.sh       # Quality checks on stop (Stop)
│   └── verify-subagent.sh      # Subagent validation (SubagentStop)
├── rules/
│   ├── core/          # Universal rules (verification, git, testing)
│   └── examples/      # Stack-specific rules (TypeScript, Firebase)
├── docs/              # Workflow and team documentation
├── scripts/           # Helper scripts for hooks
└── templates/         # CLAUDE.md and settings.local.json templates
```

## Adoption Path

### Day 1: Minimal

```bash
# Install core only
./install.sh --minimal /path/to/your-project
```

You get: `/specify` → `/plan` → `/implement` → `/verify` → `/commit-push-pr` + `code-reviewer` agent.

### Week 1: Add Quality Gates

- Enable hooks (`format-code`, `verify-on-stop`)
- Add `/learn` skill for error pattern detection
- Add `/review` for post-implementation checks

### Month 1: Full Framework

- Enable all hooks including `pre-implementation`
- Add team workflows for complex tasks
- Customize agents for your stack (copy from `examples/`)
- Build your own rules from patterns `/learn` discovers

## Language & Framework Support

The hooks auto-detect and support multiple ecosystems:

| Ecosystem | Linting | Type Checking | Testing | Security |
|---|---|---|---|---|
| TypeScript/JavaScript | ESLint | tsc | Vitest, Jest | innerHTML/eval detection |
| Python | — | mypy | pytest | eval/exec/pickle detection |
| Next.js | ESLint | tsc | Vitest/Jest | 'use client' directive |

To add support for other languages, extend the detection logic in `verify-on-stop.sh`.

## Models

Agent frontmatter uses model aliases (`opus`, `sonnet`, `haiku`) which Claude Code resolves to the latest in each family. Pin a specific version when reproducibility matters:

| Alias | Current ID (as of release) | Use for |
|---|---|---|
| `opus` | `claude-opus-4-7` | Migration planning, deep architecture review |
| `sonnet` | `claude-sonnet-4-6` | Default — code review, implementation, validation |
| `haiku` | `claude-haiku-4-5-20251001` | High-throughput scans, batch health checks |

To override per-agent, set `model: claude-sonnet-4-6` (or any full ID) in the agent's frontmatter.

## Dependencies

### Required
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI

### Optional
- [speckit](https://github.com/speckit/speckit) — Enhanced spec/plan/task management. Commands that reference speckit (`/specify`, `/plan`, `/tasks`, `/implement`, `/analyze`, `/clarify`, `/checklist`) work without it but lose structured document management.
- Node.js — For hooks that run linting/formatting
- Git — For `/commit-push-pr` and version control hooks
- Python — For mypy/pytest support in hooks

## Philosophy

1. **Verify, don't assume** — Never claim a test passes without running it this session
2. **Compound improvements** — Repeated errors automatically become rules
3. **Minimum viable complexity** — Three similar lines beat a premature abstraction
4. **Prevent, don't fix** — Pre-implementation hooks block problems before code is written
5. **Structured freedom** — The pipeline provides guardrails, but every step is optional

## FAQ

**Q: Do I need all 17 commands?**
No. Start with 5: `/specify` → `/plan` → `/implement` → `/verify` → `/commit-push-pr`. Add others as needed.

**Q: Do I need speckit?**
No. 10 commands reference speckit but all have fallback behavior. Core workflow works without it.

**Q: Is this only for TypeScript/Node.js projects?**
No. Commands and agents are language-agnostic. Hooks auto-detect TypeScript, Python, and Next.js. For other languages, extend the hook detection logic. Stack-specific rules in `rules/examples/` are just examples — use or ignore them.

**Q: How do teams work?**
`/team` launches multiple agents in parallel. Each template defines a collaboration pattern (research, review, debug, batch, health, audit). See `.claude/docs/team-workflows.md`.

**Q: Will this slow down Claude Code?**
Hooks add minimal overhead. `format-code.sh` runs only on supported file types. `verify-on-stop.sh` runs only when there are actual changes. `workflow-guide.sh` is a simple keyword check.

## Contributing

Contributions welcome! Please:
1. Keep changes focused and minimal
2. Test with a clean project before submitting
3. Follow the commit convention: `<type>(<scope>): <subject>`

## License

MIT
