# Human Initialization
Timestamp: 2026-02-04T12:00:00Z

## Contributor (Immutable)

**GitHub User:** @ai1scl

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Revision Information

**Parent Paper:** apep_0153
**Parent Title:** Does the Safety Net Bite Back? Medicaid Postpartum Coverage Extensions Through the Public Health Emergency and Beyond (v2)
**Parent Decision:** MAJOR REVISION (advisor/reviewer feedback)
**Revision Rationale:** Fix three fatal internal consistency errors (Table/Figure uninsured ATT mismatch, narrative contradiction calling significant post-PHE result "null", DDD CS-DiD text-table sign mismatch). Add permutation inference, 2024-only post-period specification, attenuation bias quantification, DDD pre-trend event study, HonestDiD sensitivity figure, cluster counts in all tables. Add missing references. Tighten prose.

## Key Changes Planned

### Priority 1: Fatal Error Fixes
1. Reconcile Table 3 Uninsured ATT = 0.0257 with Figure 2 event-study CIs overlapping zero (add explanatory note about aggregation mechanics)
2. Rewrite narrative: post-PHE Medicaid ATT of -2.18pp is statistically significant negative, not "null". Frame DDD as specification that isolates postpartum-specific effect after removing unwinding confound
3. Fix DDD CS-DiD text-table mismatch: text says +1.0pp, table shows -0.0107 (-1.1pp). Verify actual estimate, update consistently

### Priority 2: Reviewer Concerns
1. Permutation/randomization inference (500 permutations, empirical null distribution)
2. 2024-only post-period as primary robustness (exclude mixed 2023)
3. Attenuation bias quantification (ITT scaling factor under uniform birth-month distribution)
4. DDD pre-trend event study figure
5. Cluster counts in all regression tables
6. HonestDiD sensitivity figure (CI width vs M-bar)
7. Missing references: Conley & Taber (2011), MacKinnon & Webb (2017), Abadie et al. (2010)
8. Prose tightening: condense intro, add roadmap, segregate findings from speculation

### Priority 3: Code Improvements
- Ensure all scripts run end-to-end
- set.seed() for new bootstrap/permutation procedures
- New analysis sections in 04_robustness.R, 05_figures.R

## Inherited from Parent

- Research question: Effect of Medicaid postpartum coverage extensions on insurance outcomes
- Identification strategy: Staggered DiD (CS-DiD) with DDD design
- Primary data source: ACS 1-year PUMS 2017-2024 (Census Bureau API)
- All data files from apep_0153

## Setup Results

- **Domain:** Health & public health
- **Method:** DiD + DDD
- **Data era:** Modern (2017-2024)
- **Risk appetite:** Novel angle
- **Other preferences:** none
