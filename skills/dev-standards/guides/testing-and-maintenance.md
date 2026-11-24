# Testing and maintenance

Use this guide for bug fixes, refactors, test changes, and edits to existing
files. Preserve behavior unless the user requests a behavior change.

## Choose specialist guidance

| Concern | Detailed guide | Apply when |
|---|---|---|
| Behavior-first tests and red/green/refactor | [`behavior-first-testing`](testing/behavior-first-testing.md) | Adding or changing tests, fixing behavior, or reviewing test quality |
| Minimal in-place changes | [`modify-in-place`](maintenance/modify-in-place.md) | Modifying any existing file |
| Intent-focused comments and documentation comments | [`comment-why-not-what`](maintenance/comment-why-not-what.md) | Adding, reviewing, or rewriting code comments or JSDoc |

## Shared principles

- For a bug fix, identify the user-visible behavior and prove it with the
  narrowest meaningful test available. Do not assert implementation details.
- When modifying tests, read the implementation and nearby test conventions
  first. Do not claim a test was run unless it actually ran.
- Keep names, order, and surrounding structure unless the requested change
  requires changing them. Do not bundle unrelated cleanup into a fix.
- Comments should explain non-obvious intent or constraints, not narrate the
  next line of code.
- Finish with a diff review and run checks appropriate to the actual change.
