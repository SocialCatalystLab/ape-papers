# Pre-Analysis Plan: NYC Fair Workweek Law Effects on Employment

**Study ID:** APEP-NYC-FWW-2026
**Date:** 2026-01-17
**Status:** Pre-registration (prior to data analysis)

---

## 1. Research Question

**Primary Question:** Did New York City's Fair Workweek Law (effective November 26, 2017) affect employment, hours worked, and wages among workers in the fast food and retail sectors?

**Secondary Questions:**
1. Did the law's effects differ between fast food and retail sectors?
2. Were there heterogeneous effects by worker demographics (age, gender, education)?
3. Did the law affect the distribution of weekly hours (shift from variable to stable hours)?

---

## 2. Policy Background

### 2.1 The NYC Fair Workweek Law

On May 30, 2017, NYC Mayor Bill de Blasio signed a suite of legislation known as the "Fair Workweek" bills:

**For Fast Food Employers (employers with 30+ nationwide locations):**
- 14 days advance notice of schedules
- Premium pay for schedule changes within 14 days
- Prohibition of "clopenings" (close-then-open shifts with <11 hours rest)
- Offer additional hours to existing employees before hiring new workers

**For Retail Employers (20+ employees in NYC):**
- 72 hours advance notice of schedules
- Ban on on-call scheduling
- Ban on last-minute shift cancellations without consent

**Effective Date:** November 26, 2017

### 2.2 Theoretical Predictions

**Negative employment effects (standard labor demand):**
- Reduced scheduling flexibility increases labor costs
- Employers may reduce headcount or hours

**Neutral/positive effects (job quality mechanism):**
- Stable schedules may reduce turnover, offsetting compliance costs
- Improved job quality could attract more workers to affected sectors

---

## 3. Identification Strategy

### 3.1 Primary Design: Difference-in-Differences-in-Differences (DDD)

We exploit three sources of variation:

1. **Geographic:** NYC vs. non-NYC metropolitan areas
2. **Industry:** Affected sectors (fast food, retail) vs. non-affected sectors
3. **Time:** Pre-law (2015-2017) vs. post-law (2018-2020)

**DDD Estimating Equation:**

```
Y_ijst = β₀ + β₁(NYC_s × AffectedInd_j × Post_t) 
       + β₂(NYC_s × AffectedInd_j) + β₃(NYC_s × Post_t) + β₄(AffectedInd_j × Post_t)
       + γ_s + δ_j + τ_t + X'_i θ + ε_ijst
```

Where:
- Y = outcome (employment, hours, wages)
- NYC_s = 1 if individual resides in NYC PUMA
- AffectedInd_j = 1 if industry is fast food (NAICS 7222) or retail (NAICS 44-45)
- Post_t = 1 if year ≥ 2018
- γ_s = geography fixed effects (PUMA)
- δ_j = industry fixed effects
- τ_t = year fixed effects
- X_i = individual controls

**β₁ is the coefficient of interest** - the differential change in outcomes for workers in affected industries in NYC, relative to the change for (a) workers in non-affected industries in NYC, and (b) workers in affected industries outside NYC.

### 3.2 Geographic Treatment Definition

**Treatment group: NYC PUMAs**

Using 2010 Census PUMA definitions (used in ACS 2012-2021):
- Manhattan (New York County): PUMAs 3801-3810
- Bronx (Bronx County): PUMAs 3701-3710
- Brooklyn (Kings County): PUMAs 4001-4018
- Queens (Queens County): PUMAs 4101-4114
- Staten Island (Richmond County): PUMAs 3901-3903

**Control groups:**
1. **Within-NY control:** Non-NYC New York State PUMAs
2. **Large metro control:** Chicago IL, Los Angeles CA, Philadelphia PA MSA PUMAs (cities without fair workweek laws as of 2017)

### 3.3 Industry Treatment Definition

**Affected industries (INDP codes in ACS PUMS):**
- **Fast food:** INDP = 8680 (Restaurants and other eating places) - note: cannot perfectly identify "fast food chains" in ACS
- **Retail:** INDP = 4670-5790 (Retail trade industries)

**Control industries:**
- Other service industries not subject to Fair Workweek: Professional services, healthcare, education, manufacturing

### 3.4 Time Period

- **Pre-period:** 2015-2016 (2 years before law)
- **Transition:** 2017 (law signed May, effective Nov)
- **Post-period:** 2018-2019 (2 years after law)
- Exclude 2020 due to COVID-19 confounds

---

## 4. Data Sources and Sample

### 4.1 Primary Data: Census ACS PUMS

