# Pre-Analysis Plan: Texas Nurse Mandatory Overtime Ban and Labor Supply

**Paper ID:** paper_8
**Date:** 2026-01-17
**Status:** DRAFT (to be locked before analysis)

---

## 1. Research Question

Did Texas's 2009 mandatory nurse overtime ban (S.B. 476, effective September 1, 2009) affect nurse labor supply, hours worked, and employment?

## 2. Policy Background

**Policy:** Texas Health and Safety Code Chapter 258, enacted via S.B. 476, 81st Legislature.

**Effective Date:** September 1, 2009

**Key Provisions:**
- Prohibits hospitals from requiring nurses (RNs and LVNs) to work mandatory overtime
- Exceptions only for declared disasters or emergency situations
- Protects nurses from retaliation for refusing mandatory overtime

**Expected Effects:**
- Reduction in average hours worked per nurse (intensive margin)
- Potential increase in nurse employment as hospitals hire additional staff (extensive margin)
- Possible wage effects as overtime compensation changes

## 3. Identification Strategy

### Design: Difference-in-Differences

This is a classic 2x2 DiD design (NOT staggered adoption) because all Texas nurses were treated simultaneously on September 1, 2009.

**Treatment Group:** Nurses (RNs and LVNs) in Texas
**Control Group:** Nurses in states without mandatory overtime bans as of 2009

### Control State Selection

By 2009, approximately 15 states had introduced some form of nurse overtime restriction. For clean identification, I will use states that:
1. Had NO nurse mandatory overtime restrictions in 2007-2012
2. Are geographically proximate or economically similar to Texas
3. Have sufficient sample sizes in PUMS

**Primary Control States:**
- Florida (ST=12) - Large southern state, no overtime ban in study period
- Georgia (ST=13) - Southern state, no overtime ban in study period
- Louisiana (ST=22) - Neighboring state, no overtime ban in study period
- Oklahoma (ST=40) - Neighboring state, no overtime ban in study period
- Arizona (ST=04) - Southwestern state, no overtime ban in study period

**Robustness:** Will also test with all states that lacked overtime restrictions as controls.

### Timing

- **Pre-period:** 2007, 2008 (2 years before policy)
- **Post-period:** 2010, 2011, 2012 (2-3 years after policy)
- **Note:** 2009 ACS spans partial treatment period; will exclude or treat as transition year

### Key Assumptions

1. **Parallel Trends:** Absent the policy, Texas nurse outcomes would have evolved similarly to control states
2. **No Anticipation:** Nurses and hospitals did not substantially change behavior before September 2009
3. **No Spillovers:** The policy did not affect nurse labor markets in control states
4. **Stable Composition:** The sample of nurses is stable before and after treatment

## 4. Data

### Source
Census PUMS ACS 1-year data, 2007-2012

### Sample Definition

**Inclusion Criteria:**
- Age 21-64 (working-age adults)
- Employed as registered nurse (RN) or licensed vocational/practical nurse (LVN/LPN)
- OCCP codes: 3255 (RN), 3500 (LPN/LVN) in 2010+ coding; will verify codes for 2007-2009

**Exclusion Criteria:**
- Armed forces
- Self-employed nurses (less likely to be affected by hospital policy)

### Variables

| Variable | PUMS Code | Description | Role |
|----------|-----------|-------------|------|
| Hours worked | WKHP | Usual hours worked per week | Primary outcome |
| Employment | ESR | Employment status recode | Secondary outcome |
| Wages | WAGP | Annual wage/salary income | Secondary outcome |
| State | ST | State FIPS code | Treatment assignment |
| Occupation | OCCP | Occupation code | Sample restriction |
| Age | AGEP | Age | Covariate |
| Sex | SEX | Sex | Covariate |
| Race | RAC1P | Race | Covariate |
| Education | SCHL | Educational attainment | Covariate |
| Weight | PWGTP | Person weight | Weighting |

