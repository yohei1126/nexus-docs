# RM&D OSS Architecture — Part 5: OSS Solutions, Tech Stack & Sizing

> Part 5 of 6 · Sections 8–10: Build-vs-buy guidance, OSS stack recommendations, BCA KPI implementation, resource sizing.

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · [ARCH5 OSS Stack](ARCH5_OSS_STACK.md) · [ARCH6 Strategy](ARCH6_STRATEGY.md)

---

### Clarification: Normative vs. Informative
To maintain architectural maintainability and implementation flexibility, readers should distinguish between:

*   **Normative (Mandatory):** Core architecture requirements that **must** be implemented to satisfy agency standards (BCA, MPA, NEA, PUB) and security/policy mandates (e.g., IEC 62443 mapping, Canonical Telemetry Envelope).
*   **Informative (Examples):** Sector-specific KPI implementations (e.g. BCA Annex A for Lifts), suggested OSS components (e.g., QuestDB), and baseline thresholds. These serve as **initial implementation modules** and can be extended or replaced as the platform scales to new industries.

---

## 8. Leveraging Existing OSS Solutions (Build vs. Buy vs. Integrate) {#8-leveraging-existing-oss-solutions}

This section provides comprehensive guidance on selecting and integrating existing OSS components. For specific technology recommendations, see [Section 9](#9-technology-stack-recommendations). For deployment automation, see [IaC Deployment (ARCH4)](ARCH4_DEPLOYMENT.md#7.4-infrastructure-as-code-iac-deployment-strategy) and [Section 9.4](#9.4-infrastructure-automation-tooling-matrix) (in this document).

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

### 8.8 Cost-Efficient Analytics & Dashboard Stack

**Design Requirements:**

1. **Local/Cloud Portability:** Same configuration works on Docker Compose (local) and Kubernetes (cloud)
2. **Configuration-as-Code:** Full IaC support (YAML, Jsonnet, Terraform) for AI agent deployment
3. **Cost Efficiency:** Lightweight, minimal resource usage, avoid expensive commercial solutions
4. **BCA Compliance:** Support for all 7 mandatory KPIs (TFPE, FPE, FTTR, MTTR, UT, DiA, DA) per Annex A.

#### 8.8.1 Recommended Minimal Stack (Best for <10k devices)

**Philosophy:** Prioritize simplicity, low cost, and ease of deployment over enterprise features

| Component | OSS Solution | License | Why | Monthly Cost |
|-----------|--------------|---------|-----|--------------|
| **Metrics Storage** | **VictoriaMetrics** | Apache 2.0 | 10x more storage-efficient than Prometheus, drop-in compatible | $50-60 (single VM) |
| **Time-Series DB** | **QuestDB** | Apache 2.0 | Fastest ingestion, 1/10th resource vs TimescaleDB, SQL interface | Included |
| **Visualization** | **Metabase** or **Grafana** | AGPL v3 / AGPL v3 | Metabase: simpler, JSON configs; Grafana: more powerful | Included |
| **Message Queue** | **NATS JetStream** | Apache 2.0 | 7MB binary vs Kafka's JVM overhead, Kafka-like features | Included |
| **Metrics Collection** | **Telegraf** | MIT | Lightweight, multi-protocol, plugin-based | Included |

**Resource Footprint (Total):**

- **Development:** 4GB RAM, 2 CPU cores, 20GB disk
- **Production (10k devices):** 8GB RAM, 4 CPU cores, 100GB SSD
- **Cost:** $50-65/month (AWS t3.large, GCP e2-standard-2, or $10/month on Hetzner)

**vs. Traditional Stack (Elasticsearch + Kibana + Kafka):**

- **Resource Reduction:** 75% less RAM, 60% less storage
- **Cost Reduction:** 80% cheaper ($50 vs $250/month)
- **Deployment Time:** 10 minutes vs 2 hours

#### 8.8.2 Balanced Stack (Recommended for Production)

**Philosophy:** Balance between cost, scalability, and enterprise features

| Component | OSS Solution | License | Key Benefits | Custom Dev |
|-----------|--------------|---------|--------------|------------|
| **Metrics Storage** | **VictoriaMetrics** | Apache 2.0 | Prometheus-compatible, scales to millions of series | 0% |
| **Time-Series DB** | **QuestDB** | Apache 2.0 | SQL interface, Grafana integration, low resources | 10% (schema) |
| **Visualization** | **Grafana OSS** | AGPL v3 | Industry-standard, YAML provisioning, Jsonnet support (Review AGPL obligations) | 20% (BCA KPIs) |
| **Message Queue** | **NATS JetStream** | Apache 2.0 | Lightweight, persistent, effectively-once patterns with consumer acks + idempotent processing | 5% (config) |
| **Dashboard-as-Code** | **Grafonnet** (Jsonnet) | Apache 2.0 | Generate Grafana dashboards from code, version control | 15% (templates) |
| **Deployment** | **Docker Compose** + **Kubernetes** | Apache 2.0 | Identical config for local/cloud, Helm charts | 10% (manifests) |

**Resource Footprint:**

- **Production (10k devices):** 8-16GB RAM, 4-8 CPU cores, 500GB SSD
- **Cost:** $150-300/month (managed K8s or 1-2 VMs)

**Total Custom Development:** ~20-25% (BCA KPI calculations, compliance dashboards, alert rules)

#### 8.8.3 IoT-Optimized Alternative Stack

For deployments prioritizing all-in-one simplicity over modularity:

| Component | OSS Solution | License | Why |
|-----------|--------------|---------|-----|
| **IoT Platform** | **ThingsBoard CE** | Apache 2.0 | Built-in dashboards, device management, rule engine, multi-tenancy |
| **Time-Series DB** | **QuestDB** or **TimescaleDB** | Apache 2.0 | Native ThingsBoard integration |
| **Custom BCA KPIs** | **Streamlit** | Apache 2.0 | Python-based dashboards, perfect for custom KPI calculations |

**Cons:** Less flexibility for vendor plugins, harder to customize

#### 8.8.4 Modern Data Lakehouse & Zero-Copy Interoperability (Recommended for Multi-Sector Scale) {#8.8.4-lakehouse}

**Philosophy:** Move away from "Data Silos + Expensive ETL" towards an open **Data Lakehouse** architecture. By using open table formats, the platform allows third parties and other agencies to query data **in-place** without creating redundant, costly copies.

| Layer | Recommended OSS | Why |
|:--- |:--- |:--- |
| **Storage Format** | **Apache Iceberg** | Open table format for huge analytics datasets. Enables "Time Travel" and atomic transactions on S3/MinIO. |
| **Query & Processing** | **Trino / DuckDB / Polars** | **Multi-Engine Strategy.** <br>- **Trino:** Federated scale-out queries across heterogeneous sources. <br>- **DuckDB:** Ultra-fast, single-node OLAP (ideal for edge or small-cloud). <br>- **Polars:** High-performance dataframes for in-memory analytics and AI/ML pipelines. |
| **Catalog & Governance** | **Unity Catalog (OSS)** | **Universal Data & AI Governance.** Supports Iceberg, Delta, and volumes (unstructured data). Integrated RBAC, auditing, and lineage. |

**Key Benefits vs. Traditional ETL:**
1. **Zero Copy:** Third parties (NEA/MPA) can query Nexus data using Trino connectors, avoiding the $10k+/mo cloud egress and storage costs of copying data.
2. **Schema Evolution:** Iceberg handles column changes without rewriting entire datasets.
3. **Multi-Vendor Analytics:** Vendors can run their own Spark/Flink jobs directly against the Lakehouse storage without an intermediate API layer.

**Lakehouse Architecture Diagram:**
```text
┌──────────────────────────────────────────────────────────────────┐
│                      Nexus Data Lakehouse                        │
│                                                                  │
│  ┌──────────────┐      ┌────────────────┐      ┌──────────────┐  │
│  │ Third Parties│ ◄────┤  Trino/DuckDB  ├─────►│ Agency Users │  │
│  └──────────────┘      └───────┬────────┘      └──────────────┘  │
│                                │                                 │
│                   ┌────────────┴───────────┐                     │
│                   │ Unity Catalog (OSS)    │ (Data & AI Governance)      │
│                   └────────────┬───────────┘                     │
│                                │                                 │
│  ┌──────────────────┐  ┌───────▼────────┐  ┌──────────────────┐  │
│  │  QuestDB (Hot)   │  │ Iceberg (Warm) │  │ Parquet (Cold)   │  │
│  │ (DuckDB/Polars)  │  │ (Zero-Copy)    │  │ (Deep Archive)   │  │
│  └──────────────────┘  └────────────────┘  └──────────────────┘  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

#### 8.8.5 Sector-Specific KPI Implementation (BCA / Smart FM First) {#8.8.5-kpi-implementation}

The Nexus platform supports sector-specific "KPI modules". While the **Built Environment (BCA)** is the lead sector for this release, the analytics engine is designed to accommodate Water (PUB), Maritime (MPA), and Cleaning (NEA) requirements.

This section provides **exact mathematical definitions** for BCA-mandated KPIs as specified in the [BCA Code of Practice for RM&D Solutions for Lifts](https://www1.bca.gov.sg/docs/default-source/docs-corp-regulatory/lifts-and-escalators-legislation/code-of-practice-for-design-and-performance-of-remote-monitoring-and-diagnostics-solution-for-lifts-(final).pdf).

##### 8.8.4.1 Exact KPI Formulas

**1. TFPE - Technical Faults Per Equipment**

```
TFPE = Total Technical Faults / Total Equipment / Reporting Period (months)
```

**Definition:**
- **Numerator:** Count of technical faults (excludes non-technical faults per Annex B)
- **Denominator:** Number of lifts × number of months
- **Unit:** Faults per equipment per month

**Exclusions (per BCA Annex B - Non-Technical Faults):**
- Vandalism
- Water ingress (flooding, rain damage)
- External power failure
- Building structural issues affecting lift
- User misuse (overloading, obstructing doors)

**SQL Query Example:**

```sql
SELECT
  DATE_TRUNC('month', fault_time) AS month,
  COUNT(*) FILTER (WHERE fault_category = 'technical') / COUNT(DISTINCT device_id) AS tfpe
FROM faults
WHERE fault_time >= NOW() - INTERVAL '12 months'
  AND fault_category != 'vandalism'
  AND fault_category != 'water_ingress'
  AND fault_category != 'external_power'
GROUP BY month;
```

**Target:** < 0.5 faults/equipment/month (BCA benchmark)

---

**2. FTTR - First Time Fix Rate (Annex A)**

```
FTTR = (Faults Fixed on First Visit / Total Faults Closed) × 100%
```

**Definition:**
- **Numerator:** Faults resolved without requiring follow-up visit
- **Denominator:** All faults marked as "closed" or "resolved"
- **Unit:** Percentage
- **Rolling Window:** 30-day trailing average (as defined in BCA Annex A)

**Classification Rules:**
- **First-time fix:** Fault closed with `visit_count = 1`
- **Repeat fix:** Fault required `visit_count > 1` (e.g., parts not available, incorrect diagnosis)

**SQL Query Example:**

```sql
SELECT
  DATE_TRUNC('day', closed_at) AS day,
  COUNT(*) FILTER (WHERE visit_count = 1) * 100.0 / COUNT(*) AS fttr_pct
FROM faults
WHERE closed_at >= NOW() - INTERVAL '30 days'
  AND status = 'closed'
GROUP BY day
ORDER BY day DESC
LIMIT 30;
```

**Dashboard Implementation:**
- Display as 30-day moving average to smooth daily fluctuations
- Drill-down by contractor to identify performance issues
- Alert if FTTR < 80% for 7 consecutive days

**Target:** > 85% (BCA benchmark)

---

**3. MTTR - Mean Time To Repair**

```
MTTR = Σ(fault_cleared_time - fault_reported_time) / Total Faults
```

**Definition:**
- **Numerator:** Sum of repair durations for all faults
- **Denominator:** Count of faults
- **Unit:** Hours
- **Calculation:** Per fault category (critical vs. non-critical)

**Exclusions (Major Repairs - NOT Included in MTTR):**
- Repairs exceeding 24 hours
- Major modernization work
- Parts unavailable (supplier delay)
- Waiting for building management approval
- External dependencies (power utility, structural work)

**SQL Query Example:**

```sql
SELECT
  severity,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY repair_duration_hours) AS mttr_median,
  AVG(repair_duration_hours) AS mttr_mean
