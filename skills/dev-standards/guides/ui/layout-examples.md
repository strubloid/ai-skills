# Skill: layout-examples

Use this skill when the user asks for multiple visual layout alternatives in an existing screen so they can quickly compare directions before choosing one. The purpose is to rearrange the existing information, never to invent a reduced or partial version of the screen.

For design-heavy exploration, also apply `creative-data-layouts`: each option needs a distinct visual language, not merely reordered blocks or changed grid widths.

## Workflow

1. Inspect the target screen and identify the exact content and interaction whose presentation is being explored.
2. Inventory every visible data field, related record, loading/error/empty state, status indicator, and control in each relevant view before designing alternatives. Treat each tab, mode, or subview as its own complete content inventory.
3. Preserve every inventoried item in every alternative for that view. Reorder, regroup, resize, or restyle blocks; do not omit fields, truncate datasets, substitute made-up values, or move information to a different tab. Optional data remains optional under the same original condition.
4. Preserve state, data derivation, handlers, validation, submit behavior, and component accessibility. Change composition and styling only. Prefer canonical render blocks shared across layouts so a future content fix reaches every example.
5. Add alternatives next to the existing screen and make them easy to switch with a clearly named numeric selector or commented JSX branches. Keep the original view available as a baseline at selector value `0`.
6. Label options with meaningful names, and state explicitly whether the requested number is total across views or per view. When one selector spans multiple views, assign documented, non-overlapping ranges to each view. Do not silently reduce or expand the requested count.
7. Reuse the project's existing shadcn components and semantic tokens; use semantic layout HTML and responsive Tailwind composition. Do not add UI dependencies.
8. Avoid changing unrelated screen logic or extracting speculative abstractions. Local render helpers are appropriate when they guarantee all layouts use the same complete content and controls.
9. Run the project's required lint command and fix errors introduced by the examples.

## Output

Tell the user which value selects each layout and which value retains the original. Confirm that each view preserves its complete original data and controls. Summarize the visual directions briefly and report validation.
