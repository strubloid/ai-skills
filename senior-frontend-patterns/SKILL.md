---
name: senior-frontend-patterns
description: Use for any frontend task — components, pages, hooks, JSX, styling. Enforces the rules a senior frontend engineer writes by default so the output does not read like machine-generated boilerplate. Covers co-location of component-scoped code, no useEffect for derived state, no React.FC, semantic HTML, no premature memoization, no premature data structures, and the other patterns that separate a hand-written component from a generated one.
---

# Senior frontend rules

Write frontend code the way a senior engineer writes it. Not the way a code generator writes it. Every rule below exists because the opposite pattern shows up constantly in AI-generated code and reads as "intern wrote this."

If a rule and the existing project skills (`component-scoped-variables`, `prefer-shadcn-elements`, `shadcn-registry-conventions`, `tailwind-canonical-utilities`, `comment-why-not-what`, `agnostic-registry-components`) overlap, the more specific skill wins. In particular:

- For components shipped from a shadcn-style registry (`registry/<x>/*`), `agnostic-registry-components` wins on naming, CSS tokens, and default values. The components must read as project-agnostic primitives, not as a fork of one consumer's domain.

## 1. Component-scoped code lives inside the component

If a value (constant, helper function, lookup map, formatter, type guard) is used by exactly one component, declare it inside that component. The full rule lives in the `component-scoped-variables` skill. The headline: a reader should see the variable and the JSX that consumes it on the same screen.

Module scope is for things shared by multiple files. Not for things that *could* be.

## 2. No new file for a single consumer

A `ItemCard.tsx` in its own file when only one parent uses it is a smell. It pretends to be reusable. It is not. If only one file uses a component, put it in the same file as its only consumer. The rule is the variable rule from §1 applied one level up: a fresh file is only justified when a component is consumed by 2+ places.

```tsx
// BAD — fourteen single-consumer files for one screen
article/
├── index.ts
├── article.tsx
├── author-card.tsx
├── category-card.tsx
├── tags-card.tsx
├── meta-row.tsx
├── body-section.tsx
├── paragraph-row.tsx
├── expand-button.tsx
├── sidebar-section.tsx
├── comments-table.tsx
├── footer-section.tsx
└── tabs-row.tsx

// GOOD — six files, sub-components co-located with their only consumer
article/
├── index.ts
├── article.tsx
├── body-section.tsx          // also holds ParagraphRow, ExpandButton, SidebarSection, CommentsTable
├── info-cards.tsx            // also holds AuthorCard, CategoryCard, TagsCard
├── footer-section.tsx
└── form-field.tsx            // also holds FormSelect
```

A sub-component co-located with its only consumer is named by its parent: `function ParagraphRow({ ... }: Props) { ... }` at the bottom of `body-section.tsx`. The parent file is the natural home — the reader sees the type, the data, and the child definition in one scroll.

Carve-outs:
- The component is large enough that the parent file becomes unreadable. At that point, extract.
- The component is conceptually independent (a `<Table>`, a `<Button>`, a hook) and a second consumer is reasonably anticipated but not yet wired. Don't pre-extract — that's the same premature-abstraction trap as §1. Wait for the second consumer.
- The file is the public API of a shadcn-style registry. Different rule — see `agnostic-registry-components`.

If a future change adds a second consumer, *then* extract. Not before.

## 3. No helper functions outside a component for a single consumer

A `function isShadcnVariant(...)` sitting between the imports and the component is a smell. It pretends to be reusable. It is not. If only one component uses it, put it inside.

```tsx
// BAD — module-scope helper for one consumer
function isShadcnVariant(variant: StatusVariant): variant is ShadcnVariant {
  return !STATUS_INTENT_SET.has(variant);
}

export function StatusBadge({ variant }: Props) {
  const baseVariant = isShadcnVariant(variant) ? variant : "destructive";
}
```

```tsx
// GOOD — inlined, no helper, no Set, no module-scope noise
export function StatusBadge({ variant }: Props) {
  const isIntent =
    variant === "success" ||
    variant === "warning" ||
    variant === "error" ||
    variant === "info";
  const baseVariant = isIntent ? "destructive" : variant;
}
```

If the check is genuinely useful elsewhere, extract it then — not before.

## 4. No premature data structures

For a known finite set of 2–6 string literals, do not reach for `Set`, `Map`, or a generated object. An `as const` tuple, `Array.includes`, or direct `===` reads better and is fast enough. `Set.has` is O(1) but the constant factor only pays off past ~50 entries; below that you are paying for clarity.

