# Pre-Analysis Plan: Montana HELP-Link Workforce Program and Labor Force Participation

**Paper ID:** paper_29
**Date:** January 17, 2026
**Status:** LOCKED (do not modify after data analysis begins)

---

## 1. Research Question

Did Montana's combined Medicaid expansion + HELP-Link workforce program (effective 2016) produce larger employment gains among low-income adults than Medicaid expansion alone in comparable states?

## 2. Hypotheses

### Primary Hypothesis (H1)
Montana experienced a larger increase in employment rates among the Medicaid-eligible population (income <138% FPL) after 2016, relative to other Mountain West Medicaid expansion states (Colorado, Nevada, New Mexico) that expanded earlier (2014) without integrated workforce programs.

**Expected effect size:** 3-6 percentage point differential employment gain.

### Secondary Hypotheses

**H2:** The employment effect is larger for prime-age adults (25-54) than for near-elderly (55-64) or young adults (19-24).

**H3:** The employment effect is concentrated among the Medicaid-eligible population (income <138% FPL) and does not appear for the near-eligible comparison group (138-200% FPL), supporting a causal interpretation (triple-difference).

**H4:** Hours worked per week increased among the employed, consistent with intensive-margin labor supply response.

**H5:** Effects emerge gradually over 2016-2019 as HELP-Link enrollment expands (event-study dynamics).

## 3. Study Design

### 3.1 Primary Specification: Triple Difference-in-Differences

We estimate a triple-difference (DDD) model comparing:
- **First difference:** Before vs. after HELP-Link (2016)
- **Second difference:** Montana vs. control states (CO, NV, NM)
- **Third difference:** Medicaid-eligible (<138% FPL) vs. near-eligible (138-200% FPL)

The triple-difference isolates the Montana-specific, Medicaid-eligible-specific, post-HELP-Link effect, controlling for:
- General economic trends affecting all low-income workers in all states
- Montana-specific trends affecting all income groups
- National trends specific to the Medicaid-eligible population

### 3.2 Regression Specification

$$Y_{ist} = \alpha + \beta_1 (MT_s \times Post_t \times Elig_i) + \beta_2 (MT_s \times Post_t) + \beta_3 (MT_s \times Elig_i) + \beta_4 (Post_t \times Elig_i) + \gamma X_{ist} + \delta_s + \theta_t + \epsilon_{ist}$$

Where:
- $Y_{ist}$ = Employment indicator (ESR=1,2) for individual $i$ in state $s$ in year $t$
- $MT_s$ = Indicator for Montana
- $Post_t$ = Indicator for years 2016 and later
- $Elig_i$ = Indicator for Medicaid-eligible (income <138% FPL)
- $X_{ist}$ = Individual controls (age, sex, race, education, disability status)
- $\delta_s$ = State fixed effects
- $\theta_t$ = Year fixed effects

**Primary coefficient of interest:** $\beta_1$ (triple-interaction)

### 3.3 Event-Study Specification

To examine dynamics and pre-trends:

$$Y_{ist} = \alpha + \sum_{k \neq 2015} \beta_k (MT_s \times Year_k \times Elig_i) + \text{lower-order interactions} + \gamma X_{ist} + \delta_s + \theta_t + \epsilon_{ist}$$

This estimates year-by-year differential effects for Montana's Medicaid-eligible population, with 2015 as the reference year (last pre-HELP-Link year).

**Pre-trend test:** $\beta_{2013} = \beta_{2014} = 0$

## 4. Data

### 4.1 Data Source
American Community Survey (ACS) Public Use Microdata Sample (PUMS), 1-year samples, 2013-2019.

### 4.2 Sample Definition

**Geographic scope:**
- Treatment: Montana (FIPS 30)
- Control: Colorado (FIPS 08), Nevada (FIPS 32), New Mexico (FIPS 35)

**Population:**
- Adults ages 19-64
- Non-institutionalized (GQ not in institutional group quarters)
- Not enrolled in school full-time (to avoid confounding with education decisions)

**Income stratification:**
- Medicaid-eligible: POVPIP < 138 (income below 138% federal poverty level)
- Near-eligible: 138 ≤ POVPIP < 200

### 4.3 Variables

**Outcomes:**
- Employment (ESR = 1 or 2, civilian employed)
- Hours worked per week (WKHP, conditional on employment)
- Weeks worked last year (WKW, annual employment intensity)
- Wage income (WAGP, conditional on employment)

**Treatment indicators:**
- State (ST): Montana vs. controls
- Year (YEAR): 2013-2019
- Income eligibility (POVPIP): <138 vs. 138-200

