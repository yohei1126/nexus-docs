# RM&D OSS Architecture — Part 1: Overview & Layered Design

> Part 1 of 6 · Sections 1–2: Architecture overview and layered design (Edge, Gateway, Cloud).

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · [ARCH5 OSS Stack](ARCH5_OSS_STACK.md) · [ARCH6 Strategy](ARCH6_STRATEGY.md)

---

### Clarification: Normative vs. Informative
To maintain architectural maintainability and implementation flexibility, readers should distinguish between:

*   **Normative (Mandatory):** Requirements that **must** be implemented to ensure core system compatibility, security, and policy compliance (e.g., layered design, trust boundaries, canonical telemetry schemas, BCA Annex A KPIs).
*   **Informative (Examples):** Specific tool recommendations (e.g., Prometheus, Grafana), baseline values/thresholds (e.g., "1 hour session", "weekly scans"), and example cloud stacks. These serve as **provisional defaults** and can be substituted with equivalent specialized tooling during implementation.

---

# Remote Monitoring & Diagnostics (RM&D) OSS Architecture

> **Policy Mandate:** This architecture is designed to help Singapore reach the **Built Environment ITM (2022)** target of 80% of public buildings adopting Smart FM by 2030. Every design decision — open protocols, composable modules, IEC 62443 security — maps back to that national goal. See [BCA_VISION.md](BCA_VISION.md) for the full policy chain. For other sector mappings (Maritime, Water, Env Services), see the [Architecture Index](summary/ARCHITECTURE.md).

## Executive Summary

This document proposes a **commercial-friendly open-source architecture** for Remote Monitoring & Diagnostics (RM&D) solutions compliant with Singapore government security guidelines (IMDA, CSA, GovTech, BCA).

**Key Design Principles:**
- **Edge-first OSS:** Lightweight, commercial-friendly licensing (Apache 2.0/MIT) for high-volume edge deployments
- **Vendor IP Protection:** Plugin architecture allowing vendors to protect proprietary algorithms and business logic
- **Cloud Flexibility:** Choice between OSS self-hosted or commercial managed services
- **Multi-vendor Ecosystem:** Standardized interfaces enabling heterogeneous device integration
- **Compliance by Design:** Built-in support for IEC 62443, IMDA IoT Security Guide, GovTech Zero Trust, **BCA RM&D Code of Practice**
- **ITM Aligned:** Architecture satisfies the SUS pillar (Smart FM), IPD pillar (OPC UA / Common Data Environment), and AMA pillar (predictive component replacement)
- **Sustainability & Decarbonization:** Enables granular energy and equipment efficiency monitoring to support Singapore's Green Plan 2030 and ITM decarbonization targets.

**The Nexus Value Proposition:**
Nexus addresses the **proprietary fragmentation** that currently prevents the ITM targets from being met at scale. By providing a pre-compliant (IEC 62443 / TR 91), open-standard platform, it lowers the cost for vendors to participate in the Smart FM ecosystem while allowing building owners (HDB, JTC, LTA) to aggregate data across multiple equipment brands.

### Unified Platform Philosophy: "Common Core, Sector Plugins"
The architecture is built on the principle that 90% of RM&D requirements are identical across sectors (Security, Ingestion, Storage, Multi-tenancy). Nexus provides this **Common Core**, allowing stakeholders to achieve disparate sectoral visions (BCA, MPA, NEA, PUB) simply by deploying domain-specific **Plugins**:

| Feature | The "Common Core" (Generic) | Sector-Specific (The Plugin) |
|:---|:---|:---|
| **Security** | mTLS, TR 91 Compliance, IAM | Domain-specific access control lists |
| **Ingestion** | Canonical Telemetry Envelope | Custom sensor mappings (e.g. Lift Floor vs Water Pressure) |
| **Analytics** | Alerting Engine & Time-series DB | Sector Logic (e.g. "Lift Door Jam" vs "Pump Cavitation") |
| **KPIs** | Dashboard Framework | Official metrics (e.g. BCA DiA vs NEA Demand% ) |

---

