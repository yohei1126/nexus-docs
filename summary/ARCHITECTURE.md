# RM&D OSS Architecture — Index

> **Policy Mandate:** This architecture is designed to support multiple Singapore Industry Transformation Maps (ITMs) and agency roadmaps, including the **Built Environment**, **Sea Transport**, **Environmental Services**, and **Water (PUB)** sectors. See [BCA_VISION.md](BCA_VISION.md), [MAP_VISION.md](MAP_VISION.md), [NEA_VISION.md](NEA_VISION.md), and [PUB_VISION.md](PUB_VISION.md) for full policy mappings.

The original 2,900-line architecture document has been split into six focused parts for easier reading and navigation.

---

## Document Map

| File | Sections | Contents | Lines |
|------|---------|----------|-------|
| **[BCA_VISION.md](BCA_VISION.md)** | N/A | Built Environment Industry Transformation Map (BCA/BE ITM) vision & policy mapping | ~140 |
| **[ARCH1_OVERVIEW.md](ARCH1_OVERVIEW.md)** | §1–2 | Platform overview, architecture diagram, layered design (Edge / Gateway / Cloud) | ~285 |
| **[ARCH2_VENDOR_SECURITY.md](ARCH2_VENDOR_SECURITY.md)** | §3–5 | Vendor IP protection (3-tier plugin model), compliance & security architecture, licensing & business model | ~233 |
| **[ARCH3_PLUGIN_API.md](ARCH3_PLUGIN_API.md)** | §6 | Multi-vendor ecosystem: telemetry schema (Protobuf), plugin lifecycle API, gRPC/Protobuf spec (Normative), certification program | ~528 |
| **[ARCH4_DEPLOYMENT.md](ARCH4_DEPLOYMENT.md)** | §7 | Deployment models: single-node Docker Compose, multi-gateway, multi-region Kubernetes, IaC strategy (Terraform/Helm/ArgoCD) | ~253 |
| **[ARCH5_OSS_STACK.md](ARCH5_OSS_STACK.md)** | §8–10 | Build-vs-integrate guidance, OSS component selection, BCA KPI implementation (DiA/MTTR/TFPE), Grafana dashboards, resource sizing | ~1260 |
| **[ARCH6_STRATEGY.md](ARCH6_STRATEGY.md)** | §11–16 + Appendices | Migration roadmap, OSS governance, success metrics, risk mitigation, next steps, license comparison (Appendix C) | ~365 |
| **[MAP_VISION.md](MAP_VISION.md)** | N/A | Sea Transport / Maritime Industry Transformation Map (MAP/MPA) vision & policy mapping | ~50 |
| **[NEA_VISION.md](NEA_VISION.md)** | N/A | Environmental Services Industry Transformation Map (NEA/ES ITM) vision & policy mapping | ~50 |
| **[PUB_VISION.md](PUB_VISION.md)** | N/A | PUB Digital Water Roadmap (SMART PUB) vision & policy mapping | ~50 |

---

## Quick Navigation by Role

### For Government Sponsors & Regulators
1. [BCA_VISION.md](BCA_VISION.md)... — Read the policy mandate for your agency
2. [ARCH2 — Compliance Mapping](ARCH2_VENDOR_SECURITY.md) — see how Nexus satisfies TR 91 / CSA CLS / IEC 62443
3. [ARCH6 — Governance](ARCH6_STRATEGY.md) — project governance & certification program

### For Asset Owners & Facility Managers
1. [ARCH1 — Overview](ARCH1_OVERVIEW.md) — understand the multi-vendor architecture
2. [ARCH5 — BCA KPI Implementation](ARCH5_OSS_STACK.md) — see how to measure vendor performance (DiA/MTTR)
3. [ARCH4 — Deployment Patterns](ARCH4_DEPLOYMENT.md) — infrastructure options for your site

### For Solution Architects
1. [ARCH1 — Overview & Layered Design](ARCH1_OVERVIEW.md) — start here
2. [ARCH2 — Security Architecture](ARCH2_VENDOR_SECURITY.md) — compliance mapping table
3. [ARCH4 — Deployment Models](ARCH4_DEPLOYMENT.md) — infrastructure patterns

### For Platform Engineers
1. [ARCH3 — Plugin API Spec](ARCH3_PLUGIN_API.md) — Protobuf schema, gRPC interface
2. [ARCH5 — OSS Stack Selection](ARCH5_OSS_STACK.md) — component recommendations
3. [ARCH4 — IaC Strategy](ARCH4_DEPLOYMENT.md) — Terraform/Helm/GitOps

