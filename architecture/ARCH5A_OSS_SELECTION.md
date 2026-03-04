# RM&D OSS Architecture — Part 5A: OSS Selection & Strategy

> Part 5A of 6 · Section 8.1-8.7: Build-vs-buy guidance, OSS stack recommendations by scale, alternatives comparison

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · **[ARCH5 Index](ARCH5_INDEX.md)** · [ARCH6 Strategy](ARCH6_STRATEGY.md)

> **Part 5 Sections:** **5A: OSS Selection** · [5B: Analytics & KPI](ARCH5B_ANALYTICS_KPI.md) · [5C: Abstraction Patterns](ARCH5C_ABSTRACTION.md) · [5D: Tech Stack](ARCH5D_TECH_STACK.md)

---

### Clarification: Normative vs. Informative
To maintain architectural maintainability and implementation flexibility, readers should distinguish between:

*   **Normative (Mandatory):** Core architecture requirements that **must** be implemented to satisfy agency standards (BCA, MPA, NEA, PUB) and security/policy mandates (e.g., IEC 62443 mapping, Canonical Telemetry Envelope).
*   **Informative (Examples):** Sector-specific KPI implementations (e.g. BCA Annex A for Lifts), suggested OSS components (e.g., QuestDB), and baseline thresholds. These serve as **initial implementation modules** and can be extended or replaced as the platform scales to new industries.

---

## 8. Leveraging Existing OSS Solutions (Build vs. Buy vs. Integrate) {#8-leveraging-existing-oss-solutions}

