---
name: promptlint
description: Evaluate prompt quality with GOLDEN checklist and suggest 3-tier improvements.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, Task
---

# PromptLint - Prompt Quality Evaluation and Improvement

A skill that evaluates and improves prompts in real-time, like Grammarly for prompts.

## Core Features

### 1. GOLDEN Checklist Evaluation

Evaluates all prompts across 6 dimensions:

| Dimension | Description | Good Example |
|-----------|-------------|-------------|
| **G (Goal)** | Goal clarity | "Implement user authentication system" (clear) vs "Write code" (unclear) |
| **O (Output)** | Output format specification | "Write in TypeScript, include JSDoc comments" vs unspecified |
| **L (Limits)** | Constraints/boundaries | "No external libraries, max 100 lines" vs no constraints |
| **D (Data)** | Context/data | "Current project uses React 19 + Vite" vs no context |
| **E (Evaluation)** | Success criteria | "Test coverage >=70%, build succeeds" vs no criteria |
| **N (Next)** | Follow-up steps | "Write tests then request review" vs no next steps |

**Score Calculation:**
- Each dimension: 0-1 points
- Length bonus: up to +0.15 points for 50+ words
- Total: average score x 100 (0-100%)

### 2. 3-Tier Improvement Strategy

Automatically improves prompts into 3 versions:

#### 🟢 Conservative (~60% improvement)
- **Strategy**: Minimal changes, supplement only the weakest dimension
- **Use case**: When quick improvement is needed
- **Example**:
  ```
  Original: "Build a login feature"

  Conservative:
  Goal: Implement login feature using Firebase Auth
  Output: TypeScript + React Hook Form
  ```

#### 🟡 Balanced (~70-75% improvement)
- **Strategy**: Structure all GOLDEN 6 dimensions, apply category-specific templates
- **Use case**: Standard prompt writing
- **Example**:
  ```
  Original: "Build a login feature"

  Balanced:
  Goal: Implement login page using Firebase Auth + React Hook Form
  Output: Write in TypeScript, include Zod validation
  Limits: No external UI libraries, use only Tailwind CSS
  Data: Current project uses React 19 + Vite + Firebase
  Evaluation: Redirect to /dashboard on successful login
  Next: Implement signup page after login
  ```

#### 🔵 Comprehensive (~90-95% improvement)
- **Strategy**: Full structuring + tech stack inference + project context
- **Use case**: Complex tasks, high accuracy required
- **Example**:
  ```
  Original: "Build a login feature"

  Comprehensive:
  Goal: Implement complete login system using Firebase Auth + React Hook Form + Zod
  Output: Write in TypeScript, generate the following files:
    - pages/Login.tsx (login UI)
    - hooks/useAuth.ts (Firebase Auth hook)
    - types/auth.ts (type definitions)
    - schemas/login.ts (Zod validation schema)
  Limits:
    - Use only Tailwind CSS, no external UI libraries
    - Max 200 lines
    - Use only Firebase Auth SDK (no other auth libraries)
  Data:
    - Current project: React 19 + Vite + Firebase + TypeScript
    - Existing AuthContext: context/AuthContext.tsx
    - Firebase config: src/config/firebase.ts
  Evaluation:
    - Redirect to /dashboard on successful login
    - Error handling: invalid email/password, network errors
    - Test coverage >=70%
  Next:
    1. Complete login page implementation
    2. Implement signup page
    3. Add password reset feature
    4. Write E2E tests
  ```

### 3. Prompt Classification System

Automatically classifies prompts to apply tailored templates:

**Intent**:
- `command`: Imperative ("build", "create")
- `question`: Interrogative ("how to?", "why?")
- `instruction`: Directive ("modify as follows", "change this to")
- `feedback`: Feedback ("good", "no", "redo")
- `context`: Context provision ("the current situation is...", "the project is...")
- `clarification`: Clarification ("specifically...", "to be precise...")

