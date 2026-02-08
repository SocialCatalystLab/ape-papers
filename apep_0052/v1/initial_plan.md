# Initial Research Plan: Broadband Internet and Moral Foundations in Local Governance

## Research Question

**Does broadband internet expansion affect the moral foundations expressed by local government officials during public meetings?**

Specifically, we examine whether crossing a high-broadband adoption threshold (70% of households) causes shifts in:
1. Individualizing foundations (Care + Fairness)
2. Binding foundations (Loyalty + Authority + Sanctity)
3. The Universalism vs. Communal ratio (Individualizing/Binding)

## Theoretical Framework

### Moral Foundations Theory (Haidt 2012)

Moral Foundations Theory posits that human moral reasoning is built on five innate psychological foundations:

1. **Care/Harm**: Sensitivity to suffering, concern for others' well-being
2. **Fairness/Cheating**: Concern for proportional justice and reciprocity
3. **Loyalty/Betrayal**: In-group loyalty and self-sacrifice for the collective
4. **Authority/Subversion**: Respect for tradition, hierarchy, and legitimate authority
5. **Sanctity/Degradation**: Concerns about purity, contamination, and sacredness

These foundations cluster into two higher-order dimensions:
- **Individualizing** (Care + Fairness): Emphasize individual rights and welfare
- **Binding** (Loyalty + Authority + Sanctity): Emphasize group cohesion and social order

Research shows systematic differences in foundation emphasis across the political spectrum, with liberals emphasizing Individualizing foundations and conservatives emphasizing all five (including Binding) more equally.

### Mechanisms: How Broadband Could Affect Moral Language

**H1: Information Exposure Hypothesis**
- Broadband increases exposure to national media and diverse viewpoints
- Could shift moral language toward whichever perspective dominates online discourse
- Prediction: Effect depends on content of dominant online sources

**H2: Echo Chamber Hypothesis**
- Broadband enables self-selection into ideologically homogeneous information environments
- Could amplify pre-existing moral orientations
- Prediction: Treated places become more extreme in baseline direction

**H3: Nationalization Hypothesis**
- Broadband connects local politics to national partisan discourse
- Local officials may adopt national political language
- Prediction: Convergence toward nationally prevalent moral frames

**H4: Deliberation Hypothesis**
- Broadband facilitates citizen engagement and feedback (email, social media)
- Officials may moderate language to satisfy diverse constituents
- Prediction: Convergence toward middle, reduced moral language intensity

## Identification Strategy

### Primary: Staggered Difference-in-Differences

**Treatment Definition:**
- Treatment = First year place crosses 70% household broadband subscription threshold
- Data: ACS Table B28002 (2013-2022, annual, place-level)
- Treatment timing varies across places (staggered adoption)

**Estimator: Callaway-Sant'Anna (2021)**

The CS estimator addresses issues with TWFE under treatment effect heterogeneity:
- Estimates group-time average treatment effects: ATT(g,t)
- Aggregates to overall ATT avoiding "forbidden comparisons"
- Produces clean event study visualization

**Specification:**
$$Y_{pt} = \text{CS-ATT}(g_p, t) + \varepsilon_{pt}$$

Where:
- $Y_{pt}$: Moral foundations score for place $p$ in year $t$
- $g_p$: Treatment cohort (year place first crosses 70% threshold)
- Controls: Place FE, year FE, time-varying demographics

**Comparison Groups:**
- Never-treated: Places that never reach 70% threshold by 2022
- Not-yet-treated: Places that will cross threshold but haven't yet

### Secondary: Instrumental Variables (Terrain Ruggedness)

**Motivation:** Address endogeneity of broadband adoption

**Instrument:** Terrain ruggedness index (Nunn-Puga 2012)
- Rugged terrain → higher deployment costs → slower broadband rollout
- Standard instrument in broadband literature (Kolko 2012)

**First Stage:**
$$Broadband_{pt} = \alpha_p + \gamma_t + \pi \cdot (Ruggedness_p \times Post2013_t) + X_{pt}'\delta + \nu_{pt}$$

**Second Stage:**
$$Y_{pt} = \alpha_p + \gamma_t + \beta \cdot \widehat{Broadband}_{pt} + X_{pt}'\delta + \varepsilon_{pt}$$

**Exclusion Restriction:** Terrain affects moral language only through broadband deployment (plausible but discuss caveats for agriculture-dependent areas)

