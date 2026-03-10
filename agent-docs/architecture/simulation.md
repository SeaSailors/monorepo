# Deterministic Simulation Network

Testing distributed systems requires reproducible failure scenarios. `commonware-p2p` provides a simulated network that integrates with the `deterministic` runtime to provide 100% reproducible testing of network conditions.

## Simulation Features

### Link Modeling
The `Oracle` allows tests to configure individual links between peers with:
- **Latency**: Fixed delay for message delivery.
- **Jitter**: Statistical variance in delivery time (modeled via Normal distribution).
- **Success Rate**: Probability of packet loss (0.0 to 1.0).

### Bandwidth & Rate Limiting
The simulator supports modeling egress and ingress bandwidth caps. It uses the `transmitter` module to schedule delivery completions based on message size and available bandwidth.

### Network Topology Control
Tests can dynamically:
- **Partition**: Remove links to simulate split-brain scenarios.
- **Block**: Use the `Blocker` interface to simulate censorship or malicious peer eviction.
- **Churn**: Update `Manager` peer sets to simulate nodes joining and leaving.

## Usage in Tests

```rust
#[test]
fn test_network_partition() {
    let executor = deterministic::Runner::default();
    executor.start(|context| async move {
        let (network, mut oracle) = Network::new(context, config);
        network.start();

        // Configure links
        oracle.add_link(pk1, pk2, link_config).await.unwrap();

        // Simulate partition
        oracle.remove_link(pk1, pk2).await.unwrap();

        // Verify system behavior under partition
    });
}
```

## Determinism Auditor
The simulation network participates in the `deterministic::Auditor`. Every message delivery event, link update, and rate-limit check is hashed into the global state digest. This ensures that any change in network behavior is detected and recorded.
