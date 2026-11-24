---
name: modern-idiomatic-code
description: Use when writing, reviewing, or refactoring code in any language (TypeScript, JavaScript, React, HTML, CSS, Tailwind) where the goal is current, idiomatic, production-quality patterns rather than just functional code. Triggers on "modernize", "is this current", "what's the best practice", "review against standards", "old way", or code that mixes older patterns (function declarations where a local arrow would read better, manual effects where derivation would do, type casts where narrowing would work, manual memoization where the React Compiler would handle it, etc.). Complements `senior-frontend-patterns` by covering the language-level / framework-agnostic standards first; defer to more specific skills (`component-scoped-variables`, `prefer-shadcn-elements`, `shadcn-registry-conventions`, `tailwind-canonical-utilities`) when they apply.
---

# Modern code standards

Write code the way senior engineers write it in 2026. Not the way it was written in 2018. Not the way a code generator writes it. Every rule below exists because the opposite pattern shows up constantly and reads as outdated or machine-generated.

This skill is **general first, framework-specific second**. The TypeScript/JavaScript section applies to almost every codebase. The React, HTML, CSS, Tailwind, and state-management sections only apply when the project uses them.

If a rule and an existing project skill overlap, the **more specific skill wins**. In particular:

- For React components: `senior-frontend-patterns`, `component-scoped-variables`, `prefer-shadcn-elements`.
- For shadcn registry components: `shadcn-registry-conventions`, `agnostic-registry-components`.
- For Tailwind utility classes: `tailwind-canonical-utilities`.
- For inline comments: `comment-why-not-what`.

## Core principle

Evaluate whether the code follows current, idiomatic, maintainable patterns — **not** whether it merely works.

Do not perform stylistic refactoring for the sake of being different. A change has to improve at least one of:

- readability
- maintainability
- type safety
- simplicity
- consistency
- composability
- testability
- performance (when relevant)
- adherence to modern framework / language conventions

Respect the existing project's architecture, conventions, lint config, format config, and dependency versions. Project conventions take precedence over this skill's preferences unless they conflict with correctness, security, or a current best practice that has a clear reason behind it.

## Three modes

This skill works in three modes. Use the right one for the task:

1. **Preventative** — apply these standards while generating new code. Pick the modern pattern by default.
2. **Audit** — review existing code against the standards checklist. Do not change anything yet.
4. **Refactor** — apply only justified improvements. Preserve behavior. Do not rewrite working code that already follows the standards.

The headline goal: write modern, idiomatic, production-quality code without turning the skill into a rigid style guide or blindly rewriting working code.

---

## Standards audit checklist

When auditing code, walk through these 20 categories. For each, classify findings as **Must Fix**, **Should Improve**, or **Optional** (defined at the end).

1. TypeScript
2. JavaScript / ECMAScript
3. React (when present)
4. HTML / accessibility
6. Tailwind (when present)
7. State management
8. Error handling
9. Async code
10. Functions and callbacks
11. Naming
12. Imports and module structure
13. Component design
14. Reusability and duplication
15. Type safety (deeper pass)
16. Testing
17. Performance
18. Security
19. Dead code and unnecessary complexity
20. Project-specific conventions / deprecated APIs

Distinguish between **actual problems**, **modernization opportunities**, and **subjective stylistic preferences**. Do not report subjective preferences as standards violations.

---

## Modern TypeScript / JavaScript

Prefer modern language features where they improve clarity. Do not use modern syntax merely because it exists — pick the clearest construct.

Default to:

- `const` for everything; `let` only when reassignment is required.
- Arrow functions for local callbacks / inline handlers (see the **Functions** section below for when to keep declarations).
- `async / await` over `Promise` chains. See the **Async code** section for the rule, the rationale, and the canonical `useEffect` + `async` pattern.
- Optional chaining (`?.`) instead of nested `&&` chains.
- Nullish coalescing (`??`) instead of `||` for "missing or null/undefined".
- Destructuring when it improves readability — not because destructuring is "modern."
- Modern array methods (`map`, `filter`, `reduce`, `flatMap`, `find`, `some`, `every`) over manual `for` loops when the loop does not need indices.
- One flat state object for a status + payload (fields filled in by the conditionals). A discriminated union only when the branch shapes genuinely differ.
- Type narrowing (`if ("kind" in x)`, `if (x.kind === "loading")`) instead of unsafe casts.
- `unknown` instead of `any` when the value is genuinely unknown. Narrow before use.
- Type inference when explicit annotations are redundant. Annotate at module boundaries (function signatures, exported types, props).

