# Initial Research Plan: Paper 105

**Title:** Salary History Bans and the Wage Penalty for Job Stayers: Evidence from Staggered State Adoption

**Date:** 2026-01-28

---

## Research Question

Do salary history bans (SHBs) affect wages for workers who remain with their current employer (job stayers), in addition to their documented effects on job changers? Specifically, we examine whether SHBs compress wage distributions and reduce the "wage premium" traditionally associated with job switching.

---

## Policy Background

Salary history bans prohibit employers from asking job applicants about their prior compensation. The rationale is that reliance on salary history perpetuates historical pay discrimination—workers who were underpaid in previous jobs carry that disadvantage forward. Beginning with Massachusetts (effective July 2018), approximately 19 states had adopted SHBs by 2024.

**Key adoption dates:**
- Delaware: Dec 2017 (public), Dec 2018 (private)
- California: Jan 2018
- Massachusetts: July 2018
- Connecticut: Jan 2019
- Hawaii: Jan 2019
- New York: Jan 2020
- Illinois: Sept 2019
- Maine: Sept 2019
- Colorado: Jan 2021
- And others...

---

## Theoretical Framework

### Direct Effects (Job Changers - Existing Literature)
When employers cannot observe salary history, they must form wage offers based on observable characteristics and market wages rather than anchoring to prior pay. This benefits historically underpaid workers (women, minorities).

### Indirect Effects (Job Stayers - Our Novel Contribution)
SHBs may affect job stayers through several channels:
1. **Retention pressure:** If employers expect job changers to receive higher market-rate offers (unanchored to history), they may proactively raise stayer wages to prevent turnover.
2. **Internal equity adjustments:** Firms may compress wage structures to maintain fairness between new hires and incumbents.
3. **Reduced outside-option information:** Employers lose an information advantage in salary negotiations, potentially benefiting stayers in retention negotiations.

**Prediction:** SHBs should increase wages for job stayers, particularly in sectors with high turnover or competitive labor markets.

---

## Identification Strategy

### Design
Difference-in-differences with staggered adoption, using the Callaway & Sant'Anna (2021) estimator to address heterogeneous treatment effects.

**Treatment:** State enacts salary history ban (at month level)
**Unit of analysis:** Individual worker-year
**Comparison:** Never-treated states and not-yet-treated states

### Sample Definition
- **Job Stayers:** Workers observed in matched MORG rotation groups (months 4 and 8) who report same employer/industry at t and t+12
- **Job Changers:** Workers with different employer/industry between observations

### Primary Specification

For individual $i$ in state $s$ at time $t$:

$$\ln(w_{ist}) = \alpha + \beta \cdot SHB_{st} + X_{ist}'\gamma + \delta_s + \theta_t + \epsilon_{ist}$$

Where:
- $SHB_{st}$ = 1 if state $s$ has SHB effective by time $t$
- $X_{ist}$ = individual controls (age, education, gender, race, industry, occupation)
- $\delta_s$ = state fixed effects
- $\theta_t$ = time (quarter) fixed effects

---

## Expected Effects and Mechanisms

| Outcome | Expected Sign | Mechanism |
|---------|--------------|-----------|
| Log wages (stayers) | + | Retention pressure, internal equity |
| Log wages (changers) | + | Information asymmetry reduction |
| Stayer-changer wage gap | − | Compression of switching premium |
| Effect heterogeneity (women) | ++ | Correcting historical discrimination |

---

## Primary Specification

1. **Main outcome:** Log hourly wage (CPS MORG)
2. **Treatment:** Binary indicator for SHB in effect
3. **Subgroup analyses:**
   - Job stayers vs. changers (separate regressions)
   - By gender, race/ethnicity
   - By industry (high vs. low turnover)
   - By tenure (short vs. long)

---

## Planned Robustness Checks

1. **Pre-trends test:** Event study coefficients for t-4 to t-1
2. **Placebo test:** Public-sector-only SHBs (should not affect private sector)
3. **Coincident policy controls:** Include minimum wage, pay transparency laws, paid leave mandates
4. **HonestDiD sensitivity:** Assess robustness to parallel trend violations
5. **Border discontinuity:** Compare border counties in treated vs. control states
6. **Alternative estimators:** Sun & Abraham (2021), de Chaisemartin & D'Haultfoeuille (2020)

---

## Data Sources

| Data | Source | Variables |
|------|--------|-----------|
| Wages, employment | CPS MORG (2010-2024) | Hourly earnings, industry, occupation, demographics, state |
| SHB adoption dates | NELP, HR Dive, state statutes | Effective month by state |
| Coincident policies | NCSL, DOL, A Better Balance | Min wage, pay transparency, leave laws |

---

## Timeline and Milestones

1. **Data acquisition:** Fetch CPS MORG, compile policy dates
2. **Data cleaning:** Match rotation groups, define stayer/changer status
3. **Main analysis:** Run CS DiD for stayers and changers separately
4. **Event studies:** Generate pre-trend plots
5. **Robustness:** Run all planned checks
6. **Paper writing:** Compile results into publication-ready document

---

## DiD Feasibility Assessment

| Criterion | Assessment | Notes |
|-----------|------------|-------|
| Pre-treatment periods | ≥8 years | 2010-2017 before first SHB |
| Selection into treatment | Moderate concern | Control with region×time, policy bundles |
| Comparison group | Never-treated + not-yet-treated | ~31 states without SHB |
| Treatment clusters | ~19 states | Adequate for inference |
| Concurrent policies | Present | Will control explicitly |
| Outcome-policy alignment | Strong | Wages directly targeted by SHB mechanism |

---

## Power Considerations

- CPS MORG: ~180,000 workers/year × 15 years = ~2.7 million observations
- Matched rotation sample: ~30% = ~800,000 person-year pairs
- Expected stayer fraction: ~60-70%
- Minimum detectable effect: ~1-2% wage change with 80% power

---

**This plan is locked. Any modifications during execution will be documented in research_plan.md.**
