---
name: typescript-class-conventions
description: Use when writing, reviewing, or refactoring a TypeScript class — "the correct way to write a class", class vs object literal vs plain functions, static vs instance methods, private members, constructor shape, or when a module's API surface should become a class.
---

# The correct way to write a class

A class is a tool, not a container. This skill says when to reach for one, what
shape it should take in a TypeScript project, and what compiler options may reject.

---

## 1. When a class is the right tool

Use a class when **at least one** of these is true:

| Reason | Example |
| --- | --- |
| The type owns state and the behaviour that mutates it | A `Session` that holds a token and renews it |
| You need encapsulation — a public surface plus a private implementation | An API client whose request helpers are internal |
| The API benefits from method chaining | `builder.withHeader().withTimeout().build()` |
| The type is a domain concept with a lifecycle | A `Cart`, a `Subscription`, a `Session` |

**Do not** use a class as a namespace for a bag of stateless functions. That is
the shape this skill exists to replace:

```ts
// ❌ A class used only to group functions — no state, no encapsulation,
//    and it blocks tree-shaking and module mocking.
export class AuthApi {
  static async login() { /* … */ }
  static async logout() { /* … */ }
}
```

Plain exported functions are the right answer for a stateless module:

```ts
// ✅ Tree-shakable, mockable with `vi.mock`, no `this`.
export async function login(username: string, password: string) { /* … */ }
```

If the module has no state but you still want one namespace, use an **object
with a declared interface**, not a class:

```ts
export interface AuthService {
  login(username: string, password: string): Promise<AuthSession>;
}

export const authService: AuthService = { /* … */ };
```

---

## 2. Check the project's TypeScript constraints

