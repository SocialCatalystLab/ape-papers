# Research Plan: Social Network Minimum Wage Exposure

**Paper:** Social Network Minimum Wage Exposure: A New County-Level Measure Using the Facebook Social Connectedness Index

**Date:** 2026-02-04

**Paper Type:** DESCRIPTIVE DATA PAPER (no causal identification)

**Pivot Note:** This paper evolved from a causal spillover analysis to a descriptive data paper. The contribution is introducing a new measure of network minimum wage exposure and documenting its properties, NOT estimating causal effects.

---

## Exposure Alignment (DESCRIPTIVE PAPER)

**IMPORTANT:** This paper evolved into a DESCRIPTIVE DATA PAPER. No causal effects are estimated.

**Who is "treated":** Not applicable - this is a descriptive paper documenting a new measure.

**Primary estimand:** We describe the distribution and properties of network minimum wage exposure, NOT its causal effects on any outcome.

**Placebo/control:** Not applicable - no causal design is employed.

**Design:** DESCRIPTIVE (not DiD or RDD). The paper constructs and characterizes a new measure for future researchers to use.

---

## 1. Research Question (REVISED - Descriptive)

**Primary:** Do minimum wage increases in state j affect labor market outcomes in county c through social network connections, *beyond* what geographic proximity alone would predict?

**Secondary (Mechanisms):**
1. Do social network effects operate through migration/job search information channels?
2. Do effects concentrate in "minimum wage bite" industries (retail, food service)?
3. Do effects appear in hiring flows vs. incumbent wages?

**Null Hypothesis We Want to Reject:** Social networks merely proxy for geography; once we control for distance, SCI adds nothing.

---

## 2. Identification Strategy

### Primary Design: Network Shift-Share Exposure

Following Borusyak-Hull-Jaravel (2022), our design is a network shift-share instrument where:
- **Shocks (g):** State-level minimum wage changes
- **Shares (s):** Social Connectedness Index weights

**Social Network Exposure** for county c at time t:
```
SocialExposure_{ct} = Σⱼ w_{cj} × log(MinWage_{jt})
```

Where:
- w_{cj} = SCI(c,j) / Σₖ SCI(c,k) — normalized social connectedness weight
- Sum is over all counties j NOT in county c's state (leave-own-state-out)

**Geographic Exposure** (benchmark):
```
GeographicExposure_{ct} = Σⱼ g_{cj} × log(MinWage_{jt})
```

Where g_{cj} = 1/distance(c,j) — inverse distance weight

### Key Identification Insight

State × time fixed effects absorb the direct effect of own-state minimum wage changes. We're estimating the **spillover** effect through social networks to **other** states.

### Estimating Equation

```
Y_{cit} = α + β₁ SocialExposure_{ct} + β₂ GeographicExposure_{ct}
        + γ_c + δ_t + λ_i + θ_{st} + X_{ct}'ψ + ε_{cit}
```

Where:
- Y_{cit} = outcome (log employment, log earnings, hires/employment) in county c, industry i, quarter t
- γ_c = county fixed effects
- δ_t = quarter fixed effects
- λ_i = industry fixed effects
- θ_{st} = state × time fixed effects (absorbs own-state minimum wage!)
- X_{ct} = time-varying controls

---

## 3. Data Sources

### Treatment: State Minimum Wages
- Source: Vaghul-Zipperer minimum wage database (via FRED/DOL)
- Period: 2010-2023
- Variation: 30+ states raised minimum wages at different times

### Exposure: Social Connectedness Index (SCI)
- Source: Facebook Research via Humanitarian Data Exchange
- Coverage: ~3,000 US counties × ~3,000 counties = 9 million pairs
- Version: Use 2018 or earliest available snapshot (pre-determined)
- URL: https://data.humdata.org/dataset/social-connectedness-index

### Outcomes: Quarterly Workforce Indicators (QWI)
- Source: Census Bureau LEHD via API
- Granularity: County × quarter × industry (NAICS 2-digit) × demographics
- Outcomes: Employment, earnings, hires, separations, job creation/destruction
- Period: 2010-2023

### Geographic Controls
- County centroids and distances
- Source: Census TIGER files or tidycensus

---

## 4. Mechanism Tests (Heterogeneity)

### By Industry "Bite"
- **High-bite industries** (NAICS 44-45 Retail, 72 Accommodation/Food): Large effects expected
- **Low-bite industries** (NAICS 52 Finance, 54 Professional Services): Near-zero effects (PLACEBO)

### By Worker Demographics
- **Young workers** (age 14-24): More likely minimum wage workers, stronger effects
- **Prime-age workers** (25-54): Less affected, smaller expected effects

### By Outcome Type
- **New hires:** Immediate response to current wage levels
- **Incumbent earnings:** Stickier, slower adjustment
- **Employment flows:** Most granular test of mechanisms

---

## 5. Inference Strategy

### Standard Errors
- **Primary:** Cluster at state level (policy variation unit)
- **Alternative:** Multi-way cluster (state + network community via Louvain)
- **Robustness:** Conley spatial HAC

### Randomization Inference
- Permute minimum wage timing across states (hold magnitudes fixed)
- Re-compute exposure and estimate effects
- Build exact p-values under sharp null

### Leave-One-State-Out Jackknife
- Re-estimate excluding each treated state
- Check if results driven by CA, NY

---

## 6. Robustness Checks

1. **Alternative network measures:** SCI vs. pure geography vs. commuting flows
2. **Alternative SCI vintages:** Test if results robust to different SCI snapshot years
3. **Different exposure windows:** Contemporaneous vs. 1-4 quarter lags
4. **Placebo industries:** Finance and professional services should show no effect
5. **Pre-trend tests:** Event study with pre-treatment periods
6. **Partial identification bounds:** Following Weinstein-Nevo (2023)

---

## 7. Power Assessment

### Sample Size
- ~3,000 counties × ~50 quarters × ~20 industries = ~3 million observations
- With demographics: Even larger

### Treated Variation
- 30+ states with minimum wage changes
- Multiple states per year in staggered adoption
- Substantial within-state minimum wage variation

### Cluster Count
- 50 states for clustering
- Well above threshold for reliable inference

---

## 8. Timeline

| Phase | Tasks |
|-------|-------|
| Data | Fetch SCI county pairs; QWI via Census API; state minimum wages |
| Cleaning | Merge datasets; construct exposure measures; create panel |
| Descriptive | Summary stats; exposure variation maps; pre-trends |
| Main Analysis | Shift-share DiD; horse race with geography; event study |
| Mechanisms | Industry heterogeneity; demographic heterogeneity |
| Robustness | All planned checks including RI |
| Writing | Full paper draft |
| Review | External model reviews |

---

## Commitment

This plan is locked before data fetching. The pivot from Germany→Poland to US SCI-based design is documented in this file.
