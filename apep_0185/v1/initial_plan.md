# Initial Research Plan

**Paper:** Cross-Border Minimum Wage Spillovers: Did Germany's 2015 Minimum Wage Affect Polish Labor Markets?

**Date:** 2026-02-04

---

## 1. Research Question

Did Germany's introduction of a national minimum wage (€8.50/hour) on January 1, 2015 affect labor market outcomes in Polish regions near the German border compared to Polish regions in the interior?

**Hypothesis:** Polish border regions experienced:
1. **Wage spillovers:** Increased wages due to competition with higher German wages
2. **Labor supply effects:** Increased outflows of workers to Germany OR tighter local labor markets
3. **Employment reallocation:** Differential employment effects in tradable sectors

---

## 2. Identification Strategy

### Primary Design: Spatial Difference-in-Differences

**Treatment:** Germany's January 1, 2015 minimum wage introduction
- External to Polish regional shocks (federal German policy)
- Sharp timing provides clean event date

**Treatment Intensity:** Geographic proximity to German border
- **Treated:** Polish powiats (NUTS3) adjacent to or near German border
- **Control:** Polish powiats in the interior, far from Germany
- **Continuous measure:** Distance from powiat centroid to nearest German border crossing

**Estimating Equation:**
```
Y_it = α + β₁(Border_i × Post_t) + γ_i + δ_t + X_it'θ + ε_it
```

Where:
- Y_it = outcome (employment rate, wages) in powiat i at time t
- Border_i = 1 if powiat borders Germany (or continuous distance measure)
- Post_t = 1 if t ≥ 2015
- γ_i = powiat fixed effects
- δ_t = year fixed effects
- X_it = time-varying controls (sectoral composition, population)

### Alternative: Synthetic Control Method

For aggregate analysis, construct synthetic Polish border region from interior regions:
- Donor pool: All non-border powiats
- Matching variables: Pre-treatment employment, wages, sectoral composition, demographics
- Inference: Placebo tests using other powiats

---

## 3. Expected Effects and Mechanisms

### Mechanism 1: Commuter Wage Premium
- German minimum wage → Polish commuters to Germany earn more
- Increases returns to cross-border work
- **Test:** Effect should be larger in sectors with high cross-border employment (construction, transport)

### Mechanism 2: Polish Labor Market Tightening
- Higher German wages → more Poles choose to commute/migrate
- Reduces labor supply in Polish border regions
- Polish employers must raise wages to retain workers
- **Test:** Employment effects vs. wage effects; unemployment changes

### Mechanism 3: Trade Competition
- German firms face higher labor costs → become less competitive
- Polish exporters gain market share
- Employment shifts to Polish border regions
- **Test:** Effect should be larger in tradable manufacturing sectors

### Expected Signs:
| Outcome | Expected Effect | Mechanism |
|---------|-----------------|-----------|
| Border region wages | + | Labor tightening |
| Border region employment | Ambiguous | Tightening vs. trade |
| Border region unemployment | - | Tightening |
| Low-wage sector employment | + | Trade competition |

---

## 4. Primary Specification

### Main Model (Event Study):
```
Y_it = α + Σ_k β_k (Border_i × Year_kt) + γ_i + δ_t + ε_it
```

- Reference year: 2014 (last pre-treatment year)
- Pre-treatment years: 2010, 2011, 2012, 2013
- Post-treatment years: 2015, 2016, 2017, 2018, 2019

### Inference:
- Cluster standard errors at powiat level
- Wild cluster bootstrap (Webb 6-point weights) for robustness
- Report both TWFE and Callaway-Sant'Anna estimates

---

## 5. Planned Robustness Checks

### Treatment Definition Robustness:
1. Binary: Border-adjacent (40 powiats) vs. all others (340)
2. Terciles of distance to border
3. Continuous distance (log km)

### Sample Robustness:
4. Exclude Czech-border and Slovakia-border powiats
5. Donut: Exclude powiats 50-150 km from border
6. Within-NUTS2: Only compare within same region

### Placebo Tests:
7. Czech-Poland border (Czech min wage already existed)
8. Pre-trend placebo: Test for effects in 2012-2014
9. Random border assignment within Poland

### Outcome Robustness:
10. Wages at different percentiles (25th, 50th, 75th)
11. Sector-specific employment (tradables vs. non-tradables)
12. Unemployment inflows vs. outflows

---

## 6. Data Requirements

### Primary Data:
- **Eurostat Regional Labour Market Statistics (reg_lmk):** Employment, unemployment by NUTS3
- **EU Labour Force Survey:** Individual-level data with region identifiers
- **EU-SILC:** Income distribution by region

### Secondary Data:
- **Eurostat GISCO:** Geographic boundaries, border calculations
- **Eurostat SBS:** Sectoral employment composition
- **Eurostat Posted Workers Statistics:** Cross-border labor flows

### Time Period: 2010-2019
- Pre-treatment: 2010-2014 (5 years)
- Post-treatment: 2015-2019 (5 years)
- Stop at 2019 to avoid COVID confounds

---

## 7. Power Assessment

### Treated Units: ~40 border powiats
### Pre-Treatment Periods: 5 years
### Post-Treatment Periods: 5 years
### Total Observations: 380 powiats × 10 years = 3,800 powiat-years

### Effect Size Expectations:
- German minimum wage affected ~11% of workers
- Border regions more exposed to low-wage German labor markets
- Reasonable to expect 1-3 pp employment effect, 2-5% wage effect

### Inference:
- 40+ treated clusters sufficient for wild cluster bootstrap
- Power analysis to be conducted with actual data variance

---

## 8. Timeline

| Phase | Tasks |
|-------|-------|
| Data | Fetch Eurostat regional data; construct border distance measures |
| Cleaning | Harmonize NUTS classifications; create panel dataset |
| Descriptive | Summary stats; pre-treatment balance tables; maps |
| Main Analysis | Event study; DiD estimates; mechanism tests |
| Robustness | All planned checks |
| Writing | Full paper draft with figures and tables |
| Review | External model reviews |

---

## Commitment

This plan is locked before data fetching. Any deviations will be documented in research_plan.md with justification.
