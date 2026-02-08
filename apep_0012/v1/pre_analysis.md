# Pre-Analysis Plan: Universal Occupational Licensing Recognition and Employment

**Study ID:** APEP-ULR-2026
**Date:** 2026-01-17
**Status:** Pre-registration (prior to data analysis)

---

## 1. Research Question

**Primary Question:** Did state adoption of universal occupational licensing recognition laws increase employment and labor force participation among interstate migrants in licensed occupations?

**Secondary Questions:**
1. Did effects vary by occupation type (healthcare vs. trades vs. personal services)?
2. Were effects concentrated among recent movers (moved within past year)?
3. Did effects differ by prior state licensing stringency?

---

## 2. Policy Background

### 2.1 Universal Licensing Recognition Laws

Universal occupational licensing recognition (ULR) laws allow professionals licensed in one state to practice in another without full re-licensure. These laws emerged rapidly between 2019-2024 as states sought to reduce barriers to interstate labor mobility.

**Key features of ULR laws:**
- Licensed professionals can practice upon demonstrating valid license from another state
- Typically require "good standing" in originating state
- May include background check requirements
- Often exclude certain high-risk occupations (e.g., physicians, attorneys)

**State adoption timeline (as of May 2024):**
- 2019: Arizona (first comprehensive ULR)
- 2020-2021: Montana, Pennsylvania, Utah, others
- 2022-2023: Colorado, Florida, Ohio, Virginia, others
- 2024: Georgia, Indiana, Louisiana, Nebraska, others
- **Total: 26 states with ULR laws**

### 2.2 Theoretical Predictions

**Positive employment effects (reduced barriers):**
- Lower transaction costs for interstate moves
- Faster re-employment after relocation
- Reduced time unemployed while awaiting license transfer

**Potential null effects:**
- Licensing was already reciprocal for many occupations
- Movers in licensed occupations may have other relocation barriers
- Implementation lags may delay effects

**Negative effects (unlikely but possible):**
- Increased competition may reduce wages for incumbent workers
- Quality concerns could lead to increased scrutiny

---

## 3. Identification Strategy

### 3.1 Design Overview: Staggered Difference-in-Differences

We exploit the staggered adoption of ULR laws across states, comparing changes in outcomes for licensed-occupation workers in states that adopted ULR vs. states that never adopted (through 2023).

**Treatment:** State adoption of universal licensing recognition law
**Treatment timing:** Varies by state (2019-2024)
**Control group:** Never-treated states (as of 2023 ACS data)

### 3.2 Why Modern DiD Methods Are Required

