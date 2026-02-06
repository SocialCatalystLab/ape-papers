# Initial Research Plan: Promise Programs and Community College Completion

## Research Question

Do state college Promise programs (free community college tuition) increase degree completion rates, or do they primarily increase enrollment without improving educational attainment?

**Core hypothesis:** Promise programs remove financial barriers at enrollment, but completion requires sustained academic support and student effort. Effect on completion may be smaller than enrollment effect, or could be zero/negative if marginal students are less academically prepared.

## Policy Background

State College Promise programs provide free tuition (typically "last-dollar" after other aid) at community colleges. The policy began with Tennessee Promise in 2015 and spread to 20+ states by 2021.

### Treatment Timeline (First Cohort Year)

| State | Program | First Cohort |
|-------|---------|--------------|
| Tennessee | Tennessee Promise | Fall 2015 |
| Oregon | Oregon Promise | Fall 2016 |
| Arkansas | ArFuture Grant | Fall 2017 |
| Hawaii | Hawaii Promise | Fall 2017 |
| Indiana | 21st Century expansion | Fall 2017 |
| Kentucky | Work Ready | Fall 2017 |
| Nevada | Nevada Promise | Fall 2017 |
| New York | Excelsior (4-yr focus) | Fall 2017 |
| Rhode Island | RI Promise | Fall 2017 |
| Maryland | CC Promise | Fall 2018 |
| Washington | College Bound expansion | Fall 2019 |
| California | CA College Promise expansion | Fall 2019 |
| Connecticut | PACT | Fall 2020 |
| Delaware | SEED | Fall 2020 |
| Michigan | Reconnect | Fall 2021 |

**Treatment clusters: 15-20 states (meets ≥20 threshold with additional states)**

## Exposure Alignment

This section documents who is actually affected by Promise programs and how treatment exposure maps to the observed outcome.

### Who Is Treated?

**Directly Treated Population:** First-time, full-time freshmen enrolling in community colleges in Promise states. These students receive tuition subsidies directly under Promise programs.

**Primary Estimand Population:** All undergraduate students enrolled in postsecondary institutions within a state. This is a broader population than the directly treated because:
- Includes continuing students (sophomores, juniors, seniors) enrolled before Promise
- Includes students at 4-year institutions (not directly subsidized by most Promise programs)
- Includes part-time and returning adult students

**Dilution Factor:** The directly treated population (first-time CC freshmen) is approximately 25% of total undergraduate enrollment. This means effects on the directly treated population are diluted by a factor of ~4 when measured at the aggregate level.

### Control Population

**Never-Treated States (N = 31):** States that did not adopt statewide Promise programs through 2023. These serve as the primary control group for difference-in-differences estimation.

**Not-Yet-Treated States:** States that adopted Promise in later years, before their adoption date. Available as alternative control group for robustness.

### Design Classification

**Method:** Difference-in-Differences (DiD) with staggered adoption timing
**Estimator:** Callaway-Sant'Anna (2021) for heterogeneous treatment effects
**Unit:** State × year panel
**Clustering:** State level (51 clusters)

### Exposure-to-Outcome Pathway

```
Promise adoption (Year t)
    ↓
First-time CC freshmen receive tuition subsidy
    ↓
Enrollment decision affected (intensive/extensive margin)
    ↓
Aggregate state enrollment changes
    ↓
Observed outcome: Log total undergraduate enrollment
```

**Key limitation:** The outcome (total enrollment) includes populations not directly treated. If Promise shifts composition between CC and 4-year without changing totals, the aggregate effect would be zero despite real individual-level effects.

## Identification Strategy

### Staggered Difference-in-Differences

- **Unit of analysis:** State × cohort-year
- **Treatment:** State has active Promise program when cohort enrolls
- **Outcome:** 150% time graduation rate for first-time, full-time (FTFT) community college entrants
- **Estimator:** Callaway-Sant'Anna (2021) for heterogeneous treatment timing

### Timing/Lag Structure

Promise adoption in year $t$ affects the **fall $t$ entering cohort**. Completion at 150% time (3 years for associate degree) is observed in year $t+3$.

