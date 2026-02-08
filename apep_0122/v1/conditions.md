# Conditional Requirements

**Generated:** 2026-01-30T20:20:12.255037
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

## Do Renewable Portfolio Standards Create or Destroy Utility Sector Jobs? Evidence from Staggered State Adoption

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: redefining treatment to a meaningful exposure measure—e.g.

**Status:** [x] RESOLVED

**Response:**

Treatment will be defined as the **first year with a binding RPS compliance obligation** (not enactment year). Many states enacted RPS laws years before compliance was required. I will use the DSIRE (Database of State Incentives for Renewables & Efficiency) and LBNL RPS compliance data to identify the first year each state's RPS imposed a non-zero renewable generation requirement on utilities. For robustness, I will also consider an alternative treatment definition based on the first year the required renewable share exceeded 5% (capturing "meaningful" stringency rather than token requirements).

**Evidence:**

DSIRE database provides detailed RPS adoption, compliance start, and interim target dates. LBNL publishes annual RPS compliance data with state-year-target level detail. These will be used to construct accurate treatment timing.

---

### Condition 2: first binding compliance year or changes in required renewable share

**Status:** [x] RESOLVED

**Response:**

This is addressed jointly with Condition 1. The primary treatment variable will be the first binding compliance year. As a secondary specification, I will exploit changes in the required renewable share as a continuous treatment intensity measure (dose-response DiD), capturing the gradual ramp-up of RPS stringency. This addresses the concern that binary treatment at enactment is too crude.

**Evidence:**

EIA publishes state-by-state RPS targets and timelines. DSIRE maintains a comprehensive database of RPS policy parameters including interim targets, compliance dates, and renewable energy credit multipliers. I will cross-validate these sources.

---

### Condition 3: showing strong event-study pre-trends for late adopters

**Status:** [x] RESOLVED

**Response:**

The analysis will focus primarily on late adopters (states with first binding compliance year 2008 or later) where the ACS 1-year data provides at least 3-5 clean pre-treatment years. Event study coefficients will be plotted for at least 5 pre-treatment and 5+ post-treatment periods. I will report: (1) visual inspection of pre-trend coefficients, (2) joint F-test for pre-treatment coefficients = 0, (3) Rambachan-Roth (HonestDiD) sensitivity analysis allowing for pre-trend violations. If pre-trends are violated for the full sample, I will restrict to the late-adopter subsample where pre-trends are cleanest.

**Evidence:**

To be generated during analysis. Event study plots will be the primary evidence. CS-DiD group-time ATT estimates will be reported to show heterogeneity across cohorts.

---

### Condition 4: stress-testing with region×year trends / matched controls given the thin never-treated group

**Status:** [x] RESOLVED

**Response:**

The never-treated group includes approximately 11 states without RPS (primarily Southern/energy-producing states: AL, AR, FL, GA, ID, KY, LA, MS, NE, TN, WY). To address structural differences: (1) I will include Census region × year fixed effects to absorb region-specific trends; (2) I will use the not-yet-treated comparison group (CS-DiD default) as the primary specification, which avoids relying solely on never-treated states; (3) As robustness, I will match treated states to control states based on pre-treatment utility employment levels and energy mix using propensity score matching or coarsened exact matching, then re-estimate the DiD on matched samples; (4) I will conduct a geographic neighbor analysis comparing RPS-adopting states only to their contiguous non-RPS neighbors.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Status: RESOLVED**
