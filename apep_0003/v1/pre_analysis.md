# Pre-Analysis Plan: Indiana Ban-the-Box Preemption and Employment Outcomes

**Paper ID:** paper_10
**Date:** 2026-01-17
**Status:** Pre-registered (to be locked before analysis)

---

## Research Question

Did Indiana's 2017 preemption of local ban-the-box ordinances (SB 312) affect employment outcomes for demographic groups with higher criminal record rates, and did it exacerbate statistical discrimination in hiring?

---

## Background and Policy Context

### Indiana Senate Bill 312 (2017)
- **Effective date:** July 1, 2017
- **Content:** Prohibited local governments from restricting employers' ability to inquire about criminal history during hiring
- **Impact:** Nullified Indianapolis's 2014 ban-the-box ordinance and prevented future local BTB adoption
- **Significance:** Indiana was the first state in the US to preempt local BTB laws

### Indianapolis Ban-the-Box Ordinance (Preempted)
- Enacted 2014 by Indianapolis/Marion County
- Required delaying criminal history questions until after interview for city contractors and public employees
- Affected an estimated 20,000+ workers in city contracting and public sector

---

## Conceptual Framework

### Theory 1: Statistical Discrimination Channel
**Mechanism:** When employers cannot observe individual criminal histories (BTB in effect), they may use observable demographic characteristics (race, age, education) as proxies. When BTB is removed (preemption), employers can directly observe criminal histories, reducing their reliance on demographic proxies.

**Predictions for BTB ADOPTION (prior literature):**
- Employment increases for those with records (can be evaluated individually)
- Employment may DECREASE for demographic groups with high criminal record rates but clean individual records (statistical discrimination)

**Predictions for BTB REMOVAL (Indiana preemption - our study):**
- Employment may DECREASE for those with records (can now be screened early)
- Employment may INCREASE for demographic groups with high criminal record rates but clean individual records (reduced statistical discrimination)
- Net effect is ambiguous and depends on relative group sizes

### Theory 2: Chilling Effect Channel
**Mechanism:** Preemption may signal state-level political hostility to worker protections, potentially chilling local labor market activism and reducing worker bargaining power more broadly.

**Predictions:**
- Broader negative employment effects not concentrated in high-criminal-record demographics
- Wage effects may be negative even for groups unaffected by criminal history screening

### Theory 3: Null Effect (Business as Usual)
**Mechanism:** BTB primarily affected public sector and city contractors. Private employers already could inquire about criminal history. Preemption may have little practical effect.

**Predictions:**
- No detectable employment effects
- No differential effects by demographics

---

## Primary Specification

### Design: Difference-in-Differences

**Unit of observation:** Individual person-year

**Sample definition:**
- Working-age adults: 18-64 years old
- Treatment: Indiana residents (ST=18)
- Control: Residents of Ohio (ST=39), Michigan (ST=26), Illinois (ST=17)
- Years: 2014-2019 (3 years pre, 2.5 years post July 2017; exclude 2020+ for COVID)
- Labor force: Include all (employed, unemployed, not in labor force)

**Outcome variables (primary):**
1. **Employed** = 1 if ESR ∈ {1, 2} (employed at work or with job not at work)
2. **WAGP** = Wage/salary income (conditional on employed)

**Treatment variable:**
- Treat = 1 if ST=18 (Indiana) AND year ≥ 2018 (first full post year)
- Post = 1 if year ≥ 2018
- Indiana = 1 if ST=18

**Primary model:**
```
Y_ist = α + β(Indiana_s × Post_t) + γ(Indiana_s) + δ(Post_t) + X'_i θ + State FE + Year FE + ε_ist
```

Where:
- Y_ist = outcome for individual i in state s at time t
- X_i = controls (age, age², sex, education, race, marital status)
- β = DiD coefficient of interest

**Expected sign for β:**
- **Employment:** Ambiguous (depends on composition effects from Theory 1)
- **For high-criminal-record demographics (young Black males):** Negative or zero (Theory 1 predicts less statistical discrimination may help, but direct screening hurts those with records)

---

## Where Mechanism Should Operate

### Who is Directly Affected

**Narrow treatment group (high first-stage):**
- Workers in Indianapolis metro area (Marion County and surrounding PUMAs)
- Workers in public sector or government contracting (COW=3,4,5 for government employment)
- Workers in industries with high background check prevalence

