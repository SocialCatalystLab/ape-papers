# Initial Research Plan — Paper 36

**Created:** 2026-01-18
**Status:** LOCKED (do not modify after creation — use research_plan.md for updates)

---

## Title (Working)

**The End of Aid: How Losing Mothers' Pension Eligibility at Child Age 14 Affected Maternal Labor Supply in Early 20th Century America**

---

## Research Question

Did the loss of mothers' pension benefits when a child turned 14 cause mothers to enter the labor force?

---

## Policy Background

Between 1911-1935, 46 U.S. states enacted mothers' pension programs—the first public cash assistance programs targeting single mothers. These programs provided monthly cash transfers (typically $10-25/month) to "deserving" widows with dependent children.

**Critical eligibility feature:** In most states, eligibility terminated when the youngest child reached a specified age—most commonly 14 (in some states 15-17). This creates a sharp income discontinuity at the child's birthday.

### State Variation in Age Cutoffs

| Age Cutoff | States |
|------------|--------|
| 14 | California, Illinois, **Iowa**, Massachusetts, Minnesota, Missouri, South Dakota, Wisconsin |
| 15 | Idaho, Utah, Washington |
| 16 | Colorado, New Hampshire, New Jersey, Oklahoma, Oregon |
| 17+ | Some states with extensions |

**Iowa** (one of our randomized focus states) has an age-14 cutoff, providing a clean case for analysis.

---

## Identification Strategy

### Design: Regression Discontinuity at Child Age 14

**Running variable:** Age of youngest child in household (measured in years at census)

**Cutoff:** Age 14 (state-specific; will analyze age-14 states primarily)

**Treatment:** Mother no longer eligible for pension (youngest child ≥14)

**Outcome:** Maternal labor force participation

### Intent-to-Treat Interpretation

- We cannot observe actual pension receipt in census data
- We identify eligibility based on: (1) widow status, (2) children present, (3) age of youngest child
- Estimates capture effect of losing eligibility, not effect of benefit loss per se
- First stage (actual benefit loss) unobserved → reduced-form/ITT estimates

### Sample Definition

- **Included:** Female household heads who are widowed/single with children aged 12-16
- **States:** Initially focus on states with age-14 cutoff for cleaner discontinuity
- **Censuses:** 1920 and 1930 (programs widespread by then; 1940 has ADC confound)
- **Bandwidth:** Start with ±2 years around cutoff; robustness with ±1, ±3

### Threats to Validity

1. **Discrete running variable:** Age measured in years, not months. Must use discrete RD methods (Kolesár & Rothe 2018; Cattaneo et al. 2020 rdrobust for discrete data).

2. **Age heaping:** Test for bunching at round ages (10, 15).

3. **Other discontinuities at age 14:**
   - Child labor laws also pivot at age 14 (children can legally work)
   - If child enters labor force, household income may rise, confounding maternal LFP
   - **Mitigation:** Control for child employment; heterogeneity by child gender

4. **Selection into widowhood/sample:** Widows who remain in sample may differ systematically. Test pre-treatment covariates for smoothness.

5. **Discretion in termination:** Some counties may have granted extensions. This attenuates effects (bias toward null).

---

## Data

### Primary Source: IPUMS USA Full-Count Census

- **Censuses:** 1920, 1930 (1940 as robustness, though ADC begins)
- **Variables needed:**
  - Person-level: AGE, SEX, RELATE (relationship to head), MARST (marital status), EMPSTAT/LABFORCE (employment), OCC1950 (occupation), INCWAGE (1940 only)
  - Household-level: Family structure variables
  - Geography: STATEFIP, COUNTY

### Sample Size Estimates

From full-count data:
- ~100 million person-records per census
- Widowed female household heads with children: ~1-2 million per census
- With youngest child aged 12-16: ~300,000-500,000 per census
- Sufficient for precise RD estimates

### Data Access

- IPUMS requires extract request and download
- User indicated IPUMS API key available (though not found in environment)
- **Fallback:** Census PUMS microdata (samples, not full-count) if IPUMS access issues

---

## Analysis Plan

### Step 1: Sample Construction
1. Extract IPUMS data for 1920, 1930 censuses
2. Identify widowed/single female household heads with children
3. Determine age of youngest child in household
4. Restrict to states with age-14 cutoff

### Step 2: Descriptive Statistics
1. Distribution of youngest child age (check for heaping)
2. Characteristics of mothers by youngest child age (balance test)
3. Labor force participation rates by youngest child age (raw data visualization)

### Step 3: RDD Estimation
1. **Graphical analysis:** Plot LFP against youngest child age; look for discontinuity at 14
2. **Local linear regression:** Estimate jump at cutoff with optimal bandwidth (Imbens-Kalyanaraman or CCT)
3. **Polynomial specifications:** Linear, quadratic on either side of cutoff
4. **Discrete RD corrections:** Apply Kolesár-Rothe confidence intervals for discrete running variable

### Step 4: Robustness Checks
1. Vary bandwidth (±1, ±2, ±3 years)
2. Donut RD (exclude ages 13-14)
3. Placebo cutoffs at ages 12, 13, 15, 16
4. State-by-state estimates
5. Pre-treatment covariate balance at cutoff

### Step 5: Heterogeneity Analysis
1. By state (different benefit generosity)
2. By urban/rural location
3. By number of children
4. By mother's age
5. By year (1920 vs 1930)

### Step 6: Mechanisms
1. Test if child's employment increases at 14 (child labor law coincides)
2. Conditional on child employment, does mother's LFP still jump?
3. Type of employment mother enters (occupation analysis)

---

## Expected Results

**Primary hypothesis:** Maternal LFP increases discontinuously at youngest child age 14.

**Magnitude:** Pension loss of ~$20/month was ~25% of median male earnings. Expect 5-15 percentage point increase in LFP at the cutoff.

**Alternatives:**
- No effect: Pension not binding for employment decisions (income effects small)
- Negative effect: Mothers were already working informally; formal LFP captures exit from pension-eligible "non-working" status

---

## Paper Structure

1. **Introduction** (~2 pages)
2. **Historical Background: Mothers' Pensions** (~3 pages)
3. **Data** (~3 pages)
4. **Empirical Strategy** (~4 pages)
5. **Results** (~6 pages)
6. **Robustness and Extensions** (~4 pages)
7. **Discussion** (~2 pages)
8. **Conclusion** (~1 page)

**Target length:** 25+ pages

---

## Timeline

1. Data extraction and cleaning: [immediate]
2. Descriptive analysis and visualizations: [following data]
3. Main RDD estimation: [following descriptives]
4. Robustness and heterogeneity: [following main results]
5. Paper writing: [following analysis]
6. Internal review: [following draft]
7. External review: [following internal]

---

## Key References

- Aizer, A., Eli, S., Ferrie, J., & Lleras-Muney, A. (2016). The long-run impact of cash transfers to poor families. AER.
- Fetter, D. K., & Lockwood, L. M. (2016). Government old-age support and labor supply. NBER WP 22132.
- Kolesár, M., & Rothe, C. (2018). Inference in regression discontinuity designs with a discrete running variable. AER.
- Cattaneo, M. D., Idrobo, N., & Titiunik, R. (2020). A practical introduction to regression discontinuity designs.
