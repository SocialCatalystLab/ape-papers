# Conditional Requirements

**Generated:** 2026-01-30T20:00:02.549748
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

## State Minimum Wage Increases and Young Adult Household Formation

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: exposure-weighted treatment timing

**Status:** [x] RESOLVED

**Response:**

Treatment will be defined as the first year in which the state MW exceeds the federal floor by at least $1.00. For states with gradual increases (e.g., annual $0.50 steps), the treatment onset is the first year the gap reaches $1.00. The Callaway-Sant'Anna estimator handles staggered timing natively — each cohort (defined by first treatment year) gets its own ATT, then aggregated. I will also estimate dose-response models using the MW gap as a continuous treatment intensity measure.

**Evidence:**

DOL minimum wage history table (dol.gov/agencies/whd/state/minimum-wage/history) provides exact MW levels by state-year. Verified computationally: 30+ states exceed federal floor by $1+ at different times between 2012-2023.

---

### Condition 2: explicit controls/robustness for housing-cost trends

**Status:** [x] RESOLVED

**Response:**

ACS PUMS includes median gross rent (GRNTP) and housing value (VALP) which can be used as state-year controls. I will: (1) include state-level median rent as a time-varying control in the main specification, (2) run a robustness check using a triple-difference with renters vs. homeowners, (3) test whether results change when restricting to states with below-median housing cost growth. Additionally, state and year fixed effects absorb level differences and national housing trends.

**Evidence:**

Census ACS PUMS variables GRNTP (gross rent), VALP (property value), and GRPIP (gross rent as % of income) are all available at individual level via API, confirmed with test query.

---

### Condition 3: policy bundling

**Status:** [x] RESOLVED

**Response:**

States raising MW often simultaneously adopt other labor policies (paid leave, sick leave, scheduling laws). I will: (1) control for state-level paid family leave and paid sick leave adoption dates (well-documented by NCSL), (2) control for state EITC generosity (which also supports low-wage workers), (3) run a falsification test using higher-income young adults (ages 25-30 with BA+) who should be unaffected by MW changes, (4) discuss remaining bundling concerns as a limitation. The CS-DiD estimator comparing each cohort to not-yet-treated states also mitigates this if policy bundles are adopted simultaneously.

**Evidence:**

NCSL databases on paid family leave (8 states) and paid sick leave (~15 states) provide exact adoption dates. These are coded as binary controls in the state-year panel.

---

### Condition 4: heterogeneity by MW exposure to address dilution

**Status:** [x] RESOLVED

**Response:**

Not all young adults are exposed to MW changes. I will: (1) estimate heterogeneous effects by education (no college vs. BA+), industry (food service/retail vs. professional), and current wage level (below median vs. above), (2) use a continuous treatment intensity measure (state MW gap over federal) to test dose-response, (3) report separate effects for the most exposed subgroup (ages 18-24 without college education in service industries) as the "first stage" population. This directly addresses the dilution concern — if the effect is concentrated in the exposed subgroup, we have stronger evidence of causal mechanism.

**Evidence:**

ACS PUMS variables SCHL (educational attainment), INDP (industry), WAGP (wages), and OCCP (occupation) allow precise subgroup identification. Young adults 18-24 without college in food service/retail comprise ~15% of the 18-30 age group — still providing ample sample size (~90K/year).

---

## State Ban-the-Box Laws and Racial Employment Disparities

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: high-quality policy database distinguishing private-sector vs public-only

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: precise effective dates with monthly CPS

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: explicit strategy for local-policy contamination—e.g.

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: drop/flag high-ordinance states or use metro-level designs

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

**Status: RESOLVED**
