# Initial Research Plan

## Paper 134: Do Supervised Drug Injection Sites Save Lives?
## Evidence from America's First Overdose Prevention Centers

---

## Research Question

Do overdose prevention centers (OPCs) reduce drug overdose deaths in their surrounding neighborhoods? We exploit the November 30, 2021 opening of America's first two government-sanctioned OPCs in New York City to estimate causal effects on local mortality.

---

## Policy Background

On November 30, 2021, OnPoint NYC opened two overdose prevention centers - the first publicly sanctioned supervised drug injection sites in U.S. history:

1. **East Harlem OPC:** 104-106 E 126th Street, New York, NY 10035 (UHF neighborhood 103)
2. **Washington Heights OPC:** 500 W 180th Street, New York, NY 10033 (UHF neighborhood 102)

These sites allow adults to use pre-obtained drugs under medical supervision, with staff trained to intervene in overdoses. The sites have reversed over 1,700 overdoses with zero deaths on-site since opening.

**Policy Controversy:** In January 2025, the Trump administration asked NYC to shut down the OPCs. Multiple states are considering similar programs. Rigorous evidence on mortality effects is urgently needed.

---

## Identification Strategy

### Primary Approach: Synthetic Control Method

**Treated Units:**
- East Harlem (UHF 103)
- Washington Heights (UHF 102)

**Donor Pool:** Other NYC UHF neighborhoods (N≈38), excluding:
- Adjacent "spillover" neighborhoods (Central Harlem, Inwood, South Bronx)
- Neighborhoods with extremely low baseline overdose rates

**Pre-Treatment Period:** 2015-2021 (7 years)
**Post-Treatment Period:** 2022-2024 (3 years)

**Outcome:** Overdose death rate per 100,000 population by UHF × year

**Synthetic Control Construction:**
- Match on: Pre-treatment overdose rates, demographic composition, poverty rates, treatment facility density
- Use `Synth` package in R with augmented synthetic control (`augsynth`)

### Alternative Approach: Difference-in-Differences

For robustness, we also estimate a DiD specification:
- Treatment: Indicator for UHFs 102 or 103 × Post-November 2021
- Controls: UHF and year fixed effects
- Standard errors: Wild cluster bootstrap (few clusters)

---

## Pre-Specified Spillover Structure

**Ring 1 (Treated):** UHF 102 (Washington Heights), UHF 103 (East Harlem)

**Ring 2 (Spillover - Excluded from Donor Pool):**
- UHF 101 (Central Harlem) - adjacent to East Harlem
- UHF 104 (Inwood) - adjacent to Washington Heights
- UHF 201-203 (South Bronx neighborhoods) - adjacent to East Harlem

**Ring 3 (Potential Controls):**
- High-overdose UHFs: Brownsville, East New York, Mott Haven, Hunts Point, Bedford-Stuyvesant
- Moderate-overdose UHFs: Sunset Park, Bushwick, Jamaica

**Donut Robustness:**
- Specification A: Include Ring 2 in donor pool
- Specification B: Exclude Ring 2 from donor pool (primary)
- Specification C: Exclude Ring 2 + Ring 3 high-overdose areas

---

## Expected Effects and Mechanisms

**Primary Mechanism:** Direct prevention of fatal overdoses
- OPCs reverse overdoses on-site before they become fatal
- Staff intervention with naloxone and medical care

**Secondary Mechanisms:**
1. Reduced public drug use → fewer unwitnessed overdoses
2. Linkage to treatment → reduced long-term risk
3. Harm reduction education → safer use practices
4. Displacement from surrounding areas → concentration effect

**Expected Effect Size:**
- Vancouver Insite: 35% reduction in overdose deaths within 500m
- Toronto OPCs: 67-69% reduction within 1km
- **Hypothesis:** 20-40% reduction in treated UHFs

**Plausible Null:** Effect may be attenuated by:
- Geographic mismatch (people travel to OPCs from other UHFs)
- Displacement (deaths shift to other locations)
- Small treatment dose (only ~3% of local drug users access OPCs)

---

## Inference Strategy for Few Treated Units

Given only 2 treated neighborhoods, we use:

### 1. Randomization Inference
- Permute treatment assignment across 42 UHFs
- Compute SCM estimate under each permutation
- Report exact p-value

### 2. Placebo-in-Time Tests
- Assign placebo treatment dates: 2016, 2017, 2018, 2019, 2020
- Verify no detectable "effect" in pre-period
- Compare placebo distribution to actual effect

### 3. Placebo-in-Space Tests
- Randomly assign treatment to 2 control UHFs (1000 iterations)
- Construct null distribution of placebo effects
- Report p-value = Pr(|placebo effect| ≥ |actual effect|)

### 4. MSPE Ratio
- Compute ratio of post-treatment MSPE to pre-treatment MSPE
- Compare treated ratio to donor pool distribution
- Report rank-based p-value

---

## Primary Specification

