# RM&D OSS Architecture — Part 4: Deployment Models

> Part 4 of 6 · Section 7: Single-node, multi-gateway, multi-region, and IaC deployment strategies.

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · [ARCH5 OSS Stack](ARCH5_OSS_STACK.md) · [ARCH6 Strategy](ARCH6_STRATEGY.md)

## 7. Deployment Models

This section describes deployment patterns by scale. For Infrastructure as Code (IaC) implementation details, see [Section 7.4](#7.4-infrastructure-as-code-iac-deployment-strategy). For sizing and resource requirements, see [ARCH5 Section 10](ARCH5_OSS_STACK.md#10-reference-architecture-sizing).

### 7.0 IEC 62443 Zone & Conduit Architecture

Compliance with IEC 62443-3-3 requires partitioning the system into **Zones** (grouping of assets with similar security requirements) connected by **Conduits** (secure communication paths).

| Zone | Assets | IEC 62443 Security Level (Target) |
|:-----|:-------|:---------------------------------|
| **Utility/Device Zone (Level 0)** | Sensors, Actuators, Hardwired I/O | SL 0 (Physical protection relied upon) |
| **Control Zone (Level 1)** | Lift/HVAC Controllers, PLCs, SDKs | SL 2-3 (Component security per 62443-4-2) |
| **Building Edge Zone (Level 2)** | RM&D Edge Gateways, Local HMIs | SL 2-3 (Zonal isolation from Enterprise network) |
| **System DMZ (Level 3)** | Protocol Converters, Security Bastions | SL 3 (Deep packet inspection & access enforcement) |
| **Enterprise/Cloud Zone (Level 4)** | RM&D Platform Core, DBs, Analytics | SL 2-3 (Identity-centric zero trust per GovTech ZTA) |

**Conduit Requirements:**
- **Boundary Protection:** All conduits between Building Edge and Cloud MUST use mTLS (TLS 1.3).
- **One-Way Flow:** Primary flow is OT → IT (Telemetry). Remote control (IT → OT) is restricted and audited.
- **Protocol Filtering:** Conduits enforce protocol-specific deep packet inspection (DPI) where possible.


```text
┌─────────────────────────────────────────────────┐
│ Building A                                      │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐        │
│  │ Lift │  │ HVAC │  │ Pump │  │ Light│        │
│  │ +SDK │  │ +SDK │  │ +SDK │  │ +SDK │        │
│  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘        │
│     └─────────┴─────────┴─────────┘            │
│                  │                               │
│          ┌───────▼────────┐                     │
│          │ Edge Gateway   │                     │
│          │ (Raspberry Pi  │                     │
│          │  or NUC)       │                     │
│          └───────┬────────┘                     │
└──────────────────┼──────────────────────────────┘
                   │
         ┌─────────▼────────────────┐
         │ Cloud Platform           │
         │ (Commercial Managed SaaS)│
         └──────────────────────────┘
```

### 7.2 Large Building / Campus (100-1000 devices)

```text
┌─────────────────────────────────────────────────────────────┐
│ Campus (Multiple Buildings)                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Building A   │  │ Building B   │  │ Building C   │      │
│  │  50 devices  │  │  75 devices  │  │  30 devices  │      │
│  │ ┌──────────┐ │  │ ┌──────────┐ │  │ ┌──────────┐ │      │
│  │ │ Gateway  │ │  │ │ Gateway  │ │  │ │ Gateway  │ │      │
│  │ └────┬─────┘ │  │ └────┬─────┘ │  │ └────┬─────┘ │      │
│  └──────┼───────┘  └──────┼───────┘  └──────┼───────┘      │
│         └──────────────────┴──────────────────┘             │
│                            │                                 │
│                  ┌─────────▼─────────┐                       │
│                  │ Cluster Gateway   │                       │
│                  │ (Data Aggregation)│                       │
│                  └─────────┬─────────┘                       │
└────────────────────────────┼─────────────────────────────────┘
                             │
                   ┌─────────▼──────────┐
                   │ Cloud Platform     │
                   │ (OSS Self-Hosted   │
                   │  on AWS/Azure/GCP) │
                   └────────────────────┘
```

### 7.3 National-Scale (10,000+ devices)

```text
┌─────────────────────────────────────────────────────────────┐
│ National RM&D Network (Government/Utility/Large Enterprise) │
│                                                              │
│  Region 1      Region 2      Region 3      Region 4         │
│  ┌─────┐       ┌─────┐       ┌─────┐       ┌─────┐         │
│  │1000 │       │2000 │       │1500 │       │ 800 │         │
│  │devs │       │devs │       │devs │       │devs │         │
│  └──┬──┘       └──┬──┘       └──┬──┘       └──┬──┘         │
│     │             │             │             │             │
│  ┌──▼──┐       ┌──▼──┐       ┌──▼──┐       ┌──▼──┐         │
│  │ GW  │       │ GW  │       │ GW  │       │ GW  │         │
│  │Cluster      │Cluster      │Cluster      │Cluster        │
│  └──┬──┘       └──┬──┘       └──┬──┘       └──┬──┘         │
└─────┼─────────────┼─────────────┼─────────────┼────────────┘
      └─────────────┴─────────────┴─────────────┘
                            │
              ┌─────────────▼─────────────┐
              │ National Data Center      │
              │ (Kubernetes Cluster)      │
              │  - TimescaleDB (HA)       │
              │  - Kafka (Multi-Region)   │
              │  - Grafana (Federated)    │
              └───────────────────────────┘
```

### 7.4 Infrastructure as Code (IaC) Deployment Strategy {#7.4-infrastructure-as-code-iac-deployment-strategy}

**Philosophy:** All infrastructure must be version-controlled, reproducible, and deployable via automated tooling for AI agent compatibility.

#### 7.4.1 Small Deployment - Single VM (IaC Stack)

**Provisioning (Terraform):**

- Cloud provider module (AWS/GCP/Azure/DigitalOcean)
- VM instance with proper security groups
- Persistent storage volumes
- DNS records and SSL certificates

**Configuration (Cloud-Init/Ansible):**

- Docker and Docker Compose installation
- Firewall rules (ufw/iptables)
- Monitoring agent setup (Telegraf)
- Automated backup configuration

**Deployment (Docker Compose):**

- Single YAML file for entire stack
- Environment variables via .env file
- Volume mounts for data persistence
- Health checks and restart policies

**GitOps Workflow:**

```
1. Developer commits to Git
2. CI/CD pipeline validates configs
3. Terraform plan → Manual approval
4. Terraform apply → VM provisioned
5. Ansible playbook → System configured
6. Docker Compose up → Services deployed
```

#### 7.4.2 Medium Deployment - Kubernetes Cluster (IaC Stack)

**Provisioning (Terraform):**

- Managed Kubernetes cluster (EKS/GKE/AKS)
- Node groups with autoscaling
- Load balancers and ingress controllers
- Network policies and VPC configuration

**Configuration (Helm Charts):**

- VictoriaMetrics cluster mode
- QuestDB StatefulSet with persistence
- Grafana with provisioned datasources
- NATS JetStream cluster
- Cert-manager for TLS automation

**Deployment (ArgoCD/Flux GitOps):**

- Git repository as source of truth
- Automated sync from Git to cluster
- Progressive delivery with Flagger
- Automatic rollback on failure

**Repository Structure:**

```
infrastructure/
├── terraform/
│   ├── aws/                    # AWS-specific resources
│   │   ├── eks-cluster.tf
│   │   ├── vpc.tf
│   │   └── rds.tf
│   ├── gcp/                    # GCP-specific resources
│   └── modules/                # Reusable modules
│       ├── k8s-cluster/
│       ├── monitoring/
│       └── networking/
├── helm/
│   ├── values/
│   │   ├── dev.yaml
│   │   ├── staging.yaml
│   │   └── production.yaml
│   └── charts/
│       ├── rmd-monitoring/     # Custom chart
│       └── Chart.yaml
├── k8s/
│   ├── namespaces/
│   ├── network-policies/
│   └── sealed-secrets/
└── gitops/
    ├── apps/                   # ArgoCD Applications
    └── config/                 # Flux configuration
```

#### 7.4.3 Large Deployment - Multi-Region (IaC Stack)

**Provisioning (Terraform with Workspaces):**

- Multi-region VPC peering
- Global load balancing (CloudFlare/Route53)
- Cross-region replication for databases
- Multi-cluster Kubernetes federation

**Configuration (Helm + Kustomize):**

- Base Helm charts with Kustomize overlays
- Environment-specific overrides
- Secret management with Sealed Secrets/External Secrets
- Multi-cluster service mesh (Istio/Linkerd)

**Deployment (GitOps at Scale):**

- ArgoCD ApplicationSet for multi-cluster
- Automated promotion: dev → staging → production
- Blue/Green or Canary deployments
- Automated rollback based on SLO/SLI

**Disaster Recovery:**

- Infrastructure state in remote Terraform backend (S3/GCS)
- Automated backup to multiple regions
- Runbook automation with Terraform/Ansible
- Recovery Time Objective (RTO): < 1 hour

#### 7.4.4 AI Agent Deployment Automation

**Agent-Friendly Design Principles:**

1. **Declarative Over Imperative**
   - All configs in YAML/JSON/HCL
   - No manual steps required
   - Idempotent operations

2. **Version-Controlled Everything**
   - Infrastructure code in Git
   - Secrets in encrypted form (SOPS/Sealed Secrets)
   - Change history trackable

3. **Automated Validation**
   - Terraform plan before apply
   - Helm lint and dry-run
   - Policy enforcement with OPA/Kyverno

4. **Self-Service Deployment**
   - AI agent triggers CI/CD pipeline
   - Automated testing in ephemeral environments
   - Approval gates for production

**Example AI Agent Workflow:**

```
User: "Deploy RM&D monitoring to staging environment"
Agent: Reads infrastructure repo
      ↓
Agent: Validates staging.yaml config
      ↓
Agent: Runs Terraform plan
      ↓
Agent: Shows diff to user for approval
      ↓
User: Approves
      ↓
Agent: Terraform apply + Helm upgrade
      ↓
Agent: Runs smoke tests
      ↓
Agent: Reports deployment status + URLs
```

---

## 📖 Glossary (Key Terms)

- **BCA:** Building and Construction Authority (the agency that oversees building safety and excellence in Singapore).
- **IMDA:** Infocomm Media Development Authority (the agency that leads Singapore’s digital transformation).
- **CSA:** Cyber Security Agency of Singapore (the national agency overseeing cybersecurity).
- **RM&D:** Remote Monitoring & Diagnostics (systems that detect technical faults early and reduce equipment breakdowns).
- **Smart FM:** Smart Facilities Management (using data and technology to operate buildings more safely, efficiently, and with less manpower).

