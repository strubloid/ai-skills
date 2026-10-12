# Frontend testing strategy — what to test where

The right tool depends on the question. Choose by behavior, not by tooling availability.

## Unit tests

Use for:

- Pure functions: calculations, formatting, validation, transformations, business rules.
- Helper modules that do not touch the DOM.
- Type guards and narrowing helpers.

Test meaningful input partitions and boundary conditions. Use parameterized tests (`it.each`) when multiple inputs exercise the same rule. Do not duplicate the implementation's algorithm inside the test — assert the result of the function, not the steps it took.

Boundary conditions to cover:

- Empty input.
- Single-item input.
- Threshold values (the cut-over points where behavior changes).
- Maximum / minimum inputs.
- Invalid inputs that should be rejected or normalized.

## Component tests

Use Testing Library + jsdom (or Vitest Browser Mode if configured) to verify **user-observable behavior**.

Cover, in priority order:

1. **Accessible roles and names** — can a screen reader user find and operate the component?
2. **Forms and validation** — submission, error states, disabled state.
3. **User interactions** — click, type, hover, keyboard.
4. **State transitions** — empty → loading → success / error.
5. **Loading, empty, success, and error states** — every state has a UI, and the UI is intentional.
6. **Disabled and pending states** — submit during fetch, button while disabled.
7. **Keyboard navigation and focus management** — tab order, focus trap, escape-to-close.
8. **Tables** — sorting, filtering, selection, pagination.
9. **Modals, event propagation, callbacks** — onClick, onChange, onSelect, controlled vs uncontrolled.

Prefer semantic queries: `getByRole`, `getByLabelText`, `getByText`. Use `findBy*` for anything async. Avoid arbitrary sleeps, private state assertions, CSS-class assertions (except as a proxy for a public contract like `aria-invalid` propagation), and unnecessary `data-testid`s.

When the visible state is well expressed through Tailwind classes (e.g., a label that visually "floats up" via `top-1` and `text-xs`), asserting on the class is acceptable **only when** the class is the documented contract. Otherwise prefer `toBeVisible()` or `toHaveAttribute(...)`.

## Integration tests

Test meaningful behavior across components, providers, routing, state management, and API boundaries. Use the project's real providers and routing where possible — only mock the network and the modules outside your scope.

Use **MSW** (Mock Service Worker) for HTTP interception when:

- The component fetches data.
- You need to verify loading, success, error, and empty states.
- You need to verify the request payload and headers, not just the response.

Do **not** use MSW when:

- The component does not touch the network.
- A simpler stub (`vi.fn()`) suffices and the test stays clear.

## Browser / end-to-end tests

Use Playwright (or the project's supported browser tool) for behavior that simulated DOM environments cannot reliably validate:

- Complex layout (sticky positioning, scroll containers, viewport-dependent rendering).
- Focus management across browser focus traps.
- Real browser APIs (clipboard, file upload, drag-and-drop).
- Responsive interactions at specific viewport sizes.
- Critical user journeys (sign-up, checkout, multi-step form).

Avoid duplicating every component test as an end-to-end test. End-to-end tests are slower and more brittle. Use them for the journeys that justify the cost.

## React-specific guidance

- Follow current React docs (https://react.dev/).
- Account for Strict Mode (double-invocation of effects in development).
- Account for concurrent rendering — `act()` and `findBy*` already handle most cases.
- Keep fixtures compatible with real application types. Use the same `MapPoint`, `User`, `Row` types the production code uses.
- Avoid `any` and unsafe `as` casts in tests. A test that needs a cast to compile usually signals the wrong fixture.
- Test public component contracts, not private implementation details.

## What NOT to test

- Trivial getters/setters.
- Pure pass-through components (props in, JSX out, no logic).
- Generated code (type declarations, build artifacts).
- Third-party library internals — trust the library's own tests.
- Implementation details that will change in a refactor.

If a test exists only because the line of production code exists, it is testing the implementation, not the contract. Delete it or rewrite it.

## Coverage — diagnostic, not target

Coverage is a tool for finding files nobody has tested. It is not a quality metric. A component with 100% line coverage and no behavior tests is more dangerous than a component with 80% coverage and one well-written scenario test.

When to use coverage:

- To find untested files in a module you are about to modify.
- To find dead code paths in a file you are rewriting.
- To confirm a refactor did not silently drop a branch.

When NOT to use coverage:

- As a merge gate ("must be 90%").
- As the reason to add tests.
- As the reason to keep tests that prove nothing.

Mutation testing (e.g., Stryker) is a stronger signal when it is compatible with the project — it modifies production code and checks whether tests catch the change. Use it when meaningful behavior coverage is the goal and a Jest/Vitest plugin is available.