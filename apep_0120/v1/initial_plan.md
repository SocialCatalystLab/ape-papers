# Initial Research Plan: State Minimum Wage Increases and Young Adult Household Formation

## Research Question

Do state minimum wage increases affect young adults' ability to form independent households? When minimum wages rise, do young adults (ages 18-30) become more or less likely to live independently rather than with parents?

## Identification Strategy

**Design:** Staggered difference-in-differences exploiting state × year variation in minimum wage levels above the federal floor ($7.25/hour).

**Treatment definition:** A state is "treated" in the year it first raises its effective minimum wage above $8.25 (i.e., $1+ above the federal floor of $7.25, providing a meaningful bite). States that never exceed $8.25 are the never-treated comparison group.

**Estimator:** Callaway and Sant'Anna (2021) group-time ATT estimator using the `did` R package. This handles staggered adoption without the negative weighting bias of traditional TWFE.

**Comparison group:** Never-treated states (those at or near the federal $7.25 throughout the sample period). Robustness: not-yet-treated as alternative comparison group.

**Clustering:** Standard errors clustered at the state level (51 clusters).

## Expected Effects and Mechanisms

**Primary hypothesis:** Minimum wage increases enable young adults to afford independent living. Higher wages → more income → greater ability to pay rent → higher household formation rates.

**Alternative hypothesis:** If minimum wage increases reduce employment among young adults (the disemployment effect), the net impact on household formation could be negative — job loss forces young adults to remain with or return to parents.

**Expected sign:** Theoretically ambiguous, which makes this an interesting empirical question regardless of the result.

**Magnitude:** A $1 increase in the minimum wage raises annual income by ~$2,000 for full-time workers. With median rent for young adults ~$800-1,200/month, this represents a meaningful increase in affordability (15-20% of annual rent).

## Primary Specification

$$Y_{st} = \alpha + \sum_g \sum_t \text{ATT}(g,t) \cdot \mathbf{1}[G_s = g] \cdot \mathbf{1}[T = t] + X_{st}\beta + \gamma_s + \delta_t + \epsilon_{st}$$

Where:
- $Y_{st}$: Share of young adults (18-30) living independently in state $s$, year $t$
- $G_s$: Year state $s$ first exceeds $8.25 MW (treatment cohort)
- $X_{st}$: Time-varying state controls (unemployment rate, housing costs, college enrollment)
- $\gamma_s, \delta_t$: State and year fixed effects

## Exposure Alignment (DiD)

- **Who is treated:** Young adults (18-30) earning at or near the minimum wage in states that raised MW
- **Primary estimand population:** All young adults 18-30 (intent-to-treat on the full population)
- **Placebo/control population:** Young adults 18-30 in never-treated states (MW = $7.25)
- **Design:** Staggered DiD with state-year panels

## Power Assessment

- **Pre-treatment periods:** 2010-2013 (4 years before major MW acceleration in 2014)
- **Treated clusters:** 30+ states exceeded $8.25 by 2023
- **Post-treatment periods per cohort:** Varies (2-10 years for early adopters)
- **Sample size:** ~600K young adults per year in ACS; ~50 state-year cells per year; total panel ~700 state-years
- **MDE:** With 50+ treated states and 10+ years, MDE should be well under 5 percentage points on a base rate of ~50% independent living

## Planned Robustness Checks

1. **Alternative treatment definitions:** $0.50, $1.00, $2.00 above federal floor
2. **Age subgroups:** 18-21, 22-25, 26-30 (different labor market attachment)
3. **Education subgroups:** HS dropout, HS diploma, some college, BA+
4. **Alternative comparison groups:** Not-yet-treated vs. never-treated
5. **Placebo outcomes:** Independent living among 40-50 year olds (should not be affected by MW)
6. **Event study:** Dynamic treatment effects to test parallel trends and effect timing
7. **HonestDiD sensitivity:** Rambachan-Roth bounds for parallel trends violations
8. **Sun-Abraham (2021):** Alternative heterogeneity-robust estimator via fixest::sunab()
9. **Continuous treatment:** Log(MW) as treatment intensity rather than binary

## Data Sources

| Source | Variables | Access |
|--------|-----------|--------|
| Census ACS PUMS (api.census.gov) | Age, relationship to HH, employment, wages, state, year | No key needed |
| DOL Historical MW Tables | State × year minimum wage rates | Web scrape |
| BLS LAUS | State unemployment rates | Public API |

## Analysis Script Structure

```
code/
├── 00_packages.R        # Libraries and themes
├── 01_fetch_data.R      # Census PUMS + MW data
├── 02_clean_data.R      # Variable construction
├── 03_main_analysis.R   # CS-DiD, event studies, TWFE
├── 04_robustness.R      # Alternative specs, placebo, HonestDiD
├── 05_figures.R         # All figures
└── 06_tables.R          # All tables
```
