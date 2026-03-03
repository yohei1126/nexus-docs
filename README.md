# Singapore Built Environment: Government Vision & RM&D Compliance Standards

Singapore's **Built Environment ITM** (2022) is the initial lead strategy for this platform. While the **Nexus Core** is designed to be industry-agnostic, the current implementation prioritizes the mandate from the BCA Sustainable Urban Systems (SUS) pillar:

> *"BCA will aim for 80% of public buildings adopting Smart FM by 2030, and 40% of private buildings by GFA."*
> — Minister Desmond Lee, IBEW 2022

📄 **Source document:** [Built Environment Industry Transformation Map (ITM) 2025](https://www1.bca.gov.sg/buildsg/built-environment-industry-transformation-map-itm)

**Three ITM pillars and their RM&D relevance:**

| Pillar | Target | RM&D Angle |
|--------|--------|-----------|
| **Integrated Planning & Design (IPD)** | IDD adoption → 70% by 2025 | Open data standards (OPC UA, MQTT) for FM integration |
| **Advanced Manufacturing & Assembly (AMA)** | DfMA adoption → 70% by 2025 | Predictive replacement scheduling from sensor data |
| **Sustainable Urban Systems (SUS)** | **Smart FM: 80% public, 40% private by 2030** | **Real-time RM&D is the prerequisite for Smart FM** |

📖 **Full vision mapping → implementation:** [summary/BCA_VISION.md](summary/BCA_VISION.md)

---

## 📐 Vision → Standards → Implementation

The ITM is the **why**. The specific agency standards are the **what**. The Nexus platform is the **how**.

```
Built Environment ITM (SUS Pillar)    ← VISION: Smart FM by 2030
        │
        ├── BCA RM&D CoP (Lifts)      ← STANDARD: DiA ≥85%, OPC UA, IEC 62443
        ├── IMDA TR 91                ← SECURITY: mTLS, device identity
        ├── CSA CLS                   ← CERTIFICATION: IoT device labelling
        └── GovTech Zero Trust        ← POSTURE: Zero Trust architecture
                │
                ▼
        Nexus RM&D Platform           ← IMPLEMENTATION
```

---

## What is RM&D?

**Remote Monitoring & Diagnostics (RM&D)** enables continuous monitoring, fault detection, and predictive maintenance of building systems (lifts, HVAC, pumps, chillers) and autonomous robots through IoT telemetry, cloud analytics, and machine learning.

**Key Capabilities:**
- **Real-time Monitoring:** Continuous telemetry streaming from devices (temperature, vibration, pressure, motor speed)
- **Fault Detection:** Automated anomaly detection and alert generation
- **Predictive Maintenance:** ML-based prediction of equipment failures before they occur
- **Regulatory Compliance:** Automated KPI calculation and reporting for BCA/government requirements
- **Remote Diagnostics:** Technicians can troubleshoot issues remotely, reducing on-site visits

---

## 🚀 One Nexus Core, Multiple Industry Visions

The Nexus RM&D Platform provides a **unified, open-source foundation** for Remote Monitoring & Diagnostics. While the project uses the **Built Environment (BCA)** as its first focus, the architecture is designed to support any sector requiring secure IoT telemetry and analytics:

| Industry Sector | Strategy Lead | Core Focus | Vision Document |
|:---|:---|:---|:---|
| **Built Env** | BCA | Smart FM & Lift Safety | [BCA_VISION.md](summary/BCA_VISION.md) |
| **Maritime** | MPA | Port Automation & Resilience | [MAP_VISION.md](summary/MAP_VISION.md) |
| **Cleaning/Waste** | NEA | Demand-Based Services | [NEA_VISION.md](summary/NEA_VISION.md) |
| **Water** | PUB | Network Health & Digital Water | [PUB_VISION.md](summary/PUB_VISION.md) |

This repository provides a consolidated, implementation-oriented view of Singapore government security guidelines relevant to RM&D across Connected Devices, Smart Buildings, Smart City infrastructure, and Autonomous Robots.

Its purpose is to reduce the compliance burden for hardware manufacturers, sensor vendors, and robotics platforms by offering:

- A unified interpretation of multi‑agency government requirements
- A high‑level technical translation of security expectations
- A foundation for an OSS reference implementation that vendors can adopt

---

## 👥 Who Should Use This Repository?

This repository is designed for:

### Primary Audience

**1. Government Sponsors & Regulators (BCA, MPA, NEA, PUB, GovTech)**
- Policy makers and agency leads driving Industry Transformation Maps (ITMs)
- Security and compliance enforcers (IMDA, CSA)
- **Use Case:** Set the technical "bar" for a sector, audit vendor compliance, and aggregate national-level performance data

**2. Asset Owners & Facility Managers (HDB, JTC, LTA, Private Developers)**
- Direct owners of lifts, HVAC, chillers, and fleet infrastructure
- Building managers responsible for uptime and maintenance costs
- **Use Case:** Use a single, vendor-neutral dashboard to monitor heterogeneous fleets and lower subscription costs

**3. Hardware Manufacturers & Device Vendors**
- Lift/elevator manufacturers, HVAC providers, and AMR/Robotics companies
- **Use Case:** Integrate RM&D capabilities into your devices while ensuring Singapore regulatory compliance

**4. Software Platform Providers & System Integrators**
- BMS vendors and IoT platform providers
- **Use Case:** Build compliant cloud platforms and deploy multi-vendor RM&D solutions

### Secondary Audience

**5. Architects & Technical Decision Makers**
- Solution architects designing RM&D systems
- CTOs evaluating technology stacks
- **Use Case:** Understand trade-offs between commercial services and OSS alternatives

**6. Compliance & Regulatory Officers**
- Building owners navigating BCA requirements
- Compliance teams ensuring IMDA/CSA/GovTech alignment
- **Use Case:** Understand regulatory requirements and technical implementation options

**7. Open-Source Contributors & Researchers**
- Developers contributing to RM&D ecosystem
- Academic researchers in IoT security, predictive maintenance
- **Use Case:** Contribute to reference implementations or research compliance patterns

### When NOT to Use This Repository

This repository may not be suitable if:
- ❌ You're building consumer IoT devices (not industrial/building systems)
- ❌ You're outside Singapore and don't need Singapore-specific compliance
- ❌ You're looking for end-user documentation (this is for implementers)
- ❌ You need production-ready code today (this provides architecture guidance; reference implementations are in progress)

## 🚀 Getting Started

**New to this repository?** Start here:

1. **[BCA_VISION.md](summary/BCA_VISION.md)** — **Start here.** Vision → Standards → Nexus implementation chain
2. **[ARCHITECTURE.md](summary/ARCHITECTURE.md)** - Complete OSS architecture (recommended for architects, developers, and vendors)
3. **[Smart Buildings Summary](summary/SMART_BUILDINGS_SUMMARY.md)** - Regulatory framework overview (recommended for compliance officers)
4. **[Smart Buildings Documentation Guide](summary/SMART_BUILDINGS_DOCS.md)** - Prioritized reading guide

## 📖 Quick Links to Documentation

### Comprehensive Analysis Documents

- **[Vision → Standards → Implementation](summary/BCA_VISION.md)** — **Read first.** Maps the BE ITM 2022 vision to agency standards to Nexus features
- **[RM&D OSS Architecture](summary/ARCHITECTURE.md)** - Complete commercial-friendly open-source architecture
- **[Smart Buildings Documentation Guide](summary/SMART_BUILDINGS_DOCS.md)** - Prioritized reading guide for RM&D in Smart Buildings
- **[Smart Buildings RM&D Framework - Comprehensive Summary](summary/SMART_BUILDINGS_SUMMARY.md)** - Singapore's layered regulatory framework

### Key Reference Documents by Agency

**Upstream Vision:**
- **BCA:** `bca/Built Environment Industry Transformation Map...md` — **ITM 2022 vision** (Smart FM 80% by 2030) ← *start here for the why*

**Technical Standards:**
- **BCA:** `bca/code-of-practice-for-design-and-performance-of-remote-monitoring-and-diagnostics-solution-for-lifts-(final).md` — RM&D Code of Practice (implements SUS pillar for lifts)
- **BCA:** `bca/site-mgmt-data-standards-v1-1.md` - Site Management Data Standards
- **BCA:** `bca/sitemanagementplatform.md` - Site Management Platform Guidebook
- **BCA:** `bca/20241008_gmdc2024_ver1.md` - Green Mark Data Centre Guidelines

**Security & Certification:**
- **IMDA:** `imda/imda-iot-cyber-security-guide.md` - IoT Cyber Security Guide v2.0 (TR 91)
- **CSA:** `csa/CCC SP-151-1 CLS(IoT) Overview of the scheme v1.4.md` - Cybersecurity Labelling Scheme
- **CSA:** `csa/ccop.md` - Code of Practice for Critical Information Infrastructure
- **GovTech:** `govtech/Government-Zero-Trust-Architecture.md` - Zero Trust Architecture

---

## 🎯 Purpose of This Repository

Singapore’s regulatory environment is robust and multi‑layered — spanning cybersecurity, IoT safety, building infrastructure, and autonomous systems. While essential for national safety and resilience, this creates high barriers to entry for smaller hardware vendors.

This repository exists to:

1. Summarize security requirements from the Singapore government relevant to RM&D.
2. Translate policy-level guidelines into actionable technical requirements.
3. Provide a foundation for an OSS reference implementation that meets baseline government expectations.
4. Enable hardware and device makers to enter the market more easily by standardizing RM&D patterns.
5. Ultimately, this promotes interoperability, lower cost, and vendor diversity across Singapore’s Smart Nation ecosystem.

## 🏛️ Singapore Government Stakeholders & Relevant Guidelines (High-Level)

### IMDA — Infocomm Media Development Authority

Focus: Connected Devices, IoT cybersecurity, AMR guidelines

* IoT Cyber Security Guide
* Cybersecurity Labelling Scheme (CLS)
* AMR Technical Guidelines

### CSA — Cyber Security Agency of Singapore

Focus: National cybersecurity standards, IoT/OT, critical infrastructure

* IoT Cybersecurity Baseline
* OT Security Guidelines
* Secure-by-Design principles

### GovTech — Smart Nation & Digital Government Office

Focus: Public sector Zero Trust, Smart Nation infrastructure

* Government Zero Trust Architecture
* IoT security & device onboarding patterns

### BCA — Building and Construction Authority

Focus: Smart buildings, built environment, lift & building system monitoring

* RM&D for Lifts (Remote Monitoring and Diagnostics)
* Green Mark (DC) monitoring & energy visibility standards

### NRP (National Robotics Programme)

Focus: Robotics–building interoperability

* TR93 (Robot–Lift and Facility Interoperability)
* SS713 (Robot–Infrastructure Data Exchange)

## 🚧 Why an OSS RM&D Solution Is Needed

Currently:

* Security requirements across agencies are distributed and complex
* Vendors implement requirements independently, leading to fragmentation
* Small/medium manufacturers face high compliance cost
* Lack of interoperability makes system integration expensive

A shared OSS RM&D foundation would:

* Provide pre-built security conformity aligned to government expectations
* Reduce duplicated effort across vendors
* Standardize telemetry, diagnostics, OTA updates, and device onboarding
* Improve ecosystem compatibility between devices, sensors, AMRs, and building systems
* Accelerate Smart Nation adoption of multi-vendor hardware

This repository organizes the guidelines needed to build that shared foundation.

## 🏗️ OSS Architecture Reference Implementation

The **[ARCHITECTURE.md](summary/ARCHITECTURE.md)** document provides a complete, production-ready architecture for building commercial-friendly RM&D solutions:

### Key Features

- **✅ Commercial-Friendly Licensing:** All recommended OSS solutions use Apache 2.0/MIT licenses, avoiding BSL, AGPL, and GPL restrictions
- **🔌 Plugin Architecture:** Enables vendors to protect proprietary IP while participating in the ecosystem
- **📊 Complete Technology Stack:** From edge devices to cloud platform with specific tool recommendations
- **🚀 Infrastructure as Code:** Full IaC deployment strategies using Terraform, Kubernetes, Helm, and GitOps
- **📏 Compliance by Design:** Built-in support for IEC 62443, IMDA IoT Security Guide, CSA CLS, GovTech Zero Trust, and BCA RM&D requirements
- **💰 Cost Optimization:** Detailed cost analysis and resource sizing for small (<1k), medium (1k-10k), and large (10k+ devices) deployments

### Architecture Coverage

1. **Edge Device Layer:** Lightweight SDK (Apache 2.0/MIT) for millions of devices
2. **Gateway Layer:** EdgeX Foundry-based edge platform with vendor plugin support
3. **Cloud Platform:** 100% OSS stack (Kafka/NATS, TimescaleDB/QuestDB, Grafana, Prometheus)
4. **Security & Compliance:** Zero Trust architecture with comprehensive security controls
5. **Deployment Models:** Docker Compose, Kubernetes, multi-region with complete IaC examples

### License Compliance Highlights

The architecture document includes comprehensive license guidance to avoid commercial restrictions:

- ⛔ **Avoid:** EMQX (BSL 1.1), HashiCorp Vault 1.16+ (BSL 1.1), GPL-licensed tools
- ✅ **Recommended:** VerneMQ, OpenBao, QuestDB, VictoriaMetrics (all Apache 2.0)
- ⚠️ **Use with Caution:** Grafana (AGPL v3) - acceptable for internal dashboards only

See [Appendix C: License Comparison](summary/ARCHITECTURE.md#appendix-c-license-comparison) for detailed license analysis.

## 📌 Priority Target Markets for RM&D

These verticals have the strongest operational and regulatory drivers for RM&D adoption:

### 1. Smart Buildings / Facilities Management (Highest Priority)

* HVAC, power systems, water pumps, elevators, lighting
* Strong regulatory push + high labour costs

### 2. Data Centres

* Energy monitoring, cooling, UPS health, environmental telemetry
* Strict uptime requirements

### 3. Hospitals (Facilities + Autonomous Robots)

* Critical environments + AMR logistics

### 4. Smart City Infrastructure

* Streetlights, drainage pumps, environmental sensors

### 5. Logistics Warehouses (AMRs)

* Automated storage, AGVs, AMRs, robotics fleets

## 🔐 Government Requirements → Technical Requirements (High-Level Mapping)

### A. Device & Edge Security Requirements

* Secure boot, firmware signing, anti‑rollback
* Encrypted telemetry (TLS 1.2+)
* Device certificates + mutual TLS
* Encrypted storage (AES‑256)
* OTA updates: authenticated, encrypted, rollback-safe

### B. Network & Cloud Security

* Zero Trust segmentation
* Role‑based API access
* Immutable audit logs
* Anomaly detection: tamper/fault/behavioral monitoring

### C. RM&D Application Layer

* Standard telemetry schema (JSON/MQTT/OPC-UA)
* Unified event/alarm engine
* Multi-vendor ingestion interface
* TR93/SS713‑compatible building/robot gateway

### D. Compliance & Governance

* Alignment with: IMDA CLS, CSA IoT baseline, GovTech Zero Trust
* Data residency and PDPA-aware retention policies
* Remote attestation & compliance evidence generation

## 🧩 Implementation Status & Next Steps

### ✅ Completed

- **Architecture Design** - Complete 100+ page architecture document with technology stack, deployment strategies, and compliance mapping
- **License Compliance** - Comprehensive OSS license analysis ensuring commercial viability
- **Reference Architecture** - Cloud platform stack (Kafka/NATS, TimescaleDB/QuestDB, Grafana, Prometheus)
- **IaC Deployment Strategies** - Terraform, Kubernetes, Helm charts, GitOps workflows
- **Compliance Mapping** - Detailed mapping to IEC 62443, IMDA, CSA, GovTech, BCA requirements

### 🚧 In Progress / Planned

#### 1. Reference SDK Implementation

* Edge Device SDK (C/C++, Rust) - Eclipse Paho + mbedTLS + Protobuf
* Gateway SDK - EdgeX Foundry with vendor plugin framework
* Cloud SDK - API clients for telemetry ingestion and device management

#### 2. Vendor Plugin Ecosystem

* Plugin API specification (OpenAPI 3.1)
* WebAssembly runtime for sandboxed plugins
* Plugin marketplace and certification program

#### 3. Deployment Automation

* Terraform modules for AWS/Azure/GCP
* Helm charts for Kubernetes deployment
* Docker Compose templates for development/testing
* ArgoCD/Flux GitOps configurations

#### 4. Certification & Testing

* Automated compliance test suite (IEC 62443, IMDA CLS, CSA)
* Device certification program
* Performance benchmarking tools

## 🗓️ Implementation Roadmap

This roadmap outlines the planned development phases for the RM&D OSS ecosystem.

| Phase | Timeline | Milestone | Key Deliverables | Compliance Gates |
|-------|----------|-----------|------------------|------------------|
| **Phase 1: Foundation** | Q1 2026 (Jan-Mar) | OSS Core Platform | • Telemetry schema (Protobuf) finalized<br>• MQTT/gRPC ingestion API<br>• Time-series DB setup (QuestDB)<br>• Basic Grafana dashboards | • IMDA IoT Guide Section 5 (Device Auth)<br>• IEC 62443 SL-2 (Authenticated Access) |
| **Phase 2: Plugin Ecosystem** | Q2 2026 (Apr-Jun) | Vendor Integration | • Plugin API v1.0 (OpenAPI 3.1)<br>• WASM runtime sandbox<br>• 3 reference plugins (lift, HVAC, pump)<br>• Plugin certification test suite | • CSA CLS Level 3 (Crypto)<br>• GovTech Zero Trust Principle 6 (Least Privilege) |
| **Phase 3: Deployment Automation** | Q3 2026 (Jul-Sep) | Production Readiness | • Terraform modules (AWS/Azure/GCP)<br>• Kubernetes Helm charts<br>• Docker Compose templates<br>• GitOps workflows (ArgoCD/Flux) | • GovTech Zero Trust Principle 4 (Encrypt in Transit)<br>• IEC 62443 SL-3 (Encrypted Channels) |
| **Phase 4: Compliance & Certification** | Q4 2026 (Oct-Dec) | Ecosystem Launch | • BCA KPI dashboard (TFPE, FTFR, MTTR, DA)<br>• Automated compliance reports<br>• Device certification program<br>• Public plugin marketplace | • BCA RM&D Code of Practice<br>• IMDA CLS certification path<br>• IEC 62443-4-2 (Component Requirements) |

### Quarterly Objectives

**Q1 2026 - Foundation**
- ✅ Complete: ARCHITECTURE.md with plugin API, telemetry schema, trust boundaries
- 🎯 Goal: Deployable single-node stack (Docker Compose) processing 1,000 devices
- 📊 Success Metric: End-to-end telemetry flow (device → gateway → cloud → dashboard)

**Q2 2026 - Plugin Ecosystem**
- 🎯 Goal: 3 certified vendor plugins live
- 📊 Success Metric: Plugins processing real telemetry from partner devices
- 🤝 Partner Onboarding: Engage 5 lift/HVAC/pump vendors

**Q3 2026 - Production Hardening**
- 🎯 Goal: Kubernetes deployment handling 10,000 devices
- 📊 Success Metric: 99.9% uptime, <100ms p95 ingestion latency
- 🔒 Security Audit: Penetration testing, CVE scanning

**Q4 2026 - Certification Launch**
- 🎯 Goal: First building goes live with certified RM&D stack
- 📊 Success Metric: BCA compliance reports generated automatically
- 🏆 Certification: 10 devices certified, 5 plugins certified

### Community Milestones

- **Jan 2026:** Repository public, architecture document released
- **Mar 2026:** First external contributor merged
- **Jun 2026:** First vendor plugin published
- **Sep 2026:** 100 GitHub stars, 10 active contributors
- **Dec 2026:** Production deployment case study published

## 📚 Current Repository Structure

```
/summary                    # Comprehensive analysis documents
  ARCHITECTURE.md           # Commercial-friendly OSS RM&D architecture (100+ pages)
  SMART_BUILDINGS_DOCS.md   # Reading guide for RM&D documentation
  SMART_BUILDINGS_SUMMARY.md # Complete framework analysis

/imda                       # IMDA IoT security standards
  imda-iot-cyber-security-guide.md

/csa                        # CSA cybersecurity standards
  CCC SP-151-1 CLS(IoT) Overview of the scheme v1.4.md
  ccop.md                   # Critical Information Infrastructure Code

/govtech                    # GovTech Zero Trust Architecture
  Government-Zero-Trust-Architecture.md

/bca                        # BCA building & RM&D standards
  code-of-practice-for-design-and-performance-of-remote-monitoring-and-diagnostics-solution-for-lifts-(final).md
  site-mgmt-data-standards-v1-1.md
  sitemanagementplatform.md
  20241008_gmdc2024_ver1.md

/iec                        # IEC 62443 industrial cybersecurity
  IEC-62443-Standard-Enhancing-Cybersecurity-for-Industrial-Automation-and-Control-Systems-Fortinet.md

main.py                     # PDF to Markdown conversion tool
```

## 📚 Planned Repository Expansion

The architecture foundation is complete. Next steps include:

```
/specs                      # Technical specifications (planned)
  /telemetry                # Standard telemetry schema (Protobuf/JSON)
  /ota                      # OTA update protocol
  /device_onboarding        # Device provisioning and registration
  /plugin_api               # Vendor plugin API specification

/reference-sdk              # Reference implementations (planned)
  /edge-device-sdk          # C/C++, Rust device SDK
    /examples               # Sample integrations (HVAC, lift, pump)
  /gateway-sdk              # EdgeX Foundry customizations
    /plugins                # Sample vendor plugins
  /cloud-client-sdk         # API clients (Python, Go, TypeScript)

/infrastructure             # IaC templates (planned)
  /terraform                # Terraform modules (AWS, Azure, GCP)
  /kubernetes               # Helm charts and manifests
  /docker-compose           # Development environments

/compliance                 # Certification tooling (planned)
  /test-suites              # Automated compliance tests
  /audit-tools              # Evidence generation scripts
  /checklists               # Compliance checklists by vertical
```

**Current Focus:** Reference SDK implementation and IaC template development based on the completed architecture.

---

## ⚖️ Legal Disclaimer & License Information

### Documentation License

The documentation, architecture guides, and analysis in this repository are provided under the **MIT License** for maximum reusability.

### Regulatory Compliance Disclaimer

> **⚠️ IMPORTANT - NOT LEGAL OR REGULATORY ADVICE**
>
> This repository provides **technical guidance and architectural recommendations** based on publicly available Singapore government guidelines. It is intended as a reference for software architects, engineers, and technical decision-makers.
>
> **This repository does NOT:**
> - Constitute legal advice or regulatory compliance certification
> - Guarantee compliance with Singapore government requirements
> - Replace the need for professional legal, compliance, or regulatory consultation
> - Represent official guidance from IMDA, CSA, GovTech, BCA, or any Singapore government agency
>
> **Before deploying RM&D solutions in production:**
> 1. ✅ Consult qualified legal counsel familiar with Singapore regulations
> 2. ✅ Verify current regulatory requirements with relevant authorities (IMDA, CSA, BCA, etc.)
> 3. ✅ Conduct formal compliance assessments and certifications where required
> 4. ✅ Engage accredited security auditors for production systems
> 5. ✅ Review data protection obligations under Singapore's Personal Data Protection Act (PDPA)
>
> **Regulatory Requirements Change:** Singapore government guidelines are updated periodically. Always verify you are referencing the latest official versions:
> - **IMDA:** [https://www.imda.gov.sg](https://www.imda.gov.sg)
> - **CSA:** [https://www.csa.gov.sg](https://www.csa.gov.sg)
> - **GovTech:** [https://www.tech.gov.sg](https://www.tech.gov.sg)
> - **BCA:** [https://www.bca.gov.sg](https://www.bca.gov.sg)

### Open-Source Software Licensing Disclaimer

> **⚠️ OSS LICENSE COMPLIANCE RESPONSIBILITY**
>
> The architecture document recommends various open-source components (Apache 2.0, MIT, AGPL, BSL, etc.). License terms and compatibility are provided as **general technical guidance only**.
>
> **You are responsible for:**
> - Verifying current license terms for all OSS components you deploy
> - Ensuring license compatibility with your commercial use case
> - Maintaining a Software Bill of Materials (SBOM) for your deployments
> - Consulting legal counsel regarding OSS license compliance
>
> **License terms change:** Some projects have changed licenses (e.g., EMQX, HashiCorp Vault, TimescaleDB). Always verify the license of the **specific version** you are using.
>
> **This repository does NOT provide:**
> - Legal interpretation of OSS licenses
> - Guarantees of license compatibility
> - Indemnification against license violations

### Data Protection & Privacy Disclaimer

> **⚠️ PDPA AND DATA PROTECTION COMPLIANCE**
>
> RM&D solutions may collect and process personal data (e.g., access logs, fault reports linked to individuals). Under Singapore's **Personal Data Protection Act (PDPA)**, organizations must:
>
> - Obtain consent for personal data collection
> - Provide clear data protection notices
> - Implement appropriate security safeguards
> - Comply with data retention and deletion obligations
> - Report data breaches to the Personal Data Protection Commission (PDPC)
>
> **This repository does NOT:**
> - Provide PDPA compliance guidance
> - Implement data anonymization or pseudonymization techniques
> - Define data retention policies
>
> **Consult:** [Personal Data Protection Commission (PDPC)](https://www.pdpc.gov.sg) for PDPA compliance requirements.

### No Warranty

> **This repository and all associated documentation, architecture designs, and reference implementations are provided "AS IS" without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.**
>
> **The contributors and maintainers of this repository:**
> - Make no representations regarding regulatory compliance of implementations based on this guidance
> - Are not liable for any damages arising from use of this repository
> - Do not guarantee the accuracy, completeness, or timeliness of information provided
>
> **Use of this repository is entirely at your own risk.**

### Contributions & Community

Contributions are welcome! By contributing to this repository, you agree that your contributions will be licensed under the MIT License.

For questions, issues, or feedback:
- **GitHub Issues:** [https://github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues) (placeholder - update with actual repo URL)
- **Discussions:** Use GitHub Discussions for architecture questions and best practices

---

**Last Updated:** March 2026
**Repository Maintainer:** nexus-docs Architecture Working Group
**Status:** Architecture proposal and reference implementation in progress