### Sample Size Estimates

Based on ACS sampling rates (~1% of population) and nurse workforce:
- Texas: ~15,000-20,000 nurses per year
- Control states combined: ~40,000-60,000 per year
- Total sample across 5 years (excluding 2009): ~250,000-400,000

## 5. Estimation

### Primary Specification

```
WKHP_ist = α + β₁·Texas_s + β₂·Post_t + τ·(Texas_s × Post_t) + X_ist'γ + ε_ist
```

Where:
- `WKHP_ist` = usual hours worked per week for nurse i in state s in year t
- `Texas_s` = 1 if state is Texas
- `Post_t` = 1 if year ≥ 2010
- `τ` = DiD estimate (treatment effect)
- `X_ist` = demographic controls (age, sex, race, education)

**Weighting:** All regressions weighted by PWGTP

**Standard Errors:** Clustered at state level

### Secondary Specifications

1. **Employment (extensive margin):**
   - Outcome: Employed as nurse (binary)
   - Population: All individuals with nursing occupation in any year (or nursing credentials if identifiable)

2. **Wages:**
   - Outcome: log(WAGP) conditional on employment
   - Note: May reflect composition changes if hours change

3. **Event Study:**
   - Estimate year-by-year effects relative to 2008
   - Visualize parallel trends in pre-period

### Heterogeneity Analysis

1. **By sex:** Effects may differ for female vs male nurses given caregiving responsibilities
2. **By age:** Younger vs older nurses may have different overtime preferences
3. **By nurse type:** RN vs LVN/LPN may face different overtime demands

## 6. Hypotheses

### Primary Hypothesis
**H1:** The overtime ban reduced average weekly hours worked among Texas nurses.
- **Expected sign:** Negative
- **Mechanism:** Without mandatory overtime, nurses work closer to scheduled hours

### Secondary Hypotheses
**H2:** The overtime ban increased nurse employment (extensive margin).
- **Expected sign:** Positive
- **Mechanism:** Hospitals hire additional staff to cover shifts previously filled by mandatory overtime

**H3:** The overtime ban had heterogeneous effects by nurse demographics.
- Female nurses may show larger reductions in hours if overtime disproportionately affected women
- Younger nurses may be more responsive if they have more outside options

## 7. Threats to Validity

### Parallel Trends
- **Concern:** Great Recession (2008-2009) may have differentially affected Texas vs control states
- **Check:** Event study showing pre-trends; compare recession impact across states

### Selection into Nursing
- **Concern:** Policy may attract/deter different types of workers into nursing
- **Check:** Examine composition changes in nurse demographics over time

### Compliance and Enforcement
- **Concern:** Policy may not have been fully enforced
- **Response:** This would attenuate estimates (bias toward zero), making any effects we find conservative

### Migration
- **Concern:** Nurses may move to/from Texas in response to policy
- **Check:** Examine in-migration rates among nurses

## 8. Robustness Checks

1. **Alternative control groups:**
   - All non-regulated states
   - Neighboring states only
   - Synthetic control method

2. **Alternative specifications:**
   - Including state-specific linear trends
   - Different functional forms for hours

3. **Placebo tests:**
   - Run DiD on pre-treatment period only (should find null effect)
   - Run DiD on occupations not affected by policy (e.g., physicians)

4. **Inference:**
   - Wild bootstrap clustered standard errors (given small number of clusters)
   - Permutation inference

## 9. Pre-Registration Commitment

Before looking at any outcome data, I commit to:
1. The sample definition above
2. The primary specification above
3. Reporting all pre-specified analyses regardless of results
4. Not adding specifications after seeing results without clearly labeling them as exploratory

## 10. Timeline

1. Lock this pre-analysis plan (git commit and push)
2. Fetch and clean PUMS data
3. Run analysis exactly as specified
4. Write paper
5. Verify pre-analysis integrity before publication

---

**Checksum will be generated upon locking.**
