# Pre-Analysis Plan: Lifeline Broadband Subsidy and Internet Adoption

**Study Title:** The Effects of Lifeline Broadband Eligibility on Internet Adoption: A Regression Discontinuity Analysis

**Authors:** APEP Research Team

**Date:** 2026-01-17

**Status:** PRE-REGISTERED (locked before data analysis)

---

## 1. Research Question

Does eligibility for the FCC Lifeline broadband subsidy (at the 135% Federal Poverty Line threshold) increase household broadband adoption?

### 1.1 Policy Background

The FCC Lifeline program, established in 1985 and expanded to include broadband in 2016, provides a $9.25/month subsidy for phone or internet service to households with income at or below 135% of the Federal Poverty Line (FPL). As of 2024, following the end of the Affordable Connectivity Program (ACP), Lifeline remains the primary federal broadband subsidy program.

Eligibility criteria:
- Household income ≤ 135% FPL, OR
- Participation in qualifying federal programs (SNAP, Medicaid, SSI, FPHA, Veterans Pension, Tribal programs)

### 1.2 Research Design

We employ a **regression discontinuity design (RDD)** exploiting the sharp income eligibility threshold at 135% FPL. We compare households just below 135% FPL (eligible for Lifeline) to households just above (ineligible based on income alone).

**Estimand:** The effect is an **intent-to-treat (ITT)** estimate measuring the impact of Lifeline *eligibility* on broadband adoption, not the effect of Lifeline *enrollment*. This is because:
1. Census ACS does not observe Lifeline enrollment
2. Not all eligible households enroll (take-up is incomplete)
3. Some households above 135% FPL may qualify via categorical eligibility

---

## 2. Data

### 2.1 Data Source

**Census American Community Survey (ACS) Public Use Microdata Sample (PUMS)**
- Years: 2018-2023 (post-Lifeline broadband expansion, pre/during ACP)
- Geographic coverage: National (all 50 states + DC)
- Unit of observation: Household

### 2.2 Key Variables

**Running Variable:**
- `POVPIP`: Household income as a percentage of the Federal Poverty Line (0-501+)
- Cutoff: 135

**Outcome Variables (Primary):**
- `HISPEED`: Broadband (high speed) Internet service such as cable, fiber optic, or DSL service (1=Yes, 2=No)
- `ACCESSINET`: Access to the Internet (1=Yes, with subscription; 2=Yes, without subscription; 3=No)

**Outcome Variables (Secondary):**
- `BROADBND`: Cellular data plan for a smartphone or other mobile device
- `LAPTOP`: Laptop or desktop computer ownership
- `SMARTPHONE`: Smartphone ownership

**Covariates (for robustness checks):**
- `AGEP`: Age of householder
- `SEX`: Sex of householder
- `RAC1P`: Race of householder
- `HISP`: Hispanic origin
- `SCHL`: Educational attainment
- `ENG`: English language proficiency
- `ST`: State
- `PUMA`: Public Use Microdata Area

### 2.3 Sample Restrictions

1. Households with `POVPIP` between 85 and 185 (baseline bandwidth: 50 percentage points on each side of cutoff)
2. Householder age 18+
3. Non-group quarters (household type)
4. Non-missing values on `HISPEED` and `POVPIP`

### 2.4 Expected Sample Size

Based on prior ACS PUMS, we expect approximately:
- 300,000-400,000 household observations per year
- ~50,000-70,000 households in the 85-185% FPL bandwidth per year
- Total sample: 300,000-420,000 households across 2018-2023

---

## 3. Empirical Strategy

### 3.1 Main Specification

We estimate the following local linear regression:

```
HISPEED_i = α + τ·D_i + β₁·(POVPIP_i - 135) + β₂·D_i·(POVPIP_i - 135) + ε_i
```

Where:
- `D_i = 1` if `POVPIP_i ≤ 135` (eligible), `0` otherwise
- `τ` is the ITT effect of Lifeline eligibility on broadband adoption
- Standard errors clustered at the state level

### 3.2 Bandwidth Selection

We will use three bandwidth selection methods:

1. **Imbens-Kalyanaraman (IK) optimal bandwidth** (baseline)
2. **Calonico-Cattaneo-Titiunik (CCT) robust bandwidth** (robustness)
3. **Fixed bandwidths**: 20, 30, 40, 50 percentage points (sensitivity)

### 3.3 Estimation Methods

1. **Local linear regression** (baseline)
2. **Local quadratic regression** (robustness)
3. **Bias-corrected robust confidence intervals** (Calonico, Cattaneo, Titiunik 2014)

### 3.4 Kernel Functions