With staggered adoption, traditional two-way fixed effects (TWFE) estimators can be biased if treatment effects are heterogeneous across cohorts or time (Goodman-Bacon 2021; de Chaisemartin & D'Haultfoeuille 2020). We therefore use:

**Primary estimator:** Callaway & Sant'Anna (2021)
- Uses never-treated units as controls
- Produces cohort-time specific ATT estimates
- Aggregates to overall ATT with proper weighting

**Alternative estimator:** Sun & Abraham (2021) interaction-weighted approach

### 3.3 Treatment Definition

**Treated states:** States that adopted ULR laws, coded by effective date:
- Arizona (2019), Montana (2020), Pennsylvania (2021), Utah (2021)
- Colorado (2022), Florida (2022), Ohio (2022), Virginia (2022)
- Georgia (2023), Indiana (2023), Louisiana (2023), others

**Never-treated states:** States without ULR as of December 2023
- California, New York, Texas, Illinois (major states)
- Approximately 24 states serve as controls

### 3.4 Sample Stratification

**Primary analysis:** Interstate movers in licensed occupations
- MIG = 1 (moved from different state in past year)
- Occupation in licensed category (see Section 4.3)

**Secondary analysis:** All workers in licensed occupations
- Captures entry effects and incumbent effects

**Placebo:** Workers in non-licensed occupations
- Should show no effect if identification is valid

---

## 4. Data Sources and Sample

### 4.1 Primary Data: Census ACS PUMS

- **Years:** 2017-2023 (1-year ACS)
- **Geographic unit:** State (ST)
- **Key variables:**
  - ST: State FIPS code
  - MIG: Mobility status (1=different state, 2=different county, 3=same county, 4=abroad)
  - MIGSP: Migration state (origin state for movers)
  - OCCP: Occupation code
  - ESR: Employment status
  - WKHP: Usual hours worked per week
  - WAGP: Wages and salary income
  - PWGTP: Person weight
  - AGEP, SEX, RAC1P, SCHL: Demographics

### 4.2 Sample Restrictions

- Ages 25-64 (prime working age, past education completion)
- Employed or unemployed (ESR 1-3), excluding not in labor force
- Non-missing occupation code
- Private sector or state/local government workers

### 4.3 Licensed Occupation Classification

Using OCCP codes, we identify occupations subject to state licensing:

**Healthcare (OCCP 3000-3600):**
- 3000-3010: Physicians, surgeons (excluded - separate boards)
- 3030-3050: Dentists, optometrists (excluded)
- 3100-3258: Nurses (RN, LPN)
- 3310-3420: Health technicians
- 3500-3545: Health aides, therapists

**Education (OCCP 2200-2340):**
- 2200-2310: Teachers (K-12)
- 2320-2340: Other educational workers

**Personal services (OCCP 4500-4540):**
- 4500-4530: Barbers, hairdressers, cosmetologists

**Trades (OCCP 6200-6800):**
- 6200-6260: Electricians
- 6400-6442: Plumbers, pipefitters
- 6500-6530: Other construction trades

**Excluded from treatment group:**
- Physicians, lawyers, accountants (specialized licensing)
- Federal employees (not subject to state licensing)

### 4.4 Expected Sample Size

Based on ACS sample sizes:
- Interstate movers (all occupations): ~2 million person-years
- Interstate movers in licensed occupations: ~400,000 person-years
- Per treated state-year: ~5,000-15,000 observations
- Never-treated states: ~150,000 observations per year

---

## 5. Outcome Variables

### 5.1 Primary Outcomes

| Variable | Definition | ACS Variable |
|----------|------------|--------------|
| **Employment rate** | Employed indicator | ESR = 1 or 2 |
| **Weeks worked** | Weeks worked in past 12 months | WKWN |
| **Hours worked** | Usual hours per week | WKHP |

### 5.2 Secondary Outcomes

| Variable | Definition | Notes |
|----------|------------|-------|
| **Log wages** | Log(WAGP) | Conditional on employment |
| **Full-time employment** | WKHP >= 35 | Intensive margin |
| **In labor force** | ESR in (1,2,3) | Extensive margin including unemployed |

### 5.3 Outcome Timing

All outcomes refer to the **survey year** (when ACS was collected). Treatment assignment is based on whether the state had adopted ULR by the start of that calendar year.

---

## 6. Hypotheses and Expected Effect Sizes

### 6.1 Primary Hypotheses

**H1 (Employment):** ULR adoption increases employment rates among interstate movers in licensed occupations.
- Direction: Positive
- Magnitude: 2-5 percentage point increase based on licensing barrier literature
- Prior: Occupational licensing reduces employment by ~4% (Nature 2025 study); removing barriers should partially reverse this

**H2 (Hours):** ULR adoption increases hours worked among employed movers.
- Direction: Positive (or null)
- Magnitude: 0.5-2 hours per week
- Rationale: Faster re-employment means less time in marginal/part-time work

**H3 (Wages):** ULR adoption has no effect or small positive effect on wages.
- Direction: Null or slightly positive
- Magnitude: 0-3%
- Rationale: Reduced job search time allows better matching; no direct wage mechanism

### 6.2 Heterogeneity Hypotheses

**H4:** Effects are larger for occupations with historically low license portability (cosmetologists, electricians, teachers) than healthcare workers (who often had reciprocity agreements)

**H5:** Effects are larger for movers from states with stricter licensing requirements

**H6:** Effects are concentrated in the first year post-adoption (as pipeline of previously-blocked movers enters)

---

## 7. Statistical Analysis

### 7.1 Callaway & Sant'Anna Estimator

**Group-time ATT:**
For each adoption cohort g and time period t:
$$ATT(g,t) = E[Y_{it}(g) - Y_{it}(\infty) | G_i = g]$$

Where:
- $Y_{it}(g)$ is the potential outcome for units treated at time g
- $Y_{it}(\infty)$ is the potential outcome under never-treatment
- $G_i$ is the treatment cohort for unit i

**Aggregation to overall ATT:**
$$ATT^{simple} = \sum_g \sum_{t \geq g} w_{g,t} \cdot ATT(g,t)$$

Using equal-weighted average across cohort-time cells, or weighted by group size.

### 7.2 Event Study Specification

For dynamic effects, we estimate:
$$ATT(e) = \sum_g w_g \cdot ATT(g, g+e)$$

Where e is the event-time (years since adoption), and we plot estimates for e = -3, -2, -1, 0, 1, 2, 3, ...

Pre-period coefficients (e < 0) test parallel trends assumption.

### 7.3 Implementation Details

- All regressions weighted by PWGTP (person weight)
- Standard errors clustered at state level
- Event study window: e in {-3, ..., +4}
- Covariates: Age, sex, race, education, marital status (interacted with year)
- Never-treated states as comparison group

### 7.4 Software

Using R package `did` (Callaway & Sant'Anna) or Stata `csdid` command.

---

## 8. Robustness Checks

### 8.1 Alternative Estimators

1. **Sun & Abraham (2021):** Interaction-weighted estimator
2. **Borusyak, Jaravel & Spiess (2024):** Imputation-based estimator
3. **TWFE (for comparison):** To document potential bias

### 8.2 Alternative Control Groups

1. **Not-yet-treated:** Include states that adopt after 2023 as controls
2. **Neighboring states:** Geographic proximity matching
3. **Synthetic control:** For leading adopter states (Arizona)

### 8.3 Placebo Tests

1. **Non-licensed occupations:** Estimate same model for managers, sales workers, administrative support
2. **Non-movers:** Estimate for workers who did not move interstate
3. **Pre-trends:** Event study coefficients for e = -3, -2, -1 should be zero

### 8.4 Sensitivity Analyses

1. **Occupation classification:** Vary which occupations are considered "licensed"
2. **Sample restrictions:** Include/exclude part-time workers, age restrictions
3. **Covariates:** With and without demographic controls
4. **State-level controls:** Include unemployment rate, GDP growth

---

## 9. Limitations

### 9.1 Identification Challenges

1. **Treatment measurement error:** "Licensed occupation" is an imperfect proxy; some workers in coded occupations may not need licenses
2. **Policy heterogeneity:** ULR laws differ across states in scope, exceptions, implementation
3. **Non-random adoption:** States adopting ULR may differ systematically; parallel trends may not hold
4. **Spillovers:** Effects in treated states may affect migration patterns from control states

### 9.2 Data Limitations

1. **Occupation coding:** OCCP is employer-reported; may not perfectly identify licensed workers
2. **Migration timing:** ACS captures "moved in past year" but not exact date; treatment timing is imprecise
3. **Cross-sectional:** Cannot observe same individuals over time; cannot track individual-level effects
4. **Outcome timing:** Wages/employment measured at survey time; may not capture immediate effects

### 9.3 External Validity

Results specific to 2019-2023 period and adopting states. Effects may differ for:
- Different occupations not studied
- Future adopting states with different labor markets
- Long-run effects beyond study period

---

## 10. Timeline

1. **Data acquisition:** Fetch ACS PUMS 2017-2023 for all states
2. **Variable construction:** Create treatment, outcome, and covariate variables
3. **Descriptive statistics:** Sample sizes, means, pre-trends
4. **Main analysis:** Callaway & Sant'Anna estimation
5. **Event study:** Dynamic effects visualization
6. **Heterogeneity:** By occupation, origin state, demographics
7. **Robustness:** Alternative estimators, placebo tests
8. **Draft writing:** Results, discussion, conclusions

---

## 11. References

- Baker, A., Callaway, B., Cunningham, S., Goodman-Bacon, A., & Sant'Anna, P. H. C. (2025). Difference-in-Differences Designs: A Practitioner's Guide. arXiv:2503.13323.
- Callaway, B., & Sant'Anna, P. H. C. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*, 225(2), 200-230.
- de Chaisemartin, C., & D'Haultfoeuille, X. (2020). Two-way fixed effects estimators with heterogeneous treatment effects. *American Economic Review*, 110(9), 2964-2996.
- Goodman-Bacon, A. (2021). Difference-in-differences with variation in treatment timing. *Journal of Econometrics*, 225(2), 254-277.
- Sun, L., & Abraham, S. (2021). Estimating dynamic treatment effects in event studies with heterogeneous treatment effects. *Journal of Econometrics*, 225(2), 175-199.
- Roth, J., Sant'Anna, P. H. C., Bilinski, A., & Poe, J. (2023). What's trending in difference-in-differences? A synthesis of the recent econometrics literature. *Journal of Econometrics*, 235(2), 2218-2244.

---

## 12. Declaration

This pre-analysis plan was written before examining the outcome data. The analysis will follow this plan, and any deviations will be documented and justified.

**Locked:** [To be signed by preanalysis.py lock command]
