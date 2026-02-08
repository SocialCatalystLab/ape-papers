# Reply to Reviewers: Paper 110

## Summary of Reviews
- Reviewer 1: REJECT AND RESUBMIT
- Reviewer 2: REJECT AND RESUBMIT
- Reviewer 3: MAJOR REVISION

## Changes Made

### 1. CS Reframed as Primary Estimator (All 3 Reviewers)
**Concern:** Paper placed too much weight on TWFE; CS should be primary.
**Action:** Restructured the entire paper to present CS as the primary specification. Section 5 now labels TWFE as "(Benchmark)" and CS as "(Primary)." Section 6 presents CS results first (Section 6.2) and TWFE as a benchmark (Section 6.3). Abstract leads with CS ATT. Introduction paragraph now presents CS first. All framing updated throughout.

### 2. 95% Confidence Intervals Added (All 3 Reviewers)
**Concern:** TWFE tables (Tables 3, 5) missing 95% CIs.
**Action:** Added 95% CIs in brackets to Tables 3 and 5 via modelsummary's `statistic` parameter. Table notes updated to explain bracket notation. CS CIs already present in Table 4. Abstract now reports CIs for both CS and TWFE headline estimates.

### 3. Missing References Added (All 3 Reviewers)
**Concern:** Missing key methodological and domain references.
**Action:** Added 8 references to bibliography:
- Rambachan & Roth (2023) - HonestDiD
- Arkhangelsky et al. (2021) - Synthetic DiD
- Roodman et al. (2019) - Wild cluster bootstrap
- Bertrand, Duflo & Mullainathan (2004) - DiD inference
- Baker, Larcker & Wang (2022) - Staggered DiD guidance
- Gardner (2022) - Two-stage DiD
- Hansen, Miller & Weber (2020) - Cannabis taxation
All cited in appropriate locations in the text.

### 4. Pre-Trend Limitations Acknowledged (All 3 Reviewers)
**Concern:** Joint pre-trend test failed; insufficient discussion of pre-test limitations.
**Action:** Added explicit discussion of Roth (2022) pre-test caution and Rambachan & Roth (2023) sensitivity analysis in both the Empirical Strategy (Section 5.1) and Appendix B.1. Acknowledged that failing to reject pre-trends does not establish parallel trends. Noted that the largest pre-trend coefficient (0.079) is comparable to some post-treatment estimates, urging cautious interpretation. Discussed alternative approaches (collapsing leads, imputation estimators).

### 5. Spillover Robustness Added (All 3 Reviewers)
**Concern:** No spillover analysis despite cross-border effects being plausible.
**Action:** Added a border-state exclusion robustness check. Identified 9 "interior" never-treated states that do not share a border with any treated state (AL, FL, GA, HI, LA, MN, MS, NC, SC). CS ATT with interior controls = -0.042 (SE = 0.034), similar to baseline, suggesting spillovers are not driving the results. Results added to Table 6, Section 6.7, and discussed in Limitations.

### 6. Conceptual Framework Rewritten (All 3 Reviewers)
**Concern:** Section 3 too bullet-heavy, reads like notes.
**Action:** Completely rewrote Section 3 as connected prose with three subsections: Direct Effects, Indirect Effects, and Testable Implications. Replaced enumerated list with narrative prose linking mechanisms to specific BFS series predictions. Added cannabis license count benchmark (Colorado: ~2,900 licenses vs. 80,000 annual applications) to contextualize why direct positive effects may be hard to detect in aggregate data.

### 7. Magnitudes Contextualized (R1, R3)
**Concern:** Effect sizes not translated to economically meaningful units.
**Action:** Added magnitude translations throughout: CS ATT of -0.028 = ~1,250 fewer applications/year for a median state; TWFE of -0.068 = ~3,000 fewer applications. Added in introduction, main results, and TWFE sections.

### 8. Brown et al. Comparison Sharpened (R2, R3)
**Concern:** Need sharper reconciliation of BFS applications down vs. BDS establishments up.
**Action:** Expanded Discussion (Section 7.1) with three specific measurement differences: (1) establishments vs. applications, (2) formation-year vs. application-year indexing, (3) sample coverage (21 states vs. 12). Explained how later cohorts (with more positive CS ATTs) may reconcile the aggregate direction.

### 9. Data Frequency Limitation Discussed (All 3 Reviewers)
**Concern:** Annual aggregation is a major design flaw given monthly BFS and precise treatment dates.
**Action:** Added new subsection (Section 7.2) explicitly discussing the partial-year exposure problem, how it attenuates effects and makes event-time 0 non-comparable across cohorts, and how monthly re-estimation would improve identification. Added to Limitations (Section 7.3) and Conclusion. Cited Baker et al. (2022) and Gardner (2022) on practical DiD implementation.

## Changes NOT Made (With Rationale)

### Monthly re-estimation
All three reviewers recommended re-estimating at monthly frequency. This would require a complete redesign of the data pipeline, panel construction, and estimation code. While acknowledged as the highest-priority improvement for future work, it is beyond the scope of this revision.

### Wild cluster bootstrap
Package `fwildclusterboot` not available for the installed R version. The pairs cluster bootstrap already provides alternative inference.

### HonestDiD sensitivity analysis
Implementing formal Rambachan & Roth (2023) sensitivity bounds would require the HonestDiD R package and substantial additional code. Acknowledged as important future work and cited appropriately.

### Border-county design
Would require county-level BFS or alternative data (QCEW, CBP) not currently in the pipeline. Mentioned as a promising avenue for future work.

### Mechanism interaction tests
Would require additional data sources (bank density, license counts, etc.) not in the current data pipeline. Discussed as a limitation.

### Synthetic control for early adopters
Would require substantial new estimation code. Mentioned in the context of Arkhangelsky et al. (2021) citation.
