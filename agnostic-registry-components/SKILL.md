---
name: agnostic-registry-components
description: Use when writing components for a shadcn-style registry that is shipped to multiple consumer projects. Enforces that component names, types, defaults, docs, and CSS tokens are project-agnostic. Covers the names to avoid, the vocabulary that stays generic, what to move OUT of the registry into per-consumer theme/style modules, and the convention for cross-provider constants.
---

# Generic registry components

A shadcn-style registry ships the same files to many consumers. The
moment a single name carries a project reference, that registry becomes
a fork waiting to happen. Every name in `registry/` should read as
domain vocabulary, not as a Salesforce / Acme / etc. brand.

## 1. The hard rule

**If a name only makes sense in one consumer's product, it does not
belong in the registry.** Period.

If a consumer needs a project-specific value (status names, business
IDs, color overrides), they pass it through a prop or wire it through
a consumer-owned `theme.css` / token file. The registry stays neutral.

## 2. Names to avoid

Any name that includes a project, company, or product reference. The
ones that show up most often in AI-generated registry code:

- **Company / product names** — `AppMap`, `OrderRoute`,
  `ProductCard`. If you wrote the name and a different consumer would
  not understand it without context, rename.
- **Domain status / enum names from one consumer's product** —
  `Pending`, `Approved`, `Archived`, `Rejected`. These
  are usually fine inside a single consumer's page, but in a registry
  they constrain the vocabulary. Use generic shapes
  (`"primary" | "secondary"`, discriminated unions) and let consumers
  map their domain to those shapes.
- **Mock data shapes** — `mockAppRoutes`, `sampleOrderItems`,
  etc. Mocks belong to the consumer; the registry shouldn't even know
  what a project-specific ID is.
- **Project-specific CSS tokens** — `--app-line-color`,
  `--priority-accent`. Tokens carry the theme. The registry
  uses *its own* theme (`--primary`, `--color-line`) and exposes a
  documented mapping surface for consumers to override.
- **Project-specific route paths / asset paths / import aliases** —
  `@/lib/helpers/env` (consumer), `@/registry/helpers/env` (registry).
  Pick the alias that matches *this* repo and only this repo. Don't
  import across the line.

## 3. Names that stay

Domain vocabulary that maps to the underlying primitive, regardless of
consumer:

- **Map / table primitives** — `MapPoint`, `MapRoute`,
  `RouteCapableMap`, `FlexTable`, `FlexColumn`, `MapProvider`. These
  describe the shape, not the use case.
- **Lifecycle / render verbs** — `mountRoutes`, `useMapLifecycle`,
  `computeBounds`, `fitCamera`, `restyleRoutes`, `compareValues`,
  `handleSort`. Action words.
- **Cross-provider constants** — `SELECTED_ROUTE_COLOR`,
  `DEFAULT_CENTER`, `DEFAULT_ZOOM`. Lives in `shared.ts` so both
  providers reuse them without one reaching into the other.
- **Hook-private paint constants** — `DEFAULT_LINE_WIDTH`,
  `SELECTED_LINE_WIDTH`, `DEFAULT_ROUTE_COLOR`. Hook-local; not
  exported, not in shared.
- **CSS class names** — `data-slot="flex-map"`, `data-slot="table"`.
  Convention, not domain.

## 4. The split: what goes where

| Lives in the registry                          | Lives in the consumer      |
| ---------------------------------------------- | --------------------- |
| Generic component, type, helper                | Page / feature code   |
| `MapRoute`                              | `mockOrdersList` |
| `mountRoutes`                          | `deriveOrderStatus` |
| `SELECTED_ROUTE_COLOR`                 | `OrderStatus = "Pending" | "Approved"` |
| `DEFAULT_LINE_WIDTH = 3`               | Domain status enums            |
| `flex-table` `FlexTable`               | `awaiting-approval.tsx` |
| `registerSchema` validation rules        | per-page mock data              |
| `--color-line` (registry CSS)          | `--color-accent` (consumer CSS) |

If a constant is shared between two providers within the registry, it
belongs in `shared.ts`. If it's shared between the registry and a
consumer, it's not the registry's job to define it — pass it through
a prop.

## 5. Defaults that aren't yours

`DEFAULT_CENTER`, `DEFAULT_ZOOM`, `DEFAULT_ROUTE_COLOR` — these are
*registry defaults*, not project defaults. They exist so the
component works the moment it's dropped in. The moment a consumer
wants different defaults, they pass them as props.

