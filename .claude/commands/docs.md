---
description: Auto-generate docs — API, architecture, user guide, changelog.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Auto-generate documentation from specs, plans, and code to keep docs in sync with code.

## Context

> "Documentation must evolve with code. Manual docs always fall behind."
> — Documentation as Code principle

Run this command after `/implement` or before major releases.

## Document Types

| Type | Source | Output | Audience |
|------|--------|--------|----------|
| API Docs | contracts/, code | api.md | Developers |
| Architecture | plan.md | architecture.md | Developers, Architects |
| User Guide | spec.md | user-guide.md | End users |
| Changelog | Git commits | CHANGELOG.md | All stakeholders |
| README | Combined | README.md | New contributors |

---

## Execution Steps

### Phase 1: Source Analysis

```bash
# Feature directory check (requires speckit - optional)
.specify/scripts/bash/check-prerequisites.sh --json 2>/dev/null || echo "No feature context (speckit not installed)"

# Available source files
echo "=== Documentation sources ==="
[ -f "spec.md" ] && echo "✅ spec.md" || echo "❌ spec.md"
[ -f "plan.md" ] && echo "✅ plan.md" || echo "❌ plan.md"
[ -d "contracts" ] && echo "✅ contracts/" || echo "❌ contracts/"
[ -f "CHANGELOG.md" ] && echo "✅ CHANGELOG.md (existing)" || echo "❌ CHANGELOG.md"
```

### Phase 2: API Documentation

#### 2.1 Analyze contracts/ (if available)
```bash
# Analyze files in contracts directory
if [ -d "contracts" ]; then
    find contracts -name "*.ts" -o -name "*.json" | head -20
fi
```

#### 2.2 API Documentation Structure

```markdown
# API Documentation

## Overview
[Extract from plan.md Summary]

## Base URL
- Production: `https://[your-api-base-url]`
- Development: `http://localhost:[port]`

## Authentication
[Detect auth method from code]

## Endpoints

### [Endpoint Group 1]

#### `POST /api/endpoint1`

**Description**: [Extract from function comments]

**Request**:
```json
{
  "field1": "string",
  "field2": "number"
}
```

**Response**:
```json
{
  "success": true,
  "data": {}
}
```

**Errors**:
| Code | Message | Description |
|------|---------|-------------|
| 400 | Invalid input | Input validation failed |
| 401 | Unauthorized | Authentication required |
| 500 | Internal error | Server error |

---
[Additional endpoints...]
```

#### 2.3 Extract APIs from Code
```bash
# Extract endpoints from Cloud Functions (if applicable)
grep -rn "onCall\|onRequest\|https\." functions/src/*.ts 2>/dev/null | head -20 || true

# Extract from Express router (if applicable)
grep -rn "router\.\(get\|post\|put\|delete\)" src/**/*.ts 2>/dev/null | head -20 || true
```

### Phase 3: Architecture Documentation

#### 3.1 Extract from plan.md

Convert the following plan.md sections into architecture docs:
- Technical Context → Technology Stack
- Project Structure → Directory Structure
- Key Decisions → Architecture Decisions

#### 3.2 Architecture Document Structure

```markdown
# Architecture Guide

## System Overview

[Extract from plan.md Summary]

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Frontend | [from plan.md] | [from package.json] |
| Backend | [from plan.md] | [from package.json] |
| Database | [from plan.md] | - |
| Hosting | [from plan.md] | - |

## Directory Structure

```
project/
├── src/
│   ├── components/    # UI components
│   ├── services/      # Business logic
│   ├── hooks/         # Custom hooks
│   └── utils/         # Utilities
├── functions/         # Cloud Functions
└── tests/             # Tests
```

## Data Flow

```
[User] → [React UI] → [Services] → [Cloud Functions] → [Database]
                                         ↓
                                   [External APIs]
```

## Key Architectural Decisions

### ADR-001: [Decision Title]
- **Context**: [Context]
- **Decision**: [Decision]
- **Consequences**: [Consequences]

## Security Architecture

[Security-related content from spec.md or plan.md]

## Performance Considerations

[Performance-related content from plan.md]
```

### Phase 4: User Guide

#### 4.1 Extract from spec.md

Convert spec.md User Scenarios into user guide:
- User Story → Feature description
- Acceptance Scenarios → Usage instructions

#### 4.2 User Guide Structure

```markdown
# User Guide

## Getting Started

### Prerequisites
- [Requirements]

### Quick Start
1. [First step]
2. [Second step]
3. [Third step]

## Features

### Feature 1: [Feature Name]

[Description extracted from User Story 1]

**How to use:**
1. [Start from Given state]
2. [Perform When action]
3. [Verify Then result]

**Tips:**
- [Useful tips]

### Feature 2: [Feature Name]

[Extracted from User Story 2]

...

## FAQ

### Q: [Frequently asked question]
A: [Answer]

## Troubleshooting

| Issue | Solution |
|-------|----------|
| [Problem 1] | [Solution] |
| [Problem 2] | [Solution] |
```

### Phase 5: Changelog Generation

#### 5.1 Analyze Commit Log
```bash
# Parse Conventional Commits format
git log --oneline --since="1 month ago" | head -50

# Group by type
echo "=== Features ==="
git log --oneline --since="1 month ago" | grep "^[a-f0-9]* feat" | head -10

echo "=== Bug Fixes ==="
git log --oneline --since="1 month ago" | grep "^[a-f0-9]* fix" | head -10

echo "=== Other ==="
git log --oneline --since="1 month ago" | grep -v "feat\|fix" | head -10
```

#### 5.2 Changelog Structure

```markdown
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- [feat commits]

### Changed
- [refactor, update commits]

### Fixed
- [fix commits]

### Removed
- [remove commits]

## [v1.0.0] - YYYY-MM-DD

### Added
- Initial release
- [Key features]
```

### Phase 6: README Generation

#### 6.1 README Structure

```markdown
# [Project Name]

[First paragraph from spec.md or project description]

## Features

- [Key feature 1]
- [Key feature 2]
- [Key feature 3]

## Tech Stack

[Technology stack from plan.md]

## Getting Started

### Prerequisites

- Node.js >= 18
- npm or pnpm

### Installation

```bash
git clone [repo-url]
cd [project-name]
npm install
```

### Development

```bash
npm run dev
```

### Testing

```bash
npm test
```

## Documentation

- [API Documentation](./docs/api.md)
- [Architecture Guide](./docs/architecture.md)
- [User Guide](./docs/user-guide.md)

## Contributing

[Contribution guide]

## License

[License information]
```

---

## Output Options

### Option 1: Individual Files (default)
```
docs/
├── api.md
├── architecture.md
├── user-guide.md
└── CHANGELOG.md
```

### Option 2: Single File
```bash
/docs --single-file
# → docs/documentation.md (all content combined)
```

### Option 3: Specific Type Only
```bash
/docs --api-only
/docs --changelog-only
/docs --readme-only
```

---

## Quick Reference

```bash
# Generate all docs
/docs

# API docs only
/docs --api

# Architecture docs only
/docs --architecture

# User guide only
/docs --user-guide

# Changelog only
/docs --changelog

# Update README
/docs --readme

# Verify docs (compare existing docs with source)
/docs --verify
```

## Integration

### CI/CD Usage
```yaml
# GitHub Actions
- name: Generate Documentation
  run: npx claude-code /docs --changelog

- name: Commit Docs
  run: |
    git add docs/
    git commit -m "docs: auto-generate documentation" || echo "No changes"
```

### Pre-release Hook
```bash
# Auto-update docs before release
/docs && git add docs/ && git commit -m "docs: update for release"
```
