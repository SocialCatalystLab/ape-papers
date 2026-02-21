# Research Ideas

## Idea 1: Multi-Level Political Alignment and Local Development in India's Federal System

**Policy:** India's federal system creates complex political alignment dynamics. When a state assembly constituency elects an MLA whose party also controls the state government, the constituency is "state-aligned." When the MLA's party also controls the central government, the constituency is "center-aligned." When both conditions hold simultaneously, the constituency is "doubly aligned." The dramatic rise of BJP dominance since 2014 — winning a parliamentary majority alone for the first time in 30 years — transformed center-state dynamics and created unprecedented variation in multi-level alignment across India's ~4,000 assembly constituencies.

**Outcome:** SHRUG Assembly Constituency–level VIIRS nightlights (2012–2023), annual frequency. Secondary outcomes: Census 2011 baseline demographics and amenities at AC level.

**Identification:** Close-election regression discontinuity design (Lee 2008). In state assembly elections where the ruling party candidate and the leading opposition candidate are the top-two finishers, the vote margin serves as the running variable. Treatment: the ruling party candidate wins. The RDD identifies the causal effect of alignment on nightlights growth. The multi-level dimension comes from comparing:

- State-aligned only (MLA party = state ruling party ≠ central ruling party)
- Center-aligned only (MLA party = central ruling party ≠ state ruling party)
- Doubly aligned (MLA party = both state AND central ruling party)
- Unaligned (MLA party = neither)

Dynamic effects traced year-by-year over the 5-year election cycle using VIIRS annual panel.

**Why it's novel:**
1. Asher & Novosad (2017 AEJ:Applied) studied single-level state alignment with DMSP nightlights (1992–2012). This paper extends to **multi-level alignment** (state + center), uses **VIIRS** (higher resolution, no top-coding), and covers the **post-2014 Modi era** — a fundamentally different political landscape.
2. The center-state alignment interaction is the core theoretical contribution: does double alignment create super-additive development benefits through fiscal federalism channels?
3. Dynamic treatment effects over the election cycle (year-by-year using annual VIIRS) add temporal granularity absent from prior work.
4. Speaks to the comparative fiscal federalism literature (Brazil: Brollo & Nannicini 2012; Pakistan: Callen et al. 2020).

**Feasibility check:**
- Confirmed: SHRUG has AC-level VIIRS nightlights for 4,080 ACs, 2012–2023 (viirs_annual_con07.csv)
- Confirmed: Harvard Dataverse (doi:10.7910/DVN/26526) has candidate-level state election data 1977–2015; TCPD LokDhaba covers 2015–present
- Confirmed: State ruling party and central ruling party identifiable from public records
- Sample size: ~4,080 ACs × ~3 election cycles (2012–2023) = ~12,000 constituency-elections; after restricting to close races (10% bandwidth), ~2,000–4,000 observations
- McCrary density test applicable for manipulation check
- Pre-election nightlights provide built-in balance check


## Idea 2: Does Road Connectivity Catalyze Enterprise Formation? Evidence from India's PMGSY

**Policy:** The Pradhan Mantri Gram Sadak Yojana (PMGSY) provides all-weather road connectivity to habitations exceeding a population threshold: 500 in plain areas, 250 in hills/tribal/desert areas. Launched in 2000 with continuous construction through 2024.

**Outcome:** SHRUG Economic Census firm counts and employment (EC 2005, EC 2013) at village level. Primary outcome: number of non-agricultural establishments (ec13_count_all). Secondary: female employment in enterprises (ec13_emp_f), sectoral composition (manufacturing vs. services).

**Identification:** Sharp RDD at the 500-person population threshold (plain areas). Running variable: Census 2001 village population. Treatment: eligibility for PMGSY road construction. Estimate effects on firm formation by comparing villages just above and just below the threshold. Use the 250-person threshold for tribal/hill areas as a robustness/replication exercise.

**Why it's novel:**
1. Asher & Novosad (2020 AER) studied PMGSY's effects on consumption, occupation, and transport. Existing APEP papers (0428–0432) studied tribal development, gender gaps, and education. **None studied firm/enterprise formation as the primary outcome.**
2. Enterprise formation is the mechanism through which road connectivity drives structural transformation — this tests the intensive margin (more firms per village) rather than the extensive margin (more workers switching sectors).
3. Uses Economic Census 2005 (pre-PMGSY for many villages) and EC 2013 (post-PMGSY) for a clean before/after comparison within the RDD framework.
4. The 500 vs. 250 threshold comparison allows testing whether roads have heterogeneous effects by remoteness.

