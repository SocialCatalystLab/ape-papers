# Initial Research Plan: Noncompete Agreement Restrictions and Worker Mobility

**Paper ID:** 50
**Date:** 2026-01-19
**Method:** Difference-in-Differences

---

## Research Question

Do state laws restricting noncompete agreements increase worker mobility and wages?

## Policy Background

Noncompete agreements restrict workers' ability to leave for competitors. As of 2023, nearly one in five U.S. workers are bound by a noncompete. A growing body of evidence suggests noncompetes suppress wages, reduce job mobility, and stifle innovation, prompting states to restrict them.

### Recent State Actions (2021-2023)

| State | Effective Date | Type | Details |
|-------|---------------|------|---------|
| Minnesota | July 1, 2023 | **Full Ban** | First new full ban since Oklahoma (1890) |
| Oregon | January 1, 2022 | Income threshold + duration | Limited to 12 months; income ≥$100,533 |
| Illinois | January 1, 2022 | Income threshold | Banned for workers earning <$75,000 |
| Colorado | August 10, 2022 | Criminal penalties | Penalties for improper noncompetes |
| D.C. | April 1, 2022 | Near-complete ban | Only allowed for workers >$150k |
| Nevada | October 1, 2021 | Hourly worker ban | Banned for hourly workers; enforcement penalties |

### Control States

States with no restrictions on noncompete enforceability: ~12 states including TX, FL, GA, NC, SC, TN, AL, AR, etc.

## Identification Strategy

### Primary Analysis: Staggered DiD

Compare labor market outcomes in states that adopted noncompete restrictions (2021-2023) vs. never-treated control states, using pre-period 2018-2020 and post-period 2021-2024.

**Estimator:** Callaway-Sant'Anna (2021) with:
- Group-time ATT estimates
- Event study aggregation
- Never-treated and not-yet-treated as controls

### Robustness: Synthetic Control for Minnesota

Given Minnesota's clean full ban (July 2023), construct synthetic Minnesota from donor states and estimate treatment effect with placebo tests.

### Border Design (if data permits)

Compare counties on MN borders vs. adjacent WI/ND/SD/IA counties to address unobserved state trends.

## Hypotheses

**H1 (Mobility):** Noncompete restrictions increase job-to-job transitions.
- Expected: 5-15% increase in separation rates to other employers

**H2 (Wages):** Restrictions increase wages, especially for job changers.
- Expected: 2-5% increase in earnings for job changers

**H3 (Heterogeneity):** Effects concentrated in:
- High-skilled occupations (where noncompetes most common)
- Professional services and technology sectors
- Workers in middle of wage distribution

## Data Sources

### Primary: Census QWI (Quarterly Workforce Indicators)

- **Endpoint:** `api.census.gov/data/timeseries/qwi/sa`
- **Variables:**
  - `EmpS`: Stable employment (beginning-of-quarter)
  - `EarnS`: Stable earnings
  - `HirA`: Hires (all)
  - `Sep`: Separations
  - `TurnOvrS`: Turnover rate
- **Granularity:** State × Quarter × Industry × Demographics
- **Period:** 2018-Q1 through 2024-Q4 (if available)

### Secondary: ACS PUMS

- **Endpoint:** `api.census.gov/data/{year}/acs/acs1/pums`
- **Variables:** WAGP (wages), ESR (employment), JWTR (commute), INDP (industry)
- **Use:** Robustness on individual-level wage outcomes

## Sample Construction

### Treatment Definition

| Group | States | Treatment Date |
|-------|--------|----------------|
| Full Ban | MN | 2023-Q3 |
| Strong Restriction | DC | 2022-Q2 |
| Moderate Restriction | OR, IL, CO, NV | 2022-Q1 to 2022-Q3 |
| Never Treated | TX, FL, GA, NC, etc. | Never |

### Inclusion Criteria

- All private sector industries (NAICS 2-digit)
- All firm sizes
- All worker demographics
- Exclude: Government sector (not subject to noncompetes)

## Specification

### Primary (Callaway-Sant'Anna)

```r
library(did)

att_gt <- att_gt(
  yname = "turnover_rate",       # or log_earnings, hires_rate
  tname = "year_quarter",
  idname = "state",
  gname = "treatment_cohort",    # 0 for never-treated
  data = panel_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)
```

### Event Study Aggregation

```r
es <- aggte(att_gt, type = "dynamic", min_e = -8, max_e = 8)
```

## Robustness Checks

1. **Alternative controls:** Not-yet-treated as control
2. **Anticipation:** Allow 1-2 quarters anticipation
3. **Alternative outcomes:** Earnings levels, hire rates, separation rates
4. **Placebo treatment dates:** Test false treatment in 2019
5. **Synthetic control:** For Minnesota only
6. **Sensitivity analysis:** HonestDiD for parallel trends violations

## Expected Tables and Figures

### Figures
1. Map of noncompete law stringency by state (2023)
2. Event study: Job-to-job transition rates
3. Event study: Earnings for job changers
4. Synthetic control: Minnesota vs. synthetic Minnesota
5. Heterogeneity by industry

### Tables
1. Summary statistics by treatment status
2. Main DiD results (turnover, earnings)
3. Heterogeneity by industry and occupation
4. Robustness checks
5. Synthetic control estimates

## Timeline

1. Data fetch and cleaning: ~2 hours
2. Main analysis: ~3 hours
3. Robustness checks: ~2 hours
4. Paper writing: ~4 hours
5. Review and revision: ~3 hours

## Potential Challenges

1. **Few treated units:** Minnesota is the only full ban state (2023). Mitigate with synthetic control and border design.

2. **Compliance/enforcement:** Laws may not change actual noncompete use immediately. Pre-2022 signing of agreements may persist.

3. **Contemporaneous shocks:** COVID recovery (2021-2022) and tight labor markets may confound. Use never-treated controls and event study to assess.

4. **Data availability:** QWI may not have 2024 data yet. Check API and adjust period as needed.

---

**Commit this plan before proceeding to data fetch.**
