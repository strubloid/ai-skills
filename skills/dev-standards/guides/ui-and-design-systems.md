# UI and design systems

Use this guide when selecting UI primitives, shaping design-system components,
or exploring different layouts for data-heavy screens. First inspect the target
project's existing component library and design tokens.

## Choose specialist guidance

| Concern | Detailed guide | Apply when |
|---|---|---|
| Composing UI from shadcn primitives | [`prefer-shadcn-elements`](ui/prefer-shadcn-elements.md) | The target project uses shadcn/ui |
| Components distributed from a shadcn-style registry | [`shadcn-registry-conventions`](ui/shadcn-registry-conventions.md) | The component is copied or shipped as a reusable registry item |
| Project-agnostic registry APIs and tokens | [`agnostic-registry-components`](ui/agnostic-registry-components.md) | A registry component must work across consumer projects |
| Multiple visual directions for one screen | [`creative-data-layouts`](ui/creative-data-layouts.md) | The user asks for distinct design alternatives |
| Complete layout variants that preserve screen content | [`layout-examples`](ui/layout-examples.md) | Adding selectable layout examples to an existing screen |
| Data-table filter pattern selection | [`enterprise-filtering`](ui/enterprise-filtering.md) | Designing or reviewing filtering for a dense list, table, or analytics view |

## Shared principles

- Reuse the project's installed, accessible primitives. Keep product behavior
  in application compositions and component defaults neutral when code ships
  to multiple consumers.
- Treat design tokens as semantic contracts. Avoid hard-coded consumer branding
  in shared registry components.
- Make layout alternatives genuinely distinct, but keep every original field,
  state, control, and interaction in each alternative.
- Select filter placement according to filter count, scope, and viewport. Keep
  the active selection visible and do not combine competing filter patterns for
  the same dataset without a clear reason.
- Preserve responsive behavior, keyboard visibility, and meaningful focus
  styling while changing layout or appearance.
