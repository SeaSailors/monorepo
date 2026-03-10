# How to Add a New Example Crate

A new example crate is a runnable integration surface that lives under `examples/` and is wired into the workspace like the existing bridge, chat, estimator, flood, log, reshare, and sync examples.

1. **Create the crate directory.** Add `examples/<name>/` with `src/`, `README.md`, and `Cargo.toml`.
2. **Match the existing package shape.** In `examples/<name>/Cargo.toml`, follow the other examples by setting workspace-managed `edition`, `version`, `license`, and `homepage`, plus `readme = "README.md"` and `lints.workspace = true`.
3. **Add workspace dependencies.** Use `commonware-*` workspace dependencies for the primitives you are composing, and keep target-specific or feature-specific settings local to the crate.
4. **Add an entrypoint.** Use `src/main.rs` for a CLI example or `src/lib.rs` plus `[[bin]]` entries when the example exposes multiple executables, as `examples/bridge` does.
5. **Document the example.** Write `examples/<name>/README.md` with the purpose, setup, and run commands so the example is discoverable from the repository docs.
6. **Register the crate in the workspace.** Add `examples/<name>` to the root `Cargo.toml` workspace members list.
7. **Verify the integration.** Run `cargo check -p commonware-<name>` or the example's `just`/test command, then confirm the root workspace still builds the new member.
