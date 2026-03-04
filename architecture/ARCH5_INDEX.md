# RM&D OSS Architecture — Part 5: OSS Solutions, Tech Stack & Sizing

> Part 5 of 6 · Complete guide to OSS selection, analytics implementation, abstraction patterns, and technology stack

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · **ARCH5 Index** · [ARCH6 Strategy](ARCH6_STRATEGY.md)

---

## Overview

Part 5 provides comprehensive guidance on leveraging Open Source Software (OSS) to build the Nexus RM&D platform. This part is split into 4 focused documents for easier navigation and maintenance.

---

## Part 5 Documents

### **[5A: OSS Selection & Strategy](ARCH5A_OSS_SELECTION.md)** (Sections 8.1-8.7)

**Build vs. buy guidance and OSS stack recommendations**

- **8.1** Philosophy: Maximize OSS Reuse, Minimize Custom Development
- **8.2** OSS Solution Mapping by Layer (Edge SDK, Gateway, Cloud, Security)
- **8.3** Recommended OSS Stack by Deployment Scale (Small/Medium/Large)
- **8.4** OSS Alternatives Comparison (Databases, Message Brokers, Stream Processing)
- **8.5** Build vs. Integrate Decision Tree
- **8.6** OSS Dependency Management Best Practices
- **8.7** Migration Path from Custom to OSS

**Key Topics:**
- EdgeX Foundry vs ThingsBoard
- TimescaleDB vs InfluxDB vs QuestDB
- Kafka vs NATS vs MQTT
- Zero Trust Security Stack (100% OSS)
- License compliance (Apache 2.0, MIT, AGPL considerations)

---

### **[5B: Analytics & KPI Implementation](ARCH5B_ANALYTICS_KPI.md)** (Section 8.8)

**Cost-efficient analytics stack and BCA KPI formulas**

- **8.8.1** Recommended Minimal Stack (< 10k devices)
- **8.8.2** Balanced Stack (Production-ready)
- **8.8.3** IoT-Optimized Alternative Stack
- **8.8.4** Modern Data Lakehouse Architecture (Apache Iceberg, Trino, Unity Catalog)
- **8.8.5** BCA KPI Implementation (Exact formulas with SQL examples)
  - TFPE (Technical Faults Per Equipment)
  - FTTR (First Time Fix Rate)
  - MTTR (Mean Time To Repair)
  - DA (Device Availability)
  - UT (Average Monthly Uptime)
  - DiA (Diagnostics Accuracy)
  - Sustainability & Energy Dashboard
- **8.8.6** Real-Time vs. Historical Analytics
- **8.8.7** Mobile Dashboard Support
- **8.8.8** Cost Breakdown by Deployment Scale
- **8.8.9** Key Success Metrics
- **8.8.10** AI Agent Deployment Compatibility
- **8.8.11** Data Quality, Semantic Integrity & Flow Control
- **8.8.12** License Verification for Modern Data Stack

**Key Topics:**
- VictoriaMetrics + QuestDB + Grafana stack
- BCA compliance dashboards with exact SQL queries
- Configuration-as-Code (Jsonnet, Terraform)
- Data Lakehouse vs Traditional ETL
- Brick Schema for semantic interoperability
- Cost comparison: OSS vs Commercial solutions (70-90% cheaper)

---

### **[5C: Infrastructure Abstraction Patterns](ARCH5C_ABSTRACTION.md)** (Section 8.9)

**Minimize infrastructure lock-in through Ports & Adapters architecture**

- **8.9.1** Architecture Pattern: Ports & Adapters (Hexagonal Architecture)
- **8.9.2** Port Definitions (Interfaces)
  - `ITimeSeriesStore` (TimescaleDB, InfluxDB, QuestDB adapters)
  - `IMessageBroker` (Kafka, NATS, MQTT adapters)
  - `IGatewayAdapter` (EdgeX, ThingsBoard adapters)
  - `IAPIGateway` (Kong, Traefik adapters)
