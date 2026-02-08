# Pre-Analysis Plan: Head Start Grant-Writing Assistance and Intergenerational Mobility

**Paper ID:** paper_25
**Date:** 2026-01-17
**Status:** DRAFT (to be locked before analysis)

---

## 1. Research Question

Did children born in counties that received Office of Economic Opportunity (OEO) grant-writing assistance for Head Start (the 300 poorest U.S. counties in 1960) experience greater intergenerational economic mobility than children born in counties just below the poverty threshold?

## 2. Hypothesis

In 1965, the OEO provided technical assistance to the 300 poorest U.S. counties to develop Head Start funding proposals, creating a sharp discontinuity in Head Start program participation that persisted for decades. We hypothesize that:

1. **First Stage:** Counties above the 1960 poverty cutoff (59.1984%) had substantially higher Head Start funding and participation rates.
2. **Reduced Form:** Children born in these high-Head-Start counties exhibit higher intergenerational mobility, measured as their adult income rank relative to their parents' income rank.

**Expected direction:** Positive effect—counties receiving OEO assistance should exhibit higher upward mobility, particularly for children from low-income families.

**Mechanisms:**
- Improved cognitive development and school readiness
- Better health outcomes due to Head Start health services
- Increased parental engagement and family stability
- Long-term human capital accumulation leading to higher adult earnings

## 3. Identification Strategy

### 3.1 Design: Sharp Regression Discontinuity

- **Running variable:** County 1960 poverty rate (percentage of families below poverty line)
- **Cutoff:** 59.1984% (threshold for being among the 300 poorest counties)
- **Treatment:** OEO grant-writing assistance → Higher Head Start funding → Greater early childhood program participation
- **Assignment:** Sharp (counties either received OEO assistance or not based on poverty threshold)

### 3.2 Historical Background

The 1964 Economic Opportunity Act created the Office of Economic Opportunity, which launched Head Start in 1965. To encourage participation, OEO provided technical assistance for writing grant proposals to the 300 poorest counties in the United States, defined using 1960 Census poverty rates. This assistance created a large and persistent discontinuity in Head Start funding and participation (Ludwig and Miller 2007).

### 3.3 Bandwidth Selection

- **Primary:** Counties within 18 percentage points of the cutoff (Ludwig-Miller specification)
- **Robustness:** Test bandwidths of 10, 12, 15, and 20 percentage points
- **Sample restriction:** Counties with 1960 poverty rates between 41% and 78%

### 3.4 Estimation

**Main Specification (Reduced Form):**
```
Y_c = α + β₁ · ABOVE_CUTOFF_c + f(POVERTY_1960_c) + X_c'γ + ε_c
```

Where:
- Y_c = county-level mobility outcome from Opportunity Insights
- ABOVE_CUTOFF_c = 1 if county 1960 poverty rate ≥ 59.1984%
- f(·) = polynomial function of running variable (linear, quadratic, or local linear)
- X_c = county-level controls

**Functional Forms:**
1. Local linear regression with triangular kernel weights (preferred)
2. Global polynomial (linear, quadratic, cubic)
3. Local polynomial with optimal bandwidth (Calonico-Cattaneo-Titiunik)

### 3.5 Controls

**Core controls:**
- State fixed effects
- County 1960 population (log)
- County 1960 urban share
- County 1960 Black population share

**No controls specification (primary):**
- RDD validity means controls should not affect point estimates
- Controls can improve precision

## 4. Data

### 4.1 Sources

**Opportunity Insights Data:**
- The Opportunity Atlas: county-level intergenerational mobility outcomes
- Birth cohorts: 1978-1983 (individuals observed as adults at ages 26-35)
- Available at: https://opportunityinsights.org/data/

**Ludwig-Miller Replication Data:**
- County 1960 poverty rates
- OEO treatment status
- Available via QJE replication archives or RD packages

**Additional County Data:**
- 1960 Census county characteristics (from ICPSR/NHGIS)

### 4.2 Key Variables

**Running Variable:**
- POVERTY_1960: County poverty rate in 1960 (% families below poverty line)
- Normalized: POVERTY_CENTERED = POVERTY_1960 - 59.1984