- **Years:** 2015-2019 (1-year ACS)
- **Variables:** PUMA, ST, INDP, ESR, WKHP, WAGP, PWGTP, AGEP, SEX, RAC1P, SCHL

### 4.2 Sample Restrictions

- Ages 16-64 (working age)
- Employed in private sector (COW = 1 or 2)
- Non-missing values for key variables
- Exclude self-employed (treatment targets employers)

### 4.3 Expected Sample Size

Based on ACS sample sizes:
- NYC fast food/retail workers: ~15,000 person-years
- Non-NYC NY fast food/retail: ~20,000 person-years
- Control metro fast food/retail: ~80,000 person-years
- Total sample including control industries: ~500,000+ person-years

---

## 5. Outcome Variables

### 5.1 Primary Outcomes

| Variable | Definition | ACS Variable |
|----------|------------|--------------|
| **Employment** | Employed indicator | ESR = 1 or 2 |
| **Hours worked** | Usual hours per week | WKHP |
| **Wages** | Annual wage/salary income | WAGP |

### 5.2 Secondary Outcomes

| Variable | Definition | Notes |
|----------|------------|-------|
| **Full-time employment** | WKHP ≥ 35 | Full-time indicator |
| **Part-time employment** | WKHP < 35 | Part-time indicator |
| **Hours distribution** | Std dev of hours | Proxy for schedule stability |

---

## 6. Hypotheses and Expected Effect Sizes

### 6.1 Primary Hypotheses

**H1 (Employment):** The Fair Workweek law reduced employment in affected industries in NYC relative to control conditions.
- Direction: Negative (expected)
- Magnitude: 1-5 percentage point reduction based on prior scheduling law studies

**H2 (Hours):** The law reduced average weekly hours among employed workers.
- Direction: Negative
- Magnitude: 0.5-2 hours reduction

**H3 (Wages):** The law had no effect or small positive effect on wages (survivors may work more stable, higher-quality jobs).
- Direction: Null or positive
- Magnitude: 0-3% change

### 6.2 Heterogeneity Hypotheses

**H4:** Effects are larger in fast food than retail (stricter requirements)
**H5:** Effects are larger for young workers (more prevalent in these industries)
**H6:** Effects are larger for workers without college degrees

---

## 7. Statistical Analysis

### 7.1 Main Specification

All regressions weighted by PWGTP (person weight).

**Binary outcomes (employment):** Linear probability model
**Continuous outcomes (hours, wages):** OLS with log transformation for wages

### 7.2 Standard Errors

Clustered at the PUMA level to account for within-geographic-area correlation.

### 7.3 Robustness Checks

1. **Event study:** Replace Post × Treatment with year × Treatment dummies to test parallel trends and examine dynamics
2. **Alternative control groups:** 
   - Use only within-NY comparison
   - Use synthetic control for NYC
3. **Placebo tests:**
   - Pseudo-treatment dates (2014, 2015)
   - Pseudo-treatment industries (manufacturing, professional services)
4. **Sensitivity to sample restrictions:**
   - Restrict to chain restaurants (employer size proxy)
   - Vary age restrictions

### 7.4 Multiple Hypothesis Testing

Apply Benjamini-Hochberg correction for multiple outcomes (employment, hours, wages).

---

## 8. Limitations

### 8.1 Identification Challenges

1. **Treatment misclassification:** Cannot identify specific fast food chains vs. independent restaurants in ACS
2. **Concurrent policies:** NYC minimum wage increases occurred during this period
3. **Selection:** Workers may sort across geographies or industries in response to law

### 8.2 Data Limitations

1. **PUMA boundaries:** May not perfectly map to NYC boundaries in outer boroughs
2. **Industry codes:** INDP groups "restaurants" broadly; cannot isolate fast food chains
3. **Cross-sectional data:** Cannot observe individual-level responses over time

### 8.3 External Validity

Results specific to NYC's labor market (high cost of living, diverse economy, strong labor market) may not generalize to other cities considering similar laws.

---

## 9. Timeline

1. **Data acquisition:** Fetch ACS PUMS 2015-2019 for NY, IL, CA, PA
2. **Data processing:** Clean, merge, construct variables
3. **Descriptive statistics:** Sample characteristics, pre-trends
4. **Main analysis:** DDD estimation
5. **Robustness:** Event studies, placebo tests
6. **Draft writing:** Results, discussion, conclusions

---

## 10. Declaration

This pre-analysis plan was written before examining the outcome data. The analysis will follow this plan, and any deviations will be documented and justified.

**Locked:** [To be signed by preanalysis.py lock command]
