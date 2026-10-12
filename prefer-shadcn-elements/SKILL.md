---
name: prefer-shadcn-elements
description: Use whenever creating, editing, reviewing, or composing UI components, pages, and frontend features. Enforce the current official shadcn/ui elements as the only UI primitives, while allowing app-level compositions, semantic layout HTML, and the dependencies required by official shadcn components.
---

# Only shadcn elements

Build the UI from the current official shadcn/ui catalog and the target project's
configuration. This is the default for every new or changed component. Do not
invent a second UI system or recreate a primitive that shadcn already provides.

## Live source of truth

Read [`references/live-reference.md`](references/live-reference.md) before
implementing any UI. The links there are intentionally live references, not a
snapshot of the component list.

On every applicable task:

1. Read the nearest `components.json`, the relevant global CSS, `package.json`,
   and existing `components/ui` files.
2. Run the project's package-manager equivalent of `shadcn@latest info --json`
   to learn the framework, aliases, installed components, base library, icon
   library, and resolved paths.
3. Check the current official catalog and component documentation using
   `shadcn@latest docs <component> --json`, `shadcn@latest search @shadcn -q
   "<need>"`, and `shadcn@latest view <item>` when available.
4. Read the live references in `references/live-reference.md`, especially
   `llms.txt`, the components page, CLI docs, and the changelog.

Use `@latest` and the current live source. Do not rely on memory, an old copied
snippet, a pinned old registry, or a component list stored in this skill. If the
live sources are unavailable, say so, use the installed project's source and
configuration as the fallback, and do not claim that the implementation was
verified against the current catalog.

## Strict component policy

- Official shadcn/ui registry items are the only allowed source for UI
  primitives, controls, overlays, navigation, feedback, and recognizable UI
  surfaces.
- Reuse an installed shadcn component before creating anything new. Install a
  missing official item with the current CLI, then adapt it in the application
  layer instead of duplicating it.
- A new application component is normally a composition of existing shadcn
  elements. Keep the composition's product logic in the app; do not turn it
  into a replacement primitive.
- Use semantic HTML and Tailwind utilities for layout, content, and composition
  only. Do not hand-build a button, dialog, dropdown, popover, select, checkbox,
  switch, tabs, tooltip, table behavior, or other control that an official
  shadcn element already provides.
- Do not add an alternate UI component library (for example MUI, Ant Design,
  Chakra, Mantine, or another design system) for a component that can be built
  with shadcn. Official primitive dependencies required by the selected shadcn
  item, the configured icon library, and non-UI application dependencies are
  allowed.
- Do not use a community or private registry item unless the user explicitly
  requests it. Label any explicitly approved exception in the implementation
  summary.
- If no official shadcn element exists, first look for a composition of existing
  official elements. If that cannot satisfy the requirement, stop and explain
  the gap to the user before introducing a custom primitive or another UI
  dependency. Never silently make that exception.

Do not confuse “only shadcn elements” with a ban on HTML. `<div>`, `<section>`,
`<nav>`, headings, lists, and other semantic layout/content elements are fine;
the ban is on replacing the official interactive and UI primitives with
hand-built or third-party equivalents.

## Implementation rules

Follow the target project's existing shadcn configuration rather than assuming
a particular style, base library, framework, or alias:

- Use the aliases and paths from `components.json`.
- Use the project's current `cn` utility and component conventions.
- Accept and forward `className` through `cn(...)` last, forward native props
  and refs, and preserve accessibility attributes.
- Prefer the current official component API and examples over older
  `new-york`, Radix, Base UI, or ARIA examples that do not match the project.
- Use semantic theme tokens and the project's spacing, radius, typography, dark
  mode, RTL, and responsive conventions.
- Keep client/server boundaries and dependencies consistent with the current
  official component documentation.
- Preserve existing user customizations. Use the CLI's dry-run, view, and diff
  commands before overwriting a component, and ask before destructive changes.

Before editing, identify the exact official shadcn element(s) that will be
reused or installed. If the task is not a shadcn-compatible project, ask before
initializing or changing its configuration.

## Required workflow

1. **Inspect** the project configuration, dependencies, theme, aliases, and
   existing UI components.
2. **Discover** current official items and their APIs with the live references
   and CLI commands above.
3. **Choose** existing official items first; compose them instead of recreating
   them.
4. **Install** missing official items with the current shadcn CLI. Do not copy
   stale code from a blog or an old version of the documentation.
5. **Implement** the feature using the project's conventions and semantic
   tokens.
6. **Audit** imports and JSX for alternate UI libraries and hand-rolled
   replacements.
7. **Validate** with the project's formatter, typecheck, lint, tests, and build
   commands that are available.
8. **Report** which official shadcn elements were used, what live sources were
   checked, and any explicitly approved exception.

## Completion checklist

Do not call the task complete until all applicable items are true:

- [ ] The project's `components.json` and aliases were inspected.
- [ ] Current shadcn catalog/docs/CLI sources were checked.
- [ ] Missing UI primitives came from the official shadcn registry.
- [ ] No alternate UI library or hand-rolled replacement was introduced.
- [ ] New components are app-level compositions or approved exceptions.
- [ ] `className`, props, refs, semantic tokens, accessibility, and server/client
  boundaries follow the current project conventions.
- [ ] The diff and validation commands pass.

## Failure handling

If the current shadcn documentation conflicts with the installed project,
follow the installed project configuration for its existing API, use the live
official source for new additions, and call out the mismatch. Do not migrate the
project or rewrite a component just to make it match a newer style without the
user's approval.
