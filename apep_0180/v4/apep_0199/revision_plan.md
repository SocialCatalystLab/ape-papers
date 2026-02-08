# Revision Plan: apep_0184 → apep_XXXX

## Context

apep_0184 is the #1-ranked APEP paper (rating 19.3, μ=23.5). It calculates the MVPF for unconditional cash transfers in Kenya using published RCT data. The code scan flagged it as SUSPICIOUS with two HIGH-severity methodology mismatches: (1) fiscal parameters are fixed scalars in the Monte Carlo despite the paper claiming beta-distribution uncertainty propagation, and (2) `02_clean_data.R` uses Egger et al. effects while `03_main_analysis.R` uses Haushofer & Shapiro effects for fiscal externalities.

**Parent:** apep_0184
**Goal:** Clear SUSPICIOUS code flag + sharpen prose

---

## Workstream 1: Code Integrity Fixes (Priority #1)

### 1a. Propagate fiscal parameter uncertainty in Monte Carlo
- Convert fixed `params` scalars to Beta distributions
- Draw fiscal params inside Monte Carlo loop
- Update CIs and variance decomposition

### 1b. Resolve fiscal externality data source inconsistency
- Ensure main analysis consistently uses Haushofer & Shapiro for recipient fiscal externalities
- Clean up Egger-based computation in 02_clean_data.R

### 1c. Wire sensitivity table to computed results
- Replace hard-coded MVPF values in 06_tables.R with reads from robustness_results.RData

### 1d. Parameterize spillover ratio
- Replace hard-coded 0.5 with params$spillover_ratio from study design

### 1e. Add provenance comments to transcribed effects
- Add table/page references for each value in 01_fetch_data.R

### 1f. Fix heterogeneity hard-coded base effects
- Pull base_consumption and base_earnings from haushofer_shapiro_effects

## Workstream 2: Writing Edits

### 2a. Tighten abstract
### 2b. Compress Section 2
### 2c. Fix MVPF definition repetition
### 2d. Compress Section 7.2
### 2e. Cut boilerplate heterogeneity preambles
### 2f. Tighten limitations
### 2g. Sentence-level fixes
### 2h. Update text to match code changes

## Execution Order

1. Create workspace (done)
2. Code integrity fixes (1a → 1f)
3. Re-run R pipeline
4. Writing edits (2a → 2h)
5. Compile PDF
6. Review cycle
7. Publish
