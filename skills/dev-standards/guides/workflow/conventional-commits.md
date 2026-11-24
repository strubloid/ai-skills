---
name: conventional-commits
description: Use when writing, reviewing, or formatting git commit messages per the Conventional Commits 1.0.0 spec (feat, fix, scope, breaking change footer, ! marker, body, footers). Use ONLY for commit messages, not for changelogs, PR titles, or branch names.
---

# Conventional Commits 1.0.0

Lightweight convention on top of commit messages. Pairs with [SemVer](https://semver.org/):
`fix` → PATCH, `feat` → MINOR, `BREAKING CHANGE` → MAJOR.

## Deliverable

When this skill is invoked, the output **is the literal commit message text** — the
prefix line, blank line, body, blank line, and footers exactly as it would be passed
to `git commit -m` (or appended to a message file). Do not wrap it in prose,
explanations, headings, or surrounding documentation. The user will copy it as-is.

If the user asked to draft from a branch diff, the deliverable is a *separate*
commit message per logical change in the diff, each formatted per this spec.

## Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- `type` — noun, `feat`, `fix`, etc. Lowercase recommended for consistency.
- `scope` — optional, in parens, describes a section of the codebase: `feat(parser):`.
- `!` — optional, before the colon, marks a breaking change.
- `description` — short summary, imperative mood, no period at end.
- `body` — optional, free-form, explains the *what* and *why*. One blank line after the description.
- `footer(s)` — optional, `token: value` or `token #value` format (git trailer style). Tokens use `-` instead of spaces (`Reviewed-by`, not `Reviewed by`).

## Body guidance

The body is free-form prose. A good body reads like a developer explaining the
commit to a colleague — not like formal documentation.

- **Set the scene when it's not obvious from the diff**: open with "While
  testing…", "During the migration…", "When wiring up X…". Tells the reviewer
  the *when* and *where* of the change, not just the *what*.
- **First person is fine and often natural**: "I noticed", "I moved", "I tried".
  The commit is written by a person; let it sound like one. The spec does not
  require a neutral voice.
- **Stack related motivations with ", and"** instead of splitting them into
  paragraphs. "I moved it to a helper, and tried to make it more readable, and
  used X to subscribe the right way" reads more honestly than three crisp
  imperatives that pretend the author weighed each decision in isolation.
- **Mention the technology version when it motivates the choice**: "to use
  React 18+'s external store hook", "now that Node 20 supports…". Explains
  *why this approach, why now*.
- **Don't force a Problem / Solution / Impact structure**. A single flowing
  sentence is often clearer than three short ones.
- **Wrap lines around 72 columns only when the body has multiple paragraphs**.
  A one-sentence body can run long.
- **Keep it on-topic**: skip backstory the diff already conveys (which files
  changed, which function was renamed). Focus on *why* and the non-obvious
  *how*.
- **Skip the body** entirely if the description is unambiguous.

Imperative mood applies to the **description**. The body can use any voice the
developer would naturally use.

If the diff bundles unrelated changes (e.g. a `feat` plus a `chore`), split them
into separate commits and produce one message per commit.

## Types

| Type       | SemVer | When                                                  |
| ---------- | ------ | ----------------------------------------------------- |
| `feat`     | MINOR  | New feature for the user                              |
| `fix`      | PATCH  | Bug fix for the user                                  |
| `docs`     | —      | Documentation only                                    |
| `style`    | —      | Formatting, whitespace, semicolons (no code change)   |
| `refactor` | —      | Code change that neither fixes a bug nor adds a feat  |
| `perf`     | —      | Performance improvement                               |
| `test`     | —      | Adding or fixing tests                                |
| `build`    | —      | Build system or external dependencies                 |
| `ci`       | —      | CI configuration files and scripts                    |
| `chore`    | —      | Other changes that don't modify src or test files     |
| `revert`   | —      | Reverts a previous commit                             |

## Breaking changes

Two equivalent ways to mark a breaking change. Either is valid; pick one.

**1. `!` in the prefix** (preferred — visible in `git log --oneline`):

```
feat(api)!: drop support for Node 6
```

**2. `BREAKING CHANGE:` footer** (use when you also need to explain):

```
feat: drop support for Node 6

BREAKING CHANGE: use JavaScript features not available in Node 6.
```

`BREAKING CHANGE` MUST be uppercase. The token `BREAKING-CHANGE` (with hyphen) is synonymous.

## Examples

```
docs: correct spelling of CHANGELOG
```

```
feat(lang): add Polish language
```

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

```
refactor(pinned-columns): share per-row offset registry via useSyncExternalStore

While testing our shadcn-ui module, I could see one of the issues still persisted with multiple table columns, I could move the code to a helper, and i tried to make it more readable, and I've used useSyncExternalStore to solve this issue with a better way to subscribe from react 18+
```

```
feat(api): add /v2/users endpoint

While migrating the dashboard to React 18, the legacy useEffect-based data fetcher started racing the new Suspense boundary. I moved the loader into a small useResource hook, and added a stale-while-revalidate cache so navigating away and back doesn't refetch.
```

```
fix(auth): stop refreshing tokens on focus

When the focus listener fired during a tab switch, the refresh request raced the in-flight one and produced a 401. I gated the listener behind a leader-election check on the active tab, and now only one tab refreshes at a time.
```

```
feat: allow provided config object to extend other configs

BREAKING CHANGE: `extends` key in config file is now used for extending other config files
```

```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

## Spec rules (must follow)

1. Type + colon + space are **required**. `!` and scope are optional.
2. `feat` adds a feature. `fix` patches a bug.
3. Scope is a noun in parens (`fix(parser):`).
4. Description immediately follows the colon+space.
5. Body starts one blank line after description.
6. Footer tokens use `-` for whitespace (`Acked-by`). Exception: `BREAKING CHANGE`.
7. `!` or `BREAKING CHANGE` is **required** for any breaking change.
8. Types are case-insensitive except `BREAKING CHANGE` which must be uppercase.

## Common mistakes

- Period at end of description (`feat: add foo.`), drop the period.
- Imperfect tense in the **description** (`feat: added foo`), use imperative
  (`feat: add foo`). Imperative is required for the description; the body can
  use any voice.
- Vague scope (`feat: update code`), drop scope or use a real section name.
- Mixing types in one commit, split into multiple commits when possible.
- Forgetting the `!` or `BREAKING CHANGE` footer on API-breaking changes.
- Wrapping the message in surrounding prose or documentation when the user asked
  for a commit message — the deliverable is the message itself.

## Reference

Full spec: <https://www.conventionalcommits.org/en/v1.0.0/>
