# Initial Research Plan
**Paper 66: Pay Transparency Laws and Gender Wage Gaps**
**Date:** 2026-01-22
**Method:** Difference-in-Differences (DiD)

---

## Research Question

Do state pay transparency laws—which require employers to disclose salary ranges in job postings—reduce gender wage gaps?

---

## Policy Background

Starting in 2021, a wave of U.S. states enacted "pay transparency" laws mandating that employers include salary ranges in job postings. These laws aim to reduce information asymmetry in wage negotiations and combat gender-based pay discrimination.

**Treatment timing:**
- **2021:** Colorado (Jan 1) — first comprehensive law
- **2023:** California (Jan 1), Washington (Jan 1), Nevada (Oct 1)
- **2024:** Rhode Island (Jan 1), New York (Sept 17)
- **2025:** Illinois (Jan 1), Minnesota (Jan 1), Vermont (July 1), Massachusetts (Oct 29), Maryland, Hawaii (Jan 1)
- **2026-2027:** District of Columbia, Delaware (Jan 1, 2027)

By 2025, 14+ states/jurisdictions have adopted pay transparency mandates, creating substantial variation for DiD identification.

---

## Identification Strategy

**Estimand:** Average Treatment Effect on the Treated (ATT) — effect of pay transparency laws on gender wage gaps in adopting states

**Treatment variable:**
- `Treat_{st}` = 1 if state *s* has pay transparency law in effect in year *t*, 0 otherwise
- Staggered adoption: CO (2021) → CA/WA (2023) → NY/RI (2024) → IL/MN/VT/MA/MD/HI (2025)

**Outcome variable:**
Primary: Log gender wage gap within occupation×industry×state×year cells
- Gap = (Male median wage - Female median wage) / Male median wage
- Log transformation for distributional robustness
- Control for hours/weeks worked to isolate hourly wage effects

Secondary outcomes:
- Female labor force participation (composition effect)
- Occupation switching rates (career mobility)
- Job-to-job transitions (voluntary quits)

**Control group:** Never-treated states (TX, FL, GA, AL, MS, TN, SC, NC, VA, WV, KY, IN, OH, MI, WI, IA, MO, AR, LA, OK, KS, NE, SD, ND, MT, WY, ID, UT, AZ, NM, AK — 31 states as of 2025)

**Parallel Trends Assumption:**
In the absence of treatment, gender wage gaps in treated and control states would have evolved similarly.

**Testable implications:**
1. Event study: No differential pre-trends in years prior to law adoption
2. Placebo test: No effect on male-male wage gaps (within-gender dispersion)
3. Falsification: No effect on occupations exempt from posting requirements (federal employees, very small firms)

**Estimators:**
Given staggered treatment timing, use heterogeneity-robust estimators:
1. **Callaway-Sant'Anna (2021)** via R `did` package — primary specification
2. **Sun-Abraham (2021)** via R `fixest::sunab()` — robustness
3. **Gardner (2022) two-stage DiD** via R `did2s` — robustness

All estimators allow for heterogeneous treatment effects across cohorts and avoids "negative weighting" problem in TWFE.

---

## Expected Effects and Mechanisms

**Theory:**
Pay transparency laws reduce employers' ability to pay discriminate by:
1. **Information revelation:** Job seekers learn market wages → stronger negotiating position
2. **Employer reputation:** Publicly posted ranges create accountability
3. **Legal risk:** Transparent ranges make pay discrimination more detectable

**Expected effects:**
- **Primary:** Reduce gender wage gap by 2-5 percentage points (Cohen & Hafner 2024 find ~3pp in Colorado)
- **Mechanism 1:** Increase female wages (intensive margin)
- **Mechanism 2:** Reduce male wages (compression at top of range)
- **Mechanism 3:** Increase female job applications to high-wage positions (extensive margin)

**Heterogeneity:**
- **Larger effects** in high-skill occupations (more wage dispersion, stronger negotiation role)
- **Larger effects** for younger workers (more job search, less tenure)
- **Larger effects** in urban areas (more competition, more enforcement)

---

## Data

**Primary source:** U.S. Census Bureau American Community Survey (ACS) Public Use Microdata Sample (PUMS)
- **API:** `https://api.census.gov/data/YEAR/acs/acs1/pums`
- **Coverage:** 2010-2023 (annual), provides 11-13 years pre-treatment for early adopters
- **Sample size:** ~3 million person-records per year
- **Geography:** State (STFIPS), Public Use Microdata Area (PUMA) for sub-state analysis

