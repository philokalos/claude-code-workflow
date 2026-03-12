# Testing Standards

## Test Frameworks

| Type | Framework |
|------|-----------|
| Unit Tests | Vitest / Jest |
| E2E Tests | Playwright |
| Component Tests | React Testing Library |

## Commands

```bash
npm test              # Run all tests
npm run test:watch    # Watch mode
npm run test:coverage # Coverage report
npx playwright test   # E2E tests
```

## Coverage Requirements

- Minimum coverage: Follow project-specific requirements
- Critical paths must have tests
- New features require corresponding tests

## Test Structure

```typescript
describe('ComponentName', () => {
  it('should render correctly', () => {
    // Arrange
    const props = { ... };

    // Act
    render(<Component {...props} />);

    // Assert
    expect(screen.getByText('...')).toBeInTheDocument();
  });
});
```

## Best Practices

1. **Test behavior, not implementation**
2. **Use meaningful test descriptions**
3. **Avoid testing library internals**
4. **Mock external dependencies**
5. **Keep tests focused and isolated**

## Firebase Emulator Testing

```bash
firebase emulators:start
# Then run tests against emulators
```
