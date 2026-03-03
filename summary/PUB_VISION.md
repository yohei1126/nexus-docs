# Singapore Water Vision → Nexus RM&D Integration

This document summarizes **PUB's (Singapore's National Water Agency) Digital Roadmap**, as detailed in *"Digitalising Water: Sharing Singapore's Experience"*, and maps its priorities to the **Nexus RM&D Platform**.

📄 Source: [Digitalising Water – Sharing Singapore’s Experience](https://iwaponline.com/ebooks/book/776/Digitalising-Water-Sharing-Singapore-s-Experience) (IWA/PUB)

---

## 1. The Vision: SMART PUB Roadmap

PUB's digital transformation is centered on the **SMART PUB Roadmap** (unveiled in 2018), which aims to digitalize Singapore's entire water system to optimize operational capabilities and meet future water demand (slated to double by 2060).

### Four Strategic Goals

| Goal | Description | Relevance to Nexus RM&D |
|-----------|-------------|-------------------------|
| **Create Value** | New capabilities & breakthroughs. | Standardized data ingestion for novel sensors (e.g., MES for toxic detection). |
| **Efficient Operations** | Predictive & optimized systems. | Predictive maintenance for 2,000+ pump sets; real-time leak detection in networks. |
| **Better Work Environment** | Automation & safety for staff. | UAV-based tunnel inspections; wearable safety trackers; RFID asset tracking. |
| **Improved Customer Service** | Empowering users with data. | Smart water meter integration; real-time usage visibility and leak alerts. |

---

## 2. Vision → Nexus Implementation Mapping

### Asset Health Monitoring (Pump Sets)
Nexus's **condition-based monitoring** aligns with PUB's use of vibration and electrical current sensors to predict pump failures. Nexus can serve as the baseline platform for ingesting these high-frequency telemetry points and running anomaly detection models to pre-empt mechanical faults (imbalances, misalignments, bearing defects).

### Smart Drainage Grid & CWOS
Nexus's **multi-sensor integration** capabilities support PUB's "Smart Drainage Grid." By correlating water level sensors, flow sensors, and rainfall data, the platform can identify chokes or blockages and optimize the operations of critical infrastructure like the Marina Barrage.

### Unmanned & Robotic Inspections
Nexus integrates with **UAVs and Robotics** (via TR93/SS713) to support man-less inspections in hazardous environments (e.g., deep tunnel sewerage systems). The platform provides the repository for inspection data and 3D navigation logs.

### Digital Twins
Nexus provides the **replicated historian and real-time data stream** required for "Digital Twins" (Logic Check-out Platforms and Mirror Plants). This enables operators to simulate "what-if" scenarios for chemical dosing or process changes before implementation.

---

## 3. Collaborative Stakeholders

| Stakeholder | Role in Digital Water | Primary Interest in Nexus RM&D |
|-------------|-----------------------|--------------------------------|
| **PUB** | Lead Agency (National Water Agency) | System-wide optimization, water security, asset longevity. |
| **GovTech** | Co-developer of AI systems | Zero Trust architecture, cross-agency data sharing patterns. |
| **NEA** | Partner (Meteorological Service) | Integration of rain gauge data for drainage and flood management. |
| **Industry Partners** | Equipment/Software Vendors | Standardized API for deploying proprietary analytics (e.g., aeration control, pump diagnostics). |

---

## 4. Glossary (Key Water Terms)

- **PUB:** Singapore's National Water Agency.
- **Four National Taps:** Local catchments, imported water, NEWater (reclaimed water), and desalinated water.
- **NEWater:** High-grade reclaimed water produced from treated used water.
- **CWOS:** Catchment and Waterways Operations System.
- **DTSS:** Deep Tunnel Sewerage System.
- **DiA:** Diagnostic Accuracy (used here for water quality and event prediction).
- **MES:** Microbial Electrochemical Sensor (for toxic pollution detection).
