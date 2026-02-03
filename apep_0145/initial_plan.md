# Research Plan: EERS Revision

## Revision of apep_0119

This is a revision of the paper "Do Energy Efficiency Resource Standards Reduce Electricity Consumption? Evidence from Staggered State Adoption" (apep_0119).

## Research Question

Do state Energy Efficiency Resource Standards (EERS) reduce residential electricity consumption?

## Identification Strategy

Staggered difference-in-differences using Callaway and Sant'Anna (2021) estimator with:
- 28 treated jurisdictions (27 states + DC) adopting EERS between 1998-2020
- 23 never-treated states as controls
- Balanced panel: 51 jurisdictions, 1990-2023

## Exposure Alignment

**Who is actually treated?**
- Residential electricity consumers in states with binding EERS mandates
- Treatment operates through utility-administered DSM programs (rebates, audits, appliance incentives)
- Industrial consumers largely exempt from residential-focused EERS programs

**Primary estimand population:**
- State-level aggregate residential electricity consumption per capita
- Captures intent-to-treat effect of EERS policy adoption on all residential consumers

**Placebo/control population:**
- Industrial electricity consumption (should show null effect - not targeted by EERS)
- Commercial consumption (partial effect expected - some programs include C&I)

**Design:**
- Standard staggered DiD (not triple-diff)
- Treatment: binary adoption of binding mandatory EERS
- Control: never-treated states (voluntary/non-binding EERS coded as control)

## Key Improvements in This Revision

### 1. Fixed Code Integrity Issues
- Corrected heterogeneity analysis treatment coding (early/late adopters now properly defined)
- Added all robustness results to summary output (fixed selective reporting)
- Added zero-value guards for log transformations

### 2. Strengthened Identification
- Added Census Division × Year fixed effects (addresses regional trend concerns)
- Added controls for concurrent policies (RPS, utility decoupling)
- Added weather controls (HDD/CDD) - data source
- Policy controls merged from constructed dataset

### 3. Improved Inference
- Wild cluster bootstrap implemented (fwildclusterboot package)
- Rambachan-Roth sensitivity attempted (HonestDiD)

### 4. Expanded Literature
- Added Borusyak et al. (2024), Arkhangelsky et al. (2021), Gardner (2022)
- Added Cameron et al. (2008), MacKinnon and Webb (2018) for bootstrap inference
- Improved framing as "policy package" interpretation

## Data Sources

1. **Electricity consumption**: EIA SEDS (residential, commercial, industrial, total)
2. **Electricity prices**: EIA Retail Sales
3. **Population**: Census Bureau Population Estimates Program
4. **Treatment coding**: ACEEE, DSIRE, NCSL databases
5. **Policy controls**: RPS, decoupling from DSIRE/RAP
6. **Weather**: NOAA NCEI HDD/CDD (to be fetched)

## Expected Results

Based on parent paper and revised analysis:
- Main ATT estimate: approximately -4% (CS-DiD with never-treated)
- Robust to region-year FE, policy controls
- Early adopters: larger effect (-4.0%, p<0.05)
- Late adopters: smaller, imprecise (-2.3%)

## Timeline

- [x] Initialize workspace and copy parent artifacts
- [x] Fix code integrity issues
- [x] Add policy controls
- [x] Update robustness script with new specifications
- [x] Update paper.tex with new results and literature
- [x] Compile paper
- [ ] Run advisor review
- [ ] Run external review
- [ ] Publish with --parent apep_0119