**Treatment Indicator:**
- ABOVE_CUTOFF = 1 if POVERTY_1960 ≥ 59.1984

**Primary Outcomes (Opportunity Insights):**
| Variable | Description |
|----------|-------------|
| kfr_pooled_pooled_p25 | Mean income rank for children from families at 25th percentile |
| kfr_pooled_pooled_p75 | Mean income rank for children from families at 75th percentile |
| kfr_pooled_pooled_mean | Mean income rank across all parent income levels |
| prob_p1_p100_pooled | Probability of reaching top quintile from bottom quintile |
| has_dad_pooled_pooled_p25 | Fraction with dad present at age 15 (family stability) |
| jail_pooled_pooled_p25 | Incarceration rate for children from 25th percentile families |
| coll_pooled_pooled_p25 | College attendance rate for children from 25th percentile families |

**Subgroup Outcomes (by race):**
- kfr_black_pooled_p25: Mobility for Black children from low-income families
- kfr_white_pooled_p25: Mobility for White children from low-income families

**Weights:**
- County population weight (for population-representative estimates)
- Unweighted (for county-representative estimates)

### 4.3 Sample Construction

1. Obtain Ludwig-Miller county poverty data (N ≈ 2,783 counties excluding Alaska)
2. Download Opportunity Insights county-level mobility data
3. Merge datasets on county FIPS codes
4. Restrict to counties within 18 pp bandwidth: 41.2% ≤ poverty ≤ 77.2%
5. Drop counties with missing mobility outcomes

**Expected Sample Size:**
- Full sample: ~2,700 counties
- Within 18pp bandwidth: ~800-1,200 counties (estimated)
- Within 10pp bandwidth: ~500-700 counties (estimated)

## 5. Analysis Plan

### 5.1 Descriptive Statistics

**Table 1:** Summary Statistics
- Panel A: All counties within bandwidth
- Panel B: Counties below cutoff (control)
- Panel C: Counties above cutoff (treatment)
- Variables: Poverty rate, population, urban share, Black share, mobility outcomes

**Table 2:** Balance Test
- Test for discontinuities in predetermined county characteristics at cutoff
- 1950 county characteristics, geographic features
- Report coefficients, standard errors, p-values

### 5.2 Validity Tests

**Figure 1:** McCrary Density Test
- Histogram of county poverty rates around cutoff
- Test for manipulation (bunching) at threshold
- Should show smooth density through cutoff

**Figure 2:** Covariate Balance
- RD plots for predetermined characteristics (1950 variables, geography)
- Should show no discontinuity at cutoff

### 5.3 Main Results

**Figure 3:** RD Plot - Primary Outcome
- Binned scatter plot of mean child income rank (kfr_pooled_pooled_p25) by 1960 poverty rate
- Fitted regression lines on either side of cutoff
- Show discontinuity at 59.1984%

**Table 3:** Main RDD Estimates - Intergenerational Mobility
- Panel A: Mean income rank (kfr_pooled_pooled_p25)
- Panel B: Probability of reaching top quintile (prob_p1_p100_pooled)
- Panel C: College attendance (coll_pooled_pooled_p25)

Columns:
1. No controls, linear
2. No controls, quadratic
3. With controls, linear
4. With controls, quadratic
5. Optimal bandwidth (CCT)

**Table 4:** Effects on Other Outcomes
- Incarceration (jail_pooled_pooled_p25)
- Family stability (has_dad_pooled_pooled_p25)
- Teenage birth rates

### 5.4 Figures

**Figure 4:** RD Plots for All Primary Outcomes
- Panel A: Income rank at p25
- Panel B: College attendance
- Panel C: Incarceration
- Panel D: Top quintile probability

**Figure 5:** Bandwidth Sensitivity
- Plot coefficients and 95% CIs for bandwidths 8, 10, 12, 15, 18, 20 pp

### 5.5 Robustness Checks

**Table 5:** Bandwidth Sensitivity
- Columns: 10pp, 12pp, 15pp, 18pp (primary), 20pp bandwidth
- Rows: Main outcomes

