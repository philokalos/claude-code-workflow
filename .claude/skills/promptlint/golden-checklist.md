# GOLDEN Checklist Details

A prompt quality evaluation framework based on Anthropic's official guidelines.

## 📋 6 Dimensions

### G - Goal

**Definition**: A clear objective that the prompt aims to achieve

**Characteristics of a Good Goal**:
- Starts with a verb ("implement", "create", "analyze", "fix")
- Specifies a concrete feature/task
- Avoids vague expressions

**Examples**:

| Score | Prompt | Reason |
|-------|--------|--------|
| 90% | "Implement email/password login system using Firebase Auth" | Tech stack, method, and feature are clear |
| 70% | "Implement login feature" | Feature is clear but specific method not specified |
| 40% | "Make a login" | Too vague |
| 10% | "Write code" | Goal is unclear |

**Evaluation Keywords**:
- ✅ High score: "implement", "create", "analyze", "fix", "add", "remove", "optimize"
- ⚠️ Medium score: "make", "build", "write"
- ❌ Low score: "do it", "please", "help me"

---

### O - Output

**Definition**: Specify desired output format, structure, and files

**Characteristics of Good Output**:
- Language/framework specified
- File structure specified
- Code style/format specified
- Comment/documentation requirements

**Examples**:

| Score | Prompt | Reason |
|-------|--------|--------|
| 95% | "Write in TypeScript, generate the following files:<br>- pages/Login.tsx (UI)<br>- hooks/useAuth.ts (logic)<br>- types/auth.ts (types)<br>Include JSDoc comments, Prettier format" | Language, files, structure, comments, and format all specified |
| 75% | "Write in TypeScript, generate Login.tsx and useAuth.ts" | Language and files specified, structure lacking |
| 50% | "Write in TypeScript" | Only language specified |
| 20% | "Write as code" | Too vague |

**Evaluation Keywords**:
- ✅ High score: language, filenames, directories, comments, format, structure
- ⚠️ Medium score: only language specified
- ❌ Low score: output format not specified

---

### L - Limits (Constraints)

**Definition**: Constraints, restrictions, and boundaries for code/work

**Characteristics of Good Limits**:
- Allowed/prohibited libraries specified
- Code length/complexity restrictions
- Performance/resource constraints
- Style/pattern constraints

**Examples**:

| Score | Prompt | Reason |
|-------|--------|--------|
| 90% | "Use only Tailwind CSS, no external UI libraries<br>Max 200 lines<br>No auth libraries besides Firebase Auth SDK<br>Use only React Hook Form" | Libraries, length, and restrictions all specified |
| 70% | "Use only Tailwind CSS, max 200 lines" | Library and length limits present |
| 40% | "Keep it simple" | Vague constraint |
| 0% | No constraints | Constraints not specified |

**Evaluation Keywords**:
- ✅ High score: "only", "prohibited", "max", "min", "within", "without"
- ⚠️ Medium score: "simple", "short", "minimal"
- ❌ Low score: constraints not specified

---

### D - Data (Context)

**Definition**: Context, background information, and existing code needed for the task

**Characteristics of Good Data**:
- Current project information
- Tech stack
- Existing code/files mentioned
- Related settings/dependencies

**Examples**:

| Score | Prompt | Reason |
|-------|--------|--------|
| 95% | "Current project: React 19 + Vite + Firebase<br>Existing AuthContext: context/AuthContext.tsx<br>Firebase config: src/config/firebase.ts<br>Firestore rules: userId filter required for all queries<br>Region: your-configured-region" | Project, existing code, rules, and settings all specified |
| 75% | "React 19 + Vite project, AuthContext exists" | Project and existing code mentioned |
| 50% | "React project" | Only framework mentioned |
| 0% | No context | No information provided |

**Evaluation Keywords**:
- ✅ High score: "current", "existing", "project", "config", "dependency", "version"
- ⚠️ Medium score: only framework mentioned
- ❌ Low score: no context

---

### E - Evaluation (Verification)

**Definition**: Success criteria, verification methods, test requirements

**Characteristics of Good Evaluation**:
- Success conditions specified
- Error handling required
- Test coverage
- Performance criteria

**Examples**:

| Score | Prompt | Reason |
|-------|--------|--------|
| 95% | "Redirect to /dashboard on successful login<br>Error handling: invalid email/password, network errors<br>Test coverage ≥70%<br>Login processing time <2 seconds" | Success, error, test, and performance all specified |
| 75% | "Redirect to /dashboard on login success, include error handling" | Only success and error specified |
| 50% | "Navigate to dashboard on login success" | Only success condition specified |
| 0% | No verification criteria | Evaluation criteria not specified |

**Evaluation Keywords**:
- ✅ High score: "on success", "on failure", "test", "verify", "coverage", "performance"
- ⚠️ Medium score: only success condition mentioned
- ❌ Low score: no criteria

