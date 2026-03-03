# Singapore Built Environment Vision → Nexus RM&D Platform

This document maps the Singapore government's high-level Built Environment vision
to the specific standards, technical requirements, and Nexus implementation tasks.
For other sectors, see **[MAP_VISION.md](MAP_VISION.md)** (Maritime), **[NEA_VISION.md](NEA_VISION.md)** (Env Services), and **[PUB_VISION.md](PUB_VISION.md)** (Water).

---

## The Vision: Built Environment Industry Transformation Map (ITM, 2022)

The **Built Environment ITM** (refreshed September 2022, announced at IBEW 2022 by
Minister Desmond Lee) is Singapore's master strategy to transform the entire built
environment sector across the full building life cycle — from design through
construction to operations and maintenance.

📄 Source: [Built Environment Industry Transformation Map (ITM) 2025](https://www1.bca.gov.sg/buildsg/built-environment-industry-transformation-map-itm)

### Three Pillars of the ITM

| Pillar | Target | Relevance to RM&D |
|--------|--------|--------------------|
| **Integrated Planning & Design (IPD)** | IDD adoption from 34% → 70% by 2025; Common Data Environment (CDE) standards | Standardised telemetry schemas and open data formats enable IDD-compatible FM systems |
| **Advanced Manufacturing & Assembly (AMA)** | DfMA adoption 44% → 70% by 2025; factory-built modular components | Predictive maintenance enables planned component replacement, supporting the modular/product-based construction model |
| **Sustainable Urban Systems (SUS)** | **80% of public buildings adopt Smart FM by 2030**; 40% of private buildings; $30M IFM/AFM Grant | **Primary driver for RM&D.** Real-time equipment monitoring is a prerequisite for Smart FM. |

> The **SUS pillar is the direct policy mandate** behind all Singapore government RM&D requirements.
> "Integrated, Aggregated and Smart FM" is explicitly named as the mechanism for decarbonisation.

---

## Vision → Standards → Implementation

```
Built Environment ITM (2022)               ← HIGH-LEVEL VISION
│  "80% public buildings → Smart FM by 2030"
│  "Sustainable Urban Systems"
│
├── BCA RM&D Code of Practice (Lifts)      ← SECTOR STANDARD (technical minimum bar)
│   • Diagnostic accuracy ≥85% (DiA)
│   • OPC UA open interface (§3.1.4)
│   • Cybersecurity: IEC 62443 (§6)
│   • Feedback system (§3.7.3)
│
├── IMDA IoT Cyber Security Guide (TR 91)  ← SECURITY STANDARD
│   • mTLS, device identity, secure boot
│   • Applies to all IoT in public infra
│
├── CSA Cybersecurity Labelling Scheme     ← DEVICE CERTIFICATION
│   • Level 3/4 for connected building devices
│
├── MPA Sea Transport ITM                  ← MARITIME VISION
│   • See [MAP_VISION.md](MAP_VISION.md)
│
├── NEA Env Services ITM                   ← CLEANING & WASTE VISION
│   • See [NEA_VISION.md](NEA_VISION.md)
│
├── SMART PUB Roadmap                      ← DIGITAL WATER VISION
│   • See [PUB_VISION.md](PUB_VISION.md)
│
└── GovTech Zero Trust Architecture        ← PLATFORM SECURITY POSTURE
    • Zero Trust for any govt-connected platform

                    ▼

Nexus RM&D Platform                        ← IMPLEMENTATION
    Phase 0–5: Core platform + elevator module
    Phase 6:   Security hardening (IEC 62443 + TR 91)
```

---

## ITM Pillar → Nexus Feature Mapping

### SUS Pillar: Smart FM (Primary)

| ITM Goal | Singapore Target | Nexus Feature | Phase |
|----------|----------------|--------------|-------|
| Smart FM adoption | 80% public buildings by 2030 | Full RM&D platform — telemetry, alerts, dashboards | Phase 0–4 |
| Integrated FM | Aggregated data across buildings | Multi-device, multi-building QuestDB schema | Phase 3 |
| Decarbonisation visibility | Energy & equipment monitoring | Grafana dashboards + Evidence KPI reports | Phase 3 |
| Predictive maintenance | Reduce callouts, lower cost | Statistical anomaly detector + vendor ML modules | Phase 4–5 |
| Diagnostic accuracy accountability | DiA KPI (Annex A of BCA CoP) | `accuracy_reporter.py` + Phase 4.8 benchmark ≥85% | Phase 4 |
| Regulatory reporting | BCA Form D compliance | `report_generator.py` in analytics modules | Phase 4 |

### IPD Pillar: Open Data (Secondary)

| ITM Goal | Nexus Feature |
|----------|--------------|
| Common Data Environment (CDE) | Open MQTT 5.0 + PostgreSQL wire protocol — any BMS can connect |
| IDD interoperability | OPC UA `device-opc-ua` in EdgeX — aligns with BCA §3.1.4 |
| Open standard interface | All protocols open: MQTT, gRPC, S3 API — no proprietary lock-in |

### AMA Pillar: Planned Replacement (Tertiary)

| ITM Goal | Nexus Feature |
|----------|--------------|
| Modular / product-based construction | Component-specific monitoring (brakes, ropes, doors) → replacement scheduling |
| Reduce unplanned breakdown | MTTR + FTTR KPIs → trend to zero |

---

## The Nexus Value Proposition in ITM Terms

The Singapore government's problem is **not a lack of standards** — it is a **fragmented, costly, proprietary landscape** that prevents the ITM targets from being met at scale:

1. **Cost:** Each lift vendor provides its own RM&D platform → building owners pay multiple subscriptions → government cannot aggregate data across buildings.
2. **Interoperability:** Proprietary platforms cannot easily integrate with other building systems (HVAC, pumps, fire systems) required for true Smart FM.
3. **Compliance:** Small vendors cannot afford to independently certify to IEC 62443 + TR 91 → market fragmentation.
4. **Accuracy accountability:** No standard way to measure and report DiA across vendors.

**Nexus solves this** by providing an open, composable, pre-compliant platform:
- Single platform, multiple vendor algorithms (IP protected as black-box Docker images)
- Standard KPI outputs (DiA, TFPE, MTTR, FTTR) consumable by BCA, HDB, or building owners
- Open protocols (MQTT, OPC UA, gRPC) → plug into any building management system
- Security hardening built-in (Phase 6) → reduces per-vendor compliance cost

---

## Key Government Stakeholders and Their Interests

| Stakeholder | ITM Role | Primary Interest in Nexus |
|-------------|----------|--------------------------|
| **BCA** | Chair of Working Group, mandates RM&D for lifts | DiA ≥85%, open protocols, BCA KPI API access |
| **HDB** | ~1M households, largest public lift owner | Cost reduction, centralised fleet dashboard |
| **LTA** | MRT stations, public transport infrastructure | Real-time alerts, IMDA TR 91 security compliance |
| **JTC** | Industrial estates, warehouses | AMR + lift integration, Smart FM across campuses |
| **MOH / hospitals** | Critical environment, AMR logistics | High uptime (UT metric), TR 91 security, PDPA compliance |
| **IMDA** | TR 91 enforcement for IoT in public infra | mTLS, device identity, no hardcoded credentials |
| CSA | Cybersecurity Labelling Scheme | IEC 62443-4-2 component compliance |
| **GovTech** | Smart Nation, Zero Trust for govt apps | Zero Trust architecture, PDPA-compliant data residency |

---

## 4. Glossary (Key Terms)

- **BCA:** Building and Construction Authority (the agency that oversees building safety and excellence in Singapore).
- **IMDA:** Infocomm Media Development Authority (the agency that leads Singapore’s digital transformation).
- **CSA:** Cyber Security Agency of Singapore (the national agency overseeing cybersecurity).
- **RM&D:** Remote Monitoring & Diagnostics (systems that detect technical faults early and reduce equipment breakdowns).
- **Smart FM:** Smart Facilities Management (using data and technology to operate buildings more safely, efficiently, and with less manpower).
