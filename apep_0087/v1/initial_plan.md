# Initial Research Plan

## Research Question

What is the effect of occupational automation exposure on labor force exit among older workers (ages 55-70)?

## Identification Strategy

**Method:** Doubly Robust Estimation (AIPW)

**Key Assumption:** Selection on observables (unconfoundedness). Conditional on demographic, human capital, health, and economic characteristics, automation exposure is independent of potential labor force outcomes.

**Treatment:** Binary indicator for high-automation occupation (top tercile of Frey-Osborne/Autor-Dorn automation scores)

**Outcome:** Not in labor force (binary)

**Population:** Workers aged 55-70 in 10 largest US states (ACS PUMS 2022-2023)

## Expected Effects and Mechanisms

**Hypothesis:** High automation exposure increases probability of labor force exit.

**Mechanisms:**
1. Displacement: Job loss from technology substitution
2. Early retirement incentives: Firms restructure using automation
3. Job quality decline: Reduced satisfaction leading to voluntary exit
4. Anticipated obsolescence: Workers exit before skills become obsolete

**Expected heterogeneity:**
- Stronger effects for less-educated workers (fewer alternative occupations)
- Stronger effects near retirement thresholds (ages 61-65)

## Primary Specification

$$\hat{\tau}_{AIPW} = \frac{1}{n}\sum_{i=1}^n \left[\hat{\phi}_1(O_i) - \hat{\phi}_0(O_i)\right]$$

**Propensity score model:** Logistic regression on age, age², sex, education, race, nativity, marital status, disability, log income, homeownership, Medicare, employer insurance, industry.

**Outcome model:** Linear probability model within treatment groups.

**Inference:** Nonparametric bootstrap (500 replications)

## Planned Robustness Checks

1. **Alternative treatments:** Continuous exposure, tercile comparisons
2. **Fixed effects:** Industry FE, State FE
3. **Sample restrictions:** Exclude disability, by sex
4. **Negative control outcomes:** Homeownership, marital status, children
5. **Sensitivity analysis:** Calibrated sensitivity (Cinelli-Hazlett), E-values

## Data Requirements

- ACS PUMS 2022-2023 (10 largest states)
- Frey-Osborne automation probabilities (mapped to SOC codes)
- Autor-Dorn routine task intensity indices

## Timeline

1. Data acquisition and cleaning
2. Automation score construction
3. Propensity score estimation and diagnostics
4. Main analysis (OLS, IPW, AIPW)
5. Heterogeneity analysis
6. Robustness checks
7. Paper writing and figure generation
