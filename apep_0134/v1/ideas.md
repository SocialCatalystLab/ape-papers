# Research Ideas - Deep Discovery Mode

## Discovery Summary

Searched for: U.S. state(s) with amazing open government data + novel "wow factor" policy + within-state geographic variation + solid identification strategy.

**Key constraints from user:**
- Within-state variation (not cross-state DiD)
- "Wow factor" policy (drugs, attention-grabbing)
- Geocoded data is on the table
- Open to synthetic control, spatial methods

---

## Idea 1: America's First Supervised Drug Injection Sites and Neighborhood Overdose Deaths (NYC)

**Policy:** OnPoint NYC opened America's first two government-sanctioned overdose prevention centers (OPCs) on November 30, 2021 - one in East Harlem (104-106 E 126th St) and one in Washington Heights (500 W 180th St). Sharp temporal discontinuity. 6+ years pre-treatment data available.

**Outcome:** NYC DOHMH EpiQuery - Overdose deaths by UHF neighborhood (42 areas) × year, 2000-2024. Data briefs with neighborhood-level rates published through 2024. Published JAMA/NEJM studies provide data structure blueprint. NYU/Brown NIDA-funded study ongoing.

**Identification:** Spatial Difference-in-Differences OR Synthetic Control. Treated neighborhoods: East Harlem (UHF 103), Washington Heights (UHF 102). Control neighborhoods: High-overdose areas without OPCs (South Bronx, Brownsville, etc.). Pre-period: 2015-2021 (7 years). Post-period: 2022-2024 (3 years). Event study to verify parallel trends.

**Why Novel:** No rigorous causal evaluation of U.S. OPCs on mortality yet. Existing studies focus on crime (JAMA 2023), not deaths. Vancouver/Toronto studies show 35-69% reductions in surrounding neighborhoods - first U.S. test.

**Feasibility Check:**
- [x] Variation exists: Sharp geographic + temporal discontinuity
- [x] Data verified: NYC DOHMH EpiQuery has UHF-level mortality by year (accessed reports 2019-2024)
- [x] Novelty: Not in APEP; no synthetic control/DiD studies on U.S. OPCs and mortality
- [x] Power: 2,000+ overdose deaths/year citywide; treated neighborhoods had 80-90/100k rates

---

## Idea 2: Oregon Psilocybin "Opt-Out" Bans and Mental Health Outcomes

**Policy:** Oregon Measure 109 (2020) legalized psilocybin therapy with local opt-out provisions. By November 2024, 100+ jurisdictions banned psilocybin via ballot measures - creating sharp within-state geographic variation. First legal psychedelic therapy in U.S.

**Outcome:** Oregon Health Authority psilocybin data dashboard with client demographics and county of residence. Oregon vital statistics for county-level mortality. CDC WONDER county-level suicide/overdose. Oregon BRFSS for mental health days.

**Identification:** Staggered DiD with county/city ban votes as treatment. Pre-treatment: 2020-2022 (before service centers opened). Post-treatment: 2023-2025. Callaway-Sant'Anna estimator for staggered adoption. Alternative: Spatial RDD at county borders (opted-in vs. opted-out).

**Why Novel:** No economic evaluation of psilocybin therapy access ever published. Mental health effects of legal psychedelic access at population level never studied. 50%+ clients traveling from out of state creates "therapeutic tourism" angle.

**Feasibility Check:**
- [x] Variation exists: 100+ local bans vs. remaining allowed areas
- [x] Data verified: OHA dashboard accessible; county-level vital stats available via CDC WONDER
- [x] Novelty: Nothing on psilocybin in APEP; no causal studies
- [?] Power: Only ~15,000 clients so far; population-level effects may be undetectable

---

## Idea 3: Rhode Island's First State-Regulated OPC and Geographic Overdose Patterns

**Policy:** Rhode Island opened nation's first state-regulated overdose prevention center (not just city-tolerated) in January 2025 at 45 Willard Ave, Providence. Has explicit RIDOH oversight and state legislative authorization. Different regulatory model than NYC.

**Outcome:** RIDOH Opioid and Stimulant Use Data Hub on ArcGIS - census tract and ZIP code level overdose data. Rhode Island was first state with mandatory 48-hour overdose reporting (since 2016). Geocoded EMS incident data available.

**Identification:** Synthetic Control with Providence as treated unit. Donor pool: Similar RI cities (Pawtucket, Warwick, Cranston). Pre-period: 2016-2024 (9 years of excellent pre-treatment data). Post-period: 2025+. Alternative: Within-Providence spatial analysis (distance to OPC).

**Why Novel:** First evaluation of state-regulated (vs. city-tolerated) OPC model. Tests whether explicit state authorization affects outcomes differently. Rhode Island's unique mandatory reporting gives near-real-time granular data.

**Feasibility Check:**
- [x] Variation exists: Single OPC creates sharp geographic + temporal discontinuity
- [x] Data verified: RIDOH ArcGIS hub has geocoded data; 48-hour reporting confirmed operational
- [x] Novelty: No APEP or published studies on RI OPC
- [?] Power: RI has only ~330 overdose deaths/year statewide; may need micro-level analysis

