# Fuzzing Reference

## Core Fuzzing Commands

| Task | Command |
| :--- | :--- |
| List targets | `cargo +nightly fuzz list --fuzz-dir <dir>` |
| Run target | `cargo +nightly fuzz run <target> --fuzz-dir <dir>` |
| Coverage | `cargo +nightly fuzz coverage <target> --fuzz-dir <dir>` |
| Minimize Input | `cargo +nightly fuzz tmin <target> <file> --fuzz-dir <dir>` |
| Minimize Corpus | `cargo +nightly fuzz cmin <target> --fuzz-dir <dir>` |

## Fuzzing Targets Map

| Crate | Primary Fuzz Targets |
| :--- | :--- |
| `codec` | `codec_roundtrip` |
| `consensus` | `simplex_ed25519`, `simplex_messages`, `simplex_elector`, etc. |
| `cryptography` | `ed25519`, `secp256r1`, `bls12381` |
| `p2p` | `simulated`, `lookup`, `discovery` |
| `stream` | `connection`, `e2e`, `transport` |
| `storage` | `journal`, `mmr`, `qmdb_sync` |

## Resource Limits

Default `just` limits:
*   `max_time`: 60 seconds per target.
*   `max_mem`: 4000 MB (RSS limit).

CI limits:
*   Timed out at 180 minutes for the entire fuzzing job matrix.
*   Individual target runs limited to 60 seconds.