**Feasibility check:**
- Confirmed: SHRUG has Census 2001 population at SHRID level (pc01_pca_clean_shrid.csv, ~589K rural SHRIDs)
- Confirmed: SHRUG has EC 2005 and EC 2013 firm counts at SHRID level (shrug_ec05, shrug_ec13 — need to verify these specific files are downloaded)
- Need to verify: EC data files present locally. If not, download from SHRUG portal
- Sample: ~47K villages in the 2K–8K population range; ~8K in the narrow bandwidth around 500
- Risk: 5th PMGSY paper in APEP; judges may penalize repetition. Mitigated by genuinely novel outcome variable.


## Idea 3: India's Aspirational Districts Programme: Does Bureaucratic Attention Drive Development?

**Policy:** In January 2018, NITI Aayog designated 112 districts as "Aspirational Districts" based on a composite index of 49 indicators across 5 themes (Health, Education, Agriculture, Financial Inclusion, Infrastructure). Selected districts received: intensive central monitoring, dedicated officers, priority in central scheme implementation, and inter-district competition/ranking. The programme aims to improve India's most backward districts through accountability and coordination rather than additional funding.

**Outcome:** VIIRS nightlights at district level (2012–2023), with 2012–2017 as pre-treatment and 2018–2023 as post-treatment. Secondary outcomes: UDISE+ education data (enrollment, infrastructure), NFHS-5 health indicators.

**Identification:** RDD at the composite index cutoff. NITI Aayog computed a "backwardness" index for all ~740 districts; the bottom 112 were selected (with one-per-state constraint). The running variable is the composite index, and the treatment is programme designation. Need to either: (a) obtain the full index from NITI Aayog/Champions of Change portal, or (b) reconstruct it from the 49 component indicators.

**Why it's novel:**
1. **First RDD study on this programme.** Existing evaluations (Agarwal & Mishra 2024; Das, Gupta & Singhal 2025) use DiD and PSM-DiD. An RDD at the selection cutoff would provide cleaner causal identification.
2. Tests the "bureaucratic attention" hypothesis: can monitoring and accountability alone (without additional resources) drive development?
3. Six years of post-treatment nightlights data (2018–2023) provides substantial time for effects to materialize.
4. The programme's theory of change — competition between districts, real-time dashboards, named central officers — represents a novel governance mechanism being tried at scale.

**Feasibility check:**
- Partially confirmed: NITI Aayog published baseline rankings for 112 selected districts (PDF available). Scores for all ~740 districts not confirmed publicly available.
- Confirmed: VIIRS nightlights available at district level (viirs_annual_pc11dist.csv in SHRUG or aggregable from SHRID level)
- Risk: the one-per-state constraint means some districts were included regardless of their index score (they were the worst in their state, but might not be below the national cutoff). This complicates the RDD — need to either restrict to states with multiple Aspirational Districts or use a within-state cutoff.
- Risk: composite index may need reconstruction from 49 components. This is feasible but adds substantial data work.
- Sample: 112 treated, ~630 untreated. In the RDD bandwidth, perhaps 50–100 observations. Low power is a concern.


## Idea 4: Bihar's Alcohol Prohibition and Local Economic Activity: A Border Discontinuity Design

**Policy:** Bihar implemented total alcohol prohibition in April 2016 under the Bihar Prohibition and Excise Act. All manufacture, sale, and consumption of alcohol was banned. Bihar borders Jharkhand, West Bengal, Uttar Pradesh, and Nepal — creating sharp policy discontinuities at state borders where alcohol remains legal on the other side.

**Outcome:** VIIRS nightlights at village level (2012–2023), with 2012–2015 as pre-prohibition and 2016–2023 as post-prohibition. Secondary: nightlights at district level for border districts.

**Identification:** Spatial RDD at Bihar's state borders. Compare villages/districts immediately inside Bihar (treated: prohibition) with those immediately outside (control: alcohol legal). Distance to the state border serves as the running variable. The identifying assumption is that villages on either side of the border were on similar economic trajectories before April 2016.

**Why it's novel:**
1. **First spatial RDD at an Indian state border.** The border discontinuity design (Dell 2010; Dube, Lester & Reich 2010) is well-established in US/Latin American contexts but has not been applied to Indian state-level policy variation.
2. Tests whether prohibition helps or hurts local economies — a contentious question with limited causal evidence from developing countries.
3. Eight years of post-prohibition VIIRS data (2016–2023) enables studying dynamic effects: did economic activity recover after the initial shock?

**Feasibility check:**
- SHRUG has village-level VIIRS nightlights (viirs_annual_shrid.csv, 1.6GB). However, CSV files do NOT include latitude/longitude coordinates.
- **Critical barrier:** Need geographic coordinates or shapefiles to compute distance to state border. SHRUG distributes shapefiles separately from the portal. This requires additional download and spatial processing in R (using sf/sp packages).
- District-level version feasible without coordinates: compare Bihar border districts to neighboring-state border districts. But district-level analysis has ~20 observations per side — potentially underpowered.
- If shapefiles obtainable, village-level analysis is very well-powered (thousands of villages near the border).
- Risk: data access to shapefiles uncertain; spatial processing adds complexity.
