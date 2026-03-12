# Firebase Functions Region

## Required Region: asia-northeast3

All Firebase Functions calls MUST specify the correct region:

```typescript
// REQUIRED
import { getFunctions } from 'firebase/functions';

const functions = getFunctions(app, 'asia-northeast3');
```

## Why This Matters

- Functions are deployed to `asia-northeast3` (Seoul)
- Default region (us-central1) will result in 404 errors
- All projects in this monorepo use the same region

## Common Patterns

```typescript
// Callable function
import { httpsCallable } from 'firebase/functions';

const functions = getFunctions(app, 'asia-northeast3');
const myFunction = httpsCallable(functions, 'functionName');

// With emulator
if (process.env.NODE_ENV === 'development') {
  connectFunctionsEmulator(functions, 'localhost', 5001);
}
```

## Emulator Ports

| Service | Port |
|---------|------|
| Auth | 9099 |
| Firestore | 8080 |
| Functions | 5001 |

## Common Pitfalls

| Issue | Solution |
|-------|----------|
| Functions 404 | Add `'asia-northeast3'` region |
| Emulator port conflict | `pkill -f firebase && rm -rf .firebase/` |
