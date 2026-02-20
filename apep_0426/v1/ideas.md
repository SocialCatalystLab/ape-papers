# Research Ideas

## Idea 1: The 20-Year Legacy of MGNREGA: Village-Level Evidence of Structural Transformation from Satellite Data

**Policy:** India's Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA), rolled out in three phases: Phase I (Feb 2006, 200 most backward districts), Phase II (Apr 2007, +130 districts), Phase III (Apr 2008, all remaining ~310 rural districts). Assignment based on Planning Commission's backwardness index (2003). Program was formally replaced by VB-G RAM G Act in December 2025.

**Outcome:** SHRUG nightlights panel (DMSP 1994–2013 + VIIRS 2012–2023) at the village level (~596K villages), supplemented by Census PCA worker composition data (1991, 2001, 2011) measuring structural transformation from agricultural to non-agricultural employment.

**Identification:** Callaway-Sant'Anna doubly robust DiD estimator with three treatment cohorts (2006, 2007, 2008) using not-yet-treated villages as controls. Village fixed effects absorb time-invariant heterogeneity; state × year fixed effects absorb state-level trends. 13+ pre-treatment years of nightlights (1994–2005) allow thorough pre-trend testing. Cluster standard errors at district level.

**Why it's novel:**
- First village-level (N≈596K) assessment of MGNREGA using satellite data spanning 30 years
- Long-run perspective: 15+ years post-treatment for Phase I — prior studies examined short-run (2–5 year) effects
- Directly tests competing theories: crowd-out (reservation wage increase reduces non-farm activity) vs. demand multiplier (income boost stimulates non-farm growth) vs. insurance (safety net enables risk-taking/entrepreneurship)
- Timely: MGNREGA was just replaced in Dec 2025, making retrospective evaluation policy-relevant
- Heterogeneity analysis by baseline development level (initially dark vs. bright villages) and SC/ST population share

**Feasibility check:**
- ✅ Variation exists: 3 treatment cohorts across 640 districts
- ✅ Data accessible: SHRUG nightlights + Census PCA already downloaded locally (4.7 GB)
- ✅ Not overstudied at this granularity: Prior work (Imbert & Papp 2015 AEJ:Applied; Muralidharan et al. 2023 Econometrica) used district-level or RCT data from specific states; no published village-level nightlights study
- ✅ Sample size: 596K villages × 30 years = ~18M village-year observations
- ✅ Phase assignment obtainable: Imbert & Papp replication data (openICPSR 113591) + official gazette notifications

---

## Idea 2: One Nation One Ration Card and Interstate Labor Mobility

**Policy:** One Nation One Ration Card (ONORC) — allows migrant workers to access subsidized food grains from any Fair Price Shop nationwide, not just their home district. Staggered state adoption: 4 states in Aug 2019, expanding to 24 states by Aug 2020, all 36 states/UTs by June 2022.

**Outcome:** PLFS quarterly urban employment panel (labor force participation, migration status, sector of employment) + state-level GST revenue (proxy for formal economic activity) + nightlights.

**Identification:** State-level staggered DiD using ONORC adoption dates. Callaway-Sant'Anna estimator with state × quarter panel.

**Why it's novel:**
- Only one published study (Tumbe & Jha 2024) — found limited interstate traction
- Clean staggered adoption over 3 years across 36 states
- Tests whether reducing PDS portability friction increases interstate migration
- COVID creates a natural acceleration in adoption (PMGKAY interaction)

**Feasibility check:**
- ✅ Variation exists: 36 states with staggered adoption dates (well-documented)
- ⚠️ Pre-periods limited: PLFS starts July 2017, first treatment Aug 2019 → only 2 annual pre-periods
- ✅ Data accessible: PLFS published annual reports with state-level aggregates (no registration needed for aggregates); nightlights in SHRUG
- ⚠️ COVID confounding: ONORC rollout coincides with COVID (2020-21), complicating identification
- ✅ Novelty: Barely studied

---

## Idea 3: Jal Jeevan Mission and School Enrollment

