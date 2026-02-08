# Pre-Analysis Plan: Kansas 3.2% Beer Law Repeal and Retail Labor Markets

**Paper ID:** paper_26
**Date:** January 17, 2026
**Status:** DRAFT (to be locked before analysis)

---

## 1. Research Question

Does the legalization of full-strength beer sales in Kansas grocery stores (April 1, 2019) cause a decline in liquor store employment and self-employment, and does this represent a net labor market reallocation to grocery retail?

## 2. Background

### Policy Context
From 1937 to 2019, Kansas restricted grocery and convenience stores to selling only "cereal malt beverages" (beer with ≤3.2% alcohol by weight, or ~4% ABV). Full-strength beer, wine, and spirits could only be sold in licensed liquor stores. On April 1, 2019, Kansas House Bill 2502 took effect, allowing grocery stores, convenience stores, and gas stations to sell full-strength beer (up to 6% ABW).

This created a sharp, exogenous shock to the competitive landscape:
- **Before:** Liquor stores had a protected quasi-monopoly on beer sales
- **After:** Liquor stores competed directly with Walmart, Kroger, and convenience stores

### Theoretical Predictions
1. **Substitution Effect:** Consumers shift beer purchases from liquor stores to grocery stores
2. **Liquor Store Exit:** Small, independently-owned liquor stores lose viability and close
3. **Employment Reallocation:** Workers move from liquor retail to grocery retail (or exit retail)
4. **Self-Employment Decline:** Owner-operators of small liquor stores shut down, reducing self-employment

### Control Group Rationale
Neighboring states (Nebraska, Missouri, Oklahoma, Colorado) did not experience similar beer law changes in 2019 and serve as controls. These states share regional economic trends but have varying liquor regulations.

## 3. Data

### Source
American Community Survey (ACS) Public Use Microdata Sample (PUMS), 1-year files for 2015-2022.

### Sample
- **Geographic scope:** Kansas (treatment), Nebraska, Missouri, Oklahoma, Colorado (control)
- **Population:** Civilian labor force participants aged 18-64
- **Years:** 2015-2018 (pre-treatment), 2019-2022 (post-treatment)

### Key Variables

**Outcomes:**
1. `employed_bev_retail` (binary): Employed in NAICS 4453 (Beer, Wine, and Liquor Stores)
2. `employed_grocery` (binary): Employed in NAICS 4451 (Grocery Stores)
3. `employed_retail` (binary): Employed in NAICS 44-45 (Retail Trade)
4. `self_employed` (binary): Class of worker is self-employed (incorporated or unincorporated)
5. `self_employed_retail` (binary): Self-employed AND in retail trade
6. `employed` (binary): Currently employed

**Treatment:**
- `treat`: 1 if Kansas, 0 if control state
- `post`: 1 if year ≥ 2019, 0 if year ≤ 2018
- `treat_post`: Interaction term (DiD estimand)

**Controls:**
- Age, age squared
- Female indicator
- Race/ethnicity (White, Black, Hispanic, Asian, Other)
- Education (less than HS, HS, some college, BA+)
- Married indicator
- Presence of children indicator

### Sample Size Expectations
- Kansas has ~3 million population; expect ~15,000-20,000 observations per ACS year
- Control states have ~15 million combined; expect ~75,000-100,000 observations per year
- Beverage retail workers: likely 500-2,000 per year across all states

## 4. Empirical Strategy

### Main Specification
$$Y_{ist} = \alpha + \beta_1 \cdot \text{Treat}_s + \beta_2 \cdot \text{Post}_t + \beta_3 \cdot (\text{Treat}_s \times \text{Post}_t) + X_{ist}'\gamma + \epsilon_{ist}$$

Where:
- $Y_{ist}$: Outcome for individual $i$ in state $s$ in year $t$
- $\text{Treat}_s$: Kansas indicator
- $\text{Post}_t$: Indicator for 2019 or later
- $X_{ist}$: Individual-level controls
- $\beta_3$: Difference-in-differences estimand

### Robustness Checks
1. **Event study:** Replace $\text{Post}$ with year fixed effects, estimate treatment × year interactions
2. **Alternative controls:** Exclude/include different control states
3. **Placebo test:** Use 2017 as fake treatment year with 2015-2016 as pre-period
4. **Heterogeneity:** By age, education, gender, urban/rural status

### Inference
- Cluster standard errors at the state level (few clusters → use wild cluster bootstrap or state-year clustering)
- Report both OLS SEs and bootstrap SEs given small number of treatment clusters (1 treatment state)

## 5. Hypotheses and Expected Signs

| Outcome | Hypothesis | Expected Sign of $\beta_3$ |
|---------|------------|---------------------------|
| Beverage retail employment | Deregulation harms liquor stores | **Negative** |
| Grocery employment | Increased beer sales require more workers | **Positive or null** |
| Overall retail employment | Net effect unclear | **Ambiguous** |
| Self-employment (retail) | Small liquor store owners exit | **Negative** |
| Self-employment (all) | Spillover to related businesses | **Negative or null** |

## 6. Power Considerations

Given the small treatment group (Kansas) and relatively rare outcomes (beverage retail employment), we may be underpowered to detect small effects. We pre-commit to:
1. Reporting null results honestly if confidence intervals include zero
2. Interpreting imprecise estimates cautiously
3. Focusing narrative on point estimates and their economic magnitude, not just statistical significance

## 7. Figures and Tables

### Tables
1. **Table 1:** Summary statistics by treatment/control and pre/post period
2. **Table 2:** Main DiD results for all outcomes
3. **Table 3:** Event study coefficients
4. **Table 4:** Robustness checks (alternative specifications)

### Figures
1. **Figure 1:** Event study plot for beverage retail employment
2. **Figure 2:** Event study plot for self-employment in retail
3. **Figure 3:** Pre-trends in outcome variables (visual parallel trends check)
4. **Figure 4:** Map of treatment and control states

## 8. What We Will Report

We commit to reporting:
- All pre-specified outcomes, including null results
- Point estimates, standard errors, and confidence intervals
- Sample sizes for each regression
- Pre-trend tests and event study plots
- Any deviations from this pre-analysis plan with justification

## 9. Deviations from Plan

Any changes to this plan after data analysis begins will be documented in a separate section of the final paper, clearly labeled as "Post-hoc analyses" or "Exploratory results."

---

**Lock this document before running any regressions.**
