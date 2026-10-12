# Vitest + React Testing Library idioms for this repo

Stack: Vitest 4.x, `@testing-library/react` 16.x, `@testing-library/user-event` 14.x, `@testing-library/jest-dom` 7.x, `jsdom` 30.x. Verified 2026-10-12 against `vitest.dev` and `testing-library.com`. See [`sources.md`](sources.md) for the full citation list.

This file is project-flavored guidance on top of the framework-agnostic rules in `SKILL.md`. The preservation and granularity rules still apply. Nothing here overrides them.

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

For "wait one microtask" inside a hook test, the repo uses a `waitForEffect` helper:

```ts
const waitForEffect = async () => {
  await act(async () => {
    await Promise.resolve();
  });
};
```

Match that pattern when adding new hook tests.

## Test independence

- No shared mutable state between tests.
- `beforeEach` for setup, `afterEach` for teardown.
- `test/setup.ts` runs `cleanup()` after every test through RTL's auto-cleanup. Do not manually unmount in addition.

## Setup files this repo already has

- `test/setup.ts` — `jest-dom/vitest` matchers, `cleanup()` afterEach, `offsetWidth` polyfill (reads `data-mock-width`), `ResizeObserver` no-op stub, `matchMedia` stub, default viewport `1024px`.
- `test/mocks/resize-observer.ts` — controllable `ResizeObserver` mock. Use `installResizeObserverMock()` in `beforeEach` when a test needs to assert ResizeObserver behavior.
- `test/helpers/pinned-cell.tsx` — `renderCell` / `renderRow` helpers for tests that exercise the pinned-column table geometry. Use them; do not rebuild the same DOM.
- `vitest-jest-dom.d.ts` — bridges `@testing-library/jest-dom` matchers into the global `expect()` type.

If a test needs a new polyfill or a new mock, add it to these files — do not redefine it inline.

## Files and imports

- Test files: `*.test.ts` / `*.test.tsx` co-located with the file they test.
- Imports use the project's aliases: `import { useFoo } from "@/registry/foo/use-foo"` (or the relevant path).
- Test-only helpers: `import { renderCell } from "@test/helpers/pinned-cell"`.
- The repo uses `globals: true`, but the existing tests import `describe`, `it`, `expect`, `vi` explicitly. **Match the existing style — import explicitly.**

## What to do when tooling breaks

1. Read `vitest.config.ts` and `test/setup.ts` first.
2. Read the failing test's setup (especially `beforeEach` / `installResizeObserverMock` / `mockResizeObservers`).
3. If a polyfill is missing, add it to `test/setup.ts` once, not per-test.
4. If you find yourself writing the same mock helper in multiple tests, extract it to `test/mocks/` or `test/helpers/`.

## Source-of-truth docs

Verified 2026-10-12 — see [`sources.md`](sources.md):

- Vitest getting started — https://vitest.dev/guide/
- Vitest component testing — https://vitest.dev/guide/browser/component-testing
- Testing Library queries — https://testing-library.com/docs/queries/about
- Testing Library user-event — https://testing-library.com/docs/user-event/intro
- React Testing Library — https://testing-library.com/docs/react-testing-library/intro
- jest-dom matchers — https://github.com/testing-library/jest-dom