FROM (
  SELECT
    severity,
    EXTRACT(EPOCH FROM (cleared_at - reported_at)) / 3600 AS repair_duration_hours
  FROM faults
  WHERE cleared_at IS NOT NULL
    AND status = 'closed'
    AND EXTRACT(EPOCH FROM (cleared_at - reported_at)) / 3600 < 24  -- Exclude >24h repairs
    AND exclusion_reason IS NULL  -- Exclude flagged cases
    AND reported_at >= NOW() - INTERVAL '3 months'
) AS repairs
GROUP BY severity;
```

**Exclusion Flagging Logic:**

```sql
UPDATE faults
SET exclusion_reason = 'major_repair'
WHERE EXTRACT(EPOCH FROM (cleared_at - reported_at)) / 3600 > 24
   OR fault_description ILIKE '%modernization%'
   OR fault_description ILIKE '%part not available%';
```

**BCA Targets:**
- **Critical faults:** MTTR < 2 hours
- **Non-critical faults:** MTTR < 8 hours

---

**4. DA - Device Availability**

```
DA = (Total Uptime Minutes / Total Minutes in Period) × 100%
```

**Definition:**
- **Numerator:** Minutes device was operational (not faulted or offline)
- **Denominator:** Total minutes in reporting period (e.g., 43,200 min/month)
- **Unit:** Percentage

**State Classification:**
- **Uptime:** Device status = `operational` OR `idle`
- **Downtime:** Device status = `faulted` OR `offline` OR `maintenance`

**Calculation Methods:**

**Method A: Event-based (High Accuracy)**

```sql
WITH uptime_intervals AS (
  SELECT
    device_id,
    status,
    timestamp AS start_time,
    LEAD(timestamp) OVER (PARTITION BY device_id ORDER BY timestamp) AS end_time
  FROM device_state_changes
  WHERE timestamp >= DATE_TRUNC('month', NOW())
)
SELECT
  device_id,
  SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 60) FILTER (WHERE status IN ('operational', 'idle')) AS uptime_min,
  SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 60) AS total_min,
  SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 60) FILTER (WHERE status IN ('operational', 'idle')) * 100.0 /
    NULLIF(SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 60), 0) AS availability_pct
