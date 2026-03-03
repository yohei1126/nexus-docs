# RM&D OSS Architecture — Part 2: Vendor Integration, Security & Licensing

> Part 2 of 6 · Sections 3–5: Vendor IP protection, compliance mapping, security layers, licensing & business model.

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · [ARCH5 OSS Stack](ARCH5_OSS_STACK.md) · [ARCH6 Strategy](ARCH6_STRATEGY.md)

---

### Clarification: Normative vs. Informative
To maintain document clarity and implementation flexibility, readers should distinguish between:

*   **Normative (Mandatory):** Architectural requirements that **must** be implemented to ensure security and compliance (e.g., Trust Boundaries, Sandboxing, Code Signing, Tenant Isolation, BCA Annex A KPIs).
*   **Informative (Examples):** Specific tooling recommendations (e.g., Vault, Kong), baseline values/thresholds (e.g., "90 days", "1000 req/min"), and example algorithms. These are **provisional defaults** and should be tuned based on actual deployment policy-as-code.

---

## 3. Vendor Integration & IP Protection Strategy

### 3.1 Three-Tier Plugin Model

```text
┌────────────────────────────────────────────────────────────────┐
│ Tier 1: OSS Core (Apache 2.0)                                  │
│  - Standard telemetry schema                                   │
│  - Protocol adapters                                           │
│  - Security framework                                          │
│  - Basic analytics                                             │
│  └─ Anyone can use, modify, commercialize                      │
└────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌────────────────────────────────────────────────────────────────┐
│ Tier 2: Vendor Plugins (Proprietary or Dual-License)           │
│  - Custom fault prediction algorithms                          │
│  - Proprietary device control protocols                        │
│  - Business logic (e.g., maintenance scheduling)               │
│  - Domain-specific knowledge (e.g., lift safety codes)         │
│  └─ Vendors control distribution, licensing, pricing           │
└────────────────────────────────────────────────────────────────┘
                              ▲
                              │
┌────────────────────────────────────────────────────────────────┐
│ Tier 3: Customer-Specific Extensions (Private)                 │
│  - Custom dashboards                                           │
│  - Internal workflows                                          │
│  - Integration with customer's CMMS/ERP                        │
│  └─ Customers own their extensions                             │
└────────────────────────────────────────────────────────────────┘
```

### 3.2 Plugin Distribution Models

**Option A: Vendor-Hosted Plugins**
- Vendor hosts plugin binaries in their registry
- Customers purchase license keys from vendor
- Gateway downloads and activates plugin using license key
- Vendor controls updates and versioning

**Option B: Marketplace Model**
- Central plugin marketplace (similar to VS Code extensions)
- Vendors publish plugins (free, paid, trial)
- Revenue sharing model (e.g., 70% vendor, 30% marketplace)
- Automated compatibility testing and certification

**Option C: Private Enterprise Deployment**
- Enterprises negotiate directly with vendors
- Plugins deployed in customer's private environment
- No dependency on external marketplace

### 3.3 IP Protection Mechanisms

1. **Code Obfuscation:** Vendors can compile plugins to native binaries or obfuscated WASM
2. **License Keys:** Plugin activation requires vendor-issued license
3. **Runtime Sandboxing:** Plugins cannot access other vendors' code or data
4. **Platform-Mediated Egress:** Plugins primarily communicate via core APIs. Any outbound communication is restricted to pre-approved vendor whitelists (e.g., proprietary ML inference) with mandatory logging and platform-enforced TLS policy.
5. **Attestation:** Secure boot and remote attestation prevent plugin tampering

---

## 4. Compliance & Security Architecture

### 4.1 Singapore Government Compliance Mapping