**TaskCategory**:
- `code-generation`: Writing new code
- `code-review`: Code review
- `bug-fix`: Bug fixing
- `refactoring`: Refactoring
- `explanation`: Explanation request
- `documentation`: Documentation writing
- `testing`: Test writing
- `architecture`: Architecture design
- `deployment`: Deployment related
- `data-analysis`: Data analysis

### 4. Automatic Session Context Recognition

Automatically detects the current work environment and reflects it in prompts:

```typescript
// Automatically detected information
{
  project: "your-project",                    // Current project
  techStack: ["React 19", "Vite", "Firebase", "TypeScript"],
  recentFiles: ["src/App.tsx", "src/hooks/useTasks.ts"],
  currentTask: "Implementing AI task classification",
  gitBranch: "feature/ai-classification"
}
```

## Usage

### 🚀 Immediate Execution Workflow (Recommended)

Evaluates then immediately executes the task with the improved prompt:

```
User: Build a login feature

Claude: (PromptLint skill auto-activated)

📊 Prompt Quality Evaluation:
- Goal: 20% (goal too vague)
- Output: 0% (output format unspecified)
- Limits: 0% (no constraints)
- Data: 0% (no context)
- Evaluation: 0% (no success criteria)
- Next: 0% (no next steps)
**Total: 3.3%** ⚠️

🔄 Improvement Suggestions (3 versions):

1. 🟢 Conservative (~60%):
   "Implement a login page using Firebase Auth. Use TypeScript + React Hook Form."

2. 🟡 Balanced (~75%): ⭐ Recommended
   [GOLDEN structured version]

3. 🔵 Comprehensive (~95%):
   [Fully structured version]

---

💡 **Which version should we execute?**
- **"1"** or **"Conservative"**: Quick start (60%)
- **"2"** or **"Balanced"**: Well-balanced structure (75%) ⭐
- **"3"** or **"Comprehensive"**: Full specification (95%)
- **"auto"**: Auto-execute with Balanced

User: 2

Claude: ✅ Executing with Balanced version!

[Immediately executing task with improved prompt...]
```

**Execution Trigger Keywords**:
- Numbers: "1", "2", "3"
- Names: "Conservative", "Balanced", "Comprehensive"
- Short: "c", "b", "comp"
- Auto: "auto"

### Auto-Execution Mode

Evaluate and execute in one step:

```
User: Build a login feature --auto

Claude: (Skips evaluation, auto-executes Balanced version)

✅ Prompt auto-improved (3.3% → 78%)

[Immediately executing task with improved prompt...]
```

**Auto Mode Flags**:
- `--auto`: Auto-execute with Balanced
- `--auto-conservative`: Auto-execute with Conservative
- `--auto-comprehensive`: Auto-execute with Comprehensive

### Basic Usage (Evaluation Only)

When you only want improvement suggestions:

```
User: Build a login feature. Improve prompt.

Claude: (PromptLint skill auto-activated)

📊 Prompt Quality Evaluation:
[Evaluation results...]

🔄 Improvement Suggestions (3 versions):
[3 versions provided...]

💡 Recommended: Use Balanced version (proper structure + sufficient detail)
```

### Evaluation Request

```
User: Evaluate the following prompt:
"Build a login page with Firebase Auth + React Hook Form.
Write in TypeScript, include Zod validation.
Redirect to /dashboard on successful login."

Claude: (PromptLint evaluation)

📊 GOLDEN Evaluation:
- Goal: 85% ✅ (clear goal)
- Output: 80% ✅ (format specified)
- Limits: 40% ⚠️ (insufficient constraints)
- Data: 30% ⚠️ (no project context)
- Evaluation: 60% ⚠️ (partial success criteria)
- Next: 0% ❌ (no follow-up steps)
**Total: 49.2%**

🎯 Improvement Directions:
1. Limits: Add "Use only Tailwind CSS, no external UI libraries"
2. Data: Specify "Current project uses React 19 + Vite"
3. Evaluation: Add "Include error handling, test coverage >=70%"
4. Next: Add "Next: implement signup page"
```

