# Research Plan: Paper 78 (Revision of apep_0069)

## Summary

This paper is a revision of apep_0069 ("Do State Dyslexia Laws Improve Reading Achievement?"). The revision addresses four key issues identified by reviewers:

1. **Treatment timing misalignment** - Laws effective July cannot affect that year's NAEP (tested Jan-Mar)
2. **Policy bundling confounds** - MS, FL, TN, AL bundled dyslexia with comprehensive literacy reforms
3. **State mean dilutes effects** - Dyslexia targets bottom 5-10%; mean outcome dilutes effects
4. **Inference gaps** - Singular covariance, missing pretrend tests, bootstrap details

## Key Revisions

### 1. Corrected Treatment Timing

**Problem:** NAEP is administered January-March. Laws effective July cannot affect that year's NAEP.

**Solution:** Created `first_naep_exposure` variable:
- If law effective Jan-Mar → first exposure = that year's NAEP (if NAEP year)
- If law effective Apr-Dec → first exposure = NEXT NAEP cycle

This correctly maps treatment to the first outcome that could be affected.

### 2. Bundled vs. Dyslexia-Only Estimation

**Problem:** MS, FL, TN, AL adopted comprehensive literacy reform bundles, not just dyslexia screening.

**Solution:** Separate estimation:
- **Bundled reform** (MS, FL, TN, AL) + never-treated controls
- **Dyslexia-only** (all other treated) + never-treated controls

The bundled estimate measures "early literacy reform bundles"; the dyslexia-only estimate isolates screening mandate effects.

### 3. Improved Inference

- Bootstrap iterations increased to 1,000
- Simultaneous confidence bands enabled
- Formal pretrend Wald test reported
- Binned event study to handle sparse cells
- Documentation of inference approach

### 4. Expanded Paper

- Treatment classification table with all law components
- Expanded institutional background
- Discussion of bundled reform mechanisms (Mississippi's LETRS, etc.)
- Target ≥25 pages main text

## Method

Callaway-Sant'Anna (2021) staggered DiD with:
- Doubly-robust estimation
- Never-treated control group (23 states including CA 2023)
- State-clustered standard errors
- 1,000 bootstrap iterations

## Expected Results

Based on the revision plan:
- **Pooled ATT:** Near-zero (screening-only states drive toward null)
- **Bundled reform ATT:** Positive, ~3-4 NAEP points (but imprecise, N=4 states)
- **Dyslexia-only ATT:** Null or slightly negative

## Data Sources

- **NAEP:** Grade 4 Reading, 2003-2022, all 50 states
- **Treatment:** Dyslexia law effective dates from Dyslegia.com, State of Dyslexia, Education Week
- **Coding:** Effective month, policy components, bundled reform indicator

## Code Structure

```
code/
├── 00_packages.R      # Load libraries, set paths
├── 01_fetch_data.R    # Fetch NAEP, create treatment variables with corrected timing
├── 02_descriptives.R  # Summary stats, treatment classification table
├── 03_main_analysis.R # C-S estimation, bundled/dyslexia-only split
└── 04_robustness.R    # Placebo tests, heterogeneity, binned event study
```

## Timeline

1. Run 01_fetch_data.R - Fetch NAEP data, create corrected treatment timing
2. Run 02_descriptives.R - Generate summary stats and maps
3. Run 03_main_analysis.R - Main estimation, bundled/dyslexia-only split
4. Run 04_robustness.R - Robustness checks
5. Compile paper.tex - Generate PDF
6. Run external_review.py --advisor - Get review feedback
7. Iterate as needed
