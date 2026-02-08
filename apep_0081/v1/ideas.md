# Research Ideas

## Paper 108: Descriptive Data Paper

### Idea 1: Geocoded Atlas of US Traffic Fatalities (SELECTED)

**Title:** Roads, Crashes, and Substances: A Geocoded Atlas of US Traffic Fatalities 2001-2023

**Research Question:** Can we create an integrated dataset combining FARS crash data with OpenStreetMap road networks and marijuana policy timing to enable high-resolution spatial analysis of impaired driving?

**Data Sources:**
- FARS (NHTSA): 2001-2023 fatal crashes with lat/lon coordinates
- OpenStreetMap: Road network attributes (highway type, speed limits, lanes)
- Harvard Dataverse: Marijuana legalization policy timing

**Identification Strategy:** Descriptive data paper - no causal claims. Documents patterns at marijuana legalization borders to motivate future spatial RDD research.

**Feasibility Assessment:**
- Data availability: HIGH - FARS is publicly available, OSM is open source
- Sample size: HIGH - ~200,000 geocoded crashes in Western states
- Novelty: HIGH - First comprehensive FARS + OSM integration
- Policy relevance: HIGH - Marijuana legalization is a major policy question

**Status:** IMPLEMENTED

---

### Idea 2: Spatial RDD at Marijuana Borders (Alternative)

**Title:** The Geography of Impaired Driving: Spatial RDD at Marijuana Legalization Borders

**Research Question:** Does recreational marijuana legalization increase THC-involved fatal crashes at state borders?

**Identification Strategy:** Spatial regression discontinuity at state borders separating legal and illegal jurisdictions.

**Feasibility Assessment:**
- Requires more extensive border distance computation
- Causal claims require stronger assumptions
- Better suited as follow-up to data paper

**Status:** NOT SELECTED - Data paper provides foundation for this future work

---

### Idea 3: THC-Alcohol Substitution Analysis (Alternative)

**Title:** Substitution or Complement? THC and Alcohol in Fatal Crashes

**Research Question:** Does marijuana legalization lead to substitution from alcohol to THC in impaired driving?

**Identification Strategy:** Difference-in-differences comparing substance involvement patterns before/after legalization.

**Feasibility Assessment:**
- Drug testing selection is a major concern
- Requires careful handling of poly-substance involvement
- Better suited as focused follow-up study

**Status:** NOT SELECTED - Descriptive patterns documented in data paper