## 1. Architecture Overview

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                          VENDOR ECOSYSTEM                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  │ Lift Vendor  │  │ HVAC Vendor  │  │ Pump Vendor  │  │ AMR Vendor   ││
│  │   Plugin     │  │   Plugin     │  │   Plugin     │  │   Plugin     ││
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘│
│         ▲                ▲                 ▲                 ▲           │
│         └────────────────┴─────────────────┴─────────────────┘           │
│                              │                                           │
│                    Standard Plugin API                                   │
└─────────────────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      CLOUD PLATFORM LAYER                                │
│                    (OSS Core + Commercial Options)                       │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │ RM&D Platform Core (Apache 2.0)                                   │  │
│  │  - Telemetry Ingestion Engine                                     │  │
│  │  - Event Processing & Routing                                     │  │
│  │  - Time-series Database Interface                                 │  │
│  │  - Analytics Engine Interface                                     │  │
│  │  - Alerting & Notification                                        │  │
│  │  - Multi-tenant Management                                        │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│  ┌────────────────────┐  ┌──────────────────────────────────────────┐  │
│  │ OSS Components     │  │ Commercial Managed Services (Optional)   │  │
│  │ - TimescaleDB      │  │ - AWS IoT Core + Timestream              │  │
│  │ - InfluxDB         │  │ - Azure IoT Hub + ADX                    │  │
│  │ - Prometheus       │  │ - GCP Pub/Sub + Cloud Run + BigQuery     │  │
│  │ - Grafana          │  │ - Custom Commercial RM&D Platform        │  │
│  └────────────────────┘  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         GATEWAY LAYER                                    │
│                       (Apache 2.0 OSS)                                   │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │ RM&D Edge Gateway                                                 │  │
│  │  - Protocol Adapters (MQTT, OPC-UA, Modbus, BACnet)              │  │
│  │  - Edge Analytics & Pre-processing                                │  │
│  │  - Local Data Buffering                                           │  │
│  │  - Security: mTLS, Certificate Management                         │  │
│  │  - Network Segmentation (OT/IT isolation)                         │  │
│  │  - Vendor Plugin Runtime                                          │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         EDGE DEVICE LAYER                                │
│                    (Apache 2.0 or MIT OSS SDK)                           │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐  ┌──────────┐ │
│  │ Lift          │  │ HVAC          │  │ Water Pump    │  │ AMR      │ │
│  │ Controller    │  │ Controller    │  │ Controller    │  │ Fleet    │ │
│  ├───────────────┤  ├───────────────┤  ├───────────────┤  ├──────────┤ │
│  │ Device SDK    │  │ Device SDK    │  │ Device SDK    │  │ Device   │ │
│  │ - Telemetry   │  │ - Telemetry   │  │ - Telemetry   │  │ SDK      │ │
│  │ - OTA Client  │  │ - OTA Client  │  │ - OTA Client  │  │          │ │
│  │ - Security    │  │ - Security    │  │ - Security    │  │          │ │
│  │ - Local Diag  │  │ - Local Diag  │  │ - Local Diag  │  │          │ │
│  └───────────────┘  └───────────────┘  └───────────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Layered Architecture Detail

### 2.1 Edge Device Layer (High-Volume, OSS-First)

**Purpose:** Lightweight SDK embedded in millions of devices

**License:** **Apache 2.0 or MIT** (maximum commercial freedom)

| Policy/Standard | Architectural Component | Alignment/Implementation Detail |
|:----------------|:------------------------|:--------------------------------|
| **BE ITM — SUS Pillar** (Smart FM 80% by 2030) | Entire platform | Primary policy driver. Open, composable RM&D enabling Smart FM and decarbonization at scale. |
| **BE ITM — IPD Pillar** (open data / CDE) | Gateway + Cloud Core | **Common Data Environment (CDE)** implementation via OPC UA (§3.1.4 BCA CoP), MQTT 5.0, gRPC. |
| **BE ITM — AMA Pillar** (modular / predictive) | Analytics / Telemetry | Component-level monitoring for factory-built modules (AMA/DfMA) → replacement scheduling. |
| **BCA Lift Code RM&D** | Analytics Engine | - Critical data prioritization per BCA Annex B<br>- Diagnostic accuracy (DiA) benchmark ≥85%<br>- KPI dashboards (TFPE, FTTR, MTTR, DiA, DA) |
| **IMDA TR 91** | Device SDK + Gateway | Mandatory for public infra (LTA/HDB). Root-of-Trust, strong crypto, no hardcoded secrets. |
| **GovTech Zero Trust** | Cloud Platform | Aligned with Government Zero Trust Framework. Continuous verification, PDP/PEP architecture. |
| **MOH / PDPA** | Multi-tenant Layer | Data residency, PII anonymization, and strict encryption for critical medical facilities. |
| **CSA CLS Level 3-4** | Device Certification | Reference implementation for high-security connected devices (Level 3 or 4 required for Smart Buildings). |
| **IEC 62443** (3-3, 4-1, 4-2) | System, Process & Component | Mandated by BCA Code (§6). Mapping to 7 Foundational Requirements (FRs) and Secure SDL Lifecycle. |

**Core Components (OSS):**