- Triangular kernel (baseline)
- Uniform kernel (robustness)
- Epanechnikov kernel (robustness)

---

## 4. Validity Tests

### 4.1 Manipulation Test

We will test for bunching/manipulation at the 135% threshold using:
- McCrary (2008) density test
- Cattaneo, Jansson, Ma (2020) local polynomial density test

**Hypothesis:** No statistically significant discontinuity in the density of `POVPIP` at 135

**Decision rule:** If p-value < 0.05 for the density test, we will:
1. Report the finding transparently
2. Conduct donut-hole RDD excluding observations within ±5 pp of cutoff
3. Interpret results with appropriate caution

### 4.2 Covariate Balance Tests

We will test for discontinuities in predetermined covariates at the 135% threshold:
- Age (`AGEP`)
- Sex (`SEX`)
- Race (`RAC1P`)
- Educational attainment (`SCHL`)
- State distribution (`ST`)

**Hypothesis:** No statistically significant discontinuities in covariates at 135% FPL

### 4.3 Placebo Tests

We will estimate the RDD at false cutoffs:
- 100% FPL
- 120% FPL
- 150% FPL
- 170% FPL

**Hypothesis:** No significant effects at placebo cutoffs

---

## 5. Heterogeneity Analysis

We will estimate heterogeneous effects by:

1. **Urban/Rural status** (using PUMA urban/rural classification)
2. **Age group** (<35, 35-54, 55+)
3. **Educational attainment** (<HS, HS, Some college, BA+)
4. **Household composition** (single person, with children, elderly)
5. **State** (focusing on UT, NJ, ND as assigned states, plus national pooled)
6. **Year** (pre-ACP: 2018-2021 vs. during-ACP: 2022-2023)

---

## 6. Hypotheses

### 6.1 Primary Hypothesis

**H1:** Households just below 135% FPL have higher rates of broadband subscription than households just above 135% FPL.

- Direction: Positive effect (τ > 0)
- Expected magnitude: Small (1-3 percentage points), given incomplete take-up and the modest subsidy amount ($9.25/month)

### 6.2 Secondary Hypotheses

**H2:** Effects are larger in rural areas where broadband costs represent a larger share of household budgets.

**H3:** Effects are larger for elderly households who may be more price-sensitive.

**H4:** Effects are smaller during the ACP period (2022-2023) when the larger ACP subsidy ($30/month) at 200% FPL may crowd out Lifeline effects.

### 6.3 Null Result Interpretation

If we find no significant effect (τ ≈ 0), we will interpret this as:
1. Incomplete Lifeline take-up attenuating the ITT estimate
2. The $9.25/month subsidy being insufficient to change adoption decisions
3. Categorical eligibility pathways blurring the income-based threshold

---

## 7. Reporting Standards

### 7.1 Tables

1. **Table 1:** Summary statistics by income group (below vs. above 135% FPL)
2. **Table 2:** Main RDD results (broadband adoption)
3. **Table 3:** Bandwidth sensitivity analysis
4. **Table 4:** Covariate balance tests
5. **Table 5:** Heterogeneity analysis

### 7.2 Figures

1. **Figure 1:** Binned scatter plot of broadband adoption by income (% FPL)
2. **Figure 2:** RDD plot with local linear fit
3. **Figure 3:** McCrary density test
4. **Figure 4:** Bandwidth sensitivity plot
5. **Figure 5:** Heterogeneity by subgroup

### 7.3 Statistical Significance

- Primary threshold: p < 0.05 (two-tailed)
- Report exact p-values
- Report 95% confidence intervals
- Use robust standard errors clustered at the state level

---

## 8. Software and Replication

### 8.1 Software

- Python 3.11+ with:
  - `pandas` for data manipulation
  - `statsmodels` for regression
  - `rdrobust` (if available) or custom implementation for RDD
  - `matplotlib`/`seaborn` for visualization

### 8.2 Replication Package

All code and data will be made available in:
- `output/paper_24/data/` - processed data files
- `output/paper_24/code/` - analysis scripts
- `output/paper_24/figures/` - all figures

---

## 9. Deviations from Pre-Analysis Plan

Any deviations from this pre-analysis plan will be:
1. Clearly documented in the paper
2. Justified with methodological rationale
3. Labeled as exploratory (not confirmatory)

---

## 10. Timeline

1. Data acquisition: Day 1
2. Data cleaning and preparation: Day 1
3. Main analysis: Day 1
4. Robustness checks: Day 1
5. Paper writing: Day 1-2
6. Review and revision: Day 2+

---

*This pre-analysis plan was locked before any data analysis was conducted.*
