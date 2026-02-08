# Initial Research Plan: The Insurance Value of Secondary Employment

**Paper ID:** paper_154
**Date:** 2026-02-03
**Method:** Doubly Robust (DR) with panel extensions

---

## Research Question

Does holding a secondary job enable greater mobility in one's primary employment? Specifically, does the "income insurance" provided by secondary work allow workers to take risks in their primary job market (voluntary quits, job search, wage negotiation) that they otherwise would avoid?

---

## Theoretical Framework

### Competing Hypotheses

**H1: Insurance Hypothesis**
Secondary employment provides income smoothing that enables risk-taking:
- Workers with secondary income can absorb temporary primary job loss
- Reduces precautionary savings motive → more willingness to quit bad matches
- Enables job search while employed (less time-constrained with income buffer)
- **Prediction:** Multiple job holders (MJH) have HIGHER job-to-job transition rates

**H2: Lock-in Hypothesis**
Secondary employment consumes resources that reduce mobility:
- Time/energy spent on second job reduces job search effort
- Cognitive load of managing multiple jobs reduces risk tolerance
- May create scheduling constraints that limit primary job options
- **Prediction:** MJH have LOWER job-to-job transition rates

### Mechanism Test: Heterogeneous Effects

If the insurance mechanism dominates:
- Effects should be LARGER for credit-constrained workers (low income, no savings)
- Effects should be LARGER for workers without other insurance (no spouse income, no unemployment eligibility)
- Effects should be concentrated in workers who START secondary jobs (event-study)

If the lock-in mechanism dominates:
- Effects should be uniform across credit constraint proxies
- Effects should be LARGER for time-intensive second jobs

---

## Identification Strategy

### Primary Design: Doubly Robust AIPW

**Treatment:** Holding a secondary job (MULTJOB = 1)

**Outcome:** Primary job transitions measured at 12-month horizon:
- Voluntary quit (job-to-job with wage gain)
- Involuntary separation (layoff/discharge)
- Any separation from primary employer
- Wage growth in primary job

**Covariates for conditional independence:**
- Demographics: Age, age², sex, race/ethnicity, marital status, children
- Human capital: Education (detailed), occupation (3-digit), industry (2-digit)
- Job characteristics: Hours, tenure, union status, firm size
- Geography: State, metro status
- Family: Spouse employment, spouse income, household size
- Financial proxies: Home ownership, income-to-needs ratio

### Enhanced Design: Individual Fixed Effects + Event Study

Per GPT recommendation, exploit CPS panel structure:

1. **Within-person changes:** Compare same individual before/after starting secondary job
2. **Event-study specification:** Center on month of secondary job start
3. **Stacked cohorts:** Pool workers who start secondary jobs in different months

This addresses time-invariant unobserved heterogeneity (risk preferences, ability).

---

## Data

### Source: CPS Monthly + ASEC

**Variables needed:**
- MULTJOB: Multiple job holder indicator
- NUMJOB: Number of jobs held
- CPSIDP: Person identifier for longitudinal linking
- EMPSTAT: Employment status
- CLASSWKR: Class of worker (wage/salary, self-employed)
- OCC: Occupation (3-digit)
- IND: Industry (2-digit)
- EARNWT, WTFINL: Weights
- Standard demographics (AGE, SEX, RACE, EDUC, etc.)
- UHRSWORK: Usual hours
- UNION: Union membership
- FIRMSIZE: Employer size

**Longitudinal structure:**
- 4-8-4 rotation: Can observe same person for up to 4 consecutive months, then 8 months later for 4 more months
- ASEC panels: March-to-March linking for annual changes

**Sample period:** 2015-2024 (post-Great Recession, includes COVID period)

**Sample restrictions:**
- Age 25-54 (prime working age)
- Employed at baseline
- Valid CPSIDP for panel linking
- Non-agricultural employment

### Expected Sample Size

- ~150,000 employed workers per month in CPS
- ~20% (30,000) are multiple job holders
- Over 10-year period with panel linking: ~500,000 person-year observations
- Adequate power for heterogeneity analysis

---

## Estimation

### Main Specification: AIPW

