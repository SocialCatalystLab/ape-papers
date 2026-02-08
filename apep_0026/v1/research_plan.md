# Initial Research Plan: Paper 31

**Created:** 2026-01-18
**Status:** LOCKED (do not modify after creation)

---

## Research Question

Does legal recreational marijuana access at age 21 shift workers from traditional employment into self-employment, where they can consume legally without risking employer-imposed consequences for drug testing?

## Title (Working)

"Legal Weed, Self-Made: Does Marijuana Legalization Push Workers Into Self-Employment? A Difference-in-Discontinuities Analysis"

---

## Policy Background

Colorado Amendment 64 (passed November 2012, effective January 2014) legalized recreational marijuana for adults aged 21+. At exactly age 21, Colorado residents gain legal access to purchase and consume recreational marijuana.

**Critical Policy Twist:** Federal law still classifies marijuana as Schedule I. The Colorado Supreme Court ruled in *Coats v. Dish Network* (2015) that employers retain the right to terminate employees for off-duty marijuana use, even when legal under state law. This creates a unique labor market mechanism:

- Workers who wish to legally consume marijuana face a trade-off
- Traditional W-2 employment: Risk termination via drug testing
- Self-employment: No employer can fire you for legal off-duty conduct

**Hypothesis:** At age 21, we expect an INCREASE in self-employment in Colorado as workers avoid drug-tested employers—but NO such discontinuity in non-legal states where the trade-off doesn't exist.

---

## Identification Strategy

### Design: Difference-in-Discontinuities (Diff-in-Disc)

A simple RDD at age 21 in Colorado is confounded by alcohol access (also legal at 21). We address this by comparing the age-21 discontinuity across states:

**Treatment Group:** Colorado (recreational marijuana legal at 21)
**Control Group:** States where recreational marijuana was NOT legal during the sample period

**Difference-in-Discontinuities Estimator:**
```
τ = [E[Y|Age=21+, CO] - E[Y|Age=21-, CO]] - [E[Y|Age=21+, Control] - E[Y|Age=21-, Control]]
```

Both Colorado and control states have the alcohol-at-21 discontinuity. Only Colorado has the marijuana-at-21 discontinuity. The difference isolates the marijuana effect.

### Running Variable

Age in years (ACS provides single-year age, not months). We use ages 19-23 (bandwidth of 2 years on each side of cutoff).

### Sample

- **Data:** American Community Survey (ACS) PUMS, 2015-2023
- **Treatment states:** Colorado (post-2014)
- **Control states:** States where recreational marijuana was illegal throughout sample period (e.g., TX, FL, GA, NC, OH, PA)
- **Ages:** 19-23 (centered on 21)
- **Exclusions:** Still in high school, institutionalized

### Outcomes

1. **Primary:** Self-employment rate (incorporated + unincorporated)
2. **Secondary:**
   - Unincorporated self-employment only (better gig/freelance proxy)
   - Industry composition (shift away from drug-testing industries)
3. **Heterogeneity:**
   - By industry (construction, transportation, healthcare vs. tech, creative)
   - By education (less educated more affected?)
   - By gender

---

## Falsification Tests

1. **Pre-legalization placebo:** Run same diff-in-disc on 2010-2013 data. Should find NO effect.
2. **Age placebo:** Test discontinuities at ages 20, 22, 23. Should find NO effect.
3. **Outcome placebo:** Test on outcomes unrelated to employment-marijuana trade-off (e.g., marital status, number of children).
4. **Density test:** McCrary test for manipulation of running variable (should be smooth).

---

## Expected Results

- **Primary:** Positive discontinuity in self-employment at age 21 in Colorado, no discontinuity in control states
- **Magnitude:** 1-3 percentage point increase in self-employment rate
- **Heterogeneity:** Larger effects for workers in drug-testing industries, less educated workers

---

## Data Requirements

From ACS PUMS:
- `AGEP`: Age (single year)
- `ST`: State
- `COW`: Class of worker (self-employed incorporated, unincorporated, private, government)
- `ESR`: Employment status
- `INDP`: Industry
- `SCHL`: Educational attainment
- `SEX`: Gender
- `WKHP`: Hours worked per week
- `WAGP`: Wage/salary income
- `SEMP`: Self-employment income
- `PWGTP`: Person weight

---

## Timeline

1. Write and commit initial_plan.md (this document) - **NOW**
2. Download ACS PUMS data (2015-2023) for CO + control states
3. Clean and prepare analysis dataset
4. Run diff-in-disc estimation
5. Generate figures (discontinuity plots, event study)
6. Write full paper (25+ pages)
7. Internal review (3-5 rounds)
8. External validation (GPT + Gemini, 3-5 rounds)
9. Publish

---

## Key References

- Cerdá, M. et al. (2020). Association of state recreational marijuana laws with adolescent marijuana use. JAMA Pediatrics.
- Coats v. Dish Network, 350 P.3d 849 (Colo. 2015).
- Card, D. & Lemieux, T. (2001). Regression discontinuity designs in economics.
- Grembi, V., Nannicini, T., & Troiano, U. (2016). Do fiscal rules matter? AEJ: Applied Economics. [Diff-in-disc methodology]
