# Pre-Analysis Plan

## Study Title
**The Labor Market Effects of Hawaii's Kupuna Caregivers Program: A Difference-in-Differences Analysis**

---

## 1. Research Question

Did Hawaii's Kupuna Caregivers Program (enacted 2017, implemented January 2018) reduce labor force exit among working-age adults in multigenerational households compared to similar households in control states?

---

## 2. Policy Background

### Treatment
**Hawaii's Kupuna Caregivers Program** (Act 102, 2017):
- First state-level program in the U.S. providing financial assistance to working caregivers of elderly relatives
- Provides up to $70/day (later $210/week) to employed caregivers for contracted care services (adult day care, respite, home care)
- Eligibility requires: (1) caregiver works at least 30 hours/week, (2) unpaid primary caregiver for an elderly relative, (3) Hawaii residency
- Implementation date: January 1, 2018
- Program size: ~110-150 caregivers served annually (capacity-constrained)

### Mechanism
The program reduces the opportunity cost of maintaining employment by subsidizing respite care services. Working caregivers can use funds to pay for adult day care or home health aides while they work, reducing the need to exit the labor force to provide full-time unpaid care.

---

## 3. Identification Strategy

### Design: Difference-in-Differences (DiD)

**Treatment Group:** Adults aged 30-64 in Hawaii residing in multigenerational households (R65=1 or MULTG=1)

**Control Group:** Adults aged 30-64 in control states residing in multigenerational households

**Pre-Period:** 2015-2017 (3 years)
**Post-Period:** 2018-2022 (5 years)

### Control State Selection

We select control states that are:
1. Demographically similar to Hawaii (racial composition, age distribution)
2. Similar labor market structures (tourism-dependent, service economy)
3. Did NOT implement similar caregiver support programs during the study period

**Primary control states:**
- California (large Asian/Pacific Islander population, tourism)
- Nevada (tourism-dependent economy)
- Arizona (retirement population, similar demographics)
- Washington (Pacific state, diverse economy)

**Robustness check:** All non-treatment states, synthetic control

### Assumptions

1. **Parallel Trends:** Absent treatment, employment trends in Hawaii multigenerational households would have followed the same trajectory as control states
2. **No Anticipation:** Individuals did not adjust labor supply in 2017 anticipating the 2018 program
3. **SUTVA:** No spillovers across state borders (Hawaii's isolation helps)
4. **No Confounding Policies:** No other major caregiver/employment policies differentially affected Hawaii during this period

---

## 4. Data

### Source
Census PUMS (ACS 1-year), 2015-2022

### Sample
- Adults aged 30-64
- In multigenerational households (R65=1 or MULTG=1)
- Hawaii (ST=15) vs. control states (ST=06, 04, 32, 53)
- Excludes: institutionalized population, group quarters

### Key Variables

| Variable | Description | Role |
|----------|-------------|------|
| **ESR** | Employment status | Primary outcome |
| **WKHP** | Usual hours worked per week | Secondary outcome |
| **WAGP** | Wage/salary income | Secondary outcome |
| **MULTG** | Multigenerational household | Sample restriction |
| **R65** | Presence of person 65+ in HH | Sample restriction |
| **ST** | State FIPS code | Treatment assignment |
| **AGEP** | Age | Sample restriction, covariate |
| **SEX** | Sex | Heterogeneity analysis |
| **RAC1P** | Race | Covariate |
| **SCHL** | Educational attainment | Covariate |
| **MAR** | Marital status | Covariate |
| **PWGTP** | Person weight | Weighting |

### Sample Size Estimate

Based on ACS sample sizes:
- Hawaii: ~15,000-20,000 total adults per year
- ~15-20% in multigenerational/elderly-present households
- Expected: ~2,500-4,000 Hawaii treatment observations per year
- Control states: ~50,000-100,000 comparable observations per year

---

## 5. Outcome Variables

### Primary Outcome
**Labor Force Participation (LFP):** Binary indicator = 1 if ESR ∈ {1, 2, 3}, else 0
- Employed (ESR=1,2) or unemployed looking for work (ESR=3) = in labor force
- Not in labor force (ESR=6) = out of labor force

### Secondary Outcomes
1. **Employment:** Binary = 1 if ESR ∈ {1, 2}
2. **Hours Worked:** WKHP (conditional on employed), treated as 0 for non-employed
3. **Weekly Hours > 30:** Binary indicator for meeting program eligibility threshold
4. **Log Wages:** ln(WAGP) conditional on positive wages

---

## 6. Empirical Specification

### Main Model

$$Y_{ist} = \alpha + \beta \cdot (Hawaii_s \times Post_t) + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}$$

