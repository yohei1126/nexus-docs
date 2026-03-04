# nexus-docs — Agent Instructions

This repository stores Singapore government regulatory standards (as Markdown)
and Nexus RM&D platform analysis documents. It is a **git submodule** inside
`nexus-demo/nexus-docs/`.

---

## Repository Layout

```
nexus-docs/
├── README.md                     ← Project overview and quick links
├── AGENTS.md                     ← You are here
├── main.py                       ← PDF → Markdown conversion tool (docling)
├── pyproject.toml                ← Python deps (uv)
├── uv.lock                       ← Locked dependency versions
│
├── standards/                    ← Government source documents (Markdown)
│   ├── bca/                      ← Building and Construction Authority
│   ├── imda/                     ← Infocomm Media Development Authority
│   ├── csa/                      ← Cyber Security Agency
│   ├── govtech/                  ← GovTech / Smart Nation
│   └── iec/                      ← IEC 62443 industrial cybersecurity
│
└── summary/                      ← Nexus team analysis and guides
    ├── ARCHITECTURE.md           ← OSS RM&D architecture (100+ pages)
    ├── SMART_BUILDINGS_SUMMARY.md
    └── SMART_BUILDINGS_DOCS.md
```

**Key subfolders in `standards/`:**

| Folder | Agency | Key Documents |
|--------|--------|--------------|
| `bca/` | Building & Construction Authority | RM&D Code of Practice for Lifts (with Nexus analysis added), Site Management Data Standards, Site Management Platform |
| `imda/` | IMDA | IoT Cyber Security Guide (TR 91) |
| `csa/` | Cyber Security Agency | Cybersecurity Labelling Scheme (CLS), CCoP |
| `govtech/` | GovTech | Government Zero Trust Architecture |
| `iec/` | IEC | IEC 62443 Industrial Automation Cybersecurity |

---

## Document Generation — Converting PDFs to Markdown

When a new government standard PDF is obtained, convert it to Markdown using
the `main.py` docling pipeline.

### Prerequisites

```bash
# Install uv if not present
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install dependencies (from nexus-docs/ root)
cd /path/to/nexus-docs
uv sync
```

### Convert a single PDF

```bash
uv run python main.py <path/to/document.pdf> [output/path.md]
```

**Example — adding a new IMDA standard:**
```bash
# Place PDF in the correct standards folder first
cp ~/Downloads/imda-new-standard.pdf standards/imda/

# Convert (output is auto-named next to the PDF if not specified)
uv run python main.py standards/imda/imda-new-standard.pdf

# Result: standards/imda/imda-new-standard.md
```

### Convert all PDFs recursively

```bash
# Convert every PDF under standards/ that doesn't already have an .md
uv run python main.py standards/
```

> [!NOTE]
> The tool **skips** PDFs where a same-named `.md` already exists.
> Re-run with `--force` is not implemented; to reconvert, delete the `.md` first.

### Convert with a separate output directory

```bash
uv run python main.py standards/bca/ output/bca-markdown/
```

---

## Document Annotation — Adding Nexus Platform Analysis

After converting a PDF, annotate the generated Markdown with a **Nexus
platform analysis section** at the top. See the BCA Code of Practice as the
reference example:

```
standards/bca/code-of-practice-for-design-and-performance-of-remote-monitoring-and-diagnostics-solution-for-lifts-(final).md
```

### Required annotation structure

Insert the following block immediately after the document title (`## Document Title`):

```markdown
---

## [Agency] Perspective — Analysis for Nexus RM&D Platform

> This section is **not part of the original [Agency] document**. It is an
> analysis written for the Nexus RM&D platform team, mapping [Agency] policy
> goals to specific clauses and Nexus implementation tasks.

### 1. [Policy Goal]

**Government goal:** ...

**[Agency] levers in this document:**

| Clause | Requirement |
|--------|------------|
| §X.Y   | ...        |

**Nexus platform relevance:**
- ...

---

### N. Summary: [Agency] Requirements → Nexus Platform Mapping

| Government Goal | [Agency] Clause | Nexus Implementation |
|----------------|----------------|---------------------|
| ...            | ...            | ...                  |

---
```

### Where to cross-reference

When writing the analysis, link to concrete Nexus deliverables:

| Topic | Link in nexus-demo |
|-------|-------------------|
| Phase tasks | `PLAN_PHASES.md` (Phase numbers) |
| Architecture diagram | `PLAN_ARCHITECTURE.md` |
| Module interfaces | `PLAN_MODULES.md` |
| Data layer / KPIs | `PLAN_DATA.md` |
| Security hardening | `PLAN_PHASES.md` Phase 6 |

---

## Document Publishing — Generating Ebooks

The repository includes automation scripts to generate professional EPUB ebooks from all documentation.

### 📚 Generate Ebook (`generate-ebook.sh`)

Generates EPUB ebook from all markdown documentation in the repository.

**Features:**

