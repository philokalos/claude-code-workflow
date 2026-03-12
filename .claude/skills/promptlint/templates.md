# Category-Specific Prompt Templates

A collection of ready-to-use prompt templates. Fill in the blanks and go.

## 📝 How to Use

1. Select the task category
2. Copy the appropriate template
3. Fill in the `[blank]` sections
4. Check GOLDEN score (target 70%+)

---

## 1. Code Generation

### Template 1-A: Component Creation

```
Goal: Implement [component name] component using [framework + version]
Output: Write in [language], generate the following files:
  - [file1]: [description]
  - [file2]: [description]
  [Comment/documentation requirements]
Limits:
  - Use only [allowed libraries]
  - [Prohibited items] not allowed
  - Max [N] lines
Data:
  - Current project: [tech stack]
  - Existing components: [related components]
  - Design system: [design guide]
Evaluation:
  - [Success criteria]
  - Error handling: [error types]
  - Test coverage: ≥[N]%
  - Accessibility: WCAG [level] compliance
Next:
  1. [Follow-up task 1]
  2. [Follow-up task 2]
```

**Example**:
```
Goal: Implement TaskCard component using React 19 + TypeScript
Output: Write in TypeScript, generate the following files:
  - components/TaskCard.tsx: Card UI
  - components/TaskCard.test.tsx: Tests
  - types/task.ts: Type definitions
  Include JSDoc comments, Prettier format
Limits:
  - Use only Tailwind CSS (no external UI libraries)
  - Minimize props drilling (use Context)
  - Max 150 lines
Data:
  - Current project: React 19 + Vite + TypeScript
  - Existing components: Used in TaskList.tsx
  - Design system: Swiss Design (minimal, typography-focused)
Evaluation:
  - Open detail modal on click
  - Error handling: Show placeholder when data is missing
  - Test coverage: ≥80%
  - Accessibility: WCAG 2.1 AA compliance (keyboard navigation, aria-label)
Next:
  1. Complete TaskCard
  2. Implement TaskDetail modal
  3. Integrate into TaskList
```

---

### Template 1-B: API Endpoint Creation

```
Goal: Implement [endpoint] API using [framework]
Output: Write in [language], generate the following files:
  - [file1]: [description]
  - [file2]: [description]
  [Documentation requirements]
Limits:
  - Use only [allowed libraries]
  - [Security requirements]
  - Response time: <[N]ms
Data:
  - Current API: [existing API]
  - Database: [DB info]
  - Authentication: [auth method]
Evaluation:
  - Success: [response format]
  - Error: [error codes + messages]
  - Tests: [test cases]
Next:
  1. [Follow-up task]
```

**Example**:
```
Goal: Implement /api/classifyTask POST endpoint using Firebase Cloud Functions
Output: Write in TypeScript, generate the following files:
  - functions/src/api/classifyTask.ts: callable function
  - functions/src/services/geminiService.ts: Gemini API calls
  - functions/src/types/classification.ts: Type definitions
  Write OpenAPI 3.0 spec
Limits:
  - Use only Gemini API (no other AI providers)
  - Manage API keys via environment variables (.env)
  - Response time: <3 seconds
Data:
  - Current API: configured region
  - Database: Firestore (tasks collection)
  - Authentication: Firebase Auth (userId-based)
Evaluation:
  - Success: { quadrant: 'Q1' | 'Q2' | 'Q3' | 'Q4', confidence: number }
  - Error: 400 (invalid input), 401 (auth failure), 500 (API error)
  - Tests: Each quadrant case + error cases
Next:
  1. Complete classifyTask function
  2. Frontend integration
  3. Set up monitoring
```

---

## 2. Bug Fix

### Template 2-A: Bug Fix

```
Goal: Fix [symptom] bug in [file:line]
Output: Modify [fix file], explain changes
Limits:
  - No existing API changes
  - No [unrelated changes]
  - Minimal changes only
Data:
  - Bug reproduction:
    1. [step 1]
    2. [step 2]
    3. [result]
  - Expected behavior: [normal behavior]
  - Actual behavior: [buggy behavior]
  - Error message: [error]
  - Browser/environment: [environment]
Evaluation:
  - Bug resolution verified: [test method]
  - Regression test: [existing functionality]
  - Unit test added
Next:
  1. Write tests
  2. Search for similar bugs
```