If the project's `tsconfig` enables `erasableSyntaxOnly`, every file must stay
runnable after types are stripped (for example, by Node's native type stripping).
The compiler rejects:

- `enum`
- `namespace` / `module` with runtime code
- **parameter properties** — `constructor(private port: number) {}`
- `import =` / `export =`
- `<Type>value` assertions

Write the field out instead:

```ts
// ❌ compile error under erasableSyntaxOnly
class Server {
  constructor(private readonly port: number) {}
}

// ✅ explicit field, assigned in the constructor
class Server {
  private readonly port: number;

  constructor(port: number) {
    this.port = port;
  }
}
```

Follow established examples in the target project when they do not conflict
with its compiler settings.

---

## 3. Shape of a class

- **`export class PascalCaseName`** — named export, always. No `export default`
  for a class.
- **One class per file.** The file name matches the class: `auth-api.ts` →
  `AuthApi`.
- **Fields are declared explicitly** and initialised in the constructor. With
  `target: es2023`, `useDefineForClassFields` is on: a field is *defined*, not
  assigned, so a subclass field shadows the parent field rather than
  overwriting it.
- **Declaration order inside the class body** — readers scan top to bottom and
  expect this order:

  1. private static members
  2. public static members
  3. `static {}` blocks
  4. `#private` instance fields
  5. `protected` fields
  6. `public readonly` fields
  7. `public` mutable fields
  8. constructor
  9. static methods
  10. public methods
  11. protected methods
  12. private methods

- **No trailing commas between methods.** A class body is not an object
  literal — methods are separated by blank lines, not `,`.
- **Explicit access modifiers.** `private` and `protected` must be written out;
  `public` is the default and may be omitted.
- **No `enum`, no `namespace`.** Use an `as const` tuple plus a derived union.

---

## 4. Instance vs static

| Use | When |
| --- | --- |
| Instance method | Needs `this`, or belongs to an object that holds state |
| Static method | Genuinely stateless **and** must be callable without an instance |

Do not keep two flavours of the same operation on one class.

**`this` is bound at call time.** Destructuring a method loses it:

```ts
const { login } = authApi;   // ❌ `this` is undefined inside
login("a", "b");

await authApi.login("a", "b");  // ✅ method call — `this` is the instance
```

If a method must survive destructuring, bind it in the constructor or make it
an arrow-function field. Do not do it "just in case".

---

## 5. `private` vs `#private`

| Modifier | Enforced at | Use for |
| --- | --- | --- |
| `private` | compile time only | The default. Implementation detail of the class. |
| `#private` | runtime | An invariant that must hold even against JS callers, `any` casts, or reflection. |

`#private` costs you `in` checks, structural typing, and easy mocking in
tests. Reach for `private` first.

---

## 6. Async methods

- `async` methods annotate the **resolved** type: `async login(): Promise<AuthSession>`.
- Never a `.then()` chain inside a method — `await` inside `async`
  (see `async-await-only`).
- **Do not mark a method `async` when it only hands back a promise.** `async`
  adds a wrapper and an extra microtask hop for nothing:

```ts
// ❌ pointless async wrapper
async logout(): Promise<void> {
  await endSession();
}

// ✅ return the promise
logout(): Promise<void> {
  return endSession();
}
```

- A method that awaits several independent calls uses `await Promise.all([...])`
  — never a chain.

---

## 7. The public surface

The public surface is the smallest set that a consumer needs. Everything else
is `private`. A method that only exists to serve another method of the same
class does not belong on the public surface.

Expose the class **and** an instance when the module is a service:

```ts
export class AuthApi {
  /* … */
}

export const authApi = new AuthApi();
```

The class export lets a consumer type against it, construct its own instance in
a test, or inject a fake. The instance is the default.

---

## 8. JSDoc on a class

Document the **contract**, not the body:

- What it does.
- What it accepts, when the names are not obvious.
- What it returns, when the shape is not obvious from the signature.
- **When it throws.**

Never restate the signature:

```ts
// ❌ noise — the signature already says all of this
/**
 * @param username username of the user
 * @returns a Promise that resolves to an AuthSession
 */

// ✅ the contract the signature cannot express
/**
 * Authenticates the user and returns the session the rest of the app runs on.
 *
 * @throws {ApiError} `invalid_credentials` when the login is rejected,
 * `account_locked` when the account is locked, `network` when the server
 * cannot be reached.
 */
```

No file-header comments. No section dividers inside the class body. See
`comment-why-not-what`.

---

## 9. Anti-patterns

```ts
// ❌ Object literal masquerading as a class — every member needs a trailing
//    comma and the module can never be instantiated or subclassed.
export const authApi = {
  async login() { /* … */ },
  async logout() { /* … */ },
};

// ❌ Parameter property — banned by erasableSyntaxOnly
class Server {
  constructor(private port: number) {}
}

// ❌ Static-only class — no state, no encapsulation, blocks tree-shaking
export class Utils {
  static format(value: string) { /* … */ }
}

// ❌ Destructured method loses `this`
const { login } = authApi;

// ❌ Unnecessary `async`
async logout(): Promise<void> {
  await endSession();
}

// ❌ JSDoc that restates the signature
/** @param id the id */
```

---

## 10. Checklist before calling it done

- [ ] The class earns its place — state, encapsulation, or a domain lifecycle.
- [ ] No parameter properties when prohibited by the project's TypeScript settings.
- [ ] Named export, one class per file, file name matches the class.
- [ ] Fields declared explicitly and assigned in the constructor.
- [ ] Declaration order followed.
- [ ] Public surface is the smallest set that works; the rest is `private`.
- [ ] No trailing commas in the class body.
- [ ] `this` is only used in methods that are called as methods.
- [ ] Async methods return `Promise<T>` and use `await`, never `.then()`.
- [ ] JSDoc documents the contract, not the signature.
- [ ] The project's relevant lint and type-check commands pass.

---

## Sources

Checked 2026-10-30. Re-verify before citing.

- TypeScript Handbook — Classes: <https://www.typescriptlang.org/docs/handbook/classes.html>
- `erasableSyntaxOnly`: <https://www.typescriptlang.org/tsconfig/erasableSyntaxOnly.html>
- TypeScript interop constraints: <https://www.tslang.org/en/config/compiler-options/interop-constraints>
- Static classes: patterns and pitfalls: <https://www.devcrea.com/static-classes-in-typescript>
- Static methods vs object with function properties (mocking, DI, tree-shaking):
  <https://stackoverflow.com/questions/78681442/javascript-class-with-static-methods-vs-object-with-function-properties>

---

## Related

- `modern-idiomatic-code` — the general language standards.
- `async-await-only` — how promises are consumed inside a method.
- `comment-why-not-what` — what a JSDoc is allowed to say.
- `modify-in-place` — how to apply these rules without churning the file.
- `behavior-first-testing` — how to test a class without mocking it into oblivion.
