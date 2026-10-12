---
name: behavior-first-testing
description: Use when writing, reviewing, or modifying unit, component, integration, hook, or end-to-end tests for TypeScript, React, Vitest, or Playwright. Triggers on "write a test for", "add tests for", "is this test good", "TDD", "red-green-refactor", "test-driven", "regression test", "bug fix needs a test", "review my test", or when an existing test is being touched. Enforces disciplined Red-Green-Refactor, behavior-over-implementation, scenario-based granularity, mandatory preservation of existing identifiers and minimal-diff changes, and a final diff-review pass before declaring done.
license: MIT
compatibility: opencode agent (Agent Skills format); designed for Vitest + @testing-library/react + Playwright projects but the preservation and granularity rules apply to any language or framework.
metadata:
  audience: frontend-engineers
  topic: test-driven-development
  stack: typescript-react-vitest
  sources-verified: "2026-10-12"
  opencode/autoinvoke: "true"
---

# TDD — disciplined, behavior-first frontend testing

This skill enforces three rules that AI coding agents frequently violate:

1. **Preserve existing identifiers and code.** Never rename a working variable, function, prop, callback, export, or type just because you are editing the surrounding code. Make the smallest change that satisfies the requirement.
2. **Test meaningful behaviors, not individual lines.** One scenario per test. Multiple assertions are fine when they collectively prove one contract. Do not split a coherent scenario into many tiny tests, and do not pile unrelated behaviors into one giant test.
3. **Execute the failing test before writing the production code.** Strict TDD requires Red-Green-Refactor with verified execution. If you cannot run the test, say so — do not claim a cycle you did not complete.

These three rules are non-negotiable. Every other rule in this skill exists to support them.

## When this skill applies

Load this skill when **any** of the following are true:

- The user asks to add, change, or delete a test file.
- The user asks for a bug fix, feature, or refactor and the workflow requires test support.
- You are reviewing or modifying an existing test.
- A test failure needs diagnosis.
- You are choosing how to organize tests, how many to write, or what to assert.

If the change is purely a documentation edit or a non-functional config tweak, this skill is not needed.

## Read first

Before writing or changing any test, read in this order:

1. The target file's current implementation and its callers, types, and dependencies.
2. The nearest existing test file (`*.test.ts`, `*.test.tsx`, `*.spec.*`) to learn the established style.
3. `vitest.config.ts` / `vite.config.ts` for environment, setup files, and aliases.
4. `package.json` for installed versions of `vitest`, `@testing-library/react`, `@testing-library/user-event`, `@testing-library/jest-dom`, `@playwright/test`.
5. This skill's [`references/sources.md`](references/sources.md) for verified documentation URLs and the date each was checked.

If the project uses a different test runner or framework, switch to the equivalent tooling — the rules in this skill are framework-agnostic at the rule level. The Vitest + RTL specifics live in [`references/vitest-rtl-idioms.md`](references/vitest-rtl-idioms.md).

## The non-negotiable rules

### Rule 1 — Preserve existing identifiers and code

Read [`references/preservation.md`](references/preservation.md) for the full version. The headline:

- Preserve every existing variable, function, parameter, state, callback, prop, export, type, and test fixture name unless changing the name is required to satisfy the requested behavior or fix a demonstrated bug.
- Do not rename identifiers to match personal preferences, perceived style improvements, or a newly introduced abstraction.
- Do not rename across multiple files unless the change is necessary and all references, imports, tests, and public contracts are accounted for.
- Treat public exports, component props, event callbacks, data fields, and established domain terminology as contracts.
- When adding behavior, reuse existing variables, helpers, and patterns instead of introducing competing equivalents.
- Before editing, identify the smallest change that satisfies the requirement. Preserve unrelated logic, names, formatting, imports, and file structure. Avoid opportunistic refactors, file moves, broad formatting, and unrelated cleanup.
- A refactor is justified only when it improves maintainability or correctness **within the task's scope** and does not introduce disproportionate risk.

If the requested feature can be implemented without renaming existing identifiers, those identifiers **must remain unchanged**.

### Rule 2 — Test meaningful scenarios

Read [`references/scenario-granularity.md`](references/scenario-granularity.md) for the full version. The headline:

- Organize tests around **one meaningful behavior per `it`**. Not one assertion, not one source line, not one branch fragment.
- Multiple related assertions are encouraged when they collectively prove one scenario's contract.
- Several sequential user actions can belong in one test when they form a coherent user journey or state transition.
- Separate scenarios when they represent independently failing behaviors, distinct requirements, materially different preconditions, or substantially different failure modes.
- Use `it.each([...])` for parameterized cases that exercise the same rule with multiple inputs — they belong together.
- Before creating a test, answer four questions:
  1. What real behavior or contract does this protect?
  2. What regression would cause it to fail?
  3. Would a harmless refactor break it even though the behavior remains correct?
  4. Is the behavior already adequately covered by another test?

If the only thing a test proves is that a variable exists, an assignment executed, a class name was added, or a line was called, it usually provides no meaningful regression protection. Delete it or rewrite it.

### Rule 3 — Red-Green-Refactor with verified execution

Read [`references/red-green-refactor.md`](references/red-green-refactor.md) for the full version. The headline:

- **Red**: write the failing test first. Execute it. Confirm it fails for the right reason (missing behavior, not invalid setup). If it passes before any production code exists, the test is not asserting anything.
- **Green**: write the minimum production code to make the failing test pass. Do not refactor unrelated code. Do not rename anything. Run the test and confirm it passes.
- **Refactor**: clean up while the test stays green. Rename or restructure only if it improves maintainability **and** the test still describes behavior, not internals.
- A Red-Green-Refactor cycle that exceeds 15–20 minutes is too large. Decompose.
- If you cannot execute tests (no runtime, missing dependency, sandboxed environment), state the limitation clearly. Do not claim TDD compliance for tests you did not run.

## The mandatory final diff review

Before declaring the task complete, walk through the checklist in [`references/final-diff-review.md`](references/final-diff-review.md). Every item must hold or be explicitly justified.

If any item fails, **revert the change or fix it before reporting completion**. Do not bury the violation in a summary.

## Stack-specific guidance

| Topic | Where it lives |
| --- | --- |
| Vitest + RTL + user-event idioms for this repo | [`references/vitest-rtl-idioms.md`](references/vitest-rtl-idioms.md) |
| Frontend testing strategy (unit, component, integration, e2e, MSW) | [`references/testing-strategy.md`](references/testing-strategy.md) |
| Bug fixes and regression tests | [`references/regression-bugfixes.md`](references/regression-bugfixes.md) |
| Shared UI component / registry boundaries | [`references/registry-and-shared-ui.md`](references/registry-and-shared-ui.md) |
| Verified documentation sources | [`references/sources.md`](references/sources.md) |

If the project does not use Vitest, MSW, or Playwright, the strategy and idiom files still apply — substitute the equivalent tooling (Jest, fetch stubs, Cypress, etc.) and match the same rules.

## Anti-patterns this skill explicitly rejects

- Renaming a working variable because the surrounding code is being edited.
- One trivial test per source line, branch, or assignment.
- Giant tests that combine unrelated behaviors and make failures hard to diagnose.
- Tests with no meaningful assertions ("it works").
- Tests that duplicate the implementation's algorithm (re-implementing the function inside the test).
- Excessive mocking of internal modules to "prove" the test works.
- Snapshot tests used as a substitute for behavioral assertions.
- Arbitrary `setTimeout` / `sleep` waits in place of proper async queries.
- Shared mutable state between tests.
- Suppressed errors (`catch {}`) or disabled tests (`it.skip`, `xit`) to make the suite green.
- Coverage numbers treated as proof of quality.
- Unrelated formatting, reordering, or cleanup rolled into a feature change.
- Dependency upgrades smuggled into a test change.

## Quick self-check before reporting done

- [ ] Every test asserts a real user-observable contract, not an internal variable.
- [ ] No test was added "to fill out" the diff.
- [ ] No identifier outside the scope of the change was renamed.
- [ ] No unrelated code was reformatted, reordered, or extracted.
- [ ] Tests run in isolation — no shared mutable state between tests.
- [ ] Every async call is `await`ed; state updates from outside React are wrapped in `act()`.
- [ ] Mocks are restored (`vi.restoreAllMocks()` / `vi.useRealTimers()`).
- [ ] The failing test was executed before the production code was written, or the limitation was stated.
- [ ] The final diff review checklist passed.