---

### N - Next (Next Steps)

**Definition**: Follow-up tasks and priorities after the current work

**Characteristics of Good Next**:
- Clear follow-up tasks
- Order/priority
- Dependencies specified

**Examples**:

| Score | Prompt | Reason |
|-------|--------|--------|
| 90% | "After login is complete:<br>1. Implement signup page<br>2. Password reset feature<br>3. Write E2E tests<br>4. Deploy login page" | Order, priority, and dependencies are clear |
| 70% | "Implement signup page after login" | Next step specified, order lacking |
| 40% | "Next is signup" | Too brief |
| 0% | No next steps | Follow-up tasks not specified |

**Evaluation Keywords**:
- ✅ High score: "next", "follow-up", "after", "1.", "2.", "priority"
- ⚠️ Medium score: only next step mentioned
- ❌ Low score: no next steps

---

## 📊 Score Calculation Formula

```typescript
// 1. Calculate each dimension score (0-1)
const goalScore = evaluateGoal(prompt);
const outputScore = evaluateOutput(prompt);
const limitsScore = evaluateLimits(prompt);
const dataScore = evaluateData(prompt);
const evaluationScore = evaluateEvaluation(prompt);
const nextScore = evaluateNext(prompt);

// 2. Calculate average
const average = (goalScore + outputScore + limitsScore +
                 dataScore + evaluationScore + nextScore) / 6;

// 3. Length bonus (50+ words)
const wordCount = prompt.split(' ').length;
const lengthBonus = wordCount >= 50 ? 0.15 : 0;

// 4. Final score (0-100)
const totalScore = Math.min((average + lengthBonus) * 100, 100);
```

## 🎯 Practical Application

### Example 1: Improving a Low-Score Prompt

**Original (Score: 12%)**:
```
Make a login
```

**GOLDEN Evaluation**:
- Goal: 20% (goal is vague)
- Output: 0% (format not specified)
- Limits: 0% (no constraints)
- Data: 0% (no context)
- Evaluation: 0% (no criteria)
- Next: 0% (no next steps)

**After Improvement (Score: 78%)**:
```
Goal: Implement email/password login page using Firebase Auth + React Hook Form
Output: Write in TypeScript, generate the following files:
  - pages/Login.tsx (login UI)
  - hooks/useAuth.ts (Firebase Auth hook)
  - types/auth.ts (type definitions)
Limits: Use only Tailwind CSS, no external UI libraries, max 200 lines
Data: Current project uses React 19 + Vite + Firebase, existing AuthContext available
Evaluation: Redirect to /dashboard on login success, include error handling, test coverage >=70%
Next: Implement signup page after login is complete
```

**GOLDEN Evaluation**:
- Goal: 85% ✅
- Output: 80% ✅
- Limits: 70% 🟢
- Data: 75% 🟢
- Evaluation: 80% ✅
- Next: 60% 🟡

### Example 2: Improving a Mid-Score Prompt

**Original (Score: 48%)**:
```
Build a login page in TypeScript. Use Firebase Auth.
```

**GOLDEN Evaluation**:
- Goal: 70% (feature clear, method specified)
- Output: 60% (language specified, structure lacking)
- Limits: 0% (no constraints)
- Data: 40% (some tech stack mentioned)
- Evaluation: 0% (no criteria)
- Next: 0% (no next steps)

**After Improvement (Score: 82%)**:
```
Goal: Implement email/password login page using Firebase Auth + React Hook Form
Output: Write in TypeScript, generate pages/Login.tsx + hooks/useAuth.ts + types/auth.ts, include JSDoc comments
Limits: Use only Tailwind CSS, no external UI libraries, use only Firebase Auth SDK
Data: Current project uses React 19 + Vite + Firebase, your-configured-region region, existing AuthContext: context/AuthContext.tsx
Evaluation: Redirect to /dashboard on login success, error handling (invalid email/password, network errors), test coverage >=70%
Next: Implement signup page after login, add password reset feature
```

**GOLDEN Evaluation**:
- Goal: 90% ✅
- Output: 85% ✅
- Limits: 80% ✅
- Data: 85% ✅
- Evaluation: 85% ✅
- Next: 75% 🟢

---

## 🔄 Iterative Improvement Process

1. **Draft**: Write the initial idea
2. **GOLDEN Evaluation**: Check scores across all 6 dimensions
3. **Identify Weaknesses**: Find dimensions scoring 0-40%
4. **Incremental Improvement**: Conservative → Balanced → Comprehensive
5. **Re-evaluate**: Check scores after improvement
6. **Target Achieved**: Complete when reaching 70%+

## 📚 References

- [Anthropic Prompt Engineering Guide](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/)
- [Claude Code Best Practices](https://code.claude.com/docs/en/guides/best-practices)
- [Prompt Pattern Library](patterns.md)
