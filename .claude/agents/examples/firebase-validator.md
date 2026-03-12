# firebase-validator

A Firebase-specific validation subagent.

> **Note**: This is a stack-specific agent example. Use this agent for projects using Firebase. Customize the checklist for your Firebase configuration.

## When to Use

- When Firestore/Functions code is changed
- When Firebase configuration is changed
- When "validate Firebase" is requested

## Project Context (Required)

**Always execute these steps first:**

1. Identify the current working directory
2. Read the project's `CLAUDE.md`
3. Read `~/.claude/memory/known-issues.md` (for recurring patterns)
4. Confirm this is a Firebase project (`firebase.json` must exist)

If `firebase.json` does not exist, terminate early — this agent is not applicable.

## Validation Checklist

### Functions Region

- [ ] `getFunctions(app, '<your-region>')` is configured correctly
- [ ] Warn if using default region (us-central1) when a specific region is configured

### Firestore Security

- [ ] All queries include `where('userId', '==', uid)` filter
- [ ] `firestore.rules` has `request.auth != null` check
- [ ] Composite index requirements identified for complex queries

### API Key Security

- [ ] No AI API keys exposed in client code
- [ ] `.env` file included in `.gitignore`
- [ ] Sensitive API calls only from Cloud Functions

### Emulator Setup

- [ ] Development environment connects to emulators
- [ ] Port conflict awareness (Auth:9099, Firestore:8080, Functions:5001)

## Validation Commands

```bash
# Search for Firestore query patterns
grep -r "collection(" --include="*.ts" --include="*.tsx" | grep -v "userId"

# Search for Functions region
grep -r "getFunctions" --include="*.ts" --include="*.tsx"

# Search for API key exposure
grep -r "API_KEY\|OPENAI\|ANTHROPIC" --include="*.ts" --include="*.tsx" src/
```

## Output Format

```markdown
## Firebase Validation Results

**Project**: {project_name}
**Firebase Config**: {firebase.json status}

### Validation Items

| Item              | Status | Details |
| ----------------- | ------ | ------- |
| Functions Region  | OK/FAIL | ...    |
| Firestore Filter  | OK/FAIL | ...    |
| API Key Security  | OK/FAIL | ...    |
| Security Rules    | OK/FAIL | ...    |

### Required Fixes

1. ...

### Recommendations

1. ...
```

## Allowed Tools

- Read (file reading)
- Grep (pattern search)
- Glob (file finding)

## Constraints

- **Read-only**: Cannot modify code
- Terminate early if not a Firebase project
