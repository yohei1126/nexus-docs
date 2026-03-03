# Smart Buildings / Facilities Management — Reading Guide

> **Context:** This reading guide is structured according to Singapore's policy chain:
> **[Built Environment ITM](https://www1.bca.gov.sg/buildsg/built-environment-industry-transformation-map-itm) (Vision)**
> → Agency Standards (What) → Nexus Platform (How)
>
> See [BCA_VISION.md](BCA_VISION.md) for the full vision-to-implementation mapping.

## Which Documents Should You Read First?

This prioritisation is designed specifically for **Remote Monitoring & Diagnostics (RM&D)** and **Connected Devices** in the **Built Environment**.

### 0. Start with the Government Vision (ITM)

Before reading any technical standard, understand *why* Singapore mandates RM&D.

#### (0a) BCA – Built Environment Industry Transformation Map (ITM, 2022)

Why first:

* Sets the overarching policy mandate: **80% of public buildings to adopt Smart FM by 2030**
* Explains the three pillars: IPD (open data), AMA (modular construction), **SUS (Smart FM = RM&D)**
* All subsequent standards are instruments to achieve this vision
* Understanding the vision prevents over-engineering against standards without understanding intent

Details:

* `standards/bca/Built Environment Industry Transformation Map...md`

#### (0b) MPA – Sea Transport Industry Transformation Map (ITM)

Why first (for Maritime use cases):

* Sets the strategy for **next-generation ports** and **International Maritime Centre**
* Explains the five pillars: Innovation, Productivity, Jobs and Skills, Internationalisation, and **Resilience (RM&D)**
* Essential if building for port equipment (cranes, AGVs) or vessel monitoring

Details:

* [MAP_VISION.md](MAP_VISION.md)
* `standards/map/transformation_map.md`

#### (0c) NEA – Environmental Services Industry Transformation Map (ITM)

Why first (for Cleaning & Waste use cases):

* Sets the strategy for **automated cleaning** and **sustainable waste management**
* Explains the four key thrusts: Innovation, Productivity, Quality Jobs, and Sustainability
* Essential for projects involving Smart Bins, Cleaning Robots, or Pest Monitoring

Details:

* [NEA_VISION.md](NEA_VISION.md)
* `standards/nea/transformation_map.md`

#### (0d) PUB – SMART PUB Roadmap (Digital Water)

Why first (for Water & Drainage use cases):

* Sets the strategy for **automated treatment plants**, **smart networks**, and **digital twins**
* Explains the four strategic goals: Create Value, Efficient Operations, Better Work Environment, and Improved Customer Service
* Essential for projects involving Pump Monitoring, Leak Detection, or Smart Water Meters

Details:

* [PUB_VISION.md](PUB_VISION.md)
* `standards/pub/Digitalising-Water-Sharing-Singapores-Experience.md`

#### Outcome of Step 0:

You understand *why* RM&D is mandated, *who* the target beneficiaries are (HDB, LTA, JTC, hospitals), and *what success looks like* (Smart FM adoption metrics). This frames all subsequent technical decisions.

---

### 1. Start with Cross‑Industry IoT Security (IMDA & CSA)

These are **foundational** because everything in a building (sensors, gateways, HVAC controllers, lifts, AMRs) must meet IoT/edge security baselines before any RM\&D system can be considered compliant.

#### (1) IMDA – IoT Cyber Security Guide (Top Priority)

Why first:

* Defines baseline secure‑by‑design patterns for IoT/edge
* Directly affects device firmware, OTA, PKI, telemetry, identity
* Applies to **all sensors, controllers, gateways** in buildings
* You need this before specifying SDKs or OSS modules

Details:

* [IMDA IoT Cyber Security Guide](https://www.imda.gov.sg/regulations-and-licensing-and-consultations/ict-standards/iot-cyber-security-guide)

#### (2) CSA – IoT Security Baseline / CLS (Cybersecurity Labelling Scheme)

Why second:

* Defines *minimum hardware and firmware requirements*
* Good reference for: secure boot, crypto, update, identity
* Helps translate policy → technical requirements for RM\&D OSS

Details:

* [CSA Cybersecurity Labelling Scheme (CLS)](https://www.csa.gov.sg/cls)
* [CSA CCoP for Critical Information Infrastructure](https://www.csa.gov.sg/-/media/Csa/Documents/Legislation_Supplementary_References/Cybersecurity-Code-of-Practice-for-CII.pdf)

#### Outcome of Step 1:

You can define the **Device SDK security model**, telemetry security, OTA standards, and enrollment/onboarding patterns.

#### (3) IEC-62443

Details:

* iec/IEC-62443-Standard-Enhancing-Cybersecurity-for-Industrial-Automation-and-Control-Systems-Fortinet.md

### 2. Next: Smart Buildings / Digital Infrastructure Requirements (GovTech)

These guidelines determine **how buildings and public-sector systems want devices to connect**.

#### (3) GovTech – Smart Nation IoT & Zero‑Trust Architecture**

Why:

* Defines **network segmentation**, **zero trust**, **API access**, **device onboarding**, and **trusted communication patterns**
* Provides the overarching *platform architecture* that your OSS RM\&D must follow

Details:

* [Government Zero Trust Architecture (GovZTA)](https://developer.tech.gov.sg/standards-and-best-practices/security-and-compliance/zero-trust-architecture/)

Outcome of Step 2:

You can define the Gateway architecture, API gateways, IAM integration, and audit/logging layer.

### 3. Built Environment: Domain‑Specific Standards (BCA)

Now move to the **Smart Building / Facilities Management specific** ones.

#### (4) BCA – RM&D Code of Practice for Lifts

Why:

* **This is the SUS pillar operationalised for the lift asset class** — the technical minimum bar that lifts must meet so they count toward the 80% Smart FM target
* Only explicit RM\&D guideline in the Built Environment; the reference model for HVAC, pumps, chillers etc.
* Defines what data must be collected, what metrics matter (DiA, MTTR, FTTR), fault codes, and reporting format
* Section 3.1.4 mandates OPC UA open interface — this directly drives the Nexus EdgeX ingestion design
* Section 6 cybersecurity requirements (IEC 62443) are shared with IMDA TR 91 — satisfying this document and TR 91 simultaneously

Details:

* `bca/code-of-practice-for-design-and-performance-of-remote-monitoring-and-diagnostics-solution-for-lifts-(final).md`

#### (5) BCA / IMDA – Green Mark Data Centre (DC monitoring requirements)

Why:

* DCs are highly RM&D‑dependent
* Defines **visibility requirements**, **energy reporting**, environmental telemetry → these directly inform the **common telemetry schema**

Details:

* bca/20241008_gmdc2024_ver1.pdf

Outcome of Step 3:

You can define the RM&D core modules: telemetry model, fault model, dashboard structure, and compliance evidence model.

### 4. Building–Robot Interoperability (NRP)

You only need these **after the building side is clear**.

#### (6) TR93 – Robot–Lift / Facility Interoperability

Why:

* Defines how robots interact with building systems
* Useful for your OSS **gateway layer** if you want AMRs integrated

Details:

#### (7) SS713 – Robot–Infrastructure Data Exchange Standard

Why:

* Defines the data schemas, handshake, status exchange
* Helps you design a **multi‑vendor compatible RM\&D gateway**

Outcome of Step 4:

You can extend RM&D OSS from “building devices” to “building+AMR system.”

## 🎯 Why This Order Works

Because it matches the **policy and dependency order** you need when building a government-compliant RM&D system:

| Layer | Required Documents | Maps to ITM Pillar |
|-------|-------------------|-------------------|
| **Vision & mandate** | BE ITM 2022 (Built Env) / Sea Transport ITM (Maritime) / ES ITM (Cleaning) / SMART PUB Roadmap (Water) | SUS / Resilience / Sustainability / Efficiency — RM&D targets |
| **Security foundation (device → network → cloud)** | IMDA TR 91 → CSA CLS → GovTech Zero Trust | SUS — secure infra |
| **RM&D functional requirements** | BCA RM&D CoP → Green Mark DC | SUS — measurable outcomes |
| **Open data interoperability** | BCA Data Standards, OPC UA (§3.1.4) | IPD — Common Data Environment |
| **Building–robot interoperability (optional)** | TR93 / SS713 | AMA — modular systems |

This mirrors the natural structure of a government-compliant RM&D platform:

1. **Policy intent** — ITM tells you what success looks like
2. **Device security & telemetry security** — IMDA TR 91, CSA CLS
3. **Network & backend security** — GovTech Zero Trust
4. **RM&D data models & operational requirements** — BCA CoP
5. **Interoperability for multi‑vendor environments** — TR93 / SS713