**Example**:
```
Goal: Fix bug in components/TaskList.tsx:45 where tasks can be added while loading
Output: Modify components/TaskList.tsx, explain changes with JSDoc comments
Limits:
  - No changes to TaskList props interface
  - No changes to other components
  - Minimal changes only (button disabled logic)
Data:
  - Bug reproduction:
    1. Open TaskList page
    2. While data is loading from Firestore (isLoading: true)
    3. "Add Task" button is clickable
    4. Duplicate tasks are created
  - Expected behavior: Button is disabled during loading
  - Actual behavior: Button is active, duplicates created
  - Error message: None
  - Browser/environment: Chrome 120, macOS
Evaluation:
  - Bug resolved: Verify button is disabled during loading
  - Regression test: Button works normally after loading completes
  - Unit test: Add isLoading case to TaskList.test.tsx
Next:
  1. Write button disabled tests
  2. Search for same bug in other forms
```

---

## 3. Refactoring

### Template 3-A: Component Separation

```
Goal: Refactor [file] by [separation direction]
Output: [Modified files], change summary
Limits:
  - No functionality changes (behavior identical)
  - No [unrelated changes]
  - All existing tests must pass
Data:
  - Current problem: [code smell]
  - Current structure: [existing structure]
  - Target structure: [improved structure]
Evaluation:
  - Functionality works correctly
  - All existing tests pass
  - Code quality improved
Next:
  1. Complete refactoring
  2. [Follow-up refactoring]
```

**Example**:
```
Goal: Split pages/Dashboard.tsx into component units
Output: Modify the following files:
  - pages/Dashboard.tsx: Keep layout only (100 lines)
  - components/DashboardStats.tsx: Statistics section (80 lines)
  - components/RecentTasks.tsx: Recent tasks (120 lines)
  - components/QuickActions.tsx: Quick action buttons (60 lines)
  Record changes in CHANGELOG.md
Limits:
  - Dashboard page render output must be identical
  - No changes to props interface
  - All existing tests (Dashboard.test.tsx) must pass
Data:
  - Current problem: Dashboard.tsx is 500 lines, all logic mixed together
  - Current structure: All UI + logic in a single file
  - Target structure: Split into 4 components (60-120 lines each)
Evaluation:
  - Dashboard render output is identical
  - All existing tests pass
  - Each component is reusable
Next:
  1. Complete component separation
  2. Write tests for each component
  3. Add Storybook stories
```

---

## 4. Testing

### Template 4-A: Unit Tests

```
Goal: Write unit tests for [file]
Output: Generate [test file], using [test framework]
Limits:
  - Coverage: ≥[N]%
  - [Test scope]
  - [Exclusion scope]
Data:
  - Test target: [file]
  - Key functions: [functions]
  - Edge cases: [cases]
Evaluation:
  - All tests pass
  - Coverage target met
  - Edge cases covered
Next:
  1. Complete tests
  2. [Follow-up tests]
```

**Example**:
```
Goal: Write unit tests for services/aiProcessor.ts
Output: Generate services/aiProcessor.test.ts, using Vitest + MSW
Limits:
  - Coverage: ≥85%
  - Test all public methods
  - Mock Gemini API (no real API calls)
Data:
  - Test target: services/aiProcessor.ts
  - Key functions:
    - classifyTask: Classify tasks into 4 quadrants
    - validateClassification: Validate classification results
    - handleAPIError: Handle API errors
  - Edge cases:
    - API timeout
    - Invalid response format
    - Network error
Evaluation:
  - All tests pass (npm test)
  - Coverage 85%+
  - All edge cases tested
Next:
  1. Complete aiProcessor tests
  2. Write integration tests
  3. Add E2E tests
```

---

### Template 4-B: E2E Tests

```
Goal: Write E2E tests for [user flow]
Output: Generate [test file], using Playwright
Limits:
  - [Test scenarios]
  - Test in [environment] environment
Data:
  - User flow:
    1. [step 1]
    2. [step 2]
    3. [result]
  - Test data: [data]
Evaluation:
  - All flows pass
  - [Verification items]
Next:
  1. Complete E2E tests
  2. CI/CD integration
```

**Example**:
```
Goal: Write E2E tests for login → add task → AI classification flow
Output: Generate e2e/task-classification.spec.ts, using Playwright + Firebase Emulator
Limits:
  - Test the full flow (from login to AI classification)
  - Test only in local emulator environment
Data:
  - User flow:
    1. Navigate to /login page
    2. Log in with test account
    3. Verify redirect to /dashboard
    4. Click "Add Task" button
    5. Enter task title
    6. Click "Classify with AI" button
    7. AI classification result displayed (Q1-Q4)
  - Test data: email: test@example.com, password: test1234
Evaluation:
  - All flows pass
  - AI classification result accuracy verified
  - Page transitions work correctly
Next:
  1. Complete E2E tests
  2. Integrate into GitHub Actions CI/CD
  3. Add E2E tests for other flows
```

