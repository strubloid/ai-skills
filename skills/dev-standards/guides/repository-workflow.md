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
