---
name: accessibility
description: Use when writing, reviewing, or fixing any UI in a browser — forms, dialogs, tables, navigation, filters, charts, async loading and error states. Enforces accessibility from the first line of code in a fixed order: semantics (WAI-ARIA) → keyboard operability → focus management → announcements. Triggers on "accessible", "a11y", "aria", "screen reader", "keyboard navigation", "focus management", "focus ring", "skip link", "WCAG", "audit for a11y", "label this input", "announce this".
---

# Accessibility

Accessibility is not a cleanup pass. It is decided by the first line of JSX:
which element you used, what you named it, and where focus lands. Build it in
and it costs nothing; retrofit it and it costs a rewrite.

Work in this order, because each layer depends on the previous one:

1. **Semantics** — the right element, the right role, the right name.
2. **Keyboard** — every action reachable, operable, and visible.
3. **Focus** — where it starts, where it goes, where it lands afterwards.
4. **Announcements** — what a screen reader is told when the world changes.

Never start at 4. An `aria-live` region wrapped around a `<div onClick>` is
still a mouse-only feature.

## 0. Know what the framework already does

Before adding a single ARIA attribute, find out what the component library
already gives you. Most modern primitives (Base UI, Radix, Headless UI) ship
correct roles, keyboard handling and focus management. Adding ARIA on top of
correct ARIA is how you break it.

In a shadcn/Base UI stack:

| The library gives you | Never hand-roll it |
|---|---|
| `role="dialog"`, focus trap, Escape to close, focus restore on close | a custom modal |
| `role="menu"`, `menuitem`, arrow-key navigation, `aria-expanded` on the trigger | a dropdown |
| `role="listbox"`/`option`, typeahead, `aria-activedescendant` | a custom select |
| `role="tab"`/`tabpanel`, arrow keys, `aria-controls` | tab switching |
| `aria-modal`, `aria-labelledby` from `DialogTitle` | focus trapping utilities |
| `type="button"` on every rendered button | `onClick` on a `<div>` |

Known gaps in **Base UI 1.8** (verify against the installed version, don't
trust this list forever):

- It does **not** emit `aria-modal="true"` on the dialog popup — add it yourself.
- It does not emit `aria-sort` on sortable table headers — you own that.
- It does not wire `aria-describedby` from a form error to its input — you own that.

Also: **lucide-react v1** auto-adds `aria-hidden="true"` to an icon that has no
`aria-*` / `role` / `title` prop and no children. Decorative lucide icons need
no manual `aria-hidden`. Hand-rolled `<svg>` does.

If the project uses `render` (Base UI) or `asChild` (Radix) for polymorphism,
use it instead of nesting: **never nest interactive content inside another
interactive element.**

```tsx
// BAD — a button inside a button, a link inside a button
<DropdownMenuTrigger><Button>Columns</Button></DropdownMenuTrigger>
<SidebarMenuButton><Link to="/x">Item</Link></SidebarMenuButton>

// GOOD — one element, composed
<DropdownMenuTrigger render={<Button variant="outline" />}>Columns</DropdownMenuTrigger>
<SidebarMenuButton render={<Link to="/x" />}>Item</SidebarMenuButton>
```

## 1. Semantics

### Use the native element first

Native HTML is more accessible than the ARIA that imitates it, and screen
readers have muscle memory for it.

| Instead of | Use |
|---|---|
| `<div onClick>` | `<button type="button">` |
| `<div onClick>` for navigation | `<a href>` / router `<Link>` |
| `<div role="switch">` | a real `<button role="switch">` or a checkbox |
| `<span aria-label>` | `<span class="sr-only">` inside, or visible text |
| `<div role="listbox">` of checkboxes | a plain group of checkboxes |
| `<span onClick>` to stop propagation | put the handler on the control itself |

### Every control needs a programmatic name

A placeholder is not a label. An icon is not a label.