### Context-Based Improvement

```
User: (Working in your-project project)
"Add an AI task classification feature"

Claude: (Auto-detects project context)

📍 Current Context:
- Project: your-project
- Tech stack: React 19, Vite, Firebase, TypeScript
- Recent work: AI task classification
- Existing files: services/aiProcessor.ts, hooks/useTasks.ts

🔵 Comprehensive Improvement:
Goal: Add AI feature to your-project that auto-classifies tasks into 4 quadrants using Gemini API
Output: Modify the following files:
  - services/aiProcessor.ts: Add Gemini API call logic
  - hooks/useTasks.ts: Add AI classification hook
  - types/task.ts: Define AIClassification type
Limits:
  - Must route through Cloud Functions (API key security)
  - Use your-configured-region region
  - Preserve existing Firestore structure
Data:
  - Current your-project has 63 hooks, uses Swiss Design system
  - Firebase Functions Node 20 runtime
  - Existing task type: { title, description, userId, quadrant }
Evaluation:
  - AI classification accuracy >=85%
  - Processing time <3 seconds
  - Fallback mode implemented (manual classification when API fails)
Next:
  1. Implement classifyTask function in Cloud Functions
  2. Add AI classification UI to frontend
  3. Write tests (unit + E2E)
```

## 🔄 Workflow Execution Guide

### Selection-Based Execution

After evaluation, when the user selects a version, **immediately execute the task with that prompt**:

#### Step 1: Evaluation and Suggestions

```
User: Build a login feature

Claude:
📊 GOLDEN Evaluation: 3.3%
🔄 Improvement Suggestions (3 options):
1. Conservative (60%)
2. Balanced (75%) ⭐
3. Comprehensive (95%)

💡 Which version should we execute?
```

#### Step 2: User Selection

**Selection Methods**:
- Numbers: `1`, `2`, `3`
- Names: `Conservative`, `Balanced`, `Comprehensive`
- Short: `c`, `b`, `comp`
- Auto: `auto`

**Examples**:
```
User: 2

or

User: Balanced

or

User: Go with the balanced version
```

#### Step 3: Immediate Execution

```
Claude: ✅ Executing with Balanced version!

Goal: Implement login page using Firebase Auth + React Hook Form
Output: Write in TypeScript, generate the following files:
  - pages/Login.tsx: Login UI
  - hooks/useAuth.ts: Firebase Auth logic
  ...

[Starting login feature implementation with improved prompt...]
```

### Auto-Execution Patterns

#### Pattern 1: --auto flag

```
User: Build a login feature --auto

Claude: ✅ Auto-executing with Balanced version (3.3% → 78%)
[Skipping evaluation step, proceeding directly to implementation...]
```

#### Pattern 2: Explicit version specification

```
User: Build a login feature --auto-comprehensive

Claude: ✅ Auto-executing with Comprehensive version (3.3% → 94%)
[Proceeding directly to implementation with top-tier version...]
```

#### Pattern 3: Inline selection

```
User: Build a login feature. Execute as Balanced.

Claude: ✅ Executing with Balanced version!
[Proceeding directly to implementation...]
```

### Execution Logic

**Claude's Behavior**:

1. **Evaluation Phase**:
   - GOLDEN evaluation of original prompt
   - Generate 3 improved versions
   - Predict scores

2. **Selection Wait**:
   - Request selection from user
   - Wait for keyword detection

3. **Execution Phase**:
   - Extract the selected version's prompt
   - Treat that prompt as a **new user request**
   - Immediately execute the task (file creation, code writing, etc.)

4. **Completion**:
   - Provide task results
   - Suggest follow-up tasks (based on Next steps)

### Keyword Detection