FROM uptime_intervals
WHERE end_time IS NOT NULL
GROUP BY device_id;
```

**Method B: Polling-based (Simpler)**

```sql
SELECT
  device_id,
  COUNT(*) FILTER (WHERE status IN ('operational', 'idle')) * 100.0 / COUNT(*) AS availability_pct
FROM device_status_snapshots
WHERE snapshot_time >= DATE_TRUNC('month', NOW())
  AND snapshot_interval = '5 minutes'
GROUP BY device_id;
```

**BCA Target:** > 99% monthly availability

---

**5. UT - Average Monthly Uptime**

```
UT = (DA₁ + DA₂ + ... + DAₙ) / n
```

**Definition:**
- **Numerator:** Sum of daily availability percentages
- **Denominator:** Number of days in month
- **Unit:** Percentage

**Note:** This is the **arithmetic mean** of daily DA values.

**SQL Query Example:**

```sql
SELECT
  device_id,
  DATE_TRUNC('month', day) AS month,
  AVG(daily_availability_pct) AS avg_monthly_uptime
FROM (
  SELECT
    device_id,
    DATE_TRUNC('day', timestamp) AS day,
    SUM(uptime_seconds) * 100.0 / 86400 AS daily_availability_pct
  FROM device_uptime_events
  GROUP BY device_id, day
) AS daily_stats
GROUP BY device_id, month;
```

---

**6. DiA - Diagnostics Accuracy**

```
DiA = (True Positives / (True Positives + False Positives)) × 100%
```

**Definition:**
- **True Positive:** Predicted fault confirmed by technician inspection
- **False Positive:** Predicted fault NOT confirmed (false alarm)
- **False Negative:** Actual fault NOT predicted (missed detection)
- **Unit:** Percentage (Precision metric)
- **BCA Target:** ≥ 85% (per BCA RM&D Code of Practice benchmark)

**Classification Logic:**

| Prediction | Actual Fault? | Classification |
|------------|---------------|----------------|
| Fault predicted | Fault confirmed | True Positive (TP) |
| Fault predicted | No fault found | False Positive (FP) |
| No fault predicted | Fault occurred | False Negative (FN) |
| No fault predicted | No fault | True Negative (TN) |

**SQL Query Example:**

```sql
SELECT
  prediction_type,
  COUNT(*) FILTER (WHERE confirmed = true) AS true_positives,
  COUNT(*) FILTER (WHERE confirmed = false) AS false_positives,
  COUNT(*) FILTER (WHERE confirmed = true) * 100.0 /
    NULLIF(COUNT(*), 0) AS diagnostics_accuracy_pct
