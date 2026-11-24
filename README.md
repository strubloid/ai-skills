# Development Standards Skills

This repository is a source collection for agent skills. The installable
first-party skill is [`skills/dev-standards`](skills/dev-standards/SKILL.md).
It routes development work to the project's categorized standards and includes
the upstream Google Modern Web Guidance workflow and guide corpus.

## Add the skill to an agent

From a local checkout, run the standard Skills CLI:

```sh
npx skills add ./skills --skill dev-standards --agent opencode
```

For Claude Code, use `--agent claude-code`; omit `--agent` to let the CLI prompt
for the supported agent. To install from a hosted copy of this repository, use
its repository URL in place of `./skills`.

The skill bundle contains the official Modern Web Guidance snapshot under
`skills/dev-standards/guides/modern-web-guidance/`. Its upstream source and
revision are recorded in `skills/dev-standards/UPSTREAM.md`.
