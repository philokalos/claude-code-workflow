# CLAUDE.md — Claude Code Workflow Framework

This is the source repo for a public Claude Code workflow framework.

## What This Repo Contains

A complete `.claude/` directory structure with:
- 17 slash commands (specify → plan → implement → verify → commit pipeline)
- 3 skills (learn, promptlint, frontend-design)
- 12 agents (7 core + 4 team + 1 examples)
- 5 hooks (workflow-guide, pre-implementation, format-code, verify-on-stop, verify-subagent)
- 6 rules (3 core + 3 examples)

## Rules for This Repo

1. **No personal data**: No usernames, personal paths, or project-specific names
2. **English primary**: All text in English. Korean only in clearly marked examples
3. **Generic examples**: Use `my-app`, `api-server`, `web-frontend` — never real project names
4. **No hardcoded paths**: No absolute paths. Use relative paths or environment variables
5. **Stack-agnostic core**: Core components must work with any tech stack

## Verification

Before claiming any file is "generalized", run:

```bash
# Must return 0 results
grep -rn "philokalos\|asia-northeast3\|dailystream\|voice-journal\|morph\|kyeol\|ai-task-matrix\|ledger\|prompt-evolution\|/Volumes/\|/Users/" .claude/
```