```tsx
// GOOD — registry default is a fallback, consumer passes their own
<FlexMap defaultCenter={{ longitude: 8.68, latitude: 50.11 }} />
```

If the registry default turns out to be wrong for everyone, change
the default — don't make consumers override it.

## 6. Docs that don't leak

Docstrings and comments in registry code describe what the prop /
helper does, not what the consumer does with it.

```ts
// BAD — leaks the consumer's domain
map | "An order with a project-specific ID between two cities."

// GOOD — describes the abstraction
map | "A polyline drawn on the map. Coordinates are `[longitude, latitude]` pairs."
```

Same goes for variable names — `routes` is generic; `orderItems` is
not (unless the component is genuinely about orders, in which
case it belongs in the consumer, not the registry).

## 7. Examples

### Generic names — done

```ts
export interface MapRoute {
  id: string | number;
  coordinates: Array<[longitude: number, latitude: number]>;
  color?: string;
}

export interface RouteCapableMap extends MapLike { /* … */ }
export const SELECTED_ROUTE_COLOR = "#9333ea";
export function mountRoutes(/* … */) { /* … */ }
```

### Project-specific names — flagged

```ts
// BAD — domain-specific, this is a consumer concept
export interface OrderRoute {
  projectNumber: string;
  owner: string;
  archived: boolean;
}

// BAD — project status enum used as a default status
export const DEFAULT_ORDER_STATUS: "Pending" | "Approved" = "Pending";

// BAD — company name in a CSS variable
const appPrimary = "var(--app-primary)";

// BAD — project-specific default center
const DEFAULT_APP_CENTER = {
  longitude: 8.68,
  latitude: 50.11,
};
```

If a consumer needs these, they live in the consumer. The registry
stays neutral.

## 8. CSS theme tokens

The registry may ship its own theme (`--color-primary`, `--color-line`)
because every component needs *some* color. The convention is:

- Registry CSS defines `--color-primary` → `--primary` (or a neutral
  palette variable).
- Consumers override the registry variable in their own `index.css`
  (`@layer base { :root { --color-primary: oklch(…); } }`).
- Registry components read `var(--color-primary)`, never a literal
  palette value.

This keeps the registry themeable per consumer without the registry
ever knowing about the consumer's brand.

## 9. Imports inside the registry

Inside `registry/`, every import starts with `@/registry/...` or is a
peer (`@base-ui/react`, `cn`, `lucide-react`). Never `@/lib/...`,
`@/components/...`, never a relative `../../private` from this repo's
consumer code.

```ts
// BAD — leaks the consumer's path alias
import { env } from "@/lib/helpers/env";

// GOOD — registry owns its helpers
import { env } from "@/registry/helpers/env";
```

If a helper would be useful in the consumer too, move it to the
registry's `helpers/` directory (or to a shared package) — don't
import from the consumer into the registry.

## 10. When you're tempted to "just hardcode it for now"

The temptation: "It's just one constant. We'll rename it later when
another consumer shows up."

The reality: there will not be a "later." The constant will ship to
ten consumers and become a fork bomb in year two. Rename now.

The audit that catches this is short:

```
rg "Acme|priority[_-]?accent|Project[_-]?[Nn]ame|Company[_-]?[Nn]ame" \
   registry/
```

If that returns anything, rename before merging. The CI
equivalent in real registries: a simple grep gate on the
`registry/` directory.

## 11. Senior-frontend rules interaction

This skill layers on top of `senior-frontend-patterns`:

- **Co-location (rule 1)** applies — generic helpers live in
  `registry/<component>/shared.ts` or alongside the only consumer in
  `registry/<component>/<provider>/...`. Module-scope constants for
  one consumer stay inside the hook.
- **No helper functions for one consumer (rule 2)** applies across
  the registry / consumer line — don't extract a consumer's helper into
  the registry just because two providers would use it.
- **Composable APIs (rule 20)** applies — registry props are
  primitives (`color`, `width`, `coordinates`), not consumer-shaped
  blobs (`orderRequest`, `owner`).
- **Strict TypeScript (rule 15)** applies — `MapRoute.color` is
  `string`, not `AppBrandColor | AcmeBrandColor`.

Where this skill and `senior-frontend-patterns` overlap, this skill wins (more
specific to the registry context).