#!/bin/bash

################################################################################
# Nexus Documentation Ebook Generator
#
# Generates EPUB ebook from all markdown files in the repository
# Excludes: standards folder, .venv, node_modules, .git, AGENTS.md
#
# Requirements:
#   - pandoc (https://pandoc.org/installing.html)
#
# Usage:
#   ./scripts/generate-ebook.sh
#
################################################################################

set -e  # Exit on error

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$REPO_ROOT/output"
METADATA_FILE="$REPO_ROOT/scripts/ebook-metadata.yaml"
CSS_FILE="$REPO_ROOT/scripts/ebook-style.css"

# Output filename
EPUB_OUTPUT="$OUTPUT_DIR/nexus-architecture.epub"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo "========================================="
    echo "$1"
    echo "========================================="
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "$1 is not installed"
        echo "Install with: $2"
        exit 1
    fi
}

################################################################################
# Pre-flight Checks
################################################################################

print_header "Pre-flight Checks"

# Check pandoc
check_command "pandoc" "brew install pandoc (macOS) or apt install pandoc (Linux)"
print_success "pandoc is installed ($(pandoc --version | head -n1))"

# Create output directory
mkdir -p "$OUTPUT_DIR"
print_success "Output directory: $OUTPUT_DIR"

################################################################################
# Create Metadata File
################################################################################

print_header "Creating Metadata"

cat > "$METADATA_FILE" << 'EOF'
---
title: "Nexus RM&D Architecture Guide"
subtitle: "Singapore National IoT Platform for Remote Monitoring & Diagnostics"
author:
  - "Smart Nation & Digital Government Office"
  - "Government Technology Agency of Singapore"
date: "2026"
lang: "en-SG"
rights: "© 2026 Government of Singapore"
description: |
  Comprehensive architecture guide for the Nexus Remote Monitoring & Diagnostics (RM&D)
  platform - Singapore's national IoT infrastructure serving Built Environment, Water,
  Maritime, and Environmental sectors.
keywords:
  - IoT
  - Remote Monitoring
  - Diagnostics
  - Singapore
  - Smart Nation
  - Architecture
  - BCA
  - NEA
  - PUB
  - MPA
---
EOF

print_success "Metadata file created"

################################################################################
# Create Custom CSS
################################################################################

cat > "$CSS_FILE" << 'EOF'
/* Nexus Documentation Ebook Styles */

body {
    font-family: "Georgia", "Times New Roman", serif;
    font-size: 12pt;
    line-height: 1.6;
    color: #333;
    max-width: 40em;
    margin: 0 auto;
    padding: 2em;
}

h1, h2, h3, h4, h5, h6 {
    font-family: "Helvetica Neue", "Arial", sans-serif;
    font-weight: 600;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
    color: #1a1a1a;
}

h1 {
    font-size: 2em;
    border-bottom: 2px solid #0066cc;
    padding-bottom: 0.3em;
}

h2 {
    font-size: 1.5em;
    border-bottom: 1px solid #ccc;
    padding-bottom: 0.2em;
}

h3 {
    font-size: 1.3em;
    color: #0066cc;
}

code {
    font-family: "Monaco", "Courier New", monospace;
    background-color: #f5f5f5;
    padding: 2px 6px;
    border-radius: 3px;
    font-size: 0.9em;
}

pre {
    background-color: #f5f5f5;
    border-left: 4px solid #0066cc;
    padding: 1em;
    overflow-x: auto;
    border-radius: 3px;
}

pre code {
    background-color: transparent;
    padding: 0;
}

blockquote {
    border-left: 4px solid #ddd;
    padding-left: 1em;
    margin-left: 0;
    font-style: italic;
    color: #666;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin: 1em 0;
}

th, td {
    border: 1px solid #ddd;
    padding: 8px 12px;
    text-align: left;
}

th {
    background-color: #f5f5f5;
    font-weight: 600;
}