---

## 5. Documentation

### Template 5-A: API Documentation

```
Goal: Write API documentation for [file/module]
Output: Generate [document file], Markdown format
Limits:
  - Max document length: [N] lines
  - Must include: [items]
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
  2. [Follow-up documentation]
```

**Example**:
```
Goal: Write API documentation for hooks/useTasks.ts
Output: Generate docs/hooks/useTasks.md, Markdown + Mermaid diagrams
Limits:
  - Max document length: 500 lines
  - Must include: API reference, usage examples, error handling, type definitions
  - Exclude: Internal implementation details
Data:
  - Target: hooks/useTasks.ts
  - Audience: Frontend developers
  - Existing docs: docs/README.md, docs/hooks/useAuth.md
Evaluation:
  - API reference completeness (all methods documented)
  - All example code is executable
  - Links work correctly
Next:
  1. Complete useTasks documentation
  2. Write useProjects documentation
  3. Build API documentation site
```

---

## 6. Architecture

### Template 6-A: System Design

```
Goal: Design [system/module] architecture
Output: [Design document], include Mermaid diagrams
Limits:
  - Use [tech stack]
  - [Constraints]
Data:
  - Requirements: [functional requirements]
  - Constraints: [non-functional requirements]
  - Current system: [existing structure]
Evaluation:
  - [Design criteria] met
  - Scalability: [scaling plan]
  - Performance: [performance targets]
Next:
  1. Complete design
  2. Begin implementation
```

**Example**:
```
Goal: AI classification system architecture design
Output: docs/architecture/ai-classification.md, Mermaid flow diagram + sequence diagram
Limits:
  - Use Firebase (Functions, Firestore) + Gemini API
  - Configured deployment region required
  - API key security (route through Cloud Functions)
Data:
  - Requirements:
    - Auto-classify tasks into 4 quadrants (Q1-Q4)
    - Classification accuracy ≥85%
    - Processing time <3 seconds
  - Constraints:
    - Cost: Minimize Gemini API calls
    - Security: No API key exposure
    - Performance: Minimize user wait time
  - Current system: React 19 + Vite + Firebase
Evaluation:
  - All requirements met
  - Scalability: Handle 100K requests/month
  - Performance: Average processing time <2 seconds
Next:
  1. Complete architecture design
  2. Implement Cloud Functions
  3. Frontend integration
```

---

## 7. Deployment

### Template 7-A: Deployment Automation

```
Goal: Automate [deployment process]
Output: [Deployment scripts/config], [CI/CD config]
Limits:
  - [Deployment environment]
  - [Security requirements]
Data:
  - Current deployment: [manual/automated]
  - Deployment target: [environment]
  - Deployment steps: [steps]
Evaluation:
  - Deployment success rate: ≥[N]%
  - Deployment time: <[N] minutes
  - Rollback possible
Next:
  1. Automate deployment
  2. Set up monitoring
```

**Example**:
```
Goal: Automate Firebase Hosting + Functions deployment
Output: .github/workflows/deploy.yml, GitHub Actions CI/CD configuration
Limits:
  - Production environment (configured region)
  - Secret management: Use GitHub Secrets
Data:
  - Current deployment: Manual (firebase deploy)
  - Deployment target: Hosting + Functions
  - Deployment steps:
    1. npm run build
    2. npm test
    3. firebase deploy --only hosting
    4. firebase deploy --only functions
Evaluation:
  - Deployment success rate: ≥95%
  - Deployment time: <10 minutes
  - Rollback: Possible via firebase hosting:channel:deploy
Next:
  1. Set up GitHub Actions
  2. Add Slack notifications
  3. Build monitoring dashboard
```

---

## 🎯 Template Usage Tips

1. **Fill in the blanks**: Write the `[blank]` sections to match your project
2. **GOLDEN verification**: Check the score after writing (target 70%+)
3. **Add context**: Provide sufficient project information in the Data section
4. **Evaluation criteria**: Specify concrete criteria in the Evaluation section
5. **Follow-up tasks**: Write clear steps in the Next section

## 📚 Additional Resources

- [GOLDEN Checklist](golden-checklist.md)
- [Prompt Patterns](patterns.md)
- [PromptLint Skill](SKILL.md)
