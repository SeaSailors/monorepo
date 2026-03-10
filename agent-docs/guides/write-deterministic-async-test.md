# How to Write a Deterministic Async Test

Use this workflow when you need a reproducible async test that can also model network changes.

1. Start with `commonware_runtime::deterministic::Runner::seeded(seed)` or `Runner::timed(timeout)` in `runtime/src/deterministic.rs:500-550`.
2. Put the test body inside `executor.start(|context| async move { ... })`, and label spawned tasks with `context.with_label(...)` so failures are easier to trace.
3. If you need crash/restart coverage, use `Runner::start_and_recover` and continue from the returned checkpoint on the next run.
4. For network behavior, create `p2p::simulated::Network::new(context.with_label("network"), cfg)` and use the returned `Oracle` to `control(peer).register(...)`, `add_link(...)`, `remove_link(...)`, or `limit_bandwidth(...)`; links are unidirectional in `p2p/src/simulated/ingress.rs:135-240`.
5. Use `select!` or another explicit wait path for concurrent progress, and compare `context.auditor().state()` or observed outputs to a second run with the same seed.
6. Final verification: rerun the test with the same seed and confirm the auditor state and outputs match, then change the seed and confirm the order changes only where expected.
