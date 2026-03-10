# How to Run Local Quality Checks

This is the shortest practical pre-PR loop for the Commonware workspace.

1. Run `just check-fmt` and `just check-toml-fmt` to catch formatting drift in Rust files and manifests.
2. Run `just clippy` to catch lint violations; the workspace treats warnings as errors.
3. Run `just test` for the default Rust suite. If you touched slower or broader behavior, use `just test --profile slow`; narrow a crate with `-p <crate-name>` when needed.
4. If you changed exported Rust APIs, storage formats, or stability-gated code, run `just check-stability` and `just unstable-public`.
5. If you changed codec, storage, or other format-sensitive code, run `just test-conformance`. Use `just regenerate-conformance` only for intentional fixture updates.
6. If you changed `mcp/`, run `npm run ci` from that directory, or run `npm run format:check`, `npm run lint`, `npm run build`, and `npm test` separately.
7. Final verification: rerun the exact command that maps to the CI surface you affected, or finish with `just pre-pr` when you want the repository's minimum pre-pull-request check.