```tsx
// BAD
<Input placeholder="Search" />

// GOOD
<Label htmlFor="search">Search</Label>
<Input id="search" />

// GOOD — icon-only button
<Button aria-label="Copy record ID"><CopyIcon /></Button>
```

The name comes from: visible text, `aria-label`, `aria-labelledby`, or the
`title` attribute (last resort).

### `aria-label` only works on a nameable element

`aria-label` on a generic `<div>` or `<span>` is ignored — there is no role to
name. Use a real element, or put the text in the element:

```tsx
// BAD — ignored by screen readers
<span aria-label="Dangerous goods"><TruckIcon aria-hidden /></span>

// GOOD
<span><TruckIcon aria-hidden /><span className="sr-only">Dangerous goods</span></span>
```

### Do not put state in the name

`aria-checked` already carries the state. A name that changes with state breaks
voice control ("click Shown on map").

```tsx
// BAD
aria-label={isHidden ? "Shown on map — click to hide" : "Hidden — click to show"}

// GOOD
aria-label="Show vehicle on map"
aria-checked={!isHidden}
```

### Errors are announced with their field

`aria-invalid` says *that* it is invalid. `aria-describedby` says *why*.

```tsx
const errorId = `${id}-error`;

<Input
  id={id}
  aria-invalid={error ? "true" : undefined}
  aria-describedby={error ? errorId : undefined}
/>
<FieldError id={errorId}>{error}</FieldError>
```

A live region (`role="alert"`) on the error is not a substitute — it fires once
and is gone by the time the user tabs to the field.

### Disclosures and navigation

```tsx
<button aria-expanded={open} aria-controls={panelId} />
<div id={panelId} hidden={!open} />

<Link aria-current="page" />   // only the active one
```

`aria-current="page"` on a menu *button* is meaningless — put it on the item
that navigates.

### Do not fake a widget pattern

If you write `role="listbox"`, you owe arrow keys, `aria-activedescendant` or
roving `tabIndex`, Home/End, and option children. If you do not want to build
that, do not claim the pattern. A list of checkboxes is a group of checkboxes.

Same for `role="tab"`: it needs a `tablist` parent, `aria-selected`, and a
`tabpanel` the tab controls. Buttons that switch panels without that
relationship should not claim `aria-current="page"` either.

### Tables

- Sortable header: `aria-sort="ascending" | "descending" | "none"` on the `<th>`.
- A row that is clickable needs a real `<button>` in a cell (a `<tr>` cannot
  change role) — and a row that is focusable must do something on Enter/Space.
- A scrollable table container needs `tabIndex={0}` and an accessible name, or
  keyboard users cannot scroll it.

## 2. Keyboard

Every action a mouse can do, the keyboard can do.

- No action may exist only on double-click, long-press, drag or hover.
- If a row opens a detail view on double-click, it must also open on Enter, or
  have a visible button that does.
- Custom interactive elements need `tabIndex={0}`, `role`, Enter/Space handling
  — or, better, be a real `<button>`.
- `tabIndex` is `0` or `-1`. A positive `tabIndex` reorders the whole page and
  is always a bug.
- Never `preventDefault()` a key without an equivalent affordance.

### The focus ring must survive

```tsx
// BAD — focus is invisible
className="focus-visible:outline-none"

// GOOD
className="focus-visible:ring-2 focus-visible:ring-ring"
```

Every `outline-none` needs a `focus-visible` replacement in the same class
list. If a project uses the shadcn lint rule, remember it also rejects spacing
and colour utilities on shadcn components: put `gap-*` on a plain wrapper
`<div>`, not on the primitive.

### Global shortcuts must not fire while typing

```tsx
if (event.key === "b" && (event.metaKey || event.ctrlKey)) {
  if (event.target instanceof HTMLElement &&
      event.target.closest("input, textarea, [contenteditable]")) return;
  toggleSidebar();
}
```

## 3. Focus management

### Overlays

The primitive handles the trap, the initial focus, Escape and the restore to
the trigger. Your job:

