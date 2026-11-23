# Task runner for humans and agents. `just --list` shows every
# recipe. Keep each recipe a thin call to a portable tool or a script under
# scripts/. See https://github.com/simpsonm09-projects/repo-standard/blob/main/docs/task-runner.md

# List the recipes.
default:
    @just --list

# Install the pinned tools.
install:
    mise install

# Fetch the crate dependencies from the lockfile.
deps:
    mise exec -- cargo fetch

# Format the Rust sources with rustfmt.
fmt *files:
    mise exec -- node scripts/fmt.mjs {{files}}

# Fail when a Rust source is not rustfmt-formatted.
fmt-check:
    mise exec -- cargo fmt --check

# Run every linter over the tracked files.
lint *files:
    mise exec -- flint run --full

# Fix what the linters can fix.
lint-fix:
    mise exec -- flint run --fix

# Run the repo-owned complexity gate. Flint does not activate cargo-clippy, so
# the shared lint job calls this recipe after flint.
complexity:
    mise exec -- cargo clippy --all-targets --all-features -- -D warnings

# Run the AI-slop gate.
aislop:
    mise exec -- aislop ci

# Run the test suite. `mise run test` holds the repository test command.
test:
    mise run test

# Run the tests and write an lcov report to coverage/lcov.info.
coverage:
    mise exec -- node scripts/coverage.mjs

# Regenerate docs/openapi.json from the handlers and the DTOs.
spec:
    mise exec -- cargo run --quiet --bin write-openapi

# Fail when the generated API document differs from the code.
spec-check:
    just spec
    git diff --exit-code -- docs/openapi.json

# Serve the API on http://127.0.0.1:3000.
serve:
    mise run serve

# Everything CI requires.
check: fmt-check lint complexity test spec-check

# Historical alias for `check`, kept for the support template.
verify: check

# Install the shared Lefthook hooks and assert the merged jobs (C7.8).
hooks:
    mise exec -- node scripts/hooks.ts

# Check the .agents/skills tree and its .claude/skills links.
agent-files:
    mise exec -- node scripts/agent-files.mjs

# Staged secret scan (C7.10).
secrets-staged:
    mise exec -- gitleaks git --staged --redact --no-banner

# Reject env files, private keys, kubeconfigs and files over 5 MB (C7.10).
forbidden-files *files:
    mise exec -- node scripts/forbidden-files.ts {{files}}

# actionlint and zizmor over the given workflows, or every workflow (C7.10).
workflows *files:
    {{ if files == "" { "mise exec -- actionlint" } else { "mise exec -- actionlint -- " + files } }}
    {{ if files == "" { "mise exec -- zizmor --quiet .github/workflows" } else { "mise exec -- zizmor --quiet " + files } }}

# shellcheck over the given scripts; nothing to do when none are given (C7.10).
shellcheck *files:
    {{ if files == "" { "echo shellcheck: no files to check" } else { "mise exec -- shellcheck -- " + files } }}

# Advisory Conventional Commit check (C2.4); never fails the commit (C7.10).
commit-msg file:
    mise exec -- node scripts/commit-msg.ts {{quote(file)}}

# Read the pushed refs from stdin, refuse main, and scan the range (C7.10).
hook-pre-push:
    mise exec -- node scripts/git-hook.ts pre-push

# Fast pre-push subset, under 30 seconds (C7.10).
pre-push-check:
    just fmt-check
    just lint

# Refresh locked dependencies when a manifest changed (C7.10).
deps-refresh *files:
    {{ if files == "" { "mise exec -- node scripts/deps-refresh.ts mise.toml" } else { "mise exec -- node scripts/deps-refresh.ts " + files } }}

# Owner hook: fail when this checkout cannot sign commits (C2.7).
signing-check:
    mise exec -- node scripts/signing-check.mjs

# Prune remote-tracking refs and delete local branches merged into main.
prune:
    node scripts/prune.mjs
