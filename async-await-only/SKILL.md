---
name: async-await-only
description: Use when writing, reviewing, or refactoring any code that creates, awaits, or chains a Promise — enforces async/await instead of .then()/.catch()/.finally() chains. Triggers on "async await", "promise chain", ".then(", ".catch(", ".finally(", "await", "useEffect fetch", "single flight", "refactor promise", "no promise chain".
---

# async/await only

Every promise in this codebase is consumed with `await` inside an `async`
function. Promise chains (`.then()`, `.catch()`, `.finally()`) do not ship.

## The rule

**One rule: if a promise is involved, `await` it inside an `async` function.**

A chain forces the reader to mentally invert control flow and spreads one
operation across three callbacks. `await` keeps the code top-down: what it
does, in order.

## Forbidden

| Pattern | Why |
| --- | --- |
| `promise.then(...)` | The chain itself. |
| `promise.catch(...)` | Use `try` / `catch`. |
| `promise.finally(...)` | Use `try` / `finally`. |
| `return promise.then(...)` from a non-`async` function | Make the function `async` and `await`. |
| `void promise.then(...)` | Same as above — it is still a chain. |
| `.then()` inside `.then()` | The symptom this skill exists to prevent. |

`try` / `catch` / `finally` — the **language** constructs — are always fine.
Only the promise methods are banned.

## Allowed

- `async` functions that `await` their work.
- `await Promise.all([...])` and `await Promise.allSettled([...])` inside an
  `async` function. These are not chains: they are a single await on a
  collection.
- `await` inside a `for` loop when the work is genuinely sequential.
- The `useEffect` async IIFE (see below) — the single exception, because an
  effect callback cannot be `async`.
- `void someAsyncFn()` in a fire-and-forget spot, **only** when that function
  handles its own errors internally.

## Patterns

### Sequential work

```ts
// BAD
fetchUser()
  .then((user) => fetchOrders(user.id))
  .then((orders) => setOrders(orders))
  .catch((error) => console.error(error));

// GOOD
try {
  const user = await fetchUser();
  const orders = await fetchOrders(user.id);
  setOrders(orders);
} catch (error) {
  console.error(error);
}
```

### Parallel work

```ts
// BAD
Promise.all([fetchUser(), fetchOrders()]).then(([user, orders]) => ...);

// GOOD
const [user, orders] = await Promise.all([fetchUser(), fetchOrders()]);
```

### A shared, single-flight promise (dedup, refresh, cache)

The promise lives in a variable; the reset happens in `finally`, not in
`.finally()`.

```ts
let pending: Promise<string> | null = null;

export const refresh = async (): Promise<string> => {
  if (!pending) {
    pending = performRefresh();
  }
  const current = pending;
  try {
    return await current;
  } finally {
    if (pending === current) pending = null;
  }
};
```

Compare `pending === current` before resetting: a late `finally` must not
clear a newer in-flight promise.

### `useEffect`

An effect callback cannot be `async` — React would read the returned Promise
as a cleanup function. Use the inline async IIFE.

```ts
useEffect(() => {
  if (!enabled) return;
  (async () => {
    try {
      const data = await loadData();
      setData(data);
    } catch (error) {
      console.error("Could not load the data:", error);
    }
  })();
}, [enabled]);
```

This IIFE is the **only** exception to the rule. It is not a licence to write
`.then()` inside an effect.

### Event handlers and other fire-and-forget spots

```ts
// GOOD — the handler is async and handles its own errors
const onSubmit = async (event: FormEvent) => {
  event.preventDefault();
  try {
    await save();
  } catch (error) {
    console.error("Could not save:", error);
  }
};
```

## Converting a chain

1. Make the enclosing function `async`.
2. Replace each `.then(onFulfilled)` with `const value = await promise;`.
3. Replace `.catch(onRejected)` with `try` / `catch` around the awaits.
4. Replace `.finally(onFinally)` with `finally` in the `try` statement.
5. If the chain returned a value, `return` the awaited value.

## Checklist

- [ ] No `.then(`, `.catch(` or `.finally(` in the file.
- [ ] Every promise is awaited inside an `async` function.
- [ ] Errors are handled with `try` / `catch`, not a rejection callback.
- [ ] Parallel work uses `await Promise.all([...])`.
- [ ] Effects use the async IIFE.
- [ ] Shared promises are reset in `finally`, guarded against a stale reset.
- [ ] No floating promise: every promise is awaited, returned, or explicitly
      `void`-ed with internal error handling.

## What not to do

- Do not convert a chain into `await` inside a non-async function — make the
  function `async`.
- Do not use `await` in a loop to parallelize work; that is sequential by
  definition. Use `Promise.all` when the work is independent.
- Do not invent a wrapper to escape the rule. If the chain is awkward, the
  operation is usually better split into two `async` functions.
- Do not use this skill to rewrite promise chains in code the user did not
  touch — it applies to the code being written or changed.