**Selection Detection Patterns**:

| User Input | Detection Result | Execution Version |
|------------|-----------------|-------------------|
| "1", "first" | Conservative | 60% |
| "2", "second", "recommended" | Balanced | 75% ⭐ |
| "3", "third", "complete" | Comprehensive | 95% |
| "c", "con" | Conservative | 60% |
| "b", "bal" | Balanced | 75% |
| "comp", "full", "detailed" | Comprehensive | 95% |
| "auto" | Balanced (default) | 75% |

### Interruption and Re-evaluation

**Re-evaluate**:
```
User: 2

Claude: ✅ Executing with Balanced version!
[Working...]

User: Wait, re-evaluate

Claude:
📊 Previous Evaluation:
Original: 3.3%
Balanced: 78%

🔄 Do you need a new evaluation?
```

**Version Change**:
```
User: No, go with option 3

Claude: ✅ Switching to Comprehensive version!
[Restarting task...]
```

## Practical Tips

### ✅ How to Write Good Prompts

1. **Goal**: Start with a verb, be specific
   - ✅ "Implement login system using Firebase Auth"
   - ❌ "Make login"

2. **Output**: Specify format, files, structure
   - ✅ "Write in TypeScript, generate pages/Login.tsx + hooks/useAuth.ts"
   - ❌ "Write code"

3. **Limits**: Clearly state constraints and restrictions
   - ✅ "No external libraries, use only Tailwind CSS, max 200 lines"
   - ❌ No constraints

4. **Data**: Mention project info and existing code
   - ✅ "Currently React 19 + Vite, existing AuthContext available"
   - ❌ No context

5. **Evaluation**: Define success criteria, error handling, tests
   - ✅ "Redirect to /dashboard on login success, include error handling, coverage >=70%"
   - ❌ No criteria

6. **Next**: Specify follow-up tasks and priorities
   - ✅ "After login is complete, implement signup page"
   - ❌ No next steps

### ⚠️ Patterns to Avoid

| Bad Prompt | Score | After Improvement | Score |
|------------|-------|-------------------|-------|
| "Write some code" | 5% | "Write a login page in TypeScript using Firebase Auth" | 65% |
| "Fix the bug" | 8% | "Fix the bug in useAuth hook where error message doesn't display on login failure" | 72% |
| "Explain this" | 10% | "Explain how the useTasks hook in src/hooks/useTasks.ts works, especially the Firestore subscription part" | 78% |

### 📊 Score Guide

| Score | Grade | Improvement Direction |
|-------|-------|-----------------------|
| 0-20% | ❌ Very Poor | All dimensions need improvement |
| 21-40% | ⚠️ Poor | 3+ dimensions need improvement |
| 41-60% | 🟡 Average | 2-3 dimensions need improvement |
| 61-80% | 🟢 Good | 1-2 dimensions need improvement |
| 81-100% | ✅ Excellent | Maintain or fine-tune |

## Additional Resources

- [GOLDEN Checklist Details](golden-checklist.md)
- [Prompt Pattern Library](patterns.md)
- [Category-Specific Templates](templates.md)
- [PromptLint Skill Reference](SKILL.md)

## Technical Details

### Evaluation Algorithm

```typescript
// GOLDEN score calculation
function evaluateGOLDEN(prompt: string): GOLDENScore {
  const scores = {
    goal: detectGoal(prompt),        // 0-1
    output: detectOutput(prompt),    // 0-1
    limits: detectLimits(prompt),    // 0-1
    data: detectData(prompt),        // 0-1
    evaluation: detectEval(prompt),  // 0-1
    next: detectNext(prompt)         // 0-1
  };

  const avg = Object.values(scores).reduce((a, b) => a + b) / 6;
  const lengthBonus = prompt.split(' ').length >= 50 ? 0.15 : 0;

  return {
    ...scores,
    total: Math.min((avg + lengthBonus) * 100, 100)
  };
}
```

