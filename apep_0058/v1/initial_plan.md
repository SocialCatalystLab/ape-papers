# Paper 74: Initial Research Plan

**Title:** Dental Therapy Authorization and Oral Health Access: Evidence from Staggered State Adoption

**Created:** 2026-01-24
**Phase:** 4 - Execute

---

## Research Question

Does state authorization of dental therapy increase dental care access and utilization, particularly among underserved populations?

## Contribution

This is the **first quasi-experimental study** of dental therapy's effects on population-level oral health access. Existing evidence consists of:
- Descriptive statistics on program utilization
- Provider/patient surveys
- Case studies from Minnesota

No difference-in-differences or other rigorous causal inference methods have been applied. This paper fills that gap.

## Policy Context

Dental therapists are mid-level providers authorized to perform:
- Preventive services (cleanings, sealants, fluoride)
- Basic restorative procedures (fillings, extractions)
- Patient education and triage

They operate under dentist supervision but extend practice capacity, particularly in underserved areas. Over 50 countries use dental therapists; in the U.S., 14 states have authorized them since 2009.

---

## Treatment: State Authorization Dates

| State | Year | Notes |
|-------|------|-------|
| Minnesota | 2009 | First state; two-tier system (DT and ADT) |
| Maine | 2014 | Public health focus |
| Vermont | 2016 | |
| Arizona | 2018 | |
| Michigan | 2018 | |
| New Mexico | 2018 | |
| Nevada | 2019 | |
| Idaho | 2019 | |
| Washington | 2020 | |
| Oregon | 2020 | |
| Connecticut | 2021 | |
| Colorado | 2022 | |
| Wisconsin | 2024 | (may be outside data window) |

**Note:** Alaska has tribal dental health aide therapists (2005+) operating on tribal lands. This is a separate regulatory framework—will treat Alaska as never-treated for state-level analysis.

---

## Identification Strategy

### Method: Staggered Difference-in-Differences

Using Callaway & Sant'Anna (2021) estimator with:
- **Treatment:** Year of dental therapy authorization
- **Comparison group:** Not-yet-treated and never-treated states
- **Clustering:** State level

### Why DiD Is Appropriate

1. **Staggered adoption:** 14 states adopted between 2009-2024
2. **Clear treatment timing:** Authorization dates are discrete, known events
3. **Sufficient clusters:** 50+ state-year observations
4. **Long pre-period:** MN 2009 adoption allows 9+ years of pre-treatment data

### Parallel Trends Assumption

The identifying assumption is that dental visit rates would have evolved similarly in adopting and non-adopting states absent authorization.

**Supporting evidence to provide:**
- Event study showing flat pre-trends
- Covariate balance checks
- HonestDiD sensitivity analysis for trend violations

**Potential threats:**
- States adopting due to declining dental access (endogenous timing)
- Concurrent Medicaid dental expansions
- Dentist supply trends

---

## Data

### Primary Outcome: BRFSS

**Source:** CDC Behavioral Risk Factor Surveillance System

**Variables:**
1. `LASTDEN4`: When did you last visit dentist?
   - Outcome: Visited within past year (yes/no)
2. `RMVTETH4`: How many permanent teeth removed?
   - Outcome: Any teeth removed due to decay (yes/no)
3. `GENHLTH`/`POORHLTH`: General/poor health (control)

**Years:** 2000-2024 (2024 may not be fully available; use through 2023)

**Level:** State-year (aggregate from individual responses)

**Sample:** All adults 18+ (will also examine low-income subgroup)

### Secondary Outcome: Census Business Dynamics Statistics

**Source:** Census Bureau BDS

**Variables:**
- Establishment counts in NAICS 6212 (Offices of Dentists)
- Establishment births (new entries)

**Years:** 2000-2023

**Level:** State-NAICS-year

### Covariates

| Variable | Source | Purpose |
|----------|--------|---------|
| Population | Census | Denominators |
| % Below poverty | ACS | SES control |
| % Uninsured | ACS | Access control |
| % Age 65+ | ACS | Demographic control |
| Dentists per capita | HRSA AHRF | Supply control |
| Medicaid dental coverage | KFF | Concurrent policy |

---

## Empirical Specification

### Main Estimator: Callaway-Sant'Anna

```r
library(did)

# ATT(g,t) for each cohort g at time t
cs_result <- att_gt(
  yname = "dental_visit_rate",
  tname = "year",
  idname = "state_fips",
  gname = "treatment_year",  # 0 for never-treated
  data = analysis_df,
  control_group = "notyettreated",
  clustervars = "state_fips",
  anticipation = 0,
  base_period = "universal"
)

# Aggregate to event study
es_result <- aggte(cs_result, type = "dynamic", min_e = -8, max_e = 8)

# Aggregate to overall ATT
att_result <- aggte(cs_result, type = "simple")
```

