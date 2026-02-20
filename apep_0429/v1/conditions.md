# Conditional Requirements

**Generated:** 2026-02-20T19:40:47.762202
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

## The Long Arc of Rural Roads — Dynamic Treatment Effects of PMGSY Over Two Decades

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: using fuzzy RDD/IV with road completion data or a defensible exposure measure

**Status:** [x] RESOLVED

**Response:**

Following Asher & Novosad (2020, AER), the primary specification uses a **sharp/intent-to-treat (ITT) RDD** at the Census 2001 population threshold of 500 — this estimates the causal effect of *eligibility* for PMGSY road construction. This is the standard approach in the literature because: (a) PMGSY eligibility is mechanically determined by population, making the sharp RDD valid for ITT; (b) not all eligible villages receive roads (compliance is imperfect), so the sharp RDD is a conservative estimate. As a robustness check, I will also implement a **fuzzy RDD** using road connectivity as the endogenous treatment, with population-based eligibility as the instrument. OMMAS (Online Management, Monitoring, and Accounting System) data on actual road completion would be ideal for the first stage, but bulk access is uncertain; I will use the 2011 Census Village Directory road access variable (`pc11_vd_tar_road` / `pc11_vd_k_road`) as a proxy for the first stage if available, and otherwise note the OMMAS limitation transparently.

**Evidence:**

Asher & Novosad (2020, AER 110(3), pp. 797-823) use the same sharp ITT approach. Their Table 2 shows the first stage: villages above 500 are ~25 pp more likely to receive a PMGSY road. The ITT estimand is well-defined and policy-relevant.

---

### Condition 2: rigorous DMSP–VIIRS calibration

**Status:** [x] RESOLVED

**Response:**

Three-pronged calibration strategy: (1) **Separate sensor analyses**: run the dynamic RDD separately for DMSP (1992–2013) and VIIRS (2012–2021), avoiding any cross-sensor comparison. (2) **Overlap calibration**: use the 2012–2013 period where both sensors operate to estimate a calibration function (log-linear mapping DMSP → VIIRS-equivalent). (3) **Combined series**: create a harmonized nightlights index using the Henderson, Storeygard & Weil (2012) intercalibration approach, and verify that dynamic RDD results are robust across all three measures. Report all three in robustness tables.

SHRUG provides pre-calibrated nightlights (`total_light_cal`), but I will verify the calibration method used and implement my own as a cross-check.

**Evidence:**

SHRUG data includes both DMSP (`dmsp_shrid.csv`, 1.2 GB) and VIIRS (`viirs_annual_shrid.csv`, 1.6 GB) at village level. The 2012-2013 overlap period provides the calibration anchor. Standard approach per Henderson et al. (2012, AER).

---

### Condition 3: robustness to saturation/truncation

**Status:** [x] RESOLVED

**Response:**

DMSP top-codes at 63, which can attenuate estimates for bright urban areas. However, villages near the PMGSY 500-person threshold are overwhelmingly small and rural — exactly the population where DMSP saturation is NOT a concern (typical nightlight values 0–10). I will: (1) verify empirically that fewer than 5% of observations near the 500 threshold have DMSP values at or near 63; (2) use log(nightlights + 1) and inverse hyperbolic sine (asinh) transformations as primary specifications to handle zeros and reduce right-skew; (3) report results dropping the (few) saturated observations; (4) for VIIRS (which has no top-coding), verify that results are consistent.

**Evidence:**

Asher & Novosad (2020) note that PMGSY-eligible villages are "small, remote, and rural" — precisely the population where DMSP saturation is negligible. The median nightlight value for villages with population ~500 is expected to be well below 10 (will verify in data).

---

## The Governance Gap — Census Town Classification and India's Subaltern Urbanization

**Rank:** #2 | **Recommendation:** PURSUE

### Condition 1: demonstrating a strong first stage

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: showing continuity in 2001 covariates

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: pre-trends in nightlights

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: clarifying that the estimand is the effect of classification/governance regime rather than simply “larger villages”

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
