# Initial Research Plan

**Paper 40: State Auto-IRA Mandates and Worker Job Mobility**
**Created:** 2026-01-18
**Status:** LOCKED (do not modify after data collection begins)

---

## Research Question

**Do state automatic-enrollment IRA (auto-IRA) mandates affect worker job mobility?**

Traditional employer-sponsored retirement plans (401k) create "job lock" as workers fear losing unvested benefits or face hassle costs in rolling over accounts. State auto-IRA programs, by contrast, create fully portable individual retirement accounts that follow workers across jobs. This paper tests whether mandatory auto-IRA programs increase job mobility by reducing retirement-benefit-related job lock.

---

## Policy Background

### Treatment: State Auto-IRA Mandates

States requiring employers without retirement plans to either offer one or auto-enroll workers in a state-run IRA:

| State | Program Name | Pilot/Launch | Full Implementation |
|-------|-------------|--------------|---------------------|
| Oregon | OregonSaves | Jul 2017 | May 2020 |
| Illinois | Secure Choice | Nov 2018 | Nov 2019 |
| California | CalSavers | Jul 2019 | Dec 2022 |
| Maryland | MarylandSaves | Sep 2022 | 2024 |
| Connecticut | MyCTSavings | Mar 2022 | 2023 |
| Colorado | Colorado SecureSavings | Jan 2023 | 2024 |
| New Jersey | RetireReady NJ | Mar 2024 | 2025 |
| Virginia | RetirePath | Jul 2023 | 2024 |

### Focus: Early Adopters (COVID-Robust Design)
To avoid COVID confounding, primary analysis focuses on **Oregon (2017)** and **Illinois (2018)** which have substantial pre-COVID post-treatment periods.

---

## Identification Strategy

### Primary Approach: Staggered Difference-in-Differences

**Treatment definition:** State × Post-mandate × Likely-eligible worker

**Likely-eligible workers** (proxy): Workers in industries/occupations with low baseline retirement plan coverage. Using 2015-2016 CPS data, identify industries where <50% of workers have employer-sponsored retirement plans.

### Specification

```
Y_ist = α + β(State_s × Post_t × HighExposure_i) + γ(State_s × Post_t) + δ(State_s × HighExposure_i) + θ(Post_t × HighExposure_i) + State_FE + Year_FE + X_ist + ε_ist
```

Where:
- Y_ist = job mobility outcome for individual i in state s at time t
- HighExposure_i = indicator for industry/occupation with low baseline retirement coverage
- X_ist = individual controls (age, education, race, gender, marital status)

### Event Study Specification

```
Y_ist = α + Σ_k β_k × 1{t - EventYear_s = k} × HighExposure_i + Controls + ε_ist
```

### Robustness Checks
1. Modern staggered DiD estimators (Callaway-Sant'Anna, Sun-Abraham)
2. Synthetic control for Oregon/Illinois
3. Border-county analysis (OR-WA, IL-WI/IN borders)
4. Varying definitions of "high exposure" industries

---

## Data

### Primary: IPUMS-CPS Monthly Data (2010-2024)
- **Source:** IPUMS API (key available)
- **Sample:** Adults 18-64 in labor force
- **Key variables:**
  - Job tenure (JBTENURE, available in tenure supplement)
  - Industry (IND), Occupation (OCC)
  - State (STATEFIP)
  - Employment status, hours worked
  - Demographics (age, education, race, sex)

### Secondary: CPS Annual Social and Economic Supplement (ASEC)
- Retirement plan coverage at prior job
- Health insurance coverage (placebo)
- Income and benefits

### Tertiary: Quarterly Workforce Indicators (QWI)
- State-industry-quarter level job flows
- Hires, separations, job-to-job transitions
- Can validate individual-level findings at aggregate level

---

## Outcome Variables

### Primary Outcomes
1. **Job-to-job transitions** (changed employer in past year)
2. **Job tenure** (months at current employer)
3. **Voluntary separations** (quit rate proxy)

### Secondary Outcomes
1. **Labor force participation** (especially ages 55-64)
2. **Hours worked** (full-time vs. part-time)
3. **Self-employment** (entrepreneurship)

### Placebo Outcomes
1. **Health insurance coverage** (should not be affected by retirement mandates)
2. **Wage levels** (secondary channel, may show small effects)

---

## Sample Construction

### Treatment States (Early Adopters)
- Oregon: Treatment = 2017+
- Illinois: Treatment = 2018+

### Control States
States without auto-IRA mandates as of 2020:
- Geographic neighbors: Washington, Idaho, Nevada (for Oregon); Wisconsin, Indiana, Iowa (for Illinois)
- Similar states by propensity score

### Exclusions
- Federal employees
- Self-employed (already have access to SEP-IRA)
- Workers in industries with >80% retirement plan coverage (not affected)
- 2020 (COVID year) in sensitivity analysis

---

## Timeline

| Week | Task |
|------|------|
| 1 | Data download from IPUMS; construct analysis sample |
| 2 | Construct treatment and outcome variables; summary statistics |
| 3 | Main DiD regressions; event study graphs |
| 4 | Robustness checks; heterogeneity analysis |
| 5 | Write paper draft |
| 6 | Compile PDF; review and revise |

---

## Expected Contributions

1. **First paper** examining worker (not firm) labor market responses to auto-IRA mandates
2. **Novel mechanism test**: portable retirement benefits reduce job lock
3. **Policy implications**: Informs debate on federal auto-IRA proposals

---

## Potential Findings

### If auto-IRAs increase job mobility:
- Suggests portable benefits reduce job lock
- Supports federal expansion of auto-IRA programs
- May find heterogeneous effects by age (older workers benefit more from portability)

### If no effect on job mobility:
- Job lock from retirement benefits may be small
- Or auto-IRAs not salient enough to affect behavior
- Still informative for policy (mandates don't distort labor market)

---

## Key Threats to Identification

1. **Simultaneity**: States adopting auto-IRAs may also pass other labor reforms
   - *Mitigation*: Control for state-specific time trends; check for other policy adoptions

2. **Selection into treatment**: Progressive states may have different labor market trends
   - *Mitigation*: Event study to check pre-trends; synthetic control

3. **Treatment misclassification**: Can't perfectly identify eligible workers
   - *Mitigation*: Triple-difference with high/low exposure industries; validate with SIPP

4. **COVID-19**: Major shock during rollout period
   - *Mitigation*: Focus on early adopters; drop 2020; interact with COVID indicators

---

## Code Structure

```
output/paper_40/
├── code/
│   ├── 01_download_data.py      # IPUMS API download
│   ├── 02_clean_data.py         # Sample construction
│   ├── 03_summary_stats.py      # Descriptive statistics
│   ├── 04_main_analysis.py      # DiD and event study
│   ├── 05_robustness.py         # Alternative specifications
│   └── 06_figures.py            # Generate figures
├── data/
│   ├── raw/                     # Downloaded data
│   └── clean/                   # Analysis-ready data
└── figures/
    ├── event_study.png
    ├── parallel_trends.png
    └── heterogeneity.png
```

---

*This plan is locked. Any modifications should be documented in research_plan.md.*
