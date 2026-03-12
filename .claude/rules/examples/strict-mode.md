# TypeScript Strict Mode

## Required Compiler Options

All projects use strict TypeScript configuration:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}
```

## No `any` Policy

- **Never use `any` type** - use `unknown` or proper typing
- Use generics for flexible typing
- Define interfaces/types for all data structures

## Examples

```typescript
// WRONG
function process(data: any) { ... }

// CORRECT
function process<T extends Record<string, unknown>>(data: T) { ... }

// CORRECT - with proper interface
interface TaskData {
  id: string;
  title: string;
  completed: boolean;
}
function process(data: TaskData) { ... }
```

## Null Safety

Use optional chaining and nullish coalescing for safe property access:

```typescript
// WRONG - may throw TypeError
const name = user.profile.name;
const value = data.count || 0;  // Falsy bug: 0 becomes 0

// CORRECT
const name = user?.profile?.name;
const value = data.count ?? 0;  // Only null/undefined triggers default
```

## Type Guards

Use type guards for runtime type checking:

```typescript
function isTaskData(data: unknown): data is TaskData {
  return (
    typeof data === 'object' &&
    data !== null &&
    'id' in data &&
    'title' in data
  );
}
```

## ESLint Integration

ESLint enforces TypeScript rules with `--max-warnings 0`:

```bash
npm run lint  # Must pass with zero warnings
```