**Controls:**
- Age (AGEP): continuous + squared
- Sex (SEX): male/female
- Race (RAC1P): White, Black, Hispanic, Asian, Other
- Education (SCHL): less than HS, HS, some college, BA+
- Disability (DIS): any disability indicator
- Marital status (MAR): married, never married, divorced/separated/widowed

**Weights:** PWGTP (person weight)

### 4.4 Sample Size Estimates

Per state-year for Medicaid-eligible population:
- Montana: ~3,000-4,000
- Colorado: ~15,000-20,000
- Nevada: ~8,000-12,000
- New Mexico: ~10,000-15,000

Total sample (2013-2019, all states, both income groups): ~400,000-500,000 observations

## 5. Analysis Plan

### 5.1 Descriptive Statistics
1. Sample characteristics by state, year, and eligibility group
2. Pre-treatment employment trends by state (2013-2015)
3. Raw difference-in-differences tabulations

### 5.2 Main Results
1. Triple-difference estimates (Equation 1)
2. Standard errors clustered at state level (4 clusters)
   - Also report wild cluster bootstrap p-values given small number of clusters
3. Event-study coefficients (Equation 2)

### 5.3 Robustness Checks
1. Alternative control states (add Wyoming, Idaho as non-expansion controls for placebo)
2. Excluding 2014 (partial treatment year for control states)
3. Varying income thresholds for eligibility (100% vs. 138% vs. 150% FPL)
4. Controlling for state-specific linear time trends
5. Synthetic control weights for comparison states

### 5.4 Heterogeneity Analysis
1. By age group (19-24, 25-54, 55-64)
2. By sex
3. By education (less than BA vs. BA+)
4. By disability status
5. By rural vs. urban (PUMA classification)

### 5.5 Mechanism Tests
1. Health insurance coverage (HICOV, HINS4) as outcome
2. Migration patterns (to rule out composition changes)

## 6. Inference

### 6.1 Standard Errors
- Primary: Heteroskedasticity-robust, clustered at state level
- Given only 4 clusters, also report wild cluster bootstrap (WCB) p-values using 1,000 replications

### 6.2 Multiple Hypothesis Correction
- Primary outcome (employment): no correction
- Secondary outcomes: Benjamini-Hochberg correction across 3 secondary outcomes (hours, weeks, wages)
- Heterogeneity: report as exploratory, no formal correction

### 6.3 Statistical Power
With ~500,000 total observations and state-level clustering, we have power to detect employment effects of approximately 2-3 percentage points at conventional significance levels.

## 7. Timeline

- **2016:** HELP-Link begins operations
- **2013-2015:** Pre-period
- **2016-2019:** Post-period
- **2020+:** Excluded (COVID-19 confounding)

## 8. Potential Threats to Identification

### 8.1 Parallel Trends Violation
- **Concern:** Montana may have differential trends unrelated to HELP-Link
- **Mitigation:** Event-study pre-trends; triple-difference with near-eligible comparison

### 8.2 Differential Medicaid Expansion Timing
- **Concern:** Control states expanded in 2014; Montana in 2016
- **Mitigation:** Triple-difference uses within-state variation in eligibility group; robustness to excluding 2014

### 8.3 Composition Changes
- **Concern:** Migration patterns may change sample composition
- **Mitigation:** Test migration as outcome; control for demographics

### 8.4 Other Montana-Specific Shocks
- **Concern:** Oil/gas or agriculture shocks specific to Montana
- **Mitigation:** Triple-difference isolates Medicaid-eligible-specific effect; add state-specific trends

### 8.5 Small Number of Clusters
- **Concern:** Standard cluster-robust SEs may underreject with 4 clusters
- **Mitigation:** Wild cluster bootstrap; synthetic control approach

## 9. Stopping Rules

We commit to the following decision rules:

1. **If pre-trends are significant (any $|\beta_{2013}|$ or $|\beta_{2014}|$ > 0.03 or p<0.10):** Report but flag identification concerns prominently.

2. **If triple-difference is null ($|\beta_1|$ < 0.02, p > 0.20):** Report null finding; do not search for alternative specifications.

3. **If effects appear but only in heterogeneous subgroups:** Report as exploratory; do not claim as main result.

## 10. Data Availability Statement

All data are publicly available from the U.S. Census Bureau PUMS files. Analysis code will be archived with the paper.

---

**LOCK TIMESTAMP:** This pre-analysis plan is locked as of the date above. Any deviations must be documented and justified in the final paper.
