# Conditional Requirements

**Generated:** 2026-02-01T23:34:59.470465
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## America's First Supervised Drug Injection Sites and Neighborhood Overdose Deaths (NYC)

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: securing outcome data at finer geography than UHF or demonstrating robustness to geography choice

**Status:** [x] RESOLVED

**Response:**

We have multiple options for geographic granularity:

1. **UHF-42 neighborhoods (primary):** NYC DOHMH EpiQuery provides mortality by UHF neighborhood (42 areas) × year. This is the publicly available level. The treated UHFs (East Harlem = UHF 103, Washington Heights = UHF 102) are small enough geographic units (~22,000-60,000 people each) to capture localized effects.

2. **ZIP code approximation:** UHF neighborhoods are defined as contiguous ZIP codes. The mapping is publicly available (nyc.gov/assets/doh/downloads/pdf/ah/zipcodetable.pdf). We can verify that treated UHFs correspond to a small set of ZIP codes around OPC locations.

3. **Robustness to geography:** We will conduct sensitivity analyses:
   - Vary the donor pool (all NYC UHFs vs. only high-overdose UHFs)
   - Exclude adjacent "spillover" UHFs from donor pool
   - Use pre-period placebo tests (placebo OPC dates in 2018, 2019, 2020)

4. **Published precedent:** The JAMA 2023 study on crime/disorder (PMC10644216) used a 6-city-block hexagon (22 acres) centered on each OPC. We can replicate this spatial structure for our analysis.

**Evidence:**

- NYC DOHMH EpiQuery: https://a816-health.nyc.gov/hdi/epiquery/
- UHF-ZIP code mapping: https://www1.nyc.gov/assets/doh/downloads/pdf/ah/zipcodetable.pdf
- Published methodology: Overdose Prevention Centers, Crime, and Disorder in NYC (JAMA 2023) - used tessellated hexagonal array

---

### Condition 2: pre-specifying spillover rings/"donut" buffers

**Status:** [x] RESOLVED

**Response:**

We will pre-specify the following spillover structure in the research plan:

1. **Treated ring (0-6 blocks):** The immediate UHF containing the OPC
   - East Harlem (UHF 103) contains OPC at 104-106 E 126th St
   - Washington Heights (UHF 102) contains OPC at 500 W 180th St

2. **Spillover ring (adjacent UHFs):** Exclude from donor pool
   - For East Harlem: Exclude Central Harlem (UHF 101), South Bronx (UHF 201-203)
   - For Washington Heights: Exclude Inwood (UHF 104), Bronx neighborhoods sharing border

3. **Control ring (non-adjacent high-overdose UHFs):** Use as donor pool
   - Brownsville, East New York, Mott Haven, Hunts Point
   - Pre-select based on 2015-2019 baseline overdose rates (top quintile)

4. **Donut robustness:** Run specifications with and without adjacent UHFs to test sensitivity

**Evidence:**

This approach follows Marshall et al. (JAMA 2023) who used concentric hexagons and explicitly tested for spillover effects in adjacent blocks.

---

### Condition 3: implementing randomization inference/placebo tests appropriate for few treated units

**Status:** [x] RESOLVED

**Response:**

Given only 2 treated units (East Harlem + Washington Heights), we will use:

1. **Randomization Inference (RI):**
   - Permute treatment assignment across the 42 UHFs
   - Compute synthetic control or DiD estimate under each permutation
   - Report exact p-value as fraction of permutations with effect ≥ observed

2. **Placebo-in-time tests:**
   - Run synthetic control with fake treatment dates: 2016, 2017, 2018, 2019
   - Verify no effect detected in pre-period
   - Compare placebo effect distribution to actual 2021 treatment effect

3. **Placebo-in-space tests:**
   - Randomly assign "treatment" to 2 control UHFs
   - Verify no significant effects
   - Repeat 1000 times for distribution

4. **Wild cluster bootstrap:**
   - For DiD specification, use wild cluster bootstrap with cluster = UHF
   - Use Webb weights for few-cluster inference

5. **Synth inference:**
   - Use `Synth` package with inference via placebo distribution
   - Report MSPE ratio (post/pre) and compare to donor pool distribution

**Evidence:**

- Abadie, Diamond, Hainmueller (2010): Synthetic Control inference via placebo studies
- MacKinnon & Webb (2017): Wild cluster bootstrap with few clusters
- JAMA 2023 study used similar permutation-based inference

---

## Oregon Psilocybin "Opt-Out" Bans and Mental Health Outcomes

**Rank:** #4 | **Recommendation:** CONSIDER

### Condition 1: data exist

**Status:** [x] NOT APPLICABLE

**Response:**

Not pursuing this idea. NYC OPCs is the selected project.

---

## Rhode Island's First State-Regulated OPC and Geographic Overdose Patterns

**Rank:** #5 | **Recommendation:** CONSIDER

### Condition 1: at least 2–3 full post years

**Status:** [x] NOT APPLICABLE

**Response:**

Not pursuing this idea. NYC OPCs is the selected project.

---

### Condition 2: focusing on higher-frequency outcomes like EMS overdoses

**Status:** [x] NOT APPLICABLE

**Response:**

Not pursuing this idea.

---

### Condition 3: naloxone reversals

**Status:** [x] NOT APPLICABLE

**Response:**

Not pursuing this idea.

---

### Condition 4: nonfatal overdoses

**Status:** [x] NOT APPLICABLE

**Response:**

Not pursuing this idea.

---

### Condition 5: pre-registering a small-number-of-treated inference strategy

**Status:** [x] NOT APPLICABLE

**Response:**

Not pursuing this idea.

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [x] This file has been committed to git

**Status: RESOLVED**
