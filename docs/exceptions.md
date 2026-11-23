# Exceptions

One row per rule this repository cannot meet yet. The reason and the revisit date
are required. The shared `standard` job reads this file.

| Rule | Reason | Revisit |
| --- | --- | --- |
| `C7.4` | `scripts/coverage.mjs`, `scripts/prune.mjs` and `scripts/agent-files.mjs` are still `.mjs` on Node. The Rust application has no JavaScript or TypeScript sources, so the repository keeps the Rust toolchain behind the core recipe names and runs the helpers on the pinned Node until they port to Bun TypeScript. | 2027-05-31 |
