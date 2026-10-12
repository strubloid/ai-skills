---
name: tailwind-canonical-utilities
description: Use when writing, editing, or reviewing Tailwind v4 utility classes in this repo. Converts arbitrary `[Npx]` / `[Nrem]` values to the native `<utility>-<number>` form (e.g. `h-[400px]` → `h-100`, `text-[12px]` → `text-3`, `translate-x-[2.5rem]` → `translate-x-10`). Leaves true arbitrary values (colors, calc(), complex grids, shadows with var(), property lists, ARIA/data attribute selectors) alone. Skips files under `src/components/ui/` unless explicitly asked.
---

# Tailwind canonical classes (v4)

Tailwind v4 sizing and typography utilities use `--spacing: 0.25rem` as their
base unit, so any value that resolves to a multiple of `0.25rem` has a
canonical `<utility>-<number>` form. Decimals are supported (`h-62.5`,
`text-2.5`, `ring-0.75`), so the arbitrary `[Npx]` / `[Nrem]` form is almost
never needed.

This codebase mixes both forms (e.g. `h-100` next to `h-[400px]`). Prefer the
canonical form when writing new code. When editing an existing file, convert
arbitrary forms in that file to canonical.

## Quick conversion

```text
px  → number = px / 4          (h-[400px] → h-100,    text-[12px] → text-3)
rem → number = rem / 0.25      (translate-x-[2.5rem] → translate-x-10)
mixed → convert to rem first   (1rem = 16px)
```

Round to 3 decimals max. If the result has more than 3 decimals, it's not on
the spacing scale — leave the arbitrary value alone.

## What converts

Every utility driven by `--spacing`, including (not exhaustive):

- Sizing: `h-*`, `w-*`, `size-*`, `min-h-*`, `max-h-*`, `min-w-*`, `max-w-*`,
  `min-block-*`, `max-block-*`, `min-inline-*`, `max-inline-*`
- Box: `p-*`, `px-*`, `py-*`, `pt-*`, `pr-*`, `pb-*`, `pl-*`, `m-*`, `gap-*`,
  `space-x-*`, `space-y-*`
- Position: `top-*`, `right-*`, `bottom-*`, `left-*`, `inset-*`, `inset-x-*`,
  `inset-y-*` (and `t-*`, `r-*`, `b-*`, `l-*`, `x-*`, `y-*` shorthands)
- Transforms: `translate-*`, `translate-x-*`, `translate-y-*`
- Typography: `text-*` (font-size), `leading-*`, `tracking-*` (em-based)
- Borders & rings: `border-*`, `border-t-*`, `ring-*`, `outline-*`
- Radius: `rounded-*`, `rounded-t-*`, etc.

## What stays arbitrary

These don't have a canonical numeric form. Leave them:

- **Colors**: `bg-[#1d3a8a]`, `text-[oklch(...)]`, `[color:var(--x)]`
- **Complex grids / sizing**: `grid-cols-[1fr_180px_240px]`,
  `grid-rows-[auto_auto]`, `aspect-[16/10]`
- **Shadows with var()**: `shadow-[0_0_0_1px_var(--sidebar-border)]`
- **calc() / function calls**: `w-[calc(...)]`, `p-[var(--x)+2px]`
- **Property lists**: `transition-[left,right,width]`,
  `transition-[margin,opacity]`
- **Mixed-unit arithmetic**: `w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)]`
- **Attribute selectors inside variants**: `aria-[haspopup]`,
  `data-[active]`, `group-data-[collapsible=icon]:...` — these are ARIA/data
  selectors, not arbitrary utility values
- **Non-spacing themes**: `blur-[3px]`, `opacity-[0.42]`, `z-[5]`, `order-[7]`
  — these use their own scales, not `--spacing`

## Before/after (real cases in this repo)

```tsx
// height / width
<Card className="h-[400px]" />
<Card className="h-100" />

className="h-[200px] w-full"
className="h-50 w-full"

"mx-auto aspect-square max-h-[250px] w-full"
"mx-auto aspect-square max-h-62.5 w-full"

// font-size
className="text-[12px] text-muted-foreground"
className="text-3 text-muted-foreground"

className="text-[10px] text-muted-foreground"
className="text-2.5 text-muted-foreground"

"text-[0.625rem] tracking-widest text-muted-foreground"
"text-2.5 tracking-widest text-muted-foreground"

// position
"after:start-1/2 after:w-[2px] hover:after:bg-sidebar-border"
"after:start-1/2 after:w-0.5 hover:after:bg-sidebar-border"

// borders / rings
"focus-visible:ring-[3px] focus-visible:ring-ring/50"
"focus-visible:ring-0.75 focus-visible:ring-ring/50"

"rounded-[2px]"
"rounded-0.5"

"border-t-[6px]"
"border-t-1.5"

// transforms
"ltr:-translate-x-1/2"
no change — already canonical

// stays arbitrary
"shadow-[0_0_0_1px_var(--sidebar-border)]"            // uses var()
"grid-cols-[1fr_180px_240px]"                        // mixed units
"transition-[left,right,width]"                      // property list
"bg-[#1d3a8a]"                                       // color
"group-data-[collapsible=icon]:w-[calc(...)]"        // variant selector
```

## Workflow

1. **New code**: write canonical from the start. Don't reach for `h-[Npx]`
   unless the value is off the spacing scale.
2. **Editing a file**: while you have it open, convert any arbitrary
   `[Npx]` / `[Nrem]` on a `--spacing`-driven utility to the canonical
   `<utility>-<number>` form. Touch only the classes you're already
   reviewing — don't churn unrelated files in the same edit.
3. **Sweep**: when asked to clean up, run a grep first to find every match,
   then convert in batches. Group conversions by file so each edit is
   reviewable.
4. **Verify**: after converting, run the project's `lint` and `build`
   commands. Tailwind's compiler will fail to find the canonical class if
   `--spacing` was overridden — check `src/index.css` first.

## Skipping shadcn files

Files under `src/components/ui/` are generated by the shadcn CLI. Converting
them is wasted work: the next `shadcn add` overwrites them. **Skip them by
default.** If the user explicitly asks to clean those up too, do it and flag
the regeneration risk in the summary.

## Sanity-check before converting

- Does the value divide cleanly by `0.25rem` (i.e. `4px`)? If not, the
  canonical form doesn't exist — keep arbitrary.
- Does the value look like `0.625rem`, `1.5rem`, `2.5rem`? Those are
  common off-grid values from shadcn output. `0.625rem = 10px = 2.5` on the
  scale — convert.
- Is the utility driven by `--spacing`? If not (color, blur, opacity, z,
  order), don't touch.