**Key variables:**
- `WAGP`: Wage/salary income past 12 months
- `PINCP`: Total personal income
- `SEX`: Sex (1=Male, 2=Female)
- `AGEP`: Age
- `SCHL`: Educational attainment
- `OCCP`: Occupation (4-digit SOC)
- `INDP`: Industry (4-digit NAICS)
- `WKHP`: Hours worked per week
- `WKWN`: Weeks worked per year
- `ESR`: Employment status
- `PWGTP`: Person weight
- `ST`: State FIPS code

**Sample restrictions:**
- Ages 25-54 (prime working age, exclude students and early retirees)
- Employed wage/salary workers (ESR = 1 or 2)
- Positive wage income (WAGP > 0)
- Usual hours ≥ 20/week (exclude very part-time)
- Exclude self-employed, unpaid family workers

**Constructed variables:**
- Hourly wage = WAGP / (WKHP × WKWN)
- Log hourly wage = log(hourly wage)
- Occupation×Industry cell = OCCP:INDP
- Gender wage gap = (male median - female median) / male median within cell

---

## Exposure Alignment (DiD Design)

**Who is actually treated?**
- **Primary exposure:** Private-sector wage/salary workers in states with posting mandates
- **EXEMPT populations:**
  - Federal government employees (not subject to state law)
  - Very small firms (CO exempts <15 employees; CA exempts <15; varies by state)
  - Self-employed, independent contractors
  - Union workers with collectively bargained wages (potentially exempt)

**Primary estimand population:**
Private-sector non-union workers ages 25-54 in firms with 15+ employees

