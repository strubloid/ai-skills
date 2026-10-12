---
name: modify-in-place
description: Use whenever you are about to change a file that already exists, for any reason. Default behavior is to add to or modify the existing structure in place — keep the names, locations, ordering, and surrounding code of what's already there. Triggered by any modification task ("fix", "refactor", "apply the standards", "make this nicer", "organize this", "clean up", "use the new standards", "rename", "restructure", "extract", "split", "move", "reorder", "migrate"), and especially when the user is frustrated about previous unnecessary churn. Do NOT use when the user explicitly asks for a fresh rewrite, a new component from scratch, or a "from scratch" / "redo" / "replace this whole thing" instruction.
---

# Extend in place — don't restructure

The default move when the user asks you to change anything in an existing file
is **change only what they asked for**. Keep the rest of the file exactly as it
was: same variable names, same module-scope / function-scope placement, same
ordering, same surrounding code.

Restructuring turns a one-line ask into a 50-line diff. The user then has to
review and revert the structure just to keep the original shape, while still
accepting the new fields. They asked for one change; they got a rewrite.

This skill is the default for *every* modification task — data adds, mock
updates, component refactors, "apply the new standards", "make this nicer",
"organize this". Not just data files.

---

## The decision in one sentence

If you are about to touch a line that the user didn't ask you to touch — stop.
Either revert that change, or check with the user first.

---

## When to apply

Any time the user asks you to modify a file that already exists:

- Mock / fixture / seed data
- Config objects (`opencode.json`, app config, route tables)
- Components, hooks, pages, services, utilities
- Type / interface declarations
- Lookup tables, enums-as-objects, label maps
- Test fixtures
- i18n / translation tables
- Tailwind / CSS token tables
- API endpoint maps
- Permission / role tables
- Storybook stories

This applies even when the ask *sounds* like a refactor: "apply the new
standards", "make this nicer", "organize the code", "use shadcn only",
"remove the duplicate". The user's intent in those asks is to *improve*, not to
*restructure*. An improvement that keeps the shape is almost always preferred
over an improvement that reshapes.

---

## Default behavior

Add the new piece, fix the bug, or apply the new pattern **without changing
the names, locations, ordering, or surrounding structure** of what was already
there.

```ts
// EXISTING
export const mockOrdersList: Order[] = [
  {
    id: 29575799,
    order: {
      id: 329310,
      orderNumber: "ORD-001",
      // ...
    },
  },
  // ...
];

// USER ASKS: "include priority on the order"

// WRONG — restructure
const sharedOrder329310: OrderData = { id: 329310, /* ... */ };
const buildItems = (qty: number, unitPrice: number) => [/* ... */ ];
const order329311: OrderData = { id: 329311, /* ... */ };
export const mockOrdersList: Order[] = [
  { id: 29575799, order: sharedOrder329310 },
  // ...
];

// RIGHT — add the field to every literal that needs it
export const mockOrdersList: Order[] = [
  {
    id: 29575799,
    order: {
      id: 329310,
      orderNumber: "ORD-001",
      // ...
      priority: "Standard",
    },
  },
  // ...same addition on the other 3 entries
];
```

---

## What "extend in place" looks like for each kind of change

### Adding a field to every record

Edit each record. If there are 4 records and the field goes on every one,
edit 4 times. The shape is repeated on purpose; that repetition is the file's
intent.

### Adding a new record to a list

Append the new entry at the end (or insert it where the user implied). Don't
reorder, don't re-number, don't consolidate.

### Adding a config option

Update the existing object in place with the new key. Don't migrate the
config to a new shape (e.g. `flat: true` → `nested: { flat: true }`) unless
the user asked.

### Applying a "new standard" or refactor rule

The smallest possible change that makes the file compliant. If the rule says
"helper used by one consumer should be inside the component" and there's only
one helper used by one consumer, move just that one helper — don't reorder the
file, don't rename siblings, don't extract more helpers, don't inline
siblings. The user will tell you if they want more.

### Fixing a layout / spacing / styling issue

Adjust the specific class or wrapper that causes the problem. Don't rewrite the
surrounding markup, don't reorder siblings, don't rename props.

### Replacing a deprecated API call with its modern equivalent