- **8.9.3** Configuration-Driven Adapter Selection
- **8.9.4** Testing Strategies (Mock adapters, Testcontainers)
- **8.9.5** Migration Playbooks (Zero-downtime dual-write pattern)
- **8.9.6** Real-World Example: BCA KPI Service (Infrastructure-agnostic)
- **8.9.7** Benefits Summary
- **8.9.8** License Compliance for Adapter Implementations
- **8.9.9** Implementation Roadmap

**Key Topics:**
- Interface-based abstraction for all infrastructure components
- Switch from Mosquitto → Kafka with a single config change
- Mock adapters for unit testing
- Dual-write pattern for zero-downtime migration
- TypeScript/Go/Python implementation examples
- 5-phase implementation roadmap

---

### **[5D: Technology Stack & Resource Sizing](ARCH5D_TECH_STACK.md)** (Sections 9-10)

**Specific technology choices and resource sizing guidelines**

- **9.1** Edge Device SDK (Languages, Protocols, Security, OTA)
- **9.2** Gateway (Languages, Message Brokers, Protocol Adapters, Edge Analytics)
- **9.3** Cloud Platform (Detailed recommendations per layer)
- **9.4** Infrastructure Automation Tooling Matrix
  - IaC tools by layer (Edge, API Gateway, Message Broker, Database, etc.)
  - CI/CD integration
  - Observability tooling
- **10** Reference Architecture Sizing
  - Small deployment (< 1,000 devices)
  - Medium deployment (1,000-10,000 devices)
  - Large deployment (10,000-100,000 devices)
  - Enterprise deployment (100,000+ devices)
- **Glossary** - Key terms and definitions

**Key Topics:**
- Specific technology choices per layer
- Terraform vs Pulumi vs Helm
- Resource sizing guidelines (CPU, RAM, Storage)
- Cost estimation by deployment scale
- Observability stack (Prometheus, Grafana, Jaeger)

---

## Quick Reference

### Core Philosophy

**90% OSS, 10% Custom Code** - Don't rebuild what already exists

### Decision Framework

```text
Is there mature OSS? → Yes → Use it (90% of cases)
                     → No  → Is it RM&D-specific? → Yes → Build custom
                                                  → No  → Reconsider (likely exists)
```

### Recommended Stack (Production)

| Layer | Small Deployment | Medium Deployment | Large Deployment |
|-------|------------------|-------------------|------------------|
| **Gateway** | Node-RED/ThingsBoard | EdgeX Foundry | EdgeX + KubeEdge |
| **Database** | PostgreSQL | TimescaleDB (HA) | TimescaleDB (distributed) |
| **Message Broker** | Mosquitto (MQTT) | NATS/Kafka | Kafka (multi-region) |
| **Visualization** | Grafana | Grafana + Prometheus | Grafana (federated) |
| **Container** | Docker Compose | Kubernetes (managed) | Kubernetes (multi-cluster) |

### License Policy

- ✅ **Allowed:** Apache 2.0, MIT, BSD-3-Clause, MPL 2.0
- ⚠️ **Review Required:** LGPL, EPL 2.0, AGPL (network service)
- ❌ **Prohibited (Linked):** GPL, AGPL (for components embedded in proprietary code)
- ✅ **Allowed (Standalone):** GPL/AGPL (for infrastructure services like Mosquitto, Grafana)

---

## Navigation

**Previous:** [Part 4: Deployment & Operations](ARCH4_DEPLOYMENT.md)
**Next:** [Part 6: Strategic Recommendations](ARCH6_STRATEGY.md)

**Part 5 Sections:**
- [5A: OSS Selection & Strategy](ARCH5A_OSS_SELECTION.md)
- [5B: Analytics & KPI Implementation](ARCH5B_ANALYTICS_KPI.md)
- [5C: Infrastructure Abstraction Patterns](ARCH5C_ABSTRACTION.md)
- [5D: Technology Stack & Resource Sizing](ARCH5D_TECH_STACK.md)

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2026-03-04 | Split ARCH5_OSS_STACK.md into 4 focused documents for better navigation |
| 1.0 | - | Original monolithic ARCH5_OSS_STACK.md (73KB, 3043 lines) |