FROM predictions
WHERE prediction_time >= NOW() - INTERVAL '3 months'
  AND verification_status = 'completed'
GROUP BY prediction_type;
```

**BCA Target:** ≥ 85% diagnostics accuracy (benchmark required per BCA RM&D Code of Practice for Lifts)

**Note:** This KPI validates the effectiveness of ML-based fault prediction algorithms.

---

**7. Sustainability & Energy Dashboard**
- Real-time energy consumption tracking (kW/h)
- Carbon footprint estimation (CO2e) based on equipment usage
- Efficiency benchmarking across building fleets (SUS pillar)
- Alert for abnormal energy usage (potential equipment degradation)

---

##### 8.8.4.2 Mandatory Components (Custom Development ~30%)

**1. KPI Calculation Engine**

Implement the above formulas as SQL views or time-series queries:

```sql
-- Create materialized view for daily KPI calculation
CREATE MATERIALIZED VIEW bca_kpi_daily AS
SELECT
  device_id,
  DATE_TRUNC('day', timestamp) AS day,
  -- TFPE calculation
  COUNT(*) FILTER (WHERE fault_type = 'technical') AS technical_faults,
  -- FTTR calculation
  COUNT(*) FILTER (WHERE visit_count = 1 AND status = 'closed') * 100.0 /
    NULLIF(COUNT(*) FILTER (WHERE status = 'closed'), 0) AS fttr_pct,
  -- MTTR calculation
  AVG(EXTRACT(EPOCH FROM (cleared_at - reported_at)) / 3600)
    FILTER (WHERE EXTRACT(EPOCH FROM (cleared_at - reported_at)) / 3600 < 24) AS mttr_hours,
  -- DA calculation
  SUM(uptime_seconds) * 100.0 / 86400 AS availability_pct