```tsx
// BAD — Set of three values built once at module load just to do includes
const STATUS_INTENT_SET = new Set<StatusVariant>([
  "success",
  "warning",
  "error",
  "info",
]);

// GOOD — array literal of literals, no Set, no module-scope constant
const STATUS_INTENTS = ["success", "warning", "error", "info"] as const;
type StatusIntent = (typeof STATUS_INTENTS)[number];

// inside the component:
const isIntent = (STATUS_INTENTS as readonly string[]).includes(variant);
```

If the set is shared across files, define the `as const` tuple in the shared module and derive the type from it. Do not hand-maintain a parallel `type` and a parallel `Set`.

## 5. Derive, do not store

If a value can be computed from props or existing state during render, compute it. Do not `useState` it and `useEffect` it into sync.

```tsx
// BAD — derived state stored in useState
const [fullName, setFullName] = useState("");
useEffect(() => setFullName(`${firstName} ${lastName}`), [firstName, lastName]);

// GOOD — derived inline
const fullName = `${firstName} ${lastName}`;
```

If the derivation is expensive, take the rest of the rule on memoization (rule 11). Never `useEffect` to set state from other state.

## 6. No `useEffect` for events

If the work is "respond to user action," put it in the handler. If it is "respond to data changing," consider whether it should be derived first (rule 5). `useEffect` is for syncing with an *outside* system: subscriptions, timers, focus, imperative DOM, network on mount. Not for chaining state, not for "do X when prop Y changes" if you can just compute it.

## 7. No `React.FC`

Write components as plain functions with explicit prop types.

```tsx
// BAD
export const StatusBadge: React.FC<Props> = ({ variant, children }) => { ... }

// GOOD
export function StatusBadge({ variant, children }: Props) { ... }
```

`React.FC` (a) drops the generic when you need one, (b) silently injects `children` into the props (footgun for components that should not accept children), and (c) is a deprecated convention.

## 8. Named exports only for components

No `export default` for a component unless the file is being lazy-loaded and you have a reason. Named exports give you better error messages, better renames, and prevent the "two unnamed components accidentally swapped" bug.

```tsx
// BAD
export default function MyComponent() { ... }

// GOOD
export function MyComponent() { ... }
```

## 9. Single JSX root, no decorative wrappers

A component returns one tree. Do not wrap it in a `<div>` "just in case." If the parent needs a wrapper, the parent wraps. Decorative wrappers break grid/flex layouts, ruin accessibility landmarks, and add DOM weight you cannot measure.

```tsx
// BAD
return (
  <div>
    <span>{label}</span>
    <Badge>{count}</Badge>
  </div>
);

// GOOD — return what you need, nothing extra
return (
  <>
    <span>{label}</span>
    <Badge>{count}</Badge>
  </>
);
```

Fragments are fine. Empty wrapper `<div>`s are not.

## 10. Semantic HTML before ARIA

`<button>` not `<div onClick>`. `<a href>` not `<span onClick>`. `<nav>`, `<main>`, `<header>`, `<footer>` before `aria-*.` Semantic elements come with keyboard handling, screen reader semantics, and focus management for free. ARIA is for the gaps semantic HTML cannot cover.

If the project enforces `prefer-shadcn-elements`, defer to that skill first.

## 11. No premature memoization

Do not add `useMemo`, `useCallback`, or `React.memo` "in case." Add them when profiling shows a problem. With the React Compiler (default in modern setups) most manual memoization is redundant or harmful.

The exceptions are real:
- A value passed to a `React.memo`-wrapped child that does referential equality.
- A referentially stable identity required by a hook dep array (rare).
- A genuinely expensive computation over a large dataset, measured.

If you do memoize because of a memoized child, memoize the *whole* chain (the function with `useCallback`, the object with `useMemo`). Half-memoization is worse than no memoization.

## 12. Inline literals are fine — except when they aren't

A fresh array, object, or function literal in JSX props is only a problem when the consumer is `React.memo`-wrapped. Otherwise it is invisible noise to optimize. Do not pre-emptively write `useCallback` "to be safe." That is the same trap as rule 11.

```tsx
// Fine — child is not memoized, identity churn is invisible
<Table rows={items.map(transformItem)} />

// Bad — child is memoized, fresh array breaks it
<MemoizedTable rows={items.map(transformItem)} />
```

## 13. Stable keys, never the array index

Use a stable, content-derived key. Never `index`, never `Math.random()`. For lists the user can mutate, index-as-key causes silent state-preservation bugs (the wrong row keeps its edited input across a delete-and-reinsert).

```tsx
// BAD
{items.map((item, i) => <Row key={i} item={item} />)}

// GOOD
{items.map((item) => <Row key={item.id} item={item} />)}
```

## 14. Handle loading, error, and empty explicitly

Every screen backed by data renders three states: loading, error, empty. A spinner alone is not an error state. A blank table is not a "no data" state. If a component renders data, every branch has a UI, and the UI is intentional.

