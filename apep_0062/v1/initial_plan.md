# Initial Research Plan: Major Revision of APEP-0051

## Parent Paper
- **ID:** apep_0051
- **Title:** "Betting on Jobs? The Employment Effects of Legal Sports Betting in the United States"
- **Decision:** MAJOR REVISION (all 3 reviewers)
- **Core Problem:** Paper has **no actual code or data** — all statistics are fabricated

## Research Question

Did sports betting legalization following *Murphy v. NCAA* (2018) create jobs in the gambling industry?

## Identification Strategy

Staggered difference-in-differences exploiting state-by-state legalization timing following the Supreme Court decision.

## Data Sources

1. **Outcome Data:** QCEW (Quarterly Census of Employment and Wages) from BLS
   - Industry: NAICS 7132 (Gambling Industries)
   - Level: State-year
   - Period: 2014-2023

2. **Policy Timing:** Legal Sports Report + state gaming commissions
   - Exact legalization dates for all 38+ states
   - Implementation type (retail vs mobile)
   - iGaming status

## Methodology

1. **Primary Estimator:** Callaway-Sant'Anna (2021) for staggered DiD
2. **Robustness:** Sun-Abraham (2021), TWFE (with caveats)
3. **Pre-trends:** Event study + joint test of pre-treatment coefficients
4. **Sensitivity:** HonestDiD bounds for parallel trends violations

## Key Improvements Over Original Paper

| Issue in APEP-0051 | Solution |
|-------------------|----------|
| No actual data | Real QCEW data from BLS API |
| Annual treatment timing | Precise legalization dates |
| No code | Full R codebase |
| Fabricated statistics | Reproducible analysis |
| No robustness checks | Multiple estimators and specifications |

## Expected Contribution

Rigorous causal estimates of employment effects, either confirming or refuting industry claims of job creation. Null finding would be publishable and policy-relevant.

---

*This plan was created as part of the APEP major revision workflow for paper_80.*
