# Skill: git-respect-worktree

# Never mutate the user's git state without explicit permission

The user's worktree is theirs. You can read from it freely (`git status`, `git log`, `git diff`, `git show`, etc.) but you do NOT touch it without being asked. No `git add`, no `git stash`, no `git mv`, no `git rm`, no `git reset`, no `git checkout <ref> -- <path>`, no `git commit`, no `git push`, no `git branch -d`, no `git tag`, no `git clean`, no `git worktree`.

## Why

The user has their own workflow. They stage, commit, push, branch, stash — when THEY choose, in the order THEY want. When you run a git mutation, you're imposing your judgment on their state: you're deciding what gets staged, what gets moved, what gets deleted. That's their call.

The agent's job is to edit FILES (`Edit`, `Write`, plain `mv`, plain `rm`), not to edit HISTORY.

## Permitted without asking — read-only

Anything that only reports state:

- `git status` (incl. `git status --short`, `git status -sb`)
- `git log`, `git log --oneline`, `git log --all`, `git log -p`
- `git diff`, `git diff --stat`, `git diff --staged`, `git diff <ref>`
- `git show <sha>`, `git show <ref>:<path>` (read-only — see "redirect file" rule below)
- `git branch -a`, `git branch -vv`, `git branch --show-current`
- `git remote -v`, `git remote show <name>`
- `git reflog`
- `git stash list` (read the list, don't pop)
- `git ls-files`, `git ls-tree`
- `git blame <file>`
- `git config --get <key>` (read only)

## Forbidden without explicit user permission

Anything that mutates the worktree, the index, refs, or remotes:

- `git add` — don't stage anything
- `git mv` — don't rename tracked files (use plain `mv` instead)
- `git rm` — don't delete tracked files (use plain `rm`; the user can `git add` the deletion when they want)
- `git stash`, `git stash pop`, `git stash apply`, `git stash drop` — don't stash anything
- `git reset` in any form (`--soft`, `--mixed`, `--hard`) — don't rewrite the index or worktree
- `git checkout <ref> -- <path>`, `git restore`, `git restore --staged`, `git restore --worktree` — don't replace worktree files
- `git commit`, `git commit --amend` — don't commit
- `git push`, `git pull`, `git fetch`, `git fetch --prune` — don't sync with remotes
- `git branch` (anything other than `-a`, `-vv`, `--show-current`) — don't create / delete / rename branches
- `git tag` — don't tag
- `git rebase`, `git merge`, `git cherry-pick`, `git revert` — don't rewrite history
- `git clean` — don't delete untracked files
- `git worktree add`, `git worktree remove` — don't manage worktrees
- `git submodule add`, `git submodule update`, etc.

## Tells that you're about to violate this — STOP and ask

- "I'll just `git mv` to clean this up" — STOP.
- "Let me `git add` these for you" — STOP.
- "I'll `git stash` this so we can test something else" — STOP.
- "Let me `git reset` to undo" — STOP (or use plain filesystem ops).
- "I'll `git commit -m "..."` to save progress" — STOP.
- "I'll do `git checkout HEAD --` to restore that file" — STOP.
- You typed `git ` followed by anything not in the read-only list above — STOP.

## What to do instead

- To move a file: plain `mv` (or `Edit` + `Write` at new path + plain `rm` of old). Tell the user where the file is now.
- To "undo" a file change: use `Edit` to restore its content, or plain `rm` if it shouldn't exist.
- To track a new file: leave it on disk. Tell the user "new file at <path>" so they can `git add` it.
- To commit: write the proposed commit message in your response and let the user run `git commit`.
- To check state: `git status --short`, `git diff --stat`, etc. (all read-only).
- To restore a file from another ref (rare): `git show <ref>:<path> > <path>` — `git show` is read-only, the redirect is a plain file write. This is fine.

## When the user explicitly asks for a git operation

If the user says "commit this", "stash it", "create a branch X", "merge main in", etc., THEN do it. Use the operation they named, with sensible defaults:

- Don't `git push` unless they said "push" too.
- Don't force-push (`--force`, `-f`) ever.
- Don't use interactive flags (`-i`) without asking.
- Don't pass `--no-verify` / skip hooks.
- If they say "commit and push", do both — but ask before pushing if it wasn't explicit.

If they give a multi-step instruction like "merge main and resolve conflicts", do each git step they named — don't sneak in extra `git commit --amend` or `git push` at the end.

## Undoing your own mess

If you accidentally mutated the worktree (e.g. ran `git mv` without permission), use plain filesystem ops to undo:

- For a misplaced file: plain `mv` it back to its original location.
- For a staged change: `git reset --mixed HEAD` is the *one* allowed exception — it only un-stages, it never modifies the worktree. If you can avoid even that, do so (just tell the user what's currently staged).
- For a commit you shouldn't have made: tell the user the SHA and offer a `git reset --mixed <prev-sha>` command they can run themselves.

The principle: never silently "fix" your mistakes by running more git commands. Surface what you did and let the user decide.