This section provides comprehensive guidance on selecting and integrating existing OSS components. For specific technology recommendations, see [Part 5D: Tech Stack](ARCH5D_TECH_STACK.md). For deployment automation, see [IaC Deployment (ARCH4)](ARCH4_DEPLOYMENT.md#7.4-infrastructure-as-code-iac-deployment-strategy).

### 8.1 Philosophy: Maximize OSS Reuse, Minimize Custom Development

**Key Principle:** **"Don't rebuild what already exists and works well."**

The RM&D architecture should be **90% integration of existing OSS, 10% custom glue code**. This approach:

✅ Reduces development time (months → weeks)
✅ Improves security (battle-tested code)
✅ Lowers maintenance burden (community support)
✅ Accelerates time-to-market
✅ Enables focus on domain-specific value (RM&D logic, not infrastructure)

**Decision Framework:**

| Component | Build Custom | Adopt OSS | Criteria |
|-----------|--------------|-----------|----------|
| **Core Infrastructure** (DB, message broker, container orchestration) | ❌ Never | ✅ Always | Mature OSS exists (PostgreSQL, Kafka, Kubernetes) |
| **Protocol Adapters** (MQTT, OPC-UA, Modbus) | ⚠️ Only if missing | ✅ Prefer OSS | Check GitHub/CNCF landscape first |
| **Security Primitives** (TLS, encryption, certificates) | ❌ Never | ✅ Always | Use OpenSSL, Let's Encrypt, Vault |
| **Telemetry Schema** | ✅ Define standard | ⚠️ Extend existing | Use [RM&D TelemetryEnvelope (ARCH3 §6.1.1)](ARCH3_PLUGIN_API.md#6.1.1); use OpenTelemetry naming conventions where applicable |
| **Analytics Models** | ✅ Domain-specific | ⚠️ Use frameworks | Use TensorFlow/PyTorch, not custom ML |
| **Vendor Plugins** | ✅ Vendor-specific | ❌ N/A | This is where vendors differentiate |

---

### 8.2 OSS Solution Mapping by Layer

#### 8.2.1 Edge Device SDK - Maximize Use of Existing IoT SDKs

**❌ DON'T:** Build a new IoT SDK from scratch

**✅ DO:** Adopt and extend proven IoT SDKs

| OSS Solution | License | Maturity | Use For | Notes |
|--------------|---------|----------|---------|-------|
| **AWS IoT Device SDK** (C, Python, Java) | Apache 2.0 | ⭐⭐⭐⭐⭐ | Cloud-connected devices | Works with any MQTT broker, not just AWS |
| **Azure IoT SDK** (C, Python, Node.js) | MIT | ⭐⭐⭐⭐⭐ | Enterprise devices | Good protocol support (MQTT, AMQP, HTTP) |
| **Eclipse Paho** (C, Python, Go, Java) | EPL 2.0 | ⭐⭐⭐⭐⭐ | MQTT client library | Lightweight, embedded-friendly |
| **Zephyr RTOS** (with IoT subsystem) | Apache 2.0 | ⭐⭐⭐⭐ | Microcontrollers | Full RTOS with networking, OTA, security |
| **ESP-IDF** (Espressif IoT Framework) | Apache 2.0 | ⭐⭐⭐⭐ | ESP32 devices | Optimized for Espressif chips |

**Recommendation:**
```
Edge Device SDK = Eclipse Paho (MQTT)
                 + mbedTLS (security)
                 + Protobuf/JSON (telemetry)
                 + RAUC / SWUpdate (OTA - Standalone)
```

**Custom Development Needed:** ~10%
- Telemetry schema definitions (Protobuf)
- Device-specific sensor interfaces
- BCA/IMDA compliance wrappers

#### 8.2.2 Gateway Layer - Use EdgeX Foundry or ThingsBoard

**❌ DON'T:** Build a custom IoT gateway from scratch

**✅ DO:** Adopt a mature IoT edge platform and customize

| OSS Solution | License | Maturity | Best For | Vendor Plugin Support |
|--------------|---------|----------|----------|----------------------|
| **EdgeX Foundry** (Linux Foundation) | Apache 2.0 | ⭐⭐⭐⭐⭐ | Industrial IoT, multi-protocol | ✅ Yes (App Services) |
| **ThingsBoard** | Apache 2.0 | ⭐⭐⭐⭐⭐ | Smart buildings, telemetry visualization | ✅ Yes (Rule Engine, Integrations) |
| **Node-RED** | Apache 2.0 | ⭐⭐⭐⭐ | Rapid prototyping, visual flows | ✅ Yes (Nodes) |
| **Akri** (CNCF) | Apache 2.0 | ⭐⭐⭐ | Kubernetes-native edge | ⚠️ Limited (new project) |
| **KubeEdge** (CNCF) | Apache 2.0 | ⭐⭐⭐⭐ | Edge computing with K8s | ✅ Yes (EdgeMesh) |

**Recommendation: EdgeX Foundry**

**Why EdgeX Foundry?**
- ✅ Production-ready (used by Dell, Intel, VMware)
- ✅ Microservices architecture (easy to customize)
- ✅ **Built-in protocol adapters** (MQTT, OPC-UA, Modbus, BACnet, REST)
- ✅ **Device service framework** (vendors can write custom device connectors)
- ✅ **App services framework** (perfect for vendor plugins)
- ✅ **Security services** (Secret Store, API Gateway with Kong)
- ✅ Rule Engine (trigger alerts, route data)
- ✅ Meets IEC 62443 requirements (with configuration)

**Architecture Fit:**
```text
┌─────────────────────────────────────────────────────────┐
│ EdgeX Foundry Gateway                                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Core Services (OSS - use as-is)                   │  │
│  │  - Core Data (data ingestion)                     │  │
│  │  - Core Metadata (device registry)                │  │
│  │  - Core Command (device control)                  │  │
│  │  - Support Scheduler (task scheduling)            │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Device Services (OSS + Custom)                    │  │
│  │  - device-mqtt (✅ OSS)                           │  │
│  │  - device-opcua (✅ OSS)                          │  │
│  │  - device-modbus (✅ OSS)                         │  │
│  │  - device-bacnet (✅ OSS)                         │  │
│  │  - device-lift (⚠️ Custom for BCA compliance)     │  │
│  │  - device-hvac (⚠️ Custom for vendor X)          │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Application Services (Vendor Plugins)             │  │
│  │  - app-analytics-lift (Vendor A plugin)           │  │
│  │  - app-analytics-hvac (Vendor B plugin)           │  │
│  │  - app-export-cloud (export to cloud platform)    │  │
│  └───────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────┐  │
│  │ Security Services (OSS)                           │  │
│  │  - Secret Store (Vault)                           │  │
│  │  - API Gateway (Kong)                             │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Custom Development Needed:** ~20%
- BCA-specific device services (lift, HVAC with RM&D requirements)
- Vendor plugin SDK (wrapper around EdgeX App Services)
- IEC 62443 compliance configuration
- Singapore-specific certifications

**Alternative: ThingsBoard Gateway** (for simpler deployments)
- ✅ Good for small-medium deployments (< 10,000 devices)
- ✅ Built-in visualization (no need for separate Grafana)
- ✅ Rule Engine for alerts
- ⚠️ Less flexible than EdgeX for industrial protocols

#### 8.2.3 Cloud Platform - Use Existing IoT/Observability Stack {#8.2.3-cloud-platform-stack}

**❌ DON'T:** Build a custom cloud platform from scratch

**✅ DO:** Assemble proven OSS components

**Recommended Stack (Production-Ready OSS):**

| Component | OSS Solution | License | Why | Custom Dev Needed |
|-----------|--------------|---------|-----|-------------------|
| **Message Broker** | **Apache Kafka** or **NATS** | Apache 2.0 | Battle-tested, high throughput | ~5% (config, monitoring) |
| **Time-Series DB** | **QuestDB** or **TimescaleDB Community** | Apache 2.0 / TSL | SQL compatibility, scaling, compression. (Avoid BSL-restricted advanced features for commercial distribution; see [ARCH6 §C](ARCH6_STRATEGY.md#appendix-c-license-comparison)) | ~10% (schema, retention policies) |
| **Metrics Store** | **Prometheus + Thanos** | Apache 2.0 | Industry standard for metrics | ~5% (custom exporters) |
| **Stream Processing** | **Apache Flink** or **Kafka Streams** | Apache 2.0 | Real-time analytics | ~30% (business logic) |
| **Alerting** | **Alertmanager** (Prometheus) or **Kapacitor** | Apache 2.0 | Multi-channel alerts | ~10% (alert rules) |
| **Visualization** | **Grafana OSS** ⚠️ | AGPL v3 | Best-in-class dashboards (Review AGPL obligations for network distribution) | ~20% (custom dashboards, plugins) |
| **API Gateway** | **Kong** or **Traefik** | Apache 2.0 | Rate limiting, auth, routing | ~10% (policies, plugins) |
| **Identity/Auth** | **Keycloak** | Apache 2.0 | OAuth 2.0, OIDC, RBAC | ~15% (user management) |
| **Secrets Mgmt** | **OpenBao** (Recommended) or **Vault** ⚠️ | MPL 2.0 / BSL | Certificate rotation, key management. (Verify HashiCorp licensing/version; prefer OpenBao) | ~10% (policies) |
| **Workflow Engine** | **Temporal** or **Apache Airflow** | MIT / Apache 2.0 | Orchestration, incident response | ~25% (workflows) |
| **ML Platform** | **MLflow** or **Kubeflow** | Apache 2.0 | Model training, serving | ~40% (models, training pipelines) |
| **Container Orchestration** | **Kubernetes** | Apache 2.0 | De facto standard | ~5% (cluster config) |

**Reference Architecture (100% OSS):**

```text
┌──────────────────────────────────────────────────────────────┐
│ Ingestion Layer                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐             │
│  │ MQTT       │  │ gRPC       │  │ HTTP       │             │
│  │ (Mosquitto)│  │ (Envoy)    │  │ (Nginx)    │             │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘             │
│        └────────────────┴────────────────┘                   │
│                         ▼                                     │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ API Gateway (Kong) - Auth, Rate Limit, Routing      │    │
│  └─────────────────────┬────────────────────────────────┘    │
└────────────────────────┼──────────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────────┐
│ Stream Processing Layer                                      │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ Apache Kafka (Message Broker)                        │    │
│  │  - Device telemetry topic                            │    │
│  │  - Alerts topic                                      │    │
│  │  - Commands topic                                    │    │
│  └─────────────────────┬────────────────────────────────┘    │
│                        ▼                                      │
│  ┌──────────────────────────────────────────────────────┐    │
│  │ Apache Flink (Stream Processing)                     │    │
│  │  - Real-time analytics                               │    │
│  │  - Anomaly detection                                 │    │
│  │  - Data enrichment                                   │    │
│  └─────────────────────┬────────────────────────────────┘    │
└────────────────────────┼──────────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────────┐
│ Storage Layer                                                │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐   │
│  │ TimescaleDB    │  │ Prometheus     │  │ S3/MinIO     │   │
│  │ (Telemetry)    │  │ (Metrics)      │  │ (Blobs)      │   │
│  └────────────────┘  └────────────────┘  └──────────────┘   │
└──────────────────────────────────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────────┐
│ Analytics & Alerting Layer                                   │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐   │
│  │ MLflow         │  │ Alertmanager   │  │ Temporal     │   │
│  │ (ML Models)    │  │ (Alerts)       │  │ (Workflows)  │   │
│  └────────────────┘  └────────────────┘  └──────────────┘   │
└──────────────────────────────────────────────────────────────┘
                         ▼
┌──────────────────────────────────────────────────────────────┐
│ Visualization & API Layer                                    │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐   │
│  │ Grafana        │  │ REST API       │  │ GraphQL API  │   │
│  │ (Dashboards)   │  │ (FastAPI)      │  │ (Hasura)     │   │
│  └────────────────┘  └────────────────┘  └──────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

**Custom Development Breakdown:**

| Component | OSS % | Custom % | Custom Work |
|-----------|-------|----------|-------------|
| Ingestion | 95% | 5% | Protocol normalization, multi-tenant routing |
| Stream Processing | 70% | 30% | Business logic, RM&D analytics |
| Storage | 95% | 5% | Schema design, retention policies |
| ML Pipeline | 60% | 40% | Predictive models, training pipelines |
| Alerting | 90% | 10% | Alert rules, escalation policies |
| Dashboards | 80% | 20% | BCA KPI dashboards, custom visualizations |
| APIs | 80% | 20% | BCA data standards, vendor APIs |
| **Overall** | **85%** | **15%** | Focus on RM&D domain logic |

#### 8.2.4 Security & Compliance - Use Security-Focused OSS

**❌ DON'T:** Implement custom crypto, auth, or secrets management

**✅ DO:** Use hardened security OSS

| Security Domain | OSS Solution | License | Use For |
|-----------------|--------------|---------|---------|
| **TLS/mTLS** | **OpenSSL** or **BoringSSL** | Apache 2.0 | All encrypted communication |
| **Certificate Management** | **cert-manager** (Kubernetes) | Apache 2.0 | Auto-renew certificates |
| **Secrets Management** | **OpenBao** (Recommended) or **Vault** | MPL 2.0 / BSL | API keys, certificates, encryption keys (Check current HashiCorp licensing) |
| **Identity & Access** | **Keycloak** | Apache 2.0 | OAuth 2.0, OIDC, RBAC, MFA |
| **API Security** | **Kong** or **Traefik** | Apache 2.0 | Rate limiting, WAF, authentication |
| **Network Security** | **Cilium** (Kubernetes CNI) | Apache 2.0 | Zero Trust networking, micro-segmentation |
| **Intrusion Detection** | **Falco** (CNCF) | Apache 2.0 | Runtime security, anomaly detection |
| **Vulnerability Scanning** | **Trivy** or **Clair** | Apache 2.0 | Container/dependency scanning |
| **SIEM** | **Wazuh** (fork of OSSEC) | GPL v2 | Log aggregation, threat detection |
| **Compliance Audit** | **Open Policy Agent (OPA)** | Apache 2.0 | Policy enforcement, compliance checks |

**Zero Trust Architecture (100% OSS):**

```text
┌──────────────────────────────────────────────────────────┐
│ Zero Trust Security Stack (100% OSS)                     │
│                                                           │
│  ┌─────────────────────────────────────────────────┐     │
│  │ Identity Layer                                  │     │
│  │  - Keycloak (Identity Provider)                 │     │
│  │  - FreeIPA (Device Identity)                    │     │
│  └─────────────────────────────────────────────────┘     │
│  ┌─────────────────────────────────────────────────┐     │
│  │ Policy Layer                                    │     │
│  │  - Open Policy Agent (Policy Decision Point)    │     │
│  │  - Kyverno (Kubernetes policies)                │     │
│  └─────────────────────────────────────────────────┘     │
│  ┌─────────────────────────────────────────────────┐     │
│  │ Network Layer                                   │     │
│  │  - Cilium (Network policies, service mesh)      │     │
│  │  - Envoy (Proxy, Policy Enforcement Point)      │     │
│  └─────────────────────────────────────────────────┘     │
│  ┌─────────────────────────────────────────────────┐     │
│  │ Data Layer                                      │     │
│  │  - Vault (Secrets, encryption keys)             │     │
│  │  - cert-manager (Certificate lifecycle)         │     │
│  └─────────────────────────────────────────────────┘     │
│  ┌─────────────────────────────────────────────────┐     │
│  │ Visibility Layer                                │     │
│  │  - Falco (Runtime security)                     │     │
│  │  - Wazuh (SIEM)                                 │     │
│  │  - Prometheus (Monitoring)                      │     │
│  └─────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────┘
```

**Custom Development:** ~5%
- Compliance policies (IEC 62443, BCA)
- Audit report generation
- Singapore-specific integrations (SingPass, CorpPass)

---

### 8.3 Recommended OSS Stack by Deployment Scale

#### 8.3.1 Small Deployment (< 1,000 devices)

**Philosophy:** Simplicity over scalability

| Component | OSS Solution | Why |
|-----------|--------------|-----|
| **Gateway** | **Node-RED** or **ThingsBoard** | Easy to configure, built-in UI |
| **Database** | **PostgreSQL** (single instance) | Simple, reliable, SQL |
| **Message Broker** | **Eclipse Mosquitto** (MQTT) | Lightweight, easy setup |
| **Visualization** | **Grafana** | Best-in-class dashboards |
| **Container** | **Docker Compose** | No Kubernetes complexity |

**Total Custom Code:** < 500 lines (configuration, alert rules)

#### 8.3.2 Medium Deployment (1,000 - 10,000 devices)

**Philosophy:** Balance between simplicity and scalability

| Component | OSS Solution | Why |
|-----------|--------------|-----|
| **Gateway** | **EdgeX Foundry** | Production-ready, extensible |
| **Database** | **TimescaleDB** (HA cluster) | Time-series optimized, SQL |
| **Message Broker** | **NATS** or **Kafka** | High throughput, clustering |
| **Stream Processing** | **Kafka Streams** | Lightweight, integrated with Kafka |
| **Visualization** | **Grafana** + **Prometheus** | Industry standard |
| **Container** | **Kubernetes** (managed service) | EKS, AKS, GKE |

**Total Custom Code:** ~2,000 lines (business logic, integrations)

#### 8.3.3 Large Deployment (10,000+ devices)

**Philosophy:** Scalability, resilience, multi-region

| Component | OSS Solution | Why |
|-----------|--------------|-----|
| **Gateway** | **EdgeX Foundry** + **KubeEdge** | Kubernetes-native edge |
| **Database** | **TimescaleDB** (distributed) or **Cassandra** | Multi-region, petabyte-scale |
| **Message Broker** | **Apache Kafka** (multi-region) | Battle-tested at scale |
| **Stream Processing** | **Apache Flink** | Complex event processing, stateful |
| **ML Platform** | **Kubeflow** + **MLflow** | Production ML pipelines |
| **Visualization** | **Grafana** (federated) | Multi-tenant dashboards |
| **Container** | **Kubernetes** (multi-cluster) | HA, disaster recovery |

**Total Custom Code:** ~10,000 lines (distributed systems glue, vendor plugins)

---

### 8.4 OSS Alternatives Comparison

#### 8.4.1 Time-Series Databases

| OSS Solution | License | Pros | Cons | Best For |
|--------------|---------|------|------|----------|
| **TimescaleDB** | Apache 2.0 (Core) | SQL compatibility, compression, continuous aggregates | PostgreSQL overhead; non-core features use TSL | General-purpose RM&D |
| **InfluxDB** (OSS v2) | MIT | Purpose-built for time-series, InfluxQL | Limited clustering in OSS | Single-node deployments |
| **VictoriaMetrics** | Apache 2.0 | Prometheus-compatible, high compression, fast queries | Newer project | Metrics-heavy workloads |
| **QuestDB** | Apache 2.0 | Fastest ingestion, SQL, low resource usage | Smaller community | High-frequency data |
| **Apache Druid** | Apache 2.0 | OLAP queries, real-time + historical | Complex setup | Analytics-heavy |

**Recommendation:** **TimescaleDB** for most RM&D use cases (SQL familiarity, good compression, HA support)

#### 8.4.2 Message Brokers

| OSS Solution | License | Pros | Cons | Best For |
|--------------|---------|------|------|----------|
| **Apache Kafka** | Apache 2.0 | Industry standard, high throughput, durable | Heavy, complex | Large scale (10k+ devices) |
| **NATS** | Apache 2.0 | Lightweight, fast, simple | No built-in persistence (use JetStream) | Small-medium scale |
| **RabbitMQ** | MPL 2.0 | Feature-rich, AMQP support | Lower throughput than Kafka | Complex routing |
| **Apache Pulsar** | Apache 2.0 | Multi-tenancy, geo-replication | Newer, smaller community | Multi-region |
| **Eclipse Mosquitto** | EPL 2.0 / Edl 1.0 | Lightweight MQTT broker; simple and reliable | Clustering/HA is limited (use LB + bridges) | MQTT-only, small scale |
| **VerneMQ** | Apache 2.0 | Scalable MQTT broker, clustering | Less mature than Mosquitto | MQTT at scale |
| ~~**EMQX**~~ | ~~BSL 1.1~~ ⚠️ | ~~High performance MQTT~~ | ~~Commercial use restrictions~~ | ~~Not recommended for commercial RM&D~~ |

**Recommendation:** **NATS** for small-medium, **Kafka** for large-scale, **VerneMQ** for MQTT clustering

**License Warning:** Avoid EMQX (BSL 1.1) for commercial use - use VerneMQ (Apache 2.0) or Eclipse Mosquitto instead.

#### 8.4.3 Stream Processing

| OSS Solution | License | Pros | Cons | Best For |
|--------------|---------|------|------|----------|
| **Apache Flink** | Apache 2.0 | Stateful, exactly-once semantics, complex CEP | Steep learning curve | Complex analytics |
| **Kafka Streams** | Apache 2.0 | Integrated with Kafka, simple Java library | Tied to Kafka | Kafka-native pipelines |
| **Apache Spark Streaming** | Apache 2.0 | Batch + streaming, ML integration | Micro-batch (not true streaming) | Hybrid batch/stream |
| **Benthos** | MIT | Simple, no code, YAML config | Limited stateful processing | Simple ETL |

**Recommendation:** **Kafka Streams** for simple cases, **Flink** for complex CEP

---

### 8.5 Build vs. Integrate Decision Tree

```text
Do you need [Feature X]?
        │
        ▼
Is there mature OSS that does this?
        │
   Yes  ├──► Use OSS (90% of cases)
        │    │
        │    ▼
        │    Does it have commercial-friendly license?
        │    │
        │    ├─ Yes (Apache 2.0, MIT) ──► ✅ Adopt
        │    │
        │    └─ No (GPL, AGPL) ──► Can you dual-license or use as service?
        │                           │
        │                           ├─ Yes ──► ✅ Adopt with caution
        │                           │
        │                           └─ No ──► ⚠️ Find alternative OSS
        │
   No   └──► Is it domain-specific to RM&D?
             │
             ├─ Yes (RM&D logic, BCA compliance) ──► ✅ Build custom
             │
             └─ No (generic infrastructure) ──► ⚠️ Reconsider - likely exists
```

**Examples:**

| Feature | Decision | OSS Solution | Custom % |
|---------|----------|--------------|----------|
| MQTT broker | ✅ Use OSS | Eclipse Mosquitto, VerneMQ | 0% |
| OPC-UA adapter | ✅ Use OSS | open62541, EdgeX device-opcua | 5% (config) |
| Time-series DB | ✅ Use OSS | QuestDB, TimescaleDB (core) | 10% (schema) |
| Lift fault prediction | ✅ Build custom | N/A (domain-specific) | 100% |
| BCA KPI dashboard | ⚠️ Extend OSS | Grafana + custom panels | 30% |
| Multi-tenant auth | ✅ Use OSS | Keycloak | 15% (RBAC policies) |
| Certificate rotation | ✅ Use OSS | cert-manager, OpenBao/Vault | 5% (policies) |
| IEC 62443 audit | ✅ Build custom | N/A (compliance-specific) | 100% |

---

### 8.6 OSS Dependency Management Best Practices

#### 8.6.1 License Compliance

**Required Tools:**
- **FOSSA** or **Black Duck** (commercial) - License scanning
- **Syft + Grype** (OSS, Apache 2.0) - SBOM generation + vulnerability scanning
- **Trivy** (OSS, Apache 2.0) - Container/dependency scanning

**Policy:**
1. ✅ **Allowed:** Apache 2.0, MIT, BSD-3-Clause, MPL 2.0.
2. ⚠️ **Review Required:** LGPL, EPL 2.0 (weak copyleft).
3. ❌ **Prohibited (Linked/Integrated):** GPL, AGPL (strong copyleft) – prohibited for components statically or dynamically linked into proprietary vendor code or the core gateway binary.
4. ✅ **Allowed (Standalone Service/Binary):** GPL-licensed standalone components (e.g., Mosquitto, SWUpdate, RAUC) are allowed for infrastructure use provided they are not modified or are treated as separate processes communicating via standard protocols.
5. ⚠️ **Special Case:** **Grafana OSS** is AGPL; review obligations if you modify and provide it as a network service. For strict commercial-friendly stacks, consider alternatives (Superset/Metabase) or keep dashboards as internal-only.

#### 8.6.2 Security & CVE Monitoring

**Tools:**
- **Dependabot** (GitHub) - Automated dependency updates
- **Snyk** (free for OSS) - Vulnerability alerts
- **Trivy** - Container/SBOM scanning
- **OWASP Dependency-Check** - Java/Node.js dependency analysis

**Process:**
1. Generate SBOM (Software Bill of Materials) for all components
2. Subscribe to security mailing lists (e.g., Kubernetes security-announce)
3. Automate CVE scanning in CI/CD pipeline
4. Define SLA for patching critical vulnerabilities (e.g., 7 days)

#### 8.6.3 OSS Health Assessment

Before adopting an OSS project, check:

| Criterion | Red Flag 🚩 | Green Flag ✅ |
|-----------|------------|-------------|
| **Last commit** | > 6 months ago | < 1 month ago |
| **GitHub stars** | < 100 | > 1,000 |
| **Active contributors** | 1-2 people | 10+ people |
| **Issue response time** | > 1 week | < 24 hours |
| **Production users** | Unknown | Known enterprises |
| **Documentation** | Outdated, missing | Comprehensive, updated |
| **Release cadence** | Irregular | Regular (monthly/quarterly) |
| **Breaking changes** | Frequent | Rare, with migration guides |

**Example Assessment:**

| Project | Stars | Contributors | Last Release | Production Users | Verdict |
|---------|-------|--------------|--------------|------------------|---------|
| **EdgeX Foundry** | 1.5k | 100+ | 2 weeks ago | Dell, Intel, VMware | ✅ Adopt |
| **TimescaleDB** | 16k | 200+ | 1 week ago | Cisco, IBM, Warner Bros | ✅ Adopt |
| **Keycloak** | 20k | 500+ | 1 month ago | Red Hat, Deutsche Telekom | ✅ Adopt |
| **Random IoT Gateway** | 50 | 2 | 1 year ago | Unknown | 🚩 Avoid |

---

### 8.7 Migration Path from Custom to OSS

If you've already built custom components, migrate incrementally:

**Phase 1: Replace Infrastructure (Low Risk)**
1. Custom message broker → Kafka/NATS
2. Custom database → TimescaleDB/InfluxDB
3. Custom container orchestration → Kubernetes

**Phase 2: Replace Middleware (Medium Risk)**
4. Custom API gateway → Kong/Traefik
5. Custom auth → Keycloak
6. Custom monitoring → Prometheus + Grafana

**Phase 3: Replace Application Logic (High Risk)**
7. Custom stream processing → Flink/Kafka Streams
8. Custom alerting → Alertmanager/Kapacitor
9. Custom dashboards → Grafana

**Phase 4: Keep Domain-Specific (No Migration)**
- Vendor plugins
- RM&D analytics models
- BCA/IMDA compliance logic
- Customer-specific integrations

---

**Next:** [Part 5B: Analytics & KPI Implementation](ARCH5B_ANALYTICS_KPI.md) - Cost-efficient analytics stack, BCA KPI formulas, data lakehouse architecture
