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