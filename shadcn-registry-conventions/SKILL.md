---
name: shadcn-registry-conventions
description: Use when creating, editing, or reviewing shadcn/ui registry components (files under registry/ that ship through a registry.json, or anything copied into a consumer's components/ui/). Covers the registry model, neutral token-driven defaults, className passthrough via cn(), and the override-prop pattern for opinionated bits. Use ONLY for shadcn-style components, not for unrelated Tailwind or React UI work.
---

# shadcn/ui registry rules

## Mental model

A shadcn registry component is **source code that gets copied verbatim** into
the consumer's app via the shadcn CLI. It is not an npm package. The consumer
owns the file the moment it lands in `components/ui/`.

Consequence: **the registry component must not bake any specific app's look
in.** Whatever renders at runtime is whatever the consumer has in their
`globals.css` (CSS variables like `--primary`, `--destructive`, `--background`)
and `tailwind.config` (token extensions). If the consumer's tokens say
`bg-primary` is sky-blue, the component renders sky-blue. If they say it is
garish pink, it renders garish pink. That is the consumer's choice, not the
component's.

This is the whole reason two apps can drop the same component into wildly
different design systems without fighting `!important`.

## Hard rules

1. **Every component accepts `className` and passes it through `cn(...)` LAST.**
   Tailwind class ordering means later wins on conflict, so the consumer's
   classes must come after the component's defaults. Pattern:

   ```tsx
   export function Thing({ className, ...props }: React.ComponentProps<"div">) {
     return (
       <div
         className={cn(
           "rounded-md border bg-background text-foreground",
           className,
         )}
         {...props}
       />
     )
   }
   ```

2. **Forward `...props` and standard HTML attributes.** The component extends
   the underlying element's props (`React.ComponentProps<"div">`,
   `React.ComponentProps<"input">`, etc.) so `id`, `aria-*`, `data-*`,
   event handlers, and refs all flow through untouched.

3. **For opinionated styling that consumers may reasonably want to override,
   expose explicit props with neutral defaults.** Do not force them to
   fight `className` for things that have a clear semantic meaning.
   Reference pattern: `registry/outlined-input/input.tsx` with `textColor`,
   `borderColor`, `inputBackgroundColor`. Defaults stay neutral, props are
   typed as `string` (Tailwind class names), and the prop's class is composed
   alongside — not instead of — the consumer's `className`.

4. **Preserve the original visual identity.** When refactoring an existing
   component, do not strip decorative layers (gradient backgrounds,
   overlay divs, marker halos, pill colors, status color defaults) just
   because they don't read as "pure token-driven". The user's design intent
   for the original look is authoritative. Add extension points; do not
   unilaterally rewrite the look.

5. **No comments unless the user asks.** Same rule as the rest of the codebase.

## Soft guidance — defaults

Prefer design tokens (`bg-background`, `text-foreground`, `text-muted-foreground`,
`border-input`, `border-destructive`, `ring-primary/30`, `bg-accent`) for new
code so the component rethemes with the consumer's palette. But this is a
default, not a hard ban — if a component has an established visual identity
that uses specific colors (e.g. `LocationMap`'s emerald/amber/rose status
palette and gradient backdrop), keep it. Status semantics belong on props
(`variant="destructive"`), not baked-in palettes, but the *existing* look
must not be removed without the user's say-so.

## Review checklist

When reviewing an existing component (or your own draft) against this repo:

- [ ] Does it accept and forward `className` as the last argument to `cn(...)`?
- [ ] Are the defaults tokens (`bg-background`, `text-foreground`, etc.) — no hardcoded palette colors?
- [ ] Does it spread `...props` onto the underlying element?
- [ ] Are opinionated visual choices either (a) overridable via `className` or (b) exposed as typed props with neutral defaults?
- [ ] Does it avoid app-specific branding (no `text-[app]-...`, no logo colors, no flag indicators, no per-status color palettes)?
- [ ] Does it use `data-slot` where the consumer's tooling expects it (e.g. `data-slot="input"`)?

## What "loud consumer-app look" means and how to avoid it

If a previous app using these components ended up looking loud (many
distinct colors, status flags, badges everywhere), that look came from
**the consumer app's tokens and the per-instance classes it passed**, not
from the registry components themselves. The way to keep the next-gen
frontend clean is:

- Keep registry defaults neutral. A `Badge` should default to a muted
  surface, not a saturated status color. Status semantics are a prop
  (`variant="destructive"`), not a baked-in palette.
- When a status *does* need color, drive it from a token (`bg-destructive`,
  `text-destructive-foreground`) so swapping the token retheme's every
  consumer at once.
- Never hardcode a color that maps to a specific business meaning in
  one app (e.g. "this exact green means approved in [app]").
  If a status needs a color, parameterize it.
