# Registry and shared UI component testing

Use this guide when testing a shared UI library or shadcn-style registry whose
components are consumed by separate applications. Consumer-facing contracts and
the boundary between shared and application-specific behavior need special care.

## Test the public contract, not the source

A registry component's *contract* is the API it exposes to consumers:

- Props (names, types, defaults, optionality).
- DOM output (rendered structure, accessibility, attributes).
- Callbacks (`onRowClick`, `onSelect`, `onChange`).
- Controlled vs uncontrolled behavior.
- Documented edge cases (empty state, error state, disabled state).

Test the contract. Do not test:

- Private helpers used only inside the component.
- The exact Tailwind classes applied (they are theme-driven and may shift across consumers).
- The internal state shape (`useState` variables).
- The fact that a private function was called (unless it is an externally observable callback).

## Boundaries between library and consumer

| Lives in the registry | Lives in the consumer |
| --- | --- |
| Generic component, type, helper | Page / feature code |
| Domain-neutral CSS tokens (`--color-line`, `--color-primary`) | Domain tokens (`--app-line-color`, `--priority-accent`) |
| Generic mocks / fixtures | Application-domain mocks |
| Public callback signatures | Consumer wiring (`<FlexTable onRowClick={...}>`) |

Tests for shared components should use **generic fixtures**, not fixtures owned
by one consuming application. If a test needs application-specific setup to
exercise the component, it likely belongs in that consumer rather than the
shared library.

## Multi-instance isolation

When a registry component supports being rendered multiple times on the same page (tables, maps, forms), verify that instances do not share state. A common regression is a hook that uses module-level state and breaks when two instances render side-by-side.

```ts
it("isolates state across two rendered instances", () => {
  render(
    <>
      <Foo id="a" />
      <Foo id="b" />
    </>,
  );

  expect(screen.getByTestId("a-thing")).toHaveTextContent("A's value");
  expect(screen.getByTestId("b-thing")).toHaveTextContent("B's value");
});
```

## Tables, maps, and complex interactions

Cover the actual contract:

- **Tables**: row selection, click handlers, keyboard activation, sort toggles, empty state, custom empty messages.
- **Maps**: lifecycle (mount, load, error, unmount), marker placement, route drawing, camera fit, zoom control add/remove, error event handling.
- **Forms**: validation rules (each rule is its own scenario), submission success path, submission error path, disabled state during submit.
- **Modals / popovers**: open / close, focus trap, escape-to-close, click-outside, return focus to trigger.

Do not test the internal marker helper class if a marker integration test already proves placement. The internal helper is an implementation detail.

## Protected files

The project's ignore rules, contribution guide, or build configuration may
designate files as protected or generated. Before editing a generated component,
find its source template and change the source rather than an overwritten copy.

If a test would require editing a generated file, write the test against the upstream pattern instead.

## Style preservation in refactors

When a registry component has an established visual identity (specific colors, gradient backgrounds, marker halos, status palettes), the test suite should not assert those exact visual treatments — they are theme-driven and may shift between consumers. Assert the contract (rendered presence, accessible name, ARIA state), not the visual.

## Test co-location

Co-locate tests with components according to the project's conventions. Put
helpers shared across library components in the library's test support area;
keep application-domain fixtures with the consuming application.

## What to do when a registry test reveals a bug

Follow the bug-fix workflow in [`regression-bugfixes.md`](regression-bugfixes.md). The added constraint: the fix must remain theme-neutral and consumer-agnostic. If the fix requires a consumer-specific token, the fix belongs in the consumer's theme, not in the registry.
