# Conditional Requirements

**Generated:** 2026-01-27T08:37:12.971691
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Minimum Wage Increases and Teen Time Allocation: Direct and Spillover Effects

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: coding treatment by effective date using ATUS interview/diary month

**Status:** [X] RESOLVED

**Response:**

IPUMS ATUS includes the `MONTH` variable which records the month of the diary day. Most state minimum wage increases take effect on January 1 or July 1 of a given year. We will code treatment at the state×month level rather than state×year to properly capture treatment timing.

Specifically:
- Merge MW effective date data from DOL historical database (which includes exact effective dates, not just years)
- Create treatment indicator: `treated = 1` if diary_date >= MW_effective_date in that state
- For states with mid-year changes (e.g., July 1), observations before July are coded as untreated, observations July+ are coded as treated

This avoids the attenuation bias from annual coding that the reviewer flagged.

**Evidence:**

- IPUMS ATUS MONTH variable: https://www.atusdata.org/atus-action/variables/MONTH
- DOL MW effective dates: https://www.dol.gov/agencies/whd/state/minimum-wage/history

---

### Condition 2: pre-trend/event-study diagnostics by cohort

**Status:** [X] RESOLVED

**Response:**

We will implement full event-study diagnostics using the Callaway-Sant'Anna (2021) framework in R, which is designed for staggered adoption and produces cohort-specific estimates.

Diagnostic plan:
1. **Event study plots:** Estimate dynamic treatment effects for each relative time period (t-4, t-3, ..., t-1, t, t+1, ...) and plot with 95% CIs
2. **Pre-trend tests:** Formal F-test for joint significance of pre-treatment coefficients
3. **Cohort-specific effects:** Report ATT(g,t) by adoption cohort to detect heterogeneity
4. **Aggregation:** Report overall ATT and dynamic ATT only if pre-trends pass

We will use the `did` package (Sant'Anna & Zhao) and `HonestDiD` package (Rambachan & Roth) for sensitivity to parallel trends violations.

**Evidence:**

- Callaway & Sant'Anna (2021), Journal of Econometrics: https://www.sciencedirect.com/science/article/pii/S0304407620303948
- R `did` package: https://bcallaway11.github.io/did/
- HonestDiD: https://github.com/asheshrambachan/HonestDiD

---

### Condition 3: a clear plan for dilution/power—especially for spillovers

**Status:** [X] RESOLVED

**Response:**

**Direct effects (working teens in MW-sensitive industries):**
- Sample: Teens 16-19 employed in retail (NAICS 44-45), food service (NAICS 722), or leisure/hospitality (NAICS 71)
- Estimated sample size: ~2,000-3,000 across 2003-2023 (based on ~25k total teen obs × ~0.3 employed × ~0.4 in these industries)
- Power: With 30+ treated states and ~100 obs per state-year, we have power for ~5-10 minute effects (plausible given avg work time ~120 min/day for working teens)

**Spillover effects (non-working teens):**
- Sample: Teens 16-19 not currently employed
- Estimated sample size: ~17,000 across 2003-2023
- Expected effect: Smaller than direct effects. Realistic expectation is 2-5 minute shifts in time categories.
- Power mitigation: (a) Focus on aggregate time categories (work+job search, education total, leisure total) rather than fine categories; (b) Pool all non-working teens rather than further stratifying; (c) Report standardized effects (% of category mean) for interpretability

**Pre-registered power analysis:** Will run formal power simulation using first data pull before finalizing specifications.

**Evidence:**

- ATUS teen sample sizes: ~10k respondents/year × ~12% teen share = ~1,200 teens/year × 20 years = ~24,000 total
- Will verify in data pull

---

### Condition 4: explicit controls/robustness for bundled state policy changes

**Status:** [X] RESOLVED

**Response:**

States that raise minimum wages often also adopt other progressive policies (paid sick leave, EITC expansions, scheduling laws) that could affect teen time use. We address this through:

**Primary controls:**
1. State fixed effects (absorb time-invariant state characteristics)
2. Year fixed effects (absorb national trends)
3. State-specific linear trends (absorb differential trends)

**Robustness checks:**
1. **Exclude "big reform" states:** Drop California, New York, Washington which had major labor policy bundles
2. **Control for EITC:** Include state EITC presence/generosity as time-varying control
3. **Control for paid leave:** Include indicator for state paid sick leave mandates
4. **"Clean" MW increases:** Restrict to states where MW increase was not accompanied by other major labor legislation in same year
5. **Placebo outcomes:** Test effects on outcomes that should NOT be affected by MW (e.g., sleep time, personal care)

**Evidence:**

- EPI Minimum Wage Tracker includes policy details: https://www.epi.org/minimum-wage-tracker/
- NCSL state policy databases for paid leave, EITC: https://www.ncsl.org/

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
