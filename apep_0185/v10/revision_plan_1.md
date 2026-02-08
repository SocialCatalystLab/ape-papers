# Revision Plan 1: Response to External Reviews

## Paper: Friends in High Places: How Social Networks Transmit Minimum Wage Shocks
## Parent: apep_0197 → Current revision (paper_182)

## Summary of Reviewer Feedback

Both reviewers (GPT-5-mini and Grok-4.1-Fast) assigned MAJOR REVISION. Key concerns:

### Critical Issues (addressed in this revision)
1. **Pre-trend rejection (p=0.008)**: Joint F-test of pre-period event-study coefficients rejects parallel trends. Both reviewers flagged this as the most serious identification concern.
2. **Text-table consistency**: Empty tables (earnings, job flows), inconsistent sample sizes, mismatched coefficients — all resolved in this revision.
3. **Job flow narrative**: Original text claimed "reduced separations" but data shows increased separations — corrected to "churn/dynamism" interpretation.
4. **Causal language**: Tempered throughout; added explicit Identification Limitations subsection.
5. **SCI vintage concern**: Added justification for 2018 measurement in 2012-2022 panel.

### Suggestions for Future Revisions (not addressed here)
1. County-specific linear/quadratic trends in 2SLS specifications
2. Sun & Abraham interaction-weighted event-study estimates (displayed, not just mentioned)
3. Rambachan & Roth sensitivity plots (formal visualization)
4. Industry-level (high-bite vs low-bite sector) analysis
5. Extended pre-period using QCEW/BLS data before 2012
6. Additional placebo shocks beyond GDP and state employment
7. Formal mediation analysis for migration channel
8. LATE/complier characterization

## Changes Made in This Revision

### Phase 1: Weight Normalization Bug Fix
- **File**: `code/02_clean_data.R`
- Re-normalized SCI weights after NA filtering so exposure measures cannot fall below log($7.25) = 1.981
- Validation: 0% of observations below theoretical floor (was 20% in parent paper)
- USD exposure range: [$7.25, $13.56], mean $7.99, SD $0.96

### Phase 2: Job Flow Data Integration
- **Files**: `code/01_fetch_data.R`, separate fetch script
- Fixed QWI API variable name: FrmJbD → FrmJbLs (correct Census name)
- Fetched 103,060 county-quarter observations with HirA, Sep, FrmJbC, FrmJbLs
- Coverage: 75% for hires/separations, 39% for firm job creation

### Phase 3: Earnings as Co-Primary Outcome
- **Files**: `code/03_main_analysis.R`, `paper.tex`
- Earnings 2SLS: β=0.319 (SE=0.063, p<0.001) — now highly significant
- Added earnings table (tab:main_earnings) with OLS and 2SLS results

### Phase 4: USD-Denominated Specifications
- **Files**: `code/03_main_analysis.R`, `paper.tex`
- Employment: $1 increase in network avg MW → 9.0% employment (β=0.0902)
- Earnings: $1 increase → 3.5% earnings (β=0.0345)

### Phase 5: Job Flow Mechanism Analysis
- **Files**: `code/04d_job_flows.R`, `paper.tex`
- Key finding: BOTH hires and separations increase significantly
- Interpretation: labor market churn/dynamism, not simple matching improvement
- Net job creation: null (p=0.93)

### Phase 6: Text-Table Consistency (Advisor Review Fixes)
- Populated empty earnings and job flow tables with actual regression coefficients
- Corrected sample sizes throughout (135,700 obs, 3,108 counties)
- Fixed prob-weighted coefficient in shock-robust table (0.28 → 0.323)
- Updated correlation between exposure measures (0.87 → 0.96)
- Corrected panel balance claim (nearly balanced, not fully balanced)
- Added F-stat definition (Cragg-Donald Wald F from fixest::fitstat)

### Phase 7: Pre-Trend Honesty
- Computed formal joint F-test: F(4,50) = 3.90, p = 0.008
- Updated ALL references to pre-trend evidence to honestly report rejection
- Added Identification Limitations subsection listing all concerns
- Tempered causal language throughout abstract, intro, and conclusion

### Phase 8: Causal Language Tempering
- Changed "causally shifts" → "IV evidence consistent with shifting"
- Added pre-trend caveat to abstract and introduction
- Added explicit limitations paragraph to Discussion section
- Qualified conclusion: "suggestive of causal effects under maintained assumptions"
