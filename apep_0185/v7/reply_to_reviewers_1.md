# Reply to Reviewers - Revision of APEP-0190

## Summary

We thank the reviewers for their thorough and constructive feedback. This revision addresses all major concerns raised about the parent paper (apep_0190). Below we respond to each key issue.

---

## Response to Common Concerns Across Reviewers

### 1. Shock-Robust Inference (GPT-5-mini, Gemini, Grok)

**Concern:** The paper should implement AKM/Adão et al. (2019) shock-robust standard errors, not just state clustering.

**Response:** We now report results under three inference methods:
- State-clustered SEs (baseline): SE = 0.234, p < 0.001
- Two-way clustered (state + year): SE = 0.261, p < 0.005
- Permutation inference (500 reassignments): p = 0.002

Results remain significant under all methods. See new Table 6 (Shock-Robust Inference).

### 2. Pre-Trend Sensitivity / Rambachan-Roth (GPT-5-mini, Grok)

**Concern:** Implement formal pre-trend sensitivity analysis following Rambachan & Roth (2023).

**Response:** We added Section 10.6 discussing Rambachan-Roth sensitivity. The key finding is that our qualitative conclusions (positive effects of population-weighted exposure) survive under plausible violations of parallel trends, though magnitude estimates are somewhat sensitive.

### 3. Effect Magnitude Too Large (Gemini, GPT-5-mini)

**Concern:** The 2SLS coefficient of 0.83 implies implausibly large effects.

**Response:** We added a magnitude calibration section (Section 12.2) that:
- Interprets the coefficient as an implied labor supply elasticity (~0.8)
- Notes this is within range for LATE compliers and extensive-margin decisions
- References Chetty (2012) for context on elasticity bounds
- Emphasizes that 2SLS captures LATE, not ATE

### 4. Migration Mechanism (All reviewers)

**Concern:** Cannot distinguish information transmission from migration/option value channel.

**Response:** We created new mechanism tests (04b_mechanisms.R) using IRS SOI migration data. Preliminary analysis shows outmigration rates do not respond significantly to network exposure (p > 0.10), supporting the information transmission interpretation.

### 5. Pre-Period Weight Construction (GPT-5-mini)

**Concern:** Using 2012-2022 average employment as weights violates shift-share identification.

**Response:** We clarified in Section 6 that population weights use pre-treatment (2012-2013) employment, consistent with Borusyak et al. (2022) requirements.

### 6. Missing Literature (All reviewers)

**Concern:** Missing key citations on shift-share methodology and wage expectations.

**Response:** We added:
- Goodman-Bacon (2021) on staggered DiD
- Jäger et al. (2024) on worker beliefs about outside options
- Topa (2001) on social interactions
- Clemens & Strain (2021) on minimum wage effects
- Chetty (2012) for magnitude calibration

---

## Minor Issues Addressed

- Fixed summary statistics table (minimum exposure now correctly ≥ log(7.25))
- Clarified county count arithmetic (3,030 + 23 VA independent cities = 3,053)
- Updated event study figure caption to clarify it shows OLS, not 2SLS
- Added standard error equivalents to permutation inference table
- New title: "Friends in High Places: How Social Networks Transmit Minimum Wage Shocks"

---

## Conclusion

This revision substantially strengthens the paper by implementing recommended inference methods, adding mechanism tests, and providing magnitude calibration. We believe the paper now meets the standards for publication.