**Demographic proxy for criminal record exposure:**
- Males aged 18-35 with less than college education
- Black males in particular (due to documented disparities in criminal justice contact)
- Workers in high-turnover occupations (service, retail, manual labor)

### Who is NOT Affected (Placebo Groups)

- Workers outside Indianapolis metro
- Workers in professional/managerial occupations requiring advanced degrees
- Older workers (45+) with established careers
- Self-employed workers (no employer screening)

### Heterogeneity Tests (Pre-Specified)

1. **Geography:** Indianapolis metro vs. rest of Indiana (expect stronger effect in Indianapolis)
2. **Demographics:** Young Black males vs. other demographics (proxy for criminal record exposure)
3. **Sector:** Public/government vs. private sector
4. **Education:** Less than BA vs. BA or more

---

## Sample Size and Power Considerations

**Expected sample sizes (from prior PUMS analysis):**
- Indiana: ~60,000 person-observations per year
- Control states combined: ~300,000 person-observations per year
- Total 6-year sample: ~2.2 million observations

**Minimum detectable effect:**
- With N=2.2M, SE ≈ 0.5 percentage points on employment
- Can detect effects of ~1 percentage point at 80% power
- Given baseline employment ~60%, this is ~1.7% effect size

---

## Robustness Checks

### Specification Variations
1. Include state-specific linear trends
2. Drop 2017 (transition year)
3. Add PUMA fixed effects (within-state geography)
4. Cluster standard errors at state level (4 states)

### Sample Variations
1. Restrict to ages 25-54 (prime working age)
2. Restrict to those with high school or less
3. Exclude self-employed
4. Restrict to full-time workers only

### Control State Variations
1. Drop Illinois (large, different economy)
2. Add additional Midwest states: Wisconsin, Kentucky, Iowa
3. Synthetic control approach (if feasible)

---

## Validity Checks

### Parallel Trends Test
- Event-study specification with year × Indiana interactions
- Visual inspection of pre-trends
- Test H0: coefficients on pre-2017 interactions = 0

### Covariate Balance
Test for differential changes in:
- Age distribution
- Education composition
- Race/ethnicity composition
- Industry composition
- Occupation composition

### Placebo Tests
1. **Placebo timing:** Apply treatment in 2015 (expect null)
2. **Placebo geography:** Apply to non-Indianapolis Indiana PUMAs only (expect null or smaller)
3. **Placebo population:** Test effect on college-educated workers (expect null)

---

## What Would Invalidate the Design

1. **Differential economic shocks:** If Indiana experienced different labor market trends than control states for reasons unrelated to SB 312
2. **Other contemporaneous policies:** If Indiana enacted other employment-related policies in 2017
3. **Compositional changes:** If the preemption caused migration that changed Indiana's demographics
4. **Anticipation effects:** If employers changed behavior before the July 2017 effective date

---

## Analysis Plan

### Step 1: Descriptive Statistics
- Sample sizes by state, year, demographics
- Employment rates over time by state
- Wage distributions

### Step 2: Primary DiD
- Full sample DiD regression
- Report point estimate, SE, 95% CI, p-value
- Report in terms of percentage point effect and percentage effect (relative to baseline)

### Step 3: Heterogeneity Analysis
- Interact treatment with pre-specified heterogeneity dimensions
- Report full table of interactions
- Apply FDR correction for multiple testing

### Step 4: Robustness
- Run all pre-specified robustness checks
- Report in appendix table

### Step 5: Validity
- Event-study figure
- Covariate balance table
- Placebo test table

---

## Interpretation Guide (Pre-Specified)

### If β < 0 (employment declines in Indiana):
- Consistent with Theory 2 (chilling effect) or Theory 1 (net negative for workers with records)
- Check heterogeneity: if concentrated in high-criminal-record demographics, supports Theory 1

### If β > 0 (employment increases in Indiana):
- Consistent with Theory 1 (reduced statistical discrimination helping clean-record individuals)
- Check heterogeneity: should be concentrated in demographics that benefit from being individually screened

### If β ≈ 0 (null effect):
- Consistent with Theory 3 (BTB had limited scope)
- Check power: can we rule out economically meaningful effects?
- Check heterogeneity: may mask offsetting effects

---

## Deviations Protocol

If I deviate from this pre-analysis plan, I will:
1. Document the deviation clearly in the paper
2. Explain the rationale for the deviation
3. Report both pre-specified and deviated results
4. Label exploratory analyses as such