FROM faults
LEFT JOIN device_uptime USING (device_id, day)
GROUP BY device_id, day;

-- Refresh daily
REFRESH MATERIALIZED VIEW bca_kpi_daily;
```

**2. Custom Grafana Panels**
- BCA compliance dashboard template (pre-configured JSON)
- Fault classification dropdown (technical vs. non-technical per Annex B)
- MTTR exclusion panel (auto-detect major repairs based on duration > 24h)
- Multi-dimensional filtering (building, floor, contractor, OEM)

**3. Alert Engine (Typical Baseline)**

Alert thresholds represent **typical baseline** values (tunable via configuration):

- Device offline alerts: Trigger if DA < 99% for > 2 hours (baseline)
- Repeated fault detection: Alert if FTTR < 80% for 7 days (baseline)
- MTTR threshold exceeded: Alert if MTTR > 2h for critical faults (baseline)
- Diagnostics accuracy drop: Alert if DiA < 70% for 30 days (baseline)

**4. Export Module**
- CSV/PDF/Excel export for BCA regulatory submission
- Monthly compliance report templates (auto-generated)
- Quarterly maintenance summaries with KPI trends

**5. Data Quality Checks**

Before calculating KPIs, validate:

```sql
-- Check for missing timestamps
SELECT COUNT(*) FROM faults WHERE reported_at IS NULL OR cleared_at IS NULL;

-- Check for data integrity (cleared before reported)
SELECT COUNT(*) FROM faults WHERE cleared_at < reported_at;

-- Check for classification errors
SELECT COUNT(*) FROM faults WHERE fault_category IS NULL;