## 15. Business logic out of components

Components render. They do not fetch, validate, transform, or decide. Extract fetching to hooks/services, validation to schemas, transformations to pure functions. A component should read top-to-bottom as: receive props, derive render values, return JSX.

```tsx
// BAD — component does the fetching
function StatusBadge({ userId }) {
  const [user, setUser] = useState(null);
  useEffect(() => { fetch(`/api/users/${userId}`).then(r => setUser(r.json())) }, [userId]);
  ...
}

// GOOD — hook does the fetching
function StatusBadge({ user }: { user: User }) {
  return <Badge>{user.status}</Badge>
}
```

## 16. Strict TypeScript

`strict: true`. No `any`. No `as` to silence an error unless you have left a one-line comment explaining why. No `enum` (use `as const` tuples). No `// @ts-ignore`. Prefer discriminated unions for state.

```tsx
// BAD
const status: any = getStatus();

// GOOD
const status = getStatus();
if (status.kind === "error") { ... }  // narrows via discriminated union
```

## 17. No mutating props, state, or refs' `.current`

Props are read-only. State is replaced, not mutated. `ref.current` is the only place mutation is acceptable, and even there it does not trigger a re-render. `array.push`, `state.foo = x`, `props.onChange(items)` — all forbidden. Always return a new reference.

## 18. Co-locate, do not type-sort

A component, its types, its hook, its test, and its styles live in the same folder. `components/Button/Button.tsx`, `Button.test.tsx`, `Button.types.ts`, `Button.module.css`. Not `components/buttons/Button.tsx` plus `hooks/useButton.ts` plus `types/button.ts` in three different trees. Co-location makes deleting a feature a single folder delete.

## 19. Controlled vs uncontrolled — be deliberate

If a component owns no state of its own, it is uncontrolled; the consumer owns the value. If it owns the value, it is controlled and takes `value` + `onChange`. Mixed modes (`defaultValue` with a state-driven reset) need explicit comments explaining the intent. Default to uncontrolled for primitives, controlled for composed components that need to coordinate state.

## 20. Accessibility is not a checklist at the end

Every interactive element gets keyboard handling, focus management, and an accessible name as part of writing it — not as a follow-up. Every image gets alt text (or `alt=""` if decorative). Every form input gets a label. Every color contrast meets WCAG AA. If you can navigate it with a mouse but not a keyboard, it is broken.

## 21. Composable APIs over prop-driven forks

A `<Button variant="primary" size="lg" icon="check" loading>` is a fork bomb. Prefer small composed primitives:

```tsx
// BAD — every new use case is a new prop
<Button variant="primary" size="lg" icon="check" loading />

// GOOD — composition handles the use case
<Button size="lg">
  <CheckIcon /> Confirm
</Button>
```

If a prop exists because two distinct UI states need genuinely distinct rendering, the prop is fine. If a prop exists "just in case someone needs it," delete it.

## 22. Bake repeated configuration into the component

If a layout class, default variant, or stylistic prop is repeated at every call site of a component, it is not the caller's choice — it is the component's own default. Move it inside.

A consumer of `<ItemCard />` should not have to know that the row uses a 6-column grid and the card takes one column of it. That knowledge belongs inside `ItemCard`. A second consumer — a different row, a different grid — should work without re-supplying the layout.

```tsx
// BAD — every caller restates the layout contract
<section className="grid grid-cols-6">
  <AuthorCard className="lg:col-span-1" ... />
  <CategoryCard className="lg:col-span-1" ... />
  <TagsCard className="lg:col-span-2" ... />
  <AttachmentsCard className="lg:col-span-2" ... />
</section>

// GOOD — each card knows its own footprint in the row
<section className="grid grid-cols-6">
  <AuthorCard ... />          // internally: "lg:col-span-1"
  <CategoryCard ... />        // internally: "lg:col-span-1"
  <TagsCard ... />            // internally: "lg:col-span-2"
  <AttachmentsCard ... />     // internally: "lg:col-span-2"
</section>
```

The `className` prop stays for the uncommon override. Reuse without re-supplying.

The heuristic: if you copy-paste the same `className` (or variant, or prop value) onto every call site, you have already proved the configuration is intrinsic. Move it once.

## 23. The shape of a finished component

A component file, when finished, looks like:

1. Imports.
2. *Maybe* an exported type/interface used by other files.
3. The component function.
4. Inside the component: prop destructuring, derived values, helpers, JSX return.
5. Nothing else. No module-scope constants for one consumer. No helper functions for one consumer. No "in case" comments. No single-consumer sub-components extracted to their own file (rule 2).

If a finished component file is longer than the screen can hold, it is doing too much. Split it — but split by *feature*, not by *type*.