1. **Telemetry Client**
   - Standard telemetry schema (JSON/Protobuf)
   - Efficient batching and compression
   - Offline buffering and retry logic
   - Support for MQTT, HTTP, CoAP

2. **Security Module**
   - Device identity (X.509 certificates)
   - Secure boot verification
   - Encrypted storage (firmware, credentials)
   - mTLS for cloud communication

3. **OTA Update Client**
   - Secure firmware download
   - Cryptographic signature verification
   - Rollback protection
   - Delta updates support

4. **Local Diagnostics Agent**
   - Health metrics collection
   - Fault detection (read-only access to device controller)
   - Edge analytics (basic anomaly detection)

**Vendor Integration Points:**

- Vendors embed OSS SDK into their devices
- Proprietary control logic remains closed-source
- Telemetry schema is standardized but vendors can extend with custom fields
- Device SDK is **read-only** for controller access (per BCA Lift Code requirement)

**Language Support:** C/C++ (embedded), Rust (modern embedded), Python (Linux-based edge)

---

### 2.2 Gateway Layer (OSS with Vendor Plugins)

**Purpose:** Edge gateway for protocol translation, local processing, and vendor-specific logic

**License:** **Apache 2.0**

**Core Components (OSS):**

1. **Protocol Adapters** (Adapters are pluggable; only MQTT + OPC UA are baseline)
   - MQTT (Initial target: AWS IoT, Azure IoT Hub, generic MQTT brokers)
   - OPC-UA (Initial target: building automation, industrial equipment)
   - Modbus TCP/RTU (Optional adapter: legacy PLCs, sensors)
   - BACnet (Future: HVAC systems)
   - TR93/SS713 (Future: AMR-building interoperability)

2. **Edge Analytics Engine**
   - Time-series data pre-processing
   - Critical vs. non-critical data prioritization (per BCA Lift Code)
   - Local alerting for immediate issues
   - Data aggregation and compression

3. **Security & Network Isolation**
   - OT/IT network segmentation (IEC 62443 compliance)
   - mTLS for device-to-gateway and gateway-to-cloud
   - Certificate management (auto-renewal, rotation)
   - Firewall rules enforcement

4. **Vendor Plugin Runtime**
   - **Sandboxed execution** (WASM, gRPC sidecars, or containers)
   - Standard Plugin API (defined in separate spec)
   - Resource limits (CPU, memory, network)
   - Lifecycle management (install, update, remove)

**Vendor Plugin Architecture:**

```text
┌────────────────────────────────────────────────────────┐
│           Gateway Core (OSS)                           │
│  ┌──────────────────────────────────────────────────┐ │
│  │  Plugin Manager                                  │ │
│  │   - Plugin Discovery & Loading                   │ │
│  │   - Sandboxing (WASM/Container)                  │ │
│  │   - Resource Quotas                              │ │
│  └──────────────────────────────────────────────────┘ │
│                        ▲                               │
│                        │                               │
│         Standard Plugin API (gRPC / REST)               │
│                        │                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Lift Vendor  │  │ HVAC Vendor  │  │ Pump Vendor  │ │
│  │   Plugin     │  │   Plugin     │  │   Plugin     │ │
│  │ (Proprietary)│  │ (Proprietary)│  │ (Proprietary)│ │
│  │              │  │              │  │              │ │
│  │ - Custom     │  │ - Custom     │  │ - Custom     │ │
│  │   Analytics  │  │   Analytics  │  │   Analytics  │ │
│  │ - Fault      │  │ - Fault      │  │ - Fault      │ │
│  │   Prediction │  │   Prediction │  │   Prediction │ │
│  │ - Business   │  │ - Business   │  │ - Business   │ │
│  │   Logic      │  │   Logic      │  │   Logic      │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
└────────────────────────────────────────────────────────┘
```

**How Vendors Protect IP:**

