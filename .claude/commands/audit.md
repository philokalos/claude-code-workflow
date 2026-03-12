---
description: Security and compliance audit — vulnerabilities, secrets, security patterns.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Identify security vulnerabilities and compliance issues before production deployment to prevent security incidents.

## Context

> "Security issues found in production are 100x more expensive to fix than in development."

This command can run in parallel with `/implement` and should be run before deployment.

## Audit Categories

### 1. Dependency Vulnerabilities
### 2. Secret Detection
### 3. Code Security Patterns
### 4. Compliance Checklist
### 5. Framework-Specific Security (if applicable)

## Execution Steps

### Phase 1: Dependency Audit

```bash
# Vulnerability scan
npm audit --json 2>/dev/null || echo '{"vulnerabilities":{}}'

# Severity classification
npm audit --json | jq '.metadata.vulnerabilities | {critical, high, moderate, low}'

# Outdated packages
npm outdated --json 2>/dev/null || echo '{}'
```

**Severity criteria:**

| Severity | Action |
|----------|--------|
| Critical | Immediate fix required, block deployment |
| High | Fix within 48 hours recommended |
| Moderate | Fix in next release |
| Low | Add to backlog |

### Phase 2: Secret Detection

```bash
# API key patterns
grep -rn "(?:api[_-]?key|apikey)\s*[:=]\s*['\"][^'\"]+['\"]" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.git \
  -E 2>/dev/null || true

# Password patterns
grep -rn "(?:password|passwd|pwd|secret)\s*[:=]\s*['\"][^'\"]+['\"]" \
  --include="*.ts" --include="*.tsx" --include="*.js" \
  --exclude-dir=node_modules --exclude-dir=.git \
  -E 2>/dev/null || true

# AWS key patterns
grep -rn "AKIA[0-9A-Z]{16}" \
  --include="*.ts" --include="*.tsx" --include="*.env*" \
  --exclude-dir=node_modules \
  2>/dev/null || true

# Private key patterns
grep -rn "-----BEGIN.*PRIVATE KEY-----" \
  --exclude-dir=node_modules \
  2>/dev/null || true
```

**Allow list (false positive exclusions):**
- `process.env.*` usage
- `.env.example` files
- Examples in comments
- Public configuration keys (e.g., Firebase public apiKey)

### Phase 3: Code Security Patterns

#### XSS Vulnerabilities
```bash
grep -rn "innerHTML\s*=" --include="*.tsx" --include="*.ts" --exclude-dir=node_modules 2>/dev/null || true
grep -rn "dangerouslySetInnerHTML" --include="*.tsx" --exclude-dir=node_modules 2>/dev/null || true
grep -rn "eval\s*(" --include="*.ts" --include="*.tsx" --exclude-dir=node_modules 2>/dev/null || true
grep -rn "document\.write" --include="*.ts" --include="*.tsx" --exclude-dir=node_modules 2>/dev/null || true
```

#### SQL/NoSQL Injection
```bash
grep -rn "where\s*(\s*['\`]" --include="*.ts" --exclude-dir=node_modules 2>/dev/null || true
grep -rn "\+\s*['\"].*where" --include="*.ts" --exclude-dir=node_modules 2>/dev/null || true
```

#### Auth/AuthZ Patterns
```bash
# Check for missing user-scoped data filters in database queries
grep -rn "getDocs\|getDoc\|setDoc\|updateDoc\|deleteDoc" --include="*.ts" \
  --exclude-dir=node_modules -l 2>/dev/null | \
  xargs -I {} sh -c 'grep -L "where.*userId" {}'
```

### Phase 4: Compliance Checklist

#### Privacy (GDPR/CCPA)

| Item | How to Check | Status |
|------|-------------|--------|
| Data collection consent | Check signup flow | OK/FAIL |
| Data deletion capability | Check account deletion API | OK/FAIL |
| Data export | Check data portability feature | OK/FAIL |
| Encryption | Check sensitive data storage | OK/FAIL |

#### Accessibility (WCAG)
```bash
grep -rn "aria-" --include="*.tsx" --exclude-dir=node_modules | wc -l
grep -rn "<img" --include="*.tsx" --exclude-dir=node_modules | grep -v "alt=" | head -5
```

### Phase 5: Framework-Specific Security (if applicable)

#### Firebase (if firebase.json exists)
```bash
if [ -f "firestore.rules" ]; then
  cat firestore.rules
fi

# Region check
grep -rn "region\s*(" --include="*.ts" functions/ 2>/dev/null || true
grep -rn "getFunctions\|connectFunctionsEmulator" --include="*.ts" src/ 2>/dev/null || true

# CORS check
grep -rn "cors" --include="*.ts" functions/ 2>/dev/null || true
```

### Phase 6: Report Generation

```markdown
# Security Audit Report

**Date**: [YYYY-MM-DD]
**Project**: [Project Name]
**Auditor**: Claude Code

## Executive Summary

| Category | Issues Found | Severity |
|----------|-------------|----------|
| Dependencies | X critical, Y high | HIGH/MED/LOW |
| Secrets | X exposed | HIGH/MED/LOW |
| Code Patterns | X vulnerabilities | HIGH/MED/LOW |
| Compliance | X gaps | HIGH/MED/LOW |

## Overall Risk Level: [HIGH/MEDIUM/LOW]

---

[Detailed findings per category...]

---

## Remediation Priority

### P0 - Critical (Block Deployment)
1. [Critical items]

### P1 - High (Fix Within 48h)
1. [High priority items]

### P2 - Medium (Next Release)
1. [Medium priority items]

## Verdict

APPROVED FOR DEPLOYMENT - No critical issues
OR
CONDITIONAL APPROVAL - Address P1 items before production
OR
DEPLOYMENT BLOCKED - Critical issues must be resolved
```

## Pass/Fail Criteria

### Deployment Approved
- 0 Critical vulnerabilities
- 0 Exposed secrets
- 0 XSS vulnerabilities in production code

### Deployment Blocked
- Any Critical vulnerability
- Any exposed secret (API key, password, private key)
- Missing auth checks in security rules
- XSS vulnerability in user input handling

## Quick Reference

```bash
/audit                    # Full audit
/audit --dependencies     # Dependencies only
/audit --secrets          # Secret scan only
/audit --security         # Code patterns only
/audit --compliance       # Compliance only
/audit --fix              # Auto-fix what's possible
```
