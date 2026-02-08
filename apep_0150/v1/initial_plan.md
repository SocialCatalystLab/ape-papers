# Initial Research Plan

## Paper 135: State Insulin Copay Caps and Working-Age Diabetes Mortality

### Research Question

Do state insulin copay cap laws reduce diabetes mortality among working-age adults (25-64)?

### Background and Motivation

Between 2019 and 2025, over 25 US states enacted laws capping out-of-pocket insulin costs for commercially insured patients, typically at $25-$100 per month for a 30-day supply. These laws were motivated by evidence that insulin rationing due to cost is widespread and dangerous: approximately 25% of insulin users report rationing to manage costs, with some experiencing life-threatening diabetic ketoacidosis (DKA) as a result.

The existing literature on insulin copay caps focuses primarily on proximate outcomes: medication adherence (claims-based), out-of-pocket spending, and self-reported cost barriers. A key unanswered question is whether these affordability interventions translate into reduced hard health outcomes — specifically, whether fewer people die from diabetes when insulin becomes more affordable.

### Identification Strategy

**Method:** Staggered Difference-in-Differences using the Callaway and Sant'Anna (2021) estimator.

**Treatment:** State-level insulin copay cap law effective dates. Treatment is coded as 1 from the year the law takes effect onward.

**Control group:** Never-treated and not-yet-treated states.

**Key identifying assumption:** In the absence of insulin copay cap laws, diabetes mortality trends in treated states would have evolved similarly to those in control states (parallel trends). Testable with 20+ years of pre-treatment data.

### Treatment Timing (Preliminary)

| Year Effective | States (approximate) |
|---------------|---------------------|
| 2020 | Colorado, Utah, Washington, Maine, West Virginia, New York, Virginia, Illinois, New Mexico, Delaware, Minnesota |
| 2021 | Connecticut, Texas, New Hampshire, Vermont |
| 2022 | DC (delayed from 2020) |
| 2023 | Additional states (Montana, Nebraska, others) |
| 2024-2025 | California, additional late adopters |
| Never treated | ~20 states |

### Outcome Variable

**Primary:** Age-adjusted diabetes mortality rate (per 100,000) for ages 25-64, ICD-10 codes E10-E14 as underlying cause of death, from CDC WONDER Multiple Cause of Death files.

**Why ages 25-64:** Insulin copay caps primarily affect commercially insured individuals. Medicare covers those 65+, and the federal $35 cap for Medicare (effective 2023) would contaminate the control group. Ages 25-64 isolates the commercially insured working-age population.

**Secondary outcomes:**
1. Type 1 diabetes mortality (E10) — insulin-dependent, most directly affected
2. Type 2 diabetes mortality (E11) — larger population, insulin used in advanced cases
3. All-cause mortality ages 25-64 — placebo/dilution test
4. Diabetes mortality ages 65+ — placebo test (should show no effect from state caps since Medicare applies)

### Data Sources

1. **CDC WONDER Multiple Cause of Death, 1999-2023** — State×year×age-group mortality counts and rates
2. **Census population estimates** — Denominators for rates (embedded in CDC WONDER)
3. **Policy database** — Hand-coded from NCSL, ADA, BeyondType1, and state legislative records

### Econometric Specification

**Primary model (CS-DiD):**
Using the `did` R package:
- Group variable: Year of copay cap law effective date
- Time variable: Calendar year
- Outcome: Log diabetes mortality rate (ages 25-64) or level
- Clustering: State level
- Estimand: ATT (average treatment effect on the treated)

**Event study:**
- Plot dynamic treatment effects from t-10 to t+4 (or maximum available post-period)
- Pre-treatment coefficients should be indistinguishable from zero

**Robustness checks:**
1. Wild cluster bootstrap (for inference with ~25 treated clusters)
2. Exclude 2020-2021 (COVID sensitivity)
3. Control for state-level COVID death rates
4. Placebo: ages 65+ (Medicare population — state caps shouldn't matter)
5. Placebo: non-diabetes mortality (cancer, heart disease) — same age group
6. Bacon decomposition (goodman_bacon function) to show which 2×2 DiD comparisons drive results
7. HonestDiD sensitivity analysis for violations of parallel trends
8. Different cap thresholds (states with $25 vs $100 caps as heterogeneous treatment)

### Exposure Alignment

- **Who is treated:** Commercially insured adults ages 25-64 who use insulin
- **Primary estimand population:** All adults ages 25-64 (intent-to-treat, population-level)
- **Dilution concern:** Not all working-age adults have diabetes or use insulin (~10% diabetes prevalence, ~30% of diabetics use insulin → ~3% directly affected). This is acknowledged and we test for dose-response using state diabetes prevalence.

### Power Assessment

- **Pre-treatment periods:** 20+ years (1999-2019)
- **Treated clusters:** 25+ states
- **Post-treatment periods:** 1-4 years depending on cohort
- **MDE estimate:** With ~50 state-year units and diabetes mortality rates of ~15 per 100,000 for ages 25-64, standard DiD should detect ~10-15% changes. Given dilution (only 3% directly treated), a null result is plausible and informative.

### Expected Results

**Hypothesis:** Insulin copay caps reduce diabetes mortality among working-age adults, but the effect may be small due to dilution and short post-treatment periods.

**Alternative interpretations:**
- Null result: Copay caps may not be sufficient to prevent mortality; caps only apply to commercial insurance and don't reach uninsured; compliance/enforcement varies.
- Positive result (increased mortality): Would be surprising but could reflect selection (sicker patients staying alive longer with better adherence, then dying of diabetes-related causes later).
- Negative result (decreased mortality): Consistent with improved insulin adherence → better glucose control → fewer acute complications.

### Limitations (acknowledged ex ante)

1. Outcome dilution: State-level mortality includes many non-insulin-using diabetics
2. Short post-treatment periods for most cohorts
3. COVID-19 contemporaneous shock
4. State caps only cover commercial insurance; uninsured and Medicaid populations unaffected
5. Caps don't address insulin pricing itself, only out-of-pocket costs
6. Death certificate coding for diabetes varies
