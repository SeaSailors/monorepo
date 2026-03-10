# Deployer Architecture

The `commonware-deployer` orchestrates a hub-and-spoke infrastructure topology optimized for low-latency distributed systems and centralized observability.

## Deployment Topology

The architecture consists of a centralized **Monitoring Region** (fixed to `us-east-1`) and multiple **Binary Regions** where the application logic resides.

```txt
                   Deployer Machine (Public IP)
                                 |
                                 v
              +-----------------------------------+
              | Monitoring VPC (us-east-1)        |
              |  - Monitoring Instance            |
              |    - Grafana, Prometheus, Loki    |
              |    - Pyroscope, Tempo             |
              +-----------------------------------+
                    ^                       ^
               (Telemetry)             (Telemetry)
                    |                       |
+------------------------------+  +------------------------------+
| Binary VPC 1 (Region A)      |  | Binary VPC 2 (Region B)      |
|  - Binary Instance           |  |  - Binary Instance           |
|    - Custom Binary           |  |    - Custom Binary           |
|    - Promtail, Node Exporter |  |    - Promtail, Node Exporter |
+------------------------------+  +------------------------------+
```

## Core Components

### 1. Monitoring Stack
- **Prometheus**: Pulls metrics from binary instances via private network.
- **Loki**: Receives logs pushed by Promtail.
- **Pyroscope**: Collects profiles from binary instances.
- **Tempo**: Collects distributed traces.
- **Grafana**: Provides a unified dashboard for all telemetry.

### 2. Binary Instances
- **Custom Binary**: The application being tested/deployed.
- **Promtail**: Forwards local logs to the monitoring region.
- **Node Exporter**: Exposes OS-level metrics for Prometheus.
- **Pyroscope Agent**: Periodically captures and forwards performance profiles.

### 3. Networking & Security
- **VPC Peering**: Secure, private communication between the monitoring VPC and all binary VPCs.
- **Security Groups**: Granular ingress rules allowing:
    - Deployer IP full access.
    - Inter-instance telemetry traffic over private IPs.
    - User-defined ports for the application.
- **BBR**: Bottleneck Bandwidth and Round-trip propagation time (BBR) congestion control is enabled on all instances for optimal network throughput.

## Runtime & Dependencies

Unlike most Commonware crates, the Deployer is **not** runtime-agnostic and relies directly on **Tokio**.

### Why Tokio?
The Deployer is a CLI tool and orchestrator, not a consensus-critical primitive. It uses `tokio` for:
- Concurrent AWS SDK calls (provisioning resources in parallel).
- Concurrent SSH connections (configuring multiple instances simultaneously).
- Asynchronous I/O for file uploads and downloads.

### S3 Cache Layer
A shared S3 bucket (`commonware-deployer-cache`) acts as a global cache:
- **Tools**: Pre-compiled observability binaries (versioned and architecture-specific).
- **Deployments**: Unique binaries, configurations, and host-mapping files for specific `tag` IDs.
- **Efficiency**: Binaries are uploaded once and pulled by N instances via pre-signed URLs, minimizing outbound bandwidth from the deployer's machine.
