# Firebase Functions Region

> **Note**: Stack-specific example. Replace `<your-region>` (e.g. `us-central1`,
> `asia-northeast1`, `europe-west1`) with the region your project deploys to.

## Required Region: `<your-region>`

All Firebase Functions calls MUST specify the correct region:

```typescript
// REQUIRED
import { getFunctions } from 'firebase/functions';

const functions = getFunctions(app, '<your-region>');
```

## Why This Matters

- Functions are deployed to a single region per project — pinning the client
  prevents cross-region invocation
- The default region (`us-central1`) will return 404 if the function lives
  elsewhere
- Mixing regions across packages in a monorepo causes silent latency and
  routing bugs

## Common Patterns

```typescript
// Callable function
import { httpsCallable } from 'firebase/functions';

const functions = getFunctions(app, '<your-region>');
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
| Functions 404 | Pass the deployed region as the second `getFunctions` arg |
| Emulator port conflict | `pkill -f firebase && rm -rf .firebase/` |
