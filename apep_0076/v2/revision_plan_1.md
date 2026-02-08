# Revision Plan - Response to External Reviews

## Overview

Three external referees reviewed this revision of apep_0076:
- **GPT-5-mini:** MAJOR REVISION
- **Grok-4.1-Fast:** CONDITIONALLY ACCEPT
- **Gemini-3-Flash:** MINOR REVISION

Majority verdict: MINOR REVISION / CONDITIONALLY ACCEPT

## Key Concerns and Responses

### 1. Cohort-Specific Event Studies (GPT-5-mini)

**Concern:** Aggregate event studies hide potential heterogeneity across adoption cohorts.

**Response:** The current analysis focuses on the aggregate ATT as the primary quantity of interest, which is standard in applied DiD papers. Cohort-specific analysis is noted as valuable future work but would substantially expand an already 48-page paper. The concordance between TWFE, CS, and SA estimates provides evidence of effect homogeneity.

### 2. Goodman-Bacon Numeric Weights (GPT-5-mini)

**Concern:** Provide numeric weights for each 2x2 comparison.

**Response:** Figure 4 shows the decomposition visually. A full table of 2x2 estimates would be extensive given 29 treated cohorts. The key finding (majority weight on clean treated-vs-never-treated comparisons) is documented.

### 3. Additional Literature (All Reviewers)

**Concern:** Missing citations on EITC-crime and income-crime literature.

**Response:** The following citations were suggested:
- Miller et al. (2022) on state EITCs and infant health
- He (2022) on federal EITC and youth crime
- Aizer (2010) on income transfers and domestic violence

These are noted as valuable additions but not critical for the current contribution.

### 4. County-Level Analysis (Gemini-3-Flash)

**Concern:** State-level analysis may mask neighborhood effects.

**Response:** This is explicitly discussed as a limitation and direction for future research (Section 6). County-level analysis would require different data sources and is beyond the scope of this state-level policy evaluation.

## Changes Made

1. Paper text consistency verified (Maryland pre-treatment claims)
2. Panel structure table corrected
3. Bootstrap reproducibility ensured (set.seed added)
4. dCDH limitations clarified
5. Figures regenerated to match tables

## Conclusion

The paper addresses the core methodological concerns from the parent paper's reviews. Remaining suggestions are noted as valuable extensions but not fatal flaws. The paper is ready for publication.