a {
    color: #0066cc;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

/* Page breaks */
h1 {
    page-break-before: always;
}

h1:first-of-type {
    page-break-before: avoid;
}
EOF

print_success "CSS file created"

################################################################################
# Collect Markdown Files
################################################################################

print_header "Collecting Markdown Files"

# Define file order for logical reading
ORDERED_FILES=(
    "$REPO_ROOT/README.md"
    "$REPO_ROOT/summary/READING_GUIDE.md"
    "$REPO_ROOT/summary/ARCHITECTURE.md"
    "$REPO_ROOT/summary/ANALYSIS.md"
    "$REPO_ROOT/summary/BCA_VISION.md"
    "$REPO_ROOT/summary/PUB_VISION.md"
    "$REPO_ROOT/summary/MAP_VISION.md"
    "$REPO_ROOT/summary/NEA_VISION.md"
    "$REPO_ROOT/architecture/ARCH1_OVERVIEW.md"
    "$REPO_ROOT/architecture/ARCH2_VENDOR_SECURITY.md"
    "$REPO_ROOT/architecture/ARCH3_PLUGIN_API.md"
    "$REPO_ROOT/architecture/ARCH4_DEPLOYMENT.md"
    "$REPO_ROOT/architecture/ARCH5_INDEX.md"
    "$REPO_ROOT/architecture/ARCH5A_OSS_SELECTION.md"
    "$REPO_ROOT/architecture/ARCH5B_ANALYTICS_KPI.md"
    "$REPO_ROOT/architecture/ARCH5C_ABSTRACTION.md"
    "$REPO_ROOT/architecture/ARCH5D_TECH_STACK.md"
    "$REPO_ROOT/architecture/ARCH6_STRATEGY.md"
)

# Verify files exist and count them
FILE_COUNT=0
MISSING_FILES=()

for file in "${ORDERED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        ((FILE_COUNT++))
        echo "  ✓ $(basename "$file")"
    else
        MISSING_FILES+=("$file")
        print_warning "Missing: $file"
    fi
done

print_success "Found $FILE_COUNT markdown files"

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    print_warning "${#MISSING_FILES[@]} files not found (skipping)"
fi

################################################################################
# Generate EPUB
################################################################################

print_header "Generating EPUB"

pandoc \
    "$METADATA_FILE" \
    "${ORDERED_FILES[@]}" \
    --from=markdown+smart \
    --to=epub3 \
    --output="$EPUB_OUTPUT" \
    --toc \
    --toc-depth=3 \
    --split-level=2 \
    --css="$CSS_FILE" \
    --standalone \
    --number-sections \
    --syntax-highlighting=tango \
    --epub-metadata=<(cat << METADATA_EOF
<dc:publisher>Government Technology Agency of Singapore</dc:publisher>
<dc:type>Architecture Documentation</dc:type>
<dc:subject>IoT Architecture</dc:subject>
<dc:subject>Remote Monitoring</dc:subject>
<dc:subject>Smart Nation</dc:subject>
METADATA_EOF
) \
    2>&1 | tee "$OUTPUT_DIR/epub-build.log"

if [[ -f "$EPUB_OUTPUT" ]]; then
    EPUB_SIZE=$(du -h "$EPUB_OUTPUT" | cut -f1)
    print_success "EPUB generated: $EPUB_OUTPUT ($EPUB_SIZE)"
else
    print_error "EPUB generation failed"
    exit 1
fi

################################################################################
# Summary
################################################################################

print_header "Summary"

echo ""
echo "Generated ebook:"
echo "  📖 EPUB: $EPUB_OUTPUT"
echo ""
echo "Source files: $FILE_COUNT markdown files"
echo "Excluded:     standards/ folder, AGENTS.md, .venv/, node_modules/"
echo ""

print_success "Done!"
echo ""

################################################################################
# Cleanup prompt
################################################################################

read -p "Open output directory? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$OUTPUT_DIR"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$OUTPUT_DIR" 2>/dev/null || echo "Output: $OUTPUT_DIR"
    else
        echo "Output: $OUTPUT_DIR"
    fi
fi
