# Agent Teams Workflow

**Inter-agent communication + shared tasks for parallel work.**

---

## Decision Framework: Subagent vs Team

```
Q1. Is this a cross-project batch operation?
    YES → Template D (batch) or E (health)
    NO  → Q2

Q2. Do agents need to communicate with each other?
    NO  → Subagent (standard, 1.5-2x tokens)
    YES → Q3

Q3. Are 5+ sequential steps expected?
    NO  → Parallel subagents (2-3 Task tool calls)
    YES → Team A/B/C (3-5x tokens, persistent context)
```

### Cost Reference

| Template | Agent Count | Est. Tokens | Best For |
| -------- | ----------- | ----------- | -------- |
| Subagent | 1 | 1.5-2x | One-off, independent context |
| A/B/C (single project) | 3 | ~29K | 5-7+ sequential steps |
| D (batch, 2 workers) | 3 | ~35-50K | ≤10 projects |
| D (batch, 3 workers) | 4 | ~45-65K | 10+ projects |
| E (health) | 3 | ~25-35K | Read-only full scan |
| F (audit) | 3 | ~30-40K | Comprehensive audit |

- Only team-lead uses Opus; others use Sonnet for cost optimization
- D/E cut wall-clock time ~3x vs sequential execution

---

## Team Suitability

### Template A/B/C (Single Project)

Teams are most valuable for:
- **High suitability**: Complex projects with multiple sub-modules, monorepo workspaces, or multi-language backends
- **Medium suitability**: Large projects with significant codebase
- **Low suitability**: Small-to-medium, single-stack projects
- **Exclude**: Static HTML or single-component projects

### Template D/E (Cross-Project)

All projects in the repository are candidates. Team-lead filters based on CLAUDE.md project table.

---

## Team Templates (6 Types)

### Single Project Templates (A/B/C)

### Template A: Research-Then-Implement

```
team-lead (Opus)     — coordination, specs, review, commits
researcher (Sonnet)  — codebase exploration (read-only)
implementer (Opus)   — plan_approval_required, code writing
```

**Use when**: Medium-to-large feature requiring codebase exploration

**Workflow**:
1. Team-lead decomposes requirements into tasks
2. Researcher explores related code/patterns and reports
3. Team-lead creates implementation plan based on findings
4. Implementer writes code after plan approval
5. Team-lead verifies + commits

### Template B: Parallel Review

```
team-lead (Opus)          — review synthesis, apply fixes
reviewer-1 (Sonnet)       — dynamic perspective by project type (read-only)
quality-reviewer (Sonnet)  — code quality + test perspective (read-only)
```

**Use when**: Multi-angle review after large implementation
**Difference from subagents**: 2 reviewers run in parallel + can cross-reference

**reviewer-1 dynamic assignment**:
- Next.js project changes → `nextjs-validator` perspective
- Firebase project changes → `firebase-validator` perspective
- API call patterns detected → `api-guardian` perspective
- Default → security + general perspective

### Template C: Debug Hypothesis

```
team-lead (Opus)       — define hypotheses, draw conclusions, apply fixes
hypothesis-1 (Sonnet)  — investigate hypothesis A (read-only)
hypothesis-2 (Sonnet)  — investigate hypothesis B (read-only)
```

**Use when**: Complex bug with unclear root cause
**Key**: Agents challenge each other's theories to converge on the answer

### Cross-Project Templates (D/E/F)

### Template D: Batch Operations

```
team-lead (Opus)        — parse request, distribute projects, aggregate results
batch-worker-1 (Sonnet) — execute on project subset 1
batch-worker-2 (Sonnet) — execute on project subset 2
```

**Use when**: Cross-project batch verification (lint/build/test/security)

### Template E: Health Dashboard

```
team-lead (Opus)     — coordination, dashboard compilation
scanner-1 (Sonnet)   — scan first half of projects (read-only)
scanner-2 (Sonnet)   — scan second half (read-only)
```

**Use when**: Full project status snapshot, dependency version audit
**Completely read-only**: No file modifications

### Template F: Comprehensive Audit

```
team-lead (Opus)        — aggregate results, organize action items
dep-auditor (Sonnet)    — dependency + vulnerability scan
api-auditor (Sonnet)    — API security + cost risk
```

**Use when**: Dependency vulnerabilities + API security comprehensive audit (monthly)
**Read-only**: No file modifications

---

## Review System Role Separation

| System | Role | When |
| ------ | ---- | ---- |
| `verify-on-stop.sh` | **Auto basic verification**: TSC + ESLint + Tests | Session end (automatic) |
| `/verify` | **Manual comprehensive verification**: Above + security + bundle | User request |
| `code-reviewer` subagent | **Code quality review**: patterns, complexity, type safety | After implementation (proactive) |
| `/review` | **Architecture review**: verify structure against plan.md | Within specify→plan→implement workflow |
| **Team Review** | **Multi-angle parallel review**: security + quality + cross-reference | `/team review` request |

---

## Core Principles

1. **Only team-lead commits** (team members cannot commit)
2. **Each team member edits only assigned files/directories**
3. **Always run `/verify` after team completion**
4. **Read-only members use Sonnet, implementers use Opus**
5. **Clean up with `TeamDelete` after team work completes**

---

## `/team` Command Usage

```bash
/team                            # Analyze context and recommend
/team research                   # Template A
/team review                     # Template B (dynamic reviewers)
/team debug "hypothesis1" "h2"   # Template C
/team batch lint                 # Template D: lint all
/team batch build --tier1        # Template D: Tier 1 only
/team batch security             # Template D: security scan
/team health                     # Template E: full health dashboard
/team health --deps              # Template E: dependency versions only
/team audit                      # Template F: comprehensive audit
/team audit --tier1              # Template F: Tier 1 only
```

Details: `.claude/commands/team.md`

---

## References

- [Claude Code Teams Documentation](https://docs.anthropic.com/en/docs/claude-code/teams)