Avoid:

- `enum` (prefer `as const` tuples with a derived union).
- `namespace` (use ES modules).
- IIFEs.
- `arguments` object (rest parameters).
- `var`.
- `==` (always `===` / `!=`).
- Legacy module formats.
- Type assertions (`as`) to silence an error unless you have a one-line comment explaining why.

---

## Functions

**Context decides form.** Apply judgement, not a mechanical rule.

### Prefer `const` arrow for local handlers

Inside a component or function body, local callbacks, handlers, and helpers should generally be arrow `const`s. They are closer to the call site, have no hoisting surprises, and read as "this is a local behavior."

```ts
// OK — local handler inside a component
export function OrdersPage() {
  const toggleSelected = (id: number) => {
    setSelectedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  const clearSelection = () => setSelectedIds(new Set());

  // ...
}
```

Not:

```ts
export function OrdersPage() {
  function toggleSelected(id: number) {
    setSelectedIds((prev) => { ... });
  }
  function clearSelection() {
    setSelectedIds(new Set());
  }
  // ...
}
```

### Keep declarations for top-level / exported / hoisted functions

Function declarations are still appropriate for:

- **Exported components** (better stack traces, hoisting).
- **Exported library / public APIs** — readers can find them by name regardless of position.
- **Recursive functions** — easier to read the recursion than an arrow.
- **Cases where hoisting is genuinely useful** — e.g., procedural scripts where flow reads top-down with helpers hoisted.
- **Project conventions that require it**.

```ts
// GOOD — top-level exported component, keep declaration
export function OrdersPage() { /* ... */ }

// GOOD — exported utility
export function formatMoney(amount: string | null, currency: string | null): string { /* ... */ }
```

The skill must understand context rather than apply a mechanical replacement.

### Other function rules

- **Single responsibility.** A function does one thing, named after what it returns or what it does for side effects (`getUser`, `formatMoney`, not `doStuff`).
- **Pure by default.** Side effects at the edges; logic in the middle is testable.
- **Accept arguments instead of closing over module state when possible.** Makes the function testable without mocking globals.
- **Keep the signature honest.** Return type matches what the function returns. If it can return `null`, the signature says so.
- **No factory that is called once.** `const createThing = () => { … }; export const thing = createThing();` is an indirection with no payoff — the reader has to jump between two names to see what it is, and the "private" state it closes over lives exactly as long as the module anyway. Write the function directly and keep its private state at module scope. Reach for a factory (or a class) only when there is more than one instance.

---

## React (when React is present)

Modern React patterns, layered on top of the language rules above. Many of these are enforced more strictly by `senior-frontend-patterns` — defer to it for the full detail; the bullets below are the modernization highlights.

Avoid these:

- **`React.FC`** — drops generics, silently injects `children`. Use plain functions with explicit prop types.
- **`useEffect` for derived state** — compute during render instead. Two renders when one would do is a bug, not a precaution.
- **`useEffect` for events** — handlers handle events. Effects handle syncing with the outside world.
- **Storing values in `useState` that can be computed** — derive inline. Use `useMemo` only when measured to be expensive.
- **`useMemo` / `useCallback` / `React.memo` as defaults** — the React Compiler handles most of this. Add them when profiling shows a problem or when a `React.memo`-wrapped child requires stable identity.
- **`export default`** for components — use named exports for better errors and to prevent swap bugs.
- **Index-as-key** — use a stable content-derived key.
- **Decorative `<div>` wrappers** — return what you need. Fragments or single roots.
- **`<div onClick>` instead of `<button>`** — semantic HTML gets keyboard handling, focus, screen reader semantics for free.
- **Giant components** — split. A finished component fits on a screen.
- **Business logic inside the component** — fetching, validation, transformation belong in hooks/services/pure utilities.

These are checks worth carrying forward:

- **Loading, error, and empty states are explicit.** A spinner is not an error state. A blank table is not "no data."
- **Controlled vs uncontrolled is deliberate.** Mixed modes need explicit intent.
- **Accessibility is part of writing the component, not a follow-up.** Every interactive element has a keyboard path and an accessible name.
- **Composition over prop-driven forks.** `<Button size="lg"><CheckIcon /> Confirm</Button>` not `<Button variant="primary" size="lg" icon="check" />`.
- **Server/client boundaries are respected.** Server-only code stays server-only. Client islands are re-marked explicitly.

---

## Type safety

Identify:

- Unnecessary `any`. Replace with `unknown` + narrow, or with the actual type.
- Unsafe type assertions (`as SomeType`) without a one-line comment explaining why.
- Duplicated types. One source of truth; derive the rest.
- Incorrect nullable handling. `value?.foo` when `value` can be `null` but `foo` cannot be `undefined` is fine; `value.x` then checking `value` is fragile.
- Overly broad types (`object`, `Record<string, any>`). Tighten.
- Types that should be inferred (trivial locals).
- Types that should be explicit (exports, props, hook return types).
- State objects that repeat the whole literal once per branch, or that model a status + payload as a union of object literals (see "Loading / error / not-found states").
- Inconsistent domain models — the same concept typed two different ways across the codebase.

Do not over-type trivial code. There is no value in annotating a literal that TypeScript already infers.

---

## Error handling

Check whether:

- Errors are silently swallowed (`catch {}` with no log, no rethrow).
- `catch` blocks exist but do nothing useful (catch-and-ignore is worse than no catch — it removes the call site's ability to react).
- Errors lose useful context. Wrap with cause: `throw new Error("...", { cause: e })`.
- Async failures are handled appropriately. Unhandled promise rejections on `fetch` are silent bugs.
- User-facing errors are separated from technical errors. Don't show `TypeError: Cannot read property 'foo' of undefined` to the user.
- Error types are handled safely. `error instanceof Error` before reading `.message`.

Do not add excessive defensive code when the surrounding architecture already handles the failure (e.g., a top-level error boundary, a route-level error element).

---

## Async code

**Always use `async` / `await`. Never use `.then().then().catch()` chains.**

A Promise chain forces the reader to mentally invert control flow: each `.then` is a "what happens after", each `.catch` is "what happens if it fails", and the shape of the work is fragmented across three callbacks. `async` / `await` reads top-down like synchronous code, makes the call site one expression instead of three, and lets `try` / `catch` do the job it was designed for.

```ts
// GOOD — async / await
const quotation = await getMyQuotation(id);
if (!quotation) {
  setState({ kind: "not-found" });
  return;
}
setState({ kind: "ready", bundle: adapt(quotation) });

// BAD — Promise chain
getMyQuotation(id)
  .then((quotation) => {
    if (!quotation) {
      setState({ kind: "not-found" });
      return;
    }
    setState({ kind: "ready", bundle: adapt(quotation) });
  })
  .catch((err) => {
    setState({ kind: "error", message: errorMessage(err) });
  });
```

### The `useEffect` + `async` pattern

`useEffect`'s callback must not return a Promise. The standard form is an **inline async IIFE** — short, single expression, no extra names:

```ts
useEffect(() => {
  if (!Number.isFinite(id)) return;
  (async () => {
    try {
      const data = await fetchSomething(id);
      setState({ kind: "ready", data });
    } catch (err) {
      setState({ kind: "error", message: errorMessage(err) });
    }
  })();
}, [id]);
```

This is the preferred form. The async IIFE is fire-and-forget — the trailing `;` discards the returned Promise. Errors do not escape because the body has its own `try` / `catch`. The `(async () => {...})()` pattern is the one accepted exception to the "no IIFEs" rule, for the same reason `try` / `catch` is: there is no shorter way to express async work inside `useEffect` that still returns a cleanup function.

**Avoid the heavier form.** Do not introduce a named `const run = async () => {...}`, a `void run();` line, or a `let cancelled` flag unless you actually need the cancellation behaviour. That form:

```ts
// AVOID — extra names, no benefit on a mount-once fetch
useEffect(() => {
  let cancelled = false;
  const run = async () => {
    try {
      const data = await fetchSomething(id);
      if (cancelled) return;
      setState({ kind: "ready", data });
    } catch (err) {
      if (cancelled) return;
      setState({ kind: "error", message: errorMessage(err) });
    }
  };
  void run();
  return () => { cancelled = true; };
}, [id]);
```

The `cancelled` flag only matters when deps change *while a fetch is in flight* — rare for a single-resource page that loads on mount and is gone when the user navigates away. For those cases, reach for a project-standard data-fetching library (TanStack Query, SWR) before reaching for a hand-rolled cancellation flag. The hand-rolled form is a sign the project is missing a data-layer primitive — fix the layer, not the component.

If the project has a strict floating-Promise lint rule (`@typescript-eslint/no-floating-promises`), add the `void` annotation on the IIFE call: `void (async () => {...})();`. It is a one-token annotation for the linter, not a structural choice.

### Rules

- **No `.then().then().catch()`.** If you find yourself reaching for it, write an `async` function instead.
- **No `.then()` without an immediately following `.catch()` / `.finally()`** (or in a `try` block).
- **Await every Promise that has a meaningful return value.** Bare `.then(...)` to read a value is just `.then(x => x)` with extra steps.
- **`Promise.all([...])` is fine** for parallel fetches inside an `await`-driven function. It is not a Promise chain.
- **Helpers that do one async thing should be `async function`s**, not `function foo(): Promise<T> { return ...then(...) }`. The body should `await`, not chain.
- **Error messages**: read `err.message` only after `err instanceof Error`. Wrap low-level errors with `cause` when crossing a domain boundary.

### `useEffect` for fetching: when it is and isn't the right tool

`useEffect` is the right tool when the call is **a side effect of mounting or of a prop/state change** — a fetch, a subscription, a `setInterval`. It is the wrong tool when the call is an **event handler** (use the click handler), a **one-shot initialization that blocks render** (lift it to a parent or use a route loader), or **derivable from existing state** (compute during render instead).

If the project already has a server-state library (TanStack Query, SWR, etc.), prefer that over `useState` + `useEffect`. The combination of `useState` + `useEffect` + manual `loading` / `error` / `ready` state is the fallback for projects that have not adopted one.

### Loading / error / not-found states

Pages that back onto a fetch expose three (sometimes four) states. Model them as **one flat state object** whose fields are filled in by the conditionals — not as a union of object literals:

```ts
type State<T> = {
  status: "loading" | "error" | "not-found" | "ready";
  data: T | null;
  error: string | null;
};
```

```ts
const state: State<T> = {
  status: "loading",
  data: null,
  error: null,
};

// Validators first — each one blocks the return and changes what is returned.
if (errorCode) {
  state.status = "error";
  state.error = errorMessages[errorCode];
  return state;
}

if (!data) {
  state.status = "loading";
  return state;
}

// The happy path is last.
if (data) {
  state.status = "ready";
  state.data = data;
}

return state;
```

**Flow: validators first, happy path last.** Each validator sets the status and returns immediately — it *blocks* the return. The happy path is the last thing that runs. Do not chain the states with `else if`: a chain hides which condition blocks the return, and the reader has to walk the whole chain to know what a branch actually returns.

**Why one object and not a union.** A union of object literals repeats the whole shape once per branch, makes every field conditional on the branch, and forces the consumer to narrow before it can read anything. One flat object is written once, the status discriminates, and the payload fields are `null` until they have a value. The consumer reads `state.status` and the fields it needs.

**Name a field after when it exists, not what it holds.** `error: null` reads correctly ("no error"); `message: null` does not ("no message"?).

A discriminated union is still the right tool when the branches have genuinely different shapes and narrowing is the point — e.g. `{ kind: "user"; user: User } | { kind: "group"; group: Group }` — where there is no single set of fields to share.

Render rules:

- **`loading`** uses the project's `Skeleton` component, not `<div>Loading…</div>`. A skeleton mirrors the eventual layout (subheader + cards + sections) so the layout doesn't jump when the data arrives.
- **`error`** shows a focused message ("Could not load this X") plus the error text. Do not surface `TypeError: Cannot read property 'foo' of undefined` to the user. Read `err.message` only after `err instanceof Error`.
- **`not-found`** is a separate state from `error` when the resource can legitimately not exist (404-style). If the page cannot meaningfully distinguish (e.g., the URL has no id and the default is also missing), collapse it into `error`.
- **`ready`** carries the data and nothing else. No "success" wrapper.

If the page is small and the only states are "loading" and "ready", the `useState` + inline IIFE is enough. Do not reach for a `useAsyncResource`-style custom hook for a single page — see `component-scoped-variables` for the broader "don't extract prematurely" rule.

### Polymorphic rendering: `render`, not `asChild`

If the project uses **base-ui** (`@base-ui/react/*`), the polymorphic element override is the `render` prop, not Radix's `asChild`:

```tsx
// GOOD — base-ui
<Button variant="outline" size="sm" render={<Link to="/back" />}>
  Back
</Button>

// BAD — Radix pattern, base-ui does not support it
<Button asChild variant="outline" size="sm">
  <Link to="/back">Back</Link>
</Button>
```

The `render` prop is the right primitive in a base-ui codebase; reaching for `asChild` is a porting tell from a Radix codebase. If you find yourself writing `asChild`, you are in the wrong mental model — switch to `render`.

For Radix-based codebases, the equivalent rule applies in reverse: do not reach for `render`.

---

## Testing

When reviewing code, check whether behavior that matters is testable and whether existing tests cover meaningful behavior.

- Prefer tests that verify **behavior**, not implementation details.
- Do not recommend tests simply to increase coverage numbers.
- A test that asserts the right thing is worth ten tests that assert implementation.
- Co-locate tests with the unit they test (`Button.tsx` + `Button.test.tsx`).
- Pure functions and hooks are easiest to test. If something is hard to test, that's a signal about its shape.

---

## Security

Common things to catch:

- **Unsafe HTML injection** — `dangerouslySetInnerHTML` on user input without DOMPurify or equivalent. Prefer text content.
- **Unsafe URL handling** — `href={userInput}` allows `javascript:` URLs. Validate scheme.
- **Exposed secrets** — never read or surface `.env`, `.env.*`, `.envrc`, `*.pem`, `*.key`, `credentials.json`. (See `protect-env-files`.)
- **Insecure client-side assumptions** — never assume client-side validation is a security boundary. The server must enforce.
- **Missing authorization checks** — UI hides an action; server still has to reject it.
- **Unsafe storage of sensitive data** — `localStorage` is readable by any script in the page. Use `httpOnly` cookies for session tokens.
- **Dependency / supply-chain concerns** — typosquatted packages, abandoned deps. Flag only when visible from the project; do not invent issues.

---

## Code quality

Identify:

- Duplicated logic across components (extract).
- Unnecessary abstractions (helper for one caller — inline).
- Dead code (unused imports, variables, branches, unreachable code).
- Overly complex conditionals (extract named booleans or split the branch).
- Deeply nested logic (early returns, guard clauses).
- Giant functions (split).
- Giant components (split).
- Unclear naming (a `data` / `result` / `temp` local is a smell — name what it is).
- Unnecessary intermediate variables (`const x = y; return x;` is `return y;`).
- Unnecessary wrappers (`forwardRef` when no ref is needed, `memo` when child isn't expensive).
- Excessive comments (comments that describe obvious code instead of explaining intent).

Prefer simple code over clever code.

---

## Imports and module structure

- **Named exports** for components and utilities.
- **Default exports** only when the file is being lazy-loaded and there is a clear reason.
- **Import order** is the project's `eslint-config` / `prettier` business. Do not invent rules.
- **Barrel files** (`index.ts` re-exports) are fine for public APIs but expensive when pulled into hot paths — flag when measured.
- **Type-only imports** when only types are used: `import type { Foo } from "./foo";`.
- **No inline `import("path").Type` in type positions.** Use a regular import at the top of the file. Inline imports in types usually mean you forgot to import the type (or were too lazy to) — both are fixable in 5 seconds at the import block. Inline imports in values are fine (`import("./x")` for dynamic loading).

  ```ts
  // BAD
  interface Props {
    carrier: import("@/mocks/foo").Carrier;
    request: import("@/mocks/foo").Request;
  }

  // GOOD
  import type { Carrier, Request } from "@/mocks/foo";
  interface Props {
    carrier: Carrier;
    request: Request;
  }
  ```

---

## Naming

- **Variables / functions**: `camelCase`.
- **Components / types / interfaces**: `PascalCase`. No `I`-prefix on interfaces.
- **Constants**: `UPPER_SNAKE_CASE` only for true compile-time constants (regexes, magic numbers used in more than one place, env-derived lookups). Module-scope `const` for runtime values stays `camelCase`.
- **Enums / union members**: `PascalCase` for the union, `camelCase` for the members (e.g., `Status.Loading` not `STATUS_LOADING`).
- **Boolean variables**: prefix with the question's answer — `isLoading`, `hasChildren`, `canSubmit`. Never `loading`, `flag`, `temp`.
- **Event handlers**: `on` prefix for the prop (`onClick`, `onSelect`); `handle` prefix for the implementation (`handleClick`, `handleSelect`).
- **Files**: PascalCase for components (`StatusBadge.tsx`), camelCase for hooks / utilities (`useStatus.ts`, `formatMoney.ts`).
- **Avoid generic names**: `data`, `result`, `temp`, `obj`, `item`. Name what they are.

---

## State management

When a project uses a state library, defer to its conventions. The general rules:

- **Local state** is for things only the component cares about. Default to `useState` (or `useReducer` for transitions).
- **Server state** is for things that live on a server. Use a server-state library (TanStack Query, SWR, etc.) — not `useState` + `useEffect`.
- **Global state** is rare. Default to lifting state up, then context, then a store. Reach for Redux/Jotai/Zustand only when there is a concrete problem.
- **One flat state object** for a status + payload: `{ status: "loading" | "error" | "ready"; data: T | null; error: string | null }`, with the fields filled in by the conditionals. Do not repeat the object literal once per branch. Reserve a discriminated union for branches whose shapes genuinely differ and where narrowing is the point.

---

## Performance

- **Measure first.** Do not pre-emptively memoize, debounce, virtualize, or split. Profile and then fix the actual hotspot.
- **`useMemo`** is for expensive calculations over large data. Most calculations are not expensive enough to justify it.
- **`useCallback`** is for stable identity passed to a `React.memo`-wrapped child. Half-memoization (the child is memoized but the prop is fresh) is the trap.
- **`React.memo`** is for leaves that re-render with the same props frequently.
- **Keys**: stable, content-derived. Index-as-key breaks under reorder / insert / delete.
- **Lists over 5000 rows**: profile. Then virtualize.
- **Bundle size**: dynamic `import()` for routes and large features.
- **Re-renders**: parent state changes re-render the whole subtree. Lift state down, or memoize the children that don't need the update.

---

## Project awareness

Before applying standards, inspect the project. The minimum reads:

- `package.json` — language version, framework version, library versions, lint / format scripts.
- `tsconfig.json` — `strict`, `target`, `module`, `jsx`.
- `.eslintrc*` / `eslint.config.*` — active rules.
- `tailwind.config.*` / CSS-in-Tailwind tokens.
- Existing patterns — find a similar feature and mimic it.
- Existing architecture — read before suggesting a restructure.

Project conventions take precedence over generic preferences unless they clearly conflict with correctness, security, or modern framework requirements.

Do not introduce a new library when the project already has an appropriate solution. Do not change dependency versions as part of a style refactor unless explicitly requested.

---

## Audit output

When reviewing code against this skill, group them as:

### Must Fix

Actual correctness, security, maintainability, type-safety, or architectural problems. Examples: silent error swallowing, unsafe HTML injection, `useEffect` for derived state, broken keys, uncontrolled-to-controlled warnings, `any` masking a real type error.

### Should Improve

Strong modernization or maintainability recommendations. Examples: function declarations where local arrows read better, plain `for` where `map` / `find` reads better, a state object that repeats its whole literal once per branch, missing empty/error states, helper functions outside the component for a single consumer.

### Optional

Subjective or context-dependent improvements. Examples: switching to `flatMap` over `reduce` + `concat`, renaming a local from `data` to `users`, alternative decomposition of a JSX block. These are not standards violations.

If the code already follows the standards, **say so explicitly**. Do not invent issues to fill a checklist.

---

## What not to do

- Do not run a mechanical find-and-replace from `function` to `const`. The Functions section above is context-dependent for a reason.
- Do not report subjective preferences as standards violations. `let` over `const` is. `function` over `const arrow` is context-dependent, not a violation.
- Do not introduce a new library when the project has one that works.
- Do not rewrite a passing test for stylistic reasons — tests are behavior, not style.
- Do not change dependency versions as part of a style pass.
- Do not delete code that is exercised, even if it looks redundant, without confirming what consumes it.
- Do not add defensive code the surrounding architecture already handles.
- Do not surface subjective taste as the user's signature. The skill is a tool for production code, not a style guide for a single team.