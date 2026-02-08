# Initial Research Plan

**Paper:** paper_96
**Date:** 2026-01-28
**Status:** Pre-registered (to be committed before data fetch)

---

## Research Question

Do state telehealth parity laws—which require private insurers to cover telehealth services on par with in-person care—increase mental health treatment utilization?

---

## Policy Background

### Telehealth Parity Laws

Beginning in the early 2010s, states began adopting "telehealth parity" laws requiring private health insurers to cover services delivered via telehealth. These laws vary in scope:

1. **Coverage parity:** Insurers must cover the same services via telehealth as they would cover in-person
2. **Payment parity:** Insurers must reimburse telehealth services at the same rate as in-person services

By 2019, approximately 30 states had some form of telehealth parity law. This paper focuses on the **pre-COVID period (2010-2019)** to avoid confounding from pandemic-era emergency telehealth expansions.

### Treatment Timing

| State | Parity Type | Effective Date | First Treated Year |
|-------|-------------|----------------|-------------------|
| (To be compiled from CCHPCA, NCSL) | | | |

**Treatment definition:** A state is "treated" in year $t$ if a telehealth parity law was in effect for the **full calendar year** $t$. This addresses partial-year exposure concerns.

---

## Identification Strategy

### Design

**Staggered Difference-in-Differences** using the Callaway-Sant'Anna (2021) estimator.

### Treatment

State adopts a telehealth parity law (coverage and/or payment parity for private insurers).

### Comparison Group

- **Primary:** Not-yet-treated states (states that adopt later in the sample)
- **Robustness:** Never-treated states (states that never adopt through 2019)

### Unit of Analysis

State-year

### Sample Period

2008-2019 (ensuring 5+ pre-treatment years for states adopting 2013+, while excluding COVID period)

### Estimator

Callaway-Sant'Anna group-time ATT with doubly robust estimation, aggregated to:
1. Overall ATT
2. Event-time dynamic effects
3. Cohort-specific effects

---

## Parallel Trends Assumption

The key identifying assumption is that mental health treatment utilization would have evolved similarly in treatment and control states absent the telehealth parity law.

### Supporting Arguments

1. Telehealth parity adoption was primarily driven by legislative processes and lobbying, not pre-existing mental health trends
2. Event study will verify parallel pre-trends (testing $H_0$: all pre-treatment coefficients = 0)
3. Callaway-Sant'Anna allows separate estimation by cohort, revealing heterogeneity

### Potential Threats

1. **Medicaid expansion:** States expanding Medicaid (2014+) may simultaneously experience mental health utilization changes
2. **Mental health parity enforcement:** Enhanced enforcement of federal MHPAEA may correlate with telehealth adoption
3. **Provider supply:** States with greater mental health provider shortages may both adopt telehealth laws and have constrained treatment growth
4. **Economic conditions:** Recessions/recoveries affect mental health and insurance coverage

### Mitigation Strategies

1. **Triple-difference:** Interact treatment with private insurance status (laws affect private insurance, not Medicare/Medicaid directly)
2. **Explicit controls:** Include Medicaid expansion indicator as covariate
3. **Event study:** Verify flat pre-trends
4. **Sensitivity analysis:** Rambachan-Roth bounds (HonestDiD) for violations of parallel trends

---

## Expected Effects and Mechanisms

### Primary Hypothesis

Telehealth parity laws increase the share of adults receiving mental health treatment.

### Mechanism

Telehealth reduces barriers to mental health care:
1. **Access:** Eliminates travel time and transportation costs
2. **Scheduling flexibility:** Enables sessions during lunch breaks, after hours
3. **Stigma reduction:** Patients can receive care in private settings
4. **Provider availability:** Expands geographic reach of mental health providers

### Expected Magnitude

Based on post-COVID telehealth adoption rates and historical telehealth growth:
- Modest effects expected: 1-3 percentage point increase in treatment rates
- Effects may be larger for states with greater baseline provider shortages

### Heterogeneity

Effects may be larger for:
- Rural states (greater baseline access barriers)
- States with payment parity (stronger financial incentives for providers)
- Later adopters (more mature telehealth infrastructure)

---

## Primary Outcome Variables

### Primary

**Share of adults receiving mental health treatment in past year**
- Source: National Survey on Drug Use and Health (NSDUH)
- State-level estimates available from SAMHSA

### Secondary

1. **Major depressive episode receiving treatment:** % of adults with MDE who received treatment
2. **Unmet mental health care needs:** % reporting unmet need for mental health care
3. **Serious mental illness treatment:** % of adults with SMI who received treatment