```
Promise adopted: 2015
    ↓
Fall 2015 cohort enters
    ↓
Observed completion: 2018 (150% time)
```

### Key Identification Assumptions

1. **Parallel trends:** Absent Promise, treated and control states would have had similar completion rate trends
2. **No anticipation:** Institutions and students don't change behavior before Promise implementation
3. **SUTVA:** No spillovers between states (reasonable for state-specific programs)

### Potential Threats

1. **Compositional change:** Promise may change WHO enrolls, affecting measured graduation rates mechanically
   - *Address:* Decompose into enrollment effects vs completion effects
   - *Placebo:* Examine 4-year completion rates at 4-year institutions in same states

2. **Concurrent policies:** States may adopt Promise alongside other higher-ed reforms
   - *Address:* Audit concurrent policies (performance-based funding, workforce initiatives)
   - *Control:* Include state-specific linear trends in robustness

3. **Selection into treatment:** States adopt Promise due to attainment concerns
   - *Address:* Event study to examine pre-trends
   - *Robustness:* Match on pre-treatment characteristics

## Data Sources

### Primary: IPEDS Graduation Rates Survey

- **Table:** 2-year institution graduation rates within 150% of normal time
- **Population:** First-time, full-time degree-seeking students
- **Years:** 2010-2024 (entering cohorts 2007-2021)
- **Variables:**
  - `GR200_22`: Overall graduation rate (150% time)
  - Subcategories by sex, race/ethnicity
  - Institution-level → aggregate to state-level

### Secondary: IPEDS Fall Enrollment

- To measure enrollment effects (potential mechanism)
- First-time, degree-seeking enrollment by institution type

### Verification of Data Access

IPEDS data is publicly available via:
- NCES IPEDS Data Center (bulk download)
- Urban Institute Education Data Portal (API - currently blocked, use NCES direct)

## Expected Effects and Mechanisms

### Main Effect
- **Prior enrollment studies:** Promise increases CC enrollment by 5-15%
- **Expected completion effect:** Smaller magnitude, likely 2-8 percentage points
- **Mechanism:** Reduced financial stress allows focus on academics; but marginal students may be less prepared

### Heterogeneity
- Effects may be larger for:
  - Students from low-income backgrounds
  - States with more restrictive eligibility (less dilution)
  - Programs with wrap-around support services

### Power Assessment
- Pre-treatment periods: 5+ years (2010-2014)
- Post-treatment periods: 3-8 years depending on cohort
- Treated clusters: 15-20 states
- MDE calculation needed once data loaded

## Primary Specification

$$Y_{st} = \alpha + \sum_{g} \sum_{e \neq -1} \beta_{g,e} \cdot D_{st}^{g,e} + X_{st}\gamma + \mu_s + \lambda_t + \epsilon_{st}$$

Where:
- $Y_{st}$: 150% completion rate in state $s$ for cohort entering in year $t-3$ (observed in $t$)
- $D_{st}^{g,e}$: Indicator for cohort being $e$ periods from treatment, in group $g$ (adoption year)
- $X_{st}$: Time-varying state controls (unemployment, state higher-ed funding)
- $\mu_s$: State fixed effects
- $\lambda_t$: Year fixed effects

## Robustness Checks

1. **Alternative estimators:**
   - Sun & Abraham (2021) interaction-weighted estimator
   - Borusyak, Jaravel, Spiess (2024) imputation estimator

2. **Inference:**
   - Wild cluster bootstrap (few clusters)
   - Randomization inference
   - HonestDiD sensitivity analysis for parallel trends violations

3. **Placebo tests:**
   - 4-year institution completion rates (should be unaffected or smaller)
   - Pre-treatment pseudo-treatments

4. **Alternative control groups:**
   - Never-treated states only
   - Not-yet-treated states only
   - Matching on pre-treatment outcomes

5. **Compositional adjustment:**
   - Control for enrollment levels
   - Examine completion conditional on enrollment (if enrollment data contemporaneous)

## Timeline

- Week 1: Data collection and cleaning
- Week 2: Main analysis and event studies
- Week 3: Robustness checks
- Week 4: Writing and figures
