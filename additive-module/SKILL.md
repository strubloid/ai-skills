---
name: additive-module
description: Use when adding new functionality to an existing codebase — "add a feature", "new module", "new service", "call it from somewhere else", "without touching the rest of the code", "don't rename anything". Enforces one new file that delegates to a globally accessible singleton (zustand `store.getState()`), with no renames, no restructuring, no provider/context, no import-time side effects and no circular imports, so the new code is callable from anywhere without loading problems.
---

# Add one module, delegate to the global singleton

A new capability lands as **one new file** that calls into a piece of global state
that already exists. Everything else in the codebase stays byte-identical.

The new file is the seam. It is the only place that knows how to talk to the
outside world, and it can be called from a hook, a component, an event handler, a
`setTimeout`, or an interceptor — with no provider to mount, no context to thread,
and nothing that has to finish loading before it works.

## Why

- **Minimum diff.** The blast radius of a change is the diff. A new file plus the
  two or three lines that call it can be reviewed in one screen and reverted in one
  keystroke.
- **No migration.** Renaming or restructuring existing code forces every consumer
  to move at the same time. Adding is safe to land on its own; renaming is a
  coordinated refactor that has to be right the first time.
- **One direction of dependency.** A module that reads a global singleton has no
  knowledge of who calls it, so it cannot create a cycle.
- **No loading problems.** A module with no import-time side effects is safe to
  import from anywhere — including from another module's module scope.

## The pattern

```
caller (hook / component / handler)
   └── calls  newModule.doThing()          ← the new file
                    └── reads global state: store.getState()…
                    └── talks to the outside world (fetch, storage, clock)
```

The global singleton is the existing zustand store:

```ts
// src/features/auth/stores/auth-store.ts (already exists — do not touch it)
export const useAuthStore = create<AuthState>()(persist(/* … */));
```

It is created at import time and lives for the lifetime of the page. Zustand
documents `getState()` as the supported way to read and write state **outside** of
React — non-reactive, no re-render, no provider:

```ts
// anywhere, including module scope and non-React code
const token = useAuthStore.getState().session?.token;
useAuthStore.getState().clear();
```

Never call the hook itself outside a component (`useAuthStore(...)` is a hook).
Call `useAuthStore.getState()` instead.

## Rules

### 1. One new file, one responsibility

The new module owns exactly one job — "talk to the API", "read the token", "write
the session". It exports plain functions. It is not a class, not a factory that
must be constructed, not a context provider.

```ts
// src/lib/api/client.ts
export async function apiRequest<T>(path: string, init?: RequestInit): Promise<T> {
  const token = useAuthStore.getState().session?.token;
  // …
}
```

### 2. The dependency direction is one-way

```
newModule  →  store          (allowed: read global state)
newModule  →  other libs     (allowed)
store      →  newModule      (FORBIDDEN — this is the cycle)
```

If the store would need to call the new module, the new module must instead
expose a callback that the store's owner registers — or the call has to move to
the caller. Never let the store import the module that imports the store.

### 3. No import-time side effects

The module must be safe to `import` anywhere, including from another module's
module scope:

- no `await` at the top level
- no `fetch` on import
- no timers started on import
- no `window`/`document` access at import time (guard it, or do it inside a function)

An import that starts a request is the classic "it loads in the wrong order"
bug: the value is `undefined` for whoever imported it first, and only becomes
correct after a re-render that may never come.

### 4. Rename nothing

Do not rename existing files, functions, types, props or store fields. Do not
move code into a new folder. Do not re-export the old name from the new file to
keep both alive — that is a rename with extra steps.

If an existing name is genuinely wrong, that is a **separate** change, landed
separately, with the whole codebase updated in the same commit.

### 5. Wire it in at exactly one call site

The new module is called from the one place that needs it. If a second place
needs it later, that is a second small change — not a reason to restructure now.

### 6. Keep the existing public surface

Existing exported names keep working exactly as before. The new module is
additive: `login()`, `logout()` and `getCurrentUser()` keep their signatures even
if their internals now delegate to the client.

### 7. Errors are values

The module throws typed errors with a `code` (`invalid_credentials`, `network`,
`unauthorized`, …) instead of returning error strings or logging and swallowing.
The caller decides what the user sees.

## Where the file goes

Match the folder the codebase already uses for that kind of thing — do not invent
a new top-level directory:

| Kind of module | Typical location |
| --- | --- |
| Cross-cutting infrastructure (http client, logger, analytics) | `src/lib/<area>/` |
| Feature-scoped API layer | `src/features/<feature>/api/` |
| Feature-scoped state | `src/features/<feature>/stores/` |
| Feature-scoped hooks | `src/features/<feature>/hooks/` |

One file, one name, named after what it does (`client.ts`, `session.ts`,
`api.ts`) — not after the feature that happens to use it first.

## Anti-patterns

```ts
// ❌ Renaming + moving: a coordinated refactor disguised as a feature
//   api/auth-api.ts  →  lib/api/client.ts   (plus every import updated)

// ❌ Provider + context: now every consumer needs the provider mounted
export const ApiProvider = ({ children }) => (
  <ApiContext.Provider value={client}>{children}</ApiContext.Provider>
);

// ❌ Import-time side effect: the value is undefined for whoever imported first
export const user = await fetch("/me").then((r) => r.json());

// ❌ Circular import: the store imports the client, the client imports the store
//   auth-store.ts  →  lib/api/client.ts  →  auth-store.ts

// ❌ Swallowing the error: the caller cannot tell success from failure
try { await apiRequest("/x"); } catch { /* ignore */ }

// ❌ Renaming an existing export and keeping a back-compat alias
export const loginUser = login;   // now there are two names for one thing
```

```ts
// ✅ Additive, one-way, no side effects on import
// src/lib/api/client.ts
import { useAuthStore } from "@/features/auth/stores/auth-store";

export class ApiError extends Error {
  constructor(readonly code: ApiErrorCode, readonly status?: number) {
    super(code);
  }
}

export async function apiRequest<T>(path: string, init?: RequestInit): Promise<T> {
  const token = useAuthStore.getState().session?.token;
  const response = await fetch(path, {
    ...init,
    headers: {
      ...init?.headers,
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });

  if (!response.ok) throw new ApiError("unauthorized", response.status);
  return response.json() as Promise<T>;
}
```

## Checklist before you call it done

- [ ] One new file; `git diff --stat` shows it plus the few lines that call it
- [ ] No existing file renamed, moved or re-exported
- [ ] The new module reads global state through `store.getState()`, never a hook
- [ ] No cycle: `grep` the new module's import in the store — it must not be there
- [ ] No top-level `await`, no request fired on import
- [ ] The new module throws typed errors; nothing is swallowed
- [ ] `npm run lint` and `npm run validate` are clean for the touched files
- [ ] The new behaviour is reachable from the app (a caller actually calls it)

## Related

- `modify-in-place` — how to change existing code without churning it.
- `behavior-first-testing` — how to write the tests for the new module.
