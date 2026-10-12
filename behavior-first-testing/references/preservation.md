# Preservation — do not rename, do not restructure

The single most common failure mode of AI coding agents modifying existing files is **unnecessary renaming and restructuring**. A user asks for one change; the agent returns a 50-line diff where the requested change is buried inside renamed variables, reordered imports, and extracted helpers. The user then has to review the entire diff and revert most of it.

This reference is the long version of Rule 1 in `SKILL.md`.

## Identifier preservation — the rules

- **Preserve existing variable names, function names, parameter names, state names, callback names, props, exported identifiers, and types** unless changing them is necessary to satisfy the requested behavior or fix a demonstrated problem.
- **Never rename a working variable merely because you are editing the surrounding code.**
- Do not rename identifiers to match personal naming preferences, perceived stylistic improvements, or a newly introduced abstraction.
- Preserve existing naming conventions and terminology throughout the relevant code.
- When adding behavior, **reuse existing variables and functions** where appropriate instead of introducing competing equivalents.
- Do not rename a variable across multiple files unless the change is necessary and all references, imports, tests, and public contracts are accounted for.
- Treat public exports, component props, event callbacks, data fields, and established domain terminology as **contracts**.
- If a rename is genuinely necessary, establish why the current name prevents a correct implementation **and** identify its impact before making the change.
- Do not rename variables in tests simply to mirror a new implementation unless the test itself requires modification.

## Minimal-diff engineering — the rules

Before editing, inspect the relevant implementation and its callers, tests, types, and dependencies. Then:

1. Identify the **smallest change** that satisfies the requirement.
2. Preserve unrelated logic, names, formatting, imports, and file structure.
3. Change only the behavior and supporting code that actually need to change.
4. Avoid opportunistic refactoring, file moves, broad formatting, and unrelated cleanup.
5. Do not replace an existing working implementation with a new abstraction without a demonstrated benefit.
6. Do not rewrite an entire function or component when a small, safe edit will solve the problem.
7. Preserve existing public APIs and behavior unless the requirement explicitly calls for a change.
8. Review the final diff for unrelated changes and revert unnecessary modifications.

A refactor is justified only when it improves maintainability or correctness within the task's scope **and** does not introduce disproportionate risk.

When the requested feature can be implemented without renaming existing identifiers, those identifiers **must remain unchanged**.

## What this looks like in practice

### Wrong — the "improve while I'm here" diff

The user asks for one new prop. The agent:

- Renames 3 existing variables to match a perceived convention.
- Extracts 2 inline literals into a helper.
- Reorders the imports.
- Reformats the file.
- Adds a comment block explaining the "improvements".

The diff is 50 lines. The user wanted 5. The user has to revert most of the diff to keep the original shape.

### Right — the smallest possible change

The user asks for one new prop. The agent:

- Adds the prop to the type.
- Adds the prop handling in the body, using the existing variable names.
- Optionally adds a test for the new behavior.

The diff is 5–15 lines. Every changed line is required for the requested behavior. The user reviews and merges.

## Common rationalizations to reject

| Rationalization | Why it's wrong |
| --- | --- |
| "It's just one rename — it's clearer." | You were not asked to rename. The rename is unrelated to the requested change. |
| "This helper would be cleaner extracted." | Helpers are for code that runs more than once. A literal that appears once is fine. |
| "The file needs reorganization." | The file was organized by the original author or a previous maintainer. Reorganizing is a separate task. |
| "I'll just convert these to the new pattern." | The new pattern was not requested. Patterns are project-wide decisions, not per-file. |
| "This duplicates the other file — let me dedupe." | Deduping is a refactor. It is a separate task with its own review. |
| "I can rename this private helper." | Private does not mean "free to rename". Call sites and tests still need to be updated, and the diff is now noisy. |
| "It would be cleaner if I also fixed this." | No. Stay in scope. |

## When restructuring IS the right move

Restructure only when **any** of the following is true:

- The user explicitly asks for a refactor ("extract this", "dedupe", "I keep typing the same thing").
- The literal is repeated 5+ times **and** the user is adding more on top — at that point the duplication is the actual blocker. Ask first.
- The data is broken (invalid JSON, type errors that block compilation, references to a removed API). Fixing breakage is not "restructuring," it's keeping the file working.
- A rename is required by an upstream API change (a renamed dependency function, a deleted type). Then rename, and update every call site and test.

If you are tempted to restructure because "it would be cleaner," do the minimal modification first, stop, and ask. The user can ask for the cleanup as a separate step.

## Final reminder

A user who asked for a small change should receive a small diff. If your diff is large, the user has to read every line to find the actual change. That is a tax on every review, forever. Pay it once by keeping the diff small.