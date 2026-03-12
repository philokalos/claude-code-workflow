# Prompt Pattern Library

A collection of reusable high-quality prompt patterns.

## 📚 Patterns by Category

### 1. Code Generation

#### Pattern: Feature Implementation

```
Goal: Implement [feature] using [tech stack]
Output: Write in [language], generate the following files:
  - [file1]: [purpose]
  - [file2]: [purpose]
  - [file3]: [purpose]
  [Comment/format requirements]
Limits:
  - Use only [allowed libraries]
  - [Prohibited libraries] not allowed
  - Max [N] lines
Data:
  - Current project: [framework + version]
  - Existing files: [related files]
  - [Other context]
Evaluation:
  - Success criteria: [criteria]
  - Error handling: [error types]
  - Test coverage: ≥[N]%
Next:
  1. [Follow-up task 1]
  2. [Follow-up task 2]
```

**Real Example**:
```
Goal: Implement login page using Firebase Auth + React Hook Form
Output: Write in TypeScript, generate the following files:
  - pages/Login.tsx: Login UI (email/password input)
  - hooks/useAuth.ts: Firebase Auth logic
  - types/auth.ts: Authentication type definitions
  Include JSDoc comments, Prettier format
Limits:
  - Use only Tailwind CSS (no external UI libraries)
  - Use only Firebase Auth SDK
  - Max 200 lines
Data:
  - Current project: React 19 + Vite + Firebase + TypeScript
  - Existing AuthContext: context/AuthContext.tsx
  - Firebase config: src/config/firebase.ts
  - Region: your-configured-region
Evaluation:
  - On success: Redirect to /dashboard
  - Error handling: Invalid email/password, network errors, Firebase Auth errors
  - Test coverage: ≥70%
Next:
  1. Write login page tests
  2. Implement signup page
  3. Add password reset feature
```

---

### 2. Bug Fix

#### Pattern: Bug Fix

```
Goal: Fix [symptom] bug in [file/component]
Output: Modify [fix file], explain changes in [description format]
Limits:
  - No existing API changes
  - No [unrelated changes]
  - Minimal changes only
Data:
  - Bug reproduction: [reproduction steps]
  - Expected behavior: [normal behavior]
  - Actual behavior: [buggy behavior]
  - Error message: [error]
  - Related code: [file:line]
Evaluation:
  - Bug resolution verified: [test method]
  - Regression test: [existing functionality works]
  - Unit test added
Next:
  1. Write tests
  2. Search for similar bugs
```

**Real Example**:
```
Goal: Fix bug in hooks/useAuth.ts where error message doesn't display on login failure
Output: Modify hooks/useAuth.ts, explain changes with JSDoc comments
Limits:
  - No changes to existing useAuth hook API
  - No changes to other files
  - Minimal changes only (error handling logic only)
Data:
  - Bug reproduction:
    1. Enter invalid email on login page
    2. Click login button
    3. No error message displayed
  - Expected behavior: Display "Invalid email or password" message
  - Actual behavior: No message displayed
  - Error message: Firebase Auth error (auth/invalid-credential)
  - Related code: hooks/useAuth.ts:45-60 (signIn function)
Evaluation:
  - Bug resolved: Verify error message displays when attempting login with invalid email
  - Regression test: Normal login still works
  - Unit test: Add error case to useAuth.test.ts
Next:
  1. Write error message tests
  2. Verify other Firebase Auth errors are also handled
```

---

### 3. Refactoring

#### Pattern: Code Refactoring

```
Goal: Refactor [file/component] for [refactoring objective]
Output: [Modified files], change summary
Limits:
  - No functionality changes (behavior must remain identical)
  - No [unrelated changes]
  - All existing tests must pass
Data:
  - Current problem: [code smell/issues]
  - Current structure: [existing structure description]
  - Target structure: [improved structure]
Evaluation:
  - Existing functionality works correctly
  - All existing tests pass
  - Code quality improvement verified
Next:
  1. Complete refactoring
  2. [Follow-up refactoring]
```

