# Final diff review — the mandatory checklist

Before reporting the task complete, inspect the diff relative to the initial state. **Inspect it, do not assume it.** Every item must hold or be explicitly justified.

If any item fails, **revert the change or fix it before reporting completion**.

## Identifier preservation

- [ ] Were existing variable names preserved?
- [ ] Were any functions, props, callbacks, exports, or types renamed unnecessarily?
- [ ] Were any variables renamed across multiple files?
- [ ] Were test fixture names changed without a behavioral reason?
- [ ] Did I preserve the established terminology (e.g., `pinnedLeft`, `pinSide`, `stickStyle`)?

## Scope and minimality

- [ ] Was any unrelated code rewritten?
- [ ] Were files reformatted without need?
- [ ] Were imports reordered or restructured?
- [ ] Were helpers extracted from code that runs once?
- [ ] Were unrelated types or interfaces updated?

## Test quality

- [ ] Are the tests organized around meaningful scenarios (not one per line)?
- [ ] Do the assertions prove actual behavior (not internal state)?
- [ ] Does each test have a clear purpose?
- [ ] Were any existing assertions weakened or removed?
- [ ] Were redundant tests introduced that overlap with existing coverage?
- [ ] Were tests added to make the diff look bigger, not to cover real behavior?

## Implementation discipline

- [ ] Did the implementation introduce unnecessary abstractions?
- [ ] Did it introduce new dependencies without a demonstrated need?
- [ ] Were existing helpers reused where appropriate?
- [ ] Were existing public APIs and behavior preserved?

## TDD discipline

- [ ] Was the failing test executed before the production code was written?
- [ ] If not, was the limitation clearly stated in the report?
- [ ] Was the passing test executed after the production code change?
- [ ] Did I run related tests to catch collateral regressions?

## Regression safety

- [ ] Are relevant existing behaviors preserved?
- [ ] Did I run the broader test suite (`npm test` / equivalent), not just the file I changed?
- [ ] If a test failure was caused by my change, was it diagnosed and fixed — not ignored?

## Reporting

- [ ] The report distinguishes between written tests and verified tests.
- [ ] The report lists the exact commands executed and their results.
- [ ] The report identifies any checks that could not be performed.
- [ ] The report does not claim TDD compliance for cycles that were not executed.

## What "clean diff" actually means

A clean diff is not "the diff is short." A clean diff is:

- Every changed line is required for the requested behavior.
- No changed line is there because the agent prefers a different style.
- No test was added to inflate the diff.
- No identifier was renamed because the agent thinks a different name is better.
- The diff could be reviewed line-by-line and every line would be approved by a senior engineer reading "what does this line do?" and answering "implements the requested behavior."

If you cannot honestly answer "yes" to each line, the diff is not clean. Revert and re-do.