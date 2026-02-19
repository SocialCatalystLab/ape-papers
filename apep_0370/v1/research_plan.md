# Initial Research Plan: apep_0369

## Research Question

Do state mandates requiring electronic prescribing for controlled substances (EPCS) reduce opioid prescribing and prescription opioid overdose mortality?

## Identification Strategy

**Design:** Staggered difference-in-differences using Callaway-Sant'Anna (2021) estimator.

**Treatment:** State-level EPCS mandates. 34 states enacted mandates with staggered adoption from 2011 (Minnesota) to 2024 (Illinois). Major adoption waves in 2020 (6 states), 2021 (14 states), and 2022 (6 states).

**Control group:** Never-treated states (as of end of study period) and not-yet-treated states.

**Key identification assumption:** Absent the EPCS mandate, treated and control states would have followed parallel trends in opioid prescribing and overdose mortality. This is supported by:
1. EPCS mandates are driven by state legislative cycles and federal policy momentum, not by state-specific opioid trends
2. The 2020-2022 adoption wave was triggered by CMS rulemaking and the SUPPORT Act (2018), creating quasi-exogenous timing variation
3. Multiple pre-treatment periods (5+ years for the main 2020-2022 cohorts) allow rigorous pre-trend testing

**Exposure alignment:**
- Who is actually treated? Prescribers of controlled substances in mandated states
- Primary estimand population: All state residents (population-level mortality outcomes)
- Placebo/control population: States without mandates; within treated states, illicit fentanyl deaths (T40.4) serve as a drug-class placebo

## Expected Effects and Mechanisms

**Primary mechanism:** EPCS mandates eliminate paper prescriptions for controlled substances, which:
1. Prevents prescription fraud/forgery (patients altering paper prescriptions)
2. Enables integration with PDMP databases (automatic cross-referencing)
3. Creates decision-support alerts at point of prescribing
4. Makes prescribing patterns more transparent and auditable

**Expected signs:**
- Opioid prescribing rate: Negative (fewer prescriptions dispensed per capita)
- Prescription opioid overdose deaths (T40.2): Negative (fewer deaths)
- Illicit fentanyl deaths (T40.4): Zero/null (placebo — EPCS doesn't affect illicit supply)
- Total opioid deaths: Ambiguous (possible substitution to illicit opioids)

**Counterpoint:** Yang et al. (2020, JAMA Network Open) found voluntary EPCS adoption was associated with INCREASED prescribing, possibly because electronic systems make prescribing more convenient (lower hassle cost). My design isolates the MANDATE effect, which differs from voluntary adoption.

## Primary Specification

```r
# Callaway-Sant'Anna staggered DiD
cs_out <- att_gt(
  yname = "rx_opioid_death_rate",  # Prescription opioid deaths per 100K
  tname = "year",
  idname = "state_fips",
  gname = "epcs_mandate_year",     # First year of EPCS mandate (0 if never-treated)
  data = panel_df,
  control_group = "nevertreated",
  anticipation = 1,                # Allow 1 year anticipation
  base_period = "universal"
)
```

## Planned Robustness Checks

1. **Event study with pre-trends test:** Dynamic ATT aggregation with HonestDiD sensitivity
2. **Drug-class placebo:** Same specification on synthetic opioid deaths (T40.4) — should show null
3. **Alternative estimators:** Sun-Abraham (sunab), Borusyak-Jaravel-Spiess imputation
4. **Control group sensitivity:** Not-yet-treated vs never-treated only
5. **Anticipation sensitivity:** 0, 1, and 2 years of allowed anticipation
6. **Bacon decomposition:** Diagnose potential TWFE contamination
7. **Concurrent policy controls:** Control for PDMP must-access mandates, naloxone access laws
8. **Wild cluster bootstrap:** Inference robustness with ~50 clusters
9. **Heterogeneity:** By pre-treatment prescribing rate (high vs low prescribing states)
10. **Dose-response:** States with broader mandates (all prescriptions vs controlled only)

## Power Assessment

- Pre-treatment periods: 5+ years for 2020-2022 cohorts (2015-2019/2021)
- Treated clusters: 34 states
- Post-treatment periods per cohort: 1-4 years depending on adoption timing
- Outcome variation: State-level prescription opioid death rates range from ~1 to ~15 per 100K
- MDE estimate: With 50 state-year clusters and within-state variation of ~2 deaths/100K, minimum detectable effect is approximately 5-10% of the mean — plausible given the magnitude of the opioid crisis

## Data Sources

1. **CDC VSRR Drug Overdose Deaths** (data.cdc.gov/resource/xkb8-kh2a): State × month × drug class, 2015-2025
2. **EPCS mandate dates:** Compiled from RXNT, state legislative records (34 states)
3. **State controls:** Population (Census), unemployment (BLS/FRED), concurrent opioid policies (PDMP mandates, naloxone access laws)
