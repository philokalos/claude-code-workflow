# Git Commit Convention (VVCS)

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude <claude-model>@anthropic.com
```

## Types

| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| docs | Documentation |
| style | Formatting (no code change) |
| refactor | Code refactoring |
| test | Adding tests |
| chore | Maintenance |

## VVCS Commit Goals

- **Fix commits < 15%** of total commits
- Indicates proper planning reduces bug-fix iterations

## Examples

```bash
# Good
feat(auth): add OAuth2 login support

# Good
fix(firestore): add userId filter to prevent permission denied

# Bad - vague
fix: stuff
```

## Branch Naming

```
<type>/<issue-number>-<short-description>

# Examples
feat/123-oauth-login
fix/456-firestore-permission
```

## Pre-commit Checklist

1. `npm run lint` passes
2. `npm run build` succeeds
3. Tests pass
4. No secrets in code

## Co-Author Attribution

Always include Claude attribution when assisted:

```
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```
