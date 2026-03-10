# Deterministic Testing Guide

The deterministic runtime is the primary tool for verifying the correctness and robustness of Commonware primitives. It allows you to simulate complex network conditions, crash-recovery scenarios, and time-dependent behavior in a perfectly reproducible environment.

## Basic Usage

All asynchronous tests should use the `deterministic::Runner`.

### 1. Seeded Runner
Use `Runner::seeded(seed)` for reproducible tests.
```rust
#[test]
fn test_my_primitive() {
    let executor = deterministic::Runner::seeded(42);
    executor.start(|context| async move {
        // Your test logic here
        context.sleep(Duration::from_secs(1)).await;
    });
}
```

### 2. Timed Runner
Use `Runner::timed(timeout)` to ensure a test doesn't hang indefinitely.
```rust
let executor = deterministic::Runner::timed(Duration::from_secs(30));
```

## Simulating Time

In the deterministic runtime, time does not pass in "real-time". It only advances when:
1. All spawned tasks are pending (waiting for I/O or sleep).
2. The runtime advances to the next "cycle".

Use `context.sleep(duration).await` to yield control and wait for a simulated duration.

## Simulating Crashes & Recovery

One of the most powerful features of the deterministic runtime is the ability to test state persistence and recovery.

### The Checkpoint Pattern
1. Run a setup phase.
2. Create a `Checkpoint` (save the current state of the auditor and virtual storage).
3. Recover from the checkpoint in a new runner instance.

```rust
// 1. Initial run
let (complete, context) = deterministic::Runner::timed(timeout).start(actor_logic);

// 2. Simulate crash
let checkpoint = context.recover();

// 3. Recover and continue
let (complete, _) = deterministic::Runner::from(checkpoint).start(actor_logic);
```

## Network Simulation

Use the `oracle` (from `p2p/src/simulated`) to control the network link between peers.

### Common Patterns:
- **Partitions**: Remove links between two sets of peers to simulate a network split.
- **Latency/Jitter**: Add high latency and jitter to test timeout handling.
- **Lossy Links**: Set a low `success_rate` (e.g., 0.5) to test packet loss and retransmission.

## Detecting Non-Determinism

If your test fails with a "Non-determinism detected" error:
1. **Check for Un-seeded RNG**: Ensure you are using `commonware_utils::test_rng()` and NOT `OsRng` or `StdRng::from_entropy()`.
2. **Avoid External State**: Do not read files or environment variables inside the `start` block.
3. **Use the Auditor**: Compare the auditor digests between two runs with the same seed to identify where the execution diverged.

## Verification Patterns

### Metrics Verification
Use `context.encode()` to get a Prometheus-formatted string of all recorded metrics and assert on their values.

### Labels for Debugging
Always label your actors (`context.with_label("actor_name")`). This makes it much easier to read the execution trace when a test fails.
