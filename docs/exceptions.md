# Exceptions

One row per rule this repository cannot meet yet. The reason and the revisit date
are required. The shared `standard` job reads this file.

| Rule | Reason | Revisit |
| --- | --- | --- |
| `C5.1` | The audit snapshot's median pull request run was 59 s. This pull request's first run took 124 s from the first job starting to the last required check finishing, with a cold Cargo cache and a cold `mise` install of the Rust toolchain in every job. The `test` job (2m4s) and the shared `coverage` job (1m45s) both compile the crate from scratch. The Cargo cache is now restored on the pull request path; the next step is to re-measure once the cache is warm and to share the build between `test` and `coverage`. | 2027-02-28 |
| `C7.4` | `scripts/coverage.mjs`, `scripts/prune.mjs` and `scripts/agent-files.mjs` are still `.mjs` on Node. The Rust application has no JavaScript or TypeScript sources, so the repository keeps the Rust toolchain behind the core recipe names and runs the helpers on the pinned Node until they port to Bun TypeScript. | 2027-05-31 |
