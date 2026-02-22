# Research Ideas

## Idea 1: Smaller States, Bigger Growth? Two Decades of Evidence from India's State Bifurcations

**Policy:** India's 2000 state trifurcation — Uttarakhand from Uttar Pradesh, Jharkhand from Bihar, and Chhattisgarh from Madhya Pradesh (all November 2000). Extension to Telangana from Andhra Pradesh (June 2014). These represent the most significant administrative decentralization events in India's post-independence history, affecting ~200 million people.

**Outcome:** SHRUG district-level nightlights (DMSP 1994–2013, VIIRS 2012–2023). Primary: calibrated total luminosity as proxy for economic activity (Henderson, Storeygard, Weil 2012). Secondary: Census 2001/2011 worker composition, literacy, amenities for mechanism analysis.

**Identification:** Staggered DiD comparing districts in newly created states vs remaining districts in parent states. 2000 cohort: 55 treated districts vs 159 control districts, with 6 pre-treatment years. 2014 cohort (Telangana): 10 treated vs 13 control with VIIRS panel. Use Callaway-Sant'Anna heterogeneity-robust estimator for staggered design. Reinforce with border discontinuity — compare villages/sub-districts near the new state boundary (within 50km) to isolate geographic proximity effects from statehood treatment.

**Why it's novel:** (1) No published peer-reviewed paper applies DiD to India's state bifurcations — Dhillon et al. (2015 working paper) used geographic discontinuity with older data; Vaibhav & Ramaswamy (2024 Indian Economic Review) used state-level synthetic control with only 28 units. (2) 23 years of post-treatment nightlights data reveals the full long-run trajectory — do new states converge with or diverge from parent states? (3) Village-level SHRUG data enables spatial analysis impossible at state level — did capital cities of new states boom while peripheries stagnated? (4) Staggered design (2000 + 2014) enables modern heterogeneity-robust methods. (5) Direct policy relevance: demands for Vidarbha, Gorkhaland, and other new states continue.

**Feasibility check:** Confirmed: 55+10 treated districts, 159+13 control districts; DMSP 1994–2013 + VIIRS 2012–2023 present locally; Census PCA available for 1991/2001/2011; state codes clearly identify treatment vs control. District assignment followed pre-existing regional boundaries (not economic selection). Few-clusters concern (8 state-level clusters for 2000 cohort) addressed via wild cluster bootstrap + randomization inference.

---

## Idea 2: Does District Proliferation Accelerate Development? Evidence from India's Administrative Fragmentation

**Policy:** India created 100+ new districts between 2001 and 2020 by splitting existing districts. New district headquarters bring closer government services, courts, and administrative capacity. The timing of splits varied across states and years, creating staggered treatment.

**Outcome:** SHRUG sub-district/district nightlights (DMSP + VIIRS). Census 2001 vs 2011 village amenities and worker composition.

**Identification:** DiD comparing sub-districts that became part of new districts vs sub-districts remaining in parent districts. Treatment: reclassification as part of a new district. Uses sub-district-level data for large sample sizes. Heterogeneity by distance to new district HQ tests the "closer government" mechanism.

**Why it's novel:** While state creation has received some attention, DISTRICT proliferation (a far more common event) is almost entirely unstudied with rigorous methods. Over 100 treated units gives excellent statistical power. Tests whether bureaucratic proximity drives development.

**Feasibility check:** Partially confirmed. SHRUG data available at sub-district level. BUT: need comprehensive list of district splits with exact dates and parent-child mappings. Wikipedia has partial lists; LGD (Local Government Directory) may have official records. Data construction is more complex than Idea 1. Higher execution risk.

---

## Idea 3: The GST Dividend — Did Tax Unification Boost Economic Activity?

**Policy:** Goods and Services Tax (GST) implemented July 1, 2017 — India's most significant tax reform, replacing a patchwork of cascading state/central taxes with a unified national framework.

**Outcome:** VIIRS nightlights at district level (2012–2023: 5 pre + 6 post years). State-level GST revenue collections (monthly, from GST Council press releases) as secondary outcome.

**Identification:** Event study with cross-sectional intensity variation. Intensity: pre-GST state tax revenue as share of GSDP (states with higher pre-reform tax burden experienced larger effective rate changes). VIIRS district-level nightlights capture spatial patterns of formalization. Triple-difference: high-tax-burden states × post-GST × districts with more informal economy activity (proxied by Census non-agricultural workers in household industry).

**Why it's novel:** GST's aggregate effects are studied, but district-level spatial patterns of economic formalization are not. The informal-to-formal transition is the key mechanism — GST incentivized formalization through input tax credit chains. Village/district nightlights can capture this shift at high spatial resolution.

**Feasibility check:** Partially confirmed. VIIRS data available 2012–2023 at district level. State-level GST revenue available from GST Council. BUT: pre-GST state tax revenue composition data needs web scraping from RBI DBIE (confirmed accessible). Only 5 pre-treatment years with VIIRS limits pre-trend testing. The intensity measure (pre-GST tax burden) requires careful construction from state fiscal data.
