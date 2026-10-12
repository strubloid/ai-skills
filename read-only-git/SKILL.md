---
name: read-only-git
description: Use when a coding task might touch version control. The agent runs no mutating git command unless the user asked for that exact action in the current turn. Read-only git (status, log, diff, show, branch -a, remote -v, reflog, stash list) stays available for context. Triggered by "commit this", "push it", "create a branch", "merge", "rebase", "stash this", "I forgot what I stashed", or any turn where the agent is tempted to "clean up" with git.
---

# Git is read-only unless explicitly asked

You do not own the repo's history. Every mutating git command — commit, push, branch create/delete, merge, rebase, stash, reset, restore, clean, checkout between branches — is the user's call. Ask first, every time, in the current turn.

If a task seems to require git (e.g. the user says "commit this"), run only the command they named. Do not add `git add` you weren't asked for, do not amend, do not push, do not create a branch they didn't name.

## Why this rule exists

Agents have repeatedly destroyed work with the same handful of commands. Every one of these has a documented incident:

- `git reset --hard` — discards uncommitted edits; Claude Code reportedly did this on a 10-minute loop, wiping hours of work before the user noticed.
- `git checkout .` / `git restore <path>` — silently reverts tracked files to HEAD; a Cursor agent did this to a user's `Biblio/ref.bib` and lost entries that weren't recoverable.
- `git clean -fd` — deletes untracked files; no reflog, no undo.
- `git stash` / `git stash pop` — agents stash and forget. Across sessions the stash list is invisible and the work looks gone forever.
- `git push --force` — rewrites remote history; Cline force-pushed during a merge and erased a teammate's work.
- `git rebase -i` / `git filter-repo` — historical rewrites; one incident deleted four production files from every commit.
- `git commit --amend` — rewrites the last commit, including things the user already reviewed.
- `git branch -D` — deletes a branch even if its commits are unmerged elsewhere.

Plain git keeps no copy to restore from after these. The user has to do the forensics.

## What you can run without asking

Read-only, no state change, recoverable by re-running:

- `git status`
- `git log`, `git log -p`, `git log --oneline`, `git log --stat`
- `git diff`, `git diff --staged`, `git diff <ref>`, `git diff --cached`
- `git show <ref>`
- `git branch` (list only — never `-d` / `-D`), `git branch -a`, `git branch --list`
- `git remote -v`
- `git reflog` (reading; don't act on it)
- `git stash list` (reading; never pop/drop/apply)
- `git blame <file>`, `git ls-files`

These are safe for getting context. Run them when you need to understand state, before suggesting next steps to the user.

## What you must never run

Never run these unless the user typed the exact command in the current turn:

| Command | What it can break |
| --- | --- |
| `git add`, `git add -A`, `git add .` | Stages things the user didn't review |
| `git commit`, `git commit -m`, `git commit -am` | Creates a commit the user didn't author |
| `git commit --amend` | Rewrites the last commit |
| `git push`, `git push --force`, `git push -f`, `git push --force-with-lease` | Publishes / rewrites remote |
| `git pull`, `git pull --rebase` | Moves local branch pointer |
| `git fetch`, `git fetch --prune` | Modifies remote-tracking refs |
| `git merge`, `git merge --no-ff`, `git merge --squash` | Creates merge commit |
| `git rebase`, `git rebase -i` | Rewrites local history |
| `git cherry-pick`, `git revert` | Replays / undoes commits |
| `git checkout <ref-or-branch>` | Switches branches or restores files |
| `git switch <branch>` | Switches branches |
| `git restore`, `git restore <path>`, `git restore .` | Reverts working-tree files to HEAD |
| `git reset`, `git reset --hard`, `git reset --mixed`, `git reset HEAD~1` | Discards commits or staged work |
| `git clean`, `git clean -fd`, `git clean -fdx` | Deletes untracked files |
| `git stash`, `git stash push`, `git stash pop`, `git stash drop`, `git stash apply`, `git stash clear` | Hides work; easy to forget |
| `git branch -d`, `git branch -D`, `git branch --delete` | Deletes a branch (and possibly its commits) |
| `git tag -d`, `git tag --delete` | Deletes a tag |
| `git worktree add`, `git worktree remove` | Changes worktree layout |
| `git remote remove`, `git remote add`, `git remote set-url` | Changes remotes |
| `git config --global`, `git config --system` | Modifies git config outside the repo |
| `git filter-branch`, `git filter-repo` | Historical rewrite of every commit |

This list is not exhaustive. The principle is: if the command could leave the working tree, branch pointer, index, stash, remote, reflog, or history different than the user left it, don't run it without explicit instruction.

## What to do instead

When you want to suggest a git action:

1. Show the user the exact command you would run.
2. Explain what it would change.
3. Wait for them to say "yes" or "do it" before running it.

When the user types a git command for you:

1. Run only that command.
2. Do not chain additional git commands to "complete" the workflow. `git commit -m "feat: ..."` does not imply `git push` or `git add` of untracked files.
3. Do not pre- or post-clean with `git reset`, `git restore`, or `git checkout`.

When you need state to make a code decision (e.g. "what changed in this branch?", "is this staged?"), use the read-only list above.

## Edge: bash heredocs and `&&` chains

A destructive command hidden in a longer bash chain still counts. `git status && git checkout .` is two commands; the second one is forbidden. Refuse the whole chain or split it and run only the safe prefix after asking.

## Edge: agent's own stash

If you do run `git stash` in a session — only because the user asked — write the stash ref and a one-line description of what was stashed into the response. The user can't recover what they can't see.

## When the user says "commit this"

Run `git commit -m "<message they wrote>"` only. If they haven't given a message, ask. If you think you know a good message, suggest it in prose and let them type the command. Don't assume `git add` is implied — list the files you think should be in the commit and confirm.