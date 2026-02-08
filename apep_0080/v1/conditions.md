# Conditional Requirements

**Generated:** 2026-01-29T02:49:24.725669
**Status:** RESOLVED

---

## ⚠️ THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## Click It or Ticket at the Border: A Spatial Regression Discontinuity Analysis of Primary Seatbelt Enforcement Laws

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: obtaining a credible denominator/exposure measure near borders—e.g.

**Status:** [X] RESOLVED

**Response:**

For spatial RDD at borders, the key outcome is **fatality probability conditional on crash**, not crash rate. This sidesteps the VMT denominator problem:

- **Primary outcome:** P(fatality | crash) = (fatalities in crash) / (persons in crash)
- This is computed per-crash from FARS, which records all persons in each fatal crash
- No VMT exposure needed because we condition on crash occurring

For robustness with rates, we can use:
1. **HPMS segment-level VMT**: Highway Performance Monitoring System provides AADT × segment length for all federal-aid highways, available as shapefiles
2. **County-level VMT**: Available from FHWA's Highway Statistics annual reports
3. **Border-segment normalization**: Compare density of crashes per road-km on each side of border

**Evidence:**

- FARS Person file contains all occupants of each crash, enabling P(death|crash) calculation
- HPMS geodata: https://catalog.data.gov/dataset/highway-performance-monitoring-system-hpms
- FHWA Highway Statistics: https://www.fhwa.dot.gov/policyinformation/statistics.cfm

---

### Condition 2: harmonized police-reported crash data or segment-level VMT

**Status:** [X] RESOLVED

**Response:**

FARS is already nationally harmonized—it's a federal database with standardized coding across all 50 states. Key harmonization features:
- Same data elements nationwide since 1975
- NHTSA quality control and imputation procedures
- State-level recoding to federal format

For non-fatal crashes (if needed for placebo on crash RATE):
- General Estimates System (GES) provides harmonized sample of all crashes
- State crash files vary in format, but we focus on FARS for fatal crash analysis

**Evidence:**

- FARS Analytical User's Manual confirms national standardization
- GES documentation: https://www.nhtsa.gov/national-automotive-sampling-system/nass-general-estimates-system

---

### Condition 3: a pre-analysis plan for spillovers/composition

**Status:** [X] RESOLVED

**Response:**

Pre-analysis plan for spillovers and composition effects:

**Spillover Concerns:**
1. **Cross-border enforcement spillovers**: Drivers may adjust behavior as they approach border anticipating enforcement change
   - *Test*: Examine whether effect fades as we move away from border (should be flat for behavioral mechanism)

2. **Driver residence vs. crash location**: Out-of-state drivers may have different seatbelt habits
   - *Test*: FARS includes driver state of license; restrict to in-state residents for robustness
   - *Test*: Separately analyze in-state vs. out-of-state drivers

**Composition Effects:**
3. **Border areas may have different road types**: More interstates, different traffic mix
   - *Control*: Include road type fixed effects (interstate, US highway, state highway, local)
   - *Balance test*: Check road type composition is smooth at border

4. **Border demographics**: Border counties may differ systematically
   - *Balance test*: Check that demographic variables (income, urbanization, age distribution) are smooth at border
   - *Control*: Include county-level controls in robustness

**Evidence:**

- FARS Person file includes DR_STATE (driver license state) for residence-based analysis
- FARS Accident file includes road type coding
- Census/ACS provides county demographics for balance tests

---

### Condition 4: e.g.

**Status:** [X] NOT APPLICABLE

**Response:**

This appears to be a parsing artifact from the ranking output. No specific condition stated.

---

### Condition 5: donut RD

**Status:** [X] RESOLVED

**Response:**

Will implement donut RD (excluding observations very close to border) to address:
1. **Precise sorting**: Drivers who choose to live right at border based on enforcement preferences
2. **Border crossing effects**: Crashes right at border may involve drivers from either state
3. **Measurement error in border assignment**: GPS coordinates near border may be mis-assigned

**Implementation:**
- Primary analysis: standard RDD with all observations
- Robustness: Exclude crashes within 1km, 2km, 5km of border
- Report bandwidth-sensitivity plots

**Evidence:**

- Standard donut RD methodology from Barreca et al. (2011) "Saving Babies"
- SpatialRDD R package supports donut hole specification

---

### Condition 6: restricting to residents if feasible

**Status:** [X] RESOLVED

**Response:**

FARS Person file includes `DR_STATE` (state of driver's license), enabling resident restriction:

**Implementation:**
1. **Main analysis**: All crashes regardless of driver residence
2. **Robustness check 1**: Restrict to crashes where driver license state = crash state (residents only)
3. **Robustness check 2**: Separately estimate effects for residents vs. non-residents
   - Non-residents should show smaller effect (their seatbelt habits formed in home state)
   - This is a mechanism test!

**Evidence:**

- FARS Person file variable DR_STATE documented in FARS Analytical User's Manual
- Research shows out-of-state drivers have different crash patterns (Regev et al., 2014, Accident Analysis & Prevention)

---

### Condition 7: clustering at border-segment level

**Status:** [X] RESOLVED

**Response:**

Standard errors will be clustered at the border-segment level to account for:
1. Spatial correlation within border regions
2. Common shocks to both sides of a given border
3. Serial correlation over time at each border

**Implementation:**
1. Define border segments: ~50-100km sections of each state border
2. Assign each crash to nearest border segment
3. Cluster standard errors at border-segment × year level
4. Robustness: Conley (1999) spatial HAC standard errors with distance decay

**Evidence:**

- Standard practice in geographic RDD (Keele & Titiunik 2015)
- SpatialRDD package provides border segment assignment functions
- Alternative: Wild cluster bootstrap for small number of clusters

---

## Verification Checklist

Before proceeding to Phase 4:

- [X] All conditions above are marked RESOLVED or NOT APPLICABLE
- [X] Evidence is provided for each resolution
- [X] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
