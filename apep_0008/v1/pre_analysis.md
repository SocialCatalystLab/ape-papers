# Pre-Analysis Plan

## Universal Occupational License Recognition and Interstate Migration

**Author:** APEP Autonomous Research
**Date:** 2026-01-17
**Status:** Pre-registered before data analysis

---

## 1. Research Question

Does universal occupational license recognition (ULR) increase interstate migration among workers in licensed occupations?

## 2. Background and Motivation

Approximately 22% of American workers require occupational licenses to practice their profession. These licenses are state-specific, creating barriers to interstate mobility for licensed workers. When workers relocate across state lines, they often must obtain new licenses, which can involve additional training, examinations, fees, and waiting periods.

Starting in 2019, several states enacted Universal License Recognition (ULR) laws that allow licensed professionals from other states to practice without re-licensure. Arizona was first (April 2019), followed by Montana (March 2019), Pennsylvania (2019), Idaho (March 2020), Utah (March 2020), Missouri (July 2020), and Iowa (June 2020).

**Policy mechanism:** ULR reduces migration costs for licensed workers by eliminating re-licensure requirements, theoretically increasing mobility into ULR states.

## 3. Hypotheses

### Primary Hypothesis (H1)
ULR states will experience increased in-migration from non-ULR states among workers in licensed occupations, relative to workers in non-licensed occupations.

**Direction:** Positive effect on migration into treatment states
**Expected magnitude:** 10-30% increase in in-migration rates (based on prior research finding 0.98 pp employment increase)

### Secondary Hypotheses

**H2:** Effects will be larger for occupations with historically low license portability (e.g., cosmetologists, teachers) compared to occupations with existing interstate compacts (e.g., nurses, physicians).

**H3:** Effects will be concentrated among younger workers (ages 25-40) who are more mobile at baseline.

**H4:** Employment rates among in-migrants to ULR states will be higher than employment rates among in-migrants to non-ULR states.

### Null Hypothesis
ULR has no effect on migration patterns because: (a) other migration frictions dominate licensing costs, (b) workers were unaware of ULR, or (c) the policy was not effectively implemented.

## 4. Data

### Source
Census Bureau American Community Survey (ACS) Public Use Microdata Sample (PUMS)
- Years: 2017-2022 (3 years pre-treatment for early adopters, post-treatment for all)
- Unit of observation: Individual
- Universe: Adults aged 25-60 in the civilian labor force

### Key Variables

| Variable | Description | Role |
|----------|-------------|------|
| MIGSP | State of residence 1 year ago | Identifies interstate migrants |
| ST | Current state of residence | Identifies destination state |
| OCCP | Occupation code (SOC-based) | Identifies licensed occupations |
| ESR | Employment status | Outcome: employed, unemployed, NILF |
| WAGP | Annual wages/salary | Outcome: earnings |
| AGEP | Age | Heterogeneity analysis |
| SEX | Sex | Control |
| RAC1P | Race | Control |
| SCHL | Education | Control |
| PWGTP | Person weight | Weighting |

### Treatment Definition

**Treatment group:** Workers in licensed occupations living in ULR states in year t
**Control group:** Workers in licensed occupations living in non-ULR states in year t

**ULR State Treatment Timing:**
| State | FIPS | Effective Date | First PUMS Year Treated |
|-------|------|----------------|-------------------------|
| Arizona | 04 | April 2019 | 2020 |
| Montana | 30 | March 2019 | 2020 |
| Pennsylvania | 42 | 2019 | 2020 |
| Idaho | 16 | March 2020 | 2021 |
| Utah | 49 | March 2020 | 2021 |
| Missouri | 29 | July 2020 | 2021 |
| Iowa | 19 | June 2020 | 2021 |

**Note:** PUMS data reflects status at time of survey (distributed throughout the year). Treatments effective mid-year are coded as treated in the following PUMS year to ensure full treatment exposure.

### Licensed Occupations

Occupations requiring state licensure will be identified using the National Occupational Licensing Database (NCSL) and include:
- Healthcare: Nurses (3255, 3256), Physicians (3060), Physical therapists (3160)
- Education: Teachers (2300-2330)
- Personal services: Cosmetologists (4510), Barbers (4500)
- Trades: Electricians (6355), Plumbers (6440)
- Professional: Real estate agents (4920), Accountants (0800)
- Legal: Lawyers (2100) [excluded - already high portability via bar reciprocity]

Full list of OCCP codes to be included will be documented in replication materials.

### Sample Restrictions

1. Age 25-60 (prime working age, excludes students and retirees)
2. In civilian labor force (ESR = 1, 2, or 3)
3. Valid state of residence and migration information
4. Non-imputed values for key variables (where flagged)

### Expected Sample Size

- Total PUMS records per year: ~3.5 million
- After age restriction (25-60): ~2 million
- In labor force: ~1.5 million
- In licensed occupations (~22%): ~330,000 per year
- Total across 6 years: ~2 million observations
- Interstate migrants per year (~3%): ~10,000 migrants in licensed occupations per year