**Table 6:** Polynomial Order Sensitivity
- Columns: Linear, quadratic, cubic, local linear (CCT)

**Table 7:** Placebo Cutoffs
- Test for discontinuities at poverty rates of 50%, 55%, 65%, 70%
- Should find no effect at false cutoffs

**Table 8:** Donut Hole Specification
- Exclude counties within 2pp, 4pp of cutoff
- Tests for manipulation concerns

### 5.6 Heterogeneity Analysis

**Table 9:** Effects by Race
- Row 1: Black children (kfr_black_pooled_p25)
- Row 2: White children (kfr_white_pooled_p25)
- Row 3: Black-White gap

**Table 10:** Effects by Region
- Columns: South, Non-South
- Head Start effects may differ by regional context

**Table 11:** Effects by Parent Income Level
- p25, p50, p75 starting income
- Test if effects concentrated among lowest-income families

## 6. Inference

- **Primary:** Robust standard errors (heteroskedasticity-robust)
- **Alternative:** Clustered at state level (conservative)
- Report 95% confidence intervals
- Report p-values (two-sided tests)
- For multiple outcomes: discuss multiple testing corrections (Bonferroni, Holm)

## 7. Threats to Validity

### 7.1 Manipulation

- The poverty cutoff was determined by 1960 Census data, collected before the policy was conceived
- Counties could not manipulate their position relative to the cutoff
- McCrary test will assess density smoothness
- Donut hole specification provides additional robustness

### 7.2 Persistence of Treatment

- **Key concern (from GPT review):** Does the Head Start funding discontinuity persist into the 1978-1983 birth cohorts used by Opportunity Insights?
- Ludwig-Miller document persistence through 1998; we will verify funding patterns in our sample period
- If first stage weakens, estimates represent intent-to-treat effect of historical OEO assignment

### 7.3 Compound Treatment

- OEO may have affected other programs beyond Head Start
- Ludwig-Miller (2007) show no discontinuity in other federal spending at the cutoff
- We treat estimates as effect of "OEO treatment package" with Head Start as primary mechanism

### 7.4 Sorting

- Families may have migrated across counties between treatment and outcome measurement
- Opportunity Insights data reflects childhood county of residence
- Sorting would bias toward null if high-ability families leave treated counties

### 7.5 External Validity

- Estimates are local average treatment effects for counties near the cutoff
- These are among the poorest counties in the U.S. in 1960
- Generalizability to less poor counties is limited

## 8. Decision Rules

### 8.1 Interpretation

- If significant positive effect on mobility: Conclude Head Start/OEO assistance improved long-run intergenerational mobility
- If null effect: Discuss power, potential mechanisms for null, compare to prior Head Start literature
- If negative effect: Investigate carefully, likely spurious or due to specification issues

### 8.2 Minimum Detectable Effect

With ~1,000 counties and σ ≈ 10 percentile ranks:
- Power of 0.80, α = 0.05
- MDE ≈ 2-3 percentile point change in mobility

### 8.3 Publication

- Report all pre-specified analyses regardless of statistical significance
- Clearly distinguish pre-specified from exploratory analyses
- Report effect sizes and confidence intervals, not just p-values

## 9. Deviations from Ludwig-Miller (2007)

| Element | Ludwig-Miller (2007) | This Study |
|---------|---------------------|------------|
| Outcome | Mortality ages 5-9 | Intergenerational mobility |
| Birth cohorts | 1965-1980 | 1978-1983 (OI data) |
| Geographic level | County | County |
| Bandwidth | 18pp | 18pp (with sensitivity) |
| Running variable | Same | Same |
| Cutoff | 59.1984% | 59.1984% |

## 10. Data Availability and Replication

All data sources are publicly available:
- Opportunity Insights: https://opportunityinsights.org/data/
- Ludwig-Miller replication data: QJE archives / rdrobust R package (headst dataset)
- Code and processed data will be included in replication package

---

**Lock Status:** DRAFT
**To be locked before any regression analysis**