## DiD Feasibility Assessment

### Exposure Alignment

| Question | Answer |
|----------|--------|
| Who is treated? | All residents of places with >70% broadband |
| Who generates outcome? | Local government officials (council members, mayors, board members) |
| Primary population | Officials in treated places |
| Placebo population | Not applicable (no unaffected subgroup within treated places) |
| Design | Standard DiD (not DDD) |
| Intensity variation | Continuous broadband rate for dose-response |

### Power Assessment

| Criterion | Assessment | Rating |
|-----------|------------|--------|
| Pre-treatment periods | 2-4 years for most cohorts (2013-treatment) | MARGINAL |
| Treated clusters | ~500+ places expected to cross threshold | STRONG |
| Post-treatment periods | 2-7 years depending on cohort | STRONG |
| MDE | Need to calculate based on variance | TBD |

### Selection Concerns

Broadband adoption is endogenous to:
- Income/wealth (richer places adopt faster)
- Education levels
- Urban/rural status
- Age demographics
- Political engagement

**Mitigation Strategies:**
1. IV with terrain ruggedness (addresses geography-driven selection)
2. Control for time-varying ACS demographics
3. Examine pre-trends explicitly (event study)
4. HonestDiD sensitivity analysis (Rambachan-Roth)
5. Matching/IPW robustness

## Data Sources

### LocalView Database
- **Source:** Harvard Dataverse
- **Coverage:** 153,452 meetings, 1,033 places, 49 states, 2006-2023
- **Key Variables:** st_fips, place_name, meeting_date, caption_text_clean
- **Pre-processing:** Moral Foundations Dictionary scoring implemented (eMFD)

### ACS Broadband (Table B28002)
- **Source:** Census API
- **Coverage:** All places, 2013-2022 (5-year estimates)
- **Key Variables:**
  - B28002_001E: Total households
  - B28002_004E: Households with broadband subscription
- **Derived:** broadband_rate = B28002_004E / B28002_001E

### Terrain Ruggedness Index
- **Source:** Nunn & Puga (2012), available at diegopuga.org
- **Coverage:** All U.S. counties
- **Merge:** County to place via county FIPS

### ACS Demographics (Controls)
- **Source:** Census API
- **Variables:** Median income, % college educated, % white, % urban, median age

## Variable Definitions

### Outcome Variables (from LocalView)

| Variable | Definition |
|----------|------------|
| care_p | Care foundation words per 1,000 words |
| fairness_p | Fairness foundation words per 1,000 words |
| loyalty_p | Loyalty foundation words per 1,000 words |
| authority_p | Authority foundation words per 1,000 words |
| sanctity_p | Sanctity foundation words per 1,000 words |
| individualizing | (care_p + fairness_p) / 2 |
| binding | (loyalty_p + authority_p + sanctity_p) / 3 |
| univ_comm_ratio | individualizing / binding |

### Treatment Variables

| Variable | Definition |
|----------|------------|
| broadband_rate | Fraction of HH with broadband subscription |
| treated | 1 if place ever crosses 70% threshold |
| treat_year | First year place crosses 70% threshold |
| post | 1 if year >= treat_year |
| rel_year | year - treat_year (event time) |

### Control Variables (ACS)

| Variable | Definition |
|----------|------------|
| log_income | Log median household income |
| pct_college | % adults with bachelor's degree or higher |
| pct_white | % white population |
| pct_urban | % urban population |
| median_age | Median age |
| log_pop | Log population |

## Analysis Plan

### Step 1: Data Preparation
1. Merge LocalView (place-year) with ACS broadband
2. Construct treatment indicators (threshold crossing)
3. Merge terrain ruggedness at county level
4. Aggregate to place-year panel

### Step 2: Descriptive Analysis
1. Summary statistics (treated vs never-treated)
2. Treatment timing distribution
3. Broadband adoption trends by cohort
4. Moral foundations trends by treatment status

### Step 3: Main DiD Analysis
1. Callaway-Sant'Anna event study
2. Aggregate ATT estimates
3. Pre-trend tests (joint F-test on pre-period coefficients)
4. HonestDiD sensitivity bounds

### Step 4: IV Analysis
1. First-stage (ruggedness → broadband)
2. Reduced form (ruggedness → moral foundations)
3. 2SLS estimates
4. Falsification: ruggedness on pre-period outcomes

