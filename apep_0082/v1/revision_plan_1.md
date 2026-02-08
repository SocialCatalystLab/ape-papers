# Revision Plan: Paper 110

## Review Summary
- **Reviewer 1:** REJECT AND RESUBMIT
- **Reviewer 2:** REJECT AND RESUBMIT
- **Reviewer 3:** MAJOR REVISION

## Consolidated Feedback (Grouped by Theme)

### 1. Annual Aggregation (All 3 reviewers — CANNOT address)
All reviewers flagged that BFS is monthly but the analysis uses annual data, introducing treatment misclassification. This would require a complete redesign of the analysis pipeline. **Will acknowledge explicitly as limitation but not re-estimate.**

### 2. Missing 95% CIs in TWFE Tables (All 3 — WILL FIX)
Tables 3 and 5 show SEs and stars but not 95% CIs. Will add CIs to key estimates.

### 3. CS Should Be Primary, TWFE Benchmark (All 3 — WILL FIX)
Paper gives too much prominence to TWFE. Will restructure results narrative to lead with CS.

### 4. Missing References (All 3 — WILL FIX)
Add: Rambachan & Roth (2023), Roth (2022) [already present as roth2023pretest], Arkhangelsky et al. (2021), Roodman et al. (2019), Bertrand/Duflo/Mullainathan (2004), Baker/Larcker/Wang (2022), Gardner (2022), Hansen/Miller/Weber (2020).

### 5. Pre-Trend Limitations (All 3 — WILL FIX)
Joint test failed due to singular covariance. Will cite Roth (2022) explicitly, discuss power limitations of pre-trend tests, and acknowledge need for HonestDiD-style sensitivity.

### 6. Conceptual Framework Too Bullet-Heavy (All 3 — WILL FIX)
Section 3 reads like notes. Will rewrite as connected prose with testable implications.

### 7. Spillovers Not Addressed (All 3 — WILL PARTIALLY ADDRESS)
Add robustness check excluding states bordering treated states. Add discussion of spillover concern.

### 8. Wild Cluster Bootstrap (R2, R3 — WILL TRY)
Add fwildclusterboot results if package available.

### 9. Mechanisms Underdeveloped (All 3 — WILL PARTIALLY ADDRESS)
Cannot add new data sources, but will:
- Contextualize magnitudes (translate to counts for median state)
- Discuss cannabis license counts as share of total applications
- Sharpen the "quality upgrade" discussion

### 10. Contextualize Magnitudes (R1, R3 — WILL FIX)
Translate percentage effects to application counts for interpretability.

### 11. Reconcile with Brown et al. (R2, R3 — WILL FIX)
Add sharper comparison of BFS vs BDS measurement and why signs differ.

## Execution Plan

### Phase 1: R Code Updates
1. Modify `06_tables.R`: Add 95% CIs to Table 3 (TWFE main results)
2. Modify `04_robustness.R`: Add border-state exclusion robustness check
3. Modify `04_robustness.R`: Try wild cluster bootstrap (fwildclusterboot)
4. Re-run R scripts and regenerate tables

### Phase 2: References
1. Add 6-8 missing BibTeX entries to `references.bib`

### Phase 3: Paper Text
1. Rewrite Section 3 (Conceptual Framework) as connected prose
2. Restructure Section 6 to lead with CS, TWFE as benchmark
3. Add magnitude contextualization throughout
4. Expand pre-trends discussion citing Roth (2022)
5. Add spillover discussion and robustness results
6. Sharpen Brown et al. comparison
7. Acknowledge monthly aggregation limitation explicitly
8. Add wild cluster bootstrap results (if successful)

### Phase 4: Compile & QA
1. Recompile PDF
2. Visual QA
3. Write reply_to_reviewers.md
