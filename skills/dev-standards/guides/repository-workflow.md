# Repository workflow

Use this guide for Git operations, environment/credential-sensitive paths, and
commit-message work. Protect user state and secrets before optimizing workflow.

## Choose specialist guidance

| Concern | Detailed guide | Apply when |
|---|---|---|
| Protecting environment and credential files | [`protect-env-files`](workflow/protect-env-files.md) | Every request where a tool might encounter environment or credential files |
| Read-only Git policy | [`read-only-git`](workflow/read-only-git.md) | Any coding task involving Git or a possible Git mutation; this is the primary rule |
| Respecting user worktree state | [`git-respect-worktree`](workflow/git-respect-worktree.md) | Additional safeguards when a decision could change files, the index, branches, or history |
| Conventional Commit formatting | [`conventional-commits`](workflow/conventional-commits.md) | Writing or reviewing a commit message only |

## Shared principles

- Treat Git state as user-owned. Read status and diffs freely; do not stage,
  commit, restore, reset, stash, branch, merge, rebase, or push unless the user
  explicitly asks for that operation in the current turn.
- Never read, print, copy, search, or summarize `.env`/credential contents.
  Use variable names, safe templates, and typed accessors instead.
- Keep commit-message standards separate from changelog, PR-title, and branch
  naming conventions.
- If an operation could affect user files, environment state, or the Git index,
  inspect first and ask before doing it unless the user explicitly requested it.

## Dependency advisory handling

- Verify the resolved package tree with `npm ls` and `npm audit` before changing versions. Identify whether each finding is direct or transitive and which parent introduces it.
- Treat a package advisory as dependency risk, not automatically as an application-code defect. Check whether the affected package is present in the lockfile and whether the project directly invokes the affected capability before describing exploitability.
- Prefer updating the direct dependency or the affected parent package to a compatible patched release. Use an `overrides` entry only when the parent cannot yet be upgraded; verify the override against the parent's declared range and run the relevant tests.
- For a major-version fix, check the package's peer ranges and run typecheck, tests, lint, and build after updating both the manifest and lockfile.
- Verify the resolved versions again with `npm ls` and `npm audit`. Report remaining advisories and distinguish them from the advisories that were resolved.
