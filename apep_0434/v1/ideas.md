# Research Ideas

## Idea 1: MGNREGA and the Geography of Structural Transformation: Village-Level Evidence from 600,000 Indian Villages

**Policy:** India's Mahatma Gandhi National Rural Employment Guarantee Act (MGNREGA), rolled out in three staggered phases: Phase I (Feb 2006, 200 most backward districts), Phase II (Apr 2007, +130 districts), Phase III (Apr 2008, all remaining ~310 rural districts). Phase assignment based on Planning Commission's backwardness index.

**Outcome:** (1) Village-level worker composition changes from Census 2001 to 2011 — specifically the share of workers classified as cultivators, agricultural laborers, household industry workers, and "other workers" (non-farm). (2) Annual nighttime lights (DMSP 1994–2013) as a continuous proxy for economic activity at village level.

**Identification:** Staggered DiD exploiting the three-phase rollout. Treatment cohorts: Phase I (2006), Phase II (2007), Phase III (2008, serves as late control). Apply Callaway & Sant'Anna (2021) heterogeneity-robust estimator with group-time ATTs and dynamic event study. Cluster SEs at district level (200+ clusters). Pre-treatment balance: Census 2001 outcomes and nightlights 2000–2005.

**Why it's novel:**
- **Scale:** ~596,000 villages across all of India (vs. survey samples of <10K households in prior work)
- **Outcome:** Worker composition decomposition (cultivators vs ag labor vs HH industry vs non-farm) captures structural transformation directly — previous studies focus on wages or total employment
- **Method:** CS-DiD addresses well-documented TWFE bias with staggered timing (Goodman-Bacon 2021)
- **Gender × caste heterogeneity:** Census data allows testing whether MGNREGA differentially shifted SC/ST and female workers out of agricultural labor — a triple-difference design
- **Key tension:** Did MGNREGA accelerate structural transformation (by raising wages → mechanization → releasing labor) or retard it (by providing comfortable rural employment → reducing migration incentive)?

**Feasibility check:**
- Variation: 3 clean cohorts covering 200, 130, and ~310 districts with 5+ years pre-treatment nightlights ✓
- Data: SHRUG Census PCA (2001, 2011) + DMSP nightlights (1994–2013) all available locally ✓
- Novelty: No published paper uses SHRUG village-level Census with CS-DiD for MGNREGA's structural transformation effects ✓
- Sample: ~596K villages, 640+ districts → ample power ✓
- Phase assignment data: Available from Imbert & Papp (2015) replication data (openICPSR 113591) and government gazette notifications ✓

**Key references:** Imbert & Papp (2015 AEJ:Applied), Muralidharan et al. (2023 Econometrica), Cook & Shah (2020), Callaway & Sant'Anna (2021 JoE), Asher & Novosad (2020 AER)

---

## Idea 2: India's Demonetization and Rural Economic Activity: A Village-Level Intensity Design

**Policy:** On November 8, 2016, the Indian government demonetized 86% of currency in circulation (all ₹500 and ₹1000 notes). The shock was immediate, unexpected, and national.

**Outcome:** Village/district-level VIIRS nighttime lights (2012–2023, annual) as proxy for economic activity.

**Identification:** Cross-sectional intensity DiD. Pre-shock banking penetration (Census 2011 Village Directory: bank presence, ATM access) serves as the intensity variable — cash-dependent villages (no banks) experienced greater disruption than villages with banking access. Event study framework: treatment = interaction of post-November 2016 × low-banking-access.

**Why it's novel:**
- Village-level analysis using SHRUG nightlights (previous work uses aggregate district or state data)
- Long post-period (2017–2023) captures both short-run disruption and medium-run adaptation
- Banking access heterogeneity at village level (from Census VD) is a novel intensity measure

**Feasibility check:**
- Variation: National shock with cross-sectional intensity from village banking access ✓
- Data: VIIRS nightlights 2012–2023 at district level; Census 2011 banking variables ✓
- Novelty: Village-level demonetization study with nightlights is not published ✓
- Concern: Annual VIIRS may be too coarse to identify a Nov 2016 shock (previous studies used monthly satellite data)
- Concern: Only 28 state clusters for state-level banking policy variation

---

## Idea 3: MGNREGA and Female Human Capital Formation: Did Employment Guarantees Promote Girls' Education?

**Policy:** Same MGNREGA staggered rollout (2006–2008).

**Outcome:** Village-level female literacy rates and female-to-male literacy ratios from Census 2001 vs 2011.

**Identification:** Same staggered DiD as Idea 1 but focused on education outcomes. The mechanism: MGNREGA guaranteed adult employment → reduced economic pressure to withdraw children (especially girls) from school → improved female literacy. Alternative mechanism: MGNREGA increased child labor demand (substituting for adult labor diverted to public works) → reduced schooling.

**Why it's novel:**
- Village-level literacy outcomes for ~596K villages (vs. district-level or survey-based)
- Gender-specific effects with caste heterogeneity (SC/ST villages may show larger gains)
- Resolves contested results in literature: Adukia (2019) finds minimal effects; Sekhri & Li (2020) find negative effects. Village-level Census data can adjudicate.

**Feasibility check:**
- Variation: Same clean 3-cohort stagger ✓
- Data: Census PCA has literacy by gender at village level ✓
- Novelty: Village-level education effects using full Census not yet published ✓
- Concern: Only 2 time points (2001, 2011) — cannot trace dynamic year-by-year effects
- Concern: 5-year gap between MGNREGA onset (2006) and outcome measurement (2011) makes mechanism attribution harder

---

## Idea 4: PMGSY Rural Roads and Non-Farm Employment: Extending the Asher-Novosad RDD

**Policy:** Pradhan Mantri Gram Sadak Yojana (PMGSY) — India's rural road construction program. Villages with population ≥500 in plains (≥250 in hilly/tribal areas) were eligible for all-weather road connectivity.

**Outcome:** Village-level worker composition (cultivators vs non-farm workers) from Census 2001 vs 2011, plus nightlights.

**Identification:** Sharp RDD at the population eligibility threshold (500 for plains, 250 for tribal/hilly areas) using Census 2001 population as the running variable. Extend Asher & Novosad (2020 AER) who focused on broad economic outcomes — here, focus specifically on worker composition changes (structural transformation).

**Why it's novel:**
- Worker decomposition outcomes (not in Asher & Novosad 2020)
- Combination of RDD with nightlight dynamics (annual outcomes around the discontinuity)

**Feasibility check:**
- Variation: Sharp population threshold with extensive data ✓
- Data: Census PCA + population from SHRUG ✓
- Novelty: Worker composition at RDD threshold is an incremental extension of published AER paper
- Concern: Method is RDD, not DiD (user preference was DiD)
- Concern: Incremental rather than novel — Asher & Novosad (2020) is very close
