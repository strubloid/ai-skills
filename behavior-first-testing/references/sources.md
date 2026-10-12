# Sources and verification dates

All sources were checked on 2026-10-12. Re-verify before citing any of them in user-facing documentation if more than 90 days have passed; the testing ecosystem moves.

## Agent Skills specification

- **Spec**: https://agentskills.io/specification
- **What it provides**: SKILL.md frontmatter format, directory layout, progressive disclosure rules.
- **Used for**: frontmatter fields (`name`, `description`, `license`, `compatibility`, `metadata`), name validation regex (`^[a-z0-9]+(-[a-z0-9]+)*$`), the recommendation to keep `SKILL.md` under 500 lines and split detail into `references/`.

## OpenCode skills integration

- **Docs**: https://opencode.ai/docs/skills
- **What it provides**: skill loading locations (`.opencode/skills/<name>/SKILL.md`, `~/.config/opencode/skills/<name>/SKILL.md`, `.claude/skills/`, `.agents/skills/`), `opencode/slash` and `opencode/autoinvoke` metadata keys, the `<available_skills>` block format, permission patterns.
- **Used for**: where to place the skill, which metadata keys OpenCode recognizes, how the skill surface area appears to the agent.

## Vitest

- **Getting started**: https://vitest.dev/guide/
- **Component testing**: https://vitest.dev/guide/browser/component-testing
- **What they provide**: writing tests (`describe`, `it`, `expect`), Browser Mode (real-browser testing via Playwright provider), the position that component tests focus on behavior over implementation, MSW as the recommended network mocking approach.
- **Used for**: framework section in [`vitest-rtl-idioms.md`](vitest-rtl-idioms.md), the strategy file's notes on MSW.

## Testing Library

- **Queries overview**: https://testing-library.com/docs/queries/about
- **React Testing Library intro**: https://testing-library.com/docs/react-testing-library/intro
- **user-event intro**: https://testing-library.com/docs/user-event/intro
- **What they provide**: query priority (Role → LabelText → PlaceholderText → Text → DisplayValue → AltText → Title → TestId), `getBy` vs `queryBy` vs `findBy` semantics, `user-event` v14 `setup()` pattern, the "tests should resemble how users use your software" principle.
- **Used for**: query priority in [`vitest-rtl-idioms.md`](vitest-rtl-idioms.md), the "tests should resemble user behavior" core principle in `SKILL.md`.

## jest-dom

- **Repository**: https://github.com/testing-library/jest-dom
- **What it provides**: DOM matchers (`toBeInTheDocument`, `toHaveAttribute`, `toHaveTextContent`, `toBeVisible`, `not.toBeInTheDocument`).
- **Used for**: assertion idioms in [`vitest-rtl-idioms.md`](vitest-rtl-idioms.md).

## Playwright

- **Introduction**: https://playwright.dev/docs/intro
- **What it provides**: end-to-end testing framework, browser binaries (Chromium, Firefox, WebKit), Node 22+/24+/26+ system requirements, headless / headed modes, HTML reporter, UI Mode, codegen.
- **Used for**: the end-to-end section in [`testing-strategy.md`](testing-strategy.md).

## React

- **Docs**: https://react.dev/
- **What it provides**: current React behavior, Strict Mode double-invocation semantics, concurrent rendering guidance.
- **Used for**: testing caveats (Strict Mode effects, concurrent rendering) in [`testing-strategy.md`](testing-strategy.md).

## TypeScript

- **Docs**: https://www.typescriptlang.org/docs/
- **What it provides**: strict mode, discriminated unions, narrowing.
- **Used for**: the "no `any`, no unsafe casts" rule in `SKILL.md` and in [`testing-strategy.md`](testing-strategy.md).

## W3C accessibility

- **Standards**: https://www.w3.org/WAI/standards-guidelines/
- **What it provides**: WCAG 2.x and ARIA Authoring Practices.
- **Used for**: the "accessibility is part of writing the component, not a follow-up" rule in [`testing-strategy.md`](testing-strategy.md).

## OpenAI evaluation guidance on skills

- **Blog**: https://developers.openai.com/blog/eval-skills
- **What it provides**: guidance on how to evaluate whether a skill is effective (representative tasks, failure modes, before/after comparisons).
- **Used for**: the validation approach in this skill's creation report (run the skill against representative tasks and check whether the output improves).

## What's NOT cited and why

- W3C ARIA Authoring Practices Guide pages — referenced only by URL in the testing-strategy file. The full role tables are out of scope; the skill does not enumerate ARIA roles.
- Vitest API reference (`/api/*`) — specific APIs (`vi.fn`, `vi.mock`, `vi.spyOn`) are cited by name without API-page links, because they are stable across Vitest 4.x and 5.x.
- `@testing-library/jest-dom` matcher list — too long to enumerate; the skill cites the most-used matchers and links to the repo.
- Mutation testing frameworks (Stryker) — mentioned as an option when compatible; no specific URL because the framework choice is project-specific.

## Re-verification policy

Before citing any of the above URLs in user-facing documentation (READMEs, blog posts, generated registry docs) more than 90 days after 2026-10-12, re-check the page. The testing ecosystem has historically been stable at the API level but has churned at the documentation URL level (paths like `/docs/queries/about` have moved between major doc revisions).