-- Alert if > 1% of records have data quality issues
```

---

##### 8.8.4.3 Reference Implementation

See `/reference-implementation/kpi-engine/` for:
- SQL scripts for KPI calculation
- Grafana dashboard JSON templates
- Alert rule definitions (Prometheus/Grafana)
- Python/Go microservice for real-time KPI computation

**Technology Stack:**
- **Time-series DB:** QuestDB or TimescaleDB (for efficient time-range queries)
- **Scheduler:** Apache Airflow or Kubernetes CronJob (for daily materialized view refresh)
- **Alerting:** Prometheus Alertmanager or Grafana Alerts
- **Export:** Pandas (Python) or golang/excelize for Excel generation

#### 8.8.5 Configuration-as-Code Approach

**Key Principle:** Zero manual UI clicks, 100% version-controlled configuration

**IaC Components:**

1. **Docker Compose** (local development)
   - Single YAML file defines entire stack
   - Environment variables for secrets
   - Volume mounts for config files

2. **Grafana Provisioning**
   - `datasources.yml` - Pre-configured data sources
   - `dashboards.yml` - Dashboard providers
   - Jsonnet/JSON - Dashboard definitions

3. **Kubernetes Helm Charts**
   - `values.yaml` - Environment-specific config
   - Same Docker images as local development
   - Automated deployment via Terraform/Pulumi

4. **Terraform/Pulumi**
   - Infrastructure provisioning (VMs, storage, networking)
   - Cloud-agnostic (works on AWS, GCP, Azure, DigitalOcean)

**Deployment Flow:**

```text
1. Developer: Edit Jsonnet dashboard → Generate JSON
2. Git commit → CI/CD pipeline triggered
3. Automated tests → Validate dashboard syntax
4. Deploy to staging → Docker Compose or K8s
5. Manual approval → Deploy to production
6. Rollback support → Version-controlled configs
```

#### 8.8.6 Real-Time vs. Historical Analytics

**Real-Time Dashboards (<5s latency):**

- Current lift status (floor, door, movement)
- Active faults and alerts
- Device online/offline status
- Live technician dispatch

**Tech Stack:** MQTT → NATS → QuestDB → Grafana (WebSocket auto-refresh)

**Historical Analytics (Daily/Monthly/Yearly):**

- KPI trend analysis (TFPE, MTTR trends over time)
- Seasonal fault patterns
- Maintenance quality tracking (FTTR improvement)
- Predictive maintenance forecasting

**Tech Stack:** QuestDB continuous aggregates → Grafana dashboards

#### 8.8.11 Data Quality, Semantic Integrity & Flow Control {#8.8.11-data-quality}

For a national-scale RM&D platform, technical data collection is only half the battle. Ensuring the **quality** and **meaning** of that data is critical for achieving the BCA's 85% diagnostics accuracy target.

##### 8.8.11.1 Semantic Interoperability (Brick Schema)

To avoid "Data Swamps," Nexus recommends using **Brick Schema** for metadata mapping:
- **Challenge:** Vendor A calls it `rm_temp`, Vendor B calls it `room_t`.
- **Solution:** Use a semantic mapping layer (implemented in Unity Catalog or dbt) to tag these points as `brick:Temperature_Sensor`. This allows analytics to run across multi-vendor fleets without custom code for each device.

##### 8.8.11.2 Data Observability & Quality (Great Expectations)

"Bad data is worse than no data." Nexus integrates data quality checks:
- **Tools:** **dbt tests** or **Great Expectations** (OSS).
- **Checks:** 
    - **Freshness:** Is data arriving within the 30s window?
    - **Validity:** Are temperatures within physical limits (e.g., -50°C to 100°C)?
    - **Consistency:** Does the "Door Open" event match the "Lift at Floor" state?
- **Action:** Data failing quality checks is tagged with an `is_valid=false` flag and excluded from KPI calculations (BCA Annex A) to prevent skewed accuracy metrics.

##### 8.8.11.3 IoT Flow Control & Back-pressure (NATS JetStream)

During network outages or localized surges, the system must handle back-pressure:
- **Strategy:** Use **NATS JetStream** with pull-consumers.
- **Benefit:** If the Cloud Ingestion layer is slow, the Edge Gateway buffers data locally. Once restored, the Cloud "pulls" at its own pace, preventing message loss or system crashes (OOM) during catch-up periods.

---

#### 8.8.12 License Verification for Modern Data Stack {#8.8.12-license}

To ensure the "Maximum Commercial Freedom" principle, all recently added data components have been verified for commercial use:

| Component | License | Permissiveness | Rationale |
|:---|:---|:---|:---|
| **Unity Catalog (OSS)** | **Apache 2.0** | ✅ Commercial-friendly | Standard for universal governance without Databricks lock-in. |
| **Apache Iceberg** | **Apache 2.0** | ✅ Commercial-friendly | Foundation-backed, no "Bus Test" risk. |
| **Trino** | **Apache 2.0** | ✅ Commercial-friendly | High-performance SQL without GPL constraints. |
| **DuckDB** | **MIT** | ✅ Commercial-friendly | Permissive, can be embedded in proprietary edge software. |
| **Polars** | **MIT** | ✅ Commercial-friendly | Permissive, high-performance processing. |
| **Great Expectations**| **Apache 2.0** | ✅ Commercial-friendly | Industry standard for data quality. |
| **Brick Schema** | **BSD 3-Clause** | ✅ Commercial-friendly | Open semantic standard for Built Environment. |

> [!TIP]
> **Commercial Advantage:** By sticking to Apache 2.0 and MIT licenses, system integrators and vendors can build proprietary value-added services atop the Nexus core without legal risks of source code disclosure (Copyleft).

---

#### 8.8.7 Mobile Dashboard Support

**BCA Requirement:** "Web-based interface and/or mobile application"

**Options:**

1. **Grafana Mobile** (Limited) - Basic viewing, push notifications
2. **Progressive Web App (PWA)** - Responsive Grafana, offline caching, installable
3. **React Native + Grafana API** - Full customization, native experience

**Recommended:** **PWA** for fastest deployment with native-like experience

#### 8.8.8 Cost Breakdown by Deployment Scale

| Scale | Devices | Stack | CPU | RAM | Storage | Monthly Cost |
|-------|---------|-------|-----|-----|---------|--------------|
| **Small** | <1,000 | Minimal (VictoriaMetrics + QuestDB + Grafana) | 2 vCPU | 8GB | 100GB | $50-60 |
| **Medium** | 1k-10k | Balanced (+ NATS JetStream + Telegraf) | 4 vCPU | 16GB | 500GB | $150-250 |
| **Large** | 10k-100k | Clustered (VictoriaMetrics cluster + K8s) | 16 vCPU | 64GB | 2TB | $800-1,200 |
| **Enterprise** | 100k+ | Multi-region (Federated Grafana + distributed DB) | 64+ vCPU | 256GB+ | 10TB+ | $5,000-10,000 |

**Cost Comparison vs. Commercial Solutions:**

- vs. **AWS Timestream + QuickSight:** 70-80% cheaper
- vs. **Datadog IoT:** 85-90% cheaper
- vs. **New Relic:** 80-85% cheaper

#### 8.8.9 Key Success Metrics

| Metric | Target | Why Important |
|--------|--------|---------------|
| Dashboard load time | <3 seconds | User experience |
| KPI calculation accuracy | 100% match with BCA formulas | Regulatory compliance |
| Alert false positive rate | <5% | Operational efficiency |
| Data export success rate | 99.9% | Compliance reporting |
| System uptime SLA | 99.5% | Business continuity |
| Cost per device/month | <$0.05 | Economic viability |

#### 8.8.10 AI Agent Deployment Compatibility

**Why this stack is AI agent-friendly:**

1. ✅ **Declarative Configuration:** YAML/JSON/Jsonnet - parseable by LLMs
2. ✅ **Idempotent Deployment:** Re-running deployment is safe
3. ✅ **Version Control:** All configs in Git, trackable changes
4. ✅ **Automated Testing:** Dashboard syntax validation, health checks
5. ✅ **Self-Documenting:** Configuration doubles as documentation
6. ✅ **Rollback Support:** Git revert = instant rollback

**AI Agent Tasks:**

- Generate BCA KPI dashboard from requirements
- Modify alert thresholds based on historical data
- Create custom dashboards for new device types
- Optimize resource allocation based on metrics
- Auto-scale infrastructure based on device count

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

