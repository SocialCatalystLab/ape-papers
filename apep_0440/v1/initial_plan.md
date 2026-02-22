# Initial Research Plan: Social Insurance Thresholds and the Quality of Late-Career Employment

## Research Question

Do social insurance eligibility thresholds reduce underemployment among older workers? Specifically, does Medicare eligibility at age 65 (releasing insurance lock) and Social Security eligibility at age 62 (providing income support) improve job match quality for workers who remain employed?

## Identification Strategy

**Dual regression discontinuity design** exploiting two sharp age thresholds:

1. **Age 62:** Social Security early eligibility. Workers become entitled to reduced retirement benefits (~70-75% of PIA). This provides an income floor that may enable transitions from involuntary to voluntary part-time work, or from mismatched full-time to better-matched employment.

2. **Age 65:** Medicare eligibility. Universal health insurance decouples health coverage from employer provision, releasing workers from "insurance lock" that may trap them in mismatched jobs.

**Running variable:** Age in integer years (AGEP from ACS PUMS).

**Framework:** Lee & Card (2008) methodology for discrete running variables. Each age value is treated as a mass point; standard errors clustered at the age level. This is appropriate because:
- Age is non-manipulable (people cannot change their birthday)
- McCrary density test is not needed (no sorting possible)
- Massive sample sizes (~150,000 per age-year) compensate for discrete running variable

**Functional form:** Local linear regression within bandwidths of 5 and 10 age-years on each side of the cutoff. Robustness to triangular vs. uniform kernel, multiple bandwidths.

**Key identification concern — Anticipation and Selection:**
- Workers who retire at 62 or 65 are selectively leaving the sample. The composition of the working population changes at these thresholds.
- This is CENTRAL to the design, not a threat. The paper studies a COMPOSITE outcome: the population-level underemployment rate among workers at each age. If Medicare releases insurance-locked workers from bad matches, the underemployment rate should DECREASE at 65 — either because locked workers transition to better-matched jobs, or because the most-mismatched workers exit entirely.
- Donut RDD (excluding the threshold age) as robustness check.
- Decomposition: conditional on continued employment, does job quality improve?

## Expected Effects and Mechanisms

**At age 62 (SS eligibility):**
- Involuntary part-time rate should DECREASE: SS income allows workers to be more selective
- Overqualification rate may DECREASE: income floor enables search for better match
- Alternative: rates INCREASE if SS draws workers into low-quality bridge employment
- Expected magnitude: Small (1-3 pp) — SS at 62 is reduced benefit

**At age 65 (Medicare eligibility):**
- Overqualification rate should DECREASE for workers with employer insurance (insurance lock released)
- Effect should be LARGER than age-62 effect if insurance is the binding constraint
- Effect should be CONCENTRATED among workers currently with employer-sponsored insurance
- Expected magnitude: Moderate (2-5 pp) — insurance lock is widely documented

**Heterogeneity:**
- By pre-threshold insurance source (employer vs. individual vs. uninsured)
- By education (college+ vs. less-than-college — mismatch more measurable for college graduates)
- By gender (women have higher involuntary PT rates)
- By race (disparities in insurance lock burden)

## Primary Specification

```
Y_i = α + β₁ · 1(Age_i ≥ c) + f(Age_i - c) + X_i'γ + ε_i
```

Where:
- Y_i = underemployment indicator (overqualified, involuntary PT, or composite index)
- c = cutoff (62 or 65)
- f(·) = local linear polynomial in centered age, different slopes on each side
- X_i = covariates (sex, race, education, state, year)
- Standard errors clustered at age level

## Planned Robustness Checks

1. **Bandwidth sensitivity:** h = {3, 5, 7, 10} age-years
2. **Polynomial order:** Linear vs. quadratic (Gelman & Imbens 2019 caution against higher orders)
3. **Kernel:** Triangular (default) vs. uniform
4. **Placebo cutoffs:** Test at ages 58, 60, 63, 67, 70 (no policy change expected)
5. **Donut RDD:** Exclude threshold age to address exact-age sorting
6. **Covariate balance:** Education, race, sex, state composition should be smooth through cutoff
7. **Year-by-year estimates:** Stability across survey years 2014-2023
8. **Subgroup analyses:** By insurance type, education, gender, race
9. **Alternative overqualification measures:** O*NET Job Zone vs. education-occupation crosswalk vs. earnings-based

## Data

- **Primary:** ACS PUMS 2014-2023 via tidycensus::get_pums()
  - Variables: AGEP, SCHL, OCCP, WKHP, ESR, HINS1-HINS7, PINCP, SEX, RAC1P, ST, PWGTP
  - Replicate weights: PWGTP1-PWGTP80 for proper variance estimation
  - Sample: Workers aged 52-75 (±10 years from each cutoff)
  - Expected N: ~1.5 million workers

- **Supplementary:** O*NET Web Services API
  - Job Zone classification for each SOC code (maps to OCCP)
  - Education requirements by occupation
  - Used to construct overqualification measure

## Underemployment Measures

1. **Involuntary part-time:** WKHP < 35 AND ESR indicates employed AND (ideally) wants full-time
   - ACS may lack explicit "wants full-time" — will use hours < 35 as proxy
   - Robustness: <30 hours, <20 hours

2. **Overqualification (O*NET-based):** Worker has bachelor's degree (SCHL ≥ 21) but works in occupation with O*NET Job Zone ≤ 3 (requires less than bachelor's)
   - Clean binary measure with theoretical grounding
   - Alternative: continuous mismatch = (worker education years) - (typical education for occupation)

3. **Earnings mismatch:** Worker's wage is in the bottom quartile of the earnings distribution for their education level
   - Captures underutilization even without formal overqualification

4. **Composite index:** Principal component or average of standardized measures 1-3
