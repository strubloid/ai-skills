# Bug fixes and regression tests

Every bug fix must come with a regression test. This is the long version of the bug-fix workflow in `SKILL.md`.

## The discipline

When fixing a bug:

1. **Reproduce the incorrect behavior.** Confirm you understand what the user saw.
2. **Write a regression test that fails because of the bug.** The test should describe the *correct* behavior, not the bug itself. "Renders the success state when the form is valid" — not "renders the error state when the bug occurs."
3. **Confirm the test fails for the right reason.** It should fail because the production code is wrong, not because the test setup is wrong.
4. **Implement the smallest fix.** Change only what is required. Preserve existing identifiers (Rule 1).
5. **Verify the regression test passes.**
6. **Run related tests** to catch collateral damage.
7. **Check that unrelated behavior remains unchanged** — re-read the diff.

## What a good regression test looks like

A regression test:

- Describes the correct behavior in a present-tense scenario.
- Asserts the user-observable outcome, not the internal state.
- Would have caught the bug at the moment the bug was introduced.
- Does not break when the implementation is refactored (as long as the behavior is preserved).

A bad regression test:

- Asserts only that the component renders ("renders without crashing").
- Asserts only that the error state shows ("renders error message").
- Re-asserts the bug ("throws TypeError on invalid input") — the test name and assertion should describe the fix, not the symptom.
- Is so tightly coupled to the implementation that any refactor breaks it.

## What NOT to do

### Do not replace a precise regression test with a generic one

If the bug was "the form did not validate emails with subdomains correctly," the regression test is "rejects an email like `a@b.c`" or "accepts an email like `[email protected]`." Do not replace it with "the form renders" — that loses the regression value.

### Do not weaken assertions to make the suite pass

If a test fails after the fix, the question is *why*. The reasons can be:

- The fix is wrong.
- The test is wrong (asserted the wrong thing).
- The test environment changed.
- An unrelated change broke the test.

Diagnose the root cause. Do not relax the assertion or skip the test to make it green. If the fix genuinely requires the test to change, update both together with a justification.

### Do not change expected behavior to make the test pass

If the bug report describes the desired behavior and the test expects the *current* (buggy) behavior, the test is wrong. Update the test to match the desired behavior, then fix the code. The test should describe the contract, not the status quo.

## When the test already exists but was not catching the bug

If a test already covers the area of the bug but did not catch it, the test is testing the wrong thing. Diagnose:

- Did it assert implementation details that the bug bypassed?
- Did it use a query that did not actually find the broken element?
- Did it mock the very thing that was broken?
- Did it stop at a state that the bug does not produce?

Rewrite the test to assert the actual user-observable contract. Do not just add a second test on top of the broken one.

## When the bug is in a shared / dependency module

If the bug is in a third-party module:

- Verify it really is in the dependency, not in your wrapper.
- File or find the upstream issue.
- Add a regression test that pins the dependency version or documents the workaround.
- If you must patch the dependency locally, write the regression test first.

If the bug is in a shared registry component (this repo's `registry/` directory), see [`registry-and-shared-ui.md`](registry-and-shared-ui.md) for the additional constraints.

## Final check

Before reporting the bug fix as done:

- [ ] The regression test fails without the fix and passes with the fix.
- [ ] The regression test describes the correct behavior, not the bug symptom.
- [ ] The fix is the smallest change that resolves the bug.
- [ ] No unrelated code was changed.
- [ ] Existing identifiers in the file were preserved.
- [ ] Related tests still pass.
- [ ] The diff review checklist in [`final-diff-review.md`](final-diff-review.md) was applied.