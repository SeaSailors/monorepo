# Deployer Tooling

Commonware Deployer is a high-performance orchestration tool designed to deploy, update, and monitor distributed systems (like blockchains) across multiple AWS regions. It automates infrastructure provisioning, secure communication, and observability stack setup.

## Purpose

While most Commonware primitives are designed for adversarial network environments and emphasize runtime-agnosticism, the Deployer is a production-grade operations tool. It specifically solves the "day 0" and "day 1" challenges of distributed systems:

- **Infrastructure as Code**: Provision VPCs, Security Groups, and EC2 instances across diverse regions from a single YAML configuration.
- **Observability by Default**: Automatically deploys a centralized monitoring stack (Prometheus, Loki, Tempo, Pyroscope, Grafana) with pre-configured dashboards.
- **Optimized Performance**: Configures instances with high-performance networking (BBR) and optimized system settings.
- **Efficient Artifact Management**: Uses a centralized S3 bucket as a cache for common observability tools and deployment-specific binaries, significantly reducing deployment time and bandwidth.

## Key Capabilities

- **Multi-Region Orchestration**: Seamlessly handles VPC peering and routing between a central monitoring region and various binary deployment regions.
- **In-Place Updates**: Updates binaries and configurations on running instances with minimal downtime.
- **Dynamic Access Control**: Provides tools to authorize the deployer's current IP address across all deployment security groups.
- **Clean Teardown**: Dependency-aware destruction of all provisioned cloud resources.
- **Architecture Aware**: Detects architecture (ARM64 vs x86_64) from instance types and fetches compatible observability tools.
