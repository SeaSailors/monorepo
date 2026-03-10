# How to Add a New Workspace Crate

Use this when introducing a new `commonware-*` crate, example, helper crate, or fuzz target into the monorepo.

1. Decide the crate category and create its directory under the workspace root. Match the existing split between primitives, examples, fuzz targets, and companion tooling (`README.md:11-55`).
2. Add the new path to `[workspace].members` in `Cargo.toml:1-45`. If the crate is a helper pair, add both the public crate and its implementation crate, as done for `macros/` and `conformance/`.
3. Create the crate `Cargo.toml` and reuse workspace metadata and dependency aliases from `Cargo.toml:47-109`. Keep target-specific dependency blocks local to the crate when needed, following the patterns in `runtime/Cargo.toml` and `consensus/Cargo.toml`.
4. Add the source layout and public API docs. Keep module files minimal, document exported items, and add stability annotations if the crate exposes public Rust APIs.
5. Wire any special integration points. Examples should link back to the primitive crates they compose, fuzz targets should live under `*/fuzz`, and companion surfaces should stay aligned with the workspace/version model.
6. Add tests appropriate to the crate’s behavior: unit tests for local logic, conformance tests for format-sensitive code, and fuzz targets for adversarial inputs. Use the `just` recipes in `justfile:17-49,103-177` as the local command surface.
7. Final verification: run `just test -p <crate-name>`, then `just lint`. If the crate exports public APIs, also run `just check-stability`; if it changes an encoding or persisted format, run `just test-conformance`.