---

## Idea 4: Naloxone Vending Machines and Neighborhood Overdose Deaths (Clark County, NV)

**Policy:** Clark County (Las Vegas) deployed public health vending machines (PHVMs) dispensing free naloxone starting in 2019. Three machines at specific locations. First program of its kind at scale. Program expanded 2020-2023.

**Outcome:** Nevada DPBH overdose mortality by county and ZIP code. Published study (Harm Reduction Journal 2022) documented 41 fewer deaths than forecasted in first 12 months. Vending machine dispensing logs available by location.

**Identification:** Synthetic Control with Clark County as treated unit. Donor pool: Washoe County (Reno), rural NV counties, or similar-sized counties nationally. Pre-period: 2015-2018 (4 years). Post-period: 2020-2024 (5 years post-launch). Alternative: Within-Clark-County analysis comparing neighborhoods near/far from machines.

**Why Novel:** Published study used simple ARIMA forecast comparison - not synthetic control or proper DiD. Can extend analysis with 5+ years of post-treatment data now available. Can apply rigorous econometric methods.

**Feasibility Check:**
- [x] Variation exists: Clear geographic + temporal variation with known machine locations
- [x] Data verified: Prior study published with data structure; CDC WONDER has county data
- [x] Novelty: Not in APEP; existing study was descriptive, not causal
- [x] Power: Clark County has 2.3M population; 400+ overdose deaths/year

---

## Idea 5: Fentanyl Test Strip Distribution Intensity and Overdose Deaths (Massachusetts)

**Policy:** Fentanyl test strips (FTS) legalized in Massachusetts. State distributes through harm reduction programs. County-level variation in distribution intensity. Massachusetts has exceptional EMS overdose tracking.

**Outcome:** Massachusetts MATRIS system - geocoded EMS opioid incident data by quarter from 2017. County-level FTS distribution data from BSAS. Opioid-related overdose dashboard with county/regional breakdown.

**Identification:** DiD exploiting variation in distribution intensity across counties. High-distribution vs. low-distribution areas. Pre-period: 2017-2021. Post-period: 2022-2024 (post-federal funding boost). Instrument: Distance to nearest harm reduction program distributing FTS.

**Why Novel:** FTS effectiveness contested in public health debate. No rigorous geographic evaluation linking distribution intensity to mortality. Massachusetts has uniquely good tracking on both sides (distribution and outcomes).

**Feasibility Check:**
- [x] Variation exists: Known county-level variation in distribution intensity
- [x] Data verified: MA BSAS dashboard confirmed; MATRIS EMS data available via request
- [x] Novelty: Not in APEP; limited causal studies on FTS
- [?] Power: Endogeneity concern - FTS distributed where overdoses highest (reverse causality)

---

## Idea 6: Colorado Psychedelic "Healing Centers" and Municipal Zoning Workarounds

**Policy:** Colorado Proposition 122 (2022) legalized psilocybin therapy statewide with no local opt-out allowed. However, cities are using zoning restrictions as backdoor bans. Colorado Springs voted restrictive zoning in 2024. Parker and Castle Rock created similar ordinances.

**Outcome:** Colorado DORA licensing data for healing center applications (accepting since Dec 2024). Colorado vital statistics for county/municipal mental health indicators. Colorado BRFSS for depression/anxiety prevalence.

**Identification:** Staggered DiD with municipal zoning restrictions as treatment. Cities imposing restrictive zoning vs. cities allowing healing centers. Pre-period: 2022-2024 (before centers open). Post-period: 2025+.

**Why Novel:** Unique angle: zoning as de facto drug policy despite explicit state preemption. Tests whether local regulatory barriers affect access and outcomes. No research on this yet.

**Feasibility Check:**
- [x] Variation exists: Sharp municipal zoning variation documented
- [?] Data not yet available: Healing centers just opening Dec 2024 - no outcome data yet
- [x] Novelty: Nothing published
- [?] Power: Too early to evaluate

---

## Rankings

| Rank | Idea | Score | Rationale |
|------|------|-------|-----------|
| 1 | NYC OPCs | A | Maximum wow factor + exceptional data + clean ID + high power |
| 2 | Clark County Naloxone VMs | B+ | Extends existing study with rigorous methods + 5yr post-treatment |
| 3 | Rhode Island OPC | B+ | Excellent data but too recent (Jan 2025) |
| 4 | Oregon Psilocybin | B | Novel but underpowered for population effects |
| 5 | MA Fentanyl Test Strips | B- | Endogeneity concerns with distribution targeting |
| 6 | Colorado Psychedelics | C | Too early - no outcome data yet |

**RECOMMENDATION:** Pursue Idea 1 (NYC Overdose Prevention Centers) as primary. Idea 4 (Clark County Naloxone Vending Machines) as backup if NYC data proves insufficient.
