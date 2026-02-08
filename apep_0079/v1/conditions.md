# Conditional Requirements

**Generated:** 2026-01-28T20:55:44.061382
**Status:** RESOLVED

---

## ⚠️ CONDITIONS ADDRESSED FOR PHASE 4 (EXECUTION)

The ranking identified conditional requirements for Idea 1 (Universal Free School Meals → Household Food Security).
All conditions below have been addressed.

---

## Universal Free School Meals and Household Food Security (Idea 1)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: Primary sample restricted to households with school-age children

**Status:** [x] RESOLVED

**Response:**
Analysis will be restricted to CPS households containing at least one child aged 5-17 (school-age). This ensures the treatment population is actually exposed to universal school meals. Will also examine heterogeneity by:
- Number of children in household
- Age composition (elementary vs. middle/high school)
- Low-income households (below 200% FPL) where freed resources matter most

**Evidence:**
CPS-FSS includes household roster with ages of all members (AGE variable). Can identify households with children 5-17 using standard IPUMS filters.

---

### Condition 2: Explicitly code/control for P-EBT and SNAP emergency allotment phaseouts

**Status:** [x] RESOLVED

**Response:**
Will construct state-year controls for:
1. **P-EBT continuation** - Some states continued P-EBT after federal program ended (2022-2023)
2. **SNAP Emergency Allotments** - Federal EA ended in phases by state (Feb-Mar 2023)
3. **State SNAP supplements** - Some states added own SNAP benefits

These will be included as time-varying controls or used for heterogeneity analysis.

**Evidence:**
- USDA tracking of SNAP EA end dates by state: https://www.fns.usda.gov/snap/covid-19-emergency-allotments-guidance
- P-EBT implementation tracker from USDA FNS
- Will code state-month EA/P-EBT status and aggregate to survey year

---

### Condition 3: Inference plan suited to 9 clusters (randomization inference/wild bootstrap)

**Status:** [x] RESOLVED

**Response:**
Given only 9 treated states, standard cluster-robust SEs are unreliable. Will implement:
1. **Wild cluster bootstrap** - Using `fwildclusterboot` R package with 9999 replications
2. **Randomization inference** - Permute treatment assignment across states, compute RI p-values
3. **Callaway-Sant'Anna with bootstrap** - The `did` package supports clustered bootstrap SEs

Will report conventional SEs alongside WCB and RI p-values for transparency.

**Evidence:**
MacKinnon & Webb (2018) recommend wild bootstrap with <30 clusters. Conley & Taber (2011) for small-cluster inference. `fwildclusterboot` and `did` packages in R implement these methods.

---

### Condition 4: Pre-trend/event-study evidence shown transparently

**Status:** [x] RESOLVED

**Response:**
Will produce event-study figures showing:
1. **Dynamic treatment effects** - Coefficients for each relative year (-4 to +2)
2. **Pre-trend test** - Joint F-test that pre-treatment coefficients = 0
3. **HonestDiD sensitivity analysis** - Bounds allowing for differential trends

Event-study will be a main exhibit in the paper, not relegated to appendix.

**Evidence:**
Will use `did` package's group-time ATT estimates aggregated to event-time using `aggte(., type = "dynamic")`. Will implement Roth's HonestDiD bounds.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED
- [x] Evidence is provided for each resolution
- [x] This file will be committed to git

**Status at top of file: RESOLVED**
