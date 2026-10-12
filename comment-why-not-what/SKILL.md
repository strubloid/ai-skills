---
name: comment-why-not-what
description: Use when writing, reviewing, or rewriting comments anywhere in code (inline `//`, JSX `{/* */}`, JSDoc, file headers, section dividers, TODOs). Teaches when to add a comment, when to skip, and how to write comments that read like a human wrote them — conversational, short, "why not what".
---

# Comments that read like a human wrote them

A comment earns its line by answering one question: **why is this here?**

If the code already says what it does, the comment is dead weight. Silence is fine. But some places genuinely benefit from a short note — the trick is knowing which ones.

This skill is the canonical comment rule for the project.

---

## The decision in one sentence

Default to no comment. Add a comment only when it teaches something the reader **cannot get from the code in under five seconds**.

That's it. Everything else is judgment.

---

## When to add a comment

Add a comment when one of these is true:

| Situation | Example |
|---|---|
| Non-obvious *why* — code that looks wrong on purpose | A `useEffect` with empty deps that's correct because of a closure, a `=== false` that's intentional, an `as` cast with a one-line reason |
| A workaround for a library / browser / framework quirk | "Radix portals outside the DOM tree — focus trap requires manual restore" |
| A magic number with domain meaning | `// 1024 = 1 KiB in pixels for our 16px base grid` |
| A fragile assumption the next reader will hit | "Sort order matters: binary search assumes ascending" |
| A library version constraint | "Pinned to v2.3.1 — v2.4.0 broke the `onSuccess` shape" |
| A pattern used on purpose to avoid a bigger problem | "Inline className avoids pulling a CSS module into the bundle" |
| Intent at a dead point — the comment explains a non-code intent | "Render Skeleton on first paint to avoid layout shift" |
| A cross-reference to a ticket, RFC, or external doc | "See SPEC-42 for the rate-limit algorithm" |

If none of these apply, leave the line alone.

---

## When NOT to add a comment

- The next line says exactly the same thing.
  - `// increment counter` above `i++` — skip.
  - `{/* the menu */}` above `<AppHeaderMenu />` — skip.
  - `// Returns null when no rows match` above a guard that returns `null` — skip.
- The variable / component / prop name already says it.
  - `const isLoading = useState(false)` — `// loading flag` is noise.
- It's a section header for code that doesn't need one.
  - `// ===== Validation =====` above four obvious lines. Either refactor to a `validate()` function or skip.
- It's documentation that belongs in a README or a JSDoc, not in the body.
- It's a JSDoc that restates the signature.
  - `/** @param id the user id */ function getUser(id: string)` — the signature already says `id: string`.
- It's an explanation of how to use a public API to a future consumer. That's a README, not an inline comment.
- It's a label that survives only because deleting it would force the author to admit the block is dead code.

---

## Comment flavors — where each belongs

Different surfaces have different costs. Pick the cheapest comment that carries the message.

### Inline `//` (above a line)

The default. Cheap, scoped to the line below, easy to delete. Use for almost every "why" note.

```ts
// Mapbox tile quota resets at UTC midnight — keep the cache warm across that boundary
const TTL_MS = 24 * 60 * 60 * 1000;
```

### Inline `//` (trailing, on the same line)

Use sparingly. Reads as a footnote; competes with the code on the line. Acceptable only when the why is genuinely short:

```ts
const DEBOUNCE_MS = 120; // 100ms hover + 20ms slack for slow renderers
```

If the trailing note is more than ~50 chars, move it above the line.

### Block `/* ... */`

For a 2–3 line explanation that needs structure (a sequence of conditions, or a small recipe). Don't use it for a paragraph.

```ts
/*
 * Two render passes are needed because the first pass measures
 * the row widths and the second positions the sticky header to
 * match. Don't try to combine them — the layout loop hangs.
 */
```

### JSX `{/* ... */}` inside a JSX block

For a "why note" attached to a specific element. Keep it close to the element. **Don't** use it as a section header between every JSX node — that's the function-of-nearest-component smell.

Use `{/* ... */}` only when:
- The intent of the element is not its name.
- A non-obvious condition or workaround is sitting on the element.

```tsx
{/* Hidden on lg+ — the always-visible desktop sidebar replaces this trigger */}
<SidebarTrigger className="lg:hidden" aria-label="Toggle sidebar" />

{/* open=true is required even when items=[] so the empty-state copy renders */}
<Dialog open>
```

Do **not** use JSX comments like `{/* the logo */}`, `{/* the menu */}`, `{/* right side */}` above self-describing components. If the components need labels, the components are named wrong; if the code is self-describing, the comment is dead weight.

### JavaScript comment *around* JSX (cleaner than `{/* ... */}`)

`{/* ... */}` is verbose. A plain `//` or `/* */` just before a JSX block reads better:

