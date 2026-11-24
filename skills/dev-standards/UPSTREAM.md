# Upstream guidance

The `guides/modern-web-guidance/` directory is vendored from the official
GoogleChrome Modern Web Guidance repository.

- Repository: <https://github.com/GoogleChrome/modern-web-guidance>
- Source path: `skills/modern-web-guidance/`
- Pinned commit: `2b4aa13a72dd47cd135b06ce5abfccd92e19b24f`
- License: Apache-2.0, retained in `guides/modern-web-guidance/LICENSE`

The included skill workflow can also query the current guide catalog through
`npx modern-web-guidance@latest`. The vendored guide files provide a local
reference snapshot; refresh them from the upstream source path and update the
pinned commit here when intentionally bringing in upstream changes. Keep local
development standards in the sibling categorized guides, not in the vendored
directory.
