---
name: dev-standards
description: Use for implementation, code review, refactoring, testing, and modernization work in projects that use this standards collection. Routes work through focused topic guides to the relevant detailed standards and official Modern Web Guidance without loading every rule for every task.
---

# Development Standards

This is the entry point for the standards in this collection. It combines the
project's durable engineering preferences with specialist skills and Google's
official Modern Web Guidance corpus. Use it to find the right guidance; do not
turn it into a checklist that rewrites every file.

## Working flow

1. **Understand the task and target project.** Read the relevant code, callers,
   configuration, and nearby examples. Identify the framework, runtime, browser
   support policy, and installed UI or test libraries before choosing a pattern.
2. **Choose the smallest set of standards.** Start with the matching topic
   overview in [`guides/`](guides/), then read only the linked detailed guide or
   guides that match the task. The original individual skill content is kept as
   detailed guides under this entry point, grouped by concern. Do not load all
   of them for a focused change.
3. **Treat stack-specific standards as conditional.** Apply a guide only when
   the target project uses that stack or the task matches its scope.
4. **For browser-platform work, use the official web guidance first.** For
   browser-facing HTML, CSS, or client-side JavaScript, consult the
   `modern-web-guidance` skill before choosing APIs or patterns. Search and
   retrieve the relevant guide, check the target project's browser policy and
   Baseline support, then apply its framework-compatible guidance and fallbacks.
    The upstream workflow and full guide corpus are kept together in
    `guides/modern-web-guidance/`. Use its `SKILL.md` as the workflow and its
    `guides/` folder as the offline snapshot. If the CLI or network is
    unavailable, select the matching bundled guide by ID rather than
    substituting unrelated guidance.
5. **Respect the target project's conventions.** The existing architecture,
   installed dependencies, lint rules, and user requirements take precedence
   over a generic preference unless they conflict with correctness, security,
   accessibility, or an explicit project requirement.
6. **Make the requested change, not a standards sweep.** Preserve behavior and
   existing names. Keep unrelated improvements separate. For broad modernization,
   inspect and verify findings before changing code.
7. **Verify and report.** Run checks appropriate to the change, review the final
   diff, and distinguish required fixes from optional improvements.

## Guide map

- [`web-and-frontend.md`](guides/web-and-frontend.md) — browser platform,
  accessibility, React, async UI, Tailwind, and component primitives.
- [`language-and-architecture.md`](guides/language-and-architecture.md) —
  TypeScript/JavaScript, mapping, module boundaries, and class decisions.
- [`ui-and-design-systems.md`](guides/ui-and-design-systems.md) — shadcn
  composition, registry components, data-heavy layouts, and filtering patterns.
- [`testing-and-maintenance.md`](guides/testing-and-maintenance.md) — behavior
  tests, safe in-place edits, and comments that explain intent.
- [`repository-workflow.md`](guides/repository-workflow.md) — environment-file
  privacy, Git safety, and commit-message conventions.

## Scope and precedence

- Apply `protect-env-files` on every request that could expose environment or
  credential files. Never read or print their contents.
- For edits to existing files, use `modify-in-place` unless the user explicitly
  requests a broader rewrite or reorganization.
- Keep Git read-only unless the user explicitly requests the specific Git
  mutation in the current turn.
- For an existing file, use the smallest in-place change that satisfies the
  request. Reorganization is appropriate when the user asks for it, as they did
  for this standards collection.
- Use Modern Web Guidance for current browser-platform knowledge; use local
  specialist skills for this collection's additional preferences. If they
  overlap, retain both by applying the browser guidance to the platform behavior
  and the local skill to project structure and workflow.
- Do not assume every consumer is React, Tailwind, shadcn, Zustand, or TypeScript.
  Confirm the target stack before activating stack-specific guidance.

## Keeping the upstream corpus current

The bundled Modern Web Guidance files are an upstream snapshot; source and
revision are recorded in [`UPSTREAM.md`](UPSTREAM.md). Keep them unmodified.
When refreshing the snapshot, update that metadata and review the change. Keep
user-specific standards in the categorized guides in this directory. Re-add or
update this skill with the standard Skills CLI in each agent that uses it.
