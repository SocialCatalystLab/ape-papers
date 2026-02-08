# Initial Research Plan: Must-Access PDMP Mandates and Prime-Age Labor Force Participation

## Research Question

Do state mandates requiring prescribers to query Prescription Drug Monitoring Programs (PDMPs) before prescribing controlled substances ("must-access" laws) affect labor force participation and employment among prime-age adults (25-54)?

## Policy Background

Prescription Drug Monitoring Programs are state-run electronic databases that track controlled substance prescriptions. While all 50 states have PDMPs, a growing number adopted "must-access" or "must-query" mandates requiring prescribers to check the database before issuing prescriptions for controlled substances. These mandates shifted PDMPs from voluntary tools to binding requirements.

Key early adopters:
- Kentucky: July 2012 (first comprehensive mandate)
- Tennessee: Q1 2013
- New York: Q3 2013
- West Virginia: June 2012
- Ohio: April 2015

By 2019, approximately 40 states had adopted some form of must-access mandate, with staggered adoption from 2012 through 2020+.

## Identification Strategy

**Primary estimator:** Callaway-Sant'Anna (2021) staggered difference-in-differences estimator, using the `did` R package.

**Treatment variable:** Binary indicator equal to 1 in state-year cells where a must-access PDMP mandate was effective by January 1 of the survey year. This "full-exposure year" coding ensures alignment with CPS ASEC timing (fielded February-April, labor force status reflects ~March).

**Comparison group:** Never-treated states (states without must-access mandates by end of sample period) as primary control. Not-yet-treated as robustness check.

**Unit of analysis:** State × year, with individual-level CPS ASEC microdata aggregated using survey weights.

**Sample period:** 2007-2023 (CPS ASEC), providing 5+ pre-treatment years for most adoption cohorts.

## Exposure Alignment (DiD Requirement)

- **Who is treated:** All controlled substance prescribers in states with must-access mandates. Effects operate through reduced prescribing → reduced opioid misuse → improved health → improved labor supply.
- **Primary estimand population:** Prime-age adults (25-54) in treatment states.
- **Placebo/control populations:** (1) Elderly adults (65+) on Medicare (less affected by prescriber PDMP checks); (2) States without mandates.
- **Design:** Standard staggered DiD with CS estimator.

## Power Assessment

- **Pre-treatment periods:** 5-10 years for most cohorts (CPS ASEC from 2007)
- **Treated clusters:** ~35-40 states with must-access mandates by 2020
- **Post-treatment periods:** Varies by cohort (1-11 years)
- **Sample size:** ~100,000 individuals/year × 17 years = ~1.7M observations
- **MDE:** With 50 state clusters and ~17 years, MDE for LFP should be detectable at ~0.5-1.0 percentage points for full sample; subgroup effects may require larger magnitudes.

## Expected Effects and Mechanisms

**Primary mechanism:** Must-access mandates → reduced controlled substance prescribing → fewer new opioid users → reduced opioid dependence/disability → increased labor force participation.

**Expected direction:** Positive effect on LFP (more people in labor force), negative effect on disability receipt. Effects should be larger for:
- Males (higher opioid misuse rates)
- Less-educated workers (higher opioid exposure)
- States with higher pre-mandate opioid prescribing rates
- Workers in physically demanding occupations

**Effect timing:** Gradual onset (1-3 years) as pipeline effects work through reduced new prescriptions, not immediate for existing users.

## Data Sources

### Primary outcome data: CPS ASEC from IPUMS
- **API:** IPUMS microdata extract via `ipumspy` (API key confirmed)
- **Variables:** EMPSTAT (employment status), LABFORCE (labor force participation), WKDISAB/DIFFPHYS (work disability/physical difficulty), UHRSWORKT (hours worked), INCTOT/INCWAGE (income/wages)
- **Demographics:** AGE, SEX, RACE, EDUC, STATEFIP
- **Sample:** CPS ASEC March supplements 2007-2023
- **Weights:** ASECWT (person weight)