```r
# Synthetic Control
synth_result <- augsynth(
  od_rate ~ treat,
  unit = uhf_id,
  time = year,
  data = panel_data,
  progfunc = "ridge",
  scm = TRUE
)

# DiD with wild cluster bootstrap
did_result <- feols(
  od_rate ~ i(year, treated, ref = 2021) | uhf_id + year,
  data = panel_data,
  cluster = ~uhf_id
)

# Randomization inference
ri_pvalue <- compute_ri_pvalue(synth_result, n_perms = 1000)
```

---

## Planned Robustness Checks

1. **Donor pool variation:**
   - All NYC UHFs
   - High-overdose UHFs only (matched on baseline)
   - Boroughs separately (Manhattan only, Bronx only)

2. **Outcome variation:**
   - All-cause drug overdose deaths
   - Opioid-specific overdose deaths
   - Fentanyl-involved deaths (if data available)

3. **Temporal variation:**
   - Annual data (primary)
   - Quarterly data (if available)

4. **Inference variation:**
   - Wild cluster bootstrap
   - Randomization inference
   - Conformal inference

5. **Placebo outcomes:**
   - Non-drug mortality (should show no effect)
   - Traffic fatalities (should show no effect)

---

## Data Sources

### Primary Outcome Data
- **NYC DOHMH EpiQuery:** Overdose deaths by UHF × year
- **NYC Vital Statistics Data Briefs:** Published PDF tables with neighborhood rates
- **Source URL:** https://a816-health.nyc.gov/hdi/epiquery/

### Geographic Crosswalks
- **UHF-ZIP mapping:** https://www1.nyc.gov/assets/doh/downloads/pdf/ah/zipcodetable.pdf

### Covariates (for matching)
- **American Community Survey:** Demographics, poverty, housing
- **NYC Open Data:** Treatment facilities, harm reduction sites

---

## Power Assessment

**Baseline overdose rates (2019-2020):**
- East Harlem: ~85-90 per 100,000
- Washington Heights: ~45-50 per 100,000
- NYC average: ~35 per 100,000

**Expected power:**
- With 7 pre-treatment years and 3 post-treatment years
- For a 30% reduction (effect size ≈ 15-25 per 100,000)
- Pre-treatment RMSPE likely small given matching on rates
- Power depends heavily on pre-treatment fit quality

**MDE calculation:** To be computed after data acquisition based on actual pre-treatment variance.

---

## Timeline

1. **Data acquisition:** Fetch UHF-level overdose data from EpiQuery (1 day)
2. **Data cleaning:** Construct panel, verify consistency (1 day)
3. **Primary analysis:** Synthetic control estimation (1 day)
4. **Inference:** Randomization inference, placebos (1 day)
5. **Robustness:** Alternative specifications (1 day)
6. **Write-up:** Paper drafting (2-3 days)

---

## Potential Limitations (To Acknowledge)

1. **Only 2 treated units:** Inference relies on permutation methods
2. **Coarse geography:** UHF neighborhoods (~50k people) may not capture hyperlocal effects
3. **Spillovers:** Treatment effect may diffuse to adjacent areas, biasing toward null
4. **Selection into treatment:** East Harlem and Washington Heights chosen for OPCs based on existing infrastructure (syringe exchanges), not randomly
5. **Concurrent events:** COVID-19 pandemic, fentanyl wave, policing changes
6. **Short post-period:** Only 3 years of post-treatment data

---

## Exposure Alignment

**Who is actually treated?**
Drug users who physically visit the OPCs and consume drugs under supervision. The treatment is individual-level (a person visits the site), but our outcome is measured at neighborhood level (UHF overdose rates).

**Primary estimand population:**
Residents of East Harlem (UHF 203) and Washington Heights (UHF 201) who use drugs. This includes both OPC clients and non-clients who may benefit indirectly through network effects (naloxone sharing, harm reduction knowledge diffusion).

**Placebo/control population:**
Residents of other NYC UHF neighborhoods who do not have local OPC access. These individuals may access syringe services and other harm reduction programs but cannot use supervised consumption facilities.

**Design:**
This is a standard DiD (not triple-diff/DDD). Treatment is at the neighborhood level: neighborhoods with OPCs (treated) vs. neighborhoods without OPCs (control).

**Potential alignment issues:**
1. *Geographic mismatch:* Drug users may travel from control neighborhoods to use OPCs, diluting the treatment-control contrast
2. *Partial treatment:* Only ~3% of local drug users access OPCs, so neighborhood-level effects are attenuated versions of individual-level effects
3. *Spillovers:* Benefits may extend to adjacent (excluded) neighborhoods through client mobility and network effects

**Our approach:**
We exclude adjacent neighborhoods from the donor pool to avoid contamination. We interpret our estimates as intent-to-treat (ITT) neighborhood-level effects, not treatment-on-the-treated (TOT) individual effects. The SCM constructs unit-specific counterfactuals that account for the treated neighborhoods' particular pre-treatment trajectories.

---

## Contribution

This paper provides the first rigorous causal estimate of whether supervised drug injection sites reduce overdose mortality in the United States. Prior evidence comes from Canada and Europe with different drug markets and policy contexts. Given the intense policy debate over OPCs and multiple states considering authorization, credible U.S. evidence is urgently needed.