**Real Example**:
```
Goal: Refactor components/TaskList.tsx by extracting logic into a custom hook for better reusability
Output: Modify the following files:
  - components/TaskList.tsx: Keep UI logic only
  - hooks/useTasks.ts: Create new file (Firestore logic)
  Record changes in CHANGELOG.md
Limits:
  - No changes to TaskList component functionality (render output must be identical)
  - No changes to props interface
  - All existing tests (TaskList.test.tsx) must pass
Data:
  - Current problem: TaskList.tsx has mixed UI + Firestore logic (300 lines)
  - Current structure: All logic in a single component
  - Target structure: UI (TaskList.tsx 100 lines) + Logic (useTasks.ts 50 lines)
Evaluation:
  - TaskList component render output is identical
  - All existing tests pass
  - useTasks hook is reusable (verified by using in another component)
Next:
  1. Use useTasks hook in other components
  2. Refactor TaskForm.tsx
```

---

### 4. Testing

#### Pattern: Test Writing

```
Goal: Write [test type] for [file/component]
Output: Generate [test file], using [test framework]
Limits:
  - Coverage: ≥[N]%
  - Test [scope]
  - Exclude [exclusion scope]
Data:
  - Test target: [file]
  - Key functions: [function list]
  - Edge cases: [edge cases]
Evaluation:
  - All tests pass
  - Coverage target met
  - Edge cases covered
Next:
  1. Complete tests
  2. Add E2E tests
```

**Real Example**:
```
Goal: Write unit tests for hooks/useTasks.ts
Output: Generate hooks/useTasks.test.ts, using Vitest + React Testing Library
Limits:
  - Coverage: ≥80%
  - Test all hook methods (getTasks, addTask, updateTask, deleteTask)
  - Test with mocks, no Firebase Emulator
Data:
  - Test target: hooks/useTasks.ts
  - Key functions:
    - getTasks: Fetch tasks from Firestore
    - addTask: Add new task
    - updateTask: Update task
    - deleteTask: Delete task
  - Edge cases:
    - Firestore error handling
    - Missing userId
    - Duplicate task addition attempt
Evaluation:
  - All tests pass (npm test)
  - Coverage 80%+ (npm test -- --coverage)
  - All edge cases tested
Next:
  1. Complete useTasks tests
  2. Write TaskList component tests
  3. Add E2E tests
```

---

### 5. Documentation

#### Pattern: Documentation Writing

```
Goal: Write [document type] for [file/module]
Output: Generate/modify [document file], Markdown format
Limits:
  - Max [document length]
  - Must include: [required items]
  - Exclude: [excluded items]
Data:
  - Target: [file/module]
  - Audience: [target readers]
  - Existing docs: [related documents]
Evaluation:
  - [Documentation requirements] met
  - Example code is executable
  - Links work correctly
Next:
  1. Write documentation
  2. Request review
```

**Real Example**:
```
Goal: Write API documentation for hooks/useTasks.ts
Output: Generate docs/hooks/useTasks.md, Markdown + JSDoc comments
Limits:
  - Max document length: 500 lines
  - Must include: API reference, usage examples, error handling
  - Exclude: Internal implementation details
Data:
  - Target: hooks/useTasks.ts
  - Audience: Frontend developers
  - Existing docs: docs/README.md, docs/hooks/useAuth.md
Evaluation:
  - API reference completeness
  - All example code is executable
  - Links work correctly
Next:
  1. Complete useTasks documentation
  2. Write documentation for other hooks
  3. Build API documentation site
```

---

## 🎯 Practical Application Guide

### Pattern Selection Criteria

1. **Identify task type**: Code Generation / Bug Fix / Refactoring / Testing / Documentation
2. **Assess complexity**: Simple (Conservative) / Medium (Balanced) / Complex (Comprehensive)
3. **Gather context**: Project info, existing code, tech stack
4. **Apply pattern**: Use the appropriate category pattern
5. **GOLDEN verification**: Check scores across all 6 dimensions
6. **Iterate**: Improve until reaching 70%+

### Pattern Customization

**Base Pattern**:
```
Goal: [goal]
Output: [output]
Limits: [constraints]
Data: [data]
Evaluation: [evaluation]
Next: [next]
```

**Per-project customization**:
```
# Example: Task management app
Goal: [goal]
Output: TypeScript + React 19 + Vite
Limits: Cloud Functions only (API key security), configured region
Data: Current project context, design system info
Evaluation: Test coverage ≥70%
Next: [next steps]

# Example: Finance app
Goal: [goal]
Output: TypeScript + React 18 + Vite
Limits: Preserve amount sign (no Math.abs), N collections
Data: Current project, domain-specific constraints
Evaluation: Transaction hash deduplication
Next: [next steps]
```

---

## 📚 References

- [GOLDEN Checklist Details](golden-checklist.md)
- [Category-Specific Templates](templates.md)
- [PromptLint Skill](SKILL.md)
