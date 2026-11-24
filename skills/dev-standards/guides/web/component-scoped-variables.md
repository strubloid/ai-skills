---
name: component-scoped-variables
description: Use when writing or reviewing React components, or scaffolding new ones. Enforces declaring component-scoped variables (column configs, lookup maps, option lists, formatter objects, render helpers) inside the component function body, not at module scope above it. Triggered by "move inside", "co-locate with the component", "why is this outside the component", "split this into a file", or when adding a new component that only one consumer will use.
---

# Component variables live inside the component

If a variable is used by exactly one component, declare it inside that component's function body. Do not hoist it to module scope just because it looks static. The same rule, applied one level up: a component used by exactly one other component lives in the same file as that consumer — not in its own file. See §"Single file for a single consumer" below.

## Why

- **Locality**: a reader sees the variable and the JSX that uses it on the same screen. Less scrolling, less hunting.
- **Refactorability**: deleting or renaming the component deletes or renames its config in the same keystroke. Module-level constants survive component deletions and silently rot. Same for orphan single-consumer files: deleting the consumer should delete the component, and a co-located file does.
- **Honesty about scope**: module-level constants look reusable. They get copied into a second component, then drift. Co-locating makes the actual scope obvious.

## Rule

Inside the component unless one of the carve-outs below applies.

```tsx
function StatusTable({ rows }: Props) {
  const columns: Column<Row>[] = [
    { key: "name", label: "Name" },
    {
      key: "status",
      label: "Status",
      render: (r) => <Badge>{r.status}</Badge>,
    },
  ];

  return <Table columns={columns} rows={rows} />;
}
```

Not this:

```tsx
const COLUMNS: Column<Row>[] = [
  { key: "name", label: "Name" },
  {
    key: "status",
    label: "Status",
    render: (r) => <Badge>{r.status}</Badge>,
  },
];

function StatusTable({ rows }: Props) {
  return <Table columns={COLUMNS} rows={rows} />;
}
```

## When to break the rule

- The value is shared by more than one component in the module.
- The value is `export`-ed and consumed by another file.
- The component renders hot enough that recreating the object every render is a measured problem, and profiling says it matters. In that case hoist *and* leave a one-line `//` comment with the reason (per the project's comment rules).
- The value is a stable identity for a hook's dep array where React requires referential stability (rare, profile first).

Default to inside. Reach for the carve-outs only when there's a real reason.

## Folder location when the value escapes the file (2026 colocation)

When a value needs to be a real cross-file helper, the location is determined
by **how many places consume it**, not by what it is. This is the 2026
"feature-based with colocation" rule (Robin Wieruch, Kasun Nadeera 2026
guide, Lars Waechter, React docs "Colocation" section).

| Consumer count | Location | Reasoning |
|---|---|---|
| 1 (single page / feature) | Co-locate with the consumer (same folder, or inside the file) | Don't promote to shared until a 2nd consumer appears |
| 2-3 within one feature | Co-locate with the feature (e.g. `pages/app/nav-items.ts` if both consumers are in `pages/app/`) | The data is "feature-local", not "app-wide" |
| 2+ across features, app-wide, or a shadcn-registry helper | `@/lib/helpers/` | True cross-cutting reusable code |
| API / external integration | `@/services/` | Not for static data — only for things that talk to a backend, a 3rd party, or an external system |
| Custom hook (1+ consumer) | `@/hooks/` | Hooks are reusable by convention even with one consumer |
| Domain types | `@/types/` | One source of truth per entity, shared across pages and services |

Examples that get this right and wrong:

- A navigation list used only by one feature → **wrong** in a global library
  folder; co-locate it with that feature.
- A typed environment accessor used across features → **right** in a shared
  library location; it is genuinely cross-cutting.
- A pure formatter imported by multiple tables, charts, and detail views →
  **right** in shared helpers; it has no feature-specific coupling.
- A static array placed in a service module → **wrong**; services should own
  actual I/O or integration behavior. Co-locate the data with its consumer.

When a project consumes helpers from a component registry, follow its
documented source-of-truth and update path. Do not create a second divergent
copy of a registry helper in an application-wide folder.

## Single file for a single consumer

The variable rule extends to files. A component used by exactly one other component lives in the same file as that consumer — not in its own file. Extract to a new file when 2+ places consume it, not before.

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

The carve-outs match the variable rule:
- A second consumer exists or is genuinely anticipated by a separate feature path. Wait for the second consumer; do not pre-extract.
- The component is conceptually independent (a `<Table>`, a `<Button>`, a hook) and a second consumer is reasonably anticipated but not yet wired. Same — don't pre-extract.
- The file is the public API of a shadcn-style registry. Different rule — see `agnostic-registry-components`.
- The parent file has grown unreadable. At that point, split by *feature* (one feature per file), not by *type* (one component per file).

If a future change adds a second consumer, *then* extract. Not before.

## Don't extract a custom hook for one or two call sites

The same rule applies one level up. A `useFooResource` hook that is consumed by exactly one page is a smell. It pretends to be reusable. It is not. The hook file is one more thing to navigate, one more place to keep in sync, and the page that uses it still has to know what the hook does — you have not actually simplified anything.

The same is true for a hook consumed by two pages when the pages differ in non-trivial ways (different data shapes, different error semantics). Two call sites are a *signal* that the abstraction might be worth it, not proof.

Default: inline the data-fetching / state-machine logic in the page. Extract a custom hook when one of the following is true:

- There are three or more call sites with the same shape.
- The hook encodes a self-contained concept (e.g., a server-state primitive) that has a clear API and tests.
- The team has decided to use a data-fetching library for the project, and the hook is the project's primitive for it.

If the abstraction is wrong, deleting the hook file is one delete — and the inlined copies are easier to evolve independently than two consumers locked into a shared hook.

The same rule applies to extract `useFooStore` / `useFooMachine` style hooks when they have one consumer. A component-scoped reducer (`useReducer` inside the page) is usually the right primitive for a single page with a non-trivial state machine.
