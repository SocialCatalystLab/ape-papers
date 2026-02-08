# Paper 49: Initial Research Plan

**Title:** City Votes, Country Voices: Urban-Rural Heterogeneity in the Labor Market Effects of Women's Suffrage

**Date:** 2026-01-21
**Status:** LOCKED (do not modify after data fetch)

---

## Research Question

Did women's suffrage affect female labor force participation differently in urban versus rural areas? If suffrage empowered women to advocate for labor-friendly policies (protective legislation, equal pay, workplace safety), effects should concentrate in urban wage labor markets where such policies could bite. If suffrage primarily shifted social norms, effects might be equally strong or stronger in rural areas where traditional gender norms were more entrenched.

---

## Identification Strategy

### Main Specification

Triple-difference design:
- **First difference:** Pre vs post suffrage adoption within states
- **Second difference:** Treated states vs never-treated states (control)
- **Third difference:** Urban vs rural residents within states

$$Y_{ist} = \alpha + \beta_1 \text{Post}_{st} + \beta_2 \text{Urban}_{ist} + \beta_3 (\text{Post}_{st} \times \text{Urban}_{ist}) + \gamma_s + \delta_t + \varepsilon_{ist}$$

Where:
- $Y_{ist}$ = Labor force participation for woman $i$ in state $s$ at time $t$
- $\text{Post}_{st}$ = 1 if state $s$ has suffrage at time $t$
- $\text{Urban}_{ist}$ = 1 if woman lives in urban area
- $\gamma_s$ = State fixed effects
- $\delta_t$ = Year fixed effects
- $\beta_3$ = Key parameter: differential urban effect of suffrage

### Modern Staggered DiD

Use Callaway-Sant'Anna estimator with:
- Group-time ATT estimates by treatment cohort
- Aggregate to event-study plots
- Stratified by urban/rural for mechanism tests
- Never-treated states as control group

### Addressing Reviewer Concerns

1. **Compositional changes in urbanization:**
   - Control for state-level urbanization rate changes
   - Use 1880 urbanization as fixed baseline heterogeneity
   - Test robustness to "mover" exclusion (restrict to birth-state residents)

2. **Limited pre-periods:**
   - Focus on 1910+ adopters (WA, CA, OR, KS, AZ, MT, NV, NY, MI, OK, SD) with 2-3 pre-periods
   - Exclude early adopters (WY, UT, CO, ID) in robustness checks
   - HonestDiD sensitivity analysis for pre-trend violations

3. **Structural transformation confounds:**
   - Control for state-year manufacturing employment shares
   - Placebo test: male LFP should show no effect
   - Triple-difference removes state-wide shocks affecting both urban/rural

---

## Data

### Source
IPUMS USA Full-Count Census, 1880-1920

### Variables
| Variable | Description | Purpose |
|----------|-------------|---------|
| YEAR | Census year | Time indicator |
| STATEFIP | State FIPS code | State identification |
| SEX | Gender | Sample restriction |
| AGE | Age in years | Sample restriction + control |
| RACE | Racial classification | Heterogeneity |
| MARST | Marital status | Control + heterogeneity |
| LABFORCE | Labor force participation | **Primary outcome** |
| URBAN | Urban/rural residence | **Key heterogeneity** |
| OCC1950 | Occupation (harmonized) | Mechanism exploration |
| LIT | Literacy | Secondary outcome |
| NATIVITY | Native/foreign-born | Control |
| BPL | Birthplace | Mover identification |

### Sample Construction
- Women ages 18-64
- Census years: 1880, 1900, 1910, 1920
- Treated states: CO (1893), ID (1896), WA (1910), CA (1911), OR (1912), KS (1912), AZ (1912), MT (1914), NV (1914), NY (1917), MI (1918), OK (1918), SD (1918)
- Control states: 33 states adopting only via 19th Amendment
- Exclude: WY (1869), UT (1870) — no pre-treatment data

### Expected Sample Size
- Full-count: ~50-80 million women across 4 censuses
- Sufficient for urban/rural × state × year cells

---

## Analysis Plan

### Stage 1: Pilot (0.1% sample)
1. Validate variable construction
2. Check urban/rural distribution by state/year
3. Test parallel trends specification
4. Verify sufficient cells for triple-diff

### Stage 2: Full Analysis
1. **Descriptive statistics** (Table 1)
   - Sample characteristics by treatment status
   - Urban/rural breakdown
   - LFP trends over time

2. **Main results** (Table 2)
   - Column 1: Basic DiD (suffrage effect on LFP)
   - Column 2: Add urban interaction
   - Column 3: Add individual controls
   - Column 4: State-specific trends

3. **Event study** (Figure 1)
   - Overall ATT dynamics
   - Separate by urban/rural

4. **Parallel trends** (Figure 2)
   - Cohort-specific pre-trends
   - By urban/rural status

5. **Heterogeneity** (Table 3)
   - By race (Black vs White)
   - By marital status
   - By age group

6. **Robustness** (Table 4)
   - Exclude early adopters
   - Alternative control groups
   - State-year fixed effects
   - HonestDiD bounds

7. **Mechanisms** (Table 5)
   - Occupational composition
   - Literacy effects
   - Male LFP placebo

---

## Figures (5+ required)

1. **Figure 1:** Map of suffrage adoption by year (choropleth)
2. **Figure 2:** Event study - Overall effect with confidence intervals
3. **Figure 3:** Event study - Urban vs Rural stratified
4. **Figure 4:** Parallel trends by treatment cohort
5. **Figure 5:** Heterogeneity - Effect by race × urban/rural
6. **Figure 6:** HonestDiD sensitivity analysis

---

## Tables (5+ required)

1. **Table 1:** Summary statistics by treatment status and urban/rural
2. **Table 2:** Main results - Triple-difference estimates
3. **Table 3:** Heterogeneity by race, age, marital status
4. **Table 4:** Robustness checks
5. **Table 5:** Mechanism tests (occupation, literacy, male placebo)

---

## Paper Structure (LaTeX Subfiles)

```
output/paper_52/
├── main.tex              # Master document
├── sections/
│   ├── 01_introduction.tex
│   ├── 02_background.tex
│   ├── 03_data.tex
│   ├── 04_methods.tex
│   ├── 05_results.tex
│   ├── 06_mechanisms.tex
│   ├── 07_robustness.tex
│   ├── 08_discussion.tex
│   └── 09_conclusion.tex
├── figures/              # All .pdf figures
├── tables/               # All .tex tables
└── bibliography.bib
```

---

## Timeline

1. **Data fetch:** Submit IPUMS extract (1-4 hours wait)
2. **Pilot analysis:** Validate design
3. **Full analysis:** Run all specifications
4. **Writing:** Complete 30+ page draft
5. **Internal review:** 3-5 rounds
6. **External review:** 5+ rounds with GPT 5.2
7. **Final revision:** Address all comments

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Pre-trends failure | HonestDiD bounds; restrict to late adopters |
| Insufficient urban variation | Full-count data provides ample sample |
| Urbanization composition changes | 1880 baseline urban status; mover exclusion |
| Structural transformation confounds | Male placebo; manufacturing controls |
| Too few clusters | Wild bootstrap; randomization inference |

---

*This plan is LOCKED. Create research_plan.md as working document.*
