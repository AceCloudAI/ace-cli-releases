# AceCloud CLI (`ace`)

Command-line tool to manage your AceCloud infrastructure — instances, volumes, VPCs, load balancers, Kubernetes clusters, container deployments, registries, and more.

## Installation

### Quick Install (Linux / macOS)

```bash
curl -fsSL https://raw.githubusercontent.com/AceCloudAI/ace-cli-releases/main/install.sh | bash
```

### Manual Download

Download the binary for your platform from [Releases](https://github.com/AceCloudAI/ace-cli-releases/releases/latest):

| Platform              | Binary               | Download                                                                                            |
|-----------------------|----------------------|-----------------------------------------------------------------------------------------------------|
| Linux (amd64)         | `ace-linux-amd64`    | [Download](https://github.com/AceCloudAI/ace-cli-releases/releases/download/v1.4.2-beta/ace-linux-amd64) |
| Linux (arm64)         | `ace-linux-arm64`    | [Download](https://github.com/AceCloudAI/ace-cli-releases/releases/download/v1.4.2-beta/ace-linux-arm64) |
| macOS (Apple Silicon) | `ace-darwin-arm64`   | [Download](https://github.com/AceCloudAI/ace-cli-releases/releases/download/v1.4.2-beta/ace-darwin-arm64)|
| macOS (Intel)         | `ace-darwin-amd64`   | [Download](https://github.com/AceCloudAI/ace-cli-releases/releases/download/v1.4.2-beta/ace-darwin-amd64)|

```bash
# Example: macOS Apple Silicon
curl -L https://github.com/AceCloudAI/ace-cli-releases/releases/download/v1.4.2-beta/ace-darwin-arm64 -o /usr/local/bin/ace
chmod +x /usr/local/bin/ace
ace --version
```

### Self-Update

```bash
ace update          # Download and install latest version
ace update --check  # Only check, don't install
```

---

## Quick Start

```bash
# 1. Login with your developer token
ace auth login-token --token <your-api-token>

# 2. Verify
ace auth me
ace config show

# 3. Start using
ace instance list
ace flavor list
ace get-all          # Show all resources in the project
```

---

## Global Flags

Every command supports these flags:

| Flag                    | Description                                          |
|-------------------------|------------------------------------------------------|
| `-o, --output <format>` | Output format: `table` (default), `json`, `yaml`    |
| `-v, --verbose`         | Show full API responses                              |
| `--project <id>`        | Override project ID for this command                 |
| `--region <name>`       | Override region for this command                     |
| `-h, --help`            | Help for any command                                 |

### Environment Variables

| Variable          | Description                | Overrides           |
|-------------------|----------------------------|---------------------|
| `ACE_TOKEN`       | Authentication token       | `config.token`       |
| `ACE_PROJECT_ID`  | Project ID                 | `config.project_id`  |
| `ACE_REGION`      | Region                     | `config.region`      |

**Precedence:** CLI flag > Environment variable > Config file

---

## Authentication

```bash
# Login with developer token (recommended)
ace auth login-token --token <token>

# Login with email/password
ace auth login [--email <email>] [--password <pw>]

# View current user
ace auth me

# Account status
ace auth status

# List projects
ace auth projects

# Logout
ace auth logout
```

---

## Configuration

```bash
# Show current config
ace config show

# Set values
ace config set region ap-south-noi-1
ace config set project <project-id>

# Get a value
ace config get region

# Switch project (interactive)
ace config use-project
```

---

## Compute

### Instances

```bash
# List instances
ace instance list
ace instance list -o json

# Create instance
ace instance create --name my-vm \
  --flavor C4i.medium \
  --image Ubuntu-24.04-LTS \
  --network <vpc-id> \
  --security-group <sg-id> \
  --key my-keypair \
  --boot-size 50

# Get details
ace instance get <instance-id>

# Summary (total/active count)
ace instance summary

# Console URL
ace instance console <instance-id>

# Logs
ace instance logs <instance-id>
ace instance action-logs <instance-id>

# Network & security
ace instance interfaces <instance-id>
ace instance security-groups <instance-id>

# Volume management
ace instance volumes <instance-id>
ace instance attach-volume <instance-id> --volume <vol-id>
ace instance detach-volume <instance-id> --volume <vol-id>

# Power operations
ace instance start <instance-id>
ace instance stop <instance-id>
ace instance reboot <instance-id>
ace instance reboot <instance-id> --hard
ace instance suspend <instance-id>
ace instance unsuspend <instance-id>

# Lock / unlock
ace instance lock <instance-id>
ace instance unlock <instance-id>

# Resize
ace instance resize <instance-id> --flavor C4i.large
ace instance resize-confirm <instance-id>
ace instance resize-revert <instance-id>

# Snapshot & image
ace instance snapshot <instance-id> --name my-snapshot
ace instance save-image <instance-id> --image my-image

# Rebuild
ace instance rebuild <instance-id> --image Ubuntu-24.04-LTS

# Update
ace instance update <instance-id> --name new-name

# Recovery mode
ace instance recovery <instance-id> --on
ace instance recovery <instance-id> --off

# Batch operations
ace instance batch-shutoff <id1> <id2> <id3>        # Shutoff multiple
ace instance batch-shutoff <id1> <id2> --on          # Start multiple

# Delete
ace instance delete <instance-id>
```

**Aliases:** `ace i`, `ace vm`

### Flavors

```bash
ace flavor list                # All flavors with pricing
ace flavor list --cpu 4        # Filter by vCPUs
ace flavor list --gpu          # GPU flavors only
ace flavor get <flavor-id>
```

### Images

```bash
ace image list                  # All images
ace image list --os ubuntu      # Filter by OS
ace image list --os windows
ace image get <image-id>
ace image categories            # List image categories
ace image delete <image-id>
```

### SSH Key Pairs

```bash
ace key-pair list
ace key-pair create --name my-key                           # Generate new pair
ace key-pair create --name my-key --public-key "ssh-rsa..." # Import existing
ace key-pair get my-key
ace key-pair delete my-key
```

**Aliases:** `ace kp`, `ace keypair`

---

## Storage

### Volumes

```bash
ace volume types                                          # Available volume types
ace volume create --name my-vol --size 100 --type "NVMe based High IOPS Storage"
ace volume list
ace volume list --status available
ace volume get <vol-id>
ace volume extend <vol-id> --size 200                     # Extend (can't shrink)
ace volume update <vol-id> --name new-name
ace volume delete <vol-id>
```

**Aliases:** `ace vol`

### Snapshots

```bash
ace snapshot list
```

---

## Networking

### VPCs

```bash
# Create VPC with subnet
ace vpc create --name my-vpc --subnet-name my-subnet --subnet-cidr 10.0.0.0/24

# With custom DNS
ace vpc create --name my-vpc --subnet-name my-sub --subnet-cidr 10.0.0.0/24 \
  --dns 8.8.8.8 --dns 8.8.4.4

# List / get
ace vpc list
ace vpc get <vpc-id>

# Add more subnets
ace vpc subnet-create --vpc <vpc-id> --name sub2 --cidr 10.0.1.0/24

# Delete
ace vpc subnet-delete <subnet-id>
ace vpc delete <vpc-id>
```

**Aliases:** `ace network`

### Routers

```bash
ace vpc router create --name my-router
ace vpc router list
ace vpc router get <router-id>

# Attach external gateway
ace vpc router set-gateway --router <router-id> --network <ext-network-id>
ace vpc router remove-gateway --router <router-id>

# Attach/detach subnets
ace vpc router add-interface --router <router-id> --subnet <subnet-id>
ace vpc router remove-interface --router <router-id> --subnet <subnet-id>
ace vpc router interfaces --router <router-id>

ace vpc router delete <router-id>
```

### Security Groups

```bash
ace security-group create --name my-sg
ace security-group list
ace security-group get <sg-id>
ace security-group update <sg-id> --name new-name --description "Updated"

# Add rules (shortcut protocols: ssh, http, https, rdp, mysql, dns)
ace sg rule-add --sg <sg-id> --protocol ssh
ace sg rule-add --sg <sg-id> --protocol http
ace sg rule-add --sg <sg-id> --protocol tcp --port 3000
ace sg rule-add --sg <sg-id> --protocol tcp --port 8000-9000
ace sg rule-add --sg <sg-id> --protocol icmp
ace sg rule-add --sg <sg-id> --direction egress --protocol any

# Delete rule / group
ace sg rule-delete <rule-id>
ace security-group delete <sg-id>
```

**Aliases:** `ace sg`

### Floating IPs

```bash
ace floating-ip create --network <ext-network-id>
ace floating-ip list
ace floating-ip associate --ip <fip-addr> --instance <instance-id>
ace floating-ip disassociate --ip <fip-addr> --instance <instance-id>
ace floating-ip delete <fip-id>
```

**Aliases:** `ace fip`

### Load Balancers

```bash
# Create (ALB or NLB)
ace lb create --name my-lb --subnet <subnet-id> --type ALB

ace lb list
ace lb get <lb-id>
ace lb update <lb-id> --name new-name
ace lb delete <lb-id> --cascade          # Delete with all listeners/pools

# Listeners
ace lb listener create --lb <lb-id> --name my-listener --protocol HTTP --port 80
ace lb listener list --lb <lb-id>        # Filter by LB
ace lb listener list                     # All listeners
ace lb listener get <listener-id>
ace lb listener delete <listener-id>

# Pools
ace lb pool create --listener <listener-id> --name my-pool --protocol HTTP --algorithm ROUND_ROBIN
ace lb pool list
ace lb pool get <pool-id>
ace lb pool delete <pool-id>
```

**Aliases:** `ace lb`

---

## Kubernetes

### Clusters

```bash
# Available versions
ace k8s cluster versions

# Create cluster
ace k8s cluster create --name my-cluster --version v1.32.6 \
  --flavor <flavor-id> --worker-name pool1

# With options
ace k8s cluster create --name my-cluster --version v1.32.6 \
  --flavor <flavor-id> --worker-name pool1 \
  --worker-count 3 --volume-size 100 \
  --autoscale --autoscale-min 1 --autoscale-max 5

# GPU cluster
ace k8s cluster create --name gpu-cluster --version v1.32.6 \
  --flavor <gpu-flavor-id> --worker-name gpu-pool --gpu

# List / get
ace k8s cluster list
ace k8s cluster get my-cluster
ace k8s cluster show my-cluster     # Alias for get

# Kubeconfig
ace k8s cluster kubeconfig my-cluster > ~/.kube/config

# Nodes
ace k8s cluster nodes my-cluster
ace k8s cluster nodes my-cluster --pool pool1

# Delete
ace k8s cluster delete my-cluster
```

**Aliases:** `ace k8s cl`, `ace kubernetes`

### Node Pools

```bash
ace k8s cluster nodepool list my-cluster
ace k8s cluster nodepool get pool1 --cluster my-cluster
ace k8s cluster nodepool create my-cluster --name pool2 --flavor <flavor-id>
ace k8s cluster nodepool scale <pool-id> --count 3
ace k8s cluster nodepool delete <pool-id>
```

**Aliases:** `ace k8s cluster np`

---

## Container Deployments (CaaS)

```bash
# Shared deployment
ace deployment create --name my-app --image nginx:latest \
  --cpu 0.5 --memory 512Mi \
  --external-access --port http:HTTP:80:80

# With env vars and volumes
ace deployment create --name my-app --image myapp:v1 \
  --cpu 1 --memory 1Gi --replicas 2 \
  --env DB_HOST=localhost --env DB_PORT=5432 \
  --volume data:/data:1Gi

# Dedicated deployment
ace deployment create --name my-app --type dedicated \
  --image nginx:latest --flavor <flavor-id> \
  --replicas 1 --network-cidr 10.0.0.0/16

# List / get
ace deployment list
ace deployment get <deployment-id>
ace deployment replicas <deployment-id>

# Scale
ace deployment replicas <deployment-id> --count 3

# Update
ace deployment update <deployment-id> --cpu 2 --memory 2Gi

# Restart / delete
ace deployment restart <deployment-id>
ace deployment delete <deployment-id>
```

**Aliases:** `ace deploy`, `ace caas`

---

## Container Registry (CRaaS)

```bash
ace registry status                           # Registry info
ace registry create                           # Create registry
ace registry credentials                      # Docker login credentials
ace registry push-commands --image myapp:v1   # Push instructions

# Repositories
ace registry repo list
ace registry repo delete <repo-name>

# Artifacts
ace registry artifact list <repo-name>
ace registry artifact get-tags <repo-name> <reference>
ace registry artifact scan <repo-name> <reference>
ace registry artifact delete <repo-name> <reference>

ace registry delete
```

**Aliases:** `ace reg`, `ace craas`

---

## Monitoring & Pricing

### Quotas

```bash
ace quota all          # All quotas
ace quota compute      # vCPUs, RAM, instances, key pairs
ace quota storage      # Volumes, GB, snapshots
ace quota network      # IPs, ports, networks, routers, SGs
```

### Pricing

```bash
ace pricing            # View all resource pricing
```

### Resource Overview

```bash
ace get-all            # List all resources in the project
```

**Aliases:** `ace all`, `ace status`

---

## Command Reference

### Full Command Tree

```
ace
├── auth
│   ├── login              Login with email/password
│   ├── login-token        Login with developer token
│   ├── logout             Logout
│   ├── me                 Current user info
│   ├── projects           List projects
│   └── status             Account status
├── config
│   ├── set                Set config value (region, project)
│   ├── get                Get config value
│   ├── show               Show all config
│   └── use-project        Switch project (interactive)
├── instance (i, vm)
│   ├── list, get, create, delete, update, summary
│   ├── start, stop, reboot, suspend, unsuspend
│   ├── lock, unlock, recovery, batch-shutoff
│   ├── resize, resize-confirm, resize-revert
│   ├── rebuild, snapshot, save-image
│   ├── console, logs, action-logs
│   ├── interfaces, security-groups, volumes
│   ├── attach-volume, detach-volume
│   └── attach-interface, detach-interface
├── volume (vol)
│   ├── list, get, create, update, delete
│   ├── extend
│   └── types
├── snapshot
│   └── list
├── vpc (network)
│   ├── list, get, create, delete
│   ├── subnet-create, subnet-delete
│   └── router
│       ├── list, get, create, delete
│       ├── set-gateway, remove-gateway
│       ├── add-interface, remove-interface
│       └── interfaces
├── security-group (sg)
│   ├── list, get, create, update, delete
│   ├── rule-add
│   └── rule-delete
├── floating-ip (fip)
│   ├── list, create, delete
│   ├── associate
│   └── disassociate
├── load-balancer (lb)
│   ├── list, get, create, update, delete
│   ├── listener
│   │   ├── list, get, create, delete
│   └── pool
│       ├── list, get, create, delete
├── k8s (kubernetes)
│   └── cluster (cl)
│       ├── list, get/show, create, delete
│       ├── versions, kubeconfig, nodes
│       └── nodepool (np)
│           ├── list, get/show, create, delete, scale
├── deployment (deploy, caas)
│   ├── list, get, create, update, delete
│   ├── replicas, restart
├── registry (reg, craas)
│   ├── status, create, delete, credentials
│   ├── push-commands
│   ├── repo (list, delete)
│   └── artifact (list, get-tags, scan, delete)
├── flavor
│   ├── list, get
├── image
│   ├── list, get, delete, categories
├── key-pair (kp, keypair)
│   ├── list, get, create, delete
├── pricing
├── quota
│   ├── all, compute, storage, network
├── get-all (all, status)
├── update
└── init
```

---

## License

Proprietary - AceCloud AI
