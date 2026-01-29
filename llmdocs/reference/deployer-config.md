# Deployer Configuration Reference

The `commonware-deployer` uses a YAML configuration file to define the entire deployment lifecycle.

## Root Fields

- `tag` (String): A unique identifier for the deployment. Used for resource naming and local state tracking.
- `monitoring` (Object): Configuration for the centralized observability instance.
- `instances` (List): List of binary instances to deploy.
- `ports` (List): Global port configuration for all binary instances.

## Monitoring Configuration

- `instance_type` (String): EC2 instance type (e.g., `t4g.small`).
- `storage_size` (Integer): Disk size in GB.
- `storage_class` (String): AWS EBS volume type (e.g., `gp2`).
- `dashboard` (String): Local path to a Grafana JSON dashboard to upload.

## Instance Configuration

- `name` (String): Unique name for the instance within the deployment.
- `region` (String): AWS region (e.g., `us-west-2`).
- `instance_type` (String): EC2 instance type.
- `storage_size` (Integer): Disk size in GB.
- `storage_class` (String): EBS volume type.
- `binary` (String): Local path to the application binary.
- `config` (String): Local path to the application configuration file.
- `profiling` (Boolean): If `true`, enables Pyroscope profiling on the instance.

## Port Configuration

- `protocol` (String): `tcp` or `udp`.
- `port` (Integer): Port number.
- `cidr` (String): Allowed source IP range (e.g., `0.0.0.0/0`).

## Port Reservation (Internal)

The following ports are reserved by the deployer for internal telemetry:
- `3000`: Grafana (Monitoring)
- `3100`: Loki (Monitoring)
- `4040`: Pyroscope (Monitoring)
- `4318`: Tempo (Monitoring)
- `9090`: Application Metrics (Binary)
- `9100`: Node Exporter Metrics (Binary)
- `22`: SSH (All)