### Robustness Checks

1. **Alternative comparison groups:**
   - Never-treated only
   - Bordering states only

2. **Alternative estimators:**
   - Sun & Abraham (2021) via `fixest::sunab()`
   - Imputation estimator (Borusyak et al.)

3. **Sensitivity analysis:**
   - HonestDiD bounds for parallel trend violations
   - Rambachan-Roth smoothness restrictions

4. **Placebo tests:**
   - Fake treatment timing (shift by 3 years)
   - Fake treatment states (random assignment)

---

## Analysis Plan

### Step 1: Data Construction

1. Download BRFSS annual files 2000-2023
2. Compute state-year dental visit rates
3. Merge treatment timing
4. Merge covariates (ACS, AHRF)

### Step 2: Descriptive Analysis

1. Map of dental therapy adoption timing
2. Raw trends by adoption cohort
3. Summary statistics table

### Step 3: Main Results

1. Event study plot (primary figure)
2. Overall ATT estimate
3. Cohort-specific effects

### Step 4: Heterogeneity

1. By income level (below vs. above median)
2. By urbanicity (rural vs. urban)
3. By baseline dentist supply (shortage vs. adequate)

### Step 5: Robustness

1. Alternative estimators
2. HonestDiD bounds
3. Placebo tests
4. Covariate sensitivity

### Step 6: Mechanism

1. Effect on dental practice entry (BDS data)
2. Effect on teeth removal (quality of care)

---

## Expected Findings

**Primary hypothesis:** Dental therapy authorization increases dental visit rates by 1-3 percentage points among adults.

**Mechanism:** Authorization expands provider capacity, particularly in shortage areas, reducing wait times and travel distances.

**Heterogeneity:** Larger effects expected in:
- Rural areas (fewer dentists)
- Low-income populations (target of policy)
- States with active dental therapy training programs

**Null possibility:** Effects may be small/undetectable if:
- Few dental therapists actually practice (implementation lag)
- Dental therapists substitute for dentists rather than expanding access
- Population-level outcomes too diluted

---

## Paper Structure

1. **Introduction** (400 words)
   - Dental access crisis, especially rural/underserved
   - Dental therapy as policy response
   - This paper's contribution

2. **Background** (600 words)
   - What dental therapists do
   - History of authorization
   - Existing evidence

3. **Data** (500 words)
   - BRFSS description
   - Treatment timing
   - Summary statistics

4. **Empirical Strategy** (600 words)
   - DiD framework
   - Callaway-Sant'Anna estimator
   - Identification assumptions

5. **Results** (800 words)
   - Main event study
   - Overall ATT
   - Heterogeneity

6. **Robustness** (500 words)
   - Alternative estimators
   - Sensitivity analysis
   - Placebo tests

7. **Discussion** (400 words)
   - Interpretation
   - Policy implications
   - Limitations

8. **Conclusion** (200 words)

---

## Figures and Tables

### Main Figures

1. **Map of dental therapy adoption** - Choropleth showing adoption year by state
2. **Event study plot** - Main result with pre/post coefficients
3. **Raw trends by cohort** - Parallel trends visual evidence
4. **Heterogeneity by income** - Event study split by income tercile

### Main Tables

1. **Summary statistics** - Pre/post means by treatment status
2. **Main results** - ATT with various specifications
3. **Robustness checks** - Alternative estimators, controls
4. **Heterogeneity** - Subgroup effects

### Appendix

1. Treatment timing details by state
2. BRFSS variable definitions
3. Full event study coefficients
4. HonestDiD sensitivity plots

---

## Timeline

| Task | Duration |
|------|----------|
| Data acquisition | 1 phase |
| Data cleaning/merge | 1 phase |
| Descriptive analysis | 1 phase |
| Main estimation | 1 phase |
| Robustness/heterogeneity | 1 phase |
| Paper writing | 1 phase |
| Figures/tables | 1 phase |
| Review/revision | 2+ phases |

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Pre-trends failure | Use HonestDiD; consider synthetic control |
| Null results | Report as informative null; focus on heterogeneity |
| Data access issues | BRFSS is public; BDS is public |
| Few treated states | Use never-treated comparison; bootstrap for inference |

---

*This plan is locked. Future modifications go in research_plan.md.*
