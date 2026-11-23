# Exceptions

One row per rule this repository cannot meet yet. The reason and the revisit date
are required. The shared `standard` job reads this file.

| Rule | Reason | Revisit |
| --- | --- | --- |
| `C5.1` | The audit snapshot's median pull request run was 59 s. After this change the first run took 124 s from the first job starting to the last required check finishing, with a cold Cargo cache and a cold `mise` install of the Rust toolchain in every job; the second run took 47 s with the cache warm. The `test` job and the shared `coverage` job both compile the crate, so a cold cache doubles the work. The next step is to re-measure the median over 20 runs and to share one build between `test` and `coverage`. | 2027-02-28 |
| `C7.4` | `scripts/coverage.mjs`, `scripts/prune.mjs` and `scripts/agent-files.mjs` are still `.mjs` on Node. The Rust application has no JavaScript or TypeScript sources, so the repository keeps the Rust toolchain behind the core recipe names and runs the helpers on the pinned Node until they port to Bun TypeScript. | 2027-05-31 |
