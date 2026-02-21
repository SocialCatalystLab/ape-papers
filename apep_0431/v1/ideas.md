# Research Ideas

## Idea 1: Roads to Equality? Gender-Differentiated Effects of Rural Infrastructure on Structural Transformation in India

**Policy:** Pradhan Mantri Gram Sadak Yojana (PMGSY) — India's massive rural road construction program (2000–present, $40B+). Habitations above 500 population (plains) or 250 (special category states/tribal/desert) receive priority road construction.

**Outcome:** (a) Gender-disaggregated structural transformation: Census 2001 vs 2011 worker classification by sex — female share in non-agricultural employment (main_ot_f, main_hh_f) relative to agricultural work (main_cl_f, main_al_f). (b) Dynamic economic activity: Annual village-level nightlights (DMSP 1994–2013, VIIRS 2012–2023) — 30 years of panel data.

**Identification:** Sharp/fuzzy RDD at the 500 population threshold (plain-area states only for clean design). Running variable: Census 2001 village population. Asher & Novosad (2020 AER) showed villages above threshold are 22pp more likely to receive roads. I estimate the reduced-form effect of crossing the eligibility threshold on gender-specific labor outcomes and dynamic nightlights trajectories.

**Why it's novel:** Two novel contributions beyond Asher & Novosad (2020): (1) Gender-differentiated structural transformation — do roads differentially help women escape agriculture? Lei, Desai & Vanneman (2019 Feminist Economics) found positive effects but used panel FE, not RDD. Nobody has combined the credible PMGSY threshold design with gender-specific outcomes. (2) Dynamic year-by-year RDD — instead of comparing Census cross-sections, I trace the full causal trajectory using annual nightlights. When do road effects materialize? Do they accelerate or plateau?

**Feasibility check:** Confirmed: (a) SHRUG has Census 2001/2011 PCA with gender-disaggregated worker variables at village level (591K rural villages). (b) Annual nightlights (DMSP + VIIRS) at village level, 1994–2023. (c) State codes allow identifying plain vs special-category states for correct threshold. (d) Reduced-form design requires no additional data beyond SHRUG. (e) Population threshold well-established by Asher & Novosad replication package.


## Idea 2: When Infrastructure Meets Education: Dynamic Returns to Rural Roads in India

**Policy:** Same PMGSY program and threshold as Idea 1.

**Outcome:** Annual nightlights 1994–2023 at village level (SHRUG DMSP + VIIRS). Focus entirely on the dynamic dimension: estimate year-by-year RDD treatment effects to trace the temporal path of road investment returns.

**Identification:** RDD at 500 population threshold (plains). Estimate: RDD(year t) = f(population crossing 500 | year = t) for each t = 1994–2023. Pre-PMGSY years (1994–1999) serve as placebo. Post-construction years (2002–2023) trace the dynamic treatment path. PMGSY started in 2000 and construction was phased over 2001–2010.

**Why it's novel:** Asher & Novosad (2020) estimated a single static effect by comparing Census 2001 to 2011. Annual nightlights allow me to identify: (a) lag between road construction and economic impact, (b) whether effects are permanent or temporary, (c) whether effects accelerate or plateau, (d) heterogeneous dynamics by baseline development level. This is a methodological contribution applicable to any infrastructure RDD.

**Feasibility check:** Confirmed: All data available in local SHRUG installation. 591K rural villages × 30 years of nightlights. Reduced form requires Census 2001 population and annual nightlights only.


## Idea 3: Competitive Federalism and Local Development: RDD Evidence from India's Aspirational Districts Programme

**Policy:** Aspirational Districts Programme (ADP), launched January 2018 by NITI Aayog. 112 districts identified as most underdeveloped based on a composite backwardness index (49 KPIs across health, education, agriculture, financial inclusion, infrastructure). Districts receive intensive monitoring, central officer oversight, competitive rankings, and additional resources.

**Outcome:** Annual nightlights (VIIRS 2012–2023) at district level; potentially UDISE+ education data and NFHS-5 health indicators for mechanism analysis.

**Identification:** RDD at the selection threshold: districts just above vs just below the composite backwardness index cutoff that determined the 112 ADP districts. Running variable: NITI Aayog composite index ranking. Compare barely-selected "aspirational" districts with barely-not-selected districts of similar baseline development.

**Why it's novel:** (1) First RDD evaluation of ADP — existing studies (Agarwal & Mishra 2024) use DiD/descriptive methods. (2) Tests the "competitive federalism" hypothesis: does publishing district rankings create a tournament incentive that drives improvement? (3) Policy-relevant: India expanded ADP to "Aspirational Blocks Programme" in 2023, making the evaluation timely.

**Feasibility check:** MEDIUM RISK. The composite index scores for ALL districts (not just the 112) may not be publicly available, which would prevent constructing the running variable. The Champions of Change dashboard tracks selected districts but may not publish non-selected district scores. Need to verify data access before committing. District-level nightlights and SHRUG data are available.


## Idea 4: Does Political Alignment Channel Public Resources? Close Election Evidence from Indian State Assemblies

**Policy:** State government resource allocation via politically aligned state legislators (MLAs). When an MLA belongs to the same party as the state's chief minister, their constituency may receive preferential treatment through discretionary development spending, faster project approvals, and bureaucratic responsiveness.

**Outcome:** District-level nightlights growth (VIIRS), Census development indicators, and potentially MGNREGA implementation quality (person-days generated, expenditure) linked to assembly constituencies.

**Identification:** Close election RDD using vote margin between winning and losing candidates. Treatment: winning candidate belongs to ruling party. Compare constituencies where ruling-party candidate barely won vs barely lost. Running variable: ruling-party candidate's vote margin (centered at 0).

**Why it's novel:** Prior work on India political alignment (Lehne et al. 2018 JDE) focused on road construction corruption under PMGSY. Broader studies of alignment effects on nightlights exist but are limited in scope. Novel angle: focus on MGNREGA implementation quality as the mechanism — alignment → bureaucratic cooperation → better NREGA delivery → development. MGNREGA is demand-driven in theory but implementation depends on state bureaucracy.

**Feasibility check:** MEDIUM. Datameet GitHub repository has Indian state assembly election data (CSV format, candidate-level). TCPD has cleaned election data. Need to verify: (a) constituency-to-SHRUG mapping works reliably, (b) vote margin data is available at candidate level, (c) MGNREGA MIS district data is scrapeable. The close election RDD for India is well-established in the literature (Prakash et al. 2019 JDE).