Change the call site. Don't rename variables, don't restructure the function
that calls it, don't reorder the file.

### Adding a new action / option to an existing dropdown / menu

Append the new item next to its peers. Don't reorder the items, don't
re-group them, don't rename the trigger button, don't add unrelated actions.

---

## What "don't restructure" means in practice

These are moves that look helpful and almost always aren't. Each one will be
wrong on most modification tasks:

| Move                                                                 | Why it's wrong                                                                 |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Extract repeated literals into a `const`                              | The repetition was already there. Extracting it is a separate refactor.        |
| Build a helper that generates the new piece                           | Helpers are for code that runs more than once. A literal that appears once is fine. |
| Reorder / re-group / alphabetize                                      | The original order encodes history. Don't lose it.                              |
| Rename existing keys / fields / variables / functions                 | The change is additive. Renames break call sites, tests, mental model.          |
| Replace `any` / optional fields with stricter types                   | That's a typing pass, not a modification task.                                  |
| Fold two similar entries into one                                     | They were two entries for a reason. The user can dedupe later.                 |
| Migrate the file to a "better" structure                              | Different file. Different PR. Different ask.                                    |
| Move the new piece above older siblings                              | Insertion order in a literal usually matters. Keep it where the user implied. |
| Comment every addition with `// added for X`                          | The addition is obvious from the diff. Don't leave a tombstone.                |
| Switch from `useMemo` to module-scope const because "it's static"     | Renames and moves the value. Keep the original name and location.               |
| Inline a one-line helper just to "save a name"                        | The helper was already there. Don't replace a name with no name.               |
| Switch from `useCallback` to inline arrow "because the child isn't memoized" | The callback existed. Keep it.                                             |
| Move a constant from module scope to inside the component as a "standards improvement" | That's a structural change. The constant was there before.                |
| Reorder a property block                              | Insertion order in a literal usually matters. Keep it where the user implied. |

---

## When restructuring *is* the right move

The user is asking you to modify something — so don't. Restructure only when:

- The user explicitly asks for a refactor ("extract this", "dedupe", "I keep
  typing the same thing").
- The literal is repeated 5+ times AND the user is adding more on top — at
  that point the duplication is the actual blocker. Ask first.
- The data is broken (invalid JSON, type errors that block compilation,
  references to a removed API). Fixing breakage is not "restructuring," it's
  keeping the file working.

If you're tempted to restructure because "it would be cleaner," do the
minimal modification first, stop, and ask. The user can ask for the cleanup
as a separate step.

---

## Why this skill exists — the failure modes

Two recurring failures that this skill exists to prevent:

1. **Data churn.** "Add `priority` to the order mock" became
   "extract every duplicate order into a shared constant, build items
   with a helper, deduplicate." The user wanted three new keys on three
   records.

2. **Refactor churn.** "Apply the new standards to the page" became "move
   every helper inside, inline two helpers, rename `mapPoints` to
   `MAP_POINTS` and move it module-scope, drop `useMemo`, drop
   `useCallback`, drop the comment." The user wanted the smallest possible
   change toward the standards.

Both times the right answer was: change only what was asked. Everything else
stays.

---

## Quick checklist before you edit

1. Is the task "modify X"? If yes, only modify X.
2. Will my edit touch lines that don't need to change? If yes, stop.
3. Am I introducing a new `const` / `function` / `type` / `import` that
   wasn't in the original file at this spot? If yes, take it back unless it's
   strictly needed for the change.
4. Am I renaming anything that the user didn't ask me to rename? If yes,
   take it back.
5. Will the diff show only what was asked, or also reformatting? Aim for the
   former.
6. If I think restructuring is genuinely needed, am I sure the user meant it?
   If unsure, ask.

---

## Pair with

- `comment-why-not-what` — when you do have to comment on the addition, default to silence.
- `modern-idiomatic-code` — for the *target* code shape you should be aiming
  at when applying them in place. Don't replace this skill; this skill is
  *how* you apply those standards, not *which* standards.
- `component-scoped-variables` — when the change genuinely requires moving a value
  inside a component, that is one allowed modification. But do it for the one
  value the user asked about, not for every value in the file.
- `senior-frontend-patterns` — same: target shape, but apply it in place.