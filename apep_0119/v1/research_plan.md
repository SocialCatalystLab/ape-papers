# Initial Research Plan: Paper 112

## Research Question

Do state Energy Efficiency Resource Standards (EERS) reduce residential electricity consumption? EERS mandates require utilities to achieve specific annual energy savings targets through customer efficiency programs (weatherization, appliance rebates, building codes). Despite being one of the most widespread US energy policies (~27 states), no rigorous causal estimate of their effectiveness exists using modern econometric methods.

## Identification Strategy

**Staggered Difference-in-Differences** using the Callaway and Sant'Anna (2021) estimator.

- **Treatment:** Year a state first adopted a binding EERS mandate
- **Treatment timing:** Staggered adoption from 1999 (Texas) through 2015+
- **Treated states:** ~22-27 states (depending on classification of voluntary vs. mandatory)
- **Control group:** Never-treated states (states that never adopted EERS)
- **Unit of observation:** State × Year
- **Panel:** 50 states + DC, 1990-2023 (34 years)

### Why DiD is Credible Here

1. **Staggered adoption:** States adopted EERS at different times for political (not outcome-trend) reasons
2. **Long pre-treatment:** Most adoptions after 2004, giving 5-15 years pre-treatment data
3. **Many treated units:** 22+ treated states avoids few-cluster problems
4. **Many never-treated:** 20+ never-treated states provide clean control group
5. **Policy is state-level:** Assignment is at the state level, matching our data granularity

### Exposure Alignment (DiD Required Section)

- **Who is actually treated?** Residential electricity customers in states with binding EERS mandates. Utilities must implement efficiency programs (rebates, audits, weatherization) that reduce customer consumption.
- **Primary estimand population:** All residential electricity consumers in treated states
- **Placebo/control population:** Residential consumers in never-treated states
- **Design:** Standard staggered DiD (not DDD)

### Power Assessment

- **Pre-treatment periods:** 5-15 years depending on adoption cohort (1990 to adoption year)
- **Treated clusters:** 22-27 states
- **Post-treatment periods per cohort:** 5-20+ years (early adopters have long post-periods)
- **Total observations:** ~1,700 state-years (50 states × 34 years)
- **MDE:** With 50 state-level clusters and ~15 years pre-treatment, we expect reasonable power to detect 2-5% consumption changes

## Expected Effects and Mechanisms

**Primary hypothesis:** EERS mandates reduce per-capita residential electricity consumption.

**Mechanisms:**
1. **Direct efficiency programs:** Utilities offer rebates for efficient appliances, weatherization subsidies, building code improvements
2. **Information effects:** Mandated energy audits increase consumer awareness
3. **Rate design:** Some EERS states adopt decoupling mechanisms that remove utility disincentive to reduce sales

**Expected magnitude:** EERS targets typically range from 0.5-2% annual savings. Cumulative effects over 5-10 years could yield 5-15% reductions if programs achieve stated targets. However, rebound effects and free-ridership may attenuate real savings to 2-8%.

**Alternative outcome:** EERS may NOT reduce consumption if:
- Programs have high free-ridership (subsidize actions that would happen anyway)
- Rebound effects are large (efficiency gains → more usage)
- States adopt weak/unenforced standards

A well-executed null result would be a valuable contribution, challenging the policy rationale for EERS.

## Primary Specification

```
Y_{st} = α_s + λ_t + β·EERS_{st} + ε_{st}
```

Where:
- Y_{st}: Log per-capita residential electricity consumption in state s, year t
- α_s: State fixed effects
- λ_t: Year fixed effects
- EERS_{st}: Treatment indicator (=1 after state s adopts EERS)
- Standard errors clustered at the state level

**Callaway-Sant'Anna implementation:**
- `yname`: Log per-capita residential electricity consumption
- `tname`: Year
- `idname`: State FIPS code
- `gname`: Year of EERS adoption (0 for never-treated)
- `control_group`: "nevertreated"

## Data Sources

1. **EIA State Energy Data System (SEDS):** State-level annual electricity consumption by sector (residential, commercial, industrial), 1960-2023. API access confirmed via `api.eia.gov/v2/seds/data/`.

2. **EIA Retail Sales Data:** State-level annual electricity prices by sector, 1990-2023. API access confirmed via `api.eia.gov/v2/electricity/retail-sales/data/`.

3. **Census Bureau Population Estimates:** State-level annual population for per-capita calculations.

4. **ACEEE EERS Database + NCSL + DSIRE:** Treatment coding — EERS adoption year by state. Will compile from ACEEE database and cross-reference with NCSL records.

5. **BEA/Census controls:** State-level GDP, income, heating/cooling degree days for robustness.

## Planned Robustness Checks

1. **Callaway-Sant'Anna event study:** Plot dynamic treatment effects, assess pre-trends
2. **Goodman-Bacon decomposition:** Diagnose TWFE bias sources
3. **Sun-Abraham estimator:** Alternative heterogeneity-robust estimator
4. **HonestDiD sensitivity analysis:** Rambachan-Roth bounds for pre-trend violations
5. **Placebo tests:**
   - Fake treatment timing (shift treatment 3-5 years earlier)
   - Placebo outcome (industrial consumption — less directly targeted by residential EERS)
6. **Alternative control groups:** Not-yet-treated vs. never-treated
7. **Alternative outcome measures:** Total consumption, commercial consumption, electricity prices
8. **Heterogeneity:** By EERS stringency (high vs. low targets), by climate zone, by electricity market structure (regulated vs. deregulated)
9. **Stacked DiD:** As an additional robustness check
10. **Wild cluster bootstrap:** For few-cluster robustness in subgroup analyses

## Paper Structure

1. **Introduction** (3 pages): Motivation, contribution, preview of results
2. **Background** (4 pages): EERS policy details, theoretical framework, literature review
3. **Data** (3 pages): Data sources, sample construction, summary statistics
4. **Empirical Strategy** (4 pages): Identification strategy, estimator choice, threats to validity
5. **Results** (5 pages): Main results, event study, aggregated ATT
6. **Robustness** (4 pages): Alternative estimators, placebo tests, sensitivity analysis
7. **Heterogeneity** (3 pages): By stringency, climate, market structure
8. **Conclusion** (2 pages): Summary, policy implications, limitations
9. **References** (2 pages)
10. **Appendix** (5+ pages): Additional tables, figures, data details

Total main text: ~28 pages (excluding references and appendix)
