# Red-Green-Refactor — the TDD cycle, with verification

This is the long version of Rule 3 in `SKILL.md`. The cycle must be **executed**, not narrated. If you cannot run the test, say so.

## The three laws of TDD

1. Production code is not written until there is a failing unit test.
2. The test is not written beyond the amount needed to fail.
3. Production code is not written beyond the amount needed to pass the failing test.

## The cycle

Always cycle, in this order, in small steps:

### Red — establish the expected behavior

1. Inspect the existing implementation and tests.
2. Understand the requested behavior and identify acceptance criteria.
3. Select a meaningful scenario.
4. Write the test **before** implementing the behavior.
5. Execute it and confirm it fails for the expected reason.
6. Ensure the failure is not caused by invalid test setup, imports, configuration, or missing dependencies.

If the test already passes, investigate whether:

- The behavior already exists.
- The test is ineffective (asserting nothing real).
- The test is a duplicate of an existing test.

### Green — make the smallest implementation change

1. Implement the minimum necessary change.
2. Preserve existing working variable names and APIs.
3. Reuse existing helpers and logic where appropriate.
4. Do not refactor unrelated code.
5. Run the new test and confirm it passes.
6. Run related tests to identify regressions.

### Refactor — improve without changing behavior

1. Refactor only when there is a meaningful maintainability or correctness benefit.
2. Preserve existing identifiers unless renaming is necessary.
3. Avoid speculative abstractions and stylistic rewrites.
4. Run relevant tests again after refactoring.
5. Inspect the final diff for unintended changes.

## Cycle time

If a cycle takes longer than 15–20 minutes, the behavior increment is too large. Decompose into smaller pieces and restart at Red.

## When you cannot execute tests

If the environment prevents execution (no test runner available, missing dependency, sandboxed context, no network), you must:

- Explain the limitation clearly in the report.
- Distinguish **written** tests from **verified** tests.
- Not assert TDD compliance for tests that were never run.

A test you wrote but did not run is a draft. A test you ran and confirmed fails-then-passes is a verified cycle.

## Common Red-Green mistakes

### Writing the test after the code

If you wrote the production code first, you did not do TDD. You wrote tests for existing code. That is still useful, but it is not TDD. Label it accurately: "I added test coverage for existing behavior" rather than "I followed TDD."

### Writing a test that passes immediately

If the test passes before any production code exists, the test is not asserting the new behavior. Either:

- The behavior already exists — find out before adding a duplicate.
- The test is asserting nothing — fix the assertion.
- The test is asserting something trivially true (e.g., `expect(true).toBe(true)`).

### Skipping Red

"I wrote the test and the code at the same time" is not TDD. You did not observe the failure. You cannot claim the test caught a missing behavior.

### Skipping Green

If you wrote the test, did not run it, and the suite is green, you have not verified the test does what you think. Run it.

### Refactoring instead of going Green

If the production change is "the simplest possible code," then a refactor inside the Green step is usually scope creep. Move the refactor to the Refactor step (or do not do it).

## Verification commands for this repo

The standard sequence:

```bash
# Run only the new file first (fastest signal)
npx vitest run registry/<component>/<file>.test.ts

# Run the full suite to catch regressions
npm test

# Type and lint
npm run typecheck
npm run lint
```

Match the project's package manager (`npm`, `pnpm`, `yarn`, `bun`). Do not introduce a new package manager to "fix" a test workflow problem.