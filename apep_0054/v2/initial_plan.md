# Initial Research Plan: Salary Transparency Laws and the Gender Wage Gap

**Created:** 2026-01-22
**Status:** Locked (do not modify after creation)

---

## Research Question

Do state salary transparency laws—requiring employers to disclose salary ranges in job postings—affect:
1. Overall wage levels for workers?
2. The gender wage gap?

## Policy Context

Between 2021 and 2025, at least 14 U.S. states enacted laws requiring employers to disclose salary ranges in job postings. This staggered adoption provides a natural experiment for evaluating wage effects using difference-in-differences methods.

### Treatment Timeline

| State | Effective Date | Income Year | Employer Threshold |
|-------|----------------|-------------|-------------------|
| Colorado | Jan 1, 2021 | 2021 | All |
| Connecticut | Oct 1, 2021 | 2022 | All |
| Nevada | Oct 1, 2021 | 2022 | All |
| Rhode Island | Jan 1, 2023 | 2023 | All |
| California | Jan 1, 2023 | 2023 | 15+ |
| Washington | Jan 1, 2023 | 2023 | 15+ |
| New York | Sep 17, 2023 | 2024 | 4+ |
| Hawaii | Jan 1, 2024 | 2024 | 50+ |
| Maryland | Oct 1, 2024 | 2025 | All |

*Note: Illinois, Minnesota, New Jersey, Massachusetts, Vermont effective 2025—outside our data window*

## Identification Strategy

### Primary Design: Staggered Difference-in-Differences

**Estimator:** Callaway-Sant'Anna (2021) group-time ATT with never-treated states as controls.

**Treatment:** Binary indicator for state having an active salary transparency law (with income year alignment as specified in conditions.md).

**Outcome:**
- Primary: Log hourly wages (INCWAGE / annual hours)
- Secondary: Raw gender wage gap (male median - female median, by state-year)

### Triple-Difference Extension

To address selection concerns, we implement a DDD design:

**DDD1: State × Time × Gender**
- Tests whether transparency benefits women more (narrows gender gap)
- β(Treated × Post × Female) > 0 indicates gap narrowing

**DDD2: State × Time × Occupation Bargaining Intensity**
- Tests Cullen & Pakzad-Hurson mechanism
- β(Treated × Post × HighBargain) < 0 indicates larger wage decline in high-bargaining occupations

## Data Sources

### Primary: IPUMS CPS ASEC (2015-2024)

**Variables:**
- INCWAGE: Annual wage/salary income (income from prior calendar year)
- UHRSWORKLY: Usual hours worked per week
- SEX: Gender
- AGE: Age in years
- EDUC: Education level
- OCC2010: Detailed occupation code
- IND: Industry code
- STATEFIP: State FIPS code
- ASECWT: Person weight

**Sample Restrictions:**
- Ages 25-64 (working-age adults)
- Employed wage/salary workers (CLASSWKR = private or government)
- Positive wage income
- Full-time or part-time workers

**Sample Size:** ~70,000 per year × 10 years = ~700,000 person-year observations

### Auxiliary: State-Level Controls

- State minimum wage (DOL)
- State unemployment rate (BLS LAUS)
- Salary history ban indicators (legal databases)

### Occupation Classification: O*NET

- Telework feasibility scores (for spillover sensitivity)
- Occupation characteristics for bargaining intensity classification

## Specifications

### Main Specification (DiD)

```
log(hourly_wage)_ist = β(Transparency_st) + γ_s + δ_t + X'_ist θ + ε_ist
```

Where:
- i = individual, s = state, t = year
- Transparency_st = 1 if state s has active transparency law in income year t
- γ_s = state fixed effects
- δ_t = year fixed effects
- X_ist = individual controls (age, education, occupation, industry)

### Gender Gap Specification (DDD)

```
log(wage)_ist = β1(Trans_st) + β2(Trans_st × Female_i) + β3(Female_i) + FE + controls
```

Key coefficient: β2 (differential effect for women; positive = gap narrowing)

### Event Study

```
log(wage)_ist = Σ_k β_k (1{k periods from treatment} × Treated_s) + γ_s + δ_t + controls
```

Event time: k ∈ {-5, -4, -3, -2, -1, 0, 1, 2, 3}
Reference period: k = -1

## Expected Effects

Based on Cullen & Pakzad-Hurson (2023) and economic theory:

1. **Overall wages:** Ambiguous direction
   - ↓ Reduced worker bargaining power (firms commit to posted ranges)
   - ↑ Better outside options from information (workers know market rates)
   - Net effect likely small or slightly negative

2. **Gender wage gap:** Expected to narrow
   - Women historically have less salary information
   - Transparency provides equal information baseline
   - Reduces negotiation penalty for women

3. **Heterogeneity:**
   - Larger effects in high-bargaining occupations
   - Smaller effects in unionized sectors (already have wage posting)
   - Larger effects for new hires vs. incumbents

## Robustness Checks

1. **Alternative estimators:** Sun-Abraham (2021), Goodman-Bacon decomposition
2. **HonestDiD sensitivity:** Rambachan-Roth bounds on pre-trends
3. **State-specific trends:** Add state × linear time trends
4. **Concurrent policy controls:** Include minimum wage, unemployment rate
5. **Border state controls:** Indicator for states bordering treated states
6. **Telework restriction:** Limit to low-telework occupations (SUTVA check)
7. **Employer size heterogeneity:** Exploit threshold variation (15+, 50+)

## Exposure Alignment

**Who is treated:**
- Workers in states with active transparency laws
- Primarily affects job seekers and new hires
- Incumbent workers affected through anchoring and renegotiation

**Measurement alignment:**
- CPS ASEC captures all wage/salary workers regardless of tenure
- Effect on incumbents may be attenuated
- Consider new hire proxy (tenure < 1 year) as sensitivity

## Power Assessment

- **Pre-treatment periods:** 6-10 years depending on cohort (Strong)
- **Treated clusters:** 9 treated states with income year ≤ 2024 (Marginal-Strong)
- **Post-treatment periods:** 1-4 years depending on cohort (Marginal)
- **Sample size:** ~700,000 observations (Strong)
- **MDE estimate:** With 9 treated clusters and standard DiD precision, MDE likely ~1-2% wage change, which is economically meaningful

## Timeline

1. Data collection: Fetch CPS ASEC 2015-2024 from IPUMS
2. Data cleaning: Construct analysis sample
3. Main analysis: DiD, DDD, event study
4. Robustness: Alternative estimators, sensitivity checks
5. Figures: Event study plots, geographic maps, heterogeneity
6. Paper: Full draft following AEJ format

## Key References

- Cullen, Z. B., & Pakzad-Hurson, B. (2023). Equilibrium effects of pay transparency. *Econometrica*.
- Cullen, Z. B. (2023). Is pay transparency good? *NBER Working Paper*.
- Callaway, B., & Sant'Anna, P. H. (2021). Difference-in-differences with multiple time periods. *Journal of Econometrics*.
- Sun, L., & Abraham, S. (2021). Estimating dynamic treatment effects in event studies. *Journal of Econometrics*.
- Rambachan, A., & Roth, J. (2023). A more credible approach to parallel trends. *Review of Economic Studies*.
