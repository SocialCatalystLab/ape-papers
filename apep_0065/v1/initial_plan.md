# Initial Research Plan: Remote Work and Housing Cost Burden

**Paper:** 83
**Method:** Doubly Robust (DR) Estimation
**Date:** 2026-01-26

---

## Research Question

Does remote work reduce housing cost burden by enabling geographic arbitrage—the ability to live in lower-cost areas while maintaining employment with higher-paying employers?

## Hypothesis

Remote workers, by decoupling workplace location from residence, can choose to live in lower-cost housing markets while maintaining access to higher wages from employers in expensive markets. This should result in lower housing cost burden (housing costs as a share of income) compared to observationally similar in-person workers.

## Estimand

**Average Treatment Effect on the Treated (ATT):** The average reduction in housing cost burden among remote workers compared to what they would have experienced as in-person workers.

$$\text{ATT} = E[Y(1) - Y(0) | D = 1]$$

Where:
- $Y(1)$ = housing cost burden under remote work
- $Y(0)$ = housing cost burden under in-person work
- $D = 1$ indicates remote worker

## Identification Strategy

### Assumptions

1. **Conditional Independence (Selection on Observables):** Conditional on covariates $X$, treatment assignment (remote work) is independent of potential outcomes:
   $$Y(0), Y(1) \perp D | X$$

2. **Positivity (Overlap):** All covariate strata have some probability of both treatment and control:
   $$0 < P(D = 1 | X) < 1$$

### Covariates for Adjustment

| Category | Variables | Rationale |
|----------|-----------|-----------|
| Demographics | Age, sex, race, Hispanic origin, nativity | Basic demographic controls |
| Education | Educational attainment (SCHL) | Strong predictor of both WFH access and income |
| Occupation | 2-digit SOC (SOCP) | Controls for job-specific WFH feasibility |
| Industry | 2-digit NAICS (INDP) | Industry-specific remote work norms |
| Household | Marital status, presence of children, household size | Housing needs and dual-earner constraints |
| Geography | State, metro status | Local labor/housing markets |
| Work | Hours per week, weeks worked | Labor supply |

### Estimator Choice

**Augmented Inverse Probability Weighting (AIPW)** with cross-fitting:
- Combines propensity score weighting with outcome regression
- Doubly robust: consistent if either PS or outcome model is correctly specified
- Cross-fitting (K=5) prevents overfitting bias

Implementation: R package `AIPW` with Super Learner for nuisance estimation.

## Data

**Source:** American Community Survey Public Use Microdata Sample (ACS PUMS) 2023

**Unit:** Individual worker

**Sample Restrictions:**
- Age 25-59 (prime working age)
- Employed (ESR in 1, 2)
- Full-time (WKHP >= 35)
- Private sector wage workers (COW in 1, 2)
- Non-group quarters households

**Expected Sample:** ~2.5 million workers; ~400,000 remote workers

## Variables

### Treatment
- **Remote Work:** JWTRNS = 11 or 12 (worked from home)

### Outcomes
| Variable | ACS Code | Definition |
|----------|----------|------------|
| Gross rent burden | GRPIP | Gross rent as % of household income |
| Owner cost burden | OCPIP | Owner costs as % of household income |
| Severe burden | GRPIP/OCPIP > 30 | Binary: housing costs exceed 30% of income |

### Covariates
| Variable | ACS Code |
|----------|----------|
| Age | AGEP |
| Sex | SEX |
| Race | RAC1P |
| Hispanic | HISP |
| Nativity | NATIVITY |
| Education | SCHL |
| Occupation | SOCP |
| Industry | INDP |
| Marital status | MAR |
| Children | NOC |
| Household size | NP |
| State | ST |
| Metro status | MET2013 |
| Hours/week | WKHP |

## Analysis Plan

### 1. Descriptive Statistics
- Sample characteristics by remote/non-remote
- Raw housing burden differences
- Geographic distribution of remote workers

### 2. Propensity Score Estimation
- Super Learner with: logistic regression, random forest, XGBoost
- Cross-fitting with K=5 folds
- Overlap diagnostics: density plots, trimming at 0.01/0.99

### 3. Main DR Estimation
- AIPW estimator for ATT
- Separate estimates for renters (GRPIP) and owners (OCPIP)
- Standard errors via influence functions

### 4. Mechanism Tests (Geographic Arbitrage)
- Heterogeneity by metro status (core vs. non-metro)
- Heterogeneity by PUMA-level housing costs
- Interaction with recent migration (MIG)

### 5. Robustness and Sensitivity
- E-values for unmeasured confounding
- Calibrated sensitivity analysis (sensemakr)
- Negative control outcomes (disability, veteran status)
- Placebo test: effect for non-remote-feasible occupations

### 6. Heterogeneity
- By income quintile
- By education level
- By occupation telework feasibility
- By household composition (single vs. married)

## Expected Results

1. **Main effect:** Remote workers have 3-8 percentage points lower housing cost burden than comparable in-person workers.

2. **Mechanism:** Effect is larger for:
   - Workers who recently moved
   - Workers in non-metro/lower-cost areas
   - Higher-income workers (more arbitrage opportunity)

3. **Heterogeneity:** Effect varies by:
   - Income (larger for high-income)
   - Household type (larger for singles with more location flexibility)
   - Occupation (larger for fully remote-feasible jobs)

## Limitations

1. **Cross-sectional data:** Cannot observe same worker before/after remote transition
2. **Selection on unobservables:** Preferences for location, wealth, employer quality
3. **JWTRNS measurement:** Captures usual mode, may miss hybrid arrangements
4. **Geographic arbitrage timing:** May not capture full adjustment (people still moving)

## Timeline

| Phase | Tasks |
|-------|-------|
| Data | Fetch ACS 2023 PUMS, clean, merge PUMA costs |
| Analysis | Propensity scores, AIPW, mechanisms, robustness |
| Writing | Full paper draft (25+ pages) |
| Review | Internal + external review |
| Revision | Address reviewer comments |

## Output Files

```
output/paper_83/
├── code/
│   ├── 00_packages.R
│   ├── 01_fetch_data.R
│   ├── 02_clean_data.R
│   ├── 03_descriptives.R
│   ├── 04_propensity.R
│   ├── 05_main_analysis.R
│   ├── 06_mechanisms.R
│   ├── 07_robustness.R
│   └── 08_figures.R
├── data/
│   └── acs_2023_clean.rds
├── figures/
├── tables/
└── paper.tex
```
