# Research Plan (Revision of APEP-0146)

## Status: In Revision

## Research Question

What are the causal effects of state salary transparency laws on wage levels and the gender wage gap?

## Key Results (Inherited from Parent)

- **Main effect:** Transparency reduces average wages by 1.2-1.8% (ATT = -0.012 to -0.018)
- **Gender gap:** Narrows by ~1 pp (triple-diff coefficient = +0.012)
- **Heterogeneity:** Effects concentrated in high-bargaining occupations (-0.021 vs -0.009)
- **Robustness:** Results robust across alternative estimators, control groups, sample restrictions

## Revision Changes

### Completed

1. **Code bug fixes:**
   - Fixed `07_tables.R:75`: `statefip > 0` → `first_treat > 0`
   - Fixed `05_robustness.R:141`: Hard-coded 14 states → dynamic lookup from policy data

2. **Paper revisions:**
   - Sharpened introduction: Opens with equity-efficiency trade-off thesis
   - Expanded contribution section: Four clearly delineated contributions
   - Tightened institutional background: Merged sections, cut redundancy
   - Streamlined mechanisms: More concise theoretical discussion
   - Revised limitations: Brief acknowledgment without excessive apology
   - Expanded policy implications: Detailed design considerations

### Pending

- Advisor review
- External reviews
- Final revision based on reviews
- Publish with --parent apep_0146

## Exposure Alignment

**Who is actually treated?**
- Workers in states with active salary transparency laws
- Law affects job seekers (new hires see posted ranges) and incumbents (comparison to market)
- Treatment is state-level: all workers in treated states are potentially affected

**Primary estimand population:**
- All wage/salary workers ages 25-64 in treated states
- Intent-to-treat (ITT) interpretation: not all workers actively search or negotiate

**Placebo/control population:**
- Workers in 43 never-treated states
- Parallel trends assumption: absent treatment, wage trends would be similar

**Design:** Staggered Difference-in-Differences (DiD)
- Treatment cohorts: 2021 (CO), 2022 (CT, NV), 2023 (CA, WA, RI), 2024 (NY, HI)
- Triple-diff (DDD) for gender effects: Female × Treated × Post

**Power Assessment:**
- Pre-treatment periods: 6 years (2015-2020)
- Treated clusters: 8 states
- Post-treatment periods: 1-4 years depending on cohort
- MDE: ~2% detectable with 80% power given sample size

## Data

- **Source:** CPS ASEC 2016-2025 (income years 2015-2024) via IPUMS
- **Sample:** Wage/salary workers ages 25-64, ~650,000 observations
- **Treatment:** 8 states with transparency laws (2021-2024 adoption)

## Analysis Files

- `00_packages.R` - Load libraries
- `00_policy_data.R` - Treatment timing with citations
- `01_fetch_data.R` - CPS ASEC data acquisition
- `02_clean_data.R` - Variable construction
- `03_descriptives.R` - Summary statistics and trends
- `04_main_analysis.R` - Callaway-Sant'Anna estimation
- `05_robustness.R` - Alternative estimators and robustness
- `06_figures.R` - All figures
- `07_tables.R` - All tables