```tsx
return (
  // The trigger is the trigger itself because click target.
  // Hide on lg+ — the always-visible desktop sidebar replaces it.
  <SidebarTrigger className="lg:hidden" aria-label="Toggle sidebar" />
);
```

Use this form when the comment describes the *whole* element below it. Use `{/* ... */}` only when the comment is between sibling JSX nodes.

### JSDoc / TSDoc on exported APIs

For the public surface — exported components, exported hooks, exported utility functions. Document the *contract*, not the body.
- What does it do.
- What does it accept (especially when names are non-obvious).
- What does it return (especially when the shape isn't obvious from the signature).
- When will it throw / fail / behave non-obviously.

```ts
/**
 * Renders the orders list and a synchronized preview panel.
 *
 * Selection is shared across the table and the panel: clicking a row
 * highlights the matching item, clicking an item selects the row.
 */
export function OrdersPage() { ... }
```

Do not write JSDoc that restates the signature. Do not write JSDoc on internal helpers.

### File headers

Rarely useful. Skip unless the file has a *concrete* reason to be loaded with context — a generated file, a vendored patch, a port from another codebase.

```ts
// Vendored from @acme/ui@2.3.1. Edit at your own risk; upstream
// changes will clobber local edits. See README for the upgrade path.
```

A "this file does X" file header is almost always the README's job, not the file's.

### Section dividers

```
// =============================================
// Validation
// =============================================
```

Skip. If a section is large enough to need a divider, the file is doing too much. Split it. If a file is small enough that a divider fits on one screen, the divider is decoration.

### `// TODO`, `// FIXME`, `// XXX`

Use the right one:
- `TODO` — known follow-up, not blocking.
- `FIXME` — known bug, blocking or near-blocking.
- `XXX` — a real warning to future readers about something dangerous.

Keep them tight. Always include a ticket / reason when there is one. Remove when done — TODO comments older than the file's lifetime are noise.

---

## Voice rules ("human kind")

Write the comment the way you'd say it out loud reviewing the change. Not as a doc block, not as a textbook entry.

- **One line beats three.** If you can't say it in one line, you've written documentation, not a comment.
- **Conversational.** Use contractions. Use "because," not "because". Skip "Note that", "Edge case:", "Important:".
- **Direct.** Name the gotcha. Don't lead with the library. Don't end with "in that case".
- **No headings.** No markdown lists inside a code comment. No bold titles.
- **No em-dash padding.** Em-dashes are fine once. Three in one comment is a tell.
- **No library 101.** The reader knows the library. If a library quirk is non-obvious, name it in one phrase.
- **Match the file's voice.** A React component file reads differently from a Rust crate. Match the surrounding comments.

### Sample good / bad pairs

```ts
// BAD — restating the code
if (!user) return null;

// GOOD — the why (or skip the comment entirely if obvious)

// BAD — library 101
// React's useState hook returns a tuple of the current value and a setter function
const [count, setCount] = useState(0);

// GOOD
// held in a ref so toggling doesn't re-render the table
const expanded = useRef(false);

// BAD — section header
// =========================
// Rendering
// =========================

// GOOD — split the file, drop the divider

// BAD — formal tone
// Note that in the case where the user is not authenticated,
// we must redirect to the login page.

// GOOD
// not logged in → bounce to login
```

---

## AI tells to drop

If you wrote the comment, you wrote a tell. Drop it.

- `Returns null when …` / `Skips the case where …` — restating behavior.
- `Edge case:` / `Note that:` / `Important:` — formal section labels.
- `This is necessary because the library …` — library 101.
- "In that case" stacked on top of "the consumer considers" stacked on top of "this is needed because".
- Multi-line paragraphs above a single guard clause.
- JSDoc with `@param id the user table` (the signature already says `id: string`).
- Comments that begin with "This function" or "This component" — describe what it *does for the caller*, not what it *is*.
- Generic AI encouragement: "Great question!", "Let me explain how this works".

---

## Grouping

Three comments in a row usually want one comment at the top of the block.

```ts
// Radix portals close on Escape, focus the previous trigger,
// and trap focus inside. We rebuild that by hand because the
// tooltip is rendered outside a Dialog.
```

vs three separate comments on three lines that say the same thing in three different ways.

---

## When you're unsure

Ask three questions:

1. **Does the code already say it?** If yes, skip.
2. **Does the reader need this in under five seconds?** If no, skip.
3. **Could I rename a variable / extract a function instead of adding a comment?** Often yes — that's almost always better than the comment.

If the answer to all three is "no, no, no, this comment is the right answer", keep it. Otherwise, delete or refactor.

---

## What this skill is not

- Not a tool for leaving JSDoc on every exported function. JSDoc on a trivial getter is noise.
- Not a license to add section headers, ASCII dividers, or "// ===" banners.
- Not a way to document business rules. Rules live in docs or code.
- Not a substitute for fixing unclear names. `data` is the wrong name; rename it, don't comment it.