Where:
- $Y_{ist}$ = outcome for individual $i$ in state $s$ at time $t$
- $Hawaii_s$ = indicator for Hawaii residence
- $Post_t$ = indicator for years 2018-2022
- $\gamma_s$ = state fixed effects
- $\delta_t$ = year fixed effects
- $X_{ist}$ = individual covariates (age, age², sex, race, education, marital status)
- Standard errors clustered at state level

**Coefficient of interest:** $\beta$ captures the average treatment effect on the treated (ATT) under parallel trends

### Event Study Specification

$$Y_{ist} = \alpha + \sum_{k=-3}^{4} \beta_k \cdot (Hawaii_s \times \mathbf{1}[t = 2017 + k]) + \gamma_s + \delta_t + X_{ist}'\theta + \varepsilon_{ist}$$

With 2017 as the reference year (k=0 omitted). Event study tests pre-trends ($\beta_{-3}, \beta_{-2}$ should equal zero) and traces out dynamic treatment effects.

---

## 7. Hypotheses

### Primary Hypothesis
**H1:** The Kupuna Caregivers Program increased labor force participation among adults in multigenerational households in Hawaii relative to control states.

**Expected effect size:** 1-3 percentage point increase in LFP (based on related literature on caregiver support programs)

### Secondary Hypotheses
**H2:** Effects are concentrated among women (who are disproportionately caregivers)

**H3:** Effects are larger for households with older elderly (75+) vs. younger elderly (65-74)

**H4:** The program increased hours worked, particularly maintaining workers above the 30-hour eligibility threshold

---

## 8. Heterogeneity Analysis (Pre-Specified)

We will examine treatment effect heterogeneity by:

1. **Gender (SEX):** Female vs. male
2. **Age of potential caregiver:** 30-44 vs. 45-54 vs. 55-64
3. **Education (SCHL):** Less than BA vs. BA+
4. **Race/Ethnicity:** Asian/Pacific Islander vs. Other (given Hawaii's demographic composition)
5. **Marital Status (MAR):** Married vs. not married

For each subgroup, we report the DiD coefficient and test for heterogeneity using interaction terms.

---

## 9. Robustness Checks

1. **Alternative control groups:**
   - All U.S. states except Hawaii
   - Pacific states only (CA, WA, OR, AK)
   - Synthetic control (weighted combination of all states)

2. **Sample restrictions:**
   - Women only (primary caregivers)
   - Ages 45-64 only (more likely to have elderly parents)
   - R65=1 only (stricter definition of elderly presence)

3. **Placebo tests:**
   - Households WITHOUT elderly (R65=0, MULTG=0) - should find no effect
   - Pre-treatment placebo: artificially assign treatment to 2015

4. **Alternative outcomes:**
   - Part-time employment (WKHP < 35)
   - Self-employment (COW indicator)
   - Public assistance receipt (PAP)

5. **Inference:**
   - Wild cluster bootstrap (few clusters)
   - Permutation test across states

---

## 10. Limitations (Pre-Acknowledged)

1. **Intent-to-Treat on Proxy Group:** PUMS does not identify actual program participants or caregiving status. We estimate effects on a proxy group (multigenerational households). Estimates represent ITT effects on a broader population.

2. **Single Treated Unit:** Hawaii is the only treated state, limiting ability to separate Hawaii-specific shocks from treatment effects. We address this through careful control group selection and placebo tests.

3. **Small Program Scale:** The program serves only ~100-150 caregivers annually. Population-level effects may be attenuated. However, program effects on participant outcomes could be substantial even if population effects are modest.

4. **Confounding Events:** COVID-19 pandemic (2020-2022) severely impacted Hawaii's tourism-dependent economy. We will examine 2018-2019 effects separately from 2020-2022.

5. **Measurement Error:** Multigenerational household status is an imperfect proxy for caregiving. Some members in such households are not caregivers; some caregivers live in separate households.

---

## 11. Analysis Code

All analysis will be conducted in Python. Key packages:
- `statsmodels` for regression
- `linearmodels` for panel fixed effects
- `pandas` for data manipulation
- Standard library for API queries

Code will be saved in `output/paper_1/data/analysis.py` and is fully reproducible.

---

## 12. Expected Timeline

1. Data collection: Query PUMS API for 2015-2022, all required states
2. Data cleaning: Construct sample, create variables
3. Descriptive statistics: Summary tables, balance checks
4. Main analysis: DiD and event study estimates
5. Robustness: All pre-specified checks
6. Paper writing

---

## 13. Commitment

This pre-analysis plan is registered BEFORE examining the outcome data. We commit to:
- Reporting all pre-specified analyses regardless of results
- Clearly labeling any post-hoc analyses as exploratory
- Not changing the primary hypothesis or specification based on results

**Locked:** [To be timestamped upon git commit]
