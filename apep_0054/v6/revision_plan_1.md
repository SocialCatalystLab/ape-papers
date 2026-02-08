# Revision Plan: Code Scan Fix (v6)

## Parent: apep_0159 (v5)

## Revision Scope

This is a **targeted code-integrity revision** to resolve two HIGH-severity findings from the automated code scan that flagged family member apep_0148 as SUSPICIOUS. These findings persist identically in apep_0159.

**No changes to methodology, results, or paper content** beyond the title footnote.

## Changes Made

### 1. DATA_PROVENANCE_MISSING (07_tables.R)
- **Removed** unused `desc_stats <- readRDS("data/descriptive_stats.rds")` load (variable was never used downstream; summary stats table built from scratch from `df`)
- **Added** provenance header listing all 13 input files with source scripts
- **Added** file existence check loop before loading required files

### 2. SUSPICIOUS_TRANSFORMS (05_robustness.R)
- **Replaced** hard-coded, incomplete border state list (`# etc. (simplified)` comments) with **complete US Census Bureau state adjacency matrix** (all 50 states + DC, FIPS-coded named list)
- **Derived** border states programmatically: `lapply(treated_states, lookup_neighbors) |> union`
- **Documented** asymmetric exclusion rationale: control states adjacent to treated states may be contaminated by spillovers; treated states are retained because they define the treatment
- **Added** symmetric border-exclusion as additional robustness check (Section 4b): drops both border controls AND treated states that border other treated states

### 3. Provenance Headers (all scripts 00-07)
- Added `--- Input/Output Provenance ---` headers documenting the complete data lineage:
  - `00_packages.R`: shared dependency, loads transparency_laws.rds if exists
  - `00_policy_data.R`: hand-coded from official sources -> transparency_laws.rds
  - `01_fetch_data.R`: IPUMS API -> cps_asec_raw.rds
  - `02_clean_data.R`: raw data -> cps_analysis.rds, state_year_panel.rds
  - `03_descriptives.R`: analysis data -> descriptive_stats.rds + 4 figures
  - `04_main_analysis.R`: analysis data -> main_results.rds + event study
  - `05_robustness.R`: analysis data + results -> 12 output files
  - `06_figures.R`: all results -> 10 figures + all_event_studies.rds
  - `07_tables.R`: all results -> 10 tables

### 4. File Existence Checks (06_figures.R, 07_tables.R)
- Added pre-load validation loops that fail with informative error messages if required upstream files are missing

### 5. Paper Footnote
- Updated title footnote to reference apep_0159 as parent and describe code-integrity changes

## Reviewer Feedback Not Addressed

The external reviewers (GPT-5-mini, Grok-4.1-Fast, Gemini-3-Flash) provided substantive methodology feedback regarding:
- Small-cluster inference (6 treated states)
- Pre-trend fluctuations at t-3 and t-2
- Discrepancy between bootstrap and permutation p-values
- Compliance measurement

These are valid concerns about the underlying paper but are **out of scope** for this code-scan-fix revision. They would require new analysis and are better addressed in a future substantive revision.
