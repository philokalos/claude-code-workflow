---
description: Pre/post-deploy validation with smoke test and health check.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Verify system stability before and after production deployment to minimize deployment failures and rollback situations.

## Workflow Position

```
/implement → /review → /verify → /audit
                                    ↓
                    /deploy (pre) → deploy → /deploy (post)
```

## Execution Modes

```bash
/deploy --pre    # Pre-deploy validation
/deploy --post   # Post-deploy validation
/deploy          # Full (pre + post)
```

---

## Pre-Deploy Validation

### Phase 1: Environment Check

#### 1.1 Git Status

```bash
git branch --show-current
git status --short
git log origin/main..HEAD --oneline 2>/dev/null || \
git log origin/master..HEAD --oneline 2>/dev/null || \
echo "No remote tracking"
```

**Pass criteria:**
- Current branch is main/master or release branch
- No uncommitted changes
- Synced with remote

#### 1.2 Environment Variables

```bash
ls -la .env.production 2>/dev/null || echo "No .env.production"

if [ -f ".env.production" ]; then
    echo "Checking required env vars..."
    # Add your project-specific env var checks here
fi
```

### Phase 2: Build Verification

```bash
# Auto-detect and build
if [ -f "vite.config.ts" ] || [ -f "vite.config.js" ]; then
    npm run build
elif [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next.config.ts" ]; then
    npm run build
elif [ -f "package.json" ]; then
    npm run build 2>/dev/null || echo "No build script"
fi

# Verify build output
for dir in dist build .next out; do
    if [ -d "$dir" ]; then
        echo "Build output: $dir/"
        du -sh "$dir"
        break
    fi
done
```

### Phase 3: Smoke Tests

```bash
# Preview server test (Vite projects)
if [ -f "vite.config.ts" ]; then
    timeout 30 npm run preview &
    sleep 5
    curl -s http://localhost:4173 > /dev/null && echo "Preview server responding" || echo "Preview server failed"
    pkill -f "vite preview" 2>/dev/null || true
fi
```

### Phase 4: Configuration Validation

Auto-detect deployment target and validate configuration:

```bash
# Firebase
if [ -f "firebase.json" ]; then
    echo "Firebase project detected"
    jq '.hosting.public' firebase.json 2>/dev/null || echo "No hosting config"
    firebase use 2>/dev/null || echo "No project selected"
fi

# Vercel
if [ -f "vercel.json" ]; then
    echo "Vercel project detected"
fi

# Netlify
if [ -f "netlify.toml" ]; then
    echo "Netlify project detected"
fi
```

### Phase 5: Rollback Preparation

```bash
CURRENT_VERSION=$(git describe --tags --always 2>/dev/null || git rev-parse --short HEAD)
echo "Current version: $CURRENT_VERSION"
git tag --sort=-creatordate | head -3

echo ""
echo "=== Rollback commands (if needed) ==="
echo "Git: git revert HEAD"
# Add platform-specific rollback commands based on detected deployment target
```

---

## Post-Deploy Validation

### Phase 1: Health Check

```bash
# Set your production URL (auto-detect or manual)
PROD_URL="${DEPLOY_URL:-}"

if [ -n "$PROD_URL" ]; then
    echo "Checking: $PROD_URL"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL" 2>/dev/null || echo "000")

    if [ "$HTTP_STATUS" = "200" ]; then
        echo "Production site responding (HTTP $HTTP_STATUS)"
    else
        echo "Production site error (HTTP $HTTP_STATUS)"
    fi

    # Health endpoint
    curl -s "${PROD_URL}/api/health" 2>/dev/null | head -c 200 || echo "No health endpoint"
fi
```

### Phase 2: Error Log Check

```bash
# Check deployment platform logs for errors
# Firebase example:
if command -v firebase &> /dev/null && [ -f "firebase.json" ]; then
    firebase functions:log --limit 10 2>/dev/null || echo "No functions deployed"
fi
```

### Phase 3: Verification Report

```markdown
# Deployment Validation Report

**Date**: [YYYY-MM-DD HH:MM]
**Project**: [Project Name]
**Environment**: Production
**Version**: [Git Tag/Commit]

## Pre-Deploy Summary

| Check          | Status | Notes                   |
| -------------- | ------ | ----------------------- |
| Git Status     | OK/FAIL | Clean working directory |
| Build          | OK/FAIL | Build successful        |
| Smoke Tests    | OK/FAIL | All passed              |
| Config         | OK/FAIL | Valid configuration     |
| Rollback Ready | OK/FAIL | Commands prepared       |

## Post-Deploy Summary

| Check           | Status | Notes        |
| --------------- | ------ | ------------ |
| Site Accessible | OK/FAIL | HTTP 200    |
| Error Logs      | OK/FAIL | Log clean   |
| Monitoring      | OK/FAIL | Active      |

## Verdict

DEPLOYMENT SUCCESSFUL - All checks passed
OR
DEPLOYMENT WITH WARNINGS - Review warnings
OR
DEPLOYMENT ISSUES - Immediate action required
```

## Quick Reference

```bash
/deploy --pre              # Pre-deploy validation
/deploy --post             # Post-deploy validation
/deploy                    # Full validation
/deploy --rollback-prep    # Rollback preparation only
```
