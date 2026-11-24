---
name: enterprise-filtering
description: Use when designing, building, or reviewing any filter UI on an enterprise data table, list page, or analytics view — sidebar, top bar of pills, or inline column filters. Triggers on "filter UX", "filter bar", "filter sidebar", "filter pills", "toggle filters", "show and hide filters", "filter pattern", "make filters like [Tool X]", or when the user attaches a screenshot of an enterprise filter pattern to mimic. Enforces the positioning trade-offs from Pencil & Paper's "Filter UX Design Patterns & Best Practices" so the right shape is picked for the data, and gives concrete recipes for the sidebar pattern we use above our data tables.
---

# Enterprise filtering — positioning patterns

Distilled from Pencil & Paper's "Filter UX Design Patterns & Best Practices"
(March 2026). The article presents three positioning options; this skill
names when to use each, and gives the concrete recipe for the **sidebar
pattern** we use most often above our data tables.

## Pick the positioning by context

| Pattern      | Context level | Scalability | Best when                                                                |
| ------------ | ------------- | ----------- | ------------------------------------------------------------------------ |
| Sidebar     | Low — global    | High        | Many filters, filter values, or sections; page-level scope.              |
| Inline      | High — column  | Low         | Per-component scope; 1–3 critical filters; table is the only consumer.   |
| Top bar     | Hybrid         | Medium      | 3–10 filters, page-level scope, live filtering is fine.                  |

**Don't mix** two of these on the same dataset — the user shouldn't have to
learn two flows for the same page.

Choose the pattern that fits the target page and its existing design system.
The sidebar recipe below is one option for pages with many page-level filters.

## Sidebar pattern

Render filters in a **left-hand collapsible sidebar** that takes part of the
page width when open. Toggled by a `Filters` button in the page header.
Default state: closed (filters hidden until the user asks for them).

### Why sidebar and not top bar

- A page with several filters can grow; a sidebar scales vertically with
  collapsible sections.
- Several filters are multi-select lists with 5–20 values — they need real
  estate a top bar can't spare.
- Sidebar keeps the column header titles as the only header content, so the
  table reads cleanly when filters are off.

### Anatomy

```
+-----------------------------------------------------+
| HEADER: [Count]              [Filters (2)] [Actions]|
+-----------------------------------------------------+
| SIDEBAR                |                            |
| ┌───────────────────┐  |                            |
| │ Filters       [×] │  |                            |
| ├───────────────────┤  |                            |
| │ Name              │  |                            |
| │ [input]           │  |                            |
| │ Category          │  |                            |
| │ [input]           │  |                            |
| │ Status            │  |           TABLE            |
| │ ☐ Active          │  |                            |
| │ ☐ Archived        │  |                            |
| │ Owner             │  |                            |
| │ ☰ Pill (3)     ▾  │  |                            |
| │ Region            │  |                            |
| │ ☰ Pill (2)     ▾  │  |                            |
| │ Type              │  |                            |
| │ ☰ Pill (1)     ▾  │  |                            |
| │ Priority          │  |                            |
| │ ☰ Pill (1)     ▾  │  |                            |
| │                   │  |                            |
| │ [Clear All]       │  |                            |
| └───────────────────┘  |                            |
+-----------------------------------------------------+
```

### Section rules

- **Label**: short, sentence-case (not uppercase). Same font as the rest
  of the sidebar text. The article's "uppercase identifier" rule applies
  to the **top-bar pill**, not the sidebar — sidebars have room for a
  readable label.
- **Active count**: shown next to the label as `Pill (N)` only when > 0.
  One muted line. Don't bold the label — keep type uniform.
- **Inputs**: directly visible inside the section. No popovers inside a
  sidebar section; the whole point of a sidebar is that everything is
  visible at once.
- **Multi-select lists**: a vertical list of checkbox rows. Add a search
  input at the top of the section once the list exceeds ~8 entries.
- **Clear**: a single "Clear All" button at the bottom of the sidebar.
  Always visible (greyed out when no filter is active is fine).

### Toggle button

- Sits in the page header, next to other actions.
- Label: "Filters" with a funnel icon. Show a small `(N)` count badge when
  filters are active so they can be spotted from across the page.
- State is sticky — once the user opens the sidebar, keep it open across
  page navigations within the same session (in-memory state is enough for
  now; localStorage if it ever needs to persist).

### Layout

- Sidebar width: a fixed share of the page width, not a modal overlay.
  When open, the table reflows to fill the remaining space. This matches
  the article's "filter bar affects the page as a whole" rule and keeps
  results visible while filters change.
- On narrow viewports, fall back to a slide-over drawer (use the existing
  `Sheet` primitive with `side="left"`) so the sidebar doesn't crush the
  table.

## "Embrace redundancy" rule (applies to all patterns)

The article calls this out by name. The user needs to see the selection in
**three places**:

1. Inside the picker (popover, sidebar section).
2. On the trigger (count badge + active styling on the pill/button).
3. (Optional) A dedicated "Applied filters" summary below the bar —
   only worth it when many filters are active simultaneously.

Skipping any of these is the most common enterprise filter mistake.

## Anti-patterns to refuse

- **Don't mix two positioning patterns on the same dataset.** Pick one per
  page.
- **Don't hide the count badge.** `(3)` or `10+` is what tells the user a
  filter is applied without re-opening it.
- **Don't auto-close the popover after one selection in a multi-select.**
  Let the user pick several values, then close to apply.
- **Don't fetch on every keystroke** if the dataset is large. Add an
  Apply button inside the popover, or switch to batch filtering with a
  global Apply at the page level.
- **Don't open the sidebar as a modal overlay on desktop.** Modals block
  the table; the user can't see the live results. Use the existing
  `Sheet` primitive only as a fallback on small screens.

## Pair with

- `prefer-shadcn-elements` — use the existing `Button`, `Input`,
  `Checkbox`, `Collapsible` primitives. Don't roll a custom sidebar
  shell or popover.
- `senior-frontend-patterns` — the sidebar itself is a plain flex
  column with a header and a body. No card / shadow / rounded container
  on the outer shell; the page already has one.
- `modify-in-place` — when migrating an existing table to the sidebar
  pattern, remove the inline `column.filter` definitions, don't keep
  both.
