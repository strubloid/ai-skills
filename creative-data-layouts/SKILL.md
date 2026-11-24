# Skill: creative-data-layouts

Use when a user asks for visual alternatives for a data-heavy application screen, especially dashboards, operational tools, records, forms, or multi-tab detail panels. A layout variant must feel like a different design direction, not just a different grid order.

## Research basis

- Nielsen Norman Group, [Visual Hierarchy in UX](https://www.nngroup.com/articles/visual-hierarchy-ux-definition/): create hierarchy with scale, contrast, and grouping; reserve emphasis and avoid too many competing treatments.
- Nielsen Norman Group, [5 Principles of Visual Design in UX](https://www.nngroup.com/articles/principles-visual-design/): use scale, visual hierarchy, balance, contrast, and Gestalt relationships deliberately.
- Nielsen Norman Group, [8 Design Guidelines for Complex Applications](https://www.nngroup.com/articles/complex-application-design/): reduce clutter without removing capability and make important information visually salient.
- Nielsen Norman Group, [Cards: UI-Component Definition](https://www.nngroup.com/articles/cards-component/): use common regions to group related information, but do not turn cards into decoration or make dense information harder to scan.
- Current shadcn references: [Card](https://ui.shadcn.com/docs/components/base/card), [Badge](https://ui.shadcn.com/docs/components/base/badge), and [Separator](https://ui.shadcn.com/docs/components/base/separator). Prefer installed primitives and the target project's actual API.

## Workflow

1. Inspect the current screen, each tab/section, installed UI primitives, theme tokens, and existing responsive patterns.
2. Inventory every current value, label, conditional field, list item, state (loading/error/empty), and interaction per view. This inventory is the completeness checklist for every variant.
3. Keep business logic, data sources, bindings, validation, submit handlers, and accessible semantics unchanged. Variants may rearrange, group, emphasize, and restyle data; never drop or invent it.
4. If the variants are a preview tool, use one clearly named selector for the entire screen so the same number changes the design direction in every tab. Keep one baseline value for the original screen, and give the requested variants a clear, documented range.
5. Make every design number visually distinct through a named design system, not order/column changes alone. Vary several intentional dimensions: typography scale/weight/tracking, surface and border treatment, accent placement, contrast, density/spacing, heading/banner hierarchy, and how related metadata is grouped. Use a restrained palette and no more than three text scales in one direction.
6. Give every direction a clear visual concept and apply it consistently across every view. Examples include editorial manifest, dispatch terminal, route atlas, ruled ledger, dossier, status spotlight, field report, signal board, operations brief, and precision manifest. Do not use the same card treatment with only new proportions and call it a new design.
7. Use semantic theme colors and current shadcn components for UI primitives. Put layout styling on semantic containers, not by rebuilding controls. Verify actual project APIs before use.
8. Before finishing, compare every variant against the original per-view inventory. Confirm all fields, optional data conditions, complete lists, statuses, and interactive form controls still render. Check at narrow and wide widths and retain visible keyboard focus.
9. Run the required project lint and type validation, fix regressions, and report any unrelated pre-existing failures separately.

## Completion report

State the selector and its baseline, name the visual directions, confirm that every tab retains its full original data, mention the design references consulted, and report validation results.