### Treatment data: PDMP must-access mandate dates
- Compiled from PDAPS (pdaps.org), Horwitz et al. (2018), Buchmueller & Carey (2018), and NCSL
- Cross-referenced across multiple sources for accuracy
- Coded as effective-by-January-1 for full-year exposure alignment

### Concurrent policy controls
- Naloxone access laws (dates from PDAPS)
- Good Samaritan laws (dates from PDAPS)
- Medicaid expansion (dates from KFF)
- Medical/recreational marijuana legalization (dates from NCSL)
- Pill mill laws (dates from PDAPS)

## Primary Specification

```r
cs_out <- att_gt(
  yname = "lfp",           # Labor force participation rate
  tname = "year",          # Year
  idname = "statefip",     # State FIPS code
  gname = "first_treat",   # Year of mandate adoption (0 if never-treated)
  data = state_year_df,
  control_group = "nevertreated",
  est_method = "dr"        # Doubly-robust estimation
)

# Overall ATT
att_overall <- aggte(cs_out, type = "simple")

# Dynamic (event study)
att_dynamic <- aggte(cs_out, type = "dynamic")
```

## Planned Robustness Checks

1. **Alternative estimators:** Sun-Abraham (via `fixest::sunab()`), Gardner two-stage imputation (`did2s`)
2. **Alternative control group:** Not-yet-treated states
3. **Bacon decomposition:** Goodman-Bacon decomposition of TWFE to show heterogeneity concerns
4. **HonestDiD:** Rambachan-Roth sensitivity analysis for parallel trends violations
5. **Concurrent policy controls:** Add naloxone access, Good Samaritan, Medicaid expansion, marijuana laws
6. **Placebo outcomes:** Elderly (65+) labor force participation (should not be affected)
7. **Placebo timing:** Randomized treatment dates
8. **Subgroup analysis:**
   - By sex (male vs. female)
   - By education (< college vs. college+)
   - By pre-mandate state opioid prescribing rate (high vs. low)
9. **Alternative outcomes:** Employment-to-population ratio, hours worked, disability receipt, wage income
10. **Leave-one-out:** Drop each early-adopter state and re-estimate

## Paper Structure

1. Introduction
2. Background: Opioid Crisis, PDMPs, and Labor Markets
3. Must-Access PDMP Mandates: Policy Details and Timing
4. Data and Sample
5. Empirical Strategy
6. Results
   6.1. Main Results (LFP, Employment)
   6.2. Event Study
   6.3. Heterogeneous Effects
7. Robustness
   7.1. Alternative Estimators
   7.2. Parallel Trends Diagnostics
   7.3. Concurrent Policies
   7.4. Placebo Tests
8. Mechanisms and Discussion
9. Conclusion

## Figures Plan

1. **Figure 1:** Map of PDMP must-access mandate adoption timing (choropleth)
2. **Figure 2:** Treatment rollout timeline (staggered adoption plot)
3. **Figure 3:** Parallel trends: Mean LFP by treatment cohort over time
4. **Figure 4:** Main event study (CS-DiD, dynamic ATT)
5. **Figure 5:** Heterogeneous effects (by sex, education, opioid severity)
6. **Figure 6:** Robustness: Alternative estimators comparison
7. **Figure 7:** HonestDiD sensitivity analysis
8. **Figure 8:** Placebo: Elderly LFP event study

## Tables Plan

1. **Table 1:** Summary statistics (treated vs. never-treated states)
2. **Table 2:** PDMP must-access mandate adoption dates by state
3. **Table 3:** Main results (CS-DiD ATT for multiple outcomes)
4. **Table 4:** Robustness to alternative estimators
5. **Table 5:** Robustness to concurrent policy controls
6. **Table 6:** Heterogeneous effects by subgroup
7. **Table 7:** Bacon decomposition of TWFE
