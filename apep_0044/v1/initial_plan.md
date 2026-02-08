# Initial Research Plan: Clean Slate Laws and Employment Outcomes

## Research Question

Do state "Clean Slate" automatic criminal record expungement laws improve employment outcomes for the general population?

## Background

Clean Slate laws automatically expunge or seal certain criminal records after a waiting period, without requiring individuals to petition for relief. This is distinct from "Ban-the-Box" laws, which merely delay when employers can ask about criminal history. Clean Slate laws permanently remove the record barrier.

Between 2018 and 2024, 12 states adopted Clean Slate laws:
- Pennsylvania (2018) - First adopter
- Utah (2019)
- New Jersey (2019)
- Michigan (2020)
- Connecticut (2021)
- Delaware (2021)
- Virginia (2021)
- Oklahoma (2022)
- Colorado (2022)
- California (2022)
- Minnesota (2023)
- New York (2024)

## Identification Strategy

**Design:** Staggered difference-in-differences

**Treatment:** State adoption of Clean Slate automatic expungement law

**Control:** States without Clean Slate laws (~38 states)

**Estimator:** Callaway-Sant'Anna (2021) group-time ATT estimator to handle:
1. Staggered treatment timing
2. Heterogeneous treatment effects
3. Potential negative weights in TWFE

**Parallel Trends Assumption:** States adopting Clean Slate laws would have followed the same employment trends as non-adopting states absent the policy. This is plausible because:
- Adoption driven by advocacy coalitions and political opportunity, not employment trends
- Policy targets individuals with criminal records, not general economic conditions
- Timing is somewhat idiosyncratic (pandemic interrupted some implementations)

## Expected Effects and Mechanisms

**Primary mechanism:** Clean Slate laws reduce employment barriers for individuals with criminal records by:
1. Removing records from background checks
2. Eliminating need for costly and complex petition process
3. Automating expungement at scale (millions of records)

**Expected effects:**
- Increase in employment-to-population ratio (modest, ~0.5-2 pp)
- Increase in labor force participation
- Increase in wage income (via job access, not direct wage effects)

**Effect size reasoning:**
- ~8% of US adults have felony convictions; ~30% have arrest records
- Criminal records reduce employment probability by 50%+ (Pager 2003)
- But state-level effects will be diluted: only fraction of population affected
- Expect modest aggregate effects (1-3% of baseline)

## Primary Specification

```r
# Callaway-Sant'Anna estimator
library(did)

# Group-time ATT
att_gt <- att_gt(
  yname = "emp_pop_ratio",      # Employment-population ratio
  tname = "year",               # Time period
  idname = "state_fips",        # State identifier
  gname = "treat_year",         # Year of Clean Slate adoption (0 if never-treated)
  data = panel_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

# Aggregate to overall ATT
att_overall <- aggte(att_gt, type = "simple")

# Event study
att_event <- aggte(att_gt, type = "dynamic")
```

## Outcome Variables

**Primary:**
1. Employment-to-population ratio (ages 16+)
2. Labor force participation rate (ages 16+)

**Secondary:**
3. Unemployment rate
4. Mean wage/salary income
5. Employment-to-population ratio by demographic subgroups (race, education, age)

## Data Sources

1. **BLS Local Area Unemployment Statistics (LAUS)**
   - Monthly state-level employment, unemployment, labor force
   - Available 1976-present
   - API: https://api.bls.gov/publicAPI/v2/timeseries/data/

2. **Census ACS 1-Year Estimates**
   - State-level employment, income, demographics
   - Available 2005-present
   - API: https://api.census.gov/data/

3. **Clean Slate Law Adoption Dates**
   - Compiled from Clean Slate Initiative, CCRC, news sources
   - Manual verification of effective dates

## Planned Robustness Checks

1. **Alternative estimators:**
   - Sun-Abraham interaction-weighted (via `fixest::sunab()`)
   - Gardner two-stage (`did2s`)

2. **Parallel trends sensitivity:**
   - HonestDiD bounds (Rambachan-Roth 2023)
   - Pre-trend test

3. **Placebo tests:**
   - Fake treatment timing (shift adoption 2 years earlier)
   - Placebo outcomes (variables Clean Slate shouldn't affect)

4. **Alternative controls:**
   - Not-yet-treated as control group
   - Match on pre-treatment characteristics

5. **Subgroup analysis:**
   - By state unemployment rate
   - By strictness of Clean Slate law
   - By racial composition

## Timeline

1. Data collection: Fetch BLS LAUS and Census ACS data (2010-2024)
2. Variable construction: Create treatment indicators, outcomes
3. Main analysis: Callaway-Sant'Anna estimation
4. Robustness checks: Alternative estimators, sensitivity analysis
5. Paper writing: Full manuscript

## Potential Concerns

1. **Implementation lags:** Some states passed laws but haven't fully implemented
   - Address: Use actual implementation dates, not passage dates

2. **Concurrent policies:** Ban-the-Box laws, minimum wage changes
   - Address: Control for state-level policies; note that Clean Slate is distinct mechanism

3. **COVID disruption:** 2020-2021 employment shocks
   - Address: Include year fixed effects; note this affects pre-trends testing

4. **Small effect sizes:** State-level effects may be too small to detect
   - Address: Power calculation; focus on directional evidence

5. **Selection into treatment:** Liberal states adopt first
   - Address: Event study to check pre-trends; political controls
