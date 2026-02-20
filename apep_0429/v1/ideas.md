# Research Ideas

## Idea 1: The Governance Gap — Census Town Classification and India's Subaltern Urbanization

**Policy:** Census Town classification at the population 5,000 threshold. Between 2001 and 2011, India's Census Towns surged from ~1,362 to ~3,894 as settlements met urban criteria (population ≥ 5,000, density ≥ 400/sq km, ≥ 75% male non-agricultural workers) but remained governed as rural panchayats — the "governance gap." This is a fuzzy RDD where crossing 5,000 in Census 2001 sharply increases the probability of urban classification.

**Outcome:** SHRUG nightlights (DMSP 1992–2013, VIIRS 2012–2021) for annual economic activity; Census PCA changes 2001–2011 for workforce transformation (agricultural → non-agricultural employment), literacy, and female labor force participation. Town Directory (for settlements classified as urban) provides rich amenity data.

**Identification:** Fuzzy RDD using Census 2001 population as the running variable with a threshold at 5,000. First stage: population ≥ 5,000 predicts urban (Census Town) classification. Outcome: nightlights growth and Census PCA changes. The design exploits the fact that Census Town status is mechanically linked to the 5,000 threshold (plus density and employment criteria), creating a fuzzy discontinuity. McCrary test for manipulation; covariate balance at threshold; bandwidth sensitivity with rdrobust.

**Why it's novel:** No published RDD exists at the Census Town population threshold. Contributes to the "subaltern urbanization" debate (Denis, Mukhopadhyay & Zérah 2012; Pradhan 2013). Policy-relevant: India's 74th Amendment intended urban governance for urban areas, but Census Towns are governed as villages despite being statistically urban. A null result (classification doesn't matter for development) is itself an important finding.

**Feasibility check:** Confirmed: ~8,200 settlements within ±500 of the 5,000 threshold in Census 2001. 3,025 settlements transitioned from rural (2001) to urban (2011). Population (running variable), nightlights (outcome), and Census PCA (covariates/outcomes) all available in SHRUG data on disk. Can compute density using pc11_land_area from rural key files. Can compute non-agricultural employment share from PCA workforce data.


## Idea 2: The Long Arc of Rural Roads — Dynamic Treatment Effects of PMGSY Over Two Decades

**Policy:** Pradhan Mantri Gram Sadak Yojana (PMGSY), India's flagship rural road program (launched 2000). Villages in plain areas with population ≥ 500 (Census 2001) are eligible for all-weather road connectivity. The population threshold creates a sharp RDD.

**Outcome:** SHRUG nightlights at village level — DMSP (1992–2013) and VIIRS (2012–2021) — providing annual economic activity measures spanning the full pre- and post-treatment period. Census PCA changes (2001–2011) for workforce composition, literacy, and demographic outcomes.

**Identification:** Sharp RDD at population 500 using Census 2001 village population as the running variable. Novel dynamic extension: instead of estimating a single RDD coefficient, trace the ANNUAL treatment effect over 20 years (2001–2021) using nightlights. This "dynamic RDD" estimates heterogeneous treatment effects at different post-treatment horizons: do road effects emerge immediately, accumulate gradually, plateau, or decay? Asher & Novosad (2020, AER) could only observe two Census snapshots (2001, 2011); nightlights provide the complete annual trajectory.

**Why it's novel:** Extends Asher & Novosad (2020, AER) — the definitive PMGSY RDD paper — with 10 additional years of post-2011 nightlights data. The dynamic treatment effect profile is a genuinely new contribution: infrastructure literature assumes effects are persistent, but this is rarely tested empirically. Also differs from apep_0428 (which uses the 250 threshold in tribal areas).

**Feasibility check:** Confirmed: ~75,800 settlements within ±100 of the 500 threshold in Census 2001. Nightlights data on disk (DMSP 1992–2013, VIIRS 2012–2021). Census PCA for 1991/2001/2011 on disk. Massive sample ensures excellent power even with narrow bandwidths.


## Idea 3: Breaking the Poverty Trap? Long-Run Effects of MGNREGA Phase I Assignment

**Policy:** MGNREGA Phase I (Feb 2006) was assigned to India's 200 "most backward" districts based on a backwardness index computed by the Planning Commission (2003). Phase II added 130 districts (Apr 2007), and Phase III covered all remaining districts (Apr 2008). The cutoff between Phase I and Phase II districts at the backwardness index threshold creates an RDD.

**Outcome:** District-level nightlights (2000–2021) from SHRUG, providing 15+ years of annual post-treatment data for Phase I districts and 14+ years for Phase II. Census 2001–2011 district-level changes in population, literacy, workforce composition.

**Identification:** RDD at the within-state backwardness index cutoff between Phase I (200 most backward) and Phase II (next 130) districts. Following Zimmermann (2012), center the running variable at each state's Phase I cutoff. The 2-year head start (2006 vs 2008) in MGNREGA access is the treatment. Novel: 15 years of annual nightlights data trace whether early access creates persistent advantages (path dependence) or whether late-access districts catch up (convergence).

**Why it's novel:** Zimmermann (2012) used this RDD with limited outcome data (NSS rounds). With SHRUG nightlights, we can study the COMPLETE dynamic path: did Phase I's 2-year head start create lasting development advantages? This speaks to whether employment guarantee programs have multiplier effects (investment in local infrastructure, human capital accumulation) or merely provide temporary income transfers. Also tests the "Big Push" hypothesis at district level.

**Feasibility check:** Partially confirmed. Running variable (backwardness index) must be reconstructed from Census 2001 district-level data (SC/ST share, agricultural labor share available in SHRUG; agricultural wages/productivity need supplementation from ICRISAT). District-level nightlights on disk. ~640 districts total, with ~200/130/310 split across phases. Power may be limited with ~330 districts near the Phase I/II cutoff.


## Idea 4: Does Political Alignment Bring Development? A Village-Level Close Election RDD for Indian State Assemblies

**Policy:** In India's first-past-the-post state assembly elections, the ruling party's candidate winning vs. losing a constituency determines whether the constituency has a representative aligned with the state government. Aligned constituencies may receive more resources through discretionary development funds, better implementation of state schemes, and political favoritism.

**Outcome:** SHRUG village-level nightlights (annual, 1992–2021) aggregated to constituency level. Census PCA changes at constituency level (2001–2011).

**Identification:** Close-election RDD using vote margin (winner vote share minus runner-up vote share) as the running variable, at the zero threshold. In close elections, whether the ruling party's candidate barely wins or barely loses is quasi-random. Compare constituencies where the ruling party's candidate won by small margins to those where they lost by small margins. Outcomes: nightlights growth in the subsequent inter-election period.

**Why it's novel:** While close-election RDDs have been used for India (Bhalotra, Clots-Figueras, Iyer — various papers), the village-level granularity from SHRUG nightlights is novel. Previous studies used constituency-level or district-level outcomes. Also, the alignment question specifically (does matching the state ruling party matter?) is understudied at village resolution compared to party identity effects.

**Feasibility check:** Partially confirmed. TCPD (Trivedi Centre for Political Data, Ashoka University) provides state assembly election results with vote counts since 1962 — confirmed accessible at tcpd.ashoka.edu.in. SHRUG v2.1 includes corrected Assembly Constituency definitions for geographic linkage. Challenge: TCPD data download requires JavaScript interface (Lok Dhaba portal); need to test bulk download capability. Election data processing (identifying ruling party at time of each election, computing margins) adds complexity.