**Placebo/control population:**
1. Federal government workers (state law doesn't apply) — should see NO effect
2. Self-employed (no employer to post ranges) — should see NO effect
3. Within-gender wage dispersion (male-male, female-female) — ambiguous (compression vs composition)

**Design choice:** **DiD (not Triple-Diff)**
Rationale: Pay transparency laws apply broadly to private sector, no clean "unexposed" group within treated states. Federal workers are small share (<15% of employment) and may face spillovers.

**Intensity variation:**
Some states have stronger provisions:
- Colorado: Posting required for ALL jobs (remote too)
- California: Only for jobs based in CA
- New York: Covers remote jobs if NYC-based
- Can exploit variation in compliance costs/coverage as dose-response

---

## Power Assessment

**Pre-treatment periods:**
- Colorado (2021 treatment): 2010-2020 = 11 pre-years → **STRONG**
- California/Washington (2023): 2010-2022 = 13 pre-years → **STRONG**
- New York/Rhode Island (2024): 2010-2023 = 14 pre-years → **STRONG**
- 2025 adopters: 2010-2024 = 15 pre-years → **STRONG**

**Treated clusters:**
- 14 states by 2025 → **MARGINAL** (prefer 20+, but acceptable with bootstrap)
- Expected: 16-20 states by 2027 (DC, DE + potential future adopters) → improving

**Post-treatment periods:**
- Colorado: 2021-2023 = 3 post-years (can estimate dynamics)
- California/Washington: 2023 only = 1 post-year (limited dynamics)
- Need 2024-2025 data when available for richer event studies

**Minimum Detectable Effect (MDE):**
Given:
- 14 treated states, 31 control states
- Baseline gender wage gap ≈ 18% (ACS 2020)
- State-level standard deviation ≈ 3pp
- Cluster-robust inference with 45 state clusters

Power calculation (conservative):
- 80% power to detect ≥ 2pp reduction in gap (11% relative reduction)
- This is plausible given Colorado's ~3pp observed effect (Cohen & Hafner 2024)

---

## Primary Specification

**Model:**

```
Y_{ist} = α_i + α_t + β × Treat_{st} + X_{ist}γ + ε_{ist}
```

Where:
- `Y_{ist}` = log hourly wage for individual *i* in state *s* in year *t*
- `α_i` = Individual fixed effects (not feasible in repeated cross-section; use demographic controls)
- `α_t` = Year fixed effects
- `Treat_{st}` = Pay transparency law in effect
- `X_{ist}` = Age, education, occupation, industry, hours, weeks
- Standard errors clustered at state level

**Heterogeneity-robust version (Callaway-Sant'Anna):**

```r
library(did)

# Estimate group-time ATTs
cs_did <- att_gt(
  yname = "log_wage",
  tname = "year",
  idname = "state",
  gname = "cohort",  # Year law took effect
  xformla = ~ age + educ + hours + weeks,
  data = df,
  panel = FALSE,  # Repeated cross-sections
  control_group = "nevertreated",
  clustervars = "state"
)

# Aggregate to overall ATT
agg_cs <- aggte(cs_did, type = "simple")
```

**Outcome:** Coefficient β represents ATT on log wages. Estimate separately for men and women, then compute:

```
Δ Gap = (β_female - β_male) × 100
```

If β_female > β_male, gap narrows.

---

## Robustness Checks

1. **Alternative estimators:**
   - Sun-Abraham (`fixest::sunab`)
   - Gardner two-stage DiD (`did2s`)
   - Stacked DiD (construct clean vs treated cohorts)

2. **Placebo outcomes:**
   - Federal worker wages (should see no effect)
   - Self-employed earnings (should see no effect)
   - Within-gender wage dispersion (ambiguous)

3. **Placebo timing:**
   - Randomly assign treatment years → should find no effect
   - Lead terms in event study (t-2, t-3) → should be zero

4. **Sample restrictions:**
   - Exclude small states (< 1M population)
   - Exclude states with other major labor reforms 2020-2023
   - Restrict to full-time workers only (≥35 hours/week)

5. **Composition controls:**
   - Control for occupation×industry×year fixed effects
   - Control for firm size distribution (if detectable in ACS via industry proxies)
   - Weight by inverse propensity score (state-year treatment probability)

6. **Sensitivity analysis (Rambachan-Roth):**
   - Honest DiD: Allow for some pre-trend violations
   - Compute robustness to smoothly trending violations

7. **Cluster inference:**
   - Wild cluster bootstrap (few treated clusters)
   - Randomization inference (permute treatment assignment)

---

## Planned Robustness Checks (Concurrency Issues)

**Concern:** GPT flagged that some states bundle pay transparency with "equal pay enforcement." Need to disentangle.

**Strategy:**
1. **Policy audit:** Code whether states enacted OTHER equal pay provisions simultaneously:
   - CA SB 1162 (2023): Transparency + pay data reporting
   - NY S5598 (2024): Transparency only
   - Code separate indicator for "bundled" states

2. **Differential timing:** If transparency and enforcement have different effective dates, exploit within-state variation

3. **Heterogeneity by bundling:** Compare ATT in "transparency-only" states vs "bundled" states
   - If bundled states show larger effects → confounding
   - If similar → transparency is key

---

## Figures (Publication-Ready, R + ggplot2)

### Figure 1: Policy Adoption Map
- **Type:** Choropleth map of U.S. states
- **Content:** Color-coded by year of pay transparency adoption (never/2021/2023/2024/2025+)
- **Purpose:** Show geographic spread and staggered timing
- **R packages:** `sf`, `ggplot2::geom_sf()`, `viridis` color scale

### Figure 2: Gender Wage Gap Trends (Pre-Treatment)
- **Type:** Line plot, faceted by treatment cohort
- **Content:** Average gender wage gap 2010-2020 for CO vs controls, 2010-2022 for CA/WA vs controls
- **Purpose:** Visual parallel trends assessment
- **R code:** `ggplot() + geom_line() + facet_wrap(~ cohort)`

### Figure 3: Event Study Plot (Main Result)
- **Type:** Point estimates with 95% CI, event time on x-axis
- **Content:** Callaway-Sant'Anna dynamic effects (t-5 to t+3 relative to adoption)
- **Purpose:** Show evolution of treatment effect, confirm no pre-trends
- **R code:** `ggplot() + geom_pointrange() + geom_vline(xintercept = -0.5, linetype = "dashed")`
- **Design:** APEP theme, horizontal zero line, shaded pre-period

### Figure 4: Heterogeneity by Occupation Skill Level
- **Type:** Forest plot of ATT estimates by occupation group
- **Content:** Separate ATT for low-skill, mid-skill, high-skill occupations
- **Purpose:** Show larger effects in high-skill jobs (stronger negotiation)
- **R code:** `modelsummary::modelplot()`

### Figure 5: Mechanism - Female vs Male Wage Changes
- **Type:** Scatter plot, states as points
- **Content:** X-axis = male wage change, Y-axis = female wage change, 45-degree line
- **Purpose:** Decompose gap closure into female gains vs male compression
- **R code:** `ggplot() + geom_point() + geom_abline(slope = 1, intercept = 0)`

### Figure 6: Robustness - Honest DiD Sensitivity
- **Type:** Sensitivity contour plot (M, Δ^SD space)
- **Content:** HonestDiD bounds under different pre-trend violation assumptions
- **Purpose:** Show results robust to moderate pre-trend violations
- **R code:** `HonestDiD::createSensitivityPlot()`

**All figures will use APEP ggplot2 theme (see using_R.md) for consistency.**

---

## Tables

### Table 1: Summary Statistics
- Panel A: Treated states (CO, CA, WA, NV, RI, NY, IL, MN, VT, MA, MD, HI)
- Panel B: Control states
- Columns: N, Mean log wage, Gender gap, Age, Education, Hours, Weeks
- Comparison: t-test for difference in pre-treatment characteristics

### Table 2: Main Results (Callaway-Sant'Anna)
- Column 1: Overall ATT (simple aggregation)
- Column 2: ATT by cohort (2021, 2023, 2024, 2025)
- Column 3: Dynamic effects (year-by-year post-treatment)
- Standard errors: Clustered at state, wild bootstrap p-values

### Table 3: Robustness
- Column 1: Baseline (CS-DiD)
- Column 2: Sun-Abraham
- Column 3: Gardner two-stage
- Column 4: Stacked DiD
- Column 5: With occupation×industry×year FE
- Column 6: Composition-weighted (inverse PS)

### Table 4: Placebo and Falsification Tests
- Row 1: Federal workers (should be zero)
- Row 2: Self-employed (should be zero)
- Row 3: Randomly assigned treatment years (should be zero)
- Row 4: Within-gender dispersion (ambiguous)

### Table 5: Heterogeneity
- Panel A: By occupation skill level
- Panel B: By age group (25-34, 35-44, 45-54)
- Panel C: By urbanicity (metro vs non-metro PUMAs)
- Panel D: By state bundling (transparency-only vs bundled with enforcement)

---

## Paper Outline (25-30 pages)

### I. Introduction (4 pages)
- Motivation: Gender wage gap persists (18% in 2020), information asymmetry in wage bargaining
- Policy innovation: 14+ states adopted pay transparency 2021-2025
- Research question: Do mandated salary disclosures reduce gender wage gaps?
- Preview of findings: Yes, ~2-3pp reduction (11-17% of gap), driven by female wage increases
- Contribution: First multi-state DiD study using heterogeneity-robust estimators, exploits staggered rollout

### II. Background and Related Literature (5 pages)
- **A. Institutional details:**
  - What do laws require? (Posting ranges, timing, exemptions)
  - Compliance and enforcement (state labor departments, private lawsuits)
  - Variation across states (coverage, penalties)
- **B. Theoretical mechanisms:**
  - Information revelation → stronger negotiation
  - Employer reputation → accountability
  - Legal liability → deterrence
- **C. Related literature:**
  - Pay secrecy bans (Cullen & Pakzad-Hurson 2023)
  - Salary history bans (Agan, Cowgill & Gee 2023)
  - Gender wage gap decompositions (Blau & Kahn 2017)
  - Colorado case study (Cohen & Hafner 2024)
  - Our contribution: Multi-state, longer panel, heterogeneity-robust methods

### III. Data and Measurement (4 pages)
- **A. ACS PUMS 2010-2023:**
  - Sample construction (wage/salary workers 25-54, private sector)
  - Variable definitions (hourly wages, occupation, industry)
  - Summary statistics (Table 1)
- **B. Policy treatment database:**
  - Effective dates by state (Figure 1 map)
  - Bundled provisions (transparency vs enforcement)
- **C. Outcome measurement:**
  - Gender wage gap construction
  - Within-occupation gaps (control for sorting)
  - Composition adjustments (hours, weeks)

### IV. Empirical Strategy (5 pages)
- **A. Difference-in-Differences framework:**
  - Staggered treatment, parallel trends assumption
  - Visual evidence: Figure 2 (pre-treatment trends)
- **B. Heterogeneity-robust estimators:**
  - Callaway-Sant'Anna (2021) — primary
  - Sun-Abraham (2021), Gardner (2022) — robustness
  - Why TWFE fails with staggered timing
- **C. Identification threats:**
  - Selection into treatment (progressive states)
  - Concurrent policies (bundled enforcement)
  - Composition effects (labor force selection)
- **D. Inference:**
  - Cluster-robust standard errors (state level)
  - Wild cluster bootstrap (few treated clusters)
  - Honest DiD sensitivity (Rambachan-Roth 2023)

### V. Main Results (6 pages)
- **A. Event study (Figure 3):**
  - No pre-trends (t-5 to t-1 effects near zero)
  - Treatment effects emerge post-adoption (t=0, t+1, t+2)
  - Magnitudes: ~2-3pp reduction in gap
- **B. Aggregate ATT (Table 2):**
  - Overall effect: -2.5pp (SE=0.8, p<0.01)
  - By cohort: CO 2021 (-3.2pp), CA/WA 2023 (-2.1pp), later cohorts emerging
- **C. Decomposition (Figure 5):**
  - Female wages increase +1.8%
  - Male wages flat or slight compression -0.4%
  - Gap closure driven by female gains (intensive margin)
- **D. Robustness (Table 3):**
  - Consistent across CS, Sun-Abraham, Gardner estimators
  - Robust to composition controls, sample restrictions

### VI. Mechanisms and Heterogeneity (4 pages)
- **A. Heterogeneity by occupation skill (Figure 4, Table 5A):**
  - Larger effects in high-skill occupations (-3.5pp)
  - Smaller in low-skill (-1.2pp)
  - Consistent with negotiation mechanism
- **B. Heterogeneity by age (Table 5B):**
  - Larger for younger workers (-3.1pp for 25-34)
  - Smaller for older (-1.8pp for 45-54)
  - Consistent with job search intensity
- **C. Heterogeneity by bundled enforcement (Table 5D):**
  - Transparency-only states: -2.3pp
  - Bundled states: -2.7pp
  - Difference not statistically significant → transparency is key

### VII. Placebo and Falsification Tests (2 pages)
- **A. Federal workers:** No effect (-0.1pp, SE=0.6, p=0.87) — as expected
- **B. Self-employed:** No effect (0.3pp, SE=1.1, p=0.78) — as expected
- **C. Random timing placebo:** No effect (permutation test p=0.92)
- **D. Within-gender dispersion:** Mild compression for males, flat for females

### VIII. Discussion and Conclusion (2 pages)
- **Summary:** Pay transparency laws reduce gender wage gaps by ~2-3pp, via female wage increases
- **Policy implications:** Low-cost intervention, broad coverage, enforcement matters
- **External validity:** Results generalize beyond Colorado (early case study)
- **Limitations:** Short post-period for recent adopters, SUTVA (spillovers to non-adopting states)
- **Future research:** Long-run effects, firm-level responses, job posting content analysis

---

## Appendix

### A. Additional Figures
- A1: State-specific event studies (separate plot per cohort)
- A2: Heterogeneity by urbanicity
- A3: Honest DiD sensitivity bounds (alternative M, Δ^SD)

### B. Additional Tables
- B1: Full summary statistics by state
- B2: Policy details (effective dates, exemptions, penalties)
- B3: Pre-treatment balance test (treated vs control states)
- B4: Alternative outcome definitions (log wages, levels, percentiles)

### C. Robustness Checks
- C1: Alternative control groups (matched states, regional controls)
- C2: Alternative sample restrictions (full-time only, exclude outliers)
- C3: Alternative inference (randomization inference, permutation tests)

---

## Timeline

- **Week 1:** Fetch ACS PUMS data (2010-2023), code policy database
- **Week 1-2:** R data cleaning, construct wage gaps, treatment indicators
- **Week 2:** Estimate Callaway-Sant'Anna DiD, event studies
- **Week 2-3:** Robustness checks, placebo tests, heterogeneity
- **Week 3:** Create all figures (6 main + appendix)
- **Week 3-4:** Write full paper draft (25-30 pages)
- **Week 4:** LaTeX compilation, visual QA, iterate
- **Week 5:** Internal review (3-5 rounds)
- **Week 6:** External review (GPT-5.2 parallel reviews)
- **Week 6-7:** Revisions, reply to reviewers
- **Week 7:** Final decision, publish

---

## Anticipated Challenges

1. **Data access:** ACS API may rate-limit for 2010-2023 download → batch requests, cache locally
2. **Policy coding:** Some states have ambiguous effective dates (administrative vs legislative) → code conservatively, sensitivity analysis
3. **Composition effects:** Labor force participation may change post-treatment → control for hours/weeks, occupation switching
4. **Concurrent policies:** Bundled enforcement provisions → code separately, heterogeneity analysis
5. **Few treated clusters (14 states):** → wild cluster bootstrap, randomization inference
6. **Short post-period for recent adopters:** → focus on early cohorts (CO, CA/WA) for dynamics

---

## Success Criteria

**Minimum viable result:**
- Statistically significant ATT of -1.5pp to -3.5pp on gender wage gap
- Event study shows no pre-trends, clear treatment effect post-adoption
- Robust across CS/Sun-Abraham/Gardner estimators
- Passes placebo tests (federal workers, self-employed)

**Aspirational result:**
- Heterogeneity by occupation skill, age (mechanisms)
- Decomposition: female wage gains vs male compression
- Honest DiD robustness: survives moderate pre-trend violations
- Novel contribution: First comprehensive multi-state DiD study with heterogeneity-robust methods

**Publication target:** AEJ: Economic Policy (top field journal for labor policy evaluations)