- **Name the dialog.** `DialogTitle` / `SheetTitle` / `FlexSheetTitle` must be
  in the dialog, or the dialog has no accessible name.
- **Do not fight the restore.** Do not `autoFocus` something else, do not
  unmount the trigger on close.

### Route changes (SPA)

Focus does not move on a client-side navigation. The user is left focused on a
link that now points somewhere else.

```tsx
const { pathname } = useLocation();
const mainRef = useRef<HTMLElement>(null);

useEffect(() => { mainRef.current?.focus(); }, [pathname]);

<main id="main-content" ref={mainRef} tabIndex={-1}>{children}</main>
```

Alongside it, per route: `document.title`, and a skip link.

```tsx
<a href="#main-content"
   className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50
              focus:rounded-md focus:bg-background focus:px-3 focus:py-2 focus:ring-2 focus:ring-ring">
  Skip to main content
</a>
```

`sr-only` + `focus:not-sr-only` — never `display:none`, which removes it from
the tab order entirely.

### One main landmark

One `<main>` per page, and `<header>` / `<footer>` outside it (inside `<main>`
they stop being `banner` / `contentinfo` landmarks).

### Focus lost when the focused element unmounts

Deleting a row, clearing a selection, closing a panel — the focused element
disappears and focus falls to `<body>`. Move it explicitly:

```tsx
removeItem(index);
requestAnimationFrame(() => nextItemRef.current?.focus());
```

### Form submission

Focus the first invalid control when validation fails — do not leave focus on
the submit button while the message is somewhere else on the page.

```tsx
if (Object.keys(errors).length > 0) {
  requestAnimationFrame(() =>
    formRef.current?.querySelector<HTMLElement>('[aria-invalid="true"]')?.focus());
  return;
}
```

## 4. Announcements

The user gets no feedback from something that merely changed on screen.

| Situation | Mechanism |
|---|---|
| Something failed | `role="alert"` on the error, or a toast |
| A save is in flight | `aria-busy` on the button, label says "Saving…" |
| A list loaded / refreshed | `role="status"` with the count |
| A selection changed | `role="status"` with the count, not just the word "Selected" |
| New messages in a chat | `role="log" aria-live="polite"` |
| The route changed | a visually-hidden `aria-live="polite"` region with the page title |

Put the live region in the DOM before the content changes, and keep it
visually hidden but not `display:none` (`sr-only`).

## 5. Motion, colour, zoom

- Honour `prefers-reduced-motion`. If the app animates anything, add a global
  block in the CSS.
- `prefers-color-scheme` should drive the default theme when the user has not
  chosen one.
- Never rely on colour alone to carry meaning.
- Alpha-modified foregrounds (`text-muted-foreground/60`) routinely fall below
  4.5:1. Check contrast for the alpha variants, not just the base token.
- Typography in `rem`, root font-size untouched, and no `user-scalable=no` in
  the viewport meta.

## 6. Verifying before you call it done

An audit that only reads code misses half the failures.

1. **Tab through the page.** Every stop shows a visible ring, in a sensible
   order, and nothing traps you.
2. **Operate it with the keyboard only.** Mouse-only paths are the #1 finding.
3. **Read it with a screen reader** (or VoiceOver/NVDA). Check that each
   control announces a name, a role, a state, and a position.
4. **Run an automated checker** (axe DevTools, Lighthouse) for the mechanical
   issues: names, contrast, duplicate ids, landmark structure.
5. **Run the project lint and typecheck** — a `shadcn/no-restyle` error on an
   `aria-*` attribute means the primitive does not accept it there.

## 7. Reporting findings

When you review or audit, report each finding as:

- **file:line**
- what is wrong
- who it hurts (screen reader, keyboard only, low vision, motor)
- the minimal concrete fix, as a snippet

Rank by user impact, not by how easy the fix is. And separate what the
framework already handles from what the application layer is responsible for —
a list of "you forgot ARIA" on a component that Base UI already makes correct
is noise, and it buries the real bugs.