| Requirement | Architecture Component | Implementation |
|-------------|------------------------|----------------|
| **BE ITM — SUS Pillar** (Smart FM 80% by 2030) | Entire platform | Open, composable RM&D enabling Smart FM at scale across vendors |
| **BE ITM — IPD Pillar** (open data / CDE) | Gateway Protocol Adapters | OPC UA (§3.1.4 BCA CoP), MQTT 5.0, gRPC — no proprietary bus |
| **BE ITM — AMA Pillar** (modular / predictive replacement) | Analytics Engine | Component-level sensor streams → replacement scheduling |
| **IEC 62443-4-2** (Component) | Edge Device SDK | - Technical requirements for **Embedded Devices (EDR)** (IDs refer to specific requirement clauses)<br>- Secure boot & signature verification<br>- Protection of diagnostic/test interfaces |
| **IEC 62443-3-3** (System) | Gateway + Cloud Platform | - Mapping to **7 Foundational Requirements (FRs)**<br>- Security Level (SL) capability thresholds<br>- Zonal isolation and conduit security |
| **IEC 62443-4-1** (Process) | OSS Development SDL | - **Secure Product Development Lifecycle (SDL)**<br>- Practices: management, specification, design, implementation, verification, update |
| **IMDA IoT Security Guide (TR 91)** | Device SDK + Gateway | - Root-of-Trust (TPM/TEE)<br>- Strong cryptography<br>- Access controls<br>- Patch management |
| **CSA CLS Level 3-4** | Device Certification | - Device SDK reference<br>- Certification test suite<br>- Continuous compliance |
| **GovTech Zero Trust** | Cloud Platform | - Policy Decision Point (PDP)<br>- Policy Enforcement Point (PEP)<br>- Continuous verification |
| **BCA Lift Code RM&D** | Analytics Engine | - Critical data prioritization<br>- Predictive maintenance<br>- KPI dashboards (TFPE, FTTR, MTTR, DiA, DA) -- see [Section 4.3](#4.3-mandatory-rmd-indicators-bca-annex-a) for definitions<br>- Read-only device access |

For detailed security-focused OSS solutions, see [Security & Compliance (ARCH5 §8.2.4)](ARCH5_OSS_STACK.md#8.2.4-security--compliance---use-security-focused-oss).

### 4.2 Security Architecture

#### 4.2.1 Security Layers

```text
┌─────────────────────────────────────────────────────────────┐
│                   SECURITY LAYERS                            │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 7: Compliance & Audit                            │ │
│  │  - IEC 62443 compliance dashboard                      │ │
│  │  - Automated audit trail generation                    │ │
│  │  - Regulatory reporting (BCA, CSA, IMDA)               │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 6: Application Security                          │ │
│  │  - API authentication (OAuth 2.0, API keys)            │ │
│  │  - RBAC (building owner, contractor, vendor, admin)    │ │
│  │  - Data isolation (multi-tenant)                       │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 5: Data Security                                 │ │
│  │  - Encryption at rest (AES-256)                        │ │
│  │  - Encryption in transit (TLS 1.3)                     │ │
│  │  - Key management (HSM, KMS)                           │ │
│  │  - PII anonymization                                   │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 4: Network Security                              │ │
│  │  - Zero Trust (never trust, always verify)             │ │
│  │  - Micro-segmentation (OT/IT isolation)                │ │
│  │  - mTLS (mutual authentication)                        │ │
│  │  - DDoS protection                                     │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 3: Platform Security                             │ │
│  │  - Container security (image scanning, runtime)        │ │
│  │  - Secrets management (Vault, AWS Secrets Manager)     │ │
│  │  - SIEM integration (log aggregation, threat detection)│ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 2: Gateway Security                              │ │
│  │  - Certificate management (auto-renewal)               │ │
│  │  - Plugin sandboxing (resource limits)                 │ │
│  │  - Local firewall rules                                │ │
│  └────────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Layer 1: Device Security (IEC 62443-4-2 EDR)           │ │
│  │  - Secure boot (EDR 3.14)                              │ │
│  │  - Hardware security module (TPM, TEE)                 │ │
│  │  - Firmware signature verification (EDR 3.10)          │ │
│  │  - Anti-rollback protection (EDR 3.10 enhancement)     │ │
│  │  - Physical tamper detection (EDR 3.11)                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

> [!NOTE]
> **EDR (Embedded Device Requirement)** IDs refer to specific technical requirements defined in IEC 62443-4-2 for industrial IACS components. 


#### 4.2.2 IEC 62443 Foundational Requirements (FRs)

The architecture is designed to meet target security levels (SL-T) across all 7 FRs as defined in IEC 62443-3-3:

| FR | Requirement | Implementation in Nexus Architecture |
|----|-------------|---------------------------------------|
| **FR 1: IAC** | Identification and authentication control | X.509 certificates (mTLS) for devices; OAuth 2.0/OIDC for users. |
| **FR 2: UC** | Use control | RBAC with tenant-scoped isolation (JIT access for admins). |
| **FR 3: SI** | System integrity | Signed firmware updates (secure boot) and plugin sandboxing (WASM). |
| **FR 4: DC** | Data confidentiality | AES-256 encryption at rest; TLS 1.3 for all conduits. |
| **FR 5: RDF** | Restricted data flow | VLAN segmentation (OT/IT isolation) and firewall rule enforcement. |
| **FR 6: TRE** | Timely response to events | Real-time SIEM logging and automated alerting for security violations. |
| **FR 7: RA** | Resource availability | DoS protection at gateway; load balancing and auto-scaling in cloud. |

#### 4.2.3 Secure Product Development Lifecycle (IEC 62443-4-1)

Compliance with the BCA Code of Practice requires the RM&D solution provider to follow a certified secure SDL. The Nexus OSS project implements these foundational practices:

1.  **Security Management:** Documentation of security roles, responsibilities, and secure engineering training.
2.  **Specification of Security Requirements:** Security requirements are specified for every architecture component based on TR 91 and IEC 62443.
3.  **Secure by Design:** Adherence to "least privilege," "defense in depth," and "failure to safety" principles.
4.  **Secure Implementation:** Coding standards (e.g., MISRA for C++, strict Rust safety for core), static analysis (SAST), and secrets management.
5.  **Security Verification & Validation:** Automated testing suite including unit, integration, and fuzz testing.
6.  **Management of Security-Related Issues:** Public vulnerability reporting policy (VDP) and organized CVE tracking.
7.  **Security Update Management:** Secure OTA update mechanism with signature verification and rollback protection.
8.  **Security Guidelines:** Comprehensive documentation for secure deployment and configuration (ARCH4).

#### 4.2.4 Security Levels (SL) Baseline

Nexus is targeting **SL 2 (Medium)** for general building systems and **SL 3 (High)** for critical medical or data center facilities.

-   **SL 2:** Protection against intentional violation using simple means with low resources and generic skills.
-   **SL 3:** Protection against intentional violation using sophisticated means with moderate resources and IACS specific skills.

#### 4.2.5 Trust Boundaries & Security Controls

This table maps each trust boundary to the assets it protects, potential threats, and implemented security controls.

| Trust Boundary | Asset Protected | Primary Threats | Security Controls | Validation Method |
|----------------|-----------------|-----------------|-------------------|-------------------|
| **Device ↔ Gateway** | Telemetry data integrity & authenticity | MITM attacks, data tampering, device impersonation | • mTLS with X.509 client certificates<br>• HMAC-SHA256 signature on telemetry<br>• Certificate pinning | • Automated cert rotation tests<br>• Signature validation on 100% of messages<br>• Failed auth logged to SIEM |
| **Gateway ↔ Cloud** | Multi-tenant telemetry streams | Eavesdropping, session hijacking, replay attacks | • TLS 1.3 with perfect forward secrecy<br>• JWT tokens (typical 1h expiry) + API keys<br>• Request rate limiting (typical 1000 req/min) | • TLS cipher suite enforcement<br>• Token expiry validation<br>• Rate limit breach alerts |
| **Plugin Sandbox** | Vendor IP + tenant data isolation | Privilege escalation, memory exploits, data exfiltration | • **WASM**: Memory isolation (typical 256MB limit)<br>• **gRPC/Docker**: Process/Namespace isolation (mTLS enforced)<br>• Restricted syscalls (no exec/fork) | • Runtime sandbox violations logged<br>• Memory limit enforcement<br>• Network call audit trail |
| **Tenant ↔ Tenant** | Customer confidential data | Cross-tenant data leakage, unauthorized access | • Kubernetes NetworkPolicy (L3/L4 isolation)<br>• Database row-level security (tenant_id filter)<br>• JWT claims-based RBAC | • Automated penetration tests<br>• Query audit logs (tenant_id checks)<br>• RBAC policy validation |
| **Cloud Platform ↔ Internet** | API endpoints, dashboards | DDoS, SQL injection, XSS, brute force | • WAF (OWASP Top 10 rules)<br>• API rate limiting (per-tenant quotas)<br>• Input validation (JSON schema)<br>• Security headers (CSP, HSTS) | • WAF block rate monitoring<br>• Vulnerability scanning (typical weekly)<br>• Penetration testing (typical quarterly) |
| **OT ↔ IT Networks** | Building operational systems | Lateral movement from IT to OT, ransomware | • Physical network segmentation (VLANs)<br>• Firewall rules (deny by default)<br>• One-way data diode (OT → IT only) | • IDS/IPS at boundary<br>• Network traffic analysis<br>• Firewall rule audits (typical monthly) |
| **Admin Access** | Infrastructure & platform configuration | Credential theft, insider threats, account takeover | • MFA (TOTP or hardware keys)<br>• Bastion host with session recording<br>• Just-in-time (JIT) privilege escalation<br>• Immutable audit logs | • MFA enforcement (100% admins)<br>• Session recordings (typical 1 year retention)<br>• Privilege escalation alerts |
| **Data at Rest** | Time-series DB, object storage | Data breach, compliance violations | • AES-256-GCM encryption<br>• KMS-managed keys (typical 90d rotation)<br>• Access logging (all read/write) | • Encryption verification scripts<br>• Key rotation compliance checks<br>• Access log anomaly detection |
| **Firmware Update** | Device integrity & availability | Malicious firmware, bricked devices | • Code signing (RSA-4096 or Ed25519)<br>• Anti-rollback counter (monotonic)<br>• Staged rollout (canary deployments)<br>• Rollback capability | • Signature validation (device-side)<br>• Version monotonicity checks<br>• Rollout success rate (>99.9%) |
| **Third-Party Plugins** | Platform stability & security | Malicious plugins, supply chain attacks | • Plugin code signing (vendor certs)<br>• Security scanning (CVE checks)<br>• Reputation scoring (download metrics)<br>• Plugin certification program | • Signature verification on load<br>• CVE scan on every upload<br>• User rating system |

#### 4.2.6 Zero Trust Architecture Principles

All trust boundaries implement **Zero Trust** principles by decoupling policy decisions from enforcement points.

| Component Type | Role in Zero Trust | Placement & Implementation |
| :--- | :--- | :--- |
| **Policy Decision Point (PDP)** | Evaluates requests against central security policies | • **Cloud**: Centralized IAM + OPA (Open Policy Agent) clusters<br>• **Gateway**: Localized OPA sidecar (cached policies for offline operation) |
| **Policy Enforcement Point (PEP)** | Enforces the decision by granting or denying access | • **Edge**: mTLS handshake in Edge SDK<br>• **Gateway**: Kong API Gateway / Envoy proxy<br>• **Cloud**: Kubernetes Ingress / Service Mesh Authz (Istio/Linkerd) |
| **Policy Administration Point (PAP)** | Where policy is defined and managed | • **Cloud**: Policy-as-Code repository (GitOps) + Admin UI |
| **Policy Information Point (PIP)** | Provides context (e.g., threat intel, device health) | • **Cloud/Gateway**: SIEM logs, device heartbeat status, CRL/OCSP |

**Core Principles:**

1. **Never Trust, Always Verify**
   - No implicit trust based on network location (OT vs IT)
   - Every request authenticated and authorized via **PEP** at each boundary.

2. **Least Privilege Access**
   - Devices access only their own telemetry streams.
   - Plugins access only tenant-scoped data via **OPA-calculated claims**.
   - Admins use JIT (Just-In-Time) privilege escalation.

3. **Assume Breach**
   - Microsegmentation limits blast radius (K8s NetworkPolicies).
   - Immutable audit logs for forensics (WORM-compliant storage).
   - Anomaly detection at every boundary.

4. **Continuous Validation**
   - Certificates rotated (typical 90-day baseline).
   - Tokens expire (typical 1-hour session duration).
   - Security posture assessed (typical weekly baseline).

#### 4.2.7 Trust-boundary Compliance Mapping

| Trust Boundary | IEC 62443 | IMDA IoT Guide | GovTech Zero Trust | CSA CLS |
|----------------|-----------|----------------|--------------------| --------|
| Device ↔ Gateway | SL 2 (Authenticated access) | Section 5.2 (Device auth) | Principle 2 (Device identity) | Level 3 (Crypto) |
| Gateway ↔ Cloud | SL 3 (Encrypted channels) | Section 5.3 (Data protection) | Principle 4 (Encrypt in transit) | Level 3 (TLS 1.2+) |
| Plugin Sandbox | SL 2 (Resource control) | Section 6.1 (Update security) | Principle 6 (Least privilege) | Level 2 (Isolation) |
| Tenant ↔ Tenant | SL 3 (Data isolation) | Section 7.2 (Multi-tenancy) | Principle 3 (Segment networks) | Level 4 (Multi-tenant) |

**Legend:**
- **IEC 62443 SL:** Security Level (1=Basic, 2=Medium, 3=High, 4=Very High)
- **IMDA IoT Guide:** Singapore IoT Cyber Security Guide v2.0
- **GovTech Zero Trust:** Government Zero Trust Architecture Framework
- **CSA CLS:** Cybersecurity Labelling Scheme levels

#### 4.2.8 Default Security Baseline (Configurable)

The specific values and limits (e.g., rotation periods, rate limits, memory quotas) mentioned in the above tables represent a **Typical Baseline** for general building integration. To avoid lock-in and allow for risk-based adjustment:

- **Policy-as-Code:** All limits are defined in configuration files (YAML, Jsonnet) or declarative policies (OPA, Gatekeeper).
- **Tunabilities:** Organizations may tighten or loosen these parameters based on their specific Risk Management & Diagnostics (RM&D) requirements.
- **Reference Implementation:** The default values in the Nexus reference implementation are derived from standard GovTech and IMDA guides for public infrastructure but should be reviewed per project.

---

### 4.3 Mandatory RM&D Indicators (BCA Annex A)

As specified in Annex A of the BCA Code of Practice, the following KPIs must be monitored and reported:

- **TFPE (Technical Faults per Equipment):** Number of technical faults per lift per month.
- **FTTR (First Time Fix Rate):** % of technical faults that do not re-occur within 30 days of rectification.
- **MTTR (Mean Time To Repair):** Average hours taken to resolve a technical fault.
- **DiA (Diagnostics Accuracy):** % of RM&D-predicted faults confirmed by on-site inspection matching reality.
- **DA (Device Availability):** % of time the RM&D unit is online and transmitting data.
- **UT (Average Monthly Uptime):** % of time the lift equipment is operational (excludes technical fault downtime).
- **FPE (Faults per Equipment):** Total faults (Technical + Non-Technical) per lift per month.

---

### 4.4 Governance, Audit & Access Control {#4.4-governance}

Nexus implements a strict governance layer to ensure compliance with the **PDPA**, **Cybersecurity Act**, and **IMDA TR 91**.

#### 4.4.1 Strict Access Rights (Advanced RBAC/ABAC)

Access is denied by default (Zero Trust). Permissions are granted through a combination of Role-Based (RBAC) and Attribute-Based (ABAC) Access Control:

*   **Principal Identity:** Every user, device, and plugin has a unique, cryptographically-proven identity.
*   **Scoped Permissions:** Permissions are scoped at the **Tenant**, **Building**, and **Asset** level. A lift contractor can only see telemetry for lifts they maintain.
*   **Just-in-Time (JIT) Elevation:** Admin access to production environments requires time-limited elevation with mandatory reason-logging.
*   **Machine-to-Machine (M2M) Security:** All inter-service communication is secured via mTLS and short-lived JWTs.

#### 4.4.2 Immutable Audit Logging (WORM)

A "Single Source of Truth" for all system actions is maintained using **WORM (Write Once, Read Many)** storage:

| Log Category | Events Captured | Retention | Criticality |
|:--- |:--- |:--- |:--- |
| **Identity/Auth** | Successful logins, MFA failures, JIT elevations. | 2 Years | High (PDPA) |
| **API/Management** | Creation/deletion of tenants, users, or data sharing policies. | 5 Years | High (Cert) |
| **Data Access** | Every read/query by plugins or 3rd-parties (scoped to tenant_id). | 2 Years | Medium |
| **System Operations** | Configuration changes, firmware update triggers, plugin deployments. | 5 Years | High |

**Technical Implementation:**
- **Audit-by-Design:** No system action is permitted unless an audit record is successfully queued for persistent storage.
- **Signed Logs:** Logs are signed at the source (Gateway/Cloud) before ingestion using a hardware-backed key (TPM/HSM).
- **Centralized Archival:** Logs are streamed to cloud storage with **Object Lock** enabled, preventing any modification or deletion even by root administrators.

#### 4.4.3 Automated Regulatory Reporting

Nexus reduces the compliance burden by providing real-time, audit-ready states for:

1.  **PDPA Compliance:** Automated checks for data residency and user consent lifecycle.
2.  **Cybersecurity Act (CII):** Pre-formatted incident reports and activity logs that satisfy **CSA CII Requirements**.
3.  **BCA RM&D Audit:** One-click generation of the **Annex A Performance Report**, verifying the integrity of KPI data through cryptographic proof.

---

## 5. Licensing & Business Model

### 5.1 OSS Component Licenses

| Component | License | Rationale |
|-----------|---------|-----------|
| **Edge Device SDK** | **Apache 2.0 or MIT** | Maximum commercial freedom; no patent concerns; can be embedded in proprietary devices |
| **Gateway Core** | **Apache 2.0** | Allows commercial forks; patent protection for contributors |
| **Cloud Platform Core** | **Apache 2.0** | Enables SaaS business models; vendor-neutral |
| **Protocol Specs** | **CC0 (Public Domain)** | No restrictions on implementation |
| **Documentation** | **CC BY 4.0** | Requires attribution but allows commercial use |

### 5.2 Revenue Models for Commercial Services

**For OSS Foundation/Maintainers:**
1. **Hosted/Managed Services:** Offer fully-managed cloud platform (SaaS)
2. **Support & Consulting:** Enterprise support contracts, implementation services
3. **Certification:** Device certification program, plugin certification
4. **Training:** Official training courses, certification exams

**For Device Vendors:**
1. **Plugin Sales:** Sell proprietary analytics plugins
2. **Premium Features:** Advanced predictive models, custom integrations
3. **Service Contracts:** Maintenance optimization services
4. **Data Insights:** Aggregate analytics across installed base (anonymized)

**For System Integrators:**
1. **Implementation Services:** Deploy and customize OSS stack
2. **Integration Projects:** Connect RM&D with existing BMS, CMMS, ERP
3. **Managed Services:** Operate RM&D platform for customers

**For Cloud Providers:**
1. **Infrastructure Hosting:** Optimized RM&D hosting on AWS/Azure/GCP
2. **Marketplace Listings:** Offer 1-click deployment from cloud marketplace
3. **Co-Sell Programs:** Partner with device vendors for bundled offerings

---