### Placebo

1. **Physical health care utilization:** Dental visits, general checkups (should not respond directly to telehealth mental health parity)
2. **Medicare population:** Federal program, not affected by state private insurance laws

---

## Data Sources

### Primary Outcome Data

**National Survey on Drug Use and Health (NSDUH)**
- Annual state-level estimates
- Coverage: All 50 states + DC
- Years: 2008-2019
- Key tables: State-level prevalence of mental health treatment, major depressive episode, serious mental illness
- Access: SAMHSA data portal

### Policy Data

**Center for Connected Health Policy (CCHPCA)**
- Telehealth parity law effective dates
- Distinction between coverage and payment parity
- Historical state-by-state data available

**National Conference of State Legislatures (NCSL)**
- Telehealth private insurance laws database
- Legislative history and effective dates

### Covariates

- **Medicaid expansion:** KFF state decisions database
- **Economic conditions:** BLS unemployment rates by state
- **Provider supply:** HRSA Area Health Resources Files (mental health providers per capita)

---

## Primary Specification

$$Y_{st} = \alpha_s + \gamma_t + \beta \cdot \text{Parity}_{st} + X_{st}'\delta + \epsilon_{st}$$

Where:
- $Y_{st}$ = % of adults receiving mental health treatment in state $s$, year $t$
- $\alpha_s$ = state fixed effects
- $\gamma_t$ = year fixed effects
- $\text{Parity}_{st}$ = 1 if state $s$ has telehealth parity law in full effect in year $t$
- $X_{st}$ = covariates (Medicaid expansion, unemployment rate)

### Preferred Estimator

Callaway-Sant'Anna group-time ATT with doubly robust estimation:
- Control group: Not-yet-treated
- Anticipation: 0 periods
- Base period: Universal (-1)

### Clustering

State-level (50 clusters)

---

## Robustness Checks

### Alternative Estimators

1. Sun-Abraham (2021) interaction-weighted estimator
2. de Chaisemartin-D'Haultfoeuille (2020)
3. Standard TWFE (for comparison, acknowledging bias with heterogeneous effects)

### Alternative Samples

1. Restrict to states adopting 2013+ (ensuring 5+ pre-treatment years)
2. Exclude states with only coverage (not payment) parity
3. Balance panel (exclude states with missing years)

### Alternative Outcomes

1. Log(treatment rate) instead of levels
2. Intensive margin: Treatment frequency conditional on any treatment
3. Alternative data: BRFSS mental health days (if available at state-year level)

### Sensitivity Analysis

1. **HonestDiD bounds:** Rambachan-Roth sensitivity to violations of parallel trends
2. **Leave-one-out:** Jackknife by state
3. **Placebo timing:** Artificially shift treatment dates backward

### Addressing Policy Heterogeneity

1. Separate treatment indicators for coverage-only vs. payment parity
2. Triple-difference interacting treatment with rural/urban
3. Cohort-by-cohort effects to assess early vs. late adopter differences

---

## Power Considerations

- **States:** 51 (including DC)
- **Treated states:** ~25-30 by 2019 (depending on definition)
- **Years:** 12 (2008-2019)
- **Observations:** ~600 state-years
- **Expected effect:** 1-3 pp increase in treatment rate
- **Baseline rate:** ~15% of adults receive any mental health treatment

With ~25 treated clusters and standard state-level variation, power should be adequate to detect effects of 1-2 pp at conventional significance levels.

---

## Timeline

1. Compile telehealth parity law effective dates from CCHPCA/NCSL
2. Fetch NSDUH state estimates for mental health treatment (2008-2019)
3. Construct treatment indicators with full-year exposure rule
4. Run event study to verify parallel pre-trends
5. Estimate Callaway-Sant'Anna ATT
6. Robustness checks and sensitivity analysis
7. Write paper

---

## Pre-registration Statement

This research plan was written and committed to git before any outcome data was fetched or analyzed. The hypotheses, estimands, and primary specification were specified ex ante.

---

## Files to Create

- `code/00_packages.R` — Load libraries, set themes
- `code/01_fetch_policy_data.R` — Compile treatment timing
- `code/02_fetch_outcome_data.R` — Download NSDUH state estimates
- `code/03_clean_data.R` — Construct analysis panel
- `code/04_main_analysis.R` — Callaway-Sant'Anna estimation
- `code/05_robustness.R` — Alternative specifications
- `code/06_figures.R` — Event study, descriptive figures
- `code/07_tables.R` — Regression tables