- ✅ Generates professional EPUB3 format
- ✅ Excludes `standards/` folder (reference materials only)
- ✅ Excludes `AGENTS.md` (internal documentation only)
- ✅ Logical chapter ordering (README → Summaries → Architecture)
- ✅ Custom styling and formatting
- ✅ Table of contents with 3-level depth
- ✅ Syntax highlighting for code blocks
- ✅ Numbered sections

### Requirements

```bash
# macOS
brew install pandoc

# Linux
sudo apt install pandoc
```

### Usage

```bash
./scripts/generate-ebook.sh
```

### Output

File is generated in `output/` directory:

- `nexus-architecture.epub` - EPUB3 format (e-readers, tablets)

### What's Included

1. **Root Documents**
   - README.md

2. **Summary Documents** (`summary/`)
   - READING_GUIDE.md
   - ARCHITECTURE.md
   - ANALYSIS.md
   - BCA_VISION.md
   - PUB_VISION.md
   - MAP_VISION.md
   - NEA_VISION.md

3. **Architecture Documentation** (`architecture/`)
   - ARCH1_OVERVIEW.md
   - ARCH2_VENDOR_SECURITY.md
   - ARCH3_PLUGIN_API.md
   - ARCH4_DEPLOYMENT.md
   - ARCH5_INDEX.md
   - ARCH5A_OSS_SELECTION.md
   - ARCH5B_ANALYTICS_KPI.md
   - ARCH5C_ABSTRACTION.md
   - ARCH5D_TECH_STACK.md
   - ARCH6_STRATEGY.md

**What's Excluded:**

- `standards/` folder - BCA/CSA/IMDA/IEC reference documents (too large, reference only)
- `.venv/` - Python virtual environment
- `node_modules/` - Node.js dependencies
- `.git/` - Version control metadata

### Troubleshooting

**EPUB generation fails:**

Check pandoc version (should be 2.0 or higher):

```bash
pandoc --version
```

View build log:

```bash
cat output/epub-build.log
```

### Customization

Edit the script to customize:

**File Order:**

```bash
# Line ~250
ORDERED_FILES=(
    "$REPO_ROOT/README.md"
    # Add your files here
)
```

**Styling:**

```bash
# Edit the CSS section (line ~139)
cat > "$CSS_FILE" << 'EOF'
/* Your custom CSS */
EOF
```

**Metadata:**

```bash
# Edit metadata section (line ~105)
title: "Your Custom Title"
author: "Your Name"
```

---

## Naming Conventions

| Standard | Folder | Filename convention |
|----------|--------|-------------------|
| BCA documents | `standards/bca/` | kebab-case matching official title |
| IMDA documents | `standards/imda/` | `imda-{document-topic}.md` |
| CSA documents | `standards/csa/` | `csa-{document-topic}.md` |
| GovTech docs | `standards/govtech/` | `govtech-{document-topic}.md` |
| IEC standards | `standards/iec/` | `iec-{number}-{topic}.md` |

> **Do not** store original PDF files in this repository — Markdown only.
> PDFs may be stored locally or in a private S3 bucket for record purposes.

---

## Adding a New Document — Full Workflow

```bash
# 1. Convert PDF to Markdown
uv run python main.py ~/path/to/new-standard.pdf standards/<agency>/new-standard.md

# 2. Add Nexus analysis section (edit the .md file)
#    Use the BCA document as a template

# 3. Update README.md — add a link under the relevant agency section

# 4. Commit to nexus-docs
git add standards/<agency>/new-standard.md README.md
git commit -m "docs(bca): add [document name] with Nexus platform analysis"
git push origin main

# 5. Update submodule pointer in nexus-demo
cd ..   # back to nexus-demo/
git add nexus-docs
git commit -m "chore: update nexus-docs submodule — [document name]"
git push origin main
```

---

## Updating an Existing Analysis Section

When implementing a new Nexus platform feature that maps to a regulation:

1. Find the relevant clause in `standards/<agency>/<document>.md`
2. Update the **Nexus platform relevance** bullet or the **Summary table**
3. Follow the commit workflow above

Example: when Phase 6 mTLS is implemented, update the BCA doc analysis:
```
§6.3.1 Architecture — ✅ Implemented (Phase 6.1 mTLS between EdgeX and Mosquitto)
```

---

## Singapore Government Agencies Covered

| Agency | Scope | TR 91 / IEC ref |
|--------|-------|----------------|
| **BCA** | Lifts, buildings, RM&D KPIs | IEC 62443 |
| **IMDA** | IoT device cyber security (TR 91) | TR 91 |
| **CSA** | Cybersecurity Labelling Scheme (CLS) | IEC 62443-4-2 |
| **GovTech** | Zero Trust for public sector | NIST SP 800-207 |
| **IEC** | Industrial automation (OT) security | IEC 62443 series |

> All Nexus security hardening tasks (Phase 6) target **both** IMDA TR 91 and
> BCA §6 simultaneously — they share the same IEC 62443 foundation.