```r
library(AIPW)
library(SuperLearner)

# SuperLearner ensemble
sl_lib <- c("SL.glm", "SL.ranger", "SL.xgboost")

# AIPW with 10-fold cross-fitting
aipw_obj <- AIPW$new(
  Y = df$job_transition,
  A = df$multiple_job,
  W = df[, covariates],
  Q.SL.library = sl_lib,
  g.SL.library = sl_lib,
  k_split = 10,
  verbose = FALSE
)
```

### Event-Study with Individual FE

```r
library(fixest)

# Event-study around secondary job start
es_model <- feols(
  job_transition ~ i(event_time, ref = -1) | person_id + year_month,
  data = df_panel,
  cluster = ~ person_id
)
```

### Heterogeneity Analysis

Estimate CATE by subgroups:
- Credit constraint proxy: Bottom income quartile, renters, no spouse income
- Insurance substitutes: Spouse employed, unemployment-eligible
- Job type: "Gig-like" secondary (self-employed, variable hours) vs traditional

---

## Robustness and Sensitivity

### Required Validity Evidence

1. **Covariate balance:** Standardized mean differences < 0.1 after weighting
2. **Propensity score overlap:** Density plots showing common support
3. **E-value sensitivity:** How strong would unmeasured confounding need to be?
4. **Calibrated sensitivity:** Benchmark to observed confounders

### Negative Control Outcomes

Outcomes that SHOULDN'T be affected by secondary employment:
- Spouse's job transitions (falsification)
- Non-labor outcomes: health status, mortality (if available)

### Negative Control Exposures

"Placebo treatments" with same selection mechanism but different timing:
- Future secondary employment (assigned today, starts later)

### Specification Robustness

- Alternative ML methods (different SuperLearner libraries)
- Trimming at different propensity score thresholds
- Sample restrictions (different age ranges, excluding COVID period)

---

## Expected Results

### Baseline descriptive patterns

From BLS data and prior literature:
- ~5-7% of workers hold multiple jobs
- MJH are more likely to be young, female, educated, in service occupations
- MJH have lower household income on average

### Theoretical predictions (to be tested)

**If insurance hypothesis holds:**
- ATE on job-to-job transitions: Positive (5-15%)
- Effect larger for credit-constrained
- Event-study shows increase in transitions AFTER starting secondary job

**If lock-in hypothesis holds:**
- ATE on job-to-job transitions: Negative or null
- Effect uniform across credit constraint
- May see reduced job search intensity

### Null result value

A credible null result is still publishable if:
- Design is rigorous
- Rules out economically meaningful effects
- Provides bounds on possible insurance value

---

## Paper Structure

1. **Introduction** (3 pages)
   - Motivation: Growth of gig/secondary employment, policy debates about precarious work
   - Research question: Does secondary work enable or constrain mobility?
   - Preview: Novel causal evidence using DR + panel methods

2. **Theoretical Framework** (4 pages)
   - Insurance hypothesis with formal model
   - Lock-in hypothesis
   - Testable predictions from heterogeneity

3. **Data and Sample** (4 pages)
   - CPS structure and variables
   - Longitudinal linking methodology
   - Sample construction and descriptive statistics

4. **Empirical Strategy** (4 pages)
   - AIPW estimator with cross-fitting
   - Event-study design
   - Identification assumptions and threats

5. **Results** (6 pages)
   - Main estimates (ATE)
   - Heterogeneity by credit constraints
   - Event-study dynamics
   - Mechanism tests

6. **Robustness and Sensitivity** (4 pages)
   - Balance and overlap diagnostics
   - E-value and calibrated sensitivity
   - Negative control outcomes
   - Alternative specifications

7. **Conclusion** (2 pages)
   - Summary of findings
   - Policy implications
   - Limitations and future research

8. **Appendix** (as needed)
   - Additional tables and figures
   - Variable definitions
   - Sensitivity analysis details

---

## Timeline Targets

- Data acquisition: Day 1
- Data cleaning and panel construction: Day 1
- Main analysis: Day 1
- Robustness checks: Day 1
- Paper writing: Day 1
- External review: Day 1

---

## Key Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Unconfoundedness fails | Event-study within persons addresses time-invariant confounders; calibrated sensitivity analysis |
| Measurement error in MJH | Use both MULTJOB (any) and NUMJOB (count); test sensitivity |
| COVID confounds | Estimate separately pre/during/post COVID; include COVID interaction |
| Small effect size | Power analysis; report minimum detectable effects |
| Propensity score overlap | Trimming; overlap-weighted estimators if needed |
