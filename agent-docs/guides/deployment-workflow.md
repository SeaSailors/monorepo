# Deploying with Commonware Deployer

This guide covers the standard workflow for deploying a distributed system using the `commonware-deployer`.

## Prerequisites

- **AWS Credentials**: Configured in your environment (e.g., `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
- **Application Binaries**: Compiled for the target architectures (ARM64 or x86_64).
- **SSH Access**: The deployer generates its own keys, but ensure your local machine allows outbound SSH.

## 1. Define Configuration

Create a `deploy.yaml` file to define your infrastructure.

```yaml
tag: my-first-deployment
monitoring:
  instance_type: t4g.small
  storage_size: 10
  storage_class: gp2
  dashboard: ./my-dashboard.json
instances:
  - name: validator-1
    region: us-east-1
    instance_type: t4g.small
    storage_size: 20
    storage_class: gp2
    binary: ./bin/app-arm64
    config: ./configs/node-1.conf
    profiling: true
  - name: validator-2
    region: eu-west-1
    instance_type: t4g.small
    storage_size: 20
    storage_class: gp2
    binary: ./bin/app-arm64
    config: ./configs/node-2.conf
    profiling: true
ports:
  - protocol: tcp
    port: 8080
    cidr: 0.0.0.0/0
```

## 2. Launch Infrastructure

Run the `create` command. This will provision all AWS resources, setup VPC peering, install the monitoring stack, and start your binaries.

```bash
deployer ec2 create --config deploy.yaml
```

**What happens:**
- SSH keys are generated in `~/.commonware_deployer/my-first-deployment/`.
- S3 cache is populated with observability tools.
- Infrastructure is built in parallel across regions.
- Telemetry is wired from validators back to the monitoring instance.

## 3. Authorize Access

If your public IP changes, or you need to grant access to a teammate, use the `authorize` command:

```bash
deployer ec2 authorize --config deploy.yaml --ip 1.2.3.4
```

## 4. Update Binaries

To roll out a new version of your application without destroying the infrastructure:

```bash
deployer ec2 update --config deploy.yaml
```

**What happens:**
- New binaries are uploaded to S3.
- The `binary` service is stopped on all instances.
- Instances download the new binary and restart the service.

## 5. Teardown

To stop incurring costs and delete all resources:

```bash
deployer ec2 destroy --config deploy.yaml
```

*Note: The `~/.commonware_deployer/{tag}/` directory is retained with a `destroyed` marker to prevent accidental reuse of the same tag.*
