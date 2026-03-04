# RM&D OSS Architecture — Part 5B: Analytics & KPI Implementation

> Part 5B of 6 · Section 8.8: Cost-efficient analytics stack, BCA KPI formulas, data lakehouse architecture

> **Navigation:** [ARCH1 Overview](ARCH1_OVERVIEW.md) · [ARCH2 Security & Licensing](ARCH2_VENDOR_SECURITY.md) · [ARCH3 Plugin API](ARCH3_PLUGIN_API.md) · [ARCH4 Deployment](ARCH4_DEPLOYMENT.md) · **[ARCH5 Index](ARCH5_INDEX.md)** · [ARCH6 Strategy](ARCH6_STRATEGY.md)

> **Part 5 Sections:** [5A: OSS Selection](ARCH5A_OSS_SELECTION.md) · **5B: Analytics & KPI** · [5C: Abstraction Patterns](ARCH5C_ABSTRACTION.md) · [5D: Tech Stack](ARCH5D_TECH_STACK.md)

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


---

**Next:** [Part 5C: Infrastructure Abstraction Patterns](ARCH5C_ABSTRACTION.md) - Ports & Adapters, interface definitions, zero-downtime migration strategies
