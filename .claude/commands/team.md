---
description: Agent team parallel collaboration — research, review, debug, batch, health, audit.
---

# /team - Agent Teams Unified Command

Compose agent teams for parallel collaborative work.

## Pre-computed Context

**Branch**: !`git branch --show-current`
**Changed files**:
!`git diff --stat HEAD 2>/dev/null || echo "no changes"`
**Project dirs**:
!`ls -d */ 2>/dev/null | head -20`

## Usage

```
/team                            → Analyze context and recommend template
/team research                   → Template A: Explore-then-implement team
/team review                     → Template B: Parallel review team (dynamic reviewers by project type)
/team debug "hypothesis1" "hypothesis2" → Template C: Hypothesis debugging team
/team batch lint|build|test|security [--tier N]  → Template D: Batch operations
/team health [--deps]            → Template E: Health dashboard
/team audit [--tier N]           → Template F: Comprehensive audit (dependencies + API security)
```

## Template Selection Guidelines

When user enters `/team` without a subcommand, recommend based on these criteria:

1. **research**: New feature implementation, tasks requiring codebase exploration
2. **review**: Multi-angle review after large implementation
3. **debug**: Complex bugs with unclear root cause
4. **batch**: Cross-project batch verification (lint/build/test/security)
5. **health**: Overall project status dashboard
6. **audit**: Dependency + API security comprehensive audit (1-2x per month)

## Template A: Research-Then-Implement

Create team with TeamCreate:

| Role        | Model  | Agent Type       | Constraints                              |
| ----------- | ------ | ---------------- | ---------------------------------------- |
| team-lead   | Opus   | Direct           | Coordination, spec, review, **commits**  |
| researcher  | Sonnet | team-researcher  | Read-only                                |
| implementer | Opus   | team-implementer | plan_approval_required, no git           |

**Execution order**:

1. TeamCreate → TaskCreate (exploration + implementation tasks)
2. Assign exploration tasks to researcher
3. Build implementation plan based on exploration results
4. Assign implementation tasks to implementer (plan approval)
5. Verify → Commit → TeamDelete

## Template B: Parallel Review

Dynamically assign reviewer-1 based on project type:

- Next.js project changes → reviewer-1 = `nextjs-validator` perspective
- Firebase project changes → reviewer-1 = `firebase-validator` perspective
- API call patterns detected → reviewer-1 = `api-guardian` perspective
- Default → reviewer-1 = security + general perspective

| Role             | Model  | Agent Type | Perspective                              |
| ---------------- | ------ | ---------- | ---------------------------------------- |
| team-lead        | Opus   | Direct     | Synthesize reviews, apply fixes          |
| reviewer-1       | Sonnet | Explore    | Dynamic by project type (see rules above)|
| quality-reviewer | Sonnet | Explore    | Code quality + testing perspective       |

**Execution order**:

1. TeamCreate → Specify review target files/scope + analyze project type
2. Determine reviewer-1 perspective based on project type
3. Assign tasks to both reviewers simultaneously
4. Synthesize review results → Apply fixes
5. TeamDelete

## Template C: Debug Hypothesis

| Role         | Model  | Agent Type | Role                                  |
| ------------ | ------ | ---------- | ------------------------------------- |
| team-lead    | Opus   | Direct     | Define hypotheses, conclude, fix      |
| hypothesis-1 | Sonnet | Explore    | Investigate hypothesis A              |
| hypothesis-2 | Sonnet | Explore    | Investigate hypothesis B              |

**Execution order**:

1. TeamCreate → Analyze bug symptoms, define hypotheses
2. Assign hypothesis investigation to each agent
3. Draw evidence-based conclusions → Apply fix
4. TeamDelete

## Template D: Batch Operations

Execute cross-project batch operations based on CLAUDE.md project table.

| Role           | Model  | Agent Type   | Role                                     |
| -------------- | ------ | ------------ | ---------------------------------------- |
| team-lead      | Opus   | Direct       | Parse request, distribute projects, aggregate results |
| batch-worker-1 | Sonnet | batch-worker | Execute project subset 1                 |
| batch-worker-2 | Sonnet | batch-worker | Execute project subset 2                 |

**Usage**:

```
/team batch lint              # All lintable projects
/team batch build             # All buildable projects
/team batch test              # All testable projects
/team batch security          # Security verification for applicable projects
/team batch lint --tier1      # Tier 1 only
```

**Execution order**:

1. Select target projects from CLAUDE.md project table
2. If `--tier` option provided, filter to that tier only
3. TeamCreate → Split projects in half and assign to workers
4. Workers execute in parallel → Report results table
5. Team-lead aggregates results → TeamDelete

## Template E: Health Dashboard

Read-only scan of all project settings/status to generate a dashboard.

| Role      | Model  | Agent Type     | Role                                  |
| --------- | ------ | -------------- | ------------------------------------- |
| team-lead | Opus   | Direct         | Coordination, dashboard compilation   |
| scanner-1 | Sonnet | health-scanner | Scan first half of projects (read-only)|
| scanner-2 | Sonnet | health-scanner | Scan second half (read-only)          |

**Usage**:

```
/team health                  # Full health dashboard
/team health --deps           # Dependency version comparison only
```

**Execution order**:

1. Query all projects from CLAUDE.md project table
2. TeamCreate → Split projects in half and assign to scanners
3. Scanners run parallel scans → Report findings
4. Team-lead compiles dashboard → TeamDelete

**Output**: Version matrix + mismatch alerts + missing scripts + git status

## Template F: Comprehensive Audit

Comprehensive audit team that audits dependencies + API security simultaneously.

| Role        | Model  | Agent Perspective  | Role                                 |
| ----------- | ------ | ------------------ | ------------------------------------ |
| team-lead   | Opus   | Direct             | Aggregate results, organize actions  |
| dep-auditor | Sonnet | dependency-auditor | Dependency + vulnerability scan      |
| api-auditor | Sonnet | api-guardian       | API security + cost risk analysis    |

**Usage**:

```
/team audit                  # All projects
/team audit --tier1          # Tier 1 only
```

**Execution order**:

1. TeamCreate → Determine audit scope
2. Assign dependency audit tasks to dep-auditor
3. Assign API security audit tasks to api-auditor (simultaneously)
4. Team-lead synthesizes both audit results
5. Output prioritized action items list → TeamDelete

**Estimated cost**: ~30-40K tokens, used 1-2x per month.

## Core Principles

- **Only team-lead commits** (team members must not commit)
- **Each team member edits only assigned files/directories**
- **Run `/verify` after team completion**
- **Read-only members use Sonnet, implementation members use Opus**
- **Clean up with TeamDelete after work completes**
- **Cost reference**: 3-agent team ~29K tokens (break-even ~5-7 sequential tasks)

## Excluded Projects

Small or simple projects are excluded from team workflows (single session is more efficient).

**Note**: Template D/E (batch/health) include excluded projects in the registry but auto-SKIP them if the required capability is missing.

## Reference

Detailed documentation: @.claude/docs/team-workflows.md
