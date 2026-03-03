# RM&D OSS Architecture — Part 6: Strategy, Governance & Appendices

> Part 6 of 6 · Sections 11–16: Migration roadmap, governance, success metrics, risk mitigation, next steps, conclusion, and license appendices.

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · [ARCH5 OSS Stack](ARCH5_OSS_STACK.md) · [ARCH6 Strategy](ARCH6_STRATEGY.md)

## 11. Migration & Adoption Strategy <a id="11-migration-adoption-strategy"></a>

Technical details for each phase are covered in [Section 8 (OSS Solutions)](ARCH5_OSS_STACK.md#8-leveraging-existing-oss-solutions), [Section 9 (Technology Stack)](ARCH5_OSS_STACK.md#9-technology-stack-recommendations), and [IaC Deployment (see ARCH4)](ARCH4_DEPLOYMENT.md#7.4-infrastructure-as-code-iac-deployment-strategy).

**Focus:** Building the **industry-agnostic "OSS Core"** (foundational protocols, security, and multi-tenant runtimes) and the initial **BCA Reference Implementation** (lifts/elevators) as the lead sector.

**Scope Boundary for v0.1:**
- **Canonical Telemetry Schema:** Full implementation of `TelemetryEnvelope` and `Point` (see [ARCH3 §6.1.1](ARCH3_PLUGIN_API.md#6.1.1)).
- **Minimum Plugin API:** In-process (WASM) and out-of-process (gRPC) interfaces for `Init`, `Process`, and `HealthCheck` (see [ARCH3 §6.3.5](ARCH3_PLUGIN_API.md#6.3.5)).
- **Baseline Security:** mTLS between Edge and Cloud; signature-based plugin verification (see [ARCH2 §4.2.5](ARCH2_VENDOR_SECURITY.md#4.2.5)).
- **Core Repositories:**
  - `nexus-core-edge-gateway`: The normative gateway distribution (assembled from EdgeX Foundry + Nexus services).
  - `nexus-sdk-go/python`: Client libraries for plugin developers.
  - `nexus-telemetry-proto`: Shared Protobuf definitions.

**Deliverables:**
1. **Edge Device SDK (C/C++, Rust):** Lightweight libraries for pushing telemetry.
2. **Gateway Distribution (EdgeX-based):** Foundation assembled from EdgeX Foundry with custom Nexus device/app services.
3. **Protocol Adapters:** MQTT and OPC-UA reference connectors.
4. **Cloud Ingestion API (gRPC):** High-throughput entry point for the platform core.
5. **Reference Implementation:** A Docker Compose stack for local development (QuestDB + Mosquitto + Grafana).

**Exit Criteria:**
- **Finalized Standards:** Telemetry schema frozen (v1) and Plugin API versioned.
- **Performance Baseline:** Gateway successfully ingests > 1,000 msg/s on reference hardware.
- **Security Baseline:** mTLS established end-to-end; initial software provenance (SBOM) produced.
- **Isolation:** Basic tenant and plugin isolation tests passing in reference runtime.
- **Compliance:** IEC 62443-4-1 (SDL) gap analysis completed and findings prioritized.

### 11.2 Phase 2: Vendor Onboarding (Months 7-12)

**Activities:**
1. Plugin API specification
2. Vendor SDK documentation
3. Certification program launch
4. 3-5 pilot vendor integrations

**Deliverables:**
- Plugin marketplace (beta)
- Vendor certification test suite
- Reference plugins (lift, HVAC, pump)

**Exit Criteria:**
- **Secure Ecosystem:** Plugin signing and WASM sandbox capability enforcement fully operational.
- **Automated Validation:** Certification test suite integrated into CI/CD for vendor submissions.
- **Vendor Readiness:** At least 3 independent vendor plugins successfully pass certification and load tests.

### 11.3 Phase 3: Production Hardening (Months 13-18)

**Focus:**
1. Production-grade Kubernetes deployment
2. Multi-tenant security hardening
3. Performance optimization (10k+ devices)
4. Commercial managed service launch
5. **Cross-Sector Pilot Program:** Initiate pilots with MPA (Maritime) and NEA (Cleaning/Waste).

**Certifications:**
- IEC 62443-3-3 system certification
- CSA CLS compliance for reference devices
- BCA RM&D compliance validation

**Exit Criteria:**
- **Security Posture:** Full threat model completed; all high/critical findings from external penetration testing closed.
- **Operational Readiness:** Incident response runbooks finalized; automated multi-region failover tested.
- **Scalability:** Load tests successfully executed at 10,000+ simulated devices with < 5s dashboard latency.

### 11.4 Phase 4: Ecosystem Growth (Months 19-24)

**Goals:**
1. 20+ certified vendors across 3+ sectors
2. 50,000+ devices/sensors deployed
3. Commercial plugin marketplace (Multi-industry)
4. Regional expansion (ASEAN smart cities)
5. **Full Industry Rollout:** Release of official standard plugins for Water (PUB) and autonomous robots (NEA).

**Exit Criteria:**
- **Operational SLOs:** Marketplace and cloud APIs meeting 99.9% availability and < 100ms P99 latency.
- **Governance Maturity:** Project governance and release processes stable and transitioned to community TSC.
- **Economic Viability:** Successful track record of commercial plugin transactions and SaaS renewals.

### 11.5 IEC 62443 Certification Roadmap

To achieve full compliance with BCA RM&D Code Section 6, the project follows this certification path:

| Milestone | Standard | Objective | Activities |
|:----------|:---------|:----------|:-----------|
| **SDL Readiness** | 62443-4-1 | Secure development process | Implement automated threat modeling, SAST/DAST in CI/CD, and vulnerability disclosure policy (VDP). |
| **Component SL-C** | 62443-4-2 | Technical capability of SDK/Gateway | Hardening of binary interfaces, secure boot implementation, and technical requirement validation (EDR/SWRA). |
| **System SL-T** | 62443-3-3 | System-level security assurance | Zonal isolation validation, conduit security testing, and SL-T (Target) capability assessment (SL 2 or 3). |

**Timeline Goal:**
- Month 6: SDL compliant (4-1 partial)
- Month 12: Gateway/SDK ready for 4-2 assessment
- Month 18: Full system certification (3-3) for reference architecture.


---

## 12. Stakeholders & Ecosystem

### 12.1 Government Stakeholders & Interests

| Stakeholder | Primary Interest in Nexus RM&D | ITM / Policy Link |
|-------------|------------------------------|-------------------|
| **BCA** | DiA ≥85%, open protocols (OPC UA), auditing | Sector Regulator |
| **HDB / JTC** | Fleet cost reduction, centralized dashboards | Large-scale Asset Owners |
| **LTA** | Real-time alerts, IMDA TR 91 security | Critical Public Infra |
| **MOH** | High uptime (UT), PDPA compliance, AMR integration | Critical Logistics |
| **IMDA / CSA** | Cybersecurity certification (CLS), Root-of-Trust | Security Enforcement |
| **GovTech** | Zero Trust Architecture, data residency | Smart Nation Platform |

### 12.2 OSS Project Governance

**Model:** **Benevolent Dictator Governance Council (BDGC)** or **Apache-style Foundation**

**Structure:**
- **Technical Steering Committee (TSC):** Architecture decisions, roadmap
- **Security Working Group:** Vulnerability management, security audits
- **Compliance Working Group:** IEC 62443, IMDA, CSA compliance
- **Vendor Advisory Board:** Vendor representatives, feedback loop

**Decision Process:**
- **Lazy Consensus:** Proposals pass unless objections
- **Voting:** TSC votes on major changes (2/3 majority)
- **Transparency:** Public mailing lists, GitHub discussions

### 12.3 Commercial Entity Structure

**Option A: Foundation + Commercial Arm**
- **Non-profit Foundation:** Owns OSS IP, trademarks, certification program
- **Commercial Entity:** Offers managed services, support, training
- **Revenue Sharing:** Commercial entity funds foundation development

**Option B: Dual-License Model**
- **OSS License:** Apache 2.0 for core components
- **Commercial License:** Optional for enterprises requiring warranty, indemnification

**Option C: SaaS-First**
- **OSS Core:** Free, self-hosted
- **Managed Service:** Commercial SaaS with premium features
- **Revenue Model:** Freemium (free tier + paid tiers)

---

## 13. Success Metrics

### 13.1 Adoption Metrics

| Metric | Target (Year 1) | Target (Year 3) |
|--------|-----------------|-----------------|
| **Certified Devices** | 1,000 | 50,000 |
| **Certified Vendors** | 5 | 50 |
| **Plugin Downloads** | 100/month | 1,000/month |
| **GitHub Stars** | 500 | 5,000 |
| **Active Contributors** | 10 | 100 |
| **Production Deployments** | 10 buildings (BCA) | 500+ Sites (BCA / MPA / NEA / PUB) |
| **Industry Breadth** | 1 (Built Env) | 4+ Singapore ITM Sectors |

### 13.2 Ecosystem Health Metrics

| Metric | Target |
|--------|--------|
| **Vendor Diversity** | 5+ countries, 3+ industries |
| **Customer Diversity** | Government, enterprise, SME |
| **Geographic Reach** | Singapore → ASEAN → Global |
| **Plugin Marketplace Revenue** | $100K/year → $1M/year |

### 13.3 Compliance Metrics

| Metric | Target |
|--------|--------|
| **IEC 62443 Certified Devices** | 80% of certified devices |
| **CSA CLS Level 3+ Devices** | 50% of certified devices |
| **Availability SLO (Uptime)** | 99.9% uptime (24/7 monitoring) |
| **Vulnerability SLA** | 0 critical open CVEs > 7 days |
| **Security Incident Metric** | 0 P1/P2 security incidents per quarter |

---

## 14. Risk Mitigation

### 14.1 Technical Risks

| Risk | Mitigation |
|------|-----------|
| **Vendor Lock-In** | Standardized APIs, open protocols, multi-cloud support |
| **Security Vulnerabilities** | Regular security audits, bug bounty program, CVE monitoring |
| **Performance Bottlenecks** | Horizontal scaling, edge processing, data compression |
| **License Compliance** | Automated license scanning (FOSSA, Black Duck), legal review |

### 14.2 Business Risks

| Risk | Mitigation |
|------|-----------|
| **Low Vendor Adoption** | Early vendor engagement, pilot programs, revenue sharing |
| **Commercial Competitors** | Focus on ecosystem, community, interoperability |
| **Regulatory Changes** | Modular compliance layer, regular standard updates |
| **Funding Sustainability** | Multiple revenue streams (SaaS, support, marketplace) |

### 14.3 Operational Risks

| Risk | Mitigation |
|------|-----------|
| **Key Person Dependency** | Documentation, knowledge sharing, diverse maintainers |
| **Community Burnout** | Paid maintainers, corporate sponsorships |
| **Breaking Changes** | Semantic versioning, deprecation policy, migration guides |

---

## 15. Next Steps

### 15.1 Immediate Actions (Weeks 1-4)

1. ✅ **Finalize Architecture** (this document)
2. ⏳ **Establish OSS Project**
   - Create GitHub organization
   - Choose foundation (Apache, Linux Foundation, CNCF)
   - Define governance model
3. ⏳ **Form Core Team**
   - Recruit 3-5 core maintainers
   - Identify sponsor companies
4. ⏳ **Vendor Outreach**
   - Identify 5-10 pilot vendors
   - Conduct architecture workshops
5. ⏳ **Funding**
   - Government grants (IMDA, Enterprise Singapore)
   - Corporate sponsorships
   - Foundation funding

### 15.2 Short-Term Milestones (Months 1-3)

1. **Device SDK v0.1** (Alpha)
   - Basic telemetry client
   - MQTT support
   - X.509 authentication
2. **Gateway v0.1** (Alpha)
   - MQTT broker
   - OPC-UA adapter
   - Plugin API specification
3. **Cloud Platform v0.1** (Alpha)
   - Kafka ingestion
   - TimescaleDB storage
   - Grafana dashboards

Implementation guidance for these milestones is detailed in [Section 8 (OSS Solutions)](ARCH5_OSS_STACK.md#8-leveraging-existing-oss-solutions), [Section 9 (Technology Stack)](ARCH5_OSS_STACK.md#9-technology-stack-recommendations), [IaC Deployment (see ARCH4)](ARCH4_DEPLOYMENT.md#7.4-infrastructure-as-code-iac-deployment-strategy), and [Section 11 (Migration Strategy)](#11-migration-adoption-strategy).

### 15.3 Medium-Term Goals (Months 4-12)

1. **Production Beta Release**
   - IEC 62443 gap analysis complete
   - Security audit passed
   - 3 vendor integrations
2. **Certification Program Launch**
   - Device certification test suite
   - Plugin certification process
3. **Commercial Service Launch**
   - Managed SaaS offering
   - Support contracts
   - Training program

---

## 16. Conclusion

This architecture proposal delivers a **commercial-friendly OSS RM&D solution** that:

✅ **Protects Vendor IP:** Plugin architecture with sandboxing and licensing
✅ **Scales to Millions of Devices:** Edge-first design with efficient protocols
✅ **Compliance by Design:** IEC 62443, IMDA, CSA, GovTech, BCA alignment
✅ **Flexible Deployment:** OSS self-hosted or commercial managed service
✅ **Multi-Vendor Ecosystem:** Standardized interfaces, marketplace model
✅ **Sustainable Business Model:** Multiple revenue streams for all stakeholders

**The key differentiator:** Unlike proprietary RM&D platforms, this OSS architecture **lowers barriers to entry** for hardware vendors while **maintaining high security and compliance standards**, enabling Singapore's Smart Nation vision to scale across ASEAN and globally.

---

## Appendices

### Appendix A: Glossary

- **RM&D:** Remote Monitoring & Diagnostics
- **OSS:** Open Source Software
- **IaC:** Infrastructure as Code - managing and provisioning infrastructure through declarative configuration files
- **GitOps:** Operational model using Git as the single source of truth for infrastructure and application configuration
- **mTLS:** Mutual TLS (bidirectional authentication)
- **OTA:** Over-The-Air (firmware updates)
- **TEE:** Trusted Execution Environment
- **TPM:** Trusted Platform Module
- **WASM:** WebAssembly
- **SBOM:** Software Bill of Materials
- **EdgeX Foundry:** Linux Foundation IoT edge computing platform for building interoperable edge solutions
- **Zero Trust:** Security model based on "never trust, always verify" principle with continuous authentication and authorization
- **ArgoCD:** Declarative GitOps continuous delivery tool for Kubernetes
- **Helm:** Package manager for Kubernetes applications
- **BSL:** Business Source License - time-delayed open source license with commercial use restrictions for initial years
- **OpenBao:** Community-driven fork of HashiCorp Vault (pre-BSL) maintaining MPL 2.0 license
- **VerneMQ:** Scalable, enterprise-ready MQTT broker licensed under Apache 2.0

### Appendix B: Reference Links

- Singapore Standards: https://www.singaporestandardseshop.sg/
- IEC 62443: https://webstore.iec.ch/
- IMDA IoT Guide: https://www.imda.gov.sg/
- CSA CLS: https://www.csa.gov.sg/
- GovTech Zero Trust: https://www.tech.gov.sg/
- BCA RM&D: https://www.bca.gov.sg/

### Appendix C: License Comparison

| License | Commercial Use | Patent Grant | Copyleft | Recommended For |
|---------|----------------|--------------|----------|-----------------|
| **Apache 2.0** | ✅ Yes | ✅ Yes | ❌ No | **Recommended:** Gateway, Cloud Core, All layers |
| **MIT** | ✅ Yes | ❌ No | ❌ No | Device SDK (alternative) |
| **EPL 2.0** | ✅ Yes | ✅ Yes | ⚠️ Weak | Eclipse projects (Mosquitto) |
| **MPL 2.0** | ✅ Yes | ✅ Yes | ⚠️ File-level | RabbitMQ, older Vault |
| **LGPL v2.1** | ✅ Yes | ❌ No | ⚠️ Weak | Protocol libraries (caution) |
| **GPL v2/v3** | ⚠️ Requires source disclosure | ❌ No (v2), ✅ Yes (v3) | ✅ Yes | ❌ **Avoid** for commercial ecosystem |
| **AGPL v3** | ⚠️ Requires source for SaaS | ✅ Yes | ✅ Yes (network) | ⚠️ **Use with caution** - Internal dashboards only (Grafana) |
| **BSL 1.1** | ❌ Restricted for 4 years | Varies | N/A | ❌ **Avoid** - EMQX, newer Vault, TimescaleDB features |
| **Timescale License** | ⚠️ Partial restrictions | N/A | N/A | ⚠️ **Use core only** (Apache 2.0 parts) |

**Key License Warnings for RM&D Commercial Use:**

1. **BSL 1.1 (Business Source License)** ⛔
   - **Affected:** EMQX (v5+), HashiCorp Vault (v1.16+), TimescaleDB (advanced features)
   - **Issue:** 4-year commercial use restriction, converts to open source after period
   - **Solution:** Use Apache 2.0 alternatives (VerneMQ, OpenBao, QuestDB)

2. **AGPL v3** ⚠️
   - **Affected:** Grafana, Metabase
   - **Issue:** SaaS provision requires source code disclosure
   - **Solution:** OK for internal dashboards; use Apache Superset for SaaS offerings

3. **GPL v2/v3** ⛔
   - **Affected:** Some BACnet libraries, legacy tools
   - **Issue:** Linking requires source disclosure
   - **Solution:** Avoid or isolate in separate processes

**Commercial-Friendly License Priority:**
1. ✅ **First choice:** Apache 2.0, MIT
2. ✅ **Acceptable:** EPL 2.0, MPL 2.0 (file-level copyleft)
3. ⚠️ **Use with caution:** AGPL v3 (internal use only)
4. ❌ **Avoid:** GPL, BSL, proprietary licenses with restrictions

#### License Decision Matrix by Use Case

This matrix helps implementers choose appropriate OSS licenses based on their deployment model.

| Use Case | Apache 2.0 / MIT | AGPL v3 (Grafana) | BSL 1.1 (EMQX, Vault 1.16+) | GPL v2/v3 | Recommended Action |
|----------|------------------|-------------------|-----------------------------|-----------|--------------------|
| **Internal Dashboards** | ✅ Recommended | ✅ Acceptable (low risk) | ⚠️ Check change date (4yr restriction) | ❌ Avoid (linking issues) | Use Grafana/Metabase for internal use; prefer Apache alternatives |
| **Distributed Appliance** (Gateway sold to customers) | ✅ Recommended | ❌ May trigger source disclosure | ❌ Commercial use restricted | ❌ Must disclose source | **Only use Apache/MIT** - Use VerneMQ, OpenBao |
| **SaaS Offering** (Multi-tenant cloud) | ✅ Recommended | ⚠️ Network copyleft risk | ❌ Managed service restriction | ❌ Must disclose source | **Only use Apache/MIT** - Use Apache Superset instead of Grafana/Metabase |
| **Embedded in Device** (SDK in firmware) | ✅ Recommended | ❌ Linking triggers copyleft | ❌ 4-year commercial restriction | ❌ Linking requires disclosure | **Only use Apache/MIT** - Eclipse Paho, mbedTLS |
| **Cloud Plugin** (Vendor proprietary plugin) | ✅ Recommended | ⚠️ Plugin must be AGPL too | ⚠️ Check license terms | ❌ Plugin must be GPL | Use Apache SDK; vendor can keep plugin proprietary |
| **Development/Testing** | ✅ Recommended | ✅ Acceptable | ✅ Acceptable | ✅ Acceptable | Any license OK for non-production use |

**Key Decision Rules:**

1. **If distributing to customers (appliance/device):** ONLY use Apache 2.0 / MIT
   - Rationale: Avoids source code disclosure obligations and commercial restrictions
   - Example: Gateway sold to building operators

2. **If offering as SaaS (multi-tenant cloud):** ONLY use Apache 2.0 / MIT
   - Rationale: AGPL v3 network copyleft triggers on SaaS
   - Example: RM&D platform offered by service provider
   - Exception: Grafana OK if used internally (not customer-facing)

3. **If internal use only:** Apache 2.0 / MIT / AGPL v3 all acceptable
   - Rationale: No distribution = no copyleft obligations
   - Example: Building owner's private monitoring dashboard

4. **If enabling vendor plugins:** Plugin API must use Apache 2.0 / MIT
   - Rationale: Vendors need freedom to keep plugins proprietary
   - Example: Lift manufacturer's diagnostic plugin

**Common Pitfalls to Avoid:**

| Pitfall | Impact | Solution |
|---------|--------|----------|
| Using EMQX (BSL 1.1) in production | 4-year commercial restriction, must switch later | Use **VerneMQ** (Apache 2.0) from day 1 |
| Using HashiCorp Vault 1.16+ (BSL 1.1) | Cannot use in production for 4 years | Use **OpenBao** (MPL 2.0) or AWS Secrets Manager |
| Using Grafana in SaaS offering | Must disclose entire platform source code | Use **Apache Superset** (Apache 2.0) for customer dashboards |
| Linking GPL library in device firmware | Must disclose device firmware source | Use LGPL or Apache alternatives (e.g., mbedTLS vs OpenSSL) |
| Using TimescaleDB advanced features (BSL 1.1) | Commercial use restrictions | Use **QuestDB** (Apache 2.0) or TimescaleDB Community (Apache parts only) |
| Using Proprietary Unity Catalog | Cloud-specific lock-in | Use **Unity Catalog (OSS)** (Apache 2.0) for multi-cloud parity |
| Choosing proprietary table formats | Data silo & exit costs | Use **Apache Iceberg** (Apache 2.0) for open lakehouse |

**License Audit Checklist:**

Before production deployment, verify:

- [ ] All dependencies have Apache 2.0, MIT, or compatible licenses
- [ ] No BSL 1.1 components if commercial use within 4 years
- [ ] No AGPL components if offering SaaS to customers
- [ ] No GPL components if distributing binaries to customers
- [ ] Plugin API dependencies are Apache/MIT (enables proprietary plugins)
- [ ] Container base images use permissive licenses (e.g., Alpine, Debian)
- [ ] JavaScript/frontend libraries checked (React = MIT ✅, some npm packages = GPL ❌)

**Legal Disclaimer:**

> **⚠️ NOT LEGAL ADVICE**: This matrix provides technical guidance only. License terms change, and interpretation depends on specific use cases. **Always:**
> 1. Verify current license terms from official sources
> 2. Consult qualified legal counsel before commercial deployment
> 3. Maintain a Software Bill of Materials (SBOM) for license compliance
> 4. Review license compatibility when combining multiple components
>
> This guidance is current as of March 2026 and reflects general interpretations. Your specific deployment may have unique legal considerations.

**Resources for License Compliance:**

- **SBOM Generation:** [syft](https://github.com/anchore/syft), [SPDX Tools](https://spdx.dev/tools/)
- **License Scanning:** [FOSSA](https://fossa.com/), [Black Duck](https://www.blackducksoftware.com/)
- **License Compatibility:** [Blue Oak Council](https://blueoakcouncil.org/list), [SPDX License List](https://spdx.org/licenses/)
- **Singapore Context:** Consult IP/tech lawyers familiar with Singapore law

---

**Document Version:** 1.0
**Last Updated:** March 2026
**Author:** nexus-docs Architecture Working Group
**Status:** Proposal for Community Review
