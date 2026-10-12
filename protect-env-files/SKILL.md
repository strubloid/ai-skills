---
name: protect-env-files
description: "Use on every opencode request to enforce that .env files are never read, printed, or surfaced into context. Triggered by any tool invocation that could expose `.env`, `.env.local`, `.env.*`, `.envrc`, or any file matching that pattern, and by shell commands (cat, grep, rg, find, source, env, printenv) that would print them. Front-load: .env, env file, secret, API key, token leak."
---

# Never read .env files

This is a global rule. It applies to every opencode session, every agent
(including subagents), every model, and every tool. There are no opt-outs.

## The rule

You must NEVER read, print, dump, copy, summarize, grep, or otherwise surface
the contents of any file whose name matches the patterns below, in any tool
output that flows back into context (Read, Bash, Grep, Glob, WebFetch,
file edits, etc.):

- `.env`
- `.env.local`
- `.env.development`
- `.env.production`
- `.env.test`
- `.env.*` (any other variant)
- `.envrc`

Also treat the following as equivalent — do not surface their contents:

- Any file inside `.env.d/`, `env/`, or `secrets/`
- Any file whose permission bits are 0600 / 0400 in the project root
- Anything that looks like a credentials file at the project root
  (`credentials.json`, `service-account.json`, `*.pem`, `*.key`)

## Why this is absolute

- Once a secret value lands in your context window it is logged, indexed, and
  potentially cached. The user cannot redact it from prior turns. The leak is
  permanent for that session.
- This rule exists because in a previous turn I grepped across the repo with
  `--include="*.env*"` and pulled a Mapbox token into context. That was a
  mistake; this skill exists to prevent it recurring.

## What to do instead

You almost never need the value of an env var. Pick the right substitute:

1. **Use the documented accessor.** Vite env vars are exposed in code via
   `import.meta.env.VITE_*`. If the project wraps them (e.g. a
   `src/lib/helpers/env.ts` that exposes typed getters), call the wrapper
   instead. The variable name is enough to write code — you do not need the
   value.
2. **Check `process.env` / `import.meta.env` declarations in the codebase.**
   `grep` for the variable *name* (e.g. `VITE_MAPBOX_TOKEN`) in `*.ts` /
   `*.tsx` / `*.js` files only. Never include `.env*` in the grep.
3. **Ask the user.** If you genuinely need a value to debug, ask. The user
   can paste the relevant subset without exposing the whole file.
4. **Read the README / docs / `.env.example`.** Files like `.env.example`,
   `.env.sample`, `.env.template` are designed to be read. They do not
   contain real values.

## Tool-by-tool rules

### `read`

- If the path matches any pattern above, refuse the call. Pick a substitute.
- If you accidentally call `read` on an `.env` path, the response should
  still be treated as if you read a secret: do not echo, quote, or reason
  about the values; tell the user what happened and continue with a
  substitute.

### `grep` / `bash rg`

- Never pass `--include="*.env*"`, `--include=".env*"`, `-g '.env*'`, or
  `-g '**/.env*'` to any search.
- Never use `rg` / `grep` without an explicit `--exclude` or `-g '!.env*'`
  filter when the search scope could match an env file.
- If a search returns hits in `.env*` files, do not display the matched
  lines. Mention only that "X matches found in env files" and ask the user
  if they want to expose them.

### `glob`

- Never include `.env*` patterns in a glob. If you glob `**/*` and `.env`
  shows up in the result, do not call `read` on it.

### `bash`

Never run any of the following, even with the user's permission:

- `cat .env`, `cat .env.*`, `cat .envrc`
- `dotenv`, `direnv allow`, `source .env`, `. .env`
- `env` / `printenv` (prints all env vars to stdout)
- `git diff .env*`, `git log -p -- .env*` (would surface historical values)
- `git stash show -p` without first checking that the stash does not
  contain env files
- `npm config get` / `cat ~/.npmrc` / `cat ~/.netrc` (global credentials)
- `cat ~/.config/gh/hosts.yml`, `cat ~/.docker/config.json` (more global creds)

When you need an env value, call the typed wrapper, not the shell.

### `edit` / `write`

- Do not edit `.env` files. If the user asks you to change an env var, edit
  the typed accessor (`src/lib/helpers/env.ts` or the relevant module) or
  instruct the user to edit `.env` themselves and restart.
- Never copy contents of `.env` into `.env.example`. Make up placeholder
  values (`YOUR_TOKEN_HERE`).

## If a user asks you to read a .env file

Refuse once, briefly, and offer a substitute:

> I'm not allowed to read `.env` files — once a value lands in my context
> it can't be redacted. If you can tell me the variable name you need, I
> can wire it up via the typed accessor instead. If you really need me to
> see a value, paste just that value into the chat.

If the user insists, do not budge. The rule is non-negotiable.

## Recovery if a value has already leaked

If you notice a secret in your context from a prior turn (token, password,
private key, etc.), do not echo it. Tell them:

- which file / command surfaced it
- what to do (rotate the credential, scrub git history if it was committed)

Then continue with the substitute.

## Scope summary

| File                             | Read?                                       |
| ------------------------------- | ----------------------------------------- |
| `.env`, `.env.*`, `.envrc`      | NEVER                                      |
| `.env.example`, `.env.sample`   | OK (placeholders only)                     |
| `src/**` reading env via `import.meta.env` | OK (call the wrapper)             |
| Reading env var *name* in code   | OK (search for the identifier, not value)  |
| `~/.npmrc`, `~/.netrc`, `~/.docker/config.json`, `~/.config/gh/hosts.yml` | NEVER |