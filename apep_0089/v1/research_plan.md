# Initial Research Plan: Do Nurse Practitioners Displace Physicians?
## Full Practice Authority and the Physician Labor Market

**Paper ID:** paper_111
**Date:** 2026-01-30
**Status:** Locked before data fetch

---

## 1. Research Question

**Primary Question:** Does the adoption of Full Practice Authority (FPA) for nurse practitioners cause a decline in physician employment at the state level?

**Hypothesis:** FPA adoption will lead to a reduction in physician employment as:
1. NPs directly substitute for physicians, reducing demand
2. Physicians relocate to states with more favorable competitive environments
3. New physicians avoid FPA states for initial practice location

**Null Hypothesis:** FPA has no effect on physician employment because:
1. Physician and NP services are complements, not substitutes
2. FPA addresses unmet demand without displacing physicians
3. Physician labor markets are geographically segmented by specialty

---

## 2. Policy Background

### Full Practice Authority (FPA)
FPA allows nurse practitioners to evaluate patients, diagnose, order and interpret diagnostic tests, and initiate and manage treatments (including prescribing medications and controlled substances) without physician oversight.

### Staggered State Adoption
| State | Year | Notes |
|-------|------|-------|
| Alaska | <1994 | Early pioneer |
| Oregon | <1994 | Early pioneer |
| Washington | <1994 | Early pioneer |
| New Hampshire | <1994 | Early pioneer |
| Iowa | 1994 | |
| Montana | 1994 | |
| New Mexico | 1994 | |
| Maine | <2000 | |
| Vermont | <2000 | |
| Wyoming | <2000 | |
| Colorado | <2000 | |
| Arizona | ~2000 | |
| Hawaii | ~2000 | |
| Idaho | ~2000 | |
| Rhode Island | 2008 | |
| North Dakota | ~2011 | |
| Nevada | 2013 | |
| Connecticut | 2014 | |
| Minnesota | 2014 | |
| Maryland | 2015 | |
| Nebraska | 2015 | |
| South Dakota | 2017 | |
| Massachusetts | 2021 | |
| Delaware | 2021 | |
| New York | 2022 | |
| Kansas | 2022 | |
| Utah | 2023 | |

### Restricted/Reduced Practice States (Control Group)
California, Florida, Georgia, Michigan, Missouri, North Carolina, Oklahoma, South Carolina, Tennessee, Texas, Virginia, and others maintain physician oversight requirements.

---

## 3. Identification Strategy

### Design: Staggered Difference-in-Differences

**Treatment:** State adoption of Full Practice Authority
**Control:** States with reduced/restricted practice authority
**Unit of analysis:** State × Year
**Time period:** 2000-2024 (24 years)

### Key Advantages
1. **Multiple treated units:** 27+ states adopted FPA
2. **Staggered timing:** Adoptions spread across 30+ years
3. **Permanent control group:** ~20 states never adopted FPA
4. **Pre-treatment periods:** Early adopters have 20+ years of pre-treatment data

### Estimation
- **Primary estimator:** Callaway-Sant'Anna (2021) for staggered DiD
  - Handles heterogeneous treatment effects across cohorts
  - Avoids "forbidden comparisons" (treated vs. later-treated)
- **Robustness:** Sun-Abraham (2021) interaction-weighted estimator
- **Event study:** Group-time ATT estimates for pre-trends visualization

### Exposure Alignment (Who is Actually Treated?)

**Primary Estimand Population:** Workers in physician office establishments (NAICS 6211) in FPA-adopting states

**Directly Affected:**
- Nurse practitioners who gain independent practice authority
- Physician practice owners who face increased NP competition
- Healthcare workers in physician offices whose employment depends on practice viability

**Indirectly Affected:**
- Patients in FPA states who may have expanded provider choices
- Workers in NP-led practices (not measured in NAICS 6211)

**Placebo/Control Population:**
- Workers in physician offices in states maintaining restricted/reduced practice authority
- States with FPA adopted before sample period (always-treated, excluded from estimation)

**Design:** Two-group Difference-in-Differences with staggered adoption
- Treatment group: 8 states adopting FPA 2015-2023
- Control group: 23 states maintaining restrictive practice throughout sample period
- Not triple-diff (no within-state control group)

**Data-Design Alignment:**
- Outcome (NAICS 6211 employment) captures employment in physician office settings
- Treatment (FPA laws) affects competitive environment for physician offices
- Interpretation caveat: Cannot separate effects on physicians vs. support staff within physician offices

### Threats to Identification
1. **Endogenous adoption:** States with physician shortages may adopt FPA
   - *Mitigation:* Control for baseline physician density, test for pre-trends
2. **Concurrent policies:** Other healthcare regulations may confound
   - *Mitigation:* Placebo tests on non-healthcare industries
3. **Anticipation effects:** Physicians may respond before law takes effect
   - *Mitigation:* Use effective date, not passage date; test anticipation window

---

## 4. Data Sources

### Outcome: Physician Employment
**Source:** BLS Quarterly Census of Employment and Wages (QCEW)
- NAICS 6211: Offices of Physicians
- State × Year aggregates
- Variables: Employment level, establishments, average weekly wage
- Time period: 1990-2024

**API Access:**
```
https://data.bls.gov/cew/data/api/{year}/a/industry/6211.csv
```

### Treatment: FPA Adoption Dates
**Source:** Compiled from AANP State Practice Environment, academic literature (DePriest et al. 2020, PMC7581487), and legislative records

### Controls
- State population (Census)
- Per capita income (BEA)
- Healthcare sector trends (QCEW NAICS 62)
- Medical school graduates (AAMC)

---

## 5. Primary Specification

```r
# Callaway-Sant'Anna ATT(g,t) estimation
att_gt <- att_gt(
  yname = "log_physician_emp",
  tname = "year",
  idname = "state_fips",
  gname = "fpa_year",  # 0 for never-treated
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  clustervars = "state_fips"
)

# Aggregate to simple ATT
agg_simple <- aggte(att_gt, type = "simple")

# Event study
agg_es <- aggte(att_gt, type = "dynamic", min_e = -10, max_e = 10)
```

---

## 6. Expected Results

### If Competition Hypothesis Correct
- **Negative ATT:** FPA reduces physician employment by 2-5%
- **Event study:** Flat pre-trends, declining post-treatment trajectory
- **Heterogeneity:** Larger effects in primary care (more substitutable)

### If Complement Hypothesis Correct
- **Null ATT:** FPA has no significant effect on physician employment
- **Mechanism:** NPs address unmet demand, not physician demand
- **Heterogeneity:** Possible positive effects in underserved areas

### Minimum Detectable Effect
Given ~50 states × 24 years = 1,200 observations:
- With σ = 0.15 log points, cluster SE ≈ 0.03
- MDE at 80% power: ~5% effect size

---

## 7. Robustness Checks

1. **Event study pre-trends:** Visual + joint F-test for pre-period coefficients
2. **Placebo industries:** Manufacturing (NAICS 31-33), Retail (44-45)
3. **Alternative estimators:** Sun-Abraham, Borusyak et al. (2024)
4. **Stacked DiD:** Stack cohorts with clean controls
5. **Excluding early adopters:** Drop pre-2000 adopters (potential selection)
6. **Border discontinuity:** Compare border counties across FPA/non-FPA states
7. **Physician vs. NP employment:** Joint estimation with NP employment

---

## 8. Figures and Tables

### Main Figures
1. **Event study plot:** Dynamic ATT estimates with 95% CI
2. **Map:** FPA adoption timing across states
3. **Raw trends:** Physician employment by FPA status (raw data)

### Main Tables
1. **Summary statistics:** State characteristics by FPA status
2. **Primary results:** ATT estimates with various specifications
3. **Robustness:** Alternative estimators and samples

### Appendix
- A1: FPA adoption dates and sources
- A2: Placebo tests
- A3: Heterogeneity by state characteristics

---

## 9. Contribution

### Theoretical
- First paper to examine supply-side physician response to NP scope expansion
- Challenges "FPA expands access" narrative by identifying potential unintended consequences
- Contributes to literature on occupational licensing and labor market competition

### Policy
- Informs ongoing state debates about NP practice authority
- Quantifies trade-off: increased NP autonomy vs. potential physician displacement
- Relevant for federal proposals to expand NP Medicare reimbursement

---

## 10. Timeline

1. **Data collection:** Fetch QCEW physician employment, compile FPA dates
2. **Descriptive analysis:** Summary statistics, raw trends
3. **Primary estimation:** Callaway-Sant'Anna DiD
4. **Robustness:** Event studies, placebos, alternative estimators
5. **Write-up:** Full paper with tables and figures
