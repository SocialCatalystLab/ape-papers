# Initial Research Plan

**Paper:** State Automatic IRA Mandates and Retirement Savings Participation
**Date:** 2026-01-21
**Method:** Difference-in-Differences with Staggered Adoption

---

## Research Question

Do state-mandated automatic IRA programs increase retirement savings participation among private-sector workers, particularly those at small employers who previously lacked access to employer-sponsored plans?

## Policy Background

Beginning in 2017, states began implementing mandatory automatic enrollment IRA programs requiring employers without existing retirement plans to enroll their employees in state-facilitated retirement savings accounts. These programs aim to address the "coverage gap" — roughly 50% of private-sector workers lack access to employer-sponsored retirement plans.

### Treatment States and Timing

| State | Program Name | Program Launch | Full Mandate |
|-------|-------------|----------------|--------------|
| Oregon | OregonSaves | July 2017 | July 2023 |
| Illinois | Illinois Secure Choice | November 2018 | November 2023 |
| California | CalSavers | July 2019 | Dec 2025 |
| Connecticut | MyCTSavings | March 2021 | April 2022 |
| Maryland | MarylandSaves | Sept 2022 | 2024 |
| Colorado | Colorado SecureSavings | March 2023 | 2025 |
| Virginia | Virginia Saves | July 2023 | 2025 |
| Maine | Maine Retirement Savings | 2024 | 2025 |
| Delaware | Delaware Saves | 2024 | 2025 |
| New Jersey | NJ Secure Choice | 2024 | 2026 |
| Vermont | Green Mountain Secure | 2024 | 2025 |

### Phased Implementation

Most programs phase in by employer size:
- Phase 1: 100+ employees
- Phase 2: 50-99 employees
- Phase 3: 25-49 employees
- Phase 4: 10-24 employees
- Phase 5: 5-9 employees
- Final: 1-4 employees (varies by state)

## Identification Strategy

### Primary Specification

Use Callaway-Sant'Anna (2021) difference-in-differences estimator to account for staggered adoption and treatment effect heterogeneity:

$$ATT(g,t) = E[Y_{it}(g) - Y_{it}(0) | G_i = g]$$

Where:
- $G_i$ = first treatment period for unit $i$ (0 if never-treated)
- $Y_{it}(g)$ = potential outcome under treatment starting at $g$
- $Y_{it}(0)$ = potential outcome under never-treated

### Treatment Definition

**Preferred:** State-year treatment indicator, activated in the year the program launches for the largest employer tranche (typically 100+ employees). This captures the "intent-to-treat" effect of state adoption.

**Robustness:** Worker-level treatment based on employer size and state phase timing (requires employer size in CPS data).

### Outcome Variable

**Primary Outcome:** Binary indicator for whether worker has any retirement plan coverage (pension or retirement savings plan through current employer).

**CPS ASEC Variables:**
- PENSION: Included in employer pension/retirement plan
- INCLUGH: Health insurance from employer (for balance check)
- FIRMSIZE: Employer size (for heterogeneity)

### Sample Restrictions

1. Private-sector wage and salary workers (exclude government, self-employed)
2. Ages 18-64
3. Years 2010-2024 (ensuring 7+ pre-periods before Oregon's 2017 adoption)
4. Exclude workers at firms with 500+ employees (likely already have coverage)

### Parallel Trends

The key identifying assumption is that retirement plan coverage trends would have been parallel across treatment and control states absent the policy. We test this via:

1. Event study specification showing pre-treatment coefficients near zero
2. Comparison of pre-treatment trends in observables (employment, wages, demographics)
3. Rambachan-Roth (2023) sensitivity analysis to violations of parallel trends

## Expected Effects and Mechanisms

### Theoretical Predictions

1. **Direct Effect:** Workers at employers newly required to offer auto-IRA should show increased retirement plan participation
2. **Magnitude:** Administrative data from OregonSaves shows ~70% of eligible workers remain enrolled after auto-enrollment, suggesting large potential effects
3. **Heterogeneity:** Larger effects expected for workers at small employers, younger workers, lower-income workers

### Mechanisms

1. **Access channel:** Mandates create access where none existed
2. **Automatic enrollment:** Default enrollment overcomes inertia
3. **Payroll deduction:** Reduces transaction costs of saving

### Potential Null or Negative Results

1. **Crowdout:** If some employers already offered plans not captured in CPS, effects may be attenuated
2. **Opt-out:** High opt-out rates could reduce detected effects
3. **Measurement error:** CPS asks about employer plans; auto-IRA is technically an individual IRA with payroll deduction, which may be differently reported

## Robustness Checks

1. **Placebo test:** Estimate effects on workers at large employers (500+) who should be unaffected
2. **Alternative control groups:** (a) Never-treated states only, (b) Not-yet-treated states
3. **Synthetic control:** For California (largest state, big tech sector)
4. **Border county design:** Compare workers in adjacent counties across state borders
5. **Triple-difference:** Compare workers at small vs. large employers within treated states

## Data Requirements

### IPUMS-CPS ASEC

**Years:** 2010-2024 (15 years)
**Variables:**
- YEAR, STATEFIP (geography/time)
- AGE, SEX, RACE, EDUC, MARST (demographics)
- EMPSTAT, CLASSWKR, IND, OCC (employment)
- PENSION, INCLUGH (outcomes)
- FIRMSIZE (heterogeneity)
- INCTOT, INCWAGE, HHINCOME (controls)
- ASECWT (weights)

**Sample Size:** Approximately 1.5-2 million observations per year from ASEC, ~3-4 million working-age workers in analysis sample across all years.

### External Validation Data

- OregonSaves enrollment statistics (state reports)
- Illinois Secure Choice enrollment statistics
- CalSavers enrollment statistics

## Analysis Plan

### Primary Results

1. **Aggregate ATT:** Average treatment effect across all post-treatment periods
2. **Event study:** Dynamic effects by year relative to treatment
3. **Group-time effects:** Treatment effects by cohort and calendar time

### Heterogeneity

1. By employer size (small vs. medium)
2. By age (young vs. prime-age vs. near-retirement)
3. By prior coverage (low-coverage industries vs. high-coverage)
4. By education/income

### Figures

1. Treatment adoption map (choropleth showing rollout timing)
2. Parallel trends: Pre-treatment retirement coverage by treatment status
3. Event study: Dynamic treatment effects
4. Heterogeneity: Effects by employer size/demographics

### Tables

1. Summary statistics by treatment status
2. Main DiD results (Callaway-Sant'Anna)
3. Robustness: Alternative specifications and samples
4. Heterogeneity: Subgroup analysis

## Timeline and Milestones

1. **Data extraction:** Submit IPUMS extract request
2. **Descriptive analysis:** Summary statistics, trends plots
3. **Main analysis:** Callaway-Sant'Anna estimation
4. **Robustness:** Alternative specifications
5. **Paper writing:** Draft all sections
6. **Figures:** Create publication-quality exhibits

---

*This plan will not be modified after data collection begins. Working updates will be recorded in research_plan.md.*