## 5. Empirical Strategy

### 5.1 Primary Specification: Difference-in-Differences

$$Y_{ist} = \alpha + \beta \cdot ULR_{st} \cdot Licensed_i + \gamma \cdot ULR_{st} + \delta \cdot Licensed_i + X_i'\theta + \mu_s + \tau_t + \epsilon_{ist}$$

Where:
- $Y_{ist}$ = outcome for individual i in state s in year t
- $ULR_{st}$ = 1 if state s has ULR in year t
- $Licensed_i$ = 1 if individual i is in a licensed occupation
- $X_i$ = individual controls (age, sex, race, education)
- $\mu_s$ = state fixed effects
- $\tau_t$ = year fixed effects
- $\beta$ = coefficient of interest (DiD estimator)

**Primary outcome:** In-migration indicator (MIGSP ≠ ST and MIGSP is a non-ULR state)

### 5.2 Event Study Specification

To test parallel trends and examine dynamic effects:

$$Y_{ist} = \alpha + \sum_{k=-3}^{3} \beta_k \cdot \mathbf{1}[t - T_s = k] \cdot Licensed_i + X_i'\theta + \mu_s + \tau_t + \epsilon_{ist}$$

Where $T_s$ is the year state s adopted ULR. The reference period is k = -1 (year before adoption).

### 5.3 Staggered Adoption Robustness

Given heterogeneous treatment timing, we will implement:
1. **Callaway-Sant'Anna (2021)** estimator for group-time ATTs
2. **Sun-Abraham (2021)** interaction-weighted estimator
3. Comparison of TWFE to robust estimators

### 5.4 Standard Errors

Clustered at the state level (50 clusters) to account for within-state correlation and state-level treatment assignment.

## 6. Outcome Variables

### Primary Outcome
**In-migration rate:** Proportion of workers who lived in a different state 1 year ago
- Numerator: Workers with MIGSP ≠ ST (different state 1 year ago)
- Denominator: All workers in sample

### Secondary Outcomes
1. **Employment rate:** Proportion employed (ESR = 1 or 2) among in-migrants
2. **Log wages:** ln(WAGP) for employed workers
3. **Out-migration rate:** For existing residents, probability of leaving state

## 7. Heterogeneity Analysis

We will examine effect heterogeneity by:

1. **Occupation type:**
   - High licensing burden: Cosmetologists, teachers, electricians
   - Low licensing burden (compact states): Nurses, physicians

2. **Demographics:**
   - Age groups: 25-34, 35-44, 45-60
   - Sex: Male, Female

3. **Origin state:**
   - In-migration from non-ULR states (should see effect)
   - In-migration from other ULR states (should see weaker effect)

## 8. Robustness Checks

1. **Exclude 2020:** To address COVID-19 confounding, re-estimate excluding calendar year 2020
2. **Triple-difference:** Use non-licensed workers within treatment states as additional control
3. **Placebo test:** Test for effects in years before ULR adoption (should find null)
4. **Alternative occupation definitions:** Vary which occupations are classified as "licensed"
5. **Border analysis:** Compare migration in border counties of ULR states vs. adjacent non-ULR states
6. **Synthetic control:** For Arizona (earliest adopter), construct synthetic control state

## 9. Identification Threats and Mitigation

| Threat | Severity | Mitigation |
|--------|----------|------------|
| COVID-19 pandemic (2020-2021) | High | Exclude 2020, robustness with 2017-2019 + 2022 only |
| Selection into ULR states | Medium | Event study pre-trends, state FEs |
| Other state policies | Medium | Control for minimum wage, EITC, tax rates |
| PUMS measures occupation, not license | Medium | Interpret as intent-to-treat on "licensed occupation workers" |
| Awareness lag | Low | Allow for dynamic effects in event study |

## 10. Statistical Inference

### Significance Thresholds
- Primary hypothesis: α = 0.05 (two-sided)
- Secondary hypotheses: α = 0.10 (exploratory)

### Multiple Testing
For heterogeneity analyses, we will report unadjusted p-values and note that these are exploratory. We will not claim significance for heterogeneous effects unless they pass Bonferroni correction for the number of subgroups tested.

### Power Analysis
With ~10,000 in-migrants per year in licensed occupations and 6 years of data:
- Detectable effect size (80% power, α=0.05): ~15% change in migration rate
- Based on baseline migration rate of ~3%, this corresponds to detecting a change of ~0.45 percentage points

## 11. Deviations from Pre-Analysis Plan

Any deviations from this pre-registered plan will be clearly documented in the paper with justification. Exploratory analyses not specified here will be labeled as such.

## 12. Timeline

1. Lock pre-analysis plan (this document)
2. Data collection from Census PUMS API
3. Data cleaning and sample construction
4. Primary analysis
5. Robustness checks
6. Paper writing
7. External review

---

**Commitment:** This pre-analysis plan documents our hypotheses and methods BEFORE seeing the data. All deviations will be reported.
