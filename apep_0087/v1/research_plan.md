# Initial Research Plan

**Paper:** 110
**Title:** Does Automation Push Older Workers Out? Heterogeneous Effects of Task Routinization on Labor Force Exit
**Date:** 2026-01-29

---

## Research Question

Does occupational exposure to automation risk causally affect labor force exit among older workers (ages 55-70), and do these effects vary by skill level?

**Hypothesis:** Automation exposure has heterogeneous effects on labor force exit:
- **Low-skilled workers** in high-automation occupations face displacement pressure → earlier exit (consistent with task-based technological change theory)
- **High-skilled workers** in high-automation occupations may experience capital-skill complementarity → delayed exit (counter-intuitive)

---

## Identification Strategy

**Method:** Doubly Robust (DR) / Augmented Inverse Probability Weighting (AIPW) with machine learning for nuisance functions

**Treatment:** Occupational automation exposure (continuous), measured via:
1. **Routine Task Intensity (RTI):** Autor-Dorn classification based on O*NET work activities
2. **AI Exposure Index:** Felten et al. (2021) AIOE scores

**Outcome:** Labor force non-participation (ESR ≠ 1,2), among workers aged 55-70

**Selection-on-Observables Argument:**
- Occupation choice at age 55+ is largely determined by earlier career decisions and accumulated human capital
- Short-run occupational switching costs are high for older workers
- We observe key determinants of occupation choice: education (detailed), industry, location, demographics, income, health insurance status
- Limited scope for reverse causality: automation exposure is assigned by occupation, not changed in response to individual retirement plans

**Key Identifying Assumption:** Conditional on observed covariates (education, industry, state, demographics, income), treatment assignment (automation exposure via occupation) is independent of potential outcomes.

---

## Expected Effects and Mechanisms

**Primary Effect:**
- Average: Positive effect of automation exposure on labor force exit (displacement)
- Magnitude: ~2-5 percentage point increase in exit probability for high-exposure (top tercile) vs. low-exposure occupations

**Heterogeneity (Key Contribution):**
- By education: College+ workers may show null or negative effect (complementarity)
- By industry: Manufacturing vs. services may show different patterns
- By age: Effect may strengthen with age (less retraining capacity)

**Mechanisms:**
1. **Displacement:** Automation reduces labor demand for routine tasks → layoffs/involuntary exit
2. **Wage decline:** Automation suppresses wages → voluntary exit (retirement becomes relatively more attractive)
3. **Skill obsolescence:** Workers perceive skills as devalued → discouraged worker exit
4. **Complementarity (high-skilled):** Automation increases productivity → higher wages → delayed exit

---

## Primary Specification

**Estimand:** Average Treatment Effect (ATE) of automation exposure (continuous) on labor force exit probability

**Model:**

```
Pr(Not in Labor Force) = f(Automation Exposure, X)
```

where X includes:
- Demographics: age, age², sex, race/ethnicity, immigrant status
- Human capital: education (detailed 12 categories), English proficiency
- Family: marital status, children present, spouse's labor force status
- Economic: personal income (prior year), household income, health insurance type
- Geographic: state, metro status, PUMA (for robustness)
- Industry: NAICS 3-digit

**Estimation:**
1. **Propensity Score Model:** Random forest / XGBoost to predict Pr(High Automation Exposure | X)
2. **Outcome Model:** Random forest / XGBoost to predict Pr(Exit | X, Treatment)
3. **AIPW Estimator:** Combines both models with cross-fitting (K=5 or K=10)
4. **Standard Errors:** Influence function-based (asymptotically normal)

---

## Planned Robustness Checks

1. **Alternative Automation Measures:**
   - Routine Task Intensity (RTI) terciles
   - AI Exposure Index (Felten)
   - Automation probability (Frey-Osborne)

2. **Sensitivity Analysis:**
   - E-values for unmeasured confounding
   - Calibrated bounds (Cinelli-Hazlett) benchmarked to education, health insurance

3. **Negative Control Outcomes:**
   - Homeownership status
   - Marital status
   - Number of children

4. **Industry/Region Controls:**
   - With and without industry fixed effects
   - With and without state × year controls
   - Control for state unemployment rate

5. **Heterogeneity:**
   - By education (college+, some college, HS or less)
   - By industry sector (manufacturing, services, public)
   - By age (55-60, 61-65, 66-70)
   - By sex

6. **Alternative Samples:**
   - Restrict to employed in prior year (conditioning on employment)
   - Exclude disability recipients
   - Men vs. women separately

---

## Data Sources

| Data | Source | Years | Key Variables |
|------|--------|-------|---------------|
| Individual microdata | ACS PUMS (Census API) | 2018-2023 | ESR, AGEP, SCHL, OCCP, INDP, ST, PUMA, PINCP, HINS* |
| Automation exposure | O*NET via API | Latest | Work activities, abilities, skills by SOC |
| Occupation crosswalk | Census-SOC | Current | ACS OCCP to O*NET SOC |

---

## Power Assessment

- **Sample:** ~18M observations (3M/year × 6 years) for ages 55-70
- **Baseline exit rate:** ~25% (varies by age)
- **Expected effect:** 2-5 percentage points
- **Power:** Extremely high given sample size; can detect small effects and heterogeneity

---

## Timeline

1. Data acquisition (R scripts for ACS API and O*NET)
2. Data cleaning and merge
3. Descriptive statistics and balance checks
4. Main DR/AIPW estimation
5. Sensitivity analysis
6. Heterogeneity analysis
7. Paper writing

---

## Potential Limitations

1. **Selection on unobservables:** Cannot fully rule out that unobserved preferences (health shocks, leisure preferences) correlate with both occupation and exit
2. **Measurement:** Labor force exit includes multiple pathways (retirement, disability, discouraged workers); cannot distinguish without linked SSA data
3. **Stock vs. flow:** Cross-sectional ACS measures stock of workers, not transitions; mitigate by comparing across years
4. **Occupation assignment:** Assigned based on current/most recent occupation; those who already exited have no occupation (survivorship)

---

## Pre-Registration

This plan is locked before data fetching. Any deviations will be documented and justified.

**Hash:** [To be computed after commit]