**Policy:** Jal Jeevan Mission (JJM) — flagship program to provide household tap water connections to every rural household by 2024. Launched Aug 2019 with staggered district-level implementation. 188+ districts achieved "Har Ghar Jal" (100% coverage) by Aug 2024.

**Outcome:** UDISE+ school enrollment data (annual, 2012–present) at district/block level — enrollment by gender, class, and social group. Supplemented by nightlights as proxy for economic activity.

**Identification:** District-level staggered DiD using district completion dates. 7+ pre-periods (2012–2019 UDISE+). Callaway-Sant'Anna estimator.

**Why it's novel:**
- Only one published evaluation (PLOS One, early-phase descriptive) — no rigorous causal study exists
- Clean mechanism: piped water → reduced water collection burden (women/girls save ~5.5 crore hours/day nationally) → increased school attendance, especially for girls
- District-level stagger over 5 years provides clean variation
- Multiple outcome domains: enrollment, gender gap, dropout rates

**Feasibility check:**
- ✅ Variation exists: Staggered district completion dates (jaljeevanmission.gov.in dashboard)
- ✅ Pre-periods: UDISE+ annual data 2012–present → 7 pre-periods before 2019 launch
- ⚠️ Data accessible: UDISE+ confirmed working (smoke test PASS), but need to verify bulk download availability for district-level aggregates
- ✅ Novelty: Virtually unstudied with rigorous causal methods
- ⚠️ Outcome data lag: Most recent UDISE+ data may only cover through 2023–24

---

## Idea 4: MGNREGA as Climate Insurance: Do Guaranteed Jobs Buffer Drought Shocks?

**Policy:** Same MGNREGA 3-phase rollout as Idea 1, but studied in interaction with rainfall shocks.

**Outcome:** SHRUG nightlights (annual, village-level) interacted with district-level rainfall anomalies from ICRISAT District Level Database or Indian Meteorological Department gridded data.

**Identification:** Triple-difference: MGNREGA phase × drought × time. Tests whether villages with MGNREGA access show smaller nightlight declines during drought years compared to similar villages without access.

**Why it's novel:**
- Tests the insurance mechanism of workfare programs — theoretically important but empirically underexplored at village scale
- Climate adaptation relevance: as droughts intensify under climate change, workfare as insurance becomes more valuable
- Uses village-level variation within treated districts (rainfall heterogeneity)
- Complements Zimmermann (2020) who studied insurance mechanism but with district-level data

**Feasibility check:**
- ✅ Variation: MGNREGA phases × spatial rainfall variation
- ⚠️ Rainfall data: Need to obtain ICRISAT DLD or IMD gridded data (confirmed accessible but not downloaded)
- ✅ Power: Village-level panel with weather shocks provides enormous statistical power
- ✅ Novelty: Insurance mechanism not studied at village level with satellite data
- ⚠️ Complexity: Triple-diff requires more assumptions than simple DiD

---

## Idea 5: Ayushman Bharat PM-JAY and the Age-70 Expansion

**Policy:** Ayushman Bharat PM-JAY health insurance (Rs. 5 lakh/year coverage). Originally covered bottom 40% households (launched Sep 2018). In September 2024, expanded to ALL citizens aged 70+ regardless of income — a sharp age cutoff creating a natural RDD.

**Outcome:** Hospitalization rates, out-of-pocket health spending (would need NFHS-6 or survey data post-Sep 2024).

**Identification:** Sharp RDD at age 70 for the universal expansion. Clean cutoff, well-defined treatment.

**Why it's novel:**
- Very recent expansion (Sep 2024) — no published evaluation yet
- Clean RDD at age 70 — universal eligibility regardless of income
- Tests whether universal health insurance changes healthcare utilization for elderly

**Feasibility check:**
- ❌ Data access: Post-Sep 2024 outcome data barely exists; NFHS-6 not released; no large-scale hospitalization survey available
- ✅ Variation: Sharp age cutoff is clean
- ✅ Novelty: Completely unstudied
- ❌ Timing: Too early for rigorous evaluation — insufficient post-period data
- **VERDICT: DEFER — revisit when NFHS-6 or hospitalization data becomes available**
