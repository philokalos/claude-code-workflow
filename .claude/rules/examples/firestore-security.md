# Firestore Security Rules

## Required Query Pattern

All Firestore queries MUST include `userId` filtering:

```typescript
// REQUIRED
where('userId', '==', uid)
```

## Why This Matters

Security rules enforce user-scoped data access. Queries without `userId` filter will result in:
- `Permission denied` errors
- Failed reads even for owned documents

## Examples

```typescript
// Correct
const q = query(
  collection(db, 'tasks'),
  where('userId', '==', auth.currentUser?.uid),
  orderBy('createdAt', 'desc')
);

// WRONG - will fail
const q = query(
  collection(db, 'tasks'),
  orderBy('createdAt', 'desc')
);
```

## Common Pitfalls

| Issue | Solution |
|-------|----------|
| Permission denied | Add `where('userId', '==', uid)` |
| Can't read own data | Check if uid is defined before query |
| Composite index error | Create index in Firebase Console |

## API Keys

- **AI API keys**: Cloud Functions only, NEVER client-side
- Store secrets in Firebase environment config