### Improvement Algorithm

```typescript
function generateVariants(prompt: string, context: Context): Variant[] {
  const scores = evaluateGOLDEN(prompt);
  const weakest = findWeakestDimensions(scores);
  const category = classifyTaskCategory(prompt);

  return [
    generateConservative(prompt, weakest[0]),  // Only the weakest dimension
    generateBalanced(prompt, weakest, category), // GOLDEN structure + template
    generateComprehensive(prompt, scores, category, context) // Full structuring
  ];
}
```

## 🎬 Workflow Real-World Examples

### Example 1: Basic Workflow

```
User: Build a login feature

Claude:
📊 GOLDEN Evaluation:
- Goal: 20% ⚠️
- Output: 0% ❌
- Limits: 0% ❌
- Data: 0% ❌
- Evaluation: 0% ❌
- Next: 0% ❌
**Total: 3.3%**

🔄 Improvement Suggestions:
1. 🟢 Conservative (60%)
2. 🟡 Balanced (75%) ⭐
3. 🔵 Comprehensive (95%)

💡 Which version should we execute?

User: 2

Claude: ✅ Executing with Balanced version!

Goal: Implement login page using Firebase Auth + React Hook Form
Output: Write in TypeScript, generate pages/Login.tsx + hooks/useAuth.ts + types/auth.ts
Limits: Use only Tailwind CSS, use only Firebase Auth SDK
Data: React 19 + Vite + Firebase + TypeScript
Evaluation: Redirect to /dashboard on login success, test coverage >=70%
Next: Implement signup page after login is complete

[Starting login feature implementation...]
```

### Example 2: Auto Mode

```
User: Fix the bug --auto

Claude: ✅ Auto-executing with Balanced version (8% → 75%)

Goal: Fix the bug in hooks/useAuth.ts:45 where error message doesn't display on login failure
Output: Modify hooks/useAuth.ts, explain changes with JSDoc comments
Limits: No existing API changes, minimal changes only
Data: Bug reproduction steps, Firebase Auth error (auth/invalid-credential)
Evaluation: Verify error message appears when logging in with invalid email, regression test
Next: Write error message tests

[Starting bug fix...]
```

### Example 3: Using Project Context

```
User: (In your-project project)
Add an AI classification feature

Claude:
📍 Current Context:
- Project: your-project
- Tech stack: React 19, Vite, Firebase, TypeScript

📊 GOLDEN Evaluation: 15%

🔄 Improvement Suggestions:
1. Conservative (65%)
2. Balanced (80%) ⭐
3. Comprehensive (95%)

💡 Which version should we execute?

User: 3

Claude: ✅ Executing with Comprehensive version!

Goal: Add AI feature to your-project that auto-classifies tasks into 4 quadrants using Gemini API
Output: Modify services/aiProcessor.ts + hooks/useTasks.ts + types/task.ts
Limits: Route through Cloud Functions (API key security), your-configured-region region
Data: 63 hooks, Swiss Design, Firebase Functions Node 20
Evaluation: AI classification accuracy >=85%, processing time <3 seconds, Fallback mode
Next: Implement Cloud Functions → Frontend UI → Tests

[Starting AI classification feature implementation...]
```

### Example 4: Inline Selection

```
User: Write tests. Use Comprehensive.

Claude: ✅ Executing with Comprehensive version!

[Skipping evaluation step, executing directly with Comprehensive version...]

Goal: Write unit tests for hooks/useTasks.ts
Output: Generate hooks/useTasks.test.ts, using Vitest + React Testing Library
Limits: Coverage >=80%, mock Firebase without Emulator
Data: getTasks, addTask, updateTask, deleteTask methods
Evaluation: All tests pass, edge cases covered
Next: TaskList component tests → E2E tests

[Starting test writing...]
```

## License

MIT License - Part of claude-code-workflow framework
