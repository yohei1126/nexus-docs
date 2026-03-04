# RM&D OSS Architecture — Part 5D: Technology Stack & Resource Sizing

> Part 5D of 6 · Sections 9-10: Technology stack recommendations by layer, infrastructure automation tooling, resource sizing

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · **[ARCH5 Index](ARCH5_INDEX.md)** · [ARCH6 Strategy](ARCH6_STRATEGY.md)

> **Part 5 Sections:** [5A: OSS Selection](ARCH5A_OSS_SELECTION.md) · [5B: Analytics & KPI](ARCH5B_ANALYTICS_KPI.md) · [5C: Abstraction Patterns](ARCH5C_ABSTRACTION.md) · **5D: Tech Stack**

---

## 9. Technology Stack Recommendations {#9-technology-stack-recommendations}

This section provides specific technology choices for each layer. For OSS evaluation criteria, see [Section 8](#8-leveraging-existing-oss-solutions). For complete automation tooling, see [Section 9.4](#9.4-infrastructure-automation-tooling-matrix).

### 9.1 Edge Device SDK

| Layer | Technology Options | License | Notes |
|-------|-------------------|---------|-------|
| **Language** | C/C++, Rust, MicroPython | Various | C/C++ for resource-constrained; Rust for memory safety; Python for Linux edge |
| **Telemetry** | Protobuf, JSON, MessagePack | Apache 2.0 | Protobuf for efficiency; JSON for simplicity |
| **Transport** | MQTT (Eclipse Paho), HTTP/2 (libcurl) | EPL 2.0, MIT | MQTT for pub/sub; HTTP/2 for request/response |
| **Security** | mbedTLS, OpenSSL, wolfSSL | Apache 2.0, OpenSSL | mbedTLS for small footprint |
| **OTA** | RAUC, SWUpdate, Balena | LGPL / GPL / Apache 2.0 | RAUC/SWUpdate for standalone; Balena for managed |

### 9.2 Gateway

| Layer | Technology Options | License | Notes |
|-------|-------------------|---------|-------|
| **Language** | Go, Rust, Node.js | BSD, MIT/Apache 2.0, MIT | Go for concurrency; Rust for safety; Node.js for rapid dev |
| **Message Broker** | Eclipse Mosquitto, VerneMQ, NATS | EPL 2.0, Apache 2.0, Apache 2.0 | VerneMQ for high throughput; NATS for simplicity |
| **Protocol Adapters** | Open62541 (OPC-UA), libmodbus, BACnet Stack | MPL 2.0, LGPL, GPL | Ensure license compatibility |
| **Edge Analytics** | Apache Kafka Streams, Flink, TensorFlow Lite | Apache 2.0, Apache 2.0, Apache 2.0 | TF Lite for ML inference on edge |
| **Plugin Runtime** | Wasmtime (WASM), gRPC | Apache 2.0, Apache 2.0 | WASM for sandboxing; gRPC for performance |
| **Container** | Docker, Podman | Apache 2.0, Apache 2.0 | Podman for rootless containers |

### 9.3 Cloud Platform

| Layer | Technology Options | License | Notes |
|-------|-------------------|---------|-------|
| **Ingestion** | Apache Kafka, NATS, RabbitMQ | Apache 2.0, Apache 2.0, MPL 2.0 | Kafka for high throughput; NATS for simplicity |
| **Time-Series DB** | TimescaleDB, InfluxDB, VictoriaMetrics | Various | TimescaleDB Core is Apache 2.0 (but check advanced feature licensing) |
| **Stream Processing** | Apache Flink, Kafka Streams | Apache 2.0, Apache 2.0 | Flink for complex event processing |
| **API Gateway** | Kong, Traefik, Envoy | Apache 2.0, MIT, Apache 2.0 | Kong for plugin ecosystem |
| **ML Platform** | MLflow, Kubeflow, TensorFlow Serving | Apache 2.0, Apache 2.0, Apache 2.0 | MLflow for model lifecycle |
| **Visualization** | Grafana, Apache Superset | AGPL v3, Apache 2.0 | Grafana for time-series; Superset for BI |
| **Orchestration** | Kubernetes, Docker Swarm | Apache 2.0, Apache 2.0 | Kubernetes for production |

### 9.4 Infrastructure Automation Tooling Matrix {#9.4-infrastructure-automation-tooling-matrix}

**Complete IaC Stack by Component**

| Component | Provisioning | Configuration | Deployment | Monitoring | Secrets |
|-----------|--------------|---------------|------------|------------|---------|
| **Edge Gateway** | Terraform (VM) | Ansible/Cloud-Init | Docker Compose | Telegraf | Vault Agent |
| **K8s Cluster** | Terraform/eksctl | Helm/Kustomize | ArgoCD/Flux | Prometheus | External Secrets |
| **Time-Series DB** | Terraform (RDS) | Helm/Operator | StatefulSet | Grafana | Sealed Secrets |
| **Message Queue** | Terraform | Helm Charts | Kubernetes | NATS monitoring | K8s Secrets |
| **API Gateway** | Terraform (ALB/NLB) | Helm/Operator | Deployment | Kong metrics | Cert-manager |
| **Monitoring Stack** | Terraform | Grafana Provisioning | Helm | Self-monitoring | SOPS encryption |
| **Networking** | Terraform (VPC/Subnet) | Cilium/Calico CNI | NetworkPolicy | Hubble | - |
| **Load Balancer** | Terraform | Nginx/Traefik config | DaemonSet | Access logs | - |

**Tooling Selection by Deployment Size**

| Scale | Provisioning | Config Mgmt | GitOps | Secret Mgmt | Observability |
|-------|--------------|-------------|--------|-------------|---------------|
| **Small (<1k)** | Terraform + Cloud-Init | Docker Compose YAML | Git + CI/CD | .env files | Grafana Cloud (free tier) |
| **Medium (1k-10k)** | Terraform + Helm | Helm + Kustomize | ArgoCD | Sealed Secrets | Self-hosted Prometheus/Grafana |
| **Large (10k+)** | Terraform + Crossplane | Helm + Operators | Flux Multi-cluster | External Secrets + Vault | Federated Prometheus + Thanos |

**CI/CD Pipeline Integration**

| Stage | Tool | Purpose | Trigger |
|-------|------|---------|---------|
| **Validate** | terraform validate, helm lint | Syntax checking | Git push |
| **Plan** | terraform plan, helm template | Preview changes | Pull request |
| **Test** | terratest, helm unittest | Integration testing | PR merge |
| **Scan** | tfsec, trivy, checkov | Security scanning | Pre-deployment |
| **Apply** | terraform apply, helm upgrade | Deployment | Manual approval |
| **Verify** | smoke tests, health checks | Post-deployment validation | After apply |
| **Rollback** | terraform destroy, helm rollback | Disaster recovery | On failure |

**Infrastructure Testing Strategy**

```
Unit Tests (Terratest, Go)
  ↓ Test individual Terraform modules
Integration Tests (Kitchen-Terraform)
  ↓ Test complete infrastructure stack
E2E Tests (Selenium, Cypress)
  ↓ Test application on deployed infra
Chaos Engineering (Chaos Mesh, Litmus)
  ↓ Test resilience and fault tolerance
```

**GitOps Repository Structure**

```
infrastructure/
├── terraform/
│   ├── modules/               # Reusable Terraform modules
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── rds/
│   │   └── monitoring/
│   ├── environments/          # Environment-specific configs
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── terraform.tfvars
│   │   ├── staging/
│   │   └── production/
│   └── live/                  # Terragrunt for DRY
│       └── terragrunt.hcl
├── helm/
│   ├── charts/                # Custom Helm charts
│   │   └── rmd-monitoring/
│   │       ├── Chart.yaml
│   │       ├── values.yaml
│   │       └── templates/
│   └── values/                # Environment values
│       ├── dev.yaml
│       ├── staging.yaml
│       └── production.yaml
├── k8s/
│   ├── base/                  # Kustomize base
│   │   ├── namespace.yaml
│   │   └── kustomization.yaml
│   ├── overlays/              # Environment overlays
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   └── sealed-secrets/        # Encrypted secrets
├── ansible/
│   ├── inventory/
│   │   ├── dev.ini
│   │   └── production.ini
│   ├── playbooks/
│   │   ├── edge-gateway.yml
│   │   └── monitoring.yml
│   └── roles/
│       ├── docker/
│       └── telegraf/
├── gitops/
│   ├── argocd/
│   │   ├── applications/      # ArgoCD Application manifests
│   │   └── projects/
│   ├── flux/
│   │   ├── clusters/          # Flux cluster configs
│   │   └── apps/
│   └── policies/              # OPA/Kyverno policies
├── scripts/
│   ├── deploy.sh              # Deployment automation
│   ├── rollback.sh            # Rollback automation
│   └── disaster-recovery.sh   # DR automation
└── docs/
    ├── runbooks/              # Operational runbooks
    └── architecture/          # Architecture diagrams
```

**Automation Workflow for AI Agents**

1. **Infrastructure Change Request**
   - Agent parses user request (e.g., "Add staging environment")
   - Agent reads infrastructure repo structure
   - Agent identifies relevant Terraform modules

2. **Code Generation**
   - Agent generates Terraform/Helm configs
   - Agent validates syntax (terraform validate, helm lint)
   - Agent runs security scan (tfsec, checkov)

3. **Preview & Approval**
   - Agent runs `terraform plan` or `helm template`
   - Agent presents diff to user
   - User approves or requests changes

4. **Deployment**
   - Agent commits to Git (feature branch)
   - CI/CD pipeline triggered
   - Automated tests run
   - Manual approval for production
   - Agent monitors deployment status

5. **Verification**
   - Agent runs smoke tests
   - Agent checks health endpoints
   - Agent reports success/failure to user

**Compliance & Policy Enforcement**

| Tool | Purpose | When Applied | Scope |
|------|---------|--------------|-------|
| **OPA (Open Policy Agent)** | Policy as code | Pre-deployment | Kubernetes admission control |
| **Kyverno** | K8s native policies | Runtime | Pod security, resource limits |
| **Checkov** | IaC security scanning | CI/CD pipeline | Terraform, Helm, Dockerfile |
| **tfsec** | Terraform security | Git pre-commit | Terraform modules |
| **Conftest** | Generic policy testing | CI/CD | Any YAML/JSON config |

---

## 10. Reference Architecture Sizing

Following the **Informative** principle, these specifications are provisional benchmarks. Actual resource needs will depend on the realized data rate and processing complexity.

### 10.0 Sizing & Cost Assumptions

The following estimates assume a typical RM&D deployment profile:

| Parameter | Assumption | Notes |
| :--- | :--- | :--- |
| **Data Rate** | 1 message / 30 seconds per device | Mixed metrics, events, and heartbeats. |
| **Payload Size** | ~1 KB per message | Canonical Protobuf envelope with typical labels. |
| **Retention** | 12 months (Hot/Warm) | Historical data for BCA compliance (Annex A). |
| **Query Load** | 10 concurrent users / 1,000 devices | Dashboard viewing + periodic KPI batch jobs. |
| **HA Target** | 99.5% - 99.9% Uptime | Redundant nodes (N+1) for cloud and message brokers. |
| **Replication** | Factor = 2 or 3 | For database (Timescale/QuestDB) and Kafka/NATS. |
| **Region** | Single Cloud Region (e.g., ap-southeast-1) | Standard AWS/GCP/Azure pricing applied. |


### 10.1 Small Deployment (1,000 devices)

| Component | Spec | Quantity | Notes |
|-----------|------|----------|-------|
| **Edge Gateway** | Raspberry Pi 4 (4GB RAM) or Intel NUC | 10-20 | 50-100 devices per gateway |
| **Cloud Compute** | 4 vCPU, 16GB RAM | 2-3 VMs | HA cluster |
| **Time-Series DB** | 8 vCPU, 32GB RAM, 500GB SSD | 2 nodes | TimescaleDB with replication |
| **Message Broker** | 4 vCPU, 8GB RAM | 2 nodes | MQTT cluster |
| **Storage** | 1TB SSD | - | 1 year retention |
| **Estimated Cost** | - | - | ~$500-1000/month (cloud) |

### 10.2 Medium Deployment (10,000 devices)

| Component | Spec | Quantity | Notes |
|-----------|------|----------|-------|
| **Edge Gateway** | Industrial PC (8GB RAM) | 100-200 | 50-100 devices per gateway |
| **Cloud Compute** | 16 vCPU, 64GB RAM | 6-10 VMs | Kubernetes cluster |
| **Time-Series DB** | 32 vCPU, 128GB RAM, 2TB SSD | 3 nodes | TimescaleDB sharded |
| **Message Broker** | 16 vCPU, 32GB RAM | 3 nodes | Kafka cluster |
| **Storage** | 10TB SSD | - | 1 year retention |
| **Estimated Cost** | - | - | ~$5,000-10,000/month (cloud) |

### 10.3 Large Deployment (100,000+ devices)

| Component | Spec | Quantity | Notes |
|-----------|------|----------|-------|
| **Edge Gateway** | Industrial PC (16GB RAM) | 1,000-2,000 | 50-100 devices per gateway |
| **Cloud Compute** | 64 vCPU, 256GB RAM | 20-50 VMs | Multi-region Kubernetes |
| **Time-Series DB** | 128 vCPU, 512GB RAM, 10TB SSD | 10+ nodes | Distributed TimescaleDB |
| **Message Broker** | 32 vCPU, 128GB RAM | 10+ nodes | Multi-region Kafka |
| **Storage** | 100TB+ SSD/HDD | - | 1-2 year retention |
| **Estimated Cost** | - | - | ~$50,000-100,000/month (cloud) |

---

## 📖 Glossary (Key Terms)

- **BCA:** Building and Construction Authority (the agency that oversees building safety and excellence in Singapore).
- **IMDA:** Infocomm Media Development Authority (the agency that leads Singapore’s digital transformation).
- **CSA:** Cyber Security Agency of Singapore (the national agency overseeing cybersecurity).
- **RM&D:** Remote Monitoring & Diagnostics (systems that detect technical faults early and reduce equipment breakdowns).
- **Smart FM:** Smart Facilities Management (using data and technology to operate buildings more safely, efficiently, and with less manpower).

