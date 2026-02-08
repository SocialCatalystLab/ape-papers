# Initial Research Plan

## Title
**The Incorporation Premium: Causal Effects of Business Structure on Self-Employment Earnings**

## Research Question
Does incorporating a self-employment business (vs. operating unincorporated) causally increase earnings, or does the observed earnings gap reflect selection into incorporation by higher-ability entrepreneurs?

## Background and Motivation
Self-employed workers can organize their businesses as either incorporated or unincorporated entities. In the 2022 ACS, incorporated self-employed workers earn substantially more ($102k mean income) than unincorporated ($59k). This 73% earnings gap could reflect:

1. **Causal effect:** Incorporation provides legal liability protection, tax advantages (S-corp salary/distribution optimization), and signaling benefits that increase net earnings
2. **Selection:** Higher-ability, growth-oriented entrepreneurs select into incorporation while lifestyle businesses remain unincorporated

Understanding which mechanism dominates has important policy implications for:
- Tax treatment of pass-through entities
- Small business advisory services
- Entrepreneurship policy and LLC/S-Corp promotion

## Identification Strategy

### Method: Doubly Robust Estimation (AIPW with Cross-Fitting)

Since no quasi-experimental variation exists (incorporation is a choice), we use doubly robust methods that combine:
- Propensity score weighting (model who incorporates)
- Outcome regression (model earnings conditional on covariates)

The key assumption is **selection on observables**: conditional on observed characteristics, incorporation choice is independent of potential earnings.

### Why This Might Work
Unlike general labor market settings, we compare ONLY self-employed workers — a more homogeneous population. The covariates we control for capture many determinants of incorporation:
- **Occupation:** Technical vs. manual trades differ in incorporation norms
- **Industry:** Some industries (consulting, medical) favor incorporation
- **Education:** Higher education → better understanding of incorporation benefits
- **Age:** Life-cycle stage affects business formality
- **Demographics:** Historical access to legal/financial advice varies

### What We Cannot Observe
We acknowledge unobserved confounders:
- Business scale and revenue (ACS doesn't capture this)
- Growth intentions and entrepreneurial ability
- Risk tolerance and financial sophistication
- Access to capital and legal advice

The sensitivity analysis will quantify how large these confounders would need to be to explain away any causal effect.

## Data

**Source:** American Community Survey PUMS 2022 via Census API

**Sample:**
- Universe: Self-employed workers (COW = 6 or 7)
- Age: 25-65
- Positive income

**Treatment:** COW = 7 (incorporated self-employment) vs COW = 6 (unincorporated)

**Outcome:** Total personal income (PINCP)

**Covariates:**
- OCCP: Detailed occupation (500+ codes → aggregate to 2-digit)
- INDP: Industry (270+ codes → aggregate to 2-digit)
- SCHL: Educational attainment
- AGEP: Age
- SEX: Sex
- RAC1P: Race
- MAR: Marital status
- ST: State
- WKHP: Usual hours worked per week

## Estimation

### Primary Specification
AIPW estimator using `AIPW` R package with SuperLearner ensemble:
- Propensity model: Random Forest, XGBoost, Logistic Regression
- Outcome model: Random Forest, XGBoost, GLM
- Cross-fitting: K=10 folds

### Estimand
Average Treatment Effect on the Treated (ATT): The effect of incorporation on earnings for those who chose to incorporate.

## Robustness and Sensitivity

### Required Analyses
1. **E-values:** Report minimum confounding strength needed to explain away effect
2. **Calibrated sensitivity (Cinelli-Hazlett):** Benchmark to observed confounders (e.g., "A confounder as strong as education would change estimate by X%")
3. **Rosenbaum bounds:** Sensitivity to hidden bias magnitude
4. **Propensity score overlap:** Document common support
5. **Covariate balance:** Standardized mean differences after weighting
6. **Trimming:** Results with extreme propensity scores dropped

### Negative Control Analysis
Test for effects on outcomes that SHOULD NOT be affected by incorporation (if available) as a placebo check.

## Heterogeneity Analyses
1. By industry (professional services vs. trades)
2. By occupation (knowledge work vs. manual)
3. By education level
4. By age (early career vs. established)
5. By state (tax/legal environment varies)

## Expected Findings
Based on prior literature, we expect:
- Substantial raw earnings gap ($40k+)
- Meaningful reduction after covariate adjustment (perhaps 30-50% reduction)
- Remaining "incorporation premium" of $15-25k
- High E-values suggesting moderate confounding sensitivity
- Industry and occupation heterogeneity in the premium

## Paper Structure
1. Introduction: Policy question and contribution
2. Background: Incorporation choice and potential mechanisms
3. Data and Sample
4. Empirical Strategy: DR methods and identification
5. Results: Main effects and robustness
6. Sensitivity Analysis: E-values, calibrated bounds
7. Heterogeneity
8. Discussion: Policy implications and limitations
9. Conclusion

## Timeline
1. Data download and cleaning
2. Descriptive analysis and balance tables
3. Main DR estimation
4. Sensitivity analysis
5. Heterogeneity analysis
6. Paper writing
7. Figures and tables
8. Review and revision

## Key Methodological References
- Chernozhukov et al. (2018) — Double/Debiased ML
- Cinelli & Hazlett (2020) — Calibrated sensitivity
- VanderWeele & Ding (2017) — E-values
- Robins, Rotnitzky & Zhao (1994) — DR foundations
