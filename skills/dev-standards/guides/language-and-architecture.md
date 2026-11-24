# Language and architecture

Use this guide for implementation choices in JavaScript, TypeScript, and
application modules. Check the target project's compiler options, runtime,
existing abstractions, and local conventions before applying these preferences.

## Choose specialist guidance

| Concern | Detailed guide | Apply when |
|---|---|---|
| General modern code review and language idioms | [`modern-idiomatic-code`](web/modern-idiomatic-code.md) | Reviewing or changing code quality, maintainability, or language patterns |
| TypeScript class design and compiler constraints | [`typescript-class-conventions`](code/typescript-class-conventions.md) | The task uses TypeScript classes; verify compiler assumptions against the actual project |
| Naming computed values in API/domain mappers | [`named-mapping-consts`](code/named-mapping-consts.md) | Writing or reviewing a mapper with derived values |
| Additive module pattern | [`additive-module`](code/additive-module.md) | Only when the target architecture uses a globally accessible Zustand singleton and the task fits that pattern |

## Shared principles

- Prefer clarity, behavior, and project fit over novelty. Do not refactor passing
  code only to make it look newer.
- Prefer inference for obvious local values and explicit types at public
  boundaries. Narrow unknown values before use; avoid casts that conceal a real
  mismatch.
- Keep asynchronous control flow readable and errors actionable. Use parallel
  execution only for independent work and preserve intentional sequencing.
- Keep module boundaries aligned with existing architecture. Do not introduce a
  global store, class, service layer, or abstraction merely because an example
  in a specialist skill uses one.
- Use discriminated state models when they clarify real state transitions; do
  not add type scaffolding to trivial data.
- Treat project-specific compiler constraints (such as `erasableSyntaxOnly`)
  as conditional facts to verify, never universal TypeScript rules.
