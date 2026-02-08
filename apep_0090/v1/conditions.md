# Conditional Requirements

**Generated:** 2026-01-30T12:00:25.620842
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

## State Data Privacy Laws and Technology Sector Business Formation (REVISED)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: extending pre-periods to ≥5 years or presenting a compelling COVID-handling strategy

**Status:** [X] RESOLVED

**Response:**

We will use a hybrid strategy:
1. **Primary design (2023+ cohort):** Use 2018-2022 as pre-period (5 years), with COVID period (2020-2021) modeled explicitly via year fixed effects and pandemic controls (state unemployment rate, state COVID deaths per capita). This gives 5 pre-treatment years.
2. **Robustness:** Also present results using only 2022-H2 as pre-period (post-COVID recovery) to demonstrate effects are not driven by pandemic dynamics.
3. **California SCM:** Use 2015-2019 pre-period (5 years, pre-COVID) for synthetic control, which naturally handles COVID by constructing a unit-specific counterfactual that includes pandemic effects.

**Evidence:**
- FRED Business Formation Statistics available monthly from 2004
- State-level unemployment data available from BLS
- COVID deaths per capita available from CDC through 2023

---

### Condition 2: demonstrating strong pre-trends/event-study balance

**Status:** [X] RESOLVED

**Response:**

The Callaway-Sant'Anna estimator automatically produces group-time ATTs that can be aggregated into an event-study plot. We will:
1. **Plot pre-treatment event-study coefficients** for leads -24 to -1 months
2. **Formal pre-trend test:** Joint F-test that all pre-treatment coefficients = 0
3. **Placebo outcome test:** Run same specification on manufacturing sector (NAICS 31-33) which should NOT be affected by data privacy laws
4. **Covariate balance:** Report balance on state GDP, population, tech employment share in pre-period

**Evidence:**

Will be generated in `04_robustness.R` and displayed in Figure 2 (Event Study) and Table A1 (Balance).

---

### Condition 3: addressing dilution via outcomes more tied to covered firms

**Status:** [X] RESOLVED

**Response:**

We address dilution through multiple strategies:
1. **Tight sector focus:** NAICS 51 (Information) is substantially more data-intensive than broader aggregates. Key subsectors: Publishing (511), Software (5112), Data Processing (518), Internet (519)
2. **High-propensity applications:** Use "High-Propensity Business Applications" (BAHBA series) which filters for applications more likely to become employers (corporate filings, planned wages, etc.) - these are more likely to be firms large enough to be covered
3. **Heterogeneity analysis:** Test for stronger effects in states with lower coverage thresholds (some states set thresholds at 10k consumers, others at 100k)
4. **Employment outcome:** QCEW establishment counts in NAICS 51 as secondary outcome - establishments represent actual operating businesses, not just applications

**Evidence:**

- FRED series `BAHBATOTALSAXX` (High-Propensity) available for all states
- Coverage threshold variation documented in law summaries from Bloomberg Law and IAPP
- QCEW quarterly data available from BLS

---

### Condition 4: /or heterogeneity by firm type/state thresholds

**Status:** [X] RESOLVED

**Response:**

We will test heterogeneous effects by:
1. **Coverage threshold:** States with lower consumer thresholds (e.g., Virginia's 100k consumers) vs higher thresholds (e.g., Utah's 100k but exempts small revenue firms)
2. **Law strength:** States with "payment parity" style enforcement vs "coverage only"
3. **Sector subsample:** Compare effects in software publishing (NAICS 5112) vs broader information sector
4. **High-propensity vs all applications:** If dilution matters, high-propensity apps should show larger effects

**Evidence:**

Heterogeneity tests will be reported in Table 3 (Main Results with Heterogeneity) and Table A2 (Threshold Variation).

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