### For Compliance & Governance Officers
1. [ARCH2 — Security & Compliance Mapping](ARCH2_VENDOR_SECURITY.md#4.1) — ITM / BCA / IMDA / CSA table
2. [ARCH2 — Governance & Audit](ARCH2_VENDOR_SECURITY.md#4.4-governance) — **Strict Access, Immutable Logs, PDPA/CII Governance**
3. [ARCH5 — BCA KPI Implementation](ARCH5_OSS_STACK.md) — DiA, MTTR, TFPE, UT SQL examples
4. [ARCH6 — License Appendix C](ARCH6_STRATEGY.md) — license decision matrix

### For Business & Governance
1. [ARCH2 — Business Model](ARCH2_VENDOR_SECURITY.md) — revenue models & IP protection
2. [ARCH6 — Migration & Adoption](ARCH6_STRATEGY.md) — phased roadmap & OSS governance

### For Device / Sensor Vendors
1. [ARCH3 — Plugin API](ARCH3_PLUGIN_API.md) — how to build a vendor plugin
2. [ARCH2 — IP Protection](ARCH2_VENDOR_SECURITY.md) — plugin sandboxing & licensing
3. [ARCH6 — License Appendix C](ARCH6_STRATEGY.md) — OSS license guidance

---

## Singapore Policy Mapping: From "Why" to "How"

This architecture translates high-level national visions into technical requirements.

| Platform Capability | Strategic Outcome (The "Why") | Technical Implementation (The "How") |
|:---|:---|:---|
| **Standardized Telemetry** | Interoperability across building (BCA) and city (Smart Nation) systems. | [ARCH3 §6: Protobuf/gRPC API](ARCH3_PLUGIN_API.md) |
| **Multi-Vendor Plugins** | Vibrant SME ecosystem (Sea Transport/Env Services) & vendor IP protection. | [ARCH2 §3: 3-Tier Security](ARCH2_VENDOR_SECURITY.md) |
| **Automated KPI Engines** | Accountability for Lift DiA (BCA) and Demand-Based Cleaning (NEA). | [ARCH5 §8.8.4: KPI Logic](ARCH5_OSS_STACK.md) |
| **Pre-Compliant Security** | Rapid adoption in water (PUB) & transport (MPA) critical infra. | [ARCH2 §4: Compliance Mapping](ARCH2_VENDOR_SECURITY.md) |
| **3rd-Party Data Sharing**| Empowering ecosystem innovators while maintaining privacy. | [ARCH3 §6.5: Data Sharing](ARCH3_PLUGIN_API.md#6.5-data-sharing) |
| **Cloud-Native Scale**   | Supporting "Singapore Global Champions" (MPA/ESG) with global fleet Mgt. | [ARCH4 §7: K8s/IaC Strategy](ARCH4_DEPLOYMENT.md) |

---

## Singapore Policy Chain

```
Cross-Agency National Vision (Smart Nation Explorer)
        │
        ├── Built Environment ITM (2022) → [BCA_VISION.md](BCA_VISION.md)
        ├── MPA Sea Transport ITM        → [MAP_VISION.md](MAP_VISION.md)
        ├── NEA Env Services ITM         → [NEA_VISION.md](NEA_VISION.md)
        ├── SMART PUB Roadmap            → [PUB_VISION.md](PUB_VISION.md)
        │
        ▼
Layered Technical Standards
        ├── BCA RM&D CoP (Functional)     → ARCH5 §8.8
        ├── IMDA TR 91 (IoT Security)     → ARCH2 §4.2
        ├── CSA CLS (Cyber Labelling)     → ARCH2 §4.1
        ├── PDPA & CII (Governance)       → ARCH2 §4.4
        └── GovTech Zero Trust (Posture)   → ARCH2 §4.2.3
        │
        ▼
Nexus RM&D Architecture
        ├── Edge Component (ARCH1 §2.1)
        ├── Gateway / EdgeX (ARCH1 §2.2, ARCH5 §8.2.2)
        ├── Plugin API Spec (ARCH3 §6)
        ├── Cloud Native Backend (ARCH1 §2.3, ARCH5 §8.2.3)
        └── GitOps / IaC (ARCH4 §7.4)
```

---

## 📖 Glossary (Key Terms)

- **BCA:** Building and Construction Authority.
- **MPA:** Maritime and Port Authority of Singapore.
- **NEA:** National Environment Agency.
- **PUB:** Singapore's National Water Agency.
- **IMDA:** Infocomm Media Development Authority.
- **CSA:** Cyber Security Agency of Singapore.
- **RM&D / RMDS:** Remote Monitoring & Diagnostics (Solution).
- **ITM:** Industry Transformation Map (The strategic blueprint for a sector).
- **Smart FM:** Smart Facilities Management (Data-driven building operations).

---

*Split from original `ARCHITECTURE.md` (2,925 lines). All content preserved.*
