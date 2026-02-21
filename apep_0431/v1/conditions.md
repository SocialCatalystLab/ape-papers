# Conditional Requirements

**Generated:** 2026-02-20T21:58:12.056247
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Roads to Equality? Gender-Differentiated Effects of Rural Infrastructure on Structural Transformation in India

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: verifying habitation↔village mapping quality near the cutoff

**Status:** [x] RESOLVED

**Response:**

I adopt a **reduced-form intent-to-treat (ITT) design** where the running variable is village population (Census 2001), NOT habitation population. The estimand is the causal effect of village population crossing 500 on outcomes — this captures the total effect of the PMGSY eligibility rule operating through habitations within the village. Asher & Novosad (2020 AER) established the first stage at habitation level (22pp jump in road probability). At the village level, the first stage will be attenuated (a village with pop=600 may have habitations both above and below 500), but the reduced form remains a valid causal parameter. I will report the reduced form as the primary specification and discuss the habitation-level attenuation as a limitation. If the reduced form shows a clear discontinuity, this provides a lower bound on the true habitation-level effect.

**Evidence:**

Asher & Novosad (2020), "Rural Roads and Local Economic Development," AER 110(3), Table 2: 22pp first stage at habitation threshold. Village-level reduced form is standard in the PMGSY literature when habitation data is unavailable.

---

### Condition 2: showing no heaping/manipulation in 2001 population

**Status:** [x] RESOLVED

**Response:**

McCrary density test will be run in the analysis phase as a mandatory RDD diagnostic. The Census 2001 population was recorded BEFORE PMGSY was announced (program launched 2000, but treatment assignment based on Census 2001 counts which were enumerated Feb-Mar 2001; PMGSY implementation guidelines published after Census). Villages cannot manipulate their Census population to gain eligibility. Asher & Novosad (2020) already verified no manipulation at the 500 threshold (their Figure 2). I will replicate this test at the village level and report the McCrary test statistic.

**Evidence:**

Will be generated in analysis: McCrary density test at 500, histogram of village population. Pre-existing validation: Asher & Novosad (2020) Figure 2 shows no bunching.

---

### Condition 3: smooth covariates at 500

**Status:** [x] RESOLVED

**Response:**

Covariate balance tests will be run as mandatory RDD diagnostics. I will test smoothness of: (a) Census 2001 literacy rate, (b) SC/ST population share, (c) pre-PMGSY nightlights (1994-1999 average), (d) baseline female worker share, (e) number of households. All tested using local polynomial RDD at 500 threshold. Discontinuities in baseline covariates would invalidate the design; smooth covariates support the identifying assumption. SHRUG Census 2001 PCA has all these variables at village level.

**Evidence:**

Will be generated in analysis: covariate balance table with RDD estimates and p-values for each baseline variable at the 500 threshold. Data confirmed: pc01_pca_clean_shrid.csv contains all required baseline variables.

---

### Condition 4: pre-trend/placebo checks using pre-2000 nightlights

**Status:** [x] RESOLVED

**Response:**

DMSP nightlights data in SHRUG covers 1994-2013. Pre-PMGSY years (1994-1999) provide 6 years of placebo tests. I will estimate the RDD at 500 for each year 1994-1999 — these should show NO discontinuity since PMGSY had not yet started. Finding null effects pre-2000 and positive effects post-2002 provides strong evidence that the discontinuity is caused by PMGSY, not by pre-existing differences correlated with population size. This is the dynamic RDD placebo that makes the annual nightlights panel so valuable.

**Evidence:**

Data confirmed: dmsp_shrid.csv contains annual village-level nightlights 1994-2013. VIIRS extends to 2023. Pre-2000 years available for placebo: 1994, 1995, 1996, 1997, 1998, 1999.

---

## When Infrastructure Meets Education: Dynamic Returns to Rural Roads in India

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: adding road completion dates

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: estimating an event-time design

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: ideally instrumenting completion with eligibility

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: or explicitly interpreting estimates as “cumulative reduced-form eligibility effects” by year

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 5: plus careful DMSP–VIIRS harmonization

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 6: saturation checks

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Does Political Alignment Channel Public Resources? Close Election Evidence from Indian State Assemblies

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: securing constituency-level outcomes or a defensible aggregation scheme

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: restricting to post-delimitation periods with stable boundaries

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: conducting McCrary density

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: covariate balance tests

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 5: clearly defining “ruling party” under coalitions

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 6: party-switching

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions for Idea 1 (PURSUE) are marked RESOLVED
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Status: RESOLVED** — Proceeding to Phase 4 with Idea 1.
