# Web and frontend

Use this guide for browser UI, pages, components, styling, forms, navigation,
and client-side behavior. First identify whether the task is about a browser
platform capability, framework structure, accessibility, or a design-system
primitive; many tasks need more than one specialist skill, but rarely all of
them.

## Browser platform first

For HTML, CSS, or client-side JavaScript behavior, follow
[`modern-web-guidance/SKILL.md`](modern-web-guidance/SKILL.md) before
implementing. Search one capability at a time, retrieve the matching guide,
check the project's browser target, and follow its compatibility and fallback
guidance. The bundled `modern-web-guidance/guides/` corpus is available for
local lookup or when network retrieval is unavailable. Do not treat a modern
API as automatically better, and do not copy framework-free examples without
adapting them to the project's rendering model.

Use broad `legacy-scan` only for an explicitly broad modernization/audit. Verify
each result in context; a fallback or guarded legacy branch can be intentional.
For a focused feature change, retrieve the relevant guide instead of scanning
the repository.

## Choose specialist guidance

| Concern | Detailed guide | Apply when |
|---|---|---|
| Accessibility semantics, keyboard, focus, announcements | [`accessibility`](web/accessibility.md) | Any interactive or content-rich UI, especially forms, dialogs, tables, and navigation |
| React composition and component-level patterns | [`senior-frontend-patterns`](web/senior-frontend-patterns.md) | The target project uses React |
| Component-only variables and helpers | [`component-scoped-variables`](web/component-scoped-variables.md) | A value or helper belongs to one React component |
| Async promise handling | [`async-await-only`](web/async-await-only.md) | The change creates or consumes promises and the project adopts this rule |
| UI primitives and composition | [`prefer-shadcn-elements`](ui/prefer-shadcn-elements.md) | The target uses shadcn/ui |
| Tailwind v4 spacing utility normalization | [`tailwind-canonical-utilities`](web/tailwind-canonical-utilities.md) | The target uses Tailwind v4 and the edit is in scope for that guide |

## Shared principles

- Use native semantic HTML and accessible names before adding ARIA. Check what
  the installed component primitive already supplies before layering on roles,
  keyboard handlers, or focus management.
- Keep visual, DOM, and keyboard order aligned. Preserve visible text in
  accessible names, provide stable labels, and respect reduced motion and zoom.
- Keep loading, error, empty, and success feedback understandable to both
  visual and assistive-technology users.
- Use viewport responsiveness for page composition and component/container
  responsiveness when a component must adapt to its available space.
- Measure before adding performance machinery. Avoid layout-thrashing scripts,
  unnecessary observers, and blanket memoization; use the relevant current
  guide for performance-sensitive work.