- Plugins can be **compiled binaries** (not source-distributed)
- Plugins run in **isolated sandbox** (no access to other vendors' data)
- Vendors license plugins separately (commercial or dual-license)
- Plugin API is standardized (OSS), but implementation is proprietary

**Deployment:** Docker containers, Kubernetes pods, or standalone binaries on Linux/ARM edge devices (see [IaC Deployment (ARCH4)](ARCH4_DEPLOYMENT.md#7.4-infrastructure-as-code-iac-deployment-strategy) for detailed IaC deployment strategies)

---

### 2.3 Cloud Platform Layer (Dual Strategy: OSS + Commercial)

**Purpose:** Central RM&D platform for multi-tenant monitoring, analytics, and management

**Core Architecture:** **Pluggable** - supports both OSS self-hosted and commercial managed services

#### 2.3.1 OSS Core Platform (Apache 2.0)

**Components:**

1. **Telemetry Ingestion Engine**
   - MQTT broker (Eclipse Mosquitto, VerneMQ, NATS)
   - gRPC / REST ingestion endpoints
   - Protocol validation and normalization
   - Multi-tenant routing

2. **Event Processing & Routing**
   - Stream processing (Apache Kafka, NATS)
   - Event correlation engine
   - Rule engine for alerting
   - Webhook integrations

3. **Time-Series Data Storage Interface**
   - Abstraction layer supporting:
     - TimescaleDB (PostgreSQL extension)
     - InfluxDB
     - Prometheus + Thanos
     - VictoriaMetrics
   - Vendor-agnostic query API

4. **Analytics Engine Interface**
   - Machine learning pipeline (MLflow, Kubeflow)
   - Anomaly detection models
   - Predictive maintenance algorithms
   - Support for custom vendor models (via plugin API)

5. **Alerting & Notification**
   - Multi-channel notifications (email, SMS, Slack, webhooks)
   - Escalation policies
   - Incident management integration (PagerDuty, Opsgenie)

6. **Multi-Tenant Management**
   - Tenant isolation (data, compute, network)
   - Role-based access control (RBAC)
   - API key management
   - Usage metering and quotas

7. **Visualization & Dashboards**
   - Grafana (OSS) for dashboards
   - BCA-compliant KPI reporting (TFPE, FTTR, MTTR, DiA, DA) -- see [Section 1.3](#1.3-mandatory-rmd-indicators-bca-annex-a) for definitions.
   - Custom dashboard templates per industry vertical

#### 2.3.2 Commercial Managed Service Options

**Vendors can choose:**

| Option | Description | Use Case |
|--------|-------------|----------|
| **OSS Self-Hosted** | Deploy OSS core on own infrastructure (AWS, Azure, GCP, on-prem) | Large enterprises, government, data sovereignty requirements |
| **Commercial RM&D Platform** | Subscribe to fully-managed commercial service (built on OSS core) | SMEs, rapid deployment, SaaS economics |
| **Hybrid** | OSS core + commercial add-ons (advanced analytics, compliance reporting, premium support) | Mid-market, gradual migration |

**Commercial Add-Ons (Optional):**

- Advanced ML models (predictive maintenance, energy optimization)
- Compliance automation (IEC 62443 audit trail generation)
- Premium support (SLA, 24/7 on-call)
- Hosted training and onboarding
- Certified integrations with building management systems

**Cloud Provider Options:**

- **AWS:** IoT Core + Timestream + Lambda + S3
- **Azure:** IoT Hub + Azure Data Explorer + Functions + Blob Storage
- **GCP:** Pub/Sub + Cloud Run/Functions + BigQuery + Cloud Storage (via MQTT bridge/partner)
- **On-Premises:** Kubernetes + TimescaleDB + Kafka + MinIO

For detailed OSS solution recommendations and implementation guidance, see [Cloud Platform (ARCH5 §8.2.3)](ARCH5_OSS_STACK.md#8.2.3-cloud-platform-stack) and [Infrastructure Automation (ARCH5 §9.4)](ARCH5_OSS_STACK.md#9.4-infrastructure-automation-tooling-matrix).

---

## 1.3 Mandatory RM&D Indicators (BCA Annex A)

As specified in Annex A of the BCA Code of Practice, the following KPIs must be monitored and reported:

- **TFPE (Technical Faults per Equipment):** Number of technical faults per lift per month.
- **FTTR (First Time Fix Rate):** % of technical faults that do not re-occur within 30 days of rectification.
- **MTTR (Mean Time To Repair):** Average hours taken to resolve a technical fault.
- **DiA (Diagnostics Accuracy):** % of RM&D-predicted faults confirmed by on-site inspection matching reality.
- **DA (Device Availability):** % of time the RM&D unit is online and transmitting data.
- **UT (Average Monthly Uptime):** % of time the lift equipment is operational (excludes technical fault downtime).
- **FPE (Faults per Equipment):** Total faults (Technical + Non-Technical) per lift per month.

---

## 📖 Glossary (Key Terms)

- **BCA:** Building and Construction Authority (the agency that oversees building safety and excellence in Singapore).
- **IMDA:** Infocomm Media Development Authority (the agency that leads Singapore’s digital transformation).
- **CSA:** Cyber Security Agency of Singapore (the national agency overseeing cybersecurity).
- **RM&D:** Remote Monitoring & Diagnostics (systems that detect technical faults early and reduce equipment breakdowns).
- **Smart FM:** Smart Facilities Management (using data and technology to operate buildings more safely, efficiently, and with less manpower).

