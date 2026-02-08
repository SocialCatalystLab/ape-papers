# Revision Plan

**Paper:** Does Federal Transit Funding Improve Local Labor Markets?
**Parent:** apep_0129
**Date:** 2026-02-03

---

## Overview

This revision addresses two categories of issues: (1) code integrity problems flagged in the parent paper's scan, and (2) content tightening to sharpen the contribution for AER-level submission.

---

## Code Integrity Fixes (Priority 1)

### Issue 1: Hard-coded funding value in first-stage figure
**File:** `code/05_first_stage_figure.R`
**Problem:** Line used hard-coded `$40` per capita instead of computing from FTA formula
**Fix:** Replace with formula-based calculation using actual Section 5307 apportionment structure:
```r
calculate_5307_funding <- function(population, density_per_sq_mi = 2500) {
  if (population < 50000) return(0)
  base_rate <- 32
  density_factor <- 1 + 0.15 * min(1, density_per_sq_mi / 4000)
  per_capita <- base_rate * density_factor
  total <- population * per_capita
  return(total)
}
```

### Issue 2: Missing data provenance
**File:** `code/02_fetch_ua_characteristics.R`
**Problem:** `ua_population_2020.csv` appeared without documented source
**Fix:** Add Census API call to fetch 2020 population data with full provenance documentation

### Issue 3: Sample selection documentation
**File:** `code/01_fetch_data.R`
**Problem:** Observations dropped for missing ACS outcomes could appear as outcome-based selection
**Fix:** Add documentation explaining drops are due to ACS publication thresholds (small population areas), not outcome values

---

## Content Improvements (Priority 2)

### Abstract
- **Before:** 275 words, lists every outcome with p-values
- **After:** ~150 words, leads with precise null finding, states policy implication

### Introduction
- **Before:** Opens with general motivation, buries contribution in paragraph 4
- **After:** First paragraph states what paper does, why it matters, what it finds

### Section 2 (Institutional Background)
- **Before:** 4 subsections, 7 pages
- **After:** Merged subsections 2.1/2.2, cut subsection 2.4 by half

### Section 3 (Literature)
- **Before:** Comprehensive coverage of all related areas
- **After:** Focus on papers directly informing empirical strategy or interpretation

### Section 6 (Discussion)
- **Before:** 5 mechanisms, causal chain analysis, power discussion, literature comparison
- **After:** Single clear explanation (funding too small), one supporting calculation

---

## Verification

After implementing changes:
1. Compile PDF, verify 25+ pages main text
2. Run all R scripts to regenerate figures
3. Run advisor review (4 must PASS)
4. Run external review (tri-model)
5. Publish with `--parent apep_0129`
