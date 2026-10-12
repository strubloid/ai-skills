# Registry and shared UI component testing

This repo ships a shadcn-style registry under `registry/`. Registry components are copied verbatim into consumer projects via the shadcn CLI. Several rules from `SKILL.md` apply with extra force here.

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
| Generic mocks / fixtures | Domain mocks (`mockOrdersList`) |
| Public callback signatures | Consumer wiring (`<FlexTable onRowClick={...}>`) |

Tests for registry components should use **generic fixtures**, not consumer-domain fixtures. If a test imports a `mockOrdersList` to exercise `FlexTable`, the test belongs in the consumer, not the registry.

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

The repo's `.gitignore` / `cc.md` / `check.md` may designate certain files as protected or generated. Before editing any file in `registry/`, verify it is not generated. If it is, edit the source template, not the generated copy.

If a test would require editing a generated file, write the test against the upstream pattern instead.

## Style preservation in refactors

When a registry component has an established visual identity (specific colors, gradient backgrounds, marker halos, status palettes), the test suite should not assert those exact visual treatments — they are theme-driven and may shift between consumers. Assert the contract (rendered presence, accessible name, ARIA state), not the visual.

## Test co-location

Tests live next to the component: `registry/foo/foo.test.tsx`. Test helpers used across multiple registry components live in `test/helpers/`. Domain mocks live in the consumer, not in the registry.

## What to do when a registry test reveals a bug

Follow the bug-fix workflow in [`regression-bugfixes.md`](regression-bugfixes.md). The added constraint: the fix must remain theme-neutral and consumer-agnostic. If the fix requires a consumer-specific token, the fix belongs in the consumer's theme, not in the registry.