### Step 5: Robustness
1. Alternative thresholds (65%, 75%)
2. Continuous treatment TWFE
3. FCC broadband measure
4. Matching/IPW estimator
5. Dropping specific cohorts
6. Placebo outcomes

### Step 6: Heterogeneity
1. By baseline partisanship (county-level vote share)
2. By rurality (urban vs suburban vs rural)
3. By government type (city council vs county board vs school board)
4. By baseline moral orientation

## Expected Results

Given the theoretical ambiguity, we do not have strong priors on direction. Possible patterns:

**If Nationalizing Effect:**
- Treated places converge toward national partisan language
- Conservative areas: ↑ Binding
- Liberal areas: ↑ Individualizing

**If Echo Chamber Effect:**
- Amplification of baseline orientation
- All places become more extreme in their direction

**If Deliberation Effect:**
- Moderation: ↓ Moral language intensity overall
- Convergence toward center

**Null Effect:**
- Local governance language is insulated from internet effects
- Information consumption doesn't translate to official rhetoric

## Code Structure

```
output/paper_68/code/
├── 00_packages.R           # Load libraries, set options
├── 01_fetch_data.R         # Download ACS, merge with LocalView
├── 02_clean_data.R         # Variable construction, panel setup
├── 03_main_analysis.R      # DiD event study (C-S estimator)
├── 04_iv_analysis.R        # Terrain ruggedness IV
├── 05_robustness.R         # All robustness checks
├── 06_figures.R            # Main figures
├── 07_tables.R             # Main tables
├── 08_appendix_figs.R      # Appendix figures
└── 09_appendix_tables.R    # Appendix tables
```

## Figure Plan (Minimum 5 Main + Appendix)

### Main Text Figures

1. **Figure 1: Broadband Adoption Over Time**
   - Panel A: Mean broadband rate by year
   - Panel B: Treatment rollout (cohort timing)

2. **Figure 2: Moral Foundations by Treatment Status**
   - Trends in Individualizing vs Binding foundations
   - Treated vs Never-treated groups

3. **Figure 3: Event Study — Individualizing Foundations**
   - Callaway-Sant'Anna event study plot
   - Pre-trends visible, post-treatment dynamics

4. **Figure 4: Event Study — Binding Foundations**
   - Same structure as Figure 3 for Binding dimension

5. **Figure 5: IV Results — First Stage**
   - Binscatter: Ruggedness vs Broadband (residualized)
   - Shows strength of instrument

### Appendix Figures

6. Event study for each individual foundation (5 plots)
7. Heterogeneity by partisanship
8. Heterogeneity by rurality
9. HonestDiD sensitivity plots
10. Alternative thresholds (65%, 75%)
11. Map: Treatment timing by geography

## Table Plan (Minimum 5 Main + Appendix)

### Main Text Tables

1. **Table 1: Summary Statistics**
   - Place-year observations, outcomes, covariates
   - By treatment status

2. **Table 2: Treatment Timing**
   - Number of places by treatment year
   - Cohort sizes

3. **Table 3: Main DiD Results**
   - ATT estimates for each outcome
   - With and without controls

4. **Table 4: IV Results**
   - First stage F-stat
   - Reduced form
   - 2SLS

5. **Table 5: Robustness**
   - Alternative specifications side-by-side

### Appendix Tables

6. Balance table (treated vs never-treated)
7. Pre-trend tests
8. HonestDiD bounds
9. Heterogeneity subgroups
10. Individual foundation results
11. Alternative broadband measures

## Timeline

Phase 4 (Execution) checklist:
- [ ] Commit initial_plan.md before data fetch
- [ ] Fetch ACS broadband data
- [ ] Fetch terrain ruggedness data
- [ ] Merge all datasets
- [ ] Run main DiD analysis
- [ ] Run IV analysis
- [ ] Run robustness checks
- [ ] Generate all figures
- [ ] Generate all tables
- [ ] Write full paper (30-45 pages main + appendix)

## Output Checklist (Per User Requirements)

- [ ] 30-45 pages main manuscript (prose, no bullets)
- [ ] 4+ page introduction with 20+ citations
- [ ] 5+ publication-ready figures (main text)
- [ ] 5+ professionally formatted tables (main text)
- [ ] 5+ appendix figures
- [ ] 5+ appendix tables
- [ ] Modular LaTeX (one file per section)
- [ ] Universalism vs Communal dimension included
- [ ] Real data only (no simulation)
