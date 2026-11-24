# Vitest and React Testing Library idioms

These examples use Vitest, React Testing Library, `user-event`, `jest-dom`, and
jsdom. Verify installed versions and project configuration before applying
version-specific APIs. Sources are listed in [`sources.md`](sources.md).

Use these framework-specific idioms alongside the behavior-first rules in the
parent guide. The project's established setup takes precedence where it differs.

## Tooling cheatsheet

| Need | Use |
| --- | --- |
| Render a component | `render(<Component />)` from `@testing-library/react` |
| Find by accessible role / name | `screen.getByRole("button", { name: /submit/i })` |
| Find by label | `screen.getByLabelText(/email/i)` |
| Find by text | `screen.getByText("...")` |
| Assert element exists | `expect(el).toBeInTheDocument()` from `@testing-library/jest-dom` |
| Assert element does not exist | `expect(screen.queryByText("...")).not.toBeInTheDocument()` |
| Await async appearance | `await screen.findByText("...")` (retries up to 1000ms) |
| Simulate user interaction | `const user = userEvent.setup(); await user.click(btn);` |
| Force an event (focus, key) | `fireEvent.focus(el)` / `fireEvent.keyDown(el, { key: "Enter" })` |
| Mount a hook | `const { result, rerender, unmount } = renderHook(() => useFoo())` |
| Force a state update from outside React | `act(() => { ... })` |
| Mock a function | `vi.fn()` |
| Spy on a method | `vi.spyOn(obj, "method")` |
| Mock a module | `vi.mock(import("./module"), factory)` at the top of the file |
| Mock the network | MSW (see [`testing-strategy.md`](testing-strategy.md)) |
| Restore all mocks | `vi.restoreAllMocks()` in `afterEach` |
| Use fake timers | `vi.useFakeTimers()` + `vi.advanceTimersByTime(ms)` + `vi.useRealTimers()` in `afterEach` |
| Wait for an async state update | `await waitFor(() => ...)` or `await screen.findBy...` |

## Query priority — accessible first

Order of preference (highest first):

1. `getByRole` / `findByRole` / `queryByRole`
2. `getByLabelText` / `findByLabelText` / `queryByLabelText`
3. `getByPlaceholderText` (only when label is impractical)
4. `getByText` / `findByText` / `queryByText`
5. `getByDisplayValue`
6. `getByAltText`
7. `getByTitle`
8. `getByTestId` — last resort

If the only way to find an element is `getByTestId`, the component probably has poor accessibility. Fix the component, then re-query.

## `getBy` vs `queryBy` vs `findBy`

- `getBy*` — throws if missing. Use to assert **presence**.
- `queryBy*` — returns `null` if missing. Use to assert **absence** (`expect(...).toBeNull()` or `expect(...).not.toBeInTheDocument()`).
- `findBy*` — async, retries up to 1000 ms. Use for anything async.

Prefer `await screen.findByRole(...)` over `waitFor(() => getByRole(...))` — `findBy` retries internally and has better error messages. `waitFor` is for asserting state changes, not for waiting on element appearance.

## `userEvent` over `fireEvent`

`userEvent` simulates a full user interaction (focus, keydown, keypress, input, change, blur). `fireEvent` dispatches a single DOM event. Prefer `userEvent` for clicks, typing, and selection. Use `fireEvent` only for events `userEvent` does not yet support (e.g., some focus / blur edge cases).

```ts
const user = userEvent.setup();
render(<MyForm />);
await user.click(screen.getByRole("button", { name: /submit/i }));
await user.type(screen.getByLabelText(/email/i), "[email protected]");
```

Every `userEvent` call returns a Promise. **Always `await` it.** Missing `await` is the most common flake source.

## `act()` — when and when not

- `render()`, `screen.findBy*`, `userEvent.*` — already wrap in `act()`. **Do not add `act()` yourself.**
- Manual state updates or handler calls from outside React's callstack — wrap in `act()`.

```ts
// Needed — calling a hook updater from the test body
act(() => {
  result.current.increment();
});

// NOT needed — user.click already wraps in act
await user.click(btn);
```

Double-wrapping causes `act` warnings and is unnecessary.

## Hooks (`renderHook`)

```ts
const { result, rerender, unmount } = renderHook(
  ({ id }) => useFoo(id),
  { initialProps: { id: 1 } },
);

// Re-render with new props
rerender({ id: 2 });

// Read result
expect(result.current.value).toBe(...);

// Do NOT destructure result.current — the assignment locks the value
// expect(result.current.value) is fine; const { value } = result.current is not
```

For context-dependent hooks, pass a `wrapper`:

```ts
renderHook(() => useAuth(), {
  wrapper: ({ children }) => <AuthProvider>{children}</AuthProvider>,
});
```

## Mocking

- **Mock at the network or module boundary**, not deep into your own code.
- Module mocks go at the top of the test file via `vi.mock(import("./module"), factory)`. Hoist references the factory needs via `vi.hoisted(() => ...)`.
- Don't over-mock. A test where every dependency is a stub proves only that the stubs work.
- Always restore mocks. `vi.restoreAllMocks()` in `afterEach`. `vi.clearAllMocks()` only clears call history, not implementations.

## Async patterns

If a project already provides a helper for flushing a known effect boundary,
reuse that helper rather than inventing another one. Otherwise prefer waiting
for the user-visible result with the Testing Library async queries:

```ts
await screen.findByRole("status", { name: /updated/i });
```

Use lower-level microtask flushing only when a behavior cannot be observed
through the rendered result and the project's test architecture requires it.

## Test independence

- No shared mutable state between tests.
- `beforeEach` for setup, `afterEach` for teardown.
- Follow the project's cleanup setup. Avoid manually unmounting when its
  Testing Library integration already performs cleanup.

## Project setup

Before adding setup, polyfills, or mocks, inspect the target project's test
configuration and existing helpers. Extend shared setup when the behavior is
needed across tests; keep one-off setup local. Avoid adding polyfills for APIs
that the configured test environment already supports.

## Files and imports

- Test files: `*.test.ts` / `*.test.tsx` co-located with the file they test.
- Use the target project's configured import aliases and test helper paths.
- Follow its conventions for global test APIs versus explicit imports.

## What to do when tooling breaks

1. Read the configured test-runner configuration and setup files first.
2. Read the failing test's setup (especially `beforeEach` / `installResizeObserverMock` / `mockResizeObservers`).
3. If a polyfill is genuinely needed, add it to shared setup only when multiple tests rely on it.
4. If the same mock helper is needed in multiple tests, use or extend the project's shared test helpers.

## Source-of-truth docs

Verified 2026-10-12 — see [`sources.md`](sources.md):

- Vitest getting started — https://vitest.dev/guide/
- Vitest component testing — https://vitest.dev/guide/browser/component-testing
- Testing Library queries — https://testing-library.com/docs/queries/about
- Testing Library user-event — https://testing-library.com/docs/user-event/intro
- React Testing Library — https://testing-library.com/docs/react-testing-library/intro
- jest-dom matchers — https://github.com/testing-library/jest-dom
