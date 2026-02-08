# Initial Research Plan — Paper 59

## Research Question

Do state insulin copay cap laws improve diabetes management outcomes? Specifically, do these laws reduce diabetes-related health complications as measured by self-reported diabetes control, healthcare utilization, and health behaviors?

## Policy Background

Between 2019 and 2024, approximately 25 states enacted laws capping out-of-pocket costs for insulin, typically at $25-$100 per month for a 30-day supply. Colorado was the first state to enact such a law (effective 2020), followed by waves of adoption in 2020-2022 and 2023-2024.

**Treatment States and Effective Dates:**

| State | Effective Date | Cap Amount |
|-------|----------------|------------|
| Colorado | Jan 2020 | $100 |
| Illinois | Jan 2020 | $100 |
| New Mexico | Jan 2020 | $25 |
| New York | Jan 2020 | $100 |
| Maine | 2020 | $35 |
| Utah | 2020 | $30 |
| Washington | Jan 2021 | $100 |
| Texas | Sept 2021 | $25 |
| Connecticut | 2022 | $25 |
| Delaware | 2022 | $100 |
| New Hampshire | 2022 | $30 |
| West Virginia | 2022 | $35 |
| California | Jan 2023 | $35 |
| Kentucky | 2023 | $35 |
| Louisiana | 2023 | $35 |
| Nevada | 2023 | $35 |
| Oklahoma | 2023 | $35 |
| Vermont | 2023 | $35 |
| Additional states | 2023-2024 | Various |

## Identification Strategy

**Method:** Staggered Difference-in-Differences with Callaway-Sant'Anna (2021) estimator

**Treatment:** State enacts insulin price cap law (first year in effect)

**Control:** Never-treated states (approximately 20-25 states)

**Identification Assumption:** Parallel trends in diabetes outcomes between treated and control states absent the policy

**Key Threats:**
1. Federal Medicare $35 cap (IRA, effective Jan 2023) — affects Medicare beneficiaries
2. Manufacturer voluntary $35 caps (Eli Lilly Jan 2024, Novo Nordisk, Sanofi) — national effect
3. Selection: states with worse diabetes outcomes may be more likely to adopt

**Mitigation Strategies:**
1. Restrict sample to 2017-2022 (pre-IRA) for primary analysis
2. Conduct robustness using 2017-2023 with Medicare exclusion
3. Event study to validate pre-trends
4. Heterogeneity by insurance type (where available)

## Data

**Primary Data Source:** CDC Behavioral Risk Factor Surveillance System (BRFSS)
- Annual state-level cross-sectional survey, 2017-2023
- Sample: Adults diagnosed with diabetes
- State identifiers available
- Weighted to state populations

**Outcome Variables:**
1. **Primary:** Self-reported diabetes management
   - "About how many times in the past 12 months have you seen a doctor, nurse, or other health professional for your diabetes?" (DOCTDIAB)
   - "When was the last time you had your blood sugar or hemoglobin A1C checked by a doctor?" (CHKHEMO3)

2. **Secondary:** Health behaviors and complications
   - "Are you now taking insulin?" (INSULIN)
   - "Has a doctor, nurse, or other health professional EVER told you that you had any of the following: diabetic retinopathy?" (EYEEXAM1)
   - "Have you ever been told by a doctor that diabetes has affected your eyes?" (DIABEYE)
   - General health status (GENHLTH)

**Covariates:**
- Age, sex, race/ethnicity, education, income, employment status
- Health insurance status, type of insurance
- Body mass index (BMI)
- State-year fixed effects

## Estimating Equation

Using Callaway-Sant'Anna (2021) for group-time ATTs:

$$ATT(g,t) = E[Y_{it}(g) - Y_{it}(0) | G_i = g]$$

Where:
- $g$ = treatment cohort (year state adopted insulin cap)
- $t$ = calendar year
- $Y_{it}(g)$ = potential outcome under treatment at time $t$
- $Y_{it}(0)$ = potential outcome under never-treatment

Aggregate to overall ATT using:
$$ATT = \sum_{g} ATT(g) \times P(G=g|G>0)$$

## Expected Effects

**Mechanism:** Lower out-of-pocket insulin costs → increased insulin adherence → better glycemic control → reduced complications

**Expected Signs:**
- Healthcare visits for diabetes management: **Increase** (better access)
- A1C monitoring: **Increase** (more engagement with care)
- Insulin use: **Increase** (better affordability)
- Diabetic complications (retinopathy): **Decrease** (long-term, may not observe)
- Self-reported health: **Improve** (better management)

**Magnitude:** Based on prior evidence on cost-sharing elasticities and the ~40% reduction in OOP costs (Texas A&M 2024 study), we expect 5-15% improvements in management indicators.

## Primary Specification

```r
library(did)

# Callaway-Sant'Anna estimator
cs_result <- att_gt(
  yname = "diabetes_visits",        # outcome
  tname = "year",                   # time period
  idname = "state_fips",            # unit ID
  gname = "treatment_year",         # treatment cohort (0 for never-treated)
  data = brfss_diabetes,
  control_group = "nevertreated",
  est_method = "dr",                # doubly robust
  xformla = ~ age + female + black + hispanic + college + income_cat + insured,
  clustervars = "state_fips",
  base_period = "universal"
)

# Aggregate to overall ATT
aggte(cs_result, type = "simple")

# Event study
aggte(cs_result, type = "dynamic", min_e = -5, max_e = 5)
```

## Robustness Checks

1. **Alternative Estimators:**
   - Sun-Abraham (2021) via `fixest::sunab()`
   - Gardner (2021) two-stage via `did2s`

2. **Sample Restrictions:**
   - Exclude 2023 (post-IRA)
   - Exclude Medicare beneficiaries (if identifiable)
   - Ages 18-64 only (working-age)

3. **Alternative Outcomes:**
   - Diabetes medication adherence
   - Emergency room visits
   - Self-rated health

4. **Placebo Tests:**
   - Pre-treatment event study coefficients should be zero
   - Effects on non-diabetic population (should be zero)

5. **Sensitivity Analysis:**
   - HonestDiD bounds for pre-trends violations

## Planned Figures

1. **Map:** State adoption timeline (choropleth showing early/late/never adopters)
2. **Event Study:** Dynamic ATT estimates with 95% CI
3. **Parallel Trends:** Raw means by treatment/control group over time
4. **Heterogeneity:** Effects by insurance type, age group, income
5. **Robustness:** Alternative estimator comparison

## Timeline

1. Data acquisition and cleaning: BRFSS download and variable construction
2. Descriptive analysis: Summary statistics, pre-trend plots
3. Main DiD estimation: Callaway-Sant'Anna, event study
4. Robustness checks: Alternative estimators, sample restrictions
5. Paper writing: Full manuscript with tables and figures

## Key Uncertainties

1. **BRFSS outcome timing:** Questions about "past 12 months" may not align cleanly with policy effective dates
2. **Heterogeneous caps:** States vary from $25-$100 caps; may need dose-response analysis
3. **Private vs. public insurance:** State laws primarily affect state-regulated private insurance; Medicare/Medicaid effects differ
4. **Long-term outcomes:** Diabetes complications take years to manifest; 2-4 year post-periods may be insufficient
