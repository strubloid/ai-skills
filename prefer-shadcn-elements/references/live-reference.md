# Live shadcn references

These are canonical, maintained references. Check the relevant pages every time
an UI component is created, changed, or reviewed. They are intentionally not a
copied component catalog: the catalog changes over time, so the live pages and
the current CLI are authoritative.

## Required live sources

- [shadcn/ui llms.txt](https://ui.shadcn.com/llms.txt) — machine-readable index
  of the current documentation and component links.
- [Components](https://ui.shadcn.com/docs/components) — current official
  component catalog.
- [CLI](https://ui.shadcn.com/docs/cli) — current installation, search, view,
  documentation, and migration commands.
- [components.json](https://ui.shadcn.com/docs/components-json) — project
  configuration, aliases, base library, and registry settings.
- [Theming](https://ui.shadcn.com/docs/theming) — semantic tokens, colors,
  radius, and dark mode.
- [Forms](https://ui.shadcn.com/docs/forms) — current form composition patterns.
- [Changelog](https://ui.shadcn.com/docs/changelog) — current API, CLI, and
  component changes.
- [Source on GitHub](https://github.com/shadcn-ui/ui) — source of the official
  components and registry.

## Fast freshness check

Use the package manager already used by the target project. These examples use
`npx`; equivalent `pnpm dlx`, `yarn dlx`, or `bunx` commands are equally valid:

```sh
npx shadcn@latest info --json
npx shadcn@latest docs <component> --json
npx shadcn@latest search @shadcn -q "<need>"
npx shadcn@latest view <item>
```

For an installation, inspect the proposed changes first when the CLI supports
it, then install the official item:

```sh
npx shadcn@latest add <component> --dry-run
npx shadcn@latest add <component>
```

Do not use an old `shadcn` version or a copied component list when the current
CLI and documentation are available. If network access is unavailable, report
that the live check could not be completed and rely on the project's installed
source only as a clearly marked fallback.

## Registry note

The official shadcn registry is exposed through the current CLI and the
project's configured registries. The default namespace is `@shadcn`; community
and private registries are outside the default policy of
`prefer-shadcn-elements` and require an